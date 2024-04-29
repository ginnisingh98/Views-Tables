--------------------------------------------------------
--  DDL for Package Body ZX_TDS_OFFSET_TAX_DETM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_OFFSET_TAX_DETM_PKG" as
/* $Header: zxdioffsettxpkgb.pls 120.43.12010000.3 2010/02/12 11:47:00 msakalab ship $ */

PROCEDURE get_offset_info(
            p_tax_rate_code         IN     ZX_RATES_B.TAX_RATE_CODE%TYPE,
            p_tax                   IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code       IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax_status_code       IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_tax_determine_date    IN     ZX_DETAIL_TAX_LINES_GT.TAX_DETERMINE_DATE%TYPE,
            p_tax_jurisdiction_code IN     ZX_JURISDICTIONS_B.tax_jurisdiction_code%TYPE,
            p_tax_class             IN     ZX_RATES_B.TAX_CLASS%TYPE,
            p_offset_tax_rate_id       OUT NOCOPY ZX_RATES_B.TAX_RATE_ID%TYPE,
            p_tax_rate                 OUT NOCOPY ZX_LINES.TAX_RATE%TYPE,
            p_return_status            OUT NOCOPY VARCHAR2,
            p_error_buffer             OUT NOCOPY VARCHAR2);

PROCEDURE set_null_columns(
            p_offset_tax_line_rec   IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE);

PROCEDURE set_flg_columns(
            p_offset_tax_line_rec   IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE);

PROCEDURE set_amt_columns(
            p_offset_tax_line_rec   IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_parent_tax_rate       IN            VARCHAR2,
            p_initial_tax_rate      IN            NUMBER,
            p_return_status            OUT NOCOPY VARCHAR2,
            p_error_buffer             OUT NOCOPY VARCHAR2);


PROCEDURE get_tax_status_id(
            p_tax_regime_code       IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax                   IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_status_code       IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_tax_determine_date    IN     ZX_DETAIL_TAX_LINES_GT.TAX_DETERMINE_DATE%TYPE,
            p_tax_status_id            OUT NOCOPY ZX_STATUS_B.TAX_STATUS_ID%TYPE,
            p_return_status            OUT NOCOPY VARCHAR2,
            p_error_buffer             OUT NOCOPY VARCHAR2);

PROCEDURE get_tax_id(
            p_tax_regime_code       IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax                   IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_determine_date    IN     ZX_DETAIL_TAX_LINES_GT.TAX_DETERMINE_DATE%TYPE,
            p_tax_id                   OUT NOCOPY ZX_TAXES_B.TAX_ID%TYPE,
            p_return_status            OUT NOCOPY VARCHAR2,
            p_error_buffer             OUT NOCOPY VARCHAR2);

PROCEDURE get_old_offset_tax_line_id(
            p_event_class_rec        IN                ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_offset_tax_line_rec    IN                ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_old_offset_tax_line_id    OUT NOCOPY ZX_LINES.TAX_LINE_ID%TYPE,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2);

PROCEDURE create_offset_tax_line(
            p_offset_tax_line_rec    IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_event_class_rec        IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_offset_tax_rate_code   IN     ZX_RATES_B.TAX_RATE_CODE%TYPE,
            p_offset_tax_rate_id     IN     ZX_RATES_B.TAX_RATE_ID%TYPE,
            p_tax_rate               IN     ZX_LINES.TAX_RATE%TYPE,
            p_initial_tax_rate       IN     ZX_LINES.TAX_RATE%TYPE,
            p_offset_tax             IN     ZX_TAXES_B.TAX%TYPE,
            p_offset_status_code     IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2);

g_current_runtime_level      NUMBER;
g_level_statement            CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure            CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_unexpected           CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
g_level_error 		     CONSTANT  NUMBER   := FND_LOG.LEVEL_ERROR;

----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  process_offset_tax
--
--  DESCRIPTION
--
--  This procedure is the entry point to offset tax determination process

PROCEDURE process_offset_tax(
            p_offset_tax_line_rec  IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_event_class_rec      IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2)

