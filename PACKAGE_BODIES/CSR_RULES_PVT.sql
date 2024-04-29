--------------------------------------------------------
--  DDL for Package Body CSR_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSR_RULES_PVT" AS
  /* $Header: CSRVRULB.pls 120.0.12010000.23 2010/05/11 07:18:32 rkamasam noship $ */

  g_pkg_name            CONSTANT VARCHAR2(30)  := 'CSR_RULES_PVT';
  g_not_specified       CONSTANT NUMBER        := -9999;

  g_rules_ns            CONSTANT VARCHAR2(100) := 'http://xmlns.oracle.com/CRM/Scheduler/Rules';

  -- Parameter Name and XPath Map
  g_rule_param_names_tbl jtf_varchar2_table_300;

  TYPE node_tbl_type IS TABLE OF DBMS_XMLDOM.DOMNode;

  PROCEDURE debug(p_message VARCHAR2, p_module VARCHAR2, p_level NUMBER) IS
  BEGIN
    IF p_level >= fnd_profile.value_specific('AFLOG_LEVEL') THEN
      IF fnd_file.log > 0 THEN
        IF p_message = ' ' THEN
          fnd_file.put_line(fnd_file.log, '');
        ELSE
          fnd_file.put_line(fnd_file.log, rpad(p_module, 20) || ': ' || p_message);
        END IF;
      ELSE
        fnd_log.string(p_level, 'csr.plsql.' || g_pkg_name || '.' || p_module, p_message);
      END IF;
    END IF;
  END debug;

  /**************************************************************************
   *                                                                        *
   *                  Private PLSQL Functions and Procedures                *
   *                                                                        *
   *************************************************************************/

  PROCEDURE init_package IS
  BEGIN
    g_rule_param_names_tbl     := jtf_varchar2_table_300();
    g_rule_param_names_tbl.extend(57);

    g_rule_param_names_tbl(01) := 'spPlanScope';
    g_rule_param_names_tbl(02) := 'spMaxPlanOptions';
    g_rule_param_names_tbl(03) := 'spMaxResources';
    g_rule_param_names_tbl(04) := 'spMaxCalcTime';
    g_rule_param_names_tbl(05) := 'spMaxOvertime';
    g_rule_param_names_tbl(06) := 'spWtpThreshold';
    g_rule_param_names_tbl(07) := 'spEnforcePlanWindow';
    g_rule_param_names_tbl(08) := 'spConsiderStandbyShifts';
    g_rule_param_names_tbl(09) := 'spSparesMandatory';
    g_rule_param_names_tbl(10) := 'spSparesSource';
    g_rule_param_names_tbl(11) := 'spMinTaskLength';
    g_rule_param_names_tbl(12) := 'spDefaultShiftDuration';
    g_rule_param_names_tbl(13) := 'spDistLastChildEffort';
    g_rule_param_names_tbl(14) := 'spPickContractResources';
    g_rule_param_names_tbl(15) := 'spPickIbResources';
    g_rule_param_names_tbl(16) := 'spPickTerritoryResources';
    g_rule_param_names_tbl(17) := 'spPickSkilledResources';
    g_rule_param_names_tbl(18) := 'spAutoSchDefaultQuery';
    g_rule_param_names_tbl(19) := 'spAutoRejectStsIdSpares';
    g_rule_param_names_tbl(20) := 'spAutoRejectStsIdOthers';
    g_rule_param_names_tbl(21) := 'spForceOptimizerToGroup';
    g_rule_param_names_tbl(22) := 'spOptimizerSuccessPerc';
    g_rule_param_names_tbl(23) := 'spCommutesPosition';
    g_rule_param_names_tbl(24) := 'spCommuteExcludedTime';
    g_rule_param_names_tbl(25) := 'spCommuteHomeEmptyTrip';
    g_rule_param_names_tbl(26) := 'spRouterMode';
    g_rule_param_names_tbl(27) := 'spTravelTimeExtra';
    g_rule_param_names_tbl(28) := 'spDefaultRouterEnabled';
    g_rule_param_names_tbl(29) := 'spDefaultTravelDistance';
    g_rule_param_names_tbl(30) := 'spDefaultTravelDuration';
    g_rule_param_names_tbl(31) := 'spMaxDistanceInGroup';
    g_rule_param_names_tbl(32) := 'spMaxDistToSkipActual';
    g_rule_param_names_tbl(33) := 'rcRouterCalcType';
    g_rule_param_names_tbl(34) := 'rcConsiderTollRoads';
    g_rule_param_names_tbl(35) := 'rcRouteFuncDelay0';
    g_rule_param_names_tbl(36) := 'rcRouteFuncDelay1';
    g_rule_param_names_tbl(37) := 'rcRouteFuncDelay2';
    g_rule_param_names_tbl(38) := 'rcRouteFuncDelay3';
    g_rule_param_names_tbl(39) := 'rcRouteFuncDelay4';
    g_rule_param_names_tbl(40) := 'rcEstimateFirstBoundary';
    g_rule_param_names_tbl(41) := 'rcEstimateSecondBoundary';
    g_rule_param_names_tbl(42) := 'rcEstimateFirstAvgSpeed';
    g_rule_param_names_tbl(43) := 'rcEstimateSecondAvgSpeed';
    g_rule_param_names_tbl(44) := 'rcEstimateThirdAvgSpeed';
    g_rule_param_names_tbl(45) := 'cpTaskPerDayDelayed';
    g_rule_param_names_tbl(46) := 'cpTaskPerMinEarly';
    g_rule_param_names_tbl(47) := 'cpTaskPerMinLate';
    g_rule_param_names_tbl(48) := 'cpTlsPerDayExtra';
    g_rule_param_names_tbl(49) := 'cpTlsPerChildExtra';
    g_rule_param_names_tbl(50) := 'cpPartsViolation';
    g_rule_param_names_tbl(51) := 'cpResPerMinOvertime';
    g_rule_param_names_tbl(52) := 'cpResAssignedNotPref';
    g_rule_param_names_tbl(53) := 'cpResSkillLevel';
    g_rule_param_names_tbl(54) := 'cpStandbyShiftUsage';
    g_rule_param_names_tbl(55) := 'cpTravelPerUnitDistance';
    g_rule_param_names_tbl(56) := 'cpTravelPerUnitDuration';
    g_rule_param_names_tbl(57) := 'cpDeferSameSite';

  END init_package;

  FUNCTION handle_miss_num(p_value NUMBER, p_default_value NUMBER)
    RETURN NUMBER IS
  BEGIN
    IF p_value = fnd_api.g_miss_num THEN
      RETURN NULL;
    ELSE
      RETURN NVL(p_value, p_default_value);
    END IF;
  END handle_miss_num;

  FUNCTION handle_miss_char(p_value VARCHAR2, p_default_value VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    IF p_value = fnd_api.g_miss_char THEN
      RETURN NULL;
    ELSE
      RETURN NVL(p_value, p_default_value);
    END IF;
  END handle_miss_char;

  FUNCTION is_param_valid_for_eligibility(p_rule_rank NUMBER, p_param_index PLS_INTEGER)
    RETURN BOOLEAN IS
  BEGIN
    IF p_rule_rank = 32 THEN
      RETURN p_param_index IN (5, 24);
    ELSIF p_rule_rank = 16 THEN
      RETURN p_param_index IN (5, 7, 8) OR p_param_index >= 23;
    ELSIF p_rule_rank IN (2, 4, 8) THEN
      RETURN p_param_index <= 32;
    ELSE
      RETURN TRUE;
    END IF;
  END is_param_valid_for_eligibility;

  FUNCTION get_param_grp_dom_node(
      p_rule_dom DBMS_XMLDOM.DOMDocument
    , p_tag_name VARCHAR2
    , p_create   BOOLEAN
    )
    RETURN DBMS_XMLDOM.DOMNode IS
    l_dom_node DBMS_XMLDOM.DOMNode;
  BEGIN
    l_dom_node := DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(p_rule_dom, p_tag_name), 0);
    IF DBMS_XMLDOM.isNull(l_dom_node) AND p_create THEN
      l_dom_node :=
        DBMS_XMLDOM.appendChild(
            DBMS_XMLDOM.MAKENODE(DBMS_XMLDOM.getDocumentElement(p_rule_dom))
          , DBMS_XMLDOM.MAKENODE(DBMS_XMLDOM.createElement(p_rule_dom, p_tag_name, g_rules_ns))
          );
    END IF;

    RETURN l_dom_node;
  END get_param_grp_dom_node;

  FUNCTION get_rule_rank (
      p_appl_id     NUMBER DEFAULT NULL
    , p_resp_id     NUMBER DEFAULT NULL
    , p_user_id     NUMBER DEFAULT NULL
    , p_terr_id     NUMBER DEFAULT NULL
    , p_resource_id NUMBER DEFAULT NULL
    ) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN NVL(p_appl_id, g_not_specified) <> g_not_specified THEN
             POWER(2, 1) ELSE 0
           END
         + CASE WHEN NVL(p_resp_id, g_not_specified) <> g_not_specified THEN
             POWER(2, 2) ELSE 0
           END
         + CASE WHEN NVL(p_user_id, g_not_specified) <> g_not_specified THEN
             POWER(2, 3) ELSE 0
           END
         + CASE WHEN NVL(p_terr_id, g_not_specified) <> g_not_specified THEN
             POWER(2, 4) ELSE 0
           END
         + CASE WHEN NVL(p_resource_id, g_not_specified) <> g_not_specified THEN
             POWER(2, 5) ELSE 0
           END;
  END get_rule_rank;

  FUNCTION insert_rule (
      p_rule_name       VARCHAR2
    , p_description     VARCHAR2
    , p_base_rule_id    NUMBER
    , p_appl_id         NUMBER
    , p_resp_id         NUMBER
    , p_user_id         NUMBER
    , p_terr_id         NUMBER
    , p_resource_type   VARCHAR2
    , p_resource_id     NUMBER
    , p_rule_rank       NUMBER
    , p_enabled_flag    VARCHAR2
    , p_rule_doc        XMLTYPE
    )
    RETURN NUMBER IS
    l_new_rule_id NUMBER;
    --
    CURSOR c_lookups IS
      SELECT meaning FROM fnd_lookups
       WHERE lookup_type = 'JTF_NOTE_TYPE' AND lookup_code = 'CN_SYSGEN';
    l_rule_name     csr_rules_tl.rule_name%TYPE;
  BEGIN
    l_rule_name := p_rule_name;

    IF p_enabled_flag = 'S' THEN
      OPEN c_lookups;
      FETCH c_lookups INTO l_rule_name;
      CLOSE c_lookups;
    END IF;

    INSERT INTO csr_rules_b (
        rule_id
      , object_version_number
      , base_rule_id
      , appl_id
      , resp_id
      , user_id
      , terr_id
      , resource_type
      , resource_id
      , enabled_flag
      , rule_rank
      , rule_doc
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
      )
      VALUES(
        csr_rules_b_s.NEXTVAL
      , 1
      , NVL(p_base_rule_id, -1)
      , NVL(p_appl_id, g_not_specified)
      , NVL(p_resp_id, g_not_specified)
      , NVL(p_user_id, g_not_specified)
      , NVL(p_terr_id, g_not_specified)
      , NVL(p_resource_type, '-')
      , NVL(p_resource_id, g_not_specified)
      , p_enabled_flag
      , p_rule_rank
      , p_rule_doc
      , fnd_global.user_id
      , SYSDATE
      , fnd_global.user_id
      , SYSDATE
      , fnd_global.login_id
      )
      RETURNING rule_id INTO l_new_rule_id;

    -- Insert the Rule's Translated Attributes
    INSERT INTO csr_rules_tl (
        rule_id
      , language
      , source_lang
      , rule_name
      , description
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
      )
      SELECT l_new_rule_id
           , l.language_code
           , userenv('LANG')
           , l_rule_name
           , p_description
           , fnd_global.user_id
           , SYSDATE
           , fnd_global.user_id
           , SYSDATE
           , fnd_global.login_id
        FROM fnd_languages l
       WHERE l.installed_flag in ('I','B')
         AND NOT EXISTS (
               SELECT 1 FROM csr_rules_tl tl
                WHERE tl.rule_id = l_new_rule_id
                  AND tl.language = l.language_code
             );

    RETURN l_new_rule_id;
  END insert_rule;

  FUNCTION get_parent_territory_rule(p_terr_id NUMBER, p_rule_doc XMLTYPE) RETURN NUMBER IS
    CURSOR c_terr_hier IS
      SELECT DISTINCT t.terr_id, LEVEL terr_level, r.rule_id
        FROM jtf_terr_all t, csr_rules_b r
       WHERE t.terr_id = r.terr_id (+)
         AND NVL(r.rule_rank, 16) = 16
       START WITH t.terr_id = p_terr_id
       CONNECT BY NOCYCLE PRIOR t.parent_territory_id = t.terr_id
       ORDER BY terr_level DESC;

    l_parent_terr_rule_id NUMBER;
  BEGIN
    l_parent_terr_rule_id := -1;

    FOR v_terr IN c_terr_hier LOOP

      -- We dont want to process the row corresponding to the passed Territory
      IF v_terr.terr_id <> p_terr_id THEN

        -- If the Rule already exists for the Territory, then use it.
        IF v_terr.rule_id IS NULL THEN
          v_terr.rule_id :=
            insert_rule(
                p_rule_name       => NULL
              , p_description     => NULL
              , p_base_rule_id    => l_parent_terr_rule_id
              , p_appl_id         => NULL
              , p_resp_id         => NULL
              , p_user_id         => NULL
              , p_terr_id         => v_terr.terr_id
              , p_resource_type   => NULL
              , p_resource_id     => NULL
              , p_rule_rank       => 16
              , p_enabled_flag    => 'S'
              , p_rule_doc        => p_rule_doc
              );
        END IF;

        l_parent_terr_rule_id := v_terr.rule_id;
      END IF;
    END LOOP;

    RETURN l_parent_terr_rule_id;
  END get_parent_territory_rule;

  FUNCTION create_system_gen_base_rule(
      p_rule_eligibility_type VARCHAR2
    , p_eligibility_val1      NUMBER
    , p_eligibility_val2      VARCHAR2
    , p_rule_doc              XMLTYPE
    ) RETURN NUMBER IS
    l_appl_id       NUMBER;
    l_resp_id       NUMBER;
    l_user_id       NUMBER;
    l_terr_id       NUMBER;
    l_resource_type VARCHAR2(30);
    l_resource_id   NUMBER;
    l_base_rule_id  NUMBER;
    --
    l_new_rule_id   NUMBER;
    l_rule_rank     PLS_INTEGER;
  BEGIN
    l_base_rule_id := -1;

    IF p_rule_eligibility_type = 'APPL' THEN
      l_appl_id := p_eligibility_val1;
    ELSIF p_rule_eligibility_type = 'RESP' THEN
      l_resp_id := p_eligibility_val1;
    ELSIF p_rule_eligibility_type = 'USER' THEN
      l_user_id := p_eligibility_val1;
    ELSIF p_rule_eligibility_type = 'TERR' THEN
      l_terr_id      := p_eligibility_val1;
      l_base_rule_id := get_parent_territory_rule(l_terr_id, p_rule_doc);
    ELSIF p_rule_eligibility_type = 'RES' THEN
      l_resource_id   := p_eligibility_val1;
      l_resource_type := p_eligibility_val2;
    END IF;

    l_rule_rank := get_rule_rank(l_appl_id, l_resp_id, l_user_id, l_terr_id, l_resource_id);

    l_new_rule_id :=
      insert_rule(
          p_rule_name       => NULL
        , p_description     => NULL
        , p_base_rule_id    => l_base_rule_id
        , p_appl_id         => l_appl_id
        , p_resp_id         => l_resp_id
        , p_user_id         => l_user_id
        , p_terr_id         => l_terr_id
        , p_resource_type   => l_resource_type
        , p_resource_id     => l_resource_id
        , p_rule_rank       => l_rule_rank
        , p_enabled_flag    => 'S'
        , p_rule_doc        => p_rule_doc
        );

    RETURN l_new_rule_id;
  END create_system_gen_base_rule;

  PROCEDURE validate_rule(
      p_rule_id                  IN            NUMBER
    , p_rule_name                IN            VARCHAR2
    , p_base_rule_id             IN OUT NOCOPY NUMBER
    , p_appl_id                  IN            NUMBER   DEFAULT NULL
    , p_resp_id                  IN            NUMBER   DEFAULT NULL
    , p_user_id                  IN            NUMBER   DEFAULT NULL
    , p_terr_id                  IN            NUMBER   DEFAULT NULL
    , p_resource_type            IN            VARCHAR2 DEFAULT NULL
    , p_resource_id              IN            NUMBER   DEFAULT NULL
    , p_rule_rank                IN            NUMBER   DEFAULT NULL
    , p_rule_doc                 IN            XMLTYPE
    ) IS
    l_api_name     CONSTANT VARCHAR2(30) := 'VALIDATE_RULE';
    l_debug        CONSTANT VARCHAR2(1)  := fnd_profile.value('AFLOG_ENABLED');
    --
    CURSOR c_duplicate_rules IS
      SELECT rule_id, rule_name
        FROM csr_rules_vl
       WHERE rule_id <> NVL(p_rule_id, g_not_specified)
         AND appl_id = NVL(p_appl_id, g_not_specified)
         AND resp_id = NVL(p_resp_id, g_not_specified)
         AND user_id = NVL(p_user_id, g_not_specified)
         AND terr_id = NVL(p_terr_id, g_not_specified)
         AND resource_type = NVL(p_resource_type, '-')
         AND resource_id = NVL(p_resource_id, g_not_specified)
         AND ROWNUM = 1;
    l_duplicate_rule        c_duplicate_rules%ROWTYPE;
    --
    l_base_rule_query       VARCHAR2(500);
    l_base_bind1            NUMBER;
    l_base_bind2            VARCHAR2(30);
    l_base_eligibilty_type  VARCHAR2(10);
    l_valid_base_rule_id    NUMBER;
    l_valid_base_rule_name  csr_rules_tl.rule_name%TYPE;
    c_rules                 SYS_REFCURSOR;
  BEGIN
    IF l_debug = 'Y' THEN
      debug('Validating Rule', l_api_name, fnd_log.level_event);
      debug(' --> Rule Rank = ' || p_rule_rank, l_api_name, fnd_log.level_statement);
      debug(' --> Rule Name = ' || p_rule_name, l_api_name, fnd_log.level_statement);
      debug(' --> Appl ID   = ' || p_appl_id, l_api_name, fnd_log.level_statement);
      debug(' --> Resp ID   = ' || p_resp_id, l_api_name, fnd_log.level_statement);
      debug(' --> User ID   = ' || p_user_id, l_api_name, fnd_log.level_statement);
      debug(' --> Terr ID   = ' || p_terr_id, l_api_name, fnd_log.level_statement);
      debug(' --> Res Type  = ' || p_resource_type, l_api_name, fnd_log.level_statement);
      debug(' --> Res ID    = ' || p_resource_id, l_api_name, fnd_log.level_statement);
    END IF;

    IF p_rule_name IS NULL THEN
      fnd_message.set_name('CSR', 'CSR_RULE_NAME_NOT_GIVEN');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_rule_doc IS NULL THEN
      fnd_message.set_name('CSR', 'CSR_RULE_DOC_NOT_GIVEN');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF NVL(p_resource_id, -9999) <> -9999 AND NVL(p_resource_type, '-') = '-'
      OR NVL(p_resource_id, -9999) = -9999 AND NVL(p_resource_type, '-') <> '-'
    THEN
      IF p_resource_id IS NULL THEN
        fnd_message.set_name ('JTF', 'JTF_RS_RESOURCE_PARAM_ID_NULL');
      ELSE
        fnd_message.set_name ('JTF', 'JTF_RS_RESOURCE_CATEGORY_NULL');
      END IF;
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_debug = 'Y' THEN
      debug('Checking for Eligibility', l_api_name, fnd_log.level_statement);
    END IF;

    IF NVL(p_rule_id, g_not_specified) <> 0
      AND (p_appl_id IS NULL OR p_appl_id = g_not_specified)
      AND (p_resp_id IS NULL OR p_resp_id = g_not_specified)
      AND (p_user_id IS NULL OR p_user_id = g_not_specified)
      AND (p_terr_id IS NULL OR p_terr_id = g_not_specified)
      AND (p_resource_id IS NULL OR p_resource_id = g_not_specified)
    THEN
      fnd_message.set_name('CSR', 'CSR_RULE_ELIGIBILITY_NOT_GIVEN');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_debug = 'Y' THEN
      debug('Checking for Duplicates', l_api_name, fnd_log.level_statement);
    END IF;

    -- There can be only one Rule with a particular Eligibility Criteria.
    OPEN c_duplicate_rules;
    FETCH c_duplicate_rules INTO l_duplicate_rule;
    CLOSE c_duplicate_rules;

    IF l_duplicate_rule.rule_id IS NOT NULL THEN
      fnd_message.set_name('CSR', 'CSR_RULE_DUPLICATION');
      fnd_message.set_token ('RULE_NAME', l_duplicate_rule.rule_name);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_rule_rank NOT IN (0, 2, 4, 8, 16, 32) THEN
      IF l_debug = 'Y' THEN
        debug('Checking for Multiple Eligibility and Base Rule', l_api_name, fnd_log.level_statement);
      END IF;

      -- Multiple Eligibility Criteria given
      l_base_rule_query := 'SELECT rule_id, rule_name FROM csr_rules_vl WHERE ';

      l_base_bind2 := '-';
      IF NVL(p_resource_id, g_not_specified) <> g_not_specified THEN
        l_base_rule_query      := l_base_rule_query || ' resource_id = :1 AND resource_type = :2 AND rule_rank = 32 ';
        l_base_bind1           := p_resource_id;
        l_base_bind2           := p_resource_type;
        l_base_eligibilty_type := 'RES';
      ELSIF NVL(p_terr_id, g_not_specified) <> g_not_specified THEN
        l_base_rule_query      := l_base_rule_query || ' terr_id = :1 AND ''-'' = :2 AND rule_rank = 16 ';
        l_base_bind1           := p_terr_id;
        l_base_eligibilty_type := 'TERR';
      ELSIF NVL(p_user_id, g_not_specified) <> g_not_specified THEN
        l_base_rule_query      := l_base_rule_query || ' user_id = :1 AND ''-'' = :2 AND rule_rank = 8 ';
        l_base_bind1           := p_user_id;
        l_base_eligibilty_type := 'USER';
      ELSIF NVL(p_resp_id, g_not_specified) <> g_not_specified THEN
        l_base_rule_query      := l_base_rule_query || ' resp_id = :1 AND ''-'' = :2 AND rule_rank = 4 ';
        l_base_bind1           := p_resp_id;
        l_base_eligibilty_type := 'RESP';
      ELSIF NVL(p_appl_id, g_not_specified) <> g_not_specified THEN
        l_base_rule_query      := l_base_rule_query || ' appl_id = :1 AND ''-'' = :2 AND rule_rank = 2 ';
        l_base_bind1           := p_appl_id;
        l_base_eligibilty_type := 'APPL';
      END IF;

      IF l_debug = 'Y' THEN
        debug('Querying for Base Rule through ' || l_base_rule_query, l_api_name, fnd_log.level_statement);
      END IF;

      OPEN c_rules FOR l_base_rule_query USING l_base_bind1, l_base_bind2;
      FETCH c_rules INTO l_valid_base_rule_id, l_valid_base_rule_name;
      CLOSE c_rules;

      -- Required Base Rule doesnt exists. Create a System Generated Base Rule
      IF l_valid_base_rule_id IS NULL THEN
        IF l_debug = 'Y' THEN
          debug('Creating Base Rule with Eligibility as ' || l_base_bind1, l_api_name, fnd_log.level_statement);
        END IF;
        l_valid_base_rule_id :=
          create_system_gen_base_rule(
              l_base_eligibilty_type
            , l_base_bind1
            , l_base_bind2
            , p_rule_doc
            );
      END IF;

      p_base_rule_id := l_valid_base_rule_id;
    ELSIF p_terr_id IS NOT NULL AND p_terr_id <> g_not_specified THEN
      IF l_debug = 'Y' THEN
        debug('Checking for Territory Eligibility and Base Rule', l_api_name, fnd_log.level_statement);
      END IF;

      -- Territory Rule. Ensure that Base Rule is that of Parent Territory
      p_base_rule_id := get_parent_territory_rule(p_terr_id, p_rule_doc);
    END IF;
  END validate_rule;

  PROCEDURE handle_rule_windows(
      p_new_rule_doc          XMLTYPE
    , p_old_rule_doc          XMLTYPE
    , p_window_names          jtf_varchar2_table_300
    , p_window_descriptions   jtf_varchar2_table_1500
    ) IS
    l_rule_document   DBMS_XMLDOM.DOMDocument;
    l_root_element    DBMS_XMLDOM.DOMElement;
    l_window_nodelist DBMS_XMLDOM.DOMNodelist;
    l_num_of_windows  PLS_INTEGER;
    l_window_node     DBMS_XMLDOM.DOMNode;
    l_window_attrs    DBMS_XMLDOM.DOMNamedNodeMap;
    l_window_id_node  DBMS_XMLDOM.DOMNode;
    l_window_id       PLS_INTEGER;
  BEGIN
    -- If there are no Windows defined in the New Document, but defined in the Old
    -- Document, then we have to delete the Window Names in CSR_RULE_WINDOWS_TL
    -- to avoid Dangling References.
    IF p_window_names IS NULL AND p_old_rule_doc IS NOT NULL THEN
      l_rule_document   := DBMS_XMLDOM.newDOMDocument(p_old_rule_doc);
      l_root_element    := DBMS_XMLDOM.getDocumentElement(l_rule_document);
      l_window_nodelist := DBMS_XMLDOM.getElementsByTagName(l_root_element, 'window');
      l_num_of_windows  := DBMS_XMLDOM.GetLength(l_window_nodelist);

      FOR i IN 1..l_num_of_windows LOOP
        l_window_node  := DBMS_XMLDOM.item(l_window_nodelist, i-1);
        l_window_attrs := DBMS_XMLDOM.getAttributes(l_window_node);
        l_window_id    := DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.getNamedItem(l_window_attrs, 'windowId'));
        --
        DELETE csr_rule_windows_tl WHERE window_id = l_window_id;
      END LOOP;

      RETURN;
    END IF;

    -- Loop through the New Document to find out whether we have Windows Defined.
    l_rule_document   := DBMS_XMLDOM.newDOMDocument(p_new_rule_doc);
    l_root_element    := DBMS_XMLDOM.getDocumentElement(l_rule_document);
    l_window_nodelist := DBMS_XMLDOM.getElementsByTagName(l_root_element, 'window');
    l_num_of_windows  := DBMS_XMLDOM.GetLength(l_window_nodelist);
    FOR i IN 1..l_num_of_windows LOOP
      l_window_node    := DBMS_XMLDOM.item(l_window_nodelist, i-1);
      l_window_attrs   := DBMS_XMLDOM.getAttributes(l_window_node);
      l_window_id_node := DBMS_XMLDOM.getNamedItem(l_window_attrs, 'windowId');
      l_window_id      := DBMS_XMLDOM.getNodeValue(l_window_id_node);
      --
      IF l_window_id < 0 THEN

        SELECT csr_rule_windows_tl_s.NEXTVAL INTO l_window_id FROM dual;

        INSERT INTO csr_rule_windows_tl (
            window_id
          , language
          , source_lang
          , window_name
          , description
          , created_by
          , creation_date
          , last_updated_by
          , last_update_date
          , last_update_login
          )
          SELECT l_window_id
               , l.language_code
               , userenv('LANG')
               , p_window_names(i)
               , p_window_descriptions(i)
               , fnd_global.user_id
               , SYSDATE
               , fnd_global.user_id
               , SYSDATE
               , fnd_global.login_id
            FROM fnd_languages l
           WHERE l.installed_flag in ('I','B');

        DBMS_XMLDOM.setNodeValue(l_window_id_node, l_window_id);
      ELSE
        UPDATE csr_rule_windows_tl
           SET window_name           = p_window_names(i)
             , description           = p_window_descriptions(i)
             , last_updated_by       = fnd_global.user_id
             , last_update_date      = SYSDATE
             , last_update_login     = fnd_global.login_id
         WHERE window_id = l_window_id
           AND userenv('LANG') IN (language, source_lang);
      END IF;
    END LOOP;
  END handle_rule_windows;

  FUNCTION propagate(
      p_base_doc      IN            XMLTYPE
    , p_child_doc     IN OUT NOCOPY XMLTYPE
    , p_child_rule_id IN            NUMBER
    , p_force         IN            VARCHAR2
    ) RETURN BOOLEAN IS

    l_baserule_doc    XMLTYPE;
    l_baserule_dom    DBMS_XMLDOM.DOMDocument;
    l_childrule_dom   DBMS_XMLDOM.DOMDocument;
    l_baserule_root   DBMS_XMLDOM.DOMElement;


    l_child           DBMS_XMLDOM.DOMNode;
    l_nodelist        DBMS_XMLDOM.DOMNodelist;
    l_node            DBMS_XMLDOM.DOMNode;
    l_child_text_node DBMS_XMLDOM.DOMNode;
    l_base_text_node  DBMS_XMLDOM.DOMNode;

    l_child_node      DBMS_XMLDOM.DOMNode;
    l_child_attrs     DBMS_XMLDOM.DOMNamedNodeMap;
    l_inherited       VARCHAR2(1);
    l_wtp_nodename    CONSTANT VARCHAR2(20) := 'wtpParameters';
    l_child_modified  BOOLEAN := FALSE;

    i                 PLS_INTEGER;

    l_baserule_node_list node_tbl_type := node_tbl_type();

    l_api_name     CONSTANT VARCHAR2(30) := 'PROPAGATE';
    l_debug        CONSTANT VARCHAR2(1)  := fnd_profile.value('AFLOG_ENABLED');

  BEGIN
    -- If the Child Rule is NULL then reset it to Parent Rule
    IF p_child_doc IS NULL THEN
      p_child_doc := p_base_doc;
      RETURN TRUE;
    END IF;

    l_baserule_doc    := p_base_doc;
    l_baserule_dom    := DBMS_XMLDOM.newDOMDocument(l_baserule_doc);
    l_baserule_root   := DBMS_XMLDOM.getDocumentElement(l_baserule_dom);
    l_child           := DBMS_XMLDOM.getFirstChild(DBMS_XMLDOM.makeNode(l_baserule_root));

    -- Parse the Base Rule and Store the Nodes of the
    -- Base Rule ( schedulerParameters/costParameters/routerConfig)
    WHILE NOT DBMS_XMLDOM.isNull(l_child) LOOP
      IF DBMS_XMLDOM.getTagName(DBMS_XMLDOM.makeElement(l_child)) <> l_wtp_nodename THEN
        l_nodelist := DBMS_XMLDOM.getChildNodes(l_child);
        FOR i IN 0..DBMS_XMLDOM.getLength(l_nodelist) - 1 LOOP
          l_baserule_node_list.EXTEND(1);
          l_baserule_node_list(l_baserule_node_list.COUNT) := DBMS_XMLDOM.item(l_nodelist, i);
        END LOOP;
      END IF;
      l_child := DBMS_XMLDOM.getNextSibling(l_child);
    END LOOP;

    l_childrule_dom := DBMS_XMLDOM.newDOMDocument(p_child_doc);

    IF l_debug = 'Y' THEN
      debug('Updating Rule#' || p_child_rule_id, l_api_name, fnd_log.level_event);
      DECLARE
        buffer VARCHAR2(8000);
      BEGIN
        DBMS_XMLDOM.WRITETOBUFFER(l_childrule_dom, buffer);
        debug(' --> XML Doc#1 = ' || substr(buffer, 1, 3900), l_api_name, fnd_log.level_statement);
        debug(' --> XML Doc#2 = ' || substr(buffer, 3901, 3900), l_api_name, fnd_log.level_statement);
      END;
    END IF;

    i := l_baserule_node_list.FIRST;
    WHILE i IS NOT NULL LOOP
      l_node := l_baserule_node_list(i);
      l_child_node    := DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName
                                            (l_childrule_dom, DBMS_XMLDOM.getTagName(
                                                                 DBMS_XMLDOM.makeElement(l_node)
                                                            )
                                            ),0);
      l_child_attrs   := DBMS_XMLDOM.getAttributes(l_child_node);
      -- Propagate the Changes from a Parent Rule's XML Element to Child Rule's Element Only
      -- if it is either inherited OR its a force updation.
      l_inherited     := DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.getNamedItem(l_child_attrs, 'inherited'));
      IF l_inherited = 'Y' OR  p_force = 'Y' THEN
        l_child_text_node := DBMS_XMLDOM.getFirstChild(l_child_node);
        l_base_text_node  := DBMS_XMLDOM.getFirstChild(l_node);
        DBMS_XMLDOM.setNodeValue(l_child_text_node, DBMS_XMLDOM.getNodeValue(l_base_text_node));
        l_child_modified := TRUE;
        IF l_debug = 'Y' THEN
          debug('Modified XML Element:' ||DBMS_XMLDOM.getNodeName(l_child_text_node)
                 , l_api_name, fnd_log.level_statement);
        END IF;
      END IF;
     i := l_baserule_node_list.NEXT(i);
    END LOOP;

    -- Persist the changes to the DB only if something has changed.
    IF l_child_modified = TRUE THEN
      UPDATE csr_rules_b
         SET rule_doc = p_child_doc
       WHERE rule_id  = p_child_rule_id;
    END IF;

    IF l_debug = 'Y' THEN
      IF l_child_modified = TRUE THEN
        debug('The Rule:'||p_child_rule_id ||' was modified', l_api_name, fnd_log.level_statement);
      ELSE
        debug('The Rule:'||p_child_rule_id ||' was NOT modified', l_api_name, fnd_log.level_statement);
      END IF;
    END IF;

    -- Return whether the Child Rule is Modified or Not.
    RETURN l_child_modified;

  END propagate;

  /**
   * This method propagates the changes of parameters:
   *  1. Scheduler Parameters
   *  2. Cost Parameters
   *  3. Router Configuration Parameters
   * from an Updated Scheduler Rule to all its Children.
   *
   * The method exploits Depth First Search Traversal (DFS) approach to
   * explore all the Child Rules which can be updated based on the changes
   * done in the Base Rule.
   * A XML Element in the Child Rule is modified if it has been inherited
   * from the Base Rule and still the inheritance exists. But if the argument
   * p_force is 'Y' then the Child Rule is updated irrespective of inheritance.
   */
  PROCEDURE propagate_to_child_rules(
      p_rule_id         NUMBER
    , p_base_doc        XMLType
    , p_child_doc       XMLTYPE
    , p_force           VARCHAR2
    ) IS
    CURSOR c_child_rules IS
      SELECT rule_id, rule_doc
        FROM csr_rules_b
       WHERE base_rule_id = p_rule_id;

    l_child_doc    XMLTYPE;
    l_debug        CONSTANT VARCHAR2(1)  := fnd_profile.value('AFLOG_ENABLED');
    l_api_name     CONSTANT VARCHAR2(30) := 'PROPAGATE_TO_CHILD_RULES';
  BEGIN

    l_child_doc := p_child_doc;
    -- propagate the Changes from Base Rule to Child Rule. If there are
    -- no updations in the Child Rule then skip going down the heirarchy.
    IF NOT propagate ( p_base_doc, l_child_doc, p_rule_id, p_force ) THEN
      RETURN;
    END IF;

    -- Propagate the Changes to the Child Rules Recursively
    FOR v_child_rule IN c_child_rules LOOP
      IF l_debug = 'Y' THEN
        debug('Propogating the Changes From the Rule#'||p_rule_id||' to:'||v_child_rule.rule_id , l_api_name, fnd_log.level_statement);
      END IF;
      propagate_to_child_rules(v_child_rule.rule_id, l_child_doc, v_child_rule.rule_doc, p_force);
    END LOOP;

    -- If there are no child rules return to Parent Rule.
    RETURN;
  END propagate_to_child_rules;


  /**************************************************************************
   *                                                                        *
   *                  Public PLSQL Functions and Procedures                 *
   *                                                                        *
   *************************************************************************/
  PROCEDURE create_rule(
      p_api_version              IN            NUMBER
    , p_init_msg_list            IN            VARCHAR2                DEFAULT NULL
    , p_commit                   IN            VARCHAR2                DEFAULT NULL
    , x_return_status           OUT     NOCOPY VARCHAR2
    , x_msg_data                OUT     NOCOPY VARCHAR2
    , x_msg_count               OUT     NOCOPY NUMBER
    , p_rule_name                IN            VARCHAR2
    , p_description              IN            VARCHAR2                DEFAULT NULL
    , p_base_rule_id             IN            NUMBER                  DEFAULT NULL
    , p_appl_id                  IN            NUMBER                  DEFAULT NULL
    , p_resp_id                  IN            NUMBER                  DEFAULT NULL
    , p_user_id                  IN            NUMBER                  DEFAULT NULL
    , p_terr_id                  IN            NUMBER                  DEFAULT NULL
    , p_resource_type            IN            VARCHAR2                DEFAULT NULL
    , p_resource_id              IN            NUMBER                  DEFAULT NULL
    , p_enabled_flag             IN            VARCHAR2                DEFAULT NULL
    , p_rule_doc                 IN            XMLTYPE
    , p_window_names             IN            jtf_varchar2_table_300  DEFAULT NULL
    , p_window_descriptions      IN            jtf_varchar2_table_1500 DEFAULT NULL
    , x_rule_id                 OUT     NOCOPY NUMBER
    , x_new_rule_doc            OUT     NOCOPY CLOB
    ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_RULE';
    l_debug        CONSTANT VARCHAR2(1)  := fnd_profile.value('AFLOG_ENABLED');
    --
    l_rule_rank    PLS_INTEGER;
    l_rule_doc     XMLTYPE;
    l_note_id      NUMBER;
    l_base_rule_id NUMBER;
  BEGIN
    SAVEPOINT csr_rule_create;

    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 'Y' THEN
      debug('Creating Rule', l_api_name, fnd_log.level_event);
      debug(' --> Rule Name = ' || p_rule_name, l_api_name, fnd_log.level_event);
      debug(' --> Base Rule = ' || p_base_rule_id, l_api_name, fnd_log.level_statement);
      debug(' --> Appl ID   = ' || p_appl_id, l_api_name, fnd_log.level_statement);
      debug(' --> Resp ID   = ' || p_resp_id, l_api_name, fnd_log.level_statement);
      debug(' --> User ID   = ' || p_user_id, l_api_name, fnd_log.level_statement);
      debug(' --> Terr ID   = ' || p_terr_id, l_api_name, fnd_log.level_statement);
      debug(' --> Res Type  = ' || p_resource_type, l_api_name, fnd_log.level_statement);
      debug(' --> Res ID    = ' || p_resource_id, l_api_name, fnd_log.level_statement);
      DECLARE
        buffer VARCHAR2(8000);
      BEGIN
        DBMS_XMLDOM.WRITETOBUFFER(DBMS_XMLDOM.NEWDOMDOCUMENT(p_rule_doc), buffer);
        debug(' --> XML Doc#1 = ' || substr(buffer, 1, 3900), l_api_name, fnd_log.level_statement);
        debug(' --> XML Doc#2 = ' || substr(buffer, 3901, 3900), l_api_name, fnd_log.level_statement);
      END;
    END IF;

    l_base_rule_id := p_base_rule_id;
    l_rule_doc     := p_rule_doc;

    l_rule_rank    :=
      get_rule_rank(p_appl_id, p_resp_id, p_user_id, p_terr_id, p_resource_id);

    validate_rule(
        p_rule_id       => x_rule_id
      , p_rule_name     => p_rule_name
      , p_base_rule_id  => l_base_rule_id
      , p_appl_id       => p_appl_id
      , p_resp_id       => p_resp_id
      , p_user_id       => p_user_id
      , p_terr_id       => p_terr_id
      , p_resource_type => p_resource_type
      , p_resource_id   => p_resource_id
      , p_rule_rank     => l_rule_rank
      , p_rule_doc      => l_rule_doc
      );

    handle_rule_windows(l_rule_doc, NULL, p_window_names, p_window_descriptions);

    x_rule_id :=
      insert_rule(
          p_rule_name       => p_rule_name
        , p_description     => p_description
        , p_base_rule_id    => l_base_rule_id
        , p_appl_id         => p_appl_id
        , p_resp_id         => p_resp_id
        , p_user_id         => p_user_id
        , p_terr_id         => p_terr_id
        , p_resource_type   => p_resource_type
        , p_resource_id     => p_resource_id
        , p_rule_rank       => l_rule_rank
        , p_enabled_flag    => p_enabled_flag
        , p_rule_doc        => l_rule_doc
        );

    x_new_rule_doc := l_rule_doc.getClobVal();

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csr_rule_create;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 'Y' THEN
        debug('Create Rule Errored with ' || x_msg_data, l_api_name, fnd_log.level_error);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csr_rule_create;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 'Y' THEN
        debug('Create Rule Errored with ' || x_msg_data, l_api_name, fnd_log.level_error);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csr_rule_create;
      IF l_debug = 'Y' THEN
        debug('Create Rule Errored with ' || x_msg_data, l_api_name, fnd_log.level_error);
      END IF;
  END create_rule;

  PROCEDURE update_rule(
      p_api_version              IN            NUMBER
    , p_init_msg_list            IN            VARCHAR2                DEFAULT NULL
    , p_commit                   IN            VARCHAR2                DEFAULT NULL
    , x_return_status           OUT     NOCOPY VARCHAR2
    , x_msg_data                OUT     NOCOPY VARCHAR2
    , x_msg_count               OUT     NOCOPY NUMBER
    , p_rule_id                  IN            NUMBER
    , p_object_version_number    IN OUT NOCOPY NUMBER
    , p_rule_name                IN            VARCHAR2                DEFAULT NULL
    , p_description              IN            VARCHAR2                DEFAULT NULL
    , p_base_rule_id             IN            NUMBER                  DEFAULT NULL
    , p_appl_id                  IN            NUMBER                  DEFAULT NULL
    , p_resp_id                  IN            NUMBER                  DEFAULT NULL
    , p_user_id                  IN            NUMBER                  DEFAULT NULL
    , p_terr_id                  IN            NUMBER                  DEFAULT NULL
    , p_resource_type            IN            VARCHAR2                DEFAULT NULL
    , p_resource_id              IN            NUMBER                  DEFAULT NULL
    , p_enabled_flag             IN            VARCHAR2                DEFAULT NULL
    , p_rule_doc                 IN            XMLTYPE                 DEFAULT NULL
    , p_window_names             IN            jtf_varchar2_table_300  DEFAULT NULL
    , p_window_descriptions      IN            jtf_varchar2_table_1500 DEFAULT NULL
    , p_version_msgs             IN            jtf_varchar2_table_4000
    , p_force_propagation        IN            VARCHAR2                DEFAULT NULL
    , x_new_rule_doc             OUT    NOCOPY CLOB
    ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'UPDATE_RULE';
    l_debug        CONSTANT VARCHAR2(1)  := fnd_profile.value('AFLOG_ENABLED');
    --
    CURSOR c_rule_details IS
      SELECT b.rule_id
           , b.object_version_number
           , b.base_rule_id
           , b.appl_id
           , b.resp_id
           , b.user_id
           , b.terr_id
           , b.resource_type
           , b.resource_id
           , b.enabled_flag
           , b.rule_rank
           , b.rule_doc
           , t.rule_name
           , t.description
        FROM csr_rules_b b, csr_rules_tl t
       WHERE b.rule_id = p_rule_id
         AND b.rule_id = t.rule_id
         AND t.language = userenv('LANG')
         FOR UPDATE NOWAIT;

    l_rule            c_rule_details%ROWTYPE;
    l_old_rule_doc    XMLTYPE;
    --
    i                 PLS_INTEGER;
    l_notes           VARCHAR2(4000);
    l_notes_dtl       VARCHAR2(4000);
    l_note_id         NUMBER;
    --
  BEGIN
    SAVEPOINT csr_rule_update;

    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 'Y' THEN
      debug('Updating Rule#' || p_rule_id, l_api_name, fnd_log.level_event);
      debug(' --> Rule Name = ' || p_rule_name, l_api_name, fnd_log.level_statement);
      debug(' --> OVN       = ' || p_object_version_number, l_api_name, fnd_log.level_statement);
      debug(' --> Base Rule = ' || p_base_rule_id, l_api_name, fnd_log.level_statement);
      debug(' --> Appl ID   = ' || p_appl_id, l_api_name, fnd_log.level_statement);
      debug(' --> Resp ID   = ' || p_resp_id, l_api_name, fnd_log.level_statement);
      debug(' --> User ID   = ' || p_user_id, l_api_name, fnd_log.level_statement);
      debug(' --> Terr ID   = ' || p_terr_id, l_api_name, fnd_log.level_statement);
      debug(' --> Res Type  = ' || p_resource_type, l_api_name, fnd_log.level_statement);
      debug(' --> Res ID    = ' || p_resource_id, l_api_name, fnd_log.level_statement);
      DECLARE
        buffer VARCHAR2(8000);
      BEGIN
        DBMS_XMLDOM.WRITETOBUFFER(DBMS_XMLDOM.NEWDOMDOCUMENT(p_rule_doc), buffer);
        debug(' --> XML Doc#1 = ' || substr(buffer, 1, 3900), l_api_name, fnd_log.level_statement);
        debug(' --> XML Doc#2 = ' || substr(buffer, 3901, 3900), l_api_name, fnd_log.level_statement);
      END;
    END IF;

    OPEN c_rule_details;
    FETCH c_rule_details INTO l_rule;
    CLOSE c_rule_details;

    IF l_rule.rule_id IS NULL THEN
      fnd_message.set_name('CSR', 'CSR_RULE_NOT_FOUND');
      fnd_message.set_token('RULE_ID', p_rule_id);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_rule.object_version_number <> p_object_version_number THEN
      fnd_message.set_name ('JTF', 'JTF_API_RECORD_NOT_FOUND');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_old_rule_doc          := l_rule.rule_doc;
    p_object_version_number := p_object_version_number + 1;
    l_rule.base_rule_id     := handle_miss_num(p_base_rule_id, l_rule.base_rule_id);
    l_rule.appl_id          := handle_miss_num(p_appl_id, l_rule.appl_id);
    l_rule.resp_id          := handle_miss_num(p_resp_id, l_rule.resp_id);
    l_rule.user_id          := handle_miss_num(p_user_id, l_rule.user_id);
    l_rule.terr_id          := handle_miss_num(p_terr_id, l_rule.terr_id);
    l_rule.resource_type    := handle_miss_char(p_resource_type, l_rule.resource_type);
    l_rule.resource_id      := handle_miss_num(p_resource_id, l_rule.resource_id);
    l_rule.enabled_flag     := handle_miss_char(p_enabled_flag, l_rule.enabled_flag);

    l_rule.rule_rank :=
      get_rule_rank(l_rule.appl_id, l_rule.resp_id, l_rule.user_id, l_rule.terr_id, l_rule.resource_id);

    IF p_rule_doc IS NOT NULL THEN
      l_rule.rule_doc := p_rule_doc;
    END IF;

    validate_rule(
        p_rule_id       => l_rule.rule_id
      , p_rule_name     => l_rule.rule_name
      , p_base_rule_id  => l_rule.base_rule_id
      , p_appl_id       => l_rule.appl_id
      , p_resp_id       => l_rule.resp_id
      , p_user_id       => l_rule.user_id
      , p_terr_id       => l_rule.terr_id
      , p_resource_type => l_rule.resource_type
      , p_resource_id   => l_rule.resource_id
      , p_rule_rank     => l_rule.rule_rank
      , p_rule_doc      => l_rule.rule_doc
      );

    handle_rule_windows(l_rule.rule_doc, l_old_rule_doc, p_window_names, p_window_descriptions);

    -- Update the Rule's Base Attributes
    UPDATE csr_rules_b
       SET object_version_number = p_object_version_number
         , base_rule_id          = NVL(l_rule.base_rule_id, -1)
         , appl_id               = NVL(l_rule.appl_id, g_not_specified)
         , resp_id               = NVL(l_rule.resp_id, g_not_specified)
         , user_id               = NVL(l_rule.user_id, g_not_specified)
         , terr_id               = NVL(l_rule.terr_id, g_not_specified)
         , resource_type         = NVL(l_rule.resource_type, '-')
         , resource_id           = NVL(l_rule.resource_id, g_not_specified)
         , enabled_flag          = l_rule.enabled_flag
         , rule_rank             = l_rule.rule_rank
         , rule_doc              = l_rule.rule_doc
         , last_updated_by       = fnd_global.user_id
         , last_update_date      = SYSDATE
         , last_update_login     = fnd_global.login_id
     WHERE rule_id = p_rule_id;

    -- Update the Rule's Translatable Attributes
    IF l_rule.rule_name <> p_rule_name
       OR NVL(p_description, '@@') <> NVL(l_rule.description, '@@')
    THEN
      UPDATE csr_rules_tl
         SET rule_name             = NVL(p_rule_name, rule_name)
           , description           = NVL(p_description, description)
           , last_updated_by       = fnd_global.user_id
           , last_update_date      = SYSDATE
           , last_update_login     = fnd_global.login_id
       WHERE rule_id = p_rule_id
         AND userenv('LANG') IN (language, source_lang);
    END IF;

    -- Propagate the Document to all the child rules based on this Rule
    IF p_rule_doc IS NOT NULL THEN
      propagate_to_child_rules(p_rule_id, p_rule_doc, NULL, p_force_propagation);
    END IF;

    -- Create the Note
    IF p_version_msgs IS NOT NULL THEN
      i := p_version_msgs.FIRST;

      WHILE i IS NOT NULL LOOP
        l_notes     := SUBSTR(p_version_msgs(i), 1, INSTR(p_version_msgs(i), '@$@')-1);
        l_notes_dtl := SUBSTR(p_version_msgs(i), INSTR(p_version_msgs(i), '@$@')+3);
        IF l_notes IS NULL THEN
          l_notes := p_version_msgs(i);
          l_notes_dtl := NULL;
        END IF;

        jtf_notes_pub.create_note(
            p_api_version        => 1.0
          , x_return_status      => x_return_status
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          , p_source_object_id   => p_rule_id
          , p_source_object_code => 'CSR_RULES'
          , p_notes              => l_notes
          , p_notes_detail       => l_notes_dtl
          , x_jtf_note_id        => l_note_id
          );

        i := p_version_msgs.NEXT(i);
      END LOOP;
    END IF;

    x_new_rule_doc := l_rule.rule_doc.getClobVal();

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csr_rule_update;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 'Y' THEN
        debug('Update Rule Errored with ' || x_msg_data, l_api_name, fnd_log.level_error);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csr_rule_update;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 'Y' THEN
        debug('Update Rule Errored with ' || x_msg_data, l_api_name, fnd_log.level_error);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csr_rule_update;
      IF l_debug = 'Y' THEN
        debug('Update Rule Errored with ' || x_msg_data, l_api_name, fnd_log.level_error);
      END IF;
  END update_rule;

  PROCEDURE delete_rule(
      p_api_version              IN            NUMBER
    , p_init_msg_list            IN            VARCHAR2    DEFAULT NULL
    , p_commit                   IN            VARCHAR2    DEFAULT NULL
    , x_return_status           OUT     NOCOPY VARCHAR2
    , x_msg_data                OUT     NOCOPY VARCHAR2
    , x_msg_count               OUT     NOCOPY NUMBER
    , p_rule_id                  IN            NUMBER
    ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_RULE';
    l_debug        CONSTANT VARCHAR2(1)  := fnd_profile.value('AFLOG_ENABLED');
    --
    CURSOR c_child_rules IS
      SELECT rule_id, base_rule_id, LEVEL
        FROM csr_rules_b
       START WITH rule_id = p_rule_id
       CONNECT BY base_rule_id = PRIOR rule_id;
    --
    CURSOR c_rule_notes(v_rule_id NUMBER) IS
      SELECT n.jtf_note_id
        FROM jtf_notes_b n
       WHERE n.source_object_code = 'CSR_RULES'
         AND n.source_object_id = v_rule_id;
    --
    l_note_id NUMBER;
  BEGIN
    SAVEPOINT csr_rule_delete;

    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 'Y' THEN
      debug('Deleting Rule#' || p_rule_id || ' and the entire hierarchy', l_api_name, fnd_log.level_event);
    END IF;


    FOR v_child_rule IN c_child_rules LOOP
      IF l_debug = 'Y' THEN
        debug('Deleting Rule#' || v_child_rule.rule_id || ' based on ' || v_child_rule.base_rule_id || ' at level ' || v_child_rule.LEVEL, l_api_name, fnd_log.level_statement);
      END IF;

      -- Delete all the Dependent Objects like Notes.
      FOR v_note IN c_rule_notes(v_child_rule.rule_id) LOOP
        IF l_debug = 'Y' THEN
          debug('  Deleting Notes #' || v_note.jtf_note_id, l_api_name, fnd_log.level_statement);
        END IF;
        jtf_notes_pub.secure_delete_note(
            p_api_version        => 1.0
          , x_return_status      => x_return_status
          , x_msg_count          => x_msg_count
          , x_msg_data           => x_msg_data
          , p_jtf_note_id        => v_note.jtf_note_id
          , p_use_AOL_security   => fnd_api.g_false
          );

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END LOOP;

      DELETE csr_rules_tl WHERE rule_id = v_child_rule.rule_id;
      DELETE csr_rules_b WHERE rule_id = v_child_rule.rule_id;
    END LOOP;

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO csr_rule_delete;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO csr_rule_delete;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      ROLLBACK TO csr_rule_delete;
  END delete_rule;

  FUNCTION get_sch_parameter_value(
      p_parameter_name           IN            VARCHAR2
    , p_appl_id                  IN            NUMBER      DEFAULT NULL
    , p_resp_id                  IN            NUMBER      DEFAULT NULL
    , p_user_id                  IN            NUMBER      DEFAULT NULL
    , p_terr_id                  IN            NUMBER      DEFAULT NULL
    , p_resource_type            IN            VARCHAR2    DEFAULT NULL
    , p_resource_id              IN            NUMBER      DEFAULT NULL
    ) RETURN VARCHAR2 IS
    --
    l_param_value  VARCHAR2(255);
    l_prefix       VARCHAR2(2000) := '/schedulerRule/';
    --
    CURSOR c_matching_rules_noterr(v_param_path VARCHAR2) IS
      SELECT extractValue(r.rule_doc, v_param_path)
        FROM csr_rules_b r
       WHERE r.appl_id IN (p_appl_id, g_not_specified)
         AND r.resp_id IN (p_resp_id, g_not_specified)
         AND r.user_id IN (p_user_id, g_not_specified)
         AND r.terr_id = g_not_specified
         AND r.resource_type IN (p_resource_type, '-')
         AND r.resource_id IN (p_resource_id, g_not_specified)
         AND existsNode(r.rule_doc, v_param_path) = 1
       ORDER BY rule_rank DESC;

    CURSOR c_matching_rules_terr(v_param_path VARCHAR2) IS
      SELECT extractValue(r.rule_doc, v_param_path)
        FROM csr_rules_b r
           , (
               SELECT terr_id, LEVEL terr_level
                 FROM jtf_terr_all
                START WITH terr_id = p_terr_id
                CONNECT BY NOCYCLE PRIOR parent_territory_id = terr_id
             ) t
       WHERE r.appl_id IN (p_appl_id, g_not_specified)
         AND r.resp_id IN (p_resp_id, g_not_specified)
         AND r.user_id IN (p_user_id, g_not_specified)
         AND r.terr_id IN (t.terr_id, g_not_specified)
         AND r.resource_type IN (p_resource_type, '-')
         AND r.resource_id IN (p_resource_id, g_not_specified)
         AND existsNode(r.rule_doc, v_param_path) = 1
       ORDER BY rule_rank DESC;
  BEGIN
    IF p_parameter_name IS NULL THEN
      RETURN NULL;
    END IF;

    IF SUBSTR(p_parameter_name, 1, 2 )  = 'sp' THEN
      l_prefix := l_prefix || 'schedulerParameters/';
    ELSIF SUBSTR(p_parameter_name, 1, 2 )  = 'rc' THEN
      l_prefix := l_prefix || 'routerConfig/';
    END IF;

    IF p_terr_id IS NULL THEN
      OPEN c_matching_rules_noterr( l_prefix || p_parameter_name);
      FETCH c_matching_rules_noterr INTO l_param_value;
      CLOSE c_matching_rules_noterr;
    ELSE
      OPEN c_matching_rules_terr( l_prefix || p_parameter_name);
      FETCH c_matching_rules_terr INTO l_param_value;
      CLOSE c_matching_rules_terr;
    END IF;

    RETURN l_param_value;
  END get_sch_parameter_value;

  PROCEDURE get_scheduler_rules(
      p_api_version              IN            NUMBER
    , p_init_msg_list            IN            VARCHAR2
    , x_return_status           OUT     NOCOPY VARCHAR2
    , x_msg_data                OUT     NOCOPY VARCHAR2
    , x_msg_count               OUT     NOCOPY NUMBER
    , p_appl_id                  IN            NUMBER
    , p_resp_id                  IN            NUMBER
    , p_user_id                  IN            NUMBER
    , p_res_tbl                  IN            csf_resource_tbl
    , x_res_rules_tbl           OUT     NOCOPY csr_resource_rules_tbl
    ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'GET_SCHEDULER_RULES';
    l_debug        CONSTANT VARCHAR2(1)  := fnd_profile.value('AFLOG_ENABLED');
    --
    l_rules_wo_res_query CONSTANT VARCHAR2(1000) :=
      'SELECT r.*
         FROM csr_rules_vl r
        WHERE r.appl_id IN (:appl_id, -9999)
          AND r.resp_id IN (:resp_id, -9999)
          AND r.user_id IN (:user_id, -9999)
          AND r.terr_id = -9999
          AND r.resource_type = ''-''
          AND r.resource_id = -9999
          AND r.enabled_flag = ''Y''
        ORDER BY r.rule_rank DESC';

    l_rules_wo_terr_query CONSTANT VARCHAR2(1000) :=
      'SELECT r.*
         FROM csr_rules_vl r
        WHERE r.appl_id IN (:appl_id, -9999)
          AND r.resp_id IN (:resp_id, -9999)
          AND r.user_id IN (:user_id, -9999)
          AND r.terr_id = -9999
          AND r.resource_type IN (:res_type, ''-'')
          AND r.resource_id IN (:res_id, -9999)
          AND r.enabled_flag = ''Y''
        ORDER BY r.rule_rank DESC';

    l_rules_with_terr_query CONSTANT VARCHAR2(1000) :=
      'SELECT r.*
         FROM csr_rules_vl r
            , (SELECT terr_id, LEVEL terr_level FROM jtf_terr_all
                START WITH terr_id = :terr_id
                CONNECT BY NOCYCLE PRIOR parent_territory_id = terr_id
               UNION ALL SELECT -9999, 9999999 FROM DUAL
              ) t
        WHERE r.appl_id IN (:appl_id, -9999)
          AND r.resp_id IN (:resp_id, -9999)
          AND r.user_id IN (:user_id, -9999)
          AND r.terr_id = t.terr_id
          AND r.resource_type IN (:res_type, ''-'')
          AND r.resource_id IN (:res_id, -9999)
          AND r.enabled_flag = ''Y''
        ORDER BY r.rule_rank DESC, t.terr_level ASC';

    c_rules        SYS_REFCURSOR;
    --
    i              PLS_INTEGER;
    l_res          csf_resource;
    l_rule         csr_rules_vl%ROWTYPE;
    l_rule_tbl     csr_rule_tbl;
  BEGIN
    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_debug = 'Y' THEN
      debug('Getting Rules for given eligibility', l_api_name, fnd_log.level_event);
      debug(' --> Appl ID   = ' || p_appl_id, l_api_name, fnd_log.level_event);
      debug(' --> Resp ID   = ' || p_resp_id, l_api_name, fnd_log.level_event);
      debug(' --> User ID   = ' || p_user_id, l_api_name, fnd_log.level_event);
    END IF;

    IF x_res_rules_tbl IS NULL THEN
      x_res_rules_tbl := csr_resource_rules_tbl();
    END IF;

    l_rule_tbl := csr_rule_tbl();

    IF p_res_tbl IS NOT NULL THEN
      i := p_res_tbl.FIRST;
      WHILE i IS NOT NULL LOOP

        l_res := p_res_tbl(i);
        l_rule_tbl.DELETE;

        IF l_debug = 'Y' THEN
          debug(' --> Terr ID   = ' || l_res.terr_id, l_api_name, fnd_log.level_event);
          debug(' --> Res Type  = ' || l_res.resource_type, l_api_name, fnd_log.level_event);
          debug(' --> Res ID    = ' || l_res.resource_id, l_api_name, fnd_log.level_event);
        END IF;

        IF l_res.terr_id IS NOT NULL AND l_res.terr_id <> g_not_specified THEN
          OPEN c_rules FOR l_rules_with_terr_query USING l_res.terr_id, p_appl_id, p_resp_id, p_user_id, l_res.resource_type, l_res.resource_id;
        ELSE
          OPEN c_rules FOR l_rules_wo_terr_query USING p_appl_id, p_resp_id, p_user_id, l_res.resource_type, l_res.resource_id;
        END IF;

        LOOP
          FETCH c_rules INTO l_rule;
          EXIT WHEN c_rules%NOTFOUND;

          IF l_debug = 'Y' THEN
            debug(' ---> Fetched Rule with ID = ' || l_rule.rule_id || ' : Rank = ' || l_rule.rule_rank, l_api_name, fnd_log.level_statement);
          END IF;

          l_rule_tbl.EXTEND;
          l_rule_tbl(l_rule_tbl.COUNT) :=
            csr_rule(
                l_rule.rule_id
              , l_rule.rule_name
              , l_rule.object_version_number
              , l_rule.base_rule_id
              , l_rule.appl_id
              , l_rule.resp_id
              , l_rule.user_id
              , l_rule.terr_id
              , l_rule.resource_type
              , l_rule.resource_id
              , l_rule.rule_rank
              , l_rule.rule_doc.getClobVal()
              );
        END LOOP;

        CLOSE c_rules;

        x_res_rules_tbl.EXTEND;
        x_res_rules_tbl(x_res_rules_tbl.COUNT) := l_rule_tbl;

        i := p_res_tbl.NEXT(i);
      END LOOP;
    ELSE
      OPEN c_rules FOR l_rules_wo_res_query USING p_appl_id, p_resp_id, p_user_id;
      LOOP
        FETCH c_rules INTO l_rule;
        EXIT WHEN c_rules%NOTFOUND;

        IF l_debug = 'Y' THEN
          debug(' ---> Fetched Rule with ID = ' || l_rule.rule_id || ' : Rank = ' || l_rule.rule_rank, l_api_name, fnd_log.level_statement);
        END IF;

        l_rule_tbl.EXTEND;
        l_rule_tbl(l_rule_tbl.COUNT) :=
          csr_rule(
              l_rule.rule_id
            , l_rule.rule_name
            , l_rule.object_version_number
            , l_rule.base_rule_id
            , l_rule.appl_id
            , l_rule.resp_id
            , l_rule.user_id
            , l_rule.terr_id
            , l_rule.resource_type
            , l_rule.resource_id
            , l_rule.rule_rank
            , l_rule.rule_doc.getClobVal()
            );
      END LOOP;
      CLOSE c_rules;

      x_res_rules_tbl.EXTEND;
      x_res_rules_tbl(x_res_rules_tbl.COUNT) := l_rule_tbl;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  END get_scheduler_rules;

  PROCEDURE process_webadi_action(
      p_action                          IN            VARCHAR2
    , p_rule_id                         IN            NUMBER
    , p_object_version_number           IN            NUMBER
    , p_rule_name                       IN            VARCHAR2
    , p_description                     IN            VARCHAR2
    , p_base_rule_id                    IN            NUMBER
    , p_appl_id                         IN            NUMBER
    , p_resp_id                         IN            NUMBER
    , p_user_id                         IN            NUMBER
    , p_terr_id                         IN            NUMBER
    , p_resource_type                   IN            VARCHAR2
    , p_resource_id                     IN            NUMBER
    , p_enabled_flag                    IN            VARCHAR2
    , p_sp_plan_scope                   IN            NUMBER
    , p_sp_max_plan_options             IN            NUMBER
    , p_sp_max_resources                IN            NUMBER
    , p_sp_max_calc_time                IN            NUMBER
    , p_sp_max_overtime                 IN            NUMBER
    , p_sp_wtp_threshold                IN            NUMBER
    , p_sp_enforce_plan_window          IN            VARCHAR2
    , p_sp_consider_standby_shifts      IN            VARCHAR2
    , p_sp_spares_mandatory             IN            VARCHAR2
    , p_sp_spares_source                IN            VARCHAR2
    , p_sp_min_task_length              IN            NUMBER
    , p_sp_default_shift_duration       IN            NUMBER
    , p_sp_dist_last_child_effort       IN            VARCHAR2
    , p_sp_pick_contract_resources      IN            VARCHAR2
    , p_sp_pick_ib_resources            IN            VARCHAR2
    , p_sp_pick_territory_resources     IN            VARCHAR2
    , p_sp_pick_skilled_resources       IN            VARCHAR2
    , p_sp_auto_sch_default_query       IN            NUMBER
    , p_sp_auto_reject_sts_id_spares    IN            NUMBER
    , p_sp_auto_reject_sts_id_others    IN            NUMBER
    , p_sp_force_optimizer_to_group     IN            VARCHAR2
    , p_sp_optimizer_success_perc       IN            NUMBER
    , p_sp_commutes_position            IN            VARCHAR2
    , p_sp_commute_excluded_time        IN            NUMBER
    , p_sp_commute_home_empty_trip      IN            VARCHAR2
    , p_sp_router_mode                  IN            VARCHAR2
    , p_sp_travel_time_extra            IN            NUMBER
    , p_sp_default_router_enabled       IN            VARCHAR2
    , p_sp_default_travel_distance      IN            NUMBER
    , p_sp_default_travel_duration      IN            NUMBER
    , p_sp_max_distance_in_group        IN            NUMBER
    , p_sp_max_dist_to_skip_actual      IN            NUMBER
    , p_rc_router_calc_type             IN            VARCHAR2
    , p_rc_consider_toll_roads          IN            VARCHAR2
    , p_rc_route_func_delay_0           IN            NUMBER
    , p_rc_route_func_delay_1           IN            NUMBER
    , p_rc_route_func_delay_2           IN            NUMBER
    , p_rc_route_func_delay_3           IN            NUMBER
    , p_rc_route_func_delay_4           IN            NUMBER
    , p_rc_estimate_first_boundary      IN            NUMBER
    , p_rc_estimate_second_boundary     IN            NUMBER
    , p_rc_estimate_first_avg_speed     IN            NUMBER
    , p_rc_estimate_second_avg_speed    IN            NUMBER
    , p_rc_estimate_third_avg_speed     IN            NUMBER
    , p_cp_task_per_day_delayed         IN            NUMBER
    , p_cp_task_per_min_early           IN            NUMBER
    , p_cp_task_per_min_late            IN            NUMBER
    , p_cp_tls_per_day_extra            IN            NUMBER
    , p_cp_tls_per_child_extra          IN            NUMBER
    , p_cp_parts_violation              IN            NUMBER
    , p_cp_res_per_min_overtime         IN            NUMBER
    , p_cp_res_assigned_not_pref        IN            NUMBER
    , p_cp_res_skill_level              IN            NUMBER
    , p_cp_standby_shift_usage          IN            NUMBER
    , p_cp_travel_per_unit_distance     IN            NUMBER
    , p_cp_travel_per_unit_duration     IN            NUMBER
    , p_cp_defer_same_site              IN            NUMBER
    ) IS
    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'PROCESS_WEBADI_ACTION';
    l_debug        CONSTANT VARCHAR2(1)  := fnd_profile.value('AFLOG_ENABLED');
    --
    l_return_status       VARCHAR2(1);
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_object_version_num  NUMBER;
    --
    l_new_param_values    jtf_varchar2_table_100;
    --
    l_rule_document       DBMS_XMLDOM.DOMDocument;
    l_root_element        DBMS_XMLDOM.DOMELEMENT;
    l_dom_node            DBMS_XMLDOM.DOMNode;
    l_dom_text_node       DBMS_XMLDOM.DOMNode;
    l_dom_node_value      VARCHAR2(100);
    l_parent_dom_node     DBMS_XMLDOM.DOMNode;
    --
    CURSOR c_rule_details IS
      SELECT b.rule_doc, b.rule_rank, t.rule_name, t.description
        FROM csr_rules_b b, csr_rules_tl t
       WHERE b.rule_id = p_rule_id
         FOR UPDATE OF b.rule_doc, t.rule_name NOWAIT;
    l_rule            c_rule_details%ROWTYPE;
    l_new_rule_doc    CLOB;
  BEGIN
    IF l_debug = 'Y' THEN
      debug('Processing WebADI Action ' || p_action || ' for RuleID = ' || p_rule_id || ' with OVN = ' || p_object_version_number, l_api_name, fnd_log.level_event);
      debug('  --> Parameter : Rule Name                  = ' || p_rule_name, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Description                = ' || p_description, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Plan Scope                 = ' || p_sp_plan_scope, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Max Plan Options           = ' || p_sp_max_plan_options, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Max Resources              = ' || p_sp_max_resources, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Max Calc Time              = ' || p_sp_max_calc_time, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Max Overtime               = ' || p_sp_max_overtime, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Wtp Threshold              = ' || p_sp_wtp_threshold, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Enforce Plan Window        = ' || p_sp_enforce_plan_window, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Consider Standby Shifts    = ' || p_sp_consider_standby_shifts, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Spares Mandatory           = ' || p_sp_spares_mandatory, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Spares Source              = ' || p_sp_spares_source, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Min Task Length            = ' || p_sp_min_task_length, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Default Shift Duration     = ' || p_sp_default_shift_duration, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Dist Last Child Effort     = ' || p_sp_dist_last_child_effort, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Pick Contract Resources    = ' || p_sp_pick_contract_resources, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Pick IB Resources          = ' || p_sp_pick_ib_resources, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Pick Territory Resources   = ' || p_sp_pick_territory_resources, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Pick Skilled Resources     = ' || p_sp_pick_skilled_resources, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Auto Sch Default Query     = ' || p_sp_auto_sch_default_query, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Auto Reject Sts Id Spares  = ' || p_sp_auto_reject_sts_id_spares, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Auto Reject Sts Id Others  = ' || p_sp_auto_reject_sts_id_others, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Force Optimizer To Group   = ' || p_sp_force_optimizer_to_group, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Optimizer Success Perc     = ' || p_sp_optimizer_success_perc, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Commutes Position          = ' || p_sp_commutes_position, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Commute Excluded Time      = ' || p_sp_commute_excluded_time, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Commute Home Empty Trip    = ' || p_sp_commute_home_empty_trip, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Router Mode                = ' || p_sp_router_mode, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Travel Time Extra          = ' || p_sp_travel_time_extra, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Default Router Enabled     = ' || p_sp_default_router_enabled, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Default Travel Distance    = ' || p_sp_default_travel_distance, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Default Travel Duration    = ' || p_sp_default_travel_duration, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Max Distance In Group      = ' || p_sp_max_distance_in_group, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Max Dist To Skip Actual    = ' || p_sp_max_dist_to_skip_actual, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Router Calc Type           = ' || p_rc_router_calc_type, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Consider Toll Roads        = ' || p_rc_consider_toll_roads, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Route Func Delay 0         = ' || p_rc_route_func_delay_0, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Route Func Delay 1         = ' || p_rc_route_func_delay_1, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Route Func Delay 2         = ' || p_rc_route_func_delay_2, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Route Func Delay 3         = ' || p_rc_route_func_delay_3, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Route Func Delay 4         = ' || p_rc_route_func_delay_4, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Estimate First Boundary    = ' || p_rc_estimate_first_boundary, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Estimate Second Boundary   = ' || p_rc_estimate_second_boundary, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Estimate First Avg Speed   = ' || p_rc_estimate_first_avg_speed, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Estimate Second Avg Speed  = ' || p_rc_estimate_second_avg_speed, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Estimate Third Avg Speed   = ' || p_rc_estimate_third_avg_speed, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Task Per Day Delayed       = ' || p_cp_task_per_day_delayed, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Task Per Min Early         = ' || p_cp_task_per_min_early, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Task Per Min Late          = ' || p_cp_task_per_min_late, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Tls Per Day Extra          = ' || p_cp_tls_per_day_extra, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Tls Per Child Extra        = ' || p_cp_tls_per_child_extra, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Parts Violation            = ' || p_cp_parts_violation, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Res Per Min Overtime       = ' || p_cp_res_per_min_overtime, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Res Assigned Not Pref      = ' || p_cp_res_assigned_not_pref, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Res Skill Level            = ' || p_cp_res_skill_level, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Standby Shift Usage        = ' || p_cp_standby_shift_usage, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Travel Per Unit Distance   = ' || p_cp_travel_per_unit_distance, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Travel Per Unit Duration   = ' || p_cp_travel_per_unit_duration, l_api_name, fnd_log.level_statement);
      debug('  --> Parameter : Defer Same Site            = ' || p_cp_defer_same_site, l_api_name, fnd_log.level_statement);
    END IF;

    IF p_action = 'UPDATE' THEN
      OPEN c_rule_details;
      FETCH c_rule_details INTO l_rule;
      CLOSE c_rule_details;

      l_new_param_values := jtf_varchar2_table_100();
      l_new_param_values.extend(57);
      l_new_param_values(01) := p_sp_plan_scope;
      l_new_param_values(02) := p_sp_max_plan_options;
      l_new_param_values(03) := p_sp_max_resources;
      l_new_param_values(04) := p_sp_max_calc_time;
      l_new_param_values(05) := p_sp_max_overtime;
      l_new_param_values(06) := p_sp_wtp_threshold;
      l_new_param_values(07) := p_sp_enforce_plan_window;
      l_new_param_values(08) := p_sp_consider_standby_shifts;
      l_new_param_values(09) := p_sp_spares_mandatory;
      l_new_param_values(10) := p_sp_spares_source;
      l_new_param_values(11) := p_sp_min_task_length;
      l_new_param_values(12) := p_sp_default_shift_duration;
      l_new_param_values(13) := p_sp_dist_last_child_effort;
      l_new_param_values(14) := p_sp_pick_contract_resources;
      l_new_param_values(15) := p_sp_pick_ib_resources;
      l_new_param_values(16) := p_sp_pick_territory_resources;
      l_new_param_values(17) := p_sp_pick_skilled_resources;
      l_new_param_values(18) := p_sp_auto_sch_default_query;
      l_new_param_values(19) := p_sp_auto_reject_sts_id_spares;
      l_new_param_values(20) := p_sp_auto_reject_sts_id_others;
      l_new_param_values(21) := p_sp_force_optimizer_to_group;
      l_new_param_values(22) := p_sp_optimizer_success_perc;
      l_new_param_values(23) := p_sp_commutes_position;
      l_new_param_values(24) := p_sp_commute_excluded_time;
      l_new_param_values(25) := p_sp_commute_home_empty_trip;
      l_new_param_values(26) := p_sp_router_mode;
      l_new_param_values(27) := p_sp_travel_time_extra;
      l_new_param_values(28) := p_sp_default_router_enabled;
      l_new_param_values(29) := p_sp_default_travel_distance;
      l_new_param_values(30) := p_sp_default_travel_duration;
      l_new_param_values(31) := p_sp_max_distance_in_group;
      l_new_param_values(32) := p_sp_max_dist_to_skip_actual;
      l_new_param_values(33) := p_rc_router_calc_type;
      l_new_param_values(34) := p_rc_consider_toll_roads;
      l_new_param_values(35) := p_rc_route_func_delay_0;
      l_new_param_values(36) := p_rc_route_func_delay_1;
      l_new_param_values(37) := p_rc_route_func_delay_2;
      l_new_param_values(38) := p_rc_route_func_delay_3;
      l_new_param_values(39) := p_rc_route_func_delay_4;
      l_new_param_values(40) := p_rc_estimate_first_boundary;
      l_new_param_values(41) := p_rc_estimate_second_boundary;
      l_new_param_values(42) := p_rc_estimate_first_avg_speed;
      l_new_param_values(43) := p_rc_estimate_second_avg_speed;
      l_new_param_values(44) := p_rc_estimate_third_avg_speed;
      l_new_param_values(45) := p_cp_task_per_day_delayed;
      l_new_param_values(46) := p_cp_task_per_min_early;
      l_new_param_values(47) := p_cp_task_per_min_late;
      l_new_param_values(48) := p_cp_tls_per_day_extra;
      l_new_param_values(49) := p_cp_tls_per_child_extra;
      l_new_param_values(50) := p_cp_parts_violation;
      l_new_param_values(51) := p_cp_res_per_min_overtime;
      l_new_param_values(52) := p_cp_res_assigned_not_pref;
      l_new_param_values(53) := p_cp_res_skill_level;
      l_new_param_values(54) := p_cp_standby_shift_usage;
      l_new_param_values(55) := p_cp_travel_per_unit_distance;
      l_new_param_values(56) := p_cp_travel_per_unit_duration;
      l_new_param_values(57) := p_cp_defer_same_site;

      l_rule_document := DBMS_XMLDOM.newDOMDocument(l_rule.rule_doc);
      l_root_element  := DBMS_XMLDOM.getDocumentElement(l_rule_document);

      FOR i IN 1..g_rule_param_names_tbl.COUNT LOOP
        l_dom_node := DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(l_rule_document, g_rule_param_names_tbl(i)), 0);

        -- If the Node already exists in the RULE_DOC, then we just need to update the Value
        IF DBMS_XMLDOM.isNull(l_dom_node) = FALSE THEN
          l_dom_node_value := DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.getFirstChild(l_dom_node));

          -- Delete the Node if the new value is NULL
          IF l_new_param_values(i) IS NULL THEN
            l_dom_node := DBMS_XMLDOM.removeChild(DBMS_XMLDOM.getParentNode(l_dom_node), l_dom_node);
          ELSE
            IF NVL(l_new_param_values(i), '-') <> NVL(l_dom_node_value, '-') THEN
              DBMS_XMLDOM.setAttribute(DBMS_XMLDOM.makeElement(l_dom_node), 'inherited', 'N');
            END IF;
            DBMS_XMLDOM.setNodeValue(DBMS_XMLDOM.getFirstChild(l_dom_node), l_new_param_values(i));
          END IF;
        ELSIF l_new_param_values(i) IS NOT NULL AND is_param_valid_for_eligibility(l_rule.rule_rank, i) THEN
          -- Node doesnt exists. If a value is provided in the parameter and the parameter is valid
          -- for the current eligibility, we have to create a Node.
          l_dom_node := DBMS_XMLDOM.makeNode(DBMS_XMLDOM.createElement(l_rule_document, g_rule_param_names_tbl(i), g_rules_ns));
          l_dom_text_node := DBMS_XMLDOM.appendChild(l_dom_node, DBMS_XMLDOM.MAKENODE(DBMS_XMLDOM.createTextNode(l_rule_document, l_new_param_values(i))));
          DBMS_XMLDOM.setAttribute(DBMS_XMLDOM.makeElement(l_dom_node), 'inherited', 'N');
          l_parent_dom_node := get_param_grp_dom_node(l_rule_document, CASE WHEN i<33 THEN 'schedulerParameters' WHEN i<45 THEN 'routerConfig' ELSE 'costParameters' END, TRUE);
          l_dom_node := DBMS_XMLDOM.appendChild(l_parent_dom_node, l_dom_node);
        END IF;
      END LOOP;

      l_object_version_num := p_object_version_number;

      update_rule(
          p_api_version           => 1.0
        , p_init_msg_list         => fnd_api.g_true
        , p_commit                => fnd_api.g_true
        , x_return_status         => l_return_status
        , x_msg_data              => l_msg_data
        , x_msg_count             => l_msg_count
        , p_rule_id               => p_rule_id
        , p_object_version_number => l_object_version_num
        , p_rule_name             => p_rule_name
        , p_description           => p_description
        , p_enabled_flag          => p_enabled_flag
        , p_rule_doc              => l_rule.rule_doc
        , p_version_msgs          => NULL
        , x_new_rule_doc          => l_new_rule_doc
        );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug = 'Y' THEN
          debug('Process WebADI Action Errored out. Message Count = ' || l_msg_count || ' : Message Data = ' || l_msg_data, l_api_name, fnd_log.level_error);
        END IF;

        IF l_msg_count > 0 THEN
          fnd_message.set_encoded(fnd_msg_pub.get(fnd_msg_pub.g_last));
          fnd_message.raise_error;
        END IF;
      END IF;
    END IF;
  END process_webadi_action;

  PROCEDURE add_language IS
  BEGIN
    DELETE FROM csr_rules_tl t
     WHERE NOT EXISTS (SELECT NULL FROM csr_rules_b b WHERE b.rule_id = t.rule_id);

    UPDATE csr_rules_tl csrt
       SET (csrt.rule_name, csrt.description) = (
               SELECT csrtl.rule_name, csrtl.description
                 FROM csr_rules_tl csrtl
                WHERE csrtl.rule_id = csrt.rule_id
                  AND csrtl.language = csrt.source_lang
             )
     WHERE (csrt.rule_id, csrt.language) IN (
               SELECT subt.rule_id, subt.language
                 FROM csr_rules_tl subb, csr_rules_tl subt
                WHERE subb.rule_id = subt.rule_id
                  AND subb.language = subt.source_lang
                  AND (
                          subb.rule_name <> subt.rule_name
                       OR subb.description <> subt.description
                       OR (subb.description IS NULL AND subt.description IS NOT NULL)
                       OR (subb.description IS NOT NULL AND subt.description IS NULL)
                      )
             );

    INSERT INTO csr_rules_tl (
        rule_id
      , rule_name
      , description
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
      , language
      , source_lang
      )
      SELECT csrt.rule_id
           , csrt.rule_name
           , csrt.description
           , csrt.created_by
           , csrt.creation_date
           , csrt.last_updated_by
           , csrt.last_update_date
           , csrt.last_update_login
           , l.language_code
           , csrt.source_lang
        FROM csr_rules_tl  csrt
           , fnd_languages l
       WHERE l.installed_flag IN ('I', 'B')
         AND csrt.language = userenv('LANG')
         AND NOT EXISTS (
               SELECT NULL
                 FROM csr_rules_tl t
                WHERE t.rule_id  = csrt.rule_id
                  AND t.language = l.language_code
               );

    DELETE FROM CSR_RULE_WINDOWS_TL t
     WHERE NOT EXISTS (SELECT NULL FROM CSR_RULE_WINDOWS_TL b WHERE b.window_id = t.window_id);

    UPDATE CSR_RULE_WINDOWS_TL csrt
       SET (csrt.window_name, csrt.description) = (
               SELECT csrtl.window_name, csrtl.description
                 FROM CSR_RULE_WINDOWS_TL csrtl
                WHERE csrtl.window_id = csrt.window_id
                  AND csrtl.language = csrt.source_lang
             )
     WHERE (csrt.window_id, csrt.language) IN (
               SELECT subt.window_id, subt.language
                 FROM CSR_RULE_WINDOWS_TL subb, CSR_RULE_WINDOWS_TL subt
                WHERE subb.window_id = subt.window_id
                  AND subb.language = subt.source_lang
                  AND (
                          subb.window_name <> subt.window_name
                       OR subb.description <> subt.description
                       OR (subb.description IS NULL AND subt.description IS NOT NULL)
                       OR (subb.description IS NOT NULL AND subt.description IS NULL)
                      )
             );

    INSERT INTO CSR_RULE_WINDOWS_TL (
        window_id
      , window_name
      , description
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
      , language
      , source_lang
      )
      SELECT csrt.window_id
           , csrt.window_name
           , csrt.description
           , csrt.created_by
           , csrt.creation_date
           , csrt.last_updated_by
           , csrt.last_update_date
           , csrt.last_update_login
           , l.language_code
           , csrt.source_lang
        FROM CSR_RULE_WINDOWS_TL  csrt
           , fnd_languages l
       WHERE l.installed_flag IN ('I', 'B')
         AND csrt.language = userenv('LANG')
         AND NOT EXISTS (
               SELECT NULL
                 FROM CSR_RULE_WINDOWS_TL t
                WHERE t.window_id  = csrt.window_id
                  AND t.language = l.language_code
               );
  END add_language;

BEGIN
  init_package;
END csr_rules_pvt;

/
