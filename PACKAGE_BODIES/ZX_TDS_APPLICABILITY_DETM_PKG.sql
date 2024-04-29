--------------------------------------------------------
--  DDL for Package Body ZX_TDS_APPLICABILITY_DETM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_APPLICABILITY_DETM_PKG" AS
 /* $Header: zxditaxapplipkgb.pls 120.260.12010000.44 2010/09/09 09:22:46 prigovin ship $ */

PROCEDURE rule_base_pos_detm(
 p_tax_id                   IN            zx_taxes_b.tax_id%TYPE,
 p_tax_determine_date       IN            DATE,
 p_tax_service_type_code    IN            zx_rules_b.service_type_code%TYPE,
 p_event_class_rec          IN            zx_api_pub.event_class_rec_type,
 p_trx_line_index           IN            BINARY_INTEGER,
 x_alphanumeric_result         OUT NOCOPY VARCHAR2,
 x_result_id                   OUT NOCOPY NUMBER,
 x_return_status               OUT NOCOPY VARCHAR2);

PROCEDURE add_tax_regime(
 p_tax_regime_precedence    IN            zx_regimes_b.regime_precedence%TYPE,
 p_tax_regime_id            IN            zx_regimes_b.tax_regime_id%TYPE,
 p_tax_regime_code          IN            zx_regimes_b.tax_regime_code%TYPE,
 p_parent_regime_code       IN            zx_regimes_b.parent_regime_code%TYPE,
 p_country_code             IN            zx_regimes_b.country_code%TYPE,
 p_geography_type           IN            zx_regimes_b.geography_type%TYPE,
 p_geography_id             IN            zx_regimes_b.geography_id%TYPE,
 p_effective_from           IN            zx_regimes_b.effective_from%TYPE,
 p_effective_to             IN            zx_regimes_b.effective_to%TYPE,
 x_return_status               OUT NOCOPY VARCHAR2);

FUNCTION is_tax_applicable(
 p_tax_id                   IN            zx_taxes_b.tax_id%TYPE,
 p_tax_determine_date       IN            DATE,
 p_applicability_rule_flag  IN            zx_taxes_b.applicability_rule_flag%TYPE,
 p_event_class_rec          IN            zx_api_pub.event_class_rec_type,
 p_trx_line_index           IN            BINARY_INTEGER,
 p_applicable_by_default_flag  IN         zx_taxes_b.applicable_by_default_flag%TYPE,
 x_applicability_result        OUT NOCOPY VARCHAR2,
 x_applicability_result_id     OUT NOCOPY NUMBER,
 x_return_status               OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

FUNCTION is_direct_rate_applicable(
 p_tax_id                   IN            zx_taxes_b.tax_id%TYPE,
 p_tax_determine_date       IN            DATE,
 p_event_class_rec          IN            zx_api_pub.event_class_rec_type,
 p_trx_line_index           IN            BINARY_INTEGER,
 x_direct_rate_result_rec      OUT NOCOPY zx_process_results%ROWTYPE,
 x_direct_rate_result_id       OUT NOCOPY NUMBER,
 x_return_status               OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

PROCEDURE populate_registration_info(
 p_event_class_rec     IN            zx_api_pub.event_class_rec_type,
 p_trx_line_index      IN            NUMBER,
 p_rownum              IN            NUMBER,
 p_def_reg_type        IN            zx_taxes_b.def_registr_party_type_code%TYPE,
 p_reg_rule_flg        IN            zx_taxes_b.registration_type_rule_flag%TYPE,
 p_tax_determine_date  IN            DATE,
 x_return_status          OUT NOCOPY VARCHAR2);

-- Added for bug 4959835
PROCEDURE handle_update_scenarios(
 p_trx_line_index     IN            BINARY_INTEGER,
 p_event_class_rec    IN            zx_api_pub.event_class_rec_type,
 p_row_num                        IN                    NUMBER,
 p_tax_regime_code        IN                    zx_regimes_b.tax_regime_code%TYPE,
 p_tax                            IN                    zx_taxes_b.tax%TYPE,
 p_tax_date           IN            DATE,
 p_tax_determine_date IN            DATE,
 p_tax_point_date     IN            DATE,
 x_self_assessed_flag    OUT NOCOPY     zx_lines.self_assessed_flag%TYPE,
 x_tax_amt_included_flag OUT NOCOPY zx_lines.tax_amt_included_flag%TYPE,
 x_tax_jurisdiction_id   OUT NOCOPY zx_lines.tax_jurisdiction_id%TYPE,
 x_tax_jurisdiction_code OUT NOCOPY zx_lines.tax_jurisdiction_code%TYPE,
 x_return_status             OUT NOCOPY VARCHAR2);

 PROCEDURE enforce_tax_from_ref_doc(
  p_begin_index     IN            BINARY_INTEGER,
  p_end_index       IN            BINARY_INTEGER,
  p_trx_line_index  IN            BINARY_INTEGER,
  x_return_status          OUT NOCOPY VARCHAR2);

-- End: Bug 4959835

 g_current_runtime_level      NUMBER;
 g_level_statement            CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
 g_level_procedure            CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
 g_level_event                CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT;
 g_level_error                CONSTANT NUMBER   := FND_LOG.LEVEL_ERROR;
 g_level_unexpected           CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

 -- cache the most inner and outer jurisdiction
 g_inner_jurisdiction_code    ZX_JURISDICTIONS_B.tax_jurisdiction_code%TYPE;
 g_inner_jurisdiction_id      ZX_JURISDICTIONS_B.tax_jurisdiction_id%TYPE;
 g_outer_jurisdiction_code    ZX_JURISDICTIONS_B.tax_jurisdiction_code%TYPE;
 g_outer_jurisdiction_id      ZX_JURISDICTIONS_B.tax_jurisdiction_id%TYPE;

 g_trx_line_id       ZX_LINES.trx_line_id%TYPE;

-------------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_tax_date
--
--  DESCRIPTION
-- This procedure is used to determine the tax determination date.
-- Tax determination date will be used to check the validity of all entities
-- used in tax determination which have start and end dates such as rates,
-- rules etc.

-- This procedure will support deriving the tax point date and tax exchange
-- rate date in later phases.
-------------------------------------------------------------------------------

PROCEDURE get_tax_date
     (p_trx_line_index        IN             BINARY_INTEGER,
      x_tax_date                 OUT NOCOPY  DATE,
      x_tax_determine_date       OUT NOCOPY  DATE,
      x_tax_point_date           OUT NOCOPY  DATE,
      x_return_status            OUT NOCOPY  VARCHAR2) IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date.BEGIN',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_tax_date :=
    NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_date(p_trx_line_index),
     NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.provnl_tax_determination_date(p_trx_line_index),
      NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_date(p_trx_line_index),
       NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_date(p_trx_line_index),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_date(p_trx_line_index)))));

  x_tax_determine_date :=
    NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_date(p_trx_line_index),
     NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.provnl_tax_determination_date(p_trx_line_index),
      NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_date(p_trx_line_index),
       NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_date(p_trx_line_index),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_date(p_trx_line_index)))));
  x_tax_point_date :=
    NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_date(p_trx_line_index),
     NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.provnl_tax_determination_date(p_trx_line_index),
      NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_date(p_trx_line_index),
       NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_date(p_trx_line_index),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_date(p_trx_line_index)))));

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date(-)',
                   'Tax date = ' || to_char(x_tax_date, 'DD-MON-YY')||'Tax determine date = ' || to_char(x_tax_determine_date, 'DD-MON-YY')||'Tax point date = ' || to_char(x_tax_point_date, 'DD-MON-YY'));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_tax_date := NULL;
    x_tax_determine_date := NULL;
    x_tax_point_date := NULL;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date(-)');
    END IF;

END get_tax_date;

----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_applicable_regimes
--
--  DESCRIPTION
--
--  This procedure returns applicable tax regimes for each transaction line
--  and also unique tax regimes for whole transaction
--
--  IN     p_event_class_rec
--         p_event_rec
--  OUT NOCOPY    x_return_status
--
----------------------------------------------------------------------
PROCEDURE get_applicable_regimes (
  p_trx_line_index        IN          BINARY_INTEGER,
  p_event_class_rec       IN          zx_api_pub.event_class_rec_type,
  x_return_status         OUT NOCOPY  VARCHAR2) IS

 TYPE country_rec_type IS RECORD (
        country_code    zx_regimes_b.country_code%TYPE);
 TYPE geography_rec_type IS RECORD (
        geography_id            hz_geographies.geography_id%TYPE);

 TYPE country_tab_type IS TABLE OF country_rec_type INDEX BY VARCHAR2(2);
 TYPE geography_tab_type IS TABLE OF geography_rec_type INDEX BY BINARY_INTEGER;

 TYPE det_factor_code_tab_type IS TABLE OF
    zx_determining_factors_b.determining_factor_code%TYPE INDEX BY BINARY_INTEGER;
 TYPE det_factor_class_tab_type is TABLE of
   zx_determining_factors_b.Determining_Factor_Class_Code%TYPE INDEX BY BINARY_INTEGER;
 TYPE regime_det_level_tab_type IS TABLE OF
    zx_det_factor_templ_dtl.tax_regime_det_level_code%TYPE INDEX BY BINARY_INTEGER;

 l_location_id          NUMBER;
 l_country_code         zx_regimes_b.country_code%TYPE;
 l_country_idx          zx_regimes_b.country_code%TYPE;
 l_country_num          zx_regimes_b.country_code%TYPE;
 table_size             NUMBER;
 l_error_buffer         VARCHAR2(256);
 l_geography_id         NUMBER;
 l_msg_count            NUMBER;
 l_msg_data             VARCHAR2(2000);

 l_country_tab          country_tab_type;
 l_geography_tab        geography_tab_type;
 l_null_country_tab     country_tab_type;
 l_det_factor_code_tab  det_factor_code_tab_type;
 l_det_factor_class_tab det_factor_class_tab_type;
 l_regime_det_level_tab regime_det_level_tab_type;

 l_geo_num              NUMBER;
 l_index                NUMBER;
 l_new_row_num          NUMBER;
 l_structure_name       VARCHAR2(30);
 l_geography_name       VARCHAR2(360);
 l_location_type        VARCHAR2(30);
 l_null_country_loc_type   VARCHAR2(30);
 l_null_country_loc_id   NUMBER;

 b_location_found       BOOLEAN;

 l_location_list        VARCHAR2(1000); -- maximum is 13*30

 l_tax_date             DATE;
 l_tax_determine_date   DATE;
 l_tax_point_date       DATE;

 CURSOR get_det_factor_details_cur (
        p_reg_template_code    p_event_class_rec.det_factor_templ_code%TYPE) IS
    SELECT zxdtd.determining_factor_code,
           zxdtd.determining_factor_class_code,
           zxdtd.tax_regime_det_level_code
    FROM   zx_det_factor_templ_b zxdt,
           zx_det_factor_templ_dtl zxdtd
    WHERE  zxdtd.det_factor_templ_id = zxdt.det_factor_templ_id
      AND  zxdt.det_factor_templ_code = p_reg_template_code;

 -- Assuming the fact that taxes can be defined only for child regimes, fetch
 -- all regimes that have taxes defined for a given country p_country_code.
 -- the following cursor is assuming that tax_regime_precedence is available
 -- in zx_regimes_b
 --
 CURSOR get_tax_regime_info_cur(p_country_code varchar2,
                                p_tax_determine_date DATE) IS
   SELECT tax_regime_id,
          regime_precedence,
          tax_regime_code,
          parent_regime_code,
          country_code,
          geography_type,
          geography_id,
          effective_from,
          effective_to
     FROM ZX_REGIMES_B_V  r
    WHERE country_code = p_country_code
      AND (p_tax_determine_date >= effective_from AND
          (p_tax_determine_date <= effective_to OR effective_to IS NULL))
      AND EXISTS (SELECT /*+ no_unnest */ 1
                    FROM ZX_SCO_TAXES_B_V  t
                   WHERE t.tax_regime_code = r.tax_regime_code
                     AND t.live_for_processing_flag = 'Y'
                     AND t.live_for_applicability_flag = 'Y'
                     AND (p_tax_determine_date >= t.effective_from AND
                         (p_tax_determine_date <= t.effective_to OR t.effective_to IS NULL)))
 ORDER BY regime_precedence;

 CURSOR get_zone_level_regimes_cur(c_geography_id   NUMBER, c_date  Date) IS
   SELECT tax_regime_id,
          regime_precedence,
          tax_regime_code,
          parent_regime_code,
          country_code,
          geography_type,
          geography_id,
          effective_from,
          effective_to
     FROM ZX_REGIMES_B_V regime,
          hz_relationships relation
    WHERE relation.object_id = c_geography_id
      AND relation.object_type = 'COUNTRY'
      AND relation.subject_id = regime.geography_id
      AND relation.subject_type = regime.geography_type
      AND c_date >= relation.start_date
      AND (c_date <= relation.end_date OR relation.end_date IS NULL)
      AND (c_date >= regime.effective_from AND
          (c_date <= regime.effective_to OR regime.effective_to IS NULL))
      AND EXISTS (SELECT /*+ no_unnest */ 1
                    FROM ZX_SCO_TAXES_B_V  tax
                   WHERE tax.tax_regime_code = regime.tax_regime_code
                     AND tax.live_for_processing_flag = 'Y'
                     AND tax.live_for_applicability_flag = 'Y'
                     AND (c_date >= tax.effective_from AND
                         (c_date <= tax.effective_to OR tax.effective_to IS NULL)))
 ORDER BY regime.regime_precedence;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes.BEGIN',
                  'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  b_location_found := FALSE;
  table_size       := 2048;

  -- Validations
  IF p_event_class_rec.det_factor_templ_code IS NULL THEN

    IF (g_level_error >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                     'Event Class does not contain Regime Template');
    END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
     RETURN;
  END IF;

  -- Get information about all drivers correponding to the template code
  -- EVENT_CLASS_REC_TYPE structure contains only one record at any give time.
  --
  OPEN  get_det_factor_details_cur(p_event_class_rec.det_factor_templ_code);

  FETCH get_det_factor_details_cur
        BULK COLLECT INTO l_det_factor_code_tab,
                          l_det_factor_class_tab,
                          l_regime_det_level_tab;
  CLOSE get_det_factor_details_cur;

  -- Re-initialize the country table when beginning to process
  -- a p_transaction_line_tbl line
  --
  l_country_tab := l_null_country_tab;

  -- This loop will determine all the countries associated with a line and
  -- add them to the l_country_tab table
  --

  FOR l_det_factor_tab_rownum IN NVL(l_det_factor_code_tab.FIRST, 0) ..
                                 NVL(l_det_factor_code_tab.LAST, -1)
  LOOP
    -- fetch parameter value(location_id) for each parameter name of driver

    l_structure_name := 'TRX_LINE_DIST_TBL';
    ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
           p_struct_name     => l_structure_name,
           p_struct_index    => p_trx_line_index,
           p_tax_param_code  => l_det_factor_code_tab(l_det_factor_tab_rownum),
           x_tax_param_value => l_location_id,
           x_return_status   => x_return_status );

    IF NVL(x_return_status,FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
    THEN

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                      'The value of return_status is not ''S'' after calling '||
                      'ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value');
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes.END',
                      'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes(-)');
      END IF;
      RETURN;
    END IF;

   -- If the location_id returned is NOT NULL
   --
   IF l_location_id IS NOT NULL THEN

      IF NOT b_location_found THEN
         b_location_found := TRUE;
      END IF;

      -- Fetch Country code for each parameter value of driver(location_id)
      --
      l_location_type := substr(l_det_factor_code_tab(l_det_factor_tab_rownum),1,
          length(l_det_factor_code_tab(l_det_factor_tab_rownum))-12);

      ZX_TCM_GEO_JUR_PKG.get_master_geography (
                     p_location_id    => l_location_id,
                     p_location_type  => l_location_type,
                     p_geography_type => 'COUNTRY',
                     x_geography_id   => l_geography_id,
                     x_geography_code => l_country_code,
                     x_geography_name => l_geography_name,
                     x_return_status  => x_return_status);


      IF NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
      THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                        'Incorrect return_status after calling '||
                        'ZX_TCM_CONTROL_PKG.get_location_country');
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                        'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes.END',
                        'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes(-)');
        END IF;
        --
        -- add error message before return
        --
        FND_MESSAGE.SET_NAME ('ZX', 'ZX_GENERIC_TEXT');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Unable to determine the Country code for the Location id: '||
                              l_location_id||' and Location type: '||l_location_type);

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

        ZX_API_PUB.add_msg(
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
        RETURN;
      END IF;

      -- If status is normal and country code is associated to
      -- determining factor(location)
      --
      IF (l_country_code IS NOT NULL) THEN

        -- Populate plsql table index with country code
        --
        l_country_idx := l_country_code;

        -- Check if country (country code) already exists.
        --
        IF NOT l_country_tab.EXISTS(l_country_idx) THEN
          l_country_tab(l_country_idx).country_code := l_country_code;
        END IF;

        -- If regime_determination_level is 'ZONE', populate l_zone_tbl
        --
        IF l_regime_det_level_tab(l_det_factor_tab_rownum) = 'ZONE' THEN

          IF NOT l_geography_tab.EXISTS(l_geography_id) THEN
            l_geography_tab(l_geography_id).geography_id := l_geography_id;
          END IF;
        END IF;
      ELSE
      --  l_country_tab := l_null_country_tab;
          l_null_country_loc_id := l_location_id;
          l_null_country_loc_type := l_location_type;
        --EXIT;
        /*x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME ('ZX', 'ZX_NO_COUNTRY_CODE_FOUND');
        FND_MESSAGE.SET_TOKEN('LOCATION_TYPE', l_location_type);

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

        ZX_API_PUB.add_msg(
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

        */
        IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                         'No Country Code defined for the location: '|| l_location_id);
        END IF;

        --RETURN;
      END IF;    -- l_country_code
   END IF;       -- l_location_id is not null

   -- concatenate the location factor for the error msg.
   IF l_det_factor_tab_rownum =  l_det_factor_code_tab.FIRST THEN
     l_location_list := l_det_factor_code_tab(l_det_factor_tab_rownum);
   ELSE
     l_location_list := l_location_list || ', ' || l_det_factor_code_tab(l_det_factor_tab_rownum);
   END IF;

  END LOOP;    -- l_driver_id_tab

        -- As a part of 6798559 fix
    IF l_country_tab.count = 0 THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME ('ZX', 'ZX_NO_COUNTRY_CODE_FOUND');
        FND_MESSAGE.SET_TOKEN('LOCATION_TYPE', l_null_country_loc_type);

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

        ZX_API_PUB.add_msg(
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

        RETURN;

    END IF;
  -- End of processing for all the drivers for a line in the
  -- transaction line Memory Structure (IN parameter to this procedure)

  IF NOT b_location_found THEN
   --Bug 5065057
  /*  x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME ('ZX', 'ZX_NO_LOCATIONS_FOUND');
    FND_MESSAGE.SET_TOKEN('TEMPLATE_NAME', p_event_class_rec.det_factor_templ_code);
    FND_MESSAGE.SET_TOKEN('LOCATIONS_LIST', l_location_list);

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

    ZX_API_PUB.add_msg(
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);*/

    RETURN;
  END IF;

  -- If p_status is error then break form transaction line and return error.
--    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
--      EXIT;
--    END IF;

  -- This loop will determine the Regimes corresponding to the different
  -- countries in the l_country_tab structure and insert into the
  -- p_detail_tax_regime_tbl for each line and p_tax_regime_tbl for unique
  -- regimes on whole document.
  --
  l_country_num := l_country_tab.FIRST;
  l_geo_num := l_geography_tab.FIRST;

  IF l_country_num IS NOT NULL OR l_geo_num IS NOT NULL THEN

    get_tax_date( p_trx_line_index,
                l_tax_date,
                l_tax_determine_date,
                l_tax_point_date,
                x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
               'Incorrect return_status after calling ' ||
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date()');
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes.END',
               'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
      END IF;
      RETURN;
    END IF;
  END IF;

  WHILE l_country_num IS NOT NULL LOOP

    l_country_code := l_country_tab(l_country_num).country_code;

    FOR l_regime_rec in get_tax_regime_info_cur(l_country_code, l_tax_determine_date) LOOP

      --
      -- Bug#5440023- do not poplate detail_tax_regime_tbl
      -- for partner integration with 'LINE_INFO_TAX_ONLY' lines
      --
      IF NOT (NVL(ZX_GLOBAL_STRUCTURES_PKG.g_ptnr_srvc_subscr_flag, 'N') = 'Y' AND
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action (p_trx_line_index ) =  'LINE_INFO_TAX_ONLY' ) THEN

        l_new_row_num :=
                 NVL(ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.last, 0) + 1;

        ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(l_new_row_num).trx_line_index
                                                               := p_trx_line_index;
        ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(l_new_row_num).tax_regime_id
                                                     := l_regime_rec.tax_regime_id;
        ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(
            l_new_row_num).tax_regime_precedence := l_regime_rec.regime_precedence;
      END IF;

      IF NOT ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.EXISTS(l_regime_rec.tax_regime_id)
      THEN
        add_tax_regime (
                l_regime_rec.regime_precedence,
                l_regime_rec.tax_regime_id,
                l_regime_rec.tax_regime_code,
                l_regime_rec.parent_regime_code,
                l_regime_rec.country_code,
                l_regime_rec.geography_type,
                l_regime_rec.geography_id,
                l_regime_rec.effective_from,
                l_regime_rec.effective_to,
                x_return_status );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                           'Incorrect return_status after calling ' ||
                           'ZX_TDS_APPLICABILITY_DETM_PKG.add_tax_regime');
            FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                           'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes.END',
                           'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes(-)');
          END IF;

          RETURN;
        END IF;
      END IF;     -- NOT tax_regime_tbl.EXISTS(tax_regime_id)
    END LOOP;     -- added all the regimes for one country and one line

    -- Process next country
    --
    l_country_num := l_country_tab.NEXT(l_country_num);

  END LOOP;  -- end of processing for all the countries for one line

  -- Determine the Regimes corresponding to tax_zones
  --
  -- l_geo_num := l_geography_tab.FIRST; -- moved up

  WHILE l_geo_num IS NOT NULL LOOP

    FOR l_regime_rec IN get_zone_level_regimes_cur(
        l_geography_tab(l_geo_num).geography_id, l_tax_determine_date) LOOP

      --
      -- Bug#5440023- do not poplate detail_tax_regime_tbl
      -- for partner integration with 'LINE_INFO_TAX_ONLY' lines
      --
      IF NOT (NVL(ZX_GLOBAL_STRUCTURES_PKG.g_ptnr_srvc_subscr_flag, 'N') = 'Y' AND
              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action (p_trx_line_index ) =  'LINE_INFO_TAX_ONLY' ) THEN

        l_new_row_num :=
                 NVL(ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.last, 0) + 1;

        ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(l_new_row_num).trx_line_index
                                                               := p_trx_line_index;
        ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(l_new_row_num).tax_regime_id
                                                     := l_regime_rec.tax_regime_id;
        ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(
            l_new_row_num).tax_regime_precedence := l_regime_rec.regime_precedence;
      END IF;

      IF NOT ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.EXISTS(l_regime_rec.tax_regime_id)
      THEN
        add_tax_regime (
                l_regime_rec.regime_precedence,
                l_regime_rec.tax_regime_id,
                l_regime_rec.tax_regime_code,
                l_regime_rec.parent_regime_code,
                l_regime_rec.country_code,
                l_regime_rec.geography_type,
                l_regime_rec.geography_id,
                l_regime_rec.effective_from,
                l_regime_rec.effective_to,
                x_return_status );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                           'Incorrect return_status after calling ' ||
                           'ZX_TDS_APPLICABILITY_DETM_PKG.add_tax_regime');
            FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                           'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes.END',
                           'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes(-)');
          END IF;

          RETURN;
        END IF;
      END IF;     -- NOT tax_regime_tbl.EXISTS(tax_regime_id)
    END LOOP;     -- added all the regimes for one zone and one line

    -- Process next geography_id
    --
    l_geo_num := l_geography_tab.NEXT(l_geo_num);

  END LOOP;  -- end of processing for all the zones for one line

  -- Return with ERROR status when there are no regimes.
  -- This also handles the validation of atleast one driver parameter having
  -- value for a transaction.
  --
  IF ((NVL(l_country_tab.COUNT, 0) > 0 OR NVL(l_geography_tab.count, 0) > 0) AND
       NVL(ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.COUNT, 0) = 0) THEN
--    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                    'No Applicable Regimes');
      FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                   'Count for distinct Countries is: '||
                    NVL( l_country_tab.COUNT,0));
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                   'Count for applicable regimes is: '||
                    nvl(ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.COUNT,0));
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes(-)');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes(-)');
    END IF;

END get_applicable_regimes;


----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  add_tax_regime
--
--  DESCRIPTION
--
--  This procedure determines if the Regime already exists and adds the regime
--  to p_tax_regime_tbl only when the same regime doesn't exist
--
--  IN     p_tax_regime_precedence
--         p_tax_regime_id
--  OUT    x_return_status
----------------------------------------------------------------------

PROCEDURE add_tax_regime (
  p_tax_regime_precedence IN          zx_regimes_b.regime_precedence%TYPE,
  p_tax_regime_id         IN          zx_regimes_b.tax_regime_id%TYPE,
  p_tax_regime_code       IN          zx_regimes_b.tax_regime_code%TYPE,
  p_parent_regime_code    IN          zx_regimes_b.parent_regime_code%TYPE,
  p_country_code          IN          zx_regimes_b.country_code%TYPE,
  p_geography_type        IN          zx_regimes_b.geography_type%TYPE,
  p_geography_id          IN          zx_regimes_b.geography_id%TYPE,
  p_effective_from        IN          zx_regimes_b.effective_from%TYPE,
  p_effective_to          IN          zx_regimes_b.effective_to%TYPE,
  x_return_status         OUT NOCOPY  VARCHAR2) IS

 l_next_regime_num number;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- insert the regime_id and the regime_precedence using the regime_id as the
  -- subscript of the p_Tax_regime_tbl. Hence, when the same tax_regime_id is
  -- passed multiple times, we overwrite the p_tax_regime_tbl(tax_regime_id) row

  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(p_tax_regime_id).tax_regime_precedence :=
                                                             p_tax_regime_precedence;
  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(p_tax_regime_id).tax_regime_id :=
                                                                p_tax_regime_id;
  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(p_tax_regime_id).tax_regime_code :=
                                                              p_tax_regime_code;
  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(p_tax_regime_id).parent_regime_code :=
                                                            p_parent_regime_code;
  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(p_tax_regime_id).country_code :=
                                                                  p_country_code;
  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(p_tax_regime_id).geography_type :=
                                                                p_geography_type;
  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(p_tax_regime_id).geography_id :=
                                                                  p_geography_id;
  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(p_tax_regime_id).effective_from :=
                                                                p_effective_from;
  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(p_tax_regime_id).effective_to :=
                                                                  p_effective_to;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.add_tax_regime',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.add_tax_regime.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.add_tax_regime(-)');
    END IF;

END add_tax_regime;


----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  is_tax_applicable
--
--  DESCRIPTION
--
--  This procedure returns if the tax is applicable or not for a given regime
--  TRUE  - Applicable
--  FALSE - Not Applicable
--
--  IN     p_event_class_rec
--         p_tax_id
--         p_tax_determine_date
--         p_applicability_rule_flag
--         p_trx_line_index
-- OUT     x_applicability_result
--         x_applicability_result_id
--         x_return_status
----------------------------------------------------------------------
FUNCTION is_tax_applicable (
  p_tax_id                   IN        zx_taxes_b.tax_id%TYPE,
  p_tax_determine_date       IN        DATE,
  p_applicability_rule_flag  IN        zx_taxes_b.applicability_rule_flag%TYPE,
  p_event_class_rec          IN        zx_api_pub.event_class_rec_type,
  p_trx_line_index           IN        BINARY_INTEGER,
  p_applicable_by_default_flag  IN     zx_taxes_b.applicable_by_default_flag%TYPE,
  x_applicability_result     OUT NOCOPY  VARCHAR2,
  x_applicability_result_id  OUT NOCOPY  NUMBER,
  x_return_status            OUT NOCOPY  VARCHAR2) RETURN BOOLEAN IS

 l_tax_service_type_code zx_rules_b.service_type_code%TYPE;
 l_result   BOOLEAN;

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable.BEGIN',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable(+)');
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable',
                   'l_applicability_rule_flag: '|| p_applicability_rule_flag);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_tax_service_type_code := 'DET_APPLICABLE_TAXES';
  l_result                := FALSE;

  IF NVL(p_applicability_rule_flag, 'N') = 'N' THEN
    -- Bug fix: 4874898
    --  l_result := TRUE;
    IF p_applicable_by_default_flag = 'Y' THEN
      l_result :=TRUE;
    END IF;
  ELSIF p_applicability_rule_flag = 'Y' THEN

    rule_base_pos_detm(
                p_tax_id                =>  p_tax_id,
                p_tax_determine_date    =>  p_tax_determine_date,
                p_tax_service_type_code =>  l_tax_service_type_code,
                p_event_class_rec       =>  p_event_class_rec,
                p_trx_line_index        =>  p_trx_line_index,
                x_alphanumeric_result   => x_applicability_result,
                x_result_id             => x_applicability_result_id,
                x_return_status         => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable',
               'Incorrect return_status after calling ' ||
               'ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm');
         FND_LOG.STRING(g_level_statement,
                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable',
                'RETURN_STATUS = ' || x_return_status);
         FND_LOG.STRING(g_level_statement,
                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable.END',
                'ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable(-)');
      END IF;
      RETURN FALSE;
    END IF;

    IF ( x_applicability_result = 'APPLICABLE') THEN
      l_result := TRUE;
    ELSE
      l_result := FALSE;
      -- Bug fix: 4874898
      IF x_applicability_result_id IS NULL
        AND p_applicable_by_default_flag = 'Y'
      THEN
        l_result :=TRUE;
      END IF;
    END IF;

  ELSE
    l_result := FALSE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable',
             'applicability_rule_flag = ' || p_applicability_rule_flag );
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable',
             'Error: The valid value for applicability_rule_flag ' ||
             'should be N or Y.');
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable(-)'||'return_status '||x_return_status);
  END IF;

  RETURN l_result;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable.END',
                    'ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable(-)');
    END IF;
    RETURN FALSE;
END is_tax_applicable;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  is_direct_rate_applicable
--
--  DESCRIPTION
--
--  This procedure returns if the direct_rate is applicable or not for a
--  given regime
--  TRUE  - Applicable
--  FALSE - Not Applicable
--
--  IN     p_tax_id
--         p_tax_determine_date
--         p_event_class_rec
--         p_trx_line_index
--  OUT    x_direct_rate_result_rec
--         x_direct_rate_result_id
--         x_return_status
----------------------------------------------------------------------

FUNCTION is_direct_rate_applicable (
  p_tax_id                   IN        zx_taxes_b.tax_id%TYPE,
  p_tax_determine_date       IN        DATE,
  p_event_class_rec          IN        zx_api_pub.event_class_rec_type,
  p_trx_line_index           IN        BINARY_INTEGER,
  x_direct_rate_result_rec   OUT NOCOPY  zx_process_results%ROWTYPE,
  x_direct_rate_result_id    OUT NOCOPY  NUMBER,
  x_return_status            OUT NOCOPY  VARCHAR2) RETURN BOOLEAN IS

  l_tax_service_type_code    zx_rules_b.service_type_code%TYPE;
  l_result                   BOOLEAN;

  l_error_buffer             VARCHAR2(2000);

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_tax_service_type_code    := 'DET_DIRECT_RATE';
  l_result                   :=  FALSE;

  ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process(
                                     l_tax_service_type_code,
                                     'TRX_LINE_DIST_TBL',
                                     p_trx_line_index,
                                     p_event_class_rec,
                                     p_tax_id,
                                     NULL,
                                     p_tax_determine_date,
                                     NULL,
                                     NULL,
                                     x_direct_rate_result_rec,
                                     x_return_status,
                                     l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable',
             'Incorrect return_status after calling ' ||
             'ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process');
    END IF;

    x_direct_rate_result_rec := NULL;
    x_direct_rate_result_id := NULL;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable',
             'RETURN_STATUS = ' || x_return_status);
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable.END',
             'ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable(-)');
    END IF;
    RETURN FALSE;
  END IF;

  IF (x_direct_rate_result_rec.alphanumeric_result = 'APPLICABLE') THEN
    x_direct_rate_result_id := x_direct_rate_result_rec.result_id;
    l_result := TRUE;
  ELSE
    x_direct_rate_result_id := NULL;
    l_result := FALSE;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable',
           'RETURN_STATUS = ' || x_return_status);
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable.END',
           'ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable(-)');
  END IF;
  RETURN l_result;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable(-)');
    END IF;
    RETURN FALSE;
END is_direct_rate_applicable;

---------------------------------------------------------------------
-- PUBLIC PROCEDURE
--  fetch_tax_lines
--
--  DESCRIPTION
--
--  This procedure fetch detail tax lines from zx_lines
--
--  IN/OUT
--         p_event_class_rec
--         p_tax_line_tbl
--         x_begin_index
--         x_end_index
--  IN     p_trx_line_index
--  OUT NOCOPY    x_return_status