IS
  l_tax_rate_id               ZX_RATES_B.TAX_RATE_ID%TYPE;
  l_offset_tax_rate_id        ZX_RATES_B.TAX_RATE_ID%TYPE;
  l_offset_tax_rate           ZX_LINES.TAX_RATE%TYPE;
  l_initial_tax_rate          ZX_LINES.TAX_RATE%TYPE;
  l_offset_tax                ZX_TAXES_B.TAX%TYPE;
  l_offset_tax_regime_code    ZX_REGIMES_B.TAX_REGIME_CODE%TYPE;
  l_offset_tax_status_code    ZX_STATUS_B.TAX_STATUS_CODE%TYPE;
  l_offset_tax_rate_code      ZX_RATES_B.OFFSET_TAX_RATE_CODE%TYPE;
  l_tax_rate_rec              ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
  l_tax_class                 ZX_RATES_B.TAX_CLASS%TYPE;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.process_offset_tax.BEGIN',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: process_offset_tax(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;
  p_error_buffer  := NULL;

  -- Bug#5417753- determine tax_class value
  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  l_tax_rate_id := p_offset_tax_line_rec.tax_rate_id;
  l_offset_tax_regime_code := p_offset_tax_line_rec.tax_regime_code;


  IF ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl.EXISTS(l_tax_rate_id) THEN
    l_offset_tax_rate_code :=
        ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl(l_tax_rate_id).offset_tax_rate_code;
    l_offset_tax_status_code :=
        ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl(l_tax_rate_id).offset_status_code;
    l_offset_tax :=
        ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl(l_tax_rate_id).offset_tax;

    l_initial_tax_rate :=
        ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl(l_tax_rate_id).percentage_rate;
  ELSE

    ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
      p_tax_rate_id      => l_tax_rate_id,
      p_tax_rate_rec     => l_tax_rate_rec,
      p_return_status    => p_return_status,
      p_error_buffer     => p_error_buffer
    );
    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.process_offset_tax',
                     'Incorrect status returned from ZX_TDS_UTILITIES_PKG.get_tax_rate_info'||
                     'p_return_status = ' || p_return_status);
        FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.process_offset_tax',
                     'p_error_buffer  = ' || p_error_buffer);
      END IF;
      RETURN;
    END IF;

    ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl(l_tax_rate_id) := l_tax_rate_rec;

    l_offset_tax_rate_code   := l_tax_rate_rec.offset_tax_rate_code;
    l_offset_tax_status_code := l_tax_rate_rec.offset_status_code;
    l_offset_tax             := l_tax_rate_rec.offset_tax;
    l_initial_tax_rate       := l_tax_rate_rec.percentage_rate;

  END IF;

  get_offset_info(l_offset_tax_rate_code,
                  l_offset_tax,
                  l_offset_tax_regime_code,
                  l_offset_tax_status_code,
                  p_offset_tax_line_rec.tax_determine_date,
                  p_offset_tax_line_rec.tax_jurisdiction_code,
                  l_tax_class,
                  l_offset_tax_rate_id,
                  l_offset_tax_rate,
                  p_return_status,
                  p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    --
    -- bug#4893261- need to seed ZX_OFFSET_RATE_NOT_FOUND
    --
    IF p_return_status = FND_API.G_RET_STS_ERROR THEN
      FND_MESSAGE.SET_NAME('ZX','ZX_OFFSET_RATE_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('TAX_REGIME', l_offset_tax_regime_code);
        FND_MESSAGE.SET_TOKEN('TAX',l_offset_tax);
        FND_MESSAGE.SET_TOKEN('TAX_STATUS',l_offset_tax_status_code);
        FND_MESSAGE.SET_TOKEN('TAX_RATE_CODE', l_offset_tax_rate_code);

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
                            p_offset_tax_line_rec.trx_line_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
                            p_offset_tax_line_rec.trx_level_type;

        ZX_API_PUB.add_msg(
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

    END IF;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.process_offset_tax.END',
                   'initial tax rate '||to_char(l_initial_tax_rate));
  END IF;
  create_offset_tax_line(p_offset_tax_line_rec,
                         p_event_class_rec,
                         l_offset_tax_rate_code,
                         l_offset_tax_rate_id,
                         l_offset_tax_rate,
                         l_initial_tax_rate,
                         l_offset_tax,
                         l_offset_tax_status_code,
                         p_return_status,
                         p_error_buffer);
  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.process_offset_tax.END',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: process_offset_tax(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.process_offset_tax',
                      p_error_buffer);
    END IF;

END process_offset_tax;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_offset_info
--
--  DESCRIPTION
--  This procedure gets offset tax info from ZX_RATES_B
--
PROCEDURE get_offset_info(
            p_tax_rate_code         IN     ZX_RATES_B.TAX_RATE_CODE%TYPE,
            p_tax                   IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code       IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax_status_code       IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_tax_determine_date    IN     ZX_DETAIL_TAX_LINES_GT.TAX_DETERMINE_DATE%TYPE,
            p_tax_jurisdiction_code IN     ZX_JURISDICTIONS_B.tax_jurisdiction_code%TYPE,
            p_tax_class             IN     ZX_RATES_B.TAX_CLASS%TYPE,
            p_offset_tax_rate_id       OUT NOCOPY    ZX_RATES_B.TAX_RATE_ID%TYPE,
            p_tax_rate                 OUT NOCOPY ZX_LINES.TAX_RATE%TYPE,
            p_return_status            OUT NOCOPY VARCHAR2,
            p_error_buffer             OUT NOCOPY VARCHAR2)

IS
  --l_Rate_Type_Code           ZX_RATES_B.Rate_Type_Code%TYPE;
  --l_percentage_rate          ZX_RATES_B.PERCENTAGE_RATE%TYPE;
  --l_quantity_rate            ZX_RATES_B.QUANTITY_RATE%TYPE;
  l_tax_rate_rec               ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

  /* Bug#5417753- use cache structure
  CURSOR get_offset_info_csr
    (c_tax_rate_code         ZX_RATES_B.TAX_RATE_CODE%TYPE,
     c_tax                   ZX_TAXES_B.TAX%TYPE,
     c_tax_regime_code       ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_status_code       ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
     c_tax_determine_date    ZX_DETAIL_TAX_LINES_GT.TAX_DETERMINE_DATE%TYPE)
  IS

    SELECT tax_rate_id,
           Rate_Type_Code,
           percentage_rate,
           quantity_rate
      FROM ZX_SCO_RATES_B_V
      WHERE tax_rate_code   = c_tax_rate_code         AND
            tax             = c_tax                   AND
            tax_regime_code = c_tax_regime_code       AND
            tax_status_code = c_tax_status_code       AND
            active_flag     = 'Y'                     AND
            c_tax_determine_date >= effective_from    AND
            (c_tax_determine_date <= effective_to     OR
             effective_to IS NULL)
    ORDER BY subscription_level_code;
   */

BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_offset_info.BEGIN',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: get_offset_info(+)'||
                   'p_tax_rate_code = ' || p_tax_rate_code||
                   'p_tax = ' || p_tax||
                   'p_tax_regime_code = ' || p_tax_regime_code||
                   'p_tax_jurisdiction_code = ' || p_tax_jurisdiction_code ||
                   'p_tax_class = ' || p_tax_class ||
                   'p_tax_status_code = ' || p_tax_status_code);

  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Bug#5417753- use cache structure
  OPEN get_offset_info_csr(p_tax_rate_code,
                           p_tax,
                           p_tax_regime_code,
                           p_tax_status_code,
                           p_tax_determine_date);
  FETCH get_offset_info_csr INTO
    p_offset_tax_rate_id,
    l_Rate_Type_Code,
    l_percentage_rate,
    l_quantity_rate;
  IF get_offset_info_csr%NOTFOUND THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    p_error_buffer  := 'No data found for the specified tax rate ';
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
                        l_tax_rate_rec,
                        p_return_status,
                        p_error_buffer);

  IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
    p_offset_tax_rate_id := l_tax_rate_rec.tax_rate_id;

    IF l_tax_rate_rec.Rate_Type_Code = 'PERCENTAGE' THEN
      p_tax_rate := l_tax_rate_rec.percentage_rate;
    ELSE
      p_tax_rate := l_tax_rate_rec.quantity_rate;
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_offset_info.END',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: get_offset_info(-)'||
                   'p_tax_rate = ' || to_char(p_tax_rate));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  :=  sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (FND_LOG.LEVEL_UNEXPECTED >= g_current_runtime_level ) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_offset_info',
                     'p_error_buffer  = ' || p_error_buffer);
  END IF;
