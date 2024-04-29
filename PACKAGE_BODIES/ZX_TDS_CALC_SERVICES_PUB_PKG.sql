--------------------------------------------------------
--  DDL for Package Body ZX_TDS_CALC_SERVICES_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_CALC_SERVICES_PUB_PKG" AS
 /* $Header: zxdwtxcalsrvpubb.pls 120.132.12010000.22 2010/03/29 16:03:18 tsen ship $ */

 /* Declare constants */

 G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'zx_tds_calc_services_pub_pkg';
 G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
 G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
 G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;

 G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
 G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
 G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

 NUMBER_DUMMY    CONSTANT NUMBER(15)     := -999999999999999;

 G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

 l_error_buffer	VARCHAR2(240);

  TYPE l_tax_prof_id_rec_type IS RECORD(
     tax_prof_id                        NUMBER,
     process_for_appl_flg               VARCHAR2(1)
);

TYPE l_tax_prof_id_tbl_type IS TABLE OF l_tax_prof_id_rec_type INDEX BY BINARY_INTEGER;
l_tax_prof_id_tbl l_tax_prof_id_tbl_type;

TYPE l_templ_usage_rec_type IS RECORD(
     det_factor_templ_code      VARCHAR2(30),
     template_usage_code        VARCHAR2(30)
);

TYPE l_templ_usage_tbl_type IS TABLE OF l_templ_usage_rec_type INDEX BY BINARY_INTEGER;
l_templ_usage_tbl l_templ_usage_tbl_type;

PROCEDURE fetch_detail_tax_lines (
  x_return_status	    OUT NOCOPY 	 VARCHAR2);

PROCEDURE process_taxes_for_xml_inv_line (
  --p_event_class_rec        IN 	        zx_api_pub.event_class_rec_type,
  x_return_status          OUT NOCOPY   VARCHAR2);

PROCEDURE process_taxes_for_xml_inv_hdr (
  --p_event_class_rec        IN 	        zx_api_pub.event_class_rec_type,
  x_return_status          OUT NOCOPY   VARCHAR2);

PROCEDURE adjust_tax_for_xml_inv_line (
  --p_event_class_rec        IN 	        zx_api_pub.event_class_rec_type,
  x_return_status          OUT NOCOPY   VARCHAR2);

PROCEDURE adjust_tax_for_xml_inv_hdr (
  --p_event_class_rec        IN 	        zx_api_pub.event_class_rec_type,
  x_return_status          OUT NOCOPY   VARCHAR2);

PROCEDURE  match_tax_amt_to_summary_line (
  p_event_class_rec	  IN  OUT NOCOPY  zx_api_pub.event_class_rec_type,
  x_return_status  	  OUT NOCOPY      VARCHAR2);

g_current_runtime_level    NUMBER;
g_level_statement          CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure          CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_event              CONSTANT  NUMBER   := FND_LOG.LEVEL_EVENT;
g_level_error              CONSTANT  NUMBER   := FND_LOG.LEVEL_ERROR;
g_level_unexpected         CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

/* ======================================================================*
 |  PROCEDURE get_tax_regimes                                            |
 |  This procedure returns applicable tax regimes for each transaction   |
 |  line and also unique tax regimes for whole transaction               |
 * ======================================================================*/
PROCEDURE  get_tax_regimes (
  p_trx_line_index         IN	         BINARY_INTEGER,
  p_event_class_rec        IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
  x_return_status          OUT NOCOPY    VARCHAR2 ) IS

  /* Bug 4959835*/
  l_template_usage_code zx_det_factor_templ_b.template_usage_code%type;
  l_templ_usage_indx    BINARY_INTEGER;

  CURSOR get_template_usage_csr IS
  SELECT template_usage_code
  FROM zx_det_factor_templ_b
  WHERE DET_FACTOR_TEMPL_CODE = p_event_class_rec.DET_FACTOR_TEMPL_CODE;
  /* End: Bug 4959835*/

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes(+)');
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- Bug fix 3365220, 3426155, skip get_applicable_regimes for
  -- the following cases
  --    1) applied_from_application_id is not null
  --    2) adjusted_doc_application_id is not null
  --    3) event type code is OVERRIDE_TAX
  --    4) historical trx lines
  -- Bug 3010729: skip performing regime applicability for trx lines with
  --              line level  action 'LINE_INFO_TAX_ONLY'
  -- Bug 3990418: Skip regime applicability determination process for line
  --              level actions 'CANCEL', 'SYNCHRONIZE', 'DISCARD' and
  --              'RECORD_WITH_NO_TAX', 'NO_CHANGE'
  -- Bug 3893366: Skip regime determination for line_level_action
  --              'ALLOCATE_LINE_ONLY_ADJUSTMENT'
  -- Bug 5440023: Do not skip regime determination for line_level_action
  --              'LINE_INFO_TAX_ONLY' if it is partner integration
  --
  IF (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(
            p_trx_line_index) IS NULL
    AND  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(
            p_trx_line_index) IS NULL
    AND  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code (
            p_trx_line_index ) <> 'OVERRIDE_TAX'
    AND  nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.historical_flag (
            p_trx_line_index ), 'N') = 'N'
    AND  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action (
            p_trx_line_index ) NOT IN ('CANCEL', 'SYNCHRONIZE', 'DISCARD',
            'RECORD_WITH_NO_TAX',  'NO_CHANGE',
            'ALLOCATE_LINE_ONLY_ADJUSTMENT'))
   THEN

     --
     -- Bug#5440023- do not process non partner and line level
     -- action is 'LINE_INFO_TAX_ONLY'
     --
     IF (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action ( p_trx_line_index ) = 'LINE_INFO_TAX_ONLY'
        AND NVL(ZX_GLOBAL_STRUCTURES_PKG.g_ptnr_srvc_subscr_flag, 'N') = 'N' ) THEN

       RETURN;

     END IF;

     -- Start: Added for Bug 4959835

     -- added caching logic here
     l_templ_usage_indx := dbms_utility.get_hash_value(p_event_class_rec.det_factor_templ_code, 1, 8192);

     IF l_templ_usage_tbl.EXISTS(l_templ_usage_indx)
           AND l_templ_usage_tbl(l_templ_usage_indx).det_factor_templ_code = p_event_class_rec.det_factor_templ_code THEN
          l_template_usage_code := l_templ_usage_tbl(l_templ_usage_indx).template_usage_code;
     ELSE
       OPEN get_template_usage_csr;
       FETCH get_template_usage_csr into l_template_usage_code;
       CLOSE get_template_usage_csr;

       l_templ_usage_tbl(l_templ_usage_indx).det_factor_templ_code := p_event_class_rec.det_factor_templ_code;
       l_templ_usage_tbl(l_templ_usage_indx).template_usage_code := l_template_usage_code;
     END IF;

     IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes',
                'l_template_usage_code := '||l_template_usage_code);
     END IF;

     -- Populate the event_class_rec with template_usage_code.This is to avoid
     -- executing the above same SQL during tax_applicability.
     p_event_class_rec.template_usage_code := l_template_usage_code;

     -- Perform Tax Regime Determination only for location based taxes.
     -- For non-location based scenario(i.e.P2P and O2C OUs where tax method=VAT),
     -- use direct rate determination process to obtain the candidate taxes.

     IF l_template_usage_code = 'TAX_REGIME_DETERMINATION'
     THEN
          ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes (
                        p_trx_line_index,
                        p_event_class_rec,
						 x_return_status );
     END IF;
     -- End: Bug 4959835

  END IF;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes()');
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes',
                     'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- Start: Added for Bug 4959835
    IF get_template_usage_csr%ISOPEN THEN
       CLOSE get_template_usage_csr;
    END IF;
    -- End: Bug 4959835
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes(-)');
    END IF;

END get_tax_regimes;

/* ======================================================================*
 |  PROCEDURE calculate_tax                                              |
 |  This procedure is called for every transaction line                  |
 * ======================================================================*/