PROCEDURE fetch_tax_lines (
  p_event_class_rec      IN             zx_api_pub.event_class_rec_type,
  p_trx_line_index       IN             NUMBER,
  p_tax_date             IN             DATE,
  p_tax_determine_date   IN             DATE,
  p_tax_point_date       IN             DATE,
  x_begin_index          IN OUT NOCOPY  NUMBER,
  x_end_index            IN OUT NOCOPY  NUMBER,
  x_return_status           OUT NOCOPY  VARCHAR2) IS

 -- fetch manual tax lines for UPDATE
 --
 CURSOR get_manual_tax_lines IS
   SELECT * FROM zx_lines
   WHERE trx_id = p_event_class_rec.trx_id
     AND application_id = p_event_class_rec.application_id
     AND event_class_code = p_event_class_rec.event_class_code
     AND entity_code = p_event_class_rec.entity_code
     AND trx_line_id =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index)
     AND trx_level_type =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index)
     AND manually_entered_flag = 'Y'
     AND cancel_flag <> 'Y'
     AND mrc_tax_line_flag = 'N'
     AND tax_provider_id IS NULL;

 CURSOR get_tax_lines_override_r IS
   SELECT * FROM zx_lines
   WHERE trx_id = p_event_class_rec.trx_id
     AND application_id = p_event_class_rec.application_id
     AND event_class_code = p_event_class_rec.event_class_code
     AND entity_code = p_event_class_rec.entity_code
     AND trx_line_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index)
     AND trx_level_type =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index)
     AND tax_provider_id IS NULL
     AND cancel_flag <> 'Y'
     AND offset_link_to_tax_line_id IS NULL
     AND mrc_tax_line_flag = 'N'
     AND recalc_required_flag = 'Y'
     ORDER BY manually_entered_flag DESC;

 CURSOR get_tax_lines_override_ri IS
   SELECT * FROM zx_lines
   WHERE trx_id = p_event_class_rec.trx_id
     AND application_id = p_event_class_rec.application_id
     AND event_class_code = p_event_class_rec.event_class_code
     AND entity_code = p_event_class_rec.entity_code
     AND trx_line_id =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index)
     AND trx_level_type =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index)
     AND tax_provider_id IS NULL
     AND cancel_flag <> 'Y'
     AND offset_link_to_tax_line_id IS NULL
     AND mrc_tax_line_flag = 'N'
     AND (recalc_required_flag = 'Y' OR tax_amt_included_flag = 'Y')
     ORDER BY manually_entered_flag DESC;

 CURSOR get_tax_lines_override_rc IS
   SELECT * FROM zx_lines
   WHERE trx_id = p_event_class_rec.trx_id
     AND application_id = p_event_class_rec.application_id
     AND event_class_code = p_event_class_rec.event_class_code
     AND entity_code = p_event_class_rec.entity_code
     AND trx_line_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index)
     AND trx_level_type =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index)
     AND tax_provider_id IS NULL
     AND cancel_flag <> 'Y'
     AND offset_link_to_tax_line_id IS NULL
     AND mrc_tax_line_flag = 'N'
     AND (recalc_required_flag = 'Y' OR compounding_tax_flag = 'Y')
     ORDER BY manually_entered_flag DESC, compounding_tax_flag DESC,
              compounding_dep_tax_flag;

 CURSOR get_tax_lines_override_a IS
   SELECT * FROM zx_lines
   WHERE trx_id = p_event_class_rec.trx_id
     AND application_id = p_event_class_rec.application_id
     AND event_class_code = p_event_class_rec.event_class_code
     AND entity_code = p_event_class_rec.entity_code
     AND trx_line_id =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index)
     AND trx_level_type =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index)
     AND tax_provider_id IS NULL
     AND cancel_flag <> 'Y'
     AND offset_link_to_tax_line_id IS NULL
     AND mrc_tax_line_flag = 'N'
     AND (recalc_required_flag = 'Y' OR compounding_tax_flag = 'Y'
                                      OR tax_amt_included_flag = 'Y')
     ORDER BY manually_entered_flag DESC, compounding_tax_flag DESC,
              compounding_dep_tax_flag;

 -- fetch all tax lines for migrated transaction
 --
 CURSOR get_all_tax_lines_migrated IS
   SELECT * FROM zx_lines
   WHERE trx_id = p_event_class_rec.trx_id
     AND application_id = p_event_class_rec.application_id
     AND event_class_code = p_event_class_rec.event_class_code
     AND entity_code = p_event_class_rec.entity_code
     AND trx_line_id =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index)
     AND trx_level_type =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index)
     AND tax_provider_id IS NULL
     AND cancel_flag  <> 'Y'
     AND offset_link_to_tax_line_id IS NULL
     AND mrc_tax_line_flag = 'N'
     ORDER BY tax_regime_code, tax, tax_apportionment_line_number;

 l_tax_regime_rec       zx_global_structures_pkg.tax_regime_rec_type;
 l_tax_rec              ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
 l_tax_status_rec       ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
 l_tax_rate_rec         ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
 l_tax_jurisdiction_rec ZX_TDS_UTILITIES_PKG.zx_jur_info_cache_rec_type;

 l_current_line_amt     zx_lines.line_amt%TYPE;
 l_rownum               BINARY_INTEGER;
 l_error_buffer         VARCHAR2(200);

 l_tax_class            ZX_RATES_B.tax_class%TYPE;

 -- bug fix 5525890
 l_tax_amt_included_flag_usr zx_lines.tax_amt_included_flag%TYPE;
 l_self_assessed_flag_usr    zx_lines.self_assessed_flag%TYPE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.BEGIN',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Bug#5417753- determine tax_class value
  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  l_rownum := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);

  IF NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.historical_flag(
                                                  p_trx_line_index), 'N') = 'Y'
  THEN

    -- For migrated transactions
    --
    -- Fetch all tax lines for migrated transactions.

    FOR tax_line_rec IN get_all_tax_lines_migrated LOOP

      l_rownum := l_rownum + 1;

      -- populate tax info fetched from zx_lines to g_detail_tax_lines_tbl
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum) := tax_line_rec;

      -- 10029625
      IF p_tax_determine_date is NOT NULL AND p_tax_date is NOT NULL AND p_tax_point_date is NOT NULL THEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_rownum).tax_determine_date := p_tax_determine_date;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_rownum).tax_date := p_tax_date;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_rownum).tax_point_date := p_tax_point_date;
      END IF;

      -- populate tax cache : bug 5167406
      --
      ZX_TDS_UTILITIES_PKG.populate_tax_cache (
             p_tax_id         => tax_line_rec.tax_id,
             p_return_status  => x_return_status,
             p_error_buffer   => l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.populate_tax_cache');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
        END IF;
        RETURN;
      END IF;

      -- Set tax_amt to null
      --
      -- bug 7009115
     IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).tax_amt IS NOT NULL
     THEN

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_rownum).unrounded_tax_amt :=
             ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).tax_amt;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).tax_amt := NULL;
     END IF;

      -- bug 6906427: Set summary and detail tax line id to null
      --
      IF NVL(tax_line_rec.tax_only_line_flag, 'N') <> 'Y' THEN

       --Retain the summary tax line for historical invoices always.
       --bug#7695189
       -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
       --                                    l_rownum).summary_tax_line_id := NULL;

        IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                        p_trx_line_index) <> 'OVERRIDE_TAX'  AND
           NVL(tax_line_rec.associated_child_frozen_flag, 'N') = 'Y'
        THEN

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                   l_rownum).tax_line_id := NULL;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_rownum).associated_child_frozen_flag := NULL;

        END IF;
      END IF;

      -- If the value of p_event_class_rec.tax_recovery_flag is 'N',
      -- populate process_for_recovery_flag to 'N'. If it is 'Y', check
      -- reporting_only_flag to set tax_recovery_flag
      --

      /*
       * call populate_recovery_flg in ZX_TDS_TAX_LINES_POPU_PKG instead
       *
       * IF NVL(p_event_class_rec.tax_recovery_flag, 'N') = 'N' THEN
       *   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
       *                         l_rownum).process_for_recovery_flag := 'N';
       * ELSE
       *  IF tax_line_rec.reporting_only_flag <> 'Y' THEN
       *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
       *                           l_rownum).process_for_recovery_flag := 'Y';
       *   ELSE
       *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
       *                          l_rownum).process_for_recovery_flag := 'N';
       *   END IF;
       *   END IF;
       */

      IF (x_begin_index IS NULL) THEN
         x_begin_index := l_rownum;
      END IF;
    END LOOP;    -- tax_line_rec IN get_all_tax_lines_migrated

  ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                                          p_trx_line_index) = 'OVERRIDE_TAX'
  THEN

    -- For OVERRIDE_TAX
    --

    IF NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.compounding_tax_flag(
                                             p_trx_line_index), 'N') = 'N'  AND
       (p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag = 'N' OR
        (p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag = 'Y' AND
         NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_amt_included_flag(
                                                     p_trx_line_index), 'N') = 'N'))
    THEN

      -- For OVERRIDE_TAX, fetch all tax lines with recalc_required_flag = 'Y'.
      -- Do not need to check the tax lines with compounding_tax_flag = 'Y', or
      -- tax_amt_included_flag = 'Y'
      --
      FOR tax_line_rec IN get_tax_lines_override_r LOOP

        l_rownum := l_rownum + 1;

        -- populate tax info fetched from zx_lines to g_detail_tax_lines_tbl
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum) := tax_line_rec;

        -- populate tax cache : bug 5167406
        --
        ZX_TDS_UTILITIES_PKG.populate_tax_cache (
               p_tax_id         => tax_line_rec.tax_id,
               p_return_status  => x_return_status,
               p_error_buffer   => l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.populate_tax_cache');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        -- copy tax_amt to unrounded_tax_amt, set tax_amt to NULL
        -- comment out for bug 4569739
        -- uncommented out for bug 5525890
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).tax_amt := NULL;

        -- Bug 3359512: set summary_tax_line_id to NULL
        --
        -- bug 4569739: set summary_tax_line_id to null except last_manual_entry
        -- is 'TAX_AMOUNT' or 'TAX_RATE'
        -- Bug 6402744 - Not able to change rate name in tax details UI
        -- as summary tax line id is not regenerated.
        -- IF tax_line_rec.last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE') THEN

        -- bug 6906427: Set summary and detail tax line id to null
        --
        IF NVL(tax_line_rec.tax_only_line_flag, 'N') <> 'Y' AND
           NVL(tax_line_rec.associated_child_frozen_flag, 'N') <> 'Y' THEN
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_rownum).summary_tax_line_id := NULL;
        END IF;

        -- END IF;

        -- Set x_begin_index
        --
        IF (x_begin_index IS NULL) THEN
           x_begin_index := l_rownum;
        END IF;

/*
        IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_rownum).last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE')
        THEN
*/
	-- Bugfix 5347691: populate hq estb reg number for manually entered tax lines

        IF (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_rownum).manually_entered_flag = 'Y' and
           (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_rownum).hq_estb_reg_number is null or
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_rownum).tax_registration_number is null)) or
           (ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_rownum).last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE'))
        THEN
          -- bug fix 5525890
          IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_rownum).manually_entered_flag = 'Y' THEN

            -- if etax failed to rederive the registration information for
            -- the manually entered tax lines, the inclusive flag will be reset
            -- to NULL and the self_assessment_flag will be reset to N.
            -- For manual entered tax lines, user entered value for the
            -- inclusive flag and the self_assessment_flag should be honored.

            l_tax_amt_included_flag_usr :=ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                      l_rownum).tax_amt_included_flag;
            l_self_assessed_flag_usr :=ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                      l_rownum).self_assessed_flag;
          END IF;
          -- bug fix 5525890 end

          populate_registration_info(
               p_event_class_rec    => p_event_class_rec,
               p_trx_line_index     => p_trx_line_index,
               p_rownum             => l_rownum,
               p_def_reg_type       => NULL,
               p_reg_rule_flg       => NULL,
               p_tax_determine_date =>
                        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_rownum).tax_determine_date,
               x_return_status      => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info');
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
            END IF;
            RETURN;
          END IF;

          -- bug fix 5525890
          IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_rownum).manually_entered_flag = 'Y' THEN
            -- if etax failed to rederive the registration information for
            -- the manually entered tax lines, the inclusive flag will be reset
            -- to NULL and the self_assessment_flag will be reset to N.
            -- For manual entered tax lines, user entered value for the
            -- inclusive flag and the self_assessment_flag should be honored.

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                      l_rownum).tax_amt_included_flag := l_tax_amt_included_flag_usr;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                      l_rownum).self_assessed_flag := l_self_assessed_flag_usr;
          END IF;
          -- bug fix 5525890 end

        END IF; -- last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE')

      END LOOP;

    ELSIF NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.compounding_tax_flag(
                                              p_trx_line_index), 'N') = 'N'  AND
       (p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag = 'Y' AND
         NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_amt_included_flag(
                                                     p_trx_line_index), 'N') = 'Y')
    THEN

      -- For OVERRIDE_TAX, Need to fetch all tax lines with
      -- recalc_required_flag = 'Y', or tax_amt_included_flag = 'Y'.
      -- Do not need to fetch the tax lines with compounding_tax_flag = 'Y'.
      --
      FOR tax_line_rec IN get_tax_lines_override_ri LOOP

        l_rownum := l_rownum + 1;

        -- populate tax info fetched from zx_lines to g_detail_tax_lines_tbl
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum) := tax_line_rec;

        -- populate tax cache : bug 5167406
        --
        ZX_TDS_UTILITIES_PKG.populate_tax_cache (
               p_tax_id         => tax_line_rec.tax_id,
               p_return_status  => x_return_status,
               p_error_buffer   => l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.populate_tax_cache');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        -- copy tax_amt to unrounded_tax_amt, set tax_amt to NULL
        -- comment out for bug 4569739
        -- uncommented out for bug 5525890
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).tax_amt := NULL;

        -- Bug 3359512: set summary_tax_line_id to NULL
        --
        -- bug 4569739: set summary_tax_line_id to null except last_manual_entry
        -- is 'TAX_AMOUNT' or 'TAX_RATE'
        --
        --IF tax_line_rec.last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE') THEN
        --  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                                    l_rownum).summary_tax_line_id := NULL;
        --END IF;

        -- bug 6906427: Set summary and detail tax line id to null
        --
        IF NVL(tax_line_rec.tax_only_line_flag, 'N') <> 'Y' THEN
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_rownum).summary_tax_line_id := NULL;
        END IF;

        -- Set x_begin_index
        --
        IF (x_begin_index IS NULL) THEN
           x_begin_index := l_rownum;
        END IF;

        IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_rownum).last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE')
        THEN
          populate_registration_info(
               p_event_class_rec    => p_event_class_rec,
               p_trx_line_index     => p_trx_line_index,
               p_rownum             => l_rownum,
               p_def_reg_type       => NULL,
               p_reg_rule_flg       => NULL,
               p_tax_determine_date =>
                        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_rownum).tax_determine_date,
               x_return_status      => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                             'Incorrect return_status after calling ' ||
                             'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info');
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                             'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                             'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
            END IF;
            RETURN;
          END IF;
        END IF;  -- last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE')

      END LOOP;
    ELSIF NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.compounding_tax_flag(
                                               p_trx_line_index), 'N') = 'Y' AND
       (p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag = 'N' OR
        (p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag = 'Y' AND
         NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_amt_included_flag(
                                                        p_trx_line_index), 'N') = 'N'))
    THEN

      -- For OVERRIDE_TAX, Need to fetch all tax lines with
      -- recalc_required_flag = 'Y', or compounding_tax_flag = 'Y'.
      -- Do not need to fetch the tax lines with tax_amt_included_flag = 'Y'.
      --
      FOR tax_line_rec IN get_tax_lines_override_rc LOOP

        l_rownum := l_rownum + 1;

        -- populate tax info fetched from zx_lines to g_detail_tax_lines_tbl
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum) := tax_line_rec;

        -- populate tax cache : bug 5167406
        --
        ZX_TDS_UTILITIES_PKG.populate_tax_cache (
               p_tax_id         => tax_line_rec.tax_id,
               p_return_status  => x_return_status,
               p_error_buffer   => l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.populate_tax_cache');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        -- copy tax_amt to unrounded_tax_amt, set tax_amt to NULL
        -- comment out for bug 4569739
        -- uncommented out for bug 5525890
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).tax_amt := NULL;

        -- Bug 3359512: set summary_tax_line_id to NULL
        --
        -- bug 4569739: set summary_tax_line_id to null except last_manual_entry
        -- is 'TAX_AMOUNT' or 'TAX_RATE'
        --
        --IF tax_line_rec.last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE') THEN
        --  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                                    l_rownum).summary_tax_line_id := NULL;
        --END IF;

        -- bug 6906427: Set summary and detail tax line id to null
        --
        IF NVL(tax_line_rec.tax_only_line_flag, 'N') <> 'Y' THEN
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_rownum).summary_tax_line_id := NULL;
        END IF;

        -- Set x_begin_index
        --
        IF (x_begin_index IS NULL) THEN
           x_begin_index := l_rownum;
        END IF;

        IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_rownum).last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE')
        THEN
          populate_registration_info(
               p_event_class_rec    => p_event_class_rec,
               p_trx_line_index     => p_trx_line_index,
               p_rownum             => l_rownum,
               p_def_reg_type       => NULL,
               p_reg_rule_flg       => NULL,
               p_tax_determine_date =>
                        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_rownum).tax_determine_date,
               x_return_status      => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info');
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
            END IF;
            RETURN;
          END IF;
        END IF;  -- last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE')

      END LOOP;

    ELSIF NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.compounding_tax_flag(
                                               p_trx_line_index), 'N') = 'Y' AND
       (p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag = 'Y' AND
         NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_amt_included_flag(
                                                     p_trx_line_index), 'N') = 'Y')
    THEN

      -- For OVERRIDE_TAX, Need to fetch all tax lines with
      -- recalc_required_flag = 'Y', or compounding_tax_flag = 'Y',
      -- or tax_amt_included_flag = 'Y'
      --
      FOR tax_line_rec IN get_tax_lines_override_a LOOP

        l_rownum := l_rownum + 1;

        -- populate tax info fetched from zx_lines to g_detail_tax_lines_tbl
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum) := tax_line_rec;

        -- populate tax cache : bug 5167406
        --
        ZX_TDS_UTILITIES_PKG.populate_tax_cache (
               p_tax_id         => tax_line_rec.tax_id,
               p_return_status  => x_return_status,
               p_error_buffer   => l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.populate_tax_cache');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        -- copy tax_amt to unrounded_tax_amt, set tax_amt to NULL
        -- comment out for bug 4569739
        -- uncommented out for bug 5525890
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).tax_amt := NULL;

        -- Bug 3359512: set summary_tax_line_id to NULL
        --
        -- bug 4569739: set summary_tax_line_id to null except last_manual_entry
        -- is 'TAX_AMOUNT' or 'TAX_RATE'
        --
        -- IF tax_line_rec.last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE') THEN
        --   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                                     l_rownum).summary_tax_line_id := NULL;
        -- END IF;

        -- bug 6906427: Set summary and detail tax line id to null
        --
        IF NVL(tax_line_rec.tax_only_line_flag, 'N') <> 'Y' THEN
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_rownum).summary_tax_line_id := NULL;
        END IF;

        -- Set x_begin_index
        --
        IF (x_begin_index IS NULL) THEN
           x_begin_index := l_rownum;
        END IF;

        IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_rownum).last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE')
        THEN
          populate_registration_info(
               p_event_class_rec    => p_event_class_rec,
               p_trx_line_index     => p_trx_line_index,
               p_rownum             => l_rownum,
               p_def_reg_type       => NULL,
               p_reg_rule_flg       => NULL,
               p_tax_determine_date =>
                        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_rownum).tax_determine_date,
               x_return_status      => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info');
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
            END IF;
            RETURN;
          END IF;
        END IF;  -- last_manual_entry NOT IN ('TAX_AMOUNT', 'TAX_RATE')

      END LOOP;
    END IF;
  ELSIF ((ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                 p_trx_line_index) = 'UPDATE')
          OR
          (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(
                 p_trx_line_index) ='UPDATE'  AND
            (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                 p_trx_line_index) = 'LINE_INFO_TAX_ONLY'
              OR ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                 p_trx_line_index) = 'CREATE_WITH_TAX') -- Bug 8205359
                 )) THEN  -- Bug 5291394

    -- For Update
    --

    FOR tax_line_rec IN get_manual_tax_lines LOOP

      l_rownum := l_rownum + 1;

      -- populate tax info fetched from zx_lines to g_detail_tax_lines_tbl
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum) := tax_line_rec;

      -- 10029625
      IF p_tax_determine_date is NOT NULL AND p_tax_date is NOT NULL AND p_tax_point_date is NOT NULL THEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_rownum).tax_determine_date := p_tax_determine_date;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_rownum).tax_date := p_tax_date;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                    l_rownum).tax_point_date := p_tax_point_date;
      END IF;

      -- bug 7008562: Per Harsh and Desh, do not do validation for PO taxes
      --              that are not applicable in current AP invoice
      --
      -- set x_begin_index
      --
      -- Bug 8220741
      ZX_TDS_UTILITIES_PKG.populate_tax_cache (
               p_tax_id         => tax_line_rec.tax_id,
               p_return_status  => x_return_status,
               p_error_buffer   => l_error_buffer);
      -- End Bug 8220741

      IF (x_begin_index is NULL) THEN
        x_begin_index := l_rownum;
      END IF;

      IF tax_line_rec.other_doc_source = 'REFERENCE' AND
         tax_line_rec.unrounded_tax_amt = 0 AND
         tax_line_rec.unrounded_taxable_amt = 0 AND
         tax_line_rec.manually_entered_flag = 'Y' AND
         tax_line_rec.freeze_until_overridden_flag ='Y'
      THEN

		--Start of Bug 7383041
		--NULL;
		populate_registration_info(
             p_event_class_rec    => p_event_class_rec,
             p_trx_line_index     => p_trx_line_index,
             p_rownum             => l_rownum,
             p_def_reg_type       => NULL,
             p_reg_rule_flg       => NULL,
             p_tax_determine_date => p_tax_determine_date,
             x_return_status      => x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                           'Incorrect return_status after calling ' ||
                           'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info');
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                           'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                           'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          RETURN;
        END IF;
--End of Bug 7383041
      ELSE
        -- validate and populate tax_regime_id
        --
        ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
                          tax_line_rec.tax_regime_code,
                          p_tax_determine_date,
                          l_tax_regime_rec,
                          x_return_status,
                          l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_regime_cache_info');
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                          'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_rownum).tax_regime_id :=
                                        l_tax_regime_rec.tax_regime_id;

        -- validate and populate tax_id
        --
        ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                          tax_line_rec.tax_regime_code,
                          tax_line_rec.tax,
                          p_tax_determine_date,
                          l_tax_rec,
                          x_return_status,
                          l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_cache_info');
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                          'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_rownum).tax_id := l_tax_rec.tax_id;

        --
        -- validate and populate tax_jurisdiction_id
        --
        IF tax_line_rec.tax_jurisdiction_code is not NULL THEN
          ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info(
                          tax_line_rec.tax_regime_code,
                          tax_line_rec.tax,
                          tax_line_rec.tax_jurisdiction_code,
                          p_tax_determine_date,
                          l_tax_jurisdiction_rec,
                          x_return_status,
                          l_error_buffer);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info');
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                            'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                            'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
            END IF;
            RETURN;
          END IF;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_rownum).tax_jurisdiction_id :=
                                        l_tax_jurisdiction_rec.tax_jurisdiction_id;
        END IF;


        -- validate and populate tax_status_id
        ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                          tax_line_rec.tax,
                          tax_line_rec.tax_regime_code,
                          tax_line_rec.tax_status_code,
                          p_tax_determine_date,
                          l_tax_status_rec,
                          x_return_status,
                          l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info');
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                          'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_rownum).tax_status_id := l_tax_status_rec.tax_status_id;

        -- validate and populate tax_rate_id
        --
        ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
                          tax_line_rec.tax_regime_code,
                          tax_line_rec.tax,
                          tax_line_rec.tax_jurisdiction_code,
                          tax_line_rec.tax_status_code,
                          tax_line_rec.tax_rate_code,
                          p_tax_determine_date,
                          l_tax_class,
                          l_tax_rate_rec,
                          x_return_status,
                          l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_rate_info');
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                          'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        -- bug 6906427: Set summary and detail tax line id to null
        --
        IF NVL(tax_line_rec.tax_only_line_flag, 'N') <> 'Y' THEN

          IF tax_line_rec.tax_rate_id <> l_tax_rate_rec.tax_rate_id  THEN

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                    l_rownum).summary_tax_line_id := NULL;

            IF NVL(tax_line_rec.associated_child_frozen_flag, 'N') = 'Y' THEN

              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                           l_rownum).tax_line_id := NULL;
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_rownum).associated_child_frozen_flag := NULL;
            END IF;
          END IF;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                             l_rownum).tax_rate_id := l_tax_rate_rec.tax_rate_id;


        -- when Recalculate Manual Tax Lines flag is 'Y',
        -- prorate tax amount and taxable amount
        --
        IF p_event_class_rec.allow_manual_lin_recalc_flag ='Y' THEN

          l_current_line_amt :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt( p_trx_line_index);

          IF tax_line_rec.line_amt <> 0 THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_rownum).unrounded_tax_amt :=
                 tax_line_rec.unrounded_tax_amt *
                                        l_current_line_amt/tax_line_rec.line_amt;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_rownum).unrounded_taxable_amt :=
                 tax_line_rec.unrounded_taxable_amt *
                                        l_current_line_amt/tax_line_rec.line_amt;
          END IF;

          -- set tax_amt to NULL
          --
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).tax_amt := NULL;

        END IF;

        -- If the value of p_event_class_rec.tax_recovery_flag is 'N',
        -- populate process_for_recovery_flag to 'N'. If it is 'Y', check
        -- reporting_only_flag to set tax_recovery_flag
        --
        /*
         * call populate_recovery_flg in ZX_TDS_TAX_LINES_POPU_PKG instead
         *
         * IF NVL(p_event_class_rec.tax_recovery_flag, 'N') = 'N' THEN
         *  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         *                          l_rownum).process_for_recovery_flag := 'N';
         * ELSE
         *  IF tax_rec.reporting_only_flag <> 'Y' THEN
         *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         *                         l_rownum).process_for_recovery_flag := 'Y';
         *   ELSE
         *    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         *                         l_rownum).process_for_recovery_flag := 'N';
         *   END IF;
         *  END IF;
         */

        -- set x_begin_index
        --
        IF (x_begin_index is NULL) THEN
          x_begin_index := l_rownum;
        END IF;


        -- bug fix 5525890
        -- if etax failed to rederive the registration information for
        -- the manually entered tax lines, the inclusive flag will be reset
        -- to NULL and the self_assessment_flag will be reset to N.
        -- For manual entered tax lines, user entered value for the
        -- inclusive flag and the self_assessment_flag should be honored.

        l_tax_amt_included_flag_usr :=ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_rownum).tax_amt_included_flag;
        l_self_assessed_flag_usr :=ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_rownum).self_assessed_flag;
        -- bug fix 5525890 end
        populate_registration_info(
             p_event_class_rec    => p_event_class_rec,
             p_trx_line_index     => p_trx_line_index,
             p_rownum             => l_rownum,
             p_def_reg_type       => l_tax_rec.def_registr_party_type_code,
             p_reg_rule_flg       => l_tax_rec.registration_type_rule_flag,
             p_tax_determine_date => p_tax_determine_date,
             x_return_status      => x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                           'Incorrect return_status after calling ' ||
                           'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info');
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                           'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                           'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        -- bug fix 5525890
        -- if etax failed to rederive the registration information for
        -- the manually entered tax lines, the inclusive flag will be reset
        -- to NULL and the self_assessment_flag will be reset to N.
        -- For manual entered tax lines, user entered value for the
        -- inclusive flag and the self_assessment_flag should be honored.

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_rownum).tax_amt_included_flag := l_tax_amt_included_flag_usr;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_rownum).self_assessed_flag := l_self_assessed_flag_usr;
        -- bug fix 5525890 end

      END IF;    -- bug 7008562
    END LOOP;    -- tax_rec IN get_manual_tax_lines
  END IF;        -- line_level_action, tax_event_type_code

  -- set x_end_index
  --
  IF (x_begin_index IS NOT NULL) THEN
    x_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;
  END IF;

  --Besides update action, also need to populate the trx line info onto tax lines for
  --manually entered tax lines.
  --IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
  --                                             p_trx_line_index) = 'UPDATE' THEN
    -- copy transaction info to manual tax lines
    --
    ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines (p_trx_line_index,
                                                       x_begin_index,
                                                       x_end_index,
                                                       x_return_status,
                                                       l_error_buffer );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
               'Incorrect RETURN_STATUS after calling '||
               'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
               'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
      END IF;
      RETURN;
    END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                  'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                    'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
    END IF;

END fetch_tax_lines;

----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_applicable_taxes
--
--  DESCRIPTION
--
--  This procedure returns applicable taxes
--
--  IN/OUT
--         p_summmary_tax_line_tbl
--         p_event_class_rec
--  IN     p_tax_regime_code
--         p_trx_line_index
--         p_tax_determine_date
--         p_total_trx_amount
--         p_summary_line_index
--  OUT NOCOPY    x_return_status
--         x_begin_index
--         x_end_index