END get_offset_info;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  set_null_columns
--
--  DESCRIPTION
--  This procedure sets the values of columns to NULL

PROCEDURE set_null_columns(
            p_offset_tax_line_rec IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE)
IS
BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.set_null_columns.BEGIN',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: set_null_columns(+)');
  END IF;

  p_offset_tax_line_rec.orig_tax_status_id             := NULL;
  p_offset_tax_line_rec.orig_tax_status_code           := NULL;
  p_offset_tax_line_rec.orig_tax_rate_id               := NULL;
  p_offset_tax_line_rec.orig_tax_rate_code             := NULL;
  p_offset_tax_line_rec.orig_tax_rate                  := NULL;
  p_offset_tax_line_rec.orig_taxable_amt               := NULL;
  p_offset_tax_line_rec.orig_taxable_amt_tax_curr      := NULL;
  p_offset_tax_line_rec.orig_tax_amt                   := NULL;
  p_offset_tax_line_rec.orig_tax_amt_tax_curr          := NULL;
--  p_offset_tax_line_rec.offset_tax_line_number         := NULL;
  p_offset_tax_line_rec.created_by                     := NULL;
  p_offset_tax_line_rec.creation_date                  := NULL;
  p_offset_tax_line_rec.tax_line_id                    := NULL;
  p_offset_tax_line_rec.last_manual_entry              := NULL;
  p_offset_tax_line_rec.tax_provider_id                := NULL;
  p_offset_tax_line_rec.tax_applicability_result_id    := NULL;
  p_offset_tax_line_rec.status_result_id               := NULL;
  p_offset_tax_line_rec.rate_result_id                 := NULL;
  p_offset_tax_line_rec.basis_result_id                := NULL;
  p_offset_tax_line_rec.thresh_result_id               := NULL;
  p_offset_tax_line_rec.calc_result_id                 := NULL;
  p_offset_tax_line_rec.direct_rate_result_id          := NULL;
  p_offset_tax_line_rec.tax_apportionment_line_number  := NULL;
  p_offset_tax_line_rec.summary_tax_line_id            := NULL;
  p_offset_tax_line_rec.tax_hold_code                  := NULL;
  p_offset_tax_line_rec.tax_hold_released_code         := NULL;
  p_offset_tax_line_rec.legal_message_appl_2           := NULL;
  p_offset_tax_line_rec.legal_message_status           := NULL;
  p_offset_tax_line_rec.legal_message_rate             := NULL;
  p_offset_tax_line_rec.legal_message_basis            := NULL;
  p_offset_tax_line_rec.legal_message_calc             := NULL;
  p_offset_tax_line_rec.legal_message_pos              := NULL;
  p_offset_tax_line_rec.legal_message_trn              := NULL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.set_null_columns.END',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: set_null_columns(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.set_null_columns',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END set_null_columns;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  set_flg_columns
