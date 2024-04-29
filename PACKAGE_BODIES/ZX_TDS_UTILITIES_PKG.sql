--------------------------------------------------------
--  DDL for Package Body ZX_TDS_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_UTILITIES_PKG" as
/* $Header: zxdiutilitiespub.pls 120.44.12010000.3 2009/04/22 12:11:56 msakalab ship $ */

g_current_runtime_level      NUMBER;
g_level_statement            CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_unexpected           CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

----------------------------------------------------------------------
--  PUBLIC FUNCTION
--  get_tax_status_index
--
--  DESCRIPTION
--
--  This function returns the hash table index from global tax
--  status cache structure
--

FUNCTION get_tax_status_index(
            p_tax               IN         ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code   IN         ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax_status_code   IN         ZX_STATUS_B.TAX_STATUS_CODE%TYPE)
RETURN BINARY_INTEGER IS

  l_tbl_index      BINARY_INTEGER;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_status_index.BEGIN',
                   'ZX_TDS_UTILITIES_PKG: get_tax_status_index(+)');
  END IF;

  l_tbl_index := dbms_utility.get_hash_value(
                p_tax_regime_code||p_tax||p_tax_status_code,
                1,
                8192);

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_status_index.END',
                   'ZX_TDS_UTILITIES_PKG: get_tax_status_index(-)'||
                    'tbl index = ' || to_char(l_tbl_index));

  END IF;

  return l_tbl_index;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_status_index',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    RAISE;
END get_tax_status_index;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_tax_status_cache_info
--
--  DESCRIPTION
--  This procedure gets tax status information from global cache structure
--  based on the hash index of Tax, Tax regime code and Tax status code if
--  exists, if not, obtain the Tax status information from the database
--
PROCEDURE  get_tax_status_cache_info(
             p_tax                 IN     ZX_TAXES_B.TAX%TYPE,
             p_tax_regime_code     IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
             p_tax_status_code     IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
             p_tax_determine_date  IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
             p_status_rec             OUT NOCOPY ZX_STATUS_INFO_REC,
             p_return_status          OUT NOCOPY VARCHAR2,
             p_error_buffer           OUT NOCOPY VARCHAR2)

IS
  l_index              BINARY_INTEGER;

  CURSOR get_status_info_csr
    (c_tax_status_code         ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
     c_tax                     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_regime_code         ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_determine_date      ZX_LINES.TAX_DETERMINE_DATE%TYPE)
  IS
    SELECT tax_status_id,
           tax_status_code,
           tax,
           tax_regime_code,
           effective_from,
           effective_to,
           Rule_Based_Rate_Flag,
           Allow_Rate_Override_Flag,
--           Allow_Adhoc_Tax_Rate_Flag, -- commented out for bug 3420310
           Allow_Exemptions_Flag,
           Allow_Exceptions_Flag
      FROM  ZX_SCO_STATUS_B_V
      WHERE TAX_STATUS_CODE = c_tax_status_code      AND
            TAX             = c_tax                  AND
            TAX_REGIME_CODE = c_tax_regime_code      AND
            c_tax_determine_date >= EFFECTIVE_FROM   AND
            (c_tax_determine_date <= EFFECTIVE_TO OR
             EFFECTIVE_TO IS NULL)
        -- AND rownum = 1;
        ORDER BY subscription_level_code;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info.BEGIN',
                   'ZX_TDS_UTILITIES_PKG: get_tax_status_cache_info(+)'||
                   ' regime code: ' || p_tax_regime_code||
                   ' status code: ' || p_tax_status_code||
                   ' tax: ' || p_tax);
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  l_index := get_tax_status_index(p_tax,
                                  p_tax_regime_code,
                                  p_tax_status_code);
  --
  -- first check if the status info is available from the cache
  --
  IF g_tax_status_info_tbl.EXISTS(l_index) AND
     p_tax_determine_date >= g_tax_status_info_tbl(l_index).effective_from AND
     p_tax_determine_date <= NVL(g_tax_status_info_tbl(l_index).effective_to,
                                                          p_tax_determine_date)
  THEN

    p_status_rec := g_tax_status_info_tbl(l_index);

  ELSE
    --
    -- status info does not exist in cache, get it from zx_status
    --
    OPEN get_status_info_csr(p_tax_status_code,
                             p_tax,
                             p_tax_regime_code,
                             p_tax_determine_date);
    FETCH get_status_info_csr  INTO
       p_status_rec.tax_status_id,
       p_status_rec.tax_status_code,
       p_status_rec.tax,
       p_status_rec.tax_regime_code,
       p_status_rec.effective_from,
       p_status_rec.effective_to,
       p_status_rec.Rule_Based_Rate_Flag,
       p_status_rec.Allow_Rate_Override_Flag,