PROCEDURE get_applicable_taxes (
  p_tax_regime_id      IN            zx_regimes_b.tax_regime_id%TYPE,
  p_tax_regime_code    IN            zx_regimes_b.tax_regime_code%TYPE,
  p_trx_line_index     IN            BINARY_INTEGER,
  p_event_class_rec    IN            zx_api_pub.event_class_rec_type,
  p_tax_date           IN            DATE,
  p_tax_determine_date IN            DATE,
  p_tax_point_date     IN            DATE,
  x_begin_index        IN OUT NOCOPY BINARY_INTEGER,
  x_end_index          IN OUT NOCOPY BINARY_INTEGER,
  x_return_status         OUT NOCOPY VARCHAR2) IS

  -- local varaibles
  --
  l_new_row_num                NUMBER;
  l_place_of_supply            VARCHAR2(30);
  l_place_of_supply_type_code  zx_taxes_b.def_place_of_supply_type_code%TYPE;
  l_place_of_supply_result_id  NUMBER;
  l_applicability_result_id    NUMBER;

  l_applicability_result       zx_process_results.alphanumeric_result%TYPE;

  l_direct_rate_result_id      NUMBER;

  l_direct_rate_result_rec     zx_process_results%ROWTYPE;
  l_tax_applicable             BOOLEAN;

  /* Commented out as part of restructuring for STCC (bug 4959835)
  l_last_manual_entry          zx_lines.last_manual_entry%TYPE;
  l_tax_status_code            zx_lines.tax_status_code%TYPE;
  l_orig_tax_status_id         zx_lines.orig_tax_status_id%TYPE;
  l_orig_tax_status_code       zx_lines.orig_tax_status_code%TYPE;
  l_tax_rate_code              zx_lines.tax_rate_code%TYPE;
  l_tax_rate                   zx_lines.tax_rate%TYPE;
  l_orig_tax_rate_id           zx_lines.orig_tax_rate_id%TYPE;
  l_orig_tax_rate_code         zx_lines.orig_tax_rate_code%TYPE;
  l_orig_tax_rate              zx_lines.orig_tax_rate%TYPE;
  l_tax_amt                    zx_lines.tax_amt%TYPE;
  l_orig_tax_amt               zx_lines.orig_tax_amt%TYPE;
  l_taxable_amt                zx_lines.taxable_amt%TYPE;
  l_orig_taxable_amt           zx_lines.orig_taxable_amt%TYPE;
  l_line_amt                   zx_lines.line_amt%TYPE;
  l_current_line_amt           zx_lines.line_amt%TYPE;
  */

  l_self_assessed_flag         zx_lines.self_assessed_flag%TYPE;
  l_tax_amt_included_flag      zx_lines.tax_amt_included_flag%TYPE;
  l_tax_jurisdiction_id        zx_lines.tax_jurisdiction_id%TYPE;
  l_tax_jurisdiction_code      zx_lines.tax_jurisdiction_code%TYPE;
  l_tax_status_rec             ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
  l_tax_rate_rec               ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

  l_error_buffer               VARCHAR2(200);
  l_tax_tbl_subscript          NUMBER;

  l_trx_line_id                NUMBER;
  l_trx_level_type             zx_lines.trx_level_type%TYPE;
  l_begin_index                BINARY_INTEGER;
  l_end_index                  BINARY_INTEGER;

  /* Bug4959835: Moved to handle_update_scenarios
  l_unrounded_taxable_amt     zx_lines.unrounded_taxable_amt%TYPE;
  l_unrounded_tax_amt         zx_lines.unrounded_tax_amt%TYPE;
  l_cal_tax_amt               zx_lines.cal_tax_amt%TYPE;
  */

  l_jur_index                 NUMBER;

  l_jurisdictions_found      VARCHAR2(1);
  l_jurisdiction_rec         ZX_TCM_GEO_JUR_PKG.tax_jurisdiction_rec_type;
  l_jurisdiction_rec_tbl     ZX_TCM_GEO_JUR_PKG.tax_jurisdiction_rec_tbl_type;
  l_tax_class                zx_rates_b.tax_class%TYPE;
  l_temp_num                 NUMBER;
  -- cursor to order the jurisdictions in the GT
  CURSOR c_get_jurisdiction_from_gt(
           c_tax_regime_code  VARCHAR2,
           c_tax              VARCHAR2)IS
    SELECT tax_jurisdiction_id,
           tax_jurisdiction_code,
           tax_regime_code,
           tax,
           precedence_level
      FROM zx_jurisdictions_gt
     WHERE tax_regime_code = c_tax_regime_code
       AND tax = c_tax
     ORDER BY precedence_level;

  -- This cursor gets all the taxes for a regime
  --
  CURSOR get_all_taxes_for_regime_cur IS
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
      FROM ZX_SCO_TAXES  zxt
     WHERE zxt.tax_regime_code = p_tax_regime_code
       AND live_for_processing_flag = 'Y'
       AND live_for_applicability_flag = 'Y'
       AND ( p_tax_determine_date >= effective_from AND
            (p_tax_determine_date <= effective_to OR effective_to IS NULL))
       AND zxt.offset_tax_flag = 'N'
      ORDER BY compounding_precedence;

  /* Bug 4959835: Moved to procedure handle_update_scenarios
  CURSOR get_key_columns_cur(p_tax    zx_lines.tax%TYPE)  IS
    SELECT tax_line_id,
           last_manual_entry,
           tax_status_code,
           orig_tax_status_id,
           orig_tax_status_code,
           tax_rate_code,
           tax_rate,
           orig_tax_rate_id,
           orig_tax_rate_code,
           orig_tax_rate,
           tax_amt,
           orig_tax_amt,
           taxable_amt,
           orig_taxable_amt,
           line_amt,
           self_assessed_flag,
           tax_amt_included_flag,
           tax_jurisdiction_id,
           tax_jurisdiction_code,
           orig_self_assessed_flag,
           orig_tax_amt_included_flag,
           orig_tax_jurisdiction_id,
           orig_tax_jurisdiction_code,
           unrounded_taxable_amt,
           unrounded_tax_amt,
           cal_tax_amt,
           associated_child_frozen_flag
      FROM zx_lines
     WHERE application_id = p_event_class_rec.application_id
       AND entity_code = p_event_class_rec.entity_code
       AND event_class_code = p_event_class_rec.event_class_code
       AND trx_id = p_event_class_rec.trx_id
       AND trx_line_id =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index)
       AND trx_level_type =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index)
       AND tax_regime_code = p_tax_regime_code
       AND tax = p_tax
       AND mrc_tax_line_flag = 'N';

  CURSOR  enforce_rate_code_from_ref_doc(
                  c_tax                 zx_lines.tax%TYPE,
                  c_tax_regime_code     zx_lines.tax_regime_code%TYPE) IS
   SELECT tax_status_code,
          tax_rate_code,
          line_amt,
          tax_amt,
          taxable_amt
     FROM zx_lines
    WHERE application_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(p_trx_line_index)
      AND event_class_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_event_class_code(p_trx_line_index)
      AND entity_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_entity_code(p_trx_line_index)
      AND trx_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_id(p_trx_line_index)
      AND trx_line_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_line_id(p_trx_line_index)
      AND trx_level_type =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_level_type(p_trx_line_index)
      AND tax_regime_code = c_tax_regime_code
      AND tax = c_tax
      AND cancel_flag <> 'Y'
      AND mrc_tax_line_flag = 'N';

      Bug 4959835*/

  -- bug 4728374
  CURSOR  check_product_family_group_csr(
          c_tax_regime_code   zx_rates_b.tax_regime_code%TYPE,
          c_tax               zx_rates_b.tax%TYPE,
          c_tax_status_code   zx_rates_b.tax_status_code%TYPE,
          c_tax_rate_code     zx_rates_b.tax_rate_code%TYPE,
          c_tax_class         zx_rates_b.tax_class%TYPE) IS
   SELECT 1
     FROM ZX_SCO_RATES_B_V
    WHERE effective_from <= p_tax_determine_date
      AND (effective_to  >= p_tax_determine_date  OR  effective_to IS NULL )
      AND tax_rate_code = c_tax_rate_code
      AND tax_status_code = c_tax_status_code
      AND tax = c_tax
      AND tax_regime_code = c_tax_regime_code
      AND Active_Flag = 'Y'
      AND (tax_class = c_tax_class or tax_class IS NULL)
      AND ROWNUM=1;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_tax_applicable := FALSE;

  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  l_trx_line_id :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
  l_trx_level_type :=
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

  -- bugfix 5024740: move delete from jurisdictions gt to init_for_header and
  -- init_for_line in the wrapper

  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                              p_trx_line_index) = 'CREATE' OR
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                     p_trx_line_index) = 'CREATE_WITH_TAX' OR
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                              p_trx_line_index) = 'UPDATE' OR
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                     p_trx_line_index) = 'CREATE_TAX_ONLY' OR
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                 p_trx_line_index) = 'COPY_AND_CREATE'
  THEN

    FOR l_tax_rec IN get_all_taxes_for_regime_cur LOOP
      -- init the local indicator of whether the tax is applicable.
      l_tax_applicable := FALSE;
      l_direct_rate_result_id := NULL;
      l_tax_tbl_subscript := NULL;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                       'p_trx_line_index: '|| p_trx_line_index|| 'p_tax_regime_code: '||l_tax_rec.tax_regime_code|| 'l_tax: '|| l_tax_rec.tax);
      END IF;

      -- populate g_tax_rec_tbl, if it does not exist
      --
      IF NOT ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl.EXISTS(l_tax_rec.tax_id) THEN

        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_rec.tax_id) := l_tax_rec;

        /* Following are commented out since the select column in the cursor
          get_all_taxes_for_regime_cur has the same set of column as the definition
          of ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl and in the same order. Changed to
          assignment as above. If later new columns added to get_all_taxes_for_regime_cur,
          but not need to cache, we need to uncomment this part and add the assignment
          individually.

        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                           l_tax_rec.tax_id).tax_id := l_tax_rec.tax_id;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                           l_tax_rec.tax_id).tax := l_tax_rec.tax;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                           l_tax_rec.tax_id).def_place_of_supply_type_code :=
                                      l_tax_rec.def_place_of_supply_type_code;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                           l_tax_rec.tax_id).place_of_supply_rule_flag :=
                                      l_tax_rec.place_of_supply_rule_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                           l_tax_rec.tax_id).applicability_rule_flag :=
                                      l_tax_rec.applicability_rule_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                l_tax_rec.tax_id).direct_rate_rule_flag :=
                                             l_tax_rec.direct_rate_rule_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                l_tax_rec.tax_id).def_registr_party_type_code :=
                                       l_tax_rec.def_registr_party_type_code;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                l_tax_rec.tax_id).registration_type_rule_flag  :=
                                        l_tax_rec.registration_type_rule_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
             l_tax_rec.tax_id).tax_regime_code := l_tax_rec.tax_regime_code;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
           l_tax_rec.tax_id).tax_currency_code := l_tax_rec.tax_currency_code;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                   l_tax_rec.tax_id).tax_precision := l_tax_rec.tax_precision;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
              l_tax_rec.tax_id).minimum_accountable_unit :=
                                          l_tax_rec.minimum_accountable_unit;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
         l_tax_rec.tax_id).rounding_rule_code :=l_tax_rec.rounding_rule_code;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
             l_tax_rec.tax_id).tax_status_rule_flag :=
                                              l_tax_rec.tax_status_rule_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
           l_tax_rec.tax_id).tax_rate_rule_flag := l_tax_rec.tax_rate_rule_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
           l_tax_rec.tax_id).tax_calc_rule_flag := l_tax_rec.tax_calc_rule_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
         l_tax_rec.tax_id).taxable_basis_rule_flag :=
                                         l_tax_rec.taxable_basis_rule_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
              l_tax_rec.tax_id).def_tax_calc_formula :=
                                             l_tax_rec.def_tax_calc_formula;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
              l_tax_rec.tax_id).def_taxable_basis_formula :=
                                         l_tax_rec.def_taxable_basis_formula;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                l_tax_rec.tax_id).tax_type_code := l_tax_rec.tax_type_code;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
         l_tax_rec.tax_id).reporting_only_flag := l_tax_rec.reporting_only_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
             l_tax_rec.tax_id).def_inclusive_tax_flag :=
                                              l_tax_rec.def_inclusive_tax_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
             l_tax_rec.tax_id).applied_amt_handling_flag :=
                                           l_tax_rec.applied_amt_handling_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
             l_tax_rec.tax_id).exchange_rate_type :=
                                           l_tax_rec.exchange_rate_type;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
             l_tax_rec.tax_id).has_other_jurisdictions_flag :=
                                        l_tax_rec.has_other_jurisdictions_flag;
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
             l_tax_rec.tax_id).tax_exmpt_source_tax :=
                                        l_tax_rec.tax_exmpt_source_tax;
      */

      END IF;      -- g_tax_rec_tbl(l_tax_rec.tax_id) does not exist

      -- For import service, tax lines may be created from summary lines
      --
      -- Bug 4277751: For intercompany transaction, need to pull in detail
      --   tax lines from source documnet.
      --
      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                       p_trx_line_index) = 'CREATE_WITH_TAX' OR
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                                p_trx_line_index) = 'UPDATE' OR
          (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                 p_trx_line_index) IN ('CREATE', 'UPDATE')
            AND ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(
                                 p_trx_line_index) = 'INTERCOMPANY_TRX')
      THEN
        -- Check if this tax line exists in the new created applicable tax lines
        --
        l_tax_tbl_subscript := ZX_TDS_UTILITIES_PKG.get_tax_index(
                                           l_tax_rec.tax_regime_code,
                                           l_tax_rec.tax,
                                           l_trx_line_id,
                                           l_trx_level_type,
                                           x_begin_index,
                                           x_end_index,
                                           x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_tax_index');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(-)');
          END IF;
          RETURN;
        END IF;
      END IF;

      -- If this tax does not exist in g_detail_tax_lines_tbl ,create a
      -- new detail tax line in it
      IF (l_tax_tbl_subscript IS NULL) THEN

        -- Use direct_rate_rule_flag to check if tax is applicable first,
        -- if not, use applicability_rule_flag
        --
        IF l_tax_rec.direct_rate_rule_flag = 'Y' THEN

          l_tax_applicable := is_direct_rate_applicable (
                p_tax_id                 => l_tax_rec.tax_id,
                p_tax_determine_date     => p_tax_determine_date,
                p_event_class_rec        => p_event_class_rec,
                p_trx_line_index         => p_trx_line_index,
                x_direct_rate_result_rec => l_direct_rate_result_rec,
                x_direct_rate_result_id  => l_direct_rate_result_id,
                x_return_status          => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.is_direct_rate_applicable');
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(-)');
            END IF;
            RETURN;
          ELSE

            IF l_tax_applicable THEN

              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                       'l_direct_rate_result_rec.status_result = ' ||
                        l_direct_rate_result_rec.status_result||'l_direct_rate_result_rec.rate_result = ' ||
                        l_direct_rate_result_rec.rate_result);
              END IF;

              -- Check if tax rate exists in the same product family group
              --
              OPEN  check_product_family_group_csr(
                     l_tax_rec.tax_regime_code,
                     l_tax_rec.tax,
                     l_direct_rate_result_rec.status_result,
                     l_direct_rate_result_rec.rate_result,
                     l_tax_class);
              FETCH check_product_family_group_csr INTO l_temp_num;

              IF check_product_family_group_csr%NOTFOUND THEN
                -- tax not applicable, reset l_tax_applicable
                --
                l_tax_applicable := FALSE;

                IF (g_level_statement >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                         'Tax Rate does not exist in this product family group. ');
                END IF;
              ELSE
                IF (g_level_statement >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                         'Tax Rate exists in this product family group. ');
                END IF;
              END IF;
              CLOSE check_product_family_group_csr;
            END IF;
          END IF;

          IF (g_level_statement >= g_current_runtime_level ) THEN
            IF l_tax_applicable THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'Direct Rate is Applicable. ');
            ELSE
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'Direct Rate is not Applicable. ');
            END IF;
          END IF;
        END IF;     -- l_tax_rec.direct_rate_rule_flag = 'Y'

        -- Initialize the TCM jurisdiction global tbl for each tax.
        g_inner_jurisdiction_code := NULL;
        g_outer_jurisdiction_code := NULL;
        g_inner_jurisdiction_id := NULL;
        g_outer_jurisdiction_id := NULL;
        l_jurisdictions_found := NULL;

        IF l_direct_rate_result_id IS NOT NULL AND NOT l_tax_applicable THEN
          -- Direct rate rule returns results, but tax rate does not exist
          -- in this product family group
          --
          NULL;
        ELSIF NOT l_tax_applicable AND l_direct_rate_result_rec.alphanumeric_result = 'NOT_APPLICABLE' THEN
          NULL;
        ELSE
          -- Check if the location pointed by place of supply rules or default
          -- supply type maps to a jurisdiction.
          --
          get_place_of_supply (
              p_event_class_rec             => p_event_class_rec,
              p_tax_regime_code             => l_tax_rec.tax_regime_code,
              p_tax_id                      => l_tax_rec.tax_id,
              p_tax                         => l_tax_rec.tax,
              p_tax_determine_date          => p_tax_determine_date,
              p_def_place_of_supply_type_cd => l_tax_rec.def_place_of_supply_type_code,
              p_place_of_supply_rule_flag   => l_tax_rec.place_of_supply_rule_flag,
              p_applicability_rule_flag     => l_tax_rec.applicability_rule_flag,
              p_def_reg_type                => l_tax_rec.def_registr_party_type_code,
              p_reg_rule_flg                => l_tax_rec.registration_type_rule_flag,
              p_trx_line_index              => p_trx_line_index,
              p_direct_rate_result_id       => l_direct_rate_result_id,
              x_jurisdiction_rec            => l_jurisdiction_rec,
              x_jurisdictions_found         => l_jurisdictions_found,
              x_place_of_supply_type_code   => l_place_of_supply_type_code,
              x_place_of_supply_result_id   => l_place_of_supply_result_id,
              x_return_status               => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply');
            END IF;

            -- For migrated taxes, if the has_other_jurisdictions_flag on the tax is 'N',
            -- no jurisdiction required, so ignore the errors raised from get_place_of_supply
            --
            IF NVL(l_tax_rec.has_other_jurisdictions_flag, 'N') = 'N' AND
              NVL(l_tax_rec.record_type_code, 'USER_DEFINED') = 'MIGRATED'
            THEN

              x_return_status := FND_API.G_RET_STS_SUCCESS;
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                       'For migrated taxes, if the has_other_jurisdictions_flag on ' ||
                       'the tax is N, no jurisdiction required. Continue processing tax... ');
              END IF;

            ELSE
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                       'Unable to determine the Place of Supply for tax: '||l_tax_rec.tax||
                       ' Place of Supply is mandatory when Direct Rate Determination is not used');
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                       'RETURN_STATUS = ' || x_return_status);
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.END',
                       'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(-)');
              END IF;

              RETURN;
            END IF;
          END IF;
        END IF;

        IF l_tax_applicable AND
           NVL(l_jurisdictions_found, 'N') <> 'Y' AND
           NVL(l_tax_rec.has_other_jurisdictions_flag, 'N') = 'Y'
        THEN

          l_tax_applicable := FALSE;

        END IF;

        -- If Direct Rate Determination Process does not return
        -- successfully, check the mapping to a jurisdiction. If there is no
        -- mapping to a jurisdiction, tax is not applicable.
        --
        IF (l_jurisdictions_found = 'Y' OR
            NVL(l_tax_rec.has_other_jurisdictions_flag, 'N') = 'N' AND
	          NVL(l_tax_rec.record_type_code, 'USER_DEFINED') = 'MIGRATED') THEN  --Bug 5854385

          IF l_jurisdictions_found = 'Y'
            AND l_jurisdiction_rec.tax_jurisdiction_code IS NULL
          THEN

            -- for multiple jurisdictions case: cache the most inner
            -- and outer jurisdiction for future usage

            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'It is a multiple jurisdiction case. ' );
            END IF;

            -- Stamp multiple_jurisdiction_flag on the tax line to 'Y'
           /* Commented for the : Bug 5045030
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).multiple_jurisdictions_flag := 'Y';*/

            OPEN c_get_jurisdiction_from_gt(p_tax_regime_code, l_tax_rec.tax);
            FETCH c_get_jurisdiction_from_gt
              BULK COLLECT INTO l_jurisdiction_rec_tbl;
            CLOSE c_get_jurisdiction_from_gt;

            IF l_jurisdiction_rec_tbl.COUNT = 0 THEN
              RAISE NO_DATA_FOUND;
              IF (g_level_error >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'No data found in ZX_JURISDICTIONS_GT when multiple jurisdictions found.');
              END IF;

            END IF;
            -- cache the global most inner and outer jurisdiction code
            l_jur_index := l_jurisdiction_rec_tbl.FIRST;
            g_inner_jurisdiction_code
               := l_jurisdiction_rec_tbl(l_jur_index).tax_jurisdiction_code;
            g_inner_jurisdiction_id
               := l_jurisdiction_rec_tbl(l_jur_index).tax_jurisdiction_id;

            l_jur_index := l_jurisdiction_rec_tbl.LAST;
            g_outer_jurisdiction_code
               := l_jurisdiction_rec_tbl(l_jur_index).tax_jurisdiction_code;
            g_outer_jurisdiction_id
               := l_jurisdiction_rec_tbl(l_jur_index).tax_jurisdiction_id;

            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'inner_jurisdiction_code = '|| g_inner_jurisdiction_code ||'outer_jurisdiction_code = '|| g_outer_jurisdiction_code);

            END IF;

          ELSIF l_jurisdictions_found = 'Y'
              AND l_jurisdiction_rec.tax_jurisdiction_code IS NOT NULL
          THEN
            -- for single jurisdiction case: cache the most inner
            -- and outer jurisdiction same as the jurisdiction found
            -- for future usage

            g_inner_jurisdiction_code
               := l_jurisdiction_rec.tax_jurisdiction_code;
            g_inner_jurisdiction_id
               := l_jurisdiction_rec.tax_jurisdiction_id;
            g_outer_jurisdiction_code
               := l_jurisdiction_rec.tax_jurisdiction_code;
            g_outer_jurisdiction_id
               := l_jurisdiction_rec.tax_jurisdiction_id;

            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'single jurisdiction code  = '|| g_inner_jurisdiction_code);
            END IF;
          END IF;

          -- call is_tax_applicable to determine tax applicability
          --
          IF (NOT l_tax_applicable) THEN
            l_tax_applicable := is_tax_applicable (
                p_tax_id                  => l_tax_rec.tax_id,
                p_tax_determine_date      => p_tax_determine_date,
                p_applicability_rule_flag => l_tax_rec.applicability_rule_flag,
                p_event_class_rec         => p_event_class_rec,
                p_trx_line_index          => p_trx_line_index,
                p_applicable_by_default_flag => l_tax_rec.applicable_by_default_flag,
                x_applicability_result    => l_applicability_result,
                x_applicability_result_id => l_applicability_result_id,
                x_return_status           => x_return_status);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable');
                FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'RETURN_STATUS = ' || x_return_status);
                FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(-)');
              END IF;
              RETURN;
            END IF;
          END IF;       -- NOT l_tax_applicable
        END IF;         -- l_jurisdictions_found = 'Y'

        IF l_tax_applicable THEN

          l_new_row_num :=
            NVL( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0)+1;

          IF (x_begin_index is null) THEN
            x_begin_index := l_new_row_num;
          END IF;

          IF(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                            p_trx_line_index)='UPDATE') THEN

             -- Bug 4959835. Moved the code to a private procedure.
             handle_update_scenarios( p_trx_line_index,
                                      p_event_class_rec,
                                      l_new_row_num,
                                      l_tax_rec.tax_regime_code,
                                      l_tax_rec.tax,
                                      p_tax_date,
                                      p_tax_determine_date,
                                      p_tax_point_date,
                                      l_self_assessed_flag,
                                      l_tax_amt_included_flag,
                                      l_tax_jurisdiction_id,
                                      l_tax_jurisdiction_code,
                                      x_return_status);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 IF (g_level_statement >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable');
                   FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'RETURN_STATUS = ' || x_return_status);
                   FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(-)');
                 END IF;
                RETURN;
             END IF;

          ELSE   -- 'CREATE'
           /*
            * will be populated by pop_tax_line_for_trx_line
            * SELECT zx_lines_s.NEXTVAL
            * INTO ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            *                              l_new_row_num).tax_line_id
            * FROM dual;
            */

            NULL;
          END IF;


	  -- Added for Bug 5045030 :
	  IF l_jurisdictions_found = 'Y' AND
	     l_jurisdiction_rec.tax_jurisdiction_code IS NULL
	  THEN
		ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
			      l_new_row_num).multiple_jurisdictions_flag := 'Y';
	  END IF ;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).application_id :=  p_event_class_rec.application_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).event_class_code := p_event_class_rec.event_class_code;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).event_type_code := p_event_class_rec.event_type_code;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).entity_code := p_event_class_rec.entity_code;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                           l_new_row_num).tax_date := p_tax_date;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                   l_new_row_num).tax_determine_date := p_tax_determine_date;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).tax_point_date := p_tax_point_date;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).place_of_supply_type_code :=
                                                 l_place_of_supply_type_code;

          -- if orig_tax_jurisdiction_code(id) is not NULL (for UPDATE),
          -- populate tax_jurisdiction_code and tax_jurisdiction_id fetched
          -- from zx_lines. Otherwise, populate new tax_jurisdiction_code
          -- and tax_jurisdiction_id from most inner jurisdiction info
          --

          IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_new_row_num).orig_tax_jurisdiction_code IS NOT NULL
          THEN

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_jurisdiction_code := l_tax_jurisdiction_code;

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_jurisdiction_id := l_tax_jurisdiction_id;

          ELSE
            -- always stamp the most inner jurisdiction code on tax line

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_jurisdiction_code
                := NVL(l_jurisdiction_rec.tax_jurisdiction_code,
                     g_inner_jurisdiction_code);

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_jurisdiction_id
                := NVL(l_jurisdiction_rec.tax_jurisdiction_id,
                       g_inner_jurisdiction_id);

          END IF;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                             l_new_row_num).tax_regime_id := p_tax_regime_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 l_new_row_num).tax_regime_code := l_tax_rec.tax_regime_code;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         l_new_row_num).tax := l_tax_rec.tax;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_new_row_num).tax_id := l_tax_rec.tax_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).tax_currency_code := l_tax_rec.tax_currency_code;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_type_code := l_tax_rec.tax_type_code;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).tax_currency_conversion_date := p_tax_determine_date;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_new_row_num).tax_currency_conversion_type :=
                                                l_tax_rec.exchange_rate_type;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).reporting_only_flag := l_tax_rec.reporting_only_flag;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).place_of_supply_result_id :=
                                                  l_place_of_supply_result_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).legal_message_pos:=
                ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id(l_place_of_supply_result_id,
                      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_date(p_trx_line_index));

          -- bug 5077691: populate legal_reporting_status
          IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
            IF NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_new_row_num).cancel_flag, 'N') <> 'Y' THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_new_row_num).legal_reporting_status :=
                                     l_tax_rec.legal_reporting_status_def_val;
            END IF;
          END IF;

          -- populate applicability_rule_flag
          --
          IF l_tax_rec.applicability_rule_flag = 'Y' THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_applicability_result_id :=
                                                    l_applicability_result_id;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).legal_message_appl_2 :=
              ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id(
                                                   l_applicability_result_id,
                                                   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_date(p_trx_line_index));
          END IF;
          IF l_tax_rec.direct_rate_rule_flag = 'Y' AND
                l_direct_rate_result_id IS NOT NULL   AND -- Bug 6816250, add NVL
                NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 l_new_row_num).last_manual_entry,'X') NOT IN ('TAX_RATE','TAX_AMOUNT')
          THEN

            -- Populate direct_rate_rule_flag, as well as tax_status_code
            -- and tax_rate_code if direct_rate is applicable.
            --
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).direct_rate_result_id := l_direct_rate_result_id;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 l_new_row_num).tax_status_code :=
                                       l_direct_rate_result_rec.status_result;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 l_new_row_num).tax_rate_code :=
                                         l_direct_rate_result_rec.rate_result;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 l_new_row_num).legal_message_rate:=
                ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id(l_direct_rate_result_id,
                      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_date(p_trx_line_index));


            -- populate tax_status_id
            --
            ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                                l_tax_rec.tax,
                                l_tax_rec.tax_regime_code,
                                l_direct_rate_result_rec.status_result,
                                p_tax_determine_date,
                                l_tax_status_rec,
                                x_return_status,
                                l_error_buffer);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF (g_level_error >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                       'Incorrect return_status after calling '||
                       'ZX_TDS_UTILITIES_PKG.get_tax_rate_info.');
                FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                       'RETURN_STATUS = ' || x_return_status);
                FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.END',
                       'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(-)');
              END IF;
                           --  Bug 4959835: Since this cursor is moved, commenting this out
               -- CLOSE get_key_columns_cur;
              RETURN;
            END IF;

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                     l_new_row_num).tax_status_id :=
                                            l_tax_status_rec.tax_status_id;
          END IF;

          -- populate rounding_lvl_party_tax_prof_id and rounding_level_code
          --
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).rounding_lvl_party_tax_prof_id :=
                    ZX_TDS_CALC_SERVICES_PUB_PKG.g_rnd_lvl_party_tax_prof_id;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).rounding_level_code :=
                               ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).rounding_lvl_party_type :=
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_lvl_party_type;

          -- populate hq_estb_party_tax_prof_id
          --
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).hq_estb_party_tax_prof_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hq_estb_party_tax_prof_id(
                                                                p_trx_line_index);

          -- populate tax registration info
          --
          populate_registration_info(
                p_event_class_rec      => p_event_class_rec,
                p_trx_line_index       => p_trx_line_index,
                p_rownum                 => l_new_row_num,
                p_def_reg_type         => l_tax_rec.def_registr_party_type_code,
                p_reg_rule_flg         => l_tax_rec.registration_type_rule_flag,
                p_tax_determine_date   => p_tax_determine_date,
                x_return_status        => x_return_status);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info');
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(-)');
            END IF;
            RETURN;
          END IF;

          -- If orig_tax_amt_included_flag/orig_self_assessed_flag is not NULL
          -- (for UPDATE), populate tax_amt_included_flag/self_assessed_flag
          -- fetched from zx_lines. Otherwise, keep tax_amt_included_flag/
          -- self_assessed_flag returned from get_tax_registration
          --
          IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).orig_tax_amt_included_flag IS NOT NULL THEN
             ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_amt_included_flag := l_tax_amt_included_flag;
          END IF;

          IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       l_new_row_num).orig_self_assessed_flag IS NOT NULL THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                   l_new_row_num).self_assessed_flag := l_self_assessed_flag;
          END IF;

          -- populate rounding_rule_code if it is null
          --
          IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                l_new_row_num).rounding_rule_code IS NULL THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).rounding_rule_code := l_tax_rec.rounding_rule_code;
          END IF;

          -- If the value of p_event_class_rec.self_assess_tax_lines_flag
          -- is 'N', populate self_assessed_flg to 'N'
          --
          IF NVL(p_event_class_rec.self_assess_tax_lines_flag, 'N') = 'N'
          THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                    l_new_row_num).self_assessed_flag := 'N';
          END IF;

          -- Bug 4277751: For intercompany transaction, detail tax lines from
          -- addintional applicability process should be marked as
          -- self assessed
          --
          -- Bug 5705976: Since, we stamp 'INTERCOMPANY_TRX' on both AR and AP
          -- transactions, the following code has become incorrect.
          --
/*
          IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                 p_trx_line_index) IN ('CREATE', 'UPDATE') AND
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(
                                 p_trx_line_index) = 'INTERCOMPANY_TRX'
          THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                    l_new_row_num).self_assessed_flag := 'Y';
          END IF;
*/
          -- If the value of p_event_class_rec.tax_recovery_flag is 'N',
          -- populate process_for_recovery_flag to 'N'. If it is 'Y', check
          -- reporting_only_flag to set tax_recovery_flag
          --
          /*
           * call populate_recovery_flg in ZX_TDS_TAX_LINES_POPU_PKG instead
           *
           * IF NVL(p_event_class_rec.tax_recovery_flag, 'N') = 'N' THEN
           *   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           *                   l_new_row_num).process_for_recovery_flag := 'N';
           * ELSE
           *  IF NVL(l_tax_rec.reporting_only_flag, 'N') <> 'Y' THEN
           *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           *                  l_new_row_num).process_for_recovery_flag := 'Y';
           *   ELSE
           *    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           *                  l_new_row_num).process_for_recovery_flag := 'N';
           *   END IF;
           * END IF;
           */

          /* Move to ZX_TDS_TAXABLE_BASIS_DETM_PKG
           *
           * -- Populate tax_inclusion_flag and line_amt_includes_tax_flag
           * --
           * IF (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(
           *                                           p_trx_line_index) = 'A') THEN
           *   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           *                           l_new_row_num).tax_amt_included_flag := 'Y';
           *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           *                         l_new_row_num).line_amt_includes_tax_flag := 'A';
           *
           * ELSIF(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(
           *                                        p_trx_line_index) = 'N') THEN
           *   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           *                             l_new_row_num).tax_amt_included_flag := 'N';
           *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           *                         l_new_row_num).line_amt_includes_tax_flag := 'N';
           *
           * ELSIF(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(
           *                                    p_trx_line_index) IN ('S', 'I')) THEN
           *   -- Remain the value of tax_inclusion_flag returned by
           *   -- get_tax_regostration and set line_amt_includes_tax_flag to 'STANDARD'
           *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           *                 l_new_row_num).line_amt_includes_tax_flag := 'S';
           *   NULL;
           * END IF;
         */
          -- populate Tax_Only_Line_Flag if line_level_action is 'CREATE_TAX_ONLY'
          --
          IF (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                   p_trx_line_index) = 'CREATE_TAX_ONLY') THEN

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                      l_new_row_num).tax_only_line_flag := 'Y';
          END IF;
        END IF;       -- l_tax_applicable
      END IF;         -- l_tax_tbl_subscript IS NULL
    END LOOP;         -- l_tax_rec IN get_all_taxes_for_regime_cur

    IF (x_begin_index is NOT NULL) THEN
      x_end_index :=
         NVL( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);
    END IF;

    -- If p_event_class_rec.enforce_tax_from_ref_doc_flag = 'Y' AND
    -- trx_line_dist_tbl.ref_doc_application_id(p_trx_line_index) IS NOT NULL,
    -- get tax rate code from refefence document
    --
    IF p_event_class_rec.enforce_tax_from_ref_doc_flag = 'Y' AND
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(
                                                  p_trx_line_index) IS NOT NULL
    THEN

      enforce_tax_from_ref_doc(
                                  x_begin_index,
                                  x_end_index,
                                  p_trx_line_index,
                                  x_return_status);

          /* Bug 4959835: Moved the following as a private procedure for STCC req
      FOR i IN NVL(x_begin_index, -1) .. NVL(x_end_index, 0) LOOP

        OPEN enforce_rate_code_from_ref_doc(
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax,
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_regime_code);

        FETCH enforce_rate_code_from_ref_doc INTO
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_status_code,
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_code,
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                           i).other_doc_line_amt,
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                       i).other_doc_line_tax_amt,
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                   i).other_doc_line_taxable_amt;

        IF enforce_rate_code_from_ref_doc%FOUND THEN

          -- populate copied_from_other_doc_flag and other_doc_source
          --
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         i).copied_from_other_doc_flag := 'Y';
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                           i).other_doc_source := 'REFERENCE';

          IF g_level_statement >= g_current_runtime_level THEN

            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
               'p_event_class_rec.enforce_tax_from_ref_doc_flag = Y. '||
               'get tax rate code from reference document');
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
               'From reference document: tax_status_code = '||
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                         i).tax_status_code);
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
               'From reference document: tax_rate_code = '||
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                         i).tax_rate_code);
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
               'other_doc_line_amt = '||
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                      i).other_doc_line_amt);
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
               'other_doc_line_tax_amt = '||
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                  i).other_doc_line_tax_amt);
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
               'other_doc_line_taxable_amt = '||
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                              i).other_doc_line_taxable_amt);
          END IF;
        ELSE
          IF g_level_statement >= g_current_runtime_level THEN
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
               'enforce_tax_from_ref_doc_flag is turned on, but tax status'||
               'code and tax rate code are not available from reference doc.');
          END IF;
        END IF;

        CLOSE enforce_rate_code_from_ref_doc;

      END LOOP;  -- i IN NVL(x_begin_index, -1) .. NVL(x_end_index, 0)
      End: enforce tax from doc - Bug 4959835 */
    END IF;      -- p_event_class_rec.enforce_tax_from_ref_doc_flag = 'Y'

    -- copy transaction info to new tax lines
    --
    ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines (p_trx_line_index,
                                                       x_begin_index,
                                                       x_end_index,
                                                       x_return_status,
                                                       l_error_buffer );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
               'Incorrect RETURN_STATUS after calling '||
               'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.END',
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(-)');
      END IF;
      RETURN;
    END IF;
  END IF;   -- line_level_action = 'CREATE', 'UPDATE', 'CREATE_TAX_ONLY'

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(-)'||'RETURN_STATUS = ' || x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_begin_index := NULL;
    x_end_index := NULL;
    IF (get_all_taxes_for_regime_cur%ISOPEN) THEN
      CLOSE get_all_taxes_for_regime_cur;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(-)');
    END IF;

END get_applicable_taxes;

----------------------------------------------------------------------
--  PROCEDURE
--   get_det_tax_lines_from_applied
--
--  DESCRIPTION
--
--  This procedure get detail tax lines from applied from document
--
--  IN      p_trx_line_index
--
--  IN OUT NOCOPY
--          x_begin_index
--          x_end_index
--  OUT NOCOPY     x_return_status

PROCEDURE get_det_tax_lines_from_applied(
  p_event_class_rec        IN                   zx_api_pub.event_class_rec_type,
  p_trx_line_index         IN                   BINARY_INTEGER,
  p_tax_date               IN                   DATE,
  p_tax_determine_date     IN                   DATE,
  p_tax_point_date         IN                   DATE,
  x_begin_index            IN OUT NOCOPY        BINARY_INTEGER,
  x_end_index              IN OUT NOCOPY        BINARY_INTEGER,
  x_return_status          OUT NOCOPY           VARCHAR2) IS

 CURSOR get_tax_lines IS
   SELECT * FROM zx_lines
    WHERE application_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index)
      AND entity_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(p_trx_line_index)
      AND event_class_code  =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(p_trx_line_index)
      AND trx_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(p_trx_line_index)
      AND trx_line_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(p_trx_line_index)
      AND trx_level_type =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(p_trx_line_index)
      AND tax_provider_id IS NULL
      AND Cancel_Flag<> 'Y'
      --AND offset_link_to_tax_line_id IS NULL Bug 8517610
      AND mrc_tax_line_flag = 'N';

 l_new_row_num                  NUMBER;
 l_begin_index                  BINARY_INTEGER;
 l_error_buffer                 VARCHAR2(200);
 l_line_amt_current             NUMBER;
 l_status_rec                   ZX_TDS_UTILITIES_PKG.ZX_STATUS_INFO_REC;
 l_applied_amt_handling_flag    ZX_TAXES_B.APPLIED_AMT_HANDLING_FLAG%TYPE;

 l_orig_amt                     NUMBER;
 l_appl_tax_amt                 NUMBER;
 l_appl_line_amt                NUMBER;
 l_unrounded_tax_amt            NUMBER;

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied.BEGIN',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied(+)'|| 'p_trx_line_index = ' || to_char(p_trx_line_index));
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- initialize l_new_row_num
  --
  l_new_row_num := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);

  -- get the begin_index for tax lines created in this procedure
  --
  l_begin_index := l_new_row_num + 1;

  FOR tax_line_rec in get_tax_lines LOOP

    -- populate tax cache ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl with this tax_id,
    -- if it does not exists there.
    --
    ZX_TDS_UTILITIES_PKG.populate_tax_cache (
                p_tax_id         => tax_line_rec.tax_id,
                p_return_status  => x_return_status,
                p_error_buffer   => l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.populate_tax_cache()');
        FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied',
                 'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied(-)');
      END IF;

      RETURN;
    END IF;

    -- increment l_new_row_num
    --
    l_new_row_num := l_new_row_num +1;

    -- Populate the tax_line_id with Sequence
    --
    /*
     * will be populated by pop_tax_line_for_trx_line
     *
     * SELECT zx_lines_s.NEXTVAL
     *  INTO ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *        l_new_row_num).tax_line_id from dual;
     */
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_new_row_num).tax_line_id := NULL;

    -- populate tax related information from tax_line_rec
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_regime_id := tax_line_rec.tax_regime_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                   l_new_row_num).tax_regime_code:=tax_line_rec.tax_regime_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_new_row_num).tax_id := tax_line_rec.tax_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                        l_new_row_num).tax := tax_line_rec.tax;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                   l_new_row_num).tax_status_code:=tax_line_rec.tax_status_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).multiple_jurisdictions_flag :=
                                       tax_line_rec.multiple_jurisdictions_flag;
  BEGIN
    SELECT applied_amt_handling_flag INTO l_applied_amt_handling_flag
    FROM zx_taxes_b_tmp
    WHERE tax_id = tax_line_rec.tax_id;

    IF l_applied_amt_handling_flag = 'P'  --Bug 5650193
    THEN
	  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).tax_rate_type :=
                                       tax_line_rec.tax_rate_type;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied',
                 'Could Not Reterive a Row for the Tax Id'||tax_line_rec.tax_id);
     END IF;
  END;


    -- bug 5077691: populate legal_reporting_status
    IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).legal_reporting_status :=
                      ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                            tax_line_rec.tax_id).legal_reporting_status_def_val;
    END IF;

    -- For prepayment trx, tax lines are fetched from the original document and status codes
    -- are copied to the new tax lines.  However, since tax determiniation date most likely
    -- are different for the current document, the status id will need to be repopulated.

    ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                    tax_line_rec.tax,
                    tax_line_rec.tax_regime_code,
                    tax_line_rec.tax_status_code,
                    p_tax_determine_date,
                    l_status_rec,
                    x_return_status,
                    l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied',
               'Incorrect return_status after calling ' ||
               'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info()');
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied.END',
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied(-)');
      END IF;

      --
      -- add error message before return
      --
       FND_MESSAGE.SET_NAME('ZX','ZX_STATUS_NOT_FOUND');
       FND_MESSAGE.SET_TOKEN('TAX',tax_line_rec.tax);

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

      ZX_API_PUB.add_msg(
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

      RETURN;
    END IF;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).tax_status_id := l_status_rec.tax_status_id;

    -- populate taxable_basis_formula and tax_calculation_formula
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               l_new_row_num).taxable_basis_formula :=
                                              tax_line_rec.taxable_basis_formula;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               l_new_row_num).tax_calculation_formula :=
                                            tax_line_rec.tax_calculation_formula;

    -- 1. If applied_amt_handling_flag ='P', populate tax rate percentage from
    --    applied from document. Tax is proarted based the amount applied.
    -- 2. If applied_amt_handling_flag ='R', populate tax rate Code from
    --    applied document. Tax rate is determined in the current document.
    --    Tax is recalculated based one the tax rate in the current document.

    IF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
         tax_line_rec.tax_id).applied_amt_handling_flag = 'P' THEN

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_rate_code := tax_line_rec.tax_rate_code;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).tax_rate_id := tax_line_rec.tax_rate_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              l_new_row_num).tax_rate :=  tax_line_rec.tax_rate;

      -- 5758785: copy tax_currency_conversion_date,tax_currency_conversion_type
      --          and tax_currency_conversion_rate from prepayment document
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).tax_currency_conversion_date :=
                                       tax_line_rec.tax_currency_conversion_date;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).tax_currency_conversion_type :=
                                       tax_line_rec.tax_currency_conversion_type;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).tax_currency_conversion_rate :=
                                       tax_line_rec.tax_currency_conversion_rate;

    ELSIF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
         tax_line_rec.tax_id).applied_amt_handling_flag = 'R' THEN

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_rate_code := tax_line_rec.tax_rate_code;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_currency_conversion_date := p_tax_determine_date;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).tax_currency_conversion_type :=
                                       tax_line_rec.tax_currency_conversion_type;

      -- prorate prd_total_tax_amt, prd_total_tax_amt_tax_curr and
      -- prd_total_tax_amt_funcl_curr
      --
      l_line_amt_current :=
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index);

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).prd_total_tax_amt := tax_line_rec.tax_amt *
                                     (l_line_amt_current/tax_line_rec.line_amt);
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_new_row_num).prd_total_tax_amt_tax_curr :=
                               tax_line_rec.tax_amt_tax_curr *
                                       l_line_amt_current/tax_line_rec.line_amt;

--      IF tax_line_rec.tax_amt_funcl_curr IS NOT NULL THEN
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_new_row_num).prd_total_tax_amt_funcl_curr :=
                               tax_line_rec.tax_amt_funcl_curr *
                                       l_line_amt_current/tax_line_rec.line_amt;

        -- do rounding. May be moved to rounding package later
        --
        IF tax_line_rec.ledger_id IS NOT NULL THEN
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                 l_new_row_num).prd_total_tax_amt_funcl_curr :=
            ZX_TRD_SERVICES_PUB_PKG.round_amt_to_mau (
                  tax_line_rec.ledger_id,
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_new_row_num).prd_total_tax_amt_funcl_curr);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied',
                 'Incorrect return_status after calling ' ||
                 'ZX_TRD_SERVICES_PUB_PKG.round_amt_to_mau');
              FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied',
                 'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied.END',
                 'ZX_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied(-)');
            END IF;
            RETURN;
          END IF;

        END IF;       -- tax_line_rec.ledger_id IS NOT NULL
