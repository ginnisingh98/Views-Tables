--------------------------------------------------------
--  DDL for Package Body IGS_UC_EXPUNGE_APP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_EXPUNGE_APP" AS
/* $Header: IGSUC38B.pls 120.1 2006/02/08 19:56:45 anwest noship $ */

  PROCEDURE delete_ucas_interface_rec( p_app_no IN NUMBER) IS
    /*************************************************************
    Created By      : rbezawad
    Date Created By : 11-NOV-2002
    Purpose : To delete Wrong Applicant records from UCAS Interface tables.

    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    (reverse chronological order - newest change first)
    rbezawad        16-Oct-03       Added logic to delete from interface (_INTS) tables w.r.t. ucfd209 build, bug: 2669228.
    ***************************************************************/

    CURSOR cur_ucap IS
      SELECT ROWID
      FROM igs_uc_applicants
      WHERE app_no = p_app_no;

    CURSOR cur_ucapcl IS
      SELECT ROWID
      FROM igs_uc_app_clearing
      WHERE app_no = p_app_no;

    CURSOR cur_ucapcr IS
      SELECT ROWID
      FROM igs_uc_app_clr_rnd
      WHERE app_no = p_app_no;

    CURSOR cur_ucapre IS
      SELECT ROWID
      FROM igs_uc_app_results
      WHERE app_no = p_app_no;

    CURSOR cur_ucapst IS
      SELECT ROWID
      FROM igs_uc_app_stats
      WHERE app_no = p_app_no;

    CURSOR cur_ucaddr IS
      SELECT ROWID
      FROM igs_uc_app_addreses
      WHERE app_no = p_app_no;

    CURSOR cur_ucnames IS
      SELECT ROWID
      FROM igs_uc_app_names
      WHERE app_no = p_app_no;

    CURSOR cur_ucref IS
      SELECT ROWID
      FROM igs_uc_app_referees
      WHERE app_no = p_app_no;

    CURSOR cur_ucfq IS
      SELECT ROWID
      FROM igs_uc_form_quals
      WHERE app_no = p_app_no;

  BEGIN

    --Delete Wrong Applicant records from UCAS Interface tables by calling the corresponding TBH.
    FOR x IN cur_ucapst LOOP
    igs_uc_app_stats_pkg.delete_row ( x_rowid    => x.ROWID );
    END LOOP;

    FOR x IN cur_ucapre LOOP
    igs_uc_app_results_pkg.delete_row ( x_rowid  => x.ROWID );
    END LOOP;

    FOR x IN cur_ucapcr LOOP
    igs_uc_app_clr_rnd_pkg.delete_row ( x_rowid  => x.ROWID );
    END LOOP;

    FOR x IN cur_ucapcl LOOP
    igs_uc_app_clearing_pkg.delete_row ( x_rowid => x.ROWID );
    END LOOP;

    FOR x IN cur_ucaddr LOOP
      igs_uc_app_addreses_pkg.delete_row ( x_rowid => x.ROWID );
    END LOOP;

    FOR x IN cur_ucnames LOOP
      igs_uc_app_names_pkg.delete_row ( x_rowid => x.ROWID );
    END LOOP;

    FOR x IN cur_ucref LOOP
      igs_uc_app_referees_pkg.delete_row ( x_rowid => x.ROWID );
    END LOOP;

    FOR x IN cur_ucfq LOOP
      igs_uc_form_quals_pkg.delete_row ( x_rowid => x.ROWID );
    END LOOP;

    FOR x IN cur_ucap LOOP
      igs_uc_applicants_pkg.delete_row ( x_rowid => x.ROWID );
    END LOOP;

    DELETE igs_uc_ifrmqul_ints    WHERE  appno = p_app_no;

    DELETE igs_uc_iqual_ints      WHERE  appno = p_app_no;

    DELETE igs_uc_irefrnc_ints    WHERE  appno = p_app_no;

    DELETE igs_uc_istara_ints     WHERE  appno = p_app_no;

    DELETE igs_uc_istarg_ints     WHERE  appno = p_app_no;

    DELETE igs_uc_istarh_ints     WHERE  appno = p_app_no;

    DELETE igs_uc_istarj_ints     WHERE  appno = p_app_no;

    DELETE igs_uc_istark_ints     WHERE  appno = p_app_no;

    DELETE igs_uc_istarn_ints     WHERE  appno = p_app_no;

    DELETE igs_uc_istart_ints     WHERE  appno = p_app_no;

    DELETE igs_uc_istarw_ints     WHERE  appno = p_app_no;

    DELETE igs_uc_istarx_ints     WHERE  appno = p_app_no;

    DELETE igs_uc_istarz1_ints    WHERE  appno = p_app_no;

    DELETE igs_uc_istarz2_ints    WHERE  appno = p_app_no;

    DELETE igs_uc_istmnt_ints     WHERE  appno = p_app_no;

    DELETE igs_uc_istrpqr_ints    WHERE  appno = p_app_no;

  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igs_uc_expunge_app.delete_ucas_interface_rec'||' - '||SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END delete_ucas_interface_rec;


  PROCEDURE expunge_proc( Errbuf   OUT NOCOPY VARCHAR2,
                          Retcode  OUT NOCOPY NUMBER,
                          p_app_no IN  NUMBER
                         ) IS
    /*************************************************************
    Created By      : rbezawad
    Date Created By : 11-NOV-2002
    Purpose :  1) The admissions decision import process is used to suspend the OSS Applications for the UCAS Wrong Application
                  and the Choice Number marked as lost.
               2) The Person Alternate Id stored in IGS_PE_ALT_PERS_ID table for the UCAS Wrong Applicaton should be end dated.
               3) Delete the Wrong Application related data from UCAS interface tables.
               4) If all wrong application data is successfully deleted from UCAS Interface tables then mark the applicants as
                  expunged by setting the flag in IGS_UC_WRONG_APP.EXPUNGED to 'Y'.
               5) log the message in the log file for the each step whether the processing is succussful or not.

    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    pkpatel         2-DEC-2002     Bug No: 2599109
                                   Modified igs_pe_alt_pers_id_pkg signature to include REGION_CD
    rbezawad        16-Oct-03      Modified logic to expunge at Application Choice level rather only at Application
                                   level w.r.t. ucfd209 build, bug: 2669228.
    ssaleem    09-FEB-05     Bug 3882788 - DELETION OF INVALID ALTERNATE PERSON IDS
    anwest          18-JAN-2006     Bug# 4950285 R12 Disable OSS Mandate
    (reverse chronological order - newest change first)
    ***************************************************************/

    --To check whether the setup record is available FOR each System, which has an application to be expunged.
    CURSOR cur_system_setup IS
      SELECT 'X'
      FROM   igs_uc_defaults def,
             igs_uc_applicants ucap
      WHERE  def.system_code (+) = ucap.system_code
      AND    def.system_code IS NULL
      AND    ucap.app_no IN ( SELECT app_no
                              FROM igs_uc_wrong_app wap
                              WHERE wap.expunge = 'Y'
                              AND   wap.expunged <> 'Y'
                              AND   wap.app_no = NVL(p_app_no, wap.app_no) );

    --To check whether the all required values available in each UCAS Setup FOR the System, which has an application to be expunged.
    CURSOR cur_system_val_setup IS
      SELECT 'X'
      FROM   igs_uc_defaults def
      WHERE  system_code IN ( SELECT DISTINCT system_code
                              FROM   igs_uc_applicants ucap,
                                     igs_uc_wrong_app wap
                              WHERE  ucap.app_no = wap.app_no
                              AND    wap.expunge = 'Y'
                              AND    wap.expunged <> 'Y'
                              AND    wap.app_no = NVL(p_app_no, wap.app_no) )
      AND    ( def.obsolete_outcome_status IS NULL OR def.decision_make_id IS NULL OR def.decision_reason_id IS NULL );

    --To loop through all the Applicant records to be expunged.
    CURSOR cur_wrong_app IS
      SELECT wap.ROWID row_id, wap.*
      FROM   igs_uc_wrong_app wap
      WHERE  wap.app_no = NVL(p_app_no, wap.app_no)
        AND  wap.expunge = 'Y'
        AND  wap.expunged <> 'Y'
        ORDER  BY wap.app_no;

    CURSOR cur_defaults (cp_app_no igs_uc_wrong_app.app_no%TYPE) IS
      SELECT obsolete_outcome_status,
             decision_make_id,
             decision_reason_id
      FROM   igs_uc_defaults def,
             igs_uc_applicants ucap
      WHERE  def.system_code = ucap.system_code
      AND    ucap.app_no = cp_app_no;

    --To identify the OSS Admission Application instances, which are created FOR UCAS Application number to be expunged
    CURSOR cur_oss_ad_appl_inst (cp_app_no igs_uc_wrong_app.app_no%TYPE,
                                 cp_choice_no igs_uc_app_choices.choice_no%TYPE) IS
      SELECT aap.person_id,
             aap.admission_appl_number,
             aap.alt_appl_id,
             aap.choice_number,
             aap.acad_cal_type,
             aap.acad_ci_sequence_number,
             aap.adm_cal_type,
             aap.adm_ci_sequence_number,
             aap.admission_cat,
             aap.s_admission_process_type,
             apai.nominated_course_cd,
             apai.crv_version_number,
             apai.location_cd,
             apai.attendance_mode,
             apai.attendance_type,
             apai.sequence_number,
             apai.adm_outcome_status
      FROM   igs_ad_appl_all aap,
             igs_ad_ps_appl_inst_all apai,
             igs_ad_ou_stat aous
      WHERE  aap.alt_appl_id = TO_CHAR(cp_app_no)
      AND    aap.choice_number = NVL(cp_choice_no,aap.choice_number)
      AND    aap.person_id = apai.person_id
      AND    aap.admission_appl_number = apai. admission_appl_number
      AND    apai.adm_outcome_status = aous.adm_outcome_status
      AND    aous.s_adm_outcome_status NOT IN ('SUSPEND','VOIDED')
      ORDER BY aap.choice_number, aap.admission_appl_number, apai.preference_number;

    -- To Get the interface Run ID which is used to populate the Admission Decision Import Interface table while Suspending the Application Instances.
    CURSOR cur_interface_run_id IS
      SELECT igs_ad_interface_ctl_s.NEXTVAL
      FROM   dual ;

    --To get the Person Number FOR the give person ID
    CURSOR cur_per_no (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
      SELECT person_number
      FROM   igs_pe_person_base_v
      WHERE  person_id = cp_person_id;

    --To get the Person alternate ID record to End Date
    CURSOR cur_alt_pers_id (cp_app_no igs_uc_wrong_app.app_no%TYPE) IS
      SELECT api.ROWID row_id, api.*
      FROM   igs_pe_alt_pers_id api,
             igs_uc_applicants ucap
      WHERE  api.pe_person_id  = ucap.oss_person_id
      AND    api.api_person_id = TO_CHAR(ucap.app_no)
      AND    ucap.app_no = cp_app_no
      AND    api.person_id_type= DECODE(ucap.system_code, 'U', 'UCASID', 'G', 'GTTRID', 'S', 'SWASID', 'N', 'NMASID')
      AND    (api.end_dt IS NULL OR (api.end_dt > SYSDATE AND api.end_dt <> api.start_dt));

    CURSOR cur_ucapcc (cp_app_no igs_uc_app_choices.app_no%TYPE, cp_choice_no igs_uc_app_choices.choice_no%TYPE) IS
      SELECT ROWID
      FROM  igs_uc_app_cho_cnds
      WHERE app_no = cp_app_no
      AND   choice_no = cp_choice_no;

    CURSOR cur_ucapch (cp_app_no igs_uc_app_choices.app_no%TYPE, cp_choice_no igs_uc_app_choices.choice_no%TYPE) IS
      SELECT ROWID, choice_no
      FROM igs_uc_app_choices
      WHERE app_no = cp_app_no
      AND   choice_no = NVL(cp_choice_no, choice_no);

    CURSOR cur_uctr (cp_app_no igs_uc_app_choices.app_no%TYPE, cp_choice_no igs_uc_app_choices.choice_no%TYPE) IS
      SELECT ROWID
      FROM igs_uc_transactions
      WHERE app_no = cp_app_no
      AND   choice_no = cp_choice_no;

    l_appl_inst_rec   cur_oss_ad_appl_inst%ROWTYPE;
    l_defaults_rec    cur_defaults%ROWTYPE;
    l_alt_pers_id_rec cur_alt_pers_id%ROWTYPE;

    l_dec_batch_id       igs_ad_batc_def_det_all.batch_id%TYPE ;
    l_interface_mkdes_id igs_ad_admde_int_all.interface_mkdes_id%TYPE;
    l_interface_run_id   igs_ad_admde_int_all.interface_run_id%TYPE;
    l_error_message      fnd_new_messages.message_text%TYPE;
    l_person_no          igs_pe_person_base_v.person_number%TYPE;
    l_dec_imp_err        fnd_new_messages.message_text%TYPE;
    l_choice_no          igs_uc_app_choices.choice_no%TYPE;

    --Table Type to hold the batch_id created for diferrent system cycle calendars.
    TYPE choice_det_table_type IS TABLE OF igs_uc_app_choices.choice_no%TYPE INDEX BY BINARY_INTEGER;

    --Table/Collection variable to hold the records for batch ids created of diferrent system, cycle and calendars.
    l_expunge_choice_det choice_det_table_type;
    l_expunge_choice_loc NUMBER;

    l_setup_comp             VARCHAR2(1);
    l_ucas_app_expunged      VARCHAR2(1);
    l_oss_app_inst_suspended VARCHAR2(1);
    l_pe_alt_pers_id_closed  VARCHAR2(1);
    l_ucas_app_recs_deleted  VARCHAR2(1);

    ----Local variable to indicate whether the all Application choices marked are obsolete or not.
    l_all_makred_app_inst_expunged VARCHAR2(1);

    l_return_status VARCHAR2(100) ;
    l_rowid         VARCHAR2(50);
    l_mesg_data     VARCHAR2(2000);
    l_msg_index     NUMBER;

  BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    --Check whether the UCAS Setup is complete or not.
    OPEN cur_system_setup;
    FETCH cur_system_setup INTO l_setup_comp;
    CLOSE cur_system_setup;

    OPEN cur_system_val_setup;
    FETCH cur_system_val_setup INTO l_setup_comp;
    CLOSE cur_system_val_setup;

    IF l_setup_comp = 'X' THEN
      fnd_message.set_name( 'IGS','IGS_UC_OBS_SETUP_NOT_SET');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      -- end job in warning state
      retcode := 1;
    ELSE

      --Loop through all the Wrong Applicants to be expunged.
      FOR l_wrong_app_rec IN cur_wrong_app
      LOOP

        -- Get the default UCAS setup values and keep them in package variable c_defaults_rec
        OPEN cur_defaults(l_wrong_app_rec.app_no);
        FETCH cur_defaults INTO l_defaults_rec;
        CLOSE cur_defaults;

        l_all_makred_app_inst_expunged := 'Y';
        l_expunge_choice_loc := 0;
        l_expunge_choice_det.DELETE;

        -- Get the Choice Number details of the Application to be expunged.
        IF  l_wrong_app_rec.choice1_lost = 'N'  AND l_wrong_app_rec.choice2_lost = 'N'  AND
            l_wrong_app_rec.choice3_lost = 'N'  AND l_wrong_app_rec.choice4_lost = 'N'  AND
            l_wrong_app_rec.choice5_lost = 'N'  AND l_wrong_app_rec.choice6_lost = 'N'  AND
            l_wrong_app_rec.choice7_lost = 'N' THEN
          --Need to consider as expunging the whole application i.e., expunge all choices available
          FOR l_apch_rec IN cur_ucapch (l_wrong_app_rec.app_no, NULL) LOOP
            l_expunge_choice_det(l_expunge_choice_loc) := l_apch_rec.choice_no;
            l_expunge_choice_loc := l_expunge_choice_loc + 1;
          END LOOP;

        ELSE
          IF l_wrong_app_rec.choice1_lost = 'Y' THEN
            l_expunge_choice_det(l_expunge_choice_loc) := 1;       l_expunge_choice_loc := l_expunge_choice_loc + 1;
          END IF;
          IF l_wrong_app_rec.choice2_lost = 'Y' THEN
            l_expunge_choice_det(l_expunge_choice_loc) := 2;       l_expunge_choice_loc := l_expunge_choice_loc + 1;
          END IF;
          IF l_wrong_app_rec.choice3_lost = 'Y' THEN
            l_expunge_choice_det(l_expunge_choice_loc) := 3;       l_expunge_choice_loc := l_expunge_choice_loc + 1;
          END IF;
          IF l_wrong_app_rec.choice4_lost = 'Y' THEN
            l_expunge_choice_det(l_expunge_choice_loc) := 4;       l_expunge_choice_loc := l_expunge_choice_loc + 1;
          END IF;
          IF l_wrong_app_rec.choice5_lost = 'Y' THEN
            l_expunge_choice_det(l_expunge_choice_loc) := 5;       l_expunge_choice_loc := l_expunge_choice_loc + 1;
          END IF;
          IF l_wrong_app_rec.choice6_lost = 'Y' THEN
            l_expunge_choice_det(l_expunge_choice_loc) := 6;       l_expunge_choice_loc := l_expunge_choice_loc + 1;
          END IF;
          IF l_wrong_app_rec.choice7_lost = 'Y' THEN
            l_expunge_choice_det(l_expunge_choice_loc) := 7;       l_expunge_choice_loc := l_expunge_choice_loc + 1;
          END IF;
        END IF;

        --Loop through the Application Choice's pl/sql table for expunging the corresponding choice records.
        FOR l_loc IN l_expunge_choice_det.FIRST..l_expunge_choice_det.LAST
        LOOP

          l_oss_app_inst_suspended  := 'Y';

          -- log Application Choice processing message.
          fnd_file.put_line (fnd_file.log,' ');
          fnd_message.set_name('IGS','IGS_UC_APPNO_CHOICE_PROC');
          fnd_message.set_token('APPNO', TO_CHAR(l_wrong_app_rec.app_no));
          fnd_message.set_token('CHOICE',TO_CHAR(l_expunge_choice_det(l_loc)));
          fnd_file.put_line(fnd_file.log, fnd_message.get);

          --Identify the OSS Admission Application instances to be suspended.
          OPEN cur_oss_ad_appl_inst(l_wrong_app_rec.app_no, l_expunge_choice_det(l_loc));
          FETCH cur_oss_ad_appl_inst INTO l_appl_inst_rec;

          IF cur_oss_ad_appl_inst%NOTFOUND THEN

            --When there are no Application Instances to Suspend then log the message and proceed with expunge process FOR next Application number.
            CLOSE cur_oss_ad_appl_inst;
            fnd_message.set_name( 'IGS','IGS_UC_NO_XPG_APPL_INST');
            fnd_message.set_token('APP_NO',TO_CHAR(l_wrong_app_rec.app_no));
            fnd_message.set_token('CHOICE_NO',TO_CHAR(l_expunge_choice_det(l_loc)));
            fnd_file.put_line (fnd_file.log,fnd_message.get);

          ELSE

            CLOSE cur_oss_ad_appl_inst;

            --Loop through all the Admission Application Instances which are to be Suspended FOR UCAS Wrong Application number.
            FOR l_oss_ad_appl_inst_rec IN cur_oss_ad_appl_inst(l_wrong_app_rec.app_no, l_expunge_choice_det(l_loc))
            LOOP

              -- Insert a record into the Admission Decision Import Batch table,IGS_AD_BATC_DEF_DET_ALL with calendar details of Application Instance
              -- This Batch ID will be used while populating the Admission Decision Import Process Interface Table
              l_rowid := NULL;
              l_dec_batch_id := NULL;
              igs_ad_batc_def_det_pkg.insert_row ( x_rowid                     => l_rowid,
                                                   x_batch_id                  => l_dec_batch_id,
                                                   x_description               => fnd_message.get_string('IGS','IGS_UC_XPG_DEC_BATCH'),
                                                   x_acad_cal_type             => l_oss_ad_appl_inst_rec.acad_cal_type,
                                                   x_acad_ci_sequence_number   => l_oss_ad_appl_inst_rec.acad_ci_sequence_number,
                                                   x_adm_cal_type              => l_oss_ad_appl_inst_rec.adm_cal_type,
                                                   x_adm_ci_sequence_number    => l_oss_ad_appl_inst_rec.adm_ci_sequence_number,
                                                   x_admission_cat             => l_oss_ad_appl_inst_rec.admission_cat,
                                                   x_s_admission_process_type  => l_oss_ad_appl_inst_rec.s_admission_process_type,
                                                   x_decision_make_id          => NULL,
                                                   x_decision_date             => NULL,
                                                   x_decision_reason_id        => NULL,
                                                   x_pending_reason_id         => NULL,
                                                   x_offer_dt                  => NULL,
                                                   x_offer_response_dt         => NULL,
                                                   x_mode                      => 'R' );

              -- Populate the Admission Decision Import Interface table,IGS_AD_ADMDE_INT_ALL FOR the application instance which need to be Suspended.
              l_rowid := NULL;
              l_interface_mkdes_id := NULL ;
              l_interface_run_id := NULL ;
              l_error_message := NULL ;
              l_return_status := NULL ;

              OPEN  cur_interface_run_id ;
              FETCH cur_interface_run_id INTO l_interface_run_id ;
              CLOSE cur_interface_run_id ;

              igs_ad_admde_int_pkg.insert_row ( x_rowid                    =>  l_rowid,
                                                x_interface_mkdes_id       =>  l_interface_mkdes_id,
                                                x_interface_run_id         =>  l_interface_run_id ,
                                                x_batch_id                 =>  l_dec_batch_id,
                                                x_person_id                =>  l_oss_ad_appl_inst_rec.person_id,
                                                x_admission_appl_number    =>  l_oss_ad_appl_inst_rec.admission_appl_number,
                                                x_nominated_course_cd      =>  l_oss_ad_appl_inst_rec.nominated_course_cd,
                                                x_sequence_number          =>  l_oss_ad_appl_inst_rec.sequence_number,
                                                x_adm_outcome_status       =>  l_defaults_rec.obsolete_outcome_status,
                                                x_decision_make_id         =>  l_defaults_rec.decision_make_id,
                                                x_decision_date            =>  SYSDATE,
                                                x_decision_reason_id       =>  l_defaults_rec.decision_reason_id,
                                                x_pending_reason_id        =>  NULL,
                                                x_offer_dt                 =>  NULL,
                                                x_offer_response_dt        =>  NULL,
                                                x_status                   =>  '2', -- pending status
                                                x_error_code               =>  NULL,
                                                x_mode                     =>  'R' );

              -- Call the decision import process to obsolete old applications
              igs_ad_imp_adm_des.prc_adm_outcome_status( p_person_id                => l_oss_ad_appl_inst_rec.person_id ,
                                                         p_admission_appl_number    => l_oss_ad_appl_inst_rec.admission_appl_number ,
                                                         p_nominated_course_cd      => l_oss_ad_appl_inst_rec.nominated_course_cd ,
                                                         p_sequence_number          => l_oss_ad_appl_inst_rec.sequence_number,
                                                         p_adm_outcome_status       => l_defaults_rec.obsolete_outcome_status,
                                                         p_s_adm_outcome_status     => 'SUSPEND',
                                                         p_acad_cal_type            => l_oss_ad_appl_inst_rec.acad_cal_type ,
                                                         p_acad_ci_sequence_number  => l_oss_ad_appl_inst_rec.acad_ci_sequence_number,
                                                         p_adm_cal_type             => l_oss_ad_appl_inst_rec.adm_cal_type ,
                                                         p_adm_ci_sequence_number   => l_oss_ad_appl_inst_rec.adm_ci_sequence_number ,
                                                         p_admission_cat            => l_oss_ad_appl_inst_rec.admission_cat ,
                                                         p_s_admission_process_type => l_oss_ad_appl_inst_rec.s_admission_process_type ,
                                                         p_batch_id                 => l_dec_batch_id,
                                                         p_interface_run_id         => l_interface_run_id ,
                                                         p_interface_mkdes_id       => l_interface_mkdes_id,
                                                         p_error_message            => l_error_message,  -- Replaced error_code with error_message Bug 3297241
                                                         p_return_status            => l_return_status ,
                                                         p_ucas_transaction         => 'N' );

              -- Check if the decision import completed succussfully or not.
              IF l_error_message IS NOT NULL OR l_return_status = 'FALSE'   THEN
                l_oss_app_inst_suspended := 'N';
                l_all_makred_app_inst_expunged := 'N';
                l_dec_imp_err := ' - '||l_error_message;

		fnd_message.set_name('IGS','IGS_UC_OBS_APP_DEC_IMP_ERR');
                fnd_message.set_token('APP_NO',   l_oss_ad_appl_inst_rec.alt_appl_id);
                fnd_message.set_token('CHOICE_NO',l_oss_ad_appl_inst_rec.choice_number);
                fnd_message.set_token('BATCH_ID', l_dec_batch_id);
                fnd_file.put_line(fnd_file.log,fnd_message.get()||l_dec_imp_err);
              ELSE
                OPEN  cur_per_no(l_oss_ad_appl_inst_rec.person_id);
                FETCH cur_per_no INTO l_person_no;
                CLOSE cur_per_no;
                fnd_message.set_name('IGS','IGS_UC_OBS_APPL_INST_COMP');
                fnd_message.set_token('PER_NO',   l_person_no);
                fnd_message.set_token('APPL_NUM', l_oss_ad_appl_inst_rec.admission_appl_number);
                fnd_message.set_token('PROG_CD',  l_oss_ad_appl_inst_rec.nominated_course_cd);
                fnd_message.set_token('PROG_VER', l_oss_ad_appl_inst_rec.crv_version_number);
                fnd_message.set_token('LOC',      l_oss_ad_appl_inst_rec.location_cd);
                fnd_message.set_token('ATT_TYPE', l_oss_ad_appl_inst_rec.attendance_mode);
                fnd_message.set_token('ATT_MODE', l_oss_ad_appl_inst_rec.attendance_type);
                fnd_file.put_line(fnd_file.log,fnd_message.get());
              END IF ; -- decision import failed or passed

            END LOOP;  -- End of the Admission Application Instances Loop FOR UCAS Wrong Applications

          END IF; -- End of OSS AD Application Instances Check.

          --If either there are no OSS application instances to be obsolete or all corresponding application
          -- instances are successfully obsolete i.e. no error is encountered on decision import then delete
          -- the Application Choice data from the UCAS Interface tables.
          IF l_oss_app_inst_suspended = 'Y' THEN
            --Delete Wrong Applicant records from UCAS Interface tables by calling the corresponding TBH.
            FOR x IN cur_ucapcc (l_wrong_app_rec.app_no, l_expunge_choice_det(l_loc)) LOOP
              igs_uc_app_cho_cnds_pkg.delete_row ( x_rowid => x.ROWID );
            END LOOP;

            FOR x IN cur_ucapch (l_wrong_app_rec.app_no, l_expunge_choice_det(l_loc)) LOOP
              igs_uc_app_choices_pkg.delete_row ( x_rowid  => x.ROWID );
            END LOOP;

            FOR x IN cur_uctr (l_wrong_app_rec.app_no, l_expunge_choice_det(l_loc)) LOOP
              igs_uc_transactions_pkg.delete_row ( x_rowid => x.ROWID );
            END LOOP;

            DELETE igs_uc_istarc_ints
            WHERE  appno = l_wrong_app_rec.app_no
            AND    choiceno = l_expunge_choice_det(l_loc);

            DELETE igs_uc_ioffer_ints
            WHERE  appno = l_wrong_app_rec.app_no
            AND    choiceno = l_expunge_choice_det(l_loc);

            fnd_message.set_name('IGS','IGS_UC_XPG_APP_CHO_REC_COMP');
            fnd_message.set_token('APP_NO',   TO_CHAR(l_wrong_app_rec.app_no));
            fnd_message.set_token('CHOICE_NO',TO_CHAR(l_expunge_choice_det(l_loc)));
            fnd_file.put_line(fnd_file.log,fnd_message.get());

          END IF;

        END LOOP;  -- End of the Choices (pl/sql table) Loop FOR UCAS Wrong Application

        --Check if any Application Choice records exists for the current Application Number
        l_rowid := NULL;
        l_ucas_app_expunged := 'N';
        OPEN cur_ucapch(l_wrong_app_rec.app_no, NULL);
        FETCH cur_ucapch INTO l_rowid, l_choice_no;
        CLOSE cur_ucapch;

        IF l_rowid IS NULL THEN
          l_ucas_app_expunged := 'Y';
        END IF;

        l_pe_alt_pers_id_closed := 'N';

        --When there are no applications choices available for the current applicant
        IF l_ucas_app_expunged = 'Y' THEN
          --If all are applications Instances suspended then do the End Date FOR Person Alternate ID records.
          l_pe_alt_pers_id_closed := 'Y';
          OPEN cur_alt_pers_id (l_wrong_app_rec.app_no);
          FETCH cur_alt_pers_id INTO l_alt_pers_id_rec;

          IF cur_alt_pers_id%FOUND THEN
            BEGIN
              igs_pe_alt_pers_id_pkg.Update_Row ( x_mode                              => 'R',
                                                  x_rowid                             => l_alt_pers_id_rec.row_id,
                                                  x_pe_person_id                      => l_alt_pers_id_rec.pe_person_id,
                                                  x_api_person_id                     => l_alt_pers_id_rec.api_person_id,
                                                  x_api_person_id_uf                  => l_alt_pers_id_rec.api_person_id_uf,
                                                  x_person_id_type                    => l_alt_pers_id_rec.person_id_type,
                                                  x_start_dt                          => l_alt_pers_id_rec.start_dt,
                                                  x_end_dt                            => SYSDATE ,
                                                  x_attribute_category                => l_alt_pers_id_rec.attribute_category,
                                                  x_attribute1                        => l_alt_pers_id_rec.attribute1,
                                                  x_attribute2                        => l_alt_pers_id_rec.attribute2,
                                                  x_attribute3                        => l_alt_pers_id_rec.attribute3,
                                                  x_attribute4                        => l_alt_pers_id_rec.attribute4,
                                                  x_attribute5                        => l_alt_pers_id_rec.attribute5,
                                                  x_attribute6                        => l_alt_pers_id_rec.attribute6,
                                                  x_attribute7                        => l_alt_pers_id_rec.attribute7,
                                                  x_attribute8                        => l_alt_pers_id_rec.attribute8,
                                                  x_attribute9                        => l_alt_pers_id_rec.attribute9,
                                                  x_attribute10                       => l_alt_pers_id_rec.attribute10,
                                                  x_attribute11                       => l_alt_pers_id_rec.attribute11,
                                                  x_attribute12                       => l_alt_pers_id_rec.attribute12,
                                                  x_attribute13                       => l_alt_pers_id_rec.attribute13,
                                                  x_attribute14                       => l_alt_pers_id_rec.attribute14,
                                                  x_attribute15                       => l_alt_pers_id_rec.attribute15,
                                                  x_attribute16                       => l_alt_pers_id_rec.attribute16,
                                                  x_attribute17                       => l_alt_pers_id_rec.attribute17,
                                                  x_attribute18                       => l_alt_pers_id_rec.attribute18,
                                                  x_attribute19                       => l_alt_pers_id_rec.attribute19,
                                                  x_attribute20                       => l_alt_pers_id_rec.attribute20,
                                                  x_region_cd                         => l_alt_pers_id_rec.region_cd);

              fnd_message.set_name('IGS','IGS_UC_END_DT_ALT_PID_COMP');
              fnd_message.set_token('APP_NO', l_wrong_app_rec.app_no);
              fnd_file.put_line(fnd_file.log,fnd_message.get());
            EXCEPTION
              WHEN OTHERS THEN
                l_pe_alt_pers_id_closed := 'N';
                l_mesg_data := NULL;
                l_msg_index := NULL;
                OPEN  cur_per_no(l_alt_pers_id_rec.pe_person_id);
                FETCH cur_per_no INTO l_person_no;
                CLOSE cur_per_no;
                IGS_GE_MSG_STACK.GET(IGS_GE_MSG_STACK.COUNT_MSG,FND_API.G_FALSE, l_mesg_data, l_msg_index);
                fnd_message.set_name('IGS','IGS_UC_END_DT_ALT_PID_ERR');
                fnd_message.set_token('PER_NO',  l_person_no);
                fnd_message.set_token('ALT_PID', l_alt_pers_id_rec.api_person_id);
                fnd_message.set_token('PID_TYPE',l_alt_pers_id_rec.person_id_type);
                fnd_file.put_line(fnd_file.log,fnd_message.get()||' - '||l_mesg_data);
            END;
          END IF;
          CLOSE cur_alt_pers_id;

        END IF; --End of check FOR all OSS Application Instances are suspended or not.

        l_ucas_app_recs_deleted := 'N';

        --Check if ucas application is expunged and Alternate IDs are end dated.
        IF l_ucas_app_expunged = 'Y' AND l_pe_alt_pers_id_closed = 'Y' THEN
           l_ucas_app_recs_deleted := 'Y';
           BEGIN
             --Call the sub procedure to delete Wrong Applicant records from UCAS Interface tables.
             delete_ucas_interface_rec(l_wrong_app_rec.app_no);
             fnd_message.set_name('IGS','IGS_UC_XPG_INT_REC_COMP');
             fnd_file.put_line(fnd_file.log,fnd_message.get());
           EXCEPTION
              WHEN OTHERS THEN
                l_ucas_app_recs_deleted := 'N';
                l_mesg_data := NULL;
                l_msg_index := NULL;
                IGS_GE_MSG_STACK.GET(IGS_GE_MSG_STACK.COUNT_MSG,FND_API.G_FALSE, l_mesg_data, l_msg_index);
                fnd_message.set_name('IGS','IGS_UC_XPG_INT_REC_ERR');
                fnd_message.set_token('APP_NO', l_wrong_app_rec.app_no);
                fnd_file.put_line(fnd_file.log,fnd_message.get()||' - '||l_mesg_data);
           END;
        END IF;  ----End of Check FOR all oss applications are suspended and Alternate IDs are end dated.

        -- IGS_UC_WRONG_APP.EXPUNGED can be set to 'Y' in following 2 conditions.
        --  1. All application choice details and related OSS application instances are expunged and
        --     Alternate Person IDs are closed and Interface Records are also succussfully deleted
        --     then mark the Wrong Applicant record as expunged.
        --  2. All application choice details maked as LOST are expunged and also the related OSS application
        --     instances are suspended and there exists some Application Choices in IGS_UC_APP_CHOICES table
        --     which are not marked as LOST then mark the Wrong Applicant as expunged.
        IF ( l_ucas_app_expunged = 'Y' AND l_pe_alt_pers_id_closed = 'Y' AND l_ucas_app_recs_deleted = 'Y' ) OR
           ( l_ucas_app_expunged = 'N' AND l_all_makred_app_inst_expunged = 'Y' ) THEN
          BEGIN
            igs_uc_wrong_app_pkg.update_row ( x_mode                     => 'R',
                                              x_rowid                    => l_wrong_app_rec.row_id,
                                              x_wrong_app_id             => l_wrong_app_rec.wrong_app_id,
                                              x_app_no                   => l_wrong_app_rec.app_no,
                                              x_miscoded                 => l_wrong_app_rec.miscoded,
                                              x_cancelled                => l_wrong_app_rec.cancelled,
                                              x_cancel_date              => l_wrong_app_rec.cancel_date,
                                              x_remark                   => l_wrong_app_rec.remark,
                                              x_expunge                  => l_wrong_app_rec.expunge,
                                              x_batch_id                 => l_wrong_app_rec.batch_id,
                                              x_expunged                 => 'Y',
                                              x_joint_admission_ind      => l_wrong_app_rec.joint_admission_ind,
                                              x_choice1_lost             => l_wrong_app_rec.choice1_lost,
                                              x_choice2_lost             => l_wrong_app_rec.choice2_lost,
                                              x_choice3_lost             => l_wrong_app_rec.choice3_lost,
                                              x_choice4_lost             => l_wrong_app_rec.choice4_lost,
                                              x_choice5_lost             => l_wrong_app_rec.choice5_lost,
                                              x_choice6_lost             => l_wrong_app_rec.choice6_lost,
                                              x_choice7_lost             => l_wrong_app_rec.choice7_lost);
            -- Display the Application level expunge message only when complete Application details are expunged.
            IF l_ucas_app_expunged = 'Y' THEN
              fnd_message.set_name('IGS','IGS_UC_XPG_APP_NO_REC_COMP');
              fnd_message.set_token('APP_NO', l_wrong_app_rec.app_no);
              fnd_file.put_line(fnd_file.log,fnd_message.get());
              fnd_file.put_line(fnd_file.log,' ');
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              l_mesg_data := NULL;
              l_msg_index := NULL;
              IGS_GE_MSG_STACK.GET(IGS_GE_MSG_STACK.COUNT_MSG,FND_API.G_FALSE, l_mesg_data, l_msg_index);
              fnd_message.set_name('IGS','IGS_UC_MARK_APP_EXPUNGED_ERR');
              fnd_message.set_token('APP_NO', l_wrong_app_rec.app_no);
              fnd_file.put_line(fnd_file.log,fnd_message.get()||' - '||l_mesg_data);
          END;
        END IF;

      END LOOP;  -- End of the UCAS Wrong Applications Loop

    END IF;  --End of Setup Complete Check.

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      retcode := 2;
      fnd_message.set_name( 'IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igs_uc_expunge_app.expunge_proc'||' - '||SQLERRM);
      errbuf := fnd_message.get;
      igs_ge_msg_stack.conc_exception_hndl;

  END expunge_proc;

END igs_uc_expunge_app;

/