--       p_status_rec.Allow_Adhoc_Tax_Rate_Flag,  -- commented out for bug 3420310
       p_status_rec.Allow_Exemptions_Flag,
       p_status_rec.Allow_Exceptions_Flag;

    IF get_status_info_csr%NOTFOUND THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer  := 'No data found for the specified tax status code';

      FND_MESSAGE.SET_NAME('ZX','ZX_TAX_STATUS_INFO_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('TAX_REGIME',p_tax_regime_code);
      FND_MESSAGE.SET_TOKEN('TAX_CODE', p_tax );
      FND_MESSAGE.SET_TOKEN('TAX_STATUS', p_tax_status_code);

      -- FND_MSG_PUB.Add;
      ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

    END IF;

    CLOSE get_status_info_csr;

    -- update the global status cache structure
    --
    IF p_return_status =  FND_API.G_RET_STS_SUCCESS THEN
      g_tax_status_info_tbl(l_index) := p_status_rec;
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info',
                   'Return_status = ' || p_return_status||
                   ' tax_status_id = ' ||
                    to_char(p_status_rec.tax_status_id)||
                   ' Rule_Based_Rate_Flag = ' ||
                    p_status_rec.Rule_Based_Rate_Flag||
                   ' Allow_Rate_Override_Flag = ' ||
                    p_status_rec.Allow_Rate_Override_Flag||
                   ' Allow_Exemptions_Flag = ' ||
                    p_status_rec.Allow_Exemptions_Flag||
                   ' Allow_Exceptions_Flag = ' ||
                    p_status_rec.Allow_Exceptions_Flag);

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info.END',
                   'ZX_TDS_UTILITIES_PKG: get_tax_status_cache_info(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF get_status_info_csr%ISOPEN THEN
      CLOSE get_status_info_csr;
    END IF;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info',
                      p_error_buffer);
    END IF;

END get_tax_status_cache_info;

--------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_tax_regime_cache_info
--
--  DESCRIPTION
--  This procedure gets tax regime information from global cache
--  structure based on tax regime code, if regime exists in it.
--  If regime does not exist, get tax regime information from the database
--------------------------------------------------------------------------
PROCEDURE get_regime_cache_info (
  p_tax_regime_code     IN          zx_regimes_b.tax_regime_code%TYPE,
  p_tax_determine_date  IN          DATE,
  p_tax_regime_rec      OUT NOCOPY  zx_global_structures_pkg.tax_regime_rec_type,
  p_return_status       OUT NOCOPY  VARCHAR2,
  p_error_buffer        OUT NOCOPY  VARCHAR2) IS

  CURSOR  get_regime_info_csr IS
   SELECT regime_precedence,
          tax_regime_id,
          tax_regime_code,
          parent_regime_code,
          country_code,
          geography_type,
          geography_id,
          effective_from,
          effective_to,
          country_or_group_code
     FROM ZX_REGIMES_B_V
    WHERE tax_regime_code = p_tax_regime_code
      AND (( effective_from <= p_tax_determine_date) AND
           ( effective_to   >= p_tax_determine_date OR effective_to IS NULL));

 l_in_cache_flg         BOOLEAN         := FALSE;
 l_index                NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_regime_cache_info.BEGIN',
                   'ZX_TDS_UTILITIES_PKG.get_regime_cache_info(+)'||
                   ' regime code: ' || p_tax_regime_code);
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- check if this tax regime exists in the cache structure
  --
  l_index := ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.FIRST;
  WHILE l_index IS NOT NULL LOOP

    IF(p_tax_regime_code =
        ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_index).tax_regime_code AND
       (p_tax_determine_date >=
         ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_index).effective_from AND
        (p_tax_determine_date <=
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_index).effective_to  OR
         ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_index).effective_to IS NULL)))
    THEN

      p_tax_regime_rec := ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_index);

      l_in_cache_flg := TRUE;

      EXIT;
    END IF;
    l_index := ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.NEXT(l_index);
  END LOOP;

  IF NOT l_in_cache_flg  THEN

    OPEN  get_regime_info_csr;
    FETCH get_regime_info_csr INTO
      p_tax_regime_rec.tax_regime_precedence,
      p_tax_regime_rec.tax_regime_id,
      p_tax_regime_rec.tax_regime_code,
      p_tax_regime_rec.parent_regime_code,
      p_tax_regime_rec.country_code,
      p_tax_regime_rec.geography_type,
      p_tax_regime_rec.geography_id,
      p_tax_regime_rec.effective_from,
      p_tax_regime_rec.effective_to,
      p_tax_regime_rec.country_or_group_code;

--    CLOSE get_regime_info_csr;

    IF get_regime_info_csr%NOTFOUND THEN

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer  := 'No data found for the specified tax regime code';

      FND_MESSAGE.SET_NAME('ZX','ZX_TAX_REGIME_INFO_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('TAX_REGIME',p_tax_regime_code);

      -- FND_MSG_PUB.Add;
      ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

    ELSE
       -- populate the global cache structure for regime
       --
       ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(
                       p_tax_regime_rec.tax_regime_id) := p_tax_regime_rec;

    END IF;

    CLOSE get_regime_info_csr;

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_regime_cache_info.END',
                   'ZX_TDS_UTILITIES_PKG.get_regime_cache_info(-)'||
                   ' tax_regime_id = ' ||
                    to_char(p_tax_regime_rec.tax_regime_id)||
                    ' RETURN_STATUS = ' || p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF get_regime_info_csr%ISOPEN THEN
        CLOSE get_regime_info_csr;
     END IF;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_regime_cache_info',
                      p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_regime_cache_info.END',
                     'ZX_TDS_UTILITIES_PKG.get_regime_cache_info(-)');
    END IF;

