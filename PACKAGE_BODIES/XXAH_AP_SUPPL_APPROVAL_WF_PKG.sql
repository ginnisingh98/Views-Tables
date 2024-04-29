--------------------------------------------------------
--  DDL for Package Body XXAH_AP_SUPPL_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_AP_SUPPL_APPROVAL_WF_PKG" 
AS
   /***************************************************************************
      *                           IDENTIFICATION
      *                           ==============
      * NAME              : XXAH_AP_SUPPL_APPROVAL_WF_PKG
      * DESCRIPTION       : PACKAGE body for Supplier Approval Workflow
      ****************************************************************************
      *                           CHANGE HISTORY
      *                           ==============
      * DATE             VERSION     DONE BY           COMMENTS
      * 04-NOV-2019        1.0       Anish Hussain     Initial Package
      ****************************************************************************/

   g_party_id   hz_parties.party_id%TYPE;
   g_cc_mail    per_all_people_f.email_address%TYPE
                   := 'Vendor.Master.Data@aholddelhaize.com';

   PROCEDURE xx_debug_log (p_text IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      i   INTEGER;
   BEGIN
      SELECT xx_event_log_tab_s.NEXTVAL INTO i FROM DUAL;

      INSERT INTO xx_event_log_tab (log_message,
                                    seq,
                                    creation_date,
                                    party_id)
           VALUES (p_text,
                   i,
                   SYSDATE,
                   g_party_id);

      COMMIT;
   END xx_debug_log;

   ----------------Function which returns the instance URL------------
   FUNCTION get_instance_url
      RETURN VARCHAR2
   IS
      CURSOR instance_url_cur
      IS
         SELECT flv.meaning
           FROM fnd_lookup_values flv, v$instance vi
          WHERE     1 = 1
                AND UPPER (vi.instance_name) = flv.lookup_code
                AND flv.lookup_type = 'XXAH_INSTANCE_URL';

      l_instance_url   fnd_lookup_values.meaning%TYPE;
   BEGIN
      OPEN instance_url_cur;

      FETCH instance_url_cur INTO l_instance_url;

      CLOSE instance_url_cur;

      RETURN l_instance_url;
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log ('Exception in get_instance_url - ' || SQLERRM);
         RETURN NULL;
   END get_instance_url;

   ----------------Function which returns IBAN of supplier based on priority------------
   FUNCTION get_iban (p_party_id   IN hz_parties.party_id%TYPE,
                      p_priority   IN NUMBER)
      RETURN VARCHAR2
   IS
      l_iban   iby_ext_bank_accounts.iban%TYPE;

      CURSOR iban_cur
      IS
         SELECT ieb.iban
           FROM apps.iby_pmt_instr_uses_all instrument,
                apps.iby_account_owners owners,
                apps.iby_external_payees_all payees,
                apps.iby_ext_bank_accounts ieb,
                apps.ap_supplier_sites_all asa,
                apps.ap_suppliers asp,
                apps.ce_bank_branches_v cbbv
          WHERE     1 = 1
                AND owners.ext_bank_account_id = ieb.ext_bank_account_id
                AND owners.ext_bank_account_id = instrument.instrument_id --(+)
                AND payees.ext_payee_id = instrument.ext_pmt_party_id    --(+)
                AND cbbv.branch_party_id = ieb.branch_id
                AND payees.payee_party_id = owners.account_owner_party_id
                AND payees.supplier_site_id = asa.vendor_site_id
                AND asa.vendor_id = asp.vendor_id
                AND payees.party_site_id = asa.party_site_id
                AND asp.party_id = p_party_id
                AND instrument.order_of_preference = p_priority
         UNION
         --Supplier level Bank assignments
         SELECT ieba.iban
           FROM apps.AP_SUPPLIERS APS,
                apps.IBY_EXTERNAL_PAYEES_ALL IEPA,
                apps.IBY_PMT_INSTR_USES_ALL IPIUA,
                APPS.IBY_EXT_BANK_ACCOUNTS IEBA,
                apps.ce_banks_v cbv,
                apps.ce_bank_BRANCHES_V CBBV
          WHERE     1 = 1
                AND APS.party_id = p_party_id
                AND IEPA.PAYEE_PARTY_ID = APS.PARTY_ID
                AND PARTY_SITE_ID IS NULL
                AND SUPPLIER_SITE_ID IS NULL
                AND IPIUA.EXT_PMT_PARTY_ID(+) = IEPA.EXT_PAYEE_ID
                AND IEBA.EXT_BANK_ACCOUNT_ID(+) = IPIUA.INSTRUMENT_ID
                AND IEBA.BANK_ID = cbv.BANK_PARTY_ID(+)
                AND IEBA.BRANCH_ID = CBBV.BRANCH_PARTY_ID(+)
                AND IEBA.BANK_ACCOUNT_NUM IS NOT NULL
                AND IPIUA.order_of_preference = p_priority
         UNION
         --Supplier Address level Bank assignments
         SELECT ieba.iban
           FROM apps.AP_SUPPLIERS APS,
                apps.IBY_EXTERNAL_PAYEES_ALL IEPA,
                apps.IBY_PMT_INSTR_USES_ALL IPIUA,
                APPS.IBY_EXT_BANK_ACCOUNTS IEBA,
                apps.ce_banks_v cbv,
                apps.ce_bank_BRANCHES_V CBBV
          WHERE     1 = 1
                AND APS.party_id = p_party_id
                AND IEPA.PAYEE_PARTY_ID = APS.PARTY_ID
                --         AND PARTY_SITE_ID IS NULL
                --         AND SUPPLIER_SITE_ID IS NULL
                AND IPIUA.EXT_PMT_PARTY_ID(+) = IEPA.EXT_PAYEE_ID
                AND IEBA.EXT_BANK_ACCOUNT_ID(+) = IPIUA.INSTRUMENT_ID
                AND IEBA.BANK_ID = cbv.BANK_PARTY_ID(+)
                AND IEBA.BRANCH_ID = CBBV.BRANCH_PARTY_ID(+)
                AND IEBA.BANK_ACCOUNT_NUM IS NOT NULL
                AND IPIUA.order_of_preference = p_priority;
   BEGIN
      OPEN iban_cur;

      FETCH iban_cur INTO l_iban;

      CLOSE iban_cur;

      RETURN l_iban;
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log ('Exception in get_iban - ' || SQLERRM);
         RETURN NULL;
   END get_iban;

   ----------------Procedure to set org context
   PROCEDURE set_org_context (p_user_id   IN     fnd_user.user_id%TYPE,
                              x_appl_id      OUT NUMBER)
   IS
      ln_resp_id               fnd_responsibility_tl.responsibility_id%TYPE;
      ln_resp_appl_id          fnd_responsibility_tl.application_id%TYPE;
      lv_responsibility_name   fnd_responsibility_tl.responsibility_name%TYPE
                                  := 'Supplier Management Administrator';
   BEGIN
      BEGIN
         SELECT responsibility_id, application_id
           INTO ln_resp_id, ln_resp_appl_id
           FROM FND_RESPONSIBILITY_TL
          WHERE     1 = 1
                AND responsibility_name = lv_responsibility_name
                AND description IS NOT NULL
                AND language = 'US';
      EXCEPTION
         WHEN OTHERS
         THEN
            xx_debug_log (
               'Exception while deriving responsibility id - ' || SQLERRM);
      END;

      fnd_global.apps_initialize (p_user_id, ln_resp_id, ln_resp_appl_id);
      x_appl_id := ln_resp_appl_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log ('Exception in set_org_context - ' || SQLERRM);
   END set_org_context;

   FUNCTION split_text (p_text IN CLOB, p_delimeter IN VARCHAR2 DEFAULT ',')
      RETURN t_split_array
   IS
      l_array   t_split_array := t_split_array ();
      l_text    CLOB := p_text;
      l_idx     NUMBER;
   BEGIN
      l_array.delete;

      IF l_text IS NULL
      THEN
         RAISE_APPLICATION_ERROR (-20000, 'P_TEXT parameter cannot be NULL');
      END IF;

      WHILE l_text IS NOT NULL
      LOOP
         l_idx := INSTR (l_text, p_delimeter);
         l_array.EXTEND;

         IF l_idx > 0
         THEN
            l_array (l_array.LAST) := SUBSTR (l_text, 1, l_idx - 1);
            l_text := SUBSTR (l_text, l_idx + 1);
         ELSE
            l_array (l_array.LAST) := l_text;
            l_text := NULL;
         END IF;
      END LOOP;

      RETURN l_array;
   END split_text;

   ----------------Process_recipients------------
   PROCEDURE process_recipients (p_mail_conn   IN OUT UTL_SMTP.connection,
                                 p_list        IN     VARCHAR2)
   AS
      l_tab   t_split_array;
   BEGIN
      IF TRIM (p_list) IS NOT NULL
      THEN
         l_tab := split_text (p_list);

         FOR i IN 1 .. l_tab.COUNT
         LOOP
            UTL_SMTP.rcpt (p_mail_conn, TRIM (l_tab (i)));
         END LOOP;
      END IF;
   END process_recipients;

   ----------------Mail Procedure--------------
   PROCEDURE xx_send_mail (p_to        IN VARCHAR2,
                           p_cc        IN VARCHAR2 DEFAULT NULL,
                           p_bcc       IN VARCHAR2 DEFAULT NULL,
                           p_subject   IN VARCHAR2,
                           p_message   IN VARCHAR2)
   AS
      l_mail_conn       UTL_SMTP.connection;
      p_smtp_host       VARCHAR2 (100) := 'vmebsdblpwe01.retail.ah.eu-int-aholddelhaize.com';
      p_from            VARCHAR2 (100) := '@ah.nl';
      p_smtp_port       NUMBER (10) DEFAULT 25;
      l_instance_name   VARCHAR2 (20);
   BEGIN
      SELECT instance_name
        INTO l_instance_name
        FROM v$instance
       WHERE ROWNUM = 1;

      p_from := l_instance_name || p_from;
      l_mail_conn := UTL_SMTP.open_connection (p_smtp_host, p_smtp_port);
      UTL_SMTP.helo (l_mail_conn, p_smtp_host);
      UTL_SMTP.mail (l_mail_conn, p_from);
      process_recipients (l_mail_conn, p_to);
      process_recipients (l_mail_conn, p_cc);
      process_recipients (l_mail_conn, p_bcc);

      UTL_SMTP.open_data (l_mail_conn);

      UTL_SMTP.write_data (
         l_mail_conn,
            'Date: '
         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
         || UTL_TCP.crlf);
      UTL_SMTP.write_data (l_mail_conn, 'To: ' || p_to || UTL_TCP.crlf);

      IF TRIM (p_cc) IS NOT NULL
      THEN
         UTL_SMTP.write_data (
            l_mail_conn,
            'CC: ' || REPLACE (p_cc, ',', ';') || UTL_TCP.crlf);
      END IF;

      IF TRIM (p_bcc) IS NOT NULL
      THEN
         UTL_SMTP.write_data (
            l_mail_conn,
            'BCC: ' || REPLACE (p_bcc, ',', ';') || UTL_TCP.crlf);
      END IF;

      UTL_SMTP.write_data (l_mail_conn, 'From: ' || p_from || UTL_TCP.crlf);
      UTL_SMTP.write_data (l_mail_conn,
                           'Subject: ' || p_subject || UTL_TCP.crlf);
      UTL_SMTP.write_data (
         l_mail_conn,
         'Reply-To: ' || p_from || UTL_TCP.crlf || UTL_TCP.crlf);

      UTL_SMTP.write_data (l_mail_conn,
                           p_message || UTL_TCP.crlf || UTL_TCP.crlf);
      UTL_SMTP.close_data (l_mail_conn);

      UTL_SMTP.quit (l_mail_conn);
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log ('Exception in xx_send_mail - ' || SQLERRM);
   END xx_send_mail;

   ----------------Procedure to capture audit history of terms details update-----
   PROCEDURE supplier_terms_audit_history (
      p_party_id              IN hz_parties.party_id%TYPE,
      p_action                IN VARCHAR2,
      p_user_id               IN fnd_user.user_id%TYPE,
      p_business_controller   IN per_all_people_f.full_name%TYPE,
      p_unit_manager          IN per_all_people_f.full_name%TYPE)
   IS
      ln_attr_num                NUMBER := NULL;
      ln_msg_index_out           NUMBER := NULL;
      lv_failed_row_id_list      VARCHAR2 (100) := NULL;
      ldt_attr_date              DATE := NULL;
      lv_pk_column_values        ego_col_name_value_pair_array;
      lv_attributes_row_table    ego_user_attr_row_table;
      lv_attributes_data_table   ego_user_attr_data_table;
      lv_class_code              ego_col_name_value_pair_array;

      lv_return_status           VARCHAR2 (10) := NULL;
      ln_msg_count               NUMBER := 0;
      lv_msg_data                VARCHAR2 (1000) := NULL;
      ln_errorcode               NUMBER := 0;
      l_attr_group_name          VARCHAR2 (50)
                                    := 'XXAH_SUPPLIER_TERMS_AUDIT_MR';
      l_count                    NUMBER := 0;

      CURSOR sup_terms_cur
      IS
         SELECT xstd.*,
                pspe.c_ext_attr2 bus_cont_approval_comments,
                pspe1.c_ext_attr2 unit_man_approval_comments
           FROM XXAH_SUPP_TERMS_DTLS_UPDATED xstd,
                ego_attr_groups_v eagv,
                pos_supp_prof_ext_b pspe,
                ego_attr_groups_v eagv1,
                pos_supp_prof_ext_b pspe1
          WHERE     1 = 1
                AND xstd.party_id = p_party_id
                AND xstd.party_id = pspe.party_id
                AND eagv.attr_group_name = 'XXAH_BUSINESS_CONT_APPROVAL'
                AND eagv.attr_group_id = pspe.attr_group_id
                AND eagv1.attr_group_name = 'XXAH_UNIT_MANAGER_APPROVAL'
                AND eagv1.attr_group_id = pspe1.attr_group_id(+)
                AND pspe.party_id = pspe1.party_id(+);

      TYPE l_sup_terms_rec IS TABLE OF sup_terms_cur%ROWTYPE;

      l_sup_terms_tbl            l_sup_terms_rec;
      l_api_action               VARCHAR2 (25)
                                    := ego_user_attrs_data_pvt.g_CREATE_mode;
      ln_resp_appl_id            fnd_responsibility_tl.application_id%TYPE;
      l_unit_manager             per_all_people_f.full_name%TYPE;
      l_unit_manager_comments    pos_supp_prof_ext_b.c_ext_attr1%TYPE;
   BEGIN
      xx_debug_log ('Inside supplier_terms_audit_history - BEGIN');
      xx_debug_log ('p_action - ' || p_action);

      IF p_action = 'CREATE'
      THEN
         l_unit_manager := p_unit_manager;
      ELSE
         l_unit_manager := NULL;
      END IF;

      OPEN sup_terms_cur;

      FETCH sup_terms_cur BULK COLLECT INTO l_sup_terms_tbl;

      CLOSE sup_terms_cur;

      set_org_context (p_user_id, ln_resp_appl_id);

      FOR i IN 1 .. l_sup_terms_tbl.COUNT
      LOOP
         IF p_action = 'CREATE'
         THEN
            l_unit_manager_comments :=
               l_sup_terms_tbl (i).unit_man_approval_comments;
         ELSE
            l_unit_manager_comments := NULL;
         END IF;

         lv_pk_column_values :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('PARTY_ID',
                                            l_sup_terms_tbl (i).party_id));

         lv_class_code :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE'));
         lv_attributes_data_table :=
            ego_user_attr_data_table (
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_ID',
                  attr_value_str         => l_sup_terms_tbl (i).vendor_id,
                  attr_value_num         => NULL,
                  attr_value_date        => NULL,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_NAME',             --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).vendor_name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_SITE_CODE',        --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).vendor_site_code,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'TERMS_NAME',              --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).terms_name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'TERMS_ID',                --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).terms_id,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'RETAINAGE_RATE',          --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).retainage_rate,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'ORG_ID',                  --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).org_id,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (row_identifier         => 1,
                                       attr_name              => 'ACTION', --'A3',
                                       attr_value_str         => p_action,
                                       attr_value_num         => ln_attr_num,
                                       attr_value_date        => ldt_attr_date,
                                       attr_disp_value        => NULL,
                                       attr_unit_of_measure   => NULL,
                                       user_row_identifier    => 1),
               ego_user_attr_data_obj (row_identifier         => 1,
                                       attr_name              => 'APPROVAL_DATE', --'A3',
                                       attr_value_str         => NULL,
                                       attr_value_num         => ln_attr_num,
                                       attr_value_date        => SYSDATE,
                                       attr_disp_value        => NULL,
                                       attr_unit_of_measure   => NULL,
                                       user_row_identifier    => 1),
               ego_user_attr_data_obj (row_identifier         => 1,
                                       attr_name              => 'UNIT_MANAGER', --'A3',
                                       attr_value_str         => l_unit_manager,
                                       attr_value_num         => ln_attr_num,
                                       attr_value_date        => ldt_attr_date,
                                       attr_disp_value        => NULL,
                                       attr_unit_of_measure   => NULL,
                                       user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BUSINESS_CONTROLLER',     --'A3',
                  attr_value_str         => p_business_controller,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'UNIT_MANAGER_COMMENTS',   --'A3',
                  attr_value_str         => l_unit_manager_comments,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BUSINESS_CONTROLLER_COMMENTS', --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).bus_cont_approval_comments,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1));

         lv_attributes_row_table :=
            ego_user_attr_row_table (
               ego_user_attr_row_obj (
                  row_identifier      => 1,
                  attr_group_id       => NULL,
                  attr_group_app_id   => ln_resp_appl_id,
                  attr_group_type     => 'POS_SUPP_PROFMGMT_GROUP',
                  attr_group_name     => l_attr_group_name,
                  data_level          => 'SUPP_LEVEL', --for site level use SUPP_SITE_LEVEL
                  data_level_1        => 'N',
                  data_level_2        => NULL,
                  data_level_3        => NULL,
                  data_level_4        => NULL,
                  data_level_5        => NULL,
                  transaction_type    => l_api_action)); --for update use g_update_mode

         --Supplier uda updation started
         pos_vendor_pub_pkg.process_user_attrs_data (
            p_api_version                   => 1.0,
            p_attributes_row_table          => lv_attributes_row_table,
            p_attributes_data_table         => lv_attributes_data_table,
            p_pk_column_name_value_pairs    => lv_pk_column_values,
            p_class_code_name_value_pairs   => lv_class_code,
            x_failed_row_id_list            => lv_failed_row_id_list,
            x_return_status                 => lv_return_status,
            x_errorcode                     => ln_errorcode,
            x_msg_count                     => ln_msg_count,
            x_msg_data                      => lv_msg_data);

         IF lv_return_status = 'S'
         THEN
            l_count := l_count + 1;
            COMMIT;
         ELSE
            xx_debug_log ('Error Message Count : ' || ln_msg_count);
            xx_debug_log ('Error Message Data  : ' || lv_msg_data);
            xx_debug_log ('Error Code          : ' || ln_errorcode);
            xx_debug_log ('Entering Error Loop ');

            FOR i IN 1 .. ln_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index       => i,
                                p_data            => lv_msg_data,
                                p_encoded         => 'F',
                                p_msg_index_out   => ln_msg_index_out);
               fnd_message.set_encoded (lv_msg_data);
               xx_debug_log (
                  'Inside Error Loop : ' || i || ', ' || lv_msg_data);
            END LOOP;

            ROLLBACK;
            EXIT;
         END IF;
      END LOOP;

      xx_debug_log ('No of records inserted/deleted - ' || l_count);
      xx_debug_log ('Inside supplier_terms_audit_history - END');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log (
            'Exception in supplier_terms_audit_history: ' || SQLERRM);
         ROLLBACK;
   END supplier_terms_audit_history;

   ----------------Procedure to capture audit history of bank details update-----
   PROCEDURE supplier_bank_audit_history (
      p_party_id              IN hz_parties.party_id%TYPE,
      p_action                IN VARCHAR2,
      p_user_id               IN fnd_user.user_id%TYPE,
      p_business_controller   IN per_all_people_f.full_name%TYPE,
      p_unit_manager          IN per_all_people_f.full_name%TYPE)
   IS
      ln_attr_num                NUMBER := NULL;
      ln_msg_index_out           NUMBER := NULL;
      lv_failed_row_id_list      VARCHAR2 (100) := NULL;
      ldt_attr_date              DATE := NULL;
      lv_pk_column_values        ego_col_name_value_pair_array;
      lv_attributes_row_table    ego_user_attr_row_table;
      lv_attributes_data_table   ego_user_attr_data_table;
      lv_class_code              ego_col_name_value_pair_array;

      lv_return_status           VARCHAR2 (10) := NULL;
      ln_msg_count               NUMBER := 0;
      lv_msg_data                VARCHAR2 (1000) := NULL;
      ln_errorcode               NUMBER := 0;
      l_attr_group_name          VARCHAR2 (50)
                                    := 'XXAH_SUPPLIER_BANK_AUDIT_MR';
      l_count                    NUMBER := 0;
      l_unit_manager             per_all_people_f.full_name%TYPE;

      CURSOR supp_bank_details_cur
      IS
         SELECT xstd.*,
                pspe.c_ext_attr2 Bus_cont_approval_comments,
                pspe1.c_ext_attr2 unit_man_approval_comments
           FROM XXAH_SUPP_BANK_DTLS_UPDATED xstd,
                ego_attr_groups_v eagv,
                pos_supp_prof_ext_b pspe,
                ego_attr_groups_v eagv1,
                pos_supp_prof_ext_b pspe1
          WHERE     1 = 1
                AND xstd.party_id = p_party_id
                AND xstd.party_id = pspe.party_id
                AND eagv.attr_group_name = 'XXAH_BUSINESS_CONT_APPROVAL'
                AND eagv.attr_group_id = pspe.attr_group_id
                AND eagv1.attr_group_name = 'XXAH_UNIT_MANAGER_APPROVAL'
                AND eagv1.attr_group_id = pspe1.attr_group_id(+)
                AND pspe.party_id = pspe1.party_id(+);

      TYPE l_sup_bank_rec IS TABLE OF supp_bank_details_cur%ROWTYPE;

      l_sup_bank_tbl             l_sup_bank_rec;
      l_transaction_type         VARCHAR2 (10)
                                    := ego_user_attrs_data_pvt.g_CREATE_mode;
      ln_resp_appl_id            fnd_responsibility_tl.application_id%TYPE;
      l_unit_manager_comments    pos_supp_prof_ext_b.c_ext_attr1%TYPE;
   BEGIN
      xx_debug_log ('Inside supplier_bank_audit_history - BEGIN');
      xx_debug_log ('p_action - ' || p_action);

      IF p_action = 'CREATE'
      THEN
         l_unit_manager := p_unit_manager;
      ELSE
         l_unit_manager := NULL;
      END IF;

      OPEN supp_bank_details_cur;

      FETCH supp_bank_details_cur BULK COLLECT INTO l_sup_bank_tbl;

      CLOSE supp_bank_details_cur;

      set_org_context (p_user_id, ln_resp_appl_id);

      FOR i IN 1 .. l_sup_bank_tbl.COUNT
      LOOP
         --xx_debug_log('Inside For Loop');
         IF p_action = 'CREATE'
         THEN
            l_unit_manager_comments :=
               l_sup_bank_tbl (i).unit_man_approval_comments;
         ELSE
            l_unit_manager_comments := NULL;
         END IF;

         lv_pk_column_values :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('PARTY_ID',
                                            l_sup_bank_tbl (i).party_id));

         lv_class_code :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE'));
         lv_attributes_data_table :=
            ego_user_attr_data_table (
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_ID',
                  attr_value_str         => NULL,
                  attr_value_num         => l_sup_bank_tbl (i).vendor_id,
                  attr_value_date        => NULL,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_SITE_CODE',        --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).vendor_site_code,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_NAME',             --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).vendor_name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BANK_NAME',               --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).bank_name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BANK_BRANCH_NAME',        --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).bank_branch_name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BANK_ACCOUNT_NUMBER',     --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).bank_account_num,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BANK_ACCOUNT_NAME',       --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).bank_account_name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'IBAN',                    --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).iban,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'CURRENCY_CODE',           --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).currency_code,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'CHECK_DIGITS',            --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).check_digits,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'ORG_ID',                  --'A3',
                  attr_value_str         => NULL,
                  attr_value_num         => l_sup_bank_tbl (i).org_id,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (row_identifier         => 1,
                                       attr_name              => 'ACTION', --'A3',
                                       attr_value_str         => p_action,
                                       attr_value_num         => ln_attr_num,
                                       attr_value_date        => ldt_attr_date,
                                       attr_disp_value        => NULL,
                                       attr_unit_of_measure   => NULL,
                                       user_row_identifier    => 1),
               ego_user_attr_data_obj (row_identifier         => 1,
                                       attr_name              => 'APPROVAL_DATE', --'A3',
                                       attr_value_str         => NULL,
                                       attr_value_num         => NULL,
                                       attr_value_date        => SYSDATE,
                                       attr_disp_value        => NULL,
                                       attr_unit_of_measure   => NULL,
                                       user_row_identifier    => 1),
               ego_user_attr_data_obj (row_identifier         => 1,
                                       attr_name              => 'UNIT_MANAGER', --'A3',
                                       attr_value_str         => l_unit_manager,
                                       attr_value_num         => ln_attr_num,
                                       attr_value_date        => ldt_attr_date,
                                       attr_disp_value        => NULL,
                                       attr_unit_of_measure   => NULL,
                                       user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BUSINESS_CONTROLLER',     --'A3',
                  attr_value_str         => p_business_controller,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'UNIT_MANAGER_COMMENTS',   --'A3',
                  attr_value_str         => l_unit_manager_comments,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BUSINESS_CONTROLLER_COMMENTS', --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).bus_cont_approval_comments,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1));

         lv_attributes_row_table :=
            ego_user_attr_row_table (
               ego_user_attr_row_obj (
                  row_identifier      => 1,
                  attr_group_id       => NULL,
                  attr_group_app_id   => ln_resp_appl_id,
                  attr_group_type     => 'POS_SUPP_PROFMGMT_GROUP',
                  attr_group_name     => l_attr_group_name,
                  data_level          => 'SUPP_LEVEL', --for site level use SUPP_SITE_LEVEL
                  data_level_1        => 'N',
                  data_level_2        => NULL,
                  data_level_3        => NULL,
                  data_level_4        => NULL,
                  data_level_5        => NULL,
                  transaction_type    => l_transaction_type)); --for update use g_update_mode

         --Supplier uda updation started
         pos_vendor_pub_pkg.process_user_attrs_data (
            p_api_version                   => 1.0,
            p_attributes_row_table          => lv_attributes_row_table,
            p_attributes_data_table         => lv_attributes_data_table,
            p_pk_column_name_value_pairs    => lv_pk_column_values,
            p_class_code_name_value_pairs   => lv_class_code,
            x_failed_row_id_list            => lv_failed_row_id_list,
            x_return_status                 => lv_return_status,
            x_errorcode                     => ln_errorcode,
            x_msg_count                     => ln_msg_count,
            x_msg_data                      => lv_msg_data);

         IF lv_return_status = 'S'
         THEN
            --xx_debug_log('return_status: ' || lv_return_status);
            --xx_debug_log('msg_data: ' || lv_msg_data);
            COMMIT;
            l_count := l_count + 1;
         ELSE
            xx_debug_log ('Error Message Count : ' || ln_msg_count);
            xx_debug_log ('Error Message Data  : ' || lv_msg_data);
            xx_debug_log ('Error Code          : ' || ln_errorcode);
            xx_debug_log ('Entering Error Loop ');

            FOR i IN 1 .. ln_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index       => i,
                                p_data            => lv_msg_data,
                                p_encoded         => 'F',
                                p_msg_index_out   => ln_msg_index_out);
               fnd_message.set_encoded (lv_msg_data);
               xx_debug_log (
                  'Inside Error Loop : ' || i || ', ' || lv_msg_data);
            END LOOP;

            ROLLBACK;
            EXIT;
         END IF;
      END LOOP;

      xx_debug_log ('No of records inserted/Deleted - ' || l_count);
      xx_debug_log ('Inside supplier_bank_audit_history - END');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log (
            'Exception in supplier_bank_audit_history - ' || SQLERRM);
         ROLLBACK;
   END supplier_bank_audit_history;

   ----------------Update Approval Status------------------
   PROCEDURE xx_update_approval_status (
      p_party_id          IN hz_parties.party_id%TYPE,
      p_status            IN VARCHAR2,
      p_action            IN VARCHAR2,
      p_attr_group_name   IN VARCHAR2,
      p_user_id           IN fnd_user.user_id%TYPE)
   IS
      lv_pk_column_values        ego_col_name_value_pair_array;
      lv_attributes_row_table    ego_user_attr_row_table;
      lv_attributes_data_table   ego_user_attr_data_table;
      lv_class_code              ego_col_name_value_pair_array;
      ln_msg_index_out           NUMBER := NULL;
      lv_failed_row_id_list      VARCHAR2 (100) := NULL;

      lv_return_status           VARCHAR2 (10) := NULL;
      ln_msg_count               NUMBER := 0;
      lv_msg_data                VARCHAR2 (1000) := NULL;
      ln_errorcode               NUMBER := 0;
      ln_party_id                hz_parties.party_id%TYPE;
      lv_status                  VARCHAR2 (20);
      ln_user_id                 fnd_user.user_id%TYPE;
      ln_resp_appl_id            fnd_responsibility_tl.application_id%TYPE;
      lv_attr_group_name         VARCHAR2 (50) := 'XXAH_SUPPLIER_STATUS';
      lv_attr_name1              VARCHAR2 (20) := 'APPROVAL_STATUS';
      lv_attr_name2              VARCHAR2 (20) := 'COMMENTS';
      lv_action                  pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      lv_comments                VARCHAR2 (20) := 'NA';

      TYPE l_attr_grp_rec IS TABLE OF VARCHAR2 (50)
         INDEX BY BINARY_INTEGER;

      l_attr_grp_tbl             l_attr_grp_rec;
   BEGIN
      xx_debug_log ('Inside xx_update_approval_status - BEGIN');
      ln_party_id := p_party_id;
      lv_status := p_status;
      ln_user_id := p_user_id;
      lv_action := p_action;

      IF lv_action = 'CREATE'
      THEN
         l_attr_grp_tbl (1) := 'XXAH_UNIT_MANAGER_APPROVAL';
         l_attr_grp_tbl (2) := 'XXAH_BUSINESS_CONT_APPROVAL';
      ELSIF lv_action IN ('BANK_UPDATE',
                          'TERMS_UPDATE',
                          'BANK_AND_TERMS_UPDATE')
      THEN
         l_attr_grp_tbl (1) := 'XXAH_BUSINESS_CONT_APPROVAL';
      ELSIF p_attr_group_name IS NOT NULL
      THEN
         l_attr_grp_tbl (1) := p_attr_group_name;
      END IF;

      set_org_context (ln_user_id, ln_resp_appl_id);

      FOR i IN 1 .. l_attr_grp_tbl.COUNT
      LOOP
         lv_pk_column_values :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('PARTY_ID', ln_party_id));
         lv_class_code :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE'));
         lv_attributes_data_table :=
            ego_user_attr_data_table (
               ego_user_attr_data_obj (row_identifier         => 1,
                                       attr_name              => lv_attr_name1,
                                       attr_value_str         => lv_status,
                                       attr_value_num         => NULL,
                                       attr_value_date        => NULL,
                                       attr_disp_value        => NULL,
                                       attr_unit_of_measure   => NULL,
                                       user_row_identifier    => 1),
               ego_user_attr_data_obj (row_identifier         => 1,
                                       attr_name              => lv_attr_name2,
                                       attr_value_str         => lv_comments,
                                       attr_value_num         => NULL,
                                       attr_value_date        => NULL,
                                       attr_disp_value        => NULL,
                                       attr_unit_of_measure   => NULL,
                                       user_row_identifier    => 1));
         lv_attributes_row_table :=
            ego_user_attr_row_table (
               ego_user_attr_row_obj (
                  row_identifier      => 1,
                  attr_group_id       => NULL,
                  attr_group_app_id   => ln_resp_appl_id,
                  attr_group_type     => 'POS_SUPP_PROFMGMT_GROUP',
                  attr_group_name     => l_attr_grp_tbl (i),
                  data_level          => 'SUPP_LEVEL', --for site level use SUPP_SITE_LEVEL
                  data_level_1        => 'N',
                  data_level_2        => NULL,
                  data_level_3        => NULL,
                  data_level_4        => NULL,
                  data_level_5        => NULL,
                  transaction_type    => ego_user_attrs_data_pvt.g_sync_mode));
         pos_vendor_pub_pkg.process_user_attrs_data (
            p_api_version                   => 1.0,
            p_attributes_row_table          => lv_attributes_row_table,
            p_attributes_data_table         => lv_attributes_data_table,
            p_pk_column_name_value_pairs    => lv_pk_column_values,
            p_class_code_name_value_pairs   => lv_class_code,
            x_failed_row_id_list            => lv_failed_row_id_list,
            x_return_status                 => lv_return_status,
            x_errorcode                     => ln_errorcode,
            x_msg_count                     => ln_msg_count,
            x_msg_data                      => lv_msg_data);

         IF lv_return_status = 'S'
         THEN
            xx_debug_log ('return_status: ' || lv_return_status);
            xx_debug_log ('msg_data: ' || lv_msg_data);
            COMMIT;
         ELSE
            xx_debug_log ('Error Message Count : ' || ln_msg_count);
            xx_debug_log ('Error Message Data  : ' || lv_msg_data);
            xx_debug_log ('Error Code          : ' || ln_errorcode);
            xx_debug_log ('Entering Error Loop ');

            FOR i IN 1 .. ln_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index       => i,
                                p_data            => lv_msg_data,
                                p_encoded         => 'F',
                                p_msg_index_out   => ln_msg_index_out);
               fnd_message.set_encoded (lv_msg_data);
               xx_debug_log (
                  'Inside Error Loop : ' || i || ', ' || lv_msg_data);
            END LOOP;
         END IF;
      END LOOP;

      l_attr_grp_tbl.DELETE;
      xx_debug_log ('Inside xx_update_approval_status - END');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log (
            'Exception in xx_update_approval_status - ' || SQLERRM);
   END xx_update_approval_status;

   ----------------Check approval-------------------------
   --Procedure to validate if the approval is from the authenticated person
   PROCEDURE xx_check_approval (
      p_attr_group_name   IN VARCHAR2,
      p_extension_id      IN POS_SUPP_PROF_EXT_B.extension_id%TYPE,
      p_party_id          IN hz_parties.party_id%TYPE,
      p_approval_status   IN POS_SUPP_PROF_EXT_B.c_ext_attr1%TYPE,
      p_comments          IN POS_SUPP_PROF_EXT_B.c_ext_attr2%TYPE)
   IS
      l_user_name             per_all_people_f.full_name%TYPE;
      l_workflow_status       POS_SUPP_PROF_EXT_B.c_ext_attr1%TYPE;
      l_attr_group_name       VARCHAR2 (50) := 'XXAH_SUPPLIER_APPROVERS';
      l_unit_manager          POS_SUPP_PROF_EXT_B.c_ext_attr1%TYPE;
      l_business_controller   POS_SUPP_PROF_EXT_B.c_ext_attr1%TYPE;
      l_status                VARCHAR2 (20) := 'NA';
      l_user_id               fnd_user.user_id%TYPE;
      l_vendor_name           ap_suppliers.vendor_name%TYPE;
      l_vendor_number         ap_suppliers.segment1%TYPE;
      l_creator_email         per_all_people_f.email_address%TYPE;
      l_subject               VARCHAR2 (1000);
      l_message               VARCHAR2 (32767);
      l_action                POS_SUPP_PROF_EXT_B.c_ext_attr1%TYPE;
      l_approver_mail         per_all_people_f.email_address%TYPE;
      l_um_email              per_all_people_f.email_address%TYPE;
      l_bc_email              per_all_people_f.email_address%TYPE;
      l_update_action         POS_SUPP_PROF_EXT_B.c_ext_attr1%TYPE;

      CURSOR supplier_contacts_cur (
         p_party_id   IN hz_parties.party_id%TYPE)
      IS
         SELECT INITCAP (hps.person_pre_name_adjunct) title,
                hps.party_name contact_name,
                hps.person_title contact_title
           FROM hz_parties hp,
                hz_relationships hr,
                hz_parties hps,
                hz_parties hp2,
                ap_suppliers aps
          WHERE     1 = 1
                AND aps.party_id = p_party_id
                AND hp.party_id = aps.party_id
                AND hr.object_id = hp.party_id
                AND hr.subject_id = hps.party_id
                AND hr.object_type = 'ORGANIZATION'
                AND hr.subject_type = 'PERSON'
                AND hr.relationship_code = 'CONTACT_OF'
                AND hr.subject_table_name = 'HZ_PARTIES'
                AND hr.object_table_name = 'HZ_PARTIES'
                AND hr.status = 'A'
                AND TRUNC (hr.end_date) >= TRUNC (SYSDATE)
                AND hp2.party_id = hr.party_id;

      CURSOR supplier_address_cur (
         p_party_id   IN hz_parties.party_id%TYPE)
      IS
         SELECT address_line1 street,
                city,
                ftt.territory_short_name country,
                apsa.vendor_site_code address_name,
                apt.name,
                apsa.retainage_rate
           FROM ap_supplier_sites_all apsa,
                fnd_territories_tl ftt,
                ap_suppliers aps,
                ap_terms apt
          WHERE     1 = 1
                AND aps.party_id = p_party_id
                AND apsa.vendor_id = aps.vendor_id
                AND ftt.territory_code = apsa.country
                AND apt.term_id(+) = apsa.terms_id;

      l_db_rating             ap_suppliers.attribute12%TYPE;
      l_terms_name            ap_terms.name%TYPE;
      l_iban                  iby_ext_bank_accounts.iban%TYPE;
      l_instance_url          fnd_lookup_values.meaning%TYPE;
   BEGIN
      xx_debug_log ('Inside xx_check_approval - BEGIN');

      BEGIN
         SELECT papf.full_name,
                NVL (pspe1.c_ext_attr3, 'N'),
                pspe.last_updated_by,
                aps.vendor_name,
                aps.segment1,
                NVL (papf1.email_address, fu1.email_address)
                   creator_email_address,
                NVL (papf.email_address, fu.email_address)
                   approver_email_address,
                aps.attribute12,
                apt.name
           INTO l_user_name,
                l_workflow_status,
                l_user_id,
                l_vendor_name,
                l_vendor_number,
                l_creator_email,
                l_approver_mail,
                l_db_rating,
                l_terms_name
           FROM POS_SUPP_PROF_EXT_B pspe,
                fnd_user fu,
                per_all_people_f papf,
                ap_suppliers aps,
                fnd_user fu1,
                per_all_people_f papf1,
                POS_SUPP_PROF_EXT_B pspe1,
                ego_attr_groups_v eagv,
                ap_terms apt
          WHERE     1 = 1
                AND pspe.extension_id = p_extension_id
                AND fu.user_id = pspe.last_updated_by
                AND fu.person_party_id = papf.party_id
                AND aps.party_id = pspe.party_id
                AND eagv.attr_group_name = 'XXAH_SUPPLIER_APPROVERS'
                AND eagv.attr_group_id = pspe1.attr_group_id
                AND pspe.party_id = pspe1.party_id
                AND fu1.user_id = pspe1.last_updated_by --Changed created by to last updated by as created by is -1 for suppliers created using API
                AND fu1.person_party_id = papf1.party_id
                AND apt.term_id(+) = aps.terms_id
                AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                               NVL (
                                                  papf.EFFECTIVE_START_DATE,
                                                  SYSDATE))
                                        AND TRUNC (
                                               NVL (papf.EFFECTIVE_END_DATE,
                                                    SYSDATE))
                AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                               NVL (
                                                  papf1.EFFECTIVE_START_DATE,
                                                  SYSDATE))
                                        AND TRUNC (
                                               NVL (papf1.EFFECTIVE_END_DATE,
                                                    SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            xx_debug_log (
                  'Exception while deriving approval status and approver name - '
               || SQLERRM);
      END;

      BEGIN
         SELECT pspe.c_ext_attr1,
                pspe.c_ext_attr2,
                papf1.email_address,
                papf2.email_address
           INTO l_unit_manager,
                l_business_controller,
                l_um_email,
                l_bc_email
           FROM POS_SUPP_PROF_EXT_B pspe,
                ego_attr_groups_v eagv,
                per_all_people_f papf1,
                per_all_people_f papf2,
                fnd_user fu,
                fnd_user fu1
          WHERE     1 = 1
                AND eagv.attr_group_id = pspe.attr_group_id
                AND eagv.attr_group_name = l_attr_group_name
                AND pspe.party_id = p_party_id
                AND papf1.full_name(+) = pspe.c_ext_attr1
                AND papf2.full_name(+) = pspe.c_ext_attr2
                AND fu.employee_id(+) = papf1.person_id
                AND fu1.employee_id(+) = papf2.person_id
                AND TRUNC (NVL (fu.end_date, SYSDATE)) >= TRUNC (SYSDATE)
                AND TRUNC (NVL (fu1.end_date, SYSDATE)) >= TRUNC (SYSDATE)
                AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                               NVL (
                                                  papf2.EFFECTIVE_START_DATE,
                                                  SYSDATE))
                                        AND TRUNC (
                                               NVL (papf2.EFFECTIVE_END_DATE,
                                                    SYSDATE))
                AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                               NVL (
                                                  papf1.EFFECTIVE_START_DATE,
                                                  SYSDATE))
                                        AND TRUNC (
                                               NVL (papf1.EFFECTIVE_END_DATE,
                                                    SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            l_unit_manager := NULL;
            l_business_controller := NULL;
            xx_debug_log (
                  'Exception while deriving unit manager and business controller - '
               || SQLERRM);
      END;

      BEGIN
         SELECT DECODE (
                   pspe.c_ext_attr2,
                   'CREATE', 'Supplier Creation',
                   'BANK_UPDATE', 'Supplier Bank Update',
                   'TERMS_UPDATE', 'Supplier Payment Terms Update',
                   'BANK_AND_TERMS_UPDATE', 'Supplier Bank and Payment Terms Update',
                   pspe.c_ext_attr2),
                pspe.c_ext_attr2
           INTO l_action, l_update_action
           FROM POS_SUPP_PROF_EXT_B pspe, ego_attr_groups_v eagv
          WHERE     1 = 1
                AND eagv.attr_group_id = pspe.attr_group_id
                AND eagv.attr_group_name = 'XXAH_SUPPLIER_STATUS'
                AND pspe.party_id = p_party_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_action := NULL;
            xx_debug_log ('Exception while deriving action - ' || SQLERRM);
      END;

      IF     p_attr_group_name = 'XXAH_BUSINESS_CONT_APPROVAL'
         AND l_workflow_status = 'Y'
      THEN
         IF     l_user_name = NVL (l_business_controller, 'X')
            AND p_approval_status = 'APPROVED'
         THEN
            --Send notification to the person who created supplier that the supplier is approved.
            l_subject :=
                  'FYI. Supplier -  '
               || l_vendor_name
               || ' is approved. Action - '
               || l_action;
            l_message :=
                  'Supplier is approved by Business controller, '
               || l_business_controller
               || '.'
               || CHR (10)
               || 'Comments - '
               || p_comments
               || CHR (10)
               || 'Supplier Details :'
               || CHR (10)
               || 'Supplier Name: '
               || l_vendor_name
               || CHR (10)
               || 'Supplier Number: '
               || l_vendor_number
               || CHR (10)
               || CHR (10)
               || 'Supplier is ready to Publish.';
            xx_send_mail (l_creator_email,
                          g_cc_mail,
                          NULL,
                          l_subject,
                          l_message);
            xx_update_status (p_party_id,
                              'ACTIVE',
                              NULL,
                              l_user_id);

            IF l_update_action = 'BANK_UPDATE'
            THEN
               Update_supplier_bank_details (p_party_id, 'DELETE', l_user_id);
               Update_supplier_bank_details (p_party_id, 'CREATE', l_user_id);
               supplier_bank_audit_history (p_party_id,
                                            l_update_action,
                                            l_user_id,
                                            l_business_controller,
                                            l_unit_manager);

               BEGIN
                  DELETE FROM XXAH_SUPP_BANK_DTLS_UPDATED
                        WHERE 1 = 1 AND party_id = p_party_id;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     xx_debug_log (
                           'Exception while deleting XXAH_SUPP_BANK_DTLS_UPDATED - '
                        || SQLERRM);
               END;
            ELSIF l_update_action = 'TERMS_UPDATE'
            THEN
               Update_payment_terms_details (p_party_id, 'DELETE', l_user_id);
               Update_payment_terms_details (p_party_id, 'CREATE', l_user_id);
               supplier_terms_audit_history (p_party_id,
                                             l_update_action,
                                             l_user_id,
                                             l_business_controller,
                                             l_unit_manager);

               BEGIN
                  DELETE FROM XXAH_SUPP_TERMS_DTLS_UPDATED
                        WHERE 1 = 1 AND party_id = p_party_id;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     xx_debug_log (
                           'Exception while deleting XXAH_SUPP_TERMS_DTLS_UPDATED - '
                        || SQLERRM);
               END;
            ELSIF l_update_action IN ('BANK_AND_TERMS_UPDATE', 'CREATE')
            THEN
               Update_supplier_bank_details (p_party_id, 'DELETE', l_user_id);
               Update_supplier_bank_details (p_party_id, 'CREATE', l_user_id);
               Update_payment_terms_details (p_party_id, 'DELETE', l_user_id);
               Update_payment_terms_details (p_party_id, 'CREATE', l_user_id);
               supplier_bank_audit_history (p_party_id,
                                            l_update_action,
                                            l_user_id,
                                            l_business_controller,
                                            l_unit_manager);
               supplier_terms_audit_history (p_party_id,
                                             l_update_action,
                                             l_user_id,
                                             l_business_controller,
                                             l_unit_manager);

               BEGIN
                  DELETE FROM XXAH_SUPP_TERMS_DTLS_UPDATED
                        WHERE 1 = 1 AND party_id = p_party_id;

                  DELETE FROM XXAH_SUPP_BANK_DTLS_UPDATED
                        WHERE 1 = 1 AND party_id = p_party_id;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     xx_debug_log (
                           'Exception while deleting Supplier and Payments terms from table - '
                        || SQLERRM);
               END;
            END IF;

            xx_reset_approval_flag (p_party_id, l_user_id);
         /*
         BEGIN
           DELETE FROM XXAH_SUPP_BANK_DTLS_UPDATED
           WHERE 1=1
           AND party_id = p_party_id;
         EXCEPTION
         WHEN OTHERS THEN
           xx_debug_log('Exception while deleting XXAH_SUPP_BANK_DTLS_UPDATED - '||SQLERRM);
         END;
         */
         ELSIF     l_user_name = NVL (l_business_controller, 'X')
               AND p_approval_status = 'REJECTED'
         THEN
            --Send notification to the person who created supplier that the supplier is approved.
            l_subject :=
                  'FYI. Supplier -  '
               || l_vendor_name
               || ' is Rejected. Action - '
               || l_action;
            l_message :=
                  'Supplier is rejected by Business controller, '
               || l_business_controller
               || '.'
               || CHR (10)
               || 'Rejection Comments - '
               || p_comments
               || CHR (10)
               || 'Supplier Details :'
               || CHR (10)
               || 'Supplier Name: '
               || l_vendor_name
               || CHR (10)
               || 'Supplier Number: '
               || l_vendor_number
               || CHR (10);
            xx_send_mail (l_creator_email,
                          g_cc_mail,
                          NULL,
                          l_subject,
                          l_message);
            xx_reset_approval_flag (p_party_id, l_user_id);
         /*
         xx_update_status(p_party_id,'ACTIVE',NULL,l_user_id);
         Update_supplier_bank_details(p_party_id,'DELETE',l_user_id);
         Update_supplier_bank_details(p_party_id,'CREATE',l_user_id);
         xx_reset_approval_flag(p_party_id,l_user_id);
         BEGIN
           DELETE FROM XXAH_SUPP_BANK_DTLS_UPDATED
           WHERE 1=1
           AND party_id = p_party_id;
         EXCEPTION
         WHEN OTHERS THEN
           xx_debug_log('Exception while deleting XXAH_SUPP_BANK_DTLS_UPDATED - '||SQLERRM);
         END;
         */
         ELSE
            --Send notification that the corresponding business controller alone can approve the supplier.
            --update the approval status back to NA
            l_subject :=
               'FYI. Supplier -  ' || l_vendor_name || ' cannot be approved.';
            l_message :=
                  'Supplier can only be approved by Business controller, '
               || l_business_controller
               || '.'
               || CHR (10);
            xx_send_mail (l_approver_mail,
                          NULL,
                          NULL,
                          l_subject,
                          l_message);
            xx_update_approval_status (p_party_id,
                                       l_status,
                                       NULL,
                                       p_attr_group_name,
                                       l_user_id);
         END IF;
      ELSIF     p_attr_group_name = 'XXAH_UNIT_MANAGER_APPROVAL'
            AND l_workflow_status = 'Y'
      THEN
         IF     l_user_name = NVL (l_unit_manager, 'X')
            AND p_approval_status = 'APPROVED'
         THEN
            --Send notification to the person who created supplier that the supplier is approved.
            l_subject :=
                  'FYI. Supplier -  '
               || l_vendor_name
               || ' is approved. Action - '
               || l_action;
            l_message :=
                  'Supplier is approved by Unit Manager, '
               || l_unit_manager
               || '.'
               || CHR (10)
               || 'Comments - '
               || p_comments
               || CHR (10)
               || 'Supplier Details :'
               || CHR (10)
               || 'Supplier Name: '
               || l_vendor_name
               || CHR (10)
               || 'Supplier Number: '
               || l_vendor_number
               || CHR (10);
            xx_send_mail (l_creator_email,
                          g_cc_mail,
                          NULL,
                          l_subject,
                          l_message);
            --And send notification to Business controller for approval.
            l_iban := get_iban (p_party_id, 1);
            --Get instance URL to be sent in mail
            l_instance_url := get_instance_url ();
            l_subject :=
                  'FYA. Supplier -  '
               || l_vendor_name
               || ' needs approval. Action - '
               || l_action;
            l_message :=
                  'Supplier requires your approval. Kindly login to EBS application and approve the supplier. With your approval, you confirm that the supplier has been called back and the bank details have been verified.'
               || CHR (10)
               || l_instance_url
               || CHR (10)
               || 'Supplier Details :'
               || CHR (10)
               || 'Supplier Name: '
               || l_vendor_name
               || CHR (10)
               || 'Supplier Number: '
               || l_vendor_number
               || CHR (10)
               || 'D&B Rating - '
               || l_db_rating
               || CHR (10)
               || 'Supplier Payment Terms - '
               || l_terms_name
               || CHR (10)
               || 'Supplier IBAN - '
               || l_iban
               || CHR (10)
               || CHR (10)
               || 'Supplier Contact:'
               || CHR (10)
               || '------------------'
               || CHR (10);

            FOR i IN supplier_contacts_cur (p_party_id)
            LOOP
               l_message :=
                     l_message
                  || 'Name - '
                  || i.title
                  || i.contact_name
                  || CHR (10)
                  || 'Title - '
                  || i.contact_title
                  || CHR (10);
            END LOOP;

            l_message :=
                  l_message
               || CHR (10)
               || 'Address and Payment Terms Details:'
               || CHR (10)
               || '-----------------------------------'
               || CHR (10);

            FOR i IN supplier_address_cur (p_party_id)
            LOOP
               l_message :=
                     l_message
                  || 'Address Name - '
                  || i.address_name
                  || CHR (10)
                  || 'Street - '
                  || i.street
                  || CHR (10)
                  || 'City - '
                  || i.city
                  || CHR (10)
                  || 'Country - '
                  || i.country
                  || CHR (10)
                  || 'Payment Terms - '
                  || i.name
                  || CHR (10)
                  || 'Retainage Rate - '
                  || i.retainage_rate
                  || CHR (10);
            END LOOP;

            xx_send_mail (l_bc_email,
                          g_cc_mail,
                          NULL,
                          l_subject,
                          l_message);
         ELSIF     l_user_name = NVL (l_unit_manager, 'X')
               AND p_approval_status = 'REJECTED'
         THEN
            --Send notification to the person who created supplier that the supplier is rejected.
            l_subject :=
                  'FYI. Supplier -  '
               || l_vendor_name
               || ' is Rejected. Action - '
               || l_action;
            l_message :=
                  'Supplier is rejected by Unit Manager, '
               || l_unit_manager
               || '.'
               || CHR (10)
               || 'Rejection Comments - '
               || p_comments
               || CHR (10)
               || 'Supplier Details :'
               || CHR (10)
               || 'Supplier Name: '
               || l_vendor_name
               || CHR (10)
               || 'Supplier Number: '
               || l_vendor_number
               || CHR (10);
            xx_send_mail (l_creator_email,
                          g_cc_mail,
                          NULL,
                          l_subject,
                          l_message);
            xx_reset_approval_flag (p_party_id, l_user_id);
         ELSE
            --Send notification that the corresponding unit manager alone can approve the supplier.
            --update the approval status back to NA
            l_subject :=
               'FYI. Supplier -  ' || l_vendor_name || ' cannot be approved.';
            l_message :=
                  'Supplier can only be approved by Unit Manager, '
               || l_unit_manager
               || '.'
               || CHR (10);
            xx_send_mail (l_approver_mail,
                          NULL,
                          NULL,
                          l_subject,
                          l_message);
            xx_update_approval_status (p_party_id,
                                       l_status,
                                       NULL,
                                       p_attr_group_name,
                                       l_user_id);
         END IF;
      ELSIF l_workflow_status = 'N'
      THEN
         l_subject :=
            'FYI. Supplier -  ' || l_vendor_name || ' cannot be approved.';
         l_message :=
               'Supplier can only be approved once the workflow is initiated. '
            || CHR (10);
         xx_send_mail (l_approver_mail,
                       NULL,
                       NULL,
                       l_subject,
                       l_message);
         xx_update_approval_status (p_party_id,
                                    l_status,
                                    NULL,
                                    p_attr_group_name,
                                    l_user_id);
      END IF;

      xx_debug_log ('Inside xx_check_approval - END');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log ('Exception in xx_check_approval - ' || SQLERRM);
   END xx_check_approval;

   ----------------Update Display Status of Supplier--------------------
   PROCEDURE xx_update_status_display (
      p_party_id   IN hz_parties.party_id%TYPE,
      p_user_id    IN fnd_user.user_id%TYPE)
   IS
      lv_pk_column_values        ego_col_name_value_pair_array;
      lv_attributes_row_table    ego_user_attr_row_table;
      lv_attributes_data_table   ego_user_attr_data_table;
      lv_class_code              ego_col_name_value_pair_array;
      ln_msg_index_out           NUMBER := NULL;
      lv_failed_row_id_list      VARCHAR2 (100) := NULL;

      lv_return_status           VARCHAR2 (10) := NULL;
      ln_msg_count               NUMBER := 0;
      lv_msg_data                VARCHAR2 (1000) := NULL;
      ln_errorcode               NUMBER := 0;
      ln_party_id                hz_parties.party_id%TYPE;
      lv_status                  VARCHAR2 (20);
      ln_user_id                 fnd_user.user_id%TYPE;
      ln_resp_appl_id            fnd_responsibility_tl.application_id%TYPE;
      lv_attr_group_name         VARCHAR2 (50)
                                    := 'XXAH_SUPPLIER_STATUS_DISPLAY';
      lv_attr_name1              VARCHAR2 (20) := 'STATUS';
      lv_attr_name2              VARCHAR2 (20) := 'ACTION';
      lv_action                  pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_existing_status          pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_existing_action          pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_actual_status            pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_actual_action            pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_subject                  VARCHAR2 (1000);
      l_message                  VARCHAR2 (32767);

      CURSOR get_status_cur
      IS
         SELECT c_ext_attr1, c_ext_attr2
           FROM pos_supp_prof_ext_b pose, ego_attr_groups_v eagv
          WHERE     1 = 1
                AND party_id = p_party_id
                AND eagv.attr_group_id = pose.attr_group_id
                AND eagv.attr_group_name = 'XXAH_SUPPLIER_STATUS';

      CURSOR get_display_status_cur
      IS
         SELECT c_ext_attr1, c_ext_attr2
           FROM pos_supp_prof_ext_b pose, ego_attr_groups_v eagv
          WHERE     1 = 1
                AND party_id = p_party_id
                AND eagv.attr_group_id = pose.attr_group_id
                AND eagv.attr_group_name = lv_attr_group_name;
   BEGIN
      xx_debug_log ('Inside xx_update_status_display - BEGIN');
      ln_party_id := p_party_id;
      ln_user_id := p_user_id;

      OPEN get_status_cur;

      FETCH get_status_cur INTO l_actual_status, l_actual_action;

      CLOSE get_status_cur;

      OPEN get_display_status_cur;

      FETCH get_display_status_cur INTO l_existing_status, l_existing_action;

      CLOSE get_display_status_cur;

      IF    NVL (l_existing_status, 'XYZ') <> NVL (l_actual_status, 'XYZ')
         OR NVL (l_existing_action, 'XYZ') <> NVL (l_actual_action, 'XYZ')
      THEN
         xx_debug_log ('Status mismatch. Proceeding to update');
         set_org_context (ln_user_id, ln_resp_appl_id);
         lv_pk_column_values :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('PARTY_ID', ln_party_id));

         lv_class_code :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE'));

         lv_attributes_data_table :=
            ego_user_attr_data_table (
               ego_user_attr_data_obj (row_identifier         => 1,
                                       attr_name              => lv_attr_name1,
                                       attr_value_str         => l_actual_status,
                                       attr_value_num         => NULL,
                                       attr_value_date        => NULL,
                                       attr_disp_value        => NULL,
                                       attr_unit_of_measure   => NULL,
                                       user_row_identifier    => 1),
               ego_user_attr_data_obj (row_identifier         => 1,
                                       attr_name              => lv_attr_name2,
                                       attr_value_str         => l_actual_action,
                                       attr_value_num         => NULL,
                                       attr_value_date        => NULL,
                                       attr_disp_value        => NULL,
                                       attr_unit_of_measure   => NULL,
                                       user_row_identifier    => 1));
         lv_attributes_row_table :=
            ego_user_attr_row_table (
               ego_user_attr_row_obj (
                  row_identifier      => 1,
                  attr_group_id       => NULL,
                  attr_group_app_id   => ln_resp_appl_id,
                  attr_group_type     => 'POS_SUPP_PROFMGMT_GROUP',
                  attr_group_name     => lv_attr_group_name,
                  data_level          => 'SUPP_LEVEL', --for site level use SUPP_SITE_LEVEL
                  data_level_1        => 'N',
                  data_level_2        => NULL,
                  data_level_3        => NULL,
                  data_level_4        => NULL,
                  data_level_5        => NULL,
                  transaction_type    => ego_user_attrs_data_pvt.g_sync_mode));
         pos_vendor_pub_pkg.process_user_attrs_data (
            p_api_version                   => 1.0,
            p_attributes_row_table          => lv_attributes_row_table,
            p_attributes_data_table         => lv_attributes_data_table,
            p_pk_column_name_value_pairs    => lv_pk_column_values,
            p_class_code_name_value_pairs   => lv_class_code,
            x_failed_row_id_list            => lv_failed_row_id_list,
            x_return_status                 => lv_return_status,
            x_errorcode                     => ln_errorcode,
            x_msg_count                     => ln_msg_count,
            x_msg_data                      => lv_msg_data);

         IF lv_return_status = 'S'
         THEN
            xx_debug_log ('return_status: ' || lv_return_status);
            xx_debug_log ('msg_data: ' || lv_msg_data);
            COMMIT;
         ELSE
            xx_debug_log ('Error Message Count : ' || ln_msg_count);
            xx_debug_log ('Error Message Data  : ' || lv_msg_data);
            xx_debug_log ('Error Code          : ' || ln_errorcode);
            xx_debug_log ('Entering Error Loop ');

            FOR i IN 1 .. ln_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index       => i,
                                p_data            => lv_msg_data,
                                p_encoded         => 'F',
                                p_msg_index_out   => ln_msg_index_out);
               fnd_message.set_encoded (lv_msg_data);
               xx_debug_log (
                  'Inside Error Loop : ' || i || ', ' || lv_msg_data);
            END LOOP;
         END IF;
      END IF;

      xx_debug_log ('Inside xx_update_status_display - END');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log ('Exception in xx_update_status_display - ' || SQLERRM);
   END xx_update_status_display;

   ----------------Update Status of Supplier--------------------
   PROCEDURE xx_update_status (p_party_id   IN hz_parties.party_id%TYPE,
                               p_status     IN VARCHAR2,
                               p_action     IN VARCHAR2,
                               p_user_id    IN fnd_user.user_id%TYPE)
   IS
      lv_pk_column_values        ego_col_name_value_pair_array;
      lv_attributes_row_table    ego_user_attr_row_table;
      lv_attributes_data_table   ego_user_attr_data_table;
      lv_class_code              ego_col_name_value_pair_array;
      ln_msg_index_out           NUMBER := NULL;
      lv_failed_row_id_list      VARCHAR2 (100) := NULL;

      lv_return_status           VARCHAR2 (10) := NULL;
      ln_msg_count               NUMBER := 0;
      lv_msg_data                VARCHAR2 (1000) := NULL;
      ln_errorcode               NUMBER := 0;
      ln_party_id                hz_parties.party_id%TYPE;
      lv_status                  VARCHAR2 (20);
      ln_user_id                 fnd_user.user_id%TYPE;
      ln_resp_appl_id            fnd_responsibility_tl.application_id%TYPE;
      lv_attr_group_name         VARCHAR2 (50) := 'XXAH_SUPPLIER_STATUS';
      lv_attr_name1              VARCHAR2 (20) := 'STATUS';
      lv_attr_name2              VARCHAR2 (20) := 'ACTION';
      lv_action                  pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_existing_status          pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_existing_action          pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_subject                  VARCHAR2 (1000);
      l_message                  VARCHAR2 (32767);
      l_vendor_name              ap_suppliers.vendor_name%TYPE;
      l_vendor_number            ap_suppliers.segment1%TYPE;
      l_workflow_status          pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_email                    per_all_people_f.email_address%TYPE;

      CURSOR get_status_cur
      IS
         SELECT c_ext_attr1, c_ext_attr2
           FROM pos_supp_prof_ext_b pose, ego_attr_groups_v eagv
          WHERE     1 = 1
                AND party_id = p_party_id
                AND eagv.attr_group_id = pose.attr_group_id
                AND eagv.attr_group_name = lv_attr_group_name;

      CURSOR get_workflow_status_cur
      IS
         SELECT NVL (pose.c_ext_attr3, 'N'), ap.vendor_name, ap.segment1
           FROM pos_supp_prof_ext_b pose,
                ego_attr_groups_v eagv,
                ap_suppliers ap
          WHERE     1 = 1
                AND pose.party_id = p_party_id
                AND eagv.attr_group_id = pose.attr_group_id
                AND eagv.attr_group_name = 'XXAH_SUPPLIER_APPROVERS'
                AND ap.party_id = pose.party_id;

      CURSOR get_email_cur (
         p_user_id   IN fnd_user.user_id%TYPE)
      IS
         SELECT NVL (papf.email_address, fu.email_address)
           FROM per_all_people_f papf, fnd_user fu
          WHERE     1 = 1
                AND papf.party_id = fu.person_party_id
                AND fu.user_id = p_user_id
                AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                               NVL (
                                                  papf.EFFECTIVE_START_DATE,
                                                  SYSDATE))
                                        AND TRUNC (
                                               NVL (papf.EFFECTIVE_END_DATE,
                                                    SYSDATE));
   BEGIN
      xx_debug_log ('Inside xx_update_status - BEGIN');
      ln_party_id := p_party_id;
      lv_status := p_status;
      ln_user_id := p_user_id;
      lv_action := p_action;

      OPEN get_status_cur;

      FETCH get_status_cur INTO l_existing_status, l_existing_action;

      CLOSE get_status_cur;

      IF l_existing_status IS NOT NULL AND l_existing_action IS NOT NULL
      THEN
         IF l_existing_status = 'INACTIVE' AND l_existing_action <> lv_action
         THEN
            lv_action := 'BANK_AND_TERMS_UPDATE';
         END IF;
      END IF;

      set_org_context (ln_user_id, ln_resp_appl_id);
      lv_pk_column_values :=
         ego_col_name_value_pair_array (
            ego_col_name_value_pair_obj ('PARTY_ID', ln_party_id));

      lv_class_code :=
         ego_col_name_value_pair_array (
            ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE'));

      lv_attributes_data_table :=
         ego_user_attr_data_table (
            ego_user_attr_data_obj (row_identifier         => 1,
                                    attr_name              => lv_attr_name1,
                                    attr_value_str         => lv_status,
                                    attr_value_num         => NULL,
                                    attr_value_date        => NULL,
                                    attr_disp_value        => NULL,
                                    attr_unit_of_measure   => NULL,
                                    user_row_identifier    => 1),
            ego_user_attr_data_obj (row_identifier         => 1,
                                    attr_name              => lv_attr_name2,
                                    attr_value_str         => lv_action,
                                    attr_value_num         => NULL,
                                    attr_value_date        => NULL,
                                    attr_disp_value        => NULL,
                                    attr_unit_of_measure   => NULL,
                                    user_row_identifier    => 1));
      lv_attributes_row_table :=
         ego_user_attr_row_table (
            ego_user_attr_row_obj (
               row_identifier      => 1,
               attr_group_id       => NULL,
               attr_group_app_id   => ln_resp_appl_id,
               attr_group_type     => 'POS_SUPP_PROFMGMT_GROUP',
               attr_group_name     => lv_attr_group_name,
               data_level          => 'SUPP_LEVEL', --for site level use SUPP_SITE_LEVEL
               data_level_1        => 'N',
               data_level_2        => NULL,
               data_level_3        => NULL,
               data_level_4        => NULL,
               data_level_5        => NULL,
               transaction_type    => ego_user_attrs_data_pvt.g_sync_mode));
      pos_vendor_pub_pkg.process_user_attrs_data (
         p_api_version                   => 1.0,
         p_attributes_row_table          => lv_attributes_row_table,
         p_attributes_data_table         => lv_attributes_data_table,
         p_pk_column_name_value_pairs    => lv_pk_column_values,
         p_class_code_name_value_pairs   => lv_class_code,
         x_failed_row_id_list            => lv_failed_row_id_list,
         x_return_status                 => lv_return_status,
         x_errorcode                     => ln_errorcode,
         x_msg_count                     => ln_msg_count,
         x_msg_data                      => lv_msg_data);

      IF lv_return_status = 'S'
      THEN
         xx_debug_log ('return_status: ' || lv_return_status);
         xx_debug_log ('msg_data: ' || lv_msg_data);
         COMMIT;
      ELSE
         xx_debug_log ('Error Message Count : ' || ln_msg_count);
         xx_debug_log ('Error Message Data  : ' || lv_msg_data);
         xx_debug_log ('Error Code          : ' || ln_errorcode);
         xx_debug_log ('Entering Error Loop ');

         FOR i IN 1 .. ln_msg_count
         LOOP
            fnd_msg_pub.get (p_msg_index       => i,
                             p_data            => lv_msg_data,
                             p_encoded         => 'F',
                             p_msg_index_out   => ln_msg_index_out);
            fnd_message.set_encoded (lv_msg_data);
            xx_debug_log ('Inside Error Loop : ' || i || ', ' || lv_msg_data);
         END LOOP;
      END IF;

      IF lv_action = 'BANK_AND_TERMS_UPDATE'
      THEN
         OPEN get_workflow_status_cur;

         FETCH get_workflow_status_cur
            INTO l_workflow_status, l_vendor_name, l_vendor_number;

         CLOSE get_workflow_status_cur;

         IF l_workflow_status = 'Y'
         THEN
            --When Bank details are updated after updating payment terms,
            --reset the workflow flag and force the user to initiate the workflow again
            --so that the business controller knows that there is a bank and payment terms update
            OPEN get_email_cur (ln_user_id);

            FETCH get_email_cur INTO l_email;

            CLOSE get_email_cur;

            xx_reset_approval_flag (ln_party_id, ln_user_id);
            l_subject :=
                  'FYA. Please reinitiate Approval Workflow for Supplier -  '
               || l_vendor_name;
            l_message :=
                  'Bank Details and Payment terms has been updated for Supplier - '
               || l_vendor_name
               || '. Kindly reinitiate approval workflow for supplier.'
               || CHR (10)
               || 'Supplier Details:'
               || CHR (10)
               || 'Supplier Name - '
               || l_vendor_name
               || CHR (10)
               || 'Supplier Number - '
               || l_vendor_number;
            xx_send_mail (l_email,
                          g_cc_mail,
                          NULL,
                          l_subject,
                          l_message);
         END IF;
      END IF;

      xx_update_status_display (ln_party_id, ln_user_id);
      xx_debug_log ('Inside xx_update_status - END');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log ('Exception in xx_update_status - ' || SQLERRM);
   END xx_update_status;

   ----------Procedure to checck if payments terms is updated or not
   PROCEDURE xx_terms_details_check (p_party_id IN hz_parties.party_id%TYPE)
   IS
      CURSOR sup_terms_cur
      IS
         --Supplier level details
         SELECT aps.vendor_id,
                aps.vendor_name,
                NULL vendor_site_code,
                att.name,
                att.term_id,
                aps.party_id,
                aps.last_updated_by user_id,
                NULL retainage_rate,
                NULL org_id
           FROM ap_suppliers aps, ap_terms_tl att
          WHERE     1 = 1
                AND att.term_id = aps.terms_id
                AND aps.party_id = p_party_id
         UNION
         --Supplier site level details
         SELECT aps.vendor_id,
                aps.vendor_name,
                apsa.vendor_site_code,
                att.name,
                att.term_id,
                aps.party_id,
                apsa.last_updated_by user_id,
                apsa.retainage_rate
                   retainage_rate,
                TO_CHAR (apsa.org_id) org_id
           FROM ap_suppliers aps,
                ap_terms_tl att,
                ap_supplier_sites_all apsa,
                pos_supp_prof_ext_b pspe,
                ego_attr_groups_v eagv
          WHERE     1 = 1
                AND att.term_id = apsa.terms_id
                AND aps.party_id = p_party_id
                AND pspe.party_id = aps.party_id
                AND apsa.vendor_id = aps.vendor_id
                AND eagv.attr_group_id = pspe.attr_group_id
                AND UPPER (eagv.attr_group_name) =
                       UPPER ('XXAH_Supplier_Site_Type')
                AND UPPER (pspe.c_ext_attr1) = UPPER ('Trade')
                AND apsa.vendor_id = aps.vendor_id
                AND apsa.vendor_site_id = TO_NUMBER (pspe.pk2_value)
                AND apsa.party_site_id = TO_NUMBER (pspe.pk1_value)
                AND TRUNC (NVL (pspe.d_ext_attr1, SYSDATE)) >=
                       TRUNC (SYSDATE)
         ORDER BY vendor_name;

      TYPE l_sup_terms_rec IS TABLE OF sup_terms_cur%ROWTYPE;

      l_sup_terms_tbl     l_sup_terms_rec;
      l_supplier_status   VARCHAR2 (20) := 'INACTIVE';
      l_count             NUMBER := 0;
      l_action            pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_approval_status   VARCHAR2 (20) := 'NA';
      l_status            pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_modified_flag     VARCHAR2 (1) := 'N';
      l_user_id           fnd_user.user_id%TYPE;

      CURSOR status_check_cur
      IS
         SELECT c_ext_attr1, c_ext_attr2
           FROM pos_supp_prof_ext_b pose, ego_attr_groups_v eagv
          WHERE     1 = 1
                AND party_id = p_party_id
                AND eagv.attr_group_id = pose.attr_group_id
                AND eagv.attr_group_name = 'XXAH_SUPPLIER_STATUS';
   BEGIN
      xx_debug_log ('Inside xx_terms_details_check - BEGIN');

      OPEN status_check_cur;

      FETCH status_check_cur INTO l_status, l_action;

      CLOSE status_check_cur;

      IF NVL (l_action, 'X') <> 'CREATE'
      THEN
         OPEN sup_terms_cur;

         FETCH sup_terms_cur BULK COLLECT INTO l_sup_terms_tbl;

         CLOSE sup_terms_cur;

         DELETE FROM XXAH_SUPP_TERMS_DTLS_UPDATED
               WHERE 1 = 1 AND party_id = p_party_id;

         FOR i IN 1 .. l_sup_terms_tbl.COUNT
         LOOP
            SELECT COUNT (*)
              INTO l_count
              FROM POS_SUPP_PROF_EXT_B pspe, ego_attr_groups_v eagv
             WHERE     1 = 1
                   AND eagv.attr_group_id = pspe.attr_group_id
                   AND pspe.pk1_value IS NULL      --for  suppplier level data
                   AND pspe.pk2_value IS NULL      --for  suppplier level data
                   AND pspe.party_id = p_party_id
                   AND eagv.attr_group_name =
                          'XXAH_SUPPLIER_TERMS_DETAILS_MR'
                   AND pspe.c_ext_attr1 = l_sup_terms_tbl (i).vendor_id
                   --AND  TRIM(pspe.c_ext_attr2) = TRIM(l_sup_terms_tbl(i).vendor_name)
                   AND TRIM (NVL (pspe.c_ext_attr3, 'X')) =
                          TRIM (
                             NVL (l_sup_terms_tbl (i).vendor_site_code, 'X'))
                   AND pspe.c_ext_attr4 = l_sup_terms_tbl (i).name
                   AND pspe.c_ext_attr5 = l_sup_terms_tbl (i).term_id
                  AND NVL (replace(pspe.c_ext_attr6,'.',','), 'X') =
                          NVL (TO_CHAR (replace(l_sup_terms_tbl (i).retainage_rate,'.',',')),
                               'X')                  
                  --AND NVL (pspe.c_ext_attr6, 'X') =
                    --      NVL (TO_CHAR (l_sup_terms_tbl (i).retainage_rate),
                      --         'X')
                   AND NVL (pspe.c_ext_attr7, 'X') =
                          NVL (l_sup_terms_tbl (i).org_id, 'X');

            IF l_count = 0
            THEN
               xx_debug_log (
                     'l_sup_terms_tbl(i).vendor_id - '
                  || l_sup_terms_tbl (i).vendor_id);
               xx_debug_log (
                     'l_sup_terms_tbl(i).vendor_site_code - '
                  || l_sup_terms_tbl (i).vendor_site_code);
               xx_debug_log (
                  'l_sup_terms_tbl(i).name - ' || l_sup_terms_tbl (i).name);
               xx_debug_log (
                     'l_sup_terms_tbl(i).term_id - '
                  || l_sup_terms_tbl (i).term_id);
               xx_debug_log (
                     'l_sup_terms_tbl(i).retainage_rate - '
                  || l_sup_terms_tbl (i).retainage_rate);
               xx_debug_log (
                     'l_sup_terms_tbl(i).org_id - '
                  || l_sup_terms_tbl (i).org_id);

               --Payment Terms is new/updated
               --Add this to a table and update the status of the supplier as INACTIVE and send notification for approval
               INSERT INTO XXAH_SUPP_TERMS_DTLS_UPDATED (party_id,
                                                         vendor_id,
                                                         vendor_name,
                                                         vendor_site_code,
                                                         terms_name,
                                                         terms_id,
                                                         created_by,
                                                         creation_date,
                                                         last_updated_by,
                                                         last_update_date,
                                                         retainage_rate,
                                                         org_id)
                    VALUES (p_party_id,
                            l_sup_terms_tbl (i).vendor_id,
                            l_sup_terms_tbl (i).vendor_name,
                            l_sup_terms_tbl (i).vendor_site_code,
                            l_sup_terms_tbl (i).name,
                            l_sup_terms_tbl (i).term_id,
                            l_sup_terms_tbl (i).user_id,
                            SYSDATE,
                            l_sup_terms_tbl (i).user_id,
                            SYSDATE,
                            l_sup_terms_tbl (i).retainage_rate,
                            l_sup_terms_tbl (i).org_id);

               IF l_modified_flag = 'N'
               THEN
                  l_modified_flag := 'Y';
                  l_user_id := l_sup_terms_tbl (i).user_id;
               END IF;
            END IF;
         END LOOP;

         IF l_modified_flag = 'Y'
         THEN
            l_action := 'TERMS_UPDATE';
            xx_update_status (p_party_id,
                              l_supplier_status,
                              l_action,
                              l_user_id);
            xx_update_approval_status (p_party_id,
                                       l_approval_status,
                                       l_action,
                                       NULL,
                                       l_user_id);
         END IF;
      ELSE
         OPEN sup_terms_cur;

         FETCH sup_terms_cur BULK COLLECT INTO l_sup_terms_tbl;

         CLOSE sup_terms_cur;

         DELETE FROM XXAH_SUPP_TERMS_DTLS_UPDATED
               WHERE 1 = 1 AND party_id = p_party_id;

         FOR i IN 1 .. l_sup_terms_tbl.COUNT
         LOOP
            --Bank account is new/updated
            --Add this to a table and update the status of the supplier as INACTIVE and send notification for approval
            INSERT INTO XXAH_SUPP_TERMS_DTLS_UPDATED (party_id,
                                                      vendor_id,
                                                      vendor_name,
                                                      vendor_site_code,
                                                      terms_name,
                                                      terms_id,
                                                      created_by,
                                                      creation_date,
                                                      last_updated_by,
                                                      last_update_date,
                                                      retainage_rate,
                                                      org_id)
                 VALUES (p_party_id,
                         l_sup_terms_tbl (i).vendor_id,
                         l_sup_terms_tbl (i).vendor_name,
                         l_sup_terms_tbl (i).vendor_site_code,
                         l_sup_terms_tbl (i).name,
                         l_sup_terms_tbl (i).term_id,
                         l_sup_terms_tbl (i).user_id,
                         SYSDATE,
                         l_sup_terms_tbl (i).user_id,
                         SYSDATE,
                         to_number(l_sup_terms_tbl (i).retainage_rate),
                         l_sup_terms_tbl (i).org_id);
         END LOOP;
      END IF;

      xx_debug_log ('Inside xx_terms_details_check - END');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log ('Exception in xx_terms_details_check - ' || SQLERRM);
   END xx_terms_details_check;

   ------------------Procedure to check if Bank details is updated or not
   PROCEDURE xx_bank_details_check (p_party_id IN hz_parties.party_id%TYPE)
   IS
      CURSOR sup_bank_cur
      IS
         --Supplier site level details
         SELECT ieb.bank_account_num,
                ieb.bank_account_name,
                ieb.iban,
                ieb.currency_code,
                ieb.check_digits,
                cbbv.bank_name,
                cbbv.bank_branch_name,
                asp.vendor_name,
                asp.vendor_id,
                asa.vendor_site_code,
                asp.party_id,
                asa.org_id,
                ieb.last_updated_by user_id
           FROM apps.iby_pmt_instr_uses_all instrument,
                apps.iby_account_owners owners,
                apps.iby_external_payees_all payees,
                apps.iby_ext_bank_accounts ieb,
                apps.ap_supplier_sites_all asa,
                apps.ap_suppliers asp,
                apps.ce_bank_branches_v cbbv
          WHERE     1 = 1
                AND owners.ext_bank_account_id = ieb.ext_bank_account_id
                AND owners.ext_bank_account_id = instrument.instrument_id --(+)
                AND payees.ext_payee_id = instrument.ext_pmt_party_id    --(+)
                AND cbbv.branch_party_id = ieb.branch_id
                AND payees.payee_party_id = owners.account_owner_party_id
                AND payees.supplier_site_id = asa.vendor_site_id
                AND asa.vendor_id = asp.vendor_id
                AND payees.party_site_id = asa.party_site_id
                AND asp.party_id = p_party_id
                AND TRUNC (IEB.last_update_date) = TRUNC (SYSDATE) --Added last update date to make sure recently updated record alone is taken for consideration
         UNION
         --Supplier level Bank assignments
         SELECT IEBA.BANK_ACCOUNT_NUM,
                IEBA.BANK_ACCOUNT_NAME,
                ieba.iban,
                ieba.currency_code,
                ieba.check_digits,
                cbv.BANK_NAME,
                CBBV.BANK_BRANCH_NAME,
                VENDOR_NAME,
                aps.vendor_id,
                NULL vendor_site_code,
                aps.party_id,
                NULL org_id,
                ieba.last_updated_by user_id
           FROM apps.AP_SUPPLIERS APS,
                apps.IBY_EXTERNAL_PAYEES_ALL IEPA,
                apps.IBY_PMT_INSTR_USES_ALL IPIUA,
                APPS.IBY_EXT_BANK_ACCOUNTS IEBA,
                apps.ce_banks_v cbv,
                apps.ce_bank_BRANCHES_V CBBV
          WHERE     1 = 1
                AND APS.party_id = p_party_id
                AND IEPA.PAYEE_PARTY_ID = APS.PARTY_ID
                AND PARTY_SITE_ID IS NULL
                AND SUPPLIER_SITE_ID IS NULL
                AND IPIUA.EXT_PMT_PARTY_ID(+) = IEPA.EXT_PAYEE_ID
                AND IEBA.EXT_BANK_ACCOUNT_ID(+) = IPIUA.INSTRUMENT_ID
                AND IEBA.BANK_ID = cbv.BANK_PARTY_ID(+)
                AND IEBA.BRANCH_ID = CBBV.BRANCH_PARTY_ID(+)
                AND IEBA.BANK_ACCOUNT_NUM IS NOT NULL
                AND TRUNC (IEBA.last_update_date) = TRUNC (SYSDATE)
         UNION
         --Supplier Address level Bank assignments
         SELECT IEBA.BANK_ACCOUNT_NUM,
                IEBA.BANK_ACCOUNT_NAME,
                ieba.iban,
                ieba.currency_code,
                ieba.check_digits,
                cbv.BANK_NAME,
                CBBV.BANK_BRANCH_NAME,
                VENDOR_NAME,
                aps.vendor_id,
                NULL vendor_site_code,
                aps.party_id,
                NULL org_id,
                ieba.last_updated_by user_id
           FROM apps.AP_SUPPLIERS APS,
                apps.IBY_EXTERNAL_PAYEES_ALL IEPA,
                apps.IBY_PMT_INSTR_USES_ALL IPIUA,
                APPS.IBY_EXT_BANK_ACCOUNTS IEBA,
                apps.ce_banks_v cbv,
                apps.ce_bank_BRANCHES_V CBBV
          WHERE     1 = 1
                AND APS.party_id = p_party_id
                AND IEPA.PAYEE_PARTY_ID = APS.PARTY_ID
                --         AND PARTY_SITE_ID IS NULL
                --         AND SUPPLIER_SITE_ID IS NULL
                AND IPIUA.EXT_PMT_PARTY_ID(+) = IEPA.EXT_PAYEE_ID
                AND IEBA.EXT_BANK_ACCOUNT_ID(+) = IPIUA.INSTRUMENT_ID
                AND IEBA.BANK_ID = cbv.BANK_PARTY_ID(+)
                AND IEBA.BRANCH_ID = CBBV.BRANCH_PARTY_ID(+)
                AND IEBA.BANK_ACCOUNT_NUM IS NOT NULL
                AND TRUNC (IEBA.last_update_date) = TRUNC (SYSDATE);

      TYPE l_sup_bank_rec IS TABLE OF sup_bank_cur%ROWTYPE;

      l_sup_bank_tbl      l_sup_bank_rec;
      l_supplier_status   VARCHAR2 (20) := 'INACTIVE';
      l_count             NUMBER := 0;
      l_action            pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_approval_status   VARCHAR2 (20) := 'NA';
      l_status            pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_modified_flag     VARCHAR2 (1) := 'N';
      l_user_id           fnd_user.user_id%TYPE;

      CURSOR status_check_cur
      IS
         SELECT c_ext_attr1, c_ext_attr2
           FROM pos_supp_prof_ext_b pose, ego_attr_groups_v eagv
          WHERE     1 = 1
                AND party_id = p_party_id
                AND eagv.attr_group_id = pose.attr_group_id
                AND eagv.attr_group_name = 'XXAH_SUPPLIER_STATUS';
   BEGIN
      xx_debug_log ('Inside xx_bank_details_check - BEGIN');

      OPEN status_check_cur;

      FETCH status_check_cur INTO l_status, l_action;

      CLOSE status_check_cur;

      IF NVL (l_action, 'X') <> 'CREATE'
      THEN
         OPEN sup_bank_cur;

         FETCH sup_bank_cur BULK COLLECT INTO l_sup_bank_tbl;

         CLOSE sup_bank_cur;

         FOR i IN 1 .. l_sup_bank_tbl.COUNT
         LOOP
            SELECT COUNT (*)
              INTO l_count
              FROM POS_SUPP_PROF_EXT_B pspe, ego_attr_groups_v eagv
             WHERE     1 = 1
                   AND eagv.attr_group_id = pspe.attr_group_id
                   AND pspe.pk1_value IS NULL      --for  suppplier level data
                   AND pspe.pk2_value IS NULL      --for  suppplier level data
                   AND pspe.party_id = p_party_id
                   AND eagv.attr_group_name = 'XXAH_SUPPLIER_BANK_DETAILS_MR'
                   AND pspe.n_ext_attr1 = l_sup_bank_tbl (i).vendor_id
                   AND NVL (pspe.n_ext_attr2, -9999) =
                          NVL (l_sup_bank_tbl (i).org_id, -9999)
                   AND TRIM (NVL (pspe.c_ext_attr1, 'X')) =
                          TRIM (
                             NVL (l_sup_bank_tbl (i).vendor_site_code, 'X'))
                   --AND  TRIM(pspe.c_ext_attr2) = TRIM(l_sup_bank_tbl(i).vendor_name)
                   AND pspe.c_ext_attr3 = l_sup_bank_tbl (i).bank_name
                   AND pspe.c_ext_attr4 = l_sup_bank_tbl (i).bank_branch_name
                   AND pspe.c_ext_attr5 = l_sup_bank_tbl (i).bank_account_num
                   AND NVL (pspe.c_ext_attr6, 'X') =
                          NVL (l_sup_bank_tbl (i).bank_account_name, 'X')
                   AND NVL (pspe.c_ext_attr7, 'X') =
                          NVL (l_sup_bank_tbl (i).iban, 'X')
                   AND NVL (pspe.c_ext_attr8, 'X') =
                          NVL (l_sup_bank_tbl (i).currency_code, 'X')
                   AND NVL (pspe.c_ext_attr9, 'X') =
                          NVL (l_sup_bank_tbl (i).check_digits, 'X');

            IF l_count = 0
            THEN
               --Bank account is new/updated
               --Add this to a table and update the status of the supplier as INACTIVE and send notification for approval
               INSERT INTO XXAH_SUPP_BANK_DTLS_UPDATED (party_id,
                                                        vendor_id,
                                                        org_id,
                                                        vendor_name,
                                                        vendor_site_code,
                                                        bank_name,
                                                        bank_branch_name,
                                                        bank_account_num,
                                                        bank_account_name,
                                                        iban,
                                                        currency_code,
                                                        check_digits,
                                                        created_by,
                                                        creation_date,
                                                        last_updated_by,
                                                        last_update_date)
                    VALUES (p_party_id,
                            l_sup_bank_tbl (i).vendor_id,
                            l_sup_bank_tbl (i).org_id,
                            l_sup_bank_tbl (i).vendor_name,
                            l_sup_bank_tbl (i).vendor_site_code,
                            l_sup_bank_tbl (i).bank_name,
                            l_sup_bank_tbl (i).bank_branch_name,
                            l_sup_bank_tbl (i).bank_account_num,
                            l_sup_bank_tbl (i).bank_account_name,
                            l_sup_bank_tbl (i).iban,
                            l_sup_bank_tbl (i).currency_code,
                            l_sup_bank_tbl (i).check_digits,
                            l_sup_bank_tbl (i).user_id,
                            SYSDATE,
                            l_sup_bank_tbl (i).user_id,
                            SYSDATE);

               IF l_modified_flag = 'N'
               THEN
                  l_modified_flag := 'Y';
                  l_user_id := l_sup_bank_tbl (i).user_id;
               END IF;
            END IF;
         END LOOP;

         IF l_modified_flag = 'Y'
         THEN
            l_action := 'BANK_UPDATE';
            xx_update_status (p_party_id,
                              l_supplier_status,
                              l_action,
                              l_user_id);
            xx_update_approval_status (p_party_id,
                                       l_approval_status,
                                       l_action,
                                       NULL,
                                       l_user_id);
         END IF;
      ELSE
         OPEN sup_bank_cur;

         FETCH sup_bank_cur BULK COLLECT INTO l_sup_bank_tbl;

         CLOSE sup_bank_cur;

         DELETE FROM XXAH_SUPP_BANK_DTLS_UPDATED
               WHERE 1 = 1 AND party_id = p_party_id;

         FOR i IN 1 .. l_sup_bank_tbl.COUNT
         LOOP
            --Bank account is new/updated
            --Add this to a table and update the status of the supplier as INACTIVE and send notification for approval
            INSERT INTO XXAH_SUPP_BANK_DTLS_UPDATED (party_id,
                                                     vendor_id,
                                                     org_id,
                                                     vendor_name,
                                                     vendor_site_code,
                                                     bank_name,
                                                     bank_branch_name,
                                                     bank_account_num,
                                                     bank_account_name,
                                                     iban,
                                                     currency_code,
                                                     check_digits,
                                                     created_by,
                                                     creation_date,
                                                     last_updated_by,
                                                     last_update_date)
                 VALUES (p_party_id,
                         l_sup_bank_tbl (i).vendor_id,
                         l_sup_bank_tbl (i).org_id,
                         l_sup_bank_tbl (i).vendor_name,
                         l_sup_bank_tbl (i).vendor_site_code,
                         l_sup_bank_tbl (i).bank_name,
                         l_sup_bank_tbl (i).bank_branch_name,
                         l_sup_bank_tbl (i).bank_account_num,
                         l_sup_bank_tbl (i).bank_account_name,
                         l_sup_bank_tbl (i).iban,
                         l_sup_bank_tbl (i).currency_code,
                         l_sup_bank_tbl (i).check_digits,
                         l_sup_bank_tbl (i).user_id,
                         SYSDATE,
                         l_sup_bank_tbl (i).user_id,
                         SYSDATE);
         END LOOP;
      END IF;

      xx_debug_log ('Inside xx_bank_details_check - END');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log ('Exception in xx_bank_details_check - ' || SQLERRM);
   END xx_bank_details_check;

   -----------------Reset approval Flag-----------------------
   PROCEDURE xx_reset_approval_flag (
      p_party_id   IN hz_parties.party_id%TYPE,
      p_user_id    IN fnd_user.user_id%TYPE)
   IS
      lv_attr_group_name         VARCHAR2 (100) := 'XXAH_SUPPLIER_APPROVERS';
      lv_pk_column_values        ego_col_name_value_pair_array;
      lv_attributes_row_table    ego_user_attr_row_table;
      lv_attributes_data_table   ego_user_attr_data_table;
      lv_class_code              ego_col_name_value_pair_array;
      ln_msg_index_out           NUMBER := NULL;
      lv_failed_row_id_list      VARCHAR2 (100) := NULL;

      ln_party_id                hz_parties.party_id%TYPE;
      lv_approval_flag           VARCHAR2 (20) := 'N';
      ln_user_id                 fnd_user.user_id%TYPE;
      ln_resp_appl_id            fnd_responsibility_tl.application_id%TYPE;

      lv_return_status           VARCHAR2 (10) := NULL;
      ln_msg_count               NUMBER := 0;
      lv_msg_data                VARCHAR2 (1000) := NULL;
      ln_errorcode               NUMBER := 0;
      lv_attr_name               VARCHAR2 (20) := 'START_APPROVAL';
   BEGIN
      xx_debug_log ('Inside xx_reset_approval_flag - BEGIN');
      ln_party_id := p_party_id;
      ln_user_id := p_user_id;
      set_org_context (ln_user_id, ln_resp_appl_id);
      lv_pk_column_values :=
         ego_col_name_value_pair_array (
            ego_col_name_value_pair_obj ('PARTY_ID', ln_party_id));
      lv_class_code :=
         ego_col_name_value_pair_array (
            ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE'));
      lv_attributes_data_table :=
         ego_user_attr_data_table (
            ego_user_attr_data_obj (row_identifier         => 1,
                                    attr_name              => lv_attr_name,
                                    attr_value_str         => lv_approval_flag,
                                    attr_value_num         => NULL,
                                    attr_value_date        => NULL,
                                    attr_disp_value        => NULL,
                                    attr_unit_of_measure   => NULL,
                                    user_row_identifier    => 1));
      lv_attributes_row_table :=
         ego_user_attr_row_table (
            ego_user_attr_row_obj (
               row_identifier      => 1,
               attr_group_id       => NULL,
               attr_group_app_id   => ln_resp_appl_id,
               attr_group_type     => 'POS_SUPP_PROFMGMT_GROUP',
               attr_group_name     => lv_attr_group_name,
               data_level          => 'SUPP_LEVEL', --for site level use SUPP_SITE_LEVEL
               data_level_1        => 'N',
               data_level_2        => NULL,
               data_level_3        => NULL,
               data_level_4        => NULL,
               data_level_5        => NULL,
               transaction_type    => ego_user_attrs_data_pvt.g_sync_mode));
      pos_vendor_pub_pkg.process_user_attrs_data (
         p_api_version                   => 1.0,
         p_attributes_row_table          => lv_attributes_row_table,
         p_attributes_data_table         => lv_attributes_data_table,
         p_pk_column_name_value_pairs    => lv_pk_column_values,
         p_class_code_name_value_pairs   => lv_class_code,
         x_failed_row_id_list            => lv_failed_row_id_list,
         x_return_status                 => lv_return_status,
         x_errorcode                     => ln_errorcode,
         x_msg_count                     => ln_msg_count,
         x_msg_data                      => lv_msg_data);

      IF lv_return_status = 'S'
      THEN
         xx_debug_log ('return_status: ' || lv_return_status);
         xx_debug_log ('msg_data: ' || lv_msg_data);
         COMMIT;
      ELSE
         xx_debug_log ('Error Message Count : ' || ln_msg_count);
         xx_debug_log ('Error Message Data  : ' || lv_msg_data);
         xx_debug_log ('Error Code          : ' || ln_errorcode);
         xx_debug_log ('Entering Error Loop ');

         FOR i IN 1 .. ln_msg_count
         LOOP
            fnd_msg_pub.get (p_msg_index       => i,
                             p_data            => lv_msg_data,
                             p_encoded         => 'F',
                             p_msg_index_out   => ln_msg_index_out);
            fnd_message.set_encoded (lv_msg_data);
            xx_debug_log ('Inside Error Loop : ' || i || ', ' || lv_msg_data);
         END LOOP;
      END IF;

      xx_debug_log ('Inside xx_reset_approval_flag - END');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log ('Exception in xx_reset_approval_flag - ' || SQLERRM);
   END xx_reset_approval_flag;

   --------------Main function which gets called during business event-----
   FUNCTION xx_capture_event_parameters (
      p_subscription_guid   IN            RAW,
      p_event               IN OUT NOCOPY wf_event_t)
      RETURN VARCHAR2
   IS
      l_wf_parameter_list_t          wf_parameter_list_t;
      l_parameter_name               VARCHAR2 (30);
      l_parameter_value              VARCHAR2 (4000);
      n_total_number_of_parameters   INTEGER;
      n_current_parameter_position   NUMBER := 1;
      l_transaction_type             VARCHAR2 (50);
      l_attr_group_name              VARCHAR2 (50);
      l_entity_name                  VARCHAR2 (50);
      l_entity_key                   VARCHAR2 (50);
      l_event_name                   VARCHAR2 (100);
      l_party_id                     hz_parties.party_id%TYPE;
      l_extension_id                 NUMBER;
      l_dml_type                     VARCHAR2 (10);
      l_vendor_id                    ap_suppliers.vendor_id%TYPE;
      l_user_id                      fnd_user.user_id%TYPE;
      l_supplier_status              VARCHAR2 (20) := 'INACTIVE';
      l_start_approval               VARCHAR2 (10) := 'N';
      l_action                       pos_supp_prof_ext_b.c_ext_attr1%TYPE;
      l_approval_status              VARCHAR2 (20) := 'NA';
      l_unit_manager                 per_all_people_f.full_name%TYPE;
      l_business_controller          per_all_people_f.full_name%TYPE;
      l_subject                      VARCHAR2 (1000);
      l_message                      VARCHAR2 (32767);
      l_um_email                     per_all_people_f.email_address%TYPE;
      l_bc_email                     per_all_people_f.email_address%TYPE;
      l_vendor_name                  ap_suppliers.vendor_name%TYPE;
      l_vendor_number                ap_suppliers.segment1%TYPE;
      l_approver_mail                per_all_people_f.email_address%TYPE;
      l_comments                     pos_supp_prof_ext_b.c_ext_attr2%TYPE;
      l_status                       pos_supp_prof_ext_b.c_ext_attr2%TYPE;
      l_creation_date                ap_suppliers.creation_date%TYPE;
      l_db_rating                    ap_suppliers.attribute12%TYPE;
      l_terms_name                   ap_terms.name%TYPE;
      l_iban                         iby_ext_bank_accounts.iban%TYPE;

      CURSOR approver_email_cur (
         p_extension_id   IN POS_SUPP_PROF_EXT_B.extension_id%TYPE)
      IS
         SELECT NVL (pspe.c_ext_attr1, 'X'),
                NVL (pspe.c_ext_attr2, 'X'),
                papf1.email_address,
                papf2.email_address
           FROM POS_SUPP_PROF_EXT_B pspe,
                per_all_people_f papf1,
                per_all_people_f papf2
          WHERE     1 = 1
                AND pspe.extension_id = p_extension_id
                AND papf1.full_name(+) = pspe.c_ext_attr1
                AND papf2.full_name(+) = pspe.c_ext_attr2
                AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                               NVL (
                                                  papf2.EFFECTIVE_START_DATE,
                                                  SYSDATE))
                                        AND TRUNC (
                                               NVL (papf2.EFFECTIVE_END_DATE,
                                                    SYSDATE))
                AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                               NVL (
                                                  papf1.EFFECTIVE_START_DATE,
                                                  SYSDATE))
                                        AND TRUNC (
                                               NVL (papf1.EFFECTIVE_END_DATE,
                                                    SYSDATE))
                AND ROWNUM = 1;

      CURSOR approved_status_cur (
         p_extension_id   IN POS_SUPP_PROF_EXT_B.extension_id%TYPE)
      IS
         SELECT c_ext_attr1, c_ext_attr2
           FROM pos_supp_prof_ext_b
          WHERE extension_id = p_extension_id;

      CURSOR creation_date_cur (
         p_vendor_id   IN ap_suppliers.vendor_id%TYPE)
      IS
         SELECT TRUNC (creation_date), status.c_ext_attr1
           FROM ap_suppliers ap,
                (SELECT party_id, c_ext_attr1, c_ext_attr2
                   FROM pos_supp_prof_ext_b pspe, ego_attr_groups_v eagv
                  WHERE     1 = 1
                        AND eagv.attr_group_id = pspe.attr_group_id
                        AND eagv.attr_group_name = 'XXAH_SUPPLIER_STATUS')
                status
          WHERE     1 = 1
                AND ap.vendor_id = p_vendor_id
                AND ap.party_id = status.party_id(+) --AND status.c_ext_attr1 IS  NOT  NULL
                                                    ;

      CURSOR bank_details_cur (
         p_party_id   IN hz_parties.party_id%TYPE)
      IS
         SELECT party_id,
                vendor_id,
                vendor_name,
                DECODE (vendor_site_code, 'ZZZZZZZ', NULL, vendor_site_code)
                   vendor_site_code,
                bank_name,
                bank_branch_name,
                bank_account_num,
                bank_account_name,
                IBAN,
                currency_code,
                check_digits
           FROM (  SELECT party_id,
                          vendor_id,
                          vendor_name,
                          MIN (NVL (vendor_site_code, 'ZZZZZZZ'))
                             vendor_site_code,
                          bank_name,
                          bank_branch_name,
                          bank_account_num,
                          bank_account_name,
                          IBAN,
                          currency_code,
                          check_digits
                     FROM XXAH_SUPP_BANK_DTLS_UPDATED
                    WHERE 1 = 1 AND party_id = p_party_id
                 GROUP BY party_id,
                          vendor_id,
                          vendor_name,
                          bank_name,
                          bank_branch_name,
                          bank_account_num,
                          bank_account_name,
                          IBAN,
                          currency_code,
                          check_digits
                 UNION
                 SELECT party_id,
                        vendor_id,
                        vendor_name,
                        vendor_site_code,
                        bank_name,
                        bank_branch_name,
                        bank_account_num,
                        bank_account_name,
                        IBAN,
                        currency_code,
                        check_digits
                   FROM XXAH_SUPP_BANK_DTLS_UPDATED
                  WHERE     1 = 1
                        AND party_id = p_party_id
                        AND vendor_site_code IS NOT NULL);

      TYPE bank_details_rec IS TABLE OF bank_details_cur%ROWTYPE;

      l_bank_tbl                     bank_details_rec;

      CURSOR term_details_cur (
         p_party_id   IN hz_parties.party_id%TYPE)
      IS
         SELECT xst.party_id,
                xst.vendor_id,
                xst.vendor_name,
                xst.vendor_site_code,
                xst.terms_name,
                xst.terms_id,
                xst.retainage_rate,
                xst.org_id,
                hou.name
           FROM XXAH_SUPP_TERMS_DTLS_UPDATED xst,
                hr_all_organization_units hou
          WHERE     1 = 1
                AND xst.party_id = p_party_id
                AND xst.org_id = hou.organization_id(+);

      TYPE term_details_rec IS TABLE OF term_details_cur%ROWTYPE;

      l_terms_tbl                    term_details_rec;

      CURSOR check_status_cur (
         p_party_id   IN hz_parties.party_id%TYPE)
      IS
         SELECT c_ext_attr1
           FROM pos_supp_prof_ext_b pspe, ego_attr_groups_v eagv
          WHERE     1 = 1
                AND eagv.attr_group_id = pspe.attr_group_id
                AND eagv.attr_group_name = 'XXAH_SUPPLIER_STATUS'
                AND pspe.party_id = p_party_id;

      CURSOR supplier_contacts_cur (
         p_party_id   IN hz_parties.party_id%TYPE)
      IS
         SELECT INITCAP (hps.person_pre_name_adjunct) title,
                hps.party_name contact_name,
                hps.person_title contact_title
           FROM hz_parties hp,
                hz_relationships hr,
                hz_parties hps,
                hz_parties hp2,
                ap_suppliers aps
          WHERE     1 = 1
                AND aps.party_id = p_party_id
                AND hp.party_id = aps.party_id
                AND hr.object_id = hp.party_id
                AND hr.subject_id = hps.party_id
                AND hr.object_type = 'ORGANIZATION'
                AND hr.subject_type = 'PERSON'
                AND hr.relationship_code = 'CONTACT_OF'
                AND hr.subject_table_name = 'HZ_PARTIES'
                AND hr.object_table_name = 'HZ_PARTIES'
                AND hr.status = 'A'
                AND TRUNC (hr.end_date) >= TRUNC (SYSDATE)
                AND hp2.party_id = hr.party_id;

      CURSOR supplier_address_cur (
         p_party_id   IN hz_parties.party_id%TYPE)
      IS
         SELECT address_line1 street,
                city,
                ftt.territory_short_name country,
                apsa.vendor_site_code address_name,
                apt.name,
                apsa.retainage_rate
           FROM ap_supplier_sites_all apsa,
                fnd_territories_tl ftt,
                ap_suppliers aps,
                ap_terms apt
          WHERE     1 = 1
                AND aps.party_id = p_party_id
                AND apsa.vendor_id = aps.vendor_id
                AND ftt.territory_code = apsa.country
                AND apt.term_id(+) = apsa.terms_id;

      CURSOR old_term_details_cur (
         p_party_id           IN hz_parties.party_id%TYPE,
         p_vendor_site_code   IN ap_supplier_sites_all.vendor_site_code%TYPE,
         p_org_id             IN ap_supplier_sites_all.org_id%TYPE)
      IS
         SELECT pspe.c_ext_attr4 terms_name, pspe.c_ext_attr6 retainage_rate
           FROM pos_supp_prof_ext_b pspe, ego_attr_groups_v eagv
          WHERE     1 = 1
                AND pspe.party_id = p_party_id
                AND pspe.attr_group_id = eagv.attr_group_id
                AND eagv.attr_group_name = 'XXAH_SUPPLIER_TERMS_DETAILS_MR'
                AND NVL (pspe.c_ext_attr7, 'X') =
                       NVL (TO_CHAR (p_org_id), 'X')
                AND TRIM (NVL (pspe.c_ext_attr3, '-XYZ')) =
                       TRIM (NVL (p_vendor_site_code, '-XYZ'));

      l_instance_url                 fnd_lookup_values.meaning%TYPE;
      end_execution                  EXCEPTION;
   BEGIN
      --Clear the debug table to begin with
      l_wf_parameter_list_t := p_event.getparameterlist ();
      l_event_name := p_event.geteventname ();
      n_total_number_of_parameters := l_wf_parameter_list_t.COUNT ();
      xx_debug_log ('Name of the event is =>' || l_event_name);
      --    xx_debug_log('Key of the event is =>' || p_event.geteventkey());
      l_instance_url := get_instance_url ();

      IF l_event_name = 'oracle.apps.pos.supplier.profile'
      THEN
         l_entity_name := p_event.getvalueforparameter ('ENTITY_NAME');
         l_party_id := p_event.getvalueforparameter ('PARTY_ID');
         g_party_id := l_party_id;
         l_transaction_type :=
            p_event.getvalueforparameter ('TRANSACTION_TYPE');
         l_entity_key := p_event.getvalueforparameter ('ENTITY_KEY');
         xx_debug_log ('Event Name - ' || l_event_name);
         xx_debug_log ('Parameters Passed');
         xx_debug_log ('Party ID - ' || l_party_id);
         xx_debug_log ('Transaction Type - ' || l_transaction_type);
         xx_debug_log ('Entity Name - ' || l_entity_name);
         xx_debug_log ('Entity Key - ' || l_entity_key);

         IF l_entity_name = 'BANKING_DETAIL'
         THEN
            --Check if the Bank details have been updated
            xx_bank_details_check (l_party_id);
         ELSE
            xx_terms_details_check (l_party_id);
         END IF;
      ELSIF l_event_name = 'oracle.apps.pos.sdh.ext.postAttributeChange'
      THEN
         l_attr_group_name := p_event.getvalueforparameter ('ATTR_GROUP_NAME');
         l_party_id := p_event.getvalueforparameter ('PARTY_ID');
         g_party_id := l_party_id;
         l_extension_id := p_event.getvalueforparameter ('EXTENSION_ID');
         l_dml_type := p_event.getvalueforparameter ('DML_TYPE');
         xx_debug_log ('Party ID - ' || l_party_id);
         xx_debug_log ('Attribute Group name - ' || l_attr_group_name);
         xx_debug_log ('Extension ID - ' || l_extension_id);
         xx_debug_log ('DML Type - ' || l_dml_type);

         SELECT vendor_name,
                segment1,
                aps.attribute12,
                apt.name
           INTO l_vendor_name,
                l_vendor_number,
                l_db_rating,
                l_terms_name
           FROM ap_suppliers aps, ap_terms apt
          WHERE     1 = 1
                AND aps.party_id = l_party_id
                AND apt.term_id(+) = aps.terms_id;

         IF l_attr_group_name = 'XXAH_SUPPLIER_APPROVERS'
         THEN
            BEGIN
               SELECT NVL (c_ext_attr3, 'N'),
                      NVL (papf.email_address, fu.email_address),
                      pspe.last_updated_by
                 INTO l_start_approval, l_approver_mail, l_user_id
                 FROM POS_SUPP_PROF_EXT_B pspe,
                      per_all_people_f papf,
                      fnd_user fu
                WHERE     1 = 1
                      AND extension_id = l_extension_id
                      AND papf.party_id = fu.person_party_id
                      AND fu.user_id = pspe.last_updated_by
                      AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                     NVL (
                                                        papf.EFFECTIVE_START_DATE,
                                                        SYSDATE))
                                              AND TRUNC (
                                                     NVL (
                                                        papf.EFFECTIVE_END_DATE,
                                                        SYSDATE));
            EXCEPTION
               WHEN OTHERS
               THEN
                  xx_debug_log (
                     'Exception while derivng approval flag - ' || SQLERRM);
                  l_start_approval := 'N';
            END;

            BEGIN
               SELECT NVL (pspe.c_ext_attr2, 'X')
                 INTO l_action
                 FROM POS_SUPP_PROF_EXT_B pspe, ego_attr_groups_v eagv
                WHERE     1 = 1
                      AND pspe.party_id = l_party_id
                      AND pspe.attr_group_id = eagv.attr_group_id
                      AND eagv.attr_group_name = 'XXAH_SUPPLIER_STATUS';
            EXCEPTION
               WHEN OTHERS
               THEN
                  xx_debug_log (
                     'Exception while derivng approval flag action - ' || SQLERRM);
                  l_start_approval := 'N';
            END;

            IF l_start_approval = 'Y'
            THEN
               --Check if the supplier is in inactive status before sending notification
               --If supplier is active , then reset approval flag and send notification that workflow
               --can only be initiated for inactive suppliers
               OPEN check_status_cur (l_party_id);

               FETCH check_status_cur INTO l_status;

               CLOSE check_status_cur;

               IF NVL (l_status, 'X') <> 'INACTIVE'
               THEN
                  l_subject :=
                     'FYI. Supplier Approval Workflow cannot be initiated.';
                  l_message :=
                        'The Supplier - '
                     || l_vendor_name
                     || ' is active and hence approval workflow cannot be initiated. Kindly update Bank /Payment Terms details to initiate supplier approval workflow.';
                  xx_send_mail (l_approver_mail,
                                NULL,
                                NULL,
                                l_subject,
                                l_message);
                  xx_reset_approval_flag (l_party_id, l_user_id);
                  RAISE end_execution;
               END IF;

               --Check if unit manager and business controller is added for sending notification.
               OPEN approver_email_cur (l_extension_id);

               FETCH approver_email_cur
                  INTO l_unit_manager,
                       l_business_controller,
                       l_um_email,
                       l_bc_email;

               CLOSE approver_email_cur;

               /*
               SELECT  NVL(c_ext_attr1,'X'),NVL(c_ext_attr2,'Y')
                 INTO  l_unit_manager,l_business_controller
                 FROM  POS_SUPP_PROF_EXT_B
                WHERE  1=1
                  AND  extension_id = l_extension_id;
               */
               IF l_action = 'CREATE'
               THEN
                  IF l_unit_manager <> 'X' AND l_business_controller <> 'X'
                  THEN
                     --Send notification email to Unit manager for Approval.
                     l_iban := get_iban (l_party_id, 1);
                     l_subject :=
                           'FYA. Supplier -  '
                        || l_vendor_name
                        || ' needs approval. Action - New Vendor creation';
                     l_message :=
                           'Supplier - '
                        || l_vendor_name
                        || ' has been submitted for approval. Kindly login to EBS application and provide your approval.'
                        || CHR (10)
                        || l_instance_url
                        || CHR (10)
                        || 'Supplier Details:'
                        || CHR (10)
                        || 'Supplier Name - '
                        || l_vendor_name
                        || CHR (10)
                        || 'Supplier Number - '
                        || l_vendor_number
                        || CHR (10)
                        || 'D&B Rating - '
                        || l_db_rating
                        || CHR (10)
                        || 'Supplier Payment Terms - '
                        || l_terms_name
                        || CHR (10)
                        || 'Supplier IBAN - '
                        || l_iban
                        || CHR (10)
                        || CHR (10)
                        || 'Supplier Contact:'
                        || CHR (10)
                        || '------------------'
                        || CHR (10);

                     FOR i IN supplier_contacts_cur (l_party_id)
                     LOOP
                        l_message :=
                              l_message
                           || 'Name - '
                           || i.title
                           || i.contact_name
                           || CHR (10)
                           || 'Title - '
                           || i.contact_title
                           || CHR (10);
                     END LOOP;

                     l_message :=
                           l_message
                        || CHR (10)
                        || 'Address and Payment Terms Details:'
                        || CHR (10)
                        || '-----------------------------------'
                        || CHR (10);

                     FOR i IN supplier_address_cur (l_party_id)
                     LOOP
                        l_message :=
                              l_message
                           || 'Address Name - '
                           || i.address_name
                           || CHR (10)
                           || 'Street - '
                           || i.street
                           || CHR (10)
                           || 'City - '
                           || i.city
                           || CHR (10)
                           || 'Country - '
                           || i.country
                           || CHR (10)
                           || 'Payment Terms - '
                           || i.name
                           || CHR (10)
                           || 'Retainage Rate - '
                           || i.retainage_rate
                           || CHR (10);
                     END LOOP;

                     xx_send_mail (l_um_email,
                                   g_cc_mail,
                                   NULL,
                                   l_subject,
                                   l_message);
                  ELSE
                     --Send notification to the person who started worklfow that busines controller and unit manager is required for approval.
                     l_subject :=
                        'FYI. Unit Manager and Business controller are required for approval.';
                     l_message :=
                        'Please provide Unit Manager and Business controller to initiate supplier approval workflow.';
                     xx_send_mail (l_approver_mail,
                                   NULL,
                                   NULL,
                                   l_subject,
                                   l_message);
                     xx_reset_approval_flag (l_party_id, l_user_id);
                  END IF;
               ELSIF l_action = 'BANK_UPDATE'
               THEN
                  IF l_business_controller <> 'X'
                  THEN
                     --Send notification email to Business controller for Approval.
                     OPEN bank_details_cur (l_party_id);

                     FETCH bank_details_cur BULK COLLECT INTO l_bank_tbl;

                     CLOSE bank_details_cur;

                     l_iban := get_iban (l_party_id, 2);
                     l_subject :=
                           'FYA. Supplier -  '
                        || l_vendor_name
                        || ' needs approval. Action - Vendor Bank details update';
                     l_message :=
                           'Supplier - '
                        || l_vendor_name
                        || ' has been submitted for approval. Kindly login to EBS application and provide your approval. With your approval, you confirm that the supplier has been called back and the bank details have been verified.'
                        || CHR (10)
                        || l_instance_url
                        || CHR (10)
                        || 'Supplier Details:'
                        || CHR (10)
                        || 'Supplier Name - '
                        || l_vendor_name
                        || CHR (10)
                        || 'Supplier Number - '
                        || l_vendor_number
                        || CHR (10)
                        || 'Updated Bank Account Details'
                        || CHR (10)
                        || '----------------------------'
                        || CHR (10)
                        || 'Old IBAN - '
                        || l_iban
                        || CHR (10);

                     FOR i IN 1 .. l_bank_tbl.COUNT
                     LOOP
                        l_message :=
                              l_message
                           || 'Vendor Site Code    - '
                           || NVL (l_bank_tbl (i).vendor_site_code,
                                   'Not Applicable')
                           || CHR (10)
                           || 'Bank Name           - '
                           || l_bank_tbl (i).bank_name
                           || CHR (10)
                           || 'Bank Branch Name    - '
                           || l_bank_tbl (i).bank_branch_name
                           || CHR (10)
                           || 'Bank Account Number - '
                           || l_bank_tbl (i).bank_account_num
                           || CHR (10)
                           || 'Bank Account Name   - '
                           || l_bank_tbl (i).bank_account_name
                           || CHR (10)
                           || 'New IBAN                - '
                           || l_bank_tbl (i).iban
                           || CHR (10)
                           || 'Currency Code       - '
                           || l_bank_tbl (i).currency_code
                           || CHR (10)
                           || 'Check Digits        - '
                           || l_bank_tbl (i).check_digits
                           || CHR (10);
                     END LOOP;

                     xx_send_mail (l_bc_email,
                                   g_cc_mail,
                                   NULL,
                                   l_subject,
                                   l_message);
                  ELSE
                     --Send notification to the person who started worklfow that busines controller is required for approval.
                     l_subject :=
                        'FYI. Business controller is required for approval.';
                     l_message :=
                        'Please provide Business controller to initiate supplier approval workflow.';
                     xx_send_mail (l_approver_mail,
                                   NULL,
                                   NULL,
                                   l_subject,
                                   l_message);
                     xx_reset_approval_flag (l_party_id, l_user_id);
                  END IF;
               ELSIF l_action = 'TERMS_UPDATE'
               THEN
                  IF l_business_controller <> 'X'
                  THEN
                     --Send notification email to Business controller for Approval.
                     OPEN term_details_cur (l_party_id);

                     FETCH term_details_cur BULK COLLECT INTO l_terms_tbl;

                     CLOSE term_details_cur;

                     l_subject :=
                           'FYA. Supplier -  '
                        || l_vendor_name
                        || ' needs approval. Action - Payment Terms update';
                     l_message :=
                           'Supplier - '
                        || l_vendor_name
                        || ' has been submitted for approval. Kindly login to EBS application and provide your approval.'
                        || CHR (10)
                        || l_instance_url
                        || CHR (10)
                        || 'Supplier Details:'
                        || CHR (10)
                        || 'Supplier Name - '
                        || l_vendor_name
                        || CHR (10)
                        || 'Supplier Number - '
                        || l_vendor_number
                        || CHR (10)
                        || 'Updated Payment Terms Details'
                        || CHR (10)
                        || '----------------------------'
                        || CHR (10);

                     FOR i IN 1 .. l_terms_tbl.COUNT
                     LOOP
                        l_message :=
                              l_message
                           || 'Vendor Site Code     - '
                           || NVL (l_terms_tbl (i).vendor_site_code,
                                   'Not Applicable')
                           || CHR (10)
                           || 'Operating Unit       - '
                           || l_terms_tbl (i).name
                           || CHR (10)
                           || 'Terms Name           - '
                           || l_terms_tbl (i).terms_name
                           || CHR (10)
                           || 'Retainage Rate       - '
                           || l_terms_tbl (i).retainage_rate
                           || CHR (10);

                        FOR j
                           IN old_term_details_cur (
                                 l_party_id,
                                 l_terms_tbl (i).vendor_site_code,
                                 l_terms_tbl (i).org_id)
                        LOOP
                           IF TO_CHAR (l_terms_tbl (i).terms_name) <>
                                 TO_CHAR (j.terms_name)
                           THEN
                              l_message :=
                                    l_message
                                 || 'Old Terms Name           - '
                                 || j.terms_name
                                 || CHR (10);
                           END IF;

                           IF NVL (TO_CHAR (l_terms_tbl (i).retainage_rate),
                                   'X') <>
                                 NVL (TO_CHAR (j.retainage_rate), 'X')
                           THEN
                              l_message :=
                                    l_message
                                 || 'Old Retainage Rate       - '
                                 || j.retainage_rate
                                 || CHR (10);
                           END IF;
                        END LOOP;

                        l_message :=
                              l_message
                           || '****************************'
                           || CHR (10);
                     END LOOP;

                     xx_send_mail (l_bc_email,
                                   g_cc_mail,
                                   NULL,
                                   l_subject,
                                   l_message);
                  ELSE
                     --Send notification to the person who started worklfow that busines controller is required for approval.
                     l_subject :=
                        'FYI. Business controller is required for approval.';
                     l_message :=
                        'Please provide Business controller to initiate supplier approval workflow.';
                     xx_send_mail (l_approver_mail,
                                   NULL,
                                   NULL,
                                   l_subject,
                                   l_message);
                     xx_reset_approval_flag (l_party_id, l_user_id);
                  END IF;
               ELSIF l_action = 'BANK_AND_TERMS_UPDATE'
               THEN
                  IF l_business_controller <> 'X'
                  THEN
                     --Send notification email to Business controller for Approval.
                     OPEN bank_details_cur (l_party_id);

                     FETCH bank_details_cur BULK COLLECT INTO l_bank_tbl;

                     CLOSE bank_details_cur;

                     OPEN term_details_cur (l_party_id);

                     FETCH term_details_cur BULK COLLECT INTO l_terms_tbl;

                     CLOSE term_details_cur;

                     l_iban := get_iban (l_party_id, 2);
                     l_subject :=
                           'FYA. Supplier -  '
                        || l_vendor_name
                        || ' needs approval. Action - Bank Details and Payment Terms update';
                     l_message :=
                           'Supplier - '
                        || l_vendor_name
                        || ' has been submitted for approval. Kindly login to EBS application and provide your approval. With your approval, you confirm that the supplier has been called back and the bank details have been verified.'
                        || CHR (10)
                        || l_instance_url
                        || CHR (10)
                        || 'Supplier Details:'
                        || CHR (10)
                        || 'Supplier Name - '
                        || l_vendor_name
                        || CHR (10)
                        || 'Supplier Number - '
                        || l_vendor_number
                        || CHR (10)
                        || 'Updated Bank Account Details'
                        || CHR (10)
                        || '----------------------------'
                        || CHR (10)
                        || 'Old IBAN - '
                        || l_iban
                        || CHR (10);

                     FOR i IN 1 .. l_bank_tbl.COUNT
                     LOOP
                        l_message :=
                              l_message
                           || 'Vendor Site Code    - '
                           || NVL (l_bank_tbl (i).vendor_site_code,
                                   'Not Applicable')
                           || CHR (10)
                           || 'Bank Name           - '
                           || l_bank_tbl (i).bank_name
                           || CHR (10)
                           || 'Bank Branch Name    - '
                           || l_bank_tbl (i).bank_branch_name
                           || CHR (10)
                           || 'Bank Account Number - '
                           || l_bank_tbl (i).bank_account_num
                           || CHR (10)
                           || 'Bank Account Name   - '
                           || l_bank_tbl (i).bank_account_name
                           || CHR (10)
                           || 'New IBAN                - '
                           || l_bank_tbl (i).iban
                           || CHR (10)
                           || 'Currency Code       - '
                           || l_bank_tbl (i).currency_code
                           || CHR (10)
                           || 'Check Digits        - '
                           || l_bank_tbl (i).check_digits
                           || CHR (10);
                     END LOOP;

                     l_message :=
                           l_message
                        || CHR (10)
                        || 'Updated Payment Terms Details'
                        || CHR (10)
                        || '----------------------------'
                        || CHR (10);

                     FOR i IN 1 .. l_terms_tbl.COUNT
                     LOOP
                        l_message :=
                              l_message
                           || 'Vendor Site Code    - '
                           || NVL (l_terms_tbl (i).vendor_site_code,
                                   'Not Applicable')
                           || CHR (10)
                           || 'Operating Unit       - '
                           || l_terms_tbl (i).name
                           || CHR (10)
                           || 'Terms Name           - '
                           || l_terms_tbl (i).terms_name
                           || CHR (10)
                           || 'Retainage Rate       - '
                           || l_terms_tbl (i).retainage_rate
                           || CHR (10);

                        FOR j
                           IN old_term_details_cur (
                                 l_party_id,
                                 l_terms_tbl (i).vendor_site_code,
                                 l_terms_tbl (i).org_id)
                        LOOP
                           IF TO_CHAR (l_terms_tbl (i).terms_name) <>
                                 TO_CHAR (j.terms_name)
                           THEN
                              l_message :=
                                    l_message
                                 || 'Old Terms Name           - '
                                 || j.terms_name
                                 || CHR (10);
                           END IF;

                           IF NVL (TO_CHAR (l_terms_tbl (i).retainage_rate),
                                   'X') <>
                                 NVL (TO_CHAR (j.retainage_rate), 'X')
                           THEN
                              l_message :=
                                    l_message
                                 || 'Old Retainage Rate       - '
                                 || j.retainage_rate
                                 || CHR (10);
                           END IF;
                        END LOOP;

                        l_message :=
                              l_message
                           || '****************************'
                           || CHR (10);
                     END LOOP;

                     xx_send_mail (l_bc_email,
                                   g_cc_mail,
                                   NULL,
                                   l_subject,
                                   l_message);
                  ELSE
                     --Send notification to the person who started worklfow that busines controller is required for approval.
                     l_subject :=
                        'FYI. Business controller is required for approval.';
                     l_message :=
                        'Please provide Business controller to initiate supplier approval workflow.';
                     xx_send_mail (l_approver_mail,
                                   NULL,
                                   NULL,
                                   l_subject,
                                   l_message);
                     xx_reset_approval_flag (l_party_id, l_user_id);
                  END IF;
               END IF;
            END IF;
         ELSIF l_attr_group_name IN ('XXAH_BUSINESS_CONT_APPROVAL',
                                     'XXAH_UNIT_MANAGER_APPROVAL')
         THEN
            OPEN approved_status_cur (l_extension_id);

            FETCH approved_status_cur INTO l_approval_status, l_comments;

            CLOSE approved_status_cur;

            IF l_approval_status <> 'NA'
            THEN
               xx_check_approval (l_attr_group_name,
                                  l_extension_id,
                                  l_party_id,
                                  l_approval_status,
                                  l_comments);
            END IF;
         ELSIF l_attr_group_name = 'XXAH_SUPPLIER_STATUS_DISPLAY'
         THEN
            BEGIN
               SELECT last_updated_by
                 INTO l_user_id
                 FROM pos_supp_prof_ext_b
                WHERE 1 = 1 AND extension_id = l_extension_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  xx_debug_log (
                     'Exception while deriving user id  - ' || SQLERRM);
            END;

            xx_update_status_display (l_party_id, l_user_id);
         END IF;
      ELSIF l_event_name = 'oracle.apps.ap.supplier.event'
      THEN
         --New supplier creation. Update the status as inactive
         l_vendor_id := p_event.getvalueforparameter ('VENDOR_ID');

         OPEN creation_date_cur (l_vendor_id);

         FETCH creation_date_cur INTO l_creation_date, l_status;

         CLOSE creation_date_cur;

         IF l_creation_date = TRUNC (SYSDATE) AND l_status IS NULL
         THEN
            l_action := 'CREATE';

            BEGIN
               SELECT party_id, created_by
                 INTO l_party_id, l_user_id
                 FROM ap_suppliers
                WHERE vendor_id = l_vendor_id;

               g_party_id := l_party_id;
               xx_debug_log ('Vendor ID - ' || l_vendor_id);
               xx_debug_log ('Party ID - ' || l_party_id);
               xx_debug_log ('Create Supplier Event');
               xx_update_status (l_party_id,
                                 l_supplier_status,
                                 l_action,
                                 l_user_id);
               xx_update_approval_status (l_party_id,
                                          l_approval_status,
                                          l_action,
                                          NULL,
                                          l_user_id);
            EXCEPTION
               WHEN OTHERS
               THEN
                  xx_debug_log (
                     'Exception while derivng party_id - ' || SQLERRM);
            END;
         END IF;
      ELSE
         xx_debug_log ('Event Data is =>' || p_event.EVENT_DATA);
         xx_debug_log (
               'Total number of parameters passed to event are =>'
            || n_total_number_of_parameters);

         WHILE (n_current_parameter_position <= n_total_number_of_parameters)
         LOOP
            l_parameter_name :=
               l_wf_parameter_list_t (n_current_parameter_position).getname ();
            l_parameter_value :=
               l_wf_parameter_list_t (n_current_parameter_position).getvalue ();
            xx_debug_log (
                  'Parameter Name=>'
               || l_parameter_name
               || ' has value =>'
               || l_parameter_value);
            n_current_parameter_position := n_current_parameter_position + 1;
         END LOOP;
      END IF;

      RETURN 'SUCCESS';
   EXCEPTION
      WHEN end_execution
      THEN
         xx_debug_log ('Supplier status is not inactive. Execution stopped.');
         RETURN 'SUCCESS';
      WHEN OTHERS
      THEN
         xx_debug_log ('Unhandled Exception=>' || SQLERRM);
   END xx_capture_event_parameters;

   ------Procedure to create/delete payment terms details in attribute group
   PROCEDURE Update_payment_terms_details (
      p_party_id   IN hz_parties.party_id%TYPE,
      p_action     IN VARCHAR2,
      p_user_id    IN fnd_user.user_id%TYPE)
   IS
      ln_attr_num                NUMBER := NULL;
      ln_msg_index_out           NUMBER := NULL;
      lv_failed_row_id_list      VARCHAR2 (100) := NULL;
      ldt_attr_date              DATE := NULL;
      lv_pk_column_values        ego_col_name_value_pair_array;
      lv_attributes_row_table    ego_user_attr_row_table;
      lv_attributes_data_table   ego_user_attr_data_table;
      lv_class_code              ego_col_name_value_pair_array;

      lv_return_status           VARCHAR2 (10) := NULL;
      ln_msg_count               NUMBER := 0;
      lv_msg_data                VARCHAR2 (1000) := NULL;
      ln_errorcode               NUMBER := 0;
      l_attr_group_name          VARCHAR2 (50)
                                    := 'XXAH_SUPPLIER_TERMS_DETAILS_MR';
      l_count                    NUMBER := 0;

      CURSOR sup_terms_cur
      IS
         SELECT TO_CHAR (aps.vendor_id),
                aps.vendor_name,
                NULL vendor_site_code,
                att.name,
                TO_CHAR (att.term_id),
                aps.party_id,
                NULL retainage_rate,
                NULL org_id
           FROM ap_suppliers aps, ap_terms_tl att
          WHERE     1 = 1
                AND att.term_id = aps.terms_id
                AND aps.party_id = p_party_id
         UNION
         SELECT TO_CHAR (aps.vendor_id),
                aps.vendor_name,
                apsa.vendor_site_code,
                att.name,
                TO_CHAR (att.term_id),
                aps.party_id,
                TO_CHAR (apsa.retainage_rate) retainage_rate,
                TO_CHAR (apsa.org_id) org_id
           FROM ap_suppliers aps, ap_terms_tl att, ap_supplier_sites_all apsa
          WHERE     1 = 1
                AND att.term_id = apsa.terms_id
                AND apsa.vendor_id = aps.vendor_id
                AND aps.party_id = p_party_id
         ORDER BY vendor_name;

      CURSOR sup_terms_ag_cur
      IS
         SELECT pspe.c_ext_attr1 vendor_id,
                pspe.c_ext_attr2 vendor_name,
                pspe.c_ext_attr3 vendor_site_code,
                pspe.c_ext_attr4 name,
                pspe.c_ext_attr5 term_id,
                pspe.party_id,
                pspe.c_ext_attr6 retainage_rate,
                pspe.c_ext_attr7 org_id
           FROM pos_supp_prof_ext_b pspe, ego_attr_groups_v eagv
          WHERE     1 = 1
                AND pspe.party_id = p_party_id
                AND eagv.attr_group_name = l_attr_group_name
                AND eagv.attr_group_id = pspe.attr_group_id;

      TYPE l_sup_terms_rec IS TABLE OF sup_terms_ag_cur%ROWTYPE;

      l_sup_terms_tbl            l_sup_terms_rec;
      --    l_action        VARCHAR2(10) := 'CREATE';--DELETE
      l_api_action               VARCHAR2 (25);
      ln_resp_appl_id            fnd_responsibility_tl.application_id%TYPE;
   BEGIN
      xx_debug_log ('Inside Update_payment_terms_details - BEGIN');
      xx_debug_log ('p_action - ' || p_action);

      IF p_action = 'CREATE'
      THEN
         OPEN sup_terms_cur;

         FETCH sup_terms_cur BULK COLLECT INTO l_sup_terms_tbl;

         CLOSE sup_terms_cur;

         l_api_action := ego_user_attrs_data_pvt.g_SYNC_mode;
      ELSE
         OPEN sup_terms_ag_cur;

         FETCH sup_terms_ag_cur BULK COLLECT INTO l_sup_terms_tbl;

         CLOSE sup_terms_ag_cur;

         l_api_action := ego_user_attrs_data_pvt.g_DELETE_mode;
      END IF;

      set_org_context (p_user_id, ln_resp_appl_id);

      FOR i IN 1 .. l_sup_terms_tbl.COUNT
      LOOP
         lv_pk_column_values :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('PARTY_ID',
                                            l_sup_terms_tbl (i).party_id));

         lv_class_code :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE'));
         lv_attributes_data_table :=
            ego_user_attr_data_table (
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_ID',
                  attr_value_str         => l_sup_terms_tbl (i).vendor_id,
                  attr_value_num         => NULL,
                  attr_value_date        => NULL,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_NAME',             --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).vendor_name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_SITE_CODE',        --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).vendor_site_code,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'TERMS_NAME',              --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'TERMS_ID',                --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).term_id,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'RETAINAGE_RATE',          --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).retainage_rate,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'ORG_ID',                  --'A3',
                  attr_value_str         => l_sup_terms_tbl (i).org_id,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1));

         lv_attributes_row_table :=
            ego_user_attr_row_table (
               ego_user_attr_row_obj (
                  row_identifier      => 1,
                  attr_group_id       => NULL,
                  attr_group_app_id   => ln_resp_appl_id,
                  attr_group_type     => 'POS_SUPP_PROFMGMT_GROUP',
                  attr_group_name     => l_attr_group_name,
                  data_level          => 'SUPP_LEVEL', --for site level use SUPP_SITE_LEVEL
                  data_level_1        => 'N',
                  data_level_2        => NULL,
                  data_level_3        => NULL,
                  data_level_4        => NULL,
                  data_level_5        => NULL,
                  transaction_type    => l_api_action)); --for update use g_update_mode

         --Supplier uda updation started
         pos_vendor_pub_pkg.process_user_attrs_data (
            p_api_version                   => 1.0,
            p_attributes_row_table          => lv_attributes_row_table,
            p_attributes_data_table         => lv_attributes_data_table,
            p_pk_column_name_value_pairs    => lv_pk_column_values,
            p_class_code_name_value_pairs   => lv_class_code,
            x_failed_row_id_list            => lv_failed_row_id_list,
            x_return_status                 => lv_return_status,
            x_errorcode                     => ln_errorcode,
            x_msg_count                     => ln_msg_count,
            x_msg_data                      => lv_msg_data);

         IF lv_return_status = 'S'
         THEN
            l_count := l_count + 1;
            COMMIT;
         ELSE
            xx_debug_log ('Error Message Count : ' || ln_msg_count);
            xx_debug_log ('Error Message Data  : ' || lv_msg_data);
            xx_debug_log ('Error Code          : ' || ln_errorcode);
            xx_debug_log ('Entering Error Loop ');

            FOR i IN 1 .. ln_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index       => i,
                                p_data            => lv_msg_data,
                                p_encoded         => 'F',
                                p_msg_index_out   => ln_msg_index_out);
               fnd_message.set_encoded (lv_msg_data);
               xx_debug_log (
                  'Inside Error Loop : ' || i || ', ' || lv_msg_data);
            END LOOP;

            ROLLBACK;
            EXIT;
         END IF;
      END LOOP;

      xx_debug_log ('No of records inserted/deleted - ' || l_count);
      xx_debug_log ('Inside Update_payment_terms_details - END');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log (
            'Exception in Update_payment_terms_details: ' || SQLERRM);
         ROLLBACK;
   END Update_payment_terms_details;

   -----------Procedure to create/delete supplier bank details in attribute group
   PROCEDURE Update_supplier_bank_details (
      p_party_id   IN hz_parties.party_id%TYPE,
      p_action     IN VARCHAR2,
      p_user_id    IN fnd_user.user_id%TYPE)
   IS
      ln_attr_num                NUMBER := NULL;
      ln_msg_index_out           NUMBER := NULL;
      lv_failed_row_id_list      VARCHAR2 (100) := NULL;
      ldt_attr_date              DATE := NULL;
      lv_pk_column_values        ego_col_name_value_pair_array;
      lv_attributes_row_table    ego_user_attr_row_table;
      lv_attributes_data_table   ego_user_attr_data_table;
      lv_class_code              ego_col_name_value_pair_array;

      lv_return_status           VARCHAR2 (10) := NULL;
      ln_msg_count               NUMBER := 0;
      lv_msg_data                VARCHAR2 (1000) := NULL;
      ln_errorcode               NUMBER := 0;
      l_attr_group_name          VARCHAR2 (50)
                                    := 'XXAH_SUPPLIER_BANK_DETAILS_MR';
      l_count                    NUMBER := 0;

      CURSOR sup_bank_cur
      IS
         --Supplier Site level Bank assignments
         SELECT ieb.bank_account_num,
                ieb.bank_account_name,
                ieb.iban,
                ieb.currency_code,
                ieb.check_digits,
                cbbv.bank_name,
                cbbv.bank_branch_name,
                asp.vendor_name,
                asp.vendor_id,
                asa.vendor_site_code,
                asp.party_id,
                asa.org_id
           FROM apps.iby_pmt_instr_uses_all instrument,
                apps.iby_account_owners owners,
                apps.iby_external_payees_all payees,
                apps.iby_ext_bank_accounts ieb,
                apps.ap_supplier_sites_all asa,
                apps.ap_suppliers asp,
                apps.ce_bank_branches_v cbbv
          WHERE     1 = 1
                AND owners.ext_bank_account_id = ieb.ext_bank_account_id
                AND owners.ext_bank_account_id = instrument.instrument_id --(+)
                AND payees.ext_payee_id = instrument.ext_pmt_party_id    --(+)
                AND cbbv.branch_party_id = ieb.branch_id
                AND payees.payee_party_id = owners.account_owner_party_id
                AND payees.supplier_site_id = asa.vendor_site_id
                AND asa.vendor_id = asp.vendor_id
                AND payees.party_site_id = asa.party_site_id
                AND asp.party_id = p_party_id
         UNION
         --Supplier level Bank assignments
         SELECT IEBA.BANK_ACCOUNT_NUM,
                IEBA.BANK_ACCOUNT_NAME,
                ieba.iban,
                ieba.currency_code,
                ieba.check_digits,
                cbv.BANK_NAME,
                CBBV.BANK_BRANCH_NAME,
                VENDOR_NAME,
                aps.vendor_id,
                NULL vendor_site_code,
                aps.party_id,
                NULL org_id
           FROM apps.AP_SUPPLIERS APS,
                apps.IBY_EXTERNAL_PAYEES_ALL IEPA,
                apps.IBY_PMT_INSTR_USES_ALL IPIUA,
                APPS.IBY_EXT_BANK_ACCOUNTS IEBA,
                apps.ce_banks_v cbv,
                apps.ce_bank_BRANCHES_V CBBV
          WHERE     1 = 1
                AND APS.party_id = p_party_id
                AND IEPA.PAYEE_PARTY_ID = APS.PARTY_ID
                AND PARTY_SITE_ID IS NULL
                AND SUPPLIER_SITE_ID IS NULL
                AND IPIUA.EXT_PMT_PARTY_ID(+) = IEPA.EXT_PAYEE_ID
                AND IEBA.EXT_BANK_ACCOUNT_ID(+) = IPIUA.INSTRUMENT_ID
                AND IEBA.BANK_ID = cbv.BANK_PARTY_ID(+)
                AND IEBA.BRANCH_ID = CBBV.BRANCH_PARTY_ID(+)
                AND IEBA.BANK_ACCOUNT_NUM IS NOT NULL
         UNION
         --Supplier Address level Bank assignments
         SELECT IEBA.BANK_ACCOUNT_NUM,
                IEBA.BANK_ACCOUNT_NAME,
                ieba.iban,
                ieba.currency_code,
                ieba.check_digits,
                cbv.BANK_NAME,
                CBBV.BANK_BRANCH_NAME,
                VENDOR_NAME,
                aps.vendor_id,
                NULL vendor_site_code,
                aps.party_id,
                NULL org_id
           FROM apps.AP_SUPPLIERS APS,
                apps.IBY_EXTERNAL_PAYEES_ALL IEPA,
                apps.IBY_PMT_INSTR_USES_ALL IPIUA,
                APPS.IBY_EXT_BANK_ACCOUNTS IEBA,
                apps.ce_banks_v cbv,
                apps.ce_bank_BRANCHES_V CBBV
          WHERE     1 = 1
                AND APS.party_id = p_party_id
                AND IEPA.PAYEE_PARTY_ID = APS.PARTY_ID
                --         AND PARTY_SITE_ID IS NULL
                --         AND SUPPLIER_SITE_ID IS NULL
                AND IPIUA.EXT_PMT_PARTY_ID(+) = IEPA.EXT_PAYEE_ID
                AND IEBA.EXT_BANK_ACCOUNT_ID(+) = IPIUA.INSTRUMENT_ID
                AND IEBA.BANK_ID = cbv.BANK_PARTY_ID(+)
                AND IEBA.BRANCH_ID = CBBV.BRANCH_PARTY_ID(+)
                AND IEBA.BANK_ACCOUNT_NUM IS NOT NULL;

      CURSOR supp_bank_details_ag_cur
      IS
         SELECT c_ext_attr5 bank_account_num,
                c_ext_attr6 bank_account_name,
                c_ext_attr7 iban,
                c_ext_attr8 currency_code,
                c_ext_attr9 check_digits,
                c_ext_attr3 bank_name,
                c_ext_attr4 bank_branch_name,
                c_ext_attr2 vendor_name,
                n_ext_attr1 vendor_id,
                c_ext_attr1 vendor_site_code,
                pspe.party_id,
                n_ext_attr2 org_id
           FROM pos_supp_prof_ext_b pspe, ego_attr_groups_v eagv
          WHERE     1 = 1
                AND pspe.party_id = p_party_id
                AND pspe.attr_group_id = eagv.attr_group_id
                AND eagv.attr_group_name = l_attr_group_name;

      TYPE l_sup_bank_rec IS TABLE OF sup_bank_cur%ROWTYPE;

      l_sup_bank_tbl             l_sup_bank_rec;
      l_transaction_type         VARCHAR2 (10);
      ln_resp_appl_id            fnd_responsibility_tl.application_id%TYPE;
   BEGIN
      xx_debug_log ('Inside Update_supplier_bank_details - BEGIN');
      xx_debug_log ('p_action - ' || p_action);

      IF p_action = 'CREATE'
      THEN
         OPEN sup_bank_cur;

         FETCH sup_bank_cur BULK COLLECT INTO l_sup_bank_tbl;

         CLOSE sup_bank_cur;

         l_transaction_type := ego_user_attrs_data_pvt.g_create_mode;
      ELSE
         OPEN supp_bank_details_ag_cur;

         FETCH supp_bank_details_ag_cur BULK COLLECT INTO l_sup_bank_tbl;

         CLOSE supp_bank_details_ag_cur;

         l_transaction_type := ego_user_attrs_data_pvt.g_delete_mode;
      END IF;

      set_org_context (p_user_id, ln_resp_appl_id);

      FOR i IN 1 .. l_sup_bank_tbl.COUNT
      LOOP
         --xx_debug_log('Inside For Loop');
         lv_pk_column_values :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('PARTY_ID',
                                            l_sup_bank_tbl (i).party_id));

         lv_class_code :=
            ego_col_name_value_pair_array (
               ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE'));
         lv_attributes_data_table :=
            ego_user_attr_data_table (
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_ID',
                  attr_value_str         => NULL,
                  attr_value_num         => l_sup_bank_tbl (i).vendor_id,
                  attr_value_date        => NULL,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_SITE_CODE',        --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).vendor_site_code,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'VENDOR_NAME',             --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).vendor_name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BANK_NAME',               --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).bank_name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BANK_BRANCH_NAME',        --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).bank_branch_name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BANK_ACCOUNT_NUMBER',     --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).bank_account_num,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'BANK_ACCOUNT_NAME',       --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).bank_account_name,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'IBAN',                    --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).iban,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'CURRENCY_CODE',           --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).currency_code,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'CHECK_DIGITS',            --'A3',
                  attr_value_str         => l_sup_bank_tbl (i).check_digits,
                  attr_value_num         => ln_attr_num,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1),
               ego_user_attr_data_obj (
                  row_identifier         => 1,
                  attr_name              => 'ORG_ID',                  --'A3',
                  attr_value_str         => NULL,
                  attr_value_num         => l_sup_bank_tbl (i).org_id,
                  attr_value_date        => ldt_attr_date,
                  attr_disp_value        => NULL,
                  attr_unit_of_measure   => NULL,
                  user_row_identifier    => 1));

         lv_attributes_row_table :=
            ego_user_attr_row_table (
               ego_user_attr_row_obj (
                  row_identifier      => 1,
                  attr_group_id       => NULL,
                  attr_group_app_id   => ln_resp_appl_id,
                  attr_group_type     => 'POS_SUPP_PROFMGMT_GROUP',
                  attr_group_name     => l_attr_group_name,
                  data_level          => 'SUPP_LEVEL', --for site level use SUPP_SITE_LEVEL
                  data_level_1        => 'N',
                  data_level_2        => NULL,
                  data_level_3        => NULL,
                  data_level_4        => NULL,
                  data_level_5        => NULL,
                  transaction_type    => l_transaction_type)); --for update use g_update_mode

         --Supplier uda updation started
         pos_vendor_pub_pkg.process_user_attrs_data (
            p_api_version                   => 1.0,
            p_attributes_row_table          => lv_attributes_row_table,
            p_attributes_data_table         => lv_attributes_data_table,
            p_pk_column_name_value_pairs    => lv_pk_column_values,
            p_class_code_name_value_pairs   => lv_class_code,
            x_failed_row_id_list            => lv_failed_row_id_list,
            x_return_status                 => lv_return_status,
            x_errorcode                     => ln_errorcode,
            x_msg_count                     => ln_msg_count,
            x_msg_data                      => lv_msg_data);

         IF lv_return_status = 'S'
         THEN
            --xx_debug_log('return_status: ' || lv_return_status);
            --xx_debug_log('msg_data: ' || lv_msg_data);
            COMMIT;
            l_count := l_count + 1;
         ELSE
            xx_debug_log ('Error Message Count : ' || ln_msg_count);
            xx_debug_log ('Error Message Data  : ' || lv_msg_data);
            xx_debug_log ('Error Code          : ' || ln_errorcode);
            xx_debug_log ('Entering Error Loop ');

            FOR i IN 1 .. ln_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index       => i,
                                p_data            => lv_msg_data,
                                p_encoded         => 'F',
                                p_msg_index_out   => ln_msg_index_out);
               fnd_message.set_encoded (lv_msg_data);
               xx_debug_log (
                  'Inside Error Loop : ' || i || ', ' || lv_msg_data);
            END LOOP;

            ROLLBACK;
            EXIT;
         END IF;
      END LOOP;

      xx_debug_log ('No of records inserted/Deleted - ' || l_count);
      xx_debug_log ('Inside Update_supplier_bank_details - END');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_debug_log (
            'Exception in Update_supplier_bank_details - ' || SQLERRM);
         ROLLBACK;
   END Update_supplier_bank_details;
END XXAH_AP_SUPPL_APPROVAL_WF_PKG;

/
