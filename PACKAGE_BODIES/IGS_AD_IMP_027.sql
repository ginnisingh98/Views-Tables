--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_027
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_027" AS
/* $Header: IGSADC7B.pls 115.13 2003/12/09 11:57:43 akadam noship $ */
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 21 APR 2003

Purpose:
  To Import Legacy Data

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who        When          What
pathipat   17-Jun-2003   Enh 2831587 - FI210 Credit Card Fund Transfer build
                         Modified igs_ad_app_req_pkg TBH calls in prc_appl_fees() - added new parameters
**********************************************************************************/
cst_s_val_1    CONSTANT VARCHAR2(1) := '1';
cst_s_val_2    CONSTANT VARCHAR2(1) := '2';
cst_s_val_3    CONSTANT VARCHAR2(1) := '3';
cst_s_val_4    CONSTANT VARCHAR2(1) := '4';

cst_et_val_E322 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E322', 8405);
cst_et_val_E686 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E686', 8405);
cst_et_val_E689 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E689', 8405);
cst_et_val_E709 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E709', 8405);
cst_et_val_E710 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E710', 8405);

cst_ec_val_E322 CONSTANT VARCHAR2(4) := 'E322';
cst_ec_val_E686 CONSTANT VARCHAR2(4) := 'E686';
cst_ec_val_E689 CONSTANT VARCHAR2(4) := 'E689';
cst_ec_val_E709 CONSTANT VARCHAR2(4) := 'E709';
cst_ec_val_E710 CONSTANT VARCHAR2(4) := 'E710';

PROCEDURE prc_appl_hist ( p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
                          p_enable_log   VARCHAR2,
                          p_rule     VARCHAR2) AS

/*************************************
||   Created By :Praveen Bondugula
||  Date Created By :24-apr-2003
||  Purpose : To import Qualification details
|| Know limitations, enhancements or remarks
||  Change History
||  Who             When            What
||
*/



  CURSOR c_appl_hist_cur IS
  SELECT *
  FROM igs_ad_apphist_int
  WHERE interface_run_id = p_interface_run_id
  AND   status = '2'
  ORDER BY person_id,admission_appl_number;

  CURSOR c_appl_dtls_cur(cp_person_id igs_ad_appl.person_id%TYPE,
                           cp_adm_appl_number igs_ad_appl.admission_appl_number%TYPE) IS
  SELECT
  acad_cal_type,
  acad_ci_sequence_number,
  adm_cal_type,
  adm_ci_sequence_number,
  admission_cat,
  s_admission_process_type
  FROM
  igs_ad_appl
  WHERE
  person_id = cp_person_id AND
  admission_appl_number = cp_adm_appl_number;

  appl_dtls_rec c_appl_dtls_cur%ROWTYPE;

  l_status           VARCHAR2(1);

  l_person_id   igs_ad_interface.person_id%TYPE;
  l_admission_appl_number igs_ad_apphist_int.admission_appl_number%TYPE;

  l_person_id_errored igs_ad_interface.person_id%TYPE;
  l_adm_appl_num_errored igs_ad_apphist_int.admission_appl_number%TYPE;

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_request_id NUMBER;
  l_error_code  igs_ad_notes_int.error_code%TYPE;
  l_records_processed NUMBER := 0;
  l_rowid VARCHAR2(30);

  l_msg_index   NUMBER := 0;
  l_error_text    VARCHAR2(2000);
  l_return_status   VARCHAR2(1);
  l_msg_count      NUMBER ;
  l_msg_data       VARCHAR2(2000);
  l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;


  PROCEDURE validate_appl_hist(p_appl_hist_rec c_appl_hist_cur%ROWTYPE,
                               p_status OUT NOCOPY igs_ad_interface.status%TYPE,
                               p_error_code OUT NOCOPY igs_ad_interface.error_code%TYPE) IS

  BEGIN
    --Validate HIST_START_DT
    IF p_appl_hist_rec.hist_start_dt > sysdate THEN
      p_error_code := 'E645';
      p_status := '3';
      RETURN;
    END IF;

    --Validate HIST_END_DT
    IF (p_appl_hist_rec.hist_end_dt > sysdate) OR (p_appl_hist_rec.hist_end_dt < p_appl_hist_rec.hist_start_dt)  THEN
      p_error_code := 'E646';
      p_status := '3';
      RETURN;
    END IF;

    -- Validate adm_appl_status
    IF p_appl_hist_rec.adm_appl_status IS NOT NULL THEN
      IF IGS_AD_GEN_007.ADMP_GET_SAAS(p_appl_hist_rec.adm_appl_status) = 'COMPLETED' THEN
        p_error_code := 'E679';
        p_status := '3';
        RETURN;
      END IF;
    END IF;

    IF p_appl_hist_rec.appl_dt IS NOT NULL THEN
      -- Validate APPL_DT
      IF p_appl_hist_rec.appl_dt > SYSDATE THEN
        p_error_code := 'E649';
        p_status := '3';
        RETURN;
      END IF;
    END IF;

    p_status := 1;
    p_error_code := NULL;
    RETURN;
  END validate_appl_hist;

