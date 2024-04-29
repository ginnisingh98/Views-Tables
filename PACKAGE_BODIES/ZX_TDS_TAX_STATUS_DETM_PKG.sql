--------------------------------------------------------
--  DDL for Package Body ZX_TDS_TAX_STATUS_DETM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_TAX_STATUS_DETM_PKG" as
/* $Header: zxditaxstsdtpkgb.pls 120.29.12010000.7 2010/02/12 11:51:37 msakalab ship $ */


PROCEDURE  get_def_tax_status_info(
             p_tax                 IN     ZX_TAXES_B.TAX%TYPE,
             p_tax_regime_code     IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
             p_tax_determine_date  IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
             p_status_rec             OUT NOCOPY ZX_TDS_UTILITIES_PKG.ZX_STATUS_INFO_REC,
             p_return_status          OUT NOCOPY VARCHAR2,
             p_error_buffer           OUT NOCOPY VARCHAR2);


PROCEDURE  update_det_tax_line(
             i                      IN      BINARY_INTEGER,
             p_status_result_id     IN      ZX_LINES.STATUS_RESULT_ID%TYPE,
             p_reporting_code_id    IN      ZX_REPORTING_CODES_B.REPORTING_CODE_ID%TYPE,
             p_status_rec           IN      ZX_TDS_UTILITIES_PKG.ZX_STATUS_INFO_REC);

PROCEDURE  rule_base_tax_status_detm(
             p_structure_name       IN     VARCHAR2,
             p_structure_index      IN     BINARY_INTEGER,
             p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
             p_status_result_id        OUT NOCOPY ZX_LINES.STATUS_RESULT_ID%TYPE,
             p_tax_id               IN     ZX_TAXES_B.TAX_ID%TYPE,
             p_tax_status_code      IN OUT NOCOPY ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
             p_tax_determine_date   IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2);

g_current_runtime_level      NUMBER;
g_level_statement            CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure            CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_unexpected           CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
g_level_error                CONSTANT  NUMBER   := FND_LOG.LEVEL_ERROR;
-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_tax_status
--
--  DESCRIPTION
--
--  This procedure is the entry point to Tax status determination process
--  It gets tax status information for a given applicable tax
--

PROCEDURE  get_tax_status(
            p_begin_index          IN     BINARY_INTEGER,
            p_end_index            IN     BINARY_INTEGER,
            p_structure_name       IN     VARCHAR2,
            p_structure_index      IN     BINARY_INTEGER,
            p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status        OUT NOCOPY VARCHAR2,
            p_error_buffer         OUT NOCOPY VARCHAR2)
