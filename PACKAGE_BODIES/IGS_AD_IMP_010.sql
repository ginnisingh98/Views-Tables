--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_010
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_010" AS
/* $Header: IGSAD88B.pls 120.0 2005/06/02 03:46:30 appldev noship $ */
/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
samaresh   02-FEB-2002	 Removed the procedure crt_appcln, as this happens
                         through igsad82b.pls.
			 The procedures admp_val_import_us,admp_ins_import_program,
			 admp_ins_import_acai are removed, as these are called
			 from crt_appcln
			 bug # 2191058
vchappid   29-Aug-2001   Added new parameters into function calls, Enh Bug#1964478
******************************************************************/

/***************************Status,Discrepancy Rule, Match Indicators, Error Codes********************/
cst_rule_val_I  CONSTANT VARCHAR2(1) := 'I';
cst_rule_val_E  CONSTANT VARCHAR2(1) := 'E';
cst_rule_val_R  CONSTANT VARCHAR2(1) := 'R';

cst_mi_val_11  CONSTANT VARCHAR2(2) := '11';
cst_mi_val_12  CONSTANT VARCHAR2(2) := '12';
cst_mi_val_13  CONSTANT VARCHAR2(2) := '13';
cst_mi_val_14  CONSTANT VARCHAR2(2) := '14';
cst_mi_val_15  CONSTANT VARCHAR2(2) := '15';
cst_mi_val_16  CONSTANT VARCHAR2(2) := '16';
cst_mi_val_17  CONSTANT VARCHAR2(2) := '17';
cst_mi_val_18  CONSTANT VARCHAR2(2) := '18';
cst_mi_val_19  CONSTANT VARCHAR2(2) := '19';
cst_mi_val_20  CONSTANT VARCHAR2(2) := '20';
cst_mi_val_21  CONSTANT VARCHAR2(2) := '21';
cst_mi_val_22  CONSTANT VARCHAR2(2) := '22';
cst_mi_val_23  CONSTANT VARCHAR2(2) := '23';
cst_mi_val_24  CONSTANT VARCHAR2(2) := '24';
cst_mi_val_25  CONSTANT VARCHAR2(2) := '25';
cst_mi_val_27  CONSTANT VARCHAR2(2) := '27';

cst_s_val_1    CONSTANT VARCHAR2(1) := '1';
cst_s_val_2    CONSTANT VARCHAR2(1) := '2';
cst_s_val_3    CONSTANT VARCHAR2(1) := '3';
cst_s_val_4    CONSTANT VARCHAR2(1) := '4';

cst_ec_val_E322 CONSTANT VARCHAR2(4) := 'E322';
cst_ec_val_E014 CONSTANT VARCHAR2(4) := 'E014';

cst_insert     CONSTANT VARCHAR2(6) :=  'INSERT';
cst_update     CONSTANT VARCHAR2(6) :=  'UPDATE';
cst_unique_record   CONSTANT NUMBER :=  1;

cst_et_val_E700 CONSTANT VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405);
cst_et_val_E701 CONSTANT VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);
cst_et_val_E678 CONSTANT VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E678', 8405);

cst_ec_val_E700 CONSTANT VARCHAR2(4) := 'E700';
cst_ec_val_E701 CONSTANT VARCHAR2(4) := 'E701';
cst_ec_val_E678 CONSTANT VARCHAR2(4) := 'E678';

/***************************Status,Discrepancy Rule, Match Indicators, Error Codes********************/

  -- Process the Applicant Notes
PROCEDURE admp_val_pappl_nots(p_interface_run_id  IN NUMBER,
                              p_enable_log        IN VARCHAR2,
                              p_category_meaning  IN VARCHAR2,
                              p_rule              IN VARCHAR2 )
