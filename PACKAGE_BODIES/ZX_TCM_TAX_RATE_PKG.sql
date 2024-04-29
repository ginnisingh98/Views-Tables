--------------------------------------------------------
--  DDL for Package Body ZX_TCM_TAX_RATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TCM_TAX_RATE_PKG" AS
/* $Header: zxctaxratespkgb.pls 120.14.12010000.4 2009/07/03 07:54:35 srajapar ship $ */

g_current_runtime_level      NUMBER;
g_level_statement            CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure            CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_unexpected           CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
g_module_name                CONSTANT  VARCHAR2(50) :='ZX.PLSQL.ZX_TCM_TAX_RATE_PKG';

PROCEDURE get_tax_rate_by_jur_gt(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code           IN    ZX_RATES_B.tax_rate_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
);

PROCEDURE get_def_tax_rate_by_jur_gt(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
);

PROCEDURE get_tax_rate_by_jur_code(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax_jurisdiction_code   IN    ZX_RATES_B.tax_jurisdiction_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code           IN    ZX_RATES_B.tax_rate_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
);

PROCEDURE get_tax_rate_no_jur_code(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code           IN    ZX_RATES_B.tax_rate_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
);
PROCEDURE get_def_tax_rate_by_jur_code(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax_jurisdiction_code   IN    ZX_RATES_B.tax_jurisdiction_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
);

PROCEDURE get_def_tax_rate_no_jur_code(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
);

PROCEDURE get_tax_rate_internal(
  p_event_class_rec              IN  ZX_API_PUB.event_class_rec_type,
  p_tax_regime_code              IN  ZX_RATES_B.tax_regime_code%TYPE,
  p_tax                          IN  ZX_RATES_B.tax%TYPE,
  p_tax_date                     IN  DATE,
  p_tax_status_code              IN  ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code                IN  ZX_RATES_B.tax_rate_code%TYPE,
  p_place_of_supply_type_code    IN  ZX_LINES.place_of_supply_type_code%TYPE,
  p_structure_index              IN  NUMBER,
  p_multiple_jurisdictions_flag  IN  VARCHAR2,
  x_tax_rate_rec                 OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status                OUT NOCOPY VARCHAR2
);

PROCEDURE get_tax_rate_pvt(
  p_tax_class                    IN  VARCHAR2,
  p_tax_regime_code              IN  ZX_RATES_B.tax_regime_code%TYPE,
  p_tax_jurisdiction_code        IN  ZX_RATES_B.tax_jurisdiction_code%TYPE,
  p_tax                          IN  ZX_RATES_B.tax%TYPE,
  p_tax_date                     IN  DATE,
  p_tax_status_code              IN  ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code                IN  ZX_RATES_B.tax_rate_code%TYPE,
  p_place_of_supply_type_code    IN  ZX_LINES.place_of_supply_type_code%TYPE,
  p_structure_index              IN  NUMBER,
  p_multiple_jurisdictions_flag  IN  VARCHAR2,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
);

PROCEDURE get_def_tax_rate_pvt(
  p_tax_class                    IN  VARCHAR2,
  p_tax_regime_code              IN  ZX_RATES_B.tax_regime_code%TYPE,
  p_tax_jurisdiction_code        IN  ZX_RATES_B.tax_jurisdiction_code%TYPE,
  p_tax                          IN  ZX_RATES_B.tax%TYPE,
  p_tax_date                     IN  DATE,
  p_tax_status_code              IN  ZX_RATES_B.tax_status_code%TYPE,
  p_place_of_supply_type_code    IN  ZX_LINES.place_of_supply_type_code%TYPE,
  p_structure_index              IN  NUMBER,
  p_multiple_jurisdictions_flag  IN  VARCHAR2,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
);


------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_tax_rate_by_jur_gt
--
--  DESCRIPTION
--  This procedure find tax rate information match the passed in tax
--  information and the jurisdiction info in zx_jurisdictions_gt
------------------------------------------------------------------------------
PROCEDURE get_tax_rate_by_jur_gt(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code           IN    ZX_RATES_B.tax_rate_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
) IS

 -- the condition of tax_class is added for migration_data compatibility
 -- it is possible for migrated tax rates from AP and AR share the same tax
 -- rate code, in this case, need the tax_class info(AP: INPUT, AR: OUTPUT)
 -- to tell the tax rates apart.

 CURSOR  get_tax_rate_csr IS
  SELECT /*+ LEADING(JUR) USE_NL(JUR RATE)*/
         rate.tax_regime_code,
         rate.tax,
         rate.tax_status_code,
         rate.tax_rate_code,
         rate.tax_rate_id,
         rate.effective_from,
         rate.effective_to,
         rate.rate_type_code,
         rate.percentage_rate,
         rate.quantity_rate,
         rate.allow_adhoc_tax_rate_flag,
         rate.uom_code,
         rate.tax_jurisdiction_code,
         rate.offset_tax,
         rate.offset_status_code,
         rate.offset_tax_rate_code,
         rate.allow_exemptions_flag,
         rate.allow_exceptions_flag,
         jur.tax_jurisdiction_id,
         rate.def_rec_settlement_option_code,
         rate.taxable_basis_formula_code,
         rate.adj_for_adhoc_amt_code,
         rate.inclusive_tax_flag,
         rate.tax_class
    FROM ZX_SCO_RATES_B_V rate, ZX_JURISDICTIONS_GT jur
   WHERE rate.tax_jurisdiction_code = jur.tax_jurisdiction_code
     AND jur.tax = p_tax
     AND jur.tax_regime_code = p_tax_regime_code
     AND rate.effective_from <= p_tax_date
     AND (rate.effective_to  >= p_tax_date  OR  rate.effective_to IS NULL )
     AND rate.tax_rate_code = p_tax_rate_code
     AND rate.tax_status_code = p_tax_status_code
     AND rate.tax = p_tax
     AND rate.tax_regime_code = p_tax_regime_code
     AND rate.active_flag = 'Y'
     AND rate.tax_class IS NULL
   ORDER BY jur.precedence_level, rate.subscription_level_code;

 CURSOR  get_tax_rate_mig_csr IS
  SELECT /*+ LEADING(JUR) USE_NL(JUR RATE)*/
         rate.tax_regime_code,
         rate.tax,
         rate.tax_status_code,
         rate.tax_rate_code,
         rate.tax_rate_id,
         rate.effective_from,
         rate.effective_to,
         rate.rate_type_code,
         rate.percentage_rate,
         rate.quantity_rate,
         rate.allow_adhoc_tax_rate_flag,
         rate.uom_code,
         rate.tax_jurisdiction_code,
         rate.offset_tax,
         rate.offset_status_code,
         rate.offset_tax_rate_code,
         rate.allow_exemptions_flag,
         rate.allow_exceptions_flag,
         jur.tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
    FROM ZX_SCO_RATES_B_V rate, ZX_JURISDICTIONS_GT jur
   WHERE rate.tax_jurisdiction_code = jur.tax_jurisdiction_code
     AND jur.tax = p_tax
     AND jur.tax_regime_code = p_tax_regime_code
     AND rate.effective_from <= p_tax_date
     AND (rate.effective_to  >= p_tax_date  OR  rate.effective_to IS NULL )
     AND rate.tax_rate_code = p_tax_rate_code
     AND rate.tax_status_code = p_tax_status_code
     AND rate.tax = p_tax
     AND rate.tax_regime_code = p_tax_regime_code
     AND rate.active_flag = 'Y'
     AND rate.tax_class = p_tax_class
   ORDER BY jur.precedence_level, rate.subscription_level_code;

 l_procedure_name              CONSTANT VARCHAR2(30) := 'get_tax_rate_by_jur_gt';
 l_tax_rate_rec                ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
 l_tax_rate_rec_tmp            ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.BEGIN',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_gt(+) ');
  END IF;

  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  -- use p_tax_regime_code,
  --     p_tax,
  --     p_tax_status_code,
  --     p_tax_rate_code,
  --     p_tax_date
  -- and jurisdiction info in zx_jurisdictions_gt to
  -- get the tax rate information from zx_rates_b
  --
  OPEN get_tax_rate_csr;

  -- the first rate(the one with smallest precedence_level value) from the
  -- cursor get_tax_rate_csr is the one should be used as the tax rate.

  FETCH get_tax_rate_csr INTO l_tax_rate_rec;

  IF get_tax_rate_csr%FOUND THEN

    /* Bug#5395227- don't do a 2nd fetch
    FETCH get_tax_rate_csr INTO l_tax_rate_rec_tmp;

    IF get_tax_rate_csr%FOUND
      AND l_tax_rate_rec_tmp.tax_jurisdiction_code = l_tax_rate_rec.tax_jurisdiction_code
    THEN
      -- raise error for multiple rate retrieved for the same jurisdiction code
      x_return_status:= FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME ('ZX','ZX_MULTIPLE_RATES_FOUND');
      FND_MESSAGE.SET_TOKEN('TAX_RATE_CODE',p_tax_rate_code);
      FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('TAX',p_tax);

      CLOSE get_tax_rate_csr;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name,
                       'Too Many Tax Rate Rows Retrived. ');
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name||'.END',
                       'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_gt(-) ');
      END IF;

    ELSE
    *****  Bug#5395227 ****/

      x_tax_rate_rec := l_tax_rate_rec;
      CLOSE get_tax_rate_csr;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
      END IF;

    -- END IF;
  ELSE  -- get_tax_rate_csr%NOTFOUND
    CLOSE get_tax_rate_csr;

    -- tax rate is not found with NULL tax class, get tax rate with p_tax_class
    --
    OPEN get_tax_rate_mig_csr;

    -- the first rate(the one with smallest precedence_level value) from the
    -- cursor get_tax_rate_csr is the one should be used as the tax rate.

    FETCH get_tax_rate_mig_csr INTO l_tax_rate_rec;

    IF get_tax_rate_mig_csr%FOUND THEN

      /* Bug#5395227- don't do a 2nd fetch

      FETCH get_tax_rate_mig_csr INTO l_tax_rate_rec_tmp;

      IF get_tax_rate_mig_csr%FOUND
        AND l_tax_rate_rec_tmp.tax_jurisdiction_code = l_tax_rate_rec.tax_jurisdiction_code
      THEN
        -- raise error for multiple rate retrieved for the same jurisdiction code
        x_return_status:= FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME ('ZX','ZX_MULTIPLE_RATES_FOUND');
        FND_MESSAGE.SET_TOKEN('TAX_RATE_CODE',p_tax_rate_code);
        FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('TAX',p_tax);

        CLOSE get_tax_rate_mig_csr;

        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name,
                         'Too Many Tax Rate Rows Retrived. ');
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name||'.END',
                         'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_gt(-) ');
        END IF;

      ELSE
      *****  Bug#5395227 ****/

        x_tax_rate_rec := l_tax_rate_rec;
        CLOSE get_tax_rate_mig_csr;

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
        END IF;

      -- END IF;
    ELSE  -- get_tax_rate_mig_csr%NOTFOUND
      CLOSE get_tax_rate_mig_csr;
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_gt(-) ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF get_tax_rate_csr%ISOPEN THEN
      CLOSE get_tax_rate_csr;
    END IF;
    IF get_tax_rate_mig_csr%ISOPEN THEN
      CLOSE get_tax_rate_mig_csr;
    END IF;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name,
                   sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_gt(-) ');
    END IF;