PROCEDURE  calculate_tax (
 p_trx_line_index        IN             BINARY_INTEGER,
 p_event_class_rec       IN OUT NOCOPY  zx_api_pub.event_class_rec_type,
 x_return_status            OUT NOCOPY  VARCHAR2) IS

 l_begin_index           BINARY_INTEGER;
 l_end_index             BINARY_INTEGER;
 l_provider_id           NUMBER;
 l_tax_regime_id         zx_regimes_b.tax_regime_id%TYPE;
 l_tax_date              DATE;
 l_tax_determine_date    DATE;
 l_tax_point_date        DATE;
 l_error_buffer          VARCHAR2(240);

 l_upg_trx_info_rec      zx_on_fly_trx_upgrade_pkg.zx_upg_trx_info_rec_type;
 l_trx_migrated_b        BOOLEAN;
 l_tax_exists_flg        VARCHAR2(1);


 CURSOR get_source_doc_info(
          c_application_id    zx_evnt_cls_mappings.application_id%TYPE,
          c_entity_code       zx_evnt_cls_mappings.entity_code%TYPE,
          c_event_class_code  zx_evnt_cls_mappings.event_class_code%TYPE
        )
 IS
   SELECT intrcmp_src_appln_id,
          intrcmp_src_entity_code,
          intrcmp_src_evnt_cls_code
     FROM zx_evnt_cls_mappings
    WHERE application_id = c_application_id
      AND entity_code = c_entity_code
      AND event_class_code = c_event_class_code;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.BEGIN',
                  'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- Bug 3971016: Skip processing tax applicability for line_level_action
  --              'RECORD_WITH_NO_TAX'
  -- Bug 3893366: Skip processing tax applicability for line_level_action
  --              'ALLOCATE_LINE_ONLY_ADJUSTMENT'
  --
  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
       p_trx_line_index) IN ( 'RECORD_WITH_NO_TAX',
                              'ALLOCATE_LINE_ONLY_ADJUSTMENT')
  THEN
    IF (g_level_procedure >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                    'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)'||'Skip processing for RECORD_WITH_NO_TAX');
    END IF;
    RETURN;
  END IF;

  --comment out for bug fix 5532891, the assignment has been take cared whenever there is
  --applicable tax
  --l_begin_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST+1;

  -- Bug 3971006
  --
  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                           p_trx_line_index) = 'CREATE' AND
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                   p_trx_line_index) ='COPY_AND_CREATE'
  THEN

     ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_copy_and_create_flg := 'Y';

  END IF;

  -- bug fix 5417887
  -- following setting has been done in the srv type pkg for each trx
  /*IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                           p_trx_line_index) = 'UPDATE'
  THEN
    ZX_GLOBAL_STRUCTURES_PKG.g_update_event_process_flag := 'Y';
  END IF;
  */

  -- bug 3770874: set global variables for line_level_action 'CANCEL'/DISCARD'
  -- Remove tax_event_type 'DELETE' and 'CANCEL'
  --
  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                           p_trx_line_index) = 'UPDATE' AND
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
       p_trx_line_index) IN ('CANCEL', 'SYNCHRONIZE', 'DISCARD', 'NO_CHANGE',
                             'UNAPPLY_FROM')
  THEN

    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.historical_flag(p_trx_line_index) = 'Y' AND
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_trx_line_index) IN
                                   ('CANCEL', 'DISCARD', 'NO_CHANGE', 'UNAPPLY_FROM')
    THEN

      l_upg_trx_info_rec.application_id
        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index);
      l_upg_trx_info_rec.event_class_code
        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index);
      l_upg_trx_info_rec.entity_code
        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_index);
      l_upg_trx_info_rec.trx_id
        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id(p_trx_line_index);
      l_upg_trx_info_rec.trx_line_id
        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
      l_upg_trx_info_rec.trx_level_type
        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

      ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(
        p_upg_trx_info_rec  => l_upg_trx_info_rec,
        x_trx_migrated_b    => l_trx_migrated_b,
        x_return_status     => x_return_status );

      IF NOT l_trx_migrated_b THEN

        ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(
          p_upg_trx_info_rec  => l_upg_trx_info_rec,
          x_return_status     => x_return_status
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                   'Incorrect return_status after calling ' ||
                   ' ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly' ||
                   ' contine processing ...');
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                          'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
          END IF;
        END IF;
      END IF;    -- NOT l_trx_migrated_b
    END IF;      -- historical_flag = 'Y'

    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                                p_trx_line_index) ='CANCEL' THEN

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_cancel_exist_flg := 'Y';

    ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                               p_trx_line_index) ='DISCARD' THEN

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_discard_exist_flg:= 'Y';

    ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                         p_trx_line_index) = 'UNAPPLY_FROM' THEN

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_discard_exist_flg:= 'Y';

    ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                               p_trx_line_index) ='NO_CHANGE' THEN

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_nochange_exist_flg := 'Y';

    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)'||'Skip processing for cancel, synch, discard, no change');
    END IF;
    RETURN;
  END IF;

  -- Initialize global data structures
  g_check_cond_grp_tbl.DELETE;
  g_tsrm_num_value_tbl.DELETE;
  g_tsrm_alphanum_value_tbl.DELETE;
  g_trx_alphanum_value_tbl.DELETE;

  --  get tax date for tax event type other than 'OVERRIDE_TAX'
  --
  IF( ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                       p_trx_line_index) <> 'OVERRIDE_TAX') THEN

    ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date(
		p_trx_line_index,
		l_tax_date,
		l_tax_determine_date,
		l_tax_point_date,
		x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                       'Incorrect return_status after calling ' ||
                       'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date()');
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                       'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                       'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
      END IF;
      RETURN;
    END IF;
  END IF;

  -- comment out for bug fix 5417887
  --  Initialize g_detail_tax_lines_tbl when it is the first transaction line
  --
  --IF p_trx_line_index = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id.FIRST
  --THEN

  --  g_detail_tax_lines_tbl.DELETE;
  --END IF;

  -- If ref_doc_application_id is not null and it is not an override tax case,
  -- set the g_reference_doc_exist_flg, so that in the tail end service to
  -- call process_reference_tax_lines().

  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(
                                          p_trx_line_index) IS NOT NULL    AND
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                      p_trx_line_index) <> 'OVERRIDE_TAX'
  THEN
    g_reference_doc_exist_flg := 'Y';
  END IF;

  IF( ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                                p_trx_line_index) ='CREATE'   OR
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                                p_trx_line_index) ='UPDATE'   OR
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                        p_trx_line_index) = 'OVERRIDE_TAX') THEN

    -- IF it is a migrated transaction,
    --    fetch all tax lines from current document, skip applicability process
    --    Only do tax amount calculation and taxable basis
    --  OR IF tax_event_type_code = 'OVERRIDE_TAX',
    --     fetch all tax lines from current document, skip applicability process
    -- ELSIF applied_from_application_id IS NOT NULL,
    --   call get_det_tax_lines_from_applied. Skip applicability process
    -- ELSIF adjusted_doc_application_id IS NOT NULL,
    --   call get_det_tax_lines_from_adjusted. Skip applicability process
    -- ELSE  perform applicability process.
    --
    -- Bug 5688340: Rearranged the order of conditions in IF statement
    --              (ie. pulled adjusted_doc is NOT NULL condition before
    --              applied_from).
    --              The receipt application in AR causes a tax adjustment to be
    --              created in eBTax, if an earned discount is recognized.
    --              In this case, AR passes invoice info in adjusted doc columns
    --              and cash receipt info in applied from columns.
    --              In this case, tax calculation must be done using invoice
    --              (ie. adjusted doc info).

    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.historical_flag(p_trx_line_index)
        = 'Y' OR
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                                 p_trx_line_index) = 'OVERRIDE_TAX'
    THEN

       ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(
			p_event_class_rec,
			p_trx_line_index,
			NULL,
			NULL,
			NULL,
			l_begin_index,
			l_end_index,
			x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                        'Incorrect return_status after calling ' ||
                        'ZX_TDS_APPLICABILITY_DETM_PKG.');
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                        'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                        'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
        END IF;
        RETURN;
      END IF;

      -- When no tax line found for the historical transaction, check if the trx line
      -- exists in zx_lines_det_factors. If yes, it means the historical transaction
      -- was migrated, but don't have tax. Otherwise, migrate the historical
      -- transaction on-the-fly and call ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines
      -- again to fetch the tax lines for the historical transaction.

      IF ((l_begin_index IS NULL) OR (l_begin_index = l_end_index)) AND
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.historical_flag(p_trx_line_index) = 'Y'  THEN

        l_upg_trx_info_rec.application_id
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index);
        l_upg_trx_info_rec.event_class_code
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index);
        l_upg_trx_info_rec.entity_code
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_index);
        l_upg_trx_info_rec.trx_id
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id(p_trx_line_index);
        l_upg_trx_info_rec.trx_line_id
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
        l_upg_trx_info_rec.trx_level_type
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

        ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(
          p_upg_trx_info_rec  => l_upg_trx_info_rec,
          x_trx_migrated_b    => l_trx_migrated_b,
          x_return_status     => x_return_status );

        IF NOT l_trx_migrated_b THEN
          ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(
            p_upg_trx_info_rec  => l_upg_trx_info_rec,
            x_return_status     => x_return_status
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                     'Incorrect return_status after calling ' ||
                     ' ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly');
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                            'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                            'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
            END IF;
            RETURN;
          END IF;

          -- after migrate the trx on the fly, fetch tax lines for historical trx again.
          ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(
			                         p_event_class_rec,
			                         p_trx_line_index,
			                         NULL,
			                         NULL,
			                         NULL,
			                         l_begin_index,
			                         l_end_index,
			                         x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines');
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                            'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                            'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
            END IF;
            RETURN;
          END IF;

	END IF;
      END IF;

    ELSIF (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(
            p_trx_line_index)  IS NOT NULL ) THEN

      ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust(
			p_event_class_rec,
			p_trx_line_index,
			l_tax_date,
  			l_tax_determine_date,
  			l_tax_point_date,
			l_begin_index,
			l_end_index,
			x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                 'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
        END IF;
        RETURN;
      END IF;

      -- bug fix 4642405 : handle on the fly migration
      -- When no tax line found for the adjusted doc, check if the trx line
      -- exists in zx_lines_det_factors. If yes, it means the adjusted doc was
      -- migrated, but don't have tax. Otherwise, migrate the adjusted doc
      -- on-the-fly and call ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust
      -- again to fetch the tax lines for the adjusted doc.

      IF (l_begin_index IS NULL) OR (l_begin_index = l_end_index)  THEN

        l_upg_trx_info_rec.application_id
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(
               p_trx_line_index);
        l_upg_trx_info_rec.event_class_code
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(
               p_trx_line_index);
        l_upg_trx_info_rec.entity_code
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(
               p_trx_line_index);
        l_upg_trx_info_rec.trx_id
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(
               p_trx_line_index);
        l_upg_trx_info_rec.trx_line_id
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(
               p_trx_line_index);
        l_upg_trx_info_rec.trx_level_type
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(
               p_trx_line_index);

        ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(
          p_upg_trx_info_rec  => l_upg_trx_info_rec,
          x_trx_migrated_b    => l_trx_migrated_b,
          x_return_status     => x_return_status );

        IF NOT l_trx_migrated_b THEN
          ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(
            p_upg_trx_info_rec  => l_upg_trx_info_rec,
            x_return_status     => x_return_status
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                     'Incorrect return_status after calling ' ||
                     ' ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly');
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                            'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                            'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
            END IF;
            RETURN;
          END IF;

          -- after migrate the trx on the fly, fetch tax lines for applied_from doc again.
          ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust(
  			p_event_class_rec,
  			p_trx_line_index,
  			l_tax_date,
    			l_tax_determine_date,
    			l_tax_point_date,
  			l_begin_index,
  			l_end_index,
  			x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust');
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                            'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                            'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
            END IF;
            RETURN;
          END IF;

        END IF;
      END IF;

    ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(
                                                    p_trx_line_index) IS NOT NULL
    THEN

       ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied(
			p_event_class_rec,
			p_trx_line_index,
			l_tax_date,
  			l_tax_determine_date,
  			l_tax_point_date,
			l_begin_index,
			l_end_index,
			x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied');
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                        'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                        'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
        END IF;
        RETURN;
      END IF;

      -- bug fix 4642405 : handle on the fly migration
      -- When no tax line found for the applied_from doc, check if the trx line
      -- exists in zx_lines_det_factors. If yes, it means the applied_from doc was
      -- migrated, but don't have tax. Otherwise, migrate the applied_from doc
      -- on-the-fly and call ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied
      -- again to fetch the tax lines for the applied_from doc.

      IF (l_begin_index IS NULL) OR (l_begin_index = l_end_index)  THEN

        l_upg_trx_info_rec.application_id
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(
               p_trx_line_index);
        l_upg_trx_info_rec.event_class_code
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(
               p_trx_line_index);
        l_upg_trx_info_rec.entity_code
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(
               p_trx_line_index);
        l_upg_trx_info_rec.trx_id
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(
               p_trx_line_index);
        l_upg_trx_info_rec.trx_line_id
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(
               p_trx_line_index);
        l_upg_trx_info_rec.trx_level_type
          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(
               p_trx_line_index);

        ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(
          p_upg_trx_info_rec  => l_upg_trx_info_rec,
          x_trx_migrated_b    => l_trx_migrated_b,
          x_return_status     => x_return_status );

        IF NOT l_trx_migrated_b THEN
          ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(
            p_upg_trx_info_rec  => l_upg_trx_info_rec,
            x_return_status     => x_return_status
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                     'Incorrect return_status after calling ' ||
                     ' ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly');
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                            'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                            'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
            END IF;
            RETURN;
          END IF;

          -- after migrate the trx on the fly, fetch tax lines for applied_from doc again.
          ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied(
    			p_event_class_rec,
    			p_trx_line_index,
    			l_tax_date,
      			l_tax_determine_date,
      			l_tax_point_date,
    			l_begin_index,
    			l_end_index,
    			x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied');
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                            'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                            'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
            END IF;
            RETURN;
          END IF;

        END IF;

      END IF;

    ELSE     -- loop through detail_tax_regime_tbl to get applicable taxes

      -- For UPDATE case, fetch manual tax lines from zx_lines
      --

      IF (((ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                 p_trx_line_index) = 'UPDATE')
          OR
          (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                 p_trx_line_index) ='UPDATE'  AND
           (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                 p_trx_line_index) = 'LINE_INFO_TAX_ONLY'
              OR ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                 p_trx_line_index) = 'CREATE_WITH_TAX') -- Bug 8205359
                 ))) AND --bug#8534499
          (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(
                                      p_trx_line_index) <> 'INTERCOMPANY_TRX' OR
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_id(
                                                p_trx_line_index) IS NULL) THEN  -- Bug 5291394

         ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(
  			p_event_class_rec,
  			p_trx_line_index,
			l_tax_date,
			l_tax_determine_date,
			l_tax_point_date,
  			l_begin_index,
  			l_end_index,
  			x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
          END IF;
          RETURN;
        END IF;

        -- bug fix 4642405 : handle on the fly migration
        -- When no tax line found for docto be updated, check if the trx line
        -- exists in zx_lines_det_factors. If yes, it means current doc was
        -- migrated, but don't have tax. Otherwise, migrate current doc
        -- on-the-fly and call ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines
        -- again to fetch the tax lines for current doc.

        IF (l_begin_index IS NULL) OR (l_begin_index = l_end_index)  THEN

          l_upg_trx_info_rec.application_id
            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(
                 p_trx_line_index);
          l_upg_trx_info_rec.event_class_code
            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(
                 p_trx_line_index);
          l_upg_trx_info_rec.entity_code
            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(
                 p_trx_line_index);
          l_upg_trx_info_rec.trx_id
            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id(
                 p_trx_line_index);
          l_upg_trx_info_rec.trx_line_id
            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(
                 p_trx_line_index);
          l_upg_trx_info_rec.trx_level_type
            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(
                 p_trx_line_index);

          ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(
            p_upg_trx_info_rec  => l_upg_trx_info_rec,
            x_trx_migrated_b    => l_trx_migrated_b,
            x_return_status     => x_return_status );

          IF NOT l_trx_migrated_b THEN
            ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(
              p_upg_trx_info_rec  => l_upg_trx_info_rec,
              x_return_status     => x_return_status
            );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                       'Incorrect return_status after calling ' ||
                       ' ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly');
                FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                              'RETURN_STATUS = ' || x_return_status);
                FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                              'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
              END IF;
              RETURN;
            END IF;

            -- after migrate the trx on the fly, fetch tax lines for applied_from doc again.
            ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(
    			p_event_class_rec,
    			p_trx_line_index,
  			l_tax_date,
  			l_tax_determine_date,
  			l_tax_point_date,
    			l_begin_index,
    			l_end_index,
    			x_return_status);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                       'Incorrect return_status after calling ' ||
                       'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines');
                FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                              'RETURN_STATUS = ' || x_return_status);
                FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                              'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
              END IF;
              RETURN;
            END IF;

          END IF;
        END IF;
      END IF;        -- -- line_level_action = 'UPDATE'

      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                 p_trx_line_index) IN ('CREATE', 'UPDATE')
          AND ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(
                                 p_trx_line_index) = 'INTERCOMPANY_TRX'
          AND ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_id(
                 p_trx_line_index) IS NOT NULL
      THEN

         ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(
  			p_event_class_rec,
  			p_trx_line_index,
			l_tax_date,
			l_tax_determine_date,
			l_tax_point_date,
  			l_begin_index,
  			l_end_index,
  			x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
          END IF;
          RETURN;
        END IF;

        -- bug fix 4653504 : handle on the fly migration
        -- When no tax line found for doc to be updated, check if the trx line
        -- exists in zx_lines_det_factors. If yes, it means current doc was
        -- migrated, but don't have tax. Otherwise, migrate current doc
        -- on-the-fly and call ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines
        -- again to fetch the tax lines for current doc.

        IF ((l_begin_index IS NULL) OR (l_begin_index = l_end_index) ) THEN

          OPEN get_source_doc_info (
                 ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index),
                 ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_index),
                 ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index)
               );

          FETCH get_source_doc_info into
                 l_upg_trx_info_rec.application_id,
                 l_upg_trx_info_rec.entity_code,
                 l_upg_trx_info_rec.event_class_code;

          IF get_source_doc_info%NOTFOUND THEN
            -- need to define new error message code
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                     'No record found in zx_evnt_mappings.' );
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                     'application_id: '||
                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index) );
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                     'entity_code: '||
                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_index) );
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                     'event_class_code: '||
                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index) );
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
            END IF;
            RETURN;
          END IF;

          IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_class(p_trx_line_index) = 'AP_CREDIT_MEMO' THEN
            l_upg_trx_info_rec.event_class_code := 'CREDIT_MEMO';
          ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_class(p_trx_line_index) = 'AP_DEBIT_MEMO' THEN
            l_upg_trx_info_rec.event_class_code := 'DEBIT_MEMO';
          END IF;

          l_upg_trx_info_rec.trx_id
            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_id(
                 p_trx_line_index);
          l_upg_trx_info_rec.trx_line_id
            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_line_id(
                 p_trx_line_index);
          l_upg_trx_info_rec.trx_level_type
            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_level_type(
                 p_trx_line_index);

          ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(
            p_upg_trx_info_rec  => l_upg_trx_info_rec,
            x_trx_migrated_b    => l_trx_migrated_b,
            x_return_status     => x_return_status );

          IF NOT l_trx_migrated_b THEN
            ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(
              p_upg_trx_info_rec  => l_upg_trx_info_rec,
              x_return_status     => x_return_status
            );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                       'Incorrect return_status after calling ' ||
                       ' ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly');
                FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                              'RETURN_STATUS = ' || x_return_status);
                FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                              'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
              END IF;
              RETURN;
            END IF;

            -- after migrate the trx on the fly, fetch tax lines for applied_from doc again.
            ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(
    			p_event_class_rec,
    			p_trx_line_index,
  			l_tax_date,
  			l_tax_determine_date,
  			l_tax_point_date,
    			l_begin_index,
    			l_end_index,
    			x_return_status);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                       'Incorrect return_status after calling ' ||
                       'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx');
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                       'RETURN_STATUS = ' || x_return_status);
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                       'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
              END IF;
              RETURN;
            END IF;

          END IF;
        END IF;

      END IF;      --  'INTERCOMPANY_TRX'

      -- Bug 3648628: if line_level_action = 'LINE_INFO_TAX_ONLY', skip the
      -- process to create any detail tax line for this trx line (memo line).
      --
      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action (
                                 p_trx_line_index ) <> 'LINE_INFO_TAX_ONLY' AND
         p_event_class_rec.process_for_applicability_flag = 'Y'  AND
         NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg, 'Y') = 'Y' AND
         -- Bug 4765758: for TM, check source_process_for_appl_flag to determine
         -- whether tax needs to be calcualted or not.
         NVL(p_event_class_rec.source_process_for_appl_flag, 'Y') = 'Y'
      THEN

        /* Start: Added for Bug 4959835 */
        -- Based on the Regime Usage code, either direct rate determination
        -- processing has to be performed or it should goto the loop part below.
        -- If the Regime determination template is 'STCC' (non-location based)
        -- then, call get process results directly
        -- Else (for location based) call tax applicability.

        IF p_event_class_rec.template_usage_code = 'TAX_RULES'
        THEN

          -- The direct rate determination is coded in the applicability pkg
          -- in order to reuse some of the existing logic there.
          --
          ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(p_trx_line_index,
                                                            l_tax_date,
                                                            l_tax_determine_date,
                                                            l_tax_point_date,
                                                            p_event_class_rec,
                                                            l_begin_index,
                                                            l_end_index,
                                                            x_return_status);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF (g_level_error >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results()');
      	       FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                      'RETURN_STATUS = ' || x_return_status);
    	       FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
             END IF;
    	     RETURN;
    	   END IF;


        ELSE
         FOR regime_index IN
             NVL(ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.FIRST, 0) ..
             NVL(ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.LAST, -1)    LOOP

           IF ( ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(
                         regime_index).trx_line_index = p_trx_line_index)  THEN

             -- tax_regime_id is detail_tax_regime_tbl(regime_index).tax_regime_id.
             -- Get the tax_provider_id:
             --
             l_tax_regime_id := ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(
                                                       regime_index).tax_regime_id;
             l_provider_id := ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(
                                                  l_tax_regime_id).tax_provider_id;

             IF (l_provider_id IS NULL) THEN

               -- If l_provider_id is null, this tax needs to be processed
               --
               ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes (
                           l_tax_regime_id,
                           ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(
                                                 l_tax_regime_id).tax_regime_code,
                           p_trx_line_index,
                           p_event_class_rec,
                           l_tax_date,
                           l_tax_determine_date,
                           l_tax_point_date,
                           l_begin_index,
                           l_end_index,
                           x_return_status );

               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT,
                                    'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                                    'Incorrect return_status after calling ' ||
                                    'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes()');
                     FND_LOG.STRING(G_LEVEL_STATEMENT,
                                  'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                                  'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
                   END IF;
                   RETURN;
                 END IF;
               END IF;

             END IF;  -- provider ID
           END IF;    -- detail_regime for this transaction line
         END LOOP;    -- regime_index IN detail_tax_regime_tbl
        END IF;       -- to be added for the STCC logic
      END IF;        -- line_level_action <> 'LINE_INFO_TAX_ONLY'
    END IF;          -- applied_from(adjusted_doc)_appl_id IS NOT NULL,OR ELSE

    IF p_event_class_rec.enforce_tax_from_acct_flag = 'Y' AND
ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index) > 0
   THEN

      ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account(
			p_event_class_rec,
			p_trx_line_index,
			l_tax_date,
  			l_tax_determine_date,
  			l_tax_point_date,
			l_begin_index,
			l_end_index,
			x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                 'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
        END IF;
        RETURN;
      END IF;
    END IF;

    -- call the Internal Processes only if tax created
    --
    IF l_begin_index IS NOT NULL AND l_end_index IS NOT NULL THEN

      -- For migrated transactions, skip tax status and rate determination
      --
      IF NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.historical_flag(
                                           p_trx_line_index), 'N') <> 'Y' THEN

        -- get tax status
        --
        ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status(
             		l_begin_index,
  			l_end_index,
  			'TRX_LINE_DIST_TBL',
         		p_trx_line_index,
  	        	p_event_class_rec,
  		        x_return_status,
  			l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                          'Incorrect return_status after calling ' ||
                          'ZX_TDS_TAX_STATUS_DETM_PKG.get_tax_status()');
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_error,
                          'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                          'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
          END IF;
          RETURN;
        END IF;

        -- get tax rate
        --
        ZX_TDS_RATE_DETM_PKG.get_tax_rate(
         		l_begin_index,
  			l_end_index,
  	       		p_event_class_rec,
  			'TRX_LINE_DIST_TBL',
         		p_trx_line_index,
             		x_return_status,
  			l_error_buffer );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                           'Incorrect return_status after calling ' ||
                           'ZX_TDS_RATE_DETM_PKG.get_tax_rate()');
            FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                           'RETURN_STATUS = ' || x_return_status);
    	  FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                           'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
          END IF;
          RETURN;
        END IF;
      END IF;       -- historical_flag <> 'Y'

      -- Get taxable basis
      --
      ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis(
               		l_begin_index,
  		        l_end_index,
               		p_event_class_rec,
			'TRX_LINE_DIST_TBL',
       			p_trx_line_index,
        	        x_return_status,
			l_error_buffer );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                         'Incorrect return_status after calling ' || '
                           ZX_TDS_TAXABLE_BASIS_DETM_PKG.get_taxable_basis()');
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                         'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                         'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
        END IF;
        RETURN;
      END IF;

      -- Calculate tax amount
      --
      ZX_TDS_CALC_PKG.Get_tax_amount(
               		l_begin_index,
   		        l_end_index,
                	p_event_class_rec,
			'TRX_LINE_DIST_TBL',
                        p_trx_line_index,
           	        x_return_status,
			l_error_buffer );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                         'Incorrect return_status after calling '||
                         'ZX_TDS_CALC_PKG.Get_tax_amount()');
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                         'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                         'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
        END IF;
        RETURN;
      END IF;

      --
      -- populate Process_For_Recovery_Flag
      --
      ZX_TDS_TAX_LINES_POPU_PKG.populate_recovery_flg(
                                                l_begin_index,
                                                l_end_index,
                                                p_event_class_rec,
                                                x_return_status,
                                                l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;

      -- Call Internal_Flag Service to check mandatory columns, like WHO columns,
      -- line ids, etc, and populate values if they are missing.
      --
      ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line(
            		l_begin_index,
            		l_end_index,
            		x_return_status,
            		l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                         'Incorrect return_status after calling '||
                         'ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line()');
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                         'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                         'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
        END IF;
        RETURN;
      END IF;
    END IF;  -- begin_index and end_index NOT NULL, call internal services
  ELSE       -- tax_event_type_code other than 'CREATE','UPDATE','OVERRIDE_TAX'

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
    IF (g_level_statement >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)'||'Tax Event Type Code: '||
                      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                      p_trx_line_index));
    END IF;
    RETURN;
  END IF;    --  tax_event_type_code 'CREATE','UPDATE','OVERRIDE_TAX'

  IF p_event_class_rec.ctrl_total_hdr_tx_amt IS NOT NULL THEN

    -- If ctrl_hdr_tx_appl_flag is 'N', set the self_assessed_flag of detail
    -- tax lines to 'Y'
    --
    -- set overridden_flag = 'Y' and last_manual_entry = 'TAX_AMOUNT'
    --

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_hdr_tx_amt_flg := 'Y'; -- bug 5417887

    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_hdr_tx_appl_flag(
                                                    p_trx_line_index) = 'N' THEN
      FOR tax_line_index IN nvl(l_begin_index,0) .. nvl(l_end_index,-99) LOOP
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                    tax_line_index).self_assessed_flag := 'Y';
      END LOOP;

    END IF;      -- ctrl_hdr_tx_appl_flag is 'N'
  END IF;        -- ctrl_total_hdr_tx_amt IS NOT NULL

  -- Start : If Statement added for Bug#8540809
  -- If Ctrl_Total_Hdr_Tx_Amt is Not Null and Ctrl_Hdr_Tx_Appl_flag = Y then
  -- set the global variable g_ctrl_total_hdr_tx_amt_flg = Y

  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_total_hdr_tx_amt(p_trx_line_index) IS NOT NULL AND
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_hdr_tx_appl_flag(p_trx_line_index) = 'Y'
  THEN
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_hdr_tx_amt_flg := 'Y';
  END IF;
  -- End : If Statement added for Bug#8540809

  -- If ctrl_total_line_tx_amt is not null, process taxes for line level
  -- xml invoice
  --
  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_total_line_tx_amt (
                                               p_trx_line_index) IS NOT NULL
  THEN
    l_tax_exists_flg := 'N';
    FOR i IN  NVL(l_begin_index, 0) .. NVL(l_end_index, -1) LOOP
      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                               i).self_assessed_flag <> 'Y' AND
        ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                      i).offset_flag <> 'Y' OR
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                      i).offset_flag IS NULL) --Bug 5765221
      THEN
        l_tax_exists_flg := 'Y';
        EXIT;
      END IF;
    END LOOP;

    IF l_tax_exists_flg = 'Y' THEN

      -- populate p_event_class_rec.ctrl_total_line_tx_amt_flg because the value
      -- of ctrl_total_line_tx_amt of this transaction line is not null.
      --
      p_event_class_rec.ctrl_total_line_tx_amt_flg := 'Y';
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_line_tx_amt_flg := 'Y'; -- bug 5417887

    ELSE
      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_total_line_tx_amt(
                                                         p_trx_line_index) <> 0
      THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                        'line level control tax amount is not 0, ' ||
                        'but there is no tax lines created for the trx line.');

          FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                        'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
        END IF;

        FND_MESSAGE.SET_NAME('ZX','ZX_LN_CTRL_TOTAL_TAX_NOT_EXIST');

        -- FND_MSG_PUB.Add;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

        ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

        RETURN;
      END IF;    -- ctrl_total_line_tx_amt <> 0
    END IF;      -- l_tax_exists_flg = 'Y' or ELSE
  END IF;        -- ctrl_total_line_tx_amt IS NOT NULL

  -- If the number of tax lines in g_detail_tax_lines_tbl is greater than,
  -- or equals to 1000, dump the detail tax lines to the global temporary
  -- table zx_detail_tax_lines_gt
  --
  IF ( g_detail_tax_lines_tbl.LAST >= 1000) THEN

    dump_detail_tax_lines_into_gt (x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                      'Incorrect return_status after calling ' ||
                      'dump_detail_tax_lines_into_gt()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
      END IF;
      RETURN;
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                  'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
    END IF;

END calculate_tax;

/* ======================================================================*
 |  PROCEDURE override_detail_tax_lines                                  |
 |  This procedure is called for every transaction line                  |
 * ======================================================================*/
PROCEDURE  override_detail_tax_lines (
  p_trx_line_index	  IN	  	  BINARY_INTEGER,
  p_event_class_rec	  IN  OUT NOCOPY  zx_api_pub.event_class_rec_type,
  x_return_status         OUT NOCOPY      VARCHAR2) IS


BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.overide_detail_tax_lines.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.overide_detail_tax_lines(+)');
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                            p_trx_line_index) = 'OVERRIDE_TAX') THEN

    calculate_tax(  p_trx_line_index,
		    p_event_class_rec,
		    x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.overide_detail_tax_lines',
                       'Incorrect return_status after calling calculate_tax()');
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.overide_detail_tax_lines',
                       'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.overide_detail_tax_lines.END',
                       'ZX_TDS_CALC_SERVICES_PUB_PKG.override_detail_tax_lines(-)');
      END IF;
      RETURN;
    END IF;

  ELSE
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.override_detail_tax_lines',
                     'Tax Event Type Code: '||
                      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                      p_trx_line_index) ||' is not correct.');
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.overide_detail_tax_lines.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.override_detail_tax_lines(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.override_detail_tax_lines',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.override_detail_tax_lines.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.override_detail_tax_lines(-)');
    END IF;