END get_regime_cache_info;

-------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_tax_cache_info
--
--  DESCRIPTION
--  This procedure gets tax information from global cache structure
--  based on tax regime code and tax, if tax exists in it.
--  If tax does not exist, get the tax regime information from  database
-------------------------------------------------------------------------
PROCEDURE get_tax_cache_info (
  p_tax_regime_code     IN          zx_regimes_b.tax_regime_code%TYPE,
  p_tax                 IN          zx_taxes_b.tax%TYPE,
  p_tax_determine_date  IN          DATE,
  x_tax_rec             OUT NOCOPY  zx_tax_info_cache_rec,
  p_return_status       OUT NOCOPY  VARCHAR2,
  p_error_buffer        OUT NOCOPY  VARCHAR2) IS

  CURSOR  get_tax_info_csr IS
   SELECT tax_id,
          tax,
          tax_regime_code,
          tax_type_code,
          tax_precision,
          minimum_accountable_unit,
          Rounding_Rule_Code,
          Tax_Status_Rule_Flag,
          Tax_Rate_Rule_Flag,
          Place_Of_Supply_Rule_Flag,
          Applicability_Rule_Flag,
          Tax_Calc_Rule_Flag,
          Taxable_Basis_Rule_Flag,
          def_tax_calc_formula,
          def_taxable_basis_formula,
          Reporting_Only_Flag,
          tax_currency_code,
          Def_Place_Of_Supply_Type_Code,
          Def_Registr_Party_Type_Code,
          Registration_Type_Rule_Flag,
          Direct_Rate_Rule_Flag,
          Def_Inclusive_Tax_Flag,
          effective_from,
          effective_to,
          compounding_precedence,
          Has_Other_Jurisdictions_Flag,
          Live_For_Processing_Flag,
          Regn_Num_Same_As_Le_Flag,
          applied_amt_handling_flag,
          exchange_rate_type,
          applicable_by_default_flag,
          record_type_code,
          tax_exmpt_cr_method_code,
          tax_exmpt_source_tax,
          legal_reporting_status_def_val,
          def_rec_settlement_option_code,
          zone_geography_type,
          override_geography_type,
          allow_rounding_override_flag,
          tax_account_source_tax
     FROM ZX_SCO_TAXES_B_V
    WHERE tax = p_tax
      AND tax_regime_code = p_tax_regime_code
      AND (effective_from <= p_tax_determine_date AND
            (effective_to >= p_tax_determine_date OR effective_to IS NULL))
      AND live_for_processing_flag = 'Y'
      AND (live_for_applicability_flag = 'Y' OR
           (LIVE_FOR_APPLICABILITY_FLAG = 'N' AND
            tax ='LOCATION' AND record_type_code = 'MIGRATED'
           )
          )
      -- AND rownum = 1;
    ORDER BY subscription_level_code;


 l_in_cache_flg         BOOLEAN         := FALSE;
 l_index                NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_cache_info.BEGIN',
                   'ZX_TDS_UTILITIES_PKG.get_tax_cache_info(+)'||
                   ' regime_code: ' || p_tax_regime_code||
                   ' tax: ' || p_tax);
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- first check if tax exists in tax cache structure
  --
  l_index := g_tax_rec_tbl.FIRST;
  WHILE l_index IS NOT NULL LOOP

    IF (p_tax = g_tax_rec_tbl(l_index).tax AND
        p_tax_regime_code = g_tax_rec_tbl(l_index).tax_regime_code)
    THEN

      x_tax_rec := g_tax_rec_tbl(l_index);
      l_in_cache_flg := TRUE;
      EXIT;
    END IF;
    l_index := g_tax_rec_tbl.NEXT(l_index);
  END LOOP;

  -- if tax does not exist in cache, get tax info from zx_taxes_b
  --
  IF NOT l_in_cache_flg  THEN
    --
    -- fetching tax_info from zx_taxes_b
    --
    OPEN  get_tax_info_csr;
    FETCH get_tax_info_csr INTO x_tax_rec;

    IF get_tax_info_csr%NOTFOUND THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer  := 'No data found for the specified tax_regime_code and tax';

      FND_MESSAGE.SET_NAME('ZX','ZX_TAX_INFO_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('TAX_REGIME',p_tax_regime_code);
      FND_MESSAGE.SET_TOKEN('TAX',p_tax);

      -- FND_MSG_PUB.Add;
      ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

    ELSE

      -- populate tax cache
      --
      g_tax_rec_tbl(x_tax_rec.tax_id) :=  x_tax_rec;
    END IF;

    CLOSE get_tax_info_csr;

  END IF;   -- tax not in cache

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_cache_info.END',
                   'ZX_TDS_UTILITIES_PKG.get_tax_cache_info(-)'||
                   'return_status = ' || p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF get_tax_info_csr%ISOPEN THEN
        CLOSE get_tax_info_csr;
     END IF;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_cache_info',
                      p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_cache_info.END',
                     'ZX_TDS_UTILITIES_PKG.get_tax_cache_info(-)');
    END IF;