END get_tax_rate_by_jur_gt;

------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_def_tax_rate_by_jur_gt
--
--  DESCRIPTION
--  This procedure find tax rate information match the passed in tax
--  information and the jurisdiction info in zx_jurisdictions_gt
------------------------------------------------------------------------------
PROCEDURE get_def_tax_rate_by_jur_gt(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
)IS

 -- the condition of tax_class is added for migration_data compatibility
 -- it is possible for migrated tax rates from AP and AR share the same tax
 -- rate code, in this case, need the tax_class info(AP: INPUT, AR: OUTPUT)
 -- to tell the tax rates apart.

 CURSOR  get_def_tax_rate_csr  IS
  SELECT /*+ LEADING(JUR) USE_NL(JUR RATE)*/
         rate.tax_regime_code,
         rate.tax,
         rate.tax_status_code,
         rate.tax_rate_code,
         rate.tax_rate_id,
         rate.effective_from,
         rate.effective_to,
         rate.rate_type_code,
         rate.percentage_rate,
         rate.quantity_rate,
         rate.allow_adhoc_tax_rate_flag,
         rate.uom_code,
         rate.tax_jurisdiction_code,
         rate.offset_tax,
         rate.offset_status_code,
         rate.offset_tax_rate_code,
         rate.allow_exemptions_flag,
         rate.allow_exceptions_flag,
         jur.tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
    FROM ZX_SCO_RATES_B_V rate, ZX_JURISDICTIONS_GT jur
   WHERE rate.tax_jurisdiction_code = jur.tax_jurisdiction_code
     AND jur.tax = p_tax
     AND jur.tax_regime_code = p_tax_regime_code
     AND rate.tax_status_code = p_tax_status_code
     AND rate.tax = p_tax
     AND rate.tax_regime_code = p_tax_regime_code
     AND rate.default_flg_effective_from <= p_tax_date
     AND (rate.default_flg_effective_to >= p_tax_date
           OR rate.default_flg_effective_to IS NULL)
     AND rate.default_rate_flag = 'Y'
     AND rate.active_flag = 'Y'
     AND rate.tax_class IS NULL
   ORDER BY jur.precedence_level, rate.subscription_level_code;

 CURSOR  get_def_tax_rate_mig_csr  IS
  SELECT /*+ LEADING(JUR) USE_NL(JUR RATE)*/
         rate.tax_regime_code,
         rate.tax,
         rate.tax_status_code,
         rate.tax_rate_code,
         rate.tax_rate_id,
         rate.effective_from,
         rate.effective_to,
         rate.rate_type_code,
         rate.percentage_rate,
         rate.quantity_rate,
         rate.allow_adhoc_tax_rate_flag,
         rate.uom_code,
         rate.tax_jurisdiction_code,
         rate.offset_tax,
         rate.offset_status_code,
         rate.offset_tax_rate_code,
         rate.allow_exemptions_flag,
         rate.allow_exceptions_flag,
         jur.tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
    FROM ZX_SCO_RATES_B_V rate, ZX_JURISDICTIONS_GT jur
   WHERE rate.tax_jurisdiction_code = jur.tax_jurisdiction_code
     AND jur.tax = p_tax
     AND jur.tax_regime_code = p_tax_regime_code
     AND rate.tax_status_code = p_tax_status_code
     AND rate.tax = p_tax
     AND rate.tax_regime_code = p_tax_regime_code
     AND rate.default_flg_effective_from <= p_tax_date
     AND (rate.default_flg_effective_to >= p_tax_date
           OR rate.default_flg_effective_to IS NULL)
     AND rate.default_rate_flag = 'Y'
     AND rate.active_flag = 'Y'
     AND rate.tax_class = p_tax_class
   ORDER BY jur.precedence_level, rate.subscription_level_code;

 l_procedure_name              CONSTANT VARCHAR2(30) := 'get_def_tax_rate_by_jur_gt';
 l_tax_rate_rec                ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
 --l_tax_rate_rec_tmp            ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.BEGIN',
                   'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_by_jur_gt(+) ');
  END IF;

  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  -- get default tax rate code
  OPEN get_def_tax_rate_csr;

  -- the first rate(the one with smallest precedence_level value) from the
  -- cursor get_tax_rate_csr is the one should be used as the tax rate.
  FETCH get_def_tax_rate_csr INTO l_tax_rate_rec;

  IF get_def_tax_rate_csr%FOUND THEN

    /* Bug#5395227- don't do a 2nd fetch

    FETCH get_def_tax_rate_csr INTO l_tax_rate_rec_tmp;

    IF get_def_tax_rate_csr%FOUND
      AND l_tax_rate_rec_tmp.tax_jurisdiction_code = l_tax_rate_rec.tax_jurisdiction_code
    THEN
      -- raise error for multiple rate retrieved for the same jurisdiction code
      x_return_status:= FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME ('ZX','ZX_MULTI_DEFAULT_RATES_FOUND');
      FND_MESSAGE.SET_TOKEN('RATE_REGIME_CODE', p_tax_regime_code);
      FND_MESSAGE.SET_TOKEN('TAX_CODE',p_tax);
      FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('TAX',p_tax);

      CLOSE get_def_tax_rate_csr;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name,
                       'Too Many Tax Rate Rows Retrived. ');
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name||'.END',
                       'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_by_jur_gt(-) ');
      END IF;
    ELSE
    *****  Bug#5395227 ****/

      x_tax_rate_rec := l_tax_rate_rec;
      CLOSE get_def_tax_rate_csr;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
      END IF;

    -- END IF;
  ELSE  -- get_def_tax_rate_csr%NOTFOUND
    CLOSE get_def_tax_rate_csr;

    -- tax rate is not found with NULL tax class, get tax rate with p_tax_class
    --
    OPEN get_def_tax_rate_mig_csr;

    -- the first rate(the one with smallest precedence_level value) from the
    -- cursor get_tax_rate_csr is the one should be used as the tax rate.
    FETCH get_def_tax_rate_mig_csr INTO l_tax_rate_rec;

    IF get_def_tax_rate_mig_csr%FOUND THEN

      /* Bug#5395227- don't do a 2nd fetch
      FETCH get_def_tax_rate_mig_csr INTO l_tax_rate_rec_tmp;

      IF get_def_tax_rate_mig_csr%FOUND
        AND l_tax_rate_rec_tmp.tax_jurisdiction_code = l_tax_rate_rec.tax_jurisdiction_code
      THEN
        -- raise error for multiple rate retrieved for the same jurisdiction code
        x_return_status:= FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME ('ZX','ZX_MULTI_DEFAULT_RATES_FOUND');
        FND_MESSAGE.SET_TOKEN('RATE_REGIME_CODE', p_tax_regime_code);
        FND_MESSAGE.SET_TOKEN('TAX_CODE',p_tax);
        FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('TAX',p_tax);

        CLOSE get_def_tax_rate_mig_csr;

        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name,
                         'Too Many Tax Rate Rows Retrived. ');
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name||'.END',
                         'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_by_jur_gt(-) ');
        END IF;
      ELSE
      *****  Bug#5395227 ****/

        x_tax_rate_rec := l_tax_rate_rec;
        CLOSE get_def_tax_rate_mig_csr;

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
        END IF;

      --END IF;
    ELSE  -- get_def_tax_rate_mig_csr%NOTFOUND
      CLOSE get_def_tax_rate_mig_csr;
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_by_jur_gt(-) ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF get_def_tax_rate_csr%ISOPEN THEN
      CLOSE get_def_tax_rate_csr;
    END IF;
    IF get_def_tax_rate_mig_csr%ISOPEN THEN
      CLOSE get_def_tax_rate_mig_csr;
    END IF;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name,
                   sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_gt(-) ');
    END IF;

