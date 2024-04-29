--------------------------------------------------------
--  DDL for Package Body GCS_ICM_INTG_PROF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_ICM_INTG_PROF_PKG" AS
/* $Header: gcsicmpb.pls 120.0 2005/09/30 23:13:05 mikeward noship $ */

  new_line VARCHAR2(4) := '
';
  g_api VARCHAR2(80) := 'gcs.plsql.GCS_ICM_INTG_PROF_PKG';


  --
  -- Private Procedures
  --

  PROCEDURE set_single_option_value
            (p_option_name    VARCHAR2,
             p_option_value   VARCHAR2,
             p_force_update   VARCHAR2)
  IS
    l_profile_option_id  NUMBER;
    l_application_id     NUMBER;
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.set_single_option_value.begin',
                     '<<Enter>>');
    END IF;

    SELECT application_id,
           profile_option_id
    INTO l_application_id,
         l_profile_option_id
    FROM fnd_profile_options
    WHERE profile_option_name = p_option_name;

    MERGE INTO fnd_profile_option_values pov
    USING (SELECT 1 FROM DUAL) src
    ON (pov.application_id = l_application_id AND
        pov.profile_option_id = l_profile_option_id AND
        pov.level_id = 10001)
    WHEN MATCHED THEN
      UPDATE SET profile_option_value = decode(profile_option_value,
                                               NULL, p_option_value,
                                               decode(p_force_update,
                                                      'Y', p_option_value,
                                                      profile_option_value)),
                 last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
                 last_update_login = fnd_global.login_id
    WHEN NOT MATCHED THEN
      INSERT(
        application_id,
        profile_option_id,
        level_id,
        level_value,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        profile_option_value)
      VALUES(
        l_application_id,
        l_profile_option_id,
        10001,
        0,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
        p_option_value);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.set_single_option_value.end',
                     '<<Exit>>');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.set_single_option_value.error',
                       SQLERRM);
      END IF;

      RAISE;
  END set_single_option_value;


  --
  -- Public Procedures
  --

  PROCEDURE set_profile_option_values
            (x_errbuf    OUT NOCOPY VARCHAR2,
             x_retcode   OUT NOCOPY VARCHAR2)
  IS
    l_vs_id       VARCHAR2(100);
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.set_profile_option_values.begin',
                     '<<Enter>>');
    END IF;

    SELECT to_char(flex_value_set_id)
    INTO l_vs_id
    FROM fnd_flex_value_sets
    WHERE flex_value_set_name = 'FCH_ICM_ENTITY_VALUE_SET';

    set_single_option_value('AMW_FIN_IMPORT_FROM_FSG', 'N', 'Y');
    set_single_option_value('AMW_SUBSIDIARY_AUDIT_UNIT', l_vs_id, 'N');

    set_single_option_value('AMW_STMNT_SOURCE_VIEW', 'GCS_FIN_STMTS_V', 'N');
    set_single_option_value('AMW_STMNT_SOURCE_TL_VIEW', 'GCS_FIN_STMT_DTLS_V', 'N');
    set_single_option_value('AMW_FINITEM_SOURCE_VIEW', 'GCS_FINANCIAL_ITEMS_HIER_V', 'N');
    set_single_option_value('AMW_FINITEM_SOURCE_TL_VIEW', 'GCS_FINANCIAL_ITEMS_V', 'N');
    set_single_option_value('AMW_FIN_ITEM_ACC_RELATIONS_VIEW', 'GCS_ITEMS_TO_NAT_ACCTS_V', 'N');
    set_single_option_value('AMW_ACCOUNT_SOURCE_VIEW', 'GCS_NAT_ACCTS_HIER_V', 'N');
    set_single_option_value('AMW_ACCOUNT_NAMES_VIEW', 'GCS_NAT_ACCTS_V', 'N');

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.set_profile_option_values.end',
                     '<<Exit>>');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.set_profile_option_values.error',
                       SQLERRM);
      END IF;

      x_errbuf := SQLERRM;
      x_retcode := '2';
  END set_profile_option_values;


  PROCEDURE launch_key_account_import
  IS
    l_request_id NUMBER;

    CURSOR amw_value_set_c IS
    SELECT flex_value_set_name
    FROM fnd_flex_value_sets ffv
    WHERE ffv.flex_value_set_id = to_number(fnd_profile.value('AMW_SUBSIDIARY_AUDIT_UNIT'));

    l_vs_name    VARCHAR2(100);
  BEGIN
    OPEN amw_value_set_c;
    FETCH amw_value_set_c INTO l_vs_name;
    CLOSE amw_value_set_c;

    IF l_vs_name = 'FCH_ICM_ENTITY_VALUE_SET' THEN
      l_request_id := fnd_request.submit_request
                        (application => 'AMW',
                         program => 'AMWACCTIMP',
                         sub_request => FALSE);
    END IF;
  END launch_key_account_import;


  PROCEDURE launch_fin_stmt_import
  IS
    l_request_id NUMBER;

    l_run_id     NUMBER;
  BEGIN
    EXECUTE IMMEDIATE
      'SELECT amw_fin_stmnt_selection_s.nextval ' ||
      'FROM DUAL'
    INTO l_run_id;

    EXECUTE IMMEDIATE
      'INSERT INTO amw_fin_stmnt_selection ' ||
      '(run_id, ' ||
      ' financial_statement_id, ' ||
      ' creation_date, ' ||
      ' created_by, ' ||
      ' last_update_date, ' ||
      ' last_updated_by, ' ||
      ' last_update_login, ' ||
      ' security_group_id, ' ||
      ' object_version_number) ' ||
      'SELECT :1, ' ||
      '       hierarchy_id, ' ||
      '       sysdate, ' ||
      '       fnd_global.user_id, ' ||
      '       sysdate, ' ||
      '       fnd_global.user_id, ' ||
      '       fnd_global.login_id, ' ||
      '       null, ' ||
      '       1 ' ||
      'FROM gcs_hierarchies_b ' ||
      'WHERE certification_flag = ''Y'''
    USING l_run_id;

    commit;

    l_request_id := fnd_request.submit_request
                      (application => 'AMW',
                       program => 'AMWFSTMTIMP',
                       sub_request => FALSE,
                       argument1 => to_char(l_run_id));

  EXCEPTION
    WHEN OTHERS THEN
      null;
  END launch_fin_stmt_import;

END GCS_ICM_INTG_PROF_PKG;

/