--
--  DESCRIPTION
--  This procedure initializes the value of flag columns

PROCEDURE set_flg_columns(
            p_offset_tax_line_rec IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE)
IS
BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.set_flg_columns.BEGIN',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: set_flg_columns(+)');
  END IF;

  p_offset_tax_line_rec.Offset_Flag                     := 'Y'; --Bug6509867
  p_offset_tax_line_rec.Compounding_Tax_Flag            := 'N';
  p_offset_tax_line_rec.Tax_Apportionment_Flag          := 'N';
  p_offset_tax_line_rec.Overridden_Flag                 := 'N';
  p_offset_tax_line_rec.Manually_Entered_Flag           := 'N';
  p_offset_tax_line_rec.Reporting_Only_Flag             := 'N';
  p_offset_tax_line_rec.Freeze_Until_Overridden_Flag    := 'N';
  p_offset_tax_line_rec.Copied_From_Other_Doc_Flag      := 'N';
  p_offset_tax_line_rec.Recalc_Required_Flag            := 'N';
  p_offset_tax_line_rec.Settlement_Flag                 := 'N';
  p_offset_tax_line_rec.Associated_Child_Frozen_Flag    := 'N';
  p_offset_tax_line_rec.Enforce_From_Natural_Acct_Flag  := 'N';
  p_offset_tax_line_rec.Historical_Flag                 := 'N';

  -- should get from the parent line
  -- p_offset_tax_line_rec.Process_For_Recovery_Flag       := 'Y';

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.set_flg_columns.END',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: set_flg_columns(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.set_flg_columns',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END set_flg_columns;
----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  set_amt_columns
--
--  DESCRIPTION
--  This procedure populates tax amount related columns

PROCEDURE set_amt_columns(
            p_offset_tax_line_rec IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_parent_tax_rate     IN            VARCHAR2,
            p_initial_tax_rate    IN            NUMBER,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2
)
IS
  l_tax_id                ZX_TAXES_B.TAX_ID%TYPE;
  l_tax_min_acct_unit     ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_tax_precision         ZX_TAXES_B.TAX_PRECISION%TYPE;
BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.set_amt_columns.BEGIN',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: set_amt_columns(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- taxable amounts would be same as the original tax line
  -- do not need to change unrounded_taxable_amt,
  -- taxable_amt, taxable_amt_tax_curr, taxable_amt_funcl_curr
  --

  --
  -- prorated total amounts would be opposite of original tax line
  --
  p_offset_tax_line_rec.prd_total_tax_amt := - p_offset_tax_line_rec.prd_total_tax_amt;
  p_offset_tax_line_rec.prd_total_tax_amt_tax_curr := - p_offset_tax_line_rec.prd_total_tax_amt_tax_curr;
  p_offset_tax_line_rec.prd_total_tax_amt_funcl_curr := - p_offset_tax_line_rec.prd_total_tax_amt_funcl_curr;

  --
  -- check to see if need to recalculate tax related amounts
  -- if offset tax rate is different
  --

  IF (p_offset_tax_line_rec.tax_rate + p_parent_tax_rate = 0 ) THEN
    --
    -- set all offset amounts to negative, no need to recalculate
    --
    p_offset_tax_line_rec.unrounded_tax_amt := - p_offset_tax_line_rec.unrounded_tax_amt;
    p_offset_tax_line_rec.tax_amt := - p_offset_tax_line_rec.tax_amt;
    p_offset_tax_line_rec.tax_amt_tax_curr := - p_offset_tax_line_rec.tax_amt_tax_curr;
    p_offset_tax_line_rec.cal_tax_amt := p_offset_tax_line_rec.tax_amt;
    p_offset_tax_line_rec.cal_tax_amt_tax_curr := p_offset_tax_line_rec.tax_amt_tax_curr;
    p_offset_tax_line_rec.tax_amt_funcl_curr := - p_offset_tax_line_rec.tax_amt_funcl_curr;
    p_offset_tax_line_rec.cal_tax_amt_funcl_curr  := - p_offset_tax_line_rec.cal_tax_amt_funcl_curr;

    RETURN;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.set_amt_columns.END',
                   'initia tax rate'||to_number(p_initial_tax_rate));
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.set_amt_columns.END',
                   'offset tax rate'||to_number(p_offset_tax_line_rec.tax_rate));
  END IF;
  IF (p_offset_tax_line_rec.tax_rate + p_initial_tax_rate = 0 ) THEN
    --
    -- set all offset amounts to negative, no need to recalculate
    --
    p_offset_tax_line_rec.unrounded_tax_amt := - p_offset_tax_line_rec.unrounded_tax_amt;
    p_offset_tax_line_rec.tax_amt := - p_offset_tax_line_rec.tax_amt;
    p_offset_tax_line_rec.tax_amt_tax_curr := - p_offset_tax_line_rec.tax_amt_tax_curr;
    p_offset_tax_line_rec.cal_tax_amt := p_offset_tax_line_rec.tax_amt;
    p_offset_tax_line_rec.cal_tax_amt_tax_curr := p_offset_tax_line_rec.tax_amt_tax_curr;
    p_offset_tax_line_rec.tax_amt_funcl_curr := - p_offset_tax_line_rec.tax_amt_funcl_curr;
    p_offset_tax_line_rec.cal_tax_amt_funcl_curr  := - p_offset_tax_line_rec.cal_tax_amt_funcl_curr;
    p_offset_tax_line_rec.tax_rate  := - p_parent_tax_rate;

    RETURN;
  END IF;
  --
  -- offset tax has a different rate, need to recalculate amounts
  --

  p_offset_tax_line_rec.unrounded_tax_amt :=
     p_offset_tax_line_rec.unrounded_taxable_amt * p_offset_tax_line_rec.tax_rate/100;

  --
  -- tax amount
  --
  p_offset_tax_line_rec.tax_amt := p_offset_tax_line_rec.unrounded_tax_amt;

  p_offset_tax_line_rec.tax_amt :=
    ZX_TDS_TAX_ROUNDING_PKG.round_tax(
              p_offset_tax_line_rec.tax_amt,
              p_offset_tax_line_rec.Rounding_Rule_Code,
              p_offset_tax_line_rec.minimum_accountable_unit,
              p_offset_tax_line_rec.precision,
              p_return_status,
              p_error_buffer);


  IF p_offset_tax_line_rec.mrc_tax_line_flag = 'N' THEN
    --
    -- tax amount tax currency
    --
    p_offset_tax_line_rec.tax_amt_tax_curr :=
      p_offset_tax_line_rec.unrounded_tax_amt * p_offset_tax_line_rec.tax_currency_conversion_rate;

    --
    -- now round the tax amount tax currency
    --

    l_tax_id := p_offset_tax_line_rec.tax_id;
    l_tax_precision := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).tax_precision;
    l_tax_min_acct_unit := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).minimum_accountable_unit;

    p_offset_tax_line_rec.tax_amt_tax_curr :=
        ZX_TDS_TAX_ROUNDING_PKG.round_tax(
                p_offset_tax_line_rec.tax_amt_tax_curr,
                p_offset_tax_line_rec.Rounding_Rule_Code,
                l_tax_min_acct_unit,
                l_tax_precision,
                p_return_status,
                p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;

    --
    -- functional currency
    --

    IF p_offset_tax_line_rec.currency_conversion_rate IS NOT NULL THEN
      p_offset_tax_line_rec.tax_amt_funcl_curr :=
        p_offset_tax_line_rec.unrounded_tax_amt * p_offset_tax_line_rec.currency_conversion_rate;

      p_offset_tax_line_rec.tax_amt_funcl_curr :=
        ZX_TDS_TAX_ROUNDING_PKG.round_tax_funcl_curr(
                p_offset_tax_line_rec.tax_amt_funcl_curr,
                p_offset_tax_line_rec.ledger_id,
                p_return_status,
                p_error_buffer);

    END IF;
  END IF;

  --
  -- calculated tax amounts
  --
  p_offset_tax_line_rec.cal_tax_amt := p_offset_tax_line_rec.tax_amt;
  p_offset_tax_line_rec.cal_tax_amt_tax_curr := p_offset_tax_line_rec.tax_amt_tax_curr;
  p_offset_tax_line_rec.cal_tax_amt_funcl_curr := p_offset_tax_line_rec.tax_amt_funcl_curr;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.set_amt_columns.END',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: set_amt_columns(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.set_amt_columns',
                      p_error_buffer);
    END IF;