BEGIN
  l_prog_label := 'igs.plsql.igs_ad_imp_027.prc_appl_hist';
  l_label := 'igs.plsql.igs_ad_imp_027.prc_appl_hist.';

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_027.prc_appl_hist.begin';
    l_debug_str :=  'igs_ad_imp_027.prc_appl_hist';

    fnd_log.string_with_context( fnd_log.level_procedure,
                                 l_label,
			         l_debug_str, NULL,
			         NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  -- Error out all the interface records, if the corrospending person already having application history details.
  UPDATE igs_ad_apphist_int  in_rec
  SET    error_code = cst_ec_val_E686
         ,error_text = cst_et_val_E686
         , status ='3'
  WHERE STATUS = '2'
  AND interface_run_id = p_interface_run_id
  AND  EXISTS ( SELECT 1
                FROM igs_ad_appl_hist
                WHERE  person_id = in_rec.person_id
                AND admission_appl_number = in_rec.admission_appl_number);

  COMMIT;

  UPDATE igs_ad_apphist_int  in_rec
  SET    error_code = cst_ec_val_E709
         ,error_text = cst_et_val_E709
         , status ='3'
  WHERE STATUS = '2'
  AND interface_run_id = p_interface_run_id
  AND NOT EXISTS ( SELECT 1
                FROM igs_ad_appl
                WHERE  person_id = in_rec.person_id
                AND admission_appl_number = in_rec.admission_appl_number);

  COMMIT;

  l_person_id := NULL;
  l_admission_appl_number := NULL;

  l_person_id_errored := NULL;
  l_adm_appl_num_errored := NULL;

  FOR appl_hist_rec IN c_appl_hist_cur
  LOOP
    l_msg_index := igs_ge_msg_stack.count_msg;

    IF appl_hist_rec.person_id <>  NVL(l_person_id_errored, -1)
       AND appl_hist_rec.admission_appl_number <>  NVL(l_adm_appl_num_errored, -1) THEN

      DECLARE
        invalid_record    exception;
      BEGIN

        IF appl_hist_rec.person_id <> NVL(l_person_id, appl_hist_rec.person_id)
           OR appl_hist_rec.admission_appl_number <> NVL(l_admission_appl_number, appl_hist_rec.admission_appl_number) THEN
          COMMIT;
        END IF;
        l_person_id := appl_hist_rec.person_id;
        l_admission_appl_number := appl_hist_rec.admission_appl_number;

        l_error_Code := NULL;
        validate_appl_hist(appl_hist_rec,l_status,l_error_code);

        IF(l_status ='3' ) THEN
          RAISE invalid_record;
        END IF;

        OPEN c_appl_dtls_cur(appl_hist_rec.person_id, appl_hist_rec.admission_appl_number);
        FETCH c_appl_dtls_cur INTO appl_dtls_rec;
        CLOSE c_appl_dtls_cur;

        igs_ad_appl_hist_pkg.insert_row (
                x_rowid                                 => l_rowid,
                x_org_id                                => NULL,
                x_person_id                             => appl_hist_rec.person_id,
                x_admission_appl_number                 => appl_hist_rec.admission_appl_number,
                x_hist_start_dt                         => appl_hist_rec.hist_start_dt,
                x_hist_end_dt                           => appl_hist_rec.hist_end_dt,
                x_hist_who                              => fnd_global.user_id,
                x_appl_dt                               => TRUNC(appl_hist_rec.appl_dt),
                x_acad_cal_type                         => appl_dtls_rec.acad_cal_type,
                x_acad_ci_sequence_number               => appl_dtls_rec.acad_ci_sequence_number,
                x_adm_cal_type                          => appl_dtls_rec.adm_cal_type,
                x_adm_ci_sequence_number                => appl_dtls_rec.adm_ci_sequence_number,
                x_admission_cat                         => appl_dtls_rec.admission_cat,
                x_s_admission_process_type              => appl_dtls_rec.s_admission_process_type,
                x_adm_appl_status                       => appl_hist_rec.adm_appl_status,
                x_adm_fee_status                        => appl_hist_rec.adm_fee_status,
                x_tac_appl_ind                          => appl_hist_rec.tac_appl_ind,
                x_mode                                  => 'R');

        UPDATE igs_ad_apphist_int
	SET status =cst_s_val_1
	WHERE   interface_apphist_id = appl_hist_rec.interface_apphist_id;
        -- If the all qulaificaton records with same person_id are processed , then commit;
        --If person_id changes from previous one then it means that records with previous person_id are processed
      EXCEPTION
        WHEN invalid_record THEN
          ROLLBACK ;
          l_person_id_errored := appl_hist_rec.person_id ;
          l_adm_appl_num_errored := appl_hist_rec.admission_appl_number;

          l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);
          UPDATE igs_ad_apphist_int
 	  SET    status = cst_s_val_3
                 , error_code = l_error_code
                 , error_text = l_error_text
          WHERE  interface_apphist_id = appl_hist_rec.interface_apphist_id;

          IF p_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(appl_hist_rec.interface_apphist_id,l_error_code,'IGS_AD_APPHIST_INT');
          END IF;
          l_error_code := 'E688';
          l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E688', 8405);

          UPDATE igs_ad_apphist_int
          SET    status = cst_s_val_3
                 , error_code = l_error_code
                 , error_text = l_error_text
          WHERE  person_id = appl_hist_rec.person_id
          AND status  =cst_s_val_2
          AND admission_appl_number = appl_hist_rec.admission_appl_number
          AND interface_apphist_id <> appl_hist_rec.interface_apphist_id;

        WHEN OTHERS THEN
          ROLLBACK ;
          l_error_code := 'E322';
          igs_ad_gen_016.extract_msg_from_stack (
                          p_msg_at_index                => l_msg_index,
                          p_return_status               => l_return_status,
                          p_msg_count                   => l_msg_count,
                          p_msg_data                    => l_msg_data,
                          p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
          IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
            l_error_text := l_msg_data;
            IF p_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(appl_hist_rec.interface_apphist_id,l_msg_data,'IGS_AD_APPHIST_INT');
            END IF;
          ELSE
            l_error_code := 'E518';
            IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
	      l_label := 'igs.plsql.igs_ad_imp_027.prc_appl_hist.exception '||l_msg_data;
              fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
	      fnd_message.set_token('INTERFACE_ID',appl_hist_rec.interface_apphist_id);
	      fnd_message.set_token('ERROR_CD','E322');
	      l_debug_str :=  fnd_message.get;
              fnd_log.string_with_context( fnd_log.level_exception,
					   l_label,
					   l_debug_str, NULL,
					   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
            END IF;

          END IF;
          l_person_id_errored := appl_hist_rec.person_id ;
          l_adm_appl_num_errored := appl_hist_rec.admission_appl_number;

          l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

          UPDATE igs_ad_apphist_int
 	  SET    status = cst_s_val_3
                 , error_code = l_error_code
                 , error_text = l_error_text
          WHERE  interface_apphist_id = appl_hist_rec.interface_apphist_id;

          l_error_code := 'E688';

          l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);

          UPDATE igs_ad_apphist_int
	  SET    status = cst_s_val_3
                 , error_code = l_error_code
                 , error_text = l_error_text
          WHERE  person_id = appl_hist_rec.person_id
          AND status  =cst_s_val_2
          AND admission_appl_number = appl_hist_rec.admission_appl_number
          AND interface_apphist_id <> appl_hist_rec.interface_apphist_id;


        END;
    END IF;
 END LOOP;
 COMMIT;

END prc_appl_hist;

PROCEDURE prc_appl_inst_hist (p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
                              p_enable_log   VARCHAR2,
                              p_rule     VARCHAR2) AS

/*************************************
||   Created By :Praveen Bondugula
||  Date Created By :24-apr-2003
||  Purpose : To import Qualification details
|| Know limitations, enhancements or remarks
||  Change History
||  Who             When            What
||
*/

  CURSOR c_applinst_dup_hist_cur(cp_person_id igs_ad_appl.person_id%TYPE,
                       cp_adm_appl_number igs_ad_appl.admission_appl_number%TYPE,
                       cp_nominated_course_cd igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
                       cp_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE,
                       cp_hist_start_dt   igs_ad_appl_hist.hist_start_dt%TYPE) IS
  SELECT
  'X'
  FROM  igs_ad_ps_aplinsthst
  WHERE  person_id = cp_person_id
  AND admission_appl_number = cp_adm_appl_number
  AND nominated_course_cd = cp_nominated_course_cd
  AND sequence_number = cp_sequence_number
  AND hist_start_dt = cp_hist_start_dt;

  c_applinst_dup_hist_rec c_applinst_dup_hist_cur%ROWTYPE;

  CURSOR c_applinst_dtls_cur(cp_person_id igs_ad_appl.person_id%TYPE,
                             cp_adm_appl_number igs_ad_appl.admission_appl_number%TYPE,
                             cp_nominated_course_cd igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
                             cp_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE) IS
  SELECT
    apl.acad_cal_type,
    apl.acad_ci_sequence_number,
    aplinst.adm_cal_type,
    aplinst.adm_ci_sequence_number,
    apl.admission_cat,
    apl.s_admission_process_type,
    aplinst.course_cd,
    aplinst.crv_version_number,
    aplinst.late_adm_fee_status,
    aplinst.correspondence_cat
  FROM
    igs_ad_appl apl,
    igs_ad_ps_appl_inst aplinst
  WHERE
    apl.person_id = aplinst.person_id
    AND apl.admission_appl_number = aplinst.admission_appl_number
    AND apl.person_id = cp_person_id
    AND apl.admission_appl_number = cp_adm_appl_number
    AND aplinst.nominated_course_cd = cp_nominated_course_cd
    AND aplinst.sequence_number = cp_sequence_number;

  applinst_dtls_rec c_applinst_dtls_cur%ROWTYPE;

  CURSOR c_applinst_hist_cur IS
  SELECT *
  FROM igs_ad_insthist_int
  WHERE interface_run_id = p_interface_run_id
  AND   status = '2'
  ORDER BY person_id,admission_appl_number,nominated_course_cd,sequence_number;

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_request_id NUMBER;
  l_error_code  igs_ad_notes_int.error_code%TYPE;
  l_records_processed NUMBER := 0;
  l_status           VARCHAR2(1);
  l_rowid VARCHAR2(30);
  l_exit VARCHAR2(1);

  l_msg_index   NUMBER := 0;
  l_error_text    VARCHAR2(2000);
  l_return_status   VARCHAR2(1);
  l_msg_count      NUMBER ;
  l_msg_data       VARCHAR2(2000);
  l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;

  l_person_id   igs_ad_interface.person_id%TYPE;
  l_admission_appl_number igs_ad_insthist_int.admission_appl_number%TYPE;
  l_nominated_course_cd  igs_ad_insthist_int.nominated_course_cd%TYPE;
  l_sequence_number igs_ad_insthist_int.sequence_number%TYPE;

  l_person_id_errored igs_ad_interface.person_id%TYPE;
  l_adm_appl_num_errored igs_ad_insthist_int.admission_appl_number%TYPE;
  l_nominated_course_cd_errored  igs_ad_insthist_int.nominated_course_cd%TYPE;
  l_sequence_number_errored igs_ad_insthist_int.sequence_number%TYPE;
  l_exist VARCHAR2(1);


  PROCEDURE validate_applinst_hist(p_applinst_hist_rec c_applinst_hist_cur%ROWTYPE,
                                   p_status OUT NOCOPY igs_ad_interface.status%TYPE,
                                   p_error_code OUT NOCOPY igs_ad_interface.error_code%TYPE)
  IS
    l_var VARCHAR2(1);

    CURSOR c_validate_auth_id IS -- should be here
    SELECT
      'X'
    FROM
      hz_parties
    WHERE
      party_id = p_applinst_hist_rec.adm_otcm_stat_auth_per_number;

  BEGIN
    --Validate HIST_START_DT
    IF p_applinst_hist_rec.hist_start_dt > sysdate THEN
      p_error_code := 'E645';
      p_status := '3';
      RETURN;
    END IF;

    --Validate HIST_END_DT
    IF (p_applinst_hist_rec.hist_end_dt > sysdate) OR (p_applinst_hist_rec.hist_end_dt < p_applinst_hist_rec.hist_start_dt)  THEN
      p_error_code := 'E646';
      p_status := '3';
      RETURN;
    END IF;

    IF p_applinst_hist_rec.adm_otcm_stat_auth_per_number IS NOT NULL THEN
      OPEN c_validate_auth_id;
      FETCH c_validate_auth_id INTO l_var;
      IF c_validate_auth_id%NOTFOUND THEN
        p_status := '3';
        p_error_code := 'E655';
        CLOSE c_validate_auth_id;
        RETURN;
      ELSE
        IF NVL(igs_en_gen_003.get_staff_ind(p_applinst_hist_rec.adm_otcm_stat_auth_per_number),'N')  = 'N' THEN
          p_status := '3';
          p_error_code := 'E655';
          CLOSE c_validate_auth_id;
          RETURN;
        END IF;
      END IF;
      CLOSE c_validate_auth_id;
    END IF;

    p_status := '1';
    p_error_code := NULL;

  END validate_applinst_hist;

BEGIN
  l_prog_label := 'igs.plsql.igs_ad_imp_027.prc_appl_inst_hist';
  l_label := 'igs.plsql.igs_ad_imp_027.prc_appl_inst_hist.';

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;
    l_label := 'igs.plsql.igs_ad_imp_027.prc_appl_inst_hist.begin';
    l_debug_str :=  'igs_ad_imp_027.prc_appl_inst_hist';
    fnd_log.string_with_context( fnd_log.level_procedure,
                                 l_label,
			         l_debug_str, NULL,
			         NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  -- Error out all the interface records, if the corrospending person already
  --  having application instance history details.
   UPDATE igs_ad_insthist_int  in_rec
   SET error_code = cst_ec_val_E689
       , status ='3'
       , error_text = cst_et_val_E689
   WHERE STATUS = '2'
   AND interface_run_id = p_interface_run_id
   AND  EXISTS ( SELECT 1  FROM igs_ad_ps_aplinsthst
                 WHERE  person_id = in_rec.person_id
                 AND admission_appl_number = in_rec.admission_appl_number
                 AND nominated_course_cd = in_rec.nominated_course_cd
                 AND sequence_number = in_rec.sequence_number );

  COMMIT;

  UPDATE igs_ad_insthist_int  in_rec
  SET error_code = cst_ec_val_E710
       , status ='3'
       , error_text = cst_et_val_E710
  WHERE STATUS = '2'
  AND interface_run_id = p_interface_run_id
  AND NOT EXISTS ( SELECT 1
                FROM igs_ad_ps_appl_inst
                WHERE  person_id = in_rec.person_id
                AND admission_appl_number = in_rec.admission_appl_number
                AND nominated_course_cd = in_rec.nominated_course_cd
                AND sequence_number = in_rec.sequence_number );

  COMMIT;

  l_person_id := NULL;
  l_admission_appl_number := NULL;
  l_nominated_course_cd := NULL;
  l_sequence_number := NULL;

  l_person_id_errored := NULL;
  l_adm_appl_num_errored := NULL;
  l_nominated_course_cd_errored := NULL;
  l_sequence_number_errored := NULL;

  FOR applinst_hist_rec IN c_applinst_hist_cur
  LOOP
    l_msg_index := igs_ge_msg_stack.count_msg;

    IF applinst_hist_rec.person_id <>  NVL(l_person_id_errored, -1)
      AND applinst_hist_rec.admission_appl_number <>  NVL(l_adm_appl_num_errored, -1)
      AND applinst_hist_rec.nominated_course_cd <>  NVL(l_nominated_course_cd_errored, '~')
      AND applinst_hist_rec.sequence_number <>  NVL(l_sequence_number_errored, -1) THEN

      DECLARE
        invalid_record    exception;
      BEGIN
        IF applinst_hist_rec.person_id <> NVL(l_person_id, applinst_hist_rec.person_id)
           OR applinst_hist_rec.admission_appl_number <> NVL(l_admission_appl_number, applinst_hist_rec.admission_appl_number)
           OR applinst_hist_rec.nominated_course_cd <> NVL(l_nominated_course_cd, applinst_hist_rec.nominated_course_cd)
           OR applinst_hist_rec.sequence_number <> NVL(l_sequence_number, applinst_hist_rec.sequence_number) THEN
           COMMIT;
        END IF;
        l_person_id := applinst_hist_rec.person_id;
        l_admission_appl_number := applinst_hist_rec.admission_appl_number;
        l_nominated_course_cd := applinst_hist_rec.nominated_course_cd;
        l_sequence_number := applinst_hist_rec.sequence_number;

        l_exit := 'N';

        LOOP
          EXIT WHEN l_exit = 'Y';
          -- Check if the record is already existing
          OPEN c_applinst_dup_hist_cur(applinst_hist_rec.person_id,
              applinst_hist_rec.admission_appl_number,
              applinst_hist_rec.nominated_course_cd,
              applinst_hist_rec.sequence_number,
              applinst_hist_rec.hist_start_dt
             );
          FETCH c_applinst_dup_hist_cur INTO c_applinst_dup_hist_rec;

          IF c_applinst_dup_hist_cur%FOUND THEN
            -- Same record is found in the History table
            -- so we need to increment the current histroy start date with
            -- one second
            applinst_hist_rec.hist_start_dt := applinst_hist_rec.hist_start_dt +  (1/(24*60*60));
            l_exit := 'N';
          ELSE
          l_exit := 'Y';
          END IF;
          CLOSE c_applinst_dup_hist_cur;
        END LOOP;
        l_error_Code := NULL;
        validate_applinst_hist(applinst_hist_rec,l_status,l_error_code);
        IF(l_status ='3' ) THEN
          RAISE invalid_record;
        END IF;
        OPEN c_applinst_dtls_cur(applinst_hist_rec.person_id,
                                        applinst_hist_rec.admission_appl_number,
                                        applinst_hist_rec.nominated_course_cd,
                                        applinst_hist_rec.sequence_number);
        FETCH c_applinst_dtls_cur INTO applinst_dtls_rec;
        CLOSE c_applinst_dtls_cur;
        igs_ad_ps_aplinsthst_pkg.insert_row(
             x_rowid                                 => l_rowid,
             x_org_id                                => null    ,
             x_person_id                             => applinst_hist_rec.person_id,
             x_admission_appl_number                 => applinst_hist_rec.admission_appl_number,
             x_nominated_course_cd                   => applinst_hist_rec.nominated_course_cd,
             x_sequence_number                       => applinst_hist_rec.sequence_number,
             x_hist_start_dt                         => applinst_hist_rec.hist_start_dt,
             x_applicant_acptnce_cndtn               => applinst_hist_rec.applicant_acptnce_cndtn,
             x_cndtnl_offer_cndtn                    => applinst_hist_rec.cndtnl_offer_cndtn,
             x_hist_end_dt                           => applinst_hist_rec.hist_end_dt,
             x_hist_who                              => fnd_global.user_id,
             x_hist_offer_round_number               => null,
             x_adm_cal_type                          => applinst_dtls_rec.adm_cal_type,
             x_adm_ci_sequence_number                => applinst_dtls_rec.adm_ci_sequence_number,
             x_course_cd                             => applinst_dtls_rec.course_cd,
             x_crv_version_number                    => applinst_dtls_rec.crv_version_number,
             x_location_cd                           => applinst_hist_rec.location_cd,
             x_attendance_mode                       => applinst_hist_rec.attendance_mode,
             x_attendance_type                       => applinst_hist_rec.attendance_type,
             x_unit_set_cd                           => applinst_hist_rec.unit_set_cd,
             x_us_version_number                     => applinst_hist_rec.us_version_number,
             x_preference_number                     => applinst_hist_rec.preference_number,
             x_adm_doc_status                        => applinst_hist_rec.adm_doc_status,
             x_adm_entry_qual_status                 => applinst_hist_rec.adm_entry_qual_status      ,
             x_late_adm_fee_status                   => applinst_dtls_rec.late_adm_fee_status,
             x_adm_outcome_status                    => applinst_hist_rec.adm_outcome_status  ,
             x_adm_otcm_status_auth_per_id           => applinst_hist_rec.adm_otcm_stat_auth_per_number,
             x_adm_outcome_status_auth_dt            => TRUNC(applinst_hist_rec.adm_outcome_status_auth_dt),
             x_adm_outcome_status_reason             => applinst_hist_rec.adm_outcome_status_reason ,
             x_offer_dt                              => TRUNC(applinst_hist_rec.offer_dt)          ,
             x_offer_response_dt                     => TRUNC(applinst_hist_rec.offer_resp_date)  ,
             x_prpsd_commencement_dt                 => TRUNC(applinst_hist_rec.prpsd_commencement_dt)       ,
             x_adm_cndtnl_offer_status               => applinst_hist_rec.adm_cndtnl_offer_status    ,
             x_cndtnl_offer_satisfied_dt             => TRUNC(applinst_hist_rec.cndtnl_offer_satisfied_dt)  ,
             x_cndtnl_ofr_must_be_stsfd_ind          => applinst_hist_rec.cndtnl_offer_must_be_stsfd_ind,
             x_adm_offer_resp_status                 => applinst_hist_rec.adm_offer_resp_status   ,
             x_actual_response_dt                    => TRUNC(applinst_hist_rec.actual_response_dt)       ,
             x_adm_offer_dfrmnt_status               => applinst_hist_rec.adm_offer_dfrmnt_status   ,
             x_deferred_adm_cal_type                 => NULL     ,
             x_deferred_adm_ci_sequence_num          => NULL,
             x_deferred_tracking_id                  => applinst_hist_rec.deferred_tracking_id      ,
             x_ass_rank                              => applinst_hist_rec.ass_rank,
             x_secondary_ass_rank                    => applinst_hist_rec.secondary_ass_rank,
             x_intrntnl_accept_advice_num            => applinst_hist_rec.intrntnl_acceptance_advice_num,
             x_ass_tracking_id                       => applinst_hist_rec.ass_tracking_id,
             x_fee_cat                               => applinst_hist_rec.fee_cat,
             x_hecs_payment_option                   => applinst_hist_rec.hecs_payment_option,
             x_expected_completion_yr                => applinst_hist_rec.expected_completion_yr,
             x_expected_completion_perd              => applinst_hist_rec.expected_completion_perd,
             x_correspondence_cat                    => applinst_dtls_rec.correspondence_cat,
             x_enrolment_cat                         => applinst_hist_rec.enrolment_cat,
             x_funding_source                        => applinst_hist_rec.funding_source,
             x_mode                                  => 'R');

          UPDATE igs_ad_insthist_int
	  SET    status =cst_s_val_1
	  WHERE   interface_insthist_id = applinst_hist_rec.interface_insthist_id;
          -- If the all qulaificaton records with same person_id are processed , then commit;
          --If person_id changes from previous one then it means that records with previous person_id are processed
        EXCEPTION
          WHEN invalid_record THEN
            ROLLBACK ;
            l_person_id_errored := applinst_hist_rec.person_id ;
            l_adm_appl_num_errored := applinst_hist_rec.admission_appl_number;
            l_nominated_course_cd_errored := applinst_hist_rec.nominated_course_cd;
            l_sequence_number_errored := applinst_hist_rec.sequence_number;

            l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);

            UPDATE igs_ad_insthist_int
 	    SET    status = cst_s_val_3
                   , error_code = l_error_code
                   , error_text = l_error_text
            WHERE  interface_insthist_id = applinst_hist_rec.interface_insthist_id;

            IF p_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(applinst_hist_rec.interface_insthist_id,l_error_code,'IGS_AD_INSTHIST_INT');
            END IF;

            l_error_code := 'E691';
            l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);

            UPDATE igs_ad_insthist_int
            SET status = cst_s_val_3
                , error_code = l_error_code
                , error_text = l_error_text
            WHERE  person_id = applinst_hist_rec.person_id
            AND status  =cst_s_val_2
            AND admission_appl_number = applinst_hist_rec.admission_appl_number
            AND nominated_course_cd = applinst_hist_rec.nominated_course_cd
            AND sequence_number = applinst_hist_rec.sequence_number
            AND interface_insthist_id <> applinst_hist_rec.interface_insthist_id;

          WHEN OTHERS THEN
            ROLLBACK ;
            l_error_code := 'E322';
            igs_ad_gen_016.extract_msg_from_stack (
                          p_msg_at_index                => l_msg_index,
                          p_return_status               => l_return_status,
                          p_msg_count                   => l_msg_count,
                          p_msg_data                    => l_msg_data,
                          p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

            l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

            IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
              l_error_text := l_msg_data;
              IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(applinst_hist_rec.interface_insthist_id,l_msg_data,'IGS_AD_INSTHIST_INT');
              END IF;
            ELSE
              l_error_code := 'E518';
              IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
		l_label := 'igs.plsql.igs_ad_imp_027.prc_appl_inst_hist.exception '||l_msg_data;
		fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		fnd_message.set_token('INTERFACE_ID',applinst_hist_rec.interface_insthist_id);
		fnd_message.set_token('ERROR_CD','E322');
                l_debug_str :=  fnd_message.get;
                fnd_log.string_with_context( fnd_log.level_exception,
                                             l_label,
					     l_debug_str, NULL,
					     NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
              END IF;
            END IF;
            l_person_id_errored := applinst_hist_rec.person_id ;
            l_adm_appl_num_errored := applinst_hist_rec.admission_appl_number;
            l_nominated_course_cd_errored := applinst_hist_rec.nominated_course_cd;
            l_sequence_number_errored := applinst_hist_rec.sequence_number;

            l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

            UPDATE igs_ad_insthist_int
            SET    status = cst_s_val_3
                   , error_code = l_error_code
                   , error_text = l_error_text
            WHERE  interface_insthist_id = applinst_hist_rec.interface_insthist_id;

            l_error_code := 'E691';

            l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);

            UPDATE igs_ad_insthist_int
	    SET    status = cst_s_val_3
                   , error_code = l_error_code
                   , error_text = l_error_text
            WHERE  person_id = applinst_hist_rec.person_id
            AND status  =cst_s_val_2
            AND admission_appl_number = applinst_hist_rec.admission_appl_number
            AND nominated_course_cd = applinst_hist_rec.nominated_course_cd
            AND sequence_number = applinst_hist_rec.sequence_number
            AND interface_insthist_id <> applinst_hist_rec.interface_insthist_id;
        END;
      END IF;
    END LOOP;
    COMMIT;
END prc_appl_inst_hist;

END IGS_AD_IMP_027;

/