END get_tax_cache_info;

-------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_jurisdiction_cache_info
--
--  DESCRIPTION
--  This procedure gets jurisdiction information from global cache structure
--  based on tax regime code ,tax and tax jurisdiction code, if tax exists in it.
--
-------------------------------------------------------------------------
PROCEDURE get_jurisdiction_cache_info (
  p_tax_regime_code     IN          zx_regimes_b.tax_regime_code%TYPE,
  p_tax                 IN          zx_taxes_b.tax%TYPE,
  p_tax_jurisdiction_code IN        zx_jurisdictions_b.tax_jurisdiction_code%TYPE,
  p_tax_determine_date  IN          DATE,
  x_jurisdiction_rec    OUT NOCOPY  zx_jur_info_cache_rec_type,
  p_return_status       OUT NOCOPY  VARCHAR2,
  p_error_buffer        OUT NOCOPY  VARCHAR2) IS

  CURSOR  get_jur_info_csr IS
   SELECT tax_jurisdiction_code,
          tax_jurisdiction_id,
          effective_from,
          effective_to,
          tax_regime_code,
          tax
     FROM ZX_JURISDICTIONS_B
    WHERE tax_regime_code = p_tax_regime_code
      AND tax = p_tax
      AND tax_jurisdiction_code = p_tax_jurisdiction_code;

 l_in_cache_flg         BOOLEAN         := FALSE;
 l_index                NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info.BEGIN',
                   'ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info(+)'||
                   ' regime_code = ' || p_tax_regime_code||
                   ' tax = ' || p_tax||
                   ' jurisdiciton_code = ' || p_tax_jurisdiction_code);

  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- first check if tax exists in tax cache structure
  --
  l_index := g_jur_info_tbl.FIRST;
  WHILE l_index IS NOT NULL LOOP

    IF (p_tax = g_jur_info_tbl(l_index).tax AND
        p_tax_regime_code = g_jur_info_tbl(l_index).tax_regime_code AND
        p_tax_jurisdiction_code = g_jur_info_tbl(l_index).tax_jurisdiction_code)
    THEN

      x_jurisdiction_rec := g_jur_info_tbl(l_index);
      l_in_cache_flg := TRUE;
      EXIT;
    END IF;
    l_index := g_jur_info_tbl.NEXT(l_index);
  END LOOP;

  -- if tax does not exist in cache, get tax info from zx_taxes_b
  --
  IF NOT l_in_cache_flg  THEN
    --
    -- fetching tax_info from zx_taxes_b
    --
    OPEN  get_jur_info_csr;
    FETCH get_jur_info_csr INTO
          x_jurisdiction_rec.tax_jurisdiction_code,
          x_jurisdiction_rec.tax_jurisdiction_id,
          x_jurisdiction_rec.effective_from,
          x_jurisdiction_rec.effective_to,
          x_jurisdiction_rec.tax_regime_code,
          x_jurisdiction_rec.tax;

    IF get_jur_info_csr%NOTFOUND THEN
       p_return_status := FND_API.G_RET_STS_ERROR;
       p_error_buffer  := 'No data found for the specified tax_regime_code and tax';
    ELSE

      -- populate tax cache
      --
      g_jur_info_tbl(x_jurisdiction_rec.tax_jurisdiction_id) :=  x_jurisdiction_rec;
    END IF;

    CLOSE get_jur_info_csr;

  END IF;   -- jurisdiciton not in cache

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_jurisdiciton_cache_info.END',
                   'ZX_TDS_UTILITIES_PKG.get_jurisdiciton_cache_info(-)'||
                   ' jurisdiction id = '||to_char(x_jurisdiction_rec.tax_jurisdiction_id) ||
                   ' return_status = ' || p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF get_jur_info_csr%ISOPEN THEN
        CLOSE get_jur_info_csr;
     END IF;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info',
                      p_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info.END',
                     'ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info(-)');
    END IF;