END set_amt_columns;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_tax_status_id
--
--  DESCRIPTION
--  This procedure gets  tax status id from global cache structure based on
--  tax regime code, tax and tax status code
--
PROCEDURE get_tax_status_id(
            p_tax_regime_code       IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax                   IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_status_code       IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_tax_determine_date    IN     ZX_DETAIL_TAX_LINES_GT.TAX_DETERMINE_DATE%TYPE,
            p_tax_status_id            OUT NOCOPY ZX_STATUS_B.TAX_STATUS_ID%TYPE,
            p_return_status            OUT NOCOPY VARCHAR2,
            p_error_buffer             OUT NOCOPY VARCHAR2)

IS
  l_status_rec       ZX_TDS_UTILITIES_PKG.ZX_STATUS_INFO_REC;

BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_tax_status_id.BEGIN',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: get_tax_status_id(+)');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                                  p_tax,
                                  p_tax_regime_code,
                                  p_tax_status_code,
                                  p_tax_determine_date,
                                  l_status_rec,
                                  p_return_status,
                                  p_error_buffer);

  IF p_return_status = FND_API.G_RET_STS_SUCCESS  THEN
    p_tax_status_id := l_status_rec.tax_status_id;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_tax_status_id.END',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: get_tax_status_id(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_tax_status_id',
                      p_error_buffer);
    END IF;

END get_tax_status_id;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_tax_id
--
--  DESCRIPTION
--  This procedure gets  tax id from zx_taxes based on
--  tax regime code and  tax
--
PROCEDURE get_tax_id(
            p_tax_regime_code       IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax                   IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_determine_date    IN     ZX_DETAIL_TAX_LINES_GT.TAX_DETERMINE_DATE%TYPE,
            p_tax_id                   OUT NOCOPY ZX_TAXES_B.TAX_ID%TYPE,
            p_return_status            OUT NOCOPY VARCHAR2,
            p_error_buffer             OUT NOCOPY VARCHAR2)

IS
  l_tax_rec         ZX_TDS_UTILITIES_PKG.ZX_TAX_INFO_CACHE_REC;
BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_tax_id.BEGIN',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: get_tax_id(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                        p_tax_regime_code,
                        p_tax,
                        p_tax_determine_date,
                        l_tax_rec,
                        p_return_status,
                        p_error_buffer);

  IF p_return_status = FND_API.G_RET_STS_SUCCESS  THEN
    p_tax_id := l_tax_rec.tax_id;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_tax_id.END',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: get_tax_id(-)'||
                   'p_tax_id = ' || to_char(p_tax_id)||
                   'p_return_status = ' || p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_tax_id',
                      p_error_buffer);
    END IF;