END override_detail_tax_lines;

/* ======================================================================*
 |  PROCEDURE override_summary_lines                                     |
 |                                                                       |
 * ======================================================================*/
PROCEDURE  override_summary_tax_lines (
  p_trx_line_index	  IN	  	  BINARY_INTEGER,
  p_event_class_rec	  IN  OUT NOCOPY  zx_api_pub.event_class_rec_type,
  x_return_status  	  OUT NOCOPY      VARCHAR2) IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines(+)');
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF ( ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                          p_trx_line_index) = 'OVERRIDE_TAX') THEN

    calculate_tax( p_trx_line_index,
		   p_event_class_rec,
		   x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines',
                       'Incorrect return_status after calling calculate_tax()');
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines',
                       'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines.END',
                       'ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines(-)');
      END IF;
      RETURN;
    END IF;

  ELSE
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines',
                     'Tax Event Type Code: '||
                      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                      p_trx_line_index) ||' is not correct.');
    END IF;
  END IF;
  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.override_summary_tax_lines(-)');
    END IF;

END override_summary_tax_lines;

/* ====================================================== ===============*
 |  PROCEDURE tax_line_determination                                     |
 |  This procedure is called for the whole transaction                   |
 * ======================================================================*/
PROCEDURE  tax_line_determination (
  p_event_class_rec	  IN  OUT NOCOPY  zx_api_pub.event_class_rec_type,
  x_return_status         OUT NOCOPY      VARCHAR2) IS

 l_error_buffer 	VARCHAR2(240);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination.BEGIN',
           'ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_line_tx_amt_flg = 'Y' THEN

    -- Prorate tax across tax lines created for the transactrion line
    -- where the control_total_tax_line_amt is not null
    --
    -- Bug fix 5417887
    process_taxes_for_xml_inv_line (
        -- p_event_class_rec,
	x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
                      'Incorrect return_status after calling '||
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_line');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination.END',
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(-)');
      END IF;
      RETURN;
    END IF;

  ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_hdr_tx_amt_flg = 'Y' THEN
    -- If ctrl_total_hdr_tx_amt is not null, process taxes for header level
    -- xml invoice
    --
    -- process xml invoice with header level contrl amount
    --
    -- Bug fix 5417887
    process_taxes_for_xml_inv_hdr (
				-- p_event_class_rec,
				x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
               'Incorrect return_status after calling '||
               'ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_hdr');
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination.END',
               'ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(-)');
      END IF;
      RETURN;
    END IF;

  END IF;

  -- call Internal_Flag service ZX_TDS_TAX_LINES_DETM_PKG.determine_tax_lines
  --
  ZX_TDS_TAX_LINES_DETM_PKG.determine_tax_lines(
					p_event_class_rec,
           				x_return_status,
           			 	l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
             'Incorrect return_status after calling '||
             'ZX_TDS_TAX_LINES_DETM_PKG.determine_tax_lines()');
      FND_LOG.STRING(g_level_error,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_error,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination.END',
             'ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(-)');
    END IF;
    RETURN;
  END IF;

  -- adjust tax amount for xml invoices if the rounded total tax amount is
  -- different from the control amount
  --
  -- xml invoice with header level control amount
  --
  IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_hdr_tx_amt_flg = 'Y' THEN

    adjust_tax_for_xml_inv_hdr (
			-- p_event_class_rec,
			x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
               'Incorrect return_status after calling '||
               'ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_hdr');
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination.END',
               'ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(-)');
      END IF;
      RETURN;
    END IF;

  ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_line_tx_amt_flg = 'Y'  THEN

    -- xml invoice with header level control amount
    --
    -- if p_event_class_rec.ctrl_total_line_tx_amt_flg is 'Y'
    -- call adjust_tax_for_xml_inv_line for line level control total amount
    --
    adjust_tax_for_xml_inv_line (
			 -- p_event_class_rec,
	                 x_return_status);

    IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
               'Incorrect return_status after calling '||
               'ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_line');
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination.END',
               'ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(-)');
      END IF;
      RETURN;
    END IF;

  END IF;

  --IF p_event_class_rec.tax_event_type_code = 'OVERRIDE_TAX' AND
  --   p_event_class_rec.override_level = 'SUMMARY_OVERRIDE' THEN

  --  ZX_TDS_CALC_SERVICES_PUB_PKG.match_tax_amt_to_summary_line (
  --            p_event_class_rec	 => p_event_class_rec,
  --            x_return_status    => x_return_status );

  --  IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
  --    IF (g_level_error >= g_current_runtime_level ) THEN
  --      FND_LOG.STRING(g_level_error,
  --             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
  --             'Incorrect return_status after calling '||
  --             'ZX_TDS_CALC_SERVICES_PUB_PKG.match_tax_amt_to_summary_line');
  --      FND_LOG.STRING(g_level_error,
  --             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
  --             'RETURN_STATUS = ' || x_return_status);
  --      FND_LOG.STRING(g_level_error,
  --             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination.END',
  --             'ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(-)');
  --    END IF;
  --    RETURN;
  --  END IF;

  --END IF;

  -- Start Bugfix: 5617541
  -- Process tolerance check if control total passed
  -- bug 5684123
  IF (p_event_class_rec.tax_tolerance IS NOT NULL OR
      p_event_class_rec.tax_tol_amt_range IS NOT NULL) AND
     ((ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_hdr_tx_amt_flg = 'Y' OR
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_line_tx_amt_flg = 'Y'
      ) OR
      (p_event_class_rec.tax_event_type_code = 'UPDATE' AND
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_overridden_tax_ln_exist_flg = 'Y'
      )
     )
  THEN

    ZX_TDS_TAX_LINES_POPU_PKG.process_tax_tolerance(
            p_event_class_rec,
            x_return_status,
            l_error_buffer);

    IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
               'Incorrect return_status after calling '||
               'ZX_TDS_TAX_LINES_POPU_PKG.process_tax_tolerance');
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination.END
',
               'ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(-)');
      END IF;
      RETURN;
    END IF;


  END IF;