--      END IF;         -- tax_line_rec.tax_amt_funcl_curr IS NOT NULL
    END IF;           -- applied_amt_handling_flag = 'P' or 'R'

    -- If the value of p_event_class_rec.tax_recovery_flag is 'N',
    -- populate process_for_recovery_flag to 'N'
    --
    /*
     * call populate_recovery_flg in ZX_TDS_TAX_LINES_POPU_PKG instead
     *
     * IF NVL(p_event_class_rec.tax_recovery_flag, 'N') = 'N' THEN
     *   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                          l_new_row_num).process_for_recovery_flag := 'N';
     * ELSE
     *   IF tax_line_rec.reporting_only_flag <> 'Y' THEN
     *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                          l_new_row_num).process_for_recovery_flag := 'Y';
     *  ELSE
     *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                          l_new_row_num).process_for_recovery_flag := 'N';
     *   END IF;
     * END IF;
     */

    -- Populate other doc line amt, taxable amt and tax amt
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).other_doc_line_amt := tax_line_rec.line_amt;

    -- bug 7024219
    IF NVL(tax_line_rec.historical_flag, 'N') = 'Y' THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).other_doc_line_taxable_amt :=
              NVL(tax_line_rec.unrounded_taxable_amt, tax_line_rec.taxable_amt);
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).other_doc_line_tax_amt :=
                      NVL(tax_line_rec.unrounded_tax_amt, tax_line_rec.tax_amt);
    ELSE

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).other_doc_line_taxable_amt :=
                                            tax_line_rec.unrounded_taxable_amt;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).other_doc_line_tax_amt :=
                                                tax_line_rec.unrounded_tax_amt;
    END IF;

    -- Set copied_from_other_doc_flag to 'Y'
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               l_new_row_num).copied_from_other_doc_flag := 'Y';

    -- set other_doc_source
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              l_new_row_num).other_doc_source := 'APPLIED_FROM';
    --
    -- Bug#7302008 (Fusion Bug#7301957)- populate unrounded taxable amt  and unrounded tax amt
    --
    IF ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
         tax_line_rec.tax_id).applied_amt_handling_flag = 'P' THEN

      -- set unrounded taxable amt  and unrounded tax amt
      --
      -- bug#8203772
      -- check if the prepayment is being applied finally
      -- If yes, then get the tax amt remaning and set it to this
      -- do this check only for Payables.

      l_unrounded_tax_amt := NULL;

      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index) = 200 THEN
        SELECT line_amt
        INTO l_orig_amt
        FROM zx_lines_det_factors
        WHERE application_id =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index)
        AND entity_code =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(p_trx_line_index)
        AND event_class_code  =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(p_trx_line_index)
        AND trx_id =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(p_trx_line_index)
        AND trx_line_id =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(p_trx_line_index)
        AND trx_level_type =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(p_trx_line_index);

        SELECT sum(line_amt)
        INTO l_appl_line_amt
        FROM zx_lines_det_factors
        WHERE applied_from_application_id =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index)
        AND applied_from_entity_code =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(p_trx_line_index)
        AND applied_from_event_class_code  =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(p_trx_line_index)
        AND applied_from_trx_id =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(p_trx_line_index)
        AND applied_from_line_id =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(p_trx_line_index)
        AND applied_from_trx_level_type =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(p_trx_line_index);

        SELECT sum(tax_amt)
        INTO l_appl_tax_amt
        FROM zx_lines
        WHERE applied_from_application_id =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index)
        AND applied_from_entity_code =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(p_trx_line_index)
        AND applied_from_event_class_code  =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(p_trx_line_index)
        AND applied_from_trx_id =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(p_trx_line_index)
        AND applied_from_line_id =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(p_trx_line_index)
        AND applied_from_trx_level_type =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(p_trx_line_index)
        AND tax_provider_id IS NULL
        AND Cancel_Flag <> 'Y'
        --AND offset_link_to_tax_line_id IS NULL
        AND mrc_tax_line_flag = 'N';

        IF l_orig_amt + (l_appl_line_amt + ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index)) <= 0 THEN
          -- Final Application
          IF (tax_line_rec.tax_amt + l_appl_tax_amt >= 0)
           THEN
            l_unrounded_tax_amt := sign(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index)) *
                                   (tax_line_rec.tax_amt + l_appl_tax_amt);
          END IF;
        END IF;
      ELSE
        l_unrounded_tax_amt := NULL;
      END IF;
      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_amt <> 0 THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt:=
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_taxable_amt *
                     ( ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) /
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_amt );

         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt:=

              NVL(l_unrounded_tax_amt,
              Round(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_tax_amt *
                     ( ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) /
                            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_amt ), 20));


      ELSE   -- other_doc_line_amt = 0 OR IS NULL
         -- copy unrounded_taxable_amt from reference document,
         --
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt :=
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_taxable_amt;

         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt :=
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_line_tax_amt;

      END IF;       -- other_doc_line_amt <> 0

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_amt:= NULL;

    END IF;
   /* end  changes for Bug#7302008 (Fusion Bug#7301957) */


    -- populate WHO columns
    --
    /*
     * WHO columns will be populated by pop_tax_line_for_trx_line in
     * ZX_TDS_TAX_LINES_POPU_PKG
     *
     * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                           l_new_row_num).CREATED_BY  := fnd_global.user_id;
     * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                                   l_new_row_num).CREATION_DATE :=  sysdate;
     * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                       l_new_row_num).LAST_UPDATED_BY := fnd_global.user_id;
     * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                                l_new_row_num).LAST_UPDATE_DATE :=  sysdate;
     * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                    l_new_row_num).last_update_login := fnd_global.login_id;
     */

    -- populate other columns
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).rounding_level_code := tax_line_rec.rounding_level_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).rounding_rule_code := tax_line_rec.rounding_rule_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                          l_new_row_num).tax_date := p_tax_date;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).tax_determine_date := p_tax_determine_date;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              l_new_row_num).tax_point_date := p_tax_point_date;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).offset_flag := tax_line_rec.offset_flag;

    --bug8517610
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).offset_tax_rate_code := tax_line_rec.offset_tax_rate_code;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).place_of_supply := tax_line_rec.place_of_supply;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
       l_new_row_num).place_of_supply_type_code :=
                                          tax_line_rec.place_of_supply_type_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).place_of_supply_result_id :=
                                        tax_line_rec.place_of_supply_result_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).legal_message_pos:=
                                                tax_line_rec.legal_message_pos;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_currency_code := tax_line_rec.tax_currency_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).tax_type_code := tax_line_rec.tax_type_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          l_new_row_num).reporting_only_flag := tax_line_rec.reporting_only_flag;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).tax_jurisdiction_code :=
                                            tax_line_rec.tax_jurisdiction_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        l_new_row_num).tax_jurisdiction_id := tax_line_rec.tax_jurisdiction_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).tax_registration_number :=
                                         tax_line_rec.tax_registration_number;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).registration_party_type :=
                                         tax_line_rec.registration_party_type;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).tax_applicability_result_id :=
                                       tax_line_rec.tax_applicability_result_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).legal_message_appl_2 :=
                                       tax_line_rec.legal_message_appl_2;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).direct_rate_result_id :=
                                            tax_line_rec.direct_rate_result_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).rounding_lvl_party_tax_prof_id :=
                                   tax_line_rec.rounding_lvl_party_tax_prof_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       l_new_row_num).rounding_lvl_party_type :=
                                          tax_line_rec.rounding_lvl_party_type;
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
--         l_new_row_num).merchant_party_tax_reg_number :=
--                                    tax_line_rec.merchant_party_tax_reg_number;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          l_new_row_num).self_assessed_flag := tax_line_rec.self_assessed_flag;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_new_row_num).tax_reg_num_det_result_id :=
                                       tax_line_rec.tax_reg_num_det_result_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_new_row_num).legal_message_trn :=
                                       tax_line_rec.legal_message_trn;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
       l_new_row_num).tax_amt_included_flag := tax_line_rec.tax_amt_included_flag;
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
--                         l_new_row_num).line_amt_includes_tax_flag :=
--                                          tax_line_rec.line_amt_includes_tax_flag;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
       l_new_row_num).manually_entered_flag := tax_line_rec.manually_entered_flag;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).Tax_Only_Line_Flag := tax_line_rec.tax_only_line_flag;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).tax_provider_id := tax_line_rec.tax_provider_id;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_new_row_num).hq_estb_reg_number :=
                                        tax_line_rec.hq_estb_reg_number;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_new_row_num).hq_estb_party_tax_prof_id :=
                                        tax_line_rec.hq_estb_party_tax_prof_id;

    -- bug 6815566:
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).tax_apportionment_line_number :=
                                      tax_line_rec.tax_apportionment_line_number;

    -- Bug 8992240

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).orig_tax_amt_included_flag :=
                                      tax_line_rec.orig_tax_amt_included_flag;
    -- Bug 7117340 -- DFF ER
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute1 := tax_line_rec.attribute1;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute2 := tax_line_rec.attribute2;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute3 := tax_line_rec.attribute3;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute4 := tax_line_rec.attribute4;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute5 := tax_line_rec.attribute5;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute6 := tax_line_rec.attribute6;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute7 := tax_line_rec.attribute7;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute8 := tax_line_rec.attribute8;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute9 := tax_line_rec.attribute9;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute10 := tax_line_rec.attribute10;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute11 := tax_line_rec.attribute11;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute12 := tax_line_rec.attribute12;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute13 := tax_line_rec.attribute13;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute14 := tax_line_rec.attribute14;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute15 := tax_line_rec.attribute15;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute_category:= tax_line_rec.attribute_category;

    IF (x_begin_index IS NULL) THEN
      x_begin_index := l_new_row_num;
    END IF;
  END LOOP;   -- FOR tax_line_rec in get_tax_lines

  IF (x_begin_index IS NOT NULL) THEN
    x_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;
  END IF;

  -- copy transaction info to new tax lines for new tax_lines created here
  --
  ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines(
                                p_trx_line_index ,
                                l_begin_index,
                                x_end_index,
                                x_return_status,
                                l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
      FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied',
                 'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied.END',
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_applied(-)');
    END IF;

END  get_det_tax_lines_from_applied;

----------------------------------------------------------------------
--  PROCEDURE
--   get_det_tax_lines_from_adjust
--
--  DESCRIPTION
--
--  This procedure get detail tax lines from adjusted to document
--  AR won't call etax for adjustment to historical transactions.
--
--  IN      p_transaction_line_tbl
--          p_trx_line_index
--  IN OUT NOCOPY  p_detail_tax_lines_tbl
--          x_begin_index
--          x_end_index
--  OUT NOCOPY     x_return_status


PROCEDURE get_det_tax_lines_from_adjust (
  p_event_class_rec         IN            zx_api_pub.event_class_rec_type,
  p_trx_line_index          IN             BINARY_INTEGER,
  p_tax_date                IN             DATE,
  p_tax_determine_date      IN             DATE,
  p_tax_point_date          IN             DATE,
  x_begin_index             IN OUT NOCOPY  BINARY_INTEGER,
  x_end_index               IN OUT NOCOPY  BINARY_INTEGER,
  x_return_status           OUT NOCOPY     VARCHAR2) IS

 CURSOR   get_tax_lines IS
   SELECT * FROM zx_lines
    WHERE application_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_trx_line_index)
      AND entity_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(p_trx_line_index)
      AND event_class_code  =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(p_trx_line_index)
      AND trx_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id( p_trx_line_index)
      AND trx_line_id =
          NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(
                                                                    p_trx_line_index), trx_line_id)
      AND trx_level_type =
          NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(
                                                                 p_trx_line_index), trx_level_type)
/* Bug 5131206:
   For partner integration, when the line_level_action is 'ALLOCATE_TAX_ONLY_ADJUSTMENT',
   eBTax needs to create prorated tax lines.
   In other cases, partner tax lines should be excluded.
*/
--      AND tax_provider_id IS  NULL
      AND (tax_provider_id IS NULL
           OR ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_trx_line_index) = 'ALLOCATE_TAX_ONLY_ADJUSTMENT'
           OR ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_index) = 'ADJUSTMENTS')
      AND Cancel_Flag <> 'Y'
     --Bug 8493615 AND offset_link_to_tax_line_id IS NULL
      AND mrc_tax_line_flag = 'N';

 -- Bug 5675944 : Retain tax_line_id for UPDATE
 -- Bug 7597449 Added Tax apportionment line number to pick the correct tax line id for upgraded invoices which have same regime-tax information.
 CURSOR get_key_columns_cur
           (c_tax_regime_code   zx_regimes_b.tax_regime_code%TYPE,
            c_tax               zx_taxes_b.tax%TYPE,
            c_apportionment_line_number  zx_lines.tax_apportionment_line_number%type) IS
    SELECT * FROM zx_lines
     WHERE application_id = p_event_class_rec.application_id
       AND entity_code = p_event_class_rec.entity_code
       AND event_class_code = p_event_class_rec.event_class_code
       AND trx_id = p_event_class_rec.trx_id
       AND trx_line_id =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index)
       AND trx_level_type =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index)
       AND tax_regime_code = c_tax_regime_code
       AND tax = c_tax
       AND tax_apportionment_line_number = c_apportionment_line_number
       AND mrc_tax_line_flag = 'N';

 l_tax_line_rec                 zx_lines%ROWTYPE;
 l_new_row_num                  NUMBER;
 l_begin_index                  BINARY_INTEGER;
 l_error_buffer                 VARCHAR2(200);

 l_cm_manual_flag               VARCHAR2(1);

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust.BEGIN',
       'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust(+)'|| 'trx_line_index = ' || to_char(p_trx_line_index));
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_new_row_num := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);
  l_begin_index := l_new_row_num + 1;

  FOR tax_line_rec in get_tax_lines LOOP

   -- populate tax cache ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl with this tax_id,
    -- if it does not exists there.
    --
    ZX_TDS_UTILITIES_PKG.populate_tax_cache (
                p_tax_id         => tax_line_rec.tax_id,
                p_return_status  => x_return_status,
                p_error_buffer   => l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust',
           'Incorrect return_status after calling ' ||
           'ZX_TDS_UTILITIES_PKG.populate_tax_cache()');
        FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust',
           'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust.END',
           'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust(-)');
      END IF;

      RETURN;
    END IF;

    --increment l_new_row_num
    --
    l_new_row_num := l_new_row_num +1;

    -- Populate the tax_line_id with Sequence
    --
    /*
     * will be populated by pop_tax_line_for_trx_line
     *
     * SELECT zx_lines_s.NEXTVAL
     *  INTO ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *        l_new_row_num).tax_line_id from dual;
     */

    -- bug 5675944: retain tax_line_id for UPDATE
    --
    IF p_event_class_rec.tax_event_type_code = 'UPDATE' AND
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_trx_line_index) IN ('UPDATE','CREATE_WITH_TAX')
    THEN
      OPEN get_key_columns_cur(tax_line_rec.tax_regime_code, tax_line_rec.tax,tax_line_rec.tax_apportionment_line_number); -- Bug7597449

      FETCH get_key_columns_cur INTO l_tax_line_rec;

      IF get_key_columns_cur%FOUND THEN
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       l_new_row_num).tax_line_id := l_tax_line_rec.tax_line_id;
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).associated_child_frozen_flag :=
                                    l_tax_line_rec.associated_child_frozen_flag;
	 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).manually_entered_flag :=
                                    l_tax_line_rec.manually_entered_flag;
	 ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).summary_tax_line_id :=
                                    l_tax_line_rec.summary_tax_line_id;


	 -- if CM has a manual tax line which was not copied from the invoice.
	 IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).manually_entered_flag = 'Y'
	    AND l_tax_line_rec.copied_from_other_doc_flag = 'N'
	 THEN
           l_cm_manual_flag := 'Y';
	   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).copied_from_other_doc_flag :=
                                    l_tax_line_rec.copied_from_other_doc_flag;
           ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).other_doc_source :=
                                    l_tax_line_rec.other_doc_source;
	   IF p_event_class_rec.allow_manual_lin_recalc_flag ='Y' THEN
	     IF l_tax_line_rec.line_amt <> 0 THEN
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                    := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                       (NVL(l_tax_line_rec.unrounded_taxable_amt,l_tax_line_rec.taxable_amt) / l_tax_line_rec.line_amt);
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                    := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                       (NVL(l_tax_line_rec.unrounded_tax_amt,l_tax_line_rec.tax_amt) / l_tax_line_rec.line_amt );
             ELSE
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                    := NVL(l_tax_line_rec.unrounded_taxable_amt,l_tax_line_rec.taxable_amt);
               ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                    := NVL(l_tax_line_rec.unrounded_tax_amt,l_tax_line_rec.tax_amt);
             END IF;
           ELSE
             ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                    := NVL(l_tax_line_rec.unrounded_taxable_amt,l_tax_line_rec.taxable_amt);
             ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                    := NVL(l_tax_line_rec.unrounded_tax_amt,l_tax_line_rec.tax_amt);
           END IF;
	 END IF;
      ELSE
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_new_row_num).tax_line_id := NULL;
	ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).manually_entered_flag :=
                                    tax_line_rec.manually_entered_flag;
      END IF;
      close get_key_columns_cur; --Bug 5844597
    ELSE
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_new_row_num).tax_line_id := NULL;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).manually_entered_flag :=
                                    tax_line_rec.manually_entered_flag;
    END IF;

    -- populate tax related information from tax_line_rec
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_regime_id := tax_line_rec.tax_regime_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                   l_new_row_num).tax_regime_code:=tax_line_rec.tax_regime_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_new_row_num).tax_id := tax_line_rec.tax_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                        l_new_row_num).tax := tax_line_rec.tax;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_status_id := tax_line_rec.tax_status_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                   l_new_row_num).tax_status_code:=tax_line_rec.tax_status_code;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_rate_code := tax_line_rec.tax_rate_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).tax_rate_id := tax_line_rec.tax_rate_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                             l_new_row_num).tax_rate :=  tax_line_rec.tax_rate;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                             l_new_row_num).tax_rate_type :=  tax_line_rec.tax_rate_type; --Bug 5650193


   -- Bug#6729097 --
   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_apportionment_line_number := tax_line_rec.tax_apportionment_line_number;

 IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust',
           'Tax Apportionment Line Number: Bug6729097 ' ||
           to_char(tax_line_rec.tax_apportionment_line_number));
 END IF;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).multiple_jurisdictions_flag :=
                                      tax_line_rec.multiple_jurisdictions_flag;

    -- bug 5508356: populate account_source_tax_rate_id
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_new_row_num).account_source_tax_rate_id :=
                                        tax_line_rec.account_source_tax_rate_id;

    -- bug 5077691: populate legal_reporting_status
    IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).legal_reporting_status :=
                      ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                            tax_line_rec.tax_id).legal_reporting_status_def_val;
    END IF;

    -- If the value of p_event_class_rec.tax_recovery_flag is 'N',
    -- populate process_for_recovery_flag to 'N'. If it is 'Y', check
    -- reporting_only_flag to set tax_recovery_flag
    --
    /*
     * call populate_recovery_flg in ZX_TDS_TAX_LINES_POPU_PKG instead
     *
     * IF NVL(p_event_class_rec.tax_recovery_flag, 'N') = 'N' THEN
     *   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                          l_new_row_num).process_for_recovery_flag := 'N';
     * ELSE
     *   IF tax_line_rec.reporting_only_flag <> 'Y' THEN
     *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                          l_new_row_num).process_for_recovery_flag := 'Y';
     *  ELSE
     *     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                          l_new_row_num).process_for_recovery_flag := 'N';
     *   END IF;
     * END IF;
     */

    -- Populate other doc line amt, taxable amt and tax amt
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).other_doc_line_amt := tax_line_rec.line_amt;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).other_doc_line_taxable_amt :=
                                            tax_line_rec.unrounded_taxable_amt;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).other_doc_line_tax_amt :=
                                                tax_line_rec.unrounded_tax_amt;

    -- populate taxable_basis_formula and tax_calculation_formula
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               l_new_row_num).taxable_basis_formula :=
                                             tax_line_rec.taxable_basis_formula;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               l_new_row_num).tax_calculation_formula :=
                                           tax_line_rec.tax_calculation_formula;

    -- Set copied_from_other_doc_flag to 'Y'
    --
    IF NVL(l_cm_manual_flag, 'N') = 'N' THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               l_new_row_num).copied_from_other_doc_flag := 'Y';

    -- set other_doc_source
    --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              l_new_row_num).other_doc_source := 'ADJUSTED';
    END IF;

    -- populate WHO columns
    --
    /*
     * WHO columns will be populated by pop_tax_line_for_trx_line
     * in ZX_TDS_TAX_LINES_POPU_PKG
     *
     * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                           l_new_row_num).created_by  := fnd_global.user_id;
     * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                                    l_new_row_num).creation_date :=  sysdate;
     * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                        l_new_row_num).LAST_UPDATED_BY := fnd_global.user_id;
     * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                                 l_new_row_num).last_update_date :=  sysdate;
     * ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
     *                    l_new_row_num).last_update_login := fnd_global.login_id;
     *
     */

    -- populate other columns
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).rounding_level_code := tax_line_rec.rounding_level_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).rounding_rule_code := tax_line_rec.rounding_rule_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                          l_new_row_num).tax_date := p_tax_date;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).tax_determine_date := p_tax_determine_date;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              l_new_row_num).tax_point_date := p_tax_point_date;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_new_row_num).offset_flag := tax_line_rec.offset_flag;

    -- Bug 6776312
    /*IF NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).offset_flag,'Y') = 'Y' THEN
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).offset_flag := 'N';
    ELSE
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).offset_flag := 'Y';
    END IF;*/ --bug6929024

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).offset_tax_rate_code := tax_line_rec.offset_tax_rate_code;
    -- Bug 6776312

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).place_of_supply := tax_line_rec.place_of_supply;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
       l_new_row_num).place_of_supply_type_code :=
                                        tax_line_rec.place_of_supply_type_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).place_of_supply_result_id :=
                                        tax_line_rec.place_of_supply_result_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).legal_message_pos  :=
                                        tax_line_rec.legal_message_pos;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_currency_code := tax_line_rec.tax_currency_code;

/* Bug 5149379: When the trx currency is different from the tax currency,
                it is necessary to pick the tax_currency_conversion_date,
                tax_currency_conversion_type, tax_currency_conversion_rate
                information from the invoice tax lines.
*/
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_currency_conversion_date := tax_line_rec.tax_currency_conversion_date;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_currency_conversion_type := tax_line_rec.tax_currency_conversion_type;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_currency_conversion_rate := tax_line_rec.tax_currency_conversion_rate;

/* Bug 5131206: For partner integration, when the line_level_action is
                'ALLOCATE_TAX_ONLY_ADJUSTMENT', eBTax needs to create
                prorated tax lines and stamp the tax_provider_id on
                the tax line(s).
*/

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).tax_provider_id := tax_line_rec.tax_provider_id;

    if((ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_trx_line_index) = 'ALLOCATE_TAX_ONLY_ADJUSTMENT'
         OR ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_index) = 'ADJUSTMENTS') and
       tax_line_rec.tax_provider_id is not null ) THEN
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).SYNC_WITH_PRVDR_FLAG := 'Y';
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).global_attribute_category :=  tax_line_rec.global_attribute_category;
    end if;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).tax_type_code := tax_line_rec.tax_type_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          l_new_row_num).reporting_only_flag := tax_line_rec.reporting_only_flag;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).tax_jurisdiction_code :=
                                            tax_line_rec.tax_jurisdiction_code;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        l_new_row_num).tax_jurisdiction_id := tax_line_rec.tax_jurisdiction_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).tax_registration_number :=
                                         tax_line_rec.tax_registration_number;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       l_new_row_num).registration_party_type :=
                                         tax_line_rec.registration_party_type;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).tax_applicability_result_id :=
                                      tax_line_rec.tax_applicability_result_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).legal_message_appl_2 :=
                                      tax_line_rec.legal_message_appl_2;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).direct_rate_result_id :=
                                            tax_line_rec.direct_rate_result_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).legal_message_rate   :=
                                            tax_line_rec.legal_message_rate;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).rounding_lvl_party_tax_prof_id :=
                                   tax_line_rec.rounding_lvl_party_tax_prof_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       l_new_row_num).rounding_lvl_party_type :=
                                          tax_line_rec.rounding_lvl_party_type;
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
--         l_new_row_num).merchant_party_tax_reg_number :=
--                                    tax_line_rec.merchant_party_tax_reg_number;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
            l_new_row_num).Self_Assessed_Flag := tax_line_rec.self_assessed_flag;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_new_row_num).tax_reg_num_det_result_id :=
                                        tax_line_rec.tax_reg_num_det_result_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_new_row_num).legal_message_trn :=
                                        tax_line_rec.legal_message_trn;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_new_row_num).hq_estb_reg_number :=
                                        tax_line_rec.hq_estb_reg_number;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_new_row_num).hq_estb_party_tax_prof_id :=
                                        tax_line_rec.hq_estb_party_tax_prof_id;

    --   If line_amt_include_tax_flag on trx line is A, then set to 'Y'
    --   for other cases, set to the one from adjusted doc.
    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(
         p_trx_line_index) = 'A'
    THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).tax_amt_included_flag := 'Y';

    ELSE
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).tax_amt_included_flag
            := tax_line_rec.tax_amt_included_flag;
    END IF;

    --Bug 7133202 Added NVL for deriving unrounded taxable amt and unrounded tax amt. For migrated invoices unrounded taxable amt and unrounded tax amt can be NULL,so in this scenario taxable amt and tax amt values will be used for tax calculation.

  IF NVL(l_cm_manual_flag, 'N') = 'N' THEN
    IF NVL(tax_line_rec.historical_flag, 'N') = 'Y' THEN

      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
           p_trx_line_index) = 'ALLOCATE_TAX_ONLY_ADJUSTMENT'
      THEN

         -- for tax only adjustment set the unrounded tax amount to the
        -- unrounded tax amount of the original doc.
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).unrounded_taxable_amt := NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt);
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          l_new_row_num).unrounded_tax_amt := NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt);

      ELSE
        -- current trx is a regular adjustment or CM
        -- prorate the line amt to get the unrounded taxable/tax amount

        IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).tax_amt_included_flag ='Y'
          AND tax_line_rec.tax_amt_included_flag = 'N'
        THEN
          -- If current trx is a tax inclusive trx, while the original trx is
          -- tax exclusive trx.

          -- If-Else Condition added for Bug#8540809
          IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_total_hdr_tx_amt(p_trx_line_index) IS NOT NULL AND
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_hdr_tx_appl_flag(p_trx_line_index) = 'Y'
          THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).unrounded_taxable_amt
                  := tax_line_rec.unrounded_taxable_amt;

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).unrounded_tax_amt
                  :=  tax_line_rec.unrounded_tax_amt;
          ELSE
            IF ( tax_line_rec.line_amt + tax_line_rec.tax_amt) <> 0 THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).unrounded_taxable_amt
                  := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                    ( NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt) /
                      ( tax_line_rec.line_amt + tax_line_rec.tax_amt) );

              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).unrounded_tax_amt
                  := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                    (NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt) /
                      ( tax_line_rec.line_amt + tax_line_rec.tax_amt) );
            ELSE
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).unrounded_taxable_amt
                  := NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt);
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).unrounded_tax_amt
                  := NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt);
            END IF;
          END IF;
        ELSE -- both current tax line and original tax line are inclusive and exclusive
          IF tax_line_rec.line_amt <> 0 THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
              := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                (NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt) / tax_line_rec.line_amt);

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
              := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                (NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt) / tax_line_rec.line_amt );
          ELSE -- equal to that the original trx is a tax only trx
            IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index) = 'CREDIT_MEMO' THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                := -1 * NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt);
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                := -1 * NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt);
            ELSE
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                := NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt);
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                := NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt);
            END IF;
          END IF;
        END IF; -- tax_line_rec.tax_amt_included_flag = 'N'

      END IF; -- 'ALLOCATE_TAX_ONLY_ADJUSTMENT' trx and else
    ELSE  -- Historical Flag is 'N'
      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
         p_trx_line_index) = 'ALLOCATE_TAX_ONLY_ADJUSTMENT'
      THEN

      -- for tax only adjustment set the unrounded tax amount to the
      -- unrounded tax amount of the original doc.
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).unrounded_taxable_amt := tax_line_rec.unrounded_taxable_amt;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).unrounded_tax_amt := tax_line_rec.unrounded_tax_amt;

     ELSE
      -- current trx is a regular adjustment or CM
      -- prorate the line amt to get the unrounded taxable/tax amount

      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
           l_new_row_num).tax_amt_included_flag ='Y'
         AND tax_line_rec.tax_amt_included_flag = 'N'
      THEN
        -- If current trx is a tax inclusive trx, while the original trx is
        -- tax exclusive trx.

        -- If-Else Condition added for Bug#8540809
        IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_total_hdr_tx_amt(p_trx_line_index) IS NOT NULL AND
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_hdr_tx_appl_flag(p_trx_line_index) = 'Y'
        THEN
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).unrounded_taxable_amt
                := tax_line_rec.unrounded_taxable_amt;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).unrounded_tax_amt
                := tax_line_rec.unrounded_tax_amt;
        ELSE
          IF ( tax_line_rec.line_amt + tax_line_rec.tax_amt) <> 0 THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).unrounded_taxable_amt
                := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                  ( tax_line_rec.unrounded_taxable_amt /
                    ( tax_line_rec.line_amt + tax_line_rec.tax_amt) );
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).unrounded_tax_amt
                := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
                  ( tax_line_rec.unrounded_tax_amt /
                    ( tax_line_rec.line_amt + tax_line_rec.tax_amt) );
          ELSE
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).unrounded_taxable_amt
                := tax_line_rec.unrounded_taxable_amt;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).unrounded_tax_amt
                := tax_line_rec.unrounded_tax_amt;
          END IF;
        END IF;
      ELSE -- both current tax line and original tax line are inclusive and exclusive
        IF tax_line_rec.line_amt <> 0 THEN
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
              ( tax_line_rec.unrounded_taxable_amt / tax_line_rec.line_amt);

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index) *
              ( tax_line_rec.unrounded_tax_amt / tax_line_rec.line_amt );
        ELSE -- equal to that the original trx is a tax only trx
          IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index) = 'CREDIT_MEMO' THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
              := -1 * tax_line_rec.unrounded_taxable_amt;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
              := -1 * tax_line_rec.unrounded_tax_amt;
          ELSE
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
              := tax_line_rec.unrounded_taxable_amt;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
              := tax_line_rec.unrounded_tax_amt;
          END IF;
        END IF;
      END IF; -- tax_line_rec.tax_amt_included_flag = 'N'

    END IF; -- 'ALLOCATE_TAX_ONLY_ADJUSTMENT' trx and else

  END IF; -- Historical Flag check
END IF;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).basis_result_id
      := tax_line_rec.basis_result_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).legal_message_basis
      := tax_line_rec.legal_message_basis;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).calc_result_id
      := tax_line_rec.calc_result_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).legal_message_calc
      := tax_line_rec.legal_message_calc;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_base_modifier_rate
      := tax_line_rec.tax_base_modifier_rate;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).compounding_dep_tax_flag
      := tax_line_rec.compounding_dep_tax_flag;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).compounding_tax_miss_flag
      := tax_line_rec.compounding_tax_miss_flag;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).Compounding_Tax_Flag
      := tax_line_rec.compounding_tax_flag;

    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).tax_amt_included_flag = 'Y' THEN

      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_amt_included_flag(
        p_trx_line_index) := 'Y';
    END IF;

    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).compounding_dep_tax_flag = 'Y' THEN

      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.compounding_tax_flag(
        p_trx_line_index) := 'Y';
    END IF;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_exemption_id
      := tax_line_rec.tax_exemption_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_rate_before_exemption
      := tax_line_rec.tax_rate_before_exemption;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_rate_name_before_exemption
      := tax_line_rec.tax_rate_name_before_exemption;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).exempt_rate_modifier
      := tax_line_rec.exempt_rate_modifier;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).exempt_certificate_number
      := tax_line_rec.exempt_certificate_number;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).exempt_reason
      := tax_line_rec.exempt_reason;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).exempt_reason_code
      := tax_line_rec.exempt_reason_code;

    zx_tds_calc_services_pub_pkg.g_detail_tax_lines_tbl(l_new_row_num).tax_exception_id
      := tax_line_rec.tax_exception_id;
    zx_tds_calc_services_pub_pkg.g_detail_tax_lines_tbl(l_new_row_num).tax_rate_before_exception
      := tax_line_rec.tax_rate_before_exception;
    zx_tds_calc_services_pub_pkg.g_detail_tax_lines_tbl(l_new_row_num).tax_rate_name_before_exception
      := tax_line_rec.tax_rate_name_before_exception;
    zx_tds_calc_services_pub_pkg.g_detail_tax_lines_tbl(l_new_row_num).exception_rate
        := tax_line_rec.exception_rate;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).adjusted_doc_tax_line_id := tax_line_rec.tax_line_id;

--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
--       l_new_row_num).manually_entered_flag := tax_line_rec.manually_entered_flag;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).Tax_Only_Line_Flag := tax_line_rec.tax_only_line_flag;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_new_row_num).tax_provider_id := tax_line_rec.tax_provider_id;

   -- Bug 8992240

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_new_row_num).orig_tax_amt_included_flag :=
                                      tax_line_rec.orig_tax_amt_included_flag;
    -- Bug 7117340 -- DFF ER
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute1 := tax_line_rec.attribute1;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute2 := tax_line_rec.attribute2;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute3 := tax_line_rec.attribute3;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute4 := tax_line_rec.attribute4;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute5 := tax_line_rec.attribute5;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute6 := tax_line_rec.attribute6;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute7 := tax_line_rec.attribute7;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute8 := tax_line_rec.attribute8;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute9 := tax_line_rec.attribute9;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute10 := tax_line_rec.attribute10;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute11 := tax_line_rec.attribute11;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute12 := tax_line_rec.attribute12;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute13 := tax_line_rec.attribute13;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute14 := tax_line_rec.attribute14;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute15 := tax_line_rec.attribute15;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
   l_new_row_num).attribute_category:= tax_line_rec.attribute_category;

    IF (x_begin_index IS NULL) THEN
      x_begin_index := l_new_row_num;
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust',
         'Tax Line#' ||l_new_row_num ||
         ': Taxable Amount = '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt||
         ', Tax Amount = '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt);
    END IF;

  END LOOP;   -- FOR tax_line_rec in get_tax_lines

  IF (x_begin_index IS NOT NULL) THEN
    x_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;
  END IF;

  -- copy transaction info to new tax lines for new tax_lines created here
  --
  ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines(
                                p_trx_line_index ,
                                l_begin_index,
                                x_end_index,
                                x_return_status ,
                                l_error_buffer );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust',
         'Incorrect return_status after calling ' ||
         'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust',
         'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust.END',
         'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust(-)');
    END IF;

    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust.END',
       'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_det_tax_lines_from_adjust(-)');
    END IF;

END get_det_tax_lines_from_adjust;

----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_place_of_supply
--
--  DESCRIPTION
--
--  This procedure determines place of supply
--
--  IN/OUT
--         p_event_class_rec
--  IN     p_tax_regime_code
--         p_tax_id
--         p_tax
--         p_trx_line_index
--         p_tax_determine_date
--         p_Def_Place_Of_Supply_Type_Cd
--         p_place_of_supply_rule_flag
--         p_applicability_rule_flag
--         p_def_reg_type
--         p_reg_rule_flg
--  OUT NOCOPY    x_jurisdiction_rec
--         x_place_of_supply_type_code
--         x_place_of_supply_result_id

PROCEDURE get_place_of_supply (
  p_event_class_rec              IN        zx_api_pub.event_class_rec_type,
  p_tax_regime_code              IN        zx_regimes_b.tax_regime_code%TYPE,
  p_tax_id                       IN        zx_taxes_b.tax_id%TYPE,
  p_tax                          IN        zx_taxes_b.tax%TYPE,
  p_tax_determine_date           IN        DATE,
  p_def_place_of_supply_type_cd  IN        zx_taxes_b.def_place_of_supply_type_code%TYPE,
  p_place_of_supply_rule_flag    IN        zx_taxes_b.place_of_supply_rule_flag%TYPE,
  p_applicability_rule_flag      IN        zx_taxes_b.applicability_rule_flag%TYPE,
  p_def_reg_type                 IN        zx_taxes_b.def_registr_party_type_code%TYPE,
  p_reg_rule_flg                 IN        zx_taxes_b.registration_type_rule_flag%TYPE,
  p_trx_line_index               IN        BINARY_INTEGER,
  p_direct_rate_result_id        IN        NUMBER,
  x_jurisdiction_rec           OUT NOCOPY  ZX_TCM_GEO_JUR_PKG.tax_jurisdiction_rec_type,
  x_jurisdictions_found        OUT NOCOPY  VARCHAR2,
  x_place_of_supply_type_code  OUT NOCOPY  zx_taxes_b.def_place_of_supply_type_code%TYPE,
  x_place_of_supply_result_id  OUT NOCOPY  NUMBER,
  x_return_status              OUT NOCOPY  VARCHAR2) IS

 l_location_id             NUMBER;
 l_tax_service_type_code   zx_rules_b.service_type_code%TYPE;

 l_reg_party               VARCHAR2(256);
 l_jurisdiction_id         zx_jurisdictions_b.tax_jurisdiction_id%TYPE;
 l_jurisdiction_code       zx_jurisdictions_b.tax_jurisdiction_code%TYPE;
 l_tax_param_code          VARCHAR2(30);
 l_error_buffer            VARCHAR2(256);
 l_structure_name          varchar2(30);
 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(2000);
 l_pos_type                zx_taxes_b.def_place_of_supply_type_code%TYPE;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply.BEGIN',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply(+)');

  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_tax_service_type_code :=  'DET_PLACE_OF_SUPPLY';

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
                   'p_place_of_supply_rule_flag = ' || p_place_of_supply_rule_flag ||'p_Def_Place_Of_Supply_Type_Cd = ' || p_def_place_of_supply_type_Cd||'p_applicability_rule_flag = ' || p_applicability_rule_flag
                   ||'p_def_reg_type = ' || p_def_reg_type);
  END IF;

  IF (p_place_of_supply_rule_flag = 'Y') THEN

    rule_base_pos_detm (
                p_tax_id                => p_tax_id,
                p_tax_determine_date    => p_tax_determine_date,
                p_tax_service_type_code => l_tax_service_type_code,
                p_event_class_rec       => p_event_class_rec,
                p_trx_line_index        => p_trx_line_index,
                x_alphanumeric_result   => x_place_of_supply_type_code,
                x_result_id             => x_place_of_supply_result_id,
                x_return_status         => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm');
      END IF;

      x_place_of_supply_type_code := NULL;
      x_place_of_supply_result_id := NULL;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply.END',
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply(-)');
      END IF;
      RETURN;
    END IF;

    IF (x_place_of_supply_type_code IS NULL) THEN
      x_place_of_supply_type_code := p_def_place_of_supply_type_cd;
      x_place_of_supply_result_id := NULL;
    END IF;

  ELSE
    x_place_of_supply_type_code := p_def_place_of_supply_type_cd;
    x_place_of_supply_result_id := NULL;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  IF (x_place_of_supply_type_code IS NULL) THEN

    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MESSAGE.SET_NAME('ZX','ZX_POS_NOT_FOUND');
    FND_MESSAGE.SET_TOKEN('TAX',p_tax);
    --FND_MSG_PUB.Add;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

    ZX_API_PUB.add_msg(
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);


    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
             'Unable to derive Place of Supply Type');
    END IF;
    RETURN;
  END IF;

  IF x_place_of_supply_type_code = 'SHIP_TO_BILL_TO' then
     l_pos_type := 'SHIP_TO'; -- first try with ship_to
  ELSE
     l_pos_type := x_place_of_supply_type_code;
  end if;

  l_structure_name := 'TRX_LINE_DIST_TBL';

  l_tax_param_code := get_pos_parameter_name(
                          l_pos_type,
                          x_return_status);

  IF NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
  THEN
    -- TCM procedure called in get_pos_parameter_name will set the error msg
    -- here we just need to populate the context information.

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

    ZX_API_PUB.add_msg(
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
             'Incorrect return_status after calling ' ||
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name');
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply.END',
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply(-)');
    END IF;
    RETURN;
  END IF;

  ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
       p_struct_name     => l_structure_name,
       p_struct_index    => p_trx_line_index,
       p_tax_param_code  => l_tax_param_code,
       x_tax_param_value => l_location_id,
       x_return_status   => x_return_status );

  IF NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
  THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
             'Incorrect return_status after calling ' ||
             'ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value');
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply.END',
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply(-)');
    END IF;
    RETURN;
  END IF;

  IF l_location_id IS NULL
  and x_place_of_supply_type_code = 'SHIP_TO_BILL_TO' then

         l_pos_type := 'BILL_TO';

         -- try with bill to now
         l_tax_param_code := get_pos_parameter_name(
                          l_pos_type,
                          x_return_status);

        IF NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
        -- TCM procedure called in get_pos_parameter_name will set the error msg
        -- here we just need to populate the context information.

         ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

         ZX_API_PUB.add_msg(
           ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

         IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
             'Incorrect return_status after calling ' ||
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name');
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
             'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply.END',
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply(-)');
         END IF;
         RETURN;
        END IF;

        ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
                p_struct_name     => l_structure_name,
                p_struct_index    => p_trx_line_index,
                p_tax_param_code  => l_tax_param_code,
                x_tax_param_value => l_location_id,
                x_return_status   => x_return_status );

        IF NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        THEN
           IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
             'Incorrect return_status after calling ' ||
             'ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value');
            FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
             'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply.END',
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply(-)');
           END IF;
           RETURN;
        END IF;

  END IF;  -- ship_to_bill_to


  IF l_location_id IS NOT NULL THEN
    -- get the jurisdiction
    --
    ZX_TCM_GEO_JUR_PKG.get_tax_jurisdictions (
                       p_location_id      =>  l_location_id,
                       p_location_type    =>  l_pos_type,
                       p_tax              =>  p_tax,
                       p_tax_regime_code  =>  p_tax_regime_code,
                       p_trx_date         =>  p_tax_determine_date,
                       x_tax_jurisdiction_rec =>  x_jurisdiction_rec,
                       x_jurisdictions_found => x_jurisdictions_found,
                       x_return_status    =>  x_return_status);

    IF NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
    THEN
      -- populate the trx line context info if jurisdiction API return error
      -- jurisdiction API should have populated the error message name and text.

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

      ZX_API_PUB.add_msg(
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
                      'Incorrect return_status after calling ' ||
                      'ZX_TCM_GEO_JUR_PKG.get_tax_jurisdiction');
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply.END',
                      'ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply(-)');
      END IF;
      RETURN;
    END IF;
  ELSE
    IF  p_direct_rate_result_id IS NULL THEN
      --
      -- it is not a direct rate case, need to dump warning msg.
      --
/*
      FND_MESSAGE.SET_NAME('ZX','ZX_POS_MISSING_ON_TRX');
      FND_MESSAGE.SET_TOKEN('TAX', p_tax);
      FND_MESSAGE.SET_TOKEN('POS_TYPE', l_pos_type);
      -- FND_MSG_PUB.Add;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

      ZX_API_PUB.add_msg(
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
*/
      IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
                        'Location id is NULL for location type  ' || l_pos_type ||
                        ', and direct rate not found for the tax '|| p_tax ||
                        '. Hence the tax is not applicable.');
      END IF;
    END IF;
  END IF;

  x_place_of_supply_type_code := l_pos_type;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply.END',
                    'ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply(-)'||'X_place_of_supply_type_code = '|| x_place_of_supply_type_code);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_place_of_supply_type_code := NULL;
    x_place_of_supply_result_id := NULL;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply(-)');
    END IF;

