--------------------------------------------------------
--  DDL for Package Body GCS_WF_NTF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_WF_NTF_PKG" AS
/* $Header: gcswfntfb.pls 120.8 2006/09/12 05:19:04 hakumar noship $ */

--
-- PRIVATE GLOBAL VARIABLES
--

   -- The API name
   g_pkg_name     CONSTANT VARCHAR2 (30)                   := 'gcs.plsql.GCS_WF_NTF_PKG';
   -- A newline character. Included for convenience when writing long strings.
   g_nl                    VARCHAR2 (1)                               := '
';

--
-- PUBLIC PROCEDURES
--

  PROCEDURE raise_status_notification (       p_cons_detail_id              IN NUMBER)
  IS
      l_api_name              VARCHAR2(80) := 'raise_status_notification';
      l_event_key			        VARCHAR2(200);
      l_entity_name			      VARCHAR2(200);
      l_counter_entity_name		VARCHAR2(200);
      l_counter_entity_id	    NUMBER;
      l_cons_entity_name	    VARCHAR2(200);
      l_cons_entity_id		    NUMBER;
      l_hierarchy_name	      VARCHAR2(200);
      l_run_name			        VARCHAR2(200);
      l_entry_id              NUMBER(15);
      l_balance_type          VARCHAR2(200);
      l_date                  VARCHAR2(200);
      l_wf_region             VARCHAR2(200);
      l_attachment            VARCHAR2(200);
      l_subject               VARCHAR2(200);
      l_impacted_flag         VARCHAR2(1);
      l_category_code         VARCHAR2(30);
      l_status                VARCHAR2(200);
      l_recipient             VARCHAR2(1000);
      l_counter_recipient     VARCHAR2(1000);
      l_adhoc_role            VARCHAR2(40);
      l_adhoc_role_disp       VARCHAR2(40);
      l_adhoc_users           VARCHAR2(2001);
      l_entity_contact_attr   NUMBER(15);
      l_entity_contact_ver    NUMBER;
      l_oper_entity_attr      NUMBER(15);
      l_oper_entity_ver       NUMBER;
      -- Bug fix 5245250
      l_seq                   NUMBER;
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' ENTER :'
                         || ' p_cons_detail_id = ' || p_cons_detail_id);
  FND_FILE.NEW_LINE(FND_FILE.LOG);

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' p_cons_detail_id = '
                         || p_cons_detail_id
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
  END IF;

  l_entity_contact_attr := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_CONTACT').attribute_id;
  l_entity_contact_ver := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_CONTACT').version_id;

  -- bug fix 5109610: change joins of fnd_lookup_values to gcs_data_types_b/tl for balance_type_code
  SELECT fet_cons.entity_name,
        fet_cons.entity_id,
        fet_child.entity_name,
        fet_counter.entity_name,
        fet_counter.entity_id,
        gcerd.run_name,
        gcerd.entry_id,
        gdtct.data_type_name,
        fcpt.cal_period_name,
        ght.hierarchy_name,
        gcerd.request_error_code,
        gcerd.category_code,
        --nvl(fea_cons.varchar_assign_value, fea_child.varchar_assign_value) contact
        fea_child.varchar_assign_value,
        -- Bug fix 5245250
        fnd_flex_values_s.NEXTVAL
   INTO l_cons_entity_name,
        l_cons_entity_id,
        l_entity_name,
        l_counter_entity_name,
        l_counter_entity_id,
        l_run_name,
        l_entry_id,
        l_balance_type,
        l_date,
        l_hierarchy_name,
        l_status,
        l_category_code,
        l_recipient,
        -- Bug fix 5245250
        l_seq
   FROM gcs_cons_eng_run_dtls gcerd,
        fem_entities_tl fet_cons,
        fem_entities_tl fet_child,
        fem_entities_tl fet_counter,
        gcs_hierarchies_tl ght,
        gcs_cons_eng_runs gcer,
        gcs_data_type_codes_b gdtcb,
        gcs_data_type_codes_tl gdtct,
        fem_cal_periods_tl fcpt,
        --fem_entities_attr fea_cons,
        fem_entities_attr fea_child
  WHERE gcerd.run_detail_id = p_cons_detail_id
    AND gcerd.consolidation_entity_id = fet_cons.entity_id
    AND gcerd.child_entity_id = fet_child.entity_id (+)
    AND gcerd.contra_child_entity_id = fet_counter.entity_id (+)
    AND gcerd.run_name = gcer.run_name
    AND gcerd.consolidation_entity_id = gcer.run_entity_id
    AND gcer.hierarchy_id = ght.hierarchy_id
    AND ght.language = userenv('LANG')
    AND fet_cons.language = userenv('LANG')
    AND fet_child.language (+)= userenv('LANG')
    AND fet_counter.language (+) = userenv('LANG')
    AND gcer.balance_type_code = gdtcb.data_type_code
    AND gdtcb.data_type_id = gdtct.data_type_id
    AND gdtct.language = userenv('LANG')
    AND gcer.cal_period_id = fcpt.cal_period_id
    AND fcpt.language = userenv('LANG')
    --AND fea_cons.entity_id = fet_cons.entity_id
    AND fea_child.entity_id (+)= fet_child.entity_id
    --AND fea_cons.attribute_id = l_entity_contact_attr
    --AND fea_cons.version_id = l_entity_contact_ver
    AND fea_child.attribute_id (+)= l_entity_contact_attr
    AND fea_child.version_id (+)= l_entity_contact_ver;
  -- end of bug fix 5109610

  -- Bug fix 5245250
  --l_event_key := substr(nvl(l_entity_name, l_cons_entity_name), 1, 150) || ' ' || p_cons_detail_id;
  l_event_key := 'Consolidation Status Notification: ' || l_seq;

  FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' status is ' || l_status
                         || ' category is ' || l_category_code);
  FND_FILE.NEW_LINE(FND_FILE.LOG);

  -- consolidation successfully completed
  IF ((l_status = 'COMPLETED' OR l_status = 'WARNING') AND l_category_code = 'AGGREGATION') THEN
        FND_MESSAGE.SET_NAME ('GCS', 'GCS_WF_COMPLETE_TITLE');
        FND_MESSAGE.set_token('ENTITY_NAME', l_cons_entity_name);
        FND_MESSAGE.set_token('DATE_TOKEN', l_date);
        l_subject := FND_MESSAGE.GET;
  -- suspense violation
  ELSIF (l_status = 'WARNING') THEN
        IF (l_category_code = 'DATAPREPARATION') THEN
            FND_MESSAGE.SET_NAME ('GCS', 'GCS_WF_DP_TITLE');
            FND_MESSAGE.set_token('ENTITY_1', l_entity_name);
        ELSIF (l_category_code = 'INTERCOMPANY' or l_category_code = 'INTRACOMPANY') THEN
            FND_MESSAGE.SET_NAME ('GCS', 'GCS_WF_INTER_TITLE');
            FND_MESSAGE.set_token('ENTITY_1', l_entity_name);
            FND_MESSAGE.set_token('ENTITY_2', l_counter_entity_name);
            IF ((l_category_code = 'INTERCOMPANY' OR l_category_code = 'INTRACOMPANY') AND l_counter_entity_id IS NOT NULL) THEN
            BEGIN
                -- Get contact for counter entity
                SELECT  fea_counter.varchar_assign_value
                  INTO  l_counter_recipient
                  FROM  fem_entities_attr fea_counter
                  WHERE fea_counter.entity_id = l_counter_entity_id
                  AND   fea_counter.attribute_id = l_entity_contact_attr
                  AND   fea_counter.version_id = l_entity_contact_ver;
                -- Create ad-hoc role
                IF (l_counter_recipient IS NOT NULL and l_recipient <> l_counter_recipient) THEN
                   l_adhoc_role := l_category_code||'_SUSPENSE_'||p_cons_detail_id;
                   l_adhoc_role_disp := l_category_code||'_SUSPENSE_'||p_cons_detail_id;
                   l_adhoc_users := l_recipient||','||l_counter_recipient;
                   WF_DIRECTORY.CreateAdHocRole( role_name               => l_adhoc_role,
                                                 role_display_name       => l_adhoc_role_disp,
                                                 role_users              => l_adhoc_users);
                   -- Make this ad-hoc role to be recipient
                   l_recipient := l_adhoc_role;
                END IF;
                EXCEPTION WHEN OTHERS THEN NULL;
            END;
            END IF;
        ELSE
            FND_MESSAGE.SET_NAME ('GCS', 'GCS_WF_ELIM_TITLE');
            FND_MESSAGE.set_token('ENTITY_1', l_entity_name);
        END IF;
        FND_MESSAGE.set_token('DATE_TOKEN', l_date);
        l_subject := FND_MESSAGE.GET;

        l_wf_region := 'JSP:/OA_HTML/OA.jsp?OAFunc=FCH_WF_EMBEDDED_RG'||'&'||'RUNNAME='||l_run_name||'&'||'CONS_ENTITY_ID='||l_cons_entity_id||'&'||'CATEGORY='||l_category_code||'&'||'RUN_DETAIL_ID='||p_cons_detail_id;
        l_attachment := 'FND:entity=GCS_ENTRY_HEADERS'||'&'||'pk1name=ENTRY_ID'||'&'||'pk1value='||l_entry_id;
  -- error
  ELSE
        FND_MESSAGE.SET_NAME ('GCS', 'GCS_WF_ERROR_TITLE');
        FND_MESSAGE.set_token('CATEGORY', l_category_code);
        FND_MESSAGE.set_token('ENTITY_NAME', l_cons_entity_name);
        FND_MESSAGE.set_token('DATE_TOKEN', l_date);
        l_subject := FND_MESSAGE.GET;

  END IF;

  WF_ENGINE.CreateProcess('FCHNTFWF', l_event_key, 'GCS NOTIFICATION PROCESS', l_event_key, null);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'HIERARCHY', l_hierarchy_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'ENTITY_1', l_entity_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'ENTITY_2', l_counter_entity_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'SENDER', fnd_global.user_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'RECIPIENT', l_recipient);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'ENTITY', l_cons_entity_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'RUNNAME', l_run_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'WFREGION', l_wf_region);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'BALTYPE', l_balance_type);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'DATE', l_date);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'ENTRYID', l_entry_id);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, '#ATTACHMENTS', l_attachment);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'IMPACTED FLAG', 'N');
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'SUBJECT', l_subject);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'MESSAGE CONTENT', l_subject);
  WF_ENGINE.StartProcess('FCHNTFWF', l_event_key);

  COMMIT;

  FND_FILE.PUT_LINE(FND_FILE.LOG, g_pkg_name || '.' || l_api_name || ' EXIT ');
  FND_FILE.NEW_LINE(FND_FILE.LOG);

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
  END IF;

  END raise_status_notification;

  PROCEDURE raise_impact_notification ( p_run_name       IN VARCHAR2,
                                        p_cons_entity_id IN NUMBER,
                                        p_entry_id       IN NUMBER DEFAULT 0,
                                        p_load_id        IN NUMBER DEFAULT 0 )
  IS
      l_api_name            VARCHAR2(80) := 'raise_impact_notification';
      l_event_key	          VARCHAR2(200);
      l_cons_entity_name    VARCHAR2(200);
      l_hierarchy_name      VARCHAR2(200);
      l_balance_type        VARCHAR2(200);
      l_date			          VARCHAR2(200);
      l_wf_region           VARCHAR2(200);
      l_attachment          VARCHAR2(200);
      l_subject             VARCHAR2(200);
      l_recipient           VARCHAR2(100);
      l_entity_contact_attr NUMBER(15);
      l_entity_contact_ver  NUMBER;
      -- Bug fix 5245250
      l_seq                 NUMBER;
  BEGIN

  fnd_file.put_line(fnd_file.log, 'Within raise impact notification');

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' p_run_name = '
                         || p_run_name
                         || ', p_cons_entity_id = '
                         || p_cons_entity_id
                         || ', p_entry_id = '
                         || p_entry_id
                         || ', p_load_id = '
                         || p_load_id
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
  END IF;

  l_entity_contact_attr := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_CONTACT').attribute_id;
  l_entity_contact_ver := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_CONTACT').version_id;
  -- bug fix 5109610: change joins of fnd_lookup_values to gcs_data_types_b/tl for balance_type_code
  SELECT fet_cons.entity_name,
        gdtct.data_type_name,
        fcpt.cal_period_name,
        ght.hierarchy_name,
        fea_cons.varchar_assign_value,
        -- Bug fix 5245250
        fnd_flex_values_s.NEXTVAL
   INTO l_cons_entity_name,
        l_balance_type,
        l_date,
        l_hierarchy_name,
        l_recipient,
        -- Bug fix 5245250
        l_seq
   FROM fem_entities_tl fet_cons,
        gcs_hierarchies_tl ght,
        gcs_cons_eng_runs gcer,
        gcs_data_type_codes_b gdtcb,
        gcs_data_type_codes_tl gdtct,
        fem_entities_attr fea_cons,
        fem_cal_periods_tl fcpt
  WHERE p_run_name = gcer.run_name
    AND gcer.run_entity_id = p_cons_entity_id
    AND gcer.run_entity_id = fet_cons.entity_id
    AND gcer.hierarchy_id = ght.hierarchy_id
    AND ght.language = userenv('LANG')
    AND fet_cons.language = userenv('LANG')
    AND gcer.balance_type_code = gdtcb.data_type_code
    AND gdtcb.data_type_id = gdtct.data_type_id
    AND gdtct.language = userenv('LANG')
    AND fea_cons.entity_id = gcer.run_entity_id
    AND fea_cons.attribute_id = l_entity_contact_attr
    AND fea_cons.version_id = l_entity_contact_ver
    AND gcer.cal_period_id = fcpt.cal_period_id
    AND fcpt.language = userenv('LANG');
  -- end of bug fix 5109610

  -- Bug fix 5245250
  --l_event_key := substr(l_cons_entity_name, 1, 150) || ' impacted on ' || to_char(sysdate, 'DD-MON-RR HH24:MI:SS');
  l_event_key := 'Consolidation Impact Notification: ' || l_seq;

  FND_MESSAGE.SET_NAME ('GCS', 'GCS_WF_IMPACTED_TITLE');
  FND_MESSAGE.set_token('ENTITY_NAME', l_cons_entity_name);
  FND_MESSAGE.set_token('DATE_TOKEN', l_date);
  l_subject := FND_MESSAGE.GET;

  l_wf_region := 	'JSP:/OA_HTML/OA.jsp?OAFunc=FCH_WF_EMBEDDED_RG'||'&'||'RUNNAME='||
			p_run_name||'&'||'CONS_ENTITY_ID='||p_cons_entity_id||'&'||'CATEGORY=IMPACTED';

  IF (p_entry_id <> 0) THEN
        l_attachment := 'FND:
entity=GCS_ENTRY_HEADERS'||'&'||'pk1name=ENTRY_ID'||'&'||'pk1value='||p_entry_id;
--Commented for bug fix5521345
/*  ELSIF (p_load_id <> 0) THEN
        l_attachment := 'FND:entity=GCS_DATA_SUB_DTLS'||'&'||'pk1name=LOAD_ID'||'&'||'pk1value='||p_load_id;
*/
  END IF;

  WF_ENGINE.CreateProcess('FCHNTFWF', l_event_key, 'GCS NOTIFICATION PROCESS', l_event_key, null);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'HIERARCHY', l_hierarchy_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'SENDER', fnd_global.user_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'RECIPIENT', l_recipient);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'ENTITY', l_cons_entity_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'RUNNAME', p_run_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'WFREGION', l_wf_region);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'BALTYPE', l_balance_type);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'DATE', l_date);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'ENTRYID', p_entry_id);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, '#ATTACHMENTS', l_attachment);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'IMPACTED FLAG', 'Y');
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'SUBJECT', l_subject);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'MESSAGE CONTENT', l_subject);
  WF_ENGINE.StartProcess('FCHNTFWF', l_event_key);

  COMMIT;

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
  END IF;

  END raise_impact_notification;

  PROCEDURE raise_lock_notification ( p_run_name        IN VARCHAR2,
                                      p_cons_entity_id  IN NUMBER)
  IS
      l_api_name            VARCHAR2(80) := 'raise_lock_notification';
      l_event_key			      VARCHAR2(200);
      l_cons_entity_name		VARCHAR2(200);
      l_hierarchy_name			VARCHAR2(200);
      l_balance_type			  VARCHAR2(200);
      l_date			          VARCHAR2(200);
      l_subject 			      VARCHAR2(200);
      l_recipient           VARCHAR2(100);
      l_entity_contact_attr NUMBER(15);
      l_entity_contact_ver  NUMBER;
      -- Bug fix 5245250
      l_seq                 NUMBER;
  BEGIN

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' p_run_name = '
                         || p_run_name
                         || ', p_cons_entity_id = '
                         || p_cons_entity_id
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
  END IF;

  l_entity_contact_attr := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_CONTACT').attribute_id;
  l_entity_contact_ver := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_CONTACT').version_id;
  -- bug fix 5109610: change joins of fnd_lookup_values to gcs_data_types_b/tl for balance_type_code
  SELECT fet_cons.entity_name,
        gdtct.data_type_name,
        fcpt.cal_period_name,
        ght.hierarchy_name,
        fea_cons.varchar_assign_value,
        -- Bug fix 5245250
        fnd_flex_values_s.NEXTVAL
   INTO l_cons_entity_name,
        l_balance_type,
        l_date,
        l_hierarchy_name,
        l_recipient,
        -- Bug fix 5245250
        l_seq
   FROM fem_entities_tl fet_cons,
        gcs_hierarchies_tl ght,
        gcs_cons_eng_runs gcer,
        gcs_data_type_codes_b gdtcb,
        gcs_data_type_codes_tl gdtct,
        fem_cal_periods_tl fcpt,
        fem_entities_attr fea_cons
  WHERE p_run_name = gcer.run_name
    AND gcer.run_entity_id = p_cons_entity_id
    AND gcer.run_entity_id = fet_cons.entity_id
    AND gcer.hierarchy_id = ght.hierarchy_id
    AND ght.language = userenv('LANG')
    AND fet_cons.language = userenv('LANG')
    AND gcer.balance_type_code = gdtcb.data_type_code
    AND gdtcb.data_type_id = gdtct.data_type_id
    AND gdtct.language = userenv('LANG')
    AND fea_cons.entity_id = gcer.run_entity_id
    AND fea_cons.attribute_id = l_entity_contact_attr
    AND fea_cons.version_id = l_entity_contact_ver
    AND gcer.cal_period_id = fcpt.cal_period_id
    AND fcpt.language = userenv('LANG');
  -- end of bug fix 5109610

  -- Bug fix 5245250
  --l_event_key := substr(l_cons_entity_name, 1, 150) || ' locked on ' || to_char(sysdate, 'DD-MON-RR HH24:MI:SS');
  l_event_key := 'Consolidation Lock Notification: ' || l_seq;

  FND_MESSAGE.SET_NAME ('GCS', 'GCS_WF_LOCKED_TITLE');
  FND_MESSAGE.set_token('ENTITY_NAME', l_cons_entity_name);
  FND_MESSAGE.set_token('DATE_TOKEN', l_date);
  l_subject := FND_MESSAGE.GET;

  WF_ENGINE.CreateProcess('FCHNTFWF', l_event_key, 'GCS NOTIFICATION PROCESS', l_event_key, null);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'ENTITY_1', null);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'ENTITY_2', null);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'SENDER', fnd_global.user_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'RECIPIENT', l_recipient);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'HIERARCHY', l_hierarchy_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'ENTITY', l_cons_entity_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'RUNNAME', p_run_name);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'WFREGION', NULL);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'BALTYPE', l_balance_type);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'DATE', l_date);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'ENTRYID', NULL);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, '#ATTACHMENTS', NULL);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'SUBJECT', l_subject);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'MESSAGE CONTENT', l_subject);
  WF_ENGINE.SetItemAttrText('FCHNTFWF', l_event_key, 'IMPACTED FLAG', 'N');
  WF_ENGINE.StartProcess('FCHNTFWF', l_event_key);

  COMMIT;

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
  END IF;

  END raise_lock_notification;

  PROCEDURE check_attachment_required( p_itemtype IN VARCHAR2,
                                       p_itemkey  IN VARCHAR2,
                                       p_actid    IN NUMBER,
                                       p_funcmode IN VARCHAR2,
                                       p_result   IN OUT NOCOPY VARCHAR2)
  IS

    l_attachment VARCHAR2(200);
    l_api_name   VARCHAR2(80) := 'check_attachment_required';

  BEGIN

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
  END IF;

     l_attachment		:=	WF_ENGINE.GetItemAttrText(p_itemtype, p_itemkey, '#ATTACHMENTS', FALSE);

     IF (l_attachment IS NULL) THEN
       p_result := 'COMPLETE:F';
     ELSE
       p_result := 'COMPLETE:T';
     END IF;

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
  END IF;

  END check_attachment_required;

  PROCEDURE check_impacted(	p_itemtype IN VARCHAR2,
                            p_itemkey  IN VARCHAR2,
                            p_actid    IN NUMBER,
                            p_funcmode IN VARCHAR2,
                            p_result   IN OUT NOCOPY VARCHAR2)
  IS

    l_impacted_flag	VARCHAR2(200);
    l_api_name      VARCHAR2(80) := 'check_impacted';

  BEGIN

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
  END IF;

     l_impacted_flag		:=	WF_ENGINE.GetItemAttrText(p_itemtype, p_itemkey, 'IMPACTED FLAG', FALSE);

     IF (l_impacted_flag = 'Y') THEN
       p_result := 'COMPLETE:T';
     ELSE
       p_result := 'COMPLETE:F';
     END IF;

  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
  END IF;

  END check_impacted;

  PROCEDURE update_consolidation(	p_itemtype IN VARCHAR2,
                                  p_itemkey  IN VARCHAR2,
                                  p_actid	   IN NUMBER,
                                  p_funcmode IN VARCHAR2,
                                  p_result   IN OUT NOCOPY VARCHAR2)
  IS
    l_run_dtl_id NUMBER(15);
    l_api_name   VARCHAR2(80) := 'update_consolidation';
    l_ntf_id     NUMBER;