END get_def_tax_rate_by_jur_gt;

------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_tax_rate_by_jur_code
--
--  DESCRIPTION
--  This procedure find tax rate information match the passed in tax
--  information
------------------------------------------------------------------------------
PROCEDURE get_tax_rate_by_jur_code(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax_jurisdiction_code   IN    ZX_RATES_B.tax_jurisdiction_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code           IN    ZX_RATES_B.tax_rate_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
) IS

 -- the condition of tax_class is added for migration_data compatibility
 -- it is possible for migrated tax rates from AP and AR share the same tax
 -- rate code, in this case, need the tax_class info(AP: INPUT, AR: OUTPUT)
 -- to tell the tax rates apart.

 CURSOR  get_tax_rate_csr IS
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
         NULL tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
    FROM ZX_SCO_RATES_B_V        -- Bug#5395227
   WHERE tax_jurisdiction_code = p_tax_jurisdiction_code
     AND effective_from <= p_tax_date
     AND (effective_to  >= p_tax_date  OR  effective_to IS NULL )
     AND tax_rate_code = p_tax_rate_code
     AND tax_status_code = p_tax_status_code
     AND tax = p_tax
     AND tax_regime_code = p_tax_regime_code
     AND Active_Flag = 'Y'
     AND tax_class IS NULL
     ORDER BY subscription_level_code;      -- Bug#5395227

 CURSOR  get_tax_rate_mig_csr IS
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
         NULL tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
    FROM ZX_SCO_RATES_B_V     -- Bug#5395227
   WHERE tax_jurisdiction_code = p_tax_jurisdiction_code
     AND effective_from <= p_tax_date
     AND (effective_to  >= p_tax_date  OR  effective_to IS NULL )
     AND tax_rate_code = p_tax_rate_code
     AND tax_status_code = p_tax_status_code
     AND tax = p_tax
     AND tax_regime_code = p_tax_regime_code
     AND Active_Flag = 'Y'
     AND tax_class = p_tax_class
     ORDER BY subscription_level_code;          -- Bug#5395227

 l_procedure_name              CONSTANT VARCHAR2(30) := 'get_tax_rate_by_jur_code';
 l_tax_rate_rec                ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
 -- l_tax_rate_rec_tmp            ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.BEGIN',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_code(+) ');
  END IF;

  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  -- use p_tax_jurisdiction_code,
  --     p_tax_regime_code,
  --     p_tax,
  --     p_tax_status_code,
  --     p_tax_rate_code,
  --     p_tax_date to

  -- get tax rate with NULL tax class first
  --
  OPEN get_tax_rate_csr;

  FETCH get_tax_rate_csr INTO l_tax_rate_rec;

  IF get_tax_rate_csr%FOUND THEN

  /* Bug#5395227- don't do a 2nd fetch

    FETCH get_tax_rate_csr INTO l_tax_rate_rec_tmp;

    IF get_tax_rate_csr%FOUND THEN
      -- raise error for multiple rate retrieved
      x_return_status:= FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME ('ZX','ZX_MULTIPLE_RATES_FOUND');
      FND_MESSAGE.SET_TOKEN('TAX_RATE_CODE',p_tax_rate_code);
      FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('TAX',p_tax);

      CLOSE get_tax_rate_csr;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name,
                       'Too Many Tax Rate Rows Retrived. ');
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name||'.END',
                       'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_code(-) ');
      END IF;

    ELSE
    *****  Bug#5395227 ****/

      x_tax_rate_rec := l_tax_rate_rec;
      CLOSE get_tax_rate_csr;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
      END IF;

    -- END IF;
  ELSE  -- get_tax_rate_csr%NOTFOUND
    CLOSE get_tax_rate_csr;

    OPEN get_tax_rate_mig_csr;

    FETCH get_tax_rate_mig_csr INTO l_tax_rate_rec;

    IF get_tax_rate_mig_csr%FOUND THEN

      /* Bug#5395227- don't do a 2nd fetch
      FETCH get_tax_rate_mig_csr INTO l_tax_rate_rec_tmp;

      IF get_tax_rate_mig_csr%FOUND THEN
        -- raise error for multiple rate retrieved
        x_return_status:= FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME ('ZX','ZX_MULTIPLE_RATES_FOUND');
        FND_MESSAGE.SET_TOKEN('TAX_RATE_CODE',p_tax_rate_code);
        FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('TAX',p_tax);

        CLOSE get_tax_rate_mig_csr;

        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name,
                         'Too Many Tax Rate Rows Retrived. ');
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name||'.END',
                         'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_code(-) ');
        END IF;

      ELSE
      *****  Bug#5395227 ****/

        x_tax_rate_rec := l_tax_rate_rec;
        CLOSE get_tax_rate_mig_csr;

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
        END IF;

      -- END IF;
    ELSE  -- get_tax_rate_mig_csr%NOTFOUND
      CLOSE get_tax_rate_mig_csr;
    END IF;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_code(-) ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF get_tax_rate_csr%ISOPEN THEN
      CLOSE get_tax_rate_csr;
    END IF;
    IF get_tax_rate_mig_csr%ISOPEN THEN
      CLOSE get_tax_rate_mig_csr;
    END IF;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name,
                   sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_code(-) ');
    END IF;

END get_tax_rate_by_jur_code;

------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_tax_rate_no_jur_code
--
--  DESCRIPTION
--  This procedure find tax rate information match the passed in tax
--  information without jurisdiction information
------------------------------------------------------------------------------