END get_place_of_supply;

----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_pos_parameter_name
--
--  DESCRIPTION
--
--  This procedure returns parameter name for locations
--
--  IN     p_pos_type

FUNCTION get_pos_parameter_name (
 p_pos_type      IN zx_taxes_b.def_place_of_supply_type_code%TYPE,
 x_return_status OUT NOCOPY VARCHAR2
) RETURN VARCHAR2 IS

    l_loc_tbl        VARCHAR2(30);
    l_loc_site       VARCHAR2(30);
    x_msg_count      NUMBER;
    x_msg_data       VARCHAR2(2000);

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name.BEGIN',
                  'ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name(+)'|| 'pos_type = ' || p_pos_type);
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- x_return_status retured from TCM procedure will be handled in the
  -- calling procedure
  IF (p_pos_type = 'SHIP_TO') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.ship_to_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);

     RETURN 'SHIP_TO_'||l_loc_site;

  ELSIF (p_pos_type = 'SHIP_FROM') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.ship_from_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);

     RETURN 'SHIP_FROM_'||l_loc_site;

  ELSIF (p_pos_type = 'BILL_TO') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.bill_to_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);

     RETURN 'BILL_TO_'||l_loc_site;

  ELSIF (p_pos_type = 'BILL_FROM') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.bill_from_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);

     RETURN 'BILL_FROM_'||l_loc_site;

  ELSIF (p_pos_type = 'POINT_OF_ORIGIN') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.poo_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);

     RETURN 'POO_'||l_loc_site;

  ELSIF (p_pos_type = 'POINT_OF_ACCEPTANCE') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.poa_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);

     RETURN 'POA_'||l_loc_site;

  ELSIF (p_pos_type = 'TRADING_HQ') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.trad_hq_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);

     RETURN 'TRADING_HQ_'||l_loc_site;

  ELSIF (p_pos_type = 'OWN_HQ') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.own_hq_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);


     RETURN 'OWN_HQ_'||l_loc_site;

  ELSIF (p_pos_type = 'TITLE_TRANSFER') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.ttl_trns_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);

     RETURN 'TITLE_TRANSFER_'||l_loc_site;

  ELSIF (p_pos_type = 'PAYING') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.paying_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);

     RETURN 'PAYING_'||l_loc_site;

  ELSIF (p_pos_type = 'CONTRACT') THEN

 /* there is no party type for point of contract. so return hardcoded value
         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site
           (zx_valid_init_params_pkg.source_rec.poc_party_type,
            l_loc_tbl,
            l_loc_site,
            l_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data);
  */

     RETURN 'POC_'||'LOCATION_ID';

  ELSIF (p_pos_type = 'INVENTORY') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.poi_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);

     RETURN 'POI_'||l_loc_site;

  ELSIF (p_pos_type = 'DESTINATION') THEN

         ZX_TCM_GEO_JUR_PKG.get_pos_loc_or_site(
            zx_valid_init_params_pkg.source_rec.pod_party_type,
            l_loc_tbl,
            l_loc_site,
            x_return_status);

     RETURN 'POD_'||l_loc_site;

  ELSE
    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name',
                      'pos_parameter_name = NULL');
     END IF;
     RETURN Null;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_pos_parameter_name(-)');
    END IF;

END get_pos_parameter_name;

--------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_tax_registration_info
--
--  DESCRIPTION
--
--  This function calls TCM get_tax_registration API to return registration
--  information.
--

PROCEDURE get_tax_registration_info(
            p_structure_name         IN     VARCHAR2,
            p_structure_index        IN     BINARY_INTEGER,
            p_event_class_rec        IN     zx_api_pub.event_class_rec_type,
            p_tax_regime_code        IN     zx_regimes_b.tax_regime_code%TYPE,
            p_tax                    IN     zx_taxes_b.tax%TYPE,
            p_tax_determine_date     IN     zx_lines.tax_determine_date%TYPE,
            p_jurisdiction_code      IN     zx_jurisdictions_b.tax_jurisdiction_code%TYPE,
            p_reg_party_type         IN     zx_taxes_b.def_registr_party_type_code%TYPE,
            x_registration_rec       OUT NOCOPY zx_tcm_control_pkg.zx_registration_info_rec,
            x_return_status          OUT NOCOPY VARCHAR2
) IS

  l_reg_party_prof_id      zx_party_tax_profile.party_tax_profile_id%TYPE;

  l_registration_rec       zx_tcm_control_pkg.zx_registration_info_rec;
  l_ret_record_level       VARCHAR2(30);
  l_error_buffer           VARCHAR2(200);

  l_account_site_id        hz_cust_acct_sites_all.cust_acct_site_id%TYPE;
  l_site_use_id            hz_cust_site_uses_all.site_use_id%TYPE;
  l_account_id             hz_cust_accounts.cust_account_id%TYPE;
  l_parent_ptp_id          zx_party_tax_profile.party_tax_profile_id%TYPE;
  l_site_ptp_id            zx_party_tax_profile.party_tax_profile_id%TYPE;
  l_account_type_code      VARCHAR2(30);
  l_first_party_flag       BOOLEAN;
  l_hq_estb_ptp_id         zx_lines.hq_estb_party_tax_prof_id%TYPE;
  l_jurisdiction_code      zx_jurisdictions_b.tax_jurisdiction_code%TYPE;

  -- Bug#5395227
  l_tax_rec                ZX_TDS_UTILITIES_PKG.ZX_TAX_INFO_CACHE_REC;
  l_has_other_jurisdictions_flag VARCHAR2(1);

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info.BEGIN',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  -- get l_reg_party_prof_id
  --
  ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
            p_structure_name,
            p_structure_index,
            p_reg_party_type || '_' || 'TAX_PROF_ID',
            l_reg_party_prof_id,
            x_return_status,
            l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
      FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                    'l_reg_party_prof_id = ' || l_reg_party_prof_id);
      FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                    'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info.END',
                    'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info(-)');
    END IF;
    RETURN;
  END IF;

-- Fix for Bug 4873457 - If registration status of first party is required, then registration of
-- the establishment will be attempted to be derived. If not found, the registration of the HQ
-- establishment will be used. If registration status of third party is required, then the
-- registration at site level will be attemtped to be derived. Failing which, the party level
-- registration will be obtained.

  l_first_party_flag := ZX_TDS_RULE_BASE_DETM_PVT.evaluate_if_first_party(p_reg_party_type);

  IF l_first_party_flag THEN

    ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
            p_structure_name,
            p_structure_index,
            'HQ_ESTB_PARTY_TAX_PROF_ID',
            l_hq_estb_ptp_id,
            x_return_status,
            l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                      'l_hq_estb_ptp_id = ' || l_hq_estb_ptp_id);
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info.END',
                      'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info(-)');
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
    END IF;

    l_parent_ptp_id := l_hq_estb_ptp_id;
    l_site_ptp_id := l_reg_party_prof_id;
    l_account_type_code := NULL;
    l_account_id        := NULL;
    l_account_site_id   := NULL;
    l_site_use_id       := NULL;
  ELSE
    IF SUBSTR(p_reg_party_type, 1, 7) IN ('SHIP_TO','BILL_TO') OR
       SUBSTR(p_reg_party_type, 1, 9) IN ('SHIP_FROM','BILL_FROM')
    THEN
    -- get l_account_site_id
    --
       ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
            p_structure_name,
            p_structure_index,
            SUBSTR(p_reg_party_type,1,5) || 'THIRD_PTY_ACCT_SITE_ID',
            l_account_site_id,
            x_return_status,
            l_error_buffer);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF (g_level_error >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
           FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                      'l_account_site_id = ' || l_account_site_id);
           FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                      'RETURN_STATUS = ' || x_return_status);
           FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info.END',
                      'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info(-)');
         END IF;
         RETURN;
       END IF;

    -- get l_account_id
    --
       ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
            p_structure_name,
            p_structure_index,
            SUBSTR(p_reg_party_type,1,5) || 'THIRD_PTY_ACCT_ID',
            l_account_id,
            x_return_status,
            l_error_buffer);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF (g_level_error >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
           FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                      'l_account_id = ' || l_account_id);
           FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                      'RETURN_STATUS = ' || x_return_status);
           FND_LOG.STRING(g_level_error,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info.END',
                      'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info(-)');
         END IF;
         RETURN;
       END IF;
    END IF;   -- reg_party_type in ('SHIP_TO/FROM','BILL_TO/FROM')

  -- get l_site_use_id
  --
    IF SUBSTR(p_reg_party_type, 1, 7) IN ('SHIP_TO', 'BILL_TO') THEN

      ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
          p_structure_name,
          p_structure_index,
          SUBSTR(p_reg_party_type, 1,7) || '_' || 'CUST_ACCT_SITE_USE_ID',
          l_site_use_id,
          x_return_status,
          l_error_buffer);

    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
        FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                    'l_site_use_id = ' || l_site_use_id);
        FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                    'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info.END',
                    'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info(-)');
      END IF;
      RETURN;
    END IF;

    -- bug 4359775: TCM API changes parameter list
    -- get l_account_type_code, l_parent_ptp_id and l_site_ptp_id

      l_account_type_code := p_event_class_rec.sup_cust_acct_type;

    -- bug 4886911: Registration party type should be XXXX_PARTY only.
    -- Alway pass l_parent_ptp_id and l_site_ptp_id
    --
      l_parent_ptp_id := l_reg_party_prof_id;

    ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
            p_structure_name,
            p_structure_index,
            REPLACE(p_reg_party_type, 'PARTY', 'SITE') || '_' || 'TAX_PROF_ID',
            l_site_ptp_id,
            x_return_status,
            l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
               'Incorrect return_status after calling ' ||
               'ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value');
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
               'l_site_ptp_id = ' || l_site_ptp_id);
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info.END',
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info(-)');
      END IF;
      RETURN;
    END IF;
  END IF;

-- Bug 5003413
    IF p_jurisdiction_code IS NULL THEN
       IF g_outer_jurisdiction_code IS NULL THEN
          l_jurisdiction_code := NULL;
          -- BEGIN
          -- Bug#5395227
          l_has_other_jurisdictions_flag := NULL;

          ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                        p_tax_regime_code,
                        p_tax,
                        p_tax_determine_date,
                        l_tax_rec,
                        x_return_status,
                        l_error_buffer);

          IF x_return_status = FND_API.G_RET_STS_SUCCESS  THEN
            l_has_other_jurisdictions_flag := l_tax_rec.has_other_jurisdictions_flag;
          END IF;

          IF l_has_other_jurisdictions_flag = 'N' THEN
            BEGIN
               SELECT tax_jurisdiction_code
               INTO   l_jurisdiction_code
               FROM   zx_jurisdictions_b jur
               WHERE jur.tax_regime_code = p_tax_regime_code
               AND   jur.tax             = p_tax
               AND   jur.default_jurisdiction_flag = 'Y'
               AND   p_tax_determine_date between jur.default_flg_effective_from
                     and   nvl(jur.default_flg_effective_to, p_tax_determine_date);
              EXCEPTION WHEN OTHERS THEN
                 l_jurisdiction_code := NULL;
            END;
          END IF;
       ELSE
          l_jurisdiction_code := g_outer_jurisdiction_code;
       END IF;
    ELSE
       l_jurisdiction_code := p_jurisdiction_code;
    END IF;

  BEGIN

    ZX_TCM_CONTROL_PKG.get_tax_registration (
                p_parent_ptp_id        => l_parent_ptp_id,
                p_site_ptp_id          => l_site_ptp_id,
                p_account_type_code    => l_account_type_code,
                p_tax_determine_date   => p_tax_determine_date,
                p_tax                  => p_tax,
                p_tax_regime_code      => p_tax_regime_code,
                p_jurisdiction_code    => l_jurisdiction_code,
                p_account_id           => l_account_id,
                p_account_site_id      => l_account_site_id,
                p_site_use_id          => l_site_use_id,
                p_zx_registration_rec  => l_registration_rec,
                p_ret_record_level     => l_ret_record_level,
                p_return_status        => x_return_status);

    IF NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
                      'ZX_TCM_CONTROL_PKG.get_tax_registration_info returns with Error');
      END IF;
      -- Bug 4939819 - Skip registration processing if PTP setupis not found
      IF l_parent_ptp_id IS NULL THEN
        -- Parent PTP is NULL. Continuing...
        x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;

    ELSE
      x_registration_rec := l_registration_rec;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info',
               'Unable to get tax registration number after calling TCM API.');
      END IF;
  END;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info.END',
                  'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tax_registration_info',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END get_tax_registration_info;

----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_tax_registration
--
--  DESCRIPTION
--
--  This function returns registration number for a given party, tax regime
--  and tax defined in default tax or by evaluation of place of supply
--  registration rules
--
--  IN/OUT p_transaction_line_tbl
--         p_tax_inclusion_flag
--         p_event_class_rec
--  IN     p_tax_regime_code
--         p_tax_determine_date
--         p_tax_id
--         p_tax
--         p_jurisdiction_code
--         p_def_reg_type
--         p_reg_rule_flg
--         p_trx_line_index
--  OUT NOCOPY    x_party_id
--         x_party_site_id
--         x_registration_number
--         x_tax_inclusion_flag
--         x_self_assessment_flg

PROCEDURE get_tax_registration (
  p_event_class_rec             IN             zx_api_pub.event_class_rec_type,
  p_tax_regime_code             IN             zx_regimes_b.tax_regime_code%TYPE,
  p_tax_id                      IN             zx_taxes_b.tax_id%TYPE,
  p_tax                         IN             zx_taxes_b.tax%TYPE,
  p_tax_determine_date          IN             DATE,
  p_jurisdiction_code           IN             zx_jurisdictions_b.tax_jurisdiction_code%TYPE,
  p_def_reg_type                IN             zx_taxes_b.def_registr_party_type_code%TYPE,
  p_reg_rule_flg                IN             zx_taxes_b.registration_type_rule_flag%TYPE,
  p_trx_line_index              IN             BINARY_INTEGER,
  x_registration_number         IN OUT NOCOPY  zx_registrations.registration_number%TYPE,
  x_tax_inclusion_flag          IN OUT NOCOPY  zx_registrations.inclusive_tax_flag%TYPE,
  x_self_assessment_flg         IN OUT NOCOPY  zx_registrations.self_assess_flag%TYPE,
  x_tax_registration_result_id     OUT NOCOPY  NUMBER,
  x_rounding_rule_code             OUT NOCOPY  zx_registrations.rounding_rule_code%TYPE,
  x_registration_party_type        OUT NOCOPY  zx_taxes_b.def_registr_party_type_code%TYPE,
  x_return_status                  OUT NOCOPY  VARCHAR2) IS

  l_reg_party_type         zx_taxes_b.def_registr_party_type_code%TYPE;
  l_reg_party_prof_id      zx_party_tax_profile.party_tax_profile_id%TYPE;

  l_registration_rec        zx_tcm_control_pkg.zx_registration_info_rec;
  l_tax_service_type_code  zx_rules_b.service_type_code%TYPE;
  l_error_buffer           VARCHAR2(200);
  l_structure_name         VARCHAR2(30);
  l_ret_record_level       VARCHAR2(30);

  l_account_site_id        hz_cust_acct_sites_all.cust_acct_site_id%TYPE;
  l_site_use_id            hz_cust_site_uses_all.site_use_id%TYPE;
  l_account_id             hz_cust_accounts.cust_account_id%TYPE;
  l_parent_ptp_id          zx_party_tax_profile.party_tax_profile_id%TYPE;
  l_site_ptp_id            zx_party_tax_profile.party_tax_profile_id%TYPE;
  l_account_type_code      VARCHAR2(30);

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration.BEGIN',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration(+)'|| 'def_reg_type = ' || p_def_reg_type||'p_reg_rule_flg  = ' || p_reg_rule_flg);

  END IF;


  l_tax_service_type_code := 'DET_TAX_REGISTRATION';
  l_structure_name := 'TRX_LINE_DIST_TBL';

  IF p_reg_rule_flg = 'Y' THEN

    rule_base_pos_detm (
                p_tax_id                =>  p_tax_id,
                p_tax_determine_date    =>  p_tax_determine_date,
                p_tax_service_type_code =>  l_tax_service_type_code,
                p_event_class_rec       =>  p_event_class_rec,
                p_trx_line_index        =>  p_trx_line_index,
                x_alphanumeric_result   =>  l_reg_party_type,
                x_result_id             =>  x_tax_registration_result_id,
                x_return_status         =>  x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration',
                       'Incorrect return_status after calling ' ||
                       'ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm');
      END IF;

      x_tax_registration_result_id := NULL;
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration',
                       'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration.END',
                       'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration(-)');
      END IF;

      RETURN;
    END IF;

    IF l_reg_party_type IS NULL THEN
      l_reg_party_type := p_def_reg_type;
    END IF;

  ELSE
    l_reg_party_type := p_def_reg_type;
  END IF;

  -- Fetch tax registration number associated with
  -- tax regime, tax and party
  --
  IF (l_reg_party_type IS NOT NULL) THEN

    -- populate x_registration_party_type
    --
    if l_reg_party_type = 'SHIP_TO_BILL_TO' then
      x_registration_party_type := 'SHIP_TO_PARTY';
    else
      x_registration_party_type := l_reg_party_type;
    end if;

    -- call get_tax_registration_info
    get_tax_registration_info(
            p_structure_name     =>  l_structure_name,
            p_structure_index    =>  p_trx_line_index,
            p_event_class_rec    =>  p_event_class_rec,
            p_tax_regime_code    =>  p_tax_regime_code,
            p_tax                =>  p_tax,
            p_tax_determine_date =>  p_tax_determine_date,
            p_jurisdiction_code  =>  p_jurisdiction_code,
            p_reg_party_type     =>  x_registration_party_type,
            x_registration_rec   =>  l_registration_rec,
            x_return_status      =>  x_return_status
    );

    IF(NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
       OR l_registration_rec.registration_id IS NULL)
    THEN

        IF l_reg_party_type = 'SHIP_TO_BILL_TO'
        AND l_registration_rec.registration_id IS NULL
        THEN
         -- try with bill to now
         x_registration_party_type := 'BILL_TO_PARTY';

         -- call get_tax_registration_info
         get_tax_registration_info(
            p_structure_name     =>  l_structure_name,
            p_structure_index    =>  p_trx_line_index,
            p_event_class_rec    =>  p_event_class_rec,
            p_tax_regime_code    =>  p_tax_regime_code,
            p_tax                =>  p_tax,
            p_tax_determine_date =>  p_tax_determine_date,
            p_jurisdiction_code  =>  p_jurisdiction_code,
            p_reg_party_type     =>  x_registration_party_type,
            x_registration_rec   =>  l_registration_rec,
            x_return_status      =>  x_return_status
         );

        IF(NVL(x_return_status, FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS
        OR l_registration_rec.registration_id IS NULL)
        THEN

         IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration',
                      'ZX_TCM_CONTROL_PKG.GET_TAX_REGISTRATION returns with ' ||
                      ' Exception or no value ');

         END IF;

         x_registration_party_type := 'SHIP_TO_BILL_TO';
         x_registration_number := NULL;
         x_self_assessment_flg := 'N';
         x_tax_inclusion_flag := NULL;
         x_return_status := FND_API.G_RET_STS_SUCCESS;

        ELSE  -- Registration record found for BILL_TO registration party type
         x_registration_party_type := 'SHIP_TO_BILL_TO';
         x_registration_number := l_registration_rec.registration_number;
         x_tax_inclusion_flag := l_registration_rec.inclusive_tax_flag;
         x_self_assessment_flg := l_registration_rec.self_assess_flag;
         x_rounding_rule_code := l_registration_rec.rounding_rule_code;
        END IF;

      ELSE
         x_registration_number := NULL;
         x_self_assessment_flg := 'N';
         x_tax_inclusion_flag := NULL;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;

    ELSE  -- Registration record found
      x_registration_number := l_registration_rec.registration_number;
      x_tax_inclusion_flag := l_registration_rec.inclusive_tax_flag;
      x_self_assessment_flg := l_registration_rec.self_assess_flag;
      x_rounding_rule_code := l_registration_rec.rounding_rule_code;

    END IF;

  ELSE   -- l_reg_party_type is NULL
    x_registration_number := NULL;
    x_self_assessment_flg := 'N';
    x_tax_inclusion_flag := NULL;

  END IF;

  -- Reset x_rounding_rule_code
  --
  -- If roung level is 'HEADER', use g_rounding_rule returned with
  -- rounding level, if not available, use rounding rule from tax
  --
  IF UPPER(ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level) = 'HEADER' THEN

    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule IS NOT NULL THEN
      x_rounding_rule_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule;
    ELSE
      x_rounding_rule_code :=
        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(p_tax_id).rounding_rule_code;
    END IF;

  ELSE  -- g_rounding_level = 'LINE'

    -- bug#5638230- if allow_rounding_override_flag
    -- is 'N',  that means, user can not override the
    -- rounding rule at other levels, rounding rule
    -- should come from tax level directly
    --
    IF  ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(p_tax_id).allow_rounding_override_flag =
 'N' THEN
      x_rounding_rule_code :=
           ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(p_tax_id).rounding_rule_code;
    ELSE
      --
      -- the rounding rule defined at tax level
      -- was overridden at other levels
      --

      IF x_rounding_rule_code IS NULL THEN

        -- get rounding_rule
        --
        ZX_TDS_TAX_ROUNDING_PKG.get_rounding_rule(
             p_trx_line_index     => p_trx_line_index,
             p_event_class_rec    => p_event_class_rec,
             p_tax_regime_code    => p_tax_regime_code,
             p_tax                => p_tax,
             p_jurisdiction_code  => p_jurisdiction_code,
             p_tax_determine_date => p_tax_determine_date,
             p_rounding_rule_code => ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule,
             p_return_status      => x_return_status,
             p_error_buffer       => l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN

          x_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

        IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule IS NOT NULL THEN
          x_rounding_rule_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule;
        ELSE
          x_rounding_rule_code :=
            ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(p_tax_id).rounding_rule_code;
        END IF;
      END IF;
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration.END',
                  'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration(-)'||'x_registration_number = ' || x_registration_number||'x_tax_inclusion_flag = ' || x_tax_inclusion_flag
                  ||'x_self_assessment_flg = ' || x_self_assessment_flg||'x_tax_registration_result_id = ' ||
                   to_char(x_tax_registration_result_id)||'X_rounding_rule_code = ' || x_rounding_rule_code||'RETURN_STATUS = ' || x_return_status);
  END IF;

 EXCEPTION
    WHEN OTHERS THEN
      x_registration_number := NULL;
      x_self_assessment_flg := 'N';
      x_tax_inclusion_flag := NULL;
      --   ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(p_tax_id).def_inclusive_tax_flag;

      -- x_rounding_rule_code
      --
      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule IS NOT NULL THEN
         x_rounding_rule_code := ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_rule;
      ELSE
        x_rounding_rule_code :=
              ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(p_tax_id).rounding_rule_code;
      END IF;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration',
               'RETURN_STATUS = ' || x_return_status);
      END IF;
      x_tax_registration_result_id := NULL;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration',
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
        FND_LOG.STRING(g_level_unexpected,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration.END',
                          'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration(-)');
      END IF;

END get_tax_registration;

----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_legal_entity_registration
--
--  DESCRIPTION
--
--  This procedure returns registration number for a given legal entity party,
--  tax regime and tax
--
--  IN     p_tax_line_index
--  OUT NOCOPY
--         x_return_status
--         x_error_buffer

PROCEDURE get_legal_entity_registration(
  p_event_class_rec      IN            zx_api_pub.event_class_rec_type,
  p_trx_line_index       IN            BINARY_INTEGER,
  p_tax_line_index       IN            BINARY_INTEGER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_error_buffer            OUT NOCOPY VARCHAR2)
IS
  l_hq_estb_ptp_id           zx_lines.hq_estb_party_tax_prof_id%TYPE;
  i                          BINARY_INTEGER;
  l_tax_id                   BINARY_INTEGER;
  l_registration_rec         zx_tcm_control_pkg.zx_registration_info_rec;
  l_ret_record_level         VARCHAR2(30);
  l_jurisdiction_code        zx_jurisdictions_b.tax_jurisdiction_code%TYPE;
  l_party_ptp_id             zx_party_tax_profile.party_tax_profile_id%TYPE;

BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  i := p_tax_line_index;

  l_tax_id := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_id;
  l_hq_estb_ptp_id :=
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).hq_estb_party_tax_prof_id;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration',
           'l_hq_estb_ptp_id = ' || TO_CHAR(l_hq_estb_ptp_id));

  END IF;

  IF l_hq_estb_ptp_id IS NULL THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration',
             'HQ establishment party tax profile id is not available');
    END IF;
    RETURN;
  END IF;

  IF g_outer_jurisdiction_code IS NOT NULL THEN
    -- set most outer level jurisdiction code to find the registration information.
    l_jurisdiction_code := g_outer_jurisdiction_code;
  ELSE
    l_jurisdiction_code
      :=ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_jurisdiction_code;
  END IF;

  -- bug 4633146
  --
  IF p_event_class_rec.prod_family_grp_code = 'P2P' THEN

    ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
                'TRX_LINE_DIST_TBL',
                p_trx_line_index,
                'SHIP_TO_PARTY_TAX_PROF_ID',
                l_party_ptp_id,
                x_return_status,
                x_error_buffer);

  ELSIF p_event_class_rec.prod_family_grp_code = 'O2C' THEN

    ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value(
                'TRX_LINE_DIST_TBL',
                p_trx_line_index,
                'SHIP_FROM_PARTY_TAX_PROF_ID',
                l_party_ptp_id,
                x_return_status,
                x_error_buffer);

  END IF;

  -- bug 4359775: TCM API changes parameter list
  --
  ZX_TCM_CONTROL_PKG.get_tax_registration (
     p_parent_ptp_id        => l_hq_estb_ptp_id,
     p_site_ptp_id          => l_party_ptp_id,
     p_account_type_code    => NULL,
     p_tax_determine_date   => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date,
     p_tax                  => ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).tax,
     p_tax_regime_code      => ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).tax_regime_code,
     p_jurisdiction_code    => l_jurisdiction_code,
     p_account_id           => NULL,
     p_account_site_id      => NULL,
     p_site_use_id          => NULL,
     p_zx_registration_rec  => l_registration_rec,
     p_ret_record_level     => l_ret_record_level,
     p_return_status        => x_return_status);

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).hq_estb_reg_number :=
            l_registration_rec.registration_number;
  ELSE

    -- Bug 3511428: In case the TCM API returns no value, or with exception, reset
    -- x_return_status to FND_API.G_RET_STS_SUCCESS and continue processing ...
    -- processing.
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration',
             'Warning: ZX_TCM_CONTROL_PKG.get_tax_registration returns ' ||
             'with Exception or no value. ');
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration.END',
           'ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration(-)'||'hq_estb_reg_number = ' || l_registration_rec.registration_number||'x_return_status = ' || x_return_status
           ||'x_error_buffer  = ' || x_error_buffer);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration',
                    sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_legal_entity_registration(-)');
      END IF;

END get_legal_entity_registration;

----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  rule_base_pos_detm
--
--  DESCRIPTION
--
--  This function determines generic result by evaluating rules.
--
--  IN/OUT
--         p_event_class_rec
--  IN     p_tax
--         p_tax_id
--         p_tax_service_type_code
--         p_trx_line_index
--         p_tax_determine_date

PROCEDURE rule_base_pos_detm (
    p_tax_id                 IN             zx_taxes_b.tax_id%type,
    p_tax_determine_date     IN             DATE,
    p_tax_service_type_code  IN             zx_rules_b.service_type_code%type,
    p_event_class_rec        IN             zx_api_pub.event_class_rec_type,
    p_trx_line_index         IN             BINARY_INTEGER,
    x_alphanumeric_result       OUT NOCOPY  VARCHAR2,
    x_result_id                 OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY  VARCHAR2 )  IS

  l_tax_result_rec         zx_process_results%ROWTYPE;
  l_error_buffer           VARCHAR2(2000);
  l_structure_name         VARCHAR2(30);

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process(
                                        p_tax_service_type_code,
                                       'TRX_LINE_DIST_TBL',
                                        p_trx_line_index,
                                        p_event_class_rec,
                                        p_tax_id,
                                        NULL,
                                        p_tax_determine_date,
                                        NULL,
                                        NULL,
                                        l_tax_result_rec,
                                        x_return_status,
                                        l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm',
               'Incorrect return_status after calling ' ||
               'ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process');
      END IF;

    x_alphanumeric_result := NULL;
    x_result_id := NULL;
    IF (g_level_statement >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm.END',
             'ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm(-)'||x_return_status);
    END IF;
    RETURN;
  END IF;

  IF (l_tax_result_rec.alphanumeric_result IS NOT NULL) THEN
    x_alphanumeric_result := l_tax_result_rec.alphanumeric_result;
    x_result_id := l_tax_result_rec.result_id;

  ELSE
    x_alphanumeric_result := NULL;
    x_result_id := NULL;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm.END',
           'ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_alphanumeric_result := NULL;
    x_result_id := NULL;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.rule_base_pos_detm(-)');
    END IF;
END rule_base_pos_detm;


PROCEDURE populate_registration_info(
 p_event_class_rec     IN         zx_api_pub.event_class_rec_type,
 p_trx_line_index      IN         NUMBER,
 p_rownum              IN         NUMBER,
 p_def_reg_type        IN         zx_taxes_b.def_registr_party_type_code%TYPE,
 p_reg_rule_flg        IN         zx_taxes_b.registration_type_rule_flag%TYPE,
 p_tax_determine_date  IN         DATE,
 x_return_status       OUT NOCOPY VARCHAR2) IS

 -- get def_registr_party_type_code and registration_type_rule_flag
 --
 CURSOR get_reg_type_and_rule_flg_cur(p_tax_id  NUMBER) IS
  SELECT def_registr_party_type_code,
         registration_type_rule_flag
    FROM ZX_TAXES_B
   WHERE tax_id = p_tax_id;

 l_def_reg_type         zx_taxes_b.def_registr_party_type_code%TYPE;
 l_reg_rule_flg         zx_taxes_b.registration_type_rule_flag%TYPE;

 l_tax_id               NUMBER;
 l_error_buffer         VARCHAR2(200);
 l_jurisdiction_code    zx_jurisdictions_b.tax_jurisdiction_code%TYPE;
 l_self_assessed_flag   zx_lines.self_assessed_flag%TYPE;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info(+)');
  END IF;

  l_tax_id := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_rownum).tax_id;

  IF p_def_reg_type IS NOT NULL THEN

    l_def_reg_type := p_def_reg_type;
    l_reg_rule_flg := p_reg_rule_flg;

  ELSE
    -- get def_registr_party_type_code and registration_type_rule_flag
    --
    OPEN  get_reg_type_and_rule_flg_cur(l_tax_id);
    FETCH get_reg_type_and_rule_flg_cur INTO l_def_reg_type,l_reg_rule_flg;
    CLOSE get_reg_type_and_rule_flg_cur;
  END IF;

  IF g_outer_jurisdiction_code IS NOT NULL THEN
    -- use most outer level jurisdiction code to find the registration information.
    l_jurisdiction_code := g_outer_jurisdiction_code;

  ELSE
    l_jurisdiction_code
      :=ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          p_rownum).tax_jurisdiction_code;
  END IF;

  get_tax_registration(
    p_event_class_rec     => p_event_class_rec,
    p_tax_regime_code     => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                         p_rownum).tax_regime_code,
    p_tax_id              => l_tax_id,
    p_tax                 => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                                    p_rownum).tax,
    p_tax_determine_date  => p_tax_determine_date,
    p_jurisdiction_code   => l_jurisdiction_code,
    p_def_reg_type        => l_def_reg_type,
    p_reg_rule_flg        => l_reg_rule_flg,
    p_trx_line_index      => p_trx_line_index,
    x_registration_number => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                p_rownum).tax_registration_number,
    x_tax_inclusion_flag  => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                  p_rownum).tax_amt_included_flag,
    x_self_assessment_flg => l_self_assessed_flag,
    x_tax_registration_result_id
                          => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                              p_rownum).tax_reg_num_det_result_id,
    x_rounding_rule_code  => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                     p_rownum).rounding_rule_code,
    x_registration_party_type
                          => ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                p_rownum).registration_party_type,
    x_return_status       => x_return_status);


  IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info',
             'Incorrect return_status after calling ' ||
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration');
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info.END',
             'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info(-)');
    END IF;
    RETURN;
  END IF;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_rownum).legal_message_trn
          :=ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id(
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_rownum).tax_reg_num_det_result_id,
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_rownum).trx_date);
  -- Do not change the value of self_assessed_flag if
  -- 1. self_assessed_flag is overridden (bug 5391331)
  -- 2. manual tax line (bug 5391084)
  --
  IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  p_rownum).orig_self_assessed_flag IS NULL AND
     NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  p_rownum).manually_entered_flag, 'N') ='N'
  THEN

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         p_rownum).self_assessed_flag := l_self_assessed_flag;
  END IF;

  -- get registration number for legal entity
  --
  get_legal_entity_registration(
          p_event_class_rec => p_event_class_rec,
          p_trx_line_index  => p_trx_line_index,
          p_tax_line_index  => p_rownum,
          x_return_status   => x_return_status,
          x_error_buffer    => l_error_buffer);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info.END',
             'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info(-)');
    END IF;
    RETURN;
  END IF;


EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info(-)');
    END IF;
END populate_registration_info;

----------------------------------------------------------------------
--  PROCEDURE
--   get_tax_from_account
--
--  DESCRIPTION
--
--  This procedure handle enforcement from natual account.
--
--  IN
--          p_trx_line_index
--
--  IN OUT NOCOPY
--          x_begin_index
--          x_end_index
--  OUT NOCOPY     x_return_status