/*
    CURSOR 	c_ntf_id (	p_item_type IN VARCHAR2,
        			p_item_key IN VARCHAR2 ) IS
    SELECT 	wn.notification_id nid
    FROM    	wf_notifications wn,
        	wf_item_activity_statuses wias
    WHERE  	wn.group_id = wias.notification_id
    AND		wias.item_type = p_item_type
    AND		wias.item_key = p_item_key;
*/
  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_enter
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
    END IF;

    l_run_dtl_id		:=	WF_ENGINE.GetItemAttrText(p_itemtype, p_itemkey, 'RUN DETAIL ID', FALSE);
/*
    IF (l_run_dtl_id IS NOT NULL) THEN
      OPEN c_ntf_id(p_itemtype, p_itemkey);
      FETCH c_ntf_id INTO l_ntf_id;
      CLOSE c_ntf_id;

      UPDATE gcs_cons_eng_run_dtls
         SET notification_id = l_ntf_id
       WHERE run_detail_id = l_run_dtl_id;

      COMMIT;

    END IF;
*/
    p_result := 'COMPLETE:T';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL 	<=	FND_LOG.LEVEL_PROCEDURE) THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                            gcs_utility_pkg.g_module_success
                         || ' '
                         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS')
                        );
    END IF;

  END update_consolidation;

END GCS_WF_NTF_PKG;

/