-- End Bugfix: 5617541

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(-)');
    END IF;

END tax_line_determination;

/*=========================================================================*
 | Public procedure prorate_imported_sum_tax_lines is used to prorate      |
 | imported summary tax lines to create detail tax lines.                  |
 *=========================================================================*/
PROCEDURE prorate_imported_sum_tax_lines (
 p_event_class_rec        IN 	         zx_api_pub.event_class_rec_type,
 x_return_status             OUT NOCOPY  VARCHAR2) IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines.BEGIN',
           'ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- get detail tax lines from imported summary lines
  --
  ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines(
     p_event_class_rec => p_event_class_rec,
     x_return_status   => x_return_status);

  IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines',
             'Incorrect return_status after calling ' ||
             'ZX_TDS_IMPORT_DOCUMENT_PKG.prorate_imported_sum_tax_lines() ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines.END',
             'ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines(-)');
    END IF;
    RETURN;
  END IF;

  -- dump detail tax lines created from summary tax lines into
  -- zx_detail_tax_lines_gt
  --
  dump_detail_tax_lines_into_gt (x_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines',
             'Incorrect return_status after calling ' ||
             'dump_detail_tax_lines_into_gt()');
      FND_LOG.STRING(g_level_error,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_error,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines.END',
             'ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines.END',
           'ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines',
              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines.END',
             'ZX_TDS_CALC_SERVICES_PUB_PKG.prorate_imported_sum_tax_lines(-)');
    END IF;
END prorate_imported_sum_tax_lines;

/* ======================================================================*
 |  PROCEDURE calculate_tax_for_import                                                     |
 * ======================================================================*/
PROCEDURE  calculate_tax_for_import (
 p_trx_line_index	  IN	       BINARY_INTEGER,
 p_event_class_rec	  IN           zx_api_pub.event_class_rec_type,
 x_return_status          OUT NOCOPY   VARCHAR2) IS

 l_tax_date               DATE;
 l_tax_determine_date     DATE;
 l_tax_point_date         DATE;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import.BEGIN',
                  'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- Bug 3971016: Skip processing tax lines for line_level_action
  --              'RECORD_WITH_NO_TAX'
  --
  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                      p_trx_line_index) = 'RECORD_WITH_NO_TAX'
  THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import.END',
         'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import(-)'||' Skip processing for record_with_no_tax');
    END IF;
    RETURN;
  END IF;

  IF(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                              p_trx_line_index) = 'CREATE') THEN
    -- get tax dates
    --
    ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date(	p_trx_line_index,
						l_tax_date,
 						l_tax_determine_date,
 						l_tax_point_date,
						x_return_status	);

    IF x_return_status  <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import.END',
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;

    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(
                                                     p_trx_line_index) IS NOT NULL
    THEN
      g_reference_doc_exist_flg := 'Y';
    END IF;

    -- perform additional applicability process for import
    --
    ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import(
						p_trx_line_index,
		 				p_event_class_rec,
	 					l_tax_date,
 		 				l_tax_determine_date,
 						l_tax_point_date,
						x_return_status );

    IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import',
                       'Incorrect return_status after calling ' ||
                       'ZX_TDS_IMPORT_DOCUMENT_PKG.calculate_tax_for_import()');
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import',
                       'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import.END',
                       'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import(-)');
      END IF;
      RETURN;
    END IF;

  ELSE
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
    IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import.END',
                    'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import(-)'||' tax event type'||
                    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                              p_trx_line_index));
    END IF;
    RETURN;
  END IF;       -- tax_event_type_code

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import.END',
                  'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import.END',
                    'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax_for_import(-)');
    END IF;

END calculate_tax_for_import;

PROCEDURE update_exchange_rate (
  p_event_class_rec      	IN          ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  p_ledger_id			IN          NUMBER,
  p_currency_conversion_rate    IN          NUMBER,
  p_currency_conversion_type    IN          VARCHAR2,
  p_currency_conversion_date    IN          DATE,
  x_return_status        	OUT NOCOPY  VARCHAR2 ) IS

 l_error_buffer			VARCHAR2(240);
 l_currency_conversion_rate     NUMBER;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate(+)');
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- assign p_currency_conversion_rate to a local variable for a IN OUT
  -- parameter in the calling procedure. This may be changed later.
  --
  l_currency_conversion_rate := p_currency_conversion_rate;

  -- perform conversion and rounding for tax lines in ZX_LINES
  --
  ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_curr(
                p_conversion_rate   => l_currency_conversion_rate,
                p_conversion_type   => p_currency_conversion_type,
                p_conversion_date   => p_currency_conversion_date,
                p_event_class_rec   => p_event_class_rec,
                p_return_status     => x_return_status,
                p_error_buffer      => l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate',
                       'Incorrect return_status after calling ' ||
                       'ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_curr()');
      FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate',
                       'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate.END',
                       'ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate(-)');
    END IF;
    RETURN;
  END IF;

  -- call ZX_TRD_SERVICES_PUB_PKG.update_exchange_rate only if the value
  -- of p_event_class_rec.tax_recovery_flag is 'Y',
  --
  IF p_event_class_rec.tax_recovery_flag = 'Y' THEN

    -- perform conversion and rounding for tax distributions in
    -- ZX_REC_NREC_TAX_DIST
    --
    ZX_TRD_SERVICES_PUB_PKG.update_exchange_rate (
  		p_event_class_rec           => p_event_class_rec,
  		p_ledger_id                 => p_ledger_id,
  		p_currency_conversion_rate  => p_currency_conversion_rate,
  		p_currency_conversion_type  => p_currency_conversion_type,
  		p_currency_conversion_date  => p_currency_conversion_date,
  		x_return_status             => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate',
                         'Incorrect return_status after calling ' ||
                         'ZX_TRD_INTERNAL_SERVICES_PVT.update_exchange_rate()');
        FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate',
                         'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate.END',
                         'ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate(-)');
      END IF;
      RETURN;
    END IF;
  END IF;    -- p_event_class_rec.tax_recovery_flag = 'Y'

  -- updating related columns in functional currency in ZX_LINES_SUMMARY and
  -- ZX_LINES
  --
  ZX_TRL_PUB_PKG.update_exchange_rate (
		p_event_class_rec          =>  p_event_class_rec,
		x_return_status            =>  x_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate',
                       'Incorrect return_status after calling ' ||
                       'ZX_TRL_PUB_PKG.update_exchange_rate()');
      FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate',
                       'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate.END',
                       'ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate(-)');
    END IF;

END update_exchange_rate;

/* ======================================================================*
 |  PROCEDURE  validate_document_for_tax                                 |
 |  							                 |
 * ======================================================================*/
PROCEDURE validate_document_for_tax (
  x_return_status	  OUT NOCOPY 		VARCHAR2) IS

  begin_index	  BINARY_INTEGER;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.validate_document_for_tax.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.validate_document_for_tax(+)');
  END IF;

  begin_index := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id.FIRST;

  IF(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                              begin_index) = 'VALIDATE')  THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.validate_document_for_tax',
                     'Tax Event Type Code: '||
                      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                      begin_index) ||' is not correct.');
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.validate_document_for_tax',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.validate_document_for_tax.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.validate_document_for_tax(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.validate_document_for_tax',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.validate_document_for_tax.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.validate_document_for_tax(-)');
    END IF;

END validate_document_for_tax;

/* ======================================================================*
 |  PROCEDURE  reverse_document                                          |
 |  							                 |
 * ======================================================================*/
