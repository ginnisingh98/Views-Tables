--------------------------------------------------------
--  DDL for Package Body GCS_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_ENTITIES_PKG" AS
  /* $Header: gcsenttb.pls 120.10 2007/03/22 12:59:33 vkosuri ship $ */
  --
  -- Package
  --   gcs_entities_pkg
  -- Purpose
  --   Package procedures for Consolidation Hierarchies
  -- History
  --   06-MAR-04  M Ward    Created
  --

  --
  -- Private Global Variables
  --

  -- The API name
  g_api CONSTANT VARCHAR2(40) := 'gcs.plsql.GCS_ENTITIES_PKG';

  -- Action types for writing module information to the log file. Used for
  -- the procedure log_file_module_write.
  g_module_enter   CONSTANT VARCHAR2(2) := '>>';
  g_module_success CONSTANT VARCHAR2(2) := '<<';
  g_module_failure CONSTANT VARCHAR2(2) := '<x';

  -- A newline character. Included for convenience when writing long strings.
  g_nl CONSTANT VARCHAR2(1) := '
';

  G_CHAN_FLG     VARCHAR2(1);
  G_CCTR_FLG     VARCHAR2(1);
  G_CUST_FLG     VARCHAR2(1);
  G_GEOG_FLG     VARCHAR2(1);
  G_LN_ITEM_FLG  VARCHAR2(1);
  G_NAT_ACCT_FLG VARCHAR2(1);
  G_PROD_FLG     VARCHAR2(1);
  G_PROJ_FLG     VARCHAR2(1);
  G_USER1_FLG    VARCHAR2(1);
  G_USER2_FLG    VARCHAR2(1);
  G_USER3_FLG    VARCHAR2(1);
  G_USER4_FLG    VARCHAR2(1);
  G_USER5_FLG    VARCHAR2(1);
  G_USER6_FLG    VARCHAR2(1);
  G_USER7_FLG    VARCHAR2(1);
  G_USER8_FLG    VARCHAR2(1);
  G_USER9_FLG    VARCHAR2(1);
  G_USER10_FLG   VARCHAR2(1);

  --
  -- Private Procedures and Functions for Multiple Parents
  --

  --
  -- Procedure
  --   Module_Log_Write
  -- Purpose
  --   Write the procedure or function entered or exited, and the time that
  --   this happened. Write it to the log repository.
  -- Arguments
  --   p_module         Name of the module
  --   p_action_type    Entered, Exited Successfully, or Exited with Failure
  -- Example
  --   GCS_ENTITIES_PKG.Module_Log_Write
  -- Notes
  --
  PROCEDURE Module_Log_Write(p_module VARCHAR2, p_action_type VARCHAR2) IS
  BEGIN
    -- Only print if the log level is set at the appropriate level
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || p_module,
                     p_action_type || ' ' || p_module || '() ' ||
                     to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
  END Module_Log_Write;

  --
  -- Procedure
  --   Write_To_Log
  -- Purpose
  --   Write the text given to the log in 3500 character increments
  --   this happened. Write it to the log repository.
  -- Arguments
  --   p_module         Name of the module
  --   p_level          Logging level
  --   p_text           Text to write
  -- Example
  --   GCS_ENTITIES_PKG.Write_To_Log
  -- Notes
  --
  PROCEDURE Write_To_Log(p_module VARCHAR2,
                         p_level  NUMBER,
                         p_text   VARCHAR2) IS
    api_module_concat  VARCHAR2(200);
    text_with_date     VARCHAR2(32767);
    text_with_date_len NUMBER;
    curr_index         NUMBER;
  BEGIN
    -- Only print if the log level is set at the appropriate level
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= p_level THEN
      api_module_concat  := g_api || '.' || p_module;
      text_with_date     := to_char(sysdate, 'DD-MON-YYYY HH:MI:SS') || g_nl ||
                            p_text;
      text_with_date_len := length(text_with_date);
      curr_index         := 1;
      WHILE curr_index <= text_with_date_len LOOP
        fnd_log.string(p_level,
                       api_module_concat,
                       substr(text_with_date, curr_index, 3500));
        curr_index := curr_index + 3500;
      END LOOP;
    END IF;
  END Write_To_Log;

  --
  -- Public Procedures and Functions for Multiple Parents
  --

  --
  -- Procedure
  --   Add_To_Summary_Table
  -- Purpose
  --   Inserts rows into the gcs_entity_cctr_orgs table.
  -- Arguments
  --   p_entity_id    Entity for which the logic must be performed
  -- Example
  --   GCS_ENTITIES_PKG.Add_To_Summary_Table(...);
  -- Notes
  --
  PROCEDURE Add_To_Summary_Table(p_entity_id NUMBER) IS
    v_module VARCHAR2(30);
  BEGIN
    v_module := 'Add_To_Summary_Table';
    module_log_write(v_module, g_module_enter);

    --Added by Santosh - 5235164
    DELETE gcs_entity_cctr_orgs WHERE entity_id = p_entity_id;


    INSERT INTO gcs_entity_cctr_orgs
      (entity_id,
       company_cost_center_org_id,
       object_version_number,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login)
      SELECT p_entity_id,
             coa.company_cost_center_org_id,
             1,
             sysdate,
             eo.created_by,
             sysdate,
             eo.last_updated_by,
             eo.last_update_login
        FROM gcs_entity_organizations eo,
             fem_cctr_orgs_attr       coa,
             fem_dim_attributes_b     fdab,
             fem_dim_attr_versions_b  fdavb
       WHERE eo.entity_id = p_entity_id
         AND coa.dim_attribute_numeric_member =
             eo.company_cost_center_org_id
         AND coa.attribute_id = fdab.attribute_id
         AND coa.version_id = fdavb.version_id
         AND fdab.attribute_varchar_label = 'COMPANY'
         AND fdavb.attribute_id = fdab.attribute_id
         AND fdavb.default_version_flag = 'Y';

    module_log_write(v_module, g_module_success);
  EXCEPTION
    WHEN OTHERS THEN
      write_to_log(v_module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      module_log_write(v_module, g_module_failure);
      RAISE;
  END Add_To_Summary_Table;

  --
  -- Procedure
  --   Get_Next_Token
  -- Purpose
  --   Gets the next token from a clob
  -- Arguments
  --   p_info_clob  The clob from which to retrieve the next token
  --   p_current_loc  The current starting location of the clob
  --   x_info_buffer  The buffer into which the clob should be written
  -- Example
  --   GCS_ENTITIES_PKG.Get_Next_Token(...);
  -- Notes
  --
  PROCEDURE Get_Next_Token(p_info_clob   CLOB,
                           p_current_loc IN OUT NOCOPY INTEGER,
                           x_info_buffer OUT NOCOPY VARCHAR2) IS
    next_delim  INTEGER;
    read_amount INTEGER;
  BEGIN
    next_delim := DBMS_LOB.INSTR(p_info_clob, g_nl, p_current_loc, 1);

    read_amount := next_delim - p_current_loc;

    IF read_amount > 0 THEN
      DBMS_LOB.READ(p_info_clob, read_amount, p_current_loc, x_info_buffer);
    ELSE
      x_info_buffer := '';
    END IF;

    p_current_loc := next_delim + 1;
  END Get_Next_Token;

  --
  -- Entitiy Loader private procedures
  --

  --
  -- Function
  --   Create_Ext_Ledger
  -- Purpose
  --   Create an external ledger based on the parameters given.
  -- Arguments
  --   p_src_sys_code Source system code
  --   p_vs_combo_id  Global value set combination id
  --   p_cal_hier_id  Calendar hierarchy id
  --   p_ccy_code Default currency code
  --   p_ledger_name  Name of the new ledger
  --   p_ledger_desc  Description of the new ledger
  -- Return value
  --   The new ledger_id
  -- Example
  --   GCS_ENTITIES_PKG.Create_Ext_Ledger(...)
  -- Notes
  --
  FUNCTION Create_Ext_Ledger(p_src_sys_code NUMBER,
                             p_vs_combo_id  NUMBER,
                             p_cal_hier_id  NUMBER,
                             p_ccy_code     VARCHAR2,
                             p_ledger_name  VARCHAR2,
                             p_ledger_desc  VARCHAR2) RETURN NUMBER IS
    new_ledger_id NUMBER;

    return_status VARCHAR2(100);
    msg_count     NUMBER;
    msg_data      VARCHAR2(2000);

    source_system_disp_code VARCHAR2(200);
  BEGIN
    SELECT gl_sets_of_books_s.nextval INTO new_ledger_id FROM dual;

    FEM_DIMENSION_UTIL_PKG.REGISTER_LEDGER(X_RETURN_STATUS  => return_status,
                                           X_MSG_COUNT      => msg_count,
                                           X_MSG_DATA       => msg_data,
                                           P_LEDGER_ID      => new_ledger_id,
                                           P_DISPLAY_CODE   => p_ledger_name,
                                           P_LEDGER_NAME    => p_ledger_name,
                                           P_FUNC_CURR_CD   => p_ccy_code,
                                           P_SOURCE_CD      => p_src_sys_code,
                                           P_CAL_PER_HID    => p_cal_hier_id,
                                           P_GLOBAL_VS_ID   => p_vs_combo_id,
                                           P_EPB_DEF_LG_FLG => 'N',
                                           P_ENT_CURR_FLG   => 'Y',
                                           P_AVG_BAL_FLG    => 'Y',
                                           P_CHAN_FLG       => G_CHAN_FLG,
                                           P_CCTR_FLG       => G_CCTR_FLG,
                                           P_CUST_FLG       => G_CUST_FLG,
                                           P_GEOG_FLG       => G_GEOG_FLG,
                                           P_LN_ITEM_FLG    => G_LN_ITEM_FLG,
                                           P_NAT_ACCT_FLG   => G_NAT_ACCT_FLG,
                                           P_PROD_FLG       => G_PROD_FLG,
                                           P_PROJ_FLG       => G_PROJ_FLG,
                                           P_ENTITY_FLG     => 'Y',
                                           P_USER1_FLG      => G_USER1_FLG,
                                           P_USER2_FLG      => G_USER2_FLG,
                                           P_USER3_FLG      => G_USER3_FLG,
                                           P_USER4_FLG      => G_USER4_FLG,
                                           P_USER5_FLG      => G_USER5_FLG,
                                           P_USER6_FLG      => G_USER6_FLG,
                                           P_USER7_FLG      => G_USER7_FLG,
                                           P_USER8_FLG      => G_USER8_FLG,
                                           P_USER9_FLG      => G_USER9_FLG,
                                           P_USER10_FLG     => G_USER10_FLG,
                                           P_VER_NAME       => 'Default',
                                           P_VER_DISP_CD    => 'Default',
                                           P_LEDGER_DESC    => p_ledger_desc);

    return new_ledger_id;
  END Create_Ext_Ledger;

  --
  -- Entitiy Loader procedure
  --
  PROCEDURE Load_Entities(x_errbuf  OUT NOCOPY VARCHAR2,
                          x_retcode OUT NOCOPY VARCHAR2,
                          p_file_id NUMBER) IS
    l_local_clob CLOB;

    info_buffer VARCHAR2(1000);
    current_loc INTEGER;
    clob_length INTEGER;
    read_mode   INTEGER; -- 1 for EXT, 2 for OGL, 3 for CONS

    new_entity_id      NUMBER;
    entity_name        VARCHAR2(500);
    entity_desc        VARCHAR2(500);
    entity_nComps      NUMBER;
    entity_comp_id     NUMBER;
    entity_base_org_id NUMBER;
    entity_contact     VARCHAR2(500);
    entity_logo        VARCHAR2(500);
    entity_src_sys     NUMBER;
    entity_vs_combo_id NUMBER;
    entity_cal_hier_id NUMBER;
    entity_def_ccy     VARCHAR2(30);
    entity_trs_obj_id  NUMBER;
    entity_vrs_obj_id  NUMBER;
    entity_sec_by_role VARCHAR2(10);
    entity_nRoles      NUMBER;
    entity_role_name   VARCHAR2(500);
    entity_ledger_id   NUMBER;
    entity_bal_rule_id NUMBER;
    entity_elim_name   VARCHAR2(500);
    entity_cont_id     NUMBER;

    entity_type_code VARCHAR2(30);

    elim_entity_id NUMBER;

    base_org_attr_id    NUMBER;
    base_org_v_id       NUMBER;
    contact_attr_id     NUMBER;
    contact_v_id        NUMBER;
    logo_attr_id        NUMBER;
    logo_v_id           NUMBER;
    src_sys_attr_id     NUMBER;
    src_sys_v_id        NUMBER;
    ledger_attr_id      NUMBER;
    ledger_v_id         NUMBER;
    trs_attr_id         NUMBER;
    trs_v_id            NUMBER;
    vrs_attr_id         NUMBER;
    vrs_v_id            NUMBER;
    secure_attr_id      NUMBER;
    secure_v_id         NUMBER;
    bal_rule_attr_id    NUMBER;
    bal_rule_v_id       NUMBER;
    elim_attr_id        NUMBER;
    elim_v_id           NUMBER;
    cont_attr_id        NUMBER;
    cont_v_id           NUMBER;
    entity_type_attr_id NUMBER;
    entity_type_v_id    NUMBER;
    recon_leaf_attr_id  NUMBER;
    recon_leaf_v_id     NUMBER;

    user_id  NUMBER;
    login_id NUMBER;

    v_module     VARCHAR2(30);
    l_request_id NUMBER(15);
  BEGIN
    v_module := 'Load_Entities';
    module_log_write(v_module, g_module_enter);
    current_loc := 1;
    read_mode   := 0;

    SELECT xml_data
      INTO l_local_clob
      FROM gcs_xml_files xf
     WHERE xf.xml_file_id = p_file_id
       AND xf.xml_file_type = 'ENTITY_LOADER'
       AND xf.language = 'US';

    G_CHAN_FLG     := gcs_utility_pkg.get_dimension_required('CHANNEL_ID');
    G_CCTR_FLG     := gcs_utility_pkg.get_dimension_required('COMPANY_COST_CENTER_ORG_ID');
    G_CUST_FLG     := gcs_utility_pkg.get_dimension_required('CUSTOMER_ID');
    G_GEOG_FLG     := gcs_utility_pkg.get_dimension_required('GEOGRAPHY_ID');
    G_LN_ITEM_FLG  := gcs_utility_pkg.get_dimension_required('LINE_ITEM_ID');
    G_NAT_ACCT_FLG := gcs_utility_pkg.get_dimension_required('NATURAL_ACCOUNT_ID');
    G_PROD_FLG     := gcs_utility_pkg.get_dimension_required('PRODUCT_ID');
    G_PROJ_FLG     := gcs_utility_pkg.get_dimension_required('PROJECT_ID');
    G_USER1_FLG    := gcs_utility_pkg.get_dimension_required('USER_DIM1_ID');
    G_USER2_FLG    := gcs_utility_pkg.get_dimension_required('USER_DIM2_ID');
    G_USER3_FLG    := gcs_utility_pkg.get_dimension_required('USER_DIM3_ID');
    G_USER4_FLG    := gcs_utility_pkg.get_dimension_required('USER_DIM4_ID');
    G_USER5_FLG    := gcs_utility_pkg.get_dimension_required('USER_DIM5_ID');
    G_USER6_FLG    := gcs_utility_pkg.get_dimension_required('USER_DIM6_ID');
    G_USER7_FLG    := gcs_utility_pkg.get_dimension_required('USER_DIM7_ID');
    G_USER8_FLG    := gcs_utility_pkg.get_dimension_required('USER_DIM8_ID');
    G_USER9_FLG    := gcs_utility_pkg.get_dimension_required('USER_DIM9_ID');
    G_USER10_FLG   := gcs_utility_pkg.get_dimension_required('USER_DIM10_ID');

    base_org_attr_id    := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-BASE_ORGANIZATION')
                          .attribute_id;
    base_org_v_id       := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-BASE_ORGANIZATION')
                          .version_id;
    contact_attr_id     := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-ENTITY_CONTACT')
                          .attribute_id;
    contact_v_id        := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-ENTITY_CONTACT')
                          .version_id;
    logo_attr_id        := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-IMAGE_NAME')
                          .attribute_id;
    logo_v_id           := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-IMAGE_NAME')
                          .version_id;
    src_sys_attr_id     := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-SOURCE_SYSTEM_CODE')
                          .attribute_id;
    src_sys_v_id        := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-SOURCE_SYSTEM_CODE')
                          .version_id;
    ledger_attr_id      := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-LEDGER_ID')
                          .attribute_id;
    ledger_v_id         := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-LEDGER_ID')
                          .version_id;
    trs_attr_id         := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-TRANSFORM_RULE_SET_ID')
                          .attribute_id;
    trs_v_id            := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-TRANSFORM_RULE_SET_ID')
                          .version_id;
    vrs_attr_id         := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-VALIDATION_RULE_SET_ID')
                          .attribute_id;
    vrs_v_id            := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-VALIDATION_RULE_SET_ID')
                          .version_id;
    secure_attr_id      := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-SECURITY_ENABLED_FLAG')
                          .attribute_id;
    secure_v_id         := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-SECURITY_ENABLED_FLAG')
                          .version_id;
    bal_rule_attr_id    := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-BALANCES_RULE_ID')
                          .attribute_id;
    bal_rule_v_id       := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-BALANCES_RULE_ID')
                          .version_id;
    elim_attr_id        := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY')
                          .attribute_id;
    elim_v_id           := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY')
                          .version_id;
    cont_attr_id        := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY')
                          .attribute_id;
    cont_v_id           := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-OPERATING_ENTITY')
                          .version_id;
    entity_type_attr_id := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE')
                          .attribute_id;
    entity_type_v_id    := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE')
                          .version_id;
    recon_leaf_attr_id  := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-RECON_LEAF_NODE_FLAG')
                          .attribute_id;
    recon_leaf_v_id     := GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-RECON_LEAF_NODE_FLAG')
                          .version_id;

    user_id  := FND_GLOBAL.user_id;
    login_id := FND_GLOBAL.login_id;

    clob_length := DBMS_LOB.GETLENGTH(l_local_clob);

    WHILE (current_loc < clob_length) LOOP
      get_next_token(l_local_clob, current_loc, info_buffer);

      -- Switch reading modes if applicable
      IF info_buffer = 'EXT' THEN
        read_mode := 1;
      ELSIF info_buffer = 'OGL' THEN
        read_mode := 2;
      ELSIF info_buffer = 'CONS' THEN
        read_mode := 3;
      ELSE
        -- Now we get to the meat of the loading logic

        new_entity_id := to_number(info_buffer);
        get_next_token(l_local_clob, current_loc, entity_name);
        get_next_token(l_local_clob, current_loc, entity_desc);

        -- Insert the base entity row first
        INSERT INTO fem_entities_vl
          (entity_id,
           entity_display_code,
           entity_name,
           description,
           value_set_id,
           enabled_flag,
           read_only_flag,
           personal_flag,
           object_version_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login)
        VALUES
          (new_entity_id,
           to_char(new_entity_id),
           entity_name,
           entity_desc,
           18,
           'Y',
           'N',
           'N',
           1,
           sysdate,
           user_id,
           sysdate,
           user_id,
           login_id);

        -- operating entity
        IF read_mode IN (1, 2) THEN
          get_next_token(l_local_clob, current_loc, info_buffer);
          entity_nComps := to_number(info_buffer);
          FOR counter IN 1 .. entity_nComps LOOP
            get_next_token(l_local_clob, current_loc, info_buffer);
            entity_comp_id := to_number(info_buffer);

            -- Insert a single company assignment row
            INSERT INTO gcs_entity_organizations
              (entity_id,
               company_cost_center_org_id,
               object_version_number,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login)
            VALUES
              (new_entity_id,
               entity_comp_id,
               1,
               sysdate,
               user_id,
               sysdate,
               user_id,
               login_id);
          END LOOP;

          -- Also populate the flattened table
          add_to_summary_table(p_entity_id => new_entity_id);

          -- Get and insert the base org information
          get_next_token(l_local_clob, current_loc, info_buffer);
          entity_base_org_id := to_number(info_buffer);

          INSERT INTO fem_entities_attr
            (attribute_id,
             version_id,
             entity_id,
             value_set_id,
             aw_snapshot_flag,
             dim_attribute_numeric_member,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (base_org_attr_id,
             base_org_v_id,
             new_entity_id,
             18,
             'N',
             entity_base_org_id,
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);

          entity_type_code := 'O';
        ELSE
          entity_type_code := 'C';
        END IF;

        -- Insert the entity type information
        INSERT INTO fem_entities_attr
          (attribute_id,
           version_id,
           entity_id,
           value_set_id,
           aw_snapshot_flag,
           dim_attribute_varchar_member,
           object_version_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login)
        VALUES
          (entity_type_attr_id,
           entity_type_v_id,
           new_entity_id,
           18,
           'N',
           entity_type_code,
           1,
           sysdate,
           user_id,
           sysdate,
           user_id,
           login_id);

        -- Get and insert the contact information
        get_next_token(l_local_clob, current_loc, entity_contact);

        INSERT INTO fem_entities_attr
          (attribute_id,
           version_id,
           entity_id,
           value_set_id,
           aw_snapshot_flag,
           varchar_assign_value,
           object_version_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login)
        VALUES
          (contact_attr_id,
           contact_v_id,
           new_entity_id,
           18,
           'N',
           entity_contact,
           1,
           sysdate,
           user_id,
           sysdate,
           user_id,
           login_id);

        -- Get and insert the logo information if provided
        get_next_token(l_local_clob, current_loc, entity_logo);

        IF trim(entity_logo) IS NOT NULL THEN
          INSERT INTO fem_entities_attr
            (attribute_id,
             version_id,
             entity_id,
             value_set_id,
             aw_snapshot_flag,
             varchar_assign_value,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (logo_attr_id,
             logo_v_id,
             new_entity_id,
             18,
             'N',
             entity_logo,
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);
        END IF;

        IF read_mode = 1 THEN
          -- external operating entity
          get_next_token(l_local_clob, current_loc, info_buffer);
          entity_src_sys := to_number(info_buffer);

          get_next_token(l_local_clob, current_loc, info_buffer);
          entity_vs_combo_id := to_number(info_buffer);

          get_next_token(l_local_clob, current_loc, info_buffer);
          entity_cal_hier_id := to_number(info_buffer);

          get_next_token(l_local_clob, current_loc, entity_def_ccy);

          entity_ledger_id := create_ext_ledger(entity_src_sys,
                                                entity_vs_combo_id,
                                                entity_cal_hier_id,
                                                entity_def_ccy,
                                                entity_name,
                                                entity_desc);

          -- Now create a ledger based on the info, and get back the ledger_id
          INSERT INTO fem_entities_attr
            (attribute_id,
             version_id,
             entity_id,
             value_set_id,
             aw_snapshot_flag,
             dim_attribute_numeric_member,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (ledger_attr_id,
             ledger_v_id,
             new_entity_id,
             18,
             'N',
             entity_ledger_id,
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);

          -- Get the Transform Rule Set and set the attribute if applicable
          get_next_token(l_local_clob, current_loc, info_buffer);
          entity_trs_obj_id := to_number(info_buffer);

          IF entity_trs_obj_id IS NOT NULL THEN
            INSERT INTO fem_entities_attr
              (attribute_id,
               version_id,
               entity_id,
               value_set_id,
               aw_snapshot_flag,
               dim_attribute_numeric_member,
               object_version_number,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login)
            VALUES
              (trs_attr_id,
               trs_v_id,
               new_entity_id,
               18,
               'N',
               entity_trs_obj_id,
               1,
               sysdate,
               user_id,
               sysdate,
               user_id,
               login_id);
          END IF;

          -- Get the Validation Rule Set and set the attribute if applicable
          get_next_token(l_local_clob, current_loc, info_buffer);
          entity_vrs_obj_id := to_number(info_buffer);

          IF entity_vrs_obj_id IS NOT NULL THEN
            INSERT INTO fem_entities_attr
              (attribute_id,
               version_id,
               entity_id,
               value_set_id,
               aw_snapshot_flag,
               dim_attribute_numeric_member,
               object_version_number,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login)
            VALUES
              (vrs_attr_id,
               vrs_v_id,
               new_entity_id,
               18,
               'N',
               entity_vrs_obj_id,
               1,
               sysdate,
               user_id,
               sysdate,
               user_id,
               login_id);
          END IF;

        ELSIF read_mode = 2 THEN
          -- ogl operating entity
          entity_src_sys := 10;

          -- Get the Ledger and set the attribute
          get_next_token(l_local_clob, current_loc, info_buffer);
          entity_ledger_id := to_number(info_buffer);

          INSERT INTO fem_entities_attr
            (attribute_id,
             version_id,
             entity_id,
             value_set_id,
             aw_snapshot_flag,
             dim_attribute_numeric_member,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (ledger_attr_id,
             ledger_v_id,
             new_entity_id,
             18,
             'N',
             entity_ledger_id,
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);

          -- Get the Balances Rule and set the attribute
          get_next_token(l_local_clob, current_loc, info_buffer);
          entity_bal_rule_id := to_number(info_buffer);

          INSERT INTO fem_entities_attr
            (attribute_id,
             version_id,
             entity_id,
             value_set_id,
             aw_snapshot_flag,
             dim_attribute_numeric_member,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (bal_rule_attr_id,
             bal_rule_v_id,
             new_entity_id,
             18,
             'N',
             entity_bal_rule_id,
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);

        ELSIF read_mode = 3 THEN
          -- consolidation entity
          entity_src_sys := 70;

          -- Get the Elimination Entity name and create all necessary rows
          get_next_token(l_local_clob, current_loc, entity_elim_name);

          SELECT FND_FLEX_VALUES_S.nextval INTO elim_entity_id FROM dual;

          INSERT INTO fem_entities_attr
            (attribute_id,
             version_id,
             entity_id,
             value_set_id,
             aw_snapshot_flag,
             dim_attribute_numeric_member,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (elim_attr_id,
             elim_v_id,
             new_entity_id,
             18,
             'N',
             elim_entity_id,
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);

          INSERT INTO fem_entities_vl
            (entity_id,
             entity_display_code,
             entity_name,
             description,
             value_set_id,
             enabled_flag,
             read_only_flag,
             personal_flag,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (elim_entity_id,
             to_char(elim_entity_id),
             entity_elim_name,
             entity_elim_name,
             18,
             'Y',
             'N',
             'N',
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);

          INSERT INTO fem_entities_attr
            (attribute_id,
             version_id,
             entity_id,
             value_set_id,
             aw_snapshot_flag,
             dim_attribute_varchar_member,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (entity_type_attr_id,
             entity_type_v_id,
             elim_entity_id,
             18,
             'N',
             'E',
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);

          INSERT INTO fem_entities_attr
            (attribute_id,
             version_id,
             entity_id,
             value_set_id,
             aw_snapshot_flag,
             dim_attribute_numeric_member,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (src_sys_attr_id,
             src_sys_v_id,
             elim_entity_id,
             18,
             'N',
             70,
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);

          INSERT INTO fem_entities_attr
            (attribute_id,
             version_id,
             entity_id,
             value_set_id,
             aw_snapshot_flag,
             varchar_assign_value,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (contact_attr_id,
             contact_v_id,
             elim_entity_id,
             18,
             'N',
             entity_contact,
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);

          IF trim(entity_logo) IS NOT NULL THEN
            INSERT INTO fem_entities_attr
              (attribute_id,
               version_id,
               entity_id,
               value_set_id,
               aw_snapshot_flag,
               varchar_assign_value,
               object_version_number,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login)
            VALUES
              (logo_attr_id,
               logo_v_id,
               elim_entity_id,
               18,
               'N',
               entity_logo,
               1,
               sysdate,
               user_id,
               sysdate,
               user_id,
               login_id);
          END IF;

          INSERT INTO fem_entities_attr
            (attribute_id,
             version_id,
             entity_id,
             value_set_id,
             aw_snapshot_flag,
             dim_attribute_varchar_member,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (recon_leaf_attr_id,
             recon_leaf_v_id,
             elim_entity_id,
             18,
             'N',
             'N',
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);

          -- Get the Controlling Entity and set the attribute if applicable
          get_next_token(l_local_clob, current_loc, info_buffer);
          entity_cont_id := to_number(info_buffer);

          IF entity_cont_id IS NOT NULL THEN
            INSERT INTO fem_entities_attr
              (attribute_id,
               version_id,
               entity_id,
               value_set_id,
               aw_snapshot_flag,
               dim_attribute_numeric_member,
               object_version_number,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login)
            VALUES
              (cont_attr_id,
               cont_v_id,
               new_entity_id,
               18,
               'N',
               entity_cont_id,
               1,
               sysdate,
               user_id,
               sysdate,
               user_id,
               login_id);
          END IF;

        END IF;

        -- Insert the source system information
        INSERT INTO fem_entities_attr
          (attribute_id,
           version_id,
           entity_id,
           value_set_id,
           aw_snapshot_flag,
           dim_attribute_numeric_member,
           object_version_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login)
        VALUES
          (src_sys_attr_id,
           src_sys_v_id,
           new_entity_id,
           18,
           'N',
           entity_src_sys,
           1,
           sysdate,
           user_id,
           sysdate,
           user_id,
           login_id);

        -- Get and insert the security information
        get_next_token(l_local_clob, current_loc, entity_sec_by_role);

        INSERT INTO fem_entities_attr
          (attribute_id,
           version_id,
           entity_id,
           value_set_id,
           aw_snapshot_flag,
           dim_attribute_varchar_member,
           object_version_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login)
        VALUES
          (secure_attr_id,
           secure_v_id,
           new_entity_id,
           18,
           'N',
           entity_sec_by_role,
           1,
           sysdate,
           user_id,
           sysdate,
           user_id,
           login_id);

        IF read_mode = 3 THEN
          -- consolidation entity
          INSERT INTO fem_entities_attr
            (attribute_id,
             version_id,
             entity_id,
             value_set_id,
             aw_snapshot_flag,
             dim_attribute_varchar_member,
             object_version_number,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
            (secure_attr_id,
             secure_v_id,
             elim_entity_id,
             18,
             'N',
             entity_sec_by_role,
             1,
             sysdate,
             user_id,
             sysdate,
             user_id,
             login_id);
        END IF;

        IF entity_sec_by_role = 'Y' THEN
          get_next_token(l_local_clob, current_loc, info_buffer);
          entity_nRoles := to_number(info_buffer);
          FOR counter IN 1 .. entity_nRoles LOOP
            get_next_token(l_local_clob, current_loc, entity_role_name);

            -- Insert a single role assignment here
            INSERT INTO gcs_role_entity_relns
              (role_name,
               orig_system,
               orig_system_id,
               partition_id,
               entity_id,
               object_version_number,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login)
              SELECT wlr.name,
                     wlr.orig_system,
                     wlr.orig_system_id,
                     wlr.partition_id,
                     load_entities.new_entity_id,
                     1,
                     sysdate,
                     user_id,
                     sysdate,
                     user_id,
                     login_id
                FROM wf_local_roles wlr
               WHERE wlr.name = entity_role_name;

            IF read_mode = 3 THEN
              -- consolidation entity
              INSERT INTO gcs_role_entity_relns
                (role_name,
                 orig_system,
                 orig_system_id,
                 partition_id,
                 entity_id,
                 object_version_number,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login)
                SELECT wlr.name,
                       wlr.orig_system,
                       wlr.orig_system_id,
                       wlr.partition_id,
                       load_entities.elim_entity_id,
                       1,
                       sysdate,
                       user_id,
                       sysdate,
                       user_id,
                       login_id
                  FROM wf_local_roles wlr
                 WHERE wlr.name = entity_role_name;
            END IF;
          END LOOP;
        END IF;

        -- Insert the recon_leaf_node_flag information
        INSERT INTO fem_entities_attr
          (attribute_id,
           version_id,
           entity_id,
           value_set_id,
           aw_snapshot_flag,
           dim_attribute_varchar_member,
           object_version_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login)
        VALUES
          (recon_leaf_attr_id,
           recon_leaf_v_id,
           new_entity_id,
           18,
           'N',
           'N',
           1,
           sysdate,
           user_id,
           sysdate,
           user_id,
           login_id);

        /***** Logic to insert the ACTUAL/ADB rows into GCS_ENTITIES_ATTR
        for all operating entities********/
        --Start - Code inserted by Santosh Matam Dated 16-jan-2006
        IF read_mode IN (1, 2) THEN
          --Insert one row for Actuals
          INSERT INTO gcs_entities_attr
            (entity_id,
             data_type_code,
             ledger_id,
             source_system_code,
             balances_rule_id,
             transform_rule_set_id,
             validation_rule_set_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             object_version_number,
             -- Bug fix : 5843592
             effective_start_date)
            (SELECT feb.entity_id,
                    'ACTUAL',
                    fea_ledger.dim_attribute_numeric_member ledger_id,
                    fea_src.dim_attribute_numeric_member source_system_code,
                    fea_bal_rule.dim_attribute_numeric_member balances_rule_id,
                    --Bugfix 5087900
                    trs.rule_set_id transform_rule_set_id,
                    vrs.rule_set_id validation_rule_set_id,
                    sysdate,
                    user_id,
                    sysdate,
                    user_id,
                    login_id,
                    1,
                    -- Bug fix : 5843592
                    to_date('01-01-1900','dd-MM-yyyy')
               FROM fem_entities_b    feb,
                    fem_entities_attr fea_src,
                    fem_entities_attr fea_ledger,
                    fem_entities_attr fea_bal_rule,
                    fem_entities_attr fea_trs,
                    fem_entities_attr fea_vrs,
                    gcs_lex_map_rule_sets trs,
                    gcs_lex_map_rule_sets vrs
              WHERE fea_ledger.entity_id = feb.entity_id
                AND fea_ledger.attribute_id = ledger_attr_id
                AND fea_ledger.version_id = ledger_v_id
                AND fea_bal_rule.entity_id(+) = feb.entity_id
                AND fea_bal_rule.attribute_id(+) = bal_rule_attr_id
                AND fea_bal_rule.version_id(+) = bal_rule_v_id
                AND fea_trs.entity_id(+) = feb.entity_id
                AND fea_trs.attribute_id(+) = trs_attr_id
                AND fea_trs.version_id(+) = trs_v_id
                AND fea_vrs.entity_id(+) = feb.entity_id
                AND fea_vrs.attribute_id(+) = vrs_attr_id
                AND fea_vrs.version_id(+) = vrs_v_id
                AND fea_src.entity_id = feb.entity_id
                AND fea_src.attribute_id = src_sys_attr_id
                AND fea_src.version_id = src_sys_v_id
                AND trs.associated_object_id(+) = fea_trs.dim_attribute_numeric_member
                AND vrs.associated_object_id(+) = fea_vrs.dim_attribute_numeric_member
                AND feb.entity_id = new_entity_id);

          --Insert one row for ADB
          INSERT INTO gcs_entities_attr
            (entity_id,
             data_type_code,
             ledger_id,
             source_system_code,
             balances_rule_id,
             transform_rule_set_id,
             validation_rule_set_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             object_version_number,
             -- Bug fix : 5843592
             effective_start_date)
            (SELECT feb.entity_id,
                    'ADB',
                    fea_ledger.dim_attribute_numeric_member ledger_id,
                    fea_src.dim_attribute_numeric_member source_system_code,
                    fea_bal_rule.dim_attribute_numeric_member balances_rule_id,
                    --Bugfix 5087900
                    trs.rule_set_id transform_rule_set_id,
                    vrs.rule_set_id validation_rule_set_id,
                    sysdate,
                    user_id,
                    sysdate,
                    user_id,
                    login_id,
                    1,
                    -- Bug fix : 5843592
                    to_date('01-01-1900','dd-MM-yyyy')
               FROM fem_entities_b    feb,
                    fem_entities_attr fea_src,
                    fem_entities_attr fea_ledger,
                    fem_entities_attr fea_bal_rule,
                    fem_entities_attr fea_trs,
                    fem_entities_attr fea_vrs,
                    gcs_lex_map_rule_sets trs,
                    gcs_lex_map_rule_sets vrs
              WHERE fea_ledger.entity_id = feb.entity_id
                AND fea_ledger.attribute_id = ledger_attr_id
                AND fea_ledger.version_id = ledger_v_id
                AND fea_bal_rule.entity_id(+) = feb.entity_id
                AND fea_bal_rule.attribute_id(+) = bal_rule_attr_id
                AND fea_bal_rule.version_id(+) = bal_rule_v_id
                AND fea_trs.entity_id(+) = feb.entity_id
                AND fea_trs.attribute_id(+) = trs_attr_id
                AND fea_trs.version_id(+) = trs_v_id
                AND fea_vrs.entity_id(+) = feb.entity_id
                AND fea_vrs.attribute_id(+) = vrs_attr_id
                AND fea_vrs.version_id(+) = vrs_v_id
                AND fea_src.entity_id = feb.entity_id
                AND fea_src.attribute_id = src_sys_attr_id
                AND fea_src.version_id = src_sys_v_id
                AND trs.associated_object_id(+) = fea_trs.dim_attribute_numeric_member
                AND vrs.associated_object_id(+) = fea_vrs.dim_attribute_numeric_member
                AND feb.entity_id = new_entity_id);

        END IF;
        --End - Code inserted by Santosh Matam Dated 16-jan-2006
      END IF;

    END LOOP;

    COMMIT;

    -- Refresh Entity Value Set for FCH-ICM Integration
    l_request_id := fnd_request.submit_request(application => 'GCS',
                                               program     => 'FCH_ICM_ENTITY_VS_MAINTAIN',
                                               sub_request => FALSE);

    module_log_write(v_module, g_module_success);

  END Load_Entities;

  --
  -- GCS_ENTITY_CCTR_ORGS update
  --

  PROCEDURE Update_Entity_Orgs(x_errbuf  OUT NOCOPY VARCHAR2,
                               x_retcode OUT NOCOPY VARCHAR2) IS
    v_module VARCHAR2(30);
  BEGIN
    v_module := 'Update_Entity_Orgs';
    module_log_write(v_module, g_module_enter);

    --Added by Santosh - 5235164
    DELETE gcs_entity_cctr_orgs;

    INSERT INTO gcs_entity_cctr_orgs
      (entity_id,
       company_cost_center_org_id,
       object_version_number,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login)
      SELECT eo.entity_id,
             coa.company_cost_center_org_id,
             1,
             sysdate,
             eo.created_by,
             sysdate,
             eo.last_updated_by,
             eo.last_update_login
        FROM gcs_entity_organizations eo,
             fem_cctr_orgs_attr       coa,
             fem_dim_attributes_b     fdab,
             fem_dim_attr_versions_b  fdavb
       WHERE coa.dim_attribute_numeric_member =
             eo.company_cost_center_org_id
         AND coa.attribute_id = fdab.attribute_id
         AND coa.version_id = fdavb.version_id
         AND fdab.attribute_varchar_label = 'COMPANY'
         AND fdavb.attribute_id = fdab.attribute_id
         AND fdavb.default_version_flag = 'Y';

    module_log_write(v_module, g_module_success);
  END Update_Entity_Orgs;

END GCS_ENTITIES_PKG;

/