END get_jurisdiction_cache_info;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  populate_tax_cache
--
--  DESCRIPTION
--  This procedure populate the tax global cache structure
--  g_tax_rec_tbl based on tax_id, if it does not exist.
-----------------------------------------------------------------------
PROCEDURE populate_tax_cache (
  p_tax_id             IN           NUMBER,
  p_return_status      OUT NOCOPY   VARCHAR2,
  p_error_buffer       OUT NOCOPY   VARCHAR2) IS

  CURSOR  get_tax_info_csr IS
   SELECT tax_id,
          tax,
          tax_regime_code,
          tax_type_code,
          tax_precision,
          minimum_accountable_unit,
          Rounding_Rule_Code,
          Tax_Status_Rule_Flag,
          Tax_Rate_Rule_Flag,
          Place_Of_Supply_Rule_Flag,
          Applicability_Rule_Flag,
          Tax_Calc_Rule_Flag,
          Taxable_Basis_Rule_Flag,
          def_tax_calc_formula,
          def_taxable_basis_formula,
          Reporting_Only_Flag,
          tax_currency_code,
          Def_Place_Of_Supply_Type_Code,
          Def_Registr_Party_Type_Code,
          Registration_Type_Rule_Flag,
          Direct_Rate_Rule_Flag,
          Def_Inclusive_Tax_Flag,
          effective_from,
          effective_to,
          compounding_precedence,
          Has_Other_Jurisdictions_Flag,
          Live_For_Processing_Flag,
          Regn_Num_Same_As_Le_Flag,
          applied_amt_handling_flag,
          exchange_rate_type,
          applicable_by_default_flag,
          record_type_code,
          tax_exmpt_cr_method_code,
          tax_exmpt_source_tax,
          legal_reporting_status_def_val,
          def_rec_settlement_option_code,
          zone_geography_type,
          override_geography_type,
          allow_rounding_override_flag,
          tax_account_source_tax
     FROM ZX_TAXES_B
    WHERE tax_id = p_tax_id;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.populate_tax_cache.BEGIN',
                   'ZX_TDS_UTILITIES_PKG.populate_tax_cache(+)'||
                   'tax_id := ' || to_char(p_tax_id));
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_tax_id IS NULL THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.populate_tax_cache',
                     'tax_id cannot be null');
    END IF;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
    p_error_buffer := 'tax_id cannot be null';
    RETURN;
  END IF;

  -- if tax does not exist in the cache structure, get tax info from database
  --
  IF NOT g_tax_rec_tbl.EXISTS(p_tax_id)  THEN

    OPEN get_tax_info_csr;
    FETCH get_tax_info_csr INTO g_tax_rec_tbl(p_tax_id);

    IF get_tax_info_csr%NOTFOUND THEN
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
       p_error_buffer  := 'No data found for the specified tax_id';
    END IF;

    CLOSE get_tax_info_csr;
  END IF;       -- tax_id not exist in g_tax_rec_tbl

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.populate_tax_cache.END',
                   'ZX_TDS_UTILITIES_PKG.populate_tax_cache(-)'||
                   ' RETURN_STATUS = ' || p_return_status||
                   ' error buffer: '||p_error_buffer);
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     IF get_tax_info_csr%ISOPEN THEN
        CLOSE get_tax_info_csr;
     END IF;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
     IF (g_level_unexpected >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.populate_tax_cache',
                       p_error_buffer);
       FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.populate_tax_cache.END',
                      'ZX_TDS_UTILITIES_PKG.populate_tax_cache(-)');
     END IF;

END populate_tax_cache;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  populate_currency_cache
--
--  DESCRIPTION
--  This procedure populates the currency cache structure
--  g_currency_rec_tbl based on ledger_id. If this ledger_id already
--  exists in the cache structure, the population process will be skipped.
-----------------------------------------------------------------------
PROCEDURE populate_currency_cache (
 p_ledger_id              IN          gl_sets_of_books.set_of_books_id%TYPE,
 p_return_status          OUT NOCOPY  VARCHAR2,
 p_error_buffer           OUT NOCOPY  VARCHAR2) IS

 CURSOR  get_currency_info_csr IS
  SELECT sob.set_of_books_id,
         cur.currency_code,
         NVL(cur.minimum_accountable_unit, power(10, (-1 * precision))),
         precision
    FROM fnd_currencies cur, gl_sets_of_books sob
   WHERE sob.set_of_books_id = p_ledger_id
     AND cur.currency_code = sob.currency_code;


BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.populate_currency_cache.BEGIN',
                   'ZX_TDS_UTILITIES_PKG.populate_currency_cache(+)'||
                   'ledger_id := ' || to_char(p_ledger_id));
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_ledger_id IS NULL THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.populate_currency_cache',
                     'ledger_id cannot be null');
    END IF;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
    p_error_buffer := 'ledger_id cannot be null';
    RETURN;
  END IF;

  -- if ledger_id does not exist in the cache structure,
  -- get currency info from database
  --
  IF NOT g_currency_rec_tbl.EXISTS(p_ledger_id)  THEN

    OPEN  get_currency_info_csr;
    FETCH get_currency_info_csr INTO
            g_currency_rec_tbl(p_ledger_id).ledger_id,
            g_currency_rec_tbl(p_ledger_id).currency_code,
            g_currency_rec_tbl(p_ledger_id).minimum_accountable_unit,
            g_currency_rec_tbl(p_ledger_id).precision;

    IF get_currency_info_csr%NOTFOUND THEN
       p_return_status := FND_API.G_RET_STS_ERROR;
       p_error_buffer  := 'No data found for the specified ledger_id';
    END IF;

    CLOSE get_currency_info_csr;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.populate_currency_cache.END',
                   'ZX_TDS_UTILITIES_PKG.populate_currency_cache(-)'||
                   ' RETURN_STATUS = ' || p_return_status||
                   ' error buffer: '||p_error_buffer);
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     IF get_currency_info_csr%ISOPEN THEN
        CLOSE get_currency_info_csr;
     END IF;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
     IF (g_level_unexpected >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.populate_currency_cache',
                       p_error_buffer);
       FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.populate_currency_cache.END',
                      'ZX_TDS_UTILITIES_PKG.populate_currency_cache(-)');
     END IF;