PROCEDURE reverse_document (
  p_event_class_rec  IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status    OUT NOCOPY VARCHAR2 ) IS
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.reverse_document.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.reverse_document(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- init msg record to be passed back to TSRM
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.application_id :=
              p_event_class_rec.application_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.entity_code :=
              p_event_class_rec.entity_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.event_class_code :=
              p_event_class_rec.event_class_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_id :=
              p_event_class_rec.trx_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.summary_tax_line_number :=
              NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.tax_line_id := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_dist_id := NULL;

  -- call procedure reverse_document in ZX_TDS_REVERSE_DOCUMENT_PKG
  --
  ZX_TDS_REVERSE_DOCUMENT_PKG.reverse_document ( p_event_class_rec,
                                                 x_return_status );

  IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.reverse_document',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_REVERSE_DOCUMENT_PKG.reverse_document() ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.reverse_document.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.reverse_document(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.reverse_document.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.reverse_document(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.reverse_document',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.reverse_document.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.reverse_document(-)');
    END IF;

END reverse_document;

/* ======================================================================*
  |   Procedure   set_detail_tax_line_def_val is called to check the     |
  |   default values in the global structure                             |
  |                 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl  |
  |   Bug fix 3423300                                                    |
  * =====================================================================*/

PROCEDURE set_detail_tax_line_def_val (
  p_detail_tax_lines_rec   IN OUT NOCOPY  ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
  x_return_status	   OUT NOCOPY	  VARCHAR2
) IS
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.set_detail_tax_line_def_val.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.set_detail_tax_line_def_val(+)');
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  p_detail_tax_lines_rec.tax_amt_included_flag           := NVL( p_detail_tax_lines_rec.tax_amt_included_flag, 'N' );
  p_detail_tax_lines_rec.compounding_tax_flag            := NVL( p_detail_tax_lines_rec.compounding_tax_flag, 'N' );
  p_detail_tax_lines_rec.self_assessed_flag              := NVL( p_detail_tax_lines_rec.self_assessed_flag, 'N' );
  p_detail_tax_lines_rec.reporting_only_flag             := NVL( p_detail_tax_lines_rec.reporting_only_flag, 'N' );
  p_detail_tax_lines_rec.associated_child_frozen_flag    := NVL( p_detail_tax_lines_rec.associated_child_frozen_flag, 'N' );
  p_detail_tax_lines_rec.copied_from_other_doc_flag        := NVL( p_detail_tax_lines_rec.copied_from_other_doc_flag, 'N' );
  p_detail_tax_lines_rec.historical_flag                 := NVL( p_detail_tax_lines_rec.historical_flag, 'N' );
  p_detail_tax_lines_rec.offset_flag                     := NVL( p_detail_tax_lines_rec.offset_flag, 'N' );
  p_detail_tax_lines_rec.process_for_recovery_flag       := NVL( p_detail_tax_lines_rec.process_for_recovery_flag, 'N' );
  p_detail_tax_lines_rec.cancel_flag                     := NVL( p_detail_tax_lines_rec.cancel_flag, 'N' );
  p_detail_tax_lines_rec.purge_flag                      := NVL( p_detail_tax_lines_rec.purge_flag, 'N' );
  p_detail_tax_lines_rec.delete_flag                     := NVL( p_detail_tax_lines_rec.delete_flag, 'N' );
  p_detail_tax_lines_rec.overridden_flag                 := NVL( p_detail_tax_lines_rec.overridden_flag, 'N' );
  p_detail_tax_lines_rec.manually_entered_flag           := NVL( p_detail_tax_lines_rec.manually_entered_flag, 'N' );
  p_detail_tax_lines_rec.item_dist_changed_flag          := NVL( p_detail_tax_lines_rec.item_dist_changed_flag, 'N' );
  p_detail_tax_lines_rec.freeze_until_overridden_flag    := NVL( p_detail_tax_lines_rec.freeze_until_overridden_flag, 'N' );
  p_detail_tax_lines_rec.tax_only_line_flag              := NVL( p_detail_tax_lines_rec.tax_only_line_flag, 'N' );
  p_detail_tax_lines_rec.enforce_from_natural_acct_flag  := NVL( p_detail_tax_lines_rec.enforce_from_natural_acct_flag, 'N' );
--  p_detail_tax_lines_rec.line_amt_includes_tax_flag      := NVL( p_detail_tax_lines_rec.line_amt_includes_tax_flag, 'N' );
  p_detail_tax_lines_rec.recalc_required_flag            := 'N';
  p_detail_tax_lines_rec.compounding_dep_tax_flag        := NVL( p_detail_tax_lines_rec.compounding_dep_tax_flag, 'N' );
  p_detail_tax_lines_rec.mrc_tax_line_flag               := NVL(p_detail_tax_lines_rec.mrc_tax_line_flag, 'N');
  p_detail_tax_lines_rec.tax_apportionment_flag          := NVL(p_detail_tax_lines_rec.tax_apportionment_flag, 'N');

  p_detail_tax_lines_rec.tax_apportionment_line_number   := NVL(p_detail_tax_lines_rec.tax_apportionment_line_number,1);

  p_detail_tax_lines_rec.record_type_code                := NVL(p_detail_tax_lines_rec.record_type_code, 'ETAX_CREATED');

  -- bug 6656723
  IF p_detail_tax_lines_rec.tax_event_type_code = 'OVERRIDE_TAX' THEN
    p_detail_tax_lines_rec.tax_line_number               := NVL(p_detail_tax_lines_rec.tax_line_number, NUMBER_DUMMY);
  ELSE
    p_detail_tax_lines_rec.tax_line_number               := NUMBER_DUMMY;
  END IF;

  p_detail_tax_lines_rec.object_version_number           := NVL(p_detail_tax_lines_rec.object_version_number, 1);

  p_detail_tax_lines_rec.multiple_jurisdictions_flag     := NVL(p_detail_tax_lines_rec.multiple_jurisdictions_flag, 'N');

  -- Commented out: Bug 4438636
  --
  -- override the rounding rule from registration party type or tax
  -- with the rounding rule from TSRM rounding party hierarchy
  --
  --IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule IS NOT NULL THEN
  --  p_detail_tax_lines_rec.rounding_rule_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule;
  --END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.set_detail_tax_line_def_val.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.set_detail_tax_line_def_val(-)');
  END IF;

END set_detail_tax_line_def_val;

/* ======================================================================*
  |  Procedure dump_detail_tax_lines_into_gt is called to insert detail    |
  |    tax lines into the global temporary table zx_detail_tax_lines_gt  |
  |     when the number of tax lines in the g_detail_tax_line_tbl        |
  |     reaches 1000                                                     |
  * =====================================================================*/

PROCEDURE dump_detail_tax_lines_into_gt (
 p_detail_tax_lines_tbl	     IN OUT NOCOPY     	detail_tax_lines_tbl_type,
 x_return_status	 	OUT NOCOPY	VARCHAR2) IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(+)');
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF (p_detail_tax_lines_tbl.COUNT = 0) THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt',
                       'p_detail_tax_lines_tbl is empty. ');
    END IF;

  ELSE

    --
    -- populate default values in tax line before insert
    --
    FOR i IN p_detail_tax_lines_tbl.FIRST ..
             p_detail_tax_lines_tbl.LAST   LOOP
      set_detail_tax_line_def_val (
            p_detail_tax_lines_tbl(i),
            x_return_status );
      IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
    END LOOP;

    FORALL tax_line_index IN p_detail_tax_lines_tbl.FIRST ..
                             p_detail_tax_lines_tbl.LAST

      INSERT INTO zx_detail_tax_lines_gt
           VALUES p_detail_tax_lines_tbl(tax_line_index);

    -- Flush g_detail_tax_lines_tbl
    --p_detail_tax_lines_tbl.DELETE;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(-)');
    END IF;

END dump_detail_tax_lines_into_gt;

/* ======================================================================*
  |  Procedure dump_detail_tax_lines_into_gt is called to insert detail    |
  |  tax lines into the global temporary table zx_detail_tax_lines_gt    |
  * =====================================================================*/

PROCEDURE dump_detail_tax_lines_into_gt (
 x_return_status	 	OUT NOCOPY	VARCHAR2) IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  /*
   * move to dump_detail_tax_lines_into_gt with 2 parameters
   *
   * FOR l_index IN
   *        NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.FIRST, 1) ..
   *        NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0)
   * LOOP
   *  set_detail_tax_line_def_val (
   *       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_index),
   *       x_return_status );
   *  END LOOP;
   */

    dump_detail_tax_lines_into_gt(
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl,
          x_return_status  );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt',
                       'Incorrect return_status after calling '||
                       'ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt');
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt',
                       'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt.END',
                       'ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(-)');
      END IF;
      RETURN;
    END IF;

    -- Flush g_detail_tax_lines_tbl
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.DELETE;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(-)');
    END IF;

END dump_detail_tax_lines_into_gt;

/* ======================================================================*
 |  PROCEDURE  initialize                                                |
 * ======================================================================*/
PROCEDURE initialize IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize.BEGIN',
                  'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize(+)');
  END IF;
  g_detail_tax_lines_tbl.DELETE;

--  g_trx_lines_counter :=0;

--  g_check_template_tbl;
--  ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl;
--  g_tax_rate_info_tbl;
--  g_max_tax_line_number;

--  g_check_cond_grp_tbl.DELETE;
  g_fsc_tbl.DELETE;
  ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl.DELETE;
--  g_tsrm_num_value_tbl.DELETE;
--  g_tsrm_alphanum_value_tbl.DELETE;
--  g_trx_alphanum_value_tbl.DELETE;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize.END',
                  'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize(-)');
    END IF;

    RAISE;

END initialize;

/* ======================================================================*
 |  PROCEDURE  fetch_detail_tax_lines                                    |
 * ======================================================================*/
PROCEDURE fetch_detail_tax_lines (
  x_return_status	   OUT NOCOPY 	     	    VARCHAR2) IS

 CURSOR fetch_detail_tax_lines(p_line_index	NUMBER) IS
   SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */ *
    FROM  zx_detail_tax_lines_gt
   WHERE  trx_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id(p_line_index)
     AND  application_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_line_index)
     AND  entity_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_line_index)
     AND  event_class_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_line_index);

 l_last_row 		NUMBER;

BEGIN

  IF (g_level_procedure>= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.fetch_detail_tax_lines.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.fetch_detail_tax_lines(+)');
  END IF;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
   l_last_row      := 1;

  -- Initialize p_det_tax_line_tbl
  g_detail_tax_lines_tbl.delete;

  FOR detail_tax_lines_rec IN fetch_detail_tax_lines(
                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id.FIRST) LOOP
    g_detail_tax_lines_tbl(l_last_row) := detail_tax_lines_rec;
    l_last_row := l_last_row + 1;
  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.fetch_detail_tax_lines.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.fetch_detail_tax_lines(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.fetch_detail_tax_lines',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.fetch_detail_tax_lines.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.fetch_detail_tax_lines(-)');
    END IF;

END fetch_detail_tax_lines;

/*=========================================================================*
 | This procedure contains the code for processing tax lines for XML       |
 | invoices with line level control amount.                                |
 | rewrite for bug fix 3420456                                             |
 *=========================================================================*/

PROCEDURE process_taxes_for_xml_inv_line (
  -- p_event_class_rec        IN 	        zx_api_pub.event_class_rec_type,
  x_return_status           OUT NOCOPY   VARCHAR2) IS

 CURSOR get_total_line_tax_amt_csr IS
 SELECT /*+ INDEX(tax_line ZX_DETAIL_TAX_LINES_GT_U1) */
        ROUND(SUM(tax_line.unrounded_tax_amt), 20),
        tax_line.application_id,
        tax_line.event_class_code,
        tax_line.entity_code,
        tax_line.trx_id,
        tax_line.trx_line_id,
        tax_line.trx_level_type,
        tax_line.ctrl_total_line_tx_amt
   FROM zx_detail_tax_lines_gt tax_line
  WHERE
  -- commented out for bug fix 5417887
  --     tax_line.application_id = p_event_class_rec.application_id
  -- AND tax_line.event_class_code = p_event_class_rec.event_class_code
  -- AND tax_line.entity_code = p_event_class_rec.entity_code
  -- AND tax_line.trx_id = p_event_class_rec.trx_id
  -- AND
    nvl(tax_line.ctrl_total_line_tx_amt,0) <> 0
    AND tax_line.self_assessed_flag <> 'Y'
    AND tax_line.offset_flag <> 'Y'
    AND tax_line.offset_link_to_tax_line_id IS NULL
    AND NVL(cancel_flag,'N') <> 'Y'
    GROUP BY tax_line.application_id,
             tax_line.event_class_code,
             tax_line.entity_code,
             tax_line.trx_id,
             tax_line.trx_line_id,
             tax_line.trx_level_type,
             tax_line.ctrl_total_line_tx_amt;

 CURSOR get_mismatch_tax_lines_csr IS
 SELECT /*+ INDEX(tax_line ZX_DETAIL_TAX_LINES_GT_U1) */
        ROUND(SUM(tax_line.unrounded_tax_amt), 20)
   FROM zx_detail_tax_lines_gt tax_line
  WHERE tax_line.ctrl_total_line_tx_amt <> 0
    AND tax_line.self_assessed_flag <> 'Y'
    AND tax_line.offset_flag <> 'Y'
    AND tax_line.offset_link_to_tax_line_id IS NULL
    AND NVL(cancel_flag,'N') <> 'Y'
    GROUP BY tax_line.application_id,
             tax_line.event_class_code,
             tax_line.entity_code,
             tax_line.trx_id,
             tax_line.trx_line_id,
             tax_line.trx_level_type,
             tax_line.ctrl_total_line_tx_amt
    HAVING NVL(SUM(tax_line.unrounded_tax_amt),0) = 0;


 l_total_line_tx_amt             NUMBER;
 l_temp_char                     VARCHAR2(1);

 TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE var_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

 l_trx_line_id_tbl		num_tbl_type;
 l_trx_level_type_tbl		var_tbl_type;
 l_total_line_tx_amt_tbl	num_tbl_type;
 l_ctrl_total_line_tx_amt_tbl   num_tbl_type;
 l_application_id_tbl           num_tbl_type;
 l_event_class_code_tbl  var_tbl_type;
 l_entity_code_tbl       var_tbl_type;
 l_trx_id_tbl     num_tbl_type;

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_line.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_line(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  OPEN get_mismatch_tax_lines_csr;
  FETCH get_mismatch_tax_lines_csr INTO l_total_line_tx_amt;

  IF get_mismatch_tax_lines_csr%FOUND THEN
    CLOSE get_mismatch_tax_lines_csr;

    -- Raise error if ctrl_total_line_tx_amt <> 0.
    -- no action is required, if ctrl_total_line_tx_amt is 0,
    --
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF (g_level_statement >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_line',
                     'line level control tax amount is not 0, ' ||
                     'but the total calculated tax amount for this trx line is 0, cannot do tax proration.' );
      --FND_LOG.STRING(g_level_statement,
      --               'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_line',
      --               'trx_line_id = ' || l_trx_line_id_tbl(i));
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_line.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.' ||
                     'process_taxes_for_xml_inv_line(-)');
    END IF;

    FND_MESSAGE.SET_NAME('ZX','ZX_LN_CTRL_TOTAL_TAX_MISMATCH');

    -- FND_MSG_PUB.Add;
    --ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
    --                                                     l_trx_line_id_tbl(i);
    --ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
    --                                                  l_trx_level_type_tbl(i);
    ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

    RETURN;
  ELSE
    CLOSE get_mismatch_tax_lines_csr;
  END IF;

  -- open cursor  get_total_line_tax_amt_csr
  --
  OPEN  get_total_line_tax_amt_csr;
  LOOP
    FETCH get_total_line_tax_amt_csr BULK COLLECT INTO
          l_total_line_tx_amt_tbl,
          l_application_id_tbl,
          l_event_class_code_tbl,
          l_entity_code_tbl,
          l_trx_id_tbl,
          l_trx_line_id_tbl,
          l_trx_level_type_tbl,
	  l_ctrl_total_line_tx_amt_tbl
    LIMIT G_LINES_PER_FETCH;

  -- for each trx line prorate the tax amount according to the control total_tax amount
  FORALL i IN l_trx_line_id_tbl.FIRST .. l_trx_line_id_tbl.LAST

      -- 1. Prorate tax amt to all tax lines of this transaction line,
      --    using l_ctrl_total_line_tx_amt
      -- 2. populate ctrl_total_line_tx_amt in g_detail_tax_lines_tbl
      -- 3. for now set the original tax_amt, taxable_amt to the unrounded tax_amt
      --    and taxable_amount since rounded amounts are not available yet. This
      --    logic may need to change based on later Reporting requirements.

      UPDATE /*+ INDEX(line ZX_DETAIL_TAX_LINES_GT_U1) */
          zx_detail_tax_lines_gt line
      SET line.orig_tax_amt = line.unrounded_tax_amt,
          line.orig_taxable_amt = line.unrounded_taxable_amt,
          line.orig_tax_rate = line.tax_rate,
          line.tax_amt = NULL,
          line.unrounded_tax_amt = line.unrounded_tax_amt * (l_ctrl_total_line_tx_amt_tbl(i)/l_total_line_tx_amt_tbl(i)),
          line.ctrl_total_line_tx_amt = l_ctrl_total_line_tx_amt_tbl(i),
          line.sync_with_prvdr_flag = DECODE(line.tax_provider_id, NULL, 'N', 'Y'),
          line.overridden_flag  = 'Y',
          line.last_manual_entry = 'TAX_AMOUNT',
          line.taxable_amt = NULL,
          (line.unrounded_taxable_amt,
           line.tax_rate,
           line.taxable_basis_formula)
          = (select decode ( NVL(rate.ALLOW_ADHOC_TAX_RATE_FLAG, 'N'),
                     'N', decode ( line.tax_rate, 0,  line.unrounded_taxable_amt,
                          ROUND((line.unrounded_tax_amt * (l_ctrl_total_line_tx_amt_tbl(i)/l_total_line_tx_amt_tbl(i)))/line.tax_rate*100 , 20)
			         ),
                     'Y', decode ( NVL(rate.ADJ_FOR_ADHOC_AMT_CODE, 'TAXABLE_BASIS'),
                          'TAXABLE_BASIS', decode(line.tax_rate, 0, line.unrounded_taxable_amt,
                          ROUND((line.unrounded_tax_amt * (l_ctrl_total_line_tx_amt_tbl(i)/l_total_line_tx_amt_tbl(i)))/line.tax_rate*100, 20)
			                          ),
                          line.unrounded_taxable_amt),
                     line.unrounded_taxable_amt ) unrounded_taxable_amt,

                     decode ( NVL(rate.ALLOW_ADHOC_TAX_RATE_FLAG, 'N'),
                     'Y', decode ( NVL(rate.ADJ_FOR_ADHOC_AMT_CODE, 'TAXABLE_BASIS'),
                          'TAX_RATE', decode(line.unrounded_taxable_amt, 0, line.tax_rate,
                                           ROUND((line.unrounded_tax_amt * (l_ctrl_total_line_tx_amt_tbl(i)/l_total_line_tx_amt_tbl(i)))/line.unrounded_taxable_amt*100 , 20)
					     ),
                          line.tax_rate),
                     line.tax_rate ) tax_rate,

                     decode ( NVL(rate.ALLOW_ADHOC_TAX_RATE_FLAG, 'N'),
                     'N', decode ( line.tax_rate, 0,  line.taxable_basis_formula, 'PRORATED_TB' ),
                     'Y', decode ( NVL(rate.ADJ_FOR_ADHOC_AMT_CODE, 'TAXABLE_BASIS'),
                          'TAXABLE_BASIS', decode(line.tax_rate, 0, line.taxable_basis_formula, 'PRORATED_TB'),
                          line.taxable_basis_formula),
                     line.taxable_basis_formula ) taxable_basis_formula

              from zx_rates_b rate
             where line.tax_rate_id = rate.tax_rate_id
           )
      WHERE  line.application_id = l_application_id_tbl(i)
         AND line.event_class_code = l_event_class_code_tbl(i)
         AND line.entity_code = l_entity_code_tbl(i)
         AND line.trx_id = l_trx_id_tbl(i)
         AND line.trx_line_id = l_trx_line_id_tbl(i)
         AND line.trx_level_type = l_trx_level_type_tbl(i)
         AND nvl(line.ctrl_total_line_tx_amt,0) <> 0  -- change for this bug 7000903
         AND line.self_assessed_flag <> 'Y'
         AND line.offset_flag <> 'Y'
         AND line.offset_link_to_tax_line_id IS NULL
         AND NVL(cancel_flag,'N') <> 'Y';

    EXIT WHEN get_total_line_tax_amt_csr%NOTFOUND;
  END LOOP;

  CLOSE get_total_line_tax_amt_csr;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_line',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_line.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.' ||
                   'process_taxes_for_xml_inv_line(-)');
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF get_total_line_tax_amt_csr%ISOPEN THEN
       CLOSE get_total_line_tax_amt_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_line',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_line.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_line(-)');
    END IF;