END get_tax_id;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_old_offset_tax_line_id
--
--  DESCRIPTION
--
--  The procedure gets the tax line id of an offset tax line
--  from the repository based on the value of the tax line id
--  it links to

PROCEDURE get_old_offset_tax_line_id(
            p_event_class_rec            IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_offset_tax_line_rec        IN            ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_old_offset_tax_line_id        OUT NOCOPY ZX_LINES.TAX_LINE_ID%TYPE,
            p_return_status                 OUT NOCOPY VARCHAR2,
            p_error_buffer                  OUT NOCOPY VARCHAR2)
IS


  CURSOR get_old_offset_tax_line_id_csr
  -- (c_offset_link_to_tax_line_id   ZX_LINES.OFFSET_LINK_TO_TAX_LINE_ID%TYPE)
  IS
    SELECT tax_line_id
      FROM ZX_LINES
     WHERE APPLICATION_ID = p_offset_tax_line_rec.APPLICATION_ID
       AND ENTITY_CODE = p_offset_tax_line_rec.ENTITY_CODE
       AND EVENT_CLASS_CODE = p_offset_tax_line_rec.EVENT_CLASS_CODE
       AND trx_id = p_offset_tax_line_rec.trx_id
       AND trx_line_id = p_offset_tax_line_rec.trx_line_id
       AND trx_level_type = p_offset_tax_line_rec.trx_level_type
       AND tax_regime_code = p_offset_tax_line_rec.tax_regime_code
       AND offset_link_to_tax_line_id = p_offset_tax_line_rec.offset_link_to_tax_line_id;

BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_old_offset_tax_line_id.BEGIN',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: get_old_offset_tax_line_id(+)'||
                   'p_offset_link_to_tax_line_id = ' ||
                    to_char(p_offset_tax_line_rec.offset_link_to_tax_line_id));
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN get_old_offset_tax_line_id_csr;
  FETCH get_old_offset_tax_line_id_csr INTO p_old_offset_tax_line_id;
  IF get_old_offset_tax_line_id_csr%NOTFOUND THEN
    --
    -- in this case, it is the first time this tax line has offset
    -- tax associated with it, no offset tax line has been previously
    -- created for this line
    --
    p_old_offset_tax_line_id := NULL;
  END IF;
  CLOSE get_old_offset_tax_line_id_csr;


  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_old_offset_tax_line_id.END',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: get_old_offset_tax_line_id(-)'||
                   'p_old_offset_tax_line_id = ' ||
                    to_char(p_old_offset_tax_line_id)||
                   'p_return_status = ' || p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.get_old_offset_tax_line_id',
                      p_error_buffer);
    END IF;

END get_old_offset_tax_line_id;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  create_offset_tax_line
--
--  DESCRIPTION
--
--  The procedure is used to create an offset tax line for a main tax line
--  which has offset_flag = 'Y'

PROCEDURE create_offset_tax_line(
            p_offset_tax_line_rec    IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_event_class_rec        IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_offset_tax_rate_code   IN     ZX_RATES_B.TAX_RATE_CODE%TYPE,
            p_offset_tax_rate_id     IN     ZX_RATES_B.TAX_RATE_ID%TYPE,
            p_tax_rate               IN     ZX_LINES.TAX_RATE%TYPE,
            p_initial_tax_rate       IN     ZX_LINES.TAX_RATE%TYPE,
            p_offset_tax             IN     ZX_TAXES_B.TAX%TYPE,
            p_offset_status_code     IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2)
IS

  CURSOR  get_tax_line_number_csr IS
   SELECT NVL(MAX(tax_line_number), 0) + 1
     FROM zx_lines
    WHERE application_id       = p_offset_tax_line_rec.application_id
      AND event_class_code    = p_offset_tax_line_rec.event_class_code
      AND entity_code         = p_offset_tax_line_rec.entity_code
      AND trx_id              = p_offset_tax_line_rec.trx_id
      AND trx_line_id         = p_offset_tax_line_rec.trx_line_id
      AND trx_level_type      = p_offset_tax_line_rec.trx_level_type;

  l_parent_tax_rate         ZX_LINES.TAX_RATE%TYPE;
  l_old_offset_tax_line_id  ZX_LINES.TAX_LINE_ID%TYPE;

BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.create_offset_tax_line.BEGIN',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: create_offset_tax_line(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- set link to current non offset tax line
  --
  p_offset_tax_line_rec.offset_link_to_tax_line_id :=
                                p_offset_tax_line_rec.tax_line_id;