END populate_currency_cache;

----------------------------------------------------------------------
--  PROCEDURE
--  get_tax_rate_info
--
--  DESCRIPTION
--
--  This procedure get tax_rate_id from zx_rates_b with given tax_regime_code,
--  tax, tax_status_code, tax_rate_code and tax_determine_date.
--
--  IN
--                 p_tax_regime_code       VARCHAR2
--                 p_tax                   VARCHAR2
--                 p_tax_status_code       VARCHAR2
--                 p_tax_rate_code         VARCHAR2
--                 p_tax_determine_date    DATE
--                 p_tax_class             VARCHAR2
--  OUT NOCOPY
--                  p_tax_rate_rec         zx_rate_info_rec_type
--                 p_return_status         VARCHAR2
--                 p_error_buffer          VARCHAR2
--
PROCEDURE  get_tax_rate_info (
 p_tax_regime_code        IN          VARCHAR2,
 p_tax                    IN          VARCHAR2,
 p_tax_jurisdiction_code  IN          zx_jurisdictions_b.tax_jurisdiction_code%TYPE,
 p_tax_status_code        IN          VARCHAR2,
 p_tax_rate_code          IN          VARCHAR2,
 p_tax_determine_date     IN          DATE,
 p_tax_class              IN          VARCHAR2,
 p_tax_rate_rec           OUT NOCOPY  zx_rate_info_rec_type,
 p_return_status          OUT NOCOPY  VARCHAR2,
 p_error_buffer           OUT NOCOPY  VARCHAR2) IS

 l_tax_jurisdiction_code zx_jurisdictions_b.tax_jurisdiction_code%TYPE; -- for  bug#5569426
 CURSOR  fetch_tax_rate_info_csr_jur IS
  SELECT tax_regime_code,
         tax,
         tax_status_code,
         tax_rate_code,
         tax_rate_id,
         effective_from,
         effective_to,
         rate_type_code,
         percentage_rate,
         quantity_rate,
         Allow_Adhoc_Tax_Rate_Flag,
         uom_code,
         tax_jurisdiction_code,
         offset_tax,
         offset_status_code,
         offset_tax_rate_code,
         allow_exemptions_flag,
         allow_exceptions_flag,
         NULL     tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
   FROM  ZX_SCO_RATES_B_V
  WHERE  tax_regime_code = p_tax_regime_code
    AND  tax = p_tax
    AND  tax_status_code = p_tax_status_code
    AND  active_flag     = 'Y'
    AND  (tax_jurisdiction_code = p_tax_jurisdiction_code )
    AND  tax_rate_code = p_tax_rate_code
    AND  (tax_class = p_tax_class or tax_class IS NULL)
    AND  ( p_tax_determine_date >= effective_from AND
          (p_tax_determine_date <= effective_to OR effective_to IS NULL))
    ORDER BY tax_class NULLS LAST, subscription_level_code;

   CURSOR  fetch_tax_rate_info_csr_no_jur IS
  SELECT tax_regime_code,
         tax,
         tax_status_code,
         tax_rate_code,
         tax_rate_id,
         effective_from,
         effective_to,
         rate_type_code,
         percentage_rate,
         quantity_rate,
         Allow_Adhoc_Tax_Rate_Flag,
         uom_code,
         tax_jurisdiction_code,
         offset_tax,
         offset_status_code,
         offset_tax_rate_code,
         allow_exemptions_flag,
         allow_exceptions_flag,
         NULL     tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
   FROM  ZX_SCO_RATES_B_V
  WHERE  tax_regime_code = p_tax_regime_code
    AND  tax = p_tax
    AND  tax_status_code = p_tax_status_code
    AND  active_flag     = 'Y'
    AND  (tax_jurisdiction_code is NULL)
    AND  tax_rate_code = p_tax_rate_code
    AND  (tax_class = p_tax_class or tax_class IS NULL)
    AND  ( p_tax_determine_date >= effective_from AND
          (p_tax_determine_date <= effective_to OR effective_to IS NULL))
    ORDER BY tax_class NULLS LAST, subscription_level_code;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_rate_info.BEGIN',
                  'ZX_TDS_UTILITIES_PKG.get_tax_rate_info(+)'||
                  ' tax_regime_code = ' || p_tax_regime_code||
                  ' tax = ' || p_tax||
                  ' tax_status_code = ' || p_tax_status_code||
                  ' tax_rate_code = ' || p_tax_rate_code||
                  ' trax_class = ' || p_tax_class||
                  ' tax determine date = ' || p_tax_determine_date);

  END IF;

  --start bug#5569426
  IF  p_tax_jurisdiction_code is NULL  then
     l_tax_jurisdiction_code :='NULL';
  ELSE
     l_tax_jurisdiction_code := p_tax_jurisdiction_code;
  END IF;
  --end bug#5569426

  IF p_tax_jurisdiction_code is NOT NULL then
     OPEN  fetch_tax_rate_info_csr_JUR;
     FETCH fetch_tax_rate_info_csr_JUR INTO  p_tax_rate_rec;

     IF fetch_tax_rate_info_csr_JUR%NOTFOUND THEN

        OPEN  fetch_tax_rate_info_csr_no_JUR;
        FETCH fetch_tax_rate_info_csr_no_jur INTO  p_tax_rate_rec;

        IF fetch_tax_rate_info_csr_no_JUR%NOTFOUND THEN
             p_return_status := FND_API.G_RET_STS_ERROR;
             p_error_buffer := 'No tax_rate_id found for the specified ' ||
                               'tax_regime_code, tax, tax_status_code and tax_rate_code';

              FND_MESSAGE.SET_NAME('ZX','ZX_TAX_RATE_INFO_NOT_FOUND');
              FND_MESSAGE.SET_TOKEN('TAX_REGIME',p_tax_regime_code);
              FND_MESSAGE.SET_TOKEN('TAX_CODE',p_tax);
              FND_MESSAGE.SET_TOKEN('TAX_STATUS',p_tax_status_code);
              FND_MESSAGE.SET_TOKEN('TAX_RATE_CODE',p_tax_rate_code);
			  FND_MESSAGE.SET_TOKEN('TAX_JURISDICTION_CODE',l_tax_jurisdiction_code); --for bug#5569426
              -- FND_MSG_PUB.Add;
              ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
         END IF;
         close fetch_tax_rate_info_csr_no_JUR;

     END IF;

     CLOSE fetch_tax_rate_info_csr_JUR;

  ELSE

       OPEN  fetch_tax_rate_info_csr_no_JUR;
       FETCH fetch_tax_rate_info_csr_no_jur INTO  p_tax_rate_rec;

       IF fetch_tax_rate_info_csr_no_JUR%NOTFOUND THEN
            p_return_status := FND_API.G_RET_STS_ERROR;
            p_error_buffer := 'No tax_rate_id found for the specified ' ||
                              'tax_regime_code, tax, tax_status_code and tax_rate_code';

             FND_MESSAGE.SET_NAME('ZX','ZX_TAX_RATE_INFO_NOT_FOUND');
             FND_MESSAGE.SET_TOKEN('TAX_REGIME',p_tax_regime_code);
             FND_MESSAGE.SET_TOKEN('TAX_CODE',p_tax);
             FND_MESSAGE.SET_TOKEN('TAX_STATUS',p_tax_status_code);
             FND_MESSAGE.SET_TOKEN('TAX_RATE_CODE',p_tax_rate_code);
             FND_MESSAGE.SET_TOKEN('TAX_JURISDICTION_CODE',l_tax_jurisdiction_code);   --for bug#5569426
             -- FND_MSG_PUB.Add;
             ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
        END IF;
        close fetch_tax_rate_info_csr_no_JUR;

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_rate_info.END',
                  'ZX_TDS_UTILITIES_PKG.get_tax_rate_info(-)'||
                  ' tax rate id: '||to_char(p_tax_rate_rec.tax_rate_id)||
                  ' RETURN_STATUS = ' || p_return_status||
                  ' error buffer: '||p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_rate_info',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_rate_info.END',
                    'ZX_TDS_UTILITIES_PKG.get_tax_rate_info(-)');
    END IF;