END process_taxes_for_xml_inv_line;

/*=========================================================================*
 | This procedure contains the code for processing tax lines for XML       |
 |   invoices with header level control tax amount.                        |
 *=========================================================================*/

PROCEDURE process_taxes_for_xml_inv_hdr (
  --p_event_class_rec        IN 	        zx_api_pub.event_class_rec_type,
  x_return_status          OUT NOCOPY   VARCHAR2) IS

 CURSOR get_total_trx_tax_amt_csr IS
 SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
        ROUND(SUM(tax_line.unrounded_tax_amt), 20),
        tax_line.application_id,
        tax_line.event_class_code,
        tax_line.entity_code,
        tax_line.trx_id,
        trx_line.ctrl_total_hdr_tx_amt
   FROM zx_detail_tax_lines_gt tax_line,
        zx_lines_det_factors  trx_line
  WHERE tax_line.application_id = trx_line.application_id
    AND tax_line.event_class_code = trx_line.event_class_code
    AND tax_line.entity_code = trx_line.entity_code
    AND tax_line.trx_id = trx_line.trx_id
--  bugfix 5599951
    AND tax_line.trx_line_id = trx_line.trx_line_id
    AND tax_line.trx_level_type = trx_line.trx_level_type
    AND trx_line.ctrl_total_hdr_tx_amt IS NOT NULL
    AND tax_line.self_assessed_flag <> 'Y'
    AND tax_line.offset_flag <> 'Y'
    AND tax_line.offset_link_to_tax_line_id IS NULL
    AND NVL(cancel_flag,'N') <> 'Y'
    GROUP BY tax_line.application_id,
             tax_line.event_class_code,
             tax_line.entity_code,
             tax_line.trx_id,
             trx_line.ctrl_total_hdr_tx_amt;


 CURSOR get_mismatch_tax_lines_csr IS
 SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
        ROUND(SUM(tax_line.unrounded_tax_amt), 20)
   FROM zx_detail_tax_lines_gt tax_line,
        zx_lines_det_factors  trx_line
  WHERE tax_line.application_id = trx_line.application_id
    AND tax_line.event_class_code = trx_line.event_class_code
    AND tax_line.entity_code = trx_line.entity_code
    AND tax_line.trx_id = trx_line.trx_id
    --  bugfix 5599951
    AND tax_line.trx_line_id = trx_line.trx_line_id
    AND tax_line.trx_level_type = trx_line.trx_level_type
    AND trx_line.ctrl_total_hdr_tx_amt <> 0
    AND tax_line.self_assessed_flag <> 'Y'
    AND tax_line.offset_flag <> 'Y'
    AND tax_line.offset_link_to_tax_line_id IS NULL
    AND NVL(cancel_flag,'N') <> 'Y'
    GROUP BY tax_line.application_id,
             tax_line.event_class_code,
             tax_line.entity_code,
             tax_line.trx_id,
             trx_line.ctrl_total_hdr_tx_amt
    HAVING NVL(SUM(tax_line.unrounded_tax_amt), 0) = 0;


 l_total_trx_tax_amt		NUMBER;

 TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE var_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

 l_total_trx_tax_amt_tbl     num_tbl_type;
 l_ctrl_total_hdr_tx_amt_tbl num_tbl_type;
 l_application_id_tbl           num_tbl_type;
 l_event_class_code_tbl  var_tbl_type;
 l_entity_code_tbl       var_tbl_type;
 l_trx_id_tbl     num_tbl_type;

BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_hdr.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_hdr(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  OPEN get_mismatch_tax_lines_csr;
  FETCH get_mismatch_tax_lines_csr INTO l_total_trx_tax_amt;

  IF get_mismatch_tax_lines_csr%FOUND THEN
    CLOSE get_mismatch_tax_lines_csr;

    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_hdr',
                     'The header level control tax amount is not 0, ' ||
                     'but total calculated tax amount for this transaction is 0.');
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_hdr.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.' ||
                     'process_taxes_for_xml_inv_hdr(-)');
    END IF;

    FND_MESSAGE.SET_NAME('ZX','ZX_HDR_CTRL_TOTAL_TAX_MISMATCH');

    -- FND_MSG_PUB.Add;
    ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

    RETURN;
  ELSE
    CLOSE get_mismatch_tax_lines_csr;
  END IF;


  -- get l_total_trx_tax_amt for all tax lines of this transaction
  --
  OPEN  get_total_trx_tax_amt_csr;
  LOOP

    FETCH get_total_trx_tax_amt_csr  BULK COLLECT INTO
          l_total_trx_tax_amt_tbl,
          l_application_id_tbl,
          l_event_class_code_tbl,
          l_entity_code_tbl,
          l_trx_id_tbl,
          l_ctrl_total_hdr_tx_amt_tbl
    LIMIT G_LINES_PER_FETCH;


  FORALL i IN l_trx_id_tbl.FIRST .. l_trx_id_tbl.LAST
    -- 1. prorate tax amount to all tax lines of this transaction.
    -- 2. for now set the original tax_amt, taxable_amt to the unrounded tax_amt
    --    and taxable_amount since rounded amounts are not available yet. This
    --    logic may need to change based on later Reporting requirements.
    --
    UPDATE /*+ INDEX(line ZX_DETAIL_TAX_LINES_GT_U1) */
           zx_detail_tax_lines_gt line
       SET line.orig_tax_amt = line.unrounded_tax_amt,
           line.orig_taxable_amt = line.unrounded_taxable_amt,
           line.orig_tax_rate = line.tax_rate,
           line.tax_amt = NULL,
           line.unrounded_tax_amt = DECODE(l_total_trx_tax_amt_tbl(i),
             0, 0, (line.unrounded_tax_amt * (l_ctrl_total_hdr_tx_amt_tbl(i)/l_total_trx_tax_amt_tbl(i)))),
           line.sync_with_prvdr_flag = DECODE(tax_provider_id, NULL, 'N', 'Y'),
           line.overridden_flag  = 'Y',
           line.last_manual_entry = 'TAX_AMOUNT',
           line.taxable_amt = NULL,
           (line.unrounded_taxable_amt,
            line.tax_rate,
            line.taxable_basis_formula)
           = (select decode ( NVL(rate.ALLOW_ADHOC_TAX_RATE_FLAG, 'N'),
                      'N', decode(line.tax_rate, 0,  line.unrounded_taxable_amt,
                                  DECODE(l_total_trx_tax_amt_tbl(i), 0, line.unrounded_taxable_amt,
                                         ROUND((unrounded_tax_amt * (l_ctrl_total_hdr_tx_amt_tbl(i)/l_total_trx_tax_amt_tbl(i)))/line.tax_rate*100, 20))
                                 ),
                      'Y', decode ( NVL(rate.ADJ_FOR_ADHOC_AMT_CODE, 'TAXABLE_BASIS'),
                           'TAXABLE_BASIS', decode(line.tax_rate, 0, line.unrounded_taxable_amt,
                                                   DECODE(l_total_trx_tax_amt_tbl(i), 0, line.unrounded_taxable_amt,
                                                          ROUND((line.unrounded_tax_amt*(l_ctrl_total_hdr_tx_amt_tbl(i)/l_total_trx_tax_amt_tbl(i)))/line.tax_rate*100, 20))
                                                         ),
                          line.unrounded_taxable_amt),
                     line.unrounded_taxable_amt ) unrounded_taxable_amt,

                     decode ( NVL(rate.ALLOW_ADHOC_TAX_RATE_FLAG, 'N'),
                      'Y', decode(NVL(rate.ADJ_FOR_ADHOC_AMT_CODE, 'TAXABLE_BASIS'),
                                  'TAX_RATE',
                                   decode(line.unrounded_taxable_amt,
                                          0, line.tax_rate,
                                          decode(l_total_trx_tax_amt_tbl(i),
                                                  0, line.tax_rate,
                                                  Round((line.unrounded_tax_amt*(l_ctrl_total_hdr_tx_amt_tbl(i)/l_total_trx_tax_amt_tbl(i)))/line.unrounded_taxable_amt*100, 20)
                                                )
                                         ),
                                 line.tax_rate),
                     line.tax_rate ) tax_rate,

                     decode ( NVL(rate.ALLOW_ADHOC_TAX_RATE_FLAG, 'N'),
                     'N', decode ( line.tax_rate, 0,  line.taxable_basis_formula, 'PRORATED_TB' ),
                     'Y', decode ( NVL(rate.ADJ_FOR_ADHOC_AMT_CODE, 'TAXABLE_BASIS'),
                          'TAXABLE_BASIS', decode(line.tax_rate, 0, line.taxable_basis_formula, 'PRORATED_TB'),
                          line.taxable_basis_formula),
                     line.taxable_basis_formula ) taxable_basis_formula

              from zx_rates_b rate
              where line.tax_rate_id = rate.tax_rate_id
           )

    WHERE  line.application_id = l_application_id_tbl(i)
       AND line.event_class_code = l_event_class_code_tbl(i)
       AND line.entity_code = l_entity_code_tbl(i)
       AND line.trx_id = l_trx_id_tbl(i)
       AND line.self_assessed_flag <> 'Y'
       AND line.offset_link_to_tax_line_id IS NULL
       AND line.offset_flag <> 'Y'
       AND line.mrc_tax_line_flag = 'N'
       AND NVL(cancel_flag,'N') <> 'Y';

    EXIT WHEN get_total_trx_tax_amt_csr%NOTFOUND;
  END LOOP;

  CLOSE get_total_trx_tax_amt_csr;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_hdr',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_hdr.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.' ||
                   'process_taxes_for_xml_inv_hdr(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF get_total_trx_tax_amt_csr%ISOPEN THEN
       CLOSE get_total_trx_tax_amt_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_hdr',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_hdr.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.process_taxes_for_xml_inv_hdr(-)');
    END IF;

END process_taxes_for_xml_inv_hdr;

/*=========================================================================*
 | This procedure is used to adjust tax lines for XML invoices             |
 |   with header level control tax amount.                                 |
 *=========================================================================*/