AS
        l_prog_label  VARCHAR2(100);
        l_label  VARCHAR2(100);
        l_debug_str VARCHAR2(2000);
        l_request_id NUMBER;
        l_error_code  igs_ad_notes_int.error_code%TYPE;
	l_records_processed NUMBER := 0;

	-- local procedure
  PROCEDURE crt_apcnt_notes(
                        p_interface_run_id  IN NUMBER ) IS


    CURSOR c_igs_ad_notes_int IS
      SELECT  cst_insert dmlmode, rowid, a.*
      FROM igs_ad_notes_int a
      WHERE interface_run_id = p_interface_run_id
      AND status = cst_s_val_2;

    l_Appl_Notes_Id 	NUMBER;
    l_Rowid		VARCHAR2(100);
    l_Rowid2            VARCHAR2(25);
    l_Ref_Notes_Id	NUMBER;
    l_msg_at_index   NUMBER := 0;
    l_error_text    VARCHAR2(2000);
    l_return_status   VARCHAR2(1);
    l_msg_count      NUMBER ;
    l_msg_data       VARCHAR2(2000);
    l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;

    l_admission_cat igs_ad_appl.admission_cat%TYPE;
    l_s_admission_process_type igs_ad_appl.s_admission_process_type%TYPE;

  BEGIN
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN


      l_label := 'igs.plsql.igs_ad_imp_010.admp_val_pappl_nots.crt_apcnt_notes';
      l_debug_str :=  'Interface Run ID' || p_interface_run_id;

      fnd_log.string_with_context( fnd_log.level_procedure,
  	                           l_label,
                                   l_debug_str, NULL,
                                   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

    l_records_processed := 0;

    FOR notes_rec IN c_igs_ad_notes_int
    LOOP
      IF igs_ad_gen_016.get_appl_type_apc (p_application_type         => notes_rec.admission_application_type,
                                           p_admission_cat            => l_admission_cat,
                                           p_s_admission_process_type => l_s_admission_process_type) = 'TRUE' THEN

        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                    p_s_admission_process_type => l_s_admission_process_type,
                                    p_s_admission_step_type    => 'APPL-NOTES') = 'FALSE' THEN
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
          FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
          FND_MESSAGE.SET_TOKEN ('APPLTYPE', notes_rec.admission_application_type);
          l_error_text := FND_MESSAGE.GET;
          UPDATE igs_ad_notes_int
          SET
                 status = cst_s_val_3
                 , error_code = cst_ec_val_E701
                 , error_text = l_error_text
          WHERE rowid = notes_rec.rowid;
          l_records_processed := l_records_processed + 1;

        ELSIF NOT igs_ad_note_types_pkg.Get_UK2_For_Validation(
 	          x_notes_type_id => notes_rec.Note_Type_Id,
	          x_notes_category => 'APPLICATION',
	          x_closed_ind =>  'N') THEN
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_PK_UK_NOT_FOUND_CLOSED');
          FND_MESSAGE.SET_TOKEN ('ATTRIBUTE', FND_MESSAGE.GET_STRING('IGS','IGS_AD_NOTE_TYPE'));
          l_error_text := FND_MESSAGE.GET;
          UPDATE igs_ad_notes_int
          SET
                 status = cst_s_val_3
                 , error_code = cst_ec_val_E701
                 , error_text = l_error_text
          WHERE rowid = notes_rec.rowid;
          l_records_processed := l_records_processed + 1;

	ELSE
          BEGIN
            SAVEPOINT before_create;
            l_msg_at_index := igs_ge_msg_stack.count_msg;

            igs_ad_appl_notes_pkg.INSERT_ROW(
                                    X_ROWID => l_Rowid,
                                    X_APPL_NOTES_ID => l_Appl_Notes_Id,
                                    x_Person_Id => notes_rec.person_id,
                                    X_Admission_Appl_Number => notes_rec.Admission_Appl_Number,
                                    x_Nominated_Course_Cd =>  notes_rec.Nominated_Course_Cd,
                                    x_Sequence_Number => notes_rec.Sequence_Number,
                                    x_Note_Type_Id => notes_rec.Note_Type_Id,
                                    x_Ref_Notes_Id => l_Ref_Notes_Id,
                                    x_Mode  => 'R');
            igs_ge_note_pkg.INSERT_ROW(
                                    X_ROWID => l_Rowid2,
                                    X_REFERENCE_NUMBER =>  l_Ref_Notes_Id,
                                    X_S_NOTE_FORMAT_TYPE => 'TEXT',
                                    X_NOTE_TEXT => notes_rec.notes,
                                    X_MODE => 'R');
            UPDATE igs_ad_notes_int
            SET
                   status = cst_s_val_1
            WHERE rowid = notes_rec.rowid;
            l_records_processed := l_records_processed + 1;
            IF l_records_processed = 100 THEN
             COMMIT;
            l_records_processed := 0;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK TO before_create;
              l_error_code := 'E322';
              l_msg_data := SQLERRM;

              igs_ad_gen_016.extract_msg_from_stack (
                      p_msg_at_index                => l_msg_at_index,
                      p_return_status               => l_return_status,
                      p_msg_count                   => l_msg_count,
                      p_msg_data                    => l_msg_data,
                      p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
              l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

              IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                IF p_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(notes_rec.interface_notes_id,l_msg_data,'IGS_AD_NOTES_INT');
                END IF;
              ELSE
                IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                  l_label := 'igs.plsql.igs_ad_imp_010.admp_val_pappl_nots.crt_apcnt_notes.for_loop.execption'||l_error_code;

                  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                  fnd_message.set_token('INTERFACE_ID',notes_rec.interface_notes_id);
                  fnd_message.set_token('ERROR_CD',l_error_code);

                  l_debug_str :=  fnd_message.get;
                  fnd_log.string_with_context( fnd_log.level_exception,
                                                     l_label,
                                                     l_debug_str, NULL,
                                                     NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                END IF;
              END IF;



              UPDATE igs_ad_notes_int
              SET    status = cst_s_val_3
                     , error_code = l_error_code
                     , error_text = l_error_text
              WHERE rowid = notes_rec.rowid;
              l_records_processed := l_records_processed + 1;
          END;
        END IF;

      ELSE
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
        FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
        FND_MESSAGE.SET_TOKEN ('APPLTYPE', notes_rec.admission_application_type);
        l_error_text := FND_MESSAGE.GET;

        UPDATE igs_ad_notes_int
        SET    status = cst_s_val_3
               , error_code = cst_ec_val_E701
               , error_text = l_error_text
        WHERE rowid = notes_rec.rowid;
        l_records_processed := l_records_processed + 1;
      END IF;
      IF l_records_processed = 100 THEN
        COMMIT;
        l_records_processed := 0;
      END IF;
    END LOOP;

    IF l_records_processed < 100 AND l_records_processed > 0 THEN
      COMMIT;
    END IF;
  END crt_apcnt_notes;
	-- Local Procedure crt_apcnt_notes end here
BEGIN

  l_prog_label := 'igs.plsql.igs_ad_imp_010.admp_val_pappl_nots';
  l_label := 'igs.plsql.igs_ad_imp_010.admp_val_pappl_nots.';
  l_request_id := fnd_global.conc_request_id;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
    l_label := 'igs.plsql.igs_ad_imp_010.admp_val_pappl_nots.begin';
    l_debug_str :=  'igs_ad_imp_010.admp_val_pappl_nots';
    fnd_log.string_with_context(fnd_log.level_procedure,
                                l_label,
			        l_debug_str, NULL,
			        NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  -- Set STATUS to 3 when duplicate record is found

  UPDATE igs_ad_notes_int in_rec
  SET
         status = cst_s_val_3
         , error_code = cst_ec_val_E678
         , error_text = cst_et_val_E678
  WHERE interface_run_id = p_interface_run_id
  AND status = cst_s_val_2
  AND EXISTS ( SELECT 1
               FROM igs_ad_appl_notes mn_rec
               WHERE mn_rec.person_id = in_rec.person_id
               AND  mn_rec.admission_appl_number = in_rec.admission_appl_number
               AND  mn_rec.nominated_course_cd = in_rec.nominated_course_cd
               AND  mn_rec.note_type_id = in_rec.note_type_id
               AND  mn_rec.sequence_number = in_rec.sequence_number);
  COMMIT;

  -- Create  the OSS record after validating successfully the interface record
  crt_apcnt_notes( p_interface_run_id);

END admp_val_pappl_nots ;

PROCEDURE  prcs_applnt_edu_goal_dtls(p_interface_run_id  IN NUMBER,
                                     p_enable_log        IN VARCHAR2,
                                     p_category_meaning  IN VARCHAR2,
                                     p_rule              IN VARCHAR2 ) AS

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_request_id NUMBER;
  l_error_code  igs_ad_edugoal_int.error_code%TYPE;
  l_records_processed NUMBER := 0;

  --
  -- Start of Local Procedure create_applicant_edu_goals
  --
  PROCEDURE create_applicant_edu_goals(
                       p_interface_run_id  IN NUMBER ) IS

    CURSOR c_igs_ad_edugoal_int IS
    SELECT  cst_insert dmlmode, rowid, a.*
    FROM igs_ad_edugoal_int a
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2;

    l_rowid ROWID;
    l_post_edugoal_id igs_ad_edugoal.post_edugoal_id%TYPE;
    l_msg_at_index    NUMBER := 0;
    l_return_status   VARCHAR2(1);
    l_error_text    VARCHAR2(2000);
    l_msg_count       NUMBER ;
    l_msg_data        VARCHAR2(2000);
    l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;

    l_admission_cat igs_ad_appl.admission_cat%TYPE;
    l_s_admission_process_type igs_ad_appl.s_admission_process_type%TYPE;

  BEGIN

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
     l_label := 'igs.plsql.igs_ad_imp_010.prcs_applnt_edu_goal_dtls.create_applicant_edu_goals';
     l_debug_str :=  'Interface Run ID' || p_interface_run_id;
     fnd_log.string_with_context( fnd_log.level_procedure,
  		       l_label,
		       l_debug_str, NULL,
		       NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

    l_records_processed := 0;

    FOR edugoal_rec IN c_igs_ad_edugoal_int
    LOOP
      IF igs_ad_gen_016.get_appl_type_apc (p_application_type         => edugoal_rec.admission_application_type,
                                           p_admission_cat            => l_admission_cat,
                                           p_s_admission_process_type => l_s_admission_process_type) = 'TRUE' THEN

        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                    p_s_admission_process_type => l_s_admission_process_type,
                                    p_s_admission_step_type    => 'EDU-GOALS') = 'FALSE' THEN
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
          FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
          FND_MESSAGE.SET_TOKEN ('APPLTYPE', edugoal_rec.admission_application_type);
          l_error_text := FND_MESSAGE.GET;
          UPDATE igs_ad_edugoal_int
          SET
            status = cst_s_val_3
            , error_code = cst_ec_val_E701
            , error_text = l_error_text
            WHERE rowid = edugoal_rec.rowid;
            l_records_processed := l_records_processed + 1;
        ELSE
          BEGIN
            SAVEPOINT before_create;
            l_msg_at_index := igs_ge_msg_stack.count_msg;

            igs_ad_edugoal_pkg.insert_row
                       (
                               X_ROWID                        => l_rowid,
                               X_POST_EDUGOAL_ID              => l_post_edugoal_id,
                               X_PERSON_ID                    => edugoal_rec.person_id,
                               X_ADMISSION_APPL_NUMBER        => edugoal_rec.admission_appl_number,
                               X_NOMINATED_COURSE_CD          => edugoal_rec.nominated_course_cd,
                               X_SEQUENCE_NUMBER              => edugoal_rec.sequence_number,
                               X_EDU_GOAL_ID                  => edugoal_rec.edu_goal_id,
                               X_MODE                         => 'R'
                       );
            UPDATE igs_ad_edugoal_int
            SET    status = cst_s_val_1
            WHERE rowid = edugoal_rec.rowid;

            l_records_processed := l_records_processed + 1;

            IF l_records_processed = 100 THEN
              COMMIT;
              l_records_processed := 0;
            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK TO before_create;
              l_error_code := 'E322';
              l_msg_data := SQLERRM;
              igs_ad_gen_016.extract_msg_from_stack (
                      p_msg_at_index                => l_msg_at_index,
                      p_return_status               => l_return_status,
                      p_msg_count                   => l_msg_count,
                      p_msg_data                    => l_msg_data,
                      p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

              l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

              IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                IF p_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(edugoal_rec.interface_edugoal_id,l_msg_data,'IGS_AD_EDUGOAL_INT');
                END IF;
              ELSE
                IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                  l_label := 'igs.plsql.igs_ad_imp_010.prcs_applnt_edu_goal_dtls.create_applicant_edu_goals.for_loop.execption'||l_error_code;
                  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                  fnd_message.set_token('INTERFACE_ID',edugoal_rec.interface_edugoal_id);
        	  fnd_message.set_token('ERROR_CD',l_error_code);
                  l_debug_str :=  fnd_message.get;
                  fnd_log.string_with_context( fnd_log.level_exception,
                                               l_label,
                                               l_debug_str, NULL,
                                               NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                END IF;
              END IF;

              UPDATE igs_ad_edugoal_int
              SET    status = cst_s_val_3
                     ,error_code = l_error_code
                     ,error_text = l_error_text
              WHERE rowid = edugoal_rec.rowid;
              l_records_processed := l_records_processed + 1;
          END;
        END IF;
      ELSE
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
        FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
        FND_MESSAGE.SET_TOKEN ('APPLTYPE', edugoal_rec.admission_application_type);
        l_error_text := FND_MESSAGE.GET;
        UPDATE igs_ad_edugoal_int
        SET
          status = cst_s_val_3
          , error_code = cst_ec_val_E701
          , error_text = l_error_text
        WHERE rowid = edugoal_rec.rowid;
        l_records_processed := l_records_processed + 1;
      END IF;

      IF l_records_processed = 100 THEN
        COMMIT;
        l_records_processed := 0;
      END IF;
    END LOOP;
    IF l_records_processed < 100 AND l_records_processed > 0 THEN
      COMMIT;
    END IF;
  END create_applicant_edu_goals;

BEGIN

  l_prog_label := 'igs.plsql.igs_ad_imp_010.prcs_applnt_edu_goal_dtls';
  l_label := 'igs.plsql.igs_ad_imp_010.prcs_applnt_edu_goal_dtls.';
  l_request_id := fnd_global.conc_request_id;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
    l_label := 'igs.plsql.igs_ad_imp_010.prcs_applnt_edu_goal_dtls.begin';
    l_debug_str :=  'igs_ad_imp_010.prcs_applnt_edu_goal_dtls';
    fnd_log.string_with_context( fnd_log.level_procedure,
                                 l_label,
			         l_debug_str, NULL,
			         NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  -- Set STATUS to 3 when duplicate record is found

  UPDATE igs_ad_edugoal_int in_rec
  SET    status = cst_s_val_3
         ,error_code = cst_ec_val_E678
         ,error_text = cst_et_val_E678
  WHERE interface_run_id = p_interface_run_id
  AND status = cst_s_val_2
  AND EXISTS ( SELECT 1
               FROM igs_ad_edugoal mn_rec
               WHERE mn_rec.person_id = in_rec.person_id
               AND  mn_rec.admission_appl_number = in_rec.admission_appl_number
               AND  mn_rec.nominated_course_cd = in_rec.nominated_course_cd
               AND  mn_rec.edu_goal_id = in_rec.edu_goal_id
               AND  mn_rec.sequence_number = in_rec.sequence_number);
  COMMIT;

  -- Create  the OSS record after validating successfully the interface record
  create_applicant_edu_goals( p_interface_run_id);

END prcs_applnt_edu_goal_dtls;

PROCEDURE prc_apcnt_uset_apl( p_interface_run_id  IN NUMBER,
                              p_enable_log        IN VARCHAR2,
                              p_category_meaning  IN VARCHAR2,
                              p_rule              IN VARCHAR2 ) AS

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_request_id NUMBER;
  l_error_code  igs_ad_unitsets_int.error_code%TYPE;


  PROCEDURE crt_upd_apcnt_uset_apl(p_interface_run_id NUMBER) AS

    CURSOR c_igs_ad_unitsets_int IS
    SELECT  cst_insert dmlmode, rowid, in_rec.*
    FROM igs_ad_unitsets_int in_rec
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND ( ( NVL(match_ind,'15') = '15'
            AND NOT EXISTS ( SELECT 1
                             FROM igs_ad_unit_sets mn_rec
                             WHERE mn_rec.person_id = in_rec.person_id
                             AND   mn_rec.sequence_number = in_rec.sequence_number
                             AND   mn_rec.unit_set_cd = in_rec.unit_set_cd
                             AND   mn_rec.version_number = in_rec.version_number
                             AND   mn_rec.admission_appl_number = in_rec.admission_appl_number
                             AND   mn_rec.nominated_course_cd = in_rec.nominated_course_cd))
         OR (p_rule = cst_rule_val_R
             AND match_ind IN (cst_mi_val_16, cst_mi_val_25)))
    UNION ALL
    SELECT  cst_update dmlmode, rowid, in_rec.*
    FROM igs_ad_unitsets_int in_rec
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND (   (p_rule = cst_rule_val_I)
         OR (p_rule = cst_rule_val_R AND match_ind = cst_mi_val_21))
    AND EXISTS ( SELECT 1
                 FROM igs_ad_unit_sets mn_rec
                 WHERE mn_rec.person_id = in_rec.person_id
                 AND   mn_rec.sequence_number = in_rec.sequence_number
                 AND   mn_rec.unit_set_cd = in_rec.unit_set_cd
                 AND   mn_rec.version_number = in_rec.version_number
                 AND   mn_rec.admission_appl_number = in_rec.admission_appl_number
                 AND   mn_rec.nominated_course_cd = in_rec.nominated_course_cd);

   CURSOR c_null_hdlg_unitsets_cur_rec(cp_unit_set_cur c_igs_ad_unitsets_int%ROWTYPE) IS
   SELECT ROWID, mn_rec.*
   FROM igs_ad_unit_sets mn_rec
   WHERE mn_rec.person_id = cp_unit_set_cur.person_id
   AND   mn_rec.sequence_number = cp_unit_set_cur.sequence_number
   AND   mn_rec.unit_set_cd = cp_unit_set_cur.unit_set_cd
   AND   mn_rec.version_number = cp_unit_set_cur.version_number
   AND   mn_rec.admission_appl_number = cp_unit_set_cur.admission_appl_number
   AND   mn_rec.nominated_course_cd = cp_unit_set_cur.nominated_course_cd;

   c_null_hdlg_unitsets_rec c_null_hdlg_unitsets_cur_rec%ROWTYPE;

   l_error_code       VARCHAR2(30);
   l_msg_at_index   NUMBER := 0;
   l_return_status   VARCHAR2(1);
   l_error_text    VARCHAR2(2000);
   l_msg_count      NUMBER ;
   l_msg_data       VARCHAR2(2000);
   l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;

   l_records_processed  NUMBER;
   l_rowid VARCHAR2(30);
   l_unit_set_id igs_ad_unit_sets.unit_set_id%TYPE;

   l_admission_cat igs_ad_appl.admission_cat%TYPE;
   l_s_admission_process_type igs_ad_appl.s_admission_process_type%TYPE;

 BEGIN

   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
     l_label := 'igs.plsql.igs_ad_imp_014.prc_apcnt_uset_apl.crt_upd_apcnt_uset_apl';
     l_debug_str :=  'Interface Run ID' || p_interface_run_id;
     fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
			          l_debug_str, NULL,
			          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
   END IF;
   l_records_processed := 0;

   FOR unitsets_rec IN c_igs_ad_unitsets_int
   LOOP
     IF igs_ad_gen_016.get_appl_type_apc (p_application_type         => unitsets_rec.admission_application_type,
                                        p_admission_cat            => l_admission_cat,
                                        p_s_admission_process_type => l_s_admission_process_type) = 'TRUE' THEN
     IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                 p_s_admission_process_type => l_s_admission_process_type,
                                 p_s_admission_step_type    => 'DES-UNITSETS') = 'FALSE' THEN

       FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
       FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
       FND_MESSAGE.SET_TOKEN ('APPLTYPE', unitsets_rec.admission_application_type);
       l_error_text := FND_MESSAGE.GET;

       UPDATE igs_ad_unitsets_int
       SET    status = cst_s_val_3
              ,match_ind = DECODE (unitsets_rec.dmlmode,  cst_update, DECODE (match_ind,NULL, cst_mi_val_12,match_ind),
                                     cst_insert, DECODE (match_ind,NULL, cst_mi_val_11,match_ind))
              ,error_code = cst_ec_val_E701
              , error_text = l_error_text
       WHERE rowid = unitsets_rec.rowid;

       l_records_processed := l_records_processed + 1;
     ELSE
       BEGIN
         SAVEPOINT before_creatupdate;
           l_msg_at_index := igs_ge_msg_stack.count_msg;

           IF unitsets_rec.dmlmode = cst_insert THEN
             igs_ad_unit_sets_pkg.INSERT_ROW (
	       x_rowid => l_rowid,
	       x_unit_set_id => l_unit_set_id,
	       x_person_id => unitsets_rec.person_id,
	       x_admission_appl_number => unitsets_rec.admission_appl_number,
	       x_nominated_course_cd => unitsets_rec.nominated_course_cd,
	       x_sequence_number => unitsets_rec.sequence_number,
	       x_unit_set_cd => unitsets_rec.unit_set_cd,
	       x_version_number => unitsets_rec.version_number,
	       x_rank => unitsets_rec.rank,
	       x_mode =>  'R'
	     );
           ELSIF unitsets_rec.dmlmode = cst_update THEN
             OPEN   c_null_hdlg_unitsets_cur_rec(unitsets_rec);
             FETCH c_null_hdlg_unitsets_cur_rec INTO c_null_hdlg_unitsets_rec;
             CLOSE c_null_hdlg_unitsets_cur_rec;

             igs_ad_unit_sets_pkg.update_row(
                x_rowid => c_null_hdlg_unitsets_rec.rowid,
                x_unit_set_id => c_null_hdlg_unitsets_rec.unit_set_id,
                x_person_id => NVL(unitsets_rec.person_id,c_null_hdlg_unitsets_rec.person_id),
                x_admission_appl_number=> NVL(unitsets_rec.admission_appl_number,c_null_hdlg_unitsets_rec.admission_appl_number),
                x_nominated_course_cd => NVL(unitsets_rec.nominated_course_cd, c_null_hdlg_unitsets_rec.nominated_course_cd),
                x_sequence_number => NVL(unitsets_rec.sequence_number,c_null_hdlg_unitsets_rec.sequence_number),
                x_unit_set_cd => NVL(unitsets_rec.unit_set_cd,c_null_hdlg_unitsets_rec.unit_set_cd),
                x_version_number => NVL(unitsets_rec.version_number,c_null_hdlg_unitsets_rec.version_number),
                x_rank   => NVL(unitsets_rec.rank,c_null_hdlg_unitsets_rec.rank),
                x_mode =>'R');
           END IF;

           UPDATE igs_ad_unitsets_int
           SET
           status = cst_s_val_1
           , match_ind = DECODE (unitsets_rec.dmlmode,cst_update, cst_mi_val_18,cst_insert, cst_mi_val_11)
           WHERE rowid = unitsets_rec.rowid;

           l_records_processed := l_records_processed + 1;

           IF l_records_processed = 100 THEN
            COMMIT;
            l_records_processed := 0;
           END IF;

           EXCEPTION
             WHEN OTHERS THEN
               ROLLBACK TO before_creatupdate;
               l_msg_data := SQLERRM;

               IF unitsets_rec.dmlmode = cst_insert THEN
                 l_error_code := 'E322'; -- Insertion Failed
               ELSIF unitsets_rec.dmlmode = cst_update THEN
                 l_error_code := 'E014'; -- Update Failed
               END IF;

               igs_ad_gen_016.extract_msg_from_stack (p_msg_at_index                => l_msg_at_index,
                                                      p_return_status               => l_return_status,
                                                      p_msg_count                   => l_msg_count,
                                                      p_msg_data                    => l_msg_data,
                                                      p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
               l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

               IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                 IF p_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(unitsets_rec.interface_unitsets_id,l_msg_data,'IGS_AD_UNITSETS_INT');
                 END IF;
               ELSE
                 IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                   l_label := 'igs.plsql.igs_ad_imp_014.prc_apcnt_uset_apl.crt_upd_apcnt_uset_apl.for_loop.execption'||l_error_code;

                   fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
        	   fnd_message.set_token('INTERFACE_ID',unitsets_rec.interface_unitsets_id);
        	   fnd_message.set_token('ERROR_CD',l_error_code);

                   l_debug_str :=  fnd_message.get;
                   fnd_log.string_with_context( fnd_log.level_exception,
		                                l_label,
						l_debug_str, NULL,
						NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                 END IF;

               END IF;

               UPDATE igs_ad_unitsets_int
               SET    status = cst_s_val_3
                      , match_ind = DECODE ( unitsets_rec.dmlmode
                                             ,cst_update, DECODE ( match_ind, NULL, cst_mi_val_12, match_ind)
                                             ,cst_insert, DECODE ( p_rule
                                                                   ,cst_rule_val_R, DECODE ( match_ind, NULL, cst_mi_val_11, match_ind)
                                                                   ,cst_mi_val_11))
                      , error_code = l_error_code
                      , error_text = l_error_text
               WHERE rowid = unitsets_rec.rowid;
               l_records_processed := l_records_processed + 1;
           END;
         END IF;

       ELSE
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NOT_APC_STEP');
         FND_MESSAGE.SET_TOKEN ('CATEGORY', p_category_meaning);
         FND_MESSAGE.SET_TOKEN ('APPLTYPE', unitsets_rec.admission_application_type);
         l_error_text := FND_MESSAGE.GET;

         UPDATE igs_ad_unitsets_int
         SET    status = cst_s_val_3
                , match_ind = DECODE (unitsets_rec.dmlmode,  cst_update, DECODE (match_ind,NULL, cst_mi_val_12,match_ind),
                                                cst_insert, DECODE (match_ind,NULL, cst_mi_val_11,match_ind))
                , error_code = cst_ec_val_E701
                , error_text = l_error_text
         WHERE rowid = unitsets_rec.rowid;

         l_records_processed := l_records_processed + 1;
       END IF;

       IF l_records_processed = 100 THEN
         COMMIT;
         l_records_processed := 0;
       END IF;

     END LOOP;

     IF l_records_processed < 100 AND l_records_processed > 0 THEN
       COMMIT;
     END IF;

END crt_upd_apcnt_uset_apl; -- End of local procedure crt_upd_apcnt_uset_apl.

-- begin of main process prc_apcnt_uset_apl
BEGIN

  l_prog_label := 'igs.plsql.igs_ad_imp_014.prc_apcnt_uset_apl';
  l_label := 'igs.plsql.igs_ad_imp_014.prc_apcnt_uset_apl.';
  l_request_id := fnd_global.conc_request_id;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
    l_label := 'igs.plsql.igs_ad_imp_014.prc_apcnt_uset_apl.begin';
    l_debug_str :=  'igs_ad_imp_014.prc_apcnt_uset_apl';
    fnd_log.string_with_context( fnd_log.level_procedure,
                                 l_label,
			         l_debug_str, NULL,
			         NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  -- Set STATUS to 3 for interface records with RULE = E or I and MATCH IND
  IF p_rule IN ('E','I') THEN
    UPDATE igs_ad_unitsets_int
    SET    status = cst_s_val_3
           , error_code = cst_ec_val_E700
           , error_text = cst_et_val_E700
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND NVL (match_ind, cst_mi_val_15) <> cst_mi_val_15;
    COMMIT;
  END IF;

  -- Set STATUS to 1 for interface records with RULE = R and
  -- MATCH IND = 17,18,19,22,23,24,27
  IF p_rule IN ('R') THEN
    UPDATE igs_ad_unitsets_int
    SET    status = cst_s_val_1
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND match_ind IN (cst_mi_val_17, cst_mi_val_18, cst_mi_val_19,
                      cst_mi_val_22, cst_mi_val_23, cst_mi_val_24, cst_mi_val_27);
    COMMIT;
  END IF;

  -- Set STATUS to 1 and MATCH IND to 19 for interface records with RULE =
  -- E matching OSS record(s)
  IF p_rule IN ('E') THEN
    UPDATE igs_ad_unitsets_int in_rec
    SET    status = cst_s_val_1
           , match_ind = cst_mi_val_19
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND EXISTS ( SELECT 1
                 FROM igs_ad_unit_sets mn_rec
                 WHERE mn_rec.person_id = in_rec.person_id
                 AND   mn_rec.sequence_number = in_rec.sequence_number
                 AND   mn_rec.unit_set_cd = in_rec.unit_set_cd
                 AND   mn_rec.version_number = in_rec.version_number
                 AND   mn_rec.admission_appl_number = in_rec.admission_appl_number
                 AND   mn_rec.nominated_course_cd = in_rec.nominated_course_cd);
    COMMIT;
  END IF;

  -- Create / Update the OSS record after validating successfully the interface record
  -- Create
  -- If RULE E/I/R (match indicator will be 15 or NULL by now no need to check) and
  -- matching system record not found OR RULE = R and MATCH IND = 16, 25
  -- Update
  -- If RULE = I (match indicator will be 15 or NULL by now no need to check) OR
  -- RULE = R and MATCH IND = 21

  -- Selecting together the interface records for INSERT / UPDATE with DMLMODE identifying
  -- the DML operation. This is done to have one code section for record validation, exception
  -- handling and interface table update. This avoids call to separate PLSQL blocks, tuning
  -- performance on stack maintenance during the process.

  crt_upd_apcnt_uset_apl(p_interface_run_id);

  -- Set STATUS to 1 and MATCH IND to 23 for interface records with RULE = R matching
  -- OSS record(s) in ALL updateable column values, if column nullification is not
  -- allowed then the 2 DECODE should be replaced by a single NVL
  IF p_rule IN ('R') THEN
    UPDATE igs_ad_unitsets_int in_rec
    SET    status = cst_s_val_1
           , match_ind = cst_mi_val_23
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND NVL (match_ind, cst_mi_val_15) = cst_mi_val_15
    AND EXISTS ( SELECT 1
                 FROM igs_ad_unit_sets mn_rec
                 WHERE NVL(mn_rec.person_id, -99)            = NVL(in_rec.person_id,NVL(mn_rec.person_id, -99) )
                 AND  NVL(mn_rec.admission_appl_number, -99) = NVL(in_rec.admission_appl_number,NVL(mn_rec.admission_appl_number, -99) )
                 AND  NVL(mn_rec.nominated_course_cd,'~')    = NVL(in_rec.nominated_course_cd, NVL(mn_rec.nominated_course_cd,'~') )
                 AND  NVL(mn_rec.sequence_number, -99)       = NVL(in_rec.sequence_number, NVL(mn_rec.sequence_number, -99))
                 AND  NVL(mn_rec.unit_set_cd, '~')           = NVL(in_rec.unit_set_cd,  NVL(mn_rec.unit_set_cd, '~'))
                 AND  NVL(mn_rec.version_number, -99)        = NVL(in_rec.version_number,NVL(mn_rec.version_number, -99) )
                 AND  NVL(mn_rec.rank, -99)                  = NVL(in_rec.rank, NVL(mn_rec.rank, -99))
                );
    COMMIT;
  END IF;

  -- Set STATUS to 3 and MATCH IND = 20 for interface records with RULE = R and MATCH IND
  -- <> 21, 25, ones failed discrepancy check
  IF p_rule IN ('R') THEN
    UPDATE igs_ad_unitsets_int in_rec
    SET
    status = cst_s_val_3
    , match_ind = cst_mi_val_20
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND NVL (match_ind, cst_mi_val_15) = cst_mi_val_15
    AND EXISTS ( SELECT rowid
                 FROM igs_ad_unit_sets mn_rec
                 WHERE mn_rec.person_id = in_rec.person_id
                 AND   mn_rec.sequence_number = in_rec.sequence_number
                 AND   mn_rec.unit_set_cd = in_rec.unit_set_cd
                 AND   mn_rec.version_number = in_rec.version_number
                 AND   mn_rec.admission_appl_number = in_rec.admission_appl_number
                 AND   mn_rec.nominated_course_cd = in_rec.nominated_course_cd);
    COMMIT;
  END IF;

  -- Set STATUS to 3 for interface records with RULE = R and invalid MATCH IND
  IF p_rule IN ('R') THEN
    UPDATE igs_ad_unitsets_int
    SET    status = cst_s_val_3
           , error_code = cst_ec_val_E700
           , error_text = cst_et_val_E700
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND match_ind IS NOT NULL;
    COMMIT;
  END IF;

END prc_apcnt_uset_apl;

END Igs_Ad_Imp_010;

/