END get_tax_rate_info;

----------------------------------------------------------------------
--  FUNCTION
--   get_tax_index
--
--  DESCRIPTION
--
--  This function check if a tax line is allicable in the current document.
--  If it is applicable, return the line index in p_detail_tax_line_tbl.
--
--  IN             p_taxregime_code
--                 p_tax
--                 p_trx_line_id
--                 p_trx_level_type
--                 l_begin_index
--                 l_begin_index
--  OUT NOCOPY     x_return_status
--
FUNCTION get_tax_index (
 p_tax_regime_code        IN          zx_regimes_b.tax_regime_code%TYPE,
 p_tax                    IN          zx_taxes_b.tax%TYPE,
 p_trx_line_id            IN          NUMBER,
 p_trx_level_type         IN          VARCHAR2,
 p_begin_index            IN          BINARY_INTEGER,
 p_end_index              IN          BINARY_INTEGER,
 x_return_status          OUT NOCOPY  VARCHAR2)  RETURN NUMBER IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_index.BEGIN',
                  'ZX_TDS_UTILITIES_PKG.get_tax_index(+)'||
                  ' tax_regime_code : ' || p_tax_regime_code||
                  ' tax : ' || p_tax);
  END IF;

  -- Return NULL if p_begin_index IS NULL
  --
  IF (p_begin_index IS NULL) THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_index',
                    'Warning: p_begin_index is NULL');
      FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_index.END',
                    'ZX_TDS_UTILITIES_PKG.get_tax_index(-)');
    END IF;
    RETURN NULL;
  END IF;

  FOR i IN NVL(p_begin_index, 0) .. NVL(p_end_index, -1) LOOP

    IF(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id =
                                                              p_trx_line_id  AND
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type =
                                                           p_trx_level_type  AND
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_regime_code =
                                                           p_tax_regime_code AND
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax = p_tax )
    THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN

        FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_index.END',
                      'ZX_TDS_UTILITIES_PKG.get_tax_index(-) tax found in cache');
      END IF;
      RETURN i;
    END IF;
  END LOOP;

  -- Return NULL if tax does not exist
  --
  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_index.END',
                  'ZX_TDS_UTILITIES_PKG.get_tax_index(-) tax does not exist in cache');
  END IF;

  RETURN NULL;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected, 'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_index',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected, 'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_index.END',
                    'get_tax_index(-)');
    END IF;