--  p_offset_tax_line_rec.tax_line_number :=
--                     p_offset_tax_line_rec.offset_tax_line_number;

  --
  -- null out columns
  --
  set_null_columns(p_offset_tax_line_rec);

  --
  -- set flags
  --
  set_flg_columns(p_offset_tax_line_rec);

  --
  -- populate tax_line_id and who columns
  --
  ZX_TDS_TAX_LINES_POPU_PKG.populate_mandatory_columns(
                                               p_offset_tax_line_rec,
                                               p_return_status,
                                               p_error_buffer);
  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- keep the tax rate of the tax line which associated with this
  -- offset tax line, it will be used to determine whether all tax amounts
  -- related need to be recalculated if offset tax rate is different
  --
  l_parent_tax_rate := p_offset_tax_line_rec.tax_rate;

  --
  -- populate tax related info
  --
  p_offset_tax_line_rec.tax_rate_code := p_offset_tax_rate_code;
  p_offset_tax_line_rec.tax_rate_id := p_offset_tax_rate_id;
  p_offset_tax_line_rec.tax_rate  := p_tax_rate;
  p_offset_tax_line_rec.offset_tax_rate_code := NULL;

  p_offset_tax_line_rec.tax := p_offset_tax;
  get_tax_id(p_offset_tax_line_rec.tax_regime_code,
             p_offset_tax,
             p_offset_tax_line_rec.tax_determine_date,
             p_offset_tax_line_rec.tax_id,
             p_return_status,
             p_error_buffer);
  IF p_return_status <>FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  p_offset_tax_line_rec.tax_status_code :=  p_offset_status_code;
  get_tax_status_id(p_offset_tax_line_rec.tax_regime_code,
                    p_offset_tax,
                    p_offset_status_code,
                    p_offset_tax_line_rec.tax_determine_date,
                    p_offset_tax_line_rec.tax_status_id,
                    p_return_status,
                    p_error_buffer);
  IF p_return_status <>FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  p_offset_tax_line_rec.tax_type_code :=
    ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(p_offset_tax_line_rec.tax_id).tax_type_code;

  --
  -- populate amount columns
  --
  set_amt_columns(p_offset_tax_line_rec,
                  l_parent_tax_rate,
                  p_initial_tax_rate,
                  p_return_status,
                  p_error_buffer);

  IF p_return_status <>FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  -- bug 5580990: populate legal_reporting_status
  IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
    p_offset_tax_line_rec.legal_reporting_status :=
             ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                    p_offset_tax_line_rec.tax_id).legal_reporting_status_def_val;
  END IF;

  --
  -- if tax line is updated or overridden, need to preserve the
  -- existing offset tax line id for this tax line since the offset
  -- tax line may have been accounted, update the new created offset
  -- tax line id with the existing offset tax line id in the
  -- repository for this tax line
  --

  -- populate tax_line_number for OVERRIDE_TAX
  --
  IF NVL(p_offset_tax_line_rec.tax_event_type_code, 'A') = 'OVERRIDE_TAX' THEN
    OPEN  get_tax_line_number_csr;
    FETCH get_tax_line_number_csr INTO p_offset_tax_line_rec.tax_line_number;
    CLOSE get_tax_line_number_csr;
  END IF;

  -- Bug Fix 5417887
  -- IF (p_event_class_rec.tax_event_type_code = 'UPDATE' OR
  IF (p_offset_tax_line_rec.tax_event_type_code = 'UPDATE' OR
      p_event_class_rec.tax_event_type_code = 'OVERRIDE_TAX') THEN
    get_old_offset_tax_line_id(
            p_event_class_rec,
            p_offset_tax_line_rec,
            l_old_offset_tax_line_id,
            p_return_status,
            p_error_buffer);

    IF p_return_status <>FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;

    IF l_old_offset_tax_line_id IS NOT NULL THEN
      --
      -- overwrite the newly generated tax line id with
      -- the existing one in the repository
      --
      p_offset_tax_line_rec.tax_line_id := l_old_offset_tax_line_id;
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.create_offset_tax_line.END',
                   'ZX_TDS_OFFSET_TAX_DETM_PKG: create_offset_tax_line(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_OFFSET_TAX_DETM_PKG.create_offset_tax_line',
                      p_error_buffer);
    END IF;

END create_offset_tax_line;

END  ZX_TDS_OFFSET_TAX_DETM_PKG;

/