PROCEDURE get_tax_rate_no_jur_code(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code           IN    ZX_RATES_B.tax_rate_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
) IS

 -- the condition of tax_class is added for migration_data compatibility
 -- it is possible for migrated tax rates from AP and AR share the same tax
 -- rate code, in this case, need the tax_class info(AP: INPUT, AR: OUTPUT)
 -- to tell the tax rates apart.

  CURSOR get_tax_rate_csr_no_jur IS
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
         NULL tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
    FROM ZX_SCO_RATES_B_V       -- Bug#5395227
   WHERE tax_jurisdiction_code IS NULL
     AND effective_from <= p_tax_date
     AND ( effective_to  >= p_tax_date  OR  effective_to IS NULL)
     AND tax_rate_code = p_tax_rate_code
     AND tax_status_code = p_tax_status_code
     AND tax = p_tax
     AND tax_regime_code = p_tax_regime_code
     AND Active_Flag = 'Y'
     AND tax_class IS NULL
     ORDER BY subscription_level_code;            -- Bug#5395227

  CURSOR get_tax_rate_csr_no_jur_mig IS
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
         NULL tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
    FROM ZX_SCO_RATES_B_V      -- Bug#5395227
   WHERE tax_jurisdiction_code IS NULL
     AND effective_from <= p_tax_date
     AND ( effective_to  >= p_tax_date  OR  effective_to IS NULL)
     AND tax_rate_code = p_tax_rate_code
     AND tax_status_code = p_tax_status_code
     AND tax = p_tax
     AND tax_regime_code = p_tax_regime_code
     AND Active_Flag = 'Y'
     AND tax_class = p_tax_class
     ORDER BY subscription_level_code;           -- Bug#5395227

 l_procedure_name              CONSTANT VARCHAR2(30) := 'get_tax_rate_no_jur_code';
 l_tax_rate_rec                ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
 --l_tax_rate_rec_tmp            ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.BEGIN',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_no_jur_code(+) ');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get tax rate with NULL tax class first
  --
  OPEN get_tax_rate_csr_no_jur;

  FETCH get_tax_rate_csr_no_jur INTO l_tax_rate_rec;

  IF get_tax_rate_csr_no_jur%FOUND THEN

    /* Bug#5395227- don't do a 2nd fetch
    FETCH get_tax_rate_csr_no_jur INTO l_tax_rate_rec_tmp;

    IF get_tax_rate_csr_no_jur%FOUND THEN
      -- raise error for multiple rate retrieved
      x_return_status:= FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME ('ZX','ZX_MULTIPLE_RATES_FOUND');
      FND_MESSAGE.SET_TOKEN('TAX_RATE_CODE',p_tax_rate_code);
      FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('TAX',p_tax);

      CLOSE get_tax_rate_csr_no_jur;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name,
                       'Too Many Tax Rate Rows Retrived. ');
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name||'.END',
                       'ZX_TCM_TAX_RATE_PKG.get_tax_rate_no_jur_code(-) ');
      END IF;

      RETURN;
    ELSE
    *****  Bug#5395227 ****/

      x_tax_rate_rec := l_tax_rate_rec;
      CLOSE get_tax_rate_csr_no_jur;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
      END IF;
    -- END IF;
  ELSE  -- get_tax_rate_csr_no_jur%NOTFOUND
    CLOSE get_tax_rate_csr_no_jur;

    -- tax rate is not found with NULL tax class, get tax rate with p_tax_class
    --
    OPEN get_tax_rate_csr_no_jur_mig;

    FETCH get_tax_rate_csr_no_jur_mig INTO l_tax_rate_rec;

    IF get_tax_rate_csr_no_jur_mig%FOUND THEN

      /* Bug#5395227- don't do a 2nd fetch
      FETCH get_tax_rate_csr_no_jur_mig INTO l_tax_rate_rec_tmp;

      IF get_tax_rate_csr_no_jur_mig%FOUND THEN
        -- raise error for multiple rate retrieved
        x_return_status:= FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME ('ZX','ZX_MULTIPLE_RATES_FOUND');
        FND_MESSAGE.SET_TOKEN('TAX_RATE_CODE',p_tax_rate_code);
        FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('TAX',p_tax);

        CLOSE get_tax_rate_csr_no_jur_mig;

        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name,
                         'Too Many Tax Rate Rows Retrived. ');
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name||'.END',
                         'ZX_TCM_TAX_RATE_PKG.get_tax_rate_no_jur_code(-) ');
        END IF;

        RETURN;
      ELSE
      *****  Bug#5395227 ****/

        x_tax_rate_rec := l_tax_rate_rec;
        CLOSE get_tax_rate_csr_no_jur_mig;

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
        END IF;

      --END IF;
    ELSE  -- get_tax_rate_csr_no_jur_mig%NOTFOUND
      CLOSE get_tax_rate_csr_no_jur_mig;
    END IF;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_no_jur_code(-) ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF get_tax_rate_csr_no_jur%ISOPEN THEN
      CLOSE get_tax_rate_csr_no_jur;
    END IF;
    IF get_tax_rate_csr_no_jur_mig%ISOPEN THEN
      CLOSE get_tax_rate_csr_no_jur_mig;
    END IF;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name,
                   sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_no_jur_code(-) ');
    END IF;
END get_tax_rate_no_jur_code;

------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_def_tax_rate_by_jur_code
--
--  DESCRIPTION
--  This procedure find default tax rate information match the passed in tax
--  information
------------------------------------------------------------------------------

PROCEDURE get_def_tax_rate_by_jur_code(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax_jurisdiction_code   IN    ZX_RATES_B.tax_jurisdiction_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
) IS

 -- the condition of tax_class is added for migration_data compatibility
 -- it is possible for migrated tax rates from AP and AR share the same tax
 -- rate code, in this case, need the tax_class info(AP: INPUT, AR: OUTPUT)
 -- to tell the tax rates apart.

 CURSOR  get_def_tax_rate_csr  IS
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
         NULL tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
    FROM ZX_SCO_RATES_B_V        -- Bug#5395227
   WHERE tax_status_code = p_tax_status_code
     AND tax = p_tax
     AND tax_regime_code = p_tax_regime_code
     AND tax_jurisdiction_code = p_tax_jurisdiction_code
     AND default_flg_effective_from <= p_tax_date
     AND (default_flg_effective_to >= p_tax_date
           OR default_flg_effective_to IS NULL)
     AND Default_Rate_Flag = 'Y'
     AND Active_Flag = 'Y'
     AND tax_class IS NULL
     ORDER BY subscription_level_code;             -- Bug#5395227

 CURSOR  get_def_tax_rate_mig_csr  IS
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
         NULL tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
    FROM ZX_SCO_RATES_B_V        -- Bug#5395227
   WHERE tax_status_code = p_tax_status_code
     AND tax = p_tax
     AND tax_regime_code = p_tax_regime_code
     AND tax_jurisdiction_code = p_tax_jurisdiction_code
     AND default_flg_effective_from <= p_tax_date
     AND (default_flg_effective_to >= p_tax_date
           OR default_flg_effective_to IS NULL)
     AND Default_Rate_Flag = 'Y'
     AND Active_Flag = 'Y'
     AND tax_class = p_tax_class
     ORDER BY subscription_level_code;              -- Bug#5395227

 l_procedure_name              CONSTANT VARCHAR2(30) := 'get_def_tax_rate_by_jur_code';
 l_tax_rate_rec                ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
 l_tax_rate_rec_tmp            ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.BEGIN',
                   'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_by_jur_code(+) ');
  END IF;

  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  -- get default tax rate code with NULL tax class first
  --
  OPEN get_def_tax_rate_csr;

  FETCH get_def_tax_rate_csr INTO l_tax_rate_rec;

  IF get_def_tax_rate_csr%FOUND THEN

    /* Bug#5395227- don't do a 2nd fetch
    FETCH get_def_tax_rate_csr INTO l_tax_rate_rec_tmp;

    IF get_def_tax_rate_csr%FOUND THEN
      -- raise error for multiple rate retrieved
      x_return_status:= FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME ('ZX','ZX_MULTI_DEFAULT_RATES_FOUND');
      FND_MESSAGE.SET_TOKEN('RATE_REGIME_CODE', p_tax_regime_code);
      FND_MESSAGE.SET_TOKEN('TAX_CODE',p_tax);
      FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('TAX',p_tax);

      CLOSE get_def_tax_rate_csr;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name,
                       'Too Many Tax Rate Rows Retrived. ');
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name||'.END',
                       'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_by_jur_code(-) ');
      END IF;
    ELSE
    *****  Bug#5395227 ****/

      x_tax_rate_rec := l_tax_rate_rec;
      CLOSE get_def_tax_rate_csr;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
      END IF;

   -- END IF;
  ELSE  -- get_def_tax_rate_csr%NOTFOUND
    CLOSE get_def_tax_rate_csr;

    -- tax rate is not found with NULL tax class, try to get it with p_tax_class
    --
    OPEN get_def_tax_rate_mig_csr;

    FETCH get_def_tax_rate_mig_csr INTO l_tax_rate_rec;

    IF get_def_tax_rate_mig_csr%FOUND THEN

      /* Bug#5395227- don't do a 2nd fetch
      FETCH get_def_tax_rate_mig_csr INTO l_tax_rate_rec_tmp;

      IF get_def_tax_rate_mig_csr%FOUND THEN
        -- raise error for multiple rate retrieved
        x_return_status:= FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME ('ZX','ZX_MULTI_DEFAULT_RATES_FOUND');
        FND_MESSAGE.SET_TOKEN('RATE_REGIME_CODE', p_tax_regime_code);
        FND_MESSAGE.SET_TOKEN('TAX_CODE',p_tax);
        FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('TAX',p_tax);

        CLOSE get_def_tax_rate_mig_csr;

        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name,
                         'Too Many Tax Rate Rows Retrived. ');
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name||'.END',
                         'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_by_jur_code(-) ');
        END IF;
      ELSE
      *****  Bug#5395227 ****/

        x_tax_rate_rec := l_tax_rate_rec;
        CLOSE get_def_tax_rate_mig_csr;

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
        END IF;

      -- END IF;
    ELSE  -- get_def_tax_rate_mig_csr%NOTFOUND
      CLOSE get_def_tax_rate_mig_csr;
    END IF;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_by_jur_code(-) ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF get_def_tax_rate_csr%ISOPEN THEN
      CLOSE get_def_tax_rate_csr;
    END IF;
    IF get_def_tax_rate_mig_csr%ISOPEN THEN
      CLOSE get_def_tax_rate_mig_csr;
    END IF;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name,
                   sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_by_jur_code(-) ');
    END IF;
