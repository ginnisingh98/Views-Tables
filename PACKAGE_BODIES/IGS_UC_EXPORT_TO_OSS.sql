--------------------------------------------------------
--  DDL for Package Body IGS_UC_EXPORT_TO_OSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_EXPORT_TO_OSS" AS
/* $Header: IGSUC20B.pls 120.11 2006/08/21 03:55:46 jbaber ship $ */



  -- Get application choice details to update error code, batch id, export status and requesty id
  CURSOR c_upd_ch ( cp_app_no igs_uc_app_choices.app_no%TYPE ,
                    cp_choice_no igs_uc_app_choices.choice_no%TYPE,
                    cp_ucas_cycle igs_uc_app_choices.ucas_cycle%TYPE) IS
    SELECT ch.ROWID , ch.*
    FROM  igs_uc_app_choices  ch
    WHERE ch.app_no = cp_app_no
    AND   ch.choice_no = cp_choice_no
    AND   ch.ucas_cycle = cp_ucas_cycle;
  c_upd_ch_rec c_upd_ch%ROWTYPE ;

  l_conc_request_id  NUMBER;
  l_org_id  CONSTANT igs_ps_ver.org_id%TYPE := IGS_GE_GEN_003.GET_ORG_ID ;


 PROCEDURE populate_imp_int (
                      p_app_no IN igs_uc_applicants.app_no%TYPE,
                      p_choice_no IN igs_uc_app_choices.choice_no%TYPE ,
                      p_source_type_id igs_pe_src_types_all.source_type_id%TYPE,
                      p_batch_id NUMBER,
                      p_orgid NUMBER) AS
    /******************************************************************
     Created By      :   smaddali
     Date Created By :   08-MAR-2002
     Purpose         :   To populate import application interface tables
                 for all valid choices in status OC of the passed application
     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
     --smaddali ,bug2643048 UCFD102 build. Modified procedure to add check for igs_uc_defaults.system_code
     -- and modified insert row of igs_ad_apl_int to insert values for columns alt_appl_id and admission_application_type
     -- and to get the admission and academic calendars set up in igs_uc_defaults for the application choice system
     --pmarada  22-aug-2003 REmoved the insert row call to igs_ad_stat_int table, this is not required.bug 3094409
     --jchakrab  03-Oct-2005   Modified for 4506750 Impact - added extra filter for IGS_AD_CODE_CLASSES.class_type_code
     --jchakrab  10-Oct-2005   Modified for 4424068 - added CANCEL functionality for prog version change
     --jchin     20-jan-2006   Modified for R12 perf improvements - bug 3691277 and 3691250
     --jchakrab  22-May-2006   Modified for 5165624
    ***************************************************************** */

    l_status                  CONSTANT NUMBER := 2;
    l_record_status           CONSTANT NUMBER := 2;
    l_created_by              CONSTANT NUMBER := FND_GLOBAL.USER_ID;
    l_last_updated_by         CONSTANT NUMBER := FND_GLOBAL.LOGIN_ID;
    l_request_id              CONSTANT NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_program_application_id  CONSTANT NUMBER := FND_GLOBAL.PROG_APPL_ID;
    l_program_id              CONSTANT NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    l_ch_error igs_uc_app_choices.error_code%TYPE ;
    l_ch_batch_id igs_uc_app_choices.batch_id%TYPE ;
    l_export_to_oss_status igs_uc_app_choices.export_to_oss_status%TYPE ;
    l_aca_cal_type igs_uc_sys_calndrs.aca_cal_type%TYPE ;
    l_aca_seq_no igs_uc_sys_calndrs.aca_cal_seq_no%TYPE;
    l_adm_cal_type igs_uc_sys_calndrs.adm_cal_type%TYPE ;
    l_adm_seq_no igs_uc_sys_calndrs.adm_cal_seq_no%TYPE ;
    l_update_adm_appl_number igs_ad_apl_int.update_adm_appl_number%TYPE;
    l_update_adm_seq_number igs_ad_ps_appl_inst_int.update_adm_seq_number%TYPE;

    -- Get the admission application corresponding to the passed choice record
    -- Smaddali modified this cursor to add check for c.alt_appl_id , bug 2643048 UCFD012
    CURSOR c_match_adm_appl(cp_app_no igs_uc_app_choices.app_no%TYPE ,
                            cp_choice_no igs_uc_app_choices.choice_no%TYPE ) IS
    SELECT c.admission_appl_number, c.person_id
    FROM igs_uc_applicants a , igs_uc_app_choices b , igs_ad_appl_all c
    WHERE a.app_no = b.app_no AND
          TO_CHAR(a.app_no) = c.alt_appl_id AND
          a.oss_person_id = c.person_id AND
          b.choice_no = c.choice_number AND
          c.acad_cal_type = l_aca_cal_type AND
          c.acad_ci_sequence_number = l_aca_seq_no AND
          c.adm_cal_type = l_adm_cal_type AND
          c.adm_ci_sequence_number = l_adm_seq_no AND
          b.app_no = cp_app_no AND
          b.choice_no = cp_choice_no  AND
          c.adm_appl_status <> 'COMPLETED';
    c_match_adm_appl_rec  c_match_adm_appl%ROWTYPE ;

    -- Get the admission application instance sequence number corresponding to the passed OSS details
    CURSOR c_match_adm_appl_inst ( cp_person_id igs_ad_appl_all.person_id%TYPE,
                                   cp_admission_appl_number igs_ad_appl_all.admission_appl_number%TYPE,
                                   cp_oss_program_code igs_uc_app_choices.oss_program_code%TYPE,
                                   cp_oss_program_version igs_uc_app_choices.oss_program_version%TYPE,
                                   cp_oss_location igs_uc_app_choices.oss_location%TYPE,
                                   cp_oss_attendance_mode igs_uc_app_choices.oss_attendance_mode%TYPE,
                                   cp_oss_attendance_type igs_uc_app_choices.oss_attendance_type%TYPE,
                                   cp_unit_set_cd igs_ps_ofr_opt_unit_set_v.unit_set_cd%TYPE,
                                   cp_us_version_number igs_ps_ofr_opt_unit_set_v.us_version_number%TYPE ) IS
      SELECT acai.sequence_number
      FROM  igs_ad_ps_appl_inst acai
      WHERE acai.person_id = cp_person_id
      AND  acai.admission_appl_number = cp_admission_appl_number
      AND  acai.nominated_course_cd = cp_oss_program_code
      AND  acai.crv_version_number = cp_oss_program_version
      AND  NVL(acai.location_cd,'X') = NVL( cp_oss_location ,'X')
      AND  NVL(acai.attendance_mode,'X') = NVL( cp_oss_attendance_mode ,'X')
      AND  NVL(acai.attendance_type,'X') = NVL( cp_oss_attendance_type ,'X')
      AND  NVL(acai.unit_set_cd,'X') = NVL( cp_unit_set_cd ,'X')
      AND  NVL(acai.us_version_number,-1)= NVL( cp_us_version_number ,-1);

    c_match_adm_appl_inst_rec c_match_adm_appl_inst%ROWTYPE;

    -- Get the person details from oss for the passed applicant
    CURSOR c_pe_person IS
    SELECT p.party_id person_id, p.party_number person_number, p.person_last_name surname,
      p.person_middle_name middle_name, p.person_first_name given_names,
      pp.gender sex,p.person_title title, p.person_name_suffix suffix,
      p.person_pre_name_adjunct pre_name_adjunct,
      Pd.proof_of_ins , pd.proof_of_immu,
      pp.date_of_birth birth_dt, p.known_as preferred_given_name,
      pd.level_of_qual level_of_qual_id, pd.military_service_reg,
      pd.veteran, e.application_date
    FROM igs_pe_HZ_parties pd, hz_parties p , hz_person_profiles pp ,
        igs_uc_applicants e
    WHERE p.party_id = e.oss_person_id AND e.app_no = p_app_no  AND
          pp.party_id(+)=p.party_id AND p.party_id=pd.party_id(+) AND
          SYSDATE BETWEEN NVL(pp.effective_start_date,SYSDATE) AND NVL(pp.effective_end_date,SYSDATE);
    c_pe_person_rec      c_pe_person%ROWTYPE;
    -- Get the interface id
    CURSOR c_int_id IS
      SELECT igs_ad_interface_s.NEXTVAL int_id
      FROM dual;
    c_int_id_rec c_int_id%ROWTYPE;

    -- Get application interface ID
    CURSOR c_int_appl_id IS
      SELECT  igs_ad_apl_int_s.NEXTVAL int_appl_id
      FROM dual;
    c_int_appl_id_rec c_int_appl_id%ROWTYPE;
    -- Get application instance interface id
    CURSOR c_appl_inst_int_id IS
      SELECT  igs_ad_ps_appl_inst_int_s.NEXTVAL appl_inst_int_id
      FROM dual;
    appl_inst_int_id_rec c_appl_inst_int_id%ROWTYPE;
    -- Get ucas application source from code classes
    CURSOR cur_code_id IS
      SELECT code_id
      FROM   igs_ad_code_classes
      WHERE  class = 'SYS_APPL_SOURCE'
      AND    name = 'UCAS'
      AND    class_type_code = 'ADM_CODE_CLASSES';

    l_code_id igs_ad_code_classes.code_id%TYPE;
    -- Get all the application choices belonging to the passed app_no and choice_no in status OC
    -- if choice no is null then get all the choices in status OC belonging to the current institution
    -- smaddali modified cursor to select system_code also ,for bug 2643048
    CURSOR c_uc_app_ch  IS
      SELECT DISTINCT a.ucas_program_code, a.campus, a.choice_no, a.oss_program_code, a.oss_program_version,
                      a.oss_location, a.point_of_entry, a.deferred, a.oss_attendance_type, a.oss_attendance_mode,
                      a.route_b_pref_round, b.application_source , a.app_no , a.system_code, a.ucas_cycle, a.entry_year, a.entry_month
      FROM igs_uc_app_choices a, igs_uc_applicants b
      WHERE a.app_no=b.app_no AND
            b.app_no=NVL(p_app_no ,b.app_no) AND
            a.institute_code = (SELECT df.current_inst_code FROM igs_uc_defaults df
                                 WHERE df.system_code = a.system_code) AND
            a.export_to_oss_status = 'OC' AND
            a.choice_no = NVL(p_choice_no,a.choice_no)
      ORDER BY a.choice_no ;


    -- Get the unit set code corresponding to the application choice point of entry
    -- jchin - bug 3691277 and 3691250
    CURSOR c_unit_set_cd(p_seq_no igs_ps_us_prenr_cfg.sequence_no%TYPE,
                   p_course_cd igs_ps_ofr_opt_unit_set_v.course_cd%TYPE,
                   p_version_number igs_ps_ofr_opt_unit_set_v.crv_version_number%TYPE,
                   p_acad_cal_type igs_ps_ofr_opt_unit_set_v.cal_type%TYPE,
                   p_location_cd igs_ps_ofr_opt_unit_set_v.location_cd%TYPE,
                   p_attendance_mode igs_ps_ofr_opt_unit_set_v.attendance_mode%TYPE,
                   p_attendance_type igs_ps_ofr_opt_unit_set_v.attendance_type%TYPE) IS
      SELECT  US.UNIT_SET_CD,
              US.VERSION_NUMBER US_VERSION_NUMBER
      FROM    IGS_PS_OFR_UNIT_SET COUS,
              IGS_PS_OFR_OPT COO,
              IGS_EN_UNIT_SET US,
              IGS_EN_UNIT_SET_CAT USC,
              IGS_PS_US_PRENR_CFG CFG
      WHERE   COUS.COURSE_CD = P_COURSE_CD
      AND     COUS.CRV_VERSION_NUMBER = P_VERSION_NUMBER
      AND     COUS.CAL_TYPE = P_ACAD_CAL_TYPE
      AND        COO.LOCATION_CD = P_LOCATION_CD
      AND        COO.ATTENDANCE_MODE = P_ATTENDANCE_MODE
      AND        COO.ATTENDANCE_TYPE = P_ATTENDANCE_TYPE
      AND        COO.COURSE_CD = COUS.COURSE_CD
      AND        COO.VERSION_NUMBER = COUS.CRV_VERSION_NUMBER
      AND        COO.CAL_TYPE = COUS.CAL_TYPE
      AND        US.UNIT_SET_CD = COUS.UNIT_SET_CD
      AND        US.VERSION_NUMBER = COUS.US_VERSION_NUMBER
      AND        US.UNIT_SET_CAT = USC.UNIT_SET_CAT
      AND        USC.S_UNIT_SET_CAT ='PRENRL_YR'
      AND        US.UNIT_SET_CD = CFG.UNIT_SET_CD
      AND        CFG.SEQUENCE_NO = P_SEQ_NO
      AND        NOT EXISTS (SELECT COURSE_CD FROM IGS_PS_OF_OPT_UNT_ST COOUS WHERE COOUS.COO_ID = COO.COO_ID)
      UNION ALL
      SELECT  US.UNIT_SET_CD,
              US.VERSION_NUMBER US_VERSION_NUMBER
      FROM    IGS_PS_OF_OPT_UNT_ST COOUS,
              IGS_EN_UNIT_SET US,
              IGS_EN_UNIT_SET_CAT USC,
              IGS_PS_US_PRENR_CFG CFG
      WHERE   COOUS.COURSE_CD = P_COURSE_CD
      AND     COOUS.CRV_VERSION_NUMBER = P_VERSION_NUMBER
      AND     COOUS.CAL_TYPE = P_ACAD_CAL_TYPE
      AND     COOUS.LOCATION_CD = P_LOCATION_CD
      AND     COOUS.ATTENDANCE_MODE = P_ATTENDANCE_MODE
      AND     COOUS.ATTENDANCE_TYPE = P_ATTENDANCE_TYPE
      AND     US.UNIT_SET_CD = COOUS.UNIT_SET_CD
      AND     US.VERSION_NUMBER = COOUS.US_VERSION_NUMBER
      AND     US.UNIT_SET_CAT = USC.UNIT_SET_CAT
      AND     USC.S_UNIT_SET_CAT ='PRENRL_YR'
      AND     US.UNIT_SET_CD = CFG.UNIT_SET_CD
      AND     CFG.SEQUENCE_NO = P_SEQ_NO;
    c_unit_set_cd_rec c_unit_set_cd%ROWTYPE;

    -- Get the oss POP to which ucas program is mapped to
    -- smaddali modified cursor to add parameter cp_system_code and its check in where clause ,for bug 2643048
    CURSOR cur_oss_prog_mapped (cp_ucas_program_code igs_uc_crse_dets.ucas_program_code%TYPE,
                                cp_ucas_campus       igs_uc_crse_dets.ucas_campus%TYPE,
                                cp_system_code  igs_uc_crse_dets.system_code%TYPE )  IS
      SELECT cr.oss_program_code, cr.oss_program_version, cr.oss_location, cr.oss_attendance_type,
                  cr.oss_attendance_mode
      FROM igs_uc_crse_dets cr
      WHERE cr.ucas_program_code = cp_ucas_program_code
      AND   cr.ucas_campus       = cp_ucas_campus
      AND   cr.institute         = (SELECT current_inst_code FROM igs_uc_defaults df WHERE df.system_code = cr.system_code)
      AND   cr.system_code = cp_system_code
      AND   cr.oss_program_code IS NOT NULL
      AND   cr.oss_location IS NOT NULL;
    oss_prog_mapped_rec cur_oss_prog_mapped%ROWTYPE;

     -- Get the application choice details for updating error code,request id and export status fields
     CURSOR cur_app_choices(cp_appno igs_uc_app_choices.app_no%TYPE,
                            cp_choiceno igs_uc_app_choices.choice_no%TYPE,
                            cp_ucas_cycle igs_uc_app_choices.ucas_cycle%TYPE ) IS
       SELECT  a.ROWID, a.*
       FROM   igs_uc_app_choices a
       WHERE  a.app_no = cp_appno
       AND    a.choice_no = cp_choiceno
       AND    a.ucas_cycle = cp_ucas_cycle;
     app_choices_rec cur_app_choices%ROWTYPE;

    -- smaddali added cursor ,for bug 2643048
    CURSOR c_defaults( cp_system_code igs_uc_defaults.system_code%TYPE) IS
    SELECT *
    FROM igs_uc_defaults def
    WHERE system_code = cp_system_code;
    c_defaults_rec c_defaults%ROWTYPE ;

    --Cursor to get the Calendar details for the given System, Entry Month and Entry Year.
    CURSOR cur_sys_entry_cal_det ( cp_system_code  igs_uc_sys_calndrs.system_code%TYPE,
                                   cp_entry_year   igs_uc_sys_calndrs.entry_year%TYPE,
                                   cp_entry_month  igs_uc_sys_calndrs.entry_month%TYPE ) IS
      SELECT sc.aca_cal_type,
             sc.aca_cal_seq_no,
             sc.adm_cal_type,
             sc.adm_cal_seq_no
      FROM  igs_uc_sys_calndrs sc
      WHERE sc.system_code = cp_system_code
      AND   sc.entry_year  = cp_entry_year
      AND   sc.entry_month = cp_entry_month;

    l_sys_entry_cal_det_rec cur_sys_entry_cal_det%ROWTYPE;

  BEGIN

    SAVEPOINT sp_current_person;

      -- Get the person details from oss for the passed applicant
      c_pe_person_rec := NULL ;
      OPEN c_pe_person;
      FETCH c_pe_person INTO c_pe_person_rec;
      IF c_pe_person%NOTFOUND  THEN
        -- This applicant is not present in OSS ,hence log error and skip this person
        fnd_message.set_name('IGS','IGS_UC_NO_OSS_PERS');
        fnd_message.set_token('APP_NO',p_app_no);
        fnd_file.put_line( fnd_file.LOG ,fnd_message.get  );
      ELSE
        -- Since person is present in OSS , get his person details to populate person interface tables

        -- Get the interface ID for this person to be used to create record in igs_ad_interface table
        c_int_id_rec := NULL ;
        OPEN c_int_id;
        FETCH c_int_id INTO c_int_id_rec;
        CLOSE c_int_id;

        -- Create an interface record for this person
        INSERT INTO igs_ad_interface(person_number,
                                     interface_id,
                                     batch_id,
                                     org_id,
                                     source_type_id,
                                     surname,
                                     middle_name,
                                     given_names,
                                     sex,
                                     title,
                                     suffix,
                                     pre_name_adjunct,
                                     proof_of_insurance,
                                     proof_of_immun,
                                     birth_dt,
                                     preferred_given_name,
                                     level_of_qual,
                                     military_service_reg,
                                     veteran,
                                     status,
                                     record_status,
                                     match_ind,
                                     person_id,
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     request_id,
                                     program_application_id,
                                     program_id,
                                     program_update_date )
        VALUES(c_pe_person_rec.person_number,
               c_int_id_rec.int_id,
               p_batch_id,
               p_orgid,
               p_source_type_id,
               NVL(c_pe_person_rec.surname,' '),
               c_pe_person_rec.middle_name,
               NVL(c_pe_person_rec.given_names,' '),
               c_pe_person_rec.sex,
               c_pe_person_rec.title,
               c_pe_person_rec.suffix,
               c_pe_person_rec.pre_name_adjunct,
               c_pe_person_rec.proof_of_ins,
               c_pe_person_rec.proof_of_immu,
               c_pe_person_rec.birth_dt,
               c_pe_person_rec.preferred_given_name,
               c_pe_person_rec.level_of_qual_id,
               c_pe_person_rec.military_service_reg,
               c_pe_person_rec.veteran,
               l_status,
               l_record_status,
                     '15',
               c_pe_person_rec.person_id,
               l_created_by,
               SYSDATE,
               l_last_updated_by,
               SYSDATE,
               l_request_id,
               l_program_application_id,
               l_program_id,
               SYSDATE );

        -- Get the application choice details belonging to the passed app_no and choice_no parameters.
        -- For each application choice record create records in apl_int and appl_inst_int tables
        FOR j IN c_uc_app_ch
        LOOP
          -- initialise all the local variables
          l_aca_cal_type := NULL ;
          l_aca_seq_no := NULL ;
          l_adm_cal_type := NULL ;
          l_adm_seq_no := NULL ;

          -- smaddali added this cursor code to get the default set up for the application choice system code
          -- Get the default UCAS setup values and keep them in package variable c_defaults_rec
          c_defaults_rec := NULL ;
          OPEN c_defaults(j.system_code) ;
          FETCH c_defaults INTO c_defaults_rec;
          CLOSE c_defaults ;

          --Get the Calendar details for the given System, Entry Month and Entry Year from System Calendards table.
          l_sys_entry_cal_det_rec := NULL;
          OPEN cur_sys_entry_cal_det(j.system_code, j.entry_year, j.entry_month);
          FETCH cur_sys_entry_cal_det INTO l_sys_entry_cal_det_rec;
          --If no matching Entry Year and Entry Month record for the system is found in the System Calendars table then
          --  get the calendar details from the IGS_UC_SYS_CALNDRS table based on the system, Entry Year and Entry Month as 0 (Zero).
          IF cur_sys_entry_cal_det%NOTFOUND THEN
            CLOSE cur_sys_entry_cal_det;
            OPEN cur_sys_entry_cal_det(j.system_code, j.entry_year, 0);
            FETCH cur_sys_entry_cal_det INTO l_sys_entry_cal_det_rec;
          END IF;
          CLOSE cur_sys_entry_cal_det;

          -- Find out the oss POP to which this choice record's ucas program is mapped to
          IF j.oss_program_code IS NULL OR j.oss_location IS NULL OR j.oss_attendance_type IS NULL OR
             j.oss_attendance_mode IS NULL OR j.oss_attendance_type IS NULL THEN

            OPEN cur_oss_prog_mapped(j.ucas_program_code, j.campus, j.system_code) ;
            FETCH cur_oss_prog_mapped INTO oss_prog_mapped_rec ;
            IF cur_oss_prog_mapped%FOUND THEN
              --Populate the OSS code mapping done in IGSUC013 Form from the IGS_UC_CRSE_DETS Table.
              j.oss_program_code := oss_prog_mapped_rec.oss_program_code;
              j.oss_program_version := oss_prog_mapped_rec.oss_program_version;
              j.oss_location := oss_prog_mapped_rec.oss_location;
              j.oss_attendance_mode := oss_prog_mapped_rec.oss_attendance_mode;
              j.oss_attendance_type := oss_prog_mapped_rec.oss_attendance_type;
            END IF;
            CLOSE cur_oss_prog_mapped;
          END IF;

          -- If ucas program of this choice is not mapped to any oss pop then log an error and skip the choice
          IF j.oss_program_code IS NULL OR j.oss_location IS NULL OR j.oss_attendance_mode IS NULL OR j.oss_attendance_type IS NULL THEN
            fnd_message.set_name('IGS','IGS_UC_NO_OSS_PROG_MAPPED');
            fnd_message.set_token('APP_NO',TO_CHAR(j.app_no));
            fnd_message.set_token('CHOICE_NO',TO_CHAR(j.choice_no));
            fnd_message.set_token('SYSTEM_CODE',j.system_code);
            fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

            -- set the choice record error code to A002 and export status to OC to indicate that
            -- import interface tables have not been successfully populated but an error was encountered
            l_ch_error := 'A002' ;
            l_export_to_oss_status := 'OC' ;
                  l_ch_batch_id := NULL ;

          ELSE

            -- Get the academic and admission calendars for the application choice
            l_aca_cal_type := l_sys_entry_cal_det_rec.aca_cal_type ;
            l_aca_seq_no   := l_sys_entry_cal_det_rec.aca_cal_seq_no;
            l_adm_cal_type := l_sys_entry_cal_det_rec.adm_cal_type;
            l_adm_seq_no   := l_sys_entry_cal_det_rec.adm_cal_seq_no ;

            -- Get the Unit set cd corresponding to the application choice point of entry and POP
            c_unit_set_cd_rec := NULL ;
            OPEN c_unit_set_cd(NVL(j.point_of_entry,1),
                                   j.oss_program_code,
                                   j.oss_program_version,
                                   l_aca_cal_type,
                                   j.oss_location,
                                   j.oss_attendance_mode,
                                   j.oss_attendance_type  );
            FETCH c_unit_set_cd INTO c_unit_set_cd_rec;

            IF c_unit_set_cd%NOTFOUND  THEN
              -- If the point of entry doesnot correspond to a valid Unit set cd then log error and skip the choice
              CLOSE c_unit_set_cd;
              fnd_message.set_name('IGS','IGS_UC_NO_UNIT_SET_CD');
              fnd_message.set_token('APP_NO',TO_CHAR(j.app_no));
              fnd_message.set_token('CHOICE_NO',TO_CHAR(j.choice_no));
              fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
              -- set the choice record error code to A003 and export status to OC to indicate that
              -- import interface tables have not been successfully populated but an error was encountered
              l_ch_error := 'A003' ;
              l_export_to_oss_status := 'OC' ;
                    l_ch_batch_id := NULL ;
            ELSE
              CLOSE c_unit_set_cd;

              -- Check if this application choice has been exported previously ,
              -- i.e if an APPLICATION already exists for this choice . If so then update that application
              -- Else create a new application and application instance
              c_match_adm_appl_rec := NULL ;
              OPEN c_match_adm_appl(j.app_no , j.choice_no) ;
              FETCH c_match_adm_appl INTO c_match_adm_appl_rec ;
              IF c_match_adm_appl%NOTFOUND THEN
                 -- new application is being created by this choice
                 l_update_adm_appl_number  := NULL ;
              ELSE
                 -- existing application instance needs to be updated
                 l_update_adm_appl_number  :=  c_match_adm_appl_rec.admission_appl_number ;
              END IF ;
              CLOSE c_match_adm_appl ;

              -- Populate the admission application interface table for the application choice
              -- get the application interface ID
              c_int_appl_id_rec := NULL ;
              OPEN c_int_appl_id;
              FETCH c_int_appl_id INTO c_int_appl_id_rec;
              CLOSE c_int_appl_id;

              -- smaddali added new columns admission_application_type and alt_appl_id for bug 2643048
              INSERT INTO igs_ad_apl_int
                 ( interface_appl_id
                   ,interface_id
                   ,appl_dt
                   ,acad_cal_type
                   ,acad_ci_sequence_number
                   ,adm_cal_type
                   ,adm_ci_sequence_number
                   ,tac_appl_ind
                   ,status
                   ,created_by
                   ,creation_date
                   ,last_updated_by
                   ,last_update_date
                   ,choice_number
                   ,routeb_pref
                   ,update_adm_appl_number
                   ,admission_application_type
                   ,alt_appl_id
                  )
                VALUES( c_int_appl_id_rec.int_appl_id,
                        c_int_id_rec.int_id,
                        NVL(c_pe_person_rec.application_date,SYSDATE),
                        l_aca_cal_type,
                        l_aca_seq_no,
                        l_adm_cal_type,
                        l_adm_seq_no,
                        'N',
                        l_status,
                        l_created_by,
                        SYSDATE,
                        l_last_updated_by,
                        SYSDATE,
                        j.choice_no,
                        j.route_b_pref_round,
                        l_update_adm_appl_number,
                        c_defaults_rec.application_type,
                        TO_CHAR(j.app_no)
                        );

              -- Populate the application instance interface tables
              -- Get the application instance interface ID
              appl_inst_int_id_rec := NULL ;
              OPEN  c_appl_inst_int_id;
              FETCH c_appl_inst_int_id INTO appl_inst_int_id_rec;
              CLOSE c_appl_inst_int_id;
              -- Get the application source code
              l_code_id := NULL ;
              OPEN  cur_code_id;
              FETCH cur_code_id INTO l_code_id;
              CLOSE cur_code_id;

              -- Check if this application choice has been exported previously ,
              -- i.e if an APPLICATION INSTANCE already exists for this choice . If so then update that application instance
              -- Else create a new application instance
              c_match_adm_appl_inst_rec := NULL ;
              OPEN c_match_adm_appl_inst ( c_match_adm_appl_rec.person_id,
                                           c_match_adm_appl_rec.admission_appl_number,
                                           j.oss_program_code,
                                           j.oss_program_version,
                                           j.oss_location,
                                           j.oss_attendance_mode,
                                           j.oss_attendance_type,
                                           c_unit_set_cd_rec.unit_set_cd,
                                           c_unit_set_cd_rec.us_version_number ) ;
              FETCH c_match_adm_appl_inst INTO c_match_adm_appl_inst_rec ;
              IF c_match_adm_appl_inst%NOTFOUND THEN
                 -- new application instance is being created by this choice
                 l_update_adm_seq_number  := NULL ;
              ELSE
                 -- existing application instance needs to be updated
                 l_update_adm_seq_number  :=  c_match_adm_appl_inst_rec.sequence_number ;
              END IF ;
              CLOSE c_match_adm_appl_inst ;

              INSERT INTO igs_ad_ps_appl_inst_int
                 ( interface_appl_id
                   ,interface_ps_appl_inst_id
                   ,nominated_course_cd
                   ,req_for_adv_standing_ind
                   ,app_source_id
                   ,crv_version_number
                   ,location_cd
                   ,attendance_mode
                   ,attendance_type
                   ,preference_number
                   ,unit_set_cd
                   ,us_version_number
                   ,status
                   ,created_by
                   ,creation_date
                   ,last_updated_by
                   ,last_update_date
                   ,update_adm_seq_number
                 )
              VALUES ( c_int_appl_id_rec.int_appl_id,
                       appl_inst_int_id_rec.appl_inst_int_id,
                       j.oss_program_code,
                       'N',
                       DECODE(j.application_source, 'U',l_code_id,NULL),
                       j.oss_program_version,
                       j.oss_location,
                       j.oss_attendance_mode,
                       j.oss_attendance_type,
                       1,
                       c_unit_set_cd_rec.unit_set_cd,
                       c_unit_set_cd_rec.us_version_number,
                       l_status,
                       l_created_by,
                       SYSDATE,
                       l_last_updated_by,
                       SYSDATE,
                       l_update_adm_seq_number
                       );

              -- set the choice record error code to null and export status to AP to indicate that
              -- import interface tables have been successfully populated
              l_ch_error := NULL ;
                    l_ch_batch_id := NULL ;
              l_export_to_oss_status := 'AP' ;

            END IF;  -- c_unit_set_cd%NOTFOUND  Conditon

          END IF; -- j.oss_program_code IS NULL OR j.choice_no IS NULL Conditon


          -- Update the application choice record with the oss POP mapped to ucas program
          -- and to set export_to_oss_status = AP / OC , error code , request id
          -- depending on whether admission application interface tables have been successfully populted or not
          app_choices_rec := NULL ;
          OPEN  cur_app_choices(j.app_no, j.choice_no, j.ucas_cycle);
          FETCH cur_app_choices INTO app_choices_rec;
          CLOSE cur_app_choices;

          igs_uc_app_choices_pkg.update_row
               ( x_rowid                      => app_choices_rec.ROWID
                ,x_app_choice_id              => app_choices_rec.app_choice_id
                ,x_app_id                     => app_choices_rec.app_id
                ,x_app_no                     => app_choices_rec.app_no
                ,x_choice_no                  => app_choices_rec.choice_no
                ,x_last_change                => app_choices_rec.last_change
                ,x_institute_code             => app_choices_rec.institute_code
                ,x_ucas_program_code          => app_choices_rec.ucas_program_code
                ,x_oss_program_code           => j.oss_program_code
                ,x_oss_program_version        => j.oss_program_version
                ,x_oss_attendance_type        => j.oss_attendance_type
                ,x_oss_attendance_mode        => j.oss_attendance_mode
                ,x_campus                     => app_choices_rec.campus
                ,x_oss_location               => j.oss_location
                ,x_faculty                    => app_choices_rec.faculty
                ,x_entry_year                 => app_choices_rec.entry_year
                ,x_entry_month                => app_choices_rec.entry_month
                ,x_point_of_entry             => app_choices_rec.point_of_entry
                ,x_home                       => app_choices_rec.home
                ,x_deferred                   => app_choices_rec.deferred
                ,x_route_b_pref_round         => app_choices_rec.route_b_pref_round
                ,x_route_b_actual_round       => app_choices_rec.route_b_actual_round
                ,x_condition_category         => app_choices_rec.condition_category
                ,x_condition_code             => app_choices_rec.condition_code
                ,x_decision                   => app_choices_rec.decision
                ,x_decision_date              => app_choices_rec.decision_date
                ,x_decision_number            => app_choices_rec.decision_number
                ,x_reply                      => app_choices_rec.reply
                ,x_summary_of_cond            => app_choices_rec.summary_of_cond
                ,x_choice_cancelled           => app_choices_rec.choice_cancelled
                ,x_action                     => app_choices_rec.action
                ,x_substitution               => app_choices_rec.substitution
                ,x_date_substituted           => app_choices_rec.date_substituted
                ,x_prev_institution           => app_choices_rec.prev_institution
                ,x_prev_course                => app_choices_rec.prev_course
                ,x_prev_campus                => app_choices_rec.prev_campus
                ,x_ucas_amendment             => app_choices_rec.ucas_amendment
                ,x_withdrawal_reason          => app_choices_rec.withdrawal_reason
                ,x_offer_course               => app_choices_rec.offer_course
                ,x_offer_campus               => app_choices_rec.offer_campus
                ,x_offer_crse_length          => app_choices_rec.offer_crse_length
                ,x_offer_entry_month          => app_choices_rec.offer_entry_month
                ,x_offer_entry_year           => app_choices_rec.offer_entry_year
                ,x_offer_entry_point          => app_choices_rec.offer_entry_point
                ,x_offer_text                 => app_choices_rec.offer_text
                ,x_export_to_oss_status       => l_export_to_oss_status
                ,x_error_code                 => l_ch_error
                ,x_batch_id                   => l_ch_batch_id
                ,x_request_id                 => l_conc_request_id
                ,x_mode                       => 'R'
                ,x_extra_round_nbr            => app_choices_rec.extra_round_nbr
                ,x_system_code                => app_choices_rec.system_code
                ,x_part_time                  => app_choices_rec.part_time
                ,x_interview                  => app_choices_rec.interview
                ,x_late_application           => app_choices_rec.late_application
                ,x_modular                    => app_choices_rec.modular
                ,x_residential                => app_choices_rec.residential
                ,x_ucas_cycle                 => app_choices_rec.ucas_cycle);
        END LOOP ; -- loop for application choice records

      END IF; -- person details not found in OSS for the passed ucas application
      CLOSE c_pe_person;


  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO sp_current_person;
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UCAS_EXPORT_TO_OSS.POPULATE_IMP_INT'||' - '||SQLERRM);
      fnd_file.put_line(fnd_file.LOG,fnd_message.get());
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

  END  populate_imp_int;


  PROCEDURE import_process(
    p_source_type_id igs_pe_src_types_all.source_type_id%TYPE,
    p_batch_id NUMBER,
    p_orgid NUMBER
  )  IS

    /******************************************************************
     Created By      :   smaddali
     Date Created By :   12-sep-2002
     Purpose         :  Submit the concurrent request for admission application import process
     Known limitations,enhancements,remarks:
     Change History
     Who       When          What
     --smaddali initialising l_rowid to null for bug 2626178
     -- smaddali modified this procedure for bug 2643048 UCFD102 build , to remove code creating admission
     -- interface ctl record
     ***************************************************************** */

    l_row_id VARCHAR2(26);

    CURSOR cur_match_set IS
      SELECT match_set_id
      FROM   igs_pe_match_sets
      WHERE  source_type_id = p_source_type_id;
    match_set_rec cur_match_set%ROWTYPE;

    l_interface_run_id igs_ad_interface_ctl.interface_run_id%TYPE;
    l_errbuff VARCHAR2(100) ;
    l_retcode NUMBER ;


  BEGIN

    -- Get the match set criteria corresponding to the ucas source type to be used for the person import
    match_set_rec := NULL ;
    OPEN cur_match_set;
    FETCH cur_match_set INTO match_set_rec;
    CLOSE cur_match_set;

    l_interface_run_id := NULL ;
    l_errbuff:= NULL ;
    l_retcode := NULL ;
    -- Call admission application import process procedure because current process has to wait until import process is finished
    IGS_AD_IMP_001.IMP_ADM_DATA ( errbuf => l_errbuff,
                                  retcode => l_retcode ,
                                  p_batch_id =>  p_batch_id,
                                  p_source_type_id => p_source_type_id,
                                  p_match_set_id => match_set_rec.match_set_id,
                                  p_acad_cal_type => NULL ,
                                  p_acad_sequence_number => NULL ,
                                  p_adm_cal_type => NULL ,
                                  p_adm_sequence_number => NULL ,
                                  p_admission_cat => NULL ,
                                  p_s_admission_process_type => NULL ,
                                  p_interface_run_id =>  l_interface_run_id ,
                                  P_org_id => NULL ) ;


 EXCEPTION
    WHEN OTHERS THEN
      -- even though the admission import process completes in error , this process should continue processing
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UCAS_EXPORT_TO_OSS.IMPORT_PROCESS'||' - '||SQLERRM);
      fnd_file.put_line(fnd_file.LOG,fnd_message.get());

 END import_process;

 PROCEDURE obsolete_applications(
        p_app_no igs_uc_applicants.app_no%TYPE ,
        p_choice_no igs_uc_app_choices.choice_no%TYPE
        ) IS
    /******************************************************************
     Created By      :   smaddali
     Date Created By :   12-SEP-2002
     Purpose         :   To obsolete old applications when the
                     choice record will result in a new application/instance
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     smaddali               initialising l_rowid to null for bug 2626178
     smaddali               checking if record exists before inserting into igs_uc_old_oustat  if so then update ,
                            else insert. Also added code to get unit set cd for point of entry and use it in finding
                            matching admissions application, for bug 2630219
     ayedubat  24-MAR-2003  Added the Logic to identify the Applications Choices modified by UCAS  which already went UF
                            and institution asking for change in Course, Entry Month, Entry Year or Point of Entry for
                            the Bug, 2669209
     rbezawad  7-Oct-03     Added a validation before setting the export_to_oss status to 'UF' which will check for
                            ucas decision is 'U' or 'A' and the reply is 'F'.  Bug: 3179630
     jchakrab  10-Oct-2005  Modified for 4424068 - added CANCEL functionality for prog version change
     jchin     20-jan-2006  Modified for R12 Perf improvements - bug 3691277 and 3691250
     jchakrab  04-May-2006  Modified for 5203018 - modified to close c_cancel_appl cursor correctly
     jchakrab  22-May-2006  Modified for 5165624
    ***************************************************************** */

    l_description igs_ad_batc_def_det_all.description%TYPE ;
    l_rowid VARCHAR2(50) ;

    l_batch_id igs_ad_batc_def_det_all.batch_id%TYPE ;

    l_appl_batch_id NUMBER;
    l_dec_batch_id NUMBER;
    l_aca_cal_type igs_uc_sys_calndrs.aca_cal_type%TYPE ;
    l_aca_seq_no igs_uc_sys_calndrs.aca_cal_seq_no%TYPE;
    l_adm_cal_type igs_uc_sys_calndrs.adm_cal_type%TYPE ;
    l_adm_seq_no igs_uc_sys_calndrs.adm_cal_seq_no%TYPE ;
    l_interface_mkdes_id NUMBER ;
    l_count NUMBER ;
    l_new_appl BOOLEAN ;
    l_new_appl_inst BOOLEAN ;
    l_cancel_appl BOOLEAN; -- added for bug 4424068
    l_ch_error igs_uc_app_choices.error_code%TYPE ;
    l_ch_batch_id igs_uc_app_choices.batch_id%TYPE ;
    l_export_to_oss_status igs_uc_app_choices.export_to_oss_status%TYPE ;
    l_error_message fnd_new_messages.message_text%TYPE; -- Bug 3297241
    l_return_status VARCHAR2(100) ;
    l_pref_excep BOOLEAN ;

    -- Get all valid application choices with status NEW belonging to current institution
    -- smaddali modified this cursor to add new field system_code in select clause ,
    -- and check for system_code for bug 2630219
    CURSOR c_new_app_ch IS
      SELECT ch.app_no , ch.choice_no , ch.deferred , ch.batch_id , ch.export_to_oss_status ,
             ch.point_of_entry , ch.oss_program_code, ch.oss_location ,ch.oss_program_version ,
             ch.oss_attendance_type ,ch.oss_attendance_mode , ch.system_code, ch.ucas_cycle,
             ch.entry_year, ch.entry_month, ch.decision, ch.reply
      FROM  igs_uc_app_choices ch
      WHERE ch.app_no = NVL(p_app_no,ch.app_no) AND
            ch.export_to_oss_status = 'NEW' AND
            ch.choice_no = NVL(p_choice_no , ch.choice_no) AND
            ch.institute_code = (SELECT df.current_inst_code FROM igs_uc_defaults df
                                  WHERE df.system_code = ch.system_code)
      ORDER BY ch.ucas_cycle, ch.app_no, ch.choice_no;

    -- Get all valid application choices with status OO belonging to current institution
    -- smaddali modified this cursor to add check for system_code ,bug 2643048 UCFD102 build
    CURSOR c_oo_ch IS
      SELECT ch.batch_id, ch.deferred , ch.app_no , ch.choice_no , ch.system_code, ch.ucas_cycle, ch.entry_year, ch.entry_month
      FROM  igs_uc_app_choices ch
      WHERE ch.app_no = NVL(p_app_no,ch.app_no) AND
            ch.export_to_oss_status ='OO' AND
            ch.choice_no = NVL(p_choice_no , ch.choice_no) AND
            ch.institute_code = (SELECT df.current_inst_code FROM igs_uc_defaults df
                                 WHERE df.system_code = ch.system_code)
      ORDER BY ch.ucas_cycle, ch.app_no, ch.choice_no;

    -- Get the admission application corresponding to the passed application choice
    -- i.e if this choice has been previously exported to oss or not
    -- smaddali modified this cursor to add check for alt_appl_id ,bug 2643048 UCFD102 build
    CURSOR c_adm_appl( cp_app_no igs_uc_app_choices.app_no%TYPE,
                        cp_choice_no igs_uc_app_choices.choice_no%TYPE ) IS
    SELECT c.person_id , c.admission_appl_number
    FROM igs_uc_applicants a , igs_uc_app_choices b , igs_ad_appl_all c
    WHERE a.app_no = b.app_no AND
          a.oss_person_id = c.person_id AND
          TO_CHAR(a.app_no) = c.alt_appl_id AND
          b.choice_no = c.choice_number AND
          b.app_no = cp_app_no AND
          b.choice_no = cp_choice_no  ;
    c_adm_appl_rec c_adm_appl%ROWTYPE ;

    -- Get the admission application number of the application corresponding to the passed application choice
    -- smaddali modified this cursor to add check for alt_appl_id ,bug 2643048 UCFD102 build
    CURSOR c_match_adm_appl(cp_app_no igs_uc_app_choices.app_no%TYPE,
                        cp_choice_no igs_uc_app_choices.choice_no%TYPE ) IS
    SELECT c.person_id,c.admission_appl_number ,b.choice_no
    FROM igs_uc_applicants a , igs_uc_app_choices b , igs_ad_appl_all c
    WHERE a.app_no = b.app_no AND
          a.oss_person_id = c.person_id AND
          TO_CHAR(a.app_no) = c.alt_appl_id AND
          b.choice_no = c.choice_number AND
          c.acad_cal_type = l_aca_cal_type AND
          c.acad_ci_sequence_number = l_aca_seq_no AND
          c.adm_cal_type = l_adm_cal_type AND
          c.adm_ci_sequence_number = l_adm_seq_no AND
          b.app_no = cp_app_no AND
          b.choice_no = cp_choice_no  AND
          igs_ad_gen_007.Admp_Get_Saas(c.adm_appl_status) <> 'COMPLETED';
    c_match_adm_appl_rec c_match_adm_appl%ROWTYPE ;

    -- Get the admission application instance corresponding to the passed application choice
    -- smaddali added unit set cd and version number parameters and in where clause using these parameters ,bug2630219
    -- smaddali modified this cursor to add check for alt_appl_id ,bug 2643048 UCFD102 build
    CURSOR c_adm_appl_inst (cp_app_no igs_uc_app_choices.app_no%TYPE,
                        cp_choice_no igs_uc_app_choices.choice_no%TYPE,
                        cp_adm_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE ,
                        cp_unit_set_cd igs_ad_ps_appl_inst.unit_set_cd%TYPE ,
                        cp_us_version_number igs_ad_ps_appl_inst.us_version_number%TYPE ) IS
    SELECT 'X'
    FROM igs_uc_applicants a , igs_uc_app_choices b , igs_ad_appl_all c,
         igs_ad_ps_appl_all d , igs_ad_ps_appl_inst_all e
    WHERE a.app_no = b.app_no AND
          a.oss_person_id = c.person_id AND
          TO_CHAR(a.app_no) = c.alt_appl_id AND
          b.choice_no = c.choice_number AND
          c.person_id = d.person_id AND
          c.admission_appl_number = cp_adm_appl_number AND
          c.admission_appl_number = d.admission_appl_number AND
          d.person_id = e.person_id AND
          d.admission_appl_number = e.admission_appl_number AND
          d.nominated_course_cd = e.nominated_course_cd AND
          b.oss_program_code = e.course_cd AND
          b.oss_program_version = e.crv_version_number AND
          b.oss_location = e.location_cd AND
          b.oss_attendance_type = e.attendance_type AND
          b.oss_attendance_mode = e.attendance_mode AND
          e.unit_set_cd = cp_unit_set_cd AND
          e.us_version_number = cp_us_version_number AND
          b.app_no = cp_app_no AND
          b.choice_no = cp_choice_no
    ORDER BY e.preference_number ASC ;
    c_adm_appl_inst_rec c_adm_appl_inst%ROWTYPE ;

    -- Get the admission application instance corresponding to the passed application choice
    -- for bug 4424068 - need to check if the oss-program-version has changed for the application
    -- if the only change in the new choice record is the program version number
    -- and the current application status is 'RECEIVED', and current outcome status is 'PENDING'/'WITHDRAWN'

    CURSOR c_cancel_appl (cp_app_no igs_uc_app_choices.app_no%TYPE,
                        cp_choice_no igs_uc_app_choices.choice_no%TYPE,
                        cp_adm_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE ,
                        cp_unit_set_cd igs_ad_ps_appl_inst.unit_set_cd%TYPE ,
                        cp_us_version_number igs_ad_ps_appl_inst.us_version_number%TYPE ) IS
    SELECT
         c.person_id , c.admission_appl_number ,c.choice_number, e.sequence_number,
         e.decision_date , e.decision_reason_id , e.decision_make_id ,e.adm_outcome_status ,
         e.nominated_course_cd , c.adm_cal_type , c.adm_ci_sequence_number,
         c.acad_cal_type , c.acad_ci_sequence_number ,c.admission_cat ,c.s_admission_process_type
    FROM igs_uc_applicants a , igs_uc_app_choices b , igs_ad_appl_all c,
         igs_ad_ps_appl_all d , igs_ad_ps_appl_inst_all e
    WHERE a.app_no = b.app_no AND
          a.oss_person_id = c.person_id AND
          TO_CHAR(a.app_no) = c.alt_appl_id AND
          b.choice_no = c.choice_number AND
          c.person_id = d.person_id AND
          c.admission_appl_number = cp_adm_appl_number AND
          c.admission_appl_number = d.admission_appl_number AND
          d.person_id = e.person_id AND
          d.admission_appl_number = e.admission_appl_number AND
          d.nominated_course_cd = e.nominated_course_cd AND
          b.oss_program_code = e.course_cd AND
          b.oss_program_version <> e.crv_version_number AND
          b.oss_location = e.location_cd AND
          b.oss_attendance_type = e.attendance_type AND
          b.oss_attendance_mode = e.attendance_mode AND
          e.unit_set_cd = cp_unit_set_cd AND
          e.us_version_number = cp_us_version_number AND
          b.app_no = cp_app_no AND
          b.choice_no = cp_choice_no AND
          igs_ad_gen_007.Admp_Get_Saas(c.adm_appl_status) = 'RECEIVED' AND
          igs_ad_gen_008.Admp_Get_Saos(e.adm_outcome_status) IN ('PENDING','SUSPEND');
    c_cancel_appl_rec c_cancel_appl%ROWTYPE;


    -- Get the interface ctl ID
    CURSOR c_interface_run_id IS
    SELECT igs_ad_interface_ctl_s.NEXTVAL
    FROM dual ;
    l_interface_run_id NUMBER ;

   -- Get the application  to be voided ,i.e the currently active application instance
    -- smaddali modified this cursor to add check for alt_appl_id ,bug 2643048 UCFD102 build
    CURSOR c_obsol_appl_cnt(cp_app_no igs_uc_applicants.app_no%TYPE ,
                          cp_choice_number igs_ad_appl_all.choice_number%TYPE) IS
    SELECT   COUNT(*)
    FROM  igs_uc_applicants a , igs_ad_appl_all c,  igs_ad_ps_appl_all d ,
            igs_ad_ps_appl_inst_all e , igs_ad_ou_stat ou
    WHERE  a.app_no = cp_app_no AND
           a.oss_person_id = c.person_id AND
           TO_CHAR(a.app_no) = c.alt_appl_id AND
           c.choice_number = cp_choice_number AND
           c.person_id = d.person_id AND
           c.admission_appl_number = d.admission_appl_number AND
           d.person_id = e.person_id AND
           d.admission_appl_number = e.admission_appl_number AND
           d.nominated_course_cd = e.nominated_course_cd AND
           e.adm_outcome_status = ou.adm_outcome_status AND
           ou.s_adm_outcome_status NOT IN ('SUSPEND','VOIDED','WITHDRAWN');
    l_obsol_appl_cnt NUMBER;

    -- Get the application  to be voided ,i.e the currently active application instance
    -- smaddali modified this cursor to add check for alt_appl_id ,bug 2643048 UCFD102 build
    CURSOR c_obsol_appl(cp_app_no igs_uc_applicants.app_no%TYPE ,
                        cp_choice_number igs_ad_appl_all.choice_number%TYPE) IS
    SELECT c.person_id , c.admission_appl_number ,c.choice_number, e.sequence_number,
           e.decision_date , e.decision_reason_id , e.decision_make_id ,e.adm_outcome_status ,
           e.nominated_course_cd , c.adm_cal_type , c.adm_ci_sequence_number,
           c.acad_cal_type , c.acad_ci_sequence_number ,c.admission_cat ,c.s_admission_process_type
    FROM   igs_uc_applicants a , igs_ad_appl_all c,  igs_ad_ps_appl_all d ,
           igs_ad_ps_appl_inst_all e , igs_ad_ou_stat ou
    WHERE  a.app_no = cp_app_no AND
           a.oss_person_id = c.person_id AND
           TO_CHAR(a.app_no)   = c.alt_appl_id AND
           c.choice_number = cp_choice_number AND
           c.person_id = d.person_id AND
           c.admission_appl_number = d.admission_appl_number AND
           d.person_id = e.person_id AND
           d.admission_appl_number = e.admission_appl_number AND
           d.nominated_course_cd = e.nominated_course_cd AND
           e.adm_outcome_status = ou.adm_outcome_status AND
           ou.s_adm_outcome_status NOT IN ('SUSPEND','VOIDED','WITHDRAWN');
    c_obsol_appl_rec  c_obsol_appl%ROWTYPE ;

    -- Get the application instance details for incrementing preference number
    CURSOR c_upd_appl_inst ( cp_person_id igs_ad_ps_appl_inst.person_id%TYPE,
                             cp_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE  ) IS
    SELECT a.ROWID , a.*
    FROM igs_ad_ps_appl_inst_all a
    WHERE a.person_id = cp_person_id AND
          a.admission_appl_number = cp_admission_appl_number
    ORDER BY a.preference_number DESC ;


    -- Get the admission decision import interface record for the passed admission application instace.
    CURSOR c_dec_int( p_batch_id IGS_AD_BATC_DEF_DET_ALL.batch_id%TYPE ,
                        p_person_id IGS_AD_ADMDE_INT.person_id%TYPE,
                        p_admission_appl_number IGS_AD_ADMDE_INT.admission_appl_number%TYPE,
                        p_nominated_course_cd IGS_AD_ADMDE_INT.nominated_course_cd%TYPE,
                        p_sequence_number IGS_AD_ADMDE_INT.sequence_number%TYPE ) IS
   SELECT error_code , status
   FROM IGS_AD_ADMDE_INT_ALL
   WHERE batch_id           = p_batch_id AND
      person_id             = p_person_id   AND
      admission_appl_number = p_admission_appl_number AND
      nominated_course_cd   = p_nominated_course_cd AND
      sequence_number       = p_sequence_number ;
   c_dec_int_rec c_dec_int%ROWTYPE;

   --smaddali added this cursor for bug 2630219
   -- Check if old outcome status record exists for the passed application choice
   CURSOR c_old_oustat ( cp_app_no igs_uc_old_oustat.app_no%TYPE,
                    cp_choice_no igs_uc_old_oustat.choice_no%TYPE ) IS
   SELECT ou.ROWID , ou.*
   FROM igs_uc_old_oustat ou
   WHERE app_no = cp_app_no AND
        choice_no = cp_choice_no ;
   c_old_oustat_rec  c_old_oustat%ROWTYPE ;

     -- Get the unit set code corresponding to the application choice point of entry
     -- smaddali added this cursor for bug 2630219
     -- jchin - bug 3691277 and 3691250
    CURSOR c_unit_set_cd(p_seq_no igs_ps_us_prenr_cfg.sequence_no%TYPE,
                   p_course_cd igs_ps_ofr_opt_unit_set_v.course_cd%TYPE,
                   p_version_number igs_ps_ofr_opt_unit_set_v.crv_version_number%TYPE,
                   p_acad_cal_type igs_ps_ofr_opt_unit_set_v.cal_type%TYPE,
                   p_location_cd igs_ps_ofr_opt_unit_set_v.location_cd%TYPE,
                   p_attendance_mode igs_ps_ofr_opt_unit_set_v.attendance_mode%TYPE,
                   p_attendance_type igs_ps_ofr_opt_unit_set_v.attendance_type%TYPE) IS
      SELECT  US.UNIT_SET_CD,
              US.VERSION_NUMBER US_VERSION_NUMBER
      FROM    IGS_PS_OFR_UNIT_SET COUS,
              IGS_PS_OFR_OPT COO,
              IGS_EN_UNIT_SET US,
              IGS_EN_UNIT_SET_CAT USC,
              IGS_PS_US_PRENR_CFG CFG
      WHERE   COUS.COURSE_CD = P_COURSE_CD
      AND     COUS.CRV_VERSION_NUMBER = P_VERSION_NUMBER
      AND     COUS.CAL_TYPE = P_ACAD_CAL_TYPE
      AND     COO.LOCATION_CD = P_LOCATION_CD
      AND     COO.ATTENDANCE_MODE = P_ATTENDANCE_MODE
      AND     COO.ATTENDANCE_TYPE = P_ATTENDANCE_TYPE
      AND     COO.COURSE_CD = COUS.COURSE_CD
      AND     COO.VERSION_NUMBER = COUS.CRV_VERSION_NUMBER
      AND     COO.CAL_TYPE = COUS.CAL_TYPE
      AND     US.UNIT_SET_CD = COUS.UNIT_SET_CD
      AND     US.VERSION_NUMBER = COUS.US_VERSION_NUMBER
      AND     US.UNIT_SET_CAT = USC.UNIT_SET_CAT
      AND     USC.S_UNIT_SET_CAT ='PRENRL_YR'
      AND     US.UNIT_SET_CD = CFG.UNIT_SET_CD
      AND     CFG.SEQUENCE_NO = P_SEQ_NO
      AND     NOT EXISTS (SELECT COURSE_CD FROM IGS_PS_OF_OPT_UNT_ST COOUS WHERE COOUS.COO_ID = COO.COO_ID)
      UNION ALL
      SELECT  US.UNIT_SET_CD,
              US.VERSION_NUMBER US_VERSION_NUMBER
      FROM    IGS_PS_OF_OPT_UNT_ST COOUS,
              IGS_EN_UNIT_SET US,
              IGS_EN_UNIT_SET_CAT USC,
              IGS_PS_US_PRENR_CFG CFG
      WHERE   COOUS.COURSE_CD = P_COURSE_CD
      AND     COOUS.CRV_VERSION_NUMBER = P_VERSION_NUMBER
      AND     COOUS.CAL_TYPE = P_ACAD_CAL_TYPE
      AND     COOUS.LOCATION_CD = P_LOCATION_CD
      AND     COOUS.ATTENDANCE_MODE = P_ATTENDANCE_MODE
      AND     COOUS.ATTENDANCE_TYPE = P_ATTENDANCE_TYPE
      AND     US.UNIT_SET_CD = COOUS.UNIT_SET_CD
      AND     US.VERSION_NUMBER = COOUS.US_VERSION_NUMBER
      AND     US.UNIT_SET_CAT = USC.UNIT_SET_CAT
      AND     USC.S_UNIT_SET_CAT ='PRENRL_YR'
      AND     US.UNIT_SET_CD = CFG.UNIT_SET_CD
      AND     CFG.SEQUENCE_NO = P_SEQ_NO;
    c_unit_set_cd_rec c_unit_set_cd%ROWTYPE;

    -- smaddali added cursors ,for bug 2643048 UCFD102 build
    CURSOR c_defaults( cp_system_code igs_uc_defaults.system_code%TYPE) IS
    SELECT *
    FROM igs_uc_defaults def
    WHERE def.system_code = NVL(cp_system_code, def.system_code);
    c_defaults_rec c_defaults%ROWTYPE ;

    CURSOR c_obs_ou_stat ( cp_out_stat igs_ad_ou_stat.adm_outcome_status%TYPE) IS
    SELECT s_Adm_outcome_status
    FROM igs_Ad_ou_stat
    WHERE adm_outcome_status = cp_out_stat ;
    l_s_obsol_ou_stat  igs_ad_ou_stat.s_adm_outcome_status%TYPE ;

    -- Cursor to fetch the latest Transaction
    CURSOR cur_latest_trans( p_app_no     igs_uc_app_choices.app_no%TYPE,
                             p_choice_no  igs_uc_app_choices.choice_no%TYPE,
                             p_ucas_cycle igs_uc_app_choices.ucas_cycle%TYPE) IS
      SELECT transaction_type,program_code,entry_month,entry_year,entry_point
      FROM   IGS_UC_TRANSACTIONS tran
      WHERE tran.app_no    = p_app_no
      AND   tran.choice_no = p_choice_no
      AND   tran.ucas_cycle = p_ucas_cycle
      ORDER BY tran.uc_tran_id DESC;
    cur_latest_trans_rec cur_latest_trans%ROWTYPE;

    -- Cursor to find whether a Completed OSS Admission Application already exist
    -- for the UCAS Application Choice
    CURSOR cur_comp_app_choice(p_app_no    igs_uc_app_choices.app_no%TYPE ,
                               p_choice_no igs_uc_app_choices.choice_no%TYPE,
                               p_ucas_cycle igs_uc_app_choices.ucas_cycle%TYPE ) IS
      SELECT apl.person_id,apl.admission_appl_number
      FROM   IGS_UC_APP_CHOICES uac,
             IGS_UC_APPLICANTS ua,
             IGS_AD_APPL_ALL apl,
             IGS_AD_PS_APPL_ALL aplps,
             IGS_AD_PS_APPL_INST_ALL aplinst
      WHERE uac.app_no    = p_app_no
      AND   uac.choice_no = p_choice_no
      AND   uac.ucas_cycle= p_ucas_cycle
      AND   ua.app_no     = uac.app_no
      AND   ua.oss_person_id    = apl.person_id
      AND   TO_CHAR(ua.app_no)  = apl.alt_appl_id
      AND   apl.choice_number   = uac.choice_no
      AND   apl.person_id = aplps.person_id
      AND   apl.admission_appl_number = aplps.admission_appl_number
      AND   aplps.person_id = aplinst.person_id
      AND   aplps.admission_appl_number = aplinst.admission_appl_number
      AND   aplps.nominated_course_cd = aplinst.nominated_course_cd
      AND   igs_ad_gen_007.admp_get_saas(apl.adm_appl_status) = 'COMPLETED'
      AND   igs_ad_gen_008.Admp_Get_Saos(aplinst.adm_outcome_status) <> 'CANCELLED';
    cur_comp_app_choice_rec cur_comp_app_choice%ROWTYPE;

    -- Cursor to find any change in the UCAS Application Choice with the OSS Admission
    -- Application Instance
    CURSOR change_in_adm_appl_cur (
      cp_app_no      igs_uc_app_choices.app_no%TYPE,
      cp_choice_no   igs_uc_app_choices.choice_no%TYPE,
      cp_ucas_cycle  igs_uc_app_choices.ucas_cycle%TYPE,
      cp_person_id   igs_pe_person.person_id%TYPE,
      cp_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE) IS
    SELECT
      'X'
    FROM
      igs_uc_app_choices uac,
      igs_uc_sys_calndrs ucal,
      igs_ad_appl_all apl,
      igs_ad_ps_appl_inst_all aplinst,
      igs_en_unit_set us,
      igs_en_unit_set_cat usc,
      igs_ps_us_prenr_cfg cnfg,
      igs_uc_map_out_stat mos,
      igs_uc_map_off_resp mor
    WHERE uac.app_no    = cp_app_no
      AND  uac.choice_no = cp_choice_no
      AND  uac.ucas_cycle= cp_ucas_cycle
      -- Comparing the Entry Year and Entry Month mapping with the Calendars
      AND  ucal.system_code = uac.system_code
      AND  uac.entry_year   = ucal.entry_year
      AND  (uac.entry_month = ucal.entry_month OR ucal.entry_month = 0)
      AND  apl.person_id    = cp_person_id
      AND  apl.admission_appl_number    = cp_admission_appl_number
      AND  apl.acad_cal_type            = ucal.aca_cal_type
      AND  apl.acad_ci_sequence_number  = ucal.aca_cal_seq_no
      AND  apl.adm_cal_type             = ucal.adm_cal_type
      AND  apl.adm_ci_sequence_number   = ucal.adm_cal_seq_no
      -- Comparing the OSS Program Instance
      AND  aplinst.person_id  = apl.person_id
      AND  aplinst.admission_appl_number = apl.admission_appl_number
      AND  aplinst.nominated_course_cd = uac.oss_program_code
      AND  aplinst.crv_version_number  = uac.oss_program_version
      AND  aplinst.location_cd         = uac.oss_location
      AND  aplinst.attendance_mode     = uac.oss_attendance_mode
      AND  aplinst.attendance_type     = uac.oss_attendance_type
      -- Comparing the Final Unit Set
      AND  aplinst.unit_set_cd         = us.unit_set_cd
      AND  aplinst.us_version_number   = us.version_number
      AND  us.unit_set_cat    = usc.unit_set_cat
      AND  usc.s_unit_set_cat = 'PRENRL_YR'
      AND  us.unit_set_cd   = cnfg.unit_set_cd
      AND  cnfg.sequence_no    = NVL(uac.point_of_entry,1)
      -- Comparing the Admission Outcome Status
      AND  mos.system_code   =  uac.system_code
      AND  mos.decision_code = uac.decision
      AND  mos.default_ind   = 'Y'
      AND  mos.closed_ind    <> 'Y'
      AND  mos.adm_outcome_status = aplinst.adm_outcome_status
      -- Comparing the Admission Offer Response Status
      AND(uac.reply IS NULL OR
          (mor.system_code   = uac.system_code
           AND  mor.decision_code = uac.decision
           AND  mor.reply_code    = uac.reply
           AND  mor.closed_ind    <> 'Y'
           AND  mor.adm_offer_resp_status = aplinst.adm_offer_resp_status ) );
    l_dummy VARCHAR2(1);

    -- to get all the distinct system_codes belonging to the passed application choice parameter
    CURSOR c_ch_system IS
    SELECT DISTINCT a.system_code, a.entry_year, a.entry_month
    FROM igs_uc_app_choices a
    WHERE a.app_no = NVL(p_app_no, a.app_no)
    AND   a.choice_no = NVL(p_choice_no,a.choice_no)
    AND   a.export_to_oss_status = 'NEW'
    AND   a.institute_code IN (SELECT df.current_inst_code FROM igs_uc_defaults df);

    --Cursor to get the Calendar details for the given System, Entry Month and Entry Year.
    CURSOR cur_sys_entry_cal_det (cp_system_code  igs_uc_sys_calndrs.system_code%TYPE,
                                  cp_entry_year   igs_uc_sys_calndrs.entry_year%TYPE,
                                  cp_entry_month  igs_uc_sys_calndrs.entry_month%TYPE ) IS
      SELECT aca_cal_type,
             aca_cal_seq_no,
             adm_cal_type,
             adm_cal_seq_no
      FROM  igs_uc_sys_calndrs
      WHERE system_code = cp_system_code
      AND   entry_year = cp_entry_year
      AND   entry_month = cp_entry_month;

    l_sys_entry_cal_det_rec cur_sys_entry_cal_det%ROWTYPE;

    --Cursor to get the Admission Process Category and Admission Process Type for the
    --Admission Application Type defined for the System in UCAS Setup.
    CURSOR cur_apc_det ( cp_application_type igs_uc_defaults.application_type%TYPE) IS
      SELECT admission_cat, s_admission_process_type
      FROM   igs_ad_ss_appl_typ
      WHERE  admission_application_type = cp_application_type
      AND    closed_ind = 'N';

    l_apc_det_rec cur_apc_det%ROWTYPE;

    --Record Type to hold the batch_id created for a system cycle calendars.
    TYPE batch_det_type IS RECORD
     ( system_code igs_uc_app_choices.system_code%TYPE,
       entry_year  igs_uc_app_choices.entry_year%TYPE,
       entry_month igs_uc_app_choices.entry_month%TYPE,
       batch_id    igs_ad_batc_def_det_all.batch_id%TYPE
      );

    --Table Type to hold the batch_id created for diferrent system cycle calendars.
     TYPE batch_det_table_type IS TABLE OF batch_det_type INDEX BY BINARY_INTEGER;

    --Table/Collection variable to hold the records for batch ids created of diferrent system, cycle and calendars.
    l_batch_id_det batch_det_table_type;
    l_batch_id_loc NUMBER;


    PROCEDURE get_batchid_loc( p_system_code IN igs_uc_app_choices.system_code%TYPE,
                               p_entry_year  IN igs_uc_app_choices.entry_year%TYPE,
                               p_entry_month IN igs_uc_app_choices.entry_month%TYPE,
                               p_batch_id_loc OUT NOCOPY NUMBER) IS
        /******************************************************************
         Created By      :   rbezawad
         Date Created By :   14-Jun-03
         Purpose         :   Local Procedure to obsolete_applications() procedure, which retuns the Batch ID location
                             in pl/sql table(l_batch_id_det) of Batch ID for passed parameter criteria.
         Known limitations,enhancements,remarks:
         Change History
         Who       When         What
         rbezawad  24-Jul-2003  Done modifications to retrieve the batch id location based on system code, entry year and entry month.
                                  Modifications are done as part of UCCR007 and UCCR203 enhancement, Bug No: 3022067.
        ***************************************************************** */
    BEGIN

      -- Search for the Batch ID location only when the PL/SQL table has some data.
      IF l_batch_id_det.FIRST IS NOT NULL AND l_batch_id_det.LAST IS NOT NULL THEN

        --Loop through the pl/sql table and check for the values.
        FOR l_loc IN l_batch_id_det.FIRST..l_batch_id_det.LAST LOOP
          IF l_batch_id_det(l_loc).system_code = p_system_code AND
             l_batch_id_det(l_loc).entry_year = p_entry_year AND
             l_batch_id_det(l_loc).entry_month = p_entry_month THEN
            --If the Batch ID found for the matching parameters then return the location of batch id in to out parameter p_batch_id_loc.
            p_batch_id_loc := l_loc;
            EXIT;
          END IF;
        END LOOP;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UCAS_EXPORT_TO_OSS.GET_BATCHID_LOC'||' - '||SQLERRM);
        fnd_file.put_line(fnd_file.LOG,fnd_message.get());
        App_Exception.Raise_Exception;

    END get_batchid_loc;

  BEGIN

      l_batch_id_loc := 0;

      -- Insert a record into the Admission Decision Import Batch table,IGS_AD_BATC_DEF_DET_ALL
      -- for the deffered academic/admission calendar session details
      -- This Batch ID will be used while populating the Admission Decision Import Process Interface Table
      FOR c_ch_system_rec IN c_ch_system LOOP

        --Get the Admission Process category details available in UCAS Setup.
        FOR c_defaults_rec IN c_defaults(c_ch_system_rec.system_code) LOOP

          --Get the APC details corresponding to the Application Type defined in UCAS Setup
          OPEN cur_apc_det(c_defaults_rec.application_type);
          FETCH cur_apc_det INTO l_apc_det_rec;
          CLOSE cur_apc_det;

          -- We need to create a separate batch id for each of the UCAS System's calendars
          -- Get the Batch ID Description value from the Message,IGS_UC_DEC_BATCH
          fnd_message.set_name('IGS','IGS_UC_DEC_BATCH');
          l_description := fnd_message.Get() ;
          l_rowid := NULL ;
          l_batch_id := NULL;

          --Get the Calendar details for the given System, Entry Month and Entry Year from System Calendards table.
          l_sys_entry_cal_det_rec := NULL;
          OPEN cur_sys_entry_cal_det(c_ch_system_rec.system_code, c_ch_system_rec.entry_year,c_ch_system_rec.entry_month );
          FETCH cur_sys_entry_cal_det INTO l_sys_entry_cal_det_rec;
          --If no matching Entry Year and Entry Month record for the system is found in the System Calendars table then
          --  get the calendar details from the IGS_UC_SYS_CALNDRS table based on the system, Entry Year and Entry Month as 0 (Zero).
          IF cur_sys_entry_cal_det%NOTFOUND THEN
            CLOSE cur_sys_entry_cal_det;
            OPEN cur_sys_entry_cal_det(c_ch_system_rec.system_code, c_ch_system_rec.entry_year, 0);
            FETCH cur_sys_entry_cal_det INTO l_sys_entry_cal_det_rec;
          END IF;
          CLOSE cur_sys_entry_cal_det;

          -- We need to create a separate batch id for each of the calendar setup available for UCAS System, Entry Year and Entry Month details.
          igs_ad_batc_def_det_pkg.insert_row(
                   x_rowid                     => l_rowid,
                   x_batch_id                  => l_batch_id,
                   x_description               => l_description,
                   x_acad_cal_type             => l_sys_entry_cal_det_rec.aca_cal_type,
                   x_acad_ci_sequence_number   => l_sys_entry_cal_det_rec.aca_cal_seq_no,
                   x_adm_cal_type              => l_sys_entry_cal_det_rec.adm_cal_type,
                   x_adm_ci_sequence_number    => l_sys_entry_cal_det_rec.adm_cal_seq_no,
                   x_admission_cat             => l_apc_det_rec.admission_cat,
                   x_s_admission_process_type  => l_apc_det_rec.s_admission_process_type,
                   x_decision_make_id          => c_defaults_rec.decision_make_id,
                   x_decision_date             => SYSDATE,
                   x_decision_reason_id        => c_defaults_rec.decision_reason_id,
                   x_pending_reason_id         => NULL,
                   x_offer_dt                  => NULL,
                   x_offer_response_dt         => NULL,
                   x_mode                      => 'R'   );

          --Store the information of Batch ID created into a pl/sql table
          l_batch_id_det(l_batch_id_loc).system_code := c_ch_system_rec.system_code;
          l_batch_id_det(l_batch_id_loc).entry_year := c_ch_system_rec.entry_year;
          l_batch_id_det(l_batch_id_loc).entry_month := c_ch_system_rec.entry_month;
          l_batch_id_det(l_batch_id_loc).batch_id := l_batch_id;
          l_batch_id_loc := l_batch_id_loc + 1;

         END LOOP ;

       END LOOP ;

       l_batch_id_loc := NULL;

       -- Get all the valid application choices in status NEW and
       -- check if the old applications need to be obsoleted
       FOR  c_new_app_ch_rec IN c_new_app_ch LOOP
         Savepoint pref ;
         l_new_appl := FALSE ;
         l_new_appl_inst := FALSE ;
         l_export_to_oss_status := NULL ;
         l_ch_batch_id := NULL ;
         l_ch_error := NULL ;
         l_cancel_appl := FALSE;

         cur_comp_app_choice_rec := NULL;
         OPEN cur_comp_app_choice(c_new_app_ch_rec.app_no, c_new_app_ch_rec.choice_no,c_new_app_ch_rec.ucas_cycle) ;
         FETCH cur_comp_app_choice INTO cur_comp_app_choice_rec;
         IF cur_comp_app_choice%FOUND THEN
            --Check the Last Transaction Type whether it is 'RD' and Course, Entry Month, Entry Year and Point of Entry are NULL or not
            cur_latest_trans_rec := NULL ;
            OPEN cur_latest_trans(c_new_app_ch_rec.app_no, c_new_app_ch_rec.choice_no, c_new_app_ch_rec.ucas_cycle);
            FETCH cur_latest_trans INTO cur_latest_trans_rec;

            -- If Transaction Type is 'RD' and Course, Entry Month, Entry Year and Point of Entry are NULL
            -- and ucas decision is 'U' or 'A' and the reply is 'F' then set the export_to_oss_status to 'UF'
            IF cur_latest_trans%FOUND AND cur_latest_trans_rec.transaction_type = 'RD' AND
               cur_latest_trans_rec.program_code IS NULL AND cur_latest_trans_rec.entry_month IS NULL AND
               cur_latest_trans_rec.entry_year IS NULL AND cur_latest_trans_rec.entry_point IS NULL AND
               c_new_app_ch_rec.decision IN ('U','A') AND c_new_app_ch_rec.reply = 'F' THEN
              l_export_to_oss_status:= 'UF' ;
            ELSE

              -- Check whether any change in Decision, Reply, Program Offering Option, Point of entry map to
              -- OSS Admission Application Instance
              OPEN change_in_adm_appl_cur(c_new_app_ch_rec.app_no, c_new_app_ch_rec.choice_no, c_new_app_ch_rec.ucas_cycle,
                                          cur_comp_app_choice_rec.person_id, cur_comp_app_choice_rec.admission_appl_number );
              FETCH change_in_adm_appl_cur INTO l_dummy;

              -- If no change was found then change the status to COMP, else to MAN
              IF change_in_adm_appl_cur%FOUND THEN
                l_export_to_oss_status:= 'COMP';
              ELSE
                l_export_to_oss_status:= 'MAN';
                l_ch_error := 'M001' ;
              END IF;
              CLOSE change_in_adm_appl_cur;

            END IF ;
            CLOSE cur_latest_trans;

         ELSE
           -- Get the default UCAS setup values and keep them in package variable c_defaults_rec
           c_defaults_rec := NULL ;
           OPEN c_defaults(c_new_app_ch_rec.system_code) ;
           FETCH c_defaults INTO c_defaults_rec;
           CLOSE c_defaults ;

          --Get the Calendar details for the given System, Entry Month and Entry Year from System Calendards table.
          l_sys_entry_cal_det_rec := NULL;
          OPEN cur_sys_entry_cal_det(c_new_app_ch_rec.system_code, c_new_app_ch_rec.entry_year, c_new_app_ch_rec.entry_month );
          FETCH cur_sys_entry_cal_det INTO l_sys_entry_cal_det_rec;
          --If no matching Entry Year and Entry Month record for the system is found in the System Calendars table then
          --  get the calendar details from the IGS_UC_SYS_CALNDRS table based on the system, Entry Year and Entry Month as 0 (Zero).
          IF cur_sys_entry_cal_det%NOTFOUND THEN
            CLOSE cur_sys_entry_cal_det;
            OPEN cur_sys_entry_cal_det(c_new_app_ch_rec.system_code, c_new_app_ch_rec.entry_year, 0);
            FETCH cur_sys_entry_cal_det INTO l_sys_entry_cal_det_rec;
          END IF;
          CLOSE cur_sys_entry_cal_det;

           -- Get the system outcome status
           l_s_obsol_ou_stat := NULL ;
           OPEN c_obs_ou_stat( c_defaults_rec.obsolete_outcome_status) ;
           FETCH c_obs_ou_stat INTO l_s_obsol_ou_stat;
           CLOSE c_obs_ou_stat ;

           -- Determine if a new application / application instance needs to be created for this choice , or
           -- an application instance already exists for this choice
           OPEN c_adm_appl(c_new_app_ch_rec.app_no, c_new_app_ch_rec.choice_no) ;
           FETCH c_adm_appl INTO c_adm_appl_rec ;

           -- If there is no application in admissions with this choice number then
           -- it means that this choice had never been imported previously.
           -- Hence no need to void any existing application
           IF c_adm_appl%NOTFOUND THEN
             CLOSE c_adm_appl ;
             l_export_to_oss_status := 'OC' ;
             -- If this choice had been exported previously ,an application exits for it.
           ELSE

             CLOSE c_adm_appl ;
             -- Get the admission and academic calendars for this choice
             l_aca_cal_type := l_sys_entry_cal_det_rec.aca_cal_type ;
             l_aca_seq_no   := l_sys_entry_cal_det_rec.aca_cal_seq_no;
             l_adm_cal_type := l_sys_entry_cal_det_rec.adm_cal_type;
             l_adm_seq_no   := l_sys_entry_cal_det_rec.adm_cal_seq_no ;

             -- Check if an application exists for corresponding to this choice and calendars
             OPEN c_match_adm_appl(c_new_app_ch_rec.app_no, c_new_app_ch_rec.choice_no)  ;
             FETCH c_match_adm_appl INTO c_match_adm_appl_rec ;
             --If applications exist for this choice number but not for the choice's calendars then
             -- set flag that new application needs to be created and old application needs to be voided
             IF c_match_adm_appl%NOTFOUND THEN
                     l_new_appl := TRUE ;
             ELSE
                 --If applications exists for this choice number and choice's calendars then
                 -- check if the application instance for this choice's POP and unit set also exist

                 -- smaddali added this code to find the unit set code corresponding to the point of entry of the
                 -- current application choice ,for bug 2630219
                 -- Find Unit set cd
                 -- Get the Unit set cd corresponding to the application choice point of entry and POP
                 c_unit_set_cd_rec := NULL ;
                 OPEN c_unit_set_cd(NVL(c_new_app_ch_rec.point_of_entry,1),
                                     c_new_app_ch_rec.oss_program_code,
                                     c_new_app_ch_rec.oss_program_version,
                                     l_aca_cal_type,
                                     c_new_app_ch_rec.oss_location,
                                     c_new_app_ch_rec.oss_attendance_mode,
                                     c_new_app_ch_rec.oss_attendance_type  );
                FETCH c_unit_set_cd INTO c_unit_set_cd_rec;
                IF c_unit_set_cd%NOTFOUND  THEN
                   -- If the point of entry doesnot correspond to a valid Unit set cd then log error and skip the choice
                   fnd_message.set_name('IGS','IGS_UC_NO_UNIT_SET_CD');
                   fnd_message.set_token('APP_NO',TO_CHAR(c_new_app_ch_rec.app_no));
                   fnd_message.set_token('CHOICE_NO',TO_CHAR(c_new_app_ch_rec.choice_no));
                   fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
                   -- set the choice record error code to A003 and export status to OC to indicate that
                   -- import interface tables have not been successfully populated but an error was encountered
                   l_ch_error := 'A003' ;
                   l_export_to_oss_status := c_new_app_ch_rec.export_to_oss_status ;
                   l_ch_batch_id := NULL ;
                ELSE
                   -- smaddali added unit set cd and version number parameters to this cursor for bug 2630219
                   OPEN c_adm_appl_inst(c_new_app_ch_rec.app_no, c_new_app_ch_rec.choice_no,
                                c_match_adm_appl_rec.admission_appl_number ,
                                c_unit_set_cd_rec.unit_set_cd , c_unit_set_cd_rec.us_version_number) ;
                   FETCH c_adm_appl_inst INTO c_adm_appl_inst_rec ;
                   -- If application instance corresponding to the current choice is not found then
                   -- a new application instance needs to be created under the old application and
                   -- the old application instance needs to be obsoleted
                   IF c_adm_appl_inst%NOTFOUND THEN
                      l_new_appl_inst := TRUE ;

                      --for bug 4424068 - need to check if the oss-program-version has changed for the application
                      --if the only change in the new choice record is the program version number
                      --and the current application status is 'RECEIVED', and current outcome status is 'PENDING'/'WITHDRAWN'
                      --we need to CANCEL the application
                      OPEN c_cancel_appl (c_new_app_ch_rec.app_no, c_new_app_ch_rec.choice_no,
                                                     c_match_adm_appl_rec.admission_appl_number ,
                                                     c_unit_set_cd_rec.unit_set_cd , c_unit_set_cd_rec.us_version_number) ;
                      FETCH c_cancel_appl INTO c_cancel_appl_rec ;

                      IF c_cancel_appl%NOTFOUND THEN
                         --no action
                         NULL;
                      ELSE
                          l_cancel_appl := TRUE;
                          --need to cancel the application

                          -- capture outcome status, decision_maker_id,decision reason
                          -- If a record exists for this application choice then update it ,else create new record
                          c_old_oustat_rec := NULL ;
                          OPEN c_old_oustat(c_new_app_ch_rec.app_no , c_new_app_ch_rec.choice_no ) ;
                          FETCH c_old_oustat INTO c_old_oustat_rec ;
                          IF c_old_oustat%NOTFOUND THEN
                              l_rowid := NULL ;
                              igs_uc_old_oustat_pkg.insert_row (
                                   X_ROWID  => l_rowid
                                  ,X_APP_NO =>   c_new_app_ch_rec.app_no
                                  ,X_CHOICE_NO  =>  c_new_app_ch_rec.choice_no
                                  ,X_OLD_OUTCOME_STATUS => c_cancel_appl_rec.adm_outcome_status
                                  ,X_DECISION_DATE => c_cancel_appl_rec.decision_date
                                  ,X_DECISION_REASON_ID => c_cancel_appl_rec.decision_reason_id
                                  ,X_DECISION_MAKE_ID => c_cancel_appl_rec.decision_make_id
                                  ,X_MODE  => 'R'
                                  ) ;
                          ELSE
                             igs_uc_old_oustat_pkg.update_row (
                                  X_ROWID  => c_old_oustat_rec.ROWID
                                 ,X_APP_NO =>   c_old_oustat_rec.app_no
                                 ,X_CHOICE_NO  =>  c_old_oustat_rec.choice_no
                                 ,X_OLD_OUTCOME_STATUS => c_cancel_appl_rec.adm_outcome_status
                                 ,X_DECISION_DATE => c_cancel_appl_rec.decision_date
                                 ,X_DECISION_REASON_ID => c_cancel_appl_rec.decision_reason_id
                                 ,X_DECISION_MAKE_ID => c_cancel_appl_rec.decision_make_id
                                 ,X_MODE  => 'R'
                                 ) ;
                          END IF ;
                          CLOSE c_old_oustat ;

                          -- populate decision import interface tables
                          -- 1. Get the Batch ID of the Admission Decision Import Batch table,IGS_AD_BATC_DEF_DET_ALL
                          l_dec_batch_id := NULL;
                          l_batch_id_loc :=NULL;
                          get_batchid_loc(p_system_code  => c_new_app_ch_rec.system_code,
                                    p_entry_year   => c_new_app_ch_rec.entry_year,
                                    p_entry_month  => c_new_app_ch_rec.entry_month,
                                    p_batch_id_loc => l_batch_id_loc);
                          IF l_batch_id_loc IS NOT NULL THEN
                              l_dec_batch_id := l_batch_id_det(l_batch_id_loc).batch_id;
                          END IF;

                          -- 2. Populate the Admission Decision Import Interface table,IGS_AD_ADMDE_INT_ALL
                          /* call the insert_row of the Admission Decision Import Interface table, IGS_AD_ADMDE_INT_ALL */
                          l_interface_run_id := NULL ;
                          l_interface_mkdes_id := NULL ;
                          l_error_message := NULL ;
                          l_return_status := NULL ;
                          OPEN c_interface_run_id ;
                          FETCH c_interface_run_id INTO l_interface_run_id ;
                          CLOSE c_interface_run_id ;
                          l_rowid := NULL ;

                          -- Create record in decision import interface tables for the applications which need to be voided
                          igs_ad_admde_int_pkg.insert_row (
                              x_rowid                    =>  l_rowid,
                              x_interface_mkdes_id       =>  l_interface_mkdes_id,
                              x_interface_run_id         =>  l_interface_run_id ,
                              x_batch_id                 =>  l_dec_batch_id,
                              x_person_id                =>  c_cancel_appl_rec.person_id,
                              x_admission_appl_number    =>  c_cancel_appl_rec.admission_appl_number,
                              x_nominated_course_cd      =>  c_cancel_appl_rec.nominated_course_cd,
                              x_sequence_number          =>  c_cancel_appl_rec.sequence_number,
                              x_adm_outcome_status       =>  IGS_AD_GEN_009.Admp_Get_Sys_Aos('CANCELLED'),
                              x_decision_make_id         =>  c_defaults_rec.decision_make_id,
                              x_decision_date            =>  TRUNC(SYSDATE),
                              x_decision_reason_id       =>  c_defaults_rec.decision_reason_id,
                              x_pending_reason_id        =>  NULL,
                              x_offer_dt                 =>  NULL,
                              x_offer_response_dt        =>  NULL,
                              x_status                   =>  '2', -- pending status
                              x_error_code               =>  NULL,
                              x_mode                     =>  'R',
                              x_reconsider_flag          =>  'N' );

                          -- 3. call the decision import process to obsolete old applications
                          igs_ad_imp_adm_des.prc_adm_outcome_status(
                              p_person_id                => c_cancel_appl_rec.person_id ,
                              p_admission_appl_number    => c_cancel_appl_rec.admission_appl_number ,
                              p_nominated_course_cd      => c_cancel_appl_rec.nominated_course_cd ,
                              p_sequence_number          => c_cancel_appl_rec.sequence_number,
                              p_adm_outcome_status       => IGS_AD_GEN_009.Admp_Get_Sys_Aos('CANCELLED'),
                              p_s_adm_outcome_status     => 'CANCELLED' ,
                              p_acad_cal_type            => c_cancel_appl_rec.acad_cal_type ,
                              p_acad_ci_sequence_number  => c_cancel_appl_rec.acad_ci_sequence_number,
                              p_adm_cal_type             => c_cancel_appl_rec.adm_cal_type ,
                              p_adm_ci_sequence_number   => c_cancel_appl_rec.adm_ci_sequence_number ,
                              p_admission_cat            => c_cancel_appl_rec.admission_cat ,
                              p_s_admission_process_type => c_cancel_appl_rec.s_admission_process_type ,
                              p_batch_id                 => l_dec_batch_id,
                              p_interface_run_id         => l_interface_run_id ,
                              p_interface_mkdes_id       => l_interface_mkdes_id,
                              p_error_message            => l_error_message,
                              p_return_status            => l_return_status ,
                              p_ucas_transaction         => 'N',
                              p_reconsideration          => 'N' );

                          -- if the decision import completed in error then set appropriate error code in app choice record
                          IF   l_error_message IS NOT NULL OR l_return_status = 'FALSE'   THEN
                              /* raise the error with code 'O002' */
                              fnd_message.set_name('IGS','IGS_UC_CANCEL_APP_DEC_IMP_ERR');
                              fnd_message.set_token('APP_NO', c_new_app_ch_rec.app_no);
                              fnd_message.set_token('CHOICE_NO', c_new_app_ch_rec.choice_no);
                              fnd_message.set_token('BATCH_ID', l_dec_batch_id);
                              fnd_file.put_line(fnd_file.LOG,fnd_message.get());
                              l_ch_error := 'O002' ;
                              l_ch_batch_id := l_dec_batch_id ;
                              l_export_to_oss_status := 'OO' ;
                          ELSE
                              -- decision import for obsoletion is successful
                              l_ch_error := NULL ;
                              l_ch_batch_id := NULL ;
                              l_export_to_oss_status := 'OC' ;

                              -- Log a message that the application choice has been successfully obsoleted
                              fnd_message.set_name('IGS','IGS_UC_CANCEL_APP_DEC_IMP_SUC');
                              fnd_message.set_token('APP_NO', c_new_app_ch_rec.app_no);
                              fnd_message.set_token('CHOICE_NO', c_new_app_ch_rec.choice_no);
                              fnd_file.put_line(fnd_file.LOG,fnd_message.get());
                          END IF ; -- decision import failed or passed

                       END IF; -- if c_cancel_appl%FOUND
                       CLOSE c_cancel_appl;

                   ELSE
                      -- If application instance corresponding to the current choice is not found then
                      -- no need to obsolete any applications
                      l_export_to_oss_status := 'OC';

                   END IF ;
                   CLOSE c_adm_appl_inst ;

                END IF ; -- If unit set cd mapped to point of entry is not found
                CLOSE c_unit_set_cd;

             END IF ;
             CLOSE c_match_adm_appl ;

           END IF ;


           -- Populate the decision application import interface tables when new application / instance is to be created
           IF (l_new_appl OR l_new_appl_inst) AND NOT l_cancel_appl THEN

                  -- Check the currently active admission application instances
                  l_obsol_appl_cnt := NULL;
                  OPEN c_obsol_appl_cnt(c_new_app_ch_rec.app_no,
                            c_new_app_ch_rec.choice_no );
                  FETCH c_obsol_appl_cnt INTO l_obsol_appl_cnt ;
                  CLOSE c_obsol_appl_cnt ;

                  -- If More than one application instances is active for the application log error message .
                  IF l_obsol_appl_cnt > 1  THEN
                     fnd_message.set_name('IGS','IGS_UC_MANY_APPL');
                     fnd_message.set_token('APP_NO', c_new_app_ch_rec.app_no);
                     fnd_message.set_token('CHOICE_NO', c_new_app_ch_rec.choice_no);
                     fnd_file.put_line(fnd_file.LOG,fnd_message.get());
                     l_ch_error := 'O003' ;
                     l_export_to_oss_status:= c_new_app_ch_rec.export_to_oss_status ;
                     l_ch_batch_id := NULL;

                  -- if there are no currently active application instances then no need to obsolete anything
                  ELSIF l_obsol_appl_cnt = 0 THEN
                      l_export_to_oss_status:= 'OC' ;
                      l_ch_error := NULL ;
                      l_ch_batch_id := NULL;

                              -- If exactly one active application instance found then obsolete it
                  ELSIF l_obsol_appl_cnt = 1 THEN
                    -- Get the old application instance to be voided
                    c_obsol_appl_rec := NULL;
                    OPEN c_obsol_appl(c_new_app_ch_rec.app_no,
                           c_new_app_ch_rec.choice_no );
                    FETCH c_obsol_appl INTO c_obsol_appl_rec ;
                    CLOSE c_obsol_appl  ;

                    -- populate application interface tables to
                    -- increment preference numbers of all existing application instances of the identified application to be obsoleted
                    BEGIN
                        FOR c_upd_appl_inst_rec IN c_upd_appl_inst(c_obsol_appl_rec.person_id,
                            c_obsol_appl_rec.admission_appl_number) LOOP

                             c_upd_appl_inst_rec.preference_number := c_upd_appl_inst_rec.preference_number + 1;
                             -- call TBH update row
                             l_pref_excep := FALSE;
                             igs_ad_ps_appl_inst_pkg.update_row (
                                  x_rowid                          => c_upd_appl_inst_rec.ROWID ,
                                  x_person_id                      => c_upd_appl_inst_rec.person_id ,
                                  x_admission_appl_number          => c_upd_appl_inst_rec.admission_appl_number ,
                                  x_nominated_course_cd            => c_upd_appl_inst_rec.nominated_course_cd ,
                                  x_sequence_number                => c_upd_appl_inst_rec.sequence_number ,
                                  x_predicted_gpa                  => c_upd_appl_inst_rec.predicted_gpa ,
                                  x_academic_index                 => c_upd_appl_inst_rec.academic_index  ,
                                  x_adm_cal_type                   => c_upd_appl_inst_rec.adm_cal_type  ,
                                  x_app_file_location              => c_upd_appl_inst_rec.app_file_location  ,
                                  x_adm_ci_sequence_number         => c_upd_appl_inst_rec.adm_ci_sequence_number ,
                                  x_course_cd                      => c_upd_appl_inst_rec.course_cd ,
                                  x_app_source_id                  => c_upd_appl_inst_rec.app_source_id ,
                                  x_crv_version_number             => c_upd_appl_inst_rec.crv_version_number ,
                                  x_waitlist_rank                  => c_upd_appl_inst_rec.waitlist_rank ,
                                  x_location_cd                    => c_upd_appl_inst_rec.location_cd ,
                                  x_attent_other_inst_cd           => c_upd_appl_inst_rec.attent_other_inst_cd ,
                                  x_attendance_mode                => c_upd_appl_inst_rec.attendance_mode ,
                                  x_edu_goal_prior_enroll_id       => c_upd_appl_inst_rec.edu_goal_prior_enroll_id  ,
                                  x_attendance_type                => c_upd_appl_inst_rec.attendance_type ,
                                  x_decision_make_id               => c_upd_appl_inst_rec.decision_make_id ,
                                  x_unit_set_cd                    => c_upd_appl_inst_rec.unit_set_cd  ,
                                  x_decision_date                  => c_upd_appl_inst_rec.decision_date ,
                                  x_attribute_category             => c_upd_appl_inst_rec.attribute_category  ,
                                  x_attribute1                     => c_upd_appl_inst_rec.attribute1 ,
                                  x_attribute2                     => c_upd_appl_inst_rec.attribute2 ,
                                  x_attribute3                     => c_upd_appl_inst_rec.attribute3 ,
                                  x_attribute4                     => c_upd_appl_inst_rec.attribute4 ,
                                  x_attribute5                     => c_upd_appl_inst_rec.attribute5 ,
                                  x_attribute6                     => c_upd_appl_inst_rec.attribute6 ,
                                  x_attribute7                     => c_upd_appl_inst_rec.attribute7 ,
                                  x_attribute8                     => c_upd_appl_inst_rec.attribute8 ,
                                  x_attribute9                     => c_upd_appl_inst_rec.attribute9 ,
                                  x_attribute10                    => c_upd_appl_inst_rec.attribute10 ,
                                  x_attribute11                    => c_upd_appl_inst_rec.attribute11 ,
                                  x_attribute12                    => c_upd_appl_inst_rec.attribute12 ,
                                  x_attribute13                    => c_upd_appl_inst_rec.attribute13 ,
                                  x_attribute14                    => c_upd_appl_inst_rec.attribute14 ,
                                  x_attribute15                    => c_upd_appl_inst_rec.attribute15 ,
                                  x_attribute16                    => c_upd_appl_inst_rec.attribute16 ,
                                  x_attribute17                    => c_upd_appl_inst_rec.attribute17 ,
                                  x_attribute18                    => c_upd_appl_inst_rec.attribute18 ,
                                  x_attribute19                    => c_upd_appl_inst_rec.attribute19 ,
                                  x_attribute20                    => c_upd_appl_inst_rec.attribute20 ,
                                  x_decision_reason_id             => c_upd_appl_inst_rec.decision_reason_id ,
                                  x_us_version_number              => c_upd_appl_inst_rec.us_version_number  ,
                                  x_decision_notes                 => c_upd_appl_inst_rec.decision_notes ,
                                  x_pending_reason_id              => c_upd_appl_inst_rec.pending_reason_id ,
                                  x_preference_number              => c_upd_appl_inst_rec.preference_number ,
                                  x_adm_doc_status                 => c_upd_appl_inst_rec.adm_doc_status ,
                                  x_adm_entry_qual_status          => c_upd_appl_inst_rec.adm_entry_qual_status ,
                                  x_deficiency_in_prep             => c_upd_appl_inst_rec.deficiency_in_prep ,
                                  x_late_adm_fee_status            => c_upd_appl_inst_rec.late_adm_fee_status  ,
                                  x_spl_consider_comments          => c_upd_appl_inst_rec.spl_consider_comments  ,
                                  x_apply_for_finaid               => c_upd_appl_inst_rec.apply_for_finaid ,
                                  x_finaid_apply_date              => c_upd_appl_inst_rec.finaid_apply_date ,
                                  x_adm_outcome_status             => c_upd_appl_inst_rec.adm_outcome_status  ,
                                  x_adm_otcm_stat_auth_per_id      => c_upd_appl_inst_rec.adm_otcm_status_auth_person_id ,
                                  x_adm_outcome_status_auth_dt     => c_upd_appl_inst_rec.adm_outcome_status_auth_dt ,
                                  x_adm_outcome_status_reason      => c_upd_appl_inst_rec.adm_outcome_status_reason  ,
                                  x_offer_dt                       => c_upd_appl_inst_rec.offer_dt ,
                                  x_offer_response_dt              => c_upd_appl_inst_rec.offer_response_dt ,
                                  x_prpsd_commencement_dt          => c_upd_appl_inst_rec.prpsd_commencement_dt,
                                  x_adm_cndtnl_offer_status        => c_upd_appl_inst_rec.adm_cndtnl_offer_status ,
                                  x_cndtnl_offer_satisfied_dt      => c_upd_appl_inst_rec.cndtnl_offer_satisfied_dt  ,
                                  x_cndnl_ofr_must_be_stsfd_ind    => c_upd_appl_inst_rec.cndtnl_offer_must_be_stsfd_ind  ,
                                  x_adm_offer_resp_status          => c_upd_appl_inst_rec.adm_offer_resp_status  ,
                                  x_actual_response_dt             => c_upd_appl_inst_rec.actual_response_dt,
                                  x_adm_offer_dfrmnt_status        => c_upd_appl_inst_rec.adm_offer_dfrmnt_status  ,
                                  x_deferred_adm_cal_type          => c_upd_appl_inst_rec.deferred_adm_cal_type  ,
                                  x_deferred_adm_ci_sequence_num   => c_upd_appl_inst_rec.deferred_adm_ci_sequence_num ,
                                  x_deferred_tracking_id           => c_upd_appl_inst_rec.deferred_tracking_id ,
                                  x_ass_rank                       => c_upd_appl_inst_rec.ass_rank  ,
                                  x_secondary_ass_rank             => c_upd_appl_inst_rec.secondary_ass_rank ,
                                  x_intr_accept_advice_num         => c_upd_appl_inst_rec.intrntnl_acceptance_advice_num ,
                                  x_ass_tracking_id                => c_upd_appl_inst_rec.ass_tracking_id ,
                                  x_fee_cat                        => c_upd_appl_inst_rec.fee_cat  ,
                                  x_hecs_payment_option            => c_upd_appl_inst_rec.hecs_payment_option ,
                                  x_expected_completion_yr         => c_upd_appl_inst_rec.expected_completion_yr ,
                                  x_expected_completion_perd       => c_upd_appl_inst_rec.expected_completion_perd,
                                  x_correspondence_cat             => c_upd_appl_inst_rec.correspondence_cat  ,
                                  x_enrolment_cat                  => c_upd_appl_inst_rec.enrolment_cat ,
                                  x_funding_source                 => c_upd_appl_inst_rec.funding_source ,
                                  x_applicant_acptnce_cndtn        => c_upd_appl_inst_rec.applicant_acptnce_cndtn  ,
                                  x_cndtnl_offer_cndtn             => c_upd_appl_inst_rec.cndtnl_offer_cndtn  ,
                                  x_mode                           => 'R' ,
                                  x_ss_application_id              => c_upd_appl_inst_rec.ss_application_id ,
                                  x_ss_pwd                         => c_upd_appl_inst_rec.ss_pwd ,
                                  x_authorized_dt                  => c_upd_appl_inst_rec.authorized_dt ,
                                  x_authorizing_pers_id            => c_upd_appl_inst_rec.authorizing_pers_id ,
                                  x_entry_status                   => c_upd_appl_inst_rec.entry_status ,
                                  x_entry_level                    => c_upd_appl_inst_rec.entry_level  ,
                                  x_sch_apl_to_id                  => c_upd_appl_inst_rec.sch_apl_to_id ,
                                  x_idx_calc_date                  => c_upd_appl_inst_rec.idx_calc_date ,
                                  x_waitlist_status                => c_upd_appl_inst_rec.waitlist_status ,
                                  x_attribute21                    => c_upd_appl_inst_rec.attribute21 ,
                                  x_attribute22                    => c_upd_appl_inst_rec.attribute22 ,
                                  x_attribute23                    => c_upd_appl_inst_rec.attribute23 ,
                                  x_attribute24                    => c_upd_appl_inst_rec.attribute24 ,
                                  x_attribute25                    => c_upd_appl_inst_rec.attribute25 ,
                                  x_attribute26                    => c_upd_appl_inst_rec.attribute26 ,
                                  x_attribute27                    => c_upd_appl_inst_rec.attribute27 ,
                                  x_attribute28                    => c_upd_appl_inst_rec.attribute28 ,
                                  x_attribute29                    => c_upd_appl_inst_rec.attribute29 ,
                                  x_attribute30                    => c_upd_appl_inst_rec.attribute30 ,
                                  x_attribute31                    => c_upd_appl_inst_rec.attribute31 ,
                                  x_attribute32                    => c_upd_appl_inst_rec.attribute32 ,
                                  x_attribute33                    => c_upd_appl_inst_rec.attribute33 ,
                                  x_attribute34                    => c_upd_appl_inst_rec.attribute34 ,
                                  x_attribute35                    => c_upd_appl_inst_rec.attribute35 ,
                                  x_attribute36                    => c_upd_appl_inst_rec.attribute36 ,
                                  x_attribute37                    => c_upd_appl_inst_rec.attribute37 ,
                                  x_attribute38                    => c_upd_appl_inst_rec.attribute38 ,
                                  x_attribute39                    => c_upd_appl_inst_rec.attribute39 ,
                                  x_attribute40                    => c_upd_appl_inst_rec.attribute40 ,
                                  x_fut_acad_cal_type              => c_upd_appl_inst_rec.future_acad_cal_type ,
                                  x_fut_acad_ci_sequence_number    => c_upd_appl_inst_rec.future_acad_ci_sequence_number ,
                                  x_fut_adm_cal_type               => c_upd_appl_inst_rec.future_adm_cal_type ,
                                  x_fut_adm_ci_sequence_number     => c_upd_appl_inst_rec.future_adm_ci_sequence_number  ,
                                  x_prev_term_adm_appl_number      => c_upd_appl_inst_rec.previous_term_adm_appl_number ,
                                  x_prev_term_sequence_number      => c_upd_appl_inst_rec.previous_term_sequence_number ,
                                  x_fut_term_adm_appl_number       => c_upd_appl_inst_rec.future_term_adm_appl_number ,
                                  x_fut_term_sequence_number       => c_upd_appl_inst_rec.future_term_sequence_number ,
                                  x_def_acad_cal_type              => c_upd_appl_inst_rec.def_acad_cal_type ,
                                  x_def_acad_ci_sequence_num       => c_upd_appl_inst_rec.def_acad_ci_sequence_num ,
                                  x_def_prev_term_adm_appl_num     => c_upd_appl_inst_rec.def_prev_term_adm_appl_num ,
                                  x_def_prev_appl_sequence_num     => c_upd_appl_inst_rec.def_prev_appl_sequence_num ,
                                  x_def_term_adm_appl_num          => c_upd_appl_inst_rec.def_term_adm_appl_num  ,
                                  x_def_appl_sequence_num          => c_upd_appl_inst_rec.def_appl_sequence_num,
                                  X_APPL_INST_STATUS               => c_upd_appl_inst_rec.appl_inst_status,
                                  x_ais_reason                     => c_upd_appl_inst_rec.ais_reason,
                                  x_decline_ofr_reason             => c_upd_appl_inst_rec.decline_ofr_reason
                                  ) ;

                        END LOOP ;
                    EXCEPTION
                          WHEN OTHERS THEN
                              ROLLBACK TO pref;
                              fnd_message.set_name('IGS','IGS_UC_OBS_APP_INC_PREF_ERR');
                              fnd_message.set_token('APP_NO', c_new_app_ch_rec.app_no);
                              fnd_message.set_token('CHOICE_NO', c_new_app_ch_rec.choice_no);
                              fnd_message.set_token('ADM_APPL', c_new_app_ch_rec.choice_no);
                              fnd_file.put_line(fnd_file.LOG,fnd_message.get());
                              fnd_file.put_line(fnd_file.LOG, SQLERRM);

                              l_export_to_oss_status := c_new_app_ch_rec.export_to_oss_status;
                              l_ch_error := 'O001' ;
                              l_ch_batch_id := NULL;
                              l_pref_excep := TRUE;
                    END ;  -- end of incrementing preference number

                    -- If incrementing preference numbers has failed then skip this choice
                    IF  NOT l_pref_excep THEN

                        -- capture outcome status, decision_maker_id,decision reason
                        -- smaddali added the cursor c_old_oustat and update_row calls for bug 2630219
                        -- If a record exists for this application choice then update it ,else create new record
                        c_old_oustat_rec := NULL ;
                        OPEN c_old_oustat(c_new_app_ch_rec.app_no , c_new_app_ch_rec.choice_no ) ;
                        FETCH c_old_oustat INTO c_old_oustat_rec ;
                        IF c_old_oustat%NOTFOUND THEN
                           --smaddali initialising l_rowid to null for bug 2626178
                           l_rowid := NULL ;
                           igs_uc_old_oustat_pkg.insert_row (
                              X_ROWID  => l_rowid
                             ,X_APP_NO =>   c_new_app_ch_rec.app_no
                             ,X_CHOICE_NO  =>  c_new_app_ch_rec.choice_no
                             ,X_OLD_OUTCOME_STATUS => c_obsol_appl_rec.adm_outcome_status
                             ,X_DECISION_DATE => c_obsol_appl_rec.decision_date
                             ,X_DECISION_REASON_ID => c_obsol_appl_rec.decision_reason_id
                             ,X_DECISION_MAKE_ID => c_obsol_appl_rec.decision_make_id
                             ,X_MODE  => 'R'
                             ) ;
                        ELSE
                            igs_uc_old_oustat_pkg.update_row (
                             X_ROWID  => c_old_oustat_rec.ROWID
                             ,X_APP_NO =>   c_old_oustat_rec.app_no
                             ,X_CHOICE_NO  =>  c_old_oustat_rec.choice_no
                             ,X_OLD_OUTCOME_STATUS => c_obsol_appl_rec.adm_outcome_status
                             ,X_DECISION_DATE => c_obsol_appl_rec.decision_date
                             ,X_DECISION_REASON_ID => c_obsol_appl_rec.decision_reason_id
                             ,X_DECISION_MAKE_ID => c_obsol_appl_rec.decision_make_id
                             ,X_MODE  => 'R'
                             ) ;
                        END IF ;
                        CLOSE c_old_oustat ;

                        -- populate decision import interface tables
                        -- 1. Get the Batch ID of the Admission Decision Import Batch table,IGS_AD_BATC_DEF_DET_ALL
                        l_dec_batch_id := NULL;
                        l_batch_id_loc :=NULL;
                        get_batchid_loc(p_system_code  => c_new_app_ch_rec.system_code,
                                        p_entry_year   => c_new_app_ch_rec.entry_year,
                                        p_entry_month  => c_new_app_ch_rec.entry_month,
                                        p_batch_id_loc => l_batch_id_loc);
                        IF l_batch_id_loc IS NOT NULL THEN
                          l_dec_batch_id := l_batch_id_det(l_batch_id_loc).batch_id;
                        END IF;

                       -- 2. Populate the Admission Decision Import Interface table,IGS_AD_ADMDE_INT_ALL
                        /* call the insert_row of the Admission Decision Import Interface table, IGS_AD_ADMDE_INT_ALL */

                        l_interface_run_id := NULL ;
                        l_interface_mkdes_id := NULL ;
                        l_error_message := NULL ;
                        l_return_status := NULL ;
                        OPEN c_interface_run_id ;
                        FETCH c_interface_run_id INTO l_interface_run_id ;
                        CLOSE c_interface_run_id ;
                        l_rowid := NULL ;

                        -- Create record in decision import interface tables for the applications which need to be voided
                        igs_ad_admde_int_pkg.insert_row (
                          x_rowid                    =>  l_rowid,
                          x_interface_mkdes_id       =>  l_interface_mkdes_id,
                          x_interface_run_id         =>  l_interface_run_id ,
                          x_batch_id                 =>  l_dec_batch_id,
                          x_person_id                =>  c_obsol_appl_rec.person_id,
                          x_admission_appl_number    =>  c_obsol_appl_rec.admission_appl_number,
                          x_nominated_course_cd      =>  c_obsol_appl_rec.nominated_course_cd,
                          x_sequence_number          =>  c_obsol_appl_rec.sequence_number,
                          x_adm_outcome_status       =>  c_defaults_rec.obsolete_outcome_status,
                          x_decision_make_id         =>  c_defaults_rec.decision_make_id,
                          x_decision_date            =>  TRUNC(SYSDATE),
                          x_decision_reason_id       =>  c_defaults_rec.decision_reason_id,
                          x_pending_reason_id        =>  NULL,
                          x_offer_dt                 =>  NULL,
                          x_offer_response_dt        =>  NULL,
                          x_status                   =>  '2', -- pending status
                          x_error_code               =>  NULL,
                          x_mode                     =>  'R',
                          x_reconsider_flag          =>  'N' );

                        -- 3. call the decision import process to obsolete old applications
                        igs_ad_imp_adm_des.prc_adm_outcome_status(
                          p_person_id                => c_obsol_appl_rec.person_id ,
                          p_admission_appl_number    => c_obsol_appl_rec.admission_appl_number ,
                          p_nominated_course_cd      => c_obsol_appl_rec.nominated_course_cd ,
                          p_sequence_number          => c_obsol_appl_rec.sequence_number,
                          p_adm_outcome_status       => c_defaults_rec.obsolete_outcome_status,
                          p_s_adm_outcome_status     => l_s_obsol_ou_stat ,
                          p_acad_cal_type            => c_obsol_appl_rec.acad_cal_type ,
                          p_acad_ci_sequence_number  => c_obsol_appl_rec.acad_ci_sequence_number,
                          p_adm_cal_type             => c_obsol_appl_rec.adm_cal_type ,
                          p_adm_ci_sequence_number   => c_obsol_appl_rec.adm_ci_sequence_number ,
                          p_admission_cat            => c_obsol_appl_rec.admission_cat ,
                          p_s_admission_process_type => c_obsol_appl_rec.s_admission_process_type ,
                          p_batch_id                 => l_dec_batch_id,
                          p_interface_run_id         => l_interface_run_id ,
                          p_interface_mkdes_id       => l_interface_mkdes_id,
                          p_error_message            => l_error_message,  --Bug 3297241 replaced error_code with error_message
                          p_return_status            => l_return_status ,
                          p_ucas_transaction         => 'N',
                          p_reconsideration          => 'N' );

                        -- if the decision import completed in error then set appropriate error code in app choice record
                        IF   l_error_message IS NOT NULL OR l_return_status = 'FALSE'   THEN
                           /* raise the error with code 'O002' */
                              fnd_message.set_name('IGS','IGS_UC_OBS_APP_DEC_IMP_ERR');
                              fnd_message.set_token('APP_NO', c_new_app_ch_rec.app_no);
                              fnd_message.set_token('CHOICE_NO', c_new_app_ch_rec.choice_no);
                              fnd_message.set_token('BATCH_ID', l_dec_batch_id);
                              fnd_file.put_line(fnd_file.LOG,fnd_message.get());
                              l_ch_error := 'O002' ;
                              l_ch_batch_id := l_dec_batch_id ;
                              l_export_to_oss_status := 'OO' ;
                        ELSE
                            -- decision import for obsoletion is successful
                            l_ch_error := NULL ;
                            l_ch_batch_id := NULL ;
                            l_export_to_oss_status := 'OC' ;

                            -- Log a message that the application choice has been successfully obsoleted
                            fnd_message.set_name('IGS','IGS_UC_OBS_APP_DEC_IMP_SUC');
                            fnd_message.set_token('APP_NO', c_new_app_ch_rec.app_no);
                            fnd_message.set_token('CHOICE_NO', c_new_app_ch_rec.choice_no);
                            fnd_file.put_line(fnd_file.LOG,fnd_message.get());
                        END IF ; -- decision import failed or passed

                    END IF ; -- preference increment raised exception

                  END IF ; -- If more than one application instance active

           END IF ; -- if no new application or instance is created

         END IF; -- If the Application Choice has a Completed OSS Admission Application Instance.
         CLOSE cur_comp_app_choice;

         -- 4. Update the Application Choice Record with export_to_oss_status=OP/OO/OC and Concurrent Request ID
         c_upd_ch_rec  := NULL ;
         OPEN c_upd_ch( c_new_app_ch_rec.app_no , c_new_app_ch_rec.choice_no, c_new_app_ch_rec.ucas_cycle);
         FETCH c_upd_ch INTO c_upd_ch_rec ;
         CLOSE c_upd_ch ;
         igs_uc_app_choices_pkg.update_row
                 ( x_rowid                      => c_upd_ch_rec.rowid
                  ,x_app_choice_id              => c_upd_ch_rec.app_choice_id
                  ,x_app_id                     => c_upd_ch_rec.app_id
                  ,x_app_no                     => c_upd_ch_rec.app_no
                  ,x_choice_no                  => c_upd_ch_rec.choice_no
                  ,x_last_change                => c_upd_ch_rec.last_change
                  ,x_institute_code             => c_upd_ch_rec.institute_code
                  ,x_ucas_program_code          => c_upd_ch_rec.ucas_program_code
                  ,x_oss_program_code           => c_upd_ch_rec.oss_program_code
                  ,x_oss_program_version        => c_upd_ch_rec.oss_program_version
                  ,x_oss_attendance_type        => c_upd_ch_rec.oss_attendance_type
                  ,x_oss_attendance_mode        => c_upd_ch_rec.oss_attendance_mode
                  ,x_campus                     => c_upd_ch_rec.campus
                  ,x_oss_location               => c_upd_ch_rec.oss_location
                  ,x_faculty                    => c_upd_ch_rec.faculty
                  ,x_entry_year                 => c_upd_ch_rec.entry_year
                  ,x_entry_month                => c_upd_ch_rec.entry_month
                  ,x_point_of_entry             => c_upd_ch_rec.point_of_entry
                  ,x_home                       => c_upd_ch_rec.home
                  ,x_deferred                   => c_upd_ch_rec.deferred
                  ,x_route_b_pref_round         => c_upd_ch_rec.route_b_pref_round
                  ,x_route_b_actual_round       => c_upd_ch_rec.route_b_actual_round
                  ,x_condition_category         => c_upd_ch_rec.condition_category
                  ,x_condition_code             => c_upd_ch_rec.condition_code
                  ,x_decision                   => c_upd_ch_rec.decision
                  ,x_decision_date              => c_upd_ch_rec.decision_date
                  ,x_decision_number            => c_upd_ch_rec.decision_number
                  ,x_reply                      => c_upd_ch_rec.reply
                  ,x_summary_of_cond            => c_upd_ch_rec.summary_of_cond
                  ,x_choice_cancelled           => c_upd_ch_rec.choice_cancelled
                  ,x_action                     => c_upd_ch_rec.action
                  ,x_substitution               => c_upd_ch_rec.substitution
                  ,x_date_substituted           => c_upd_ch_rec.date_substituted
                  ,x_prev_institution           => c_upd_ch_rec.prev_institution
                  ,x_prev_course                => c_upd_ch_rec.prev_course
                  ,x_prev_campus                => c_upd_ch_rec.prev_campus
                  ,x_ucas_amendment             => c_upd_ch_rec.ucas_amendment
                  ,x_withdrawal_reason          => c_upd_ch_rec.withdrawal_reason
                  ,x_offer_course               => c_upd_ch_rec.offer_course
                  ,x_offer_campus               => c_upd_ch_rec.offer_campus
                  ,x_offer_crse_length          => c_upd_ch_rec.offer_crse_length
                  ,x_offer_entry_month          => c_upd_ch_rec.offer_entry_month
                  ,x_offer_entry_year           => c_upd_ch_rec.offer_entry_year
                  ,x_offer_entry_point          => c_upd_ch_rec.offer_entry_point
                  ,x_offer_text                 => c_upd_ch_rec.offer_text
                  ,x_export_to_oss_status       => l_export_to_oss_status
                  ,x_error_code                 => l_ch_error
                  ,x_request_id                 => l_conc_request_id
                  ,x_batch_id                   => l_ch_batch_id
                  ,x_mode                       => 'R'
                  ,x_extra_round_nbr            => c_upd_ch_rec.extra_round_nbr
                  ,x_system_code                => c_upd_ch_rec.system_code
                  ,x_part_time                  => c_upd_ch_rec.part_time
                  ,x_interview                  => c_upd_ch_rec.interview
                  ,x_late_application           => c_upd_ch_rec.late_application
                  ,x_modular                    => c_upd_ch_rec.modular
                  ,x_residential                => c_upd_ch_rec.residential
                  ,x_ucas_cycle                 => c_upd_ch_rec.ucas_cycle);

         COMMIT ;
       END LOOP ;  -- loop thru new choices

       -- for any other choice records in status OO due to previous runs
       -- then change their status if they are successfully imported
       FOR c_oo_ch_rec IN c_oo_ch LOOP

         -- smaddali added the code to get the system code and the proper batchid for that system , as part
         -- of UCFD102 build , bug 2643048
         -- Get the default UCAS setup values and keep them in package variable c_defaults_rec
         c_defaults_rec := NULL ;
         OPEN c_defaults(c_oo_ch_rec.system_code) ;
         FETCH c_defaults INTO c_defaults_rec;
         CLOSE c_defaults ;

         -- Get the Batch ID created for the calendar setup for this Application choice corresponding to the UCAS system, Entry Year and Entry Month
         --  available in Admission Decision Import Batch table,IGS_AD_BATC_DEF_DET_ALL
         l_dec_batch_id := NULL ;
         l_batch_id_loc :=NULL;
         get_batchid_loc(p_system_code  => c_oo_ch_rec.system_code,
                         p_entry_year   => c_oo_ch_rec.entry_year,
                         p_entry_month  => c_oo_ch_rec.entry_month,
                         p_batch_id_loc => l_batch_id_loc);
         IF l_batch_id_loc IS NOT NULL THEN
           l_dec_batch_id := l_batch_id_det(l_batch_id_loc).batch_id;
         ELSE
           --If batch ID is not availabe then assign it as zero.  So that the application choice
           -- will be identified as errored in previous run and necessary checks will be performed
           -- to move the application choice status to OC.
           l_dec_batch_id := 0;
         END IF;

          -- If this application choice errored out during a previous run
          -- then check if old application obsoletion has been successfull or not and
          -- update the choice status accordingly
          IF c_oo_ch_rec.batch_id <> l_dec_batch_id THEN
            c_obsol_appl_rec := NULL;
            OPEN c_obsol_appl(c_oo_ch_rec.app_no,
                              c_oo_ch_rec.choice_no );
            FETCH c_obsol_appl INTO c_obsol_appl_rec ;
            CLOSE c_obsol_appl ;

            -- Find the decision interface record corresponding to the application choice
            c_dec_int_rec := NULL ;
            OPEN c_dec_int(c_oo_ch_rec.batch_id,c_obsol_appl_rec.person_id,
                           c_obsol_appl_rec.admission_appl_number,
                           c_obsol_appl_rec.nominated_course_cd,
                           c_obsol_appl_rec.sequence_number);
            FETCH c_dec_int INTO c_dec_int_rec ;
            CLOSE c_dec_int ;
            -- if the decision import completed in error then set appropriate error code in app choice record
            IF  c_dec_int_rec.error_code IS NOT NULL OR c_dec_int_rec.status IN ('2','3') THEN
                fnd_message.set_name('IGS','IGS_UC_OBS_APP_DEC_IMP_ERR');
                fnd_message.set_token('APP_NO', c_oo_ch_rec.app_no);
                fnd_message.set_token('CHOICE_NO', c_oo_ch_rec.choice_no);
                fnd_message.set_token('BATCH_ID', c_oo_ch_rec.batch_id );
                fnd_file.put_line(fnd_file.LOG,fnd_message.get());
            ELSE
                l_ch_error := NULL ;
                l_ch_batch_id := NULL ;
                l_export_to_oss_status := 'OC' ;

                -- Log a message that the application choice has been successfully obsoleted
                fnd_message.set_name('IGS','IGS_UC_OBS_APP_DEC_IMP_SUC');
                fnd_message.set_token('APP_NO', c_oo_ch_rec.app_no);
                fnd_message.set_token('CHOICE_NO', c_oo_ch_rec.choice_no);
                fnd_file.put_line(fnd_file.LOG,fnd_message.get());

                -- 1. Update the Application Choice Record with export_to_oss_status=OP/OO/OC and Concurrent Request ID
                c_upd_ch_rec  := NULL ;
                OPEN c_upd_ch( c_oo_ch_rec.app_no , c_oo_ch_rec.choice_no, c_oo_ch_rec.ucas_cycle) ;
                FETCH c_upd_ch INTO c_upd_ch_rec ;
                CLOSE c_upd_ch ;
                igs_uc_app_choices_pkg.update_row
                 ( x_rowid                      => c_upd_ch_rec.ROWID
                  ,x_app_choice_id              => c_upd_ch_rec.app_choice_id
                  ,x_app_id                     => c_upd_ch_rec.app_id
                  ,x_app_no                     => c_upd_ch_rec.app_no
                  ,x_choice_no                  => c_upd_ch_rec.choice_no
                  ,x_last_change                => c_upd_ch_rec.last_change
                  ,x_institute_code             => c_upd_ch_rec.institute_code
                  ,x_ucas_program_code          => c_upd_ch_rec.ucas_program_code
                  ,x_oss_program_code           => c_upd_ch_rec.oss_program_code
                  ,x_oss_program_version        => c_upd_ch_rec.oss_program_version
                  ,x_oss_attendance_type        => c_upd_ch_rec.oss_attendance_type
                  ,x_oss_attendance_mode        => c_upd_ch_rec.oss_attendance_mode
                  ,x_campus                     => c_upd_ch_rec.campus
                  ,x_oss_location               => c_upd_ch_rec.oss_location
                  ,x_faculty                    => c_upd_ch_rec.faculty
                  ,x_entry_year                 => c_upd_ch_rec.entry_year
                  ,x_entry_month                => c_upd_ch_rec.entry_month
                  ,x_point_of_entry             => c_upd_ch_rec.point_of_entry
                  ,x_home                       => c_upd_ch_rec.home
                  ,x_deferred                   => c_upd_ch_rec.deferred
                  ,x_route_b_pref_round         => c_upd_ch_rec.route_b_pref_round
                  ,x_route_b_actual_round       => c_upd_ch_rec.route_b_actual_round
                  ,x_condition_category         => c_upd_ch_rec.condition_category
                  ,x_condition_code             => c_upd_ch_rec.condition_code
                  ,x_decision                   => c_upd_ch_rec.decision
                  ,x_decision_date              => c_upd_ch_rec.decision_date
                  ,x_decision_number            => c_upd_ch_rec.decision_number
                  ,x_reply                      => c_upd_ch_rec.reply
                  ,x_summary_of_cond            => c_upd_ch_rec.summary_of_cond
                  ,x_choice_cancelled           => c_upd_ch_rec.choice_cancelled
                  ,x_action                     => c_upd_ch_rec.action
                  ,x_substitution               => c_upd_ch_rec.substitution
                  ,x_date_substituted           => c_upd_ch_rec.date_substituted
                  ,x_prev_institution           => c_upd_ch_rec.prev_institution
                  ,x_prev_course                => c_upd_ch_rec.prev_course
                  ,x_prev_campus                => c_upd_ch_rec.prev_campus
                  ,x_ucas_amendment             => c_upd_ch_rec.ucas_amendment
                  ,x_withdrawal_reason          => c_upd_ch_rec.withdrawal_reason
                  ,x_offer_course               => c_upd_ch_rec.offer_course
                  ,x_offer_campus               => c_upd_ch_rec.offer_campus
                  ,x_offer_crse_length          => c_upd_ch_rec.offer_crse_length
                  ,x_offer_entry_month          => c_upd_ch_rec.offer_entry_month
                  ,x_offer_entry_year           => c_upd_ch_rec.offer_entry_year
                  ,x_offer_entry_point          => c_upd_ch_rec.offer_entry_point
                  ,x_offer_text                 => c_upd_ch_rec.offer_text
                  ,x_export_to_oss_status       => l_export_to_oss_status
                  ,x_error_code                 => l_ch_error
                  ,x_request_id                 => l_conc_request_id
                  ,x_batch_id                   => l_ch_batch_id
                  ,x_mode                       => 'R'
                  ,x_extra_round_nbr            => c_upd_ch_rec.extra_round_nbr
                  ,x_system_code                => c_upd_ch_rec.system_code
                  ,x_part_time                  => c_upd_ch_rec.part_time
                  ,x_interview                  => c_upd_ch_rec.interview
                  ,x_late_application           => c_upd_ch_rec.late_application
                  ,x_modular                    => c_upd_ch_rec.modular
                  ,x_residential                => c_upd_ch_rec.residential
                  ,x_ucas_cycle                 => c_upd_ch_rec.ucas_cycle);
             END IF ;   -- If decision import errored out

          END IF ;       -- if this choice is a rerun

       END LOOP ; -- check for choices of previous runs in status oc


   EXCEPTION

    WHEN OTHERS THEN
      Rollback;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UCAS_EXPORT_TO_OSS.OBSOLETE_APPLICATIONS'||' - '||SQLERRM);
      fnd_file.put_line(fnd_file.LOG,fnd_message.get());
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
 END obsolete_applications ;



 PROCEDURE export_applications(
    p_app_no igs_uc_applicants.app_no%TYPE ,
    p_choice_no igs_uc_app_choices.choice_no%TYPE
  ) IS
    /******************************************************************
     Created By      :   smaddali
     Date Created By :   12-SEP-2002
     Purpose         :   To create new application/instance or update old applications for choices in status OC
     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
     smaddali bug 2643048 UCFD102 build , modified cursors to add check for system_code
     rbezawad  25-Feb-03   Modified w.r.t. Bug 2777247.  Added code to insert record into IGS_AD_IMP_BATCH_DET table.
     dsridhar  02-JUN-03   Modified the cursor 'c_oc_app_ch' in the procedure 'export_applications' to tune the
                           performance.Bug No: 2913922
     dsridhar  27-OCT-03   Bug No: 2898153. Removed the space from the message name IGS_UC_EXPORT_APP_ERR.
     jchakrab  20-feb-06   Modified for 3691186 - changed c_oc_app_ch to a ref cursor to execute different queries based on parameter values
    ***************************************************************** */

     --jchakrab added for 3691186
     TYPE t_oc_app_ch IS REF CURSOR;
     c_oc_app_ch t_oc_app_ch;

     l_app_no IGS_UC_APPLICANTS.APP_NO%TYPE;

     l_imp_batch_id NUMBER;
     l_export_to_oss_status igs_uc_app_choices.export_to_oss_status%TYPE ;
     l_ch_error igs_uc_app_choices.error_code%TYPE ;
     l_ch_batch_id igs_uc_app_choices.batch_id%TYPE ;
     l_conc_process BOOLEAN ;
     l_phase VARCHAR2(10) ;
     l_status VARCHAR2(10) ;
     l_dev_phase VARCHAR2(10) ;
     l_dev_status VARCHAR2(10) ;
     l_message VARCHAR2(100) ;


    -- Get all the application choices with status AP
    -- smaddali modified this cursor to add the validation for system_code , UCFD102 build bug 2643048
    CURSOR c_ap_ch IS
      SELECT ch.app_no , ch.choice_no , ch.batch_id, ch.ucas_cycle
      FROM  igs_uc_app_choices ch
      WHERE ch.app_no = NVL(p_app_no,ch.app_no) AND
            ch.export_to_oss_status = 'AP' AND
            ch.choice_no = NVL(p_choice_no , ch.choice_no) AND
            ch.institute_code = (SELECT df.current_inst_code FROM igs_uc_defaults df
                                 WHERE df.system_code = ch.system_code)
      ORDER BY ch.app_no , ch.choice_no ;
    c_ap_ch_rec c_ap_ch%ROWTYPE ;

    -- Get the Batch ID for admission application import process
    CURSOR c_bat_id IS
      SELECT igs_ad_interface_batch_id_s.NEXTVAL
      FROM dual;

    -- Get the Source type ID of UCAS for admission import process
    CURSOR c_src_type_id IS
      SELECT source_type_id
      FROM igs_pe_src_types_all
      WHERE source_type LIKE 'UCAS APPL';
     c_src_type_id_rec c_src_type_id%ROWTYPE;

     -- Get the admission application instance interface record corresponding to the
     -- passed ucas application choice record whose import has failed
     -- smaddali modified this cursor to add b.alt_appl_id = a.app_no condition as part of ucfd102 build, bug 2643048
     CURSOR c_appl_int( cp_batch_id igs_uc_app_choices.batch_id%TYPE,
                        cp_app_no igs_uc_app_choices.app_no%TYPE ,
                        cp_choice_no igs_uc_app_choices.choice_no%TYPE ) IS
     SELECT  a.interface_id  -- if application details import fails
     FROM igs_ad_interface a, igs_ad_apl_int b , igs_ad_ps_appl_inst_int c ,
        igs_uc_app_choices ch , igs_uc_applicants ap
     WHERE a.batch_id = cp_batch_id AND
           a.interface_id = b.interface_id AND
           b.choice_number = ch.choice_no  AND
           b.interface_appl_id = c.interface_appl_id AND
           ( c.status IN ( '2','3') OR b.status IN ('2','3') ) AND
           ap.app_no = ch.app_no AND
           ap.oss_person_id = a.person_id AND
           TO_CHAR(ap.app_no) = b.alt_appl_id AND
           ch.app_no = cp_app_no AND
           ch.choice_no = cp_choice_no
     UNION  -- if person or person details import fail
     SELECT  a.interface_id
     FROM igs_ad_interface a, igs_ad_apl_int b , igs_ad_ps_appl_inst_int c ,
        igs_uc_app_choices ch , igs_uc_applicants ap
     WHERE a.batch_id = cp_batch_id AND
           a.interface_id = b.interface_id AND
           b.choice_number = ch.choice_no  AND
           b.interface_appl_id = c.interface_appl_id AND
           b.status = '2'  AND
           c.status='2' AND
           ( a.record_status = '3' OR a.status IN ('2', '3' ) )  AND
           ap.app_no = ch.app_no AND
           ap.oss_person_id = a.person_id AND
           TO_CHAR(ap.app_no) = b.alt_appl_id AND
           ch.app_no = cp_app_no AND
           ch.choice_no = cp_choice_no ;
      c_appl_int_rec c_appl_int%ROWTYPE ;

    /* Cursors used to import domicile code */
    CURSOR cur_app_dtls(cp_app_no   igs_uc_applicants.app_no%TYPE) IS
    SELECT a.oss_person_id, a.domicile_apr, b.party_number
    FROM   igs_uc_applicants a, hz_parties b
    WHERE  a.oss_person_id = b.party_id
    AND    app_no = cp_app_no;
    l_app_dtls  cur_app_dtls%ROWTYPE;

    CURSOR cur_ad_appl_inst (p_per_id igs_pe_person.person_id%TYPE) IS
    SELECT admission_appl_number,
           nominated_course_cd,
           sequence_number
    FROM   igs_ad_ps_appl_inst_all
    WHERE  person_id = p_per_id;

    CURSOR cur_he_ad_dtl_all(p_per_id igs_pe_person.person_id%TYPE) IS
    SELECT COUNT(*)
    FROM   igs_he_ad_dtl_all
    WHERE person_id = p_per_id;

    CURSOR get_had_details (l_per_id igs_pe_person.person_id%TYPE) IS
    SELECT had.ROWID ,had.*
    FROM igs_he_ad_dtl_all had
    WHERE  person_id = l_per_id;

    -- UCAS Association mapping
    CURSOR cur_ucas_oss_map (cp_assoc IGS_HE_CODE_MAP_VAL.association_code%TYPE,
                           cp_map1 IGS_HE_CODE_MAP_VAL.map2%TYPE ) IS
    SELECT map2
    FROM IGS_HE_CODE_MAP_VAL
    WHERE association_code = cp_assoc
    AND   map1  = cp_map1;

    l_dom_cd    igs_he_ad_dtl_all.domicile_cd%TYPE;
    l_count     NUMBER;
    l_rowid     VARCHAR2(250);

  BEGIN
       l_imp_batch_id := NULL ;

       -- Get the distinct applicants who have choices in status OC
       -- smaddali modified this cursor to add the validation for system_code , UCFD102 build bug 2643048
       -- jchakrab changed c_oc_app_ch to a ref cursor to execute different queries based on parameter values (3691186)
       IF p_app_no IS NOT NULL AND p_choice_no IS NOT NULL THEN
         OPEN c_oc_app_ch FOR
         SELECT DISTINCT AP.APP_NO
             FROM  IGS_UC_APP_CHOICES CH , IGS_UC_APPLICANTS AP, IGS_UC_DEFAULTS DF
             WHERE AP.APP_NO = CH.APP_NO AND
                   CH.APP_NO = P_APP_NO AND
                   DF.SYSTEM_CODE = CH.SYSTEM_CODE AND
                   CH.EXPORT_TO_OSS_STATUS = 'OC' AND
                   CH.CHOICE_NO = P_CHOICE_NO AND
                   CH.INSTITUTE_CODE = DF.CURRENT_INST_CODE
             ORDER BY AP.APP_NO;

       ELSIF p_app_no IS NOT NULL AND p_choice_no IS NULL THEN
         OPEN c_oc_app_ch FOR
         SELECT DISTINCT AP.APP_NO
             FROM  IGS_UC_APP_CHOICES CH , IGS_UC_APPLICANTS AP, IGS_UC_DEFAULTS DF
             WHERE AP.APP_NO = CH.APP_NO AND
                   CH.APP_NO = P_APP_NO AND
                   DF.SYSTEM_CODE = CH.SYSTEM_CODE AND
                   CH.EXPORT_TO_OSS_STATUS = 'OC' AND
                   CH.INSTITUTE_CODE = DF.CURRENT_INST_CODE
             ORDER BY AP.APP_NO;

       ELSE
         OPEN c_oc_app_ch FOR
         SELECT DISTINCT AP.APP_NO
             FROM  IGS_UC_APP_CHOICES CH , IGS_UC_APPLICANTS AP, IGS_UC_DEFAULTS DF
             WHERE AP.APP_NO = CH.APP_NO AND
                   DF.SYSTEM_CODE = CH.SYSTEM_CODE AND
                   CH.EXPORT_TO_OSS_STATUS = 'OC' AND
                   CH.INSTITUTE_CODE = DF.CURRENT_INST_CODE
             ORDER BY AP.APP_NO;

       END IF;

       LOOP
           FETCH c_oc_app_ch INTO l_app_no;
           EXIT WHEN c_oc_app_ch%NOTFOUND;

           -- check if there are any application choice records in status OC which need to be imported
           -- if so ,get the batch_id and source_type_id

           --only need to populate batch id once for all applicants
           IF l_imp_batch_id IS NULL THEN

               -- Get the batch ID for running the application import process
               OPEN c_bat_id;
               FETCH c_bat_id
               INTO l_imp_batch_id;
               CLOSE c_bat_id;

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
                                      VALUES ( l_imp_batch_id,
                                               fnd_message.get_string('IGS','IGS_UC_EXP_TO_OSS_BATCH_ID'),
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

               -- Get the ucas cource type id for import process
               c_src_type_id_rec := NULL ;
               OPEN c_src_type_id;
               FETCH c_src_type_id
               INTO c_src_type_id_rec;
               CLOSE c_src_type_id;
           END IF ;

           -- populate application import interface  tables to create new application / instance
           -- or update the existing application instance corresponding to all the choice records
           -- belonging to the current application
           populate_imp_int(l_app_no,p_choice_no, c_src_type_id_rec.source_type_id, l_imp_batch_id, l_org_id);

       END LOOP ;
       CLOSE c_oc_app_ch ;


       -- run the application import process to create / update admission applications
       -- corresponding to the ucas application choice records with status AP
       OPEN c_ap_ch ;
       FETCH c_ap_ch INTO c_ap_ch_rec ;
       IF c_ap_ch%FOUND  AND l_imp_batch_id IS NOT NULL THEN

         -- call the application import process to create new application /instance
         -- or update the old application instance
         fnd_file.put_line( fnd_file.LOG ,' ');
         fnd_message.set_name('IGS','IGS_UC_ADM_IMP_PROC_LAUNCH');
         fnd_message.set_token('REQ_ID',TO_CHAR(l_imp_batch_id));
         fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
         fnd_file.put_line( fnd_file.LOG ,'-----------------------------------');

         COMMIT ;
         import_process(c_src_type_id_rec.source_type_id, l_imp_batch_id, l_org_id);

       END IF ;
       CLOSE c_ap_ch ;

       -- Insert space in log file
       fnd_file.put_line( fnd_file.LOG ,' ');

       -- check if the application import has been successful for all application choices with status AP
       FOR  c_ap_ch_rec IN c_ap_ch LOOP

         -- corresponding to the current application choice record ,If an admission application interface table
         -- record exists  then this means that the import process failed for this application.
         -- Hence update application choice accordingly with error code, batch_id export_to_oss_status and request Id
         OPEN c_appl_int(NVL(c_ap_ch_rec.batch_id,l_imp_batch_id ),
                            c_ap_ch_rec.app_no, c_ap_ch_rec.choice_no);
         FETCH c_appl_int INTO c_appl_int_rec ;
         IF c_appl_int%FOUND  THEN
           -- Import of this application has completed in error
           fnd_file.put_line( fnd_file.LOG ,' ');
           -- Bug No: 2898153. Removed the space from the message name IGS_UC_EXPORT_APP_ERR.
           fnd_message.set_name('IGS','IGS_UC_EXPORT_APP_ERR');
           fnd_message.set_token('APP_NO',c_ap_ch_rec.app_no) ;
           fnd_message.set_token('CHOICE_NO',c_ap_ch_rec.choice_no) ;
           fnd_file.put_line( fnd_file.LOG ,fnd_message.get);

           l_ch_error := 'A001' ;
           l_ch_batch_id := NVL(c_ap_ch_rec.batch_id,l_imp_batch_id )  ;
           l_export_to_oss_status := 'AP';
         ELSE
           -- choice successfully imported to oss
           l_ch_error := NULL ;
           l_ch_batch_id := NULL ;
           l_export_to_oss_status := 'AC';
         END IF ;
         CLOSE c_appl_int ;

         -----------------------------------------------------------------------------------------------------------------
         /****                          Import domicile code into igs_he_ad_dtl_all table                          ******/
         -----------------------------------------------------------------------------------------------------------------
         --If sent to oss succesfull we can create igs_he_ad_dtl record to import domicile code
         IF l_export_to_oss_status = 'AC' THEN

            /* fetch the DOMICILE CODE for the applicant */
            l_dom_cd := NULL ;

            OPEN cur_app_dtls(c_ap_ch_rec.app_no);
            FETCH cur_app_dtls INTO l_app_dtls;
            CLOSE cur_app_dtls;

            IF l_app_dtls.domicile_apr IS NOT NULL THEN

                OPEN cur_ucas_oss_map('UC_OSS_HE_DOM_ASSOC',l_app_dtls.domicile_apr);
                FETCH cur_ucas_oss_map INTO l_dom_cd;
                CLOSE cur_ucas_oss_map;

                IF l_dom_cd IS NOT NULL THEN

                    l_count :=0 ;
                    OPEN cur_he_ad_dtl_all(l_app_dtls.oss_person_id) ;
                    FETCH cur_he_ad_dtl_all INTO l_count;
                    CLOSE cur_he_ad_dtl_all ;

                    IF l_count = 0 THEN

                        FOR lv_ad_appl_inst IN cur_ad_appl_inst(l_app_dtls.oss_person_id) LOOP

                            l_rowid := NULL ;
                            igs_he_ad_dtl_all_pkg.insert_row(
                                 x_rowid                 => l_rowid,
                                 x_org_id                => NULL,
                                 x_hesa_ad_dtl_id        => l_count,
                                 x_person_id             =>  l_app_dtls.oss_person_id,
                                 x_admission_appl_number => lv_ad_appl_inst.admission_appl_number,
                                 x_nominated_course_cd   => lv_ad_appl_inst.nominated_course_cd,
                                 x_sequence_number       => lv_ad_appl_inst.sequence_number,
                                 x_occupation_cd         => NULL,
                                 x_domicile_cd           => l_dom_cd,
                                 x_social_class_cd       => NULL,
                                 x_special_student_cd    => NULL,
                                 x_mode                  => 'R'  );

                        END LOOP ;

                    ELSE

                        FOR had_rec IN get_had_details(l_app_dtls.oss_person_id) LOOP
                            igs_he_ad_dtl_all_pkg.update_row (
                            x_mode                       => 'R',
                            x_rowid                      => had_rec.ROWID,
                            x_org_id                     => had_rec.org_id,
                            x_hesa_ad_dtl_id             => had_rec.hesa_ad_dtl_id,
                            x_person_id                  => had_rec.person_id,
                            x_admission_appl_number      => had_rec.admission_appl_number,
                            x_nominated_course_cd        => had_rec.nominated_course_cd,
                            x_sequence_number            => had_rec.sequence_number,
                            x_occupation_cd              => had_rec.occupation_cd,
                            x_domicile_cd                => NVL(l_dom_cd,had_rec.domicile_cd),
                            x_social_class_cd            => had_rec.social_class_cd,
                            x_special_student_cd         => had_rec.special_student_cd );

                        END LOOP ;

                    END IF ; -- l_count = 0

                ELSE
                    -- Was unable to map domicile code so log warning
                    FND_MESSAGE.Set_Name('IGS','IGS_UC_NO_DOM_MAPPING');
                    FND_MESSAGE.Set_Token('PERSON_ID',l_app_dtls.party_number);
                    FND_MESSAGE.Set_Token('CODE',l_app_dtls.domicile_apr);
                    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.get );

                END IF; -- l_dom_cd IS NOT NULL

            END IF;  -- cur_proc_applicant_rec.domicile_apr IS NOT NULL

         END IF; -- l_export_to_oss_status = 'AC'

         -- 1. Update the Application Choice Record with export_to_oss_status=OP/OO/OC ,batch id and Concurrent Request ID
         c_upd_ch_rec  := NULL ;
         OPEN c_upd_ch( c_ap_ch_rec.app_no , c_ap_ch_rec.choice_no, c_ap_ch_rec.ucas_cycle) ;
         FETCH c_upd_ch INTO c_upd_ch_rec ;
         CLOSE c_upd_ch ;
         igs_uc_app_choices_pkg.update_row
                 ( x_rowid                      => c_upd_ch_rec.ROWID
                  ,x_app_choice_id              => c_upd_ch_rec.app_choice_id
                  ,x_app_id                     => c_upd_ch_rec.app_id
                  ,x_app_no                     => c_upd_ch_rec.app_no
                  ,x_choice_no                  => c_upd_ch_rec.choice_no
                  ,x_last_change                => c_upd_ch_rec.last_change
                  ,x_institute_code             => c_upd_ch_rec.institute_code
                  ,x_ucas_program_code          => c_upd_ch_rec.ucas_program_code
                  ,x_oss_program_code           => c_upd_ch_rec.oss_program_code
                  ,x_oss_program_version        => c_upd_ch_rec.oss_program_version
                  ,x_oss_attendance_type        => c_upd_ch_rec.oss_attendance_type
                  ,x_oss_attendance_mode        => c_upd_ch_rec.oss_attendance_mode
                  ,x_campus                     => c_upd_ch_rec.campus
                  ,x_oss_location               => c_upd_ch_rec.oss_location
                  ,x_faculty                    => c_upd_ch_rec.faculty
                  ,x_entry_year                 => c_upd_ch_rec.entry_year
                  ,x_entry_month                => c_upd_ch_rec.entry_month
                  ,x_point_of_entry             => c_upd_ch_rec.point_of_entry
                  ,x_home                       => c_upd_ch_rec.home
                  ,x_deferred                   => c_upd_ch_rec.deferred
                  ,x_route_b_pref_round         => c_upd_ch_rec.route_b_pref_round
                  ,x_route_b_actual_round       => c_upd_ch_rec.route_b_actual_round
                  ,x_condition_category         => c_upd_ch_rec.condition_category
                  ,x_condition_code             => c_upd_ch_rec.condition_code
                  ,x_decision                   => c_upd_ch_rec.decision
                  ,x_decision_date              => c_upd_ch_rec.decision_date
                  ,x_decision_number            => c_upd_ch_rec.decision_number
                  ,x_reply                      => c_upd_ch_rec.reply
                  ,x_summary_of_cond            => c_upd_ch_rec.summary_of_cond
                  ,x_choice_cancelled           => c_upd_ch_rec.choice_cancelled
                  ,x_action                     => c_upd_ch_rec.action
                  ,x_substitution               => c_upd_ch_rec.substitution
                  ,x_date_substituted           => c_upd_ch_rec.date_substituted
                  ,x_prev_institution           => c_upd_ch_rec.prev_institution
                  ,x_prev_course                => c_upd_ch_rec.prev_course
                  ,x_prev_campus                => c_upd_ch_rec.prev_campus
                  ,x_ucas_amendment             => c_upd_ch_rec.ucas_amendment
                  ,x_withdrawal_reason          => c_upd_ch_rec.withdrawal_reason
                  ,x_offer_course               => c_upd_ch_rec.offer_course
                  ,x_offer_campus               => c_upd_ch_rec.offer_campus
                  ,x_offer_crse_length          => c_upd_ch_rec.offer_crse_length
                  ,x_offer_entry_month          => c_upd_ch_rec.offer_entry_month
                  ,x_offer_entry_year           => c_upd_ch_rec.offer_entry_year
                  ,x_offer_entry_point          => c_upd_ch_rec.offer_entry_point
                  ,x_offer_text                 => c_upd_ch_rec.offer_text
                  ,x_export_to_oss_status       => l_export_to_oss_status
                  ,x_error_code                 => l_ch_error
                  ,x_request_id                 => l_conc_request_id
                  ,x_batch_id                   => l_ch_batch_id
                  ,x_mode                       => 'R'
                  ,x_extra_round_nbr            => c_upd_ch_rec.extra_round_nbr
                  ,x_system_code                => c_upd_ch_rec.system_code
                  ,x_part_time                  => c_upd_ch_rec.part_time
                  ,x_interview                  => c_upd_ch_rec.interview
                  ,x_late_application           => c_upd_ch_rec.late_application
                  ,x_modular                    => c_upd_ch_rec.modular
                  ,x_residential                => c_upd_ch_rec.residential
                  ,x_ucas_cycle                 => c_upd_ch_rec.ucas_cycle);

       END LOOP ;

  EXCEPTION
     WHEN OTHERS THEN
      Rollback;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UCAS_EXPORT_TO_OSS.EXPORT_APPLICATIONS'||' - '||SQLERRM);
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

  END export_applications ;


 PROCEDURE main_process(
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER,
    p_app_no igs_uc_applicants.app_no%TYPE ,
    p_choice_no igs_uc_app_choices.choice_no%TYPE
  ) IS
    /******************************************************************
     Created By      :   smaddali
     Date Created By :   12-SEP-2002
     Purpose         :   Main process called from concurrent manager for "export applications to OSS" process
     Known limitations,enhancements,remarks:
     Change History
     Who         When           What
     jchakrab    11-Oct-2005    Added check for checking setup of CANCELLED system outcome status
     anwest      18-JAN-2006    Bug# 4950285 R12 Disable OSS Mandate
    ***************************************************************** */

    IGS_UC_HE_NOT_ENABLED_EXCEP EXCEPTION;
    l_no_setup BOOLEAN ;
    l_rep_request_id NUMBER ;

    -- smaddali added this cursor for bug 2643048 ,
    -- to get all the distinct system_codes belonging to the passed application choice parameter
    CURSOR c_ch_system IS
    SELECT DISTINCT a.system_code
    FROM igs_uc_app_choices a
    WHERE a.app_no = NVL(p_app_no, a.app_no) AND
        a.choice_no = NVL(p_choice_no,a.choice_no) ;

    -- smaddali added cursor ,for bug 2643048
    CURSOR c_defaults( cp_system_code igs_uc_defaults.system_code%TYPE) IS
    SELECT *
    FROM igs_uc_defaults def
    WHERE system_code = cp_system_code;
    c_defaults_rec c_defaults%ROWTYPE ;

    --Curosor to get the Entry Year, Entry Month details that are need to check for calendar setup.
    CURSOR cur_app_choice_entry_det (cp_system_code igs_uc_defaults.system_code%TYPE) IS
      SELECT DISTINCT entry_year, entry_month
      FROM igs_uc_app_choices
      WHERE app_no = NVL(p_app_no, app_no)
      AND choice_no = NVL(p_choice_no, choice_no)
      AND system_code = cp_system_code;

    --Cursor to get the Calendar details for the given System, Entry Month and Entry Year.
    CURSOR cur_sys_entry_cal_det (cp_system_code  igs_uc_sys_calndrs.system_code%TYPE,
                                  cp_entry_year   igs_uc_sys_calndrs.entry_year%TYPE,
                                  cp_entry_month  igs_uc_sys_calndrs.entry_month%TYPE ) IS
      SELECT aca_cal_type,
             aca_cal_seq_no,
             adm_cal_type,
             adm_cal_seq_no
      FROM  igs_uc_sys_calndrs
      WHERE system_code = cp_system_code
      AND   entry_year = cp_entry_year
      AND   (entry_month = cp_entry_month OR entry_month = 0)
      ORDER BY entry_month DESC;

    l_sys_entry_cal_det_rec cur_sys_entry_cal_det%ROWTYPE;

    --Cursor to check whether APC defined for the System includes the step "Reconsideration" or not.
    CURSOR cur_prcs_cat_step (cp_admission_cat igs_ad_ss_appl_typ.admission_cat%TYPE,
                              cp_s_admission_process_type igs_ad_ss_appl_typ.s_admission_process_type%TYPE ) IS
    SELECT 'X'
    FROM  igs_ad_prcs_cat_step
    WHERE admission_cat = cp_admission_cat
    AND   s_admission_process_type = cp_s_admission_process_type
    AND   s_admission_step_type = 'RECONSIDER';

    l_found_flag VARCHAR2(1);

    --Cursor to get the Admission Process Category and Admission Process Type for the
    --Admission Application Type defined for the System in UCAS Setup.
    CURSOR cur_apc_det ( cp_application_type igs_uc_defaults.application_type%TYPE) IS
      SELECT admission_cat, s_admission_process_type
      FROM   igs_ad_ss_appl_typ
      WHERE  admission_application_type = cp_application_type
      AND    closed_ind = 'N';

    l_apc_det_rec cur_apc_det%ROWTYPE;

  BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    -- inititalize variables
    errbuf := NULL;
    retcode := 0;
    l_no_setup := FALSE ;
    -- Get the Concurrent Request ID of the current export of UCAS application to
    -- OSS admission applications run . this is a global variable
    l_conc_request_id := fnd_global.conc_request_id();

    -- Checking whether the UK profile is enabled
    IF Not (igs_uc_utils.is_ucas_hesa_enabled) THEN
      Raise igs_uc_he_not_enabled_excep; -- user defined exception
    END IF;

    -- smaddali added the for loop of the application choice systems for bug 2643048
    -- For each of the application choice ucas system , if setup is not proper then log an error
    FOR c_ch_system_rec IN c_ch_system LOOP
           -- Get the default UCAS setup values and keep them in package variable c_defaults_rec
           c_defaults_rec := NULL ;
           OPEN c_defaults(c_ch_system_rec.system_code) ;
           FETCH c_defaults INTO c_defaults_rec;
           CLOSE c_defaults ;

           -- Check if the set up data for admission Application Type is found in ucas defaults form
           IF c_defaults_rec.application_type IS NULL THEN
              fnd_message.set_name('IGS','IGS_UC_SETUP_ADM_APPL_TYPE');
              fnd_message.set_token('SYSTEM', c_ch_system_rec.system_code);
              fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
              l_no_setup := TRUE ;
           END IF ;

           --Check if the set up data for admission Application Type is found in ucas defaults form but the Application Type is closed.
           IF c_defaults_rec.application_type IS NOT NULL THEN
             l_apc_det_rec := NULL;
             --Get the APC details corresponding to the Application Type defined in UCAS Setup
             OPEN cur_apc_det(c_defaults_rec.application_type);
             FETCH cur_apc_det INTO l_apc_det_rec;
             CLOSE cur_apc_det;
             IF l_apc_det_rec.admission_cat IS NULL OR l_apc_det_rec.s_admission_process_type IS NULL THEN
               fnd_message.set_name('IGS','IGS_UC_SETUP_ADM_APC');
               fnd_message.set_token('SYSTEM', c_ch_system_rec.system_code);
               fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
               l_no_setup := TRUE ;
             ELSE
               l_found_flag := NULL;
               --Check whether APC defined for the System includes the step "Reconsideration" or not.
               OPEN cur_prcs_cat_step(l_apc_det_rec.admission_cat, l_apc_det_rec.s_admission_process_type);
               FETCH cur_prcs_cat_step INTO l_found_flag;
               CLOSE cur_prcs_cat_step;

               --Log the error if Admission Process Category Step "Reconsideration" not exists for the given APC details.
               IF l_found_flag IS NULL THEN
                 fnd_message.set_name('IGS','IGS_UC_APC_RECNSDR_NOT_INCL');
                 fnd_message.set_token('PROCCAT', l_apc_det_rec.admission_cat);
                 fnd_message.set_token('PROCTYPE', l_apc_det_rec.s_admission_process_type);
                 fnd_message.set_token('SYSTEM', c_ch_system_rec.system_code);
                 fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
                 l_no_setup := TRUE ;
               END IF;
             END IF;

           END IF;

           FOR app_choice_entry_det_rec IN cur_app_choice_entry_det(c_ch_system_rec.system_code)
           LOOP

             --Get the Calendar details for the given System, Entry Month and Entry Year from System Calendards table.
             l_sys_entry_cal_det_rec := NULL;
             OPEN cur_sys_entry_cal_det(c_ch_system_rec.system_code, app_choice_entry_det_rec.entry_year, app_choice_entry_det_rec.entry_month);
             FETCH cur_sys_entry_cal_det INTO l_sys_entry_cal_det_rec;
             CLOSE cur_sys_entry_cal_det;

             --Log the error if calendar details are not found.
             IF  l_sys_entry_cal_det_rec.adm_cal_type IS NULL OR l_sys_entry_cal_det_rec.adm_cal_seq_no IS NULL OR
                 l_sys_entry_cal_det_rec.aca_cal_type IS NULL OR l_sys_entry_cal_det_rec.aca_cal_seq_no IS NULL THEN
               fnd_message.set_name('IGS','IGS_UC_NO_SYS_CAL_MAP_EXIST');
               fnd_message.set_token('SYSTEM', c_ch_system_rec.system_code);
               fnd_message.set_token('ENTRYYEAR', app_choice_entry_det_rec.entry_year);
               fnd_message.set_token('ENTRYMONTH', app_choice_entry_det_rec.entry_month);
               fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
               l_no_setup := TRUE ;
             END IF ;

           END LOOP;

            -- Check if the set up data for obsolete outcome status is found in ucas defaults form
            IF c_defaults_rec.obsolete_outcome_status IS NULL THEN
               fnd_message.set_name('IGS','IGS_UC_SETUP_OBS_OUSTAT');
               fnd_message.set_token('SYSTEM', c_ch_system_rec.system_code);
               fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
               l_no_setup := TRUE ;
            END IF;

            -- Check if the set up data for pending outcome status is found in ucas defaults form
            IF c_defaults_rec.pending_outcome_status IS NULL THEN
               fnd_message.set_name('IGS','IGS_UC_SETUP_PENDING_OUSTAT');
               fnd_message.set_token('SYSTEM', c_ch_system_rec.system_code);
               fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
               l_no_setup := TRUE ;
            END IF;

            -- Check if the set up data for rejected outcome status is found in ucas defaults form
            IF c_defaults_rec.rejected_outcome_status IS NULL THEN
               fnd_message.set_name('IGS','IGS_UC_SETUP_REJC_OUSTAT');
               fnd_message.set_token('SYSTEM', c_ch_system_rec.system_code);
               fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
               l_no_setup := TRUE ;
            END IF;

            -- Check if the set up data for decision maker is found in ucas defaults form
            IF c_defaults_rec.decision_make_id IS NULL THEN
               fnd_message.set_name('IGS','IGS_UC_SETUP_DEC_MAKE');
               fnd_message.set_token('SYSTEM', c_ch_system_rec.system_code);
               fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
               l_no_setup := TRUE ;
            END IF;

            -- Check if the set up data for decision reason is found in ucas defaults form
            IF c_defaults_rec.decision_reason_id IS NULL THEN
               fnd_message.set_name('IGS','IGS_UC_SETUP_DEC_REASON');
               fnd_message.set_token('SYSTEM', c_ch_system_rec.system_code);
               fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
               l_no_setup := TRUE ;
            END IF;

    END LOOP ; -- checking for setup

    --add check for checking whether CANCELLED system status has been mapped
    IF IGS_AD_GEN_009.Admp_Get_Sys_Aos('CANCELLED') IS NULL THEN
        fnd_message.set_name('IGS','IGS_UC_SETUP_CANCEL_OUSTAT');
        fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
        l_no_setup := TRUE ;
    END IF;

    IF  l_no_setup THEN
      -- end job in warning state
       retcode := 1 ;
    ELSE

       c_defaults_rec := NULL ;

       -- Call the sub process to obsolete the old admission application when
       -- the application choice results in a new application/instance
       -- for all application choices in status New
       fnd_file.put_line( fnd_file.LOG ,' ');
       FND_MESSAGE.SET_NAME('IGS','IGS_UC_OBSOL_APP');
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       fnd_file.put_line( fnd_file.LOG ,'-----------------------------------');

       obsolete_applications( p_app_no, p_choice_no) ;

       -- Call the sub process to create new application/instance or update the existing admissionapplication
       -- for all application choices in status OC
       fnd_file.put_line( fnd_file.LOG ,' ');
       FND_MESSAGE.SET_NAME('IGS','IGS_UC_CRE_APP');
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       fnd_file.put_line( fnd_file.LOG ,'-----------------------------------');

       export_applications( p_app_no, p_choice_no) ;

       -- Call the process to import the UCAS decision field into oss outcome status field
       -- for all application choices in status AC
       fnd_file.put_line( fnd_file.LOG ,' ');
       FND_MESSAGE.SET_NAME('IGS','IGS_UC_DEC_IMP');
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       fnd_file.put_line( fnd_file.LOG ,'-----------------------------------');

       igs_uc_export_decision_reply.export_decision( p_app_no, p_choice_no) ;

       -- Call the process to import the UCAS Reply field into oss offer response status field
       -- for all application choices in status DC
       fnd_file.put_line( fnd_file.LOG ,' ');
       FND_MESSAGE.SET_NAME('IGS','IGS_UC_OFR_IMP');
       fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       fnd_file.put_line( fnd_file.LOG ,'-----------------------------------');

       igs_uc_export_decision_reply.export_reply( p_app_no, p_choice_no) ;

       -- log message that the Export applications to oss process has completed
       fnd_file.put_line( fnd_file.LOG ,' ');
       fnd_message.set_name('IGS','IGS_UC_EXP_APP_PROC_COMP');
       fnd_file.put_line(fnd_file.log,fnd_message.get());
       fnd_file.put_line( fnd_file.LOG ,'-----------------------------------');

      -- Submit the Error report to show the errors generated while exporting applications
       l_rep_request_id := NULL ;
       l_rep_request_id := Fnd_Request.Submit_Request
                          ( 'IGS',
                            'IGSUCS35',
                             'Export Applications to OSS Error Report',
                             NULL,
                             FALSE,
                             l_conc_request_id ,
                             NULL,
                             NULL,
                             NULL,
                             CHR(0) ,
                             NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
       IF l_rep_request_id > 0 THEN
              -- if error report successfully submitted then log message
              fnd_file.put_line( fnd_file.LOG ,' ');
              fnd_message.set_name('IGS','IGS_UC_REP_SUBM');
              fnd_message.set_token('REQ_ID',TO_CHAR(l_rep_request_id));
              fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       ELSE
              -- if error report failed to be launched then log message
              fnd_message.set_name('IGS','IGS_UC_REP_SUBM_ERR');
              fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
       END IF;

    END IF;  -- If ucas setup proper or not


  EXCEPTION
    WHEN IGS_UC_HE_NOT_ENABLED_EXCEP THEN
      -- ucas functionality is not enabled
      Errbuf          :=  fnd_message.get_string ('IGS', 'IGS_UC_HE_NOT_ENABLED');
      Retcode         := 2 ;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

    WHEN OTHERS THEN
      Rollback;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UCAS_EXPORT_TO_OSS.MAIN_PROCESS'||' - '||SQLERRM);
      fnd_message.retrieve (Errbuf);
      Retcode := 2 ;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END main_process ;

END igs_uc_export_to_oss;

/