PROCEDURE get_tax_from_account(
 p_event_class_rec       IN             zx_api_pub.event_class_rec_type,
 p_trx_line_index        IN             BINARY_INTEGER,
 p_tax_date              IN             DATE,
 p_tax_determine_date    IN             DATE,
 p_tax_point_date        IN             DATE,
 x_begin_index           IN OUT NOCOPY  BINARY_INTEGER,
 x_end_index             IN OUT NOCOPY  BINARY_INTEGER,
 x_return_status         OUT NOCOPY     VARCHAR2) IS

 CURSOR  get_chart_of_accts_id_csr IS
  SELECT chart_of_accounts_id
    FROM gl_sets_of_books
   WHERE set_of_books_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ledger_id(p_trx_line_index);

 CURSOR get_default_jurisdiction_csr(c_tax_regime_code VARCHAR2, c_tax VARCHAR2) IS
 SELECT tax_jurisdiction_id,
        tax_jurisdiction_code
 FROM zx_jurisdictions_b
 WHERE tax_regime_code = c_tax_regime_code
 AND tax = c_tax
 AND default_jurisdiction_flag = 'Y'
 AND (p_tax_determine_date >= default_flg_effective_from AND
      (p_tax_determine_date <= default_flg_effective_to OR default_flg_effective_to IS NULL));

 CURSOR  get_det_tax_lines_frm_acct_csr(c_account_seg_value     VARCHAR2) IS
  SELECT zxtr.tax_regime_code,
         zxtr.tax,
         zxtr.tax_status_code,
         zxtr.tax_rate_code,
         zxtr.amt_incl_tax_flag,
         zxtr.allow_rate_override_flag,
         zxtr.tax_class,
         zxt.tax_id,
         zxt.tax_type_code,
         zxt.tax_precision,
         zxt.minimum_accountable_unit,
         zxt.rounding_rule_code,
         zxt.tax_status_rule_flag,
         zxt.tax_rate_rule_flag,
         zxt.place_of_supply_rule_flag,
         zxt.applicability_rule_flag,
         zxt.tax_calc_rule_flag,
         zxt.taxable_basis_rule_flag,
         zxt.def_tax_calc_formula,
         zxt.def_taxable_basis_formula,
         zxt.reporting_only_flag,
         zxt.tax_currency_code,
         zxt.def_place_of_supply_type_code,
         zxt.def_registr_party_type_code,
         zxt.registration_type_rule_flag,
         zxt.direct_rate_rule_flag,
         zxt.def_inclusive_tax_flag,
         zxt.effective_from,
         zxt.effective_to,
         zxt.compounding_precedence,
         zxt.has_other_jurisdictions_flag,
         zxt.live_for_processing_flag,
         zxt.regn_num_same_as_le_flag,
         zxt.applied_amt_handling_flag,
         zxt.exchange_rate_type,
         zxt.applicable_by_default_flag,
         zxt.record_type_code,
         zxt.tax_exmpt_cr_method_code,
         zxt.tax_exmpt_source_tax,
         zxt.legal_reporting_status_def_val,
         zxt.def_rec_settlement_option_code,
         zxt.zone_geography_type,
         zxt.override_geography_type,
         zxt.allow_rounding_override_flag,
         zxt.tax_account_source_tax
    FROM zx_sco_account_rates zxtr,
         zx_sco_taxes zxt,
         fnd_lookups lc
   WHERE zxtr.content_owner_id = p_event_class_rec.first_pty_org_id
     AND zxtr.ledger_id =
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ledger_id(p_trx_line_index)
     AND zxtr.account_segment_value= c_account_seg_value
     AND zxt.tax_regime_code = zxtr.tax_regime_code
     AND zxt.tax = zxtr.tax
     AND zxt.tax_type_code = lc.lookup_code
     AND lc.lookup_type = 'ZX_TAX_TYPE_CATEGORY'
     AND NVL(zxt.tax_type_code, 'X') <> 'OFFSET'
     AND zxt.live_for_processing_flag = 'Y'
     AND (p_tax_determine_date >= zxt.effective_from AND
          (p_tax_determine_date <= zxt.effective_to OR zxt.effective_to IS NULL))
   ORDER BY zxt.compounding_precedence;

 l_app_column_name              fnd_id_flex_segments.application_column_name%TYPE;
 l_account_seg_value            gl_code_combinations.segment1%TYPE;
 l_delimiter                    varchar2(5) := NULL;
 l_num_result                   NUMBER;
 l_boolean_result               BOOLEAN;
 l_flexsegtab                   fnd_flex_ext.SegmentArray;
 l_account_seg_num              NUMBER;
 l_chart_of_accounts_id         NUMBER;
 l_sql_statement                VARCHAR2(2000);

 l_account_ccid                 NUMBER;
 l_account_string               VARCHAR2(2000);
 l_trx_line_id                  NUMBER;
 l_trx_level_type               VARCHAR2(30);
 l_tax_tbl_subscript            NUMBER;
 l_new_row_num                  NUMBER;
 l_error_buffer                 VARCHAR2(200);

 l_begin_index                  BINARY_INTEGER;
 l_end_index                    BINARY_INTEGER;
 l_begin_index_from_acct        BINARY_INTEGER;
 l_end_index_from_acct          BINARY_INTEGER;

 l_tax_regime_rec               zx_global_structures_pkg.tax_regime_rec_type;
 l_tax_status_rec               ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
 l_tax_rate_rec                 ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;

 l_jurisdiction_id              NUMBER;
 l_jurisdiction_code            zx_jurisdictions_b.tax_jurisdiction_code%TYPE;

 l_tax_class                    zx_rates_b.tax_class%TYPE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account(+)');

  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- Bug#5417753- determine tax_class value
  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  l_account_ccid :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.account_ccid(p_trx_line_index);
  l_account_string :=
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.account_string(p_trx_line_index);

  -- get chart_of_account_id
  --
  OPEN  get_chart_of_accts_id_csr;
  FETCH get_chart_of_accts_id_csr into l_chart_of_accounts_id;
  CLOSE get_chart_of_accts_id_csr;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
           'l_chart_of_accounts_id = ' || to_char(l_chart_of_accounts_id));
  END IF;

  IF l_chart_of_accounts_id IS NULL THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
    IF g_level_statement >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
             'chart_of_accounts_id is NULL.');
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account.END',
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account(-)');
    END IF;
    RETURN;
  END IF;

  IF l_account_ccid IS NOT NULL AND l_account_ccid <> -1  THEN

    -- Get the column name of the account segment in GL_CODE_COMBINATIONS
    --
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
             'Getting tax code using code combination ID.'|| to_char(l_account_ccid));
    END IF;

    -- call fnd api to get the column name for natural account
    --
    l_boolean_result := fnd_flex_apis.get_segment_column (
                              101,
                             'GL#',
                              l_chart_of_accounts_id,
                              'GL_ACCOUNT',
                              l_app_column_name);

    -- bug#8226639- use bind variable for l_account_ccid

    l_sql_statement :=  'SELECT ' || l_app_column_name ||
                        '  FROM gl_code_combinations cc ' ||
                        ' WHERE cc.code_combination_id = :l_account_ccid ';

      EXECUTE IMMEDIATE l_sql_statement INTO l_account_seg_value
                  USING l_account_ccid;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
                    'l_account_seg_value ==' || l_account_seg_value);
    END IF;

  ELSIF l_account_string IS NOT NULL THEN

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
             'account_string ==' || l_account_string);
    END IF;

    --  Get account segment from the concatenated string
    --
    l_delimiter := fnd_flex_ext.get_delimiter(
                      'SQLGL',
                      'GL#',
                      l_chart_of_accounts_id);

    l_num_result := fnd_flex_ext.breakup_segments(
                    l_account_string,
                    l_delimiter,
                    l_flexsegtab);

    l_boolean_result := fnd_flex_apis.get_qualifier_segnum (
                            101,
                            'GL#',
                            l_chart_of_accounts_id,
                            'GL_ACCOUNT',
                            l_account_seg_num);

    l_account_seg_value := l_flexsegtab(l_account_seg_num);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
             'l_account_seg_value == ' || l_account_seg_value|| 'l_delimiter == ' || l_delimiter);
    END IF;
  END IF;

  IF l_account_seg_value IS NOT NULL THEN

    l_begin_index := x_begin_index;
    l_end_index := x_end_index;

    -- Get detail tax lines from account
    --
    l_trx_line_id :=
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
    l_trx_level_type :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

    FOR l_tax_rec IN get_det_tax_lines_frm_acct_csr(l_account_seg_value) LOOP

      l_tax_tbl_subscript := NULL;

      -- Check if this tax line exists in the applicable tax lines
      --
      IF l_begin_index IS NOT NULL THEN
        l_tax_tbl_subscript := ZX_TDS_UTILITIES_PKG.get_tax_index(
                                l_tax_rec.tax_regime_code,
                                l_tax_rec.tax,
                                l_trx_line_id,
                                l_trx_level_type,
                                l_begin_index,
                                l_end_index,
                                x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_tax_index');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account(-)');
          END IF;
          RETURN;
        END IF;
      END IF;    -- l_begin_index IS NOT NULL

      IF l_tax_tbl_subscript IS NULL THEN

        -- This tax from account does not exist in the current applicable taxes
        -- Create a new tax line in p_detail_tax_lines_tbl
        --
        -- populate g_tax_rec_tbl, if it does not exist
        --
        IF NOT ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl.EXISTS(l_tax_rec.tax_id) THEN


          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                  l_tax_rec.tax_id).tax_regime_code := l_tax_rec.tax_regime_code;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                                    l_tax_rec.tax_id).tax_id := l_tax_rec.tax_id;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_rec.tax_id).tax :=l_tax_rec.tax;

          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).def_place_of_supply_type_code :=
                                         l_tax_rec.def_place_of_supply_type_code;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).place_of_supply_rule_flag :=
                                             l_tax_rec.place_of_supply_rule_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).applicability_rule_flag :=
                                               l_tax_rec.applicability_rule_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).direct_rate_rule_flag :=
                                                 l_tax_rec.direct_rate_rule_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).def_registr_party_type_code :=
                                           l_tax_rec.def_registr_party_type_code;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).registration_type_rule_flag  :=
                                           l_tax_rec.registration_type_rule_flag;

          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
              l_tax_rec.tax_id).tax_currency_code := l_tax_rec.tax_currency_code;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                      l_tax_rec.tax_id).tax_precision := l_tax_rec.tax_precision;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).minimum_accountable_unit :=
                                              l_tax_rec.minimum_accountable_unit;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
             l_tax_rec.tax_id).rounding_rule_code :=l_tax_rec.rounding_rule_code;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).tax_status_rule_flag :=
                                                  l_tax_rec.tax_status_rule_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
            l_tax_rec.tax_id).tax_rate_rule_flag := l_tax_rec.tax_rate_rule_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
            l_tax_rec.tax_id).tax_calc_rule_flag := l_tax_rec.tax_calc_rule_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).taxable_basis_rule_flag :=
                                               l_tax_rec.taxable_basis_rule_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).def_tax_calc_formula :=
                                                  l_tax_rec.def_tax_calc_formula;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).def_taxable_basis_formula :=
                                             l_tax_rec.def_taxable_basis_formula;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                      l_tax_rec.tax_id).tax_type_code := l_tax_rec.tax_type_code;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
           l_tax_rec.tax_id).reporting_only_flag := l_tax_rec.reporting_only_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).def_inclusive_tax_flag :=
                                                l_tax_rec.def_inclusive_tax_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).applied_amt_handling_flag :=
                                             l_tax_rec.applied_amt_handling_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).exchange_rate_type :=
                                                    l_tax_rec.exchange_rate_type;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                    l_tax_rec.tax_id).effective_from := l_tax_rec.effective_from;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                        l_tax_rec.tax_id).effective_to := l_tax_rec.effective_to;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).compounding_precedence :=
                                                l_tax_rec.compounding_precedence;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).has_other_jurisdictions_flag :=
                                          l_tax_rec.has_other_jurisdictions_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).live_for_processing_flag :=
                                              l_tax_rec.live_for_processing_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).regn_num_same_as_le_flag:=
                                              l_tax_rec.regn_num_same_as_le_flag;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).applicable_by_default_flag :=
                                        l_tax_rec.applicable_by_default_flag;
           ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).record_type_code :=
                                        l_tax_rec.record_type_code;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).tax_exmpt_cr_method_code :=
                                        l_tax_rec.tax_exmpt_cr_method_code;
                   ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).tax_exmpt_source_tax :=
                                        l_tax_rec.tax_exmpt_source_tax;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).legal_reporting_status_def_val :=
                                        l_tax_rec.legal_reporting_status_def_val;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).def_rec_settlement_option_code :=
                                        l_tax_rec.def_rec_settlement_option_code;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).zone_geography_type :=
                                        l_tax_rec.zone_geography_type;
         ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).override_geography_type :=
                                        l_tax_rec.override_geography_type;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                 l_tax_rec.tax_id).tax_account_source_tax :=
                                        l_tax_rec.tax_account_source_tax;


        END IF;      -- g_tax_rec_tbl(l_tax_rec.tax_id) does not exist

        -- Create a new record in p_detail_tax_lines_tbl
        --
        l_new_row_num :=
            NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0) + 1;

        -- validate and populate tax_regime_id
        --
        ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
                        l_tax_rec.tax_regime_code,
                        p_tax_determine_date,
                        l_tax_regime_rec,
                        x_return_status,
                        l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_regime_cache_info');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 l_new_row_num).tax_regime_id := l_tax_regime_rec.tax_regime_id;

        -- validate and populate tax_status_id
        --
        ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                        l_tax_rec.tax,
                        l_tax_rec.tax_regime_code,
                        l_tax_rec.tax_status_code,
                        p_tax_determine_date,
                        l_tax_status_rec,
                        x_return_status,
                        l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 l_new_row_num).tax_status_id := l_tax_status_rec.tax_status_id;

        -- validate and populate tax_rate_id
        --
        ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
                        l_tax_rec.tax_regime_code,
                        l_tax_rec.tax,
                        NULL,  --++++
                        l_tax_rec.tax_status_code,
                        l_tax_rec.tax_rate_code,
                        p_tax_determine_date,
                        l_tax_class,
                        l_tax_rate_rec,
                        x_return_status,
                        l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_tax_rate_info');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_new_row_num).tax_rate_id := l_tax_rate_rec.tax_rate_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).tax_rate := l_tax_rate_rec.percentage_rate;

        -- Copy data from account to the detail_tax_lines_tbl
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_regime_code := l_tax_rec.tax_regime_code;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                             l_new_row_num).tax := l_tax_rec.tax;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                             l_new_row_num).tax_id := l_tax_rec.tax_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_status_code := l_tax_rec.tax_status_code;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_new_row_num).tax_rate_code := l_tax_rec.tax_rate_code;

        -- populate default tax jurisdiction code and id - Note that the jurisdiction
        -- will always be NULL for the rates associated with GL account segment values.
        --
        OPEN  get_default_jurisdiction_csr(l_tax_rec.tax_regime_code, l_tax_rec.tax);
        FETCH get_default_jurisdiction_csr into l_jurisdiction_id, l_jurisdiction_code;
        CLOSE get_default_jurisdiction_csr;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_new_row_num).tax_jurisdiction_id := l_jurisdiction_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                             l_new_row_num).tax_jurisdiction_code := l_jurisdiction_code;

        -- populate other columns
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_new_row_num).tax_amt_included_flag := l_tax_rec.amt_incl_tax_flag;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 l_new_row_num).tax_currency_code := l_tax_rec.tax_currency_code;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                             l_new_row_num).tax_type_code := l_tax_rec.tax_type_code;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_currency_conversion_date := p_tax_determine_date;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).tax_currency_conversion_type :=
                                                           l_tax_rec.exchange_rate_type;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).reporting_only_flag := l_tax_rec.reporting_only_flag;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_new_row_num).rounding_rule_code := l_tax_rec.rounding_rule_code;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                           l_new_row_num).tax_date := p_tax_date;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       l_new_row_num).tax_determine_date := p_tax_determine_date;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                               l_new_row_num).tax_point_date := p_tax_point_date;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).enforce_from_natural_acct_flag := 'Y';

        -- populate rounding_lvl_party_tax_prof_id and rounding_level_code
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_new_row_num).rounding_lvl_party_tax_prof_id :=
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_rnd_lvl_party_tax_prof_id;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_new_row_num).rounding_level_code :=
                                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_new_row_num).rounding_lvl_party_type :=
                         ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_lvl_party_type;

        -- populate hq_estb_party_tax_prof_id
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
         l_new_row_num).hq_estb_party_tax_prof_id :=
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hq_estb_party_tax_prof_id(
                                                              p_trx_line_index);

        -- bug 5077691: populate legal_reporting_status
        IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_new_row_num).legal_reporting_status :=
                        ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                              l_tax_rec.tax_id).legal_reporting_status_def_val;
        END IF;

        -- populate tax registration info
        --
        populate_registration_info(
              p_event_class_rec      => p_event_class_rec,
              p_trx_line_index       => p_trx_line_index,
              p_rownum               => l_new_row_num,
              p_def_reg_type         => l_tax_rec.def_registr_party_type_code,
              p_reg_rule_flg         => l_tax_rec.registration_type_rule_flag,
              p_tax_determine_date   => p_tax_determine_date,
              x_return_status        => x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account(-)');
          END IF;
          RETURN;
        END IF;

        -- Set x_begin_index if it has not been set
        --
        IF (x_begin_index IS NULL)  THEN
          x_begin_index := l_new_row_num ;
        END IF;

        -- Set l_begin_index_from_acct if it has not been set
        --
        IF (l_begin_index_from_acct IS NULL)  THEN
          l_begin_index_from_acct := l_new_row_num ;
        END IF;

      ELSE      -- l_tax_tbl_subscript is not NULL

        -- Set enforce_from_natural_acct_flag to 'Y'
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       l_tax_tbl_subscript).enforce_from_natural_acct_flag := 'Y';

      END IF;   -- l_tax_tbl_subscript
    END LOOP;   -- get_tax_lines from accounts

    -- set x_end_index and l_end_index_from_acct
    --
    IF (x_begin_index IS NOT NULL) THEN
       x_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;
       l_end_index_from_acct := x_end_index;
    END IF;

    -- copy transaction info to new tax lines
    --
    ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines(
                                        p_trx_line_index,
                                        l_begin_index_from_acct,
                                        l_end_index_from_acct,
                                        x_return_status,
                                        l_error_buffer );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
               'Incorrect return_status after calling ' ||
               'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account.END',
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account(-)');
      END IF;
      RETURN;
    END IF;
  END IF;  -- l_account_seg_value IS NOT NULL
  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account.END',
           'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account',
              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account.END',
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_from_account(-)');
    END IF;

END get_tax_from_account;

---------------------------------------------------------------------
-- PUBLIC PROCEDURE
--  get_taxes_for_intercomp_trx
--
--  DESCRIPTION: This procedure fetch detail tax lines from source
--               document for inter-company transaction.
--
--  April 25, 2005     Hongjun Liu     Created
--

PROCEDURE get_taxes_for_intercomp_trx(
  p_event_class_rec      IN             zx_api_pub.event_class_rec_type,
  p_trx_line_index       IN             NUMBER,
  p_tax_date             IN             DATE,
  p_tax_determine_date   IN             DATE,
  p_tax_point_date       IN             DATE,
  x_begin_index          IN OUT NOCOPY  NUMBER,
  x_end_index            IN OUT NOCOPY  NUMBER,
  x_return_status           OUT NOCOPY  VARCHAR2) IS

 CURSOR get_taxes_f_intercomp_trx_csr IS
  SELECT zxl.*
    FROM zx_lines zxl, zx_evnt_cls_mappings map
   WHERE map.application_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index)
     AND map.entity_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_index)
     AND map.event_class_code =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index)
     AND zxl.application_id = map.intrcmp_src_appln_id
     AND zxl.entity_code = map.intrcmp_src_entity_code
     AND zxl.event_class_code = decode(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(p_trx_line_index),
             'INTERCOMPANY_TRX', zxl.event_class_code,
            /* decode(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_class(p_trx_line_index),
                    'AP_CREDIT_MEMO', 'CREDIT_MEMO',
                    'AP_DEBIT_MEMO', 'DEBIT_MEMO',
                    map.intrcmp_src_evnt_cls_code), */ -- Bug9587918
             map.intrcmp_src_evnt_cls_code)
     AND zxl.trx_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_id(p_trx_line_index)
     AND zxl.trx_line_id =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_line_id(p_trx_line_index)
     AND zxl.trx_level_type =
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_level_type(p_trx_line_index)
     AND zxl.tax_provider_id IS NULL
     AND zxl.cancel_flag <> 'Y'
     AND zxl.mrc_tax_line_flag = 'N';

  CURSOR is_tax_migrated_in_ar_csr(
     c_tax_rate_id               zx_rates_b.tax_rate_id%TYPE) IS
    SELECT tax_regime_code,
           tax,
           tax_status_code,
           record_type_code,
           offset_tax_rate_code,
           tax_jurisdiction_code
      FROM zx_rates_b
     WHERE tax_rate_id = c_tax_rate_id
     AND   active_flag = 'Y';

  CURSOR get_tax_info_f_ap_input
    (c_tax_rate_code           zx_rates_b.tax_rate_code%TYPE)  IS
    SELECT tax_regime_code,
           tax,
           tax_status_code,
           tax_jurisdiction_code
      FROM zx_sco_rates_b_v
     WHERE tax_rate_code = c_tax_rate_code
       AND effective_from <= p_tax_determine_date
       AND (effective_to >= p_tax_determine_date OR effective_to IS NULL)
       AND tax_class = 'INPUT'
       AND active_flag = 'Y'
     ORDER BY subscription_level_code;

 CURSOR get_tax_info_f_ap_null
    (c_tax_rate_code           zx_rates_b.tax_rate_code%TYPE)  IS
    SELECT tax_regime_code,
           tax,
           tax_status_code,
           tax_jurisdiction_code
      FROM zx_sco_rates_b_v
     WHERE tax_rate_code = c_tax_rate_code
       AND effective_from <= p_tax_determine_date
       AND (effective_to >= p_tax_determine_date OR effective_to IS NULL)
       AND tax_class IS NULL
       AND active_flag = 'Y'
     ORDER BY subscription_level_code;

  CURSOR get_tax_info_f_not_ap
    (c_tax_rate_code           zx_rates_b.tax_rate_code%TYPE)  IS
    SELECT tax_regime_code,
           tax,
           tax_status_code,
           tax_jurisdiction_code
      FROM zx_sco_rates_b_v
     WHERE tax_rate_code = c_tax_rate_code
       AND effective_from <= p_tax_determine_date
       AND (effective_to >= p_tax_determine_date OR effective_to IS NULL)
       AND active_flag = 'Y'
       AND tax_class <> 'INPUT'
     ORDER BY subscription_level_code;

 l_tax_regime_rec                zx_global_structures_pkg.tax_regime_rec_type;
 l_tax_rec                       zx_tds_utilities_pkg.zx_tax_info_cache_rec;
 l_tax_status_rec                zx_tds_utilities_pkg.zx_status_info_rec;
 l_tax_rate_rec                  zx_tds_utilities_pkg.zx_rate_info_rec_type;
 l_tax_jurisdiction_rec          ZX_TDS_UTILITIES_PKG.zx_jur_info_cache_rec_type;
 l_rownum                        BINARY_INTEGER;
 l_error_buffer                  VARCHAR2(200);
 l_tax_regime_code               zx_regimes_b.tax_regime_code%TYPE;
 l_tax_jurisdiction_code         zx_jurisdictions_b.tax_jurisdiction_code%TYPE;
 l_tax                           zx_taxes_b.tax%TYPE;
 l_tax_status_code               zx_status_b.tax_status_code%TYPE;
 l_record_type_code              zx_rates_b.record_type_code%TYPE;
 l_offset_tax_rate_code          zx_rates_b.offset_tax_rate_code%TYPE;
 l_tax_found_in_ap_flag          VARCHAR2(1);

 l_tax_class                     zx_rates_b.tax_class%TYPE;
 l_is_valid                      BOOLEAN;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Bug#5417753- determine tax_class value
  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  l_rownum := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);

  FOR tax_line_rec IN get_taxes_f_intercomp_trx_csr LOOP

    l_is_valid := TRUE;
    l_rownum := l_rownum + 1;

    -- populate tax info fetched from zx_lines to g_detail_tax_lines_tbl
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum) := tax_line_rec;

    -- set tax_line_id to NULL. It will be reset in pop_tax_line_for_trx_line
    --
    -- set tax amount columns to null, they will be rounded later based on the
    -- unrounded tax and taxable amounts
    --
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                 l_rownum).tax_line_id := NULL;
    --bug#8611251
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                 l_rownum).tax_amt := NULL;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                 l_rownum).tax_amt_tax_curr := NULL;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                 l_rownum).tax_amt_funcl_curr := NULL;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                 l_rownum).taxable_amt := NULL;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                 l_rownum).taxable_amt_tax_curr := NULL;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                 l_rownum).taxable_amt_funcl_curr := NULL;
    --Bug 9701132
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                 l_rownum).hq_estb_party_tax_prof_id :=
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hq_estb_party_tax_prof_id(p_trx_line_index);
    --End Bug 9701132
    OPEN  is_tax_migrated_in_ar_csr(tax_line_rec.tax_rate_id);

    FETCH is_tax_migrated_in_ar_csr INTO l_tax_regime_code, l_tax,
                 l_tax_status_code,l_record_type_code, l_offset_tax_rate_code, l_tax_jurisdiction_code;

    IF is_tax_migrated_in_ar_csr%NOTFOUND THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer := 'No Tax Rate Found in AR for the specified Tax Rate Id';
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
               l_error_buffer);
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
      END IF;
      RETURN;
    END IF;

    CLOSE is_tax_migrated_in_ar_csr;

    IF l_record_type_code <> 'MIGRATED' THEN

      -- Ths is not a migrated tax rate code
      -- Need to validate and populate tax_regime_id
      --
      -- Bug fix 5653907: If the tax_amount fetched from source document is 0 and
      -- the tax is not migrated from 11i, it is not madatory to define the same
      -- tax in AP as that in AR. In this case, we do not need to error out if
      -- the validations fail because we can ignore the tax lines fetched from AR
      --
      ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
                        tax_line_rec.tax_regime_code,
                        p_tax_determine_date,
                        l_tax_regime_rec,
                        x_return_status,
                        l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        l_is_valid := FALSE;
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_regime_cache_info');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
        END IF;
        /*IF tax_line_rec.tax_amt <> 0 THEN
          RETURN;
        END IF;*/
      END IF;

      -- Populate tax_regime_id and validate tax_id
      --
      IF l_is_valid THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       l_rownum).tax_regime_id := l_tax_regime_rec.tax_regime_id;

        ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                        tax_line_rec.tax_regime_code,
                        tax_line_rec.tax,
                        p_tax_determine_date,
                        l_tax_rec,
                        x_return_status,
                        l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          l_is_valid := FALSE;
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_tax_cache_info');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
          END IF;
          /*IF tax_line_rec.tax_amt <> 0 THEN
            RETURN;
          END IF;*/

        ELSE    -- x_return_status = FND_API.G_RET_STS_SUCCESS

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                           l_rownum).tax_id := l_tax_rec.tax_id;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                           l_rownum).reporting_only_flag := l_tax_rec.reporting_only_flag;

          -- bug 5077691: populate legal_reporting_status
          --
          IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_rownum).legal_reporting_status :=
                      ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                              l_tax_rec.tax_id).legal_reporting_status_def_val;
          END IF;
        END IF;
      END IF;    -- l_is_valid for tax validation

      -- validate tax_jurisdiction_id
      --
      IF l_is_valid AND tax_line_rec.tax_jurisdiction_code is not NULL THEN

        ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info(
                        tax_line_rec.tax_regime_code,
                        tax_line_rec.tax,
                        tax_line_rec.tax_jurisdiction_code,
                        p_tax_determine_date,
                        l_tax_jurisdiction_rec,
                        x_return_status,
                        l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          l_is_valid := FALSE;
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          /*IF tax_line_rec.tax_amt <> 0 THEN
            RETURN;
          END IF;*/
        ELSE

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    l_rownum).tax_jurisdiction_id :=
                                     l_tax_jurisdiction_rec.tax_jurisdiction_id;
        END IF;
      END IF;    -- l_is_valid for jurisdiction validation

      -- validate tax_status_id
      --
      IF l_is_valid THEN

        ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                        tax_line_rec.tax,
                        tax_line_rec.tax_regime_code,
                        tax_line_rec.tax_status_code,
                        p_tax_determine_date,
                        l_tax_status_rec,
                        x_return_status,
                        l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          l_is_valid := FALSE;
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
          END IF;
          /*IF tax_line_rec.tax_amt <> 0 THEN
            RETURN;
          END IF;*/
        END IF;
      END IF;    -- l_is_valid for status validation

      -- populate tax_status_id and validate tax_rate_id
      --
      IF l_is_valid THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_rownum).tax_status_id := l_tax_status_rec.tax_status_id;

        ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
                        tax_line_rec.tax_regime_code,
                        tax_line_rec.tax,
                        tax_line_rec.tax_jurisdiction_code,
                        tax_line_rec.tax_status_code,
                        tax_line_rec.tax_rate_code,
                        p_tax_determine_date,
                        l_tax_class,
                        l_tax_rate_rec,
                        x_return_status,
                        l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          l_is_valid := FALSE;
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_tax_rate_info');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
          END IF;
          /*IF tax_line_rec.tax_amt <> 0 THEN
            RETURN;
          END IF;*/
        END IF;
      END IF;      -- l_is_valid for tax rate validation

      IF l_is_valid THEN

        IF l_tax_rate_rec.percentage_rate <> tax_line_rec.tax_rate AND --bug 5010575
           l_tax_rate_rec.allow_adhoc_tax_rate_flag = 'N'THEN

          x_return_status := FND_API.G_RET_STS_ERROR;
          l_error_buffer := 'Tax Rate Code is not adhoc';

          FND_MESSAGE.SET_NAME('ZX','ZX_INTER_COMP_RATE');

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_line_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_level_type :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);
          ZX_API_PUB.add_msg(
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   l_error_buffer);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              l_rownum).tax_rate_id := l_tax_rate_rec.tax_rate_id;

        IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).tax_amt = 0 AND
           l_tax_rate_rec.offset_tax_rate_code IS NOT NULL
        THEN

          -- Check if offset tax is allowed, if not raise error
          --
          IF l_tax_rate_rec.percentage_rate <> 0  AND -- bug 5010575
             p_event_class_rec.allow_offset_tax_calc_flag = 'N'
          THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_error_buffer := 'Need to create Offset Tax. But offset tax is not allowed';

            IF g_level_statement >= g_current_runtime_level THEN
              FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                    l_error_buffer);
              FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
            END IF;
            RETURN;
          END IF;

          -- set tax_rate column and amt related columns to NULL
          -- Tax Rate percentage will be determined in ZX_TDS_RATE_DETM_PKG
          --
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                   l_rownum).offset_flag := 'Y';

          IF NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).manually_entered_flag, 'N') = 'N' THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                     l_rownum).tax_rate := NULL;
          END IF;
	  --bug#8611251
          --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --                                            l_rownum).tax_amt := NULL;
          --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --                                   l_rownum).tax_amt_tax_curr := NULL;
          --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --                                 l_rownum).tax_amt_funcl_curr := NULL;
          --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --                                        l_rownum).taxable_amt := NULL;
          --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --                               l_rownum).taxable_amt_tax_curr := NULL;
          --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --                             l_rownum).taxable_amt_funcl_curr := NULL;
        END IF;    -- tax_amt = 0 AND offset_tax_rate_code IS NOT NULL

      ELSE     -- NOT l_is_valid after rate validation

        --IF tax_line_rec.tax_amt = 0 THEN
        -- Commented code to ensure that even if the receivables invoice has a non
        -- zero amount, there should be no error in the Payables invoice.
        -- if the same tax is not applicable in payables.

        -- delete the entry from g_detail_tax_lines_tbl
        --
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.delete(l_rownum);
        l_rownum := l_rownum - 1;

        -- set the return status back to SUCCESS
        --
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF g_level_statement >= g_current_runtime_level THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'Remove this tax line and reset return_status');
        END IF;

        /*ELSE
          -- return with error
          --
          RETURN;

        END IF;*/
      END IF;    -- l_is_valid OR ELSE

    ELSE      -- For migrated tax rate code

      l_tax_found_in_ap_flag := 'N';
      l_tax_regime_code := NULL;
      l_tax := NULL;
      l_tax_status_code := NULL;
      l_tax_jurisdiction_code := NULL;

      OPEN  get_tax_info_f_ap_input(tax_line_rec.tax_rate_code);
      FETCH get_tax_info_f_ap_input INTO
                                   l_tax_regime_code, l_tax, l_tax_status_code, l_tax_jurisdiction_code;
      CLOSE get_tax_info_f_ap_input;

      IF l_tax IS NULL THEN

        OPEN  get_tax_info_f_ap_null(tax_line_rec.tax_rate_code);
        FETCH get_tax_info_f_ap_null INTO
                                l_tax_regime_code, l_tax, l_tax_status_code, l_tax_jurisdiction_code;
        CLOSE get_tax_info_f_ap_null;
      END IF;

        IF l_tax IS NOT NULL THEN
              l_tax_found_in_ap_flag := 'Y';

              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                       'Tax rate code is defined in Payables.');
              END IF;

        ELSE  -- l_tax IS NULL

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   'Tax rate code is not defined in Payables.');
          END IF;

          -- Tax not defined in AP, try to find other tax rate code
          --
          OPEN  get_tax_info_f_not_ap(tax_line_rec.tax_rate_code);
          FETCH get_tax_info_f_not_ap INTO l_tax_regime_code,l_tax,l_tax_status_code,l_tax_jurisdiction_code;
          CLOSE get_tax_info_f_not_ap;

          IF l_tax IS NULL THEN

            -- Matching tax rate code is not defined in AP or other product,
            -- raise error
            --
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_error_buffer := 'tax_amt <> 0. Tax Rate Code is not adhoc';
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                     'Tax rate code is not defined in AP and other product.');
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
            END IF;
            RETURN;
          END IF;
        END IF;

      -- Tax Defined in AP or other product.
      -- Need to validate and populate tax_regime_id
      --
      ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
                        l_tax_regime_code,
                        p_tax_determine_date,
                        l_tax_regime_rec,
                        x_return_status,
                        l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_regime_cache_info');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
        END IF;
        RETURN;
      END IF;

      -- populate new id
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_rownum).tax_regime_id := l_tax_regime_rec.tax_regime_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     l_rownum).tax_regime_code := l_tax_regime_code;

      -- validate and populate tax_id
      --
      ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                        l_tax_regime_code,
                        l_tax,
                        p_tax_determine_date,
                        l_tax_rec,
                        x_return_status,
                        l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_tax_cache_info');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
        END IF;
        RETURN;
      END IF;

      -- populate new id
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         l_rownum).tax_id := l_tax_rec.tax_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         l_rownum).tax := l_tax;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         l_rownum).reporting_only_flag := l_tax_rec.reporting_only_flag;

      -- bug 5077691: populate legal_reporting_status
      IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                l_rownum).legal_reporting_status :=
                      ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                              l_tax_rec.tax_id).legal_reporting_status_def_val;
      END IF;
      --
      -- validate and populate tax_jurisdiction_id
      --
      IF l_tax_jurisdiction_code is not NULL THEN
        ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info(
                        l_tax_regime_code,
                        l_tax,
                        l_tax_jurisdiction_code,
                        p_tax_determine_date,
                        l_tax_jurisdiction_rec,
                        x_return_status,
                        l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info');
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines.END',
                          'ZX_TDS_APPLICABILITY_DETM_PKG.fetch_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                             l_rownum).tax_jurisdiction_id :=
                                     l_tax_jurisdiction_rec.tax_jurisdiction_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                             l_rownum).tax_jurisdiction_code :=
                                     l_tax_jurisdiction_code;
      ELSE
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                             l_rownum).tax_jurisdiction_id := NULL;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                             l_rownum).tax_jurisdiction_code := NULL;
      END IF;


      -- validate and populate tax_status_id
      --
      ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                        l_tax,
                        l_tax_regime_code,
                        l_tax_status_code,
                        p_tax_determine_date,
                        l_tax_status_rec,
                        x_return_status,
                        l_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
        END IF;
        RETURN;
      END IF;

      -- populate new id
      --
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_rownum).tax_status_id := l_tax_status_rec.tax_status_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_rownum).tax_status_code := l_tax_status_code;

     -- validate and populate tax_rate_id and retain rate % and tax amount
     --
     ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
                        l_tax_regime_code,
                        l_tax,
                        l_tax_jurisdiction_code,
                        l_tax_status_code,
                        tax_line_rec.tax_rate_code,
                        p_tax_determine_date,
                        l_tax_class,
                        l_tax_rate_rec,
                        x_return_status,
                        l_error_buffer);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_tax_rate_info');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
        END IF;
        RETURN;
     END IF;

     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_rownum).tax_rate_id := l_tax_rate_rec.tax_rate_id;
     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_rownum).tax_rate := l_tax_rate_rec.percentage_rate;


     IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).tax_amt <> 0
     THEN

        IF l_tax_rate_rec.percentage_rate <> tax_line_rec.tax_rate  AND   -- Bug 5010575
           l_tax_rate_rec.allow_adhoc_tax_rate_flag = 'N'
        THEN

          x_return_status := FND_API.G_RET_STS_ERROR;
          l_error_buffer := 'Tax Rate Code is not adhoc';
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   l_error_buffer);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
          END IF;
          RETURN;
        END IF;

        --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                        l_rownum).tax_rate_id := l_tax_rate_rec.tax_rate_id;
        --IF l_tax_found_in_ap_flag = 'Y' THEN

          -- replace tax_regime_code, tax and tax_status_code
          --
          --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --                                   l_rownum).tax_regime_code := l_tax_regime_code;
          --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --                                               l_rownum).tax := l_tax;
          --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
          --                                   l_rownum).tax_status_code := l_tax_status_code;

        --END IF;

      ELSE        -- tax_amt = 0

        -- Check if offset tax is allowed, if not raise error
        --
        -- Offset tax Flag should be set only when the tax percentage rate
        -- is not zero.
        IF l_tax_rate_rec.percentage_rate <> 0 THEN  -- Bug 5010575
          IF p_event_class_rec.allow_offset_tax_calc_flag = 'N'
          THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_error_buffer := 'Need to create Offset Tax. But offset tax is not allowed';

            IF g_level_statement >= g_current_runtime_level THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                      l_error_buffer);
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
            END IF;
            RETURN;
          ELSE
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                   l_rownum).offset_flag := 'Y';
          END IF;
        ELSE
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                   l_rownum).offset_flag := 'N';
        END IF;

        -- set tax_rate column and amt related columns to NULL
        -- Tax Rate percentage will be determined in ZX_TDS_RATE_DETM_PKG
        --
        --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                                           l_rownum).offset_flag := 'Y';

        -- Tax rate percentage derivation should be done here itself for non manual
        -- tax lines as well.

        --IF NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_rownum).manually_entered_flag, 'N') = 'N' THEN
        --  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                                             l_rownum).tax_rate := NULL;
        --END IF;
        --bug#8611251
        --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                                              l_rownum).tax_amt := NULL;
        --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                                     l_rownum).tax_amt_tax_curr := NULL;
        --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                                   l_rownum).tax_amt_funcl_curr := NULL;
        --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                                          l_rownum).taxable_amt := NULL;
        --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                                 l_rownum).taxable_amt_tax_curr := NULL;
        --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
        --                               l_rownum).taxable_amt_funcl_curr := NULL;
      END IF;     -- tax_amt <> 0 OR NOT
    END IF;       -- tax rate code is migrated or not

    IF l_is_valid THEN
      -- set x_begin_index
      --
      IF (x_begin_index is NULL) THEN
        x_begin_index := l_rownum;
      END IF;

      populate_registration_info(
         p_event_class_rec    => p_event_class_rec,
         p_trx_line_index     => p_trx_line_index,
         p_rownum             => l_rownum,
         p_def_reg_type       => l_tax_rec.def_registr_party_type_code,
         p_reg_rule_flg       => l_tax_rec.registration_type_rule_flag,
         p_tax_determine_date => p_tax_determine_date,
         x_return_status      => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info');
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
        END IF;
        RETURN;
      END IF;
    END IF;    -- l_is_valid
  END LOOP;    -- tax_line_rec IN get_taxes_f_intercomp_trx_csr

  -- set x_end_index
  --
  IF (x_begin_index IS NOT NULL) THEN
    x_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;
  END IF;

  ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines (p_trx_line_index,
                                                       x_begin_index,
                                                       x_end_index,
                                                       x_return_status,
                                                       l_error_buffer );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
               'Incorrect RETURN_STATUS after calling '||
               'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
      END IF;
      RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
           'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx.END',
                    'ZX_TDS_APPLICABILITY_DETM_PKG.get_taxes_for_intercomp_trx(-)');
    END IF;

END get_taxes_for_intercomp_trx;

-- Added for STCC Bug 4959835
---------------------------------------------------------------------
-- PUBLIC PROCEDURE
--  get_process_results
--
--  DESCRIPTION: This procedure is to fetch the applicable tax lines
--               directly from the process results for non-location based
--               scenario (P2P and O2C VAT)
--
--  January 05, 2006     Usha Srikumaran     Created
--