END get_def_tax_rate_by_jur_code;

------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_def_tax_rate_no_jur_code
--
--  DESCRIPTION
--  This procedure find default tax rate information match the passed in tax
--  information without jurisdiction information
------------------------------------------------------------------------------

PROCEDURE get_def_tax_rate_no_jur_code(
  p_tax_class               IN    VARCHAR2,
  p_tax_regime_code         IN    ZX_RATES_B.tax_regime_code%TYPE,
  p_tax                     IN    ZX_RATES_B.tax%TYPE,
  p_tax_date                IN    DATE,
  p_tax_status_code         IN    ZX_RATES_B.tax_status_code%TYPE,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
) IS

 -- the condition of tax_class is added for migration_data compatibility
 -- it is possible for migrated tax rates from AP and AR share the same tax
 -- rate code, in this case, need the tax_class info(AP: INPUT, AR: OUTPUT)
 -- to tell the tax rates apart.

 CURSOR  get_def_tax_rate_no_jur_csr  IS
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
         NULL tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
    FROM ZX_SCO_RATES_B_V          -- Bug#5395227
   WHERE tax_status_code = p_tax_status_code
     AND tax = p_tax
     AND tax_regime_code = p_tax_regime_code
     AND tax_jurisdiction_code IS NULL
     AND default_flg_effective_from <= p_tax_date
     AND (default_flg_effective_to >= p_tax_date
           OR default_flg_effective_to IS NULL)
     AND Default_Rate_Flag = 'Y'
     AND Active_Flag = 'Y'
     AND tax_class IS NULL
     ORDER BY subscription_level_code;               -- Bug#5395227

 CURSOR  get_def_tax_rate_no_jur_mi_csr  IS
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
         NULL tax_jurisdiction_id,
         def_rec_settlement_option_code,
         taxable_basis_formula_code,
         adj_for_adhoc_amt_code,
         inclusive_tax_flag,
         tax_class
    FROM ZX_SCO_RATES_B_V        -- Bug#5395227
   WHERE tax_status_code = p_tax_status_code
     AND tax = p_tax
     AND tax_regime_code = p_tax_regime_code
     AND tax_jurisdiction_code IS NULL
     AND default_flg_effective_from <= p_tax_date
     AND (default_flg_effective_to >= p_tax_date
           OR default_flg_effective_to IS NULL)
     AND Default_Rate_Flag = 'Y'
     AND Active_Flag = 'Y'
     AND tax_class = p_tax_class
     ORDER BY subscription_level_code;             -- Bug#5395227

 l_procedure_name              CONSTANT VARCHAR2(30) := 'get_def_tax_rate_no_jur_code';
 l_tax_rate_rec                ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
 --l_tax_rate_rec_tmp            ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.BEGIN',
                   'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_no_jur_code(+) ');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Try to get tax rate with NULL tax class first
  --
  OPEN get_def_tax_rate_no_jur_csr;

  FETCH get_def_tax_rate_no_jur_csr INTO l_tax_rate_rec;
  IF get_def_tax_rate_no_jur_csr%FOUND THEN

    /* Bug#5395227- don't do a 2nd fetch
    FETCH get_def_tax_rate_no_jur_csr INTO l_tax_rate_rec_tmp;

    IF get_def_tax_rate_no_jur_csr%FOUND THEN
      -- raise error for multiple rate found
      x_return_status:= FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME ('ZX','ZX_MULTI_DEFAULT_RATES_FOUND');
      FND_MESSAGE.SET_TOKEN('RATE_REGIME_CODE', p_tax_regime_code);
      FND_MESSAGE.SET_TOKEN('TAX_CODE',p_tax);
      FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
      FND_MESSAGE.SET_TOKEN('TAX',p_tax);

      CLOSE get_def_tax_rate_no_jur_csr;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name,
                       'Too Many Tax Rate Rows Retrived. ');
        FND_LOG.STRING(g_level_unexpected,
                       g_module_name||'.'||l_procedure_name||'.END',
                       'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_no_jur_code(-) ');
      END IF;
      RETURN;
    ELSE
    *****  Bug#5395227 ****/

      x_tax_rate_rec := l_tax_rate_rec;
      CLOSE get_def_tax_rate_no_jur_csr;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
        FND_LOG.STRING(g_level_statement,
                       g_module_name||'.'||l_procedure_name,
                       'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
      END IF;

    -- END IF;
  ELSE -- get_def_tax_rate_no_jur_csr%NOTFOUND
    CLOSE get_def_tax_rate_no_jur_csr;

    -- tax rate is not found for NULL  tax_class, try to get it with p_tax_class
    --
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     g_module_name||'.'||l_procedure_name,
                    'tax_class = ' || p_tax_class);
    END IF;

    OPEN get_def_tax_rate_no_jur_mi_csr;

    FETCH get_def_tax_rate_no_jur_mi_csr INTO l_tax_rate_rec;
    IF get_def_tax_rate_no_jur_mi_csr%FOUND THEN

      /* Bug#5395227- don't do a 2nd fetch
      FETCH get_def_tax_rate_no_jur_mi_csr INTO l_tax_rate_rec_tmp;

      IF get_def_tax_rate_no_jur_mi_csr%FOUND THEN
        -- raise error for multiple rate found
        x_return_status:= FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME ('ZX','ZX_MULTI_DEFAULT_RATES_FOUND');
        FND_MESSAGE.SET_TOKEN('RATE_REGIME_CODE', p_tax_regime_code);
        FND_MESSAGE.SET_TOKEN('TAX_CODE',p_tax);
        FND_MESSAGE.SET_TOKEN('TAX_DET_DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);
        FND_MESSAGE.SET_TOKEN('TAX',p_tax);

        CLOSE get_def_tax_rate_no_jur_mi_csr;
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name,
                         'Too Many Tax Rate Rows Retrived. ');
          FND_LOG.STRING(g_level_unexpected,
                         g_module_name||'.'||l_procedure_name||'.END',
                         'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_no_jur_code(-) ');
        END IF;
        RETURN;
      ELSE
      *****  Bug#5395227 ****/

        x_tax_rate_rec := l_tax_rate_rec;
        CLOSE get_def_tax_rate_no_jur_mi_csr;

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'Found Tax rate: tax_rate_id: ' || x_tax_rate_rec.tax_rate_id );
          FND_LOG.STRING(g_level_statement,
                         g_module_name||'.'||l_procedure_name,
                         'tax_rate_code: ' || x_tax_rate_rec.tax_rate_code );
        END IF;

      -- END IF;
    ELSE -- get_def_tax_rate_no_jur_mi_csr%NOTFOUND
      CLOSE get_def_tax_rate_no_jur_mi_csr;
    END IF;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_no_jur_code(-) ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF get_def_tax_rate_no_jur_csr%ISOPEN THEN
      CLOSE get_def_tax_rate_no_jur_csr;
    END IF;
    IF get_def_tax_rate_no_jur_mi_csr%ISOPEN THEN
      CLOSE get_def_tax_rate_no_jur_mi_csr;
    END IF;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name,
                   sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_no_jur_code(-) ');
    END IF;
END get_def_tax_rate_no_jur_code;