IS

  l_tax_status_code			ZX_STATUS_B.tax_status_code%TYPE;
  l_tax_rec                             ZX_TDS_UTILITIES_PKG.ZX_TAX_INFO_CACHE_REC;
  l_tax_determine_date                  ZX_LINES.TAX_DETERMINE_DATE%TYPE;
  l_tax_id                              ZX_TAXES_B.TAX_ID%TYPE;
  l_tax_regime_code                     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE;
  l_tax                                 ZX_TAXES_B.TAX%TYPE;
  l_status_result_id                    ZX_LINES.STATUS_RESULT_ID%TYPE;
  l_status_rec                          ZX_TDS_UTILITIES_PKG.ZX_STATUS_INFO_REC;
  l_reporting_code_id                   ZX_REPORTING_CODES_B.reporting_code_id%type;
  l_trx_date                            ZX_LINES.TRX_DATE%TYPE;
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status.BEGIN',
                   'ZX_TDS_TAX_STATUS_DETM_PKG: get_tax_status(+)');


  END IF;

   -- init return status to FND_API.G_RET_STS_SUCCESS
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   p_error_buffer  := NULL;

  --
  -- check if begin_index and end_index have values
  --
  IF (p_begin_index IS NULL OR p_end_index IS NULL) THEN
    p_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status',
                     'Begin index or End index is null');
    END IF;
    RETURN;
  END IF;

   --
   -- loop through the detail tax lines structure to get tax status code for
   -- each line, exit loop and return to calling process  if error occurs
   --

   FOR  i IN p_begin_index .. p_end_index LOOP
     IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status',
                     'processing detail line index = ' || to_char(i));
     END IF;

     IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source = 'REFERENCE' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_tax_amt = 0 AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unrounded_taxable_amt = 0 AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).manually_entered_flag = 'Y' AND
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).freeze_until_overridden_flag ='Y'
     THEN

        NULL;

     ELSE

     --
     -- init status info
     --
     l_status_result_id     := NULL;
     l_status_rec           := NULL;
     l_tax_status_code      := NULL;
     l_reporting_code_id    := NULL;

     l_trx_date := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_date;
     l_tax_determine_date := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date;
     l_tax_id := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_id;
     l_tax_rec := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id);
     l_tax_regime_code := l_tax_rec.tax_regime_code;
     l_tax := l_tax_rec.tax;

     IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_status_code IS NULL THEN

         --
         -- non manual tax line
         --
         IF l_tax_rec.Tax_Status_Rule_Flag = 'N' THEN
           --
           -- no rule defined, get the default tax status
           -- code from zx_status
           --
             get_def_tax_status_info(l_tax,
                                     l_tax_regime_code,
                                     l_tax_determine_date,
                                     l_status_rec,
                                     p_return_status,
                                     p_error_buffer);
         ELSE
           --
           -- tax status determination rules apply for this tax
           --
           rule_base_tax_status_detm(
               p_structure_name,
               p_structure_index,
               p_event_class_rec,
               l_status_result_id,
               l_tax_id,
               l_tax_status_code,
               l_tax_determine_date,
               p_return_status,
               p_error_buffer);

           IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF (g_level_error >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status',
                      'Incorrect return_status after calling rule_base_tax_status_detm()');
               FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status',
                      'p_return_status : '|| p_return_status);
             END IF;
             EXIT;
           ELSE

             IF l_tax_status_code IS NOT NULL THEN

               -- check valid tax status id and populate tax status cache
               --
               ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                                 l_tax,
                                 l_tax_regime_code,
                                 l_tax_status_code,
                                 l_tax_determine_date,
                                 l_status_rec,
                                 p_return_status,
                                 p_error_buffer);
               IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 IF (g_level_error >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status',
                      'Incorrect return_status after calling '||
                      'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info()' );
                   FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status',
                          'No valid tax status id for the tax status code ' ||
                          'returned from rule engine. Need to get default tax status.');
                 END IF;
                 -- reset return status
                 --
                 p_return_status := FND_API.G_RET_STS_SUCCESS;
               END IF;
               l_reporting_code_id:= ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id(l_status_result_id,
                                                                                  l_trx_date);
             END IF;

             IF l_tax_status_code IS NULL OR l_status_rec.tax_status_id IS NULL
             THEN
                 --
                 -- rule based determination returns success
                 -- but no conditions matched, get status code
                 -- from the default
                 --
                 get_def_tax_status_info(l_tax,
                                         l_tax_regime_code,
                                         l_tax_determine_date,
                                         l_status_rec,
                                         p_return_status,
                                         p_error_buffer);
                 l_reporting_code_id    := NULL;
             END IF; -- l_tax_status_code IS NULL
           END IF;   -- of checking p_return_status after calling rule based determination
         END IF;     -- of checking Tax_Status_Rule_Flag
       --
       -- should have the tax status code at this point, update
       -- detail tax line with tax status info
       --

       IF l_status_rec.tax_status_code IS NULL THEN
         IF (g_level_error >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_error,
              'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status',
              'tax status not found for tax: ' || l_tax);
         END IF;

         FND_MESSAGE.SET_NAME('ZX','ZX_STATUS_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('TAX',l_tax);
         -- FND_MSG_PUB.Add;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type;

          ZX_API_PUB.add_msg(
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
         RETURN;
       END IF;

       IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         EXIT;
       ELSE
         update_det_tax_line(i,
                             l_status_result_id,
                             l_reporting_code_id,
                             l_status_rec);
       END IF;       -- of checking p_return_status after getting tax status info
     END IF;         -- of checking event_class_rec
   END IF;
   END LOOP;

   IF (g_level_procedure >= g_current_runtime_level ) THEN

     FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status.END',
                    'ZX_TDS_TAX_STATUS_DETM_PKG: get_tax_status(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status',
                      p_error_buffer);
    END IF;

END get_tax_status;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_def_tax_status_info
--
--  DESCRIPTION
--  This procedure gets the default tax status code and
--  all information related to this status
--
PROCEDURE  get_def_tax_status_info(
             p_tax                 IN     ZX_TAXES_B.TAX%TYPE,
             p_tax_regime_code     IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
             p_tax_determine_date  IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
             p_status_rec             OUT NOCOPY ZX_TDS_UTILITIES_PKG.ZX_STATUS_INFO_REC,
             p_return_status          OUT NOCOPY VARCHAR2,
             p_error_buffer           OUT NOCOPY VARCHAR2)

IS
  l_index              BINARY_INTEGER;

  CURSOR get_def_status_info_csr
    (c_tax                     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
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
           Allow_Exemptions_Flag,
           Allow_Exceptions_Flag
--           Vat_Transaction_Type_Code
--           Default_Status_Flag,
--           default_flg_effective_from,
--           default_flg_effective_to
      FROM  ZX_SCO_STATUS_B_V
      WHERE Default_Status_Flag = 'Y'                              AND
            c_tax_determine_date >= DEFAULT_FLG_EFFECTIVE_FROM    AND
            (c_tax_determine_date <= DEFAULT_FLG_EFFECTIVE_TO OR
             DEFAULT_FLG_EFFECTIVE_TO IS NULL)                    AND
            TAX             = c_tax                               AND
            TAX_REGIME_CODE = c_tax_regime_code                   AND
            c_tax_determine_date >= EFFECTIVE_FROM                AND
            (c_tax_determine_date <= EFFECTIVE_TO OR
             EFFECTIVE_TO IS NULL)
         --AND rownum = 1;
      ORDER BY subscription_level_code;

BEGIN
 g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_def_tax_status_info.BEGIN',
                   'ZX_TDS_TAX_STATUS_DETM_PKG: get_def_tax_status_info(+)'||
                   'tax_regime_code = ' || p_tax_regime_code||
                   'tax = ' || p_tax);

  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN get_def_status_info_csr(p_tax,
                               p_tax_regime_code,
                               p_tax_determine_date);
  FETCH get_def_status_info_csr  INTO
       p_status_rec.tax_status_id,
       p_status_rec.tax_status_code,
       p_status_rec.tax,
       p_status_rec.tax_regime_code,
       p_status_rec.effective_from,
       p_status_rec.effective_to,
       p_status_rec.Rule_Based_Rate_Flag,
       p_status_rec.Allow_Rate_Override_Flag,
       p_status_rec.Allow_Exemptions_Flag,
       p_status_rec.Allow_Exceptions_Flag;
  IF get_def_status_info_csr%NOTFOUND THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer := 'No default tax status found';

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_def_tax_status_info',
                   p_error_buffer);
    END IF;
  END IF;
  CLOSE get_def_status_info_csr;
  --
  -- update the global status cache structure
  --
  IF p_return_status =  FND_API.G_RET_STS_SUCCESS THEN
    l_index := ZX_TDS_UTILITIES_PKG.get_tax_status_index(
                               p_status_rec.tax,
                               p_status_rec.tax_regime_code,
                               p_status_rec.tax_status_code);
    ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl(l_index) := p_status_rec;
  END IF;


  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_def_tax_status_info.END',
                   'ZX_TDS_TAX_STATUS_DETM_PKG: get_def_tax_status_info(-)'||
                   'tax_status_code = ' ||
                    p_status_rec.tax_status_code);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF get_def_status_info_csr%ISOPEN THEN
      CLOSE get_def_status_info_csr;
    END IF;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.get_def_tax_status_info',
                      p_error_buffer);
    END IF;