END get_tax_index;

----------------------------------------------------------------------
--  PROCEDURE
--  get_tax_rate_info
--
--  DESCRIPTION
--
--  This procedure get tax_rate_id from zx_rates_b with given tax_rate_id
--
--  IN
--                 p_tax_id                NUMBER
--  OUT NOCOPY
--                 p_tax_rate_rec         zx_rate_info_rec_type
--                 p_return_status         VARCHAR2
--                 p_error_buffer          VARCHAR2
--  HISTORY
--
--  Apr-05-2005  Ling Zhang  Created for bug fix 4277780
--

PROCEDURE  get_tax_rate_info (
 p_tax_rate_id            IN          NUMBER,
 p_tax_rate_rec           OUT NOCOPY  zx_rate_info_rec_type,
 p_return_status          OUT NOCOPY  VARCHAR2,
 p_error_buffer           OUT NOCOPY  VARCHAR2) IS

 CURSOR  fetch_tax_rate_info_csr IS
  SELECT tax_regime_code,
         tax,
         tax_status_code,
         tax_rate_code,
         tax_rate_id,
         effective_from,
         effective_to,
         rate_type_code,
         percentage_rate,
         quantity_rate,
         Allow_Adhoc_Tax_Rate_Flag,
         uom_code,
         tax_jurisdiction_code,
         offset_tax,
         offset_status_code,
         offset_tax_rate_code,
         allow_exemptions_flag,
         allow_exceptions_flag,
         NULL     tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
   -- FROM  ZX_SCO_RATES -- Bug#5395227
      FROM  ZX_RATES_B
  WHERE  tax_rate_id = p_tax_rate_id
  AND    active_flag = 'Y';

  l_tbl_index BINARY_INTEGER;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_rate_info.BEGIN',
                  'ZX_TDS_UTILITIES_PKG.get_tax_rate_info(+)'||
                  'tax_rate_id = ' || p_tax_rate_id);
  END IF;

 IF g_tax_rate_info_tbl.exists(p_tax_rate_id) then

    IF (g_level_statement >= g_current_runtime_level ) THEN

       FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_rate_info',
                  'Found rate info in cache. ');
    END IF;

    p_tax_rate_rec := g_tax_rate_info_tbl(p_tax_rate_id);

 ELSE

      OPEN  fetch_tax_rate_info_csr;
      FETCH fetch_tax_rate_info_csr INTO  p_tax_rate_rec;

      g_tax_rate_info_tbl(p_tax_rate_id) := p_tax_rate_rec;

      l_tbl_index := dbms_utility.get_hash_value(
                p_tax_rate_rec.tax_regime_code||p_tax_rate_rec.tax||
                p_tax_rate_rec.tax_status_code||p_tax_rate_rec.tax_rate_code,
                1,
                8192);

      g_tax_rate_info_ind_by_hash(l_tbl_index) := p_tax_rate_rec;

      IF fetch_tax_rate_info_csr%NOTFOUND THEN
         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         p_error_buffer := 'No tax rate info found for the specified tax_rate_id';
      END IF;

      CLOSE fetch_tax_rate_info_csr;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_rate_info.END',
                  'ZX_TDS_UTILITIES_PKG.get_tax_rate_info(-)'||
                  ' RETURN_STATUS = ' || p_return_status||
                  ' error buffer: '||p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_rate_info',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_rate_info.END',
                    'ZX_TDS_UTILITIES_PKG.get_tax_rate_info(-)');
    END IF;

END get_tax_rate_info;

END  ZX_TDS_UTILITIES_PKG;


/