------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_def_tax_rate_internal
--
--  DESCRIPTION
--  This procedure find tax rate information match the passed in tax info by
--  first getting the tax jurisdiction hierarchy
------------------------------------------------------------------------------

PROCEDURE get_tax_rate_internal(
  p_event_class_rec              IN  ZX_API_PUB.event_class_rec_type,
  p_tax_regime_code              IN  ZX_RATES_B.tax_regime_code%TYPE,
  p_tax                          IN  ZX_RATES_B.tax%TYPE,
  p_tax_date                     IN  DATE,
  p_tax_status_code              IN  ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code                IN  ZX_RATES_B.tax_rate_code%TYPE,
  p_place_of_supply_type_code    IN  ZX_LINES.place_of_supply_type_code%TYPE,
  p_structure_index              IN  NUMBER,
  p_multiple_jurisdictions_flag  IN  VARCHAR2,
  x_tax_rate_rec                 OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status                OUT NOCOPY VARCHAR2
) IS

 l_procedure_name              CONSTANT VARCHAR2(30) := 'get_tax_rate_internal';
 l_structure_name              VARCHAR2(30);
 l_location_id                 NUMBER;
 l_tax_jurisdiction_code       ZX_RATES_B.tax_jurisdiction_code%TYPE;
 l_tax_param_code              VARCHAR2(30);
 l_jurisdictions_found          VARCHAR2(1);
 l_tax_jurisdiction_rec         ZX_TCM_GEO_JUR_PKG.tax_jurisdiction_rec_type;
 l_multiple_jurisdictions_flag  VARCHAR2(1);
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.BEGIN',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_internal(+) ');
  END IF;

  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  -- get location_id
  l_structure_name := 'TRX_LINE_DIST_TBL';

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  g_module_name||'.'||l_procedure_name,
                  'Calling ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value...');
  END IF;

  l_tax_param_code := ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name(
                          p_place_of_supply_type_code,
                          x_return_status);

  IF NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
  THEN
    -- TCM procedure called in get_pos_parameter_name will set the error msg
    -- here we just need to return to the calling point which will populate
    -- the context information.
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             g_module_name||'.'||l_procedure_name,
             'Incorrect return_status after calling ' ||
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name');
      FND_LOG.STRING(g_level_statement,
             g_module_name||'.'||l_procedure_name,
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
             g_module_name||'.'||l_procedure_name||'.END',
             'ZX_TCM_TAX_RATE_PKG.get_tax_rate_internal(-) ');
    END IF;
    RETURN;
  END IF;

  ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
       p_struct_name     => l_structure_name,
       p_struct_index    => p_structure_index,
       p_tax_param_code  => l_tax_param_code,
       x_tax_param_value => l_location_id,
       x_return_status   => x_return_status );

  IF NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
  THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             g_module_name||'.'||l_procedure_name,
             'Incorrect return_status after calling ' ||
             'ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value');
      FND_LOG.STRING(g_level_statement,
             g_module_name||'.'||l_procedure_name,
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
             g_module_name||'.'||l_procedure_name||'.END',
             'ZX_TCM_TAX_RATE_PKG.get_tax_rate_internal(-)');
    END IF;
    RETURN;
  END IF;

  -- get tax jurisdiction hierarchy
  IF l_location_id IS NOT NULL THEN
    -- get the jurisdiction
    --
    ZX_TCM_GEO_JUR_PKG.get_tax_jurisdictions (
                       p_location_id      =>  l_location_id,
                       p_location_type    =>  p_place_of_supply_type_code,
                       p_tax              =>  p_tax,
                       p_tax_regime_code  =>  p_tax_regime_code,
                       p_trx_date         =>  p_tax_date,
                       x_tax_jurisdiction_rec =>  l_tax_jurisdiction_rec,
                       x_jurisdictions_found  =>  l_jurisdictions_found,
                       x_return_status    =>  x_return_status);

    IF NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      g_module_name||'.'||l_procedure_name,
                      'Incorrect return_status after calling ' ||
                      'ZX_TCM_GEO_JUR_PKG.get_tax_jurisdiction');
        FND_LOG.STRING(g_level_statement,
                      g_module_name||'.'||l_procedure_name,
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
                      g_module_name||'.'||l_procedure_name||'.END',
                      'ZX_TCM_TAX_RATE_PKG.get_tax_rate_internal(-)');
      END IF;
      RETURN;
    END IF;
  END IF;

  -- get tax rate loop through the jurisdiction hierarchy
  IF l_jurisdictions_found = 'Y' THEN
    IF l_tax_jurisdiction_rec.tax_jurisdiction_code IS NULL THEN
      l_multiple_jurisdictions_flag := 'Y';
    ELSE
      l_multiple_jurisdictions_flag := 'N';
    END IF;

    get_tax_rate(
      p_event_class_rec            => p_event_class_rec,
      p_tax_regime_code            => p_tax_regime_code,
      p_tax_jurisdiction_code      => l_tax_jurisdiction_rec.tax_jurisdiction_code,
      p_tax                        => p_tax,
      p_tax_date                   => p_tax_date,
      p_tax_status_code            => p_tax_status_code,
      p_tax_rate_code              => p_tax_rate_code,
      p_place_of_supply_type_code  => p_place_of_supply_type_code,
      p_structure_index            => p_structure_index,
      p_multiple_jurisdictions_flag => l_multiple_jurisdictions_flag,
      x_tax_rate_rec               => x_tax_rate_rec,
      x_return_status              => x_return_status
    );
  END IF;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             g_module_name||'.'||l_procedure_name,
             'Incorrect return_status after calling ' ||
             'ZX_TCM_TAX_RATE_PKG.get_tax_rate');
      FND_LOG.STRING(g_level_statement,
             g_module_name||'.'||l_procedure_name,
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
             g_module_name||'.'||l_procedure_name||'.END',
             'ZX_TCM_TAX_RATE_PKG.get_tax_rate_internal(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_internal(-) ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name,
                   sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_internal(-) ');
    END IF;

END get_tax_rate_internal;

------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_tax_rate_pvt
--
--  DESCRIPTION
--  This procedure find tax rate information match the passed in tax info
------------------------------------------------------------------------------

PROCEDURE get_tax_rate_pvt(
  p_tax_class                    IN  VARCHAR2,
  p_tax_regime_code              IN  ZX_RATES_B.tax_regime_code%TYPE,
  p_tax_jurisdiction_code        IN  ZX_RATES_B.tax_jurisdiction_code%TYPE,
  p_tax                          IN  ZX_RATES_B.tax%TYPE,
  p_tax_date                     IN  DATE,
  p_tax_status_code              IN  ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code                IN  ZX_RATES_B.tax_rate_code%TYPE,
  p_place_of_supply_type_code    IN  ZX_LINES.place_of_supply_type_code%TYPE,
  p_structure_index              IN  NUMBER,
  p_multiple_jurisdictions_flag  IN  VARCHAR2,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
) IS

 l_procedure_name              CONSTANT VARCHAR2(30) := 'get_tax_rate_pvt';
 l_tax_jurisdiction_code       ZX_RATES_B.tax_jurisdiction_code%TYPE;
 l_ind_rec                     NUMBER;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.BEGIN',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_pvt(+) ');
  END IF;

  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   g_module_name||'.'||l_procedure_name,
                   'p_multiple_jurisdictions_flag: '
                   || p_multiple_jurisdictions_flag);
  END IF;

  IF p_multiple_jurisdictions_flag = 'Y' THEN

      get_tax_rate_by_jur_gt(
        p_tax_class               => p_tax_class,
        p_tax_regime_code         => p_tax_regime_code,
        p_tax                     => p_tax,
        p_tax_date                => p_tax_date,
        p_tax_status_code         => p_tax_status_code,
        p_tax_rate_code           => p_tax_rate_code,
        x_tax_rate_rec            => x_tax_rate_rec,
        x_return_status           => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name,
                 'Incorrect return_status after calling ' ||
                 'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_code');
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name,
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name||'.END',
                 'ZX_TCM_TAX_RATE_PKG.get_tax_rate_pvt(-)');
        END IF;
        RETURN;
      END IF;

      -- if valid tax rate info found, then set the jurisdiction
      -- and return to the calling side.
      IF x_tax_rate_rec.tax_rate_id IS NOT NULL THEN
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         g_module_name||'.'||l_procedure_name||'.END',
                         'ZX_TCM_TAX_RATE_PKG.get_tax_rate_pvt(-) ');
        END IF;
        RETURN;
      END IF;
  END IF;

  IF p_tax_jurisdiction_code IS NOT NULL AND x_tax_rate_rec.tax_rate_id IS NULL
     THEN -- p_multiple_jurisdictions_flag = 'N'
      -- single jurisdiction case
      get_tax_rate_by_jur_code(
        p_tax_class               => p_tax_class,
        p_tax_regime_code         => p_tax_regime_code,
        p_tax_jurisdiction_code   => p_tax_jurisdiction_code,
        p_tax                     => p_tax,
        p_tax_date                => p_tax_date,
        p_tax_status_code         => p_tax_status_code,
        p_tax_rate_code           => p_tax_rate_code,
        x_tax_rate_rec            => x_tax_rate_rec,
        x_return_status           => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name,
                 'Incorrect return_status after calling ' ||
                 'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_code');
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name,
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name||'.END',
                 'ZX_TCM_TAX_RATE_PKG.get_tax_rate_pvt(-)');
        END IF;
        RETURN;
      END IF;

      -- if valid tax rate info found, then set the jurisdiction
      -- and return to the calling side.
      IF x_tax_rate_rec.tax_rate_id IS NOT NULL THEN
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         g_module_name||'.'||l_procedure_name||'.END',
                         'ZX_TCM_TAX_RATE_PKG.get_tax_rate_pvt(-) ');
        END IF;
        RETURN;
      END IF;
  END IF;

  -- if no tax_jurisdiction_code on the detail tax line or if no tax rate %
  -- found for the jurisdiction code on the detail tax line, go to find
  -- tax rate without jurisdiction code
  IF x_tax_rate_rec.tax_rate_id IS NULL THEN
    get_tax_rate_no_jur_code(
      p_tax_class               => p_tax_class,
      p_tax_regime_code         => p_tax_regime_code,
      p_tax                     => p_tax,
      p_tax_date                => p_tax_date,
      p_tax_status_code         => p_tax_status_code,
      p_tax_rate_code           => p_tax_rate_code,
      x_tax_rate_rec            => x_tax_rate_rec,
      x_return_status           => x_return_status
    );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name,
               'Incorrect return_status after calling ' ||
               'ZX_TCM_TAX_RATE_PKG.get_tax_rate_no_jur_code');
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name,
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name||'.END',
               'ZX_TCM_TAX_RATE_PKG.get_tax_rate_pvt(-)');
      END IF;
      RETURN;
    END IF;
  END IF;

  -- raise error when no tax rate found finally.
  IF x_tax_rate_rec.tax_rate_id IS NULL THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ZX','ZX_RATE_NOT_FOUND');
    FND_MESSAGE.SET_TOKEN('TAX_STATUS',p_tax_status_code);
    FND_MESSAGE.SET_TOKEN('TAX',p_tax);
    FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);

    IF (g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,
                    g_module_name||'.'||l_procedure_name,
                     'No rate found for tax rate code: ' ||p_tax_rate_code);
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_pvt(-) ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name,
                   sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate_pvt(-) ');
    END IF;