PROCEDURE get_process_results(
  p_trx_line_index        IN            BINARY_INTEGER,
  p_tax_date              IN            DATE,
  p_tax_determine_date    IN            DATE,
  p_tax_point_date        IN            DATE,
  p_event_class_rec       IN            zx_api_pub.event_class_rec_type,
  x_begin_index           IN OUT NOCOPY BINARY_INTEGER,
  x_end_index             IN OUT NOCOPY BINARY_INTEGER,
  x_return_status            OUT NOCOPY VARCHAR2) IS

  CURSOR get_unique_constraint_csr(
          c_tax_classification_code    zx_lines_det_factors.input_tax_classification_code%TYPE,
          c_internal_organization_id   zx_lines_det_factors.internal_organization_id%TYPE)
  IS
  SELECT cg.constraint_id
    FROM zx_condition_groups_b cg,
         ar_tax_conditions_all tc
   WHERE cg.condition_group_code like c_tax_classification_code||'~'||'%'
     AND cg.enabled_flag = 'Y'
     AND cg.constraint_id IS NOT NULL
     AND tc.tax_condition_id = cg.constraint_id
     AND tc.org_id = c_internal_organization_id;


--  CURSOR get_constraints_csr
--         (c_tax_classification_code  zx_lines_det_factors.input_tax_classification_code%TYPE)
--  IS
--  SELECT cg.CONSTRAINT_ID
--    FROM zx_condition_groups_b cg
--   WHERE cg.CONDITION_GROUP_CODE like c_tax_classification_code||'~'||'%'
--     AND cg.enabled_flag = 'Y'
--     AND cg.constraint_id IS NOT NULL;
--
--
--  CURSOR get_unique_constraint_csr(
--          c_tax_classification_code    zx_lines_det_factors.input_tax_classification_code%TYPE,
--          c_internal_organization_id   zx_lines_det_factors.internal_organization_id%TYPE)
--  IS
--  SELECT cg.constraint_id
--    FROM zx_condition_groups_b cg,
--         ar_tax_conditions tc
--   WHERE cg.condition_group_code like c_tax_classification_code||'~'||'%'
--     AND cg.enabled_flag = 'Y'
--     AND tc.tax_condition_id = cg.constraint_id
--     AND tc.org_id = c_internal_organization_id;

  CURSOR get_candidate_taxes_csr(
         c_condition_group_code   zx_condition_groups_b.condition_group_code%TYPE,
         c_tax_rate_code      zx_rates_b.tax_rate_code%TYPE,
         c_tax_class          zx_rates_b.tax_class%TYPE,
         c_tax_determine_date DATE) IS
SELECT tax_regime_code,
       tax,
       status_result,
       rate_result,
       condition_set_id,
       exception_set_id,
       result_id,
       query_num
FROM
   (SELECT /*+ leading(PR) use_nl(RL) */
         rl.tax_regime_code,
         rl.tax,
         pr.status_result,
         pr.rate_result,
         pr.condition_set_id,
         pr.exception_set_id,
         pr.result_id,
         1  query_num,
         tax.compounding_precedence
    FROM ZX_PROCESS_RESULTS pr,
         ZX_SCO_RULES_B_V rl,
         ZX_SCO_TAXES_B_V tax
         --ZX_SCO_RATES_B_V rt
    WHERE (pr.CONDITION_GROUP_CODE = c_condition_group_code or
          pr.CONDITION_GROUP_CODE like c_condition_group_code ||'~'||'%')
     AND rl.effective_from <= c_tax_determine_date                              ---Bug 5691957
     AND (rl.effective_to  >= c_tax_determine_date OR rl.effective_to IS NULL ) ---Bug 5691957
     AND pr.enabled_flag = 'Y'
     AND rl.tax_rule_id = pr.tax_rule_id
     AND rl.service_type_code = 'DET_DIRECT_RATE'
     AND tax.tax_regime_code=rl.tax_regime_code
     AND tax.tax=rl.tax
     AND EXISTS
              (SELECT /*+ no_unnest */ 1
               FROM ZX_SCO_RATES_B_V rt
               WHERE rt.tax_regime_code = rl.tax_regime_code                                -- bug 6680676
               AND   rt.tax = rl.tax
               AND   rt.tax_status_code = pr.status_result
               AND   rt.tax_rate_code = pr.rate_result
               AND   rt.effective_from <= c_tax_determine_date
               AND  (rt.effective_to  >= c_tax_determine_date OR rt.effective_to IS NULL )
               AND   rt.Active_Flag = 'Y'
               AND  (rt.tax_class = c_tax_class OR rt.tax_class IS NULL))
  UNION ALL
  SELECT /*+ leading(RT.a) use_nl(RT.sd) */
         DISTINCT rt.tax_regime_code,
         rt.tax,
         rt.tax_status_code,
         rt.tax_rate_code,
         NULL  condition_set_id,
         NULL  exception_set_id,
         NULL  result_id,
         2     query_num,
         -1    compounding_precedence
    FROM ZX_SCO_RATES_B_V rt
   WHERE rt.tax_rate_code = c_tax_rate_code
     AND rt.rate_type_code <> 'RECOVERY'
     AND rt.effective_from <= c_tax_determine_date
     AND (rt.effective_to  >= c_tax_determine_date OR rt.effective_to IS NULL )
     AND rt.Active_Flag = 'Y'
     AND (rt.tax_class = c_tax_class or rt.tax_class IS NULL)
-- Bug 5481559: Though jurisdiction code is NULL for migrated tax classification
--              codes, it can be entered for newly created tax rates, in which
--              case,w e should consider the tax rate if jurisdiction matches. i--              Jurisdiction match will be checked when place of supply is
--              validated.
--    AND rt.tax_jurisdiction_code is NULL
     AND EXISTS (SELECT 1
                  FROM ZX_SCO_TAXES_B_V tax
                 WHERE tax.tax_regime_code = rt.tax_regime_code
                   AND tax.tax = rt.tax
                   AND tax.live_for_processing_flag = 'Y'
                   AND tax.live_for_applicability_flag = 'Y')
 )
 order by compounding_precedence nulls first;

  -- To filter based on rate class
  --
  CURSOR check_tax_rate_class_csr(
         c_tax_regime_code    zx_rates_b.tax_regime_code%TYPE,
         c_tax                zx_rates_b.tax%TYPE,
         c_tax_status_code    zx_rates_b.tax_status_code%TYPE,
         c_tax_rate_code      zx_rates_b.tax_rate_code%TYPE,
         c_tax_class          zx_rates_b.tax_class%TYPE,
         c_tax_determine_date DATE) IS
  SELECT 1
    FROM ZX_SCO_RATES_B_V
   WHERE tax_regime_code = c_tax_regime_code
     AND tax = c_tax
     AND tax_status_code = c_tax_status_code
     AND tax_rate_code = c_tax_rate_code
     AND effective_from <= c_tax_determine_date
     AND (effective_to  >= c_tax_determine_date OR effective_to IS NULL )
     AND Active_Flag = 'Y'
     AND (tax_class = c_tax_class or tax_class IS NULL)
     AND rownum=1;

   -- cursor to order the jurisdictions in the GT
  CURSOR c_get_jurisdiction_from_gt(
           c_tax_regime_code  VARCHAR2,
           c_tax              VARCHAR2)IS
    SELECT tax_jurisdiction_id,
           tax_jurisdiction_code,
           tax_regime_code,
           tax,
           precedence_level
      FROM zx_jurisdictions_gt
     WHERE tax_regime_code = c_tax_regime_code
       AND tax = c_tax
     ORDER BY precedence_level;


     CURSOR  get_tax_info_csr(c_tax_regime_code    IN ZX_REGIMES_B.tax_regime_code%TYPE,
                              c_tax                IN zx_taxes_b.tax%TYPE,
                              c_tax_determine_date IN DATE) IS
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
    WHERE tax = c_tax
      AND tax_regime_code = c_tax_regime_code
      AND (effective_from <= c_tax_determine_date AND
            (effective_to >= c_tax_determine_date OR effective_to IS NULL))
      AND live_for_processing_flag = 'Y'
      AND live_for_applicability_flag = 'Y'
      -- AND rownum = 1;
    ORDER BY subscription_level_code;


  -- Local variables
  --
  l_constraint_id              zx_condition_groups_b.constraint_id%TYPE;
  l_condition_group_code       zx_condition_groups_b.condition_group_code%TYPE;
  l_tax_classification_code    zx_lines_det_factors.input_tax_classification_code%TYPE;
  l_internal_organization_id   zx_lines_det_factors.internal_organization_id%TYPE;
  l_cec_result                 BOOLEAN;
  l_action_rec_tbl             ZX_TDS_PROCESS_CEC_PVT.action_rec_tbl_type;
  l_tax_regime_code_tbl        tax_regime_code_tbl;
  l_tax_tbl                    tax_tbl;
  l_result_id_tbl              result_id_tbl;
  l_query_num_tbl              ZX_GLOBAL_STRUCTURES_PKG.NUMBER_tbl_type;
  l_status_result_tbl          status_result_tbl;
  l_rate_result_tbl            rate_result_tbl;
  l_condition_set_tbl          condition_set_tbl;
  l_exception_set_tbl          exception_set_tbl;
  l_counter                    NUMBER;
  i                            NUMBER;
  l_tax_regime_rec             zx_global_structures_pkg.tax_regime_rec_type;
  l_tax_rec                    ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
  l_tax_status_rec             ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
  l_tax_rate_rec               ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
  l_error_buffer               VARCHAR2(200);
  l_rownum                     BINARY_INTEGER;
  l_curr_rownum                BINARY_INTEGER;
  l_tax_class                  zx_rates_b.tax_class%TYPE;
  l_temp_num                   NUMBER;
  l_jurisdictions_found        VARCHAR2(1);
  l_jurisdiction_rec           ZX_TCM_GEO_JUR_PKG.tax_jurisdiction_rec_type;
  l_place_of_supply_type_code  zx_taxes_b.def_place_of_supply_type_code%TYPE;
  l_place_of_supply_result_id  NUMBER;
  l_begin_index                BINARY_INTEGER;
  l_end_index                  BINARY_INTEGER;
  l_regimerownum               BINARY_INTEGER;
  l_tax_index                  NUMBER;
  l_trx_line_id                NUMBER;
  l_trx_level_type             VARCHAR2(30);

  l_self_assessed_flag         zx_lines.self_assessed_flag%TYPE;
  l_tax_amt_included_flag      zx_lines.tax_amt_included_flag%TYPE;
  l_tax_jurisdiction_id        zx_lines.tax_jurisdiction_id%TYPE;
  l_tax_jurisdiction_code      zx_lines.tax_jurisdiction_code%TYPE;
  l_jur_index                  NUMBER;
  l_jurisdiction_rec_tbl       ZX_TCM_GEO_JUR_PKG.tax_jurisdiction_rec_tbl_type;
  l_index                      NUMBER;
  l_tbl_index                  BINARY_INTEGER;
  l_rate_exists_same_prod_family BOOLEAN;
  l_tax_applicable               BOOLEAN;
  l_applicability_result_id    NUMBER;
  l_applicability_result       zx_process_results.alphanumeric_result%TYPE;
  l_exception_rate             zx_lines.exception_rate%TYPE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_tax_classification_code :=
    NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE(p_trx_line_index),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_trx_line_index));

  l_internal_organization_id :=
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(p_trx_line_index);

  l_condition_group_code := l_tax_classification_code;

  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  l_trx_line_id :=
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
  l_trx_level_type :=
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

  IF l_tax_classification_code IS NOT NULL THEN
  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                p_trx_line_index) = 'CREATE' OR
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                p_trx_line_index) = 'CREATE_WITH_TAX' OR
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                p_trx_line_index) = 'UPDATE' OR
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                p_trx_line_index) = 'CREATE_TAX_ONLY' OR
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                p_trx_line_index) = 'COPY_AND_CREATE'
  THEN


    IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN


      OPEN  get_unique_constraint_csr(l_tax_classification_code,
                                      l_internal_organization_id);
      FETCH get_unique_constraint_csr INTO l_constraint_id;
      CLOSE get_unique_constraint_csr;

--      OPEN  get_constraints_csr(l_tax_classification_code);
--
--      -- There may be multiple records if there are 2 tax groups with the same code
--      -- having different constraint_id. In that case, get the correct record based
--      -- on the internal OU.
--
--      IF get_constraints_csr%ROWCOUNT > 1 THEN
--
--        OPEN  get_unique_constraint_csr(l_tax_classification_code,
--                                        l_internal_organization_id);
--        FETCH get_unique_constraint_csr into l_constraint_id;
--        CLOSE get_unique_constraint_csr;
--      ELSE
--        FETCH get_constraints_csr into l_constraint_id;
--      END IF;

      IF l_constraint_id IS NOT NULL THEN
        l_condition_group_code := l_tax_classification_code || '~' ||
                                  l_constraint_id;

        -- The following procedure is currently PRIVATE inside rule engine.
        -- It has to be made public to be called as below

        ZX_TDS_RULE_BASE_DETM_PVT.init_cec_params (
                                    p_structure_name  => 'TRX_LINE_DIST_TBL',
                                    p_structure_index => p_trx_line_index,
                                    p_return_status   => x_return_status,
                                    p_error_buffer    => l_error_buffer);

        ZX_TDS_PROCESS_CEC_PVT.evaluate_cec(
                            p_constraint_id                => l_constraint_id,
                            p_cec_ship_to_party_site_id    => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_ship_to_party_site_id,
                            p_cec_bill_to_party_site_id    => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_bill_to_party_site_id,
                            p_cec_ship_to_party_id         => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_ship_to_party_id,
                            p_cec_bill_to_party_id         => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_bill_to_party_id,
                            p_cec_poo_location_id          => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_poo_location_id,
                            p_cec_poa_location_id          => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_poa_location_id,
                            p_cec_trx_id                   => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_trx_id,
                            p_cec_trx_line_id              => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_trx_line_id,
                            p_cec_ledger_id                => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_ledger_id,
                            p_cec_internal_organization_id => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_internal_organization_id,
                            p_cec_so_organization_id       => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_so_organization_id,
                            p_cec_product_org_id           => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_product_org_id,
                            p_cec_product_id               => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_product_id,
                            p_cec_trx_line_date            => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_trx_line_date,
                            p_cec_trx_type_id              => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_trx_type_id,
                            p_cec_fob_point                => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_fob_point,
                            p_cec_ship_to_site_use_id      => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_ship_to_site_use_id,
                            p_cec_bill_to_site_use_id      => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_bill_to_site_use_id,
                            p_cec_result                   => l_cec_result,
                            p_action_rec_tbl               => l_action_rec_tbl,
                            p_return_status                => x_return_status,
                            p_error_buffer                 => l_error_buffer);

        FOR i IN 1.. NVL(l_action_rec_tbl.last,0) LOOP

          IF UPPER(l_action_rec_tbl(i).action_code) in ('ERROR_MESSAGE','SYSTEM_ERROR') then
            x_return_status := FND_API.G_RET_STS_ERROR;
            app_exception.raise_exception;
          ELSIF UPPER(l_action_rec_tbl(i).action_code) = 'DO_NOT_USE_THIS_TAX_GROUP' then
            l_cec_result := FALSE;
          ELSIF  UPPER(l_action_rec_tbl(i).action_code) = 'USE_THIS_TAX_GROUP' then
            l_cec_result := TRUE;
          ELSIF UPPER(l_action_rec_tbl(i).action_code) = 'DEFAULT_TAX_CODE' then

            NULL;
            --++ How do we default a Tax Code at Tax Group level if there are
            --   multiple tax codes associated with that tax group? Even if we default,
            --   should we evaluate the conditions and exceptions and if there is an action
            --   DEFAULT_TAX_CODE should we honour that one ? Revisit later
          END IF;
        END LOOP;
      END IF;   -- l_constraint_id IS NOT NULL

--      CLOSE get_constraints_csr;

    END IF; -- O2C prod family grp

    IF l_cec_result OR l_constraint_id IS NULL THEN

      l_curr_rownum := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);
      l_rownum := l_curr_rownum;

      -- Evaluate the conditions and exceptions
      --

      OPEN get_candidate_taxes_csr(
         c_condition_group_code => l_condition_group_code,
         c_tax_rate_code        => l_tax_classification_code,
         c_tax_class            => l_tax_class,
         c_tax_determine_date   => p_tax_determine_date);

      LOOP
        FETCH get_candidate_taxes_csr bulk collect INTO
                  l_tax_regime_code_tbl,
                  l_tax_tbl,
                  l_status_result_tbl,
                  l_rate_result_tbl,
                  l_condition_set_tbl,
                  l_exception_set_tbl,
                  l_result_id_tbl,
                  l_query_num_tbl
        LIMIT c_lines_per_commit;

      l_counter := l_tax_regime_code_tbl.count;

      FOR j IN 1..l_counter LOOP

        l_tax_index := NULL;

        l_end_index := NVL( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);
        -- Check if this tax line exists in the new created applicable tax lines
        l_tax_index := ZX_TDS_UTILITIES_PKG.get_tax_index(
                                           l_tax_regime_code_tbl(j),
                                           l_tax_tbl(j),
                                           l_trx_line_id,
                                           l_trx_level_type,
                                           x_begin_index,
                                           l_end_index,
                                           x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_tax_index');
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(-)');
          END IF;
          RETURN;
        END IF;

        --Only process the taxes which has NOT been added to the detail tax lines.
        IF l_tax_index is NULL THEN

          IF l_condition_set_tbl(j) IS NOT NULL OR l_exception_set_tbl(j) IS NOT NULL
          THEN

            l_action_rec_tbl.delete;
            l_cec_result := TRUE;		-- bugfix 5572117
            l_exception_rate := NULL;           -- bugfix 6906653


            IF  l_constraint_id is NULL then



              -- The initialization would have occurred earlier if the constraint_id was NOT NULL

               ZX_TDS_RULE_BASE_DETM_PVT.init_cec_params (

                                p_structure_name  => 'TRX_LINE_DIST_TBL',

                                p_structure_index => p_trx_line_index,

                                p_return_status   => x_return_status,

                                p_error_buffer    => l_error_buffer);

            END IF;



            ZX_TDS_PROCESS_CEC_PVT.evaluate_cec(
                          p_condition_set_id             => l_condition_set_tbl(j),
                          p_exception_set_id             => l_exception_set_tbl(j),
                          p_cec_ship_to_party_site_id    => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_ship_to_party_site_id,
                          p_cec_bill_to_party_site_id    => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_bill_to_party_site_id,
                          p_cec_ship_to_party_id         => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_ship_to_party_id,
                          p_cec_bill_to_party_id         => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_bill_to_party_id,
                          p_cec_poo_location_id          => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_poo_location_id,
                          p_cec_poa_location_id          => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_poa_location_id,
                          p_cec_trx_id                   => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_trx_id,
                          p_cec_trx_line_id              => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_trx_line_id,
                          p_cec_ledger_id                => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_ledger_id,
                          p_cec_internal_organization_id => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_internal_organization_id,
                          p_cec_so_organization_id       => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_so_organization_id,
                          p_cec_product_org_id           => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_product_org_id,
                          p_cec_product_id               => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_product_id,
                          p_cec_trx_line_date            => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_trx_line_date,
                          p_cec_trx_type_id              => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_trx_type_id,
                          p_cec_fob_point                => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_fob_point,
                          p_cec_ship_to_site_use_id      => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_ship_to_site_use_id,
                          p_cec_bill_to_site_use_id      => ZX_TDS_RULE_BASE_DETM_PVT.g_cec_bill_to_site_use_id,
                          p_cec_result                   => l_cec_result,
                          p_action_rec_tbl               => l_action_rec_tbl,
                          p_return_status                => x_return_status,
                          p_error_buffer                 => l_error_buffer);

       for i in 1.. nvl(l_action_rec_tbl.last,0) loop

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                   'action code ' ||
                   l_action_rec_tbl(i).action_code);
	   END IF;
           if upper(l_action_rec_tbl(i).action_code) in ('ERROR_MESSAGE','SYSTEM_ERROR') then
              x_return_status := FND_API.G_RET_STS_ERROR;
              IF (g_level_error >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result',
                               'Action_code is ERROR_MESSAGE,SYSTEM_ERROR');
              END IF;

              app_exception.raise_exception;
           elsif upper(l_action_rec_tbl(i).action_code) in  ('DO_NOT_USE_THIS_TAX_CODE',
                                                            'DO_NOT_USE_THIS_TAX_GROUP') then
              l_cec_result := FALSE;

           elsif  upper(l_action_rec_tbl(i).action_code) in ('USE_THIS_TAX_CODE','USE_TAX_CODE',
                                                              'DEFAULT_TAX_CODE','DO_NOT_APPLY_EXCEPTION') then --Bug 5865988
              l_cec_result := TRUE;

-- Bug 5730672

              IF upper(l_action_rec_tbl(i).action_code)= 'DEFAULT_TAX_CODE' THEN
                 BEGIN
                    SELECT DISTINCT rt.tax_status_code,
                                    rt.tax_rate_code,
                                    2
                      INTO l_status_result_tbl(j),
                           l_rate_result_tbl(j),
                           l_query_num_tbl(j)
                      FROM ZX_SCO_RATES_B_V rt
                     WHERE rt.tax_rate_code = l_action_rec_tbl(i).action_value
                       AND tax_regime_code = l_tax_regime_code_tbl(j)
                       AND tax = l_tax_tbl(j)
                       AND rt.effective_from <= p_tax_determine_date
                       AND (rt.effective_to  >= p_tax_determine_date
                           OR rt.effective_to IS NULL )
                       AND rt.Active_Flag = 'Y'
                       AND (rt.tax_class = l_tax_class or rt.tax_class IS NULL)
                       AND EXISTS (SELECT 1
                                     FROM ZX_SCO_TAXES_B_V tax
                                    WHERE tax.tax_regime_code = rt.tax_regime_code
                                      AND tax.tax = rt.tax
                                      AND tax.live_for_processing_flag = 'Y'
                                      AND tax.live_for_applicability_flag = 'Y');
                 EXCEPTION
                    WHEN OTHERS THEN
                       l_cec_result := FALSE;       -- Revisit
                 END;
              END IF;
-- Bug 5730672

/*
             if upper(l_action_rec_tbl(i).action_code)= 'USE_THIS_TAX_CODE' then
                 get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'OUTPUT_TAX_CLASSIFICATION_CODE',
                     l_override_tax_rate_code,
                     p_return_status,
                     p_error_buffer);
             elsif upper(l_action_rec_tbl(i).action_code)in ('DEFAULT_TAX_CODE','USE_TAX_CODE') then
                  l_override_tax_rate_code := l_action_rec_tbl(i).action_value;
             end if;

             -- Get the Tax regime, Tax, Status, Rate Code based on override_tax_rate_code
             -- and set it on the result_rec.

                 Open select_tax_status_rate_code (p_tax_regime_code, p_tax, l_override_tax_rate_code,
                                                   p_tax_determine_date);
                 fetch select_tax_status_rate_code into l_tax_status_code, l_tax_rate_code;

                 If select_tax_status_rate_code%NOTFOUND then
                    --A record does not exist with that tax rate code for the given tax.
                    --Raise error;

                    p_return_status := FND_API.G_RET_STS_ERROR;
                    p_error_buffer  := SUBSTR(SQLERRM, 1, 80);
                    IF (g_level_error >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_error,
                                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result',
                                      'Cannot set the tax rate code to '||l_override_tax_rate_code ||
                                      ', ERROR: '||p_error_buffer);
                    END IF;
                    IF select_tax_status_rate_code%isopen then
                         Close select_tax_status_rate_code;
                    END IF;
                    app_exception.raise_exception;
                 ELSE
                    p_zx_result_rec.rate_result := l_tax_rate_code;
                    p_zx_result_rec.status_result :=  l_tax_status_code;
                 End if;

                 Close select_tax_status_rate_code;
          */
           elsif upper(l_action_rec_tbl(i).action_code)= 'DO_NOT_APPLY_EXCEPTION' then
                 NULL;
           elsif upper(l_action_rec_tbl(i).action_code) = 'APPLY_EXCEPTION' then
                -- populate the numeric result column of the result rec.
                -- This rate will be used during Tax Rate Determination process
                -- The Rate determination process will check if the rate is ad-hoc and
                -- accordingly honour this rate or raise exception.
              l_cec_result := TRUE;
	      --bug6604498
	      l_exception_rate := to_number(l_action_rec_tbl(i).action_value);