END get_def_tax_status_info;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  rule_base_tax_status_detm
--
--  DESCRIPTION
--
--  The procedure is used to get derive tax status code based on the rules
--  defined by calling Rule based engine
--

PROCEDURE  rule_base_tax_status_detm(
             p_structure_name       IN     VARCHAR2,
             p_structure_index      IN     BINARY_INTEGER,
             p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
             p_status_result_id        OUT NOCOPY ZX_LINES.STATUS_RESULT_ID%TYPE,
             p_tax_id               IN     ZX_TAXES_B.TAX_ID%TYPE,
             p_tax_status_code      IN OUT NOCOPY ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
             p_tax_determine_date   IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2)
IS
  l_service_type_code      	ZX_RULES_B.SERVICE_TYPE_CODE%TYPE;
  l_tax_result_rec	        ZX_PROCESS_RESULTS%ROWTYPE;
  l_tax_rule_code               ZX_RULES_B.TAX_RULE_CODE%TYPE;
  l_recovery_type_code          ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.rule_base_tax_status_detm.BEGIN',
                   'ZX_TDS_TAX_STATUS_DETM_PKG: rule_base_tax_status_detm(+)');
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.rule_base_tax_status_detm',
                   'p_tax_id = ' || to_char(p_tax_id));
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  l_service_type_code := 'DET_TAX_STATUS';

  ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process(l_service_type_code,
                                              p_structure_name,
                                              p_structure_index,
                                              p_event_class_rec,
                                              p_tax_id,
                                              p_tax_status_code,
                                              p_tax_determine_date,
                                              l_tax_rule_code,
                                              l_recovery_type_code,
                                              l_tax_result_rec,
                                              p_return_status,
                                              p_error_buffer);

  IF (l_tax_result_rec.alphanumeric_result IS NOT NULL AND
      p_return_status =  FND_API.G_RET_STS_SUCCESS) THEN
    p_tax_status_code  := l_tax_result_rec.alphanumeric_result;
    p_status_result_id := l_tax_result_rec.result_id;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.rule_base_tax_status_detm',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.rule_base_tax_status_detm',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.rule_base_tax_status_detm',
                   'p_tax_status_code = ' || p_tax_status_code);
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.rule_base_tax_status_detm',
                  'p_status_result_id = ' ||
                     to_char(p_status_result_id));
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.rule_base_tax_status_detm.END',
                  'ZX_TDS_TAX_STATUS_DETM_PKG: rule_base_tax_status_detm(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.rule_base_tax_status_detm',
                      p_error_buffer);
    END IF;

END rule_base_tax_status_detm;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  update_det_tax_line
--
--  DESCRIPTION
--
--  This procedure is used to update the detail tax lines structure
--  with tax status information
--

PROCEDURE  update_det_tax_line(
             i                    IN     BINARY_INTEGER,
             p_status_result_id   IN     ZX_LINES.STATUS_RESULT_ID%TYPE,
             p_reporting_code_id  IN     ZX_REPORTING_CODES_B.REPORTING_CODE_ID%TYPE,
             p_status_rec         IN     ZX_TDS_UTILITIES_PKG.ZX_STATUS_INFO_REC)
IS
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.update_det_tax_line.BEGIN',
                   'ZX_TDS_TAX_STATUS_DETM_PKG: update_det_tax_line(+)');
  END IF;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_status_id := p_status_rec.tax_status_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_status_code := p_status_rec.tax_status_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).status_result_id := p_status_result_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).legal_message_status := p_reporting_code_id;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.update_det_tax_line.END',
                   'ZX_TDS_TAX_STATUS_DETM_PKG: update_det_tax_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_STATUS_DETM_PKG.update_det_tax_line',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END update_det_tax_line;

END  ZX_TDS_TAX_STATUS_DETM_PKG;

/