END get_tax_rate_pvt;

------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_def_tax_rate_pvt
--
--  DESCRIPTION
--  This procedure find tax rate information match the passed in tax info
------------------------------------------------------------------------------

PROCEDURE get_def_tax_rate_pvt(
  p_tax_class                    IN  VARCHAR2,
  p_tax_regime_code              IN  ZX_RATES_B.tax_regime_code%TYPE,
  p_tax_jurisdiction_code        IN  ZX_RATES_B.tax_jurisdiction_code%TYPE,
  p_tax                          IN  ZX_RATES_B.tax%TYPE,
  p_tax_date                     IN  DATE,
  p_tax_status_code              IN  ZX_RATES_B.tax_status_code%TYPE,
  p_place_of_supply_type_code    IN  ZX_LINES.place_of_supply_type_code%TYPE,
  p_structure_index              IN  NUMBER,
  p_multiple_jurisdictions_flag  IN  VARCHAR2,
  x_tax_rate_rec            OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2
) IS

 l_procedure_name              CONSTANT VARCHAR2(30) := 'get_def_tax_rate_pvt';

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.BEGIN',
                   'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_pvt(+) ');
  END IF;

  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   g_module_name||'.'||l_procedure_name,
                   'p_multiple_jurisdictions_flag: '
                   || p_multiple_jurisdictions_flag);
  END IF;

  -- for p_multiple_jurisdictions_flag
  IF p_multiple_jurisdictions_flag = 'Y' THEN

      get_def_tax_rate_by_jur_gt(
        p_tax_class               => p_tax_class,
        p_tax_regime_code         => p_tax_regime_code,
        p_tax                     => p_tax,
        p_tax_date                => p_tax_date,
        p_tax_status_code         => p_tax_status_code,
        x_tax_rate_rec            => x_tax_rate_rec,
        x_return_status           => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name,
                 'Incorrect return_status after calling ' ||
                 'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_gt');
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name,
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name||'.END',
                 'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_pvt(-)');
        END IF;
        RETURN;
      END IF;

      -- if valid tax rate info found, return to the calling side.
      IF x_tax_rate_rec.tax_rate_id IS NOT NULL THEN
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         g_module_name||'.'||l_procedure_name||'.END',
                         'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_pvt(-) ');
        END IF;
        RETURN;
      END IF;

  END IF;

  IF p_tax_jurisdiction_code IS NOT NULL AND x_tax_rate_rec.tax_rate_id IS NULL
     THEN  --p_multiple_jurisdictions_flag = 'N'

      -- single jurisdiction case
      get_def_tax_rate_by_jur_code(
        p_tax_class               => p_tax_class,
        p_tax_regime_code         => p_tax_regime_code,
        p_tax_jurisdiction_code   => p_tax_jurisdiction_code,
        p_tax                     => p_tax,
        p_tax_date                => p_tax_date,
        p_tax_status_code         => p_tax_status_code,
        x_tax_rate_rec            => x_tax_rate_rec,
        x_return_status           => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name,
                 'Incorrect return_status after calling ' ||
                 'ZX_TCM_TAX_RATE_PKG.get_tax_rate_by_jur_code');
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name,
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name||'.END',
                 'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_pvt(-)');
        END IF;
        RETURN;
      END IF;

      -- if valid tax rate info found, return to the calling side.
      IF x_tax_rate_rec.tax_rate_id IS NOT NULL THEN
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         g_module_name||'.'||l_procedure_name||'.END',
                         'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_pvt(-) ');
        END IF;
        RETURN;
      END IF;

  END IF;

  -- if no tax rate found, go to find tax rate without jurisdiction code
  IF x_tax_rate_rec.tax_rate_id IS NULL THEN
    get_def_tax_rate_no_jur_code(
      p_tax_class               => p_tax_class,
      p_tax_regime_code         => p_tax_regime_code,
      p_tax                     => p_tax,
      p_tax_date                => p_tax_date,
      p_tax_status_code         => p_tax_status_code,
      x_tax_rate_rec            => x_tax_rate_rec,
      x_return_status           => x_return_status
    );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name,
               'Incorrect return_status after calling ' ||
               'ZX_TCM_TAX_RATE_PKG.get_tax_rate_no_jur_code');
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name,
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name||'.END',
               'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_pvt(-)');
      END IF;
      RETURN;
    END IF;
  END IF;


  -- raise error when no tax rate found finally.
  IF x_tax_rate_rec.tax_rate_id IS NULL THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;

    FND_MESSAGE.SET_NAME('ZX','ZX_DEFAULT_RATE_NOT_FOUND');
    FND_MESSAGE.SET_TOKEN('TAX_STATUS',p_tax_status_code);
    FND_MESSAGE.SET_TOKEN('TAX',p_tax);
    FND_MESSAGE.SET_TOKEN('DATE',p_tax_date);

    IF (g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,
                    g_module_name||'.'||l_procedure_name,
                     'No default rate found for tax rate code');
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_pvt(-) ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name,
                   sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_pvt(-) ');
    END IF;

END get_def_tax_rate_pvt;

------------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_tax_rate
--
--  DESCRIPTION
--  This procedure find tax rate information match the passed in tax info
------------------------------------------------------------------------------