PROCEDURE adjust_tax_for_xml_inv_line (
  ---p_event_class_rec        IN 	        zx_api_pub.event_class_rec_type,
  x_return_status          OUT NOCOPY   VARCHAR2) IS

 CURSOR get_total_line_tax_amt_csr IS
 SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
        SUM(tax_amt),
        MAX(tax_amt),
        application_id,
        event_class_code,
        entity_code,
        trx_id,
        trx_line_id,
        trx_level_type,
        ctrl_total_line_tx_amt
   FROM zx_detail_tax_lines_gt
  WHERE
     -- commented out for bug fix 5417887
     --     trx_id = p_event_class_rec.trx_id
     -- AND application_id = p_event_class_rec.application_id
     -- AND event_class_code = p_event_class_rec.event_class_code
     -- AND entity_code = p_event_class_rec.entity_code
     -- AND
        ctrl_total_line_tx_amt IS NOT NULL
    AND self_assessed_flag <> 'Y'
    AND offset_flag <> 'Y'
    AND offset_link_to_tax_line_id IS NULL
    AND mrc_tax_line_flag = 'N'
    AND NVL(cancel_flag,'N') <> 'Y'
    GROUP BY application_id,
             event_class_code,
             entity_code,
             trx_id,
             trx_line_id,
             trx_level_type,
             ctrl_total_line_tx_amt
    HAVING SUM(tax_amt) <> ctrl_total_line_tx_amt;


 TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE var_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

 l_trx_line_id_tbl		num_tbl_type;
 l_trx_level_type_tbl		var_tbl_type;
 l_total_line_tx_amt_tbl	num_tbl_type;
 l_max_tax_amt_tbl		num_tbl_type;
 l_ctrl_total_line_tx_amt_tbl   num_tbl_type;

 l_trx_line_id_diff_tbl         num_tbl_type;
 l_trx_level_type_diff_tbl	var_tbl_type;
 l_max_tax_amt_diff_tbl		num_tbl_type;
 l_rounding_diff_tbl 		num_tbl_type;

 l_application_id_tbl           num_tbl_type;
 l_event_class_code_tbl  var_tbl_type;
 l_entity_code_tbl       var_tbl_type;
 l_trx_id_tbl     num_tbl_type;

 l_index			NUMBER;

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_line.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_line(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_index := 0;

  -- open cursor  get_total_line_tax_amt_csr
  --
  OPEN  get_total_line_tax_amt_csr;
  FETCH get_total_line_tax_amt_csr BULK COLLECT INTO
          l_total_line_tx_amt_tbl,
          l_max_tax_amt_tbl,
	  l_application_id_tbl,
	  l_event_class_code_tbl,
	  l_entity_code_tbl,
	  l_trx_id_tbl,
          l_trx_line_id_tbl,
          l_trx_level_type_tbl,
	  l_ctrl_total_line_tx_amt_tbl;
  CLOSE get_total_line_tax_amt_csr;


  FORALL i IN l_trx_line_id_tbl.FIRST ..l_trx_line_id_tbl.LAST

    -- adjust tax amount of the detail tax line with the maximum tax amount.
    --
    UPDATE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
           zx_detail_tax_lines_gt
       SET tax_amt = tax_amt + l_ctrl_total_line_tx_amt_tbl(i) - l_total_line_tx_amt_tbl(i)
           --sync_with_prvdr_flag = DECODE(tax_provider_id, NULL, 'N', 'Y') -- this should have already been set during proration
     WHERE application_id = l_application_id_tbl(i)
       AND event_class_code = l_event_class_code_tbl(i)
       AND entity_code = l_entity_code_tbl(i)
       AND trx_id = l_trx_id_tbl(i)
       AND trx_line_id = l_trx_line_id_tbl(i)
       AND trx_level_type = l_trx_level_type_tbl(i)
       AND ctrl_total_line_tx_amt IS NOT NULL
       AND self_assessed_flag <> 'Y'
       AND offset_link_to_tax_line_id IS NULL
       AND offset_flag <> 'Y'
       AND mrc_tax_line_flag = 'N'
       AND tax_amt = l_max_tax_amt_tbl(i)
       AND NVL(cancel_flag,'N') <> 'Y'
       AND rownum = 1;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_line',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_line.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.' ||
                   'adjust_tax_for_xml_inv_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF get_total_line_tax_amt_csr%ISOPEN THEN
       CLOSE get_total_line_tax_amt_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_line',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_line.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_line(-)');
    END IF;

END adjust_tax_for_xml_inv_line;

/*=========================================================================*
 | This procedure contains the code for adjusting tax lines for XML        |
 |   invoices with header level control tax amount.                        |
 *=========================================================================*/
PROCEDURE adjust_tax_for_xml_inv_hdr (
  --p_event_class_rec        IN 	        zx_api_pub.event_class_rec_type,
  x_return_status          OUT NOCOPY   VARCHAR2) IS

 CURSOR get_total_trx_tax_amt_csr IS
 SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
        SUM(tax_line.tax_amt),
        MAX(tax_line.tax_amt),
        tax_line.application_id,
        tax_line.event_class_code,
        tax_line.entity_code,
        tax_line.trx_id,
        trx_line.ctrl_total_hdr_tx_amt
   FROM zx_detail_tax_lines_gt tax_line,
        zx_lines_det_factors trx_line
  WHERE tax_line.application_id = trx_line.application_id
    AND tax_line.event_class_code = trx_line.event_class_code
    AND tax_line.entity_code = trx_line.entity_code
    AND tax_line.trx_id = trx_line.trx_id
--  bugfix 5599951
    AND tax_line.trx_line_id = trx_line.trx_line_id
    AND tax_line.trx_level_type = trx_line.trx_level_type
    AND tax_line.self_assessed_flag <> 'Y'
    AND tax_line.offset_flag <> 'Y'
    AND tax_line.offset_link_to_tax_line_id IS NULL
    AND tax_line.mrc_tax_line_flag = 'N'
    AND trx_line.ctrl_total_hdr_tx_amt IS NOT NULL
    AND NVL(cancel_flag,'N') <> 'Y'
  GROUP BY tax_line.application_id,
           tax_line.event_class_code,
           tax_line.entity_code,
           tax_line.trx_id,
           trx_line.ctrl_total_hdr_tx_amt
  HAVING SUM(tax_line.tax_amt) <> trx_line.ctrl_total_hdr_tx_amt;

 TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE var_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

 l_total_trx_tax_amt_tbl     num_tbl_type;
 l_max_tax_amt_tbl           num_tbl_type;
 l_ctrl_total_hdr_tx_amt_tbl num_tbl_type;
 l_application_id_tbl           num_tbl_type;
 l_event_class_code_tbl  var_tbl_type;
 l_entity_code_tbl       var_tbl_type;
 l_trx_id_tbl     num_tbl_type;

BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_hdr.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_hdr(+)');
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- get l_total_trx_tax_amt for all tax lines of this transaction
  --
  OPEN  get_total_trx_tax_amt_csr ;
  FETCH get_total_trx_tax_amt_csr BULK COLLECT INTO
          l_total_trx_tax_amt_tbl,
          l_max_tax_amt_tbl,
          l_application_id_tbl,
          l_event_class_code_tbl,
          l_entity_code_tbl,
          l_trx_id_tbl,
          l_ctrl_total_hdr_tx_amt_tbl;
  CLOSE get_total_trx_tax_amt_csr;

  -- adjust tax amount of the detail tax line with the maximum tax amount.
  --
  FORALL i IN l_trx_id_tbl.FIRST ..l_trx_id_tbl.LAST
    UPDATE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
           zx_detail_tax_lines_gt
       SET tax_amt = tax_amt + l_ctrl_total_hdr_tx_amt_tbl(i) - l_total_trx_tax_amt_tbl(i)
           --sync_with_prvdr_flag = DECODE(tax_provider_id, NULL, 'N', 'Y') -- this should have already been set during process proration
     WHERE application_id = l_application_id_tbl(i)
       AND event_class_code = l_event_class_code_tbl(i)
       AND entity_code = l_entity_code_tbl(i)
       AND trx_id = l_trx_id_tbl(i)
       AND self_assessed_flag <> 'Y'
       AND offset_link_to_tax_line_id IS NULL
       AND offset_flag <> 'Y'
       AND mrc_tax_line_flag = 'N'
       AND tax_amt = l_max_tax_amt_tbl(i)
       AND NVL(cancel_flag,'N') <> 'Y'
       AND rownum = 1;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_hdr',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_hdr.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.' ||
                   'adjust_tax_for_xml_inv_hdr(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF get_total_trx_tax_amt_csr%ISOPEN THEN
       CLOSE get_total_trx_tax_amt_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_hdr',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_hdr.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.adjust_tax_for_xml_inv_hdr(-)');
    END IF;

END adjust_tax_for_xml_inv_hdr;

/* ======================================================================*
 |  PROCEDURE match_tax_amt_to_summary_line is used to adjust tax        |
 |    amounts  to make sure that the total tax amount matches that of    |
 |    the summary line, including manual summary tax line or summary     |
 |    tax line with last_manual_entry = 'TAX_AMOUNT'.                    |
 |                                                                       |
 * ======================================================================*/
PROCEDURE  match_tax_amt_to_summary_line (
  p_event_class_rec	  IN  OUT NOCOPY  zx_api_pub.event_class_rec_type,
  x_return_status  	  OUT NOCOPY      VARCHAR2) IS

CURSOR  get_sum_tax_lines_for_adj_csr IS
 SELECT tax_amt, summary_tax_line_id
   FROM zx_lines_summary
  WHERE application_id = p_event_class_rec.application_id
    AND entity_code = p_event_class_rec.entity_code
    AND event_class_code = p_event_class_rec.event_class_code
    AND trx_id = p_event_class_rec.trx_id
    AND last_manual_entry = 'TAX_AMOUNT'  -- manual or overridden sum tax line
    AND adjust_tax_amt_flag = 'Y'
    AND nvl(cancel_flag,'N') <> 'Y'
    AND nvl(self_assessed_flag,'N') <> 'Y'
    AND tax_provider_id IS NULL;

 CURSOR  get_det_tax_lines_sum_amt_csr(p_summary_tax_line_id 	NUMBER) IS
  SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
         SUM(tax_amt), MAX(tax_amt)
    FROM zx_detail_tax_lines_gt
   WHERE application_id = p_event_class_rec.application_id
     AND entity_code = p_event_class_rec.entity_code
     AND event_class_code = p_event_class_rec.event_class_code
     AND trx_id = p_event_class_rec.trx_id
     AND summary_tax_line_id = p_summary_tax_line_id;

 TYPE l_num_tbl_type IS TABLE OF NUMBER INDEX by BINARY_INTEGER;
 l_summary_tax_line_id_tbl 	l_num_tbl_type;
 l_max_tax_amt_tbl	 	l_num_tbl_type;
 l_rounding_diff_tbl 		l_num_tbl_type;

 l_sum_detail_tax_amt		NUMBER;
 l_max_tax_amt			NUMBER;
 l_rounding_diff 		NUMBER;
 l_tbl_index			BINARY_INTEGER;

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.match_tax_amt_to_summary_line.BEGIN',
           'ZX_TDS_CALC_SERVICES_PUB_PKG.match_tax_amt_to_summary_line(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_tbl_index := 0;

  FOR sum_tax_rec IN get_sum_tax_lines_for_adj_csr LOOP

    OPEN  get_det_tax_lines_sum_amt_csr(sum_tax_rec.summary_tax_line_id);
    FETCH get_det_tax_lines_sum_amt_csr INTO l_sum_detail_tax_amt, l_max_tax_amt;
    CLOSE get_det_tax_lines_sum_amt_csr;

    IF l_sum_detail_tax_amt IS NOT NULL THEN

      l_rounding_diff := sum_tax_rec.tax_amt - l_sum_detail_tax_amt;

      IF l_rounding_diff <> 0 THEN
        l_tbl_index := l_tbl_index + 1;
        l_summary_tax_line_id_tbl(l_tbl_index) := sum_tax_rec.summary_tax_line_id;
        l_max_tax_amt_tbl(l_tbl_index) := l_max_tax_amt;
        l_rounding_diff_tbl(l_tbl_index) := l_rounding_diff;
      END IF;
    END IF;
  END LOOP;

  IF l_summary_tax_line_id_tbl.COUNT > 0 THEN

    -- adjust tax amount of the detail tax line with the maximum tax amount.
    --
    FORALL i IN l_summary_tax_line_id_tbl.FIRST .. l_summary_tax_line_id_tbl.LAST

      UPDATE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
             zx_detail_tax_lines_gt
         SET tax_amt = tax_amt + l_rounding_diff_tbl(i)
       WHERE trx_id = p_event_class_rec.trx_id
         AND application_id = p_event_class_rec.application_id
         AND event_class_code = p_event_class_rec.event_class_code
         AND entity_code = p_event_class_rec.entity_code
         AND summary_tax_line_id = l_summary_tax_line_id_tbl(i)
         AND tax_amt = l_max_tax_amt_tbl(i)
         AND rownum = 1;

  END IF;    -- l_summary_tax_line_id_tbl.COUNT > 0

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.match_tax_amt_to_summary_line',
           'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.match_tax_amt_to_summary_line.END',
           'ZX_TDS_CALC_SERVICES_PUB_PKG.' ||
           'match_tax_amt_to_summary_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.match_tax_amt_to_summary_line',
              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.match_tax_amt_to_summary_line.END',
             'ZX_TDS_CALC_SERVICES_PUB_PKG.match_tax_amt_to_summary_line(-)');
    END IF;

END match_tax_amt_to_summary_line;

/* ======================================================================*
 |  PROCEDURE init_for_session is used to initialize the Global          |
 |  Structures / Global Temp Tables owned by TDM at session level.       |
 * ======================================================================*/