/*            this part also needs to be revisited.  How to use an exception rate.
               Begin
                p_zx_result_rec.numeric_result := l_action_rec_tbl(i).action_value;
               exception
                when others then
                    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
                    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','The action value for APPLY_EXCEPTION action code'||
                        'does not contain number');
                    FND_MSG_PUB.Add;
                    IF (g_level_error >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_error,
                                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result',
                                     'The action value for APPLY_EXCEPTION action code '||
                                     'does not contain number');
                    END IF;
                    app_exception.raise_exception;
               end;
*/
           end if;
	end loop;
          END IF; -- Not null conditions or exceptions

          -- Question: Should we check for l_action_rec_tbl? refer to get_result
          -- procedure in zxdirulenginpvtb.pls for this

          IF (l_cec_result OR
              (l_condition_set_tbl(j) IS NULL and l_exception_set_tbl(j) is NULL))
          THEN

            l_rate_exists_same_prod_family := TRUE;

            IF l_rate_result_tbl(j) IS NOT NULL
            -- nipatel need to check if rate exists in the same product family only
            -- if the record was fetched from the first query (i.e. based on rules)
            AND l_query_num_tbl(j) = 1 THEN

              -- Filter based on tax rate class
              -- Check if tax rate exists in the same product family group
              --

                  l_tbl_index := dbms_utility.get_hash_value(
                     l_tax_regime_code_tbl(j)||l_tax_tbl(j)||
                     l_status_result_tbl(j)||l_rate_result_tbl(j),
                     1,
                     8192);


                  IF  ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash.exists(l_tbl_index)
                  THEN
                  -- cehck the product family from the cached structure

                     IF  ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash(l_tbl_index).tax_class is NULL THEN

                           l_rate_exists_same_prod_family := TRUE;

                     ELSIF (ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash(l_tbl_index).tax_class is NOT NULL
                     AND ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash(l_tbl_index).tax_class = l_tax_class)
                     THEN

                            l_rate_exists_same_prod_family := TRUE;

                     ELSIF (ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash(l_tbl_index).tax_class is NOT NULL
                     AND ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash(l_tbl_index).tax_class <> l_tax_class)
                     THEN

                            l_rate_exists_same_prod_family := FALSE;

                     END IF;
                 END IF; -- ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash.exists(l_tbl_index)

                 IF ( NOT ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash.exists(l_tbl_index) )
                 OR  l_rate_exists_same_prod_family = FALSE THEN
                 -- check product family using cursor

                       OPEN  check_tax_rate_class_csr(
                                    l_tax_regime_code_tbl(j),
                                    l_tax_tbl(j),
                                    l_status_result_tbl(j),
                                    l_rate_result_tbl(j),
                                    l_tax_class,
                                    p_tax_determine_date);
                        FETCH check_tax_rate_class_csr INTO l_temp_num;

                        IF check_tax_rate_class_csr%NOTFOUND THEN

                          close check_tax_rate_class_csr;
                          l_rate_exists_same_prod_family := FALSE;
                          -- tax not applicable. goto the next record
                          --
                          IF (g_level_statement >= g_current_runtime_level ) THEN
                            FND_LOG.STRING(g_level_statement,
                                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                                   'Tax Rate does not exist in this product family group. ');
                          END IF;
                        ELSE
                          close check_tax_rate_class_csr;
                        END IF;

                 END IF; -- check product family using cursor

            END IF;  -- l_rate_result_tbl(j) IS NOT NULL

            -- Handle for candidate taxes got from direct rate rules without tax rate/status defined
            -- and taxes got from rates_b table with approperiate rate defined.
            IF l_rate_result_tbl(j) IS NULL OR
              (l_rate_result_tbl(j) IS NOT NULL AND l_rate_exists_same_prod_family)
            THEN
              -- validate and populate tax_id
              --

              -- Bug 5252411

             l_index := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl.FIRST;
             l_tax_rec := NULL;
             WHILE l_index IS NOT NULL LOOP

               IF (l_tax_tbl(j) = ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_index).tax AND
                   l_tax_regime_code_tbl(j) = ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_index).tax_regime_code)
               THEN
                 IF (g_level_statement >= g_current_runtime_level ) THEN
                   FND_LOG.STRING(g_level_statement,
                                  'ZX.PLSQL.ZX_TDS_UTILITIES_PKG.get_tax_cache_info',
                                  'tax found in tax cache, at index '||
                                   to_char(l_index));
                 END IF;

                 IF  ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_index).effective_from <= p_tax_determine_date
                 AND (ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_index).effective_to >= p_tax_determine_date
                      OR ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_index).effective_to IS NULL)
                 THEN
                   l_tax_rec := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_index);

                 END IF;
                 EXIT;
               END IF;  -- tax found in cache

               l_index := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl.NEXT(l_index);
             END LOOP;

             -- tax not exists in the cache structure, retrieve tax info from table
             IF l_tax_rec.TAX IS NULL THEN

                  OPEN get_tax_info_csr(l_tax_regime_code_tbl(j),
                                        l_tax_tbl(j),
                                        p_tax_determine_date);
                  FETCH get_tax_info_csr into l_tax_rec;
                  CLOSE get_tax_info_csr;

                  -- bug fix 5579156: cache the tax detail info when tax found effective.
                  IF l_tax_rec.tax_id IS NOT NULL THEN
                    ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_rec.tax_id) := l_tax_rec;
                  END IF;

             END IF;


               IF l_tax_rec.TAX IS NOT NULL THEN -- Process tax only if it is enabled for processing

                 get_place_of_supply(
                    p_event_class_rec             => p_event_class_rec,
                    p_tax_regime_code             => l_tax_rec.tax_regime_code,
                    p_tax_id                      => l_tax_rec.tax_id,
                    p_tax                         => l_tax_rec.tax,
                    p_tax_determine_date          => p_tax_determine_date,
                    p_def_place_of_supply_type_cd => l_tax_rec.def_place_of_supply_type_code,
                    p_place_of_supply_rule_flag   => l_tax_rec.place_of_supply_rule_flag,
                    p_applicability_rule_flag     => l_tax_rec.applicability_rule_flag,
                    p_def_reg_type                => l_tax_rec.def_registr_party_type_code,
                    p_reg_rule_flg                => l_tax_rec.registration_type_rule_flag,
                    p_trx_line_index              => p_trx_line_index,
                    p_direct_rate_result_id       => l_result_id_tbl(j),
                    x_jurisdiction_rec            => l_jurisdiction_rec,
                    x_jurisdictions_found         => l_jurisdictions_found,
                    x_place_of_supply_type_code   => l_place_of_supply_type_code,
                    x_place_of_supply_result_id   => l_place_of_supply_result_id,
                    x_return_status               => x_return_status);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF (g_level_statement >= g_current_runtime_level ) THEN
                     FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                            'Incorrect return_status after calling ' ||
                            'ZX_TDS_APPLICABILITY_DETM_PKG.get_place_of_supply');
                   END IF;

                   -- For migrated taxes, if the has_other_jurisdictions_flag on the tax is 'N',
                   -- no jurisdiction required, so ignore the errors raised from get_place_of_supply
                   --
                   IF NVL(l_tax_rec.has_other_jurisdictions_flag, 'N') = 'N' AND
                     NVL(l_tax_rec.record_type_code, 'USER_DEFINED') = 'MIGRATED'
                   THEN
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                     IF (g_level_statement >= g_current_runtime_level ) THEN
                       FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                              'For migrated taxes, if the has_other_jurisdictions_flag on ' ||
                              'the tax is N, no jurisdiction required. Continue processing tax... ');
                     END IF;

                   ELSE
                     IF (g_level_statement >= g_current_runtime_level ) THEN
                       FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                              'Unable to determine the Place of Supply for tax: '||l_tax_rec.tax||
                              ' Place of Supply is mandatory when Direct Rate Determination is for l usocation based taxes');
                       FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results.END',
                              'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(-)'||', RETURN_STATUS = ' || x_return_status);
                     END IF;

                     RETURN;
                   END IF;
                 END IF;

                 -- bug 5120930
                 l_tax_applicable := FALSE;

                 IF (l_jurisdictions_found = 'Y' OR
                     NVL(l_tax_rec.has_other_jurisdictions_flag, 'N') = 'N') THEN

                    IF l_jurisdictions_found = 'Y'
                      AND l_jurisdiction_rec.tax_jurisdiction_code IS NULL
                    THEN

                      -- for multiple jurisdictions case: cache the most inner
                      -- and outer jurisdiction for future usage

                      OPEN c_get_jurisdiction_from_gt(l_tax_rec.tax_regime_code, l_tax_rec.tax);
                      FETCH c_get_jurisdiction_from_gt
                        BULK COLLECT INTO l_jurisdiction_rec_tbl;
                      CLOSE c_get_jurisdiction_from_gt;

                      IF l_jurisdiction_rec_tbl.COUNT = 0 THEN

                        IF (g_level_statement >= g_current_runtime_level ) THEN
                          FND_LOG.STRING(g_level_statement,
                               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                               'No data found in ZX_JURISDICTIONS_GT when multiple jurisdictions found.');
                        END IF;
                        RAISE NO_DATA_FOUND;

                      END IF;
                      -- cache the global most inner and outer jurisdiction code
                      l_jur_index := l_jurisdiction_rec_tbl.FIRST;
                      g_inner_jurisdiction_code
                         := l_jurisdiction_rec_tbl(l_jur_index).tax_jurisdiction_code;
                      g_inner_jurisdiction_id
                         := l_jurisdiction_rec_tbl(l_jur_index).tax_jurisdiction_id;

                      l_jur_index := l_jurisdiction_rec_tbl.LAST;
                      g_outer_jurisdiction_code
                         := l_jurisdiction_rec_tbl(l_jur_index).tax_jurisdiction_code;
                      g_outer_jurisdiction_id
                         := l_jurisdiction_rec_tbl(l_jur_index).tax_jurisdiction_id;

                      IF (g_level_statement >= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement,
                               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                               'g_inner_jurisdiction_code = '|| g_inner_jurisdiction_code||'g_outer_jurisdiction_code = '|| g_outer_jurisdiction_code);

                      END IF;

                    ELSIF l_jurisdictions_found = 'Y'
                      AND l_jurisdiction_rec.tax_jurisdiction_code IS NOT NULL
                    THEN
                      -- for single jurisdiction case: cache the most inner
                      -- and outer jurisdiction same as the jurisdiction found
                      -- for future usage

                      g_inner_jurisdiction_code
                         := l_jurisdiction_rec.tax_jurisdiction_code;
                      g_inner_jurisdiction_id
                         := l_jurisdiction_rec.tax_jurisdiction_id;
                      g_outer_jurisdiction_code
                         := l_jurisdiction_rec.tax_jurisdiction_code;
                      g_outer_jurisdiction_id
                         := l_jurisdiction_rec.tax_jurisdiction_id;

                      IF (g_level_statement >= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement,
                               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                               'g_inner_jurisdiction_code = '|| g_inner_jurisdiction_code|| 'g_outer_jurisdiction_code = '|| g_outer_jurisdiction_code);

                      END IF;
                    END IF;

                    IF NVL(l_tax_rec.applicability_rule_flag, 'N') = 'N' THEN
                      -- for migrated taxes, if no additioncal applicability rule
                      -- defined, treate tax as applicable

                      l_tax_applicable := TRUE;

                    ELSE
                      -- call is_tax_applicable to determine additional tax applicability
                      --
                      l_tax_applicable := is_tax_applicable (
                            p_tax_id                  => l_tax_rec.tax_id,
                            p_tax_determine_date      => p_tax_determine_date,
                            p_applicability_rule_flag => l_tax_rec.applicability_rule_flag,
                            p_event_class_rec         => p_event_class_rec,
                            p_trx_line_index          => p_trx_line_index,
                            p_applicable_by_default_flag => l_tax_rec.applicable_by_default_flag,
                            x_applicability_result    => l_applicability_result,
                            x_applicability_result_id => l_applicability_result_id,
                            x_return_status           => x_return_status);

                      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF (g_level_statement >= g_current_runtime_level ) THEN
                          FND_LOG.STRING(g_level_statement,
                                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                                 'Incorrect return_status after calling ' ||
                                 'ZX_TDS_APPLICABILITY_DETM_PKG.is_tax_applicable');
                          FND_LOG.STRING(g_level_statement,
                                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes',
                                 'RETURN_STATUS = ' || x_return_status);
                          FND_LOG.STRING(g_level_statement,
                                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes.END',
                                 'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_taxes(-)');
                        END IF;
                        RETURN;
                      END IF;
                    END IF; --NVL(l_tax_rec.applicability_rule_flag, 'N') = 'N'

                 END IF;  -- l_jurisdictions_found ='Y' OR NVL(l_tax_rec.has_other_jurisdictions_flag, 'N') = 'N')

                 /* --bug 5385188
                 -- Since Direct Rate is applicable, POS is not mandatory. So ignore
                 -- the errors raised from get_place_of_supply

                 x_return_status := FND_API.G_RET_STS_SUCCESS;
                 */

                 IF l_tax_applicable THEN
                   -- build the new detail tax lines ONLY AFTER the tax is evaluated to be applicable.
                   l_begin_index := l_curr_rownum + 1;
                   l_rownum := l_rownum + 1;

                   -- validate and populate tax_regime_id
                   --
                   ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
                                            l_tax_regime_code_tbl(j),
                                            p_tax_determine_date,
                                            l_tax_regime_rec,
                                            x_return_status,
                                            l_error_buffer);

                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                     IF (g_level_statement >= g_current_runtime_level ) THEN
                       FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                              'Incorrect return_status after calling ' ||
                              'ZX_TDS_UTILITIES_PKG.get_regime_cache_info');
                       FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                              'RETURN_STATUS = ' || x_return_status);
                       FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results.END',
                              'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(-)');
                     END IF;
                     RETURN;
                   END IF;

                   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                    l_rownum).tax_regime_id := l_tax_regime_rec.tax_regime_id;

                   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                              l_rownum).tax_id := l_tax_rec.tax_id;

                   -- bug 5077691: populate legal_reporting_status
                   IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_rownum).legal_reporting_status :=
                             ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                                   l_tax_rec.tax_id).legal_reporting_status_def_val;
                   END IF;

                   IF l_jurisdictions_found = 'Y'
                     AND l_jurisdiction_rec.tax_jurisdiction_code IS NULL
                   THEN

                     -- Stamp multiple_jurisdiction_flag on the tax line to 'Y'
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       l_rownum).multiple_jurisdictions_flag := 'Y';

                   END IF;

                   IF l_status_result_tbl(j) IS NOT NULL THEN
                     -- validate and populate tax_status_id
                     --
                     ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                                              l_tax_tbl(j),
                                              l_tax_regime_code_tbl(j),
                                              l_status_result_tbl(j),
                                              p_tax_determine_date,
                                              l_tax_status_rec,
                                              x_return_status,
                                              l_error_buffer);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                       IF (g_level_statement >= g_current_runtime_level ) THEN
                         FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                                 'Incorrect return_status after calling ' ||
                                 'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info');
                         FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                                'RETURN_STATUS = ' || x_return_status);
                         FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results.END',
                                'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(-)');
                       END IF;
                       RETURN;
                     END IF;

                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         l_rownum).tax_status_id := l_tax_status_rec.tax_status_id;

                   END IF; --l_status_result_tbl(j) IS NOT NULL

                   IF l_rate_result_tbl(j) IS NOT NULL THEN
                     -- validate and populate tax_rate_id
                     --

                     -- bug 5475775:

                       IF l_jurisdiction_rec.tax_jurisdiction_code is NULL and
                          l_jurisdictions_found = 'Y' THEN

                          -- multiple jurisdictions situation

                          FOR i IN 1 .. nvl(l_jurisdiction_rec_tbl.count, 0) LOOP

                               ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
                                           l_tax_regime_code_tbl(j),
                                           l_tax_tbl(j),
                                           l_jurisdiction_rec_tbl(i).tax_jurisdiction_code,
                                           l_status_result_tbl(j),
                                           l_rate_result_tbl(j),
                                           p_tax_determine_date,
                                           l_tax_class,
                                           l_tax_rate_rec,
                                           x_return_status,
                                           l_error_buffer);

                              IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                                 l_tax_rate_rec.tax_rate_id is not NULL and
                                 l_tax_rate_rec.tax_jurisdiction_code = l_jurisdiction_rec_tbl(i).tax_jurisdiction_code
                              THEN
                                  -- A matching rate record is found. use this record for processing
                                  EXIT;
                              END IF;

                          END LOOP;

                       ELSE

                            -- Single Jurisdiction

                            ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
                                           l_tax_regime_code_tbl(j),
                                           l_tax_tbl(j),
                                           l_jurisdiction_rec.tax_jurisdiction_code,
                                           l_status_result_tbl(j),
                                           l_rate_result_tbl(j),
                                           p_tax_determine_date,
                                           l_tax_class,
                                           l_tax_rate_rec,
                                           x_return_status,
                                           l_error_buffer);
                       END IF;


                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                       IF (g_level_statement >= g_current_runtime_level ) THEN
                         FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                                'Incorrect return_status after calling ' ||
                                'ZX_TDS_UTILITIES_PKG.get_tax_rate_info');
                         FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                                'RETURN_STATUS = ' || x_return_status);
                         FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results.END',
                                'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(-)');
                       END IF;
                       RETURN;
                     END IF;

                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                          l_rownum).tax_rate_id := l_tax_rate_rec.tax_rate_id;

                   END IF; --l_rate_result_tbl(j) IS NOT NULL

                     -- >> Update call
                     IF(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                                           p_trx_line_index)='UPDATE') THEN

                       handle_update_scenarios(p_trx_line_index,
                                               p_event_class_rec,
                                               l_rownum,
                                               l_tax_rec.tax_regime_code,
                                               l_tax_rec.tax,
                                               p_tax_date,
                                               p_tax_determine_date,
                                               p_tax_point_date,
                                               l_self_assessed_flag,
                                               l_tax_amt_included_flag,
                                               l_tax_jurisdiction_id,
                                               l_tax_jurisdiction_code,
                                               x_return_status);

                       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         IF (g_level_statement >= g_current_runtime_level ) THEN
                            FND_LOG.STRING(g_level_statement,
                                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                                   'Incorrect return_status after calling ' ||
                                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results');
                            FND_LOG.STRING(g_level_statement,
                                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                                   'RETURN_STATUS = ' || x_return_status);
                            FND_LOG.STRING(g_level_statement,
                                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results.END',
                                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(-)');
                         END IF;
                         RETURN;
                       END IF;
                     END IF;

                     -- Populate the g_detail_tax_lines structure
                     --
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           l_rownum).application_id :=  p_event_class_rec.application_id;
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_rownum).event_class_code := p_event_class_rec.event_class_code;
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_rownum).event_type_code := p_event_class_rec.event_type_code;
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_rownum).entity_code := p_event_class_rec.entity_code;

                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                        l_rownum).tax_date := p_tax_date;

                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                    l_rownum).tax_determine_date := p_tax_determine_date;

                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                           l_rownum).tax_point_date := p_tax_point_date;

                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       l_rownum).place_of_supply_type_code := l_place_of_supply_type_code;

                     -- stamp trx_level_type and trx_line_id, since they are used for
                     -- tax line index checking.
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_rownum).trx_level_type :=
                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index);

                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_rownum).trx_line_id :=
                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);

                     -- if orig_tax_jurisdiction_code(id) is not NULL (for UPDATE),
                     -- populate tax_jurisdiction_code and tax_jurisdiction_id fetched
                     -- from zx_lines. Otherwise, populate new tax_jurisdiction_code
                     -- and tax_jurisdiction_id from most inner jurisdiction info
                     --
                     IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                        l_rownum).orig_tax_jurisdiction_code IS NOT NULL
                     THEN
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              l_rownum).tax_jurisdiction_code := l_tax_jurisdiction_code;

                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_rownum).tax_jurisdiction_id := l_tax_jurisdiction_id;
                     ELSE
                        -- bug 5120930
                        -- always stamp the most inner jurisdiction code on tax line

                        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_rownum).tax_jurisdiction_code
                            := NVL(l_jurisdiction_rec.tax_jurisdiction_code,
                                 g_inner_jurisdiction_code);

                        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_rownum).tax_jurisdiction_id
                            := NVL(l_jurisdiction_rec.tax_jurisdiction_id,
                                   g_inner_jurisdiction_id);
                     END IF;

                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  l_rownum).tax_regime_code := l_tax_rec.tax_regime_code;
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                  l_rownum).tax := l_tax_rec.tax;
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              l_rownum).tax_currency_code := l_tax_rec.tax_currency_code;
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                      l_rownum).tax_type_code := l_tax_rec.tax_type_code;
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_rownum).tax_currency_conversion_date := p_tax_determine_date;
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                 l_rownum).tax_currency_conversion_type :=
                                                           l_tax_rec.exchange_rate_type;
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          l_rownum).reporting_only_flag := l_tax_rec.reporting_only_flag;
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                       l_rownum).place_of_supply_result_id :=
                                                            l_place_of_supply_result_id;
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                         l_rownum).legal_message_pos :=
                         ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id(l_place_of_supply_result_id,
                            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_date(p_trx_line_index));
                     -- Populate direct_rate_rule_flag, as well as tax_status_code
                     -- and tax_rate_code if direct_rate is applicable.
                     --
                     IF NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        l_rownum).last_manual_entry,'X') NOT IN ('TAX_RATE','TAX_AMOUNT')
                     THEN
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_rownum).direct_rate_result_id := l_result_id_tbl(j);
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                     l_rownum).tax_status_code := l_status_result_tbl(j);
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         l_rownum).tax_rate_code := l_rate_result_tbl(j);
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_rownum).legal_message_rate :=
                            ZX_TDS_CALC_SERVICES_PUB_PKG.get_rep_code_id(l_result_id_tbl(j),
                              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_date(p_trx_line_index));
                     END IF;

                     --bug6604498
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         l_rownum).exception_rate := l_exception_rate;

                     -- populate rounding_lvl_party_tax_prof_id and rounding_level_code
                     --
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                    l_rownum).rounding_lvl_party_tax_prof_id :=
                                ZX_TDS_CALC_SERVICES_PUB_PKG.g_rnd_lvl_party_tax_prof_id;

                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                             l_rownum).rounding_level_code :=
                                           ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level;

                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         l_rownum).rounding_lvl_party_type :=
                                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_lvl_party_type;

                     -- populate hq_estb_party_tax_prof_id
                     --
                     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                    l_rownum).hq_estb_party_tax_prof_id :=
                       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hq_estb_party_tax_prof_id(
                                                                         p_trx_line_index);

                     -- populate tax registration info
                     --
                     populate_registration_info(
                           p_event_class_rec    => p_event_class_rec,
                           p_trx_line_index     => p_trx_line_index,
                           p_rownum                       => l_rownum,
                           p_def_reg_type       => l_tax_rec.def_registr_party_type_code,
                           p_reg_rule_flg       => l_tax_rec.registration_type_rule_flag,
                           p_tax_determine_date => p_tax_determine_date,
                           x_return_status      => x_return_status);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       IF (g_level_statement >= g_current_runtime_level ) THEN
                         FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                                'Incorrect return_status after calling ' ||
                                'ZX_TDS_APPLICABILITY_DETM_PKG.populate_registration_info');
                         FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                                'RETURN_STATUS = ' || x_return_status);
                         FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results.END',
                                'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(-)');
                       END IF;
                       RETURN;
                     END IF;

                     -- If orig_tax_amt_included_flag/orig_self_assessed_flag is not NULL
                     -- (for UPDATE), populate tax_amt_included_flag/self_assessed_flag
                     -- fetched from zx_lines. Otherwise, keep tax_amt_included_flag/
                     -- self_assessed_flag returned from get_tax_registration
                     --
                     IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                l_rownum).orig_tax_amt_included_flag IS NOT NULL THEN
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              l_rownum).tax_amt_included_flag := l_tax_amt_included_flag;
                     END IF;

                     IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                     l_rownum).orig_self_assessed_flag IS NOT NULL THEN
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                    l_rownum).self_assessed_flag := l_self_assessed_flag;
                     END IF;

                     -- populate rounding_rule_code if it is null
                     --
                     IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                            l_rownum).rounding_rule_code IS NULL THEN
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                            l_rownum).rounding_rule_code := l_tax_rec.rounding_rule_code;
                     END IF;

                     -- If the value of p_event_class_rec.self_assess_tax_lines_flag
                     -- is 'N', populate self_assessed_flg to 'N'
                           --
                     IF NVL(p_event_class_rec.self_assess_tax_lines_flag, 'N') = 'N'
                     THEN

                         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                l_rownum).self_assessed_flag := 'N';
                     END IF;

                     -- bug#8592720
                     IF (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                            p_trx_line_index) = 'CREATE_TAX_ONLY') THEN

                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                   l_rownum).tax_only_line_flag := 'Y';
                     END IF;

                     -- Bug 4277751: For intercompany transaction, detail tax lines from
                     -- addintional applicability process should be marked as
                     -- self assessed
                     --
          --
          -- Bug 5705976: Since, we stamp 'INTERCOMPANY_TRX' on both AR and AP
          -- transactions, the following code has become incorrect.
          --
          /*
                     IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(
                                         p_trx_line_index) IN ('CREATE', 'UPDATE') AND
                        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(
                                            p_trx_line_index) = 'INTERCOMPANY_TRX'
                     THEN
                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                   l_rownum).self_assessed_flag := 'Y';
                     END IF;
          */
                     -- Populate Regime and Regime detail table
                     --

                     --
                     -- Bug#5440023- do not poplate detail_tax_regime_tbl
                     -- for partner integration with 'LINE_INFO_TAX_ONLY' lines
                     --
                     IF NOT (NVL(ZX_GLOBAL_STRUCTURES_PKG.g_ptnr_srvc_subscr_flag, 'N')  = 'Y' AND
                             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action (p_trx_line_index ) =  'LINE_INFO_TAX_ONLY' ) THEN


                      l_regimerownum :=
                         NVL(ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.last, 0) + 1;

                       ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(
                                      l_regimerownum).trx_line_index := p_trx_line_index;
                       ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(
                          l_regimerownum).tax_regime_id:= l_tax_regime_rec.tax_regime_id;
                       ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(
                                   l_regimerownum).tax_regime_precedence :=
                                                  l_tax_regime_rec.tax_regime_precedence;

                     END IF;

                     add_tax_regime (l_tax_regime_rec.tax_regime_precedence,
                                     l_tax_regime_rec.tax_regime_id,
                                     l_tax_regime_rec.tax_regime_code,
                                     l_tax_regime_rec.parent_regime_code,
                                     l_tax_regime_rec.country_code,
                                     l_tax_regime_rec.geography_type,
                                     l_tax_regime_rec.geography_id,
                                     l_tax_regime_rec.effective_from,
                                     l_tax_regime_rec.effective_to,
                                     x_return_status );
                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                       IF (g_level_error >= g_current_runtime_level ) THEN
                         FND_LOG.STRING(g_level_error,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                                'Incorrect return_status after calling ' ||
                                'ZX_TDS_APPLICABILITY_DETM_PKG.add_tax_regime');
                         FND_LOG.STRING(g_level_error,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes',
                                'RETURN_STATUS = ' || x_return_status);
                         FND_LOG.STRING(g_level_error,
                                'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes.END',
                                'ZX_TDS_APPLICABILITY_DETM_PKG.get_applicable_regimes(-)');
                       END IF;
                       RETURN;
                     END IF;
                 END IF; -- l_tax_applicable
               END IF; -- l_tax_rec.TAX IS NOT NULL
            END IF; -- l_rate_result_tbl(j) IS NULL  OR
                    -- (l_rate_result_tbl(j) IS NOT NULL AND l_rate_exists_same_prod_family)
          END IF;     -- If condition is valid or NULL
        END IF;       -- IF condition for get_tax_index

        IF (x_begin_index is null) THEN
          x_begin_index := l_begin_index;
        END IF;
      END LOOP; -- End For loop

      EXIT WHEN get_candidate_taxes_csr%NOTFOUND;

    END LOOP; -- get_candidate_taxes_csr
    CLOSE get_candidate_taxes_csr;
  END IF; -- If constraint is VALID or NULL

  --IF (l_begin_index is NOT NULL) THEN
  IF (x_begin_index is NOT NULL) THEN
     x_end_index :=
        NVL( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);
  END IF;

  -- If p_event_class_rec.enforce_tax_from_ref_doc_flag = 'Y' AND
  -- trx_line_dist_tbl.ref_doc_application_id(p_trx_line_index) IS NOT NULL,
  -- get tax rate code from refefence document
  --
  IF p_event_class_rec.enforce_tax_from_ref_doc_flag = 'Y' AND
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(
                                               p_trx_line_index) IS NOT NULL
  THEN

        enforce_tax_from_ref_doc(
                                  x_begin_index,
                                  x_end_index,
                                  p_trx_line_index,
                                  x_return_status);
  END IF;

  -- copy transaction info to new tax lines

  ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines (p_trx_line_index,
                                                     x_begin_index,
                                                     x_end_index,
                                                     x_return_status,
                                                     l_error_buffer );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
     IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
              'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
              'Incorrect RETURN_STATUS after calling '||
              'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
       FND_LOG.STRING(g_level_statement,
              'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
              'RETURN_STATUS = ' || x_return_status);
       FND_LOG.STRING(g_level_statement,
              'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results.END',
              'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(-)');
     END IF;
    RETURN;
  END IF;
 END IF; -- line_level_action = 'CREATE', 'UPDATE', 'CREATE_TAX_ONLY'

 END IF;
 IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results.END',
                   'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(-)');
 END IF;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results',
                     l_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results.END',
                    'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(-)');
    END IF;
END get_process_results;
-- End: Bug 4959835

/*Start:  Moved from get_applicable_taxes as part of restructuring for STCC */
----------------------------------------------------------------------
--  PROCEDURE
--   handle_update_scenarios
--
--  DESCRIPTION
--
--  This procedure populates the appropriate cache structures
--  and key columns of g_detail_tax_lines_tbl when the
--  transaction line level action is 'Update'
--
--  IN
--               p_row_num
--               p_tax_regime_code
--               p_tax
--               p_trx_line_index
--               p_event_class_rec
--               p_tax_date
--               p_tax_determine_date
--               p_tax_point_date
--
--  OUT NOCOPY   x_return_status
--               x_self_assessed_flag
--               x_tax_amt_included_flag
--               x_tax_jurisdiction_id
--               x_tax_jurisdiction_code
--
--  Key Columns:
--               tax_line_id,
--               last_manual_entry,
--               tax_status_code,
--               orig_tax_status_id,
--               orig_tax_status_code,
--               tax_rate_code,
--               tax_rate,
--               orig_tax_rate_id,
--               orig_tax_rate_code,
--               orig_tax_rate,
--               tax_amt,
--               orig_tax_amt,
--               taxable_amt,
--               orig_taxable_amt,
--               line_amt,
--               self_assessed_flag,
--               tax_amt_included_flag,
--               tax_jurisdiction_id,
--               tax_jurisdiction_code,
--               orig_self_assessed_flag,
--               orig_tax_amt_included_flag,
--               orig_tax_jurisdiction_id,
--               orig_tax_jurisdiction_code,
--               unrounded_taxable_amt,
--               unrounded_tax_amt,
--               cal_tax_amt,
--               associated_child_frozen_flag
--               cancel_flag
----------------------------------------------------------------------

PROCEDURE handle_update_scenarios(
 p_trx_line_index     IN            BINARY_INTEGER,
 p_event_class_rec    IN            zx_api_pub.event_class_rec_type,
 p_row_num            IN            NUMBER,
 p_tax_regime_code    IN            zx_regimes_b.tax_regime_code%TYPE,
 p_tax                IN            zx_taxes_b.tax%TYPE,
 p_tax_date           IN            DATE,
 p_tax_determine_date IN            DATE,
 p_tax_point_date     IN            DATE,
 x_self_assessed_flag    OUT NOCOPY     zx_lines.self_assessed_flag%TYPE,
 x_tax_amt_included_flag OUT NOCOPY zx_lines.tax_amt_included_flag%TYPE,
 x_tax_jurisdiction_id   OUT NOCOPY zx_lines.tax_jurisdiction_id%TYPE,
 x_tax_jurisdiction_code OUT NOCOPY zx_lines.tax_jurisdiction_code%TYPE,
 x_return_status             OUT NOCOPY VARCHAR2) IS

 -- Local variables
  l_current_line_amt           zx_lines.line_amt%TYPE;
  l_tax_line_rec               zx_lines%ROWTYPE;

  l_tax_status_rec             ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
  l_tax_rate_rec               ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
  l_error_buffer               VARCHAR2(200);

  l_tax_class                  zx_rates_b.tax_class%TYPE;


 CURSOR get_key_columns_cur IS
    SELECT * FROM zx_lines
     WHERE application_id = p_event_class_rec.application_id
       AND entity_code = p_event_class_rec.entity_code
       AND event_class_code = p_event_class_rec.event_class_code
       AND trx_id = p_event_class_rec.trx_id
       AND trx_line_id =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index)
       AND trx_level_type =
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index)
       AND tax_regime_code = p_tax_regime_code
       AND tax = p_tax
       AND mrc_tax_line_flag = 'N'
       AND tax_apportionment_line_number > 0
       ORDER BY tax_apportionment_line_number;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Bug#5417753- determine tax_class value
  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  OPEN get_key_columns_cur;

  FETCH get_key_columns_cur INTO l_tax_line_rec;


  IF get_key_columns_cur%FOUND THEN

      x_self_assessed_flag := l_tax_line_rec.self_assessed_flag;
      x_tax_amt_included_flag := l_tax_line_rec.tax_amt_included_flag;
      x_tax_jurisdiction_id := l_tax_line_rec.tax_jurisdiction_id;
      x_tax_jurisdiction_code := l_tax_line_rec.tax_jurisdiction_code;

      IF l_tax_line_rec.cancel_flag = 'Y' THEN
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_row_num) :=
                                                                l_tax_line_rec;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios.BEGIN',
                 'ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios(-)');
        END IF;
        RETURN;
      END IF;

      -- bug 6906427: 1. Retain tax_line_id and associated_child_frozen_flag
      --                 for tax only line, or associated_child_frozen_flag
      --                 is 'N'. When associated_child_frozen_flag is 'Y',
      --                 the tail end service will check if tax line id
      --                 needs to be retained
      --              2. Retain summary tax line id for tax only line
      --
      IF NVL(l_tax_line_rec.tax_only_line_flag, 'N') = 'Y' THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           p_row_num).tax_line_id := l_tax_line_rec.tax_line_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           p_row_num).associated_child_frozen_flag :=
                                      l_tax_line_rec.associated_child_frozen_flag;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             p_row_num).summary_tax_line_id := l_tax_line_rec.summary_tax_line_id;

      ELSIF NVL(l_tax_line_rec.associated_child_frozen_flag, 'N') = 'N' THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           p_row_num).tax_line_id := l_tax_line_rec.tax_line_id;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           p_row_num).associated_child_frozen_flag :=
                                      l_tax_line_rec.associated_child_frozen_flag;

      END IF;

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           p_row_num).orig_self_assessed_flag :=
                                         l_tax_line_rec.orig_self_assessed_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           p_row_num).orig_tax_amt_included_flag :=
                                      l_tax_line_rec.orig_tax_amt_included_flag;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           p_row_num).orig_tax_jurisdiction_id :=
                                        l_tax_line_rec.orig_tax_jurisdiction_id;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                           p_row_num).orig_tax_jurisdiction_code :=
                                      l_tax_line_rec.orig_tax_jurisdiction_code;

      -- bug 5633271
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                   p_row_num).overridden_flag := l_tax_line_rec.overridden_flag;

      --Bug7339485
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                   p_row_num).TAX_RATE_TYPE := l_tax_line_rec.tax_rate_type;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                 'Value for TAX_RATE_TYPE '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                   p_row_num).TAX_RATE_TYPE);
       END IF;



      -- bug 5684123: 1. Set g_overridden_tax_ln_exist_flg
      --              2. Prorate orig_tax_amt_tax_curr for P2P
      --
      IF NVL(l_tax_line_rec.overridden_flag, 'N') = 'Y' THEN

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_overridden_tax_ln_exist_flg := 'Y';



        IF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
          l_current_line_amt :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_trx_line_index);

          IF l_tax_line_rec.line_amt <> 0 AND
             l_tax_line_rec.line_amt <> l_current_line_amt THEN

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        p_row_num).orig_tax_amt_tax_curr :=
                                   l_tax_line_rec.orig_tax_amt_tax_curr *
                                     l_current_line_amt/l_tax_line_rec.line_amt;

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        p_row_num).orig_taxable_amt_tax_curr :=
                                   l_tax_line_rec.orig_taxable_amt_tax_curr *
                                     l_current_line_amt/l_tax_line_rec.line_amt;
          ELSE      /* Bug 5684123 */
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      p_row_num).orig_tax_amt_tax_curr :=
                                           l_tax_line_rec.orig_tax_amt_tax_curr;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      p_row_num).orig_taxable_amt_tax_curr :=
                                       l_tax_line_rec.orig_taxable_amt_tax_curr;
          END IF;
        ELSE
          -- bug 5636132
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      p_row_num).orig_tax_amt_tax_curr :=
                                           l_tax_line_rec.orig_tax_amt_tax_curr;
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      p_row_num).orig_taxable_amt_tax_curr :=
                                       l_tax_line_rec.orig_taxable_amt_tax_curr;
        END IF;    -- p_event_class_rec.prod_family_grp_code = 'P2P'
      END IF;      -- overridden_flag = 'Y'

              IF l_tax_line_rec.last_manual_entry = 'STATUSTORATE' THEN

                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                            p_row_num).last_manual_entry := 'TAX_STATUS';
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          p_row_num).tax_status_code := l_tax_line_rec.tax_status_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  p_row_num).orig_tax_status_code:=l_tax_line_rec.orig_tax_status_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    p_row_num).orig_tax_status_id := l_tax_line_rec.orig_tax_status_id;

                -- populate tax_status_id
                --
                ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                                p_tax,
                                p_tax_regime_code,
                                l_tax_line_rec.tax_status_code,
                                p_tax_determine_date,
                                l_tax_status_rec,
                                x_return_status,
                                l_error_buffer);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF (g_level_error >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'Incorrect return_status after calling '||
                           'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info.');
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'RETURN_STATUS = ' || x_return_status);
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios.END',
                           'ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios(-)');
                  END IF;
                  CLOSE get_key_columns_cur;
                  RETURN;
                END IF;

                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_row_num).tax_status_id :=
                                              l_tax_status_rec.tax_status_id;

              ELSIF l_tax_line_rec.last_manual_entry = 'TAX_RATE_CODE' THEN

                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          p_row_num).last_manual_entry := 'TAX_RATE_CODE';
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          p_row_num).tax_status_code := l_tax_line_rec.tax_status_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  p_row_num).orig_tax_status_code:=l_tax_line_rec.orig_tax_status_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    p_row_num).orig_tax_status_id := l_tax_line_rec.orig_tax_status_id;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_row_num).tax_rate_code := l_tax_line_rec.tax_rate_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    p_row_num).orig_tax_rate_code := l_tax_line_rec.orig_tax_rate_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        p_row_num).orig_tax_rate_id := l_tax_line_rec.orig_tax_rate_id;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_row_num).orig_tax_rate := l_tax_line_rec.orig_tax_rate;

                -- populate tax_status_id
                --
                ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                                p_tax,
                                p_tax_regime_code,
                                l_tax_line_rec.tax_status_code,
                                p_tax_determine_date,
                                l_tax_status_rec,
                                x_return_status,
                                l_error_buffer);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF (g_level_error >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'Incorrect return_status after calling '||
                           'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info.');
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'RETURN_STATUS = ' || x_return_status);
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios.END',
                           'ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios(-)');
                  END IF;
                  CLOSE get_key_columns_cur;
                  RETURN;
                END IF;

                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                       p_row_num).tax_status_id :=
                                              l_tax_status_rec.tax_status_id;

                -- validate and populate tax_rate_id
                --
                ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
                                                p_tax_regime_code,
                                p_tax,
                                x_tax_jurisdiction_code,
                                l_tax_line_rec.tax_status_code,
                                l_tax_line_rec.tax_rate_code,
                                                p_tax_determine_date,
                                                l_tax_class,
                                                l_tax_rate_rec,
                                                x_return_status,
                                                l_error_buffer);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF (g_level_error >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'Incorrect return_status after calling '||
                           'ZX_TDS_UTILITIES_PKG.get_tax_rate_info.');
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'RETURN_STATUS = ' || x_return_status);
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios.END',
                           'ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios(-)');
                  END IF;
                  CLOSE get_key_columns_cur;
                  RETURN;
                END IF;

                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                   p_row_num).tax_rate_id := l_tax_rate_rec.tax_rate_id;

              ELSIF l_tax_line_rec.last_manual_entry = 'TAX_RATE' THEN

                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          p_row_num).last_manual_entry := 'TAX_RATE';
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          p_row_num).tax_status_code := l_tax_line_rec.tax_status_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  p_row_num).orig_tax_status_code:=l_tax_line_rec.orig_tax_status_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    p_row_num).orig_tax_status_id := l_tax_line_rec.orig_tax_status_id;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_row_num).tax_rate_code := l_tax_line_rec.tax_rate_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                        p_row_num).tax_rate := l_tax_line_rec.tax_rate;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    p_row_num).orig_tax_rate_code := l_tax_line_rec.orig_tax_rate_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        p_row_num).orig_tax_rate_id := l_tax_line_rec.orig_tax_rate_id;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_row_num).orig_tax_rate := l_tax_line_rec.orig_tax_rate;

                -- populate tax_status_id
                --
                ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                                                        p_tax,
                                                        p_tax_regime_code,
                                                        l_tax_line_rec.tax_status_code,
                                                        p_tax_determine_date,
                                                        l_tax_status_rec,
                                                        x_return_status,
                                                        l_error_buffer);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF (g_level_error >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'Incorrect return_status after calling '||
                           'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info.');
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'RETURN_STATUS = ' || x_return_status);
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios.END',
                           'ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios(-)');
                  END IF;
                  CLOSE get_key_columns_cur;
                  RETURN;
                END IF;

                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                       p_row_num).tax_status_id :=
                                              l_tax_status_rec.tax_status_id;

                -- validate and populate tax_rate_id
                --
                ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
                                p_tax_regime_code,
                                p_tax,
                                x_tax_jurisdiction_code,
                                l_tax_line_rec.tax_status_code,
                                l_tax_line_rec.tax_rate_code,
                                p_tax_determine_date,
                                l_tax_class,
                                l_tax_rate_rec,
                                x_return_status,
                                l_error_buffer);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF (g_level_error >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'Incorrect return_status after calling '||
                           'ZX_TDS_UTILITIES_PKG.get_tax_rate_info.');
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'RETURN_STATUS = ' || x_return_status);
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios.END',
                           'ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios(-)');
                  END IF;
                  CLOSE get_key_columns_cur;
                  RETURN;
                END IF;

                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                   p_row_num).tax_rate_id := l_tax_rate_rec.tax_rate_id;

              ELSIF l_tax_line_rec.last_manual_entry = 'TAX_AMOUNT' THEN

                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          p_row_num).last_manual_entry := 'TAX_AMOUNT';
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                          p_row_num).tax_status_code := l_tax_line_rec.tax_status_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                 p_row_num).orig_tax_status_code :=l_tax_line_rec.orig_tax_status_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    p_row_num).orig_tax_status_id := l_tax_line_rec.orig_tax_status_id;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_row_num).tax_rate_code := l_tax_line_rec.tax_rate_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                        p_row_num).tax_rate := l_tax_line_rec.tax_rate;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    p_row_num).orig_tax_rate_code := l_tax_line_rec.orig_tax_rate_code;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        p_row_num).orig_tax_rate_id := l_tax_line_rec.orig_tax_rate_id;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_row_num).orig_tax_rate := l_tax_line_rec.orig_tax_rate;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                p_row_num).orig_tax_amt := l_tax_line_rec.orig_tax_amt;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        p_row_num).orig_taxable_amt := l_tax_line_rec.orig_taxable_amt;

                -- bug 5684123: move to the top.-- bug 5636132,
                -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                --        p_row_num).orig_tax_amt_tax_curr :=
                --                                 l_tax_line_rec.orig_tax_amt_tax_curr;
                -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                --        p_row_num).orig_taxable_amt_tax_curr :=
                --                             l_tax_line_rec.orig_taxable_amt_tax_curr;



                -- bug 5633271
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                p_row_num).tax_calculation_formula :=
                                                l_tax_line_rec.tax_calculation_formula;
                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                p_row_num).taxable_basis_formula :=
                                                  l_tax_line_rec.taxable_basis_formula;

                -- populate tax_status_id
                --
                ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                                p_tax,
                                p_tax_regime_code,
                                l_tax_line_rec.tax_status_code,
                                p_tax_determine_date,
                                l_tax_status_rec,
                                x_return_status,
                                l_error_buffer);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF (g_level_error >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'Incorrect return_status after calling '||
                           'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info.');
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'RETURN_STATUS = ' || x_return_status);
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios.END',
                           'ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios(-)');
                  END IF;
                  CLOSE get_key_columns_cur;
                  RETURN;
                END IF;

                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                              p_row_num).tax_status_id :=
                                              l_tax_status_rec.tax_status_id;

                -- validate and populate tax_rate_id
                --
                ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
                                p_tax_regime_code,
                                p_tax,
                                x_tax_jurisdiction_code,
                                l_tax_line_rec.tax_status_code,
                                l_tax_line_rec.tax_rate_code,
                                p_tax_determine_date,
                                l_tax_class,
                                l_tax_rate_rec,
                                x_return_status,
                                l_error_buffer);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF (g_level_error >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'Incorrect return_status after calling '||
                           'ZX_TDS_UTILITIES_PKG.get_tax_rate_info.');
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                           'RETURN_STATUS = ' || x_return_status);
                    FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios.END',
                           'ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios(-)');
                  END IF;
                  CLOSE get_key_columns_cur;
                  RETURN;
                END IF;

                ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                    p_row_num).tax_rate_id := l_tax_rate_rec.tax_rate_id;

                -- prorate tax amount and taxable amount
                --
                l_current_line_amt :=
                   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(
                                                             p_trx_line_index);

                IF l_tax_line_rec.line_amt <> 0 THEN
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     p_row_num).unrounded_tax_amt :=
                           l_tax_line_rec.unrounded_tax_amt*l_current_line_amt/l_tax_line_rec.line_amt;
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                     p_row_num).unrounded_taxable_amt :=
                       l_tax_line_rec.unrounded_taxable_amt*l_current_line_amt/l_tax_line_rec.line_amt;

                  -- set tax_amt to NULL
                  --
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                               p_row_num).tax_amt := NULL;

                ELSE
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      p_row_num).unrounded_tax_amt := l_tax_line_rec.unrounded_tax_amt;
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                       p_row_num).unrounded_taxable_amt
                                                   := l_tax_line_rec.unrounded_taxable_amt;
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                p_row_num).tax_amt := l_tax_line_rec.tax_amt;
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        p_row_num).taxable_amt := l_tax_line_rec.taxable_amt;
                  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                        p_row_num).cal_tax_amt := l_tax_line_rec.cal_tax_amt;

                END IF;

              END IF;

            ELSIF get_key_columns_cur%NOTFOUND THEN
              /*
               * will be populated by pop_tax_line_for_trx_line
               * SELECT zx_lines_s.NEXTVAL
               *  INTO ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               *                                    p_row_num).tax_line_id
               * FROM dual;
               */

              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                       'get_key_columns_cur NOTFOUND..');
              END IF;

              NULL;
            END IF;

  CLOSE get_key_columns_cur;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE get_key_columns_cur;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios',
                     l_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios.END',
                    'ZX_TDS_APPLICABILITY_DETM_PKG.handle_update_scenarios(-)');
    END IF;
END handle_update_scenarios;

/*Start:  Moved from get_applicable_taxes as part of restructuring for STCC */
----------------------------------------------------------------------
--  PROCEDURE
--   enforce_tax_from_ref_doc
--
--  DESCRIPTION
--
--  This procedure obtains the tax details from reference
--  docs and populates g_detail_tax_lines_tbl.
--
--
--  IN
--              p_begin_index
--                      p_end_index
--                  p_trx_line_index
--
--  OUT NOCOPY     x_return_status
--

PROCEDURE enforce_tax_from_ref_doc(
  p_begin_index     IN            BINARY_INTEGER,
  p_end_index       IN            BINARY_INTEGER,
  p_trx_line_index  IN            BINARY_INTEGER,
  x_return_status          OUT NOCOPY VARCHAR2) IS

 -- Local variables
 i                              NUMBER;
 l_tax_status_rec             ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
 l_error_buffer                 VARCHAR2(200);

 -- Cursor definitions
 CURSOR  enforce_rate_code_from_ref_doc(
                c_tax                 zx_lines.tax%TYPE,
                c_tax_regime_code     zx_lines.tax_regime_code%TYPE) IS
 SELECT tax_status_code,
        tax_rate_code,
        line_amt,
        tax_amt,
        taxable_amt,
   -- nipatel bug 6648042
        tax_apportionment_line_number
   -- nipatel bug 6648042
   FROM zx_lines
  WHERE application_id =
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(p_trx_line_index)
    AND event_class_code =
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_event_class_code(p_trx_line_index)
    AND entity_code =
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_entity_code(p_trx_line_index)
    AND trx_id =
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_id(p_trx_line_index)
    AND trx_line_id =
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_line_id(p_trx_line_index)
    AND trx_level_type =
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_level_type(p_trx_line_index)
    AND tax_regime_code = c_tax_regime_code
    AND tax = c_tax
    AND cancel_flag <> 'Y'
    AND mrc_tax_line_flag = 'N';

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN NVL(p_begin_index, 1) .. NVL(p_end_index, 0) LOOP

        OPEN enforce_rate_code_from_ref_doc(
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax,
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_regime_code);

        FETCH enforce_rate_code_from_ref_doc INTO
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_status_code,
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_code,
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                           i).other_doc_line_amt,
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                       i).other_doc_line_tax_amt,
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                   i).other_doc_line_taxable_amt,
          -- nipatel bug 6648042
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                                   i).tax_apportionment_line_number;
          -- nipatel bug 6648042

        IF enforce_rate_code_from_ref_doc%FOUND THEN

          -- populate copied_from_other_doc_flag and other_doc_source
          --
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                         i).copied_from_other_doc_flag := 'Y';
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                           i).other_doc_source := 'REFERENCE';

          -- bugfix 5176149:populate tax_status_id
          --
          ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax,
                                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_regime_code,
                                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_status_code,
                                       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date,
                                       l_tax_status_rec,
                                       x_return_status,
                                       l_error_buffer);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                IF (g_level_statement >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc',
                          'Incorrect return_status after calling ' ||
                          'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info');
                  FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc',
                         'RETURN_STATUS = ' || x_return_status);
                  FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc.END',
                         'ZX_TDS_APPLICABILITY_DETM_PKG.get_process_results(-)');
                END IF;
                RETURN;
          END IF;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                                  i).tax_status_id := l_tax_status_rec.tax_status_id;

        ELSE
          IF g_level_statement >= g_current_runtime_level THEN
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc',
               'enforce_tax_from_ref_doc_flag is turned on, but tax status'||
               'code and tax rate code are not available from reference doc.');
          END IF;
        END IF;

   CLOSE enforce_rate_code_from_ref_doc;


  END LOOP;  -- i IN NVL(x_begin_index, -1) .. NVL(x_end_index, 0)

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc.BEGIN',
           'ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc(-)');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc',
                     l_error_buffer);
      FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc.END',
                    'ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc(-)');
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc',
                     l_error_buffer);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc.END',
                    'ZX_TDS_APPLICABILITY_DETM_PKG.enforce_tax_from_ref_doc(-)');
    END IF;
END enforce_tax_from_ref_doc;

END ZX_TDS_APPLICABILITY_DETM_PKG;


/