PROCEDURE get_tax_rate(
  p_event_class_rec              IN  ZX_API_PUB.event_class_rec_type,
  p_tax_regime_code              IN  ZX_RATES_B.tax_regime_code%TYPE,
  p_tax_jurisdiction_code        IN  ZX_RATES_B.tax_jurisdiction_code%TYPE,
  p_tax                          IN  ZX_RATES_B.tax%TYPE,
  p_tax_date                     IN  DATE,
  p_tax_status_code              IN  ZX_RATES_B.tax_status_code%TYPE,
  p_tax_rate_code                IN  ZX_RATES_B.tax_rate_code%TYPE,
  p_place_of_supply_type_code    IN  ZX_LINES.place_of_supply_type_code%TYPE,
  p_structure_index              IN  NUMBER,
  p_multiple_jurisdictions_flag  IN  VARCHAR2,
  x_tax_rate_rec                 OUT NOCOPY ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type,
  x_return_status                OUT NOCOPY VARCHAR2
) IS
  l_procedure_name               CONSTANT VARCHAR2(30) := 'get_tax_rate';
  l_count_jur                    NUMBER;
  l_tax_class                    VARCHAR2(30);
  l_tbl_index                    BINARY_INTEGER;
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.BEGIN',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate(+) ');
  END IF;

  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  g_module_name||'.'||l_procedure_name,
                  'p_tax = ' || p_tax);
    FND_LOG.STRING(g_level_statement,
                  g_module_name||'.'||l_procedure_name,
                  'p_tax_status_code = ' || p_tax_status_code);
    FND_LOG.STRING(g_level_statement,
                  g_module_name||'.'||l_procedure_name,
                  'p_tax_regime_code = ' || p_tax_regime_code);
    FND_LOG.STRING(g_level_statement,
                  g_module_name||'.'||l_procedure_name,
                  'p_tax_jurisdiction_code = ' || p_tax_jurisdiction_code);
    FND_LOG.STRING(g_level_statement,
                  g_module_name||'.'||l_procedure_name,
                  'p_tax_date = ' || p_tax_date);
  END IF;


  -- for general create and update case
  --   the ZX_JURISDICTIONS_GT will be populated if multiple jurisdictions found
  -- for jurisdiction code overriden case
  --   the p_multiple_jurisdictions_flag will be set to 'N' from the UI
  -- for other override case. eg. status / rate code override.
  --   global jurisdiction table: ZX_JURISDICTIONS_GT is empty need to call tcm API
  --   to retrieve the jurisdiction info again

  IF p_multiple_jurisdictions_flag ='Y' THEN
    SELECT COUNT(*) into l_count_jur
      FROM ZX_JURISDICTIONS_GT;

    IF l_count_jur = 0 THEN
      get_tax_rate_internal(
        p_event_class_rec         => p_event_class_rec,
        p_tax_regime_code         => p_tax_regime_code,
        p_tax                     => p_tax,
        p_tax_date                => p_tax_date,
        p_tax_status_code         => p_tax_status_code,
        p_tax_rate_code           => NULL,
        p_place_of_supply_type_code => p_place_of_supply_type_code,
        p_structure_index           => p_structure_index,
        p_multiple_jurisdictions_flag => p_multiple_jurisdictions_flag,
        x_tax_rate_rec            => x_tax_rate_rec,
        x_return_status           => x_return_status
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name,
                 'Incorrect return_status after calling ' ||
                 'ZX_TCM_TAX_RATE_PKG.get_tax_rate_internal');
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name,
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 g_module_name||'.'||l_procedure_name||'.END',
                 'ZX_TCM_TAX_RATE_PKG.get_tax_rate(-)');
        END IF;
        RETURN;
      END IF;
    END IF;
  END IF;

  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  IF p_tax_rate_code IS NOT NULL THEN
    -- l_tax_rate_code is available on tax line OR
    -- Rule base engine returns l_tax_rate_code
    --
    get_tax_rate_pvt(
      p_tax_class                   => l_tax_class,
      p_tax_regime_code             => p_tax_regime_code,
      p_tax_jurisdiction_code       => p_tax_jurisdiction_code,
      p_tax                         => p_tax,
      p_tax_date                    => p_tax_date,
      p_tax_status_code             => p_tax_status_code,
      p_tax_rate_code               => p_tax_rate_code,
      p_place_of_supply_type_code   => p_place_of_supply_type_code,
      p_structure_index             => p_structure_index,
      p_multiple_jurisdictions_flag => p_multiple_jurisdictions_flag,
      x_tax_rate_rec                => x_tax_rate_rec,
      x_return_status               => x_return_status
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name,
               'Incorrect return_status after calling ' ||
               'ZX_TCM_TAX_RATE_PKG.get_tax_rate_pvt');
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name,
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name||'.END',
               'ZX_TCM_TAX_RATE_PKG.get_tax_rate(-)');
      END IF;
      -- lower level should assign the fnd msg stack
      RETURN;
    END IF;
  END IF; ---- p_tax_rate_code is not null

  -- IF p_tax_rate_code is null or no tax_rate_code returned from rule engine.
  IF p_tax_rate_code IS NULL
    OR x_tax_rate_rec.tax_rate_id IS NULL
  THEN
    -- l_tax_rate_code is not available on tax line and rule engine
    -- does not return tax rate code. Hence get the Default tax rate code
    --
    -- get default tax rate code
    get_def_tax_rate_pvt(
      p_tax_class                   => l_tax_class,
      p_tax_regime_code             => p_tax_regime_code,
      p_tax_jurisdiction_code       => p_tax_jurisdiction_code,
      p_tax                         => p_tax,
      p_tax_date                    => p_tax_date,
      p_tax_status_code             => p_tax_status_code,
      p_place_of_supply_type_code   => p_place_of_supply_type_code,
      p_structure_index             => p_structure_index,
      p_multiple_jurisdictions_flag => p_multiple_jurisdictions_flag,
      x_tax_rate_rec                => x_tax_rate_rec,
      x_return_status               => x_return_status
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name,
               'Incorrect return_status after calling ' ||
               'ZX_TCM_TAX_RATE_PKG.get_def_tax_rate_pvt');
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name,
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               g_module_name||'.'||l_procedure_name||'.END',
               'ZX_TCM_TAX_RATE_PKG.get_tax_rate(-)');
      END IF;
      -- lower level should have set the fnd msg stack
      RETURN;
    END IF;

  END IF; -- p_tax_rate_code is null or no tax_rate info
          -- found for the tax_rate_code returned from rule engine.

  IF x_tax_rate_rec.tax_rate_id IS NOT NULL THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    g_module_name||'.'||l_procedure_name,
                    'tax_rate_code = ' || x_tax_rate_rec.tax_rate_code);
      FND_LOG.STRING(g_level_statement,
                    g_module_name||'.'||l_procedure_name,
                    'tax_rate_id = ' || x_tax_rate_rec.tax_rate_id);
      FND_LOG.STRING(g_level_statement,
                    g_module_name||'.'||l_procedure_name,
                    'rate_type = ' || x_tax_rate_rec.rate_type_code);
      FND_LOG.STRING(g_level_statement,
                    g_module_name||'.'||l_procedure_name,
                    'percentage_rate = ' || x_tax_rate_rec.percentage_rate);
      FND_LOG.STRING(g_level_statement,
                    g_module_name||'.'||l_procedure_name,
                    'quantity_rate = ' || x_tax_rate_rec.quantity_rate);
      FND_LOG.STRING(g_level_statement,
                    g_module_name||'.'||l_procedure_name,
                    'allow_adhoc_tax_rate_flag = ' || x_tax_rate_rec.allow_adhoc_tax_rate_flag);
      FND_LOG.STRING(g_level_statement,
                    g_module_name||'.'||l_procedure_name,
                    'uom_code = ' || x_tax_rate_rec.uom_code);
      FND_LOG.STRING(g_level_statement,
                    g_module_name||'.'||l_procedure_name,
                    'offset_tax_rate_code = ' || x_tax_rate_rec.offset_tax_rate_code);
    END IF;
  END IF;

  -- populate the cached structure ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash
  -- for reference by ZX_TDS_APPLICABILITY_DETM_PKG.get_process_Results for batch calculation calls
  -- since this procedure only checks the existence of a rate record having the same tax class
  -- it should be ok to refecene this record.

     l_tbl_index := dbms_utility.get_hash_value(
                x_tax_rate_rec.tax_regime_code||x_tax_rate_rec.tax||
                x_tax_rate_rec.tax_status_code||x_tax_rate_rec.tax_rate_code,
                1,
                8192);

      ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash(l_tbl_index) := x_tax_rate_rec;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate(-) ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name,
                   sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                   g_module_name||'.'||l_procedure_name||'.END',
                   'ZX_TCM_TAX_RATE_PKG.get_tax_rate(-) ');
    END IF;

END get_tax_rate;

END ZX_TCM_TAX_RATE_PKG;


/