PROCEDURE init_for_session (
  x_return_status          OUT NOCOPY    VARCHAR2 ) IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_session.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_session(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- init gt tables
  DELETE FROM ZX_DETAIL_TAX_LINES_GT;

  -- added the following initializations for bug fix 5417887
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_line_tx_amt_flg := 'N';
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_hdr_tx_amt_flg := 'N';

  --bug 7537542
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_cancel_exist_flg := 'N';
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_discard_exist_flg := 'N';
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_nochange_exist_flg := 'N';
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_copy_and_create_flg := 'N';
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_reference_doc_exist_flg := 'N';
  --bug 7537542

  --Bug 8736358
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_update_exist_flg := 'N';

  ZX_GLOBAL_STRUCTURES_PKG.g_credit_memo_exists_flg := 'N';
  ZX_GLOBAL_STRUCTURES_PKG.g_update_event_process_flag := 'N';
  ZX_GLOBAL_STRUCTURES_PKG.g_bulk_process_flag := 'N';
  ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl.DELETE;
  ZX_GLOBAL_STRUCTURES_PKG.lte_trx_tbl.DELETE;


  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.DELETE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_check_cond_grp_tbl.DELETE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl.DELETE;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl.DELETE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl.DELETE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_trx_alphanum_value_tbl.DELETE;

  ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl.DELETE;
  ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl.DELETE;
  ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl.DELETE;
  ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl.DELETE;
  ZX_TRD_INTERNAL_SERVICES_PVT.g_tax_recovery_info_tbl.DELETE;
  ZX_TDS_TAX_ROUNDING_PKG.g_currency_tbl.DELETE;
  ZX_TDS_TAX_ROUNDING_PKG.g_tax_curr_conv_rate_tbl.DELETE;

  ZX_TDS_RULE_BASE_DETM_PVT.g_determining_factor_class_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_determining_factor_cq_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_data_type_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_determining_factor_code_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_tax_parameter_code_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_operator_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_numeric_value_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_date_value_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_alphanum_value_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_value_low_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_value_high_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_segment_array.DELETE;
  ZX_TPI_SERVICES_PKG.tax_regime_tmp_tbl.DELETE;

  --bug8251315
  ZX_GLOBAL_STRUCTURES_PKG.g_hz_zone_tbl.DELETE;
  --bug#8551677
  --bug#9469868
  --ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl.DELETE;

  ZX_TDS_TAX_ROUNDING_PKG.g_euro_code := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_max_tax_line_number := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_trx_lines_counter := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_rnd_lvl_party_tax_prof_id := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_lvl_party_type := NULL;

  -- added for bug 5684123
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_overridden_tax_ln_exist_flg := 'N';

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_session',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_session.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_session(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_session',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_session.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_session(-)');
    END IF;

END init_for_session;

/* ======================================================================*
 |  PROCEDURE init_for_header is used to initialize the Global           |
 |  Structures / Global Temp Tables owned by TDM at header level.        |
 * ======================================================================*/
PROCEDURE init_for_header (
  p_event_class_rec        IN            ZX_API_PUB.event_class_rec_type,
  x_return_status          OUT NOCOPY    VARCHAR2 ) IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_header.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_header(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- comment out the following init for bug fix 5417887
  -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.DELETE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_check_cond_grp_tbl.DELETE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl.DELETE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl.DELETE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_trx_alphanum_value_tbl.DELETE;

  ZX_TDS_RULE_BASE_DETM_PVT.g_determining_factor_class_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_determining_factor_cq_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_data_type_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_determining_factor_code_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_tax_parameter_code_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_operator_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_numeric_value_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_date_value_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_alphanum_value_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_value_low_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_value_high_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_segment_array.DELETE;

  --bug 7444373
  ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl.DELETE;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_max_tax_line_number := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_trx_lines_counter := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule  := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_rnd_lvl_party_tax_prof_id := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_lvl_party_type := NULL;
  -- bug7537542
/*
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_cancel_exist_flg := 'N';
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_discard_exist_flg := 'N';
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_nochange_exist_flg := 'N';
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_copy_and_create_flg := 'N';
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_reference_doc_exist_flg := 'N';
*/
  ZX_TRD_INTERNAL_SERVICES_PVT.g_tax_recovery_info_tbl.DELETE;

  --Bug 7519403--
  ZX_SRVC_TYP_PKG.l_line_level_tbl.DELETE;

  --
  -- init msg record to be passed back to TSRM
  --
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.application_id :=
              p_event_class_rec.application_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.entity_code :=
              p_event_class_rec.entity_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.event_class_code :=
              p_event_class_rec.event_class_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_id :=
              p_event_class_rec.trx_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.summary_tax_line_number :=
              NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.tax_line_id := NULL;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_dist_id := NULL;

  -- bugfix 5024740: initialize zx_jurisdictions_gt

  delete from zx_jurisdictions_gt;

  -- Bug#9233549
  ZX_R11I_TAX_PARTNER_PKG.FLUSH_TABLE_INFORMATION();

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_header',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_header.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_header(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_header',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_header.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_header(-)');
    END IF;

END init_for_header;

/* ======================================================================*
 |  PROCEDURE init_for_line is used to initialize the Global             |
 |  Structures / Global Temp Tables owned by TDM at line level.          |
 * ======================================================================*/
PROCEDURE init_for_line (
  p_event_class_rec        IN            ZX_API_PUB.event_class_rec_type,
  x_return_status          OUT NOCOPY    VARCHAR2 ) IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_line.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_line(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_check_cond_grp_tbl.DELETE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl.DELETE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl.DELETE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_trx_alphanum_value_tbl.DELETE;

  ZX_TDS_RULE_BASE_DETM_PVT.g_determining_factor_class_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_determining_factor_cq_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_data_type_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_determining_factor_code_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_tax_parameter_code_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_operator_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_numeric_value_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_date_value_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_alphanum_value_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_value_low_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_value_high_tbl.DELETE;
  ZX_TDS_RULE_BASE_DETM_PVT.g_segment_array.DELETE;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_max_tax_line_number := NULL;

  -- bugfix 5024740: initialize zx_jurisdictions_gt

  delete from zx_jurisdictions_gt;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_line',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_line.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_line',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_line.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_line(-)');
    END IF;

END init_for_line;

/* ======================================================================*
 |  PROCEDURE init_for_tax_line is used to initialize the Global         |
 |  Structures / Global Temp Tables owned by TDM at tax line level.      |
 * ======================================================================*/
PROCEDURE init_for_tax_line (
  p_event_class_rec        IN            ZX_API_PUB.event_class_rec_type,
  x_return_status          OUT NOCOPY    VARCHAR2 ) IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_line.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_line(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  ZX_TDS_RULE_BASE_DETM_PVT.g_segment_array.DELETE;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_line',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_line.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_line',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_line.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_line(-)');
    END IF;

END init_for_tax_line;

/* ======================================================================*
 |  PROCEDURE init_for_tax_dist is used to initialize the Global         |
 |  Structures/Global Temp Tables owned by TDM at tax distribution level.|
 * ======================================================================*/
PROCEDURE init_for_tax_dist (
  p_event_class_rec        IN            ZX_API_PUB.event_class_rec_type,
  x_return_status          OUT NOCOPY    VARCHAR2 ) IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_dist.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_dist(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- init gt tables
  DELETE FROM ZX_REC_NREC_DIST_GT;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_dist',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_dist.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_dist(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_dist',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_dist.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_dist(-)');
    END IF;

END init_for_tax_dist;


/* ======================================================================*
 |  PROCEDURE initialize is used to initialize the Global                |
 |  Structures / Global Temp Tables owned by TDM                         |
 * ======================================================================*/
PROCEDURE initialize (
  p_event_class_rec        IN ZX_API_PUB.event_class_rec_type,
  p_init_level             IN VARCHAR2,
  x_return_status          OUT NOCOPY    VARCHAR2 ) IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize(+)');
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                   'p_init_level = ' || p_init_level);
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF p_init_level = 'SESSION' THEN

    init_for_session( x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_session()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize.END',
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize(-)');
      END IF;
      RETURN;
    END IF;

  ELSIF p_init_level = 'HEADER' THEN

    init_for_header( p_event_class_rec,
		     x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_header()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize.END',
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize(-)');
      END IF;
      RETURN;
    END IF;
  ELSIF p_init_level = 'LINE' THEN

    init_for_line( p_event_class_rec,
		   x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_line()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize.END',
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize(-)');
     END IF;
     RETURN;
    END IF;

  ELSIF p_init_level = 'TAX_LINE' THEN

    init_for_tax_line( p_event_class_rec,
			x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_line()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize.END',
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize(-)');
      END IF;
      RETURN;
    END IF;

  ELSIF p_init_level = 'TAX_DISTRIBUTION' THEN

    init_for_tax_dist ( p_event_class_rec,
			x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.init_for_tax_dist()');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize.END',
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize(-)');
      END IF;
      RETURN;
    END IF;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.initialize.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize(-)');
    END IF;

END initialize;

PROCEDURE get_process_for_appl_flg (
  p_tax_prof_id    IN         NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2 )
IS
 CURSOR  get_process_for_appl_flg IS
 SELECT  process_for_applicability_flag
   FROM  zx_party_tax_profile
  WHERE  party_tax_profile_id = p_tax_prof_id;

 l_process_for_appl_flg  zx_party_tax_profile.process_for_applicability_flag%TYPE;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_process_for_appl_flg.BEGIN',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.get_process_for_appl_flg(+)');
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_process_for_appl_flg',
                   'p_tax_prof_id = ' || p_tax_prof_id);
    FND_LOG.STRING(g_level_procedure,'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_process_for_appl_flg',
            'ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg set for supplier site is ' ||ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg);
  END IF;


  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- Check if the tax calculation level from the party site is 'None'
  -- If it is 'None', skip the processing taxes for this transaction
  -- line get_process_for_appl_flg
  -- If the variable ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg was set
  -- for the supplier site within the rounding package then do not get the
  -- process for applicability flag for the rounding party tax profile. Added
  -- the if ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg IS NULL condition
  -- for this. Bug 7005483
  IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg IS NULL THEN
    IF p_tax_prof_id IS NOT NULL THEN
      --Introducing caching logic..
      IF l_tax_prof_id_tbl.EXISTS(p_tax_prof_id)
         AND l_tax_prof_id_tbl(p_tax_prof_id).tax_prof_id = p_tax_prof_id THEN
           l_process_for_appl_flg := l_tax_prof_id_tbl(p_tax_prof_id).process_for_appl_flg;
      ELSE
        OPEN  get_process_for_appl_flg;
        FETCH get_process_for_appl_flg INTO l_process_for_appl_flg;
        CLOSE get_process_for_appl_flg;

        l_tax_prof_id_tbl(p_tax_prof_id).tax_prof_id := p_tax_prof_id;
        l_tax_prof_id_tbl(p_tax_prof_id).process_for_appl_flg := l_process_for_appl_flg;
      END IF;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg := l_process_for_appl_flg;
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_process_for_appl_flg.END',
                   'ZX_TDS_CALC_SERVICES_PUB_PKG.get_process_for_appl_flg(-)'||'process for appl flag' ||g_process_for_appl_flg);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_process_for_appl_flg',
                      'No data found: p_tax_prof_id: '||p_tax_prof_id);
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_process_for_appl_flg',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_process_for_appl_flg.END',
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.get_process_for_appl_flg(-)');
    END IF;

END get_process_for_appl_flg;

-----------------------------------------------------------------------
--  PUBLIC FUNCTION
--    get_rep_code_id
--
--  DESCRIPTION
--    To populate the Reporting Code id defined at Rule level
--    for every result id.
--
--  CALLED BY
--    calculate_tax
-----------------------------------------------------------------------
FUNCTION get_rep_code_id (
    p_result_id  IN ZX_PROCESS_RESULTS.RESULT_ID%TYPE,
    p_date                 IN ZX_LINES.TRX_DATE%TYPE) RETURN ZX_REPORTING_CODES_B.REPORTING_CODE_ID%TYPE IS
 l_api_name             CONSTANT VARCHAR2(30):= 'GET_REP_CODE_ID';
 l_reporting_code_id    ZX_REPORTING_CODES_B.REPORTING_CODE_ID%type;
 l_date                 ZX_LINES.TRX_DATE%TYPE;
BEGIN

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id.BEGIN',
         'ZX_SRVC_TYP_PKG: GET_REP_CODE_ID()+');
  END IF;

  IF p_result_id is NOT NULL  THEN
    IF  NOT ZX_TDS_CALC_SERVICES_PUB_PKG.g_zx_rep_code_tbl.EXISTS(p_result_id) THEN
     BEGIN
       l_date:= nvl(p_date,sysdate);

       SELECT assoc.reporting_code_id
         INTO l_reporting_code_id
         FROM zx_reporting_types_b types,
              zx_report_codes_assoc assoc
        WHERE types.legal_message_flag = 'Y'
          AND assoc.entity_code = 'ZX_PROCESS_RESULTS'
          AND assoc.entity_id = p_result_id
          AND assoc.reporting_type_id = types.reporting_type_id
          AND l_date BETWEEN assoc.effective_from AND NVL(assoc.effective_to, l_date);

      EXCEPTION
        WHEN OTHERS THEN
            l_reporting_code_id := NULL;
            IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id',
                  'No Reporting Code defined for Process result id for' || to_char(p_result_id) || ' : ' ||SQLERRM);
            END IF;
      END;
      zx_tds_calc_services_pub_pkg.g_zx_rep_code_tbl(p_result_id).result_id  := p_result_id;
      zx_tds_calc_services_pub_pkg.g_zx_rep_code_tbl(p_result_id).reporting_code_id := l_reporting_code_id;
    END IF;
    l_reporting_code_id := zx_tds_calc_services_pub_pkg.g_zx_rep_code_tbl(p_result_id).reporting_code_id;
  ELSE
    l_reporting_code_id := NULL;
  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id',
         ' result_id: '||to_char(p_result_id) || ' :  reporting_code_id : '||to_char(l_reporting_code_id));
      FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id.END',
         'ZX_SRVC_TYP_PKG: GET_REP_CODE_ID()-');
  END IF;
  RETURN l_reporting_code_id;
 EXCEPTION
        WHEN OTHERS THEN
            IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id',
                  'Error occurred in ' || l_api_name || ' : ' ||SQLERRM);
            END IF;
        l_reporting_code_id := NULL;
        RETURN l_reporting_code_id;
 END get_rep_code_id;


/* ======================================================================*
 |  CONSTRUCTOR                                                          |
 * ======================================================================*/
BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.constructor.BEGIN',
                  'ZX_TDS_CALC_SERVICES_PUB_PKG.constructor(+)');

  END IF;

  initialize;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
   FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_CALC_SERVICES_PUB_PKG.constructor.END',
                  'ZX_TDS_CALC_SERVICES_PUB_PKG.constructor(-)');
  END IF;

END ZX_TDS_CALC_SERVICES_PUB_PKG ;

/
