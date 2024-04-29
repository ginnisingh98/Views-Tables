--------------------------------------------------------
--  DDL for Package Body IGS_CO_SUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_SUBMIT" AS
   /* $Header: IGSCO21B.pls 120.7 2006/01/06 04:12:34 gmaheswa ship $ */
   /*************************************************************
    Created By : Paul Cross
    Date Created on : 11-Sep-2005
    Purpose : This procedure will build the html call to the Correspondance Workbench form function and write
              it to the concurrent programs output file.
    Change History
    Who             When            What
    (reverse chronological order - newest change first)
     pacross         11-SEP-2005   Implemented code for Correspondance preview and edit fucntionality
    ***************************************************************/
   PROCEDURE build_preview_html (p_requestid NUMBER)
   IS
      l_function_id          NUMBER (15);
      l_log_request_id       NUMBER;
      l_url                  VARCHAR2 (2000);
      l_mouse_over_text      VARCHAR2 (2000);
      l_user_function_name   VARCHAR2 (2000);
      l_temp_string          VARCHAR2 (32000);
      l_count                NUMBER;

      CURSOR c_function_details (
         cp_function_name   fnd_form_functions.function_name%TYPE
      )
      IS
         SELECT function_id, user_function_name
           FROM fnd_form_functions_vl
          WHERE function_name = cp_function_name;

      CURSOR c_preview_exists (cp_concurrent_req_id NUMBER)
      IS
         SELECT COUNT (1)
           FROM igs_co_prev_reqs
          WHERE concurrent_request_id = cp_concurrent_req_id;
   BEGIN
      -- look up the function id for the correspondence workbench

      --** proc level logging.
      /*      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
               IF (l_log_request_id IS NULL) THEN
                 l_log_request_id := fnd_global.conc_request_id;
               END IF;
               l_label := 'igs.plsql.igs_co_submit.build_preview_html';
               l_debug_str :=  'JUST entered inside build_preview_html';
               fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_log_request_id));
           END IF;
      --**     */
      l_count := 0;
      OPEN c_preview_exists (p_requestid);
      FETCH c_preview_exists INTO l_count;
      CLOSE c_preview_exists;

      IF l_count > 0 THEN
         -- Get the Form function details
         OPEN c_function_details ('IGS_CO_WORKBENCH');
         FETCH c_function_details INTO l_function_id, l_user_function_name;
         CLOSE c_function_details;
         -- Update the mouse over text so that it can be used in a URL
         l_temp_string := REPLACE (l_user_function_name, '''', '\''');
         l_temp_string := REPLACE (l_temp_string, '"', '`' || '&' || 'quot;');
         l_user_function_name := REPLACE (l_temp_string, '\\', '\');
         -- Get the URL
         l_url :=
            fnd_run_function.get_run_function_url (
               l_function_id,
               fnd_global.resp_appl_id,
               fnd_global.resp_id,
               fnd_global.security_group_id,
               'pRequestId=' || TO_CHAR (p_requestid)
            );
         --
         -- Display the user function name when mousing over the generated link.
         --
         l_mouse_over_text :=    'onMouseOver="window.status='''
                              || l_user_function_name
                              || '''; return true"';
         -- Start writing out HTML output
         fnd_file.put_line (fnd_file.output, '<HTML>');
         fnd_file.put_line (fnd_file.output, '  <HEAD>');
         -- write out the auto-refresh URL metatag
         fnd_file.put (
            fnd_file.output,
            '    <META http-equiv="refresh" content="0;URL='
         );
         fnd_file.put (fnd_file.output, l_url);
         fnd_file.put_line (fnd_file.output, '">');
         -- Finish of header section and start on the body
         fnd_file.put_line (fnd_file.output, '  </HEAD>');
         fnd_file.put_line (fnd_file.output, '  <BODY>');
         -- Write out the translated message for the user to click if the
         fnd_file.put_line (
            fnd_file.output,
               '<a href="'
            || l_url
            || '" '
            || l_mouse_over_text
            || '>'
            || fnd_message.get_string (
                  'IGS',
                  'IGS_CO_PREV_VIEW_OUTPUT'
               ) -- click here if not autotmatically taken to correspondence workbench
            || '</a>'
         );
         -- finialize the html output
         fnd_file.put_line (fnd_file.output, '  </BODY>');
         fnd_file.put_line (fnd_file.output, '</HTML>');
      END IF;
   /*  --** proc level logging.
          IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
              IF (l_log_request_id IS NULL) THEN
                l_log_request_id := fnd_global.conc_request_id;
              END IF;
              l_label := 'igs.plsql.igs_co_submit.build_preview_html.exit';
              l_debug_str :=  'JUST exiting from build_preview_html';
              fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_log_request_id));
          END IF;
     --** */
   END build_preview_html;

   PROCEDURE submit_correspondence_request (
      errbuf              OUT NOCOPY      VARCHAR2,
      retcode             OUT NOCOPY      NUMBER,
      p_map_id            IN              NUMBER,
      p_select_type       IN              VARCHAR2,
      p_list_id           IN              NUMBER,
      p_person_id         IN              NUMBER,
      p_override_flag     IN              VARCHAR2,
      p_delivery_type     IN              VARCHAR2,
      p_destination       IN              VARCHAR2, -- added as part of bug# 2472250
      p_dest_fax_number   IN              VARCHAR2,
      p_reply_email       IN              VARCHAR2,
      p_sender_email      IN              VARCHAR2,
      p_cc_email          IN              VARCHAR2,
      p_org_unit_id       IN              NUMBER,
      p_parameter_1       IN              VARCHAR2,
      p_parameter_2       IN              VARCHAR2,
      p_parameter_3       IN              VARCHAR2,
      p_parameter_4       IN              VARCHAR2,
      p_parameter_5       IN              VARCHAR2,
      p_parameter_6       IN              VARCHAR2,
      p_parameter_8       IN              VARCHAR2,
      p_parameter_7       IN              VARCHAR2,
      p_parameter_9       IN              VARCHAR2,
      p_preview           IN              VARCHAR2
   )
   IS
      /*************************************************************
     Created By :Prchandr
     Date Created on : 05-Feb-2002
     Purpose : This procedure is the main procedure called aftersubmiiting letters from concurrent jobs.
     Know limitations, enhancements or remarks
     Change History
     Who             When            What
     mnade          6/1/2005        FA 157 - 4382371 - Added p_award_prd_cd parameter to corp_post_process
     Bayadav         24-MAY-2002     Included two system letter codes 'ENADHOC', 'SFADHOC' for adhoc letters as a part of bug 2376434
     pradhakr    13-Aug-2002   If the delivery type is printer then a new parameter p_destination is added to get the printer name.
                             This is done as part of bug# 2472250.
                             Reversed the order of parameter 8 and 7 due to the way the parameters are defined.
     kpadiyar        02-Mar-2003     Included nominated_course_cd,appl_sequence_number for letter
                                     code 'ADACKMT' for bug 2525936.
     pkpatel         7-May-2003      Bug 2940810
                                     Modified to Bind variable
     ssawhney        24 Sep 2003     3136817 , validations at time of audit profile setting
     hreddych        13-oct-2003     Build UK Correspondence Letters
     gmaheswa        14-nov-2003     Multiple mode of communication for same request is implemented. new parameter fax number is added.
     ssawhney        3-may-2004      IBC.C patchset changes bug 3565861 + signature of corp_get_letter_type changed
     ssaleem         02-Jun-2004     extended header usage - Validation added to check for Email delivery option when reply cc or sender
                                     Email is given
     ssaleem         09-SEP-2004   3630073. Added p_org_unit_id as a new parameter
     pacross         08-SEP-2005     Added preview flag for correspondance preview and edit.
     gmaheswa	5-Jan-2004	Bug 4869737 Added a call to SET_ORG_ID to disable OSS for R12.
     ***************************************************************/
      l_sys_ltr_code              igs_co_mapping.sys_ltr_code%TYPE;
      l_request_id                igs_co_ou_co_ref.request_id%TYPE;
      l_no_of_repeats             igs_co_mapping.repeat_times%TYPE;
      l_elapsed_days              igs_co_mapping.elapsed_days%TYPE;
      l_document_id               igs_co_mapping.document_id%TYPE;
      l_letter_type               igs_co_mapping.doc_code%TYPE;
      l_request_status            VARCHAR2 (100);
      l_send_letter               VARCHAR2 (10);
      l_sql_stmt                  VARCHAR2 (32767);
      -- these variables are required becuase when it is FAM related, Admission Application detials will be Null and when
      -- the letter is NON FAM, then Adm Application details are needed and Award cal type and seq num will be Null.
      l_adm_appl_number           igs_co_interac_hist.adm_application_number%TYPE;
      l_nominated_course_cd       igs_co_interac_hist.nominated_course_cd%TYPE;
      l_appl_sequence_number      igs_co_interac_hist.ci_sequence_number%TYPE;
      l_awd_ci_seq_number         igf_sl_disb_ltr_v.ci_sequence_number%TYPE;
      l_awd_cal_type              igf_sl_disb_ltr_v.ci_cal_type%TYPE;
      l_gen_request_id            igs_co_ou_co_ref.request_id%TYPE;
      l_fulfillment_req           NUMBER;
      l_crm_user_id               NUMBER;
      l_email_address_dy          hz_parties.email_address%TYPE;
      l_person_id_dy              igs_pe_person.person_id%TYPE;
      l_adm_appl_number_dy        igs_co_interac_hist.adm_application_number%TYPE;
      l_nominated_course_cd_dy    igs_co_interac_hist.nominated_course_cd%TYPE;
      l_appl_sequence_number_dy   igs_co_interac_hist.ci_sequence_number%TYPE;
      l_panel_code_dy             igs_ad_interview_letters_v.panel_code%TYPE;
      l_award_year_dy             igf_sl_disb_ltr_v.award_year%TYPE;
      l_exception                 VARCHAR2 (1);
      l_retcode                   NUMBER (1);
      l_errbuf                    VARCHAR2 (1000);
      -- Created new parameters as part of bug# 2472250
      l_printer_name              VARCHAR2 (240);
      l_address_found             VARCHAR2 (1);
      l_delivery_type             VARCHAR2 (30);

      -- Added cursor to print the person number in case of no email for bug 2742586
      CURSOR c_person_number (pa_person_id NUMBER)
      IS
         SELECT person_number, full_name
           FROM igs_pe_person_base_v
          WHERE person_id = pa_person_id;

      l_person_number             igs_pe_person_base_v.person_number%TYPE;
      l_full_name                 igs_pe_person_base_v.full_name%TYPE;
      l_cursor_id                 NUMBER (15);
      l_num_of_rows               NUMBER (15);
      l_dsql_debug                VARCHAR2 (32767);
      l_person_processed          NUMBER (10)                            := 0;
      l_resp_id                   NUMBER;
      l_resp_appl_id              NUMBER;
      l_login_user_id             NUMBER; --user who has logged in
      CURSOR c_valid_resource (cp_user_id fnd_user.user_id%TYPE)
      IS
         SELECT 1
           FROM jtf_rs_resource_extns
          WHERE user_id = cp_user_id;

      CURSOR c_lkup_channel (cp_sys_ltr_code VARCHAR2)
      IS
         SELECT description
           FROM igs_lookup_values
          WHERE lookup_code = cp_sys_ltr_code
            AND lookup_type = 'IGS_CO_DEL_CHANNEL';

      CURSOR c_avail_del_channel (
         cp_item_id   ibc_content_items.content_item_id%TYPE,
         cp_node_id   ibc_ctype_group_nodes.directory_node_id%TYPE
      )
      IS
         SELECT 1
           FROM ibc_content_items citem, ibc_ctype_group_nodes ctg
          WHERE citem.content_item_id = cp_item_id
            AND citem.content_type_code = ctg.content_type_code
            AND ctg.directory_node_id = cp_node_id;

      l_user                      NUMBER;
      l_fax_number                VARCHAR2 (240);
      l_count                     NUMBER (10);
      l_prog_label                VARCHAR2 (500);
      l_log_request_id            NUMBER;
      l_label                     VARCHAR2 (4000);
      l_debug_str                 VARCHAR2 (4000);
      l_version_id                NUMBER;
      l_del_desc                  igs_lookups_view.description%TYPE;
      --l_enable_log BOOLEAN

      --l_prog_label := 'igs.plsql.igs_ad_imp_002.validate_oss_ext_attr';


      -- Keep a record that preview batch request row has been stored in sticky variable.
      -- PACROSS - 27-SEP-2005
      l_preview_batch_stored      BOOLEAN;
   BEGIN
      igs_ge_gen_003.set_org_id;

      l_fulfillment_req := fnd_profile.VALUE ('IGS_CO_FUL_SERVER_ID');
      l_crm_user_id := fnd_profile.VALUE ('IGS_CO_CRM_USER_ID');
      l_login_user_id := fnd_global.user_id;
      l_prog_label := 'igs.plsql.igs_co_submit';
      --l_enable_log := igs_ad_imp_001.g_enable_log;

      l_address_found := 'N';
      l_exception := 'N';
      -- Keep a record that preview batch request row has been stored.
      -- PACROSS - 29-SEP-2005
      l_preview_batch_stored := FALSE ;
      igs_co_process.corp_check_request_status (
         errbuf                => l_errbuf,
         retcode               => l_retcode,
         p_person_id           => NULL,
         p_document_id         => NULL,
         p_application_id      => NULL,
         p_course_cd           => NULL,
         p_adm_seq_no          => NULL,
         p_awd_cal_type        => NULL,
         p_awd_seq_no          => NULL,
         p_elapsed_days        => NULL,
         p_no_of_repeats       => NULL,
         p_sys_ltr_code        => NULL
      );
      l_delivery_type := p_delivery_type;

      IF    p_reply_email IS NOT NULL
         OR p_sender_email IS NOT NULL
         OR p_cc_email IS NOT NULL THEN
         IF INSTR (l_delivery_type, 'EMAIL') <= 0 THEN -- Email option not chosen
            fnd_message.set_name ('IGS', 'IGS_CO_EMAIL_REQ');
            fnd_file.put_line (fnd_file.LOG, fnd_message.get);
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF INSTR (l_delivery_type, 'PRINTER') > 0 THEN
         --l_delivery_type := 'PRINTER';
         IF p_destination IS NOT NULL THEN
            l_printer_name := p_destination;
         ELSIF fnd_profile.VALUE ('IGS_CO_DESTINATION_NAME') IS NOT NULL THEN
            l_printer_name := fnd_profile.VALUE ('IGS_CO_DESTINATION_NAME');
         ELSE
            fnd_message.set_name ('IGS', 'IGS_CO_DEST_INF_REQ');
            fnd_message.set_token ('DELTYPE', l_delivery_type);
            fnd_file.put_line (fnd_file.LOG, fnd_message.get);
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF INSTR (l_delivery_type, 'FAX') > 0 THEN
         IF p_dest_fax_number IS NULL THEN
            IF fnd_profile.VALUE ('IGS_CO_FAX_DESTINATION_NUMBER') IS NOT NULL THEN
               l_fax_number :=
                             fnd_profile.VALUE (
                                'IGS_CO_FAX_DESTINATION_NUMBER'
                             );
            ELSE
               fnd_message.set_name ('IGS', 'IGS_CO_DEST_INF_REQ');
               fnd_message.set_token ('DELTYPE', l_delivery_type);
               fnd_file.put_line (fnd_file.LOG, fnd_message.get);
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSE
            l_fax_number := p_dest_fax_number;
         END IF;
      END IF;

      --** proc level logging.
      IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
         IF (l_log_request_id IS NULL) THEN
            l_log_request_id := fnd_global.conc_request_id;
         END IF;

         l_label :=
            'igs.plsql.igs_co_submit.submit_correspondence_request.deliverycheck';
         l_debug_str :=    'Delivery Type :'
                        || l_delivery_type
                        || ' Printer :'
                        || l_printer_name
                        || ' Fax :'
                        || l_fax_number;
         fnd_log.string_with_context (
            fnd_log.level_procedure,
            l_label,
            l_debug_str,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            TO_CHAR (l_log_request_id)
         );
      END IF;

      --**

      -- ssawhney adding code fix for bug 3136817.
      -- need to validate AUDIT enabling and decide on the CRM user to be passed.

      IF (fnd_profile.value_specific (
             'SIGNONAUDIT:LEVEL',
             l_login_user_id,
             l_resp_id,
             l_resp_appl_id
          ) <> 'A'
         ) THEN
         -- this means audit is enabled.
         -- check if the Login User, is a valid CRM resource.

         OPEN c_valid_resource (l_login_user_id);
         FETCH c_valid_resource INTO l_user;
         CLOSE c_valid_resource;

         IF l_user IS NULL THEN
            -- log a message that the current user is not a valid CRM resource
            fnd_message.set_name ('IGS', 'IGS_CO_INVALID_JTF_RES');
            fnd_file.put_line (fnd_file.LOG, fnd_message.get ());
            fnd_file.put_line (fnd_file.LOG, ' ');
            retcode := 2;
            RETURN;
         ELSE
                  -- do not need to pass server id.
            -- pass the CRM user as the current logged in person.
            l_crm_user_id := l_login_user_id;
            l_fulfillment_req := NULL;
         END IF;
      -- if all the above checks pass
      END IF;

      IF (l_crm_user_id IS NULL) THEN
         fnd_message.set_name ('JTF', 'JTF_FM_API_MISSING_USER_ID');
         fnd_file.put_line (fnd_file.LOG, fnd_message.get ());
         fnd_file.put_line (fnd_file.LOG, ' ');
         retcode := 0;
         RETURN;
      END IF;

      --**  proc level logging.
      IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
         IF (l_log_request_id IS NULL) THEN
            l_log_request_id := fnd_global.conc_request_id;
         END IF;

         l_label :=
            'igs.plsql.igs_co_submit.submit_correspondence_request.signonaudit';
         l_debug_str := 'CRM User :' || l_crm_user_id;
         fnd_log.string_with_context (
            fnd_log.level_procedure,
            l_label,
            l_debug_str,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            TO_CHAR (l_log_request_id)
         );
      END IF;

      --**

      -- get the Doc Id , sys ltr code, letter type as out NOCOPY parameters from a call.
      igs_co_process.corp_get_letter_type (
         p_map_id            => p_map_id,
         p_document_id       => l_document_id,
         p_sys_ltr_code      => l_sys_ltr_code,
         p_letter_type       => l_letter_type,
         p_version_id        => l_version_id --ssawhney
      );

      --**  proc level logging.
      IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
         IF (l_log_request_id IS NULL) THEN
            l_log_request_id := fnd_global.conc_request_id;
         END IF;

         l_label :=
            'igs.plsql.igs_co_submit.submit_correspondence_request.paramdetails';
         l_debug_str :=    'Map ID :'
                        || p_map_id
                        || 'Doc id :'
                        || l_document_id
                        || ' Version :'
                        || l_version_id;
         fnd_log.string_with_context (
            fnd_log.level_procedure,
            l_label,
            l_debug_str,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            TO_CHAR (l_log_request_id)
         );
      END IF;

      --**

      -- once we get the doc id, check if the passed delivery_type combination is
      -- valid as per new IBC.C logic. Email is dirnode=33, fax is dirnode=32, printer is dirnode=34

      IF l_document_id IS NOT NULL THEN
         IF INSTR (l_delivery_type, 'PRINTER') > 0 THEN
            OPEN c_avail_del_channel (l_document_id, 34);
            FETCH c_avail_del_channel INTO l_count;
            OPEN c_lkup_channel ('PRINTER');
            FETCH c_lkup_channel INTO l_del_desc;
            CLOSE c_lkup_channel;

            IF c_avail_del_channel%NOTFOUND THEN
               fnd_message.set_name ('IGS', 'IGS_CO_UNAVAIL_DEL_TYPE');
               fnd_message.set_token ('CHANNEL ', l_del_desc);
               fnd_file.put_line (fnd_file.LOG, fnd_message.get ());
               retcode := 2;
               RETURN;
            END IF;

            CLOSE c_avail_del_channel;
         END IF;

         IF INSTR (l_delivery_type, 'FAX') > 0 THEN
            OPEN c_avail_del_channel (l_document_id, 32);
            FETCH c_avail_del_channel INTO l_count;
            OPEN c_lkup_channel ('FAX');
            FETCH c_lkup_channel INTO l_del_desc;
            CLOSE c_lkup_channel;

            IF c_avail_del_channel%NOTFOUND THEN
               fnd_message.set_name ('IGS', 'IGS_CO_UNAVAIL_DEL_TYPE');
               fnd_message.set_token ('CHANNEL ', l_del_desc);
               fnd_file.put_line (fnd_file.LOG, fnd_message.get ());
               retcode := 2;
               RETURN;
            END IF;

            CLOSE c_avail_del_channel;
         END IF;

         IF INSTR (l_delivery_type, 'EMAIL') > 0 THEN
            OPEN c_avail_del_channel (l_document_id, 33);
            FETCH c_avail_del_channel INTO l_count;
            OPEN c_lkup_channel ('EMAIL');
            FETCH c_lkup_channel INTO l_del_desc;
            CLOSE c_lkup_channel;

            IF c_avail_del_channel%NOTFOUND THEN
               fnd_message.set_name ('IGS', 'IGS_CO_UNAVAIL_DEL_TYPE');
               fnd_message.set_token ('CHANNEL ', l_del_desc);
               fnd_file.put_line (fnd_file.LOG, fnd_message.get ());
               retcode := 2;
               RETURN;
            END IF;

            CLOSE c_avail_del_channel;
         END IF; -- endif for instr
      END IF; --end if l_document_id;
      -- validate all the parameters and their combinations
      IF l_sys_ltr_code NOT IN ('FAAWARD', 'FAMISTM', 'FADISBT') THEN
         l_exception := 'N';
         igs_co_process.corp_validate_parameters (
            p_sys_ltr_code       => l_sys_ltr_code,
            p_document_id        => l_document_id,
            p_select_type        => p_select_type,
            p_list_id            => p_list_id,
            p_person_id          => p_person_id,
            p_parameter_1        => p_parameter_1,
            p_parameter_2        => p_parameter_2,
            p_parameter_3        => p_parameter_3,
            p_parameter_4        => p_parameter_4,
            p_parameter_5        => p_parameter_5,
            p_parameter_6        => p_parameter_6,
            p_parameter_7        => p_parameter_7,
            p_parameter_8        => p_parameter_8,
            p_parameter_9        => p_parameter_9,
            p_override_flag      => p_override_flag,
            p_delivery_type      => l_delivery_type,
            p_exception          => l_exception
         );

         IF l_exception = 'Y' THEN
            retcode := 2;
            RETURN;
         END IF;
      END IF;

      -- for FAM letter of type System only (not even Adhoc)
      IF     l_sys_ltr_code IN ('FAAWARD', 'FAMISTM', 'FADISBT')
         AND (l_letter_type = 'SYSTEM') THEN
         l_exception := 'N';
         igf_aw_gen_004.corp_pre_process (
            p_document_id       => l_document_id,
            p_select_type       => p_select_type,
            p_sys_ltr_code      => l_sys_ltr_code,
            p_list_id           => p_list_id,
            p_letter_type       => l_letter_type,
            p_person_id         => p_person_id,
            p_parameter_1       => p_parameter_1,
            p_parameter_2       => p_parameter_2,
            p_parameter_3       => p_parameter_3,
            p_parameter_4       => p_parameter_4,
            p_parameter_5       => p_parameter_5,
            p_parameter_6       => p_parameter_6,
            p_parameter_7       => p_parameter_7,
            p_parameter_8       => p_parameter_8,
            p_parameter_9       => p_parameter_9,
            p_sql_stmt          => l_sql_stmt,
            p_flag              => p_override_flag,
            p_exception         => l_exception
         );

         IF l_exception = 'Y' THEN
            retcode := 2;
            RETURN;
         END IF;

         -- since it is FAM letter, ADM related fields should be made Null
         l_appl_sequence_number := NULL;
         l_adm_appl_number := NULL;
         l_nominated_course_cd := NULL;
         l_awd_cal_type := RTRIM (SUBSTR (p_parameter_1, 1, 10));
         l_awd_ci_seq_number := TO_NUMBER (RTRIM (SUBSTR (p_parameter_1, 11)));
      END IF;

      --**  proc level logging.
      IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
         IF (l_log_request_id IS NULL) THEN
            l_log_request_id := fnd_global.conc_request_id;
         END IF;

         l_label :=
            'igs.plsql.igs_co_submit.submit_correspondence_request.FACaldetails';
         l_debug_str :=    'FA Calendar :'
                        || l_awd_cal_type
                        || '-'
                        || l_awd_ci_seq_number;
         fnd_log.string_with_context (
            fnd_log.level_procedure,
            l_label,
            l_debug_str,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            TO_CHAR (l_log_request_id)
         );
      END IF;

      --**

      --
      IF    p_override_flag = 'Y'
         OR (l_sys_ltr_code IN ('FAAWARD', 'FAMISTM', 'FADISBT')) THEN
         -- if letter code is NOT FAM related then, we need to call the 'build sql stmt' from igs_co_process_pkg
         -- otherwise if it FAM related, we need to directly execute the SQL stmt received in pre_process proc.
         IF (l_sys_ltr_code NOT IN ('FAAWARD', 'FAMISTM', 'FADISBT')) THEN
            -- call needed only for NON FAM letters and Adhoc Letters
            l_exception := 'N';
            igs_co_process.corp_build_sql_stmt (
               p_document_id       => l_document_id,
               p_select_type       => p_select_type,
               p_sys_ltr_code      => l_sys_ltr_code,
               p_list_id           => p_list_id,
               p_letter_type       => l_letter_type,
               p_person_id         => p_person_id,
               p_parameter_1       => p_parameter_1,
               p_parameter_2       => p_parameter_2,
               p_parameter_3       => p_parameter_3,
               p_parameter_4       => p_parameter_4,
               p_parameter_5       => p_parameter_5,
               p_parameter_6       => p_parameter_6,
               p_parameter_7       => p_parameter_7,
               p_parameter_8       => p_parameter_8,
               p_parameter_9       => p_parameter_9,
               p_sql_stmt          => l_sql_stmt,
               p_exception         => l_exception
            );

            IF l_exception = 'Y' THEN
               retcode := 2;
               RETURN;
            END IF;

            -- since it is Non FAM letter, FAM related fields should be made Null
            l_awd_cal_type := NULL;
            l_awd_ci_seq_number := NULL;
         END IF;

         /* This will print the Dynamic SQL statement prepared. Can be uncommented when testing.
                   Igs_Ad_Imp_001.logDetail('l_sql_stmt :'||l_sql_stmt);
        */
             --**  proc level logging.
         IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
            IF (l_log_request_id IS NULL) THEN
               l_log_request_id := fnd_global.conc_request_id;
            END IF;

            l_label :=
               'igs.plsql.igs_co_submit.submit_correspondence_request.buildsql';
            l_debug_str := 'Build Sql :' || l_sql_stmt;
            fnd_log.string_with_context (
               fnd_log.level_procedure,
               l_label,
               l_debug_str,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               TO_CHAR (l_log_request_id)
            );
         END IF;

         --**


         IF l_sql_stmt IS NOT NULL THEN
            --Included last two system letter codes as a part of bug 2376434

            l_cursor_id := DBMS_SQL.open_cursor;
            fnd_dsql.set_cursor (l_cursor_id);
            DBMS_SQL.parse (l_cursor_id, l_sql_stmt, DBMS_SQL.native);
            fnd_dsql.do_binds;

            IF l_sys_ltr_code IN ('ADRESID',
                                 'FAADHOC',
                                 'ADADHOC',
                                 'GENERIC',
                                 'ENADHOC',
                                 'SFADHOC'
                                ) THEN
               DBMS_SQL.define_column (
                  l_cursor_id,
                  1,
                  l_email_address_dy,
                  2000
               );
               DBMS_SQL.define_column (l_cursor_id, 2, l_person_id_dy);
            ELSIF l_sys_ltr_code = 'ADACKMT' THEN
               DBMS_SQL.define_column (
                  l_cursor_id,
                  1,
                  l_email_address_dy,
                  2000
               );
               DBMS_SQL.define_column (l_cursor_id, 2, l_person_id_dy);
               DBMS_SQL.define_column (l_cursor_id, 3, l_adm_appl_number_dy);
               DBMS_SQL.define_column (
                  l_cursor_id,
                  4,
                  l_nominated_course_cd_dy,
                  6
               );
               DBMS_SQL.define_column (
                  l_cursor_id,
                  5,
                  l_appl_sequence_number_dy
               );
            ELSIF l_sys_ltr_code IN ('FAAWARD', 'FAMISTM', 'FADISBT') THEN
               DBMS_SQL.define_column (
                  l_cursor_id,
                  1,
                  l_email_address_dy,
                  2000
               );
               DBMS_SQL.define_column (l_cursor_id, 2, l_person_id_dy);
               DBMS_SQL.define_column (l_cursor_id, 3, l_award_year_dy, 17);
            ELSIF l_sys_ltr_code = 'ADINTRW' THEN
               DBMS_SQL.define_column (
                  l_cursor_id,
                  1,
                  l_email_address_dy,
                  2000
               );
               DBMS_SQL.define_column (l_cursor_id, 2, l_person_id_dy);
               DBMS_SQL.define_column (l_cursor_id, 3, l_adm_appl_number_dy);
               DBMS_SQL.define_column (
                  l_cursor_id,
                  4,
                  l_nominated_course_cd_dy,
                  6
               );
               DBMS_SQL.define_column (
                  l_cursor_id,
                  5,
                  l_appl_sequence_number_dy
               );
               DBMS_SQL.define_column (l_cursor_id, 6, l_panel_code_dy, 200);
            ELSE
               DBMS_SQL.define_column (
                  l_cursor_id,
                  1,
                  l_email_address_dy,
                  2000
               );
               DBMS_SQL.define_column (l_cursor_id, 2, l_person_id_dy);
               DBMS_SQL.define_column (l_cursor_id, 3, l_adm_appl_number_dy);
               DBMS_SQL.define_column (
                  l_cursor_id,
                  4,
                  l_nominated_course_cd_dy,
                  6
               );
               DBMS_SQL.define_column (
                  l_cursor_id,
                  5,
                  l_appl_sequence_number_dy
               );
            END IF;

            l_num_of_rows := DBMS_SQL.EXECUTE (l_cursor_id);

            /*This will print the Dynamic SQL statement prepared. Can be uncommented when testing.
                   l_dsql_debug := fnd_dsql.get_text(TRUE);
                           Igs_Ad_Imp_001.logDetail('l_dsql_debug :'||l_dsql_debug);
           */
            LOOP
               IF DBMS_SQL.fetch_rows (l_cursor_id) > 0 THEN
                  l_person_processed := l_person_processed + 1;

                  IF l_sys_ltr_code IN ('ADRESID',
                                       'FAADHOC',
                                       'ADADHOC',
                                       'GENERIC',
                                       'ENADHOC',
                                       'SFADHOC'
                                      ) THEN
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        1,
                        l_email_address_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 2, l_person_id_dy);
                  ELSIF l_sys_ltr_code = 'ADACKMT' THEN
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        1,
                        l_email_address_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 2, l_person_id_dy);
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        3,
                        l_adm_appl_number_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        4,
                        l_nominated_course_cd_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        5,
                        l_appl_sequence_number_dy
                     );
                  ELSIF l_sys_ltr_code IN ('FAAWARD', 'FAMISTM', 'FADISBT') THEN
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        1,
                        l_email_address_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 2, l_person_id_dy);
                     DBMS_SQL.column_value (l_cursor_id, 3, l_award_year_dy);
                  ELSIF l_sys_ltr_code = 'ADINTRW' THEN
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        1,
                        l_email_address_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 2, l_person_id_dy);
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        3,
                        l_adm_appl_number_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        4,
                        l_nominated_course_cd_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        5,
                        l_appl_sequence_number_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 6, l_panel_code_dy);
                  ELSE
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        1,
                        l_email_address_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 2, l_person_id_dy);
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        3,
                        l_adm_appl_number_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        4,
                        l_nominated_course_cd_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        5,
                        l_appl_sequence_number_dy
                     );
                  END IF;
               ELSE
                  EXIT;
               END IF;

               l_address_found := 'N';

               IF     INSTR (l_delivery_type, 'EMAIL') > 0
                  AND l_email_address_dy IS NOT NULL THEN
                  l_address_found := 'Y';
               END IF;

               -- executing Dynamic SQL. Either received from build_sql_stmt procedure (for Admissions) or Pre_Process (for FAM related letters)
               -- do not submit a request for students without mail Ids.
               IF INSTR (l_delivery_type, 'EMAIL') > 0 AND l_address_found =
                                                                           'N' THEN
                  OPEN c_person_number (l_person_id_dy);
                  FETCH c_person_number INTO l_person_number, l_full_name;
                  CLOSE c_person_number;
                  -- log a message that Email ID is Null
                  fnd_message.set_name ('IGS', 'IGS_CO_PRSN_NO_EMAIL');
                  fnd_message.set_token (
                     'STUDENT',
                     l_person_number || ' - ' || l_full_name
                  );
                  fnd_file.put_line (fnd_file.LOG, fnd_message.get);
               ELSE
                  IF     l_sys_ltr_code IN ('FAAWARD', 'FAMISTM', 'FADISBT')
                     AND (l_letter_type = 'SYSTEM') THEN
                     --**  exec level logging.

                     --**
                     igs_co_process.corp_submit_fulfil_request (
                        p_letter_type               => l_letter_type,
                        p_person_id                 => l_person_id_dy,
                        p_sys_ltr_code              => l_sys_ltr_code,
                        p_email_address             => l_email_address_dy,
                        p_content_id                => l_document_id,
                        p_adm_appl_number           => l_adm_appl_number_dy,
                        p_nominated_course_cd       => l_nominated_course_cd_dy,
                        p_appl_sequence_number      => l_appl_sequence_number_dy,
                        p_award_year                => p_parameter_1,
                        p_fulfillment_req           => l_fulfillment_req,
                        p_crm_user_id               => l_crm_user_id,
                        p_media_type                => l_delivery_type,
                        p_destination               => l_printer_name, -- Added the parameter p_destination which takes the value of the printer name. Bug# 2472250
                        p_fax_number                => l_fax_number,
                        p_request_id                => l_request_id,
                        p_request_status            => l_request_status,
                        p_reply_email               => p_reply_email,
                        p_sender_email              => p_sender_email,
                        p_cc_email                  => p_cc_email,
                        p_org_unit_id               => p_org_unit_id,
                        p_preview                   => p_preview,
                        p_awd_cal_type              => l_awd_cal_type,
                        p_awd_ci_seq_number         => l_awd_ci_seq_number,
                        p_awd_prd_cd                => p_parameter_2
                     );

                     IF NOT igs_co_process.l_corp_submit_fulfil_request THEN
                        IF p_preview = 'Y' THEN
                           IF NOT l_preview_batch_stored THEN
                              -- Store away request values  so they can be used later to fulfill the request after preview.
                              -- PACROSS - 11-SEP-2005
			      BEGIN
				      INSERT INTO igs_co_prv_bch_reqs
						  (concurrent_request_id,
						   master_content_id,
						   master_content_type_code,
						   master_version_id,
						   master_language,
						   master_media_type_code,
						   master_template_updated_flag,
						   batch_cancelled_flag,
						   object_version_number, created_by,
						   creation_date, last_updated_by,
						   last_update_login,
						   last_update_date)
					   VALUES (fnd_global.conc_request_id,
						   l_document_id,
						   l_letter_type,
						   l_version_id,
						   USERENV ('LANG'),
						   l_delivery_type,
						   'N',
						   'N',
						   1, fnd_global.user_id,
						   SYSDATE, fnd_global.user_id,
						   NULL,
						   SYSDATE);

					l_preview_batch_stored := TRUE ;
			      EXCEPTION	--added by svadde  on 10/31/2005
				      WHEN OTHERS THEN
					 IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
					    IF (l_log_request_id IS NULL) THEN
					       l_log_request_id := fnd_global.conc_request_id;
					    END IF;

					    l_label :=
					       'igs.plsql.igs_co_submit.submit_correspondence_request.exception';
					    l_debug_str := 'Insert into igs_co_prv_bch_reqs failed with :' || SQLERRM;
					    fnd_log.string_with_context (
					       fnd_log.level_procedure,
					       l_label,
					       l_debug_str,
					       NULL,
					       NULL,
					       NULL,
					       NULL,
					       NULL,
					       TO_CHAR (l_log_request_id)
					    );
					 END IF;
					 app_exception.RAISE_EXCEPTION;
			      END;
                           END IF;
                        ELSE
                           -- post-process the request as per pre-preview and edit

                           igs_co_process.corp_post_process (
                              p_person_id                => l_person_id_dy,
                              p_request_id               => l_request_id,
                              p_document_id              => l_document_id,
                              p_sys_ltr_code             => l_sys_ltr_code,
                              p_document_type            => l_letter_type,
                              p_adm_appl_number          => l_adm_appl_number_dy,
                              p_nominated_course_cd      => l_nominated_course_cd_dy,
                              p_appl_seq_number          => l_appl_sequence_number_dy,
                              p_award_year               => p_parameter_1,
                              p_awd_cal_type             => l_awd_cal_type,
                              p_awd_ci_seq_number        => l_awd_ci_seq_number,
                              p_delivery_type            => p_delivery_type,
                              p_version_id               => l_version_id,
                              p_award_prd_cd             => p_parameter_2
                           );
                        END IF;
                     END IF;
                  ELSE
                     --**  exec level logging.

                     --**
                     igs_co_process.corp_submit_fulfil_request (
                        p_letter_type               => l_letter_type,
                        p_person_id                 => l_person_id_dy,
                        p_sys_ltr_code              => l_sys_ltr_code,
                        p_email_address             => l_email_address_dy,
                        p_content_id                => l_document_id,
                        p_adm_appl_number           => l_adm_appl_number_dy,
                        p_nominated_course_cd       => l_nominated_course_cd_dy,
                        p_appl_sequence_number      => l_appl_sequence_number_dy,
                        p_award_year                => p_parameter_1,
                        p_fulfillment_req           => l_fulfillment_req,
                        p_crm_user_id               => l_crm_user_id,
                        p_media_type                => l_delivery_type,
                        p_destination               => l_printer_name, -- Added the parameter p_destination which takes the value of the printer name. Bug# 2472250
                        p_fax_number                => l_fax_number,
                        p_reply_days                => p_parameter_8,
                        p_panel_code                => p_parameter_5,
                        p_request_id                => l_request_id,
                        p_request_status            => l_request_status,
                        p_reply_email               => p_reply_email,
                        p_sender_email              => p_sender_email,
                        p_cc_email                  => p_cc_email,
                        p_org_unit_id               => p_org_unit_id,
                        p_preview                   => p_preview,
                        p_awd_cal_type              => l_awd_cal_type,
                        p_awd_ci_seq_number         => l_awd_ci_seq_number,
                        p_awd_prd_cd                => p_parameter_2
                     );

                     IF NOT igs_co_process.l_corp_submit_fulfil_request THEN
                        IF p_preview = 'Y' THEN
                           IF NOT l_preview_batch_stored THEN
                              -- Store away request values  so they can be used later to fulfill the request after preview.
                              -- PACROSS - 11-SEP-2005
			      BEGIN
				INSERT INTO igs_co_prv_bch_reqs
                                          (concurrent_request_id,
                                           master_content_id,
                                           master_content_type_code,
                                           master_version_id,
                                           master_language,
                                           master_media_type_code,
                                           master_template_updated_flag,
                                           batch_cancelled_flag,
                                           object_version_number, created_by,
                                           creation_date, last_updated_by,
                                           last_update_login,
                                           last_update_date)
                                   VALUES (fnd_global.conc_request_id,
                                           l_document_id,
                                           l_letter_type,
                                           l_version_id,
                                           USERENV ('LANG'),
                                           l_delivery_type,
                                           'N',
                                           'N',
                                           1, fnd_global.user_id,
                                           SYSDATE, fnd_global.user_id,
                                           NULL,
                                           SYSDATE);

				    l_preview_batch_stored := TRUE ;
				EXCEPTION	--added by svadde  on 10/31/2005
					      WHEN OTHERS THEN
						 IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
						    IF (l_log_request_id IS NULL) THEN
						       l_log_request_id := fnd_global.conc_request_id;
						    END IF;

						    l_label :=
						       'igs.plsql.igs_co_submit.submit_correspondence_request.exception';
						    l_debug_str := 'Insert into igs_co_prv_bch_reqs failed with :' || SQLERRM;
						    fnd_log.string_with_context (
						       fnd_log.level_procedure,
						       l_label,
						       l_debug_str,
						       NULL,
						       NULL,
						       NULL,
						       NULL,
						       NULL,
						       TO_CHAR (l_log_request_id)
						    );
						 END IF;
						 app_exception.RAISE_EXCEPTION;
				      END;
				END IF;
                        ELSE
                           -- post-process the request as per pre-preview and edit
                           igs_co_process.corp_post_process (
                              p_person_id                => l_person_id_dy,
                              p_request_id               => l_request_id,
                              p_document_id              => l_document_id,
                              p_sys_ltr_code             => l_sys_ltr_code,
                              p_document_type            => l_letter_type,
                              p_adm_appl_number          => l_adm_appl_number_dy,
                              p_nominated_course_cd      => l_nominated_course_cd_dy,
                              p_appl_seq_number          => l_appl_sequence_number_dy,
                              p_award_year               => p_parameter_1,
                              p_awd_cal_type             => l_awd_cal_type,
                              p_awd_ci_seq_number        => l_awd_ci_seq_number,
                              p_delivery_type            => p_delivery_type,
                              p_version_id               => l_version_id,
                              p_award_prd_cd             => p_parameter_2
                           );
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;

            DBMS_SQL.close_cursor (l_cursor_id);

            IF p_preview = 'Y' THEN
                 -- If in preview mode then build the HTML in the concurrent request to take the user to the workbench.
                 -- PACROSS - 11-SEP-2005
               --** proc level logging.
               IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
                  IF (l_log_request_id IS NULL) THEN
                     l_log_request_id := fnd_global.conc_request_id;
                  END IF;

                  l_label :=
                     'igs.plsql.igs_co_submit.submit_correspondence_request.calling_build_preview_1';
                  l_debug_str := 'calling build_preview_html_1';
                  fnd_log.string_with_context (
                     fnd_log.level_procedure,
                     l_label,
                     l_debug_str,
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     TO_CHAR (l_log_request_id)
                  );
               END IF;

               --**
               build_preview_html (fnd_global.conc_request_id);
            END IF;
         ELSE
            fnd_message.set_name ('IGS', 'IGS_CO_NO_REC');
            fnd_file.put_line (fnd_file.LOG, fnd_message.get ());
            fnd_file.put_line (fnd_file.LOG, ' ');
            RETURN;
         END IF;

         IF l_person_processed = 0 THEN
            fnd_message.set_name ('IGS', 'IGS_CO_NO_REC');
            fnd_file.put_line (fnd_file.LOG, fnd_message.get ());
            fnd_file.put_line (fnd_file.LOG, ' ');

            --fnd_file.put_line(FND_FILE.LOG,l_sql_stmt);

            --**  exec level logging.
            IF fnd_log.test (fnd_log.level_exception, l_prog_label) THEN
               IF (l_log_request_id IS NULL) THEN
                  l_log_request_id := fnd_global.conc_request_id;
               END IF;

               l_label :=
                  'igs.plsql.igs_co_submit.submit_correspondence_request.sqlnodata.Y';
               l_debug_str := 'Sql Statement :' || l_sql_stmt;
               fnd_log.string_with_context (
                  fnd_log.level_exception,
                  l_label,
                  l_debug_str,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  TO_CHAR (l_log_request_id)
               );
            END IF;
            --**

            RETURN;
         END IF;
      ELSIF p_override_flag = 'N' THEN
         -- if FAM letter then Document attribute checking is not required.
         IF l_sys_ltr_code NOT IN ('FAAWARD', 'FAMISTM', 'FADISTM') THEN
            igs_co_process.corp_check_document_attributes (
               p_map_id             => p_map_id,
               p_elapsed_days       => l_elapsed_days,
               p_no_of_repeats      => l_no_of_repeats
            );
                     -- If NOT FAM letter and if the Elapsed days and No of repeats is not Null then only we need to call the build SQL stmt procedure
                     -- If it is FAM letter, then the Pre Process procedure call itself gets the Dynamic SQL query and hence we need to bypass the call corp_build_sql_Stmt
            --        IF (l_elapsed_days IS NOT NULL OR l_no_of_repeats is NOT NULL) THEN
            l_exception := 'N';
            igs_co_process.corp_build_sql_stmt (
               p_document_id       => l_document_id,
               p_select_type       => p_select_type,
               p_sys_ltr_code      => l_sys_ltr_code,
               p_list_id           => p_list_id,
               p_letter_type       => l_letter_type,
               p_person_id         => p_person_id,
               p_parameter_1       => p_parameter_1,
               p_parameter_2       => p_parameter_2,
               p_parameter_3       => p_parameter_3,
               p_parameter_4       => p_parameter_4,
               p_parameter_5       => p_parameter_5,
               p_parameter_6       => p_parameter_6,
               p_parameter_7       => p_parameter_7,
               p_parameter_8       => p_parameter_8,
               p_parameter_9       => p_parameter_9,
               p_sql_stmt          => l_sql_stmt,
               p_exception         => l_exception
            );

            IF l_exception = 'Y' THEN
               retcode := 2;
               RETURN;
            END IF;

            --         END IF;
            l_awd_cal_type := NULL;
            l_awd_ci_seq_number := NULL;
         END IF;

         /* This will print the Dynamic SQL statement prepared. Can be uncommented when testing.
                   Igs_Ad_Imp_001.logDetail('l_sql_stmt :'||l_sql_stmt);
        */

         -- executing Dynamic SQL. Either received from build_sql_stmt procedure (for Admissions) or Pre_Process (for FAM related letters)
         IF l_sql_stmt IS NOT NULL THEN
            --Included last two system letter codes as a part of bug 2376434
            l_cursor_id := DBMS_SQL.open_cursor;
            fnd_dsql.set_cursor (l_cursor_id);
            DBMS_SQL.parse (l_cursor_id, l_sql_stmt, DBMS_SQL.native);
            fnd_dsql.do_binds;

            IF l_sys_ltr_code IN ('ADRESID',
                                 'FAADHOC',
                                 'ADADHOC',
                                 'GENERIC',
                                 'ENADHOC',
                                 'SFADHOC'
                                ) THEN
               DBMS_SQL.define_column (
                  l_cursor_id,
                  1,
                  l_email_address_dy,
                  2000
               );
               DBMS_SQL.define_column (l_cursor_id, 2, l_person_id_dy);
            ELSIF l_sys_ltr_code = 'ADACKMT' THEN
               DBMS_SQL.define_column (
                  l_cursor_id,
                  1,
                  l_email_address_dy,
                  2000
               );
               DBMS_SQL.define_column (l_cursor_id, 2, l_person_id_dy);
               DBMS_SQL.define_column (l_cursor_id, 3, l_adm_appl_number_dy);
               DBMS_SQL.define_column (
                  l_cursor_id,
                  4,
                  l_nominated_course_cd_dy,
                  6
               );
               DBMS_SQL.define_column (
                  l_cursor_id,
                  5,
                  l_appl_sequence_number_dy
               );
            ELSIF l_sys_ltr_code IN ('FAAWARD', 'FAMISTM', 'FADISBT') THEN
               DBMS_SQL.define_column (
                  l_cursor_id,
                  1,
                  l_email_address_dy,
                  2000
               );
               DBMS_SQL.define_column (l_cursor_id, 2, l_person_id_dy);
               DBMS_SQL.define_column (l_cursor_id, 3, l_award_year_dy, 17);
            ELSIF l_sys_ltr_code = 'ADINTRW' THEN
               DBMS_SQL.define_column (
                  l_cursor_id,
                  1,
                  l_email_address_dy,
                  2000
               );
               DBMS_SQL.define_column (l_cursor_id, 2, l_person_id_dy);
               DBMS_SQL.define_column (l_cursor_id, 3, l_adm_appl_number_dy);
               DBMS_SQL.define_column (
                  l_cursor_id,
                  4,
                  l_nominated_course_cd_dy,
                  6
               );
               DBMS_SQL.define_column (
                  l_cursor_id,
                  5,
                  l_appl_sequence_number_dy
               );
               DBMS_SQL.define_column (l_cursor_id, 6, l_panel_code_dy, 200);
            ELSE
               DBMS_SQL.define_column (
                  l_cursor_id,
                  1,
                  l_email_address_dy,
                  2000
               );
               DBMS_SQL.define_column (l_cursor_id, 2, l_person_id_dy);
               DBMS_SQL.define_column (l_cursor_id, 3, l_adm_appl_number_dy);
               DBMS_SQL.define_column (
                  l_cursor_id,
                  4,
                  l_nominated_course_cd_dy,
                  6
               );
               DBMS_SQL.define_column (
                  l_cursor_id,
                  5,
                  l_appl_sequence_number_dy
               );
            END IF;

            l_num_of_rows := DBMS_SQL.EXECUTE (l_cursor_id);

            /* This will print the Dynamic SQL statement prepared. Can be uncommented when testing.
                   l_dsql_debug := fnd_dsql.get_text(TRUE);
                           Igs_Ad_Imp_001.logDetail('l_dsql_debug :'||l_dsql_debug);
           */
            LOOP
               IF DBMS_SQL.fetch_rows (l_cursor_id) > 0 THEN
                  l_person_processed := l_person_processed + 1;

                  IF l_sys_ltr_code IN ('ADRESID',
                                       'FAADHOC',
                                       'ADADHOC',
                                       'GENERIC',
                                       'ENADHOC',
                                       'SFADHOC'
                                      ) THEN
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        1,
                        l_email_address_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 2, l_person_id_dy);
                  ELSIF l_sys_ltr_code = 'ADACKMT' THEN
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        1,
                        l_email_address_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 2, l_person_id_dy);
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        3,
                        l_adm_appl_number_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        4,
                        l_nominated_course_cd_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        5,
                        l_appl_sequence_number_dy
                     );
                  ELSIF l_sys_ltr_code IN ('FAAWARD', 'FAMISTM', 'FADISBT') THEN
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        1,
                        l_email_address_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 2, l_person_id_dy);
                     DBMS_SQL.column_value (l_cursor_id, 3, l_award_year_dy);
                  ELSIF l_sys_ltr_code = 'ADINTRW' THEN
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        1,
                        l_email_address_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 2, l_person_id_dy);
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        3,
                        l_adm_appl_number_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        4,
                        l_nominated_course_cd_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        5,
                        l_appl_sequence_number_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 6, l_panel_code_dy);
                  ELSE
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        1,
                        l_email_address_dy
                     );
                     DBMS_SQL.column_value (l_cursor_id, 2, l_person_id_dy);
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        3,
                        l_adm_appl_number_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        4,
                        l_nominated_course_cd_dy
                     );
                     DBMS_SQL.column_value (
                        l_cursor_id,
                        5,
                        l_appl_sequence_number_dy
                     );
                  END IF;

                  l_address_found := 'N';

                  IF     INSTR (l_delivery_type, 'EMAIL') > 0
                     AND l_email_address_dy IS NOT NULL THEN
                     l_address_found := 'Y';
                  /*          l_delivery_type := 'EMAIL';
                          ELSIF p_delivery_type = 'FAX' THEN
                           l_delivery_type := 'FAX';*/
                  END IF;
               ELSE
                  EXIT;
               END IF;

               l_send_letter := 'TRUE'; -- default is to be taken as True
               -- process only for persons having an email id.
               IF INSTR (l_delivery_type, 'EMAIL') > 0 AND l_address_found =
                                                                           'N' THEN
                  OPEN c_person_number (l_person_id_dy);
                  FETCH c_person_number INTO l_person_number, l_full_name;
                  CLOSE c_person_number;
                  -- log a message that Email ID is Null
                  fnd_message.set_name ('IGS', 'IGS_CO_PRSN_NO_EMAIL');
                  fnd_message.set_token (
                     'STUDENT',
                     l_person_number || ' - ' || l_full_name
                  );
                  fnd_file.put_line (fnd_file.LOG, fnd_message.get);
               ELSE
                  IF l_sys_ltr_code NOT IN ('FAAWARD', 'FAMISTM', 'FADISTM') THEN
                     igs_co_process.corp_check_interaction_history (
                        p_person_id           => l_person_id_dy,
                        p_sys_ltr_code        => l_sys_ltr_code,
                        p_document_id         => l_document_id,
                        p_application_id      => l_adm_appl_number_dy,
                        p_course_cd           => l_nominated_course_cd_dy,
                        p_adm_seq_no          => l_appl_sequence_number_dy,
                        p_awd_cal_type        => l_awd_cal_type,
                        p_awd_seq_no          => l_awd_ci_seq_number,
                        p_elapsed_days        => l_elapsed_days,
                        p_no_of_repeats       => l_no_of_repeats,
                        p_send_letter         => l_send_letter
                     );
                  END IF;

                  IF l_send_letter = 'TRUE' THEN
                     IF     l_sys_ltr_code IN
                                            ('FAAWARD', 'FAMISTM', 'FADISTBT')
                        AND (l_letter_type = 'SYSTEM') THEN
                        --**  exec level logging.
                        --**
                        igs_co_process.corp_submit_fulfil_request (
                           p_letter_type               => l_letter_type,
                           p_person_id                 => l_person_id_dy,
                           p_sys_ltr_code              => l_sys_ltr_code,
                           p_email_address             => l_email_address_dy,
                           p_content_id                => l_document_id,
                           p_adm_appl_number           => l_adm_appl_number_dy,
                           p_nominated_course_cd       => l_nominated_course_cd_dy,
                           p_appl_sequence_number      => l_appl_sequence_number_dy,
                           p_award_year                => p_parameter_1,
                           p_fulfillment_req           => l_fulfillment_req,
                           p_crm_user_id               => l_crm_user_id,
                           p_media_type                => l_delivery_type,
                           p_destination               => l_printer_name, -- Added the parameter p_destination which takes the value of the printer name. Bug# 2472250
                           p_fax_number                => l_fax_number,
                           p_request_id                => l_request_id,
                           p_request_status            => l_request_status,
                           p_reply_email               => p_reply_email,
                           p_sender_email              => p_sender_email,
                           p_cc_email                  => p_cc_email,
                           p_org_unit_id               => p_org_unit_id,
                           p_preview                   => p_preview,
                           p_awd_cal_type              => l_awd_cal_type,
                           p_awd_ci_seq_number         => l_awd_ci_seq_number,
                           p_awd_prd_cd                => p_parameter_2
                        );

                        IF NOT igs_co_process.l_corp_submit_fulfil_request THEN
                           IF p_preview = 'Y' THEN
                              -- Store away request values  so they can be used later to fulfill the request after preview.
                              -- PACROSS - 11-SEP-2005

                              IF NOT l_preview_batch_stored THEN
				BEGIN
                                 INSERT INTO igs_co_prv_bch_reqs
                                             (concurrent_request_id,
                                              master_content_id,
                                              master_content_type_code,
                                              master_version_id,
                                              master_language,
                                              master_media_type_code,
                                              master_template_updated_flag,
                                              batch_cancelled_flag,
                                              object_version_number,
                                              created_by, creation_date,
                                              last_updated_by,
                                              last_update_login,
                                              last_update_date)
                                      VALUES (fnd_global.conc_request_id,
                                              l_document_id,
                                              l_letter_type,
                                              l_version_id,
                                              USERENV ('LANG'),
                                              l_delivery_type,
                                              'N',
                                              'N',
                                              1,
                                              fnd_global.user_id, SYSDATE,
                                              fnd_global.user_id,
                                              NULL,
                                              SYSDATE);

				    l_preview_batch_stored := TRUE ;
				  EXCEPTION	--added by svadde  on 10/31/2005
					      WHEN OTHERS THEN
						 IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
						    IF (l_log_request_id IS NULL) THEN
						       l_log_request_id := fnd_global.conc_request_id;
						    END IF;

						    l_label :=
						       'igs.plsql.igs_co_submit.submit_correspondence_request.exception';
						    l_debug_str := 'Insert into igs_co_prv_bch_reqs failed with :' || SQLERRM;
						    fnd_log.string_with_context (
						       fnd_log.level_procedure,
						       l_label,
						       l_debug_str,
						       NULL,
						       NULL,
						       NULL,
						       NULL,
						       NULL,
						       TO_CHAR (l_log_request_id)
						    );
						 END IF;
						 app_exception.RAISE_EXCEPTION;
				      END;

                              END IF;
                           ELSE
                              -- post-process the request as per pre-preview and edit

                              igs_co_process.corp_post_process (
                                 p_person_id                => l_person_id_dy,
                                 p_request_id               => l_request_id,
                                 p_document_id              => l_document_id,
                                 p_sys_ltr_code             => l_sys_ltr_code,
                                 p_document_type            => l_letter_type,
                                 p_adm_appl_number          => l_adm_appl_number_dy,
                                 p_nominated_course_cd      => l_nominated_course_cd_dy,
                                 p_appl_seq_number          => l_appl_sequence_number_dy,
                                 p_award_year               => p_parameter_1,
                                 p_awd_cal_type             => l_awd_cal_type,
                                 p_awd_ci_seq_number        => l_awd_ci_seq_number,
                                 p_delivery_type            => p_delivery_type,
                                 p_version_id               => l_version_id,
                                 p_award_prd_cd             => p_parameter_2
                              );
                           END IF;
                        END IF;
                     ELSE
                        igs_co_process.corp_submit_fulfil_request (
                           p_letter_type               => l_letter_type,
                           p_person_id                 => l_person_id_dy,
                           p_sys_ltr_code              => l_sys_ltr_code,
                           p_email_address             => l_email_address_dy,
                           p_content_id                => l_document_id,
                           p_adm_appl_number           => l_adm_appl_number_dy,
                           p_nominated_course_cd       => l_nominated_course_cd_dy,
                           p_appl_sequence_number      => l_appl_sequence_number_dy,
                           p_award_year                => p_parameter_1,
                           p_fulfillment_req           => l_fulfillment_req,
                           p_crm_user_id               => l_crm_user_id,
                           p_media_type                => l_delivery_type,
                           p_destination               => l_printer_name, -- Added the parameter p_destination which takes the value of the printer name. Bug# 2472250
                           p_fax_number                => l_fax_number,
                           p_reply_days                => p_parameter_8,
                           p_panel_code                => p_parameter_5,
                           p_request_id                => l_request_id,
                           p_request_status            => l_request_status,
                           p_reply_email               => p_reply_email,
                           p_sender_email              => p_sender_email,
                           p_cc_email                  => p_cc_email,
                           p_org_unit_id               => p_org_unit_id,
                           p_preview                   => p_preview,
                           p_awd_cal_type              => l_awd_cal_type,
                           p_awd_ci_seq_number         => l_awd_ci_seq_number,
                           p_awd_prd_cd                => p_parameter_2
                        );

                        IF NOT igs_co_process.l_corp_submit_fulfil_request THEN
                           IF p_preview = 'Y' THEN
                              -- Store away request values  so they can be used later to fulfill the request after preview.
                              -- PACROSS - 11-SEP-2005
                              --**  exec level logging.

                              --**

                              IF NOT l_preview_batch_stored THEN
				BEGIN
                                 INSERT INTO igs_co_prv_bch_reqs
                                             (concurrent_request_id,
                                              master_content_id,
                                              master_content_type_code,
                                              master_version_id,
                                              master_language,
                                              master_media_type_code,
                                              master_template_updated_flag,
                                              batch_cancelled_flag,
                                              object_version_number,
                                              created_by, creation_date,
                                              last_updated_by,
                                              last_update_login,
                                              last_update_date)
                                      VALUES (fnd_global.conc_request_id,
                                              l_document_id,
                                              l_letter_type,
                                              l_version_id,
                                              USERENV ('LANG'),
                                              l_delivery_type,
                                              'N',
                                              'N',
                                              1,
                                              fnd_global.user_id, SYSDATE,
                                              fnd_global.user_id,
                                              NULL,
                                              SYSDATE);

				     l_preview_batch_stored := TRUE ;
				  EXCEPTION	--added by svadde  on 10/31/2005
					      WHEN OTHERS THEN
						 IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
						    IF (l_log_request_id IS NULL) THEN
						       l_log_request_id := fnd_global.conc_request_id;
						    END IF;

						    l_label :=
						       'igs.plsql.igs_co_submit.submit_correspondence_request.exception';
						    l_debug_str := 'Insert into igs_co_prv_bch_reqs failed with :' || SQLERRM;
						    fnd_log.string_with_context (
						       fnd_log.level_procedure,
						       l_label,
						       l_debug_str,
						       NULL,
						       NULL,
						       NULL,
						       NULL,
						       NULL,
						       TO_CHAR (l_log_request_id)
						    );
						 END IF;
						 app_exception.RAISE_EXCEPTION;
				      END;
                              END IF;

                           ELSE
                              -- post-process the request as per pre-preview and edit

                              igs_co_process.corp_post_process (
                                 p_person_id                => l_person_id_dy,
                                 p_request_id               => l_request_id,
                                 p_document_id              => l_document_id,
                                 p_sys_ltr_code             => l_sys_ltr_code,
                                 p_document_type            => l_letter_type,
                                 p_adm_appl_number          => l_adm_appl_number_dy,
                                 p_nominated_course_cd      => l_nominated_course_cd_dy,
                                 p_appl_seq_number          => l_appl_sequence_number_dy,
                                 p_award_year               => p_parameter_1,
                                 p_awd_cal_type             => l_awd_cal_type,
                                 p_awd_ci_seq_number        => l_awd_ci_seq_number,
                                 p_delivery_type            => p_delivery_type,
                                 p_version_id               => l_version_id,
                                 p_award_prd_cd             => p_parameter_2
                              );
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;

            --**  exec level logging.

            --**
            DBMS_SQL.close_cursor (l_cursor_id);

            IF p_preview = 'Y' THEN
                 -- If in preview mode then build the HTML in the concurrent request to take the user to the workbench.
                 -- PACROSS - 11-SEP-2005
               --** proc level logging.
               IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
                  IF (l_log_request_id IS NULL) THEN
                     l_log_request_id := fnd_global.conc_request_id;
                  END IF;

                  l_label :=
                     'igs.plsql.igs_co_submit.submit_correspondence_request.calling_build_preview_2';
                  l_debug_str := 'calling build_preview_html_2';
                  fnd_log.string_with_context (
                     fnd_log.level_procedure,
                     l_label,
                     l_debug_str,
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     TO_CHAR (l_log_request_id)
                  );
               END IF;

               --**
               build_preview_html (fnd_global.conc_request_id);
            END IF;

            --**  exec level logging.


         ELSE
            fnd_message.set_name ('IGS', 'IGS_CO_NO_REC');
            fnd_file.put_line (fnd_file.LOG, fnd_message.get ());
            fnd_file.put_line (fnd_file.LOG, ' ');
            RETURN;
         END IF;

         IF l_person_processed = 0 THEN
            fnd_message.set_name ('IGS', 'IGS_CO_NO_REC');
            fnd_file.put_line (fnd_file.LOG, fnd_message.get ());
            fnd_file.put_line (fnd_file.LOG, ' ');

            --fnd_file.put_line(FND_FILE.LOG,l_sql_stmt);
            --**  exec level logging.
            IF fnd_log.test (fnd_log.level_exception, l_prog_label) THEN
               IF (l_log_request_id IS NULL) THEN
                  l_log_request_id := fnd_global.conc_request_id;
               END IF;

               l_label :=
                  'igs.plsql.igs_co_submit.submit_correspondence_request.sqlnodata.N';
               l_debug_str := 'Sql Statement :' || l_sql_stmt;
               fnd_log.string_with_context (
                  fnd_log.level_exception,
                  l_label,
                  l_debug_str,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  TO_CHAR (l_log_request_id)
               );
            END IF;
            --**

            RETURN;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         retcode := 2;
         fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token (
            'NAME',
            'igs_co_submit.submit_correspondence_request' || '-' || SQLERRM
         );
         igs_ge_msg_stack.conc_exception_hndl;
   END submit_correspondence_request;

   PROCEDURE distribute_preview_request (
      errbuf              OUT NOCOPY      VARCHAR2,
      retcode             OUT NOCOPY      NUMBER,
      p_distribution_id   IN              NUMBER
   )
   IS
      /*******************************************************************
      Created By : Kevin Leggett/Paul Cross
      Date Created on : 11-Sep-2005
      Purpose : This procedure is the main concurrent program procedure
                for distributing previewed correspondence requests. Its
                logic is based on the existing functionality inside the
                IGS_CO_SUBMIT.submit_correspondence_request concurrent
                program procedure. More specifically the segments
                responsible performing the actual distribution and post
                processing to update the IGS Interaction History.
      Know limitations, enhancements or remarks
      Change History
      Who             When            What
     gmaheswa	5-Jan-2004	Bug 4869737 Added a call to SET_ORG_ID to disable OSS for R12.
     ********************************************************************/

      -- Cursor to obtain the preview requests for this distribution
      CURSOR c_preview_requests (cp_distribution_id NUMBER)
      IS
         SELECT concurrent_request_id, letter_type_code, person_id,
                email_address, original_content_id, current_content_id,
                award_year, sys_ltr_code, adm_appl_number, nominated_course_cd,
                appl_sequence_number, fulfillment_req, crm_user_id,
                media_type_code, destination, fax_number, reply_days, panel_code,
                org_unit_id, awd_cal_type, awd_ci_seq_number,
                original_version_id, current_version_id, email_subject,
                original_content_xml, current_content_xml, ff_request_hist_id,
                extended_header, distribution_id, award_prd_cd
           FROM igs_co_prev_reqs
          WHERE distribution_id = cp_distribution_id
            AND NOT (   request_status_code = 'CANCELLED'
                     OR request_status_code = 'DISTRIBUTED'
                    );

      -- Cursor to log the person's processed
      CURSOR c_per_processed (cp_person_id NUMBER)
      IS
         SELECT person_number, full_name
           FROM igs_pe_person_base_v
          WHERE person_id = cp_person_id;

      -- Get version id of content for interaction history
      CURSOR c_content_version (
         cp_content_id                NUMBER,
         cp_content_item_version_id   NUMBER
      )
      IS
         SELECT version
           FROM ibc_citems_v
          WHERE citem_id = cp_content_id
            AND citem_ver_id = cp_content_item_version_id;

      -- Preview request variables...
      l_concurrent_request_id   igs_co_prev_reqs.concurrent_request_id%TYPE;
      l_letter_type             igs_co_prev_reqs.letter_type_code%TYPE;
      l_person_id               igs_co_prev_reqs.person_id%TYPE;
      l_email_address           igs_co_prev_reqs.email_address%TYPE;
      l_original_content_id     igs_co_prev_reqs.original_content_id%TYPE;
      l_current_content_id      igs_co_prev_reqs.current_content_id%TYPE;
      l_award_year              igs_co_prev_reqs.award_year%TYPE;
      l_sys_ltr_code            igs_co_prev_reqs.sys_ltr_code%TYPE;
      l_adm_appl_number         igs_co_prev_reqs.adm_appl_number%TYPE;
      l_nominated_course_cd     igs_co_prev_reqs.nominated_course_cd%TYPE;
      l_appl_sequence_number    igs_co_prev_reqs.appl_sequence_number%TYPE;
      l_fulfillment_req         igs_co_prev_reqs.fulfillment_req%TYPE;
      l_crm_user_id             igs_co_prev_reqs.crm_user_id%TYPE;
      l_media_type              igs_co_prev_reqs.media_type_code%TYPE;
      l_destination             igs_co_prev_reqs.destination%TYPE;
      l_fax_number              igs_co_prev_reqs.fax_number%TYPE;
      l_reply_days              igs_co_prev_reqs.reply_days%TYPE;
      l_panel_code              igs_co_prev_reqs.panel_code%TYPE;
      l_org_unit_id             igs_co_prev_reqs.org_unit_id%TYPE;
      l_awd_cal_type            igs_co_prev_reqs.awd_cal_type%TYPE;
      l_awd_ci_seq_number       igs_co_prev_reqs.awd_ci_seq_number%TYPE;
      l_originalversion_id      igs_co_prev_reqs.original_version_id%TYPE;
      l_currentversion_id       igs_co_prev_reqs.current_version_id%TYPE;
      l_email_subject           igs_co_prev_reqs.email_subject%TYPE;
      l_original_content_xml    igs_co_prev_reqs.original_content_xml%TYPE;
      l_current_content_xml     igs_co_prev_reqs.current_content_xml%TYPE;
      l_ff_request_hist_id      igs_co_prev_reqs.ff_request_hist_id%TYPE;
      l_extended_header         igs_co_prev_reqs.extended_header%TYPE;
      l_distribution_id         igs_co_prev_reqs.distribution_id%TYPE;
      l_award_prd_cd            igs_co_prev_reqs.award_prd_cd%TYPE;
      -- Person details...
      l_full_name               igs_pe_person_base_v.full_name%TYPE;
      l_person_number           igs_pe_person_base_v.person_number%TYPE;
      -- Version
      l_version                 ibc_citems_v.version%TYPE;
      -- Return status
      l_return_status           VARCHAR2 (30);
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2 (2000);
      l_tmp_var                 VARCHAR2 (4000);
      l_tmp_var1                VARCHAR2 (4000);
      l_prog_label     CONSTANT VARCHAR2 (500)   := 'igs.plsql.igs_co_submit';
      l_tmp_request_id          NUMBER;
      l_label                   VARCHAR2 (4000);
      l_debug_str               VARCHAR2 (4000);
   BEGIN
      igs_ge_gen_003.set_org_id;

      -- Default to success (0-Success, 1-Success with warnings, 2-Error)
      retcode := 0;

      IF p_distribution_id IS NOT NULL THEN
         OPEN c_preview_requests (p_distribution_id);

         LOOP
            FETCH c_preview_requests INTO l_concurrent_request_id,
                                          l_letter_type,
                                          l_person_id,
                                          l_email_address,
                                          l_original_content_id,
                                          l_current_content_id,
                                          l_award_year,
                                          l_sys_ltr_code,
                                          l_adm_appl_number,
                                          l_nominated_course_cd,
                                          l_appl_sequence_number,
                                          l_fulfillment_req,
                                          l_crm_user_id,
                                          l_media_type,
                                          l_destination,
                                          l_fax_number,
                                          l_reply_days,
                                          l_panel_code,
                                          l_org_unit_id,
                                          l_awd_cal_type,
                                          l_awd_ci_seq_number,
                                          l_originalversion_id,
                                          l_currentversion_id,
                                          l_email_subject,
                                          l_original_content_xml,
                                          l_current_content_xml,
                                          l_ff_request_hist_id,
                                          l_extended_header,
                                          l_distribution_id,
                                          l_award_prd_cd;
            EXIT WHEN c_preview_requests%NOTFOUND;
            jtf_fm_request_grp.submit_previewed_request (
               p_api_version        => 1,
               p_init_msg_list      => 'T',
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               p_request_id         => l_ff_request_hist_id
            );

            IF l_return_status = 'S' THEN
               OPEN c_per_processed (l_person_id);
               FETCH c_per_processed INTO l_person_number, l_full_name;
               fnd_message.set_name ('IGF', 'IGF_AW_PROC_STUD');
               fnd_message.set_token (
                  'STDNT',
                  l_person_number || ' - ' || l_full_name
               );
               fnd_file.put_line (fnd_file.LOG, fnd_message.get);
               fnd_message.set_name ('IGS', 'IGS_CO_REQ_INFO');
               fnd_message.set_token ('REQUEST_ID', l_ff_request_hist_id);
               fnd_file.put_line (fnd_file.LOG, fnd_message.get);
               CLOSE c_per_processed;
               OPEN c_content_version (
                  l_current_content_id,
                  l_currentversion_id
               );
               FETCH c_content_version INTO l_version;
               CLOSE c_content_version;
               -- Update the IGS_CO_PREV_REQS table to identify this request as fulfilled...
               UPDATE igs_co_prev_reqs
                  SET request_status_code = 'DISTRIBUTED'
                WHERE distribution_id = p_distribution_id;

               -- Call the post processing procedure (this will log the IGS Interaction History details)...
               igs_co_process.corp_post_process (
                  p_person_id                => l_person_id,
                  p_request_id               => l_ff_request_hist_id,
                  p_document_id              => l_current_content_id,
                  p_sys_ltr_code             => l_sys_ltr_code,
                  p_document_type            => l_letter_type,
                  p_adm_appl_number          => l_adm_appl_number,
                  p_nominated_course_cd      => l_nominated_course_cd,
                  p_appl_seq_number          => l_appl_sequence_number,
                  p_award_year               => l_award_year,
                  p_awd_cal_type             => l_awd_cal_type,
                  p_awd_ci_seq_number        => l_awd_ci_seq_number,
                  p_delivery_type            => l_media_type,
                  p_version_id               => l_version,
                  p_award_prd_cd             => l_award_prd_cd
               );
               -- Commit actions...
               COMMIT;
            ELSE
               IF l_msg_count > 1 THEN
                  FOR i IN 1 .. l_msg_count
                  LOOP
                     l_tmp_var := fnd_msg_pub.get (
                                     p_encoded      => fnd_api.g_false
                                  );
                     l_tmp_var1 := l_tmp_var1 || l_tmp_var;
                  END LOOP;

                  fnd_file.put_line (fnd_file.LOG, l_tmp_var1);
               ELSE
                  fnd_file.put_line (
                     fnd_file.LOG,
                     l_msg_data || '-' || l_msg_count
                  );
               END IF;
            END IF;

            --**  proc level logging.
            IF fnd_log.test (fnd_log.level_procedure, l_prog_label) THEN
               IF (l_tmp_request_id IS NULL) THEN
                  l_tmp_request_id := fnd_global.conc_request_id;
               END IF;

               l_label :=
                  'igs.plsql.igs_co_process.corp_submit_fulfil_request.aftersubmitrequest';
               l_debug_str :=    'Request ID :'
                              || l_ff_request_hist_id
                              || 'Return Status :'
                              || l_return_status
                              || '-'
                              || l_msg_data;
               fnd_log.string_with_context (
                  fnd_log.level_procedure,
                  l_label,
                  l_debug_str,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  TO_CHAR (l_tmp_request_id)
               );
            END IF;
         --**

         END LOOP;
         -- Explicitly close the cursor...
         CLOSE c_preview_requests;
      ELSE
         -- log message "Invalid distribution identifier supplied"
         fnd_message.set_name ('IGS', 'IGS_CO_ERR_INVLD_DIST_ID');
         fnd_file.put_line (fnd_file.LOG, fnd_message.get ());
         fnd_file.put_line (fnd_file.LOG, ' ');
         retcode := 2;
         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         retcode := 2;
         fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token (
            'NAME',
            l_prog_label || '.distribute_preview_request' || '-' || SQLERRM
         );
         igs_ge_msg_stack.conc_exception_hndl;
   END distribute_preview_request;
END igs_co_submit;

/
