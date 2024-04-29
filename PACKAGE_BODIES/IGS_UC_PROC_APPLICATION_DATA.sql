--------------------------------------------------------
--  DDL for Package Body IGS_UC_PROC_APPLICATION_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_PROC_APPLICATION_DATA" AS
/* $Header: IGSUC68B.pls 120.8 2006/09/07 06:39:13 jchakrab noship $  */

  g_success_rec_cnt NUMBER;
  g_error_rec_cnt   NUMBER;
  g_error_code      igs_uc_istark_ints.error_code%TYPE;
  g_crnt_institute  igs_uc_defaults.current_inst_code%TYPE;

  --JCHAKRAB made the config_cycle variable global for UCFD308 - UCAS 2005 Changes
  g_config_cycle    igs_uc_defaults.configured_cycle%TYPE;

  PROCEDURE appl_data_setup (errbuf  OUT NOCOPY   VARCHAR2,
                             retcode OUT NOCOPY   NUMBER)
  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   Called from Main procedure Process_ucas_data
                         for general setup validations needed before
                         processing Application data views.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jchakrab  27-JUL-04    Modified for UCFD308 - UCAS - 2005 Regulatory Changes
    ******************************************************************/

     -- Get the current institution code set in UCAS Setup for FTUG as all systems have the same.
     CURSOR crnt_inst_cur IS
     SELECT DISTINCT current_inst_code
     FROM   igs_uc_defaults
     WHERE current_inst_code IS NOT NULL;

     -- Get the Configured cycle value
     CURSOR get_config_cycle_cur IS
     SELECT MAX(configured_cycle) configured_cycle
     FROM   igs_uc_defaults ;

  BEGIN

     OPEN crnt_inst_cur;
     FETCH crnt_inst_cur INTO g_crnt_institute;
     CLOSE crnt_inst_cur;

     IF g_crnt_institute IS NULL THEN
        fnd_message.set_name('IGS','IGS_UC_CURR_INST_NOT_SET');
        errbuf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, errbuf);
        retcode := 2;
     END IF;


     OPEN get_config_cycle_cur;
     FETCH get_config_cycle_cur INTO g_config_cycle; --JCHAKRAB - modified for UCAS 2005 changes
     CLOSE get_config_cycle_cur;

     IF g_config_cycle IS NULL THEN
        fnd_message.set_name('IGS','IGS_UC_CYCLE_NOT_FOUND');
        errbuf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, errbuf);
        retcode := 2;
     END IF;

  EXCEPTION
     WHEN OTHERS THEN
     ROLLBACK;
     Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME', 'PROCESS_UCAS_DATA.APPL_DATA_SETUP');
     retcode := 2;
     errbuf := fnd_message.get;
     fnd_file.put_line(fnd_file.log, errbuf);
  END appl_data_setup;

  PROCEDURE validate_applicant (p_appno igs_uc_applicants.app_no%TYPE,
                                p_error_cd OUT NOCOPY g_error_code%TYPE) IS
 /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   LOCAL PROCEDURE for validation whether application Number
                         is valid and that person ID is associated to it.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
  ******************************************************************/

     -- For getting Application details from IGS_UC_APPLICANTS.
     CURSOR get_applicant_cur IS
     SELECT app_no,
            oss_person_id
     FROM   igs_uc_applicants
     WHERE  app_no = p_appno;

     l_applicant_rec  get_applicant_cur%ROWTYPE;

  BEGIN

     OPEN  get_applicant_cur;
     FETCH get_applicant_cur INTO l_applicant_rec;
     CLOSE get_applicant_cur;

     IF l_applicant_rec.app_no IS NULL THEN
        p_error_cd := '1000';

     ELSIF l_applicant_rec.oss_person_id IS NULL THEN
        p_error_cd := '1001';
     END IF;

  EXCEPTION
     WHEN OTHERS THEN
        p_error_cd := '1000';

        -- Close any Open cursors
        IF get_applicant_cur%ISOPEN THEN
           CLOSE get_applicant_cur;
        END IF;

  END validate_applicant;




  PROCEDURE proc_update_ivstarn_status IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUN-03
     Purpose         :   LOCAL PROCEDURE called from process_IVSTARN Procedure.
                         This process picks up all the records from the IVSTARN
                         interface table where status = 'I' and checks whether
                         corresponding record exists in IGS_AD_INTERFACE table.
                         This could be due to some data error or Adm import process
                         exitting due to some reason.
                         If corresponding record found then retain the status to I
                         and popuate Error code ELSE update the status to 'D'.
     Known limitations,enhancements,remarks:
     Change History
     Who       When          What
     rgangara  31-DEC-03   Enhanced logging of Person Creation Details Bug# 3327176.
  ***************************************************************** */

  -- get all the records which have been populated successfully into UCAS tables
  -- but have encountered errors while creating person using Adm Import process
  CURSOR cur_ivstarn IS
  SELECT stn.rowid,
         stn.appno,
         stn.ad_batch_id,
         stn.ad_interface_id,
         stn.ad_api_id ,
         stn.record_status ,
         stn.error_code
  FROM   igs_uc_istarn_ints stn
  WHERE  stn.record_status = 'I';

  l_starn_rec cur_ivstarn%ROWTYPE;

  CURSOR ad_interface_cur (p_interface_id igs_uc_istarn_ints.ad_interface_id%TYPE) IS
  SELECT 'X'
  FROM   igs_ad_interface_all
  WHERE  interface_id = p_interface_id;

  l_exists_flag VARCHAR2(1);
  l_success_cnt NUMBER;
  l_failure_cnt NUMBER;

  BEGIN
     l_success_cnt  := 0;
     l_failure_cnt  := 0;

     FOR ivstarn_rec IN cur_ivstarn
     LOOP

        l_exists_flag := NULL;  -- initialize

        OPEN ad_interface_cur (ivstarn_rec.ad_interface_id);
        FETCH ad_interface_cur INTO l_exists_flag;
        CLOSE ad_interface_cur;

        IF l_exists_flag IS NULL THEN
           -- update the record with status = 'D'.
           UPDATE igs_uc_istarn_ints
           SET    record_status = 'D'
           WHERE  rowid  = ivstarn_rec.rowid;

           -- update count for success records
           l_success_cnt := l_success_cnt + 1;

        ELSE

           -- update the error code with status = 'D'.
           UPDATE igs_uc_istarn_ints
           SET    error_code = '3001'
           WHERE  rowid  = ivstarn_rec.rowid;

           -- update count for failure records
           l_failure_cnt := l_failure_cnt + 1;

           -- log error message/meaning.
           fnd_Message.Set_name('IGS','IGS_UC_ERR_CREATE_PRSN');
           fnd_message.set_token('APPNO', ivstarn_rec.appno);
           fnd_message.set_token('INTERFACE_ID', ivstarn_rec.ad_interface_id);
           fnd_message.set_token('BATCH', ivstarn_rec.ad_batch_id);
           fnd_file.put_line(fnd_file.LOG, fnd_message.get());

        END IF;

     END LOOP;

    -- log processing complete for this part of processing - Bug# 3327176.
    igs_uc_proc_ucas_data.log_proc_complete('PERSON CREATION ', l_success_cnt, l_failure_cnt);

  EXCEPTION
     WHEN OTHERS THEN
        -- Close any Open cursors
        IF ad_interface_cur%ISOPEN THEN
           CLOSE  ad_interface_cur;
        END IF;

      -- even though the admission import process completes in error , this process should continue processing
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_PROC_APPLICATION_DATA.PROC_UPDATE_IVSTARN_STATUS'||' - '||SQLERRM);
      fnd_file.put_line(fnd_file.LOG,fnd_message.get());

  END proc_update_ivstarn_status;




  PROCEDURE proc_populate_oss_person IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUN-03
     Purpose         :   LOCAL PROCEDURE called from process_IVSTARN Procedure.
                         This process picks up all the records from
                         IGS_UC_APPLICANTS where OSS PERSON ID IS NULL
                         and gets the Person ID from Alternate person ID
                         table based on Alternate Person ID which is the
                         type as that of the system to which the App belongs.
     Known limitations,enhancements,remarks:
     Change History
     Who       When          What
  ***************************************************************** */

     -- get all the records with NULL Person ID
     CURSOR ucas_app_person_cur IS
     SELECT ucap.rowid,
            ucap.*
     FROM   igs_uc_applicants ucap
     WHERE  oss_person_id IS NULL;


     -- get all the records with NULL Person ID
     CURSOR  get_person_cur (p_ucas_appno  igs_pe_alt_pers_id.api_person_id%TYPE,
                             p_ucas_system igs_pe_alt_pers_id.person_id_type%TYPE) IS
     SELECT  pe_person_id
     FROM    igs_pe_alt_pers_id
     WHERE   api_person_id = p_ucas_appno
     AND     person_id_type = p_ucas_system;


     l_oss_person_id igs_uc_applicants.oss_person_id%TYPE;
     l_system_type   igs_pe_alt_pers_id.person_id_type%TYPE;

  BEGIN

    -- log Processing message
    fnd_file.put_line(fnd_file.log, '==========================================================================');
    fnd_Message.Set_name('IGS','IGS_UC_PRSN_UPDATE_FOR_APPNO');
    fnd_message.set_token('TIME', TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.LOG,fnd_message.get);
    fnd_file.put_line(fnd_file.log, '==========================================================================');

    FOR ucas_app_person_rec IN ucas_app_person_cur
    LOOP

      BEGIN

         -- initialize variables.
         l_system_type := NULL;
         l_oss_person_id := NULL;


         -- identify the Alternate Person ID Type
         IF ucas_app_person_rec.system_code = 'U' THEN
            l_system_type := 'UCASID';

         ELSIF ucas_app_person_rec.system_code = 'G' THEN
            l_system_type := 'GTTRID';

         ELSIF ucas_app_person_rec.system_code = 'N' THEN
            l_system_type := 'NMASID';

         ELSIF ucas_app_person_rec.system_code = 'S' THEN
            l_system_type := 'SWASID';

         END IF;

         -- Check whether the Alternate Person ID type record exists
         OPEN get_person_cur (ucas_app_person_rec.app_no, l_system_type);
         FETCH get_person_cur INTO l_oss_person_id;
         CLOSE get_person_cur;

         IF l_oss_person_id IS NOT NULL THEN

             -- log Processing message
             fnd_Message.Set_name('IGS','IGS_UC_PRSN_POPULATE_APPNO');
             fnd_message.set_token('APPNO', TO_CHAR(ucas_app_person_rec.app_no));
             fnd_file.put_line(fnd_file.LOG,fnd_message.get);

             -- update UCAS Applicants table with Person ID.
             BEGIN
               igs_uc_applicants_pkg.update_row -- IGSXI01B.pls
                 (
                  x_rowid                        => ucas_app_person_rec.rowid
                 ,x_app_id                       => ucas_app_person_rec.app_id
                 ,x_app_no                       => ucas_app_person_rec.app_no
                 ,x_check_digit                  => ucas_app_person_rec.check_digit
                 ,x_personal_id                  => ucas_app_person_rec.personal_id
                 ,x_enquiry_no                   => ucas_app_person_rec.enquiry_no
                 ,x_oss_person_id                => l_oss_person_id
                 ,x_application_source           => ucas_app_person_rec.application_source
                 ,x_name_change_date             => ucas_app_person_rec.name_change_date
                 ,x_student_support              => ucas_app_person_rec.student_support
                 ,x_address_area                 => ucas_app_person_rec.address_area
                 ,x_application_date             => ucas_app_person_rec.application_date
                 ,x_application_sent_date        => ucas_app_person_rec.application_sent_date
                 ,x_application_sent_run         => ucas_app_person_rec.application_sent_run
                 ,x_lea_code                     => NULL  -- obsoleted by UCAS
                 ,x_fee_payer_code               => ucas_app_person_rec.fee_payer_code
                 ,x_fee_text                     => ucas_app_person_rec.fee_text
                 ,x_domicile_apr                 => ucas_app_person_rec.domicile_apr
                 ,x_code_changed_date            => ucas_app_person_rec.code_changed_date
                 ,x_school                       => ucas_app_person_rec.school
                 ,x_withdrawn                    => ucas_app_person_rec.withdrawn
                 ,x_withdrawn_date               => ucas_app_person_rec.withdrawn_date
                 ,x_rel_to_clear_reason          => ucas_app_person_rec.rel_to_clear_reason
                 ,x_route_b                      => ucas_app_person_rec.route_b
                 ,x_exam_change_date             => ucas_app_person_rec.exam_change_date
                 ,x_a_levels                     => NULL  -- obsoleted by UCAS
                 ,x_as_levels                    => NULL  -- obsoleted by UCAS
                 ,x_highers                      => NULL  -- obsoleted by UCAS
                 ,x_csys                         => NULL  -- obsoleted by UCAS
                 ,x_winter                       => ucas_app_person_rec.winter
                 ,x_previous                     => ucas_app_person_rec.previous
                 ,x_gnvq                         => NULL  -- obsoleted by UCAS
                 ,x_btec                         => ucas_app_person_rec.btec
                 ,x_ilc                          => ucas_app_person_rec.ilc
                 ,x_ailc                         => ucas_app_person_rec.ailc
                 ,x_ib                           => ucas_app_person_rec.ib
                 ,x_manual                       => ucas_app_person_rec.manual
                 ,x_reg_num                      => ucas_app_person_rec.reg_num
                 ,x_oeq                          => ucas_app_person_rec.oeq
                 ,x_eas                          => ucas_app_person_rec.eas
                 ,x_roa                          => ucas_app_person_rec.roa
                 ,x_status                       => ucas_app_person_rec.status
                 ,x_firm_now                     => ucas_app_person_rec.firm_now
                 ,x_firm_reply                   => ucas_app_person_rec.firm_reply
                 ,x_insurance_reply              => ucas_app_person_rec.insurance_reply
                 ,x_conf_hist_firm_reply         => ucas_app_person_rec.conf_hist_firm_reply
                 ,x_conf_hist_ins_reply          => ucas_app_person_rec.conf_hist_ins_reply
                 ,x_residential_category         => ucas_app_person_rec.residential_category
                 ,x_personal_statement           => ucas_app_person_rec.personal_statement
                 ,x_match_prev                   => ucas_app_person_rec.match_prev
                 ,x_match_prev_date              => ucas_app_person_rec.match_prev_date
                 ,x_match_winter                 => ucas_app_person_rec.match_winter
                 ,x_match_summer                 => ucas_app_person_rec.match_summer
                 ,x_gnvq_date                    => ucas_app_person_rec.gnvq_date
                 ,x_ib_date                      => ucas_app_person_rec.ib_date
                 ,x_ilc_date                     => ucas_app_person_rec.ilc_date
                 ,x_ailc_date                    => ucas_app_person_rec.ailc_date
                 ,x_gcseqa_date                  => ucas_app_person_rec.gcseqa_date
                 ,x_uk_entry_date                => ucas_app_person_rec.uk_entry_date
                 ,x_prev_surname                 => ucas_app_person_rec.prev_surname
                 ,x_criminal_convictions         => ucas_app_person_rec.criminal_convictions
                 ,x_sent_to_hesa                 => ucas_app_person_rec.sent_to_hesa
                 ,x_sent_to_oss                  => ucas_app_person_rec.sent_to_oss
                 ,x_batch_identifier             => ucas_app_person_rec.batch_identifier
                 ,x_mode                         => 'R'
                 ,x_gce                          => ucas_app_person_rec.gce
                 ,x_vce                          => ucas_app_person_rec.vce
                 ,x_sqa                          => ucas_app_person_rec.sqa
                 ,x_previousas                   => ucas_app_person_rec.previousas
                 ,x_keyskills                    => ucas_app_person_rec.keyskills
                 ,x_vocational                   => ucas_app_person_rec.vocational
                 ,x_scn                          => ucas_app_person_rec.scn
                 ,x_PrevOEQ                      => ucas_app_person_rec.PrevOEQ
                 ,x_choices_transparent_ind      => ucas_app_person_rec.choices_transparent_ind
                 ,x_extra_status                 => ucas_app_person_rec.extra_status
                 ,x_extra_passport_no            => ucas_app_person_rec.extra_passport_no
                 ,x_request_app_dets_ind         => ucas_app_person_rec.request_app_dets_ind
                 ,x_request_copy_app_frm_ind     => ucas_app_person_rec.request_copy_app_frm_ind
                 ,x_cef_no                       => ucas_app_person_rec.cef_no
                 ,x_system_code                  => ucas_app_person_rec.system_code
                 ,x_gcse_eng                     => ucas_app_person_rec.gcse_eng
                 ,x_gcse_math                    => ucas_app_person_rec.gcse_math
                 ,x_degree_subject               => ucas_app_person_rec.degree_subject
                 ,x_degree_status                => ucas_app_person_rec.degree_status
                 ,x_degree_class                 => ucas_app_person_rec.degree_class
                 ,x_gcse_sci                     => ucas_app_person_rec.gcse_sci
                 ,x_welshspeaker                 => ucas_app_person_rec.welshspeaker
                 ,x_ni_number                    => ucas_app_person_rec.ni_number
                 ,x_earliest_start               => ucas_app_person_rec.earliest_start
                 ,x_near_inst                    => ucas_app_person_rec.near_inst
                 ,x_pref_reg                     => ucas_app_person_rec.pref_reg
                 ,x_qual_eng                     => ucas_app_person_rec.qual_eng
                 ,x_qual_math                    => ucas_app_person_rec.qual_math
                 ,x_qual_sci                     => ucas_app_person_rec.qual_sci
                 ,x_main_qual                    => ucas_app_person_rec.main_qual
                 ,x_qual_5                       => ucas_app_person_rec.qual_5
                 ,x_future_serv                  => ucas_app_person_rec.future_serv
                 ,x_future_set                   => ucas_app_person_rec.future_set
                 ,x_present_serv                 => ucas_app_person_rec.present_serv
                 ,x_present_set                  => ucas_app_person_rec.present_set
                 ,x_curr_employment              => ucas_app_person_rec.curr_employment
                 ,x_edu_qualification            => ucas_app_person_rec.edu_qualification
                 ,x_ad_batch_id                  => ucas_app_person_rec.ad_batch_id
                 ,x_ad_interface_id              => ucas_app_person_rec.ad_interface_id
                 ,x_nationality                  => ucas_app_person_rec.nationality
                 ,x_dual_nationality             => ucas_app_person_rec.dual_nationality
                 ,x_special_needs                => ucas_app_person_rec.special_needs
                 ,x_country_birth                => ucas_app_person_rec.country_birth
                 );

             EXCEPTION
                WHEN OTHERS THEN
                  fnd_file.put_line(fnd_file.log, SQLERRM);

             END;

         END IF;

      EXCEPTION
        WHEN OTHERS THEN
           -- Close any Open cursors
           IF get_person_cur%ISOPEN THEN
              CLOSE  get_person_cur;
           END IF;

           fnd_file.put_line(fnd_file.LOG, SQLERRM);
           fnd_Message.Set_name('IGS','IGS_UC_ERR_PRSN_POPULATION');
           fnd_message.set_token('APPNO', TO_CHAR(ucas_app_person_rec.app_no));
           fnd_file.put_line(fnd_file.LOG,fnd_message.get);
      END;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- even though Exception is raised in this process, process should continue.
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_PROC_APPLICATION_DATA.PROC_POPULATE_OSS_PERSON'||' - '||SQLERRM);
      fnd_file.put_line(fnd_file.LOG,fnd_message.get());
  END proc_populate_oss_person ;




  PROCEDURE proc_invoke_adm_imp_process(p_batch_id NUMBER,
                                        p_source_type_id igs_pe_src_types_all.source_type_id%TYPE) IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUN-03
     Purpose         :  LOCAL PROCEDURE called from process_IVSTARN Procedure to
                        Submit the request for admission import process to create basic person in OSS
     Known limitations,enhancements,remarks:
     Change History
     Who       When          What
  ***************************************************************** */

    l_row_id   VARCHAR2(26);
    l_errbuff  VARCHAR2(100) ;
    l_retcode  NUMBER ;
    l_interface_run_id   igs_ad_interface_ctl.interface_run_id%TYPE;

    CURSOR cur_match_set IS
    SELECT match_set_id
    FROM   igs_pe_match_sets
    WHERE  source_type_id = p_source_type_id;

    match_set_rec cur_match_set%ROWTYPE;

  BEGIN

    fnd_file.put_line(fnd_file.log, '==========================================================================');
    fnd_Message.Set_name('IGS','IGS_UC_ADM_IMP_PROC_LAUNCH');
    fnd_message.set_token('REQ_ID', TO_CHAR(p_batch_id) || ' At ' || TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.LOG, fnd_message.get);
    fnd_file.put_line(fnd_file.log, '==========================================================================');

    -- Get the match set criteria corresponding to the ucas source type to be used for the person import
    match_set_rec := NULL ;
    OPEN cur_match_set;
    FETCH cur_match_set INTO match_set_rec;
    CLOSE cur_match_set;

    l_interface_run_id := NULL ;
    l_errbuff:= NULL ;
    l_retcode := NULL ;

    -- Call admission application import process procedure because current process has to wait until import process is finished
    igs_ad_imp_001.imp_adm_data
      (  errbuf                     => l_errbuff,
         retcode                    => l_retcode ,
         p_batch_id                 => p_batch_id,
         p_source_type_id           => p_source_type_id,
         p_match_set_id             => match_set_rec.match_set_id,
         p_acad_cal_type            => NULL ,
         p_acad_sequence_number     => NULL ,
         p_adm_cal_type             => NULL ,
         p_adm_sequence_number      => NULL ,
         p_admission_cat            => NULL ,
         p_s_admission_process_type => NULL ,
         p_interface_run_id         => l_interface_run_id ,
         P_org_id                   => NULL
       );

    fnd_file.put_line(fnd_file.log, '==========================================================================');
    fnd_Message.Set_name('IGS', 'IGS_UC_RTRN_ADM_IMP_PROC') ;
    fnd_message.set_token('TIME', TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log, '==========================================================================');

 EXCEPTION
    WHEN OTHERS THEN
      -- even though the admission import process completes in error , this process should continue processing

      -- Close any open cursors
      IF cur_match_set%ISOPEN THEN
         CLOSE cur_match_set;
      END IF;

      fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_PROC_APPLICATION_DATA.PROC_INVOKE_ADM_IMP_PROCESS'||' - '||SQLERRM);
      fnd_file.put_line(fnd_file.LOG,fnd_message.get());

 END proc_invoke_adm_imp_process;




  PROCEDURE process_ivstarn  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing IVSTARN - Applicant Name details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     rgangara 29-APR-04    Bug# 3601118. Modified processing of IVSTARN record to flag|
                           and generate Adm Imp Batch ID even when the APPNO rec exists
                           in IGS_UC_APPLICANTS table and does not in App Names.
     jchakrab   27-JUL-04  Modified for UCFD308 - UCAS - 2005 Regulatory Changes
     jbaber     11-JUL-06  Modified for UCFD325 - UCAS - 2007 Regulatory Changes
    ******************************************************************/

     -- get the records from interface tables where status is NEW.
     CURSOR new_ivstarn_cur IS
     SELECT ivstn.rowid,
            ivstn.*
     FROM   igs_uc_istarn_ints ivstn
     WHERE  ivstn.record_status = 'N';


     -- check for corresponding record in UCAS Names table.
     CURSOR old_starn_cur(p_appno   igs_uc_app_names.app_no%TYPE) IS
     SELECT uapn.rowid,
            uapn.*
     FROM   igs_uc_app_names uapn
     WHERE  uapn.app_no = p_appno;


     -- check for corresponding record in UCAS Applicants table.
     CURSOR old_appl_cur(p_appno   igs_uc_applicants.app_no%TYPE) IS
     SELECT ucap.rowid,
            ucap.*
     FROM   igs_uc_applicants ucap
     WHERE  ucap.app_no = p_appno;


     appl_rec old_appl_cur%ROWTYPE;

     -- Get the system to which the APplication belongs
     -- Cursor to fetch the Application Number Range of all the Systems supported by UCAS
     CURSOR cur_ucas_control (p_appno igs_uc_ucas_control.appno_maximum%TYPE) IS
     SELECT system_code
     FROM   igs_uc_ucas_control
     WHERE  ucas_cycle = (2000 + TO_NUMBER(SUBSTR(LPAD(TO_CHAR(p_appno),8,'0'),0,2)))
     AND    p_appno BETWEEN appno_first AND appno_maximum;


     -- To get the OSS eqvivalent value for UCAS Value.
     CURSOR cur_map (p_assoc igs_he_code_map_val.association_code%TYPE ,
                     p_map1 igs_he_code_map_val.map1%TYPE ) IS
     SELECT  map2
     FROM    igs_he_code_map_val
     WHERE   association_code = p_assoc
     AND     map1  = p_map1;

     -- TITLE validation
     CURSOR cur_chk_adjunct (p_adjunct fnd_lookup_values.lookup_code%TYPE) IS
     SELECT lookup_code
     FROM   fnd_lookup_values
     WHERE  lookup_Type = 'CONTACT_TITLE'
     AND    lookup_code = p_adjunct
     AND    enabled_flag = 'Y'
     AND    LANGUAGE = USERENV('LANG') AND view_application_id = 222 AND security_group_id(+) = 0;

     -- Get the Source Type ID value
     CURSOR src_types_cur IS
     SELECT source_type_id
     FROM   igs_pe_src_types_all
     WHERE  source_type = 'UCAS PER';

     -- Cursor to get the Interface ID needed while populating records into Adm Interface table.
     CURSOR get_interface_id IS
     SELECT igs_ad_interface_s.NEXTVAL
     FROM   DUAL;

     -- cursor to get the batch ID from sequence.
     CURSOR get_batch_id_cur IS
     SELECT igs_ad_interface_batch_id_s.NEXTVAL
     FROM   DUAL;

     -- cursor to get the batch ID from sequence.
     CURSOR get_alt_pers_id_cur IS
     SELECT igs_ad_api_int_s.NEXTVAL
     FROM   DUAL;

     old_starn_rec    old_starn_cur%ROWTYPE;
     l_oss_title      igs_pe_person_base_v.title%TYPE;
     l_system_code    igs_uc_ucas_control.system_code%TYPE;
     l_invoke_adm_import_Proc_flag  VARCHAR2(1) ;   -- Flag to identify atleast one new rec imported
     l_new_rec_flag   VARCHAR2(1);  -- flag to check whether a new record (i.e. insert) or old record(i.e.update)
     l_recs_inserted  NUMBER := 0;
     l_alt_pers_id_type igs_ad_api_int.person_id_type%TYPE;

     -- for populating into Adm Int tables
     l_created_by               NUMBER ;
     l_last_updated_by          NUMBER ;
     l_last_update_login        NUMBER ;
     l_creation_date            DATE   ;
     l_last_update_date         DATE   ;
     l_alt_pers_seq_id          igs_ad_api_int.interface_api_id%TYPE; -- for holding Alternate Person ID sequence
     l_adm_batch_id             igs_ad_imp_batch_det.batch_id%TYPE;  -- for holding Adm Imp Proc batch ID.
     l_source_type_id           igs_pe_src_types_all.source_type_id%TYPE;
     l_interface_id             igs_ad_interface_all.interface_id%TYPE;
     l_oss_sex_val              igs_ad_interface_all.sex%TYPE;

  BEGIN
     -- initialize variables
     l_created_by                :=  fnd_global.user_id;
     l_last_updated_by           :=  l_created_by;
     l_last_update_login         :=  fnd_global.login_id;
     l_creation_date             :=  SYSDATE;
     l_last_update_date          :=  l_creation_date;

     -- initialize variables
     g_success_rec_cnt := 0;
     g_error_rec_cnt   := 0;
     g_error_code := NULL;
     l_invoke_adm_import_Proc_flag := 'N';

     fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
     fnd_message.set_token('VIEW', 'IVSTARN ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
     fnd_file.put_line(fnd_file.log, fnd_message.get);

    ----------------------------------------------------
    -- Derive the SOURCE TYPE ID value for UCAS PER.
    -- Derived only once per execution of this procedure
    -----------------------------------------------------
    OPEN src_types_cur;
    FETCH src_types_cur INTO l_source_type_id;

    IF (src_types_cur%NOTFOUND) THEN
       CLOSE src_types_cur;
       fnd_message.set_name('IGS','IGS_UC_NO_UCAS_SRC_TYP');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       App_Exception.Raise_Exception;
    END IF;
    CLOSE src_types_cur;


    ------------------------------------------
    -- RECORD LEVEL PROCESSING BEGINS
    ------------------------------------------

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstarn_rec IN new_ivstarn_cur
    LOOP

      BEGIN
         -- initialize record level variables.
         g_error_code      := NULL;
         old_starn_rec     := NULL;
         l_system_code     := NULL;
         l_oss_title       := NULL;
         appl_rec          := NULL;
         l_new_rec_flag    := 'N';
         l_interface_id    := 0;
         l_alt_pers_seq_id := 0;

         -- log record processing info.
         fnd_message.set_name('IGS','IGS_UC_APPNO_PROC');
         fnd_message.set_token('APPL_NO', TO_CHAR(new_ivstarn_rec.appno));
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         SAVEPOINT ivstarn_rec_savepoint;

          -- no mandatory field validations as this is an update
          IF new_ivstarn_rec.appno IS NULL OR new_ivstarn_rec.surname IS NULL
             THEN
             g_error_code := '1037';
          END IF;


          ----------------------------------------------------
          -- Derive the SYSTEM to which the Application belongs
          -----------------------------------------------------
          -- Find the UCAS System Code of the Application being processed
          IF g_error_code IS NULL THEN
             l_system_code := NULL ;
             OPEN cur_ucas_control (new_ivstarn_rec.appno);
             FETCH cur_ucas_control INTO l_system_code;
             CLOSE cur_ucas_control;

             -- If the Application Number is not falling in the application range of any of the UCAS Systems,
             -- raise an error message and stop processing
             IF l_system_code IS NULL THEN
                -- raise error message
                g_error_code := '1041';
             END IF;

             -- JCHAKRAB added for UCFD308 - UCAS 2005 changes
             IF l_system_code = 'S' and g_config_cycle>2004 THEN
                 l_system_code := 'U';
             END IF;

          END IF;


          ------------------------------------------
          -- Validate PERSONAL ID
          -- jbaber added for UC325 - UCAS 2007 Support
          ------------------------------------------

          IF g_error_code IS NULL THEN

             IF new_ivstarn_rec.personalid IS NOT NULL THEN

                IF NOT igs_uc_gen_001.validate_personal_id(new_ivstarn_rec.personalid) THEN
                  g_error_code := '1063';
                END IF;

             END IF;

          END IF;



          ------------------------------------------
          -- Derive OSS SEX value from HESA Mappings
          ------------------------------------------

          IF g_error_code IS NULL THEN
             -- get the mapping value for Sex
             l_oss_sex_val := NULL;
             OPEN cur_map('UC_OSS_HE_GEN_ASSOC', new_ivstarn_rec.sex);
             FETCH cur_map INTO l_oss_sex_val;
             CLOSE cur_map;

             IF l_oss_sex_val IS NULL THEN
               fnd_message.set_name('IGS','IGS_UC_INV_MAPPING_VAL');
               fnd_message.set_token('CODE', new_ivstarn_rec.sex);
               fnd_message.set_token('TYPE', 'SEX');
               fnd_file.put_line(fnd_file.log, fnd_message.get);
               g_error_code := '1054';
             END IF;

          END IF;


          ------------------------------------------
          -- Birthdate value check
          ------------------------------------------

          IF g_error_code IS NULL THEN
             IF new_ivstarn_rec.birthdate > SYSDATE THEN
               g_error_code := '1007';
             END IF;

          END IF;


          ------------------------------------------
          -- Validate/Derive OSS TITLE value
          ------------------------------------------
          -- get the corresponding OSS title value for the incoming UCAS Title
          l_oss_title := NULL;
          IF new_ivstarn_rec.title IS NOT NULL THEN

               -- Validating the data against the Lookups
               OPEN cur_chk_adjunct(new_ivstarn_rec.title);
               FETCH cur_chk_adjunct INTO l_oss_title;
               IF cur_chk_adjunct%NOTFOUND THEN
                   CLOSE cur_chk_adjunct;

                   -- check whether no match found was because of the FULLSTOP in the end. and recheck with '.'
                   OPEN cur_chk_adjunct(new_ivstarn_rec.title || '.');
                   FETCH cur_chk_adjunct INTO l_oss_title;

                   IF cur_chk_adjunct%NOTFOUND THEN
                      -- log appropriate message and pass UCAS Title as NULL to OSS Pre name adjunct field.
                      -- The record should get processed with TITLE as NULL.
                      fnd_message.set_name('IGS','IGS_UC_INVALID_TITLE');
                      fnd_message.set_token('UCAS_TITLE', new_ivstarn_rec.title);
                      fnd_message.set_token('APPNO', TO_CHAR(new_ivstarn_rec.appno));
                      fnd_file.put_line(fnd_file.log, fnd_message.get);
                      new_ivstarn_rec.title := NULL;

                   ELSE -- since found with '.', append it to Title.
                      new_ivstarn_rec.title := new_ivstarn_rec.title || '.';
                   END IF;
                   CLOSE cur_chk_adjunct;

               ELSE
                   CLOSE cur_chk_adjunct;
               END IF;
          END IF;
          -- end of UCAS Title validation


         ----------------------------------------------------------------------------------
         -- Insert/Update data into UCAS Applicants table.
         -- Though this could be the first step. It has been put here after all validations
         -- to avoid an insert till all validations are successful. Since a ROLLBACK happens
         -- whenever any validation fails an insert before such failure is also rolled back.
         ------------------------------------------------------------------------------------

         IF  g_error_code IS NULL THEN

            -- log appropriate message
            fnd_message.set_name('IGS','IGS_UC_PROC_UCAS_APP');
            fnd_file.put_line(fnd_file.log, fnd_message.get);

            -- check whether the Application rec already exists in UCAS Applicants table.
            OPEN  old_appl_cur(new_ivstarn_rec.appno);
            FETCH old_appl_cur INTO appl_rec;
            CLOSE old_appl_cur;

            IF appl_rec.rowid IS NULL THEN

               -- since corresponding record does not exist in UCAS APplicants, Insert a record with basic details.
               BEGIN
                 igs_uc_applicants_pkg.insert_row -- IGSXI01B.pls
                  (
                   x_rowid                               => appl_rec.rowid
                  ,x_app_id                              => appl_rec.app_id   -- can be used since this rec variable would be null
                  ,x_app_no                              => new_ivstarn_rec.appno
                  ,x_check_digit                         => new_ivstarn_rec.checkdigit
                  ,x_personal_id                         => new_ivstarn_rec.personalid
                  ,x_enquiry_no                          => appl_rec.enquiry_no   -- IN OUT parameter. hence rec variable is used.
                  ,x_oss_person_id                       => NULL
                  ,x_application_source                  => 'U'  -- hard coded for UCAS
                  ,x_name_change_date                    => NULL
                  ,x_student_support                     => NULL
                  ,x_address_area                        => NULL
                  ,x_application_date                    => NULL
                  ,x_application_sent_date               => NULL
                  ,x_application_sent_run                => NULL
                  ,x_lea_code                            => NULL
                  ,x_fee_payer_code                      => NULL
                  ,x_fee_text                            => NULL
                  ,x_domicile_apr                        => NULL
                  ,x_code_changed_date                   => NULL
                  ,x_school                              => NULL
                  ,x_withdrawn                           => NULL
                  ,x_withdrawn_date                      => NULL
                  ,x_rel_to_clear_reason                 => NULL
                  ,x_route_b                             => 'N'  -- default initialization
                  ,x_exam_change_date                    => NULL
                  ,x_a_levels                            => NULL
                  ,x_as_levels                           => NULL
                  ,x_highers                             => NULL
                  ,x_csys                                => NULL
                  ,x_winter                              => NULL
                  ,x_previous                            => NULL
                  ,x_gnvq                                => NULL
                  ,x_btec                                => NULL
                  ,x_ilc                                 => NULL
                  ,x_ailc                                => NULL
                  ,x_ib                                  => NULL
                  ,x_manual                              => NULL
                  ,x_reg_num                             => NULL
                  ,x_oeq                                 => NULL
                  ,x_eas                                 => NULL
                  ,x_roa                                 => NULL
                  ,x_status                              => NULL
                  ,x_firm_now                            => NULL
                  ,x_firm_reply                          => NULL
                  ,x_insurance_reply                     => NULL
                  ,x_conf_hist_firm_reply                => NULL
                  ,x_conf_hist_ins_reply                 => NULL
                  ,x_residential_category                => NULL
                  ,x_personal_statement                  => NULL
                  ,x_match_prev                          => NULL
                  ,x_match_prev_date                     => NULL
                  ,x_match_winter                        => NULL
                  ,x_match_summer                        => NULL
                  ,x_gnvq_date                           => NULL
                  ,x_ib_date                             => NULL
                  ,x_ilc_date                            => NULL
                  ,x_ailc_date                           => NULL
                  ,x_gcseqa_date                         => NULL
                  ,x_uk_entry_date                       => NULL
                  ,x_prev_surname                        => NULL
                  ,x_criminal_convictions                => NULL
                  ,x_sent_to_hesa                        => 'N'
                  ,x_sent_to_oss                         => 'N'
                  ,x_batch_identifier                    => NULL
                  ,x_mode                                => 'R'
                  ,x_GCE                                 => NULL
                  ,x_VCE                                 => NULL
                  ,x_SQA                                 => NULL
                  ,x_PREVIOUSAS                          => NULL
                  ,x_KEYSKILLS                           => NULL
                  ,x_VOCATIONAL                          => NULL
                  ,x_SCN                                 => NULL
                  ,x_PrevOEQ                             => NULL
                  ,x_choices_transparent_ind             => NULL
                  ,x_extra_status                        => NULL
                  ,x_extra_passport_no                   => NULL
                  ,x_request_app_dets_ind                => NULL
                  ,x_request_copy_app_frm_ind            => NULL
                  ,x_cef_no                              => NULL
                  ,x_system_code                        =>  l_system_code
                  ,x_gcse_eng                           => NULL
                  ,x_gcse_math                          => NULL
                  ,x_degree_subject                     => NULL
                  ,x_degree_status                      => NULL
                  ,x_degree_class                       => NULL
                  ,x_gcse_sci                           => NULL
                  ,x_welshspeaker                       => NULL
                  ,x_ni_number                          => NULL
                  ,x_earliest_start                     => NULL
                  ,x_near_inst                          => NULL
                  ,x_pref_reg                           => NULL
                  ,x_qual_eng                           => NULL
                  ,x_qual_math                          => NULL
                  ,x_qual_sci                           => NULL
                  ,x_main_qual                          => NULL
                  ,x_qual_5                             => NULL
                  ,x_future_serv                        => NULL
                  ,x_future_set                         => NULL
                  ,x_present_serv                       => NULL
                  ,x_present_set                        => NULL
                  ,x_curr_employment                    => NULL
                  ,x_edu_qualification                  => NULL
                 );

--                 l_new_rec_flag   := 'Y';  -- flag identifying a new record i.e. insert into UC Applicants.

               EXCEPTION
                  WHEN OTHERS THEN
                    g_error_code := '1056';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE
               -- no update to IGS_UC_APPLICANTS from this procedure. Only insert is allowed
               -- first time to ensure that this remains the main table for all further validations
               -- All the other field values for the above record are populated in IVSTARK.
               NULL;
            END IF;  -- uc appliants insert check

         END IF;  -- error code check for inserting into UC applicants


         ----------------------------------------------------------------------------------------
         -- Beginning processing for IGS_UC_APP_NAMES table
         -- Ideally, an insert into UC_APPLICANTS must result in Insert into UC_APP_NAMES.
         ----------------------------------------------------------------------------------------
         IF g_error_code IS NULL THEN

            -- log appropriate message
            fnd_message.set_name('IGS','IGS_UC_PROC_UCAS_NAMES');
            fnd_file.put_line(fnd_file.log, fnd_message.get);


            -- check whether the Application rec already exists in UCAS NAMES table.
            OPEN  old_starn_cur(new_ivstarn_rec.appno);
            FETCH old_starn_cur INTO old_starn_rec;
            CLOSE old_starn_cur;

            IF old_starn_rec.rowid IS NULL THEN
               -- since corresponding record does not exist in UCAS APplicants, Insert a record with basic details.
               BEGIN
                 -- call the insert row to insert a new record
                 igs_uc_app_names_pkg.insert_row
                  (
                   x_rowid                => old_starn_rec.rowid,          -- while insert this rec variable would be null.
                   x_app_no               => new_ivstarn_rec.appno,
                   x_check_digit          => new_ivstarn_rec.checkdigit,
                   x_name_change_date     => new_ivstarn_rec.namechangedate,
                   x_title                => new_ivstarn_rec.title,
                   x_fore_names           => new_ivstarn_rec.forenames,
                   x_surname              => new_ivstarn_rec.surname,
                   x_birth_date           => new_ivstarn_rec.birthdate,
                   x_sex                  => new_ivstarn_rec.sex,
                   x_sent_to_oss_flag     => 'N',
                   x_mode                 => 'R'
                  );

                 l_new_rec_flag   := 'Y';  -- flag identifying a new record i.e. insert into UC Applicants.

               EXCEPTION
                 WHEN OTHERS THEN
                   g_error_code := '9999';
                   fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- Corr. rec exists in UCAS Names table hence going for update.

               BEGIN
                 -- call the update row to update existing record in UC APP NAMES table.
                 igs_uc_app_names_pkg.update_row
                  (
                   x_rowid                => old_starn_rec.rowid,  -- while insert this rec variable would be null.
                   x_app_no               => old_starn_rec.app_no,
                   x_check_digit          => old_starn_rec.check_digit,
                   x_name_change_date     => new_ivstarn_rec.namechangedate,
                   x_title                => new_ivstarn_rec.title,
                   x_fore_names           => new_ivstarn_rec.forenames,
                   x_surname              => new_ivstarn_rec.surname,
                   x_birth_date           => new_ivstarn_rec.birthdate,
                   x_sex                  => new_ivstarn_rec.sex,
                   x_sent_to_oss_flag     => 'N',
                   x_mode                 => 'R'
                  );

               EXCEPTION
                 WHEN OTHERS THEN
                   g_error_code := '9998';
                   fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            END IF;  -- insert/update APP NAMES table.

         END IF;  -- beginning of processing for APP NAMES table
         -----------------------------------------------
         -- End of processing for IGS_UC_APP_NAMES table
         -----------------------------------------------


         -----------------------------------------------
         --  POPULATING ADMISSION IMPORT PROCESS TABLES
         -----------------------------------------------
         IF g_error_code IS  NULL AND l_new_rec_flag = 'Y' THEN

            -- Flag control to check so that it is only exectued once for getting Batch ID.
            IF  l_invoke_adm_import_Proc_flag = 'N' THEN

               BEGIN

                  -- i.e. atleast one record is new and need to be populated into Adm Imp table
                  -- set the flag to Y
                  l_invoke_adm_import_Proc_flag := 'Y'; -- to indicate that Adm Imp Proc has to be called

                  -- Derive the Adm Import process Batch ID as there is atleast one new record.
                  ----------------------------------------------------------------------------
                  -- Derive the ADM BATCH ID for this run and populate a record in Batch table.
                  -----------------------------------------------------------------------------
                  -- get the Batch ID from sequence
                  OPEN get_batch_id_cur;
                  FETCH get_batch_id_cur INTO l_adm_batch_id;
                  CLOSE get_batch_id_cur ;

                  -- log appropriate message
                  fnd_message.set_name('IGS','IGS_UC_ADM_IMP_BATCH_ID');
                  fnd_message.set_token('BATCHID', TO_CHAR(l_adm_batch_id));
                  fnd_file.put_line(fnd_file.log, fnd_message.get);

                     -- Populate a batch record into Adm Batch table
                      INSERT INTO igs_ad_imp_batch_det ( batch_id,
                                    batch_desc,
                                    created_by,
                                    creation_date,
                                    last_updated_by,
                                    last_update_date,
                                    last_update_login,
                                    request_id,
                                    program_application_id,
                                    program_update_date,
                                    program_id)
                           VALUES ( l_adm_batch_id,
                                    fnd_message.get_string('IGS','IGS_UC_IMP_FROM_UCAS_BATCH_ID'),
                                    fnd_global.user_id,
                                    SYSDATE,
                                    fnd_global.user_id,
                                    SYSDATE,
                                    fnd_global.login_id,
                                    DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_request_id),
                                    DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.prog_appl_id),
                                    DECODE(fnd_global.conc_request_id,-1,NULL,SYSDATE),
                                    DECODE(fnd_global.conc_request_id,-1,NULL,fnd_global.conc_program_id)
                                  );

               EXCEPTION
                  WHEN OTHERS THEN
                     g_error_code := '9999';
                     fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            END IF;  -- Flag check

            -- Populating person details into Adm Interface table
            IF g_error_code IS  NULL THEN
              BEGIN
                fnd_message.set_name('IGS','IGS_UC_APP_REC_INTO_ADM');
                fnd_message.set_token('APPNO', TO_CHAR(new_ivstarn_rec.appno));
                fnd_file.put_line(fnd_file.log, fnd_message.get);

                -- get the IGS_AD_INTERFACE ID.
                OPEN get_interface_id;
                FETCH get_interface_id INTO l_interface_id;
                CLOSE get_interface_id ;


                -- Populate Adm Interface table.
                   INSERT INTO igs_ad_interface_all
                      (
                       interface_id,
                       batch_id,
                       source_type_id,
                       surname,
                       given_names,
                       sex,
                       birth_dt,
                       pre_name_adjunct,
                       status,
                       record_status,
                       pref_alternate_id,
                       created_by,
                       creation_date,
                       last_updated_by,
                       last_update_date,
                       last_update_login
                      )
                   VALUES
                      (
                       l_interface_id,
                       l_adm_batch_id,
                       l_source_type_id,
                       new_ivstarn_rec.surname,
                       NVL(new_ivstarn_rec.forenames,'*'),   -- given name
                       l_oss_sex_val,                        -- sex
                       new_ivstarn_rec.birthdate,
                       new_ivstarn_rec.title,
                       '2',                                  -- status
                       '2',                                  -- record status
                       NULL,
                       l_created_by,
                       l_creation_date,
                       l_last_updated_by,
                       l_last_update_date,
                       l_last_update_login
                      );

                      -- log appropriate message
                      fnd_message.set_name('IGS','IGS_UC_ADM_IMP_INT_ID');
                      fnd_message.set_token('INT_ID',  TO_CHAR(l_interface_id));
                      fnd_file.put_line(fnd_file.log, fnd_message.get);


              EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '1057';  -- insert error
                    fnd_file.put_line(fnd_file.log, SQLERRM);

                    -- Close any Open cursors
                    IF get_interface_id%ISOPEN THEN
                       CLOSE get_interface_id;
                    END IF;
              END;
            END IF; -- error check

            -- Processing for Populating Alternate Person ID table.
            IF g_error_code IS NULL THEN

                fnd_message.set_name('IGS','IGS_UC_APP_REC_INTO_ALT_PRSN');
                fnd_file.put_line(fnd_file.log, fnd_message.get);

                --Derive the Alternate Person ID Type based on the system to which the Application belongs.
                IF    l_system_code = 'U' THEN
                      l_alt_pers_id_type := 'UCASID';

                ELSIF l_system_code = 'G' THEN
                      l_alt_pers_id_type := 'GTTRID';

                ELSIF l_system_code = 'N' THEN
                      l_alt_pers_id_type := 'NMASID';

                ELSIF l_system_code = 'S' THEN
                      l_alt_pers_id_type := 'SWASID';

                ELSE
                      g_error_code := '1041';

                END IF;


                -- insert a record into Adm Alternate Person ID Interface table
                BEGIN

                  -- get Alternate Person ID sequence number value.
                  OPEN get_alt_pers_id_cur;
                  FETCH get_alt_pers_id_cur INTO l_alt_pers_seq_id;
                  CLOSE get_alt_pers_id_cur ;

                  -- insert into table
                   INSERT INTO igs_ad_api_int
                     (
                      interface_api_id
                      ,interface_id
                      ,person_id_type
                      ,alternate_id
                      ,status
                      ,created_by
                      ,creation_date
                      ,last_updated_by
                      ,last_update_date
                      ,last_update_login
                      )
                   VALUES
                     (
                       l_alt_pers_seq_id
                      ,l_interface_id
                      ,l_alt_pers_id_type         -- Alternate Person ID Type - Based on system
                      ,new_ivstarn_rec.appno      -- Appno as Alternate Person ID
                      ,'2'
                      ,l_created_by
                      ,l_creation_date
                      ,l_last_updated_by
                      ,l_last_update_date
                      ,l_last_update_login
                     );

                   -- log appropriate message
                   fnd_message.set_name('IGS','IGS_UC_ADM_IMP_API_INT_ID');
                   fnd_message.set_token('INT_ID',  TO_CHAR(l_alt_pers_seq_id));
                   fnd_file.put_line(fnd_file.log, fnd_message.get);


                EXCEPTION
                   WHEN OTHERS THEN
                      g_error_code := '1058';
                      fnd_file.put_line(fnd_file.log, SQLERRM);

                      -- Close any Open cursors
                       IF get_alt_pers_id_cur%ISOPEN THEN
                          CLOSE get_alt_pers_id_cur;
                       END IF;

                END;

            END IF; -- processing alternate person ID


            IF g_error_code IS NULL THEN
               -- update the count for records populated into Adm int table
               l_recs_inserted := l_recs_inserted + 1;
            END IF;

         END IF; -- processing adm import process tables.

         EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.
              ROLLBACK TO ivstarn_rec_savepoint;
              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);

              -- Close any Open cursors
              IF cur_ucas_control%ISOPEN THEN
                 CLOSE cur_ucas_control;
              END IF;

              -- Close any Open cursors
              IF cur_map%ISOPEN THEN
                 CLOSE cur_map;
              END IF;

              -- Close any Open cursors
              IF cur_chk_adjunct%ISOPEN THEN
                 CLOSE cur_chk_adjunct;
              END IF;

              -- Close any Open cursors
              IF old_appl_cur%ISOPEN THEN
                 CLOSE old_appl_cur;
              END IF;

         END;
         -----------------------------------------------
         --  End of Processing Adm import process tables.
         -----------------------------------------------


         -----------------------------------------------
         --  Updating Interface table record with success or failure
         -----------------------------------------------
         -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
         -- while processing the record.
       IF g_error_code IS NOT NULL THEN

          fnd_message.set_name('IGS','IGS_UC_REC_FAIL_PROC');
          fnd_message.set_token('APPNO', TO_CHAR(new_ivstarn_rec.appno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- rollback the insert/updates made for this record
          ROLLBACK TO ivstarn_rec_savepoint;

          UPDATE igs_uc_istarn_ints
          SET    error_code    = g_error_code
          WHERE  rowid = new_ivstarn_rec.rowid;

          -- log error message/meaning.
          igs_uc_proc_ucas_data.log_error_msg(g_error_code);

          -- update error count
          g_error_rec_cnt  := g_error_rec_cnt  + 1;

       ELSE

          -- record processed successfully
          UPDATE igs_uc_istarn_ints
          SET    record_status   = 'I'  ,  -- 'I' signifies intermediate stage of processing.
                 error_code      = NULL ,
                 ad_batch_id     = l_adm_batch_id,
                 ad_interface_id = l_interface_id,
                 ad_api_id       = l_alt_pers_seq_id
          WHERE  rowid = new_ivstarn_rec.rowid;

          g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
       END IF;


    END LOOP;

    fnd_file.put_line(fnd_file.log, '');  -- to get a blank line
    fnd_file.put_line(fnd_file.log, '');  -- to get a blank line
    fnd_file.put_line(fnd_file.log, '==========================================================================');
    fnd_message.set_name('IGS','IGS_UC_RECS_INTO_AD_INT');
    fnd_message.set_token('RECCNT', TO_CHAR(l_recs_inserted));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log, '==========================================================================');
    fnd_file.put_line(fnd_file.log, '');  -- to get a blank line
    fnd_file.put_line(fnd_file.log, '');  -- to get a blank line


    COMMIT;

    --------------------------------------------------------------------------------------------------
    --   CALLING ADMISSION IMPORT PROCESS
    --------------------------------------------------------------------------------------------------
    IF l_invoke_adm_import_Proc_flag  = 'Y' AND l_recs_inserted > 0 THEN

       -- invoke procedure that calls Adm import process to process the person details populated.
       proc_invoke_adm_imp_process (l_adm_batch_id, l_source_type_id);
    END IF;


    -- call the process to check for successful person creation and update the Inteface record status accordingly.
    proc_update_ivstarn_status;


    -- call the procedure to populate OSS Person ID into IGS_UC_APPLICANTS.
    -- processing continues even if some unhandled excpetion is raised in the called procedure.
    proc_populate_oss_person;


    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTARN', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_VW_PROC_ERROR');
    fnd_message.set_token('VIEW_NAME', 'IVSTARN'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstarn;




  PROCEDURE process_ivstara  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Applicant Address info. details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     dsridhar  25-AUG-2003  Bug No: 3108562. Since the Address data has changed,
                            the sent_to_oss flag in IGS_UC_APPLICANTS has to be reset to 'N'.
     jbaber    11-Jul-2006  Added mobile, countrycode and homecountrycode for UCAS 2007 Support
    ******************************************************************/

     CURSOR new_ivstara_cur IS
     SELECT ivsta.rowid,
            ivsta.*
     FROM   igs_uc_istara_ints ivsta
     WHERE  record_status = 'N';


     CURSOR old_stara_cur(p_appno igs_uc_applicants.app_no%TYPE) IS
     SELECT appaddr.rowid,
            appaddr.*
     FROM   igs_uc_app_addreses appaddr
     WHERE  appaddr.app_no = p_appno;

     CURSOR appl_details (cp_appno igs_uc_applicants.app_no%TYPE) IS
     SELECT app.rowid, app.*
     FROM   igs_uc_applicants app
     WHERE  app.app_no = cp_appno;

     -- To validate against Country code.
     CURSOR validate_country_cur (p_code igs_uc_ref_country.country_code%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_ref_country
     WHERE  country_code = p_code;

     l_valid  VARCHAR2(1); -- for holding fetch from cursors for rec exists check.

     app_rec  appl_details%ROWTYPE;
     old_stara_rec old_stara_cur%ROWTYPE ;

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;
    l_valid := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTARA ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstara_rec IN new_ivstara_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          g_error_code := NULL;
          old_stara_rec := NULL;
          app_rec       := NULL;

          -- log Application processing message.
          fnd_message.set_name('IGS','IGS_UC_APPNO_PROC');
          fnd_message.set_token('APPL_NO', TO_CHAR(new_ivstara_rec.appno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- mandatory field validations
          IF new_ivstara_rec.appno IS NULL THEN
             g_error_code := '1037';
          END IF;

          IF g_error_code IS NULL THEN
             -- validate Applicant record details in UCAS Applicants table.
             validate_applicant (new_ivstara_rec.appno, g_error_code);
          END IF;

          ----------------------------
          -- COUNTRYCODE validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate Country Code
             IF new_ivstara_rec.countrycode IS NOT NULL THEN

                OPEN  validate_country_cur (new_ivstara_rec.countrycode);
                FETCH validate_country_cur INTO l_valid;

                IF validate_country_cur%NOTFOUND THEN
                   g_error_code := '1061';
                END IF;

                CLOSE validate_country_cur;
             END IF;
          END IF;
          --- end of COUNTRYCODE validation

          ----------------------------
          -- HOMECOUNTRYCODE validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate Home Country Code
             IF new_ivstara_rec.homecountrycode IS NOT NULL THEN

                OPEN  validate_country_cur (new_ivstara_rec.homecountrycode);
                FETCH validate_country_cur INTO l_valid;

                IF validate_country_cur%NOTFOUND THEN
                   g_error_code := '1062';
                END IF;

                CLOSE validate_country_cur;
             END IF;
          END IF;
          --- end of COUNTRYCODE validation


          -- begining main processing
          IF g_error_code IS NULL THEN  --
             -- Check wether the Application record already exists.
             -- If exists , update the records otherwise insert a new record.
             OPEN old_stara_cur(new_ivstara_rec.appno);
             FETCH old_stara_cur INTO old_stara_rec;
             CLOSE old_stara_cur;

             IF old_stara_rec.rowid IS NULL THEN

                BEGIN
                   --Insert a new record as no corresponding record exists.
                   igs_uc_app_addreses_pkg.insert_row --
                   (
                     x_rowid              => old_stara_rec.rowid
                    ,x_app_no             => new_ivstara_rec.appno
                    ,x_address_area       => new_ivstara_rec.addressarea
                    ,x_address1           => new_ivstara_rec.address1
                    ,x_address2           => new_ivstara_rec.address2
                    ,x_address3           => new_ivstara_rec.address3
                    ,x_address4           => new_ivstara_rec.address4
                    ,x_post_code          => new_ivstara_rec.postcode
                    ,x_mail_sort          => new_ivstara_rec.mailsort
                    ,x_telephone          => new_ivstara_rec.telephone
                    ,x_fax                => new_ivstara_rec.fax
                    ,x_email              => new_ivstara_rec.email
                    ,x_home_address1      => new_ivstara_rec.homeaddress1
                    ,x_home_address2      => new_ivstara_rec.homeaddress2
                    ,x_home_address3      => new_ivstara_rec.homeaddress3
                    ,x_home_address4      => new_ivstara_rec.homeaddress4
                    ,x_home_postcode      => new_ivstara_rec.homepostcode
                    ,x_home_phone         => new_ivstara_rec.homephone
                    ,x_home_fax           => new_ivstara_rec.homefax
                    ,x_home_email         => new_ivstara_rec.homeemail
                    ,x_sent_to_oss_flag   => 'N'
                    ,x_mobile             => new_ivstara_rec.mobile
                    ,x_country_code       => new_ivstara_rec.countrycode
                    ,x_home_country_code  => new_ivstara_rec.homecountrycode
                    ,x_ad_batch_id        => NULL
                    ,x_ad_interface_id    => NULL
                    ,x_mode               => 'R'
                   );

                EXCEPTION
                   WHEN OTHERS THEN
                     g_error_code := '9999';
                     fnd_file.put_line(fnd_file.log, SQLERRM);
                END;

             ELSE /* Update the record */

                BEGIN
                   -- call the TBH to update the record
                   igs_uc_app_addreses_pkg.update_row --
                   (
                     x_rowid              => old_stara_rec.rowid
                    ,x_app_no             => old_stara_rec.app_no
                    ,x_address_area       => new_ivstara_rec.addressarea
                    ,x_address1           => new_ivstara_rec.address1
                    ,x_address2           => new_ivstara_rec.address2
                    ,x_address3           => new_ivstara_rec.address3
                    ,x_address4           => new_ivstara_rec.address4
                    ,x_post_code          => new_ivstara_rec.postcode
                    ,x_mail_sort          => new_ivstara_rec.mailsort
                    ,x_telephone          => new_ivstara_rec.telephone
                    ,x_fax                => new_ivstara_rec.fax
                    ,x_email              => new_ivstara_rec.email
                    ,x_home_address1      => new_ivstara_rec.homeaddress1
                    ,x_home_address2      => new_ivstara_rec.homeaddress2
                    ,x_home_address3      => new_ivstara_rec.homeaddress3
                    ,x_home_address4      => new_ivstara_rec.homeaddress4
                    ,x_home_postcode      => new_ivstara_rec.homepostcode
                    ,x_home_phone         => new_ivstara_rec.homephone
                    ,x_home_fax           => new_ivstara_rec.homefax
                    ,x_home_email         => new_ivstara_rec.homeemail
                    ,x_sent_to_oss_flag   => 'N'
                    ,x_mobile             => new_ivstara_rec.mobile
                    ,x_country_code       => new_ivstara_rec.countrycode
                    ,x_home_country_code  => new_ivstara_rec.homecountrycode
                    ,x_ad_batch_id        => old_stara_rec.ad_batch_id
                    ,x_ad_interface_id    => old_stara_rec.ad_interface_id
                    ,x_mode               => 'R'
                    );

                    -- Bug No: 3108562. Since the Address data has changed, the sent_to_oss flag in
                    -- IGS_UC_APPLICANTS has to be reset to 'N'.
                    OPEN appl_details(old_stara_rec.app_no);
                    FETCH appl_details INTO app_rec;
                    CLOSE appl_details;

                    IF app_rec.app_no IS NULL THEN
                       g_error_code := '1000';
                    ELSE

                       -- call the TBH to update the record setting sent to OSS as No.
                       igs_uc_applicants_pkg.update_row -- IGSXI01B.pls
                            (
                             x_rowid                        => app_rec.rowid
                            ,x_app_id                       => app_rec.app_id
                            ,x_app_no                       => app_rec.app_no
                            ,x_check_digit                  => app_rec.check_digit
                            ,x_personal_id                  => app_rec.personal_id
                            ,x_enquiry_no                   => app_rec.enquiry_no
                            ,x_oss_person_id                => app_rec.oss_person_id
                            ,x_application_source           => app_rec.application_source
                            ,x_name_change_date             => app_rec.name_change_date
                            ,x_student_support              => app_rec.student_support
                            ,x_address_area                 => app_rec.address_area
                            ,x_application_date             => app_rec.application_date
                            ,x_application_sent_date        => app_rec.application_sent_date
                            ,x_application_sent_run         => app_rec.application_sent_run
                            ,x_lea_code                     => NULL  -- obsoleted by UCAS
                            ,x_fee_payer_code               => app_rec.fee_payer_code
                            ,x_fee_text                     => app_rec.fee_text
                            ,x_domicile_apr                 => app_rec.domicile_apr
                            ,x_code_changed_date            => app_rec.code_changed_date
                            ,x_school                       => app_rec.school
                            ,x_withdrawn                    => app_rec.withdrawn
                            ,x_withdrawn_date               => app_rec.withdrawn_date
                            ,x_rel_to_clear_reason          => app_rec.rel_to_clear_reason
                            ,x_route_b                      => app_rec.route_b
                            ,x_exam_change_date             => app_rec.exam_change_date
                            ,x_a_levels                     => NULL  -- obsoleted by UCAS
                            ,x_as_levels                    => NULL  -- obsoleted by UCAS
                            ,x_highers                      => NULL  -- obsoleted by UCAS
                            ,x_csys                         => NULL  -- obsoleted by UCAS
                            ,x_winter                       => app_rec.winter
                            ,x_previous                     => app_rec.previous
                            ,x_gnvq                         => NULL  -- obsoleted by UCAS
                            ,x_btec                         => app_rec.btec
                            ,x_ilc                          => app_rec.ilc
                            ,x_ailc                         => app_rec.ailc
                            ,x_ib                           => app_rec.ib
                            ,x_manual                       => app_rec.manual
                            ,x_reg_num                      => app_rec.reg_num
                            ,x_oeq                          => app_rec.oeq
                            ,x_eas                          => app_rec.eas
                            ,x_roa                          => app_rec.roa
                            ,x_status                       => app_rec.status
                            ,x_firm_now                     => app_rec.firm_now
                            ,x_firm_reply                   => app_rec.firm_reply
                            ,x_insurance_reply              => app_rec.insurance_reply
                            ,x_conf_hist_firm_reply         => app_rec.conf_hist_firm_reply
                            ,x_conf_hist_ins_reply          => app_rec.conf_hist_ins_reply
                            ,x_residential_category         => app_rec.residential_category
                            ,x_personal_statement           => app_rec.personal_statement
                            ,x_match_prev                   => app_rec.match_prev
                            ,x_match_prev_date              => app_rec.match_prev_date
                            ,x_match_winter                 => app_rec.match_winter
                            ,x_match_summer                 => app_rec.match_summer
                            ,x_gnvq_date                    => app_rec.gnvq_date
                            ,x_ib_date                      => app_rec.ib_date
                            ,x_ilc_date                     => app_rec.ilc_date
                            ,x_ailc_date                    => app_rec.ailc_date
                            ,x_gcseqa_date                  => app_rec.gcseqa_date
                            ,x_uk_entry_date                => app_rec.uk_entry_date
                            ,x_prev_surname                 => app_rec.prev_surname
                            ,x_criminal_convictions         => app_rec.criminal_convictions
                            ,x_sent_to_hesa                 => app_rec.sent_to_hesa
                            ,x_sent_to_oss                  => 'N'
                            ,x_batch_identifier             => app_rec.batch_identifier
                            ,x_mode                         => 'R'
                            ,x_GCE                          => app_rec.GCE
                            ,x_VCE                          => app_rec.VCE
                            ,x_SQA                          => app_rec.SQA
                            ,x_PREVIOUSAS                   => app_rec.previousas
                            ,x_KEYSKILLS                    => app_rec.keyskills
                            ,x_VOCATIONAL                   => app_rec.vocational
                            ,x_SCN                          => app_rec.SCN
                            ,x_PrevOEQ                      => app_rec.PrevOEQ
                            ,x_choices_transparent_ind      => app_rec.choices_transparent_ind
                            ,x_extra_status                 => app_rec.extra_status
                            ,x_extra_passport_no            => app_rec.extra_passport_no
                            ,x_request_app_dets_ind         => app_rec.request_app_dets_ind
                            ,x_request_copy_app_frm_ind     => app_rec.request_copy_app_frm_ind
                            ,x_cef_no                       => app_rec.cef_no
                            ,x_system_code                  => app_rec.system_code
                            ,x_gcse_eng                     => app_rec.gcse_eng
                            ,x_gcse_math                    => app_rec.gcse_math
                            ,x_degree_subject               => app_rec.degree_subject
                            ,x_degree_status                => app_rec.degree_status
                            ,x_degree_class                 => app_rec.degree_class
                            ,x_gcse_sci                     => app_rec.gcse_sci
                            ,x_welshspeaker                 => app_rec.welshspeaker
                            ,x_ni_number                    => app_rec.ni_number
                            ,x_earliest_start               => app_rec.earliest_start
                            ,x_near_inst                    => app_rec.near_inst
                            ,x_pref_reg                     => app_rec.pref_reg
                            ,x_qual_eng                     => app_rec.qual_eng
                            ,x_qual_math                    => app_rec.qual_math
                            ,x_qual_sci                     => app_rec.qual_sci
                            ,x_main_qual                    => app_rec.main_qual
                            ,x_qual_5                       => app_rec.qual_5
                            ,x_future_serv                  => app_rec.future_serv
                            ,x_future_set                   => app_rec.future_set
                            ,x_present_serv                 => app_rec.present_serv
                            ,x_present_set                  => app_rec.present_set
                            ,x_curr_employment              => app_rec.curr_employment
                            ,x_edu_qualification            => app_rec.edu_qualification
                            ,x_ad_batch_id                  => app_rec.ad_batch_id
                            ,x_ad_interface_id              => app_rec.ad_interface_id
                            ,x_nationality                  => app_rec.nationality
                            ,x_dual_nationality             => app_rec.dual_nationality
                            ,x_special_needs                => app_rec.special_needs
                            ,x_country_birth                => app_rec.country_birth
                            );
                    END IF;

                EXCEPTION
                   WHEN OTHERS THEN
                     g_error_code := '9998';
                     fnd_file.put_line(fnd_file.log, SQLERRM);
                END;

             END IF; -- insert / update

          END IF;

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.
              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);

              -- Close any Open cursors
              IF old_stara_cur%ISOPEN THEN
                 CLOSE old_stara_cur;
              END IF;

        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN
             UPDATE igs_uc_istara_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivstara_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE
             UPDATE igs_uc_istara_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivstara_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTARA', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTARA'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstara;



  PROCEDURE process_ivstark  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Applicant info. details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     smaddali 8-aug-03  Modified igs_uc_applicants.update call to update ni_number, criminal_conv,ukentry_date fields,bug#3088436
     rgangara 05-FEB-04 Added update to App Stats table for Sent_to_HESA flag as the Domicile data comes in *K transaction but
                        is exported to OSS along with App Stats data. Without this, the Modified Domicile data cannot be exported
                        since the process picks only when the said flag is 'N'. Bug# 3405245
     jchakrab 23-AUG-04  Modified for Bug#3838781 - Update the system code for existing SWAS applicants in igs_uc_applicants
                         when applications are re-sent by UCAS, as SWAS applicants need to be identified as FTUG applicants for
                         ucas_cycle > 2004.
     jbaber   15-Sep-05  Modified for bug 4589994 - do not update routeb with NULL value
     jchakrab 06-Sep-06  Modified for bug 5481963 - update app-choice records when IVSTARK withdrawn value is W or C
    ******************************************************************/

     CURSOR new_ivstark_cur IS
     SELECT ivstk.rowid,
            ivstk.*
     FROM   igs_uc_istark_ints ivstk
     WHERE  record_status = 'N';


     CURSOR old_stark_cur(p_appno igs_uc_applicants.app_no%TYPE) IS
     SELECT appl.rowid,
            appl.*
     FROM   igs_uc_applicants appl
     WHERE  appl.app_no = p_appno;

     -- To validate SPECIALNEEDS, RESCAT, FEEPAYER, STATUS against Reference codes.
     CURSOR validate_refcodes_cur (p_type igs_uc_ref_codes.code_type%TYPE,
                                   p_code igs_uc_ref_codes.code%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_ref_codes
     WHERE  code_type = p_type
     AND    code      = p_code;


     -- To validate against Reference code.
     CURSOR validate_school_cur (p_school igs_uc_com_sch.school%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_com_sch
     WHERE  school = p_school;


     -- To validate against REF APR table.
     CURSOR validate_ref_apr_cur (p_id igs_uc_ref_apr.dom%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_ref_apr
     WHERE  dom = p_id;

     -- To validate against Country code.
     CURSOR validate_country_cur (p_code igs_uc_ref_country.country_code%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_ref_country
     WHERE  country_code = p_code;


     -- To Update Sent_to_HESA flag in IGS_UC_APP_STATS when Domicile APR value gets updated in Applicant's table.
     -- This is because Domicile code is stored in Applicants table and need to be exported to OSS along with other
     -- details held in IGS_UC_APP_STATS table through Export HESA data to OSS porcess.
     CURSOR Cur_app_stats (cp_appno igs_uc_app_stats.app_no%TYPE) IS
     SELECT stat.rowid,
            stat.*
     FROM   igs_uc_app_stats stat
     WHERE  app_no = cp_appno;

     -- jchakrab  added for Bug 5481963 - 06-Sep-2006
     -- Retrieves choice records for an applicant in configured cycle and current institution
     CURSOR cur_uc_app_choices(p_appno igs_uc_app_choices.app_no%TYPE,
                               p_ucas_cycle igs_uc_app_choices.ucas_cycle%TYPE,
                               p_inst_code igs_uc_app_choices.institute_code%TYPE) IS
     SELECT uacc.rowid,
            uacc.*
     FROM   igs_uc_app_choices uacc
     WHERE  uacc.app_no = p_appno
     AND    uacc.ucas_cycle = p_ucas_cycle
     AND    uacc.institute_code = p_inst_code;

     old_stark_rec old_stark_cur%ROWTYPE ;
     l_valid  VARCHAR2(1); -- for holding fetch from cursors for rec exists check.

     -- jchakrab added for deriving system_code - Bug# 3838781 - 23-Aug-2004
     l_system_code    igs_uc_applicants.system_code%TYPE;
  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTARK ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstark_rec IN new_ivstark_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          g_error_code := NULL;
          old_stark_rec := NULL;
          l_valid  := NULL;

          -- log Application processing message.
          fnd_message.set_name('IGS','IGS_UC_APPNO_PROC');
          fnd_message.set_token('APPL_NO', TO_CHAR(new_ivstark_rec.appno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);

          -- Mandatory field validations.
          IF new_ivstark_rec.appno IS NULL THEN
             g_error_code := '1037';
          END IF;

          -- appno validation
          IF g_error_code IS NULL THEN
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into IGS_UC_APPLICANTS as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivstark_rec.appno, g_error_code);
          END IF;


          ----------------------------
          -- SPECIALNEEDS validation
          -- NOTE : The values coming from UCAS have UCAS codes. However, for this field the OSS values are different. While populating
          -- these values into ADM Import tables, corresponding OSS values are being derived as part of IGSUCJ44 process from Code Mapping val table.
          -- Hence as part of this process UCAS values are being stored in UCAS Applicants table.
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate specialneeds
             IF new_ivstark_rec.specialneeds IS NOT NULL THEN
                OPEN  validate_refcodes_cur ('DC', new_ivstark_rec.specialneeds);
                FETCH validate_refcodes_cur INTO l_valid;

                IF validate_refcodes_cur%NOTFOUND THEN
                   g_error_code := '1009';
                END IF;

                CLOSE validate_refcodes_cur;
             END IF;
          END IF;
          --- end of SPECIALNEEDS validation


          ----------------------------
          -- SCHOOL validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate School
             IF new_ivstark_rec.school IS NOT NULL THEN

                OPEN  validate_school_cur (new_ivstark_rec.school);
                FETCH validate_school_cur INTO l_valid;

                IF validate_school_cur%NOTFOUND THEN
                   g_error_code := '1010';
                END IF;

                CLOSE validate_school_cur;
             END IF;
          END IF;
          --- end of SCHOOL validation


          ----------------------------
          -- RESCAT validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate RESCAT
             IF new_ivstark_rec.rescat IS NOT NULL THEN

                OPEN validate_refcodes_cur ('RC', new_ivstark_rec.rescat);
                FETCH validate_refcodes_cur INTO l_valid;

                IF validate_refcodes_cur%NOTFOUND THEN
                   g_error_code := '1011';
                END IF;

                CLOSE validate_refcodes_cur;
             END IF;
          END IF;
          --- end of RESCAT validation


          ----------------------------
          -- FEEPAYER validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate FEEPAYER
             IF new_ivstark_rec.feepayer IS NOT NULL THEN

                OPEN validate_refcodes_cur ('FC', new_ivstark_rec.feepayer);
                FETCH validate_refcodes_cur INTO l_valid;

                IF validate_refcodes_cur%NOTFOUND THEN
                   g_error_code := '1012';
                END IF;

                CLOSE validate_refcodes_cur;
             END IF;
          END IF;
          --- end of FEEPAYER validation


          ----------------------------
          -- STATUS validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate STATUS
             IF new_ivstark_rec.status IS NOT NULL THEN

                OPEN validate_refcodes_cur ('SC', new_ivstark_rec.status);
                FETCH validate_refcodes_cur INTO l_valid;

                IF validate_refcodes_cur%NOTFOUND THEN
                   g_error_code := '1017';
                END IF;

                CLOSE validate_refcodes_cur;
             END IF;
          END IF;
          --- end of STATUS validation


          ----------------------------
          -- APR validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate APR
             IF new_ivstark_rec.apr IS NOT NULL THEN

                OPEN validate_ref_apr_cur (new_ivstark_rec.apr);
                FETCH validate_ref_apr_cur INTO l_valid;

                IF validate_ref_apr_cur%NOTFOUND THEN
                   g_error_code := '1013';
                END IF;

                CLOSE validate_ref_apr_cur;
             END IF;
          END IF;
          --- end of APR validation


          ----------------------------
          --  COUNTRYBIRTH validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate CountryBirth
             IF new_ivstark_rec.countrybirth IS NOT NULL THEN

                IF g_config_cycle > 2006 THEN

                   OPEN validate_country_cur (new_ivstark_rec.countrybirth);
                   FETCH validate_country_cur INTO l_valid;

                   IF validate_country_cur%NOTFOUND THEN
                      g_error_code := '1014';
                   END IF;

                   CLOSE validate_country_cur;

                ELSE

                   OPEN validate_ref_apr_cur (new_ivstark_rec.countrybirth);
                   FETCH validate_ref_apr_cur INTO l_valid;

                   IF validate_ref_apr_cur%NOTFOUND THEN
                      g_error_code := '1014';
                   END IF;

                   CLOSE validate_ref_apr_cur;

                END IF;

             END IF;

          END IF;
          --- end of Country Birth validation


          ----------------------------
          --  NATIONALITY validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate Nationality
             IF new_ivstark_rec.nationality IS NOT NULL THEN

                IF g_config_cycle > 2006 THEN

                   OPEN validate_refcodes_cur ('NC', new_ivstark_rec.nationality);
                   FETCH validate_refcodes_cur INTO l_valid;

                   IF validate_refcodes_cur%NOTFOUND THEN
                      g_error_code := '1015';
                   END IF;

                   CLOSE validate_refcodes_cur;

                ELSE

                   OPEN validate_ref_apr_cur (new_ivstark_rec.nationality);
                   FETCH validate_ref_apr_cur INTO l_valid;

                   IF validate_ref_apr_cur%NOTFOUND THEN
                      g_error_code := '1015';
                   END IF;

                   CLOSE validate_ref_apr_cur;

                END IF;

             END IF;

          END IF;
          --- end of Nationality validation



          ----------------------------
          --  DUALNATIONALITY validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate Dual Nationality
             IF new_ivstark_rec.dualnationality IS NOT NULL THEN

                IF g_config_cycle > 2006 THEN

                   OPEN validate_refcodes_cur ('NC', new_ivstark_rec.dualnationality);
                   FETCH validate_refcodes_cur INTO l_valid;

                   IF validate_refcodes_cur%NOTFOUND THEN
                      g_error_code := '1016';
                   END IF;

                   CLOSE validate_refcodes_cur;

                ELSE

                   OPEN validate_ref_apr_cur (new_ivstark_rec.dualnationality);
                   FETCH validate_ref_apr_cur INTO l_valid;

                   IF validate_ref_apr_cur%NOTFOUND THEN
                      g_error_code := '1016';
                   END IF;

                   CLOSE validate_ref_apr_cur;

                END IF;

             END IF;

          END IF;
          --- end of Dual Nationality validation


          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN  --

             -- Check wether the Application record already exists.
             -- If exists , update the records otherwise insert a new record.
             OPEN  old_stark_cur(new_ivstark_rec.appno);
             FETCH old_stark_cur INTO old_stark_rec;
             CLOSE old_stark_cur;

             IF old_stark_rec.rowid IS NULL THEN
                -- this actually is not required as this error would
                -- get reported in the validate_applicant procedure itself. However, for
                -- logic clarity this has been retained.
                g_error_code := '1000';

             ELSE /* Update the record */


                -- jchakrab added to identify SWAS applicants in cycle > 2004
                                -- as FTUG applicants - Bug#3838781 - 23-Aug-2004
                l_system_code := old_stark_rec.system_code;
                IF l_system_code = 'S' and g_config_cycle>2004 THEN
                   l_system_code := 'U';
                END IF;

                BEGIN
                   -- call the TBH to update the record
                   -- smaddali updating criminal_conv, ukentrydate,ni_number with interface record values as per bug#3088436
                   igs_uc_applicants_pkg.update_row -- IGSXI01B.pls
                    (
                     x_rowid                        => old_stark_rec.rowid
                    ,x_app_id                       => old_stark_rec.app_id
                    ,x_app_no                       => old_stark_rec.app_no
                    ,x_check_digit                  => old_stark_rec.check_digit
                    ,x_personal_id                  => old_stark_rec.personal_id
                    ,x_enquiry_no                   => old_stark_rec.enquiry_no
                    ,x_oss_person_id                => old_stark_rec.oss_person_id
                    ,x_application_source           => old_stark_rec.application_source
                    ,x_name_change_date             => old_stark_rec.name_change_date
                    ,x_student_support              => old_stark_rec.student_support
                    ,x_address_area                 => old_stark_rec.address_area
                    ,x_application_date             => new_ivstark_rec.applicationdate
                    ,x_application_sent_date        => new_ivstark_rec.sentdate
                    ,x_application_sent_run         => new_ivstark_rec.runsent
                    ,x_lea_code                     => NULL  -- obsoleted by UCAS
                    ,x_fee_payer_code               => new_ivstark_rec.feepayer
                    ,x_fee_text                     => new_ivstark_rec.feetext
                    ,x_domicile_apr                 => new_ivstark_rec.apr
                    ,x_code_changed_date            => new_ivstark_rec.codedchangedate
                    ,x_school                       => new_ivstark_rec.school
                    ,x_withdrawn                    => new_ivstark_rec.withdrawn
                    ,x_withdrawn_date               => new_ivstark_rec.withdrawndate
                    ,x_rel_to_clear_reason          => old_stark_rec.rel_to_clear_reason
                    ,x_route_b                      => NVL(new_ivstark_rec.routeb, old_stark_rec.route_b)
                    ,x_exam_change_date             => new_ivstark_rec.examchangedate
                    ,x_a_levels                     => NULL  -- obsoleted by UCAS
                    ,x_as_levels                    => NULL  -- obsoleted by UCAS
                    ,x_highers                      => NULL  -- obsoleted by UCAS
                    ,x_csys                         => NULL  -- obsoleted by UCAS
                    ,x_winter                       => new_ivstark_rec.winter
                    ,x_previous                     => new_ivstark_rec.previousa
                    ,x_gnvq                         => NULL  -- obsoleted by UCAS
                    ,x_btec                         => new_ivstark_rec.btec
                    ,x_ilc                          => new_ivstark_rec.ilc
                    ,x_ailc                         => new_ivstark_rec.aice
                    ,x_ib                           => new_ivstark_rec.ib
                    ,x_manual                       => new_ivstark_rec.manual
                    ,x_reg_num                      => new_ivstark_rec.regno
                    ,x_oeq                          => new_ivstark_rec.oeq
                    ,x_eas                          => new_ivstark_rec.eas
                    ,x_roa                          => new_ivstark_rec.roa
                    ,x_status                       => new_ivstark_rec.status
                    ,x_firm_now                     => new_ivstark_rec.firmnow
                    ,x_firm_reply                   => new_ivstark_rec.firmreply
                    ,x_insurance_reply              => new_ivstark_rec.insurancereply
                    ,x_conf_hist_firm_reply         => new_ivstark_rec.confhistfirmreply
                    ,x_conf_hist_ins_reply          => new_ivstark_rec.confhistinsurancereply
                    ,x_residential_category         => new_ivstark_rec.rescat
                    ,x_personal_statement           => old_stark_rec.personal_statement
                    ,x_match_prev                   => old_stark_rec.match_prev
                    ,x_match_prev_date              => old_stark_rec.match_prev_date
                    ,x_match_winter                 => old_stark_rec.match_winter
                    ,x_match_summer                 => old_stark_rec.match_summer
                    ,x_gnvq_date                    => old_stark_rec.gnvq_date
                    ,x_ib_date                      => old_stark_rec.ib_date
                    ,x_ilc_date                     => old_stark_rec.ilc_date
                    ,x_ailc_date                    => old_stark_rec.ailc_date
                    ,x_gcseqa_date                  => old_stark_rec.gcseqa_date
                    ,x_uk_entry_date                => new_ivstark_rec.ukentrydate
                    ,x_prev_surname                 => old_stark_rec.prev_surname
                    ,x_criminal_convictions         => new_ivstark_rec.criminalconv
                    ,x_sent_to_hesa                 => 'N'
                    ,x_sent_to_oss                  => 'N'
                    ,x_batch_identifier             => old_stark_rec.batch_identifier
                    ,x_mode                         => 'R'
                    ,x_GCE                          => new_ivstark_rec.GCE
                    ,x_VCE                          => new_ivstark_rec.VCE
                    ,x_SQA                          => new_ivstark_rec.SQA
                    ,x_PREVIOUSAS                   => new_ivstark_rec.previousas
                    ,x_KEYSKILLS                    => new_ivstark_rec.keyskills
                    ,x_VOCATIONAL                   => new_ivstark_rec.vocational
                    ,x_SCN                          => new_ivstark_rec.SCN
                    ,x_PrevOEQ                      => new_ivstark_rec.PrevOEQ
                    ,x_choices_transparent_ind      => new_ivstark_rec.choicesalltransparent
                    ,x_extra_status                 => new_ivstark_rec.extrastatus
                    ,x_extra_passport_no            => new_ivstark_rec.extrapassportno
                    ,x_request_app_dets_ind         => old_stark_rec.request_app_dets_ind
                    ,x_request_copy_app_frm_ind     => old_stark_rec.request_copy_app_frm_ind
                    ,x_cef_no                       => old_stark_rec.cef_no
                    ,x_system_code                  => l_system_code    -- update the system code - Bug#3838781
                    ,x_gcse_eng                     => old_stark_rec.gcse_eng
                    ,x_gcse_math                    => old_stark_rec.gcse_math
                    ,x_degree_subject               => old_stark_rec.degree_subject
                    ,x_degree_status                => old_stark_rec.degree_status
                    ,x_degree_class                 => old_stark_rec.degree_class
                    ,x_gcse_sci                     => old_stark_rec.gcse_sci
                    ,x_welshspeaker                 => new_ivstark_rec.welshspeaker
                    ,x_ni_number                    => new_ivstark_rec.ninumber
                    ,x_earliest_start               => new_ivstark_rec.earlieststart
                    ,x_near_inst                    => new_ivstark_rec.nearinst
                    ,x_pref_reg                     => new_ivstark_rec.prefreg
                    ,x_qual_eng                     => new_ivstark_rec.qualeng
                    ,x_qual_math                    => new_ivstark_rec.qualmath
                    ,x_qual_sci                     => new_ivstark_rec.qualsci
                    ,x_main_qual                    => new_ivstark_rec.mainqual
                    ,x_qual_5                       => new_ivstark_rec.qual5
                    ,x_future_serv                  => old_stark_rec.future_serv
                    ,x_future_set                   => old_stark_rec.future_set
                    ,x_present_serv                 => old_stark_rec.present_serv
                    ,x_present_set                  => old_stark_rec.present_set
                    ,x_curr_employment              => old_stark_rec.curr_employment
                    ,x_edu_qualification            => old_stark_rec.edu_qualification
                    ,x_ad_batch_id                  => old_stark_rec.ad_batch_id
                    ,x_ad_interface_id              => old_stark_rec.ad_interface_id
                    ,x_nationality                  => new_ivstark_rec.nationality
                    ,x_dual_nationality             => new_ivstark_rec.dualnationality
                    ,x_special_needs                => new_ivstark_rec.specialneeds
                    ,x_country_birth                => new_ivstark_rec.countrybirth
                    );


                    -- IF Domicile is updated above, then the sent_to_hesa flag has to be set to 'N'
                    -- in the App Stats table so that the export HESA data to OSS process picks up
                    -- the Applicant data. Only the flag is updated if at all the AppNo rec exists.
                    IF new_ivstark_rec.apr <> old_stark_rec.domicile_apr THEN

                       FOR Cur_app_stats_rec IN Cur_app_stats (new_ivstark_rec.appno)
                       LOOP
                        igs_uc_app_stats_pkg.update_row(
                         x_rowid                   => Cur_app_stats_rec.rowid
                        ,x_app_stat_id             => Cur_app_stats_rec.app_stat_id
                        ,x_app_id                  => Cur_app_stats_rec.app_id
                        ,x_app_no                  => Cur_app_stats_rec.app_no
                        ,x_starh_ethnic            => Cur_app_stats_rec.starh_ethnic
                        ,x_starh_social_class      => Cur_app_stats_rec.starh_social_class
                        ,x_starh_pocc_edu_chg_dt   => Cur_app_stats_rec.starh_pocc_edu_chg_dt
                        ,x_starh_pocc              => Cur_app_stats_rec.starh_pocc
                        ,x_starh_pocc_text         => Cur_app_stats_rec.starh_pocc_text
                        ,x_starh_last_edu_inst     => Cur_app_stats_rec.starh_last_edu_inst
                        ,x_starh_edu_leave_date    => Cur_app_stats_rec.starh_edu_leave_date
                        ,x_starh_lea               => Cur_app_stats_rec.starh_lea
                        ,x_starx_ethnic            => Cur_app_stats_rec.starx_ethnic
                        ,x_starx_pocc_edu_chg      => Cur_app_stats_rec.starx_pocc_edu_chg
                        ,x_starx_pocc              => Cur_app_stats_rec.starx_pocc
                        ,x_starx_pocc_text         => Cur_app_stats_rec.starx_pocc_text
                        ,x_sent_to_hesa            => 'N'      -- set the flag to 'N' for this update.
                        ,x_mode                    => 'R'
                        ,x_starh_socio_economic    => Cur_app_stats_rec.starh_socio_economic
                        ,x_starx_socio_economic    => Cur_app_stats_rec.starx_socio_economic
                        ,x_starx_occ_background    => Cur_app_stats_rec.starx_occ_background
                        ,x_ivstarh_dependants      => Cur_app_stats_rec.ivstarh_dependants
                        ,x_ivstarh_married         => Cur_app_stats_rec.ivstarh_married
                        ,x_ivstarx_religion        => Cur_app_stats_rec.ivstarx_religion
                        ,x_ivstarx_dependants      => Cur_app_stats_rec.ivstarx_dependants
                        ,x_ivstarx_married         => Cur_app_stats_rec.ivstarx_married
                            );
                       END LOOP;
                    END IF;

                EXCEPTION
                   WHEN OTHERS THEN
                      g_error_code := '9998';
                      fnd_file.put_line(fnd_file.log, SQLERRM);
                END;

                -- jchakrab added for Bug 5481963 - 06-Sep-2006
                IF new_ivstark_rec.withdrawn = 'C' OR new_ivstark_rec.withdrawn = 'W' THEN

                   BEGIN
                      -- Get all the choice records for this applicant in the configured cycle
                      -- for current institution
                      FOR cur_uc_app_choices_rec IN cur_uc_app_choices(new_ivstark_rec.appno, g_config_cycle, g_crnt_institute)
                      LOOP
                         -- If withdrawn is C or (withdrawn is W and current choice is UF, then update the current choice
                         -- set decision = W, reply = null, and reset the export_to_oss_status to NEW
                         IF new_ivstark_rec.withdrawn = 'C' OR
                                (new_ivstark_rec.withdrawn = 'W' AND
                                 cur_uc_app_choices_rec.decision = 'U' AND
                                 cur_uc_app_choices_rec.reply = 'F') THEN

                            igs_uc_app_choices_pkg.update_row(
                             x_rowid                   => cur_uc_app_choices_rec.rowid
                            ,x_app_choice_id           => cur_uc_app_choices_rec.app_choice_id
                            ,x_app_id                  => cur_uc_app_choices_rec.app_id
                            ,x_app_no                  => cur_uc_app_choices_rec.app_no
                            ,x_choice_no               => cur_uc_app_choices_rec.choice_no
                            ,x_last_change             => cur_uc_app_choices_rec.last_change
                            ,x_institute_code          => cur_uc_app_choices_rec.institute_code
                            ,x_ucas_program_code       => cur_uc_app_choices_rec.ucas_program_code
                            ,x_oss_program_code        => cur_uc_app_choices_rec.oss_program_code
                            ,x_oss_program_version     => cur_uc_app_choices_rec.oss_program_version
                            ,x_oss_attendance_type     => cur_uc_app_choices_rec.oss_attendance_type
                            ,x_oss_attendance_mode     => cur_uc_app_choices_rec.oss_attendance_mode
                            ,x_campus                  => cur_uc_app_choices_rec.campus
                            ,x_oss_location            => cur_uc_app_choices_rec.oss_location
                            ,x_faculty                 => cur_uc_app_choices_rec.faculty
                            ,x_entry_year              => cur_uc_app_choices_rec.entry_year
                            ,x_entry_month             => cur_uc_app_choices_rec.entry_month
                            ,x_point_of_entry          => cur_uc_app_choices_rec.point_of_entry
                            ,x_home                    => cur_uc_app_choices_rec.home
                            ,x_deferred                => cur_uc_app_choices_rec.deferred
                            ,x_route_b_pref_round      => cur_uc_app_choices_rec.route_b_pref_round
                            ,x_route_b_actual_round    => cur_uc_app_choices_rec.route_b_actual_round
                            ,x_condition_category      => cur_uc_app_choices_rec.condition_category
                            ,x_condition_code          => cur_uc_app_choices_rec.condition_code
                            ,x_decision                => 'W'
                            ,x_decision_date           => cur_uc_app_choices_rec.decision_date
                            ,x_decision_number         => cur_uc_app_choices_rec.decision_number
                            ,x_reply                   => NULL
                            ,x_summary_of_cond         => cur_uc_app_choices_rec.summary_of_cond
                            ,x_choice_cancelled        => cur_uc_app_choices_rec.choice_cancelled
                            ,x_action                  => cur_uc_app_choices_rec.action
                            ,x_substitution            => cur_uc_app_choices_rec.substitution
                            ,x_date_substituted        => cur_uc_app_choices_rec.date_substituted
                            ,x_prev_institution        => cur_uc_app_choices_rec.prev_institution
                            ,x_prev_course             => cur_uc_app_choices_rec.prev_course
                            ,x_prev_campus             => cur_uc_app_choices_rec.prev_campus
                            ,x_ucas_amendment          => cur_uc_app_choices_rec.ucas_amendment
                            ,x_withdrawal_reason       => cur_uc_app_choices_rec.withdrawal_reason
                            ,x_offer_course            => cur_uc_app_choices_rec.offer_course
                            ,x_offer_campus            => cur_uc_app_choices_rec.offer_campus
                            ,x_offer_crse_length       => cur_uc_app_choices_rec.offer_crse_length
                            ,x_offer_entry_month       => cur_uc_app_choices_rec.offer_entry_month
                            ,x_offer_entry_year        => cur_uc_app_choices_rec.offer_entry_year
                            ,x_offer_entry_point       => cur_uc_app_choices_rec.offer_entry_point
                            ,x_offer_text              => cur_uc_app_choices_rec.offer_text
                            ,x_mode                    => 'R'
                            ,x_export_to_oss_status    => 'NEW'
                            ,x_error_code              => NULL
                            ,x_request_id              => cur_uc_app_choices_rec.request_id
                            ,x_batch_id                => cur_uc_app_choices_rec.batch_id
                            ,x_extra_round_nbr         => cur_uc_app_choices_rec.extra_round_nbr
                            ,x_system_code             => cur_uc_app_choices_rec.system_code
                            ,x_part_time               => cur_uc_app_choices_rec.part_time
                            ,x_interview               => cur_uc_app_choices_rec.interview
                            ,x_late_application        => cur_uc_app_choices_rec.late_application
                            ,x_modular                 => cur_uc_app_choices_rec.modular
                            ,x_residential             => cur_uc_app_choices_rec.residential
                            ,x_ucas_cycle              => cur_uc_app_choices_rec.ucas_cycle
                           );

                         END IF;

                      END LOOP;
                   EXCEPTION
                      WHEN OTHERS THEN
                      g_error_code := '9998';
                      fnd_file.put_line(fnd_file.log, SQLERRM);
                   END;

                END IF; -- end-if for new_ivstark_rec.withdrawn = C or W


             END IF; -- insert / update

          END IF;


        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.
              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);

              -- Close any Open cursors
              IF validate_refcodes_cur%ISOPEN THEN
                 CLOSE validate_refcodes_cur;
              END IF;

              IF validate_school_cur%ISOPEN THEN
                 CLOSE validate_school_cur;
              END IF;

              IF validate_ref_apr_cur%ISOPEN THEN
                 CLOSE validate_ref_apr_cur;
              END IF;

              IF old_stark_cur%ISOPEN THEN
                 CLOSE old_stark_cur;
              END IF;

        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN
             UPDATE igs_uc_istark_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivstark_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE
             UPDATE igs_uc_istark_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivstark_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTARK', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTARK'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstark;



  PROCEDURE process_ivstarc  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing IVSTARC - Applicant Choices info. details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     arvsrini  05-MAR-04  Added code to check before inserting records to IGS_UC_APP_CHOICES whether there exists record with
                          same institution code and system code but having choice number as 99.If there exists no records, then insert is performed
                          If it exists, the record is updated using choice number as IGS_UC_ISTARC_INTS.CHOICENO. Also if there exists records
                          in IGS_UC_TRANSACTIONS with choice_no = 99 then those records are also updated. Bug#3239860
     jchakrab  23-AUG-04  Modified for Bug# 3837871 - Update system_code of existing app_choice records in
                          IGS_UC_APP_CHOICES with current cycle's system_code in IGS_UC_APLICANTS
     jbaber    15-Sep-05  Entryyear defaults if NULL for all systems
     anwest    29-May-06  Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
     ******************************************************************/

     CURSOR new_ivstarc_cur IS
     SELECT ivstk.rowid,
            ivstk.*
     FROM   igs_uc_istarc_ints ivstk
     WHERE  record_status = 'N';


     CURSOR old_starc_cur(p_appno igs_uc_app_choices.app_no%TYPE,
                          p_choiceno igs_uc_app_choices.choice_no%TYPE,
                          p_cycle igs_uc_app_choices.ucas_cycle%TYPE) IS
     SELECT appl.rowid,
            appl.*
     FROM   igs_uc_app_choices appl
     WHERE  appl.app_no = p_appno
     AND    appl.choice_no = p_choiceno
     AND    appl.ucas_cycle = p_cycle;

     -- get the system and app_id to be populated into App Choices
     CURSOR get_appl_dets (p_appno igs_uc_applicants.app_no%TYPE) IS
     SELECT app_id,
            system_code
     FROM   igs_uc_applicants
     WHERE  app_no = p_appno;


     -- validate institution value
     CURSOR validate_Institution (p_inst igs_uc_com_inst.inst%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_com_inst
     WHERE  inst  = p_inst;

     -- get entry year from UCAS Control.
     CURSOR get_control_entry_year (p_system igs_uc_applicants.system_code%TYPE, p_cycle igs_uc_istarc_ints.ucas_cycle%TYPE) IS
     SELECT entry_year
     FROM igs_uc_ucas_control
     WHERE system_code = p_system
     AND   ucas_cycle  = p_cycle;

     -- Cursor to get the OSS Program details for the UCAS course from Course details table.
     CURSOR get_oss_prog_cur (p_course igs_uc_crse_dets.ucas_program_code%TYPE,
                              p_campus igs_uc_crse_dets.ucas_campus%TYPE,
                              p_inst   igs_uc_crse_dets.institute%TYPE,
                              p_system igs_uc_crse_dets.system_code%TYPE) IS
     SELECT oss_program_code,
            oss_program_version,
            oss_location,
            oss_attendance_mode,
            oss_attendance_type
     FROM   igs_uc_crse_dets
     WHERE  System_Code       = p_system
     AND    ucas_program_code = p_course
     AND    ucas_campus       = p_campus
     AND    Institute         = p_inst;




     CURSOR curr_inst_cur(p_sys_code igs_uc_defaults.system_code%type) IS
     SELECT current_inst_code
     FROM   igs_uc_defaults
     WHERE  system_code = p_sys_code;

     -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
     CURSOR uc_transaction_9_cur(p_app_no igs_uc_transactions.app_no%TYPE) IS
        SELECT trans.rowid,
               trans.*
        FROM   igs_uc_transactions trans
        WHERE  trans.app_no = p_app_no
        AND    trans.choice_no = 9;


     oss_prog_rec   get_oss_prog_cur%ROWTYPE;  -- Holds OSS Program details for the UCAS Course.
     old_starc_rec old_starc_cur%ROWTYPE ;     -- Holds the existing values for this incoming record.
     get_appl_dets_rec get_appl_dets%ROWTYPE;  -- Holds the Application details from UC_Applicants
     curr_inst_rec curr_inst_cur%ROWTYPE;
     old_starc_9_rec old_starc_cur%ROWTYPE;-- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES

     l_entry_year  igs_uc_ucas_control.entry_year%TYPE;
     l_deferred    igs_uc_app_choices.deferred%TYPE;
     l_entrymonth  igs_uc_app_choices.entry_month%TYPE;
     l_app_choice_id igs_uc_app_choices.app_choice_id%TYPE; -- Place holder for App CHoice ID - Seq gen value.
     l_valid  VARCHAR2(1); -- for holding fetch from cursors for rec exists check.

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTARC ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstarc_rec IN new_ivstarc_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          g_error_code := NULL;
          old_starc_rec := NULL;
          get_appl_dets_rec := NULL;
          l_valid  := NULL;
          oss_prog_rec := NULL;
          l_entry_year := NULL ;
          l_app_choice_id := NULL;
          curr_inst_rec := NULL;
          old_starc_9_rec := NULL;

          -- log Application Choice processing message.
          fnd_message.set_name('IGS','IGS_UC_APPNO_CHOICE_PROC');
          fnd_message.set_token('APPNO', TO_CHAR(new_ivstarc_rec.appno));
          fnd_message.set_token('CHOICE',TO_CHAR(new_ivstarc_rec.choiceno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- no mandatory field validations as this is an update
          IF new_ivstarc_rec.appno IS NULL OR new_ivstarc_rec.choiceno  IS NULL OR
             new_ivstarc_rec.ucas_cycle IS NULL OR new_ivstarc_rec.inst IS NULL OR
             new_ivstarc_rec.Course IS NULL OR new_ivstarc_rec.campus   IS NULL OR
             new_ivstarc_rec.lastchange IS NULL THEN

             g_error_code := '1037';
          END IF;

          -- AppNo validation
          IF g_error_code IS NULL THEN

             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivstarc_rec.appno, g_error_code);
          END IF;


          ----------------------------
          -- INSTITUTION validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate specialneeds
             OPEN validate_Institution (new_ivstarc_rec.inst);
             FETCH validate_Institution INTO l_valid;

             IF validate_Institution%NOTFOUND THEN
                g_error_code := '1018';
             END IF;

             CLOSE validate_Institution;
          END IF;
          --- end of Institution validation




          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN
             ------------------------------------------------
             -- Get the System Code and Application ID for the Application
             ------------------------------------------------
             -- get the App ID and System code for this Application.
             OPEN  get_appl_dets(new_ivstarc_rec.appno);
             FETCH get_appl_dets INTO get_appl_dets_rec;
             CLOSE get_appl_dets;


             ------------------------------------------------
             -- Point of Entry Derivation/defaulting
             ------------------------------------------------
             -- Derive Point of Entry. - validate that only Number values are passed to igs_uc_app_choices.point_of_entry field.
             -- For any other values the entry point should be defaulted to 1.
             IF (ASCII(new_ivstarc_rec.entrypoint) >= 48 AND ASCII(new_ivstarc_rec.entrypoint) <= 57) OR new_ivstarc_rec.entrypoint IS NULL THEN
                new_ivstarc_rec.entrypoint := TO_NUMBER(new_ivstarc_rec.entrypoint);  --
             ELSE
                new_ivstarc_rec.entrypoint := 1;  -- default value.
             END IF;

             ------------------------------------------------
             -- Deferred value derivation/defaulting
             ------------------------------------------------
             -- get entry year from ucas control table.
             OPEN  get_control_entry_year(get_appl_dets_rec.system_code, new_ivstarc_rec.ucas_cycle);
             FETCH get_control_entry_year INTO l_entry_year ;
             CLOSE get_control_entry_year;

             -- DEFERRED value derivation
             -- If ivstarc.entry_year > igs_uc_ucas_control.entry_year then deferred='Y' else 'N'.
             IF new_ivstarc_rec.entryyear > l_entry_year THEN
                l_deferred := 'Y' ;
             ELSE
                l_deferred := 'N' ;
             END IF ;

             ------------------------------------------------
             -- Entry Year derivation/defaulting.
             ------------------------------------------------
             --If entry year is NULL provide the default value for this field
             IF new_ivstarc_rec.entryyear IS NOT NULL THEN
                l_entry_year := new_ivstarc_rec.entryyear;
             END IF ;


             ------------------------------------------------
             -- Entry Month derivation/defaulting
             ------------------------------------------------
             IF new_ivstarc_rec.entrymonth IS NOT NULL THEN

                -- Incoming record has Entry Month value then this has to be populated.
                l_entrymonth := new_ivstarc_rec.entrymonth ;

             ELSE  -- default this value as per the system to which the Application belongs.
                IF get_appl_dets_rec.system_code = 'S' THEN
                   -- for SWAS, the default is 9
                   l_entrymonth :=  9;
                ELSE
                   -- for all other systems, the default is 0
                   l_entrymonth :=  0;
                END IF ;

             END IF ;


             ------------------------------------------------
             -- Decision Date value derivation/defaulting
             ------------------------------------------------
             IF new_ivstarc_rec.decision IS NULL THEN
                -- no decision therefore decision date has to be NULL.
                new_ivstarc_rec.decisiondate := NULL;
             ELSE
                new_ivstarc_rec.decisiondate := NVL(new_ivstarc_rec.decisiondate,TRUNC(SYSDATE));
             END IF;


             -- Check wether the Application record already exists.
             -- If exists , update the records otherwise insert a new record.
             OPEN  old_starc_cur(new_ivstarc_rec.appno, new_ivstarc_rec.choiceno, new_ivstarc_rec.ucas_cycle);
             FETCH old_starc_cur INTO old_starc_rec;
             CLOSE old_starc_cur;

             IF old_starc_rec.rowid IS NULL THEN

                ------------------------------------------------
                -- get OSS Program details
                ------------------------------------------------
                OPEN get_oss_prog_cur (new_ivstarc_rec.course,  new_ivstarc_rec.campus,
                                       new_ivstarc_rec.inst, get_appl_dets_rec.system_code);
                FETCH get_oss_prog_cur INTO oss_prog_rec;

                IF new_ivstarc_rec.inst = g_crnt_institute AND get_oss_prog_cur%NOTFOUND THEN
                    g_error_code := '1045';  -- UCAS Course not found
                END IF;
                CLOSE get_oss_prog_cur;

                -- Added code to check before inserting records to IGS_UC_APP_CHOICES whether there exists record with
                -- same institution code and system code but having choice number as 99.If there exists no records, then insert is performed. arvsrini bug# 3239860

                   OPEN  curr_inst_cur(get_appl_dets_rec.system_code);
                   FETCH curr_inst_cur INTO curr_inst_rec;
                   CLOSE curr_inst_cur;


                  IF curr_inst_rec.current_inst_code = new_ivstarc_rec.inst THEN  -- checking of system code (G or S)not required as choice no 99
                                                                                        -- can exist only for GTTR and SWAS systems
                        -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
                        OPEN  old_starc_cur(new_ivstarc_rec.appno, 9, new_ivstarc_rec.ucas_cycle);
                        FETCH old_starc_cur INTO old_starc_9_rec;
                        CLOSE old_starc_cur;


                  END IF;


                  IF old_starc_9_rec.rowid IS NULL THEN -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES


                   IF g_error_code IS NULL THEN

                   BEGIN

                      -- call the TBH to Insert new record
                     igs_uc_app_choices_pkg.insert_row -- IGSXI02B.pls
                     (
                      x_rowid                            => old_starc_rec.rowid
                     ,x_app_choice_id                    => l_app_choice_id
                     ,x_app_id                           => get_appl_dets_rec.app_id
                     ,x_app_no                           => new_ivstarc_rec.appno
                     ,x_choice_no                        => new_ivstarc_rec.choiceno
                     ,x_last_change                      => new_ivstarc_rec.lastchange
                     ,x_institute_code                   => new_ivstarc_rec.inst
                     ,x_ucas_program_code                => new_ivstarc_rec.course
                     ,x_oss_program_code                 => oss_prog_rec.oss_program_code
                     ,x_oss_program_version              => oss_prog_rec.oss_program_version
                     ,x_oss_attendance_type              => oss_prog_rec.oss_attendance_type
                     ,x_oss_attendance_mode              => oss_prog_rec.oss_attendance_mode
                     ,x_campus                           => new_ivstarc_rec.campus
                     ,x_oss_location                     => oss_prog_rec.oss_location
                     ,x_faculty                          => new_ivstarc_rec.faculty
                     ,x_entry_year                       => l_entry_year
                     ,x_entry_month                      => l_entrymonth
                     ,x_point_of_entry                   => new_ivstarc_rec.entrypoint
                     ,x_home                             => NVL(new_ivstarc_rec.home,'N')
                     ,x_deferred                         => l_deferred
                     ,x_route_b_pref_round               => new_ivstarc_rec.routebpref
                     ,x_route_b_actual_round             => new_ivstarc_rec.routebround
                     ,x_condition_category               => NULL
                     ,x_condition_code                   => NULL
                     ,x_decision                         => new_ivstarc_rec.decision
                     ,x_decision_date                    => new_ivstarc_rec.decisiondate
                     ,x_decision_number                  => new_ivstarc_rec.decisionnumber
                     ,x_reply                            => new_ivstarc_rec.reply
                     ,x_summary_of_cond                  => new_ivstarc_rec.summaryconditions
                     ,x_choice_cancelled                 => new_ivstarc_rec.choicecancelled
                     ,x_action                           => new_ivstarc_rec.action
                     ,x_substitution                     => new_ivstarc_rec.substitution
                     ,x_date_substituted                 => new_ivstarc_rec.datesubstituted
                     ,x_prev_institution                 => new_ivstarc_rec.previousinst
                     ,x_prev_course                      => new_ivstarc_rec.previouscourse
                     ,x_prev_campus                      => new_ivstarc_rec.previouscampus
                     ,x_ucas_amendment                   => new_ivstarc_rec.ucasamendment
                     ,x_withdrawal_reason                => NULL
                     ,x_offer_course                     => NULL
                     ,x_offer_campus                     => NULL
                     ,x_offer_crse_length                => NULL
                     ,x_offer_entry_month                => NULL
                     ,x_offer_entry_year                 => NULL
                     ,x_offer_entry_point                => NULL
                     ,x_offer_text                       => NULL
                     ,x_mode                             => 'R'
                     ,x_export_to_oss_status             => 'NEW'
                     ,x_error_code                       => NULL
                     ,x_request_id                       => NULL
                     ,x_batch_id                         => NULL
                     ,x_extra_round_nbr                  => new_ivstarc_rec.extraround
                     ,x_system_code                      => get_appl_dets_rec.system_code
                     ,x_part_time                        => NULL
                     ,x_interview                        => NULL
                     ,x_late_application                 => NULL
                     ,x_modular                          => NULL
                     ,x_residential                      => new_ivstarc_rec.residential
                     ,x_ucas_cycle                       => new_ivstarc_rec.ucas_cycle
                     );

                   EXCEPTION
                      WHEN OTHERS THEN

                        g_error_code := '9999';
                        fnd_file.put_line(fnd_file.log, SQLERRM);
                   END;

                  END IF;  --error code

            ELSE

                /* Updating the 9 choice record */

                -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
                IF new_ivstarc_rec.choiceno = 5 OR new_ivstarc_rec.choiceno = 7 THEN


                   -- For an Application Choice if the UCAS Course details are modified at UCAS end,
                   -- then the OSS program details for such an application needs to be derived again
                   -- based on the new/updated UCAS Course. Otherwise, if the UCAS Course details
                   -- remain the same, then the existing OSS Program details for this record are retained.


                   -- Checking whether the UCAS Program details have been modified at UCAS End.
                   IF new_ivstarc_rec.course <> old_starc_9_rec.ucas_program_code OR
                      new_ivstarc_rec.campus <> old_starc_9_rec.campus            OR
                      new_ivstarc_rec.inst   <> old_starc_9_rec.institute_code  THEN

                      -- Deriving the OSS Program details for the new/updated UCAS Course.
                      OPEN get_oss_prog_cur (new_ivstarc_rec.course,  new_ivstarc_rec.campus,
                                             new_ivstarc_rec.inst,    old_starc_9_rec.system_code);
                      FETCH get_oss_prog_cur INTO oss_prog_rec;

                      IF  new_ivstarc_rec.inst = g_crnt_institute AND get_oss_prog_cur%NOTFOUND THEN
                          g_error_code := '1045';  -- UCAS Course not found

                      END IF;
                      CLOSE get_oss_prog_cur;

                   ELSE
                      -- i.e. If UCAS Course details have not changed.
                      -- Retain the existing OSS Program details for this record in App Choices table.

                      -- copying existing values for the record to the program record variable.
                      oss_prog_rec.oss_program_code     :=  old_starc_9_rec.oss_program_code    ;
                      oss_prog_rec.oss_program_version  :=  old_starc_9_rec.oss_program_version ;
                      oss_prog_rec.oss_attendance_type  :=  old_starc_9_rec.oss_attendance_type ;
                      oss_prog_rec.oss_attendance_mode  :=  old_starc_9_rec.oss_attendance_mode ;
                      oss_prog_rec.oss_location         :=  old_starc_9_rec.oss_location        ;

                   END IF;

                                                   --the record is to be updated using choice number as IGS_UC_ISTARC_INTS.CHOICENO. Also if there exists records
                                                   --in IGS_UC_TRANSACTIONS with choice_no = 99 then those records are also updated. Bug#3239860


                       BEGIN

                          -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
                          FOR uc_transaction_rec IN uc_transaction_9_cur(new_ivstarc_rec.appno)
                            LOOP
                             igs_uc_transactions_pkg.update_row
                              (
                                    x_rowid                   => uc_transaction_rec.rowid,
                                    x_uc_tran_id              => uc_transaction_rec.uc_tran_id,
                                    x_transaction_id          => uc_transaction_rec.transaction_id,
                                    x_datetimestamp           => uc_transaction_rec.datetimestamp,
                                    x_updater                 => uc_transaction_rec.updater,
                                    x_error_code              => uc_transaction_rec.error_code,
                                    x_transaction_type        => uc_transaction_rec.transaction_type,
                                    x_app_no                  => uc_transaction_rec.app_no,
                                    x_choice_no               => new_ivstarc_rec.choiceno,
                                    x_decision                => uc_transaction_rec.decision,
                                    x_program_code            => uc_transaction_rec.program_code,
                                    x_campus                  => uc_transaction_rec.campus,
                                    x_entry_month             => uc_transaction_rec.entry_month,
                                    x_entry_year              => uc_transaction_rec.entry_year,
                                    x_entry_point             => uc_transaction_rec.entry_point,
                                    x_soc                     => uc_transaction_rec.soc,
                                    x_comments_in_offer       => uc_transaction_rec.comments_in_offer,
                                    x_return1                 => uc_transaction_rec.return1,
                                    x_return2                 => uc_transaction_rec.return2,
                                    x_hold_flag               => uc_transaction_rec.hold_flag,
                                    x_sent_to_ucas            => uc_transaction_rec.sent_to_ucas,
                                    x_test_cond_cat           => uc_transaction_rec.test_cond_cat,
                                    x_test_cond_name          => uc_transaction_rec.test_cond_name,
                                    x_mode                    => 'R',
                                    x_inst_reference          => uc_transaction_rec.inst_reference,
                                    x_auto_generated_flag     => uc_transaction_rec.auto_generated_flag,
                                    x_system_code             => uc_transaction_rec.system_code,
                                    x_ucas_cycle              => uc_transaction_rec.ucas_cycle,
                                    x_modular                 => uc_transaction_rec.modular,
                                    x_part_time               => uc_transaction_rec.part_time

                              );

                              END LOOP;

                        EXCEPTION
                          WHEN OTHERS THEN
                            g_error_code := '9998';
                            fnd_file.put_line(fnd_file.log, SQLERRM);
                        END;


                 -- calling the update tbh

                    IF g_error_code IS NULL THEN

                      BEGIN
                         -- call the TBH to update the record
                         igs_uc_app_choices_pkg.update_row -- IGSXI02B.pls
                          (
                           x_rowid                      => old_starc_9_rec.rowid
                          ,x_app_choice_id              => old_starc_9_rec.app_choice_id
                          ,x_app_id                     => old_starc_9_rec.app_id
                          ,x_app_no                     => old_starc_9_rec.app_no
                          ,x_choice_no                  => new_ivstarc_rec.choiceno
                          ,x_last_change                => new_ivstarc_rec.lastchange
                          ,x_institute_code             => new_ivstarc_rec.inst
                          ,x_ucas_program_code          => new_ivstarc_rec.course
                          ,x_oss_program_code           => oss_prog_rec.oss_program_code
                          ,x_oss_program_version        => oss_prog_rec.oss_program_version
                          ,x_oss_attendance_type        => oss_prog_rec.oss_attendance_type
                          ,x_oss_attendance_mode        => oss_prog_rec.oss_attendance_mode
                          ,x_campus                     => new_ivstarc_rec.campus
                          ,x_oss_location               => oss_prog_rec.oss_location
                          ,x_faculty                    => new_ivstarc_rec.faculty
                          ,x_entry_year                 => l_entry_year
                          ,x_entry_month                => l_entrymonth
                          ,x_point_of_entry             => new_ivstarc_rec.entrypoint
                          ,x_home                       => NVL(new_ivstarc_rec.home,'N')
                          ,x_deferred                   => l_deferred
                          ,x_route_b_pref_round         => new_ivstarc_rec.routebpref
                          ,x_route_b_actual_round       => new_ivstarc_rec.routebround
                          ,x_condition_category         => old_starc_9_rec.condition_category
                          ,x_condition_code             => old_starc_9_rec.condition_code
                          ,x_decision                   => new_ivstarc_rec.decision
                          ,x_decision_date              => new_ivstarc_rec.decisiondate
                          ,x_decision_number            => new_ivstarc_rec.decisionnumber
                          ,x_reply                      => new_ivstarc_rec.reply
                          ,x_summary_of_cond            => new_ivstarc_rec.summaryconditions
                          ,x_choice_cancelled           => new_ivstarc_rec.choicecancelled
                          ,x_action                     => new_ivstarc_rec.action
                          ,x_substitution               => new_ivstarc_rec.substitution
                          ,x_date_substituted           => new_ivstarc_rec.datesubstituted
                          ,x_prev_institution           => new_ivstarc_rec.previousinst
                          ,x_prev_course                => new_ivstarc_rec.previouscourse
                          ,x_prev_campus                => new_ivstarc_rec.previouscampus
                          ,x_ucas_amendment             => new_ivstarc_rec.ucasamendment
                          ,x_withdrawal_reason          => old_starc_9_rec.withdrawal_reason
                          ,x_offer_course               => old_starc_9_rec.offer_course
                          ,x_offer_campus               => old_starc_9_rec.offer_campus
                          ,x_offer_crse_length          => old_starc_9_rec.offer_crse_length
                          ,x_offer_entry_month          => old_starc_9_rec.offer_entry_month
                          ,x_offer_entry_year           => old_starc_9_rec.offer_entry_year
                          ,x_offer_entry_point          => old_starc_9_rec.offer_entry_point
                          ,x_offer_text                 => old_starc_9_rec.offer_text
                          ,x_mode                       => 'R'
                          ,x_export_to_oss_status       => 'NEW'
                          ,x_error_code                 => NULL
                          ,x_request_id                 => NULL
                          ,x_batch_id                   => NULL
                          ,x_extra_round_nbr            => new_ivstarc_rec.extraround
                          ,x_system_code                => get_appl_dets_rec.system_code -- update with current system_code in igs_uc_applicants -Bug#3838781
                          ,x_part_time                  => old_starc_9_rec.part_time
                          ,x_interview                  => old_starc_9_rec.interview
                          ,x_late_application           => old_starc_9_rec.late_application
                          ,x_modular                    => old_starc_9_rec.modular
                          ,x_residential                => new_ivstarc_rec.residential
                          ,x_ucas_cycle                 => new_ivstarc_rec.ucas_cycle
                          );

                       EXCEPTION
                          WHEN OTHERS THEN
                            g_error_code := '9998';
                            fnd_file.put_line(fnd_file.log, SQLERRM);
                       END;

                    END IF;  -- error code for Update row

                  END IF;  -- 9 rowid

              END IF;  -- choiceno 5 or 7

           ELSE        --old_starc_rec.rowid IS NOT NULL


             /* Update the record */


               -- For an Application Choice if the UCAS Course details are modified at UCAS end,
               -- then the OSS program details for such an application needs to be derived again
               -- based on the new/updated UCAS Course. Otherwise, if the UCAS Course details
               -- remain the same, then the existing OSS Program details for this record are retained.


               -- Checking whether the UCAS Program details have been modified at UCAS End.
               IF new_ivstarc_rec.course <> old_starc_rec.ucas_program_code OR
                  new_ivstarc_rec.campus <> old_starc_rec.campus            OR
                  new_ivstarc_rec.inst   <> old_starc_rec.institute_code  THEN

                  -- Deriving the OSS Program details for the new/updated UCAS Course.
                  OPEN get_oss_prog_cur (new_ivstarc_rec.course,  new_ivstarc_rec.campus,
                                         new_ivstarc_rec.inst,    old_starc_rec.system_code);
                  FETCH get_oss_prog_cur INTO oss_prog_rec;

                  IF  new_ivstarc_rec.inst = g_crnt_institute AND get_oss_prog_cur%NOTFOUND THEN
                      g_error_code := '1045';  -- UCAS Course not found

                  END IF;
                  CLOSE get_oss_prog_cur;

               ELSE
                  -- i.e. If UCAS Course details have not changed.
                  -- Retain the existing OSS Program details for this record in App Choices table.

                  -- copying existing values for the record to the program record variable.
                  oss_prog_rec.oss_program_code     :=  old_starc_rec.oss_program_code    ;
                  oss_prog_rec.oss_program_version  :=  old_starc_rec.oss_program_version ;
                  oss_prog_rec.oss_attendance_type  :=  old_starc_rec.oss_attendance_type ;
                  oss_prog_rec.oss_attendance_mode  :=  old_starc_rec.oss_attendance_mode ;
                  oss_prog_rec.oss_location         :=  old_starc_rec.oss_location        ;

               END IF;


               IF g_error_code IS NULL THEN

                  BEGIN
                     -- call the TBH to update the record
                     igs_uc_app_choices_pkg.update_row -- IGSXI02B.pls
                      (
                       x_rowid                      => old_starc_rec.rowid
                      ,x_app_choice_id              => old_starc_rec.app_choice_id
                      ,x_app_id                     => old_starc_rec.app_id
                      ,x_app_no                     => old_starc_rec.app_no
                      ,x_choice_no                  => old_starc_rec.choice_no
                      ,x_last_change                => new_ivstarc_rec.lastchange
                      ,x_institute_code             => new_ivstarc_rec.inst
                      ,x_ucas_program_code          => new_ivstarc_rec.course
                      ,x_oss_program_code           => oss_prog_rec.oss_program_code
                      ,x_oss_program_version        => oss_prog_rec.oss_program_version
                      ,x_oss_attendance_type        => oss_prog_rec.oss_attendance_type
                      ,x_oss_attendance_mode        => oss_prog_rec.oss_attendance_mode
                      ,x_campus                     => new_ivstarc_rec.campus
                      ,x_oss_location               => oss_prog_rec.oss_location
                      ,x_faculty                    => new_ivstarc_rec.faculty
                      ,x_entry_year                 => l_entry_year
                      ,x_entry_month                => l_entrymonth
                      ,x_point_of_entry             => new_ivstarc_rec.entrypoint
                      ,x_home                       => NVL(new_ivstarc_rec.home,'N')
                      ,x_deferred                   => l_deferred
                      ,x_route_b_pref_round         => new_ivstarc_rec.routebpref
                      ,x_route_b_actual_round       => new_ivstarc_rec.routebround
                      ,x_condition_category         => old_starc_rec.condition_category
                      ,x_condition_code             => old_starc_rec.condition_code
                      ,x_decision                   => new_ivstarc_rec.decision
                      ,x_decision_date              => new_ivstarc_rec.decisiondate
                      ,x_decision_number            => new_ivstarc_rec.decisionnumber
                      ,x_reply                      => new_ivstarc_rec.reply
                      ,x_summary_of_cond            => new_ivstarc_rec.summaryconditions
                      ,x_choice_cancelled           => new_ivstarc_rec.choicecancelled
                      ,x_action                     => new_ivstarc_rec.action
                      ,x_substitution               => new_ivstarc_rec.substitution
                      ,x_date_substituted           => new_ivstarc_rec.datesubstituted
                      ,x_prev_institution           => new_ivstarc_rec.previousinst
                      ,x_prev_course                => new_ivstarc_rec.previouscourse
                      ,x_prev_campus                => new_ivstarc_rec.previouscampus
                      ,x_ucas_amendment             => new_ivstarc_rec.ucasamendment
                      ,x_withdrawal_reason          => old_starc_rec.withdrawal_reason
                      ,x_offer_course               => old_starc_rec.offer_course
                      ,x_offer_campus               => old_starc_rec.offer_campus
                      ,x_offer_crse_length          => old_starc_rec.offer_crse_length
                      ,x_offer_entry_month          => old_starc_rec.offer_entry_month
                      ,x_offer_entry_year           => old_starc_rec.offer_entry_year
                      ,x_offer_entry_point          => old_starc_rec.offer_entry_point
                      ,x_offer_text                 => old_starc_rec.offer_text
                      ,x_mode                       => 'R'
                      ,x_export_to_oss_status       => 'NEW'
                      ,x_error_code                 => NULL
                      ,x_request_id                 => NULL
                      ,x_batch_id                   => NULL
                      ,x_extra_round_nbr            => new_ivstarc_rec.extraround
                      ,x_system_code                => get_appl_dets_rec.system_code -- update with current system_code in igs_uc_applicants -Bug#3838781
                      ,x_part_time                  => old_starc_rec.part_time
                      ,x_interview                  => old_starc_rec.interview
                      ,x_late_application           => old_starc_rec.late_application
                      ,x_modular                    => old_starc_rec.modular
                      ,x_residential                => new_ivstarc_rec.residential
                      ,x_ucas_cycle                 => new_ivstarc_rec.ucas_cycle
                      );

                   EXCEPTION
                      WHEN OTHERS THEN
                        g_error_code := '9998';
                        fnd_file.put_line(fnd_file.log, SQLERRM);
                   END;

                END IF;  -- error code for Update row

             END IF; -- insert / update  (starc rowid check)

       END IF; -- main processing

        EXCEPTION
           WHEN OTHERS THEN
              -- Close any Open cursors
              IF get_oss_prog_cur%ISOPEN THEN
                 CLOSE get_oss_prog_cur;
              END IF;

              IF old_starc_cur%ISOPEN THEN
                 CLOSE old_starc_cur;
              END IF;

              IF get_control_entry_year%ISOPEN THEN
                 CLOSE get_control_entry_year;
              END IF;

              IF get_appl_dets%ISOPEN THEN
                 CLOSE get_appl_dets;
              END IF;

              IF validate_Institution%ISOPEN THEN
                 CLOSE validate_Institution;
              END IF;

              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.
              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);



        END;

          -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
          -- while processing the record.
          IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_istarc_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivstarc_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

          ELSE

             UPDATE igs_uc_istarc_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivstarc_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
          END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTARC', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTARC'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstarc;



  PROCEDURE process_ivstarg  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing IVSTARG (Applicant Choices for GTTR)
                         info. details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     arvsrini  08-MAR-04  Added code to check before inserting records to IGS_UC_APP_CHOICES whether there exists record with
                          same institution code and system code but having choice number as 99.If there exists no records, then insert is performed
                          If it exists, the record is updated using choice number as IGS_UC_ISTARC_INTS.ROUNDNO. Also if there exists records
                          in IGS_UC_TRANSACTIONS with choice_no = 99 then those records are also updated.Bug#3239860
    ******************************************************************/

     CURSOR new_ivstarg_cur IS
     SELECT ivstk.rowid,
            ivstk.*
     FROM   igs_uc_istarg_ints ivstk
     WHERE  record_status = 'N';


     CURSOR old_starg_cur (p_appno igs_uc_app_choices.app_no%TYPE,
                           p_choiceno igs_uc_app_choices.choice_no%TYPE,
                           p_cycle igs_uc_app_choices.ucas_cycle%TYPE) IS
     SELECT appl.rowid,
            appl.*
     FROM   igs_uc_app_choices appl
     WHERE  appl.app_no = p_appno
     AND    appl.choice_no = p_choiceno
     AND    appl.ucas_cycle = p_cycle;

     -- get the system and app_id to be populated into App Choices
     CURSOR get_appl_dets (p_appno igs_uc_applicants.app_no%TYPE) IS
     SELECT ucap.rowid,
            ucap.*
     FROM   igs_uc_applicants ucap
     WHERE  app_no = p_appno;


     -- validate institution value
     CURSOR validate_Institution (p_inst igs_uc_com_inst.inst%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_com_inst
     WHERE  inst  = p_inst;

     -- get entry year from UCAS Control.
     CURSOR get_control_entry_year (p_system igs_uc_applicants.system_code%TYPE, p_cycle igs_uc_istarg_ints.ucas_cycle%TYPE) IS
     SELECT entry_year
     FROM igs_uc_ucas_control
     WHERE system_code = p_system
     AND   ucas_cycle  = p_cycle;

     -- Cursor to get the OSS Program details for the UCAS course from Course details table.
     CURSOR get_oss_prog_cur (p_course igs_uc_crse_dets.ucas_program_code%TYPE,
                              p_campus igs_uc_crse_dets.ucas_campus%TYPE,
                              p_inst   igs_uc_crse_dets.institute%TYPE,
                              p_system igs_uc_crse_dets.system_code%TYPE) IS
     SELECT oss_program_code,
            oss_program_version,
            oss_location,
            oss_attendance_mode,
            oss_attendance_type
     FROM   igs_uc_crse_dets
     WHERE  System_Code       = p_system
     AND    ucas_program_code = p_course
     AND    ucas_campus       = p_campus
     AND    Institute         = p_inst;

     CURSOR curr_inst_cur(p_sys_code igs_uc_defaults.system_code%type) IS
     SELECT current_inst_code
     FROM   igs_uc_defaults
     WHERE  system_code = p_sys_code;

     CURSOR uc_transaction_cur(p_app_no igs_uc_transactions.app_no%TYPE) IS
     SELECT trans.rowid,
            trans.*
     FROM   igs_uc_transactions trans
     WHERE  trans.app_no = p_app_no
     AND    trans.choice_no = 99;


     oss_prog_rec   get_oss_prog_cur%ROWTYPE;  -- Holds OSS Program details for the UCAS Course.
     old_starg_rec old_starg_cur%ROWTYPE ;     -- Holds the existing values for this incoming record.
     get_appl_dets_rec get_appl_dets%ROWTYPE;  -- Holds the Application details from UC_Applicants
     curr_inst_rec curr_inst_cur%ROWTYPE;
     old_starg_99_rec old_starg_cur%ROWTYPE;   -- arvsrini uccr008

     l_entry_year  igs_uc_ucas_control.entry_year%TYPE;
     l_deferred    igs_uc_app_choices.deferred%TYPE;
     l_entrymonth  igs_uc_app_choices.entry_month%TYPE;
     l_app_choice_id igs_uc_app_choices.app_choice_id%TYPE; -- Place holder for App CHoice ID - Seq gen value.
     l_valid  VARCHAR2(1); -- for holding fetch from cursors for rec exists check.

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTARG ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstarg_rec IN new_ivstarg_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          g_error_code      := NULL;
          old_starg_rec     := NULL;
          oss_prog_rec      := NULL;
          l_entry_year      := NULL ;
          l_valid           := NULL;
          get_appl_dets_rec := NULL;
          l_app_choice_id   := NULL;
          curr_inst_rec := NULL;
          old_starg_99_rec := NULL;

          -- Issue a savepoint
          SAVEPOINT process_ivstarg;

          -- log Application Choice processing message.
          fnd_message.set_name('IGS','IGS_UC_APPNO_CHOICE_PROC');
          fnd_message.set_token('APPNO', TO_CHAR(new_ivstarg_rec.appno));
          fnd_message.set_token('CHOICE',TO_CHAR(new_ivstarg_rec.roundno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- no mandatory field validations as this is an update
          IF new_ivstarg_rec.appno      IS NULL OR
             new_ivstarg_rec.roundno    IS NULL OR
             new_ivstarg_rec.ucas_cycle IS NULL OR
             new_ivstarg_rec.inst       IS NULL OR
             new_ivstarg_rec.Course     IS NULL OR
             new_ivstarg_rec.campus     IS NULL OR
             new_ivstarg_rec.lastchange IS NULL THEN

                g_error_code := '1037';
          END IF;

          -- AppNo validation
          IF g_error_code IS NULL THEN

             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivstarg_rec.appno, g_error_code);
          END IF;


          ----------------------------
          -- INSTITUTION validation
          ----------------------------
          IF g_error_code IS NULL THEN

             -- validate specialneeds
             OPEN validate_Institution (new_ivstarg_rec.inst);
             FETCH validate_Institution INTO l_valid;

             IF validate_Institution%NOTFOUND THEN
                g_error_code := '1018';
             END IF;

             CLOSE validate_Institution;
          END IF;
          --- end of Institution validation



          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN
             ------------------------------------------------
             -- Get the System Code and Application ID for the Application
             ------------------------------------------------
             -- get the App ID and System code for this Application.
             -- record would always be found since the earlier check error code 1000 ensures this.
             OPEN  get_appl_dets(new_ivstarg_rec.appno);
             FETCH get_appl_dets INTO get_appl_dets_rec;
             CLOSE get_appl_dets;


             -- update Applicants record for some fields
             -- (gcse_eng, gcse_match, degree_subject, degree_status, degree_class, gcse_csi).
             BEGIN
                -- call the TBH to update the record
                igs_uc_applicants_pkg.update_row -- IGSXI01B.pls
                 (
                  x_rowid                        => get_appl_dets_rec.rowid
                 ,x_app_id                       => get_appl_dets_rec.app_id
                 ,x_app_no                       => get_appl_dets_rec.app_no
                 ,x_check_digit                  => get_appl_dets_rec.check_digit
                 ,x_personal_id                  => get_appl_dets_rec.personal_id
                 ,x_enquiry_no                   => get_appl_dets_rec.enquiry_no
                 ,x_oss_person_id                => get_appl_dets_rec.oss_person_id
                 ,x_application_source           => get_appl_dets_rec.application_source
                 ,x_name_change_date             => get_appl_dets_rec.name_change_date
                 ,x_student_support              => get_appl_dets_rec.student_support
                 ,x_address_area                 => get_appl_dets_rec.address_area
                 ,x_application_date             => get_appl_dets_rec.application_date
                 ,x_application_sent_date        => get_appl_dets_rec.application_sent_date
                 ,x_application_sent_run         => get_appl_dets_rec.application_sent_run
                 ,x_lea_code                     => NULL  -- obsoleted by UCAS
                 ,x_fee_payer_code               => get_appl_dets_rec.fee_payer_code
                 ,x_fee_text                     => get_appl_dets_rec.fee_text
                 ,x_domicile_apr                 => get_appl_dets_rec.domicile_apr
                 ,x_code_changed_date            => get_appl_dets_rec.code_changed_date
                 ,x_school                       => get_appl_dets_rec.school
                 ,x_withdrawn                    => get_appl_dets_rec.withdrawn
                 ,x_withdrawn_date               => get_appl_dets_rec.withdrawn_date
                 ,x_rel_to_clear_reason          => get_appl_dets_rec.rel_to_clear_reason
                 ,x_route_b                      => get_appl_dets_rec.route_b
                 ,x_exam_change_date             => get_appl_dets_rec.exam_change_date
                 ,x_a_levels                     => NULL  -- obsoleted by UCAS
                 ,x_as_levels                    => NULL  -- obsoleted by UCAS
                 ,x_highers                      => NULL  -- obsoleted by UCAS
                 ,x_csys                         => NULL  -- obsoleted by UCAS
                 ,x_winter                       => get_appl_dets_rec.winter
                 ,x_previous                     => get_appl_dets_rec.previous
                 ,x_gnvq                         => NULL  -- obsoleted by UCAS
                 ,x_btec                         => get_appl_dets_rec.btec
                 ,x_ilc                          => get_appl_dets_rec.ilc
                 ,x_ailc                         => get_appl_dets_rec.ailc
                 ,x_ib                           => get_appl_dets_rec.ib
                 ,x_manual                       => get_appl_dets_rec.manual
                 ,x_reg_num                      => get_appl_dets_rec.reg_num
                 ,x_oeq                          => get_appl_dets_rec.oeq
                 ,x_eas                          => get_appl_dets_rec.eas
                 ,x_roa                          => get_appl_dets_rec.roa
                 ,x_status                       => get_appl_dets_rec.status
                 ,x_firm_now                     => get_appl_dets_rec.firm_now
                 ,x_firm_reply                   => get_appl_dets_rec.firm_reply
                 ,x_insurance_reply              => get_appl_dets_rec.insurance_reply
                 ,x_conf_hist_firm_reply         => get_appl_dets_rec.conf_hist_firm_reply
                 ,x_conf_hist_ins_reply          => get_appl_dets_rec.conf_hist_ins_reply
                 ,x_residential_category         => get_appl_dets_rec.residential_category
                 ,x_personal_statement           => get_appl_dets_rec.personal_statement
                 ,x_match_prev                   => get_appl_dets_rec.match_prev
                 ,x_match_prev_date              => get_appl_dets_rec.match_prev_date
                 ,x_match_winter                 => get_appl_dets_rec.match_winter
                 ,x_match_summer                 => get_appl_dets_rec.match_summer
                 ,x_gnvq_date                    => get_appl_dets_rec.gnvq_date
                 ,x_ib_date                      => get_appl_dets_rec.ib_date
                 ,x_ilc_date                     => get_appl_dets_rec.ilc_date
                 ,x_ailc_date                    => get_appl_dets_rec.ailc_date
                 ,x_gcseqa_date                  => get_appl_dets_rec.gcseqa_date
                 ,x_uk_entry_date                => get_appl_dets_rec.uk_entry_date
                 ,x_prev_surname                 => get_appl_dets_rec.prev_surname
                 ,x_criminal_convictions         => get_appl_dets_rec.criminal_convictions
                 ,x_sent_to_hesa                 => 'N'
                 ,x_sent_to_oss                  => 'N'
                 ,x_batch_identifier             => get_appl_dets_rec.batch_identifier
                 ,x_mode                         => 'R'
                 ,x_GCE                          => get_appl_dets_rec.GCE
                 ,x_VCE                          => get_appl_dets_rec.VCE
                 ,x_SQA                          => get_appl_dets_rec.SQA
                 ,x_PREVIOUSAS                   => get_appl_dets_rec.previousas
                 ,x_KEYSKILLS                    => get_appl_dets_rec.keyskills
                 ,x_VOCATIONAL                   => get_appl_dets_rec.vocational
                 ,x_SCN                          => get_appl_dets_rec.SCN
                 ,x_PrevOEQ                      => get_appl_dets_rec.PrevOEQ
                 ,x_choices_transparent_ind      => get_appl_dets_rec.choices_transparent_ind
                 ,x_extra_status                 => get_appl_dets_rec.extra_status
                 ,x_extra_passport_no            => get_appl_dets_rec.extra_passport_no
                 ,x_request_app_dets_ind         => get_appl_dets_rec.request_app_dets_ind
                 ,x_request_copy_app_frm_ind     => get_appl_dets_rec.request_copy_app_frm_ind
                 ,x_cef_no                       => get_appl_dets_rec.cef_no
                 ,x_system_code                  => get_appl_dets_rec.system_code
                 ,x_gcse_eng                     => new_ivstarg_rec.gcseeng
                 ,x_gcse_math                    => new_ivstarg_rec.gcsemath
                 ,x_degree_subject               => new_ivstarg_rec.degreesubject
                 ,x_degree_status                => new_ivstarg_rec.degreestatus
                 ,x_degree_class                 => new_ivstarg_rec.degreeclass
                 ,x_gcse_sci                     => new_ivstarg_rec.gcsesci
                 ,x_welshspeaker                 => get_appl_dets_rec.welshspeaker
                 ,x_ni_number                    => get_appl_dets_rec.ni_number
                 ,x_earliest_start               => get_appl_dets_rec.earliest_start
                 ,x_near_inst                    => get_appl_dets_rec.near_inst
                 ,x_pref_reg                     => get_appl_dets_rec.pref_reg
                 ,x_qual_eng                     => get_appl_dets_rec.qual_eng
                 ,x_qual_math                    => get_appl_dets_rec.qual_math
                 ,x_qual_sci                     => get_appl_dets_rec.qual_sci
                 ,x_main_qual                    => get_appl_dets_rec.main_qual
                 ,x_qual_5                       => get_appl_dets_rec.qual_5
                 ,x_future_serv                  => get_appl_dets_rec.future_serv
                 ,x_future_set                   => get_appl_dets_rec.future_set
                 ,x_present_serv                 => get_appl_dets_rec.present_serv
                 ,x_present_set                  => get_appl_dets_rec.present_set
                 ,x_curr_employment              => get_appl_dets_rec.curr_employment
                 ,x_edu_qualification            => get_appl_dets_rec.edu_qualification
                 ,x_ad_batch_id                  => get_appl_dets_rec.ad_batch_id
                 ,x_ad_interface_id              => get_appl_dets_rec.ad_interface_id
                 ,x_nationality                  => get_appl_dets_rec.nationality
                 ,x_dual_nationality             => get_appl_dets_rec.dual_nationality
                 ,x_special_needs                => get_appl_dets_rec.special_needs
                 ,x_country_birth                => get_appl_dets_rec.country_birth
                 );

             EXCEPTION
                WHEN OTHERS THEN
                  g_error_code := '9998';
                  fnd_file.put_line(fnd_file.log, SQLERRM);
             END;

          END IF; -- error code


          -- Application Choice processing
          IF g_error_code IS NULL THEN
             ------------------------------------------------
             -- Deferred value derivation/defaulting
             ------------------------------------------------
             -- get entry year from ucas control table.
             OPEN  get_control_entry_year(get_appl_dets_rec.system_code, new_ivstarg_rec.ucas_cycle);
             FETCH get_control_entry_year INTO l_entry_year ;
             CLOSE get_control_entry_year;

             -- DEFERRED value derivation
             -- If ivstarc.entry_year > igs_uc_ucas_control.entry_year then deferred='Y' else 'N'.
             IF new_ivstarg_rec.entryyear > l_entry_year THEN
                l_deferred := 'Y' ;
             ELSE
                l_deferred := 'N' ;
             END IF ;


             -- Check wether the Application record already exists.
             -- If exists , update the records otherwise insert a new record.
             OPEN old_starg_cur(new_ivstarg_rec.appno, new_ivstarg_rec.roundno, new_ivstarg_rec.ucas_cycle);
             FETCH old_starg_cur INTO old_starg_rec;
             CLOSE old_starg_cur;

            IF old_starg_rec.rowid IS NULL THEN

                ------------------------------------------------
                -- get OSS Program details
                ------------------------------------------------
                OPEN get_oss_prog_cur (new_ivstarg_rec.course,  new_ivstarg_rec.campus,
                                       new_ivstarg_rec.inst, get_appl_dets_rec.system_code);
                FETCH get_oss_prog_cur INTO oss_prog_rec;

                IF  new_ivstarg_rec.inst = g_crnt_institute AND get_oss_prog_cur%NOTFOUND THEN
                    g_error_code := '1045';  -- UCAS Course not found

                END IF;
                CLOSE get_oss_prog_cur;


                --Added code to check before inserting records to IGS_UC_APP_CHOICES whether there exists record with
                --same institution code and system code but having choice number as 99.If there exists no records, then insert is performed

                   OPEN  curr_inst_cur(get_appl_dets_rec.system_code);
                   FETCH curr_inst_cur INTO curr_inst_rec;
                   CLOSE curr_inst_cur;


                   IF curr_inst_rec.current_inst_code = new_ivstarg_rec.inst THEN  -- checking of system code (G or S)not required as choice no 99
                                                                                        -- can exist only for GTTR and SWAS systems
                            OPEN  old_starg_cur(new_ivstarg_rec.appno, 99, new_ivstarg_rec.ucas_cycle);
                            FETCH old_starg_cur INTO old_starg_99_rec;
                            CLOSE old_starg_cur;

                   END IF;

                IF old_starg_99_rec.rowid IS NULL THEN


                 IF g_error_code IS NULL THEN

                   BEGIN
                      -- call the TBH to Insert new record
                      igs_uc_app_choices_pkg.insert_row -- IGSXI02B.pls
                      (
                       x_rowid                            => old_starg_rec.rowid
                      ,x_app_choice_id                    => l_app_choice_id
                      ,x_app_id                           => get_appl_dets_rec.app_id
                      ,x_app_no                           => new_ivstarg_rec.appno
                      ,x_choice_no                        => new_ivstarg_rec.roundno
                      ,x_last_change                      => new_ivstarg_rec.lastchange
                      ,x_institute_code                   => new_ivstarg_rec.inst
                      ,x_ucas_program_code                => new_ivstarg_rec.course
                      ,x_oss_program_code                 => oss_prog_rec.oss_program_code
                      ,x_oss_program_version              => oss_prog_rec.oss_program_version
                      ,x_oss_attendance_type              => oss_prog_rec.oss_attendance_type
                      ,x_oss_attendance_mode              => oss_prog_rec.oss_attendance_mode
                      ,x_campus                           => new_ivstarg_rec.campus
                      ,x_oss_location                     => oss_prog_rec.oss_location
                      ,x_faculty                          => NULL
                      ,x_entry_year                       => new_ivstarg_rec.entryyear
                      ,x_entry_month                      => NVL(new_ivstarg_rec.entrymonth,0)
                      ,x_point_of_entry                   => NULL
                      ,x_home                             => 'N'
                      ,x_deferred                         => l_deferred
                      ,x_route_b_pref_round               => NULL
                      ,x_route_b_actual_round             => NULL
                      ,x_condition_category               => NULL
                      ,x_condition_code                   => NULL
                      ,x_decision                         => new_ivstarg_rec.decision
                      ,x_decision_date                    => NULL
                      ,x_decision_number                  => NULL
                      ,x_reply                            => new_ivstarg_rec.reply
                      ,x_summary_of_cond                  => NULL
                      ,x_choice_cancelled                 => NULL
                      ,x_action                           => new_ivstarg_rec.action
                      ,x_substitution                     => NULL
                      ,x_date_substituted                 => NULL
                      ,x_prev_institution                 => NULL
                      ,x_prev_course                      => NULL
                      ,x_prev_campus                      => NULL
                      ,x_ucas_amendment                   => NULL
                      ,x_withdrawal_reason                => NULL
                      ,x_offer_course                     => NULL
                      ,x_offer_campus                     => NULL
                      ,x_offer_crse_length                => NULL
                      ,x_offer_entry_month                => NULL
                      ,x_offer_entry_year                 => NULL
                      ,x_offer_entry_point                => NULL
                      ,x_offer_text                       => NULL
                      ,x_mode                             => 'R'
                      ,x_export_to_oss_status             => 'NEW'
                      ,x_error_code                       => NULL
                      ,x_request_id                       => NULL
                      ,x_batch_id                         => NULL
                      ,x_extra_round_nbr                  => NULL
                      ,x_system_code                      => get_appl_dets_rec.system_code
                      ,x_part_time                        => new_ivstarg_rec.parttime
                      ,x_interview                        => new_ivstarg_rec.interview
                      ,x_late_application                 => new_ivstarg_rec.lateapplication
                      ,x_modular                          => new_ivstarg_rec.modular
                      ,x_residential                      => NULL
                      ,x_ucas_cycle                       => new_ivstarg_rec.ucas_cycle
                     );

                   EXCEPTION
                      WHEN OTHERS THEN

                        g_error_code := '9999';
                        fnd_file.put_line(fnd_file.log, SQLERRM);
                   END;

                  END IF; -- error code

                ELSE        --if 99 rowid is not null

                  /* Update the record */

                  ------------------------------------------------
                  -- For an Application Choice if the UCAS Course details are modified at UCAS end,
                  -- then the OSS program details for such an application needs to be derived again
                  -- based on the new/updated UCAS Course. Otherwise, if the UCAS Course details
                  -- remain the same, then the existing OSS Program details for this record are retained.
                  ------------------------------------------------

                  -- Checking whether the UCAS Program details have been modified at UCAS End.
                  IF new_ivstarg_rec.course <> old_starg_99_rec.ucas_program_code OR
                     new_ivstarg_rec.campus <> old_starg_99_rec.campus            OR
                     new_ivstarg_rec.inst   <> old_starg_99_rec.institute_code  THEN

                     -- Derive the OSS Program details for the new/updated UCAS Course.
                     OPEN get_oss_prog_cur (new_ivstarg_rec.course,  new_ivstarg_rec.campus,
                                            new_ivstarg_rec.inst,    old_starg_99_rec.system_code);
                     FETCH get_oss_prog_cur INTO oss_prog_rec;

                     IF  new_ivstarg_rec.inst = g_crnt_institute AND get_oss_prog_cur%NOTFOUND THEN
                         g_error_code := '1045';  -- UCAS Course not found

                     END IF;
                     CLOSE get_oss_prog_cur;

                  ELSE
                     -- i.e. If UCAS Course details have not changed.
                     -- Retain the existing OSS Program details for this record in App Choices table.

                     -- copying existing values for the record to the program record variable.
                     oss_prog_rec.oss_program_code     :=  old_starg_99_rec.oss_program_code    ;
                     oss_prog_rec.oss_program_version  :=  old_starg_99_rec.oss_program_version ;
                     oss_prog_rec.oss_attendance_type  :=  old_starg_99_rec.oss_attendance_type ;
                     oss_prog_rec.oss_attendance_mode  :=  old_starg_99_rec.oss_attendance_mode ;
                     oss_prog_rec.oss_location         :=  old_starg_99_rec.oss_location        ;

                  END IF;


                  --If it exists, the record is updated using choice number as IGS_UC_ISTARC_INTS.ROUNDNO. Also if there exists records
                  --in IGS_UC_TRANSACTIONS with choice_no = 99 then those records are also updated.Bug#3239860


                   BEGIN

                      FOR uc_transaction_rec IN uc_transaction_cur(new_ivstarg_rec.appno)
                        LOOP
                         igs_uc_transactions_pkg.update_row
                          (
                                x_rowid                   => uc_transaction_rec.rowid,
                                x_uc_tran_id              => uc_transaction_rec.uc_tran_id,
                                x_transaction_id          => uc_transaction_rec.transaction_id,
                                x_datetimestamp           => uc_transaction_rec.datetimestamp,
                                x_updater                 => uc_transaction_rec.updater,
                                x_error_code              => uc_transaction_rec.error_code,
                                x_transaction_type        => uc_transaction_rec.transaction_type,
                                x_app_no                  => uc_transaction_rec.app_no,
                                x_choice_no               => new_ivstarg_rec.roundno,
                                x_decision                => uc_transaction_rec.decision,
                                x_program_code            => uc_transaction_rec.program_code,
                                x_campus                  => uc_transaction_rec.campus,
                                x_entry_month             => uc_transaction_rec.entry_month,
                                x_entry_year              => uc_transaction_rec.entry_year,
                                x_entry_point             => uc_transaction_rec.entry_point,
                                x_soc                     => uc_transaction_rec.soc,
                                x_comments_in_offer       => uc_transaction_rec.comments_in_offer,
                                x_return1                 => uc_transaction_rec.return1,
                                x_return2                 => uc_transaction_rec.return2,
                                x_hold_flag               => uc_transaction_rec.hold_flag,
                                x_sent_to_ucas            => uc_transaction_rec.sent_to_ucas,
                                x_test_cond_cat           => uc_transaction_rec.test_cond_cat,
                                x_test_cond_name          => uc_transaction_rec.test_cond_name,
                                x_mode                    => 'R',
                                x_inst_reference          => uc_transaction_rec.inst_reference,
                                x_auto_generated_flag     => uc_transaction_rec.auto_generated_flag,
                                x_system_code             => uc_transaction_rec.system_code,
                                x_ucas_cycle              => uc_transaction_rec.ucas_cycle,
                                x_modular                 => uc_transaction_rec.modular,
                                x_part_time               => uc_transaction_rec.part_time
                          );

                          END LOOP;


                    EXCEPTION
                      WHEN OTHERS THEN
                        g_error_code := '9998';
                        fnd_file.put_line(fnd_file.log, SQLERRM);
                    END;


                     IF g_error_code IS NULL THEN

                      BEGIN
                        -- call the TBH to update the record
                        igs_uc_app_choices_pkg.update_row -- IGSXI02B.pls
                         (
                          x_rowid                      => old_starg_99_rec.rowid
                         ,x_app_choice_id              => old_starg_99_rec.app_choice_id
                         ,x_app_id                     => old_starg_99_rec.app_id
                         ,x_app_no                     => old_starg_99_rec.app_no
                         ,x_choice_no                  => new_ivstarg_rec.roundno
                         ,x_last_change                => new_ivstarg_rec.lastchange
                         ,x_institute_code             => new_ivstarg_rec.inst
                         ,x_ucas_program_code          => new_ivstarg_rec.course
                         ,x_oss_program_code           => oss_prog_rec.oss_program_code
                         ,x_oss_program_version        => oss_prog_rec.oss_program_version
                         ,x_oss_attendance_type        => oss_prog_rec.oss_attendance_type
                         ,x_oss_attendance_mode        => oss_prog_rec.oss_attendance_mode
                         ,x_campus                     => new_ivstarg_rec.campus
                         ,x_oss_location               => oss_prog_rec.oss_location
                         ,x_faculty                    => old_starg_99_rec.faculty
                         ,x_entry_year                 => NVL(new_ivstarg_rec.entryyear,0)
                         ,x_entry_month                => NVL(new_ivstarg_rec.entrymonth,0)
                         ,x_point_of_entry             => old_starg_99_rec.point_of_entry
                         ,x_home                       => old_starg_99_rec.home
                         ,x_deferred                   => l_deferred
                         ,x_route_b_pref_round         => old_starg_99_rec.route_b_pref_round
                         ,x_route_b_actual_round       => old_starg_99_rec.route_b_actual_round
                         ,x_condition_category         => old_starg_99_rec.condition_category
                         ,x_condition_code             => old_starg_99_rec.condition_code
                         ,x_decision                   => new_ivstarg_rec.decision
                         ,x_decision_date              => old_starg_99_rec.decision_date
                         ,x_decision_number            => old_starg_99_rec.decision_number
                         ,x_reply                      => new_ivstarg_rec.reply
                         ,x_summary_of_cond            => old_starg_99_rec.summary_of_cond
                         ,x_choice_cancelled           => old_starg_99_rec.choice_cancelled
                         ,x_action                     => new_ivstarg_rec.action
                         ,x_substitution               => old_starg_99_rec.substitution
                         ,x_date_substituted           => old_starg_99_rec.date_substituted
                         ,x_prev_institution           => old_starg_99_rec.prev_institution
                         ,x_prev_course                => old_starg_99_rec.prev_course
                         ,x_prev_campus                => old_starg_99_rec.prev_campus
                         ,x_ucas_amendment             => old_starg_99_rec.ucas_amendment
                         ,x_withdrawal_reason          => old_starg_99_rec.withdrawal_reason
                         ,x_offer_course               => old_starg_99_rec.offer_course
                         ,x_offer_campus               => old_starg_99_rec.offer_campus
                         ,x_offer_crse_length          => old_starg_99_rec.offer_crse_length
                         ,x_offer_entry_month          => old_starg_99_rec.offer_entry_month
                         ,x_offer_entry_year           => old_starg_99_rec.offer_entry_year
                         ,x_offer_entry_point          => old_starg_99_rec.offer_entry_point
                         ,x_offer_text                 => old_starg_99_rec.offer_text
                         ,x_mode                       => 'R'
                         ,x_export_to_oss_status       => 'NEW'
                         ,x_error_code                 => NULL
                         ,x_request_id                 => NULL
                         ,x_batch_id                   => NULL
                         ,x_extra_round_nbr            => old_starg_99_rec.extra_round_nbr
                         ,x_system_code                => old_starg_99_rec.system_code
                         ,x_part_time                  => new_ivstarg_rec.parttime
                         ,x_interview                  => new_ivstarg_rec.interview
                         ,x_late_application           => new_ivstarg_rec.lateapplication
                         ,x_modular                    => new_ivstarg_rec.modular
                         ,x_residential                => old_starg_99_rec.residential
                         ,x_ucas_cycle                 => old_starg_99_rec.ucas_cycle
                         );

                      EXCEPTION
                         WHEN OTHERS THEN
                           g_error_code := '9998';
                           fnd_file.put_line(fnd_file.log, SQLERRM);
                      END;
                     END IF; -- error code


                   END IF;-- old starg 99 row id check


                ELSE                --if old_starg_rec.rowid IS NOT NULL

               /* Update the record */

                  ------------------------------------------------
                  -- For an Application Choice if the UCAS Course details are modified at UCAS end,
                  -- then the OSS program details for such an application needs to be derived again
                  -- based on the new/updated UCAS Course. Otherwise, if the UCAS Course details
                  -- remain the same, then the existing OSS Program details for this record are retained.
                  ------------------------------------------------

                  -- Checking whether the UCAS Program details have been modified at UCAS End.
                  IF new_ivstarg_rec.course <> old_starg_rec.ucas_program_code OR
                     new_ivstarg_rec.campus <> old_starg_rec.campus            OR
                     new_ivstarg_rec.inst   <> old_starg_rec.institute_code  THEN

                     -- Derive the OSS Program details for the new/updated UCAS Course.
                     OPEN get_oss_prog_cur (new_ivstarg_rec.course,  new_ivstarg_rec.campus,
                                            new_ivstarg_rec.inst,    old_starg_rec.system_code);
                     FETCH get_oss_prog_cur INTO oss_prog_rec;

                     IF  new_ivstarg_rec.inst = g_crnt_institute AND get_oss_prog_cur%NOTFOUND THEN
                         g_error_code := '1045';  -- UCAS Course not found

                     END IF;
                     CLOSE get_oss_prog_cur;

                  ELSE
                     -- i.e. If UCAS Course details have not changed.
                     -- Retain the existing OSS Program details for this record in App Choices table.

                     -- copying existing values for the record to the program record variable.
                     oss_prog_rec.oss_program_code     :=  old_starg_rec.oss_program_code    ;
                     oss_prog_rec.oss_program_version  :=  old_starg_rec.oss_program_version ;
                     oss_prog_rec.oss_attendance_type  :=  old_starg_rec.oss_attendance_type ;
                     oss_prog_rec.oss_attendance_mode  :=  old_starg_rec.oss_attendance_mode ;
                     oss_prog_rec.oss_location         :=  old_starg_rec.oss_location        ;

                  END IF;


                  IF g_error_code IS NULL THEN

                     BEGIN
                        -- call the TBH to update the record
                        igs_uc_app_choices_pkg.update_row -- IGSXI02B.pls
                         (
                          x_rowid                      => old_starg_rec.rowid
                         ,x_app_choice_id              => old_starg_rec.app_choice_id
                         ,x_app_id                     => old_starg_rec.app_id
                         ,x_app_no                     => old_starg_rec.app_no
                         ,x_choice_no                  => old_starg_rec.choice_no
                         ,x_last_change                => new_ivstarg_rec.lastchange
                         ,x_institute_code             => new_ivstarg_rec.inst
                         ,x_ucas_program_code          => new_ivstarg_rec.course
                         ,x_oss_program_code           => oss_prog_rec.oss_program_code
                         ,x_oss_program_version        => oss_prog_rec.oss_program_version
                         ,x_oss_attendance_type        => oss_prog_rec.oss_attendance_type
                         ,x_oss_attendance_mode        => oss_prog_rec.oss_attendance_mode
                         ,x_campus                     => new_ivstarg_rec.campus
                         ,x_oss_location               => oss_prog_rec.oss_location
                         ,x_faculty                    => old_starg_rec.faculty
                         ,x_entry_year                 => NVL(new_ivstarg_rec.entryyear,0)
                         ,x_entry_month                => NVL(new_ivstarg_rec.entrymonth,0)
                         ,x_point_of_entry             => old_starg_rec.point_of_entry
                         ,x_home                       => old_starg_rec.home
                         ,x_deferred                   => l_deferred
                         ,x_route_b_pref_round         => old_starg_rec.route_b_pref_round
                         ,x_route_b_actual_round       => old_starg_rec.route_b_actual_round
                         ,x_condition_category         => old_starg_rec.condition_category
                         ,x_condition_code             => old_starg_rec.condition_code
                         ,x_decision                   => new_ivstarg_rec.decision
                         ,x_decision_date              => old_starg_rec.decision_date
                         ,x_decision_number            => old_starg_rec.decision_number
                         ,x_reply                      => new_ivstarg_rec.reply
                         ,x_summary_of_cond            => old_starg_rec.summary_of_cond
                         ,x_choice_cancelled           => old_starg_rec.choice_cancelled
                         ,x_action                     => new_ivstarg_rec.action
                         ,x_substitution               => old_starg_rec.substitution
                         ,x_date_substituted           => old_starg_rec.date_substituted
                         ,x_prev_institution           => old_starg_rec.prev_institution
                         ,x_prev_course                => old_starg_rec.prev_course
                         ,x_prev_campus                => old_starg_rec.prev_campus
                         ,x_ucas_amendment             => old_starg_rec.ucas_amendment
                         ,x_withdrawal_reason          => old_starg_rec.withdrawal_reason
                         ,x_offer_course               => old_starg_rec.offer_course
                         ,x_offer_campus               => old_starg_rec.offer_campus
                         ,x_offer_crse_length          => old_starg_rec.offer_crse_length
                         ,x_offer_entry_month          => old_starg_rec.offer_entry_month
                         ,x_offer_entry_year           => old_starg_rec.offer_entry_year
                         ,x_offer_entry_point          => old_starg_rec.offer_entry_point
                         ,x_offer_text                 => old_starg_rec.offer_text
                         ,x_mode                       => 'R'
                         ,x_export_to_oss_status       => 'NEW'
                         ,x_error_code                 => NULL
                         ,x_request_id                 => NULL
                         ,x_batch_id                   => NULL
                         ,x_extra_round_nbr            => old_starg_rec.extra_round_nbr
                         ,x_system_code                => old_starg_rec.system_code
                         ,x_part_time                  => new_ivstarg_rec.parttime
                         ,x_interview                  => new_ivstarg_rec.interview
                         ,x_late_application           => new_ivstarg_rec.lateapplication
                         ,x_modular                    => new_ivstarg_rec.modular
                         ,x_residential                => old_starg_rec.residential
                         ,x_ucas_cycle                 => old_starg_rec.ucas_cycle
                         );

                      EXCEPTION
                         WHEN OTHERS THEN
                           g_error_code := '9998';
                           fnd_file.put_line(fnd_file.log, SQLERRM);
                      END;
                    END IF; -- error code

              END IF; -- insert / update  (starg rowid check)

           END IF; -- main processing

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.
              ROLLBACK TO process_ivstarg;

              -- Close any Open cursors
              IF get_oss_prog_cur%ISOPEN THEN
                 CLOSE get_oss_prog_cur;
              END IF;


              IF old_starg_cur%ISOPEN THEN
                 CLOSE old_starg_cur;
              END IF;

              IF get_control_entry_year%ISOPEN THEN
                 CLOSE get_control_entry_year;
              END IF;

              IF get_appl_dets%ISOPEN THEN
                 CLOSE get_appl_dets;
              END IF;

              IF validate_Institution%ISOPEN THEN
                 CLOSE validate_Institution;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_istarg_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivstarg_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_istarg_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivstarg_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTARG', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK TO process_ivstarg;
    COMMIT;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTARG'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstarg;



  PROCEDURE process_ivstart  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing IVSTART info. details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ******************************************************************/

     CURSOR new_ivstart_cur IS
     SELECT ivstt.rowid,
            ivstt.*
     FROM   igs_uc_istart_ints ivstt
     WHERE  record_status = 'N';


     CURSOR old_start_cur(p_appno igs_uc_app_choices.app_no%TYPE) IS
     SELECT ucap.rowid,
            ucap.*
     FROM   igs_uc_applicants ucap
     WHERE  ucap.app_no = p_appno;

     old_start_rec old_start_cur%ROWTYPE;

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTART ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstart_rec IN new_ivstart_cur
    LOOP
      BEGIN
          -- initialize record level variables.
          g_error_code := NULL;
          old_start_rec := NULL;


          -- log Application processing message.
          fnd_message.set_name('IGS','IGS_UC_APPNO_PROC');
          fnd_message.set_token('APPL_NO', TO_CHAR(new_ivstart_rec.appno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- mandatory field validations
          IF new_ivstart_rec.appno IS NULL THEN
             g_error_code := '1037';
          END IF;


          ----------------------------
          -- AppNo validation
          ----------------------------
          IF g_error_code IS NULL THEN
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivstart_rec.appno, g_error_code);

          END IF;


          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN

             -- Corresponding Application record would exist at this point
             -- otherwise the earlier validaton for error 1000 would have failed.
             OPEN old_start_cur(new_ivstart_rec.appno);
             FETCH old_start_cur INTO old_start_rec;
             CLOSE old_start_cur;


             BEGIN
                -- call the TBH to update the record
                igs_uc_applicants_pkg.update_row -- IGSXI01B.pls
                 (
                  x_rowid                        => old_start_rec.rowid
                 ,x_app_id                       => old_start_rec.app_id
                 ,x_app_no                       => old_start_rec.app_no
                 ,x_check_digit                  => old_start_rec.check_digit
                 ,x_personal_id                  => old_start_rec.personal_id
                 ,x_enquiry_no                   => old_start_rec.enquiry_no
                 ,x_oss_person_id                => old_start_rec.oss_person_id
                 ,x_application_source           => old_start_rec.application_source
                 ,x_name_change_date             => old_start_rec.name_change_date
                 ,x_student_support              => old_start_rec.student_support
                 ,x_address_area                 => old_start_rec.address_area
                 ,x_application_date             => old_start_rec.application_date
                 ,x_application_sent_date        => old_start_rec.application_sent_date
                 ,x_application_sent_run         => old_start_rec.application_sent_run
                 ,x_lea_code                     => NULL  -- obsoleted by UCAS
                 ,x_fee_payer_code               => old_start_rec.fee_payer_code
                 ,x_fee_text                     => old_start_rec.fee_text
                 ,x_domicile_apr                 => old_start_rec.domicile_apr
                 ,x_code_changed_date            => old_start_rec.code_changed_date
                 ,x_school                       => old_start_rec.school
                 ,x_withdrawn                    => old_start_rec.withdrawn
                 ,x_withdrawn_date               => old_start_rec.withdrawn_date
                 ,x_rel_to_clear_reason          => old_start_rec.rel_to_clear_reason
                 ,x_route_b                      => old_start_rec.route_b
                 ,x_exam_change_date             => old_start_rec.exam_change_date
                 ,x_a_levels                     => NULL  -- obsoleted by UCAS
                 ,x_as_levels                    => NULL  -- obsoleted by UCAS
                 ,x_highers                      => NULL  -- obsoleted by UCAS
                 ,x_csys                         => NULL  -- obsoleted by UCAS
                 ,x_winter                       => old_start_rec.winter
                 ,x_previous                     => old_start_rec.previous
                 ,x_gnvq                         => NULL  -- obsoleted by UCAS
                 ,x_btec                         => old_start_rec.btec
                 ,x_ilc                          => old_start_rec.ilc
                 ,x_ailc                         => old_start_rec.ailc
                 ,x_ib                           => old_start_rec.ib
                 ,x_manual                       => old_start_rec.manual
                 ,x_reg_num                      => old_start_rec.reg_num
                 ,x_oeq                          => old_start_rec.oeq
                 ,x_eas                          => old_start_rec.eas
                 ,x_roa                          => old_start_rec.roa
                 ,x_status                       => old_start_rec.status
                 ,x_firm_now                     => old_start_rec.firm_now
                 ,x_firm_reply                   => old_start_rec.firm_reply
                 ,x_insurance_reply              => old_start_rec.insurance_reply
                 ,x_conf_hist_firm_reply         => old_start_rec.conf_hist_firm_reply
                 ,x_conf_hist_ins_reply          => old_start_rec.conf_hist_ins_reply
                 ,x_residential_category         => old_start_rec.residential_category
                 ,x_personal_statement           => old_start_rec.personal_statement
                 ,x_match_prev                   => old_start_rec.match_prev
                 ,x_match_prev_date              => old_start_rec.match_prev_date
                 ,x_match_winter                 => old_start_rec.match_winter
                 ,x_match_summer                 => old_start_rec.match_summer
                 ,x_gnvq_date                    => old_start_rec.gnvq_date
                 ,x_ib_date                      => old_start_rec.ib_date
                 ,x_ilc_date                     => old_start_rec.ilc_date
                 ,x_ailc_date                    => old_start_rec.ailc_date
                 ,x_gcseqa_date                  => old_start_rec.gcseqa_date
                 ,x_uk_entry_date                => old_start_rec.uk_entry_date
                 ,x_prev_surname                 => old_start_rec.prev_surname
                 ,x_criminal_convictions         => old_start_rec.criminal_convictions
                 ,x_sent_to_hesa                 => 'N'
                 ,x_sent_to_oss                  => 'N'
                 ,x_batch_identifier             => old_start_rec.batch_identifier
                 ,x_mode                         => 'R'
                 ,x_gce                          => old_start_rec.gce
                 ,x_vce                          => old_start_rec.vce
                 ,x_sqa                          => old_start_rec.sqa
                 ,x_previousas                   => old_start_rec.previousas
                 ,x_keyskills                    => old_start_rec.keyskills
                 ,x_vocational                   => old_start_rec.vocational
                 ,x_scn                          => old_start_rec.scn
                 ,x_PrevOEQ                      => old_start_rec.PrevOEQ
                 ,x_choices_transparent_ind      => old_start_rec.choices_transparent_ind
                 ,x_extra_status                 => old_start_rec.extra_status
                 ,x_extra_passport_no            => old_start_rec.extra_passport_no
                 ,x_request_app_dets_ind         => old_start_rec.request_app_dets_ind
                 ,x_request_copy_app_frm_ind     => old_start_rec.request_copy_app_frm_ind
                 ,x_cef_no                       => old_start_rec.cef_no
                 ,x_system_code                  => old_start_rec.system_code
                 ,x_gcse_eng                     => old_start_rec.gcse_eng
                 ,x_gcse_math                    => old_start_rec.gcse_math
                 ,x_degree_subject               => old_start_rec.degree_subject
                 ,x_degree_status                => old_start_rec.degree_status
                 ,x_degree_class                 => old_start_rec.degree_class
                 ,x_gcse_sci                     => old_start_rec.gcse_sci
                 ,x_welshspeaker                 => old_start_rec.welshspeaker
                 ,x_ni_number                    => old_start_rec.ni_number
                 ,x_earliest_start               => old_start_rec.earliest_start
                 ,x_near_inst                    => old_start_rec.near_inst
                 ,x_pref_reg                     => old_start_rec.pref_reg
                 ,x_qual_eng                     => old_start_rec.qual_eng
                 ,x_qual_math                    => old_start_rec.qual_math
                 ,x_qual_sci                     => old_start_rec.qual_sci
                 ,x_main_qual                    => old_start_rec.main_qual
                 ,x_qual_5                       => old_start_rec.qual_5
                 ,x_future_serv                  => new_ivstart_rec.futureserv
                 ,x_future_set                   => new_ivstart_rec.futureset
                 ,x_present_serv                 => new_ivstart_rec.presentserv
                 ,x_present_set                  => new_ivstart_rec.presentset
                 ,x_curr_employment              => new_ivstart_rec.curremp
                 ,x_edu_qualification            => new_ivstart_rec.eduqual
                 ,x_ad_batch_id                  => old_start_rec.ad_batch_id
                 ,x_ad_interface_id              => old_start_rec.ad_interface_id
                 ,x_nationality                  => old_start_rec.nationality
                 ,x_dual_nationality             => old_start_rec.dual_nationality
                 ,x_special_needs                => old_start_rec.special_needs
                 ,x_country_birth                => old_start_rec.country_birth
                 );

             EXCEPTION
                WHEN OTHERS THEN
                  g_error_code := '9998';
                  fnd_file.put_line(fnd_file.log, SQLERRM);
             END;

          END IF; -- main processing


        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_start_cur%ISOPEN THEN
                 CLOSE old_start_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_istart_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivstart_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_istart_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivstart_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTART', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTART'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstart;



  PROCEDURE process_ivqualification  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing IVQUALIFICATION i.e. Applicant
                         qualification info. details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ******************************************************************/

     CURSOR new_ivqual_cur IS
     SELECT ivqual.rowid,
            ivqual.*
     FROM   igs_uc_iqual_ints ivqual
     WHERE  ivqual.record_status = 'N';


     CURSOR old_qual_cur(p_appno igs_uc_app_choices.app_no%TYPE) IS
     SELECT ucap.rowid,
            ucap.*
     FROM   igs_uc_applicants ucap
     WHERE  ucap.app_no = p_appno;

     old_qual_rec old_qual_cur%ROWTYPE;

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVQUALIFICATION ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivqual_rec IN new_ivqual_cur
    LOOP
       BEGIN

          -- initialize record level variables.
          g_error_code := NULL;
          old_qual_rec := NULL;


          -- log Application processing message.
          fnd_message.set_name('IGS','IGS_UC_APPNO_PROC');
          fnd_message.set_token('APPL_NO', TO_CHAR(new_ivqual_rec.appno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- mandatory field validations as this is an update
          IF new_ivqual_rec.appno IS NULL THEN
             g_error_code := '1037';
          END IF;

          IF g_error_code IS NULL THEN
             ----------------------------
             -- AppNo validation
             ----------------------------
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivqual_rec.appno, g_error_code);
          END IF;

          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN

             -- Corresponding Application record would exist at this point
             -- otherwise the earlier validaton for error 1000 would have failed.
             OPEN old_qual_cur(new_ivqual_rec.appno);
             FETCH old_qual_cur INTO old_qual_rec;
             CLOSE old_qual_cur;


             BEGIN
                -- call the TBH to update the record
                igs_uc_applicants_pkg.update_row -- IGSXI01B.pls
                 (
                  x_rowid                        => old_qual_rec.rowid
                 ,x_app_id                       => old_qual_rec.app_id
                 ,x_app_no                       => old_qual_rec.app_no
                 ,x_check_digit                  => old_qual_rec.check_digit
                 ,x_personal_id                  => old_qual_rec.personal_id
                 ,x_enquiry_no                   => old_qual_rec.enquiry_no
                 ,x_oss_person_id                => old_qual_rec.oss_person_id
                 ,x_application_source           => old_qual_rec.application_source
                 ,x_name_change_date             => old_qual_rec.name_change_date
                 ,x_student_support              => old_qual_rec.student_support
                 ,x_address_area                 => old_qual_rec.address_area
                 ,x_application_date             => old_qual_rec.application_date
                 ,x_application_sent_date        => old_qual_rec.application_sent_date
                 ,x_application_sent_run         => old_qual_rec.application_sent_run
                 ,x_lea_code                     => NULL  -- obsoleted by UCAS
                 ,x_fee_payer_code               => old_qual_rec.fee_payer_code
                 ,x_fee_text                     => old_qual_rec.fee_text
                 ,x_domicile_apr                 => old_qual_rec.domicile_apr
                 ,x_code_changed_date            => old_qual_rec.code_changed_date
                 ,x_school                       => old_qual_rec.school
                 ,x_withdrawn                    => old_qual_rec.withdrawn
                 ,x_withdrawn_date               => old_qual_rec.withdrawn_date
                 ,x_rel_to_clear_reason          => old_qual_rec.rel_to_clear_reason
                 ,x_route_b                      => old_qual_rec.route_b
                 ,x_exam_change_date             => old_qual_rec.exam_change_date
                 ,x_a_levels                     => NULL  -- obsoleted by UCAS
                 ,x_as_levels                    => NULL  -- obsoleted by UCAS
                 ,x_highers                      => NULL  -- obsoleted by UCAS
                 ,x_csys                         => NULL  -- obsoleted by UCAS
                 ,x_winter                       => old_qual_rec.winter
                 ,x_previous                     => old_qual_rec.previous
                 ,x_gnvq                         => NULL  -- obsoleted by UCAS
                 ,x_btec                         => old_qual_rec.btec
                 ,x_ilc                          => old_qual_rec.ilc
                 ,x_ailc                         => old_qual_rec.ailc
                 ,x_ib                           => old_qual_rec.ib
                 ,x_manual                       => old_qual_rec.manual
                 ,x_reg_num                      => old_qual_rec.reg_num
                 ,x_oeq                          => old_qual_rec.oeq
                 ,x_eas                          => old_qual_rec.eas
                 ,x_roa                          => old_qual_rec.roa
                 ,x_status                       => old_qual_rec.status
                 ,x_firm_now                     => old_qual_rec.firm_now
                 ,x_firm_reply                   => old_qual_rec.firm_reply
                 ,x_insurance_reply              => old_qual_rec.insurance_reply
                 ,x_conf_hist_firm_reply         => old_qual_rec.conf_hist_firm_reply
                 ,x_conf_hist_ins_reply          => old_qual_rec.conf_hist_ins_reply
                 ,x_residential_category         => old_qual_rec.residential_category
                 ,x_personal_statement           => old_qual_rec.personal_statement
                 ,x_match_prev                   => new_ivqual_rec.matchprevious
                 ,x_match_prev_date              => new_ivqual_rec.matchpreviousdate
                 ,x_match_winter                 => new_ivqual_rec.matchwinter
                 ,x_match_summer                 => new_ivqual_rec.matchsummer
                 ,x_gnvq_date                    => new_ivqual_rec.gnvqdate
                 ,x_ib_date                      => new_ivqual_rec.ibdate
                 ,x_ilc_date                     => new_ivqual_rec.ilcdate
                 ,x_ailc_date                    => new_ivqual_rec.aicedate
                 ,x_gcseqa_date                  => new_ivqual_rec.gcesqadate
                 ,x_uk_entry_date                => old_qual_rec.uk_entry_date
                 ,x_prev_surname                 => old_qual_rec.prev_surname
                 ,x_criminal_convictions         => old_qual_rec.criminal_convictions
                 ,x_sent_to_hesa                 => 'N'
                 ,x_sent_to_oss                  => 'N'
                 ,x_batch_identifier             => old_qual_rec.batch_identifier
                 ,x_mode                         => 'R'
                 ,x_gce                          => old_qual_rec.gce
                 ,x_vce                          => old_qual_rec.vce
                 ,x_sqa                          => old_qual_rec.sqa
                 ,x_previousas                   => old_qual_rec.previousas
                 ,x_keyskills                    => old_qual_rec.keyskills
                 ,x_vocational                   => old_qual_rec.vocational
                 ,x_scn                          => old_qual_rec.scn
                 ,x_PrevOEQ                      => old_qual_rec.PrevOEQ
                 ,x_choices_transparent_ind      => old_qual_rec.choices_transparent_ind
                 ,x_extra_status                 => old_qual_rec.extra_status
                 ,x_extra_passport_no            => old_qual_rec.extra_passport_no
                 ,x_request_app_dets_ind         => old_qual_rec.request_app_dets_ind
                 ,x_request_copy_app_frm_ind     => old_qual_rec.request_copy_app_frm_ind
                 ,x_cef_no                       => old_qual_rec.cef_no
                 ,x_system_code                  => old_qual_rec.system_code
                 ,x_gcse_eng                     => old_qual_rec.gcse_eng
                 ,x_gcse_math                    => old_qual_rec.gcse_math
                 ,x_degree_subject               => old_qual_rec.degree_subject
                 ,x_degree_status                => old_qual_rec.degree_status
                 ,x_degree_class                 => old_qual_rec.degree_class
                 ,x_gcse_sci                     => old_qual_rec.gcse_sci
                 ,x_welshspeaker                 => old_qual_rec.welshspeaker
                 ,x_ni_number                    => old_qual_rec.ni_number
                 ,x_earliest_start               => old_qual_rec.earliest_start
                 ,x_near_inst                    => old_qual_rec.near_inst
                 ,x_pref_reg                     => old_qual_rec.pref_reg
                 ,x_qual_eng                     => old_qual_rec.qual_eng
                 ,x_qual_math                    => old_qual_rec.qual_math
                 ,x_qual_sci                     => old_qual_rec.qual_sci
                 ,x_main_qual                    => old_qual_rec.main_qual
                 ,x_qual_5                       => old_qual_rec.qual_5
                 ,x_future_serv                  => old_qual_rec.future_serv
                 ,x_future_set                   => old_qual_rec.future_set
                 ,x_present_serv                 => old_qual_rec.present_serv
                 ,x_present_set                  => old_qual_rec.present_set
                 ,x_curr_employment              => old_qual_rec.curr_employment
                 ,x_edu_qualification            => old_qual_rec.edu_qualification
                 ,x_ad_batch_id                  => old_qual_rec.ad_batch_id
                 ,x_ad_interface_id              => old_qual_rec.ad_interface_id
                 ,x_nationality                  => old_qual_rec.nationality
                 ,x_dual_nationality             => old_qual_rec.dual_nationality
                 ,x_special_needs                => old_qual_rec.special_needs
                 ,x_country_birth                => old_qual_rec.country_birth
                 );

             EXCEPTION
                WHEN OTHERS THEN
                  g_error_code := '9998';
                  fnd_file.put_line(fnd_file.log, SQLERRM);

             END;

          END IF; -- main processing

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_qual_cur%ISOPEN THEN
                 CLOSE old_qual_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);

        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_iqual_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivqual_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_iqual_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivqual_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVQUALIFICATION', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVQUALIFICATION'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivqualification;




  PROCEDURE process_ivstatement  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing IVSTATEMENT i.e. Applicant
                         statement info. details from UCAS. This data
                         has to be updated only when the existing
                         personal statement is NULL.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ******************************************************************/

     CURSOR new_ivstmnt_cur IS
     SELECT ivstmt.rowid,
            ivstmt.*
     FROM   igs_uc_istmnt_ints ivstmt
     WHERE  ivstmt.record_status = 'N';


     CURSOR old_stmt_cur(p_appno igs_uc_app_choices.app_no%TYPE) IS
     SELECT ucap.rowid,
            ucap.*
     FROM   igs_uc_applicants ucap
     WHERE  ucap.app_no = p_appno;

     old_stmt_rec old_stmt_cur%ROWTYPE;

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTATEMENT ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstmt_rec IN new_ivstmnt_cur
    LOOP

       BEGIN

          -- initialize record level variables.
          g_error_code := NULL;
          old_stmt_rec := NULL;

          -- log Application processing message.
          fnd_message.set_name('IGS','IGS_UC_APPNO_PROC');
          fnd_message.set_token('APPL_NO', TO_CHAR(new_ivstmt_rec.appno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- mandatory field validations as this is an update
          IF new_ivstmt_rec.appno IS NULL THEN
             g_error_code := '1037';
          END IF;


          IF g_error_code IS NULL THEN
             ----------------------------
             -- AppNo validation
             ----------------------------
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivstmt_rec.appno, g_error_code);

          END IF;


          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN

             -- Corresponding Application record would exist at this point
             -- otherwise the earlier validaton for error 1000 would have failed.
             OPEN old_stmt_cur(new_ivstmt_rec.appno);
             FETCH old_stmt_cur INTO old_stmt_rec;
             CLOSE old_stmt_cur;

             -------------------------------------------------------
             -- Check whether the existing personal statement is NULL
             -- Update the record only if the existing value is NULL
             -- else ignore the record and just update the status to 'D'.
             -------------------------------------------------------

             IF old_stmt_rec.personal_statement IS NULL AND new_ivstmt_rec.statement IS NOT NULL THEN

                -- update the statement as the existing value is null
                BEGIN
                   igs_uc_applicants_pkg.update_row -- IGSXI01B.pls
                    (
                     x_rowid                        => old_stmt_rec.rowid
                    ,x_app_id                       => old_stmt_rec.app_id
                    ,x_app_no                       => old_stmt_rec.app_no
                    ,x_check_digit                  => old_stmt_rec.check_digit
                    ,x_personal_id                  => old_stmt_rec.personal_id
                    ,x_enquiry_no                   => old_stmt_rec.enquiry_no
                    ,x_oss_person_id                => old_stmt_rec.oss_person_id
                    ,x_application_source           => old_stmt_rec.application_source
                    ,x_name_change_date             => old_stmt_rec.name_change_date
                    ,x_student_support              => old_stmt_rec.student_support
                    ,x_address_area                 => old_stmt_rec.address_area
                    ,x_application_date             => old_stmt_rec.application_date
                    ,x_application_sent_date        => old_stmt_rec.application_sent_date
                    ,x_application_sent_run         => old_stmt_rec.application_sent_run
                    ,x_lea_code                     => NULL  -- obsoleted by UCAS
                    ,x_fee_payer_code               => old_stmt_rec.fee_payer_code
                    ,x_fee_text                     => old_stmt_rec.fee_text
                    ,x_domicile_apr                 => old_stmt_rec.domicile_apr
                    ,x_code_changed_date            => old_stmt_rec.code_changed_date
                    ,x_school                       => old_stmt_rec.school
                    ,x_withdrawn                    => old_stmt_rec.withdrawn
                    ,x_withdrawn_date               => old_stmt_rec.withdrawn_date
                    ,x_rel_to_clear_reason          => old_stmt_rec.rel_to_clear_reason
                    ,x_route_b                      => old_stmt_rec.route_b
                    ,x_exam_change_date             => old_stmt_rec.exam_change_date
                    ,x_a_levels                     => NULL  -- obsoleted by UCAS
                    ,x_as_levels                    => NULL  -- obsoleted by UCAS
                    ,x_highers                      => NULL  -- obsoleted by UCAS
                    ,x_csys                         => NULL  -- obsoleted by UCAS
                    ,x_winter                       => old_stmt_rec.winter
                    ,x_previous                     => old_stmt_rec.previous
                    ,x_gnvq                         => NULL  -- obsoleted by UCAS
                    ,x_btec                         => old_stmt_rec.btec
                    ,x_ilc                          => old_stmt_rec.ilc
                    ,x_ailc                         => old_stmt_rec.ailc
                    ,x_ib                           => old_stmt_rec.ib
                    ,x_manual                       => old_stmt_rec.manual
                    ,x_reg_num                      => old_stmt_rec.reg_num
                    ,x_oeq                          => old_stmt_rec.oeq
                    ,x_eas                          => old_stmt_rec.eas
                    ,x_roa                          => old_stmt_rec.roa
                    ,x_status                       => old_stmt_rec.status
                    ,x_firm_now                     => old_stmt_rec.firm_now
                    ,x_firm_reply                   => old_stmt_rec.firm_reply
                    ,x_insurance_reply              => old_stmt_rec.insurance_reply
                    ,x_conf_hist_firm_reply         => old_stmt_rec.conf_hist_firm_reply
                    ,x_conf_hist_ins_reply          => old_stmt_rec.conf_hist_ins_reply
                    ,x_residential_category         => old_stmt_rec.residential_category
                    ,x_personal_statement           => new_ivstmt_rec.statement
                    ,x_match_prev                   => old_stmt_rec.match_prev
                    ,x_match_prev_date              => old_stmt_rec.match_prev_date
                    ,x_match_winter                 => old_stmt_rec.match_winter
                    ,x_match_summer                 => old_stmt_rec.match_summer
                    ,x_gnvq_date                    => old_stmt_rec.gnvq_date
                    ,x_ib_date                      => old_stmt_rec.ib_date
                    ,x_ilc_date                     => old_stmt_rec.ilc_date
                    ,x_ailc_date                    => old_stmt_rec.ailc_date
                    ,x_gcseqa_date                  => old_stmt_rec.gcseqa_date
                    ,x_uk_entry_date                => old_stmt_rec.uk_entry_date
                    ,x_prev_surname                 => old_stmt_rec.prev_surname
                    ,x_criminal_convictions         => old_stmt_rec.criminal_convictions
                    ,x_sent_to_hesa                 => old_stmt_rec.sent_to_hesa
                    ,x_sent_to_oss                  => old_stmt_rec.sent_to_oss
                    ,x_batch_identifier             => old_stmt_rec.batch_identifier
                    ,x_mode                         => 'R'
                    ,x_gce                          => old_stmt_rec.gce
                    ,x_vce                          => old_stmt_rec.vce
                    ,x_sqa                          => old_stmt_rec.sqa
                    ,x_previousas                   => old_stmt_rec.previousas
                    ,x_keyskills                    => old_stmt_rec.keyskills
                    ,x_vocational                   => old_stmt_rec.vocational
                    ,x_scn                          => old_stmt_rec.scn
                    ,x_PrevOEQ                      => old_stmt_rec.PrevOEQ
                    ,x_choices_transparent_ind      => old_stmt_rec.choices_transparent_ind
                    ,x_extra_status                 => old_stmt_rec.extra_status
                    ,x_extra_passport_no            => old_stmt_rec.extra_passport_no
                    ,x_request_app_dets_ind         => old_stmt_rec.request_app_dets_ind
                    ,x_request_copy_app_frm_ind     => old_stmt_rec.request_copy_app_frm_ind
                    ,x_cef_no                       => old_stmt_rec.cef_no
                    ,x_system_code                  => old_stmt_rec.system_code
                    ,x_gcse_eng                     => old_stmt_rec.gcse_eng
                    ,x_gcse_math                    => old_stmt_rec.gcse_math
                    ,x_degree_subject               => old_stmt_rec.degree_subject
                    ,x_degree_status                => old_stmt_rec.degree_status
                    ,x_degree_class                 => old_stmt_rec.degree_class
                    ,x_gcse_sci                     => old_stmt_rec.gcse_sci
                    ,x_welshspeaker                 => old_stmt_rec.welshspeaker
                    ,x_ni_number                    => old_stmt_rec.ni_number
                    ,x_earliest_start               => old_stmt_rec.earliest_start
                    ,x_near_inst                    => old_stmt_rec.near_inst
                    ,x_pref_reg                     => old_stmt_rec.pref_reg
                    ,x_qual_eng                     => old_stmt_rec.qual_eng
                    ,x_qual_math                    => old_stmt_rec.qual_math
                    ,x_qual_sci                     => old_stmt_rec.qual_sci
                    ,x_main_qual                    => old_stmt_rec.main_qual
                    ,x_qual_5                       => old_stmt_rec.qual_5
                    ,x_future_serv                  => old_stmt_rec.future_serv
                    ,x_future_set                   => old_stmt_rec.future_set
                    ,x_present_serv                 => old_stmt_rec.present_serv
                    ,x_present_set                  => old_stmt_rec.present_set
                    ,x_curr_employment              => old_stmt_rec.curr_employment
                    ,x_edu_qualification            => old_stmt_rec.edu_qualification
                    ,x_ad_batch_id                  => old_stmt_rec.ad_batch_id
                    ,x_ad_interface_id              => old_stmt_rec.ad_interface_id
                    ,x_nationality                  => old_stmt_rec.nationality
                    ,x_dual_nationality             => old_stmt_rec.dual_nationality
                    ,x_special_needs                => old_stmt_rec.special_needs
                    ,x_country_birth                => old_stmt_rec.country_birth
                    );

                EXCEPTION
                   WHEN OTHERS THEN
                     g_error_code := '9998';
                     fnd_file.put_line(fnd_file.log, SQLERRM);
                END;

             END IF; -- only update and no insert.

          END IF; -- main processing

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_stmt_cur%ISOPEN THEN
                 CLOSE old_stmt_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_istmnt_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivstmt_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_istmnt_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivstmt_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTATEMENT', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTATEMENT'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstatement;




  PROCEDURE process_ivoffer  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing ivoffer info. details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ******************************************************************/

     CURSOR new_ivoffer_cur IS
     SELECT ivoff.rowid,
            ivoff.*
     FROM   igs_uc_ioffer_ints ivoff
     WHERE  record_status = 'N';


     CURSOR old_offer_cur (p_appno igs_uc_app_choices.app_no%TYPE,
                           p_choiceno igs_uc_app_choices.choice_no%TYPE,
                           p_cycle igs_uc_app_choices.ucas_cycle%TYPE) IS
     SELECT appl.rowid,
            appl.*
     FROM   igs_uc_app_choices appl
     WHERE  appl.app_no = p_appno
     AND    appl.choice_no = p_choiceno
     AND    appl.ucas_cycle = p_cycle;

     old_offer_rec old_offer_cur%ROWTYPE ;     -- Holds the existing values for this incoming record.
     l_app_choice_id igs_uc_app_choices.app_choice_id%TYPE; -- Place holder for App CHoice ID - Seq gen value.

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVOFFER ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivoffer_rec IN new_ivoffer_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          g_error_code := NULL;
          old_offer_rec := NULL;
          l_app_choice_id := NULL;

          -- log Application Choice processing message.
          fnd_message.set_name('IGS','IGS_UC_APPNO_CHOICE_PROC');
          fnd_message.set_token('APPNO', TO_CHAR(new_ivoffer_rec.appno));
          fnd_message.set_token('CHOICE',TO_CHAR(new_ivoffer_rec.choiceno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- no mandatory field validations as this is an update
          IF new_ivoffer_rec.appno IS NULL OR new_ivoffer_rec.choiceno  IS NULL OR
             new_ivoffer_rec.ucas_cycle IS NULL THEN

             g_error_code := '1037';
          END IF;


          -- AppNo validation
          IF g_error_code IS NULL THEN

             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivoffer_rec.appno, g_error_code);
          END IF;



          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN

             -- Check wether corresponding record already exists.
             -- If exists , update the records otherwise insert a new record.
             OPEN old_offer_cur(new_ivoffer_rec.appno, new_ivoffer_rec.choiceno, new_ivoffer_rec.ucas_cycle);
             FETCH old_offer_cur INTO old_offer_rec;
             CLOSE old_offer_cur;

             IF old_offer_rec.rowid IS NULL THEN
                g_error_code := '1046';

             ELSE /* Update the record */

                  BEGIN
                     -- call the TBH to update the record
                     igs_uc_app_choices_pkg.update_row -- IGSXI02B.pls
                      (
                       x_rowid                      => old_offer_rec.rowid
                      ,x_app_choice_id              => old_offer_rec.app_choice_id
                      ,x_app_id                     => old_offer_rec.app_id
                      ,x_app_no                     => old_offer_rec.app_no
                      ,x_choice_no                  => old_offer_rec.choice_no
                      ,x_last_change                => old_offer_rec.last_change
                      ,x_institute_code             => old_offer_rec.institute_code
                      ,x_ucas_program_code          => old_offer_rec.ucas_program_code
                      ,x_oss_program_code           => old_offer_rec.oss_program_code
                      ,x_oss_program_version        => old_offer_rec.oss_program_version
                      ,x_oss_attendance_type        => old_offer_rec.oss_attendance_type
                      ,x_oss_attendance_mode        => old_offer_rec.oss_attendance_mode
                      ,x_campus                     => old_offer_rec.campus
                      ,x_oss_location               => old_offer_rec.oss_location
                      ,x_faculty                    => old_offer_rec.faculty
                      ,x_entry_year                 => old_offer_rec.entry_year
                      ,x_entry_month                => old_offer_rec.entry_month
                      ,x_point_of_entry             => old_offer_rec.point_of_entry
                      ,x_home                       => old_offer_rec.home
                      ,x_deferred                   => old_offer_rec.deferred
                      ,x_route_b_pref_round         => old_offer_rec.route_b_pref_round
                      ,x_route_b_actual_round       => old_offer_rec.route_b_actual_round
                      ,x_condition_category         => old_offer_rec.condition_category
                      ,x_condition_code             => old_offer_rec.condition_code
                      ,x_decision                   => old_offer_rec.decision
                      ,x_decision_date              => old_offer_rec.decision_date
                      ,x_decision_number            => old_offer_rec.decision_number
                      ,x_reply                      => old_offer_rec.reply
                      ,x_summary_of_cond            => old_offer_rec.summary_of_cond
                      ,x_choice_cancelled           => old_offer_rec.choice_cancelled
                      ,x_action                     => old_offer_rec.action
                      ,x_substitution               => old_offer_rec.substitution
                      ,x_date_substituted           => old_offer_rec.date_substituted
                      ,x_prev_institution           => old_offer_rec.prev_institution
                      ,x_prev_course                => old_offer_rec.prev_course
                      ,x_prev_campus                => old_offer_rec.prev_campus
                      ,x_ucas_amendment             => old_offer_rec.ucas_amendment
                      ,x_withdrawal_reason          => old_offer_rec.withdrawal_reason
                      ,x_offer_course               => new_ivoffer_rec.offercourse
                      ,x_offer_campus               => new_ivoffer_rec.offercampus
                      ,x_offer_crse_length          => new_ivoffer_rec.offercourselength
                      ,x_offer_entry_month          => new_ivoffer_rec. offerentrymonth
                      ,x_offer_entry_year           => new_ivoffer_rec.offerentryyear
                      ,x_offer_entry_point          => new_ivoffer_rec.offerentrypoint
                      ,x_offer_text                 => new_ivoffer_rec.offertext
                      ,x_mode                       => 'R'
                      ,x_export_to_oss_status       => old_offer_rec.export_to_oss_status
                      ,x_error_code                 => old_offer_rec.error_code
                      ,x_request_id                 => old_offer_rec.request_id
                      ,x_batch_id                   => old_offer_rec.batch_id
                      ,x_extra_round_nbr            => old_offer_rec.extra_round_nbr
                      ,x_system_code                => old_offer_rec.system_code
                      ,x_part_time                  => old_offer_rec.part_time
                      ,x_interview                  => old_offer_rec.interview
                      ,x_late_application           => old_offer_rec.late_application
                      ,x_modular                    => old_offer_rec.modular
                      ,x_residential                => old_offer_rec.residential
                      ,x_ucas_cycle                 => old_offer_rec.ucas_cycle
                      );

                   EXCEPTION
                      WHEN OTHERS THEN
                        g_error_code := '9998';
                        fnd_file.put_line(fnd_file.log, SQLERRM);

                   END;

             END IF; -- insert / update

          END IF; -- main processing


        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_offer_cur%ISOPEN THEN
                 CLOSE old_offer_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_ioffer_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivoffer_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_ioffer_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivoffer_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVOFFER', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVOFFER'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivoffer;



  PROCEDURE process_ivstarx  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing ivstarx i.e. Applicant
                         other details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    17-Oct-05   Modified social class validation to use
                           cvRefSocialClass as cvRefPre200POOC has been obsoleted
    ******************************************************************/

     CURSOR new_ivstarx_cur IS
     SELECT ivstx.rowid,
            ivstx.*
     FROM   igs_uc_istarx_ints ivstx
     WHERE  ivstx.record_status = 'N';

     -- check for corresponding record in main table.
     CURSOR old_starx_cur(p_appno igs_uc_app_choices.app_no%TYPE) IS
     SELECT uast.rowid,
            uast.*
     FROM   igs_uc_app_stats uast
     WHERE  uast.app_no = p_appno;

     -- validate ethnic value
     CURSOR validate_ethnic (p_ethnic igs_uc_istarx_ints.ethnic%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_ref_codes
     WHERE  code_type = 'ET'
     and    code      = p_ethnic;

     -- validate Socialclass value
     CURSOR validate_socialclass (p_socialclass igs_uc_istarx_ints.socialclass%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_ref_codes
     WHERE  code_type = 'PC'
     AND    code      = p_socialclass;

     -- get the system and app_id to be populated into App Choices
     CURSOR get_appl_dets (p_appno igs_uc_applicants.app_no%TYPE) IS
     SELECT app_id,
            system_code
     FROM   igs_uc_applicants
     WHERE  app_no = p_appno;

     appl_det_rec get_appl_dets%ROWTYPE;
     old_starx_rec old_starx_cur%ROWTYPE;
     l_valid       VARCHAR2(1);

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTARX ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstarx_rec IN new_ivstarx_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          g_error_code  := NULL;
          old_starx_rec := NULL;
          l_valid       := NULL;

          -- log record processing info.
          fnd_message.set_name('IGS','IGS_UC_APPNO_PROC');
          fnd_message.set_token('APPL_NO', TO_CHAR(new_ivstarx_rec.appno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- no mandatory field validations as this is an update
          IF new_ivstarx_rec.appno IS NULL THEN
             g_error_code := '1037';
          END IF;


          ---------------------------------------
          -- validate ETHNIC value from UCAS
          ---------------------------------------
          IF g_error_code IS NULL THEN

             l_valid := NULL;
             IF new_ivstarx_rec.ethnic IS NOT NULL THEN

                OPEN  validate_ethnic (new_ivstarx_rec.ethnic);
                FETCH validate_ethnic INTO l_valid;
                CLOSE validate_ethnic;

                IF l_valid IS NULL THEN
                   g_error_code := '1019';
                END IF;

             END IF;
          END IF;


          ---------------------------------------
          -- validate SOCIALCLASS value from UCAS
          ---------------------------------------
          IF g_error_code IS NULL THEN
             l_valid := NULL;  -- initialize again because it is being re-used.

             IF new_ivstarx_rec.socialclass IS NOT NULL THEN

                OPEN  validate_socialclass (new_ivstarx_rec.socialclass);
                FETCH validate_socialclass INTO l_valid;
                CLOSE validate_socialclass;

                IF l_valid IS NULL THEN
                   g_error_code := '1020';
                END IF;

             END IF;
          END IF;


          IF g_error_code IS NULL THEN
             ----------------------------
             -- AppNo validation
             ----------------------------
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivstarx_rec.appno, g_error_code);

          END IF;



          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN

             -- Check whether corresponding Application record already exists.
             -- If exists then update else insert.
             OPEN  old_starx_cur(new_ivstarx_rec.appno);
             FETCH old_starx_cur INTO old_starx_rec;
             CLOSE old_starx_cur;

             IF old_starx_rec.rowid IS NULL THEN  -- i.e. new record.


                -- get application details - App ID which is needed while inserting a record.
                -- Record would always be found otherwise the above validation - Error 1000 would have failed.
                appl_det_rec := NULL;  -- initialize
                OPEN  get_appl_dets(new_ivstarx_rec.appno);
                FETCH get_appl_dets INTO appl_det_rec;
                CLOSE get_appl_dets;


                BEGIN

                   -- call the TBH to update the record
                   igs_uc_app_stats_pkg.insert_row -- IGSXI07B.pls
                    (
                       x_rowid                            => old_starx_rec.rowid        -- would be NULL since no existing rec found
                      ,x_app_stat_id                      => old_starx_rec.app_stat_id  -- since this will be NULL since no existing rec found.
                      ,x_app_id                           => appl_det_rec.app_id
                      ,x_app_no                           => new_ivstarx_rec.appno
                      ,x_starh_ethnic                     => NULL
                      ,x_starh_social_class               => NULL
                      ,x_starh_pocc_edu_chg_dt            => NULL
                      ,x_starh_pocc                       => NULL
                      ,x_starh_pocc_text                  => NULL
                      ,x_starh_last_edu_inst              => NULL
                      ,x_starh_edu_leave_date             => NULL
                      ,x_starh_lea                        => NULL
                      ,x_starx_ethnic                     => new_ivstarx_rec.ethnic
                      ,x_starx_pocc_edu_chg               => new_ivstarx_rec.pocceduchangedate
                      ,x_starx_pocc                       => new_ivstarx_rec.pocc
                      ,x_starx_pocc_text                  => new_ivstarx_rec.pocctext
                      ,x_sent_to_hesa                     => 'N'
                      ,x_starx_socio_economic             => new_ivstarx_rec.socioeconomic
                      ,x_starx_occ_background             => new_ivstarx_rec.occbackground
                      ,x_starh_socio_economic             => NULL
                      ,x_mode                             => 'R'
                      ,x_ivstarh_dependants               => NULL
                      ,x_ivstarh_married                  => NULL
                      ,x_ivstarx_religion                 => new_ivstarx_rec.religion
                      ,x_ivstarx_married                  => new_ivstarx_rec.married
                      ,x_ivstarx_dependants               => new_ivstarx_rec.dependants
                    );

                EXCEPTION
                   WHEN OTHERS THEN
                      g_error_code := '9999';
                      fnd_file.put_line(fnd_file.log, SQLERRM);
                END;


             ELSE  -- update

                BEGIN
                  -- call the TBH to update the record
                  igs_uc_app_stats_pkg.update_row -- IGSXI07B.pls
                  (
                    x_rowid                   => old_starx_rec.rowid
                   ,x_app_stat_id             => old_starx_rec.app_stat_id
                   ,x_app_id                  => old_starx_rec.app_id
                   ,x_app_no                  => old_starx_rec.app_no
                   ,x_starh_ethnic            => old_starx_rec.starh_ethnic
                   ,x_starh_social_class      => old_starx_rec.starh_social_class
                   ,x_starh_pocc_edu_chg_dt   => old_starx_rec.starh_pocc_edu_chg_dt
                   ,x_starh_pocc              => old_starx_rec.starh_pocc
                   ,x_starh_pocc_text         => old_starx_rec.starh_pocc_text
                   ,x_starh_last_edu_inst     => old_starx_rec.starh_last_edu_inst
                   ,x_starh_edu_leave_date    => old_starx_rec.starh_edu_leave_date
                   ,x_starh_lea               => old_starx_rec.starh_lea
                   ,x_starx_ethnic            => new_ivstarx_rec.ethnic
                   ,x_starx_pocc_edu_chg      => new_ivstarx_rec.pocceduchangedate
                   ,x_starx_pocc              => new_ivstarx_rec.pocc
                   ,x_starx_pocc_text         => new_ivstarx_rec.pocctext
                   ,x_sent_to_hesa            => 'N'
                   ,x_starx_socio_economic    => new_ivstarx_rec.socioeconomic
                   ,x_starx_occ_background    => new_ivstarx_rec.occbackground
                   ,x_starh_socio_economic    => NULL
                   ,x_mode                    => 'R'
                   ,x_ivstarh_dependants      => old_starx_rec.ivstarh_dependants
                   ,x_ivstarh_married         => old_starx_rec.ivstarh_married
                   ,x_ivstarx_religion        => new_ivstarx_rec.religion
                   ,x_ivstarx_married         => new_ivstarx_rec.married
                   ,x_ivstarx_dependants      => new_ivstarx_rec.dependants
                  );

                EXCEPTION
                   WHEN OTHERS THEN
                      g_error_code := '9998';
                      fnd_file.put_line(fnd_file.log, SQLERRM);
                END;

             END IF; -- insert / update

          END IF; -- main processing

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_starx_cur%ISOPEN THEN
                 CLOSE old_starx_cur;
              END IF;

              IF validate_ethnic%ISOPEN THEN
                 CLOSE validate_ethnic;
              END IF;

              IF validate_socialclass%ISOPEN THEN
                 CLOSE validate_socialclass;
              END IF;

              IF get_appl_dets%ISOPEN THEN
                 CLOSE get_appl_dets;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_istarx_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivstarx_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_istarx_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivstarx_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTARX', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTARX'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstarx;



  PROCEDURE process_ivstarh  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing ivstarh i.e. Applicant
                         HESA details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    17-Oct-05   Modified social class validation to use
                           cvRefSocialClass as cvRefPre200POOC has been obsoleted
    ******************************************************************/

     CURSOR new_ivstarh_cur IS
     SELECT ivsth.rowid,
            ivsth.*
     FROM   igs_uc_istarh_ints ivsth
     WHERE  ivsth.record_status = 'N';

     -- check for corresponding record in main table.
     CURSOR old_starh_cur(p_appno igs_uc_app_choices.app_no%TYPE) IS
     SELECT uast.rowid,
            uast.*
     FROM   igs_uc_app_stats uast
     WHERE  uast.app_no = p_appno;

     -- validate ethnic value
     CURSOR validate_ethnic (p_ethnic igs_uc_istarh_ints.ethnic%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_ref_codes
     WHERE  code_type = 'ET'
     and    code      = p_ethnic;

     -- validate Socialclass value
     CURSOR validate_socialclass (p_socialclass igs_uc_istarh_ints.socialclass%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_ref_codes
     WHERE  code_type = 'PC'
     AND    code      = p_socialclass;

     -- get the system and app_id to be populated into App Choices
     CURSOR get_appl_dets (p_appno igs_uc_applicants.app_no%TYPE) IS
     SELECT app_id,
            system_code
     FROM   igs_uc_applicants
     WHERE  app_no = p_appno;

     appl_det_rec  get_appl_dets%ROWTYPE;
     old_starh_rec old_starh_cur%ROWTYPE;
     l_valid       VARCHAR2(1);
     l_socialeconomic igs_uc_app_stats.starh_socio_economic%TYPE;


  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTARH ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstarh_rec IN new_ivstarh_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          g_error_code  := NULL;
          old_starh_rec := NULL;
          l_valid       := NULL;

          -- log record processing info.
          fnd_message.set_name('IGS','IGS_UC_APPNO_PROC');
          fnd_message.set_token('APPL_NO', TO_CHAR(new_ivstarh_rec.appno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- no mandatory field validations as this is an update
          IF new_ivstarh_rec.appno IS NULL THEN
             g_error_code := '1037';
          END IF;


          ---------------------------------------
          -- validate ETHNIC value from UCAS
          ---------------------------------------
          IF g_error_code IS NULL THEN
             IF new_ivstarh_rec.ethnic IS NOT NULL THEN
                OPEN  validate_ethnic (new_ivstarh_rec.ethnic);
                FETCH validate_ethnic INTO l_valid;
                CLOSE validate_ethnic;

                IF l_valid IS NULL THEN
                   g_error_code := '1019';
                END IF;

             END IF;
          END IF;


          ---------------------------------------
          -- validate SOCIALCLASS value from UCAS
          ---------------------------------------
          IF g_error_code IS NULL THEN
             l_valid := NULL;  -- initialize again because it is being re-used.
             IF new_ivstarh_rec.socialclass IS NOT NULL THEN
                OPEN  validate_socialclass (new_ivstarh_rec.socialclass);
                FETCH validate_socialclass INTO l_valid;
                CLOSE validate_socialclass;

                IF l_valid IS NULL THEN
                   g_error_code := '1020';
                END IF;

             END IF;
          END IF;


          IF g_error_code IS NULL THEN
             ----------------------------
             -- AppNo validation
             ----------------------------
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivstarh_rec.appno, g_error_code);

          END IF;


          -- Value coming from UCAS (also in INT table, the field is VARCHAR2. However, this field in main
          -- table is of NUMBER datatype. Hence validating that the incoming value is a Number and then populate.
          l_socialeconomic := NULL;
          IF (ASCII(new_ivstarh_rec.socialeconomic) >= 48 AND ASCII(new_ivstarh_rec.socialeconomic) <= 57) THEN
             l_socialeconomic := TO_NUMBER(new_ivstarh_rec.socialeconomic);
          END IF;


          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN

             -- Check whether corresponding Application record already exists.
             -- If exists then update else insert.
             OPEN  old_starh_cur(new_ivstarh_rec.appno);
             FETCH old_starh_cur INTO old_starh_rec;
             CLOSE old_starh_cur;

             IF old_starh_rec.rowid IS NULL THEN  -- i.e. new record.


                -- get application details - App ID which is needed while inserting a record.
                -- Record would always be found otherwise the above validation - Error 1000 would have failed.
                appl_det_rec := NULL;  -- initialize
                OPEN  get_appl_dets(new_ivstarh_rec.appno);
                FETCH get_appl_dets INTO appl_det_rec;
                CLOSE get_appl_dets;


                BEGIN

                   -- call the TBH to update the record
                   igs_uc_app_stats_pkg.insert_row -- IGSXI07B.pls
                    (
                       x_rowid                            => old_starh_rec.rowid
                      ,x_app_stat_id                      => old_starh_rec.app_stat_id  -- can be used as this value will be NULL during insert as no rec exists.
                      ,x_app_id                           => appl_det_rec.app_id
                      ,x_app_no                           => new_ivstarh_rec.appno
                      ,x_starh_ethnic                     => new_ivstarh_rec.ethnic
                      ,x_starh_social_class               => new_ivstarh_rec.socialclass
                      ,x_starh_pocc_edu_chg_dt            => new_ivstarh_rec.pocceduchangedate
                      ,x_starh_pocc                       => new_ivstarh_rec.pocc
                      ,x_starh_pocc_text                  => new_ivstarh_rec.pocctext
                      ,x_starh_last_edu_inst              => new_ivstarh_rec.lasteducation
                      ,x_starh_edu_leave_date             => new_ivstarh_rec.educationleavedate
                      ,x_starh_lea                        => new_ivstarh_rec.lea
                      ,x_starx_ethnic                     => NULL
                      ,x_starx_pocc_edu_chg               => NULL
                      ,x_starx_pocc                       => NULL
                      ,x_starx_pocc_text                  => NULL
                      ,x_sent_to_hesa                     => 'N'
                      ,x_starx_socio_economic             => NULL
                      ,x_starx_occ_background             => NULL
                      ,x_starh_socio_economic             => l_socialeconomic
                      ,x_mode                             => 'R'
                      ,x_ivstarh_dependants               => new_ivstarh_rec.dependants
                      ,x_ivstarh_married                  => new_ivstarh_rec.married
                      ,x_ivstarx_religion                 => NULL
                      ,x_ivstarx_married                  => NULL
                      ,x_ivstarx_dependants               => NULL
                    );

                EXCEPTION
                   WHEN OTHERS THEN
                      g_error_code := '9999';
                      fnd_file.put_line(fnd_file.log, SQLERRM);
                END;


             ELSE  -- update

                BEGIN
                  -- call the TBH to update the record
                  igs_uc_app_stats_pkg.update_row -- IGSXI07B.pls
                  (
                       x_rowid                            => old_starh_rec.rowid
                      ,x_app_stat_id                      => old_starh_rec.app_stat_id
                      ,x_app_id                           => old_starh_rec.app_id
                      ,x_app_no                           => old_starh_rec.app_no
                      ,x_starh_ethnic                     => new_ivstarh_rec.ethnic
                      ,x_starh_social_class               => new_ivstarh_rec.socialclass
                      ,x_starh_pocc_edu_chg_dt            => new_ivstarh_rec.pocceduchangedate
                      ,x_starh_pocc                       => new_ivstarh_rec.pocc
                      ,x_starh_pocc_text                  => new_ivstarh_rec.pocctext
                      ,x_starh_last_edu_inst              => new_ivstarh_rec.lasteducation
                      ,x_starh_edu_leave_date             => new_ivstarh_rec.educationleavedate
                      ,x_starh_lea                        => new_ivstarh_rec.lea
                      ,x_starx_ethnic                     => old_starh_rec.starx_ethnic
                      ,x_starx_pocc_edu_chg               => old_starh_rec.starx_pocc_edu_chg
                      ,x_starx_pocc                       => old_starh_rec.starx_pocc
                      ,x_starx_pocc_text                  => old_starh_rec.starx_pocc_text
                      ,x_sent_to_hesa                     => 'N'
                      ,x_starx_socio_economic             => old_starh_rec.starx_socio_economic
                      ,x_starx_occ_background             => old_starh_rec.starx_occ_background
                      ,x_starh_socio_economic             => l_socialeconomic
                      ,x_mode                             => 'R'
                      ,x_ivstarh_dependants               => new_ivstarh_rec.dependants
                      ,x_ivstarh_married                  => new_ivstarh_rec.married
                      ,x_ivstarx_religion                 => old_starh_rec.ivstarx_religion
                      ,x_ivstarx_married                  => old_starh_rec.ivstarx_married
                      ,x_ivstarx_dependants               => old_starh_rec.ivstarx_dependants
                  );

                EXCEPTION
                   WHEN OTHERS THEN
                      g_error_code := '9998';
                      fnd_file.put_line(fnd_file.log, SQLERRM);
                END;

             END IF; -- insert / update

          END IF; -- main processing

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_starh_cur%ISOPEN THEN
                 CLOSE old_starh_cur;
              END IF;

              IF validate_ethnic%ISOPEN THEN
                 CLOSE validate_ethnic;
              END IF;

              IF validate_socialclass%ISOPEN THEN
                 CLOSE validate_socialclass;
              END IF;

              IF get_appl_dets%ISOPEN THEN
                 CLOSE get_appl_dets;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_istarh_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivstarh_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_istarh_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivstarh_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTARH', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTARH'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstarh;




  PROCEDURE process_ivstarz1  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing ivstarz1 i.e. Applicant
                         Clearing info. details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     arvsrini  04-MAR-04  Added code to use IGS_UC_ISTARZ1_INTS record to update Choice Number 9 record in IGS_UC_APP_CHOICES when the
                          IGS_UC_ISTARZ1_INTS.INST = Current Institution Code defined in UCAS Setup.
                          modified wrt UCCR008 build. Bug#3239860
     anwest    29-MAY-06  Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
     anwest    02-AUG-06  Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL

    ******************************************************************/

     CURSOR new_ivstarz1_cur IS
     SELECT ivstz1.rowid,
            ivstz1.*
     FROM   igs_uc_istarz1_ints ivstz1
     WHERE  ivstz1.record_status = 'N';

     -- check for corresponding record in main table.
     CURSOR old_starz1_cur(p_appno igs_uc_app_clearing.app_no%TYPE) IS
     SELECT uacl.rowid,
            uacl.*
     FROM   igs_uc_app_clearing uacl
     WHERE  uacl.app_no = p_appno;

     -- validate Institution value
     CURSOR validate_inst (p_inst igs_uc_app_clearing.institution%TYPE) IS
     SELECT ucas, gttr, nmas, swas
     FROM   igs_uc_com_inst
     WHERE  inst = p_inst;

     -- validate Course value
     CURSOR validate_Course (p_course igs_uc_istarz1_ints.course%TYPE,
                             p_campus igs_uc_istarz1_ints.campus%TYPE,
                             p_inst   igs_uc_istarz1_ints.inst%TYPE,
                             p_system igs_uc_crse_dets.system_code%TYPE) IS
     SELECT 'X'
     FROM   igs_uc_crse_dets
     WHERE  ucas_program_code = p_course
     AND    institute         = p_inst
     AND    ucas_campus       = p_campus
     AND    system_code       = p_system;


     -- get the system and app_id to be populated into App Choices
     CURSOR get_appl_dets (p_appno igs_uc_applicants.app_no%TYPE) IS
     SELECT app_id,
            system_code
     FROM   igs_uc_applicants
     WHERE  app_no = p_appno;



     CURSOR curr_inst_cur(p_sys_code igs_uc_defaults.system_code%type) IS
     SELECT current_inst_code
     FROM   igs_uc_defaults
     WHERE  system_code = p_sys_code;

     -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
     CURSOR uc_app_choices_cur(p_appno igs_uc_app_choices.app_no%TYPE) IS
        SELECT uacc.rowid,
               uacc.*
        FROM   igs_uc_app_choices uacc
        WHERE  uacc.app_no = p_appno
        AND    uacc.choice_no = 9;


       -- Cursor to get the OSS Program details for the UCAS course from Course details table.
     CURSOR get_oss_prog_cur (p_course igs_uc_crse_dets.ucas_program_code%TYPE,
                              p_campus igs_uc_crse_dets.ucas_campus%TYPE,
                              p_inst   igs_uc_crse_dets.institute%TYPE,
                              p_system igs_uc_crse_dets.system_code%TYPE) IS
     SELECT oss_program_code,
            oss_program_version,
            oss_location,
            oss_attendance_mode,
            oss_attendance_type
     FROM   igs_uc_crse_dets
     WHERE  System_Code       = p_system
     AND    ucas_program_code = p_course
     AND    ucas_campus       = p_campus
     AND    Institute         = p_inst;




     validate_inst_rec validate_inst%ROWTYPE;
     appl_det_rec get_appl_dets%ROWTYPE;
     old_starz1_rec old_starz1_cur%ROWTYPE;
     l_valid       VARCHAR2(1);

     uc_app_choices_rec uc_app_choices_cur%ROWTYPE;   --arvsrini UCCR008
     oss_prog_rec   get_oss_prog_cur%ROWTYPE;  -- Holds OSS Program details for the UCAS Course.
     curr_inst_rec  curr_inst_cur%ROWTYPE;

     l_oss_program_code    igs_uc_app_choices.oss_program_code%TYPE;
     l_oss_program_version igs_uc_app_choices.oss_program_version%TYPE;
     l_oss_attendance_type igs_uc_app_choices.oss_attendance_type%TYPE;
     l_oss_attendance_mode igs_uc_app_choices.oss_attendance_mode%TYPE;
     l_oss_location        igs_uc_app_choices.oss_location%TYPE;
     l_decision            igs_uc_app_choices.decision%TYPE;
     l_reply               igs_uc_app_choices.reply%TYPE;

     -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
     l_campus_clr          igs_uc_app_clearing.campus%TYPE;
     l_campus_chc          igs_uc_app_choices.campus%TYPE;



  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTARZ1 ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstarz1_rec IN new_ivstarz1_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          g_error_code   := NULL;
          old_starz1_rec := NULL;
          l_valid        := NULL;
          oss_prog_rec := NULL;   -- added wrt UCCR008 arvsrini
          uc_app_choices_rec :=NULL;  -- added wrt UCCR008 arvsrini
          curr_inst_rec := NULL;  -- added wrt UCCR008 arvsrini

          -- log record processing info.
          fnd_message.set_name('IGS','IGS_UC_APPNO_PROC');
          fnd_message.set_token('APPL_NO', TO_CHAR(new_ivstarz1_rec.appno));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- mandatory field validations
          IF new_ivstarz1_rec.appno IS NULL THEN
               g_error_code := '1037';
          END IF;


          IF g_error_code IS NULL THEN
             ----------------------------
             -- AppNo validation
             ----------------------------
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivstarz1_rec.appno, g_error_code);

          END IF;

          IF g_error_code IS NULL THEN

             -- get application details - App ID which is needed while inserting a record.
             -- Record would always be found otherwise the above validation - Error 1000 would have failed.
             appl_det_rec := NULL;  -- initialize
             OPEN  get_appl_dets(new_ivstarz1_rec.appno);
             FETCH get_appl_dets INTO appl_det_rec;
             CLOSE get_appl_dets;

          END IF;


          ---------------------------------------
          -- validate INSTITUTION value from UCAS
          ---------------------------------------
          validate_inst_rec := NULL; -- initialize
          IF g_error_code IS NULL THEN

             IF new_ivstarz1_rec.inst IS NOT NULL THEN
                OPEN  validate_inst (new_ivstarz1_rec.inst);
                FETCH validate_inst INTO validate_inst_rec;

                IF validate_inst%NOTFOUND THEN
                   g_error_code := '1018';
                   CLOSE validate_inst;

                ELSE
                   CLOSE validate_inst;

                   -- System specific validation to check that the Institution value is valid for the system.
                   -- based on the system to which the Application belongs, check that the appropriate
                   -- flag is checked.
                   IF appl_det_rec.system_code = 'U' THEN       -- FTUG/UCAS
                      -- check for UCAS
                      IF validate_inst_rec.ucas <> 'Y' THEN
                         g_error_code := '1018';
                      End IF;

                   ELSIF  appl_det_rec.system_code = 'N' THEN   -- for NMAS
                      -- check for NMAS
                      IF validate_inst_rec.nmas <> 'Y' THEN
                         g_error_code := '1018';
                      End IF;

                   ELSIF  appl_det_rec.system_code = 'G' THEN   -- for GTTR
                      -- check for GTTR
                      IF validate_inst_rec.gttr <> 'Y' THEN
                         g_error_code := '1018';
                      End IF;

                   ELSIF  appl_det_rec.system_code = 'S' THEN   -- for SWAS
                      -- check for SWAS
                      IF validate_inst_rec.swas <> 'Y' THEN
                         g_error_code := '1018';
                      End IF;
                   END IF;

                END IF; -- Institution record found.

             END IF;
          END IF;


          ---------------------------------------
          -- validate COURSE details from UCAS
          ---------------------------------------
          IF g_error_code IS NULL THEN
             l_valid := NULL;  -- initialize
             -- validate only if the course related fields are not null from ucas.
             IF new_ivstarz1_rec.course IS NULL AND
                new_ivstarz1_rec.inst   IS NULL THEN

                  NULL;
             ELSE
                OPEN  validate_course (new_ivstarz1_rec.course, new_ivstarz1_rec.campus, new_ivstarz1_rec.inst, appl_det_rec.system_code);
                FETCH validate_course INTO l_valid;
                CLOSE validate_course;

                IF new_ivstarz1_rec.inst = g_crnt_institute AND l_valid IS NULL THEN
                   g_error_code := '1045';
                END IF;
             END IF;
          END IF;


          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN

             -- Check whether corresponding Application record already exists.
             -- If exists then update else insert.
             OPEN  old_starz1_cur(new_ivstarz1_rec.appno);
             FETCH old_starz1_cur INTO old_starz1_rec;
             CLOSE old_starz1_cur;

             -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
             IF new_ivstarz1_rec.course IS NULL THEN
                l_campus_clr := NULL;
             ELSE
                l_campus_clr := new_ivstarz1_rec.campus;
             END IF;

             IF old_starz1_rec.rowid IS NULL THEN  -- i.e. new record.

               BEGIN
                 -- call the TBH to update the record
                 igs_uc_app_clearing_pkg.insert_row -- IGSXI04B.pls
                 (
                  x_rowid                            => old_starz1_rec.rowid            -- it would be NULL since rec not found.
                 ,x_clearing_app_id                  => old_starz1_rec.clearing_app_id  -- since it would be NULL as rec not found
                 ,x_app_id                           => appl_det_rec.app_id
                 ,x_enquiry_no                       => NULL
                 ,x_app_no                           => new_ivstarz1_rec.appno
                 ,x_date_cef_sent                    => new_ivstarz1_rec.datecefsent
                 ,x_cef_no                           => NVL(new_ivstarz1_rec.cefno ,999999)
                 ,x_central_clearing                 => NVL(new_ivstarz1_rec.centralclearing ,'N')
                 ,x_institution                      => new_ivstarz1_rec.inst
                 ,x_course                           => new_ivstarz1_rec.course
                 ,x_campus                           => l_campus_clr -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
                 ,x_entry_month                      => new_ivstarz1_rec.entrymonth
                 ,x_entry_year                       => new_ivstarz1_rec.entryyear
                 ,x_entry_point                      => new_ivstarz1_rec.entrypoint
                 ,x_result                           => new_ivstarz1_rec.result
                 ,x_cef_received                     => 'N'
                 ,x_clearing_app_source              => 'O'
                 ,x_imported                         => 'Y'
                 ,x_mode                             => 'R'
                 );

               EXCEPTION
                   WHEN OTHERS THEN
                      g_error_code := '9999';
                      fnd_file.put_line(fnd_file.log, SQLERRM);
               END;


             ELSE  -- update

               BEGIN
                  -- call the TBH to update the record
                 igs_uc_app_clearing_pkg.update_row -- IGSXI04B.pls
                 (
                  x_rowid                            => old_starz1_rec.rowid
                 ,x_clearing_app_id                  => old_starz1_rec.clearing_app_id
                 ,x_app_id                           => old_starz1_rec.app_id
                 ,x_enquiry_no                       => old_starz1_rec.enquiry_no
                 ,x_app_no                           => old_starz1_rec.app_no
                 ,x_date_cef_sent                    => new_ivstarz1_rec.datecefsent
                 ,x_cef_no                           => NVL(new_ivstarz1_rec.cefno ,999999)
                 ,x_central_clearing                 => NVL(new_ivstarz1_rec.centralclearing ,'N')
                 ,x_institution                      => new_ivstarz1_rec.inst
                 ,x_course                           => new_ivstarz1_rec.course
                 ,x_campus                           => l_campus_clr -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
                 ,x_entry_month                      => new_ivstarz1_rec.entrymonth
                 ,x_entry_year                       => new_ivstarz1_rec.entryyear
                 ,x_entry_point                      => new_ivstarz1_rec.entrypoint
                 ,x_result                           => new_ivstarz1_rec.result
                 ,x_cef_received                     => old_starz1_rec.cef_received
                 ,x_clearing_app_source              => old_starz1_rec.clearing_app_source
                 ,x_imported                         => 'Y'
                 ,x_mode                             => 'R'
                 );


               EXCEPTION
                  WHEN OTHERS THEN
                     g_error_code := '9998';
                     fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

             END IF; -- insert / update


     -- added following code to udpdate igs_uc_app_choices for records with choice no=9 w.r.t. build UCCR008 bug#3239860

     OPEN  curr_inst_cur(appl_det_rec.system_code);
     FETCH curr_inst_cur INTO curr_inst_rec;
     CLOSE curr_inst_cur;

     -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
     IF curr_inst_rec.current_inst_code = new_ivstarz1_rec.inst THEN

             OPEN  uc_app_choices_cur(new_ivstarz1_rec.appno);
             FETCH uc_app_choices_cur INTO uc_app_choices_rec;
             CLOSE uc_app_choices_cur;

     END IF;

     IF g_error_code IS NULL THEN

     IF uc_app_choices_rec.rowid IS NOT NULL THEN



                IF new_ivstarz1_rec.course IS NULL THEN
                   l_oss_program_code    := uc_app_choices_rec.oss_program_code;
                   l_oss_program_version := uc_app_choices_rec.oss_program_version;
                   l_oss_attendance_type := uc_app_choices_rec.oss_attendance_type;
                   l_oss_attendance_mode := uc_app_choices_rec.oss_attendance_mode;
                   l_oss_location        := uc_app_choices_rec.oss_location;
                ELSE
                       -- Checking whether the UCAS Program details have been modified at UCAS End.
                        IF new_ivstarz1_rec.course <> uc_app_choices_rec.ucas_program_code OR
                         new_ivstarz1_rec.campus <> uc_app_choices_rec.campus            OR
                         new_ivstarz1_rec.inst   <> uc_app_choices_rec.institute_code  THEN

                         -- Derive the OSS Program details for the new/updated UCAS Course.
                           OPEN get_oss_prog_cur (new_ivstarz1_rec.course,  new_ivstarz1_rec.campus,
                                                new_ivstarz1_rec.inst,    uc_app_choices_rec.system_code);
                           FETCH get_oss_prog_cur INTO oss_prog_rec;

                              IF  new_ivstarz1_rec.inst = g_crnt_institute AND get_oss_prog_cur%NOTFOUND THEN
                                g_error_code := '1045';  -- UCAS Course not found

                              END IF;
                            CLOSE get_oss_prog_cur;

                        ELSE
                        -- i.e. If UCAS Course details have not changed.
                        -- Retain the existing OSS Program details for this record in App Choices table.

                        -- copying existing values for the record to the program record variable.
                        oss_prog_rec.oss_program_code     :=  uc_app_choices_rec.oss_program_code    ;
                        oss_prog_rec.oss_program_version  :=  uc_app_choices_rec.oss_program_version ;
                        oss_prog_rec.oss_attendance_type  :=  uc_app_choices_rec.oss_attendance_type ;
                        oss_prog_rec.oss_attendance_mode  :=  uc_app_choices_rec.oss_attendance_mode ;
                        oss_prog_rec.oss_location         :=  uc_app_choices_rec.oss_location        ;

                        END IF;
                   l_oss_program_code    := oss_prog_rec.oss_program_code;
                   l_oss_program_version := oss_prog_rec.oss_program_version;
                   l_oss_attendance_type := oss_prog_rec.oss_attendance_type;
                   l_oss_attendance_mode := oss_prog_rec.oss_attendance_mode;
                   l_oss_location        := oss_prog_rec.oss_location;
                END IF;

                IF new_ivstarz1_rec.result IS NULL THEN
                    l_decision := uc_app_choices_rec.decision;
                    l_reply    := uc_app_choices_rec.reply;
                ELSIF new_ivstarz1_rec.result = 'A' THEN
                    l_decision := 'U';
                    l_reply := 'F';
                END IF;


           IF g_error_code IS NULL THEN

               -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
               IF new_ivstarz1_rec.course IS NULL THEN
                    l_campus_chc := uc_app_choices_rec.campus;
               ELSE
                    l_campus_chc := new_ivstarz1_rec.campus;
               END IF;

               BEGIN
                  -- call the TBH to update the record
                 igs_uc_app_choices_pkg.update_row
                 (
                        x_rowid                                 => uc_app_choices_rec.rowid,
                        x_app_choice_id                         => uc_app_choices_rec.app_choice_id,
                        x_app_id                                => uc_app_choices_rec.app_id,
                        x_app_no                                => uc_app_choices_rec.app_no,
                        x_choice_no                             => uc_app_choices_rec.choice_no,
                        x_last_change                           => uc_app_choices_rec.last_change,
                        x_institute_code                        => uc_app_choices_rec.institute_code,
                        x_ucas_program_code                     => NVL(new_ivstarz1_rec.course, uc_app_choices_rec.ucas_program_code),
                        x_oss_program_code                      => l_oss_program_code   ,
                        x_oss_program_version                   => l_oss_program_version,
                        x_oss_attendance_type                   => l_oss_attendance_type,
                        x_oss_attendance_mode                   => l_oss_attendance_mode,
                        x_campus                                => l_campus_chc, -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
                        x_oss_location                          => l_oss_location,
                        x_faculty                               => NVL(new_ivstarz1_rec.faculty, uc_app_choices_rec.faculty),
                        x_entry_year                            => NVL(new_ivstarz1_rec.entryyear, uc_app_choices_rec.entry_year),
                        x_entry_month                           => NVL(new_ivstarz1_rec.entrymonth, uc_app_choices_rec.entry_month),
                        x_point_of_entry                        => NVL(new_ivstarz1_rec.entrypoint, uc_app_choices_rec.point_of_entry),
                        x_home                                  => uc_app_choices_rec.home,
                        x_deferred                              => uc_app_choices_rec.deferred,
                        x_route_b_pref_round                    => uc_app_choices_rec.route_b_pref_round,
                        x_route_b_actual_round                  => uc_app_choices_rec.route_b_actual_round,
                        x_condition_category                    => uc_app_choices_rec.condition_category,
                        x_condition_code                        => uc_app_choices_rec.condition_code,
                        x_decision                              => l_decision,
                        x_decision_date                         => NVL(uc_app_choices_rec.decision_date,SYSDATE),
                        x_decision_number                       => uc_app_choices_rec.decision_number,
                        x_reply                                 => l_reply,
                        x_summary_of_cond                       => uc_app_choices_rec.summary_of_cond,
                        x_choice_cancelled                      => uc_app_choices_rec.choice_cancelled,
                        x_action                                => uc_app_choices_rec.action,
                        x_substitution                          => uc_app_choices_rec.substitution ,
                        x_date_substituted                      => uc_app_choices_rec.date_substituted,
                        x_prev_institution                      => uc_app_choices_rec.prev_institution,
                        x_prev_course                           => uc_app_choices_rec.prev_course,
                        x_prev_campus                           => uc_app_choices_rec.prev_campus,
                        x_ucas_amendment                        => uc_app_choices_rec.ucas_amendment,
                        x_withdrawal_reason                     => uc_app_choices_rec.withdrawal_reason,
                        x_offer_course                          => uc_app_choices_rec.offer_course,
                        x_offer_campus                          => uc_app_choices_rec.offer_campus,
                        x_offer_crse_length                     => uc_app_choices_rec.offer_crse_length,
                        x_offer_entry_month                     => uc_app_choices_rec.offer_entry_month,
                        x_offer_entry_year                      => uc_app_choices_rec.offer_entry_year,
                        x_offer_entry_point                     => uc_app_choices_rec.offer_entry_point,
                        x_offer_text                            => uc_app_choices_rec.offer_text,
                        x_mode                                  => 'R',
                        x_export_to_oss_status                  => 'NEW',
                        x_error_code                            => NULL,
                        x_request_id                            => uc_app_choices_rec.request_id,
                        x_batch_id                              => uc_app_choices_rec.batch_id,
                        x_extra_round_nbr                       => uc_app_choices_rec.extra_round_nbr,
                        x_system_code                           => uc_app_choices_rec.system_code,
                        x_part_time                             => uc_app_choices_rec.part_time,
                        x_interview                             => uc_app_choices_rec.interview,
                        x_late_application                      => uc_app_choices_rec.late_application,
                        x_modular                               => uc_app_choices_rec.modular,
                        x_residential                           => uc_app_choices_rec.residential,
                        x_ucas_cycle                            => uc_app_choices_rec.ucas_cycle

                        );



               EXCEPTION
                  WHEN OTHERS THEN
                     g_error_code := '9998';
                     fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            END IF; -- error code check

         END IF;
        END IF;

      END IF; -- main processing




        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_starz1_cur%ISOPEN THEN
                 CLOSE old_starz1_cur;
              END IF;

              IF validate_inst%ISOPEN THEN
                 CLOSE validate_inst;
              END IF;

              IF validate_Course%ISOPEN THEN
                 CLOSE validate_Course;
              END IF;

              IF get_appl_dets%ISOPEN THEN
                 CLOSE get_appl_dets;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_istarz1_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivstarz1_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_istarz1_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivstarz1_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTARZ1', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTARZ1'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstarz1;





  PROCEDURE process_ivstarz2  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing ivstarz2 i.e. Applicant
                         Clearing Round info. details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ******************************************************************/

     CURSOR new_ivstarz2_cur IS
     SELECT ivstz2.rowid,
            ivstz2.*
     FROM   igs_uc_istarz2_ints ivstz2
     WHERE  ivstz2.record_status = 'N';

     -- check for corresponding record in main table.
     CURSOR old_starz2_cur(p_appno igs_uc_app_clr_rnd.app_no%TYPE,
                           p_course igs_uc_app_clr_rnd.ucas_program_code%TYPE,
                           p_campus igs_uc_app_clr_rnd.ucas_campus%TYPE,
                           p_inst   igs_uc_app_clr_rnd.institution%TYPE,
                           p_system igs_uc_app_clr_rnd.system_code%TYPE ) IS
     SELECT uaclr.rowid,
            uaclr.*
     FROM   igs_uc_app_clr_rnd uaclr
     WHERE  uaclr.app_no = p_appno
     AND    uaclr.ucas_program_code = p_course
     AND    uaclr.ucas_campus       = p_campus
     AND    uaclr.institution       = p_inst
     AND    uaclr.system_code       = p_system;



     -- get the system and app_id to be populated into App Choices
     CURSOR get_appl_dets (p_appno igs_uc_applicants.app_no%TYPE) IS
     SELECT app_id,
            system_code
     FROM   igs_uc_applicants
     WHERE  app_no = p_appno;



     -- check for corresponding Parent record in App Clearing table.
     CURSOR validate_clearing_cur(p_appno igs_uc_app_clearing.app_no%TYPE) IS
     SELECT clearing_app_id
     FROM   igs_uc_app_clearing
     WHERE  app_no = p_appno;


     -- validate Institution value
     CURSOR validate_inst (p_inst igs_uc_app_clearing.institution%TYPE) IS
     SELECT ucas, gttr, nmas, swas
     FROM   igs_uc_com_inst
     WHERE  inst = p_inst;


     -- validate Course value/get OSS Program details
     CURSOR validate_Course (p_course igs_uc_istarz2_ints.course%TYPE,
                             p_campus igs_uc_istarz2_ints.campus%TYPE,
                             p_inst   igs_uc_istarz2_ints.inst%TYPE,
                             p_system igs_uc_crse_dets.system_code%TYPE) IS
     SELECT oss_program_code,
            oss_program_version,
            oss_attendance_type,
            oss_attendance_mode,
            oss_location
     FROM   igs_uc_crse_dets
     WHERE  ucas_program_code = p_course
     AND    institute         = p_inst
     AND    ucas_campus       = p_campus
     AND    system_code       = p_system;



     validate_Course_rec validate_course%ROWTYPE;  -- Holding of OSS Course details for a UCAS Course
     validate_inst_rec   validate_inst%ROWTYPE;    -- Holding/validating of Institution details
     appl_det_rec get_appl_dets%ROWTYPE;           -- Holding App ID and System Info. from UCAS Applicants.
     old_starz2_rec old_starz2_cur%ROWTYPE;
     l_valid       VARCHAR2(1);
     l_clearing_id igs_uc_app_clearing.clearing_app_id%TYPE;  -- for holding clearing ID needed while insert

     l_oss_program         igs_uc_app_clr_rnd.oss_program_code%TYPE    ;
     l_oss_program_ver     igs_uc_app_clr_rnd.oss_program_version%TYPE ;
     l_oss_attend_type     igs_uc_app_clr_rnd.oss_attendance_type%TYPE ;
     l_oss_attend_mode     igs_uc_app_clr_rnd.oss_attendance_mode%TYPE ;
     l_oss_location        igs_uc_app_clr_rnd.oss_location%TYPE        ;


  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTARZ2 ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstarz2_rec IN new_ivstarz2_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          g_error_code   := NULL;
          old_starz2_rec := NULL;
          l_valid        := NULL;
          validate_Course_rec := NULL;
          appl_det_rec   := NULL;
          validate_inst_rec := NULL;
          l_clearing_id := NULL;

          -- log record processing info.
         fnd_message.set_name('IGS','IGS_UC_APPNO_ROUND_PROC');
         fnd_message.set_token('APPNO', TO_CHAR(new_ivstarz2_rec.appno));
         fnd_message.set_token('INST', new_ivstarz2_rec.inst);
         fnd_message.set_token('PROGRAM', new_ivstarz2_rec.course);
         fnd_message.set_token('CAMPUS', new_ivstarz2_rec.campus);
         fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- no mandatory field validations as this is an update
          IF new_ivstarz2_rec.appno  IS NULL OR
             new_ivstarz2_rec.course IS NULL OR
             new_ivstarz2_rec.campus IS NULL OR
             new_ivstarz2_rec.inst   IS NULL THEN

                g_error_code := '1037';
          END IF;


          ----------------------------
          -- AppNo validation
          ----------------------------
          IF g_error_code IS NULL THEN
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivstarz2_rec.appno, g_error_code);

          END IF;


          IF g_error_code IS NULL THEN
             -- get application details - App ID which is needed while inserting a record.
             -- Record would always be found otherwise the above validation - Error 1000 would have failed.
             OPEN  get_appl_dets(new_ivstarz2_rec.appno);
             FETCH get_appl_dets INTO appl_det_rec;
             CLOSE get_appl_dets;
          END IF;


          ---------------------------------------
          -- validate INSTITUTION value from UCAS
          ---------------------------------------

          IF g_error_code IS NULL THEN
             IF new_ivstarz2_rec.inst IS NOT NULL THEN
                OPEN  validate_inst (new_ivstarz2_rec.inst);
                FETCH validate_inst INTO validate_inst_rec;

                IF validate_inst%NOTFOUND THEN
                   g_error_code := '1018';
                   CLOSE validate_inst;

                ELSE
                   CLOSE validate_inst;

                   -- System specific validation to check that the Institution value is valid for the system.
                   -- based on the system to which the Application belongs, check that the appropriate
                   -- flag is checked.
                   IF appl_det_rec.system_code = 'U' THEN       -- FTUG/UCAS
                      -- check for UCAS
                      IF validate_inst_rec.ucas <> 'Y' THEN
                         g_error_code := '1018';
                      End IF;

                   ELSIF  appl_det_rec.system_code = 'N' THEN   -- for NMAS
                      -- check for NMAS
                      IF validate_inst_rec.nmas <> 'Y' THEN
                         g_error_code := '1018';
                      End IF;

                   ELSIF  appl_det_rec.system_code = 'G' THEN   -- for GTTR
                      -- check for GTTR
                      IF validate_inst_rec.gttr <> 'Y' THEN
                         g_error_code := '1018';
                      End IF;

                   ELSIF  appl_det_rec.system_code = 'S' THEN   -- for SWAS
                      -- check for SWAS
                      IF validate_inst_rec.swas <> 'Y' THEN
                         g_error_code := '1018';
                      End IF;
                   END IF;

                END IF; -- Institution record found.

             END IF;
          END IF;


          ---------------------------------------
          -- validate COURSE details from UCAS
          ---------------------------------------
          IF g_error_code IS NULL THEN
             -- validate only if the course related fields are not null from ucas.
             IF new_ivstarz2_rec.course IS NOT NULL
                AND new_ivstarz2_rec.campus IS NOT NULL
                AND new_ivstarz2_rec.inst IS NOT NULL THEN

                   OPEN  validate_course (new_ivstarz2_rec.course, new_ivstarz2_rec.campus, new_ivstarz2_rec.inst, appl_det_rec.system_code);
                   FETCH validate_course INTO validate_Course_rec;

                   IF new_ivstarz2_rec.inst = g_crnt_institute AND validate_course%NOTFOUND THEN
                      g_error_code := '1045';
                   END IF;
                   CLOSE validate_course;

             ELSE
                 g_error_code := '1045';  -- invalid course details - key Course related fields not having values.
             END IF;
          END IF;


          ---------------------------------------
          -- validate CLEARING details from UCAS / get clearing_id
          ---------------------------------------

          IF g_error_code IS NULL THEN
             -- validate clearing rec exists
             OPEN validate_clearing_cur (new_ivstarz2_rec.appno);
             FETCH validate_clearing_cur INTO l_clearing_id;

             IF validate_clearing_cur%NOTFOUND THEN
                g_error_code := '1047';  -- no clearing/parent rec exists.
             END IF;
             CLOSE validate_clearing_cur;

          END IF;



          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN

             -- Check whether corresponding record already exists in main table.
             -- If exists then update else insert.
             OPEN  old_starz2_cur(new_ivstarz2_rec.appno, new_ivstarz2_rec.course, new_ivstarz2_rec.campus, new_ivstarz2_rec.inst, appl_det_rec.system_code);
             FETCH old_starz2_cur INTO old_starz2_rec;
             CLOSE old_starz2_cur;


             IF old_starz2_rec.rowid IS NULL THEN  -- i.e. new record.

               BEGIN
                 -- call the TBH to update the record
                 igs_uc_app_clr_rnd_pkg.insert_row -- IGSXI05B.pls
                 (
                  x_rowid                            => old_starz2_rec.rowid
                 ,x_app_clear_round_id               => old_starz2_rec.app_clear_round_id -- since it would be NULL if no rec found.
                 ,x_clearing_app_id                  => l_clearing_id
                 ,x_app_no                           => new_ivstarz2_rec.appno
                 ,x_enquiry_no                       => NULL
                 ,x_round_no                         => NVL(new_ivstarz2_rec.roundno ,1)
                 ,x_institution                      => new_ivstarz2_rec.inst
                 ,x_ucas_program_code                => new_ivstarz2_rec.course
                 ,x_ucas_campus                      => new_ivstarz2_rec.campus
                 ,x_oss_program_code                 => validate_Course_rec.oss_program_code
                 ,x_oss_program_version              => validate_Course_rec.oss_program_version
                 ,x_oss_location                     => validate_Course_rec.oss_location
                 ,x_faculty                          => new_ivstarz2_rec.faculty
                 ,x_accommodation_reqd               => 'N'
                 ,x_round_type                       => new_ivstarz2_rec.roundtype
                 ,x_result                           => new_ivstarz2_rec.result
                 ,x_mode                             => 'R'
                 ,x_oss_attendance_type              => validate_Course_rec.oss_attendance_mode
                 ,x_oss_attendance_mode              => validate_Course_rec.oss_attendance_type
                 ,x_system_code                      => appl_det_rec.system_code
                 );

               EXCEPTION
                   WHEN OTHERS THEN
                      g_error_code := '9999';
                      fnd_file.put_line(fnd_file.log, SQLERRM);
               END;


             ELSE  -- update

               BEGIN
                 -- call the TBH to update the record
                 igs_uc_app_clr_rnd_pkg.update_row -- IGSXI05B.pls
                 (
                  x_rowid                            => old_starz2_rec.rowid
                 ,x_app_clear_round_id               => old_starz2_rec.app_clear_round_id
                 ,x_clearing_app_id                  => old_starz2_rec.clearing_app_id
                 ,x_app_no                           => old_starz2_rec.app_no
                 ,x_enquiry_no                       => old_starz2_rec.enquiry_no
                 ,x_round_no                         => old_starz2_rec.round_no
                 ,x_institution                      => old_starz2_rec.institution
                 ,x_ucas_program_code                => old_starz2_rec.ucas_program_code
                 ,x_ucas_campus                      => old_starz2_rec.ucas_campus
                 ,x_oss_program_code                 => old_starz2_rec.oss_program_code
                 ,x_oss_program_version              => old_starz2_rec.oss_program_version
                 ,x_oss_location                     => old_starz2_rec.oss_location
                 ,x_faculty                          => new_ivstarz2_rec.faculty
                 ,x_accommodation_reqd               => old_starz2_rec.accommodation_reqd
                 ,x_round_type                       => new_ivstarz2_rec.roundtype
                 ,x_result                           => new_ivstarz2_rec.result
                 ,x_mode                             => 'R'
                 ,x_oss_attendance_type              => old_starz2_rec.oss_attendance_type
                 ,x_oss_attendance_mode              => old_starz2_rec.oss_attendance_mode
                 ,x_system_code                      => old_starz2_rec.system_code
                 );


               EXCEPTION
                  WHEN OTHERS THEN
                     g_error_code := '9998';
                     fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

             END IF; -- insert / update

          END IF; -- main processing

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_starz2_cur%ISOPEN THEN
                 CLOSE old_starz2_cur;
              END IF;

              IF validate_clearing_cur%ISOPEN THEN
                 CLOSE validate_clearing_cur;
              END IF;

              IF validate_inst%ISOPEN THEN
                 CLOSE validate_inst;
              END IF;

              IF validate_Course%ISOPEN THEN
                 CLOSE validate_Course;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_istarz2_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivstarz2_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_istarz2_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivstarz2_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTARZ2', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTARZ2'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstarz2;




  PROCEDURE process_ivstarw  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing IVSTARW i.e. Wrong Applicant
                         details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     rbezawad  14-Oct-03    Modified for ucfd209- Substitution Support build bug#2669228.
     jchakrab  11-Nov-2005  Modified for 4697447 - Re-instated applications should not be marked for expunge
    ******************************************************************/

     CURSOR new_ivstarw_cur IS
     SELECT ivstz2.rowid,
            ivstz2.*
     FROM   igs_uc_istarw_ints ivstz2
     WHERE  ivstz2.record_status = 'N';

     -- check for corresponding record in main table.
     CURSOR old_starw_cur(p_appno igs_uc_wrong_app.app_no%TYPE) IS
     SELECT uwap.rowid,
            uwap.*
     FROM   igs_uc_wrong_app uwap
     WHERE  uwap.app_no = p_appno;

     old_starw_rec old_starw_cur%ROWTYPE;

     CURSOR c_reinstate_meaning IS
     SELECT LKUP.MEANING
     FROM IGS_LOOKUP_VALUES LKUP
     WHERE LKUP.LOOKUP_TYPE = 'IGS_UC_APP_WITHDRAWN'
     AND LKUP.LOOKUP_CODE = 'R';

     l_reinstate_meaning       IGS_UC_WRONG_APP.REMARK%TYPE;
     l_expunge_flag            IGS_UC_WRONG_APP.EXPUNGE%TYPE;

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTARW ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    --get the reinstate remark text from IGS_UC_APP_WITHDRAWN lookup
    OPEN c_reinstate_meaning;
    FETCH c_reinstate_meaning INTO l_reinstate_meaning;
    CLOSE c_reinstate_meaning;

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivstarw_rec IN new_ivstarw_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          g_error_code   := NULL;
          old_starw_rec  := NULL;

          -- log record processing info.
         fnd_message.set_name('IGS','IGS_UC_APPNO_PROC');
         fnd_message.set_token('APPL_NO', TO_CHAR(new_ivstarw_rec.appno));
         fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- no mandatory field validations as this is an update
          IF new_ivstarw_rec.appno IS NULL THEN
             g_error_code := '1037';
          END IF;


          ----------------------------
          -- AppNo validation
          ----------------------------
          IF g_error_code IS NULL THEN
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivstarw_rec.appno, g_error_code);

          END IF;


          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN

             -- Check whether corresponding record already exists in main table.
             -- If exists then update else insert.
             OPEN  old_starw_cur(new_ivstarw_rec.appno);
             FETCH old_starw_cur INTO old_starw_rec;
             CLOSE old_starw_cur;

             --prevent expunge when remark is reinstate
             IF UPPER(l_reinstate_meaning) = UPPER(RTRIM(new_ivstarw_rec.remark)) THEN
                 l_expunge_flag := 'N';
             ELSE
                 l_expunge_flag := 'Y';
             END IF;

             IF old_starw_rec.rowid IS NULL THEN  -- i.e. new record.

               BEGIN
                 -- call the TBH to update the record
                 igs_uc_wrong_app_pkg.insert_row -- IGSXI34B.pls
                 (
                  x_rowid                            => old_starw_rec.rowid   -- since it would be NULL if old rec not found
                 ,x_wrong_app_id                     => old_starw_rec.wrong_app_id  -- since it would be NULL if old rec not found
                 ,x_app_no                           => new_ivstarw_rec.appno
                 ,x_miscoded                         => NVL(new_ivstarw_rec.miscoded, 'N')
                 ,x_cancelled                        => NVL(new_ivstarw_rec.cancelled, 'N')
                 ,x_cancel_date                      => new_ivstarw_rec.canceldate
                 ,x_remark                           => new_ivstarw_rec.remark
                 ,x_expunge                          => l_expunge_flag
                 ,x_batch_id                         => NULL
                 ,x_expunged                         => 'N'
                 ,x_mode                             => 'R'
                 ,x_joint_admission_ind              => NVL(new_ivstarw_rec.jointadmission, 'N')
                 ,x_choice1_lost                     => NVL(new_ivstarw_rec.choice1lost, 'N')
                 ,x_choice2_lost                     => NVL(new_ivstarw_rec.choice2lost, 'N')
                 ,x_choice3_lost                     => NVL(new_ivstarw_rec.choice3lost, 'N')
                 ,x_choice4_lost                     => NVL(new_ivstarw_rec.choice4lost, 'N')
                 ,x_choice5_lost                     => NVL(new_ivstarw_rec.choice5lost, 'N')
                 ,x_choice6_lost                     => NVL(new_ivstarw_rec.choice6lost, 'N')
                 ,x_choice7_lost                     => NVL(new_ivstarw_rec.choice7lost, 'N')
                 );

               EXCEPTION
                   WHEN OTHERS THEN
                      g_error_code := '9999';
                      fnd_file.put_line(fnd_file.log, SQLERRM);
               END;


             ELSE  -- update

               BEGIN
                  -- call the TBH to update the record
                 igs_uc_wrong_app_pkg.update_row -- IGSXI34B.pls
                 (
                  x_rowid                            => old_starw_rec.rowid
                 ,x_wrong_app_id                     => old_starw_rec.wrong_app_id
                 ,x_app_no                           => old_starw_rec.app_no
                 ,x_miscoded                         => NVL(new_ivstarw_rec.miscoded, 'N')
                 ,x_cancelled                        => NVL(new_ivstarw_rec.cancelled, 'N')
                 ,x_cancel_date                      => new_ivstarw_rec.canceldate
                 ,x_remark                           => new_ivstarw_rec.remark
                 ,x_expunge                          => l_expunge_flag
                 ,x_batch_id                         => old_starw_rec.batch_id
                 ,x_expunged                         => 'N'
                 ,x_mode                             => 'R'
                 ,x_joint_admission_ind              => NVL(new_ivstarw_rec.jointadmission, 'N')
                 ,x_choice1_lost                     => NVL(new_ivstarw_rec.choice1lost, 'N')
                 ,x_choice2_lost                     => NVL(new_ivstarw_rec.choice2lost, 'N')
                 ,x_choice3_lost                     => NVL(new_ivstarw_rec.choice3lost, 'N')
                 ,x_choice4_lost                     => NVL(new_ivstarw_rec.choice4lost, 'N')
                 ,x_choice5_lost                     => NVL(new_ivstarw_rec.choice5lost, 'N')
                 ,x_choice6_lost                     => NVL(new_ivstarw_rec.choice6lost, 'N')
                 ,x_choice7_lost                     => NVL(new_ivstarw_rec.choice7lost, 'N')
                 );


               EXCEPTION
                  WHEN OTHERS THEN
                     g_error_code := '9998';
                     fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

             END IF; -- insert / update

          END IF; -- main processing

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_starw_cur%ISOPEN THEN
                 CLOSE old_starw_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_istarw_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivstarw_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_istarw_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivstarw_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTARW', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTARW'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstarw;




 PROCEDURE process_ivreference  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing IVREFERENCE details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber   12-Jul-05     Modified for UC315 - UCAS Support 2006
                            to include column PREDICTED_GRADES
    ******************************************************************/

     -- get the records from interface tables where status is NEW.
     CURSOR new_ivrefer_cur IS
     SELECT irefr.rowid,
            irefr.*
     FROM   igs_uc_irefrnc_ints irefr
     WHERE  irefr.record_status = 'N';

     -- check for corresponding record in main table.
     CURSOR old_refer_cur(p_appno   igs_uc_app_referees.app_no%TYPE,
                          p_referee igs_uc_app_referees.referee_name%TYPE) IS
     SELECT uapref.rowid,
            uapref.*
     FROM   igs_uc_app_referees uapref
     WHERE  uapref.app_no = p_appno
     AND    uapref.referee_name = p_referee;

     old_refer_rec old_refer_cur%ROWTYPE;


     --- added for support CLOB insert/update
     CURSOR old_clob_cur(cp_rowid VARCHAR2) IS
     SELECT uapref.statement
     FROM   igs_uc_app_referees uapref
     WHERE  rowid = cp_rowid
     FOR UPDATE NOWAIT;

     l_old_clob_data igs_uc_app_referees.statement%TYPE;

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVREFERENCE ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ireference_rec IN new_ivrefer_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          g_error_code   := NULL;
          old_refer_rec  := NULL;


          -- log record processing info.
          fnd_message.set_name('IGS','IGS_UC_APPNO_REFEREE_PROC');
          fnd_message.set_token('APPNO', TO_CHAR(new_ireference_rec.appno));
          fnd_message.set_token('REFEREE', new_ireference_rec.refereename);
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- no mandatory field validations as this is an update
          IF new_ireference_rec.appno IS NULL THEN
             g_error_code := '1037';
          END IF;


          ----------------------------
          -- AppNo validation
          ----------------------------
          IF g_error_code IS NULL THEN
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_applicant as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ireference_rec.appno, g_error_code);

          END IF;


          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN

             -- Check whether corresponding record already exists in main table.
             -- If exists then update else insert.
             OPEN  old_refer_cur(new_ireference_rec.appno, new_ireference_rec.refereename);
             FETCH old_refer_cur INTO old_refer_rec;
             CLOSE old_refer_cur;


             IF old_refer_rec.rowid IS NULL THEN  -- i.e. new record.

               BEGIN
                 -- call the TBH to update the record
                 igs_uc_app_referees_pkg.insert_row -- IGSXI49B.pls
                 (
                   x_rowid            => old_refer_rec.rowid
                  ,x_app_no           => new_ireference_rec.appno
                  ,x_referee_name     => new_ireference_rec.refereename
                  ,x_referee_post     => new_ireference_rec.refereepost
                  ,x_estab_name       => new_ireference_rec.estabname
                  ,x_address1         => new_ireference_rec.address1
                  ,x_address2         => new_ireference_rec.address2
                  ,x_address3         => new_ireference_rec.address3
                  ,x_address4         => new_ireference_rec.address4
                  ,x_telephone        => new_ireference_rec.telephone
                  ,x_fax              => new_ireference_rec.fax
                  ,x_email            => new_ireference_rec.email
                  ,x_statement        => EMPTY_CLOB()
                  ,x_predicted_grades => new_ireference_rec.predictedgrades
                  ,x_mode             => 'R'
                 );

                 OPEN  old_clob_cur(old_refer_rec.rowid);
                 FETCH old_clob_cur INTO l_old_clob_data;

                 -- open the CLOB and write the LONG data to it
                 dbms_lob.open(l_old_clob_data, dbms_lob.lob_readwrite);
                 dbms_lob.write(l_old_clob_data, LENGTH(new_ireference_rec.statement), 1, new_ireference_rec.statement);
                 dbms_lob.close(l_old_clob_data);
                 CLOSE old_clob_cur;

               EXCEPTION
                   WHEN OTHERS THEN

                       IF old_clob_cur%ISOPEN THEN
                          CLOSE old_clob_cur;
                       END IF;

                       g_error_code := '9999';
                       fnd_file.put_line(fnd_file.log, SQLERRM);
               END;


             ELSE  -- update

               BEGIN
                  -- call the TBH to update the record
                 igs_uc_app_referees_pkg.update_row -- IGSXI49B.pls
                 (
                   x_rowid            => old_refer_rec.rowid
                  ,x_app_no           => old_refer_rec.app_no
                  ,x_referee_name     => old_refer_rec.referee_name
                  ,x_referee_post     => new_ireference_rec.refereepost
                  ,x_estab_name       => new_ireference_rec.estabname
                  ,x_address1         => new_ireference_rec.address1
                  ,x_address2         => new_ireference_rec.address2
                  ,x_address3         => new_ireference_rec.address3
                  ,x_address4         => new_ireference_rec.address4
                  ,x_telephone        => new_ireference_rec.telephone
                  ,x_fax              => new_ireference_rec.fax
                  ,x_email            => new_ireference_rec.email
                  ,x_statement        => EMPTY_CLOB()
                  ,x_predicted_grades => new_ireference_rec.predictedgrades
                  ,x_mode             => 'R'
                 );

                 -- get the record for which the CLOB field has to be updated.
                 OPEN  old_clob_cur(old_refer_rec.rowid);
                 FETCH old_clob_cur INTO l_old_clob_data;

                 -- open the CLOB and write the LONG data to it
                 dbms_lob.open(l_old_clob_data, dbms_lob.lob_readwrite);
                 dbms_lob.write(l_old_clob_data, LENGTH(new_ireference_rec.statement), 1, new_ireference_rec.statement);
                 dbms_lob.close(l_old_clob_data);
                 CLOSE old_clob_cur;

               EXCEPTION
                  WHEN OTHERS THEN

                    IF old_clob_cur%ISOPEN THEN
                       CLOSE old_clob_cur;
                    END IF;

                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);

               END;

             END IF; -- insert / update

          END IF; -- main processing

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_refer_cur%ISOPEN THEN
                 CLOSE old_refer_cur;
              END IF;

              IF old_clob_cur%ISOPEN THEN
                 CLOSE old_clob_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_irefrnc_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ireference_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_irefrnc_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ireference_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVREFERENCE', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVREFERENCE'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivreference;





  PROCEDURE process_ivformquals  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing IVFORMQUALS details from UCAS.
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    29-Jul-05    Removed mandatory validation for field qualid
                            and changed logical primary key to
                            appno, qual_type and title
    ******************************************************************/

     -- get the records from interface tables where status is NEW.
     CURSOR new_ivfrmqual_cur IS
     SELECT ivfq.rowid,
            ivfq.*
     FROM   igs_uc_ifrmqul_ints ivfq
     WHERE  ivfq.record_status = 'N';

     -- check for corresponding record in main table.
     CURSOR old_frmqual_cur(p_appno    igs_uc_form_quals.app_no%TYPE,
                            p_qualtype igs_uc_form_quals.qual_type%TYPE,
                            p_title    igs_uc_form_quals.title%TYPE) IS
     SELECT ufq.rowid,
            ufq.*
     FROM   igs_uc_form_quals ufq
     WHERE  ufq.app_no  = p_appno
     AND    ufq.qual_type = p_qualtype
     AND    ufq.title = p_title;

     old_frmqual_rec old_frmqual_cur%ROWTYPE;

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVFORMQUALS ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_ivfrmqual_rec IN new_ivfrmqual_cur
    LOOP

      BEGIN
          -- initialize record level variables.
          g_error_code     := NULL;
          old_frmqual_rec  := NULL;

          -- log record processing info.
          fnd_message.set_name('IGS','IGS_UC_APPNO_QUAL_PROC');
          fnd_message.set_token('APPNO', TO_CHAR(new_ivfrmqual_rec.appno));
          fnd_message.set_token('QUAL', TO_CHAR(new_ivfrmqual_rec.qualid));
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- no mandatory field validations as this is an update
          IF new_ivfrmqual_rec.appno IS NULL THEN
             g_error_code := '1037';
          END IF;


          ----------------------------
          -- AppNo validation
          ----------------------------
          IF g_error_code IS NULL THEN
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivfrmqual_rec.appno, g_error_code);

          END IF;


          ----------------------------
          -- MAIN PROCESSING Begins
          ----------------------------
          IF g_error_code IS NULL THEN

             -- Check whether corresponding record already exists in main table.
             -- If exists then update else insert.
             OPEN  old_frmqual_cur(new_ivfrmqual_rec.appno, new_ivfrmqual_rec.qualtype, new_ivfrmqual_rec.title);
             FETCH old_frmqual_cur INTO old_frmqual_rec;
             CLOSE old_frmqual_cur;


             IF old_frmqual_rec.rowid IS NULL THEN  -- i.e. new record.

               BEGIN

                 -- call the TBH to Insert the record
                 igs_uc_form_quals_pkg.insert_row -- IGSXI51B.pls
                 (
                   x_rowid       => old_frmqual_rec.rowid
                  ,x_app_no      => new_ivfrmqual_rec.appno
                  ,x_qual_id     => new_ivfrmqual_rec.qualid
                  ,x_qual_type   => new_ivfrmqual_rec.qualtype
                  ,x_award_body  => new_ivfrmqual_rec.awardbody
                  ,x_title       => new_ivfrmqual_rec.title
                  ,x_grade       => new_ivfrmqual_rec.grade
                  ,x_qual_date   => new_ivfrmqual_rec.qualdate
                  ,x_mode        => 'R'
                 );

               EXCEPTION
                   WHEN OTHERS THEN
                      g_error_code := '9999';
                      fnd_file.put_line(fnd_file.log, SQLERRM);

               END;


             ELSE  -- update

               BEGIN
                 igs_uc_form_quals_pkg.update_row -- IGSXI51B.pls
                 (
                   x_rowid       => old_frmqual_rec.rowid
                  ,x_app_no      => old_frmqual_rec.app_no
                  ,x_qual_id     => new_ivfrmqual_rec.qualid
                  ,x_qual_type   => old_frmqual_rec.qual_type
                  ,x_award_body  => new_ivfrmqual_rec.awardbody
                  ,x_title       => old_frmqual_rec.title
                  ,x_grade       => new_ivfrmqual_rec.grade
                  ,x_qual_date   => new_ivfrmqual_rec.qualdate
                  ,x_mode        => 'R'
                 );

               EXCEPTION
                  WHEN OTHERS THEN
                     g_error_code := '9998';
                     fnd_file.put_line(fnd_file.log, SQLERRM);

               END;

             END IF; -- insert / update

          END IF; -- main processing

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_frmqual_cur%ISOPEN THEN
                 CLOSE old_frmqual_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

             UPDATE igs_uc_ifrmqul_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_ivfrmqual_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);

             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

             UPDATE igs_uc_ifrmqul_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_ivfrmqual_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVFORMQUALS', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVFORMQUALS'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivformquals;



  PROCEDURE process_ivstarpqr  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing IVSTARPQR (Applicant Results) details from UCAS.
                         For this view the data coming from Hercules is different from the data that comes from
                         Marvin. From Hercules Subject ID value comes. Based on the subject ID, other field values like
                         Subject Code, year, sitting, awarding body etc is derived.
                         However, data coming from Marvin does not have subject ID value. Instead fields
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     pmarada  12-aug-2003  Changed the l_proc_reqd valiable initial value to Y, moved the validate_appno
                           validation to first place. bug 3091859, 3092173
     dsridhar 21-AUG-2003  Bug No: 3106972. Added the code to assign the value for subject id when values
                           for the cursor c_subjectid is found.
     dsridhar 25-AUG-2003  Bug No: 3108657.  The year data in COM_EBL table is 4 digits whereas the transaction
                           data coming from UCAS has 2 digits. Hence need to convert 2 digit year to 4 digit
                           year. If the year is between 50 and 99, 1900 is added. If the year is between 00 and
                           49, 2000 is added.
     dsridhar 27-AUG-2003  Bug No. 3114787. In procedure process_ivstarpqr even if a sigle record fails then all
                           the processing is rolled back.
     smaddali 3-sep-03     Bug No: 3122898. 1. making successful record_status = L ,
                           2. Making error_code = 2001 for successful records with error in one qualification
                           3. For *P marvin records making eblresult = grade1 + grade2
    ******************************************************************/

     -- get the records from interface tables where status is NEW.
     CURSOR new_ivstarpqr_cur (cp_appno igs_uc_istrpqr_ints.appno%TYPE) IS
     SELECT ivpqr.rowid,
            ivpqr.*
     FROM   igs_uc_istrpqr_ints ivpqr
     WHERE  ivpqr.record_status = 'N'
     AND    ivpqr.appno = cp_appno ;



     -- check for corresponding record in main table.
     CURSOR old_starpqr_cur(p_appno   igs_uc_app_results.app_no%TYPE,
                            p_sub_id  igs_uc_app_results.subject_id%TYPE) IS
     SELECT uapr.rowid,
            uapr.*
     FROM   igs_uc_app_results uapr
     WHERE  uapr.app_no     = p_appno
     AND    uapr.subject_id = p_sub_id;


     -- get the system and app_id for the Application from UCAS Applicants table.
     CURSOR get_appl_dets (p_appno igs_uc_applicants.app_no%TYPE) IS
     SELECT app_id,
            system_code
     FROM   igs_uc_applicants
     WHERE  app_no = p_appno;

     -- get the unique list of appno that would be processed
     CURSOR new_appl_cur IS
     SELECT DISTINCT appno
     FROM   igs_uc_istrpqr_ints
     WHERE  record_status = 'N';

     -- get all the records for an applicant
     CURSOR get_appno_cur(cp_appno   igs_uc_app_results.app_no%TYPE) IS
     SELECT rowid
     FROM   igs_uc_app_results
     WHERE  app_no = cp_appno;

     CURSOR  validate_subject (p_subject igs_uc_app_results.subject_id%TYPE) IS
     SELECT rowid
           ,subject_id
           ,year
           ,sitting
           ,awarding_body
           ,external_ref
           ,exam_level
           ,title
           ,subject_code
           ,imported
     FROM   igs_uc_com_ebl_subj
     WHERE  subject_id = p_subject;


    -- For data coming from Marvin INterface
    CURSOR c_map_exam_ebl(cp_exam_board_code IGS_UC_MAP_EBL_QUAL.exam_board_code%TYPE ,
                          cp_ebl_code  IGS_UC_MAP_EBL_QUAL.ebl_format%TYPE ) IS
    SELECT exam_level ,
           awarding_body,
           conv_ebl_format
    FROM   igs_uc_map_ebl_qual
    WHERE  exam_board_code = cp_exam_board_code
    AND    ebl_format      = cp_ebl_code
    AND    closed_ind      = 'N'  ;

    c_map_exam_ebl_rec c_map_exam_ebl%ROWTYPE ;


    -- For deriving subject ID For data coming from Marvin INterface
    CURSOR c_subjectid ( cp_year Igs_uc_com_ebl_subj.year%TYPE ,
                         cp_sitting Igs_uc_com_ebl_subj.sitting%TYPE ,
                         cp_awarding_body Igs_uc_com_ebl_subj.awarding_body%TYPE ,
                         cp_exam_level Igs_uc_com_ebl_subj.exam_level%TYPE ,
                         cp_ebl_subject Igs_uc_com_ebl_subj.subject_code%TYPE ) IS
    SELECT ebl.subject_id
    FROM   Igs_uc_com_ebl_subj ebl , igs_uc_ref_subj ref
    WHERE  ebl.subject_code = ref.subj_code
    AND    ebl.year = cp_year
    AND    ebl.sitting = cp_sitting
    AND    ebl.awarding_body = cp_awarding_body
    AND    ebl.exam_level = cp_exam_level
    AND    ref.ebl_subj = cp_ebl_subject
    ORDER BY ebl.external_ref DESC ;

     -- variables
     appl_det_rec     get_appl_dets%ROWTYPE;
     old_starpqr_rec  old_starpqr_cur%ROWTYPE;
     subject_rec      validate_subject%ROWTYPE;
     l_proc_reqd   VARCHAR2(1);
     l_gen_ebl_format igs_uc_istrpqr_ints.eblsubject%TYPE;
     l_conv_ebl_code  igs_uc_istrpqr_ints.eblsubject%TYPE;
     l_subjectid      igs_uc_istrpqr_ints.subjectid%TYPE;
     l_appno_failed   BOOLEAN ;
  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    g_error_code := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'IVSTARPQR ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Bug No. 3114787. Code added to so that all the records for an applicant get processed or none
    -- the processing is rolled back.
    -- LOOP through the Applications to be processed
    FOR new_appl_rec IN new_appl_cur LOOP

       -- initialise flag that this applicant has not failed any validation
       l_appno_failed  := FALSE;

       -- initialise error_code = NULL for all interface records of this applicant in status NEW
       UPDATE igs_uc_istrpqr_ints
       SET    error_code    = NULL
       WHERE  record_status = 'N' AND appno = new_appl_rec.appno ;

       -- Delete all the qualification records for the applicant before inserting.
       FOR get_appno_rec IN get_appno_cur(new_appl_rec.appno)
       LOOP
            igs_uc_app_results_pkg.delete_row(get_appno_rec.rowid);
       END LOOP;

       -- Get all the reocords from interface table with status = 'N'
       FOR new_ivstarpqr_rec IN new_ivstarpqr_cur(new_appl_rec.appno)
       LOOP

         BEGIN
            -- initialize record level variables.
            g_error_code     := NULL;
            l_proc_reqd      := 'Y';
            l_gen_ebl_format := NULL;
            l_conv_ebl_code  := NULL;
            l_subjectid      := NULL;

            -- log record processing info.
            fnd_message.set_name('IGS','IGS_UC_APPNO_SUBJ_PROC');
            fnd_message.set_token('APPNO', TO_CHAR(new_ivstarpqr_rec.appno));
            fnd_message.set_token('SUBJ',  TO_CHAR(new_ivstarpqr_rec.subjectid));
            fnd_file.put_line(fnd_file.log, fnd_message.get);

            ----------------------------
            -- AppNo validation
            ----------------------------
             -- validate Applicant record details in UCAS Applicants table.
             -- This is because record gets inserted into igs_uc_app_choices as part of
             -- IVSTARN processing and hence at this stage the record must exist.
             validate_applicant (new_ivstarpqr_rec.appno, g_error_code);
            -- If applicant exists in uc_applicants table then Proceed

            ----------------------------
             -- Bug No. 3108657. The year data in COM_EBL table is 4 digits whereas the transaction data coming from UCAS
            -- has 2 digits. Hence need to convert 2 digit year to 4 digit year.
             -- If the year is between 50 and 99, 1900 is added.
             -- If the year is between 00 and 49, 2000 is added.
                  ----------------------------
             IF new_ivstarpqr_rec.yearofexam >= 50 AND new_ivstarpqr_rec.yearofexam <= 99 THEN
                        new_ivstarpqr_rec.yearofexam := new_ivstarpqr_rec.yearofexam + 1900;
             ELSIF new_ivstarpqr_rec.yearofexam >= 0 AND new_ivstarpqr_rec.yearofexam <= 49 THEN
                        new_ivstarpqr_rec.yearofexam := new_ivstarpqr_rec.yearofexam + 2000;
             END IF;


            IF g_error_code IS NULL THEN
            --------------------------------------------------------------------
            -- PROCESSING NEEDED EXCLUSIVELY FOR DATA RCVD FROM MARVIN INTERFACE
            -- Records populated through Marvin Interface is identified as it
            -- would have a value of 'P' or 'R' in Marvin Type field.
            -- For Hercules this field would be NULL.
            --------------------------------------------------------------------
              IF new_ivstarpqr_rec.marvin_type IS NOT NULL THEN

                 -- Do not process for '*R' record with Match Ind = 'N'.
                 IF new_ivstarpqr_rec.Matchind = 'N' AND new_ivstarpqr_rec.marvin_type = 'R' THEN
                            l_proc_reqd := 'N';
                 ELSE

                          -- Get the generic ebl format for the ebl_code given in the flat file
                          -- It can be in K1N/K2N/K3N/K4N format
                          l_gen_ebl_format :=  TRANSLATE(new_ivstarpqr_rec.eblsubject, '0123456789', 'NNNNNNNNNN') ;


                          IF l_gen_ebl_format = 'KNN' AND  SUBSTR(new_ivstarpqr_rec.eblsubject,2,1) IN ('1','2','3','4') THEN
                               l_gen_ebl_format := 'K' ||  SUBSTR(new_ivstarpqr_rec.eblsubject,2,1) || 'N' ;

                          ELSE
                               -- Else it can be in ANN/NAN/NNA format . If exam board is B/F/E/I/Q/S/Y/Z  then take format as
                               -- XXX because  seed data for these exam levels exists only for ebl format XXX
                               l_gen_ebl_format :=  TRANSLATE(new_ivstarpqr_rec.eblsubject, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ',  'NNNNNNNNNNAAAAAAAAAAAAAAAAAAAAAAAAAA') ;

                               IF l_gen_ebl_format NOT IN ('ANN','NAN','NNA') OR  new_ivstarpqr_rec.examboard IN ('B','F','E','I','Q','S','Y','Z') THEN
                                  -- If it is not in ANN/NAN/NNA format then take the generic format XXX
                                  l_gen_ebl_format := 'XXX' ;
                               END IF ;
                          END IF ;


                          -- Get the awarding body and exam level  corresponding to the exam board code and generic ebl code                  --    from the seeded table
                          -- If no seeded record found then log error message and skip this transaction , else continue
                          c_map_exam_ebl_rec := NULL;
                          OPEN c_map_exam_ebl (new_ivstarpqr_rec.examboard, l_gen_ebl_format ) ;
                          FETCH c_map_exam_ebl INTO c_map_exam_ebl_rec ;

                          IF c_map_exam_ebl%NOTFOUND THEN
                                    CLOSE c_map_exam_ebl ;
                                    g_error_code := '1059';
                                    fnd_message.set_name( 'IGS','IGS_UC_NO_EBL_MAP_REC') ;
                                    fnd_message.set_token ('EXAM_BRD', new_ivstarpqr_rec.examboard) ;
                                    fnd_message.set_token('EBL_CD',l_gen_ebl_format) ;
                                    fnd_file.put_line(fnd_file.LOG,fnd_message.get()) ;

                          ELSE
                                    -- If mapping seeded record is found then set the correct exam_level in cases where the cursor
                                    --   will fetch more than 1 rows , these cases are exam board A/L/O/N/W and generic ebl code ANN
                                    CLOSE c_map_exam_ebl ;

                                    IF new_ivstarpqr_rec.examboard IN ('A','L','N','O','W') AND l_gen_ebl_format = 'ANN' THEN
                                        IF new_ivstarpqr_rec.marvin_type = 'P' THEN
                                                -- For *P transactions ,  take the row with exam level = A
                                                c_map_exam_ebl_rec.exam_level := 'A' ;

                                        ELSIF new_ivstarpqr_rec.marvin_type = '*R' THEN

                                                -- For *R transactions depending on grade1 and 2 fields take wither exam level A or AE
                                                IF new_ivstarpqr_rec.grade1 IS NULL AND new_ivstarpqr_rec.grade2 IS NOT NULL THEN
                                                  c_map_exam_ebl_rec.exam_level := 'AE' ;
                                                ELSE
                                                    c_map_exam_ebl_rec.exam_level := 'A' ;
                                                END IF ;

                                        END IF ;
                                    END IF ;

                                    -- Convert the ebl code from the generic ebl format into ANN format if it is currently in NAN/NNA format
                                    IF l_gen_ebl_format = 'NAN' THEN
                                        l_conv_ebl_code := SUBSTR(new_ivstarpqr_rec.eblsubject,2,1) ||  SUBSTR(new_ivstarpqr_rec.eblsubject,1,1) ||  SUBSTR(new_ivstarpqr_rec.eblsubject,3,1) ;

                                    ELSIF l_gen_ebl_format = 'NNA' THEN
                                        l_conv_ebl_code := SUBSTR(new_ivstarpqr_rec.eblsubject,3,1) ||  SUBSTR(new_ivstarpqr_rec.eblsubject,1,2) ;

                                    ELSE
                                        l_conv_ebl_code := new_ivstarpqr_rec.eblsubject ;
                                    END IF ;

                                    -- Get the subjectid for the awarding_body,year,sitting,ebl_code and exam_level
                                    OPEN c_subjectid(new_ivstarpqr_rec.yearofexam ,
                                                     new_ivstarpqr_rec.sitting,
                                                     c_map_exam_ebl_rec.awarding_body,
                                                     c_map_exam_ebl_rec.exam_level,
                                                     l_conv_ebl_code ) ;

                                    FETCH c_subjectid INTO l_subjectid ;

                                    IF c_subjectid%NOTFOUND THEN
                                          -- If no subjectid record found with the combination of passed year , sitting , awarding body,
                                          -- exam_level and ebl_code then modify the awarding body as follows and check if a subjectid exists
                                          -- for this new awarding body
                                          CLOSE c_subjectid ;
                                          IF c_map_exam_ebl_rec.awarding_body = 'X' AND l_gen_ebl_format IN ( 'ANN','NAN','NNA') THEN
                                             c_map_exam_ebl_rec.awarding_body := 'A' ;
                                          ELSIF c_map_exam_ebl_rec.awarding_body = 'U' AND l_gen_ebl_format IN ( 'ANN','NAN','NNA') THEN
                                             c_map_exam_ebl_rec.awarding_body := 'L' ;
                                          ELSIF c_map_exam_ebl_rec.awarding_body = 'V' AND l_gen_ebl_format IN ( 'ANN','NAN','NNA') THEN
                                              c_map_exam_ebl_rec.awarding_body := 'O';
                                          END IF ;

                                          -- Fetch the subjectid with the new awarding body code and if no record found this time also
                                          -- then log error and skip this record
                                          OPEN c_subjectid(new_ivstarpqr_rec.yearofexam,
                                                           new_ivstarpqr_rec.sitting,
                                                           c_map_exam_ebl_rec.awarding_body,
                                                           c_map_exam_ebl_rec.exam_level,
                                                           l_conv_ebl_code ) ;

                                          FETCH c_subjectid INTO l_subjectid ;
                                          IF c_subjectid%NOTFOUND THEN
                                                  CLOSE c_subjectid ;
                                                  g_error_code := '1021';  -- subject not in ebl subject table.

                                                  fnd_message.set_name( 'IGS','IGS_UC_NO_EBL_SUBJ_REC') ;
                                                  fnd_message.set_token ('YEAR', new_ivstarpqr_rec.yearofexam) ;
                                                  fnd_message.set_token('SITTING', new_ivstarpqr_rec.sitting) ;
                                                  fnd_message.set_token('AWD_BDY',c_map_exam_ebl_rec.awarding_body) ;
                                                  fnd_message.set_token('EXAM_LEVEL',c_map_exam_ebl_rec.exam_level) ;
                                                  fnd_message.set_token('EBL_SUBJ',l_conv_ebl_code ) ;
                                                  fnd_file.put_line(fnd_file.LOG,fnd_message.get()) ;
                                          ELSE
                                                  -- populate subject ID value into Rec so that it can be processed as usual(as a record)
                                                  new_ivstarpqr_rec.subjectid := l_subjectid;
                                                  CLOSE c_subjectid ;
                                          END IF ;
                                    ELSE
                                          new_ivstarpqr_rec.subjectid := l_subjectid;
                                          CLOSE c_subjectid ;
                                    END IF ;


                                    --Do the further processing only when the Subject ID is available in IGS_UC_COM_EBL_SUBJ table.
                                    IF l_subjectid IS NOT NULL THEN

                                        /************** II) Derive the 3 result fields eblresult, eblamended and claimedresult ***************/
                                        IF new_ivstarpqr_rec.marvin_type = 'P' THEN
                                                -- only eblresult is populated for *P transactions , the fields claimedresult and eblamended
                                                -- are populated as null
                                                new_ivstarpqr_rec.eblresult := new_ivstarpqr_rec.grade1 || new_ivstarpqr_rec.grade2 ;

                                        ELSIF new_ivstarpqr_rec.marvin_type = 'R' THEN

                                                 -- For *R transactions all three result fields are derived based on the matchind
                                                IF new_ivstarpqr_rec.matchind IN ( 'F','P','T','U') THEN
                                                         -- 1.  derive eblresult field to be populated into igs_uc_mv_ivstarpqr table
                                                        new_ivstarpqr_rec.eblresult := new_ivstarpqr_rec.grade1 || new_ivstarpqr_rec.grade2;

                                                ELSIF new_ivstarpqr_rec.matchind = 'C' THEN
                                                        -- 2. derive eblamended field to be populated into igs_uc_mv_ivstarpqr table
                                                        new_ivstarpqr_rec.eblamended := new_ivstarpqr_rec.grade1 || new_ivstarpqr_rec.grade2;

                                                ELSIF new_ivstarpqr_rec.matchind = 'A' THEN
                                                        -- 3. derive claimedresult field to be populated into igs_uc_mv_ivstarpqr table
                                                        new_ivstarpqr_rec.claimedresult := new_ivstarpqr_rec.grade1 || new_ivstarpqr_rec.grade2;
                                                END IF ;

                                        END IF ; -- end of *p/*r transaction for Marvin Interface.

                                    END IF;  --End of l_subjectid IS NOT NULL Check

                          END IF ; --End of c_map_exam_ebl%NOTFOUND check.

                 END IF;  -- *R transaction with Match Ind check

              END IF;  -- End of check for Marvin populated record.

            END IF;  -- error code check
            --------------------------------------------------------------------
            -- End of processing needed only for records populated from Marvin Interface
            --------------------------------------------------------------------


            ---- Begin common processing for Hercules and Marvin
            IF l_proc_reqd = 'Y' AND g_error_code IS NULL THEN
               -- by pass all further processing for this record

                -- no mandatory field validations as this is an update
                IF new_ivstarpqr_rec.appno IS NULL OR new_ivstarpqr_rec.subjectid IS NULL THEN
                   g_error_code := '1037';
                END IF;

                ----------------------------
                -- EBL SUBJECT validation
                ----------------------------
                IF g_error_code IS NULL THEN
                   -- validate that the Subject ID from UCAS exists in COM EBL Subject table.
                   subject_rec := NULL;
                   OPEN  validate_subject(new_ivstarpqr_rec.subjectid);
                   FETCH validate_subject INTO subject_rec;
                   IF validate_subject%NOTFOUND THEN
                      g_error_code := '1021';  -- subject not in ebl subject table.
                   END IF;
                   CLOSE validate_subject ;
                END IF;

               ----------------------------
                -- MAIN PROCESSING Begins
                ----------------------------
                IF g_error_code IS NULL THEN

                   -- Gt Application system and ID - required while inserting
                   -- Record would always be found otherwise the above validation - Error 1000 would have failed.
                   appl_det_rec := NULL;  -- initialize
                   OPEN  get_appl_dets(new_ivstarpqr_rec.appno);
                   FETCH get_appl_dets INTO appl_det_rec;
                   CLOSE get_appl_dets;

                   -- Check whether corresponding record already exists in main table.
                   -- If exists then update else insert.
                   old_starpqr_rec  := NULL;
                   OPEN  old_starpqr_cur(new_ivstarpqr_rec.appno, new_ivstarpqr_rec.subjectid);
                   FETCH old_starpqr_cur INTO old_starpqr_rec;
                   CLOSE old_starpqr_cur;


                   IF old_starpqr_rec.rowid IS NULL THEN  -- i.e. new record.

                             BEGIN
                               -- call the TBH to update the record
                               igs_uc_app_results_pkg.insert_row (
                                x_rowid                            => old_starpqr_rec.rowid
                               ,x_app_result_id                    => old_starpqr_rec.app_result_id -- since it would also be NULL when record does not exist.
                               ,x_app_id                           => appl_det_rec.app_id
                               ,x_app_no                           => new_ivstarpqr_rec.appno
                               ,x_enquiry_no                       => NULL
                               ,x_exam_level                       => subject_rec.exam_level
                               ,x_year                             => subject_rec.year
                               ,x_sitting                          => subject_rec.sitting
                               ,x_award_body                       => subject_rec.awarding_body
                               ,x_subject_id                       => new_ivstarpqr_rec.subjectid
                               ,x_predicted_result                 => NULL
                               ,x_result_in_offer                  => NULL
                               ,x_ebl_result                       => new_ivstarpqr_rec.eblresult
                               ,x_ebl_amended_result               => new_ivstarpqr_rec.eblamended
                               ,x_claimed_result                   => new_ivstarpqr_rec.claimedresult
                               ,x_imported                         => 'Y'
                               ,x_mode                             => 'R'
                               );

                             EXCEPTION
                                 WHEN OTHERS THEN
                                    g_error_code := '9999';
                                    fnd_file.put_line(fnd_file.log, SQLERRM);
                             END;


                   ELSE  -- update

                             BEGIN

                                -- call the TBH to update the record
                               igs_uc_app_results_pkg.update_row  (
                                x_rowid                            => old_starpqr_rec.rowid
                               ,x_app_result_id                    => old_starpqr_rec.app_result_id
                               ,x_app_id                           => old_starpqr_rec.app_id
                               ,x_app_no                           => old_starpqr_rec.app_no
                               ,x_enquiry_no                       => old_starpqr_rec.enquiry_no
                               ,x_exam_level                       => old_starpqr_rec.exam_level
                               ,x_year                             => old_starpqr_rec.year
                               ,x_sitting                          => old_starpqr_rec.sitting
                               ,x_award_body                       => old_starpqr_rec.award_body
                               ,x_subject_id                       => old_starpqr_rec.subject_id
                               ,x_predicted_result                 => old_starpqr_rec.predicted_result
                               ,x_result_in_offer                  => old_starpqr_rec.result_in_offer
                               ,x_ebl_result                       => new_ivstarpqr_rec.eblresult
                               ,x_ebl_amended_result               => new_ivstarpqr_rec.eblamended
                               ,x_claimed_result                   => new_ivstarpqr_rec.claimedresult
                               ,x_imported                         => old_starpqr_rec.imported
                               ,x_mode                             => 'R'
                               );

                             EXCEPTION
                                WHEN OTHERS THEN
                                   g_error_code := '9998';
                             END;

                   END IF; -- insert / update

                END IF; -- error code is null , main processing

            END IF; --  Check for bypass of record processing

         EXCEPTION
              WHEN OTHERS THEN
                 -- catch any unhandled/unexpected errors while processing a record.
                 -- This would enable processing to continue with subsequent records.

                 -- Close any Open cursors
                 IF old_starpqr_cur%ISOPEN THEN
                    CLOSE old_starpqr_cur;
                 END IF;

                 IF get_appl_dets%ISOPEN THEN
                    CLOSE get_appl_dets;
                 END IF;

                 IF validate_subject%ISOPEN THEN
                    CLOSE validate_subject;
                 END IF;

                 IF c_map_exam_ebl%ISOPEN THEN
                    CLOSE c_map_exam_ebl;
                 END IF;

                 IF c_subjectid%ISOPEN THEN
                    CLOSE c_subjectid;
                 END IF;

                 g_error_code := '1055';
                 fnd_file.put_line(fnd_file.log, SQLERRM);
         END;

         -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
         -- while processing the record.
         IF g_error_code IS NOT NULL THEN
                -- set flag that this applicant has failed a validation
                l_appno_failed  := TRUE;

                -- update this record with derived error code
                UPDATE igs_uc_istrpqr_ints
                SET    error_code    = g_error_code
                WHERE  rowid = new_ivstarpqr_rec.rowid ;

                -- log error message/meaning.
                igs_uc_proc_ucas_data.log_error_msg(g_error_code);

                -- update error count
                g_error_rec_cnt  := g_error_rec_cnt  + 1;

         ELSE
                -- increment success count
                g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
         END IF;

       END LOOP;  -- inner loop i.e for the applicant

       -- smaddali added this logic for bug#3122898
       IF l_appno_failed THEN
              -- Delete all the qualification records for the applicant before inserting.
              FOR get_appno_rec IN get_appno_cur(new_appl_rec.appno)
              LOOP
                  igs_uc_app_results_pkg.delete_row(get_appno_rec.rowid);
              END LOOP;

              -- update INTS records for this appno which are successful to set error_code=2001
              UPDATE igs_uc_istrpqr_ints SET error_code = '2001'
              WHERE record_status = 'N' AND appno = new_appl_rec.appno AND error_code IS NULL ;

       ELSE
              -- update INTS records for this appno which are all successful to set record_status = L
              UPDATE igs_uc_istrpqr_ints SET record_status = 'L' , error_code = NULL
              WHERE record_status = 'N' AND appno = new_appl_rec.appno ;

       END IF ;

    END LOOP;  -- outer loop - applicant level

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('IVSTARPQR', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'IVSTARPQR'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_ivstarpqr;


END igs_uc_proc_application_data;

/
