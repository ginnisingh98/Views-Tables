--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_014
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_014" AS
/* $Header: IGSAD92B.pls 115.23 2003/12/09 11:57:21 akadam ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The procedure declaration of PRC_RELNS_EMP_DTLS removed
  -------------------------------------------------------------------------------------------


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

cst_et_val_E700 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405);

cst_ec_val_E700 VARCHAR2(4) := 'E700';

/***************************Status,Discrepancy Rule, Match Indicators, Error Codes********************/




PROCEDURE prc_pe_recruitments_dtl(
                        p_interface_run_id  IN NUMBER,
                        p_enable_log        IN VARCHAR2,
                        p_rule              IN VARCHAR2 )
AS
  /*
  ||  Created By : Rammohan.Gangarapollu@Oracle.com
  ||  Created On : 06-Jul-2001
  ||  Purpose : This procedure is for importing person recruitment details.
  ||            DLD: Modelling and Forecasting_SDQ.  Enh Bug# 1834307.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || npalanis        11-SEP-2002     bug - 2608360
  ||                                 igs_pe_code_classes is
  ||                                  removed due to transition of code
  ||                                 class to lookups , new columns added
  ||                                 for codes. the  tbh call are  modified accordingly .
  || pkpatel        24-JUL-2001     Bug no.1890270 Admissions Standards and Rules Dld_adsr_setup
  ||                                Removed the processing for 'probability' in the call to TBH igs_ad_recruitments_pkg.insert_row, update_row
  ||                                and in the cursor for discrepancy check
  ||  (reverse chronological order - newest change first)
  */

    l_prog_label  VARCHAR2(100);
    l_label  VARCHAR2(100);
    l_debug_str VARCHAR2(2000);
    l_request_id NUMBER;
    l_error_code  igs_ad_recruit_int.error_code%TYPE;




PROCEDURE crt_upd_recruitments_dtls(
  p_interface_run_id NUMBER)
AS
    CURSOR c_igs_ad_recruit_int IS
    SELECT  cst_insert dmlmode, rowid, in_rec.* FROM igs_ad_recruit_int in_rec
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND (  ( NVL(match_ind,'15') = '15'
    AND NOT EXISTS (SELECT 1
                         FROM igs_ad_recruitments mn_rec
                         WHERE mn_rec.person_id = in_rec.person_id))
    OR (          p_rule = cst_rule_val_R
    AND match_ind IN (cst_mi_val_16, cst_mi_val_25)))
    UNION ALL
    SELECT  cst_update dmlmode, rowid, in_rec.* FROM igs_ad_recruit_int in_rec
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND (       (p_rule = cst_rule_val_I)
    OR (p_rule = cst_rule_val_R AND match_ind = cst_mi_val_21))
    AND EXISTS (  SELECT 1
                           FROM igs_ad_recruitments mn_rec
                           WHERE mn_rec.person_id = in_rec.person_id);


   CURSOR c_null_hdlg_recru_cur(cp_person_id igs_ad_recruitments.person_id%TYPE) IS
   SELECT ROWID, ar.*
   FROM   igs_ad_recruitments ar
   WHERE  person_id  = cp_person_id;

   c_null_hdlg_recru_rec c_null_hdlg_recru_cur%ROWTYPE;

   l_status           VARCHAR2(1);
   l_error_code       VARCHAR2(30);
   l_error_text    igs_ad_recruit_int.error_text%TYPE;
   l_msg_at_index   NUMBER := 0;
   l_return_status   VARCHAR2(1);
   l_msg_count      NUMBER ;
   l_msg_data       VARCHAR2(2000);
   l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;

   l_records_processed  NUMBER;
   l_recruitments_ID    igs_ad_recruitments.recruitment_id%TYPE;
   l_rowid VARCHAR2(30);

BEGIN

 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN


  l_label := 'igs.plsql.igs_ad_imp_014.prc_pe_recruitments_dtl.crt_upd_recruitments_dtls';
  l_debug_str :=  'Interface Run ID' || p_interface_run_id;

  fnd_log.string_with_context( fnd_log.level_procedure,
  			       l_label,
			       l_debug_str, NULL,
			       NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
 END IF;

 l_records_processed := 0;

 FOR recruit_rec IN c_igs_ad_recruit_int
 LOOP
   BEGIN

     SAVEPOINT before_creatupdate;
     l_msg_at_index := igs_ge_msg_stack.count_msg;

     IF recruit_rec.dmlmode = cst_insert THEN
     igs_ad_recruitments_pkg.INSERT_ROW (
      X_ROWID                      =>  l_rowid,
      x_CERTAINTY_OF_CHOICE_ID     =>  recruit_rec.CERTAINTY_OF_CHOICE_ID,
      x_religion_cd                =>  recruit_rec.religion_cd,
      x_ADV_STUDIES_CLASSES        =>  recruit_rec.ADV_STUDIES_CLASSES,
      x_HONORS_CLASSES             =>  recruit_rec.HONORS_CLASSES,
      x_CLASS_SIZE                 =>  recruit_rec.CLASS_SIZE,
      x_SEC_SCHOOL_LOCATION_ID     =>  recruit_rec.SEC_SCHOOL_LOCATION_ID,
      x_PERCENT_PLAN_HIGHER_EDU    =>  recruit_rec.PERCENT_PLAN_HIGHER_EDU,
      x_RECRUITMENT_ID             =>  l_recruitments_ID,
      x_PERSON_ID                  =>  recruit_rec.PERSON_ID,
      x_SPECIAL_INTEREST_ID        =>  recruit_rec.SPECIAL_INTEREST_ID,
      x_PRIORITY                   =>  recruit_rec.PRIORITY,
      x_VIP                        =>  recruit_rec.VIP,
      x_DEACTIVATE_RECRUIT_STATUS  =>  recruit_rec.DEACTIVATE_RECRUIT_STATUS,
      x_PROGRAM_INTEREST_ID        =>  recruit_rec.PROGRAM_INTEREST_ID,
      x_INSTITUTION_SIZE_ID        =>  recruit_rec.INSTITUTION_SIZE_ID,
      x_INSTITUTION_CONTROL_ID     =>  recruit_rec.INSTITUTION_CONTROL_ID,
      x_INSTITUTION_SETTING_ID     =>  recruit_rec.INSTITUTION_SETTING_ID,
      x_INSTITUTION_LOCATION_ID    =>  recruit_rec.INSTITUTION_LOCATION_ID,
      x_SPECIAL_SERVICES_ID        =>  recruit_rec.SPECIAL_SERVICES_ID,
      x_EMPLOYMENT_ID              =>  recruit_rec.EMPLOYMENT_ID,
      x_HOUSING_ID                 =>  recruit_rec.HOUSING_ID,
      x_DEGREE_GOAL_ID             =>  recruit_rec.DEGREE_GOAL_ID,
      x_UNIT_SET_ID                =>  recruit_rec.UNIT_SET_ID,
      X_MODE                       => 'R'
     );

     ELSIF recruit_rec.dmlmode = cst_update THEN

     OPEN   c_null_hdlg_recru_cur(recruit_rec.person_id);
     FETCH c_null_hdlg_recru_cur INTO c_null_hdlg_recru_rec;
     CLOSE c_null_hdlg_recru_cur;

     igs_ad_recruitments_pkg.UPDATE_ROW(
       x_rowid                     =>  c_null_hdlg_recru_rec.rowid,
       x_CERTAINTY_OF_CHOICE_ID    =>  NVL(recruit_rec.CERTAINTY_OF_CHOICE_ID, c_null_hdlg_recru_rec.CERTAINTY_OF_CHOICE_ID),
       x_religion_cd               =>  NVL(recruit_rec.religion_cd, c_null_hdlg_recru_rec.religion_cd),
       x_ADV_STUDIES_CLASSES       =>  NVL(recruit_rec.ADV_STUDIES_CLASSES, c_null_hdlg_recru_rec.ADV_STUDIES_CLASSES),
       x_HONORS_CLASSES            =>  NVL(recruit_rec.HONORS_CLASSES, c_null_hdlg_recru_rec.HONORS_CLASSES),
       x_CLASS_SIZE                =>  NVL(recruit_rec.CLASS_SIZE, c_null_hdlg_recru_rec.CLASS_SIZE),
       x_SEC_SCHOOL_LOCATION_ID    =>  NVL(recruit_rec.SEC_SCHOOL_LOCATION_ID, c_null_hdlg_recru_rec.SEC_SCHOOL_LOCATION_ID),
       x_PERCENT_PLAN_HIGHER_EDU   =>  NVL(recruit_rec.PERCENT_PLAN_HIGHER_EDU, c_null_hdlg_recru_rec.PERCENT_PLAN_HIGHER_EDU),
       x_RECRUITMENT_ID            =>  c_null_hdlg_recru_rec.recruitment_ID,
       x_PERSON_ID                 =>  NVL(recruit_rec.PERSON_ID,c_null_hdlg_recru_rec.PERSON_ID),
       x_SPECIAL_INTEREST_ID       =>  NVL(recruit_rec.SPECIAL_INTEREST_ID, c_null_hdlg_recru_rec.SPECIAL_INTEREST_ID),
       x_PRIORITY                  =>  NVL(recruit_rec.PRIORITY, c_null_hdlg_recru_rec.PRIORITY),
       x_VIP                       =>  NVL(recruit_rec.VIP, c_null_hdlg_recru_rec.VIP),
       x_DEACTIVATE_RECRUIT_STATUS =>  NVL(recruit_rec.DEACTIVATE_RECRUIT_STATUS, c_null_hdlg_recru_rec.DEACTIVATE_RECRUIT_STATUS),
       x_PROGRAM_INTEREST_ID       =>  NVL(recruit_rec.PROGRAM_INTEREST_ID, c_null_hdlg_recru_rec.PROGRAM_INTEREST_ID),
       x_INSTITUTION_SIZE_ID       =>  NVL(recruit_rec.INSTITUTION_SIZE_ID, c_null_hdlg_recru_rec.INSTITUTION_SIZE_ID),
       x_INSTITUTION_CONTROL_ID    =>  NVL(recruit_rec.INSTITUTION_CONTROL_ID, c_null_hdlg_recru_rec.INSTITUTION_CONTROL_ID),
       x_INSTITUTION_SETTING_ID    =>  NVL(recruit_rec.INSTITUTION_SETTING_ID, c_null_hdlg_recru_rec.INSTITUTION_SETTING_ID),
       x_INSTITUTION_LOCATION_ID   =>  NVL(recruit_rec.INSTITUTION_LOCATION_ID, c_null_hdlg_recru_rec.INSTITUTION_LOCATION_ID),
       x_SPECIAL_SERVICES_ID       =>  NVL(recruit_rec.SPECIAL_SERVICES_ID, c_null_hdlg_recru_rec.SPECIAL_SERVICES_ID),
       x_EMPLOYMENT_ID             =>  NVL(recruit_rec.EMPLOYMENT_ID, c_null_hdlg_recru_rec.EMPLOYMENT_ID),
       x_HOUSING_ID                =>  NVL(recruit_rec.HOUSING_ID, c_null_hdlg_recru_rec.HOUSING_ID),
       x_DEGREE_GOAL_ID            =>  NVL(recruit_rec.DEGREE_GOAL_ID, c_null_hdlg_recru_rec.DEGREE_GOAL_ID),
       x_UNIT_SET_ID               =>  NVL(recruit_rec.UNIT_SET_ID, c_null_hdlg_recru_rec.UNIT_SET_ID),
       x_mode                      =>'R'
      );
     END IF;

     UPDATE igs_ad_recruit_int
     SET
     status = cst_s_val_1
     , match_ind = DECODE (recruit_rec.dmlmode,cst_update, cst_mi_val_18,cst_insert, cst_mi_val_11)
     WHERE rowid = recruit_rec.rowid;

     l_records_processed := l_records_processed + 1;

     IF l_records_processed = 100 THEN
      COMMIT;
      l_records_processed := 0;
     END IF;

   EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK TO before_creatupdate;

      l_msg_data := SQLERRM;
      l_status := '3';

      IF recruit_rec.dmlmode = cst_insert THEN
        l_error_code := 'E322'; -- Person Recruitment Insertion Failed
      ELSIF recruit_rec.dmlmode = cst_update THEN
        l_error_code := 'E014'; -- Could not update Person Recruitment
      END IF;

      igs_ad_gen_016.extract_msg_from_stack (
                  p_msg_at_index                => l_msg_at_index,
                  p_return_status               => l_return_status,
                  p_msg_count                   => l_msg_count,
                  p_msg_data                    => l_msg_data,
                  p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

       l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

       IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
           IF p_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(recruit_rec.interface_recruitment_id,l_msg_data,'IGS_AD_RECRUIT_INT');
           END IF;
       ELSE
         IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

          l_label := 'igs.plsql.igs_ad_imp_014.prc_pe_recruitments_dtl.crt_upd_recruitments_dtls.for_loop.execption'||l_error_code;

          fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
	  fnd_message.set_token('INTERFACE_ID',recruit_rec.interface_recruitment_id);
	  fnd_message.set_token('ERROR_CD',l_error_code);

          l_debug_str :=  fnd_message.get;
          fnd_log.string_with_context( fnd_log.level_exception,
						  l_label,
						  l_debug_str, NULL,
						  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        END IF;


      UPDATE igs_ad_recruit_int
      SET
      status = cst_s_val_3
      , match_ind = DECODE ( recruit_rec.dmlmode, cst_update, DECODE ( match_ind, NULL, cst_mi_val_12, match_ind)
                                      ,cst_insert, DECODE ( p_rule, cst_rule_val_R,
                                                            DECODE ( match_ind, NULL, cst_mi_val_11, match_ind), cst_mi_val_11))
      , error_code = l_error_code
      , error_text = l_error_text
      WHERE rowid = recruit_rec.rowid;
      l_records_processed := l_records_processed + 1;


    END;
     IF l_records_processed = 100 THEN
      COMMIT;
      l_records_processed := 0;
     END IF;

 END LOOP;
     IF l_records_processed < 100 AND l_records_processed > 0 THEN
      COMMIT;
     END IF;


END crt_upd_recruitments_dtls; -- End of local procedure crt_upd_recruitments_dtls.

-- begin of main process prc_pe_recruitments_dtl
BEGIN

 l_prog_label := 'igs.plsql.igs_ad_imp_014.prc_pe_recruitments_dtl';
 l_label := 'igs.plsql.igs_ad_imp_014.prc_pe_recruitments_dtl.';
 l_request_id := fnd_global.conc_request_id;

 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN


  l_label := 'igs.plsql.igs_ad_imp_014.prc_pe_recruitments_dtl.begin';
  l_debug_str :=  'igs_ad_imp_014.prc_pe_recruitments_dtl';

  fnd_log.string_with_context( fnd_log.level_procedure,
  			       l_label,
			       l_debug_str, NULL,
			       NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
 END IF;

   -- Set STATUS to 3 for interface records with RULE = E or I and MATCH IND
  IF p_rule IN ('E','I') THEN
     UPDATE igs_ad_recruit_int
     SET
     status = cst_s_val_3
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
     UPDATE igs_ad_recruit_int
     SET
     status = cst_s_val_1
     WHERE interface_run_id = p_interface_run_id
     AND status = cst_s_val_2
     AND match_ind IN (cst_mi_val_17, cst_mi_val_18, cst_mi_val_19,
                       cst_mi_val_22, cst_mi_val_23, cst_mi_val_24, cst_mi_val_27);
     COMMIT;
  END IF;

  -- Set STATUS to 1 and MATCH IND to 19 for interface records with RULE =
  -- E matching OSS record(s)
  IF p_rule IN ('E') THEN
     UPDATE igs_ad_recruit_int in_rec
     SET
     status = cst_s_val_1
     , match_ind = cst_mi_val_19
     WHERE interface_run_id = p_interface_run_id
     AND status = cst_s_val_2
     AND     EXISTS ( SELECT 1
                           FROM igs_ad_recruitments mn_rec
                           WHERE mn_rec.person_id = in_rec.person_id);
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

  crt_upd_recruitments_dtls(p_interface_run_id);

  -- Set STATUS to 1 and MATCH IND to 23 for interface records with RULE = R matching
  -- OSS record(s) in ALL updateable column values, if column nullification is not
  -- allowed then the 2 DECODE should be replaced by a single NVL
  IF p_rule IN ('R') THEN
     UPDATE igs_ad_recruit_int in_rec
     SET
     status = cst_s_val_1
     , match_ind = cst_mi_val_23
     WHERE interface_run_id = p_interface_run_id
     AND status = cst_s_val_2
     AND NVL (match_ind, cst_mi_val_15) = cst_mi_val_15
     AND EXISTS (
       SELECT 1
          FROM igs_ad_recruitments mn_rec
          WHERE NVL(mn_rec.adv_studies_classes, -99)     = NVL(in_rec.adv_studies_classes,NVL(mn_rec.adv_studies_classes, -99) )
          AND  NVL(mn_rec.certainty_of_choice_id, -99)   = NVL(in_rec.certainty_of_choice_id, NVL(mn_rec.certainty_of_choice_id, -99))
          AND  NVL(mn_rec.class_size, -99)               = NVL(in_rec.class_size,NVL(mn_rec.class_size, -99) )
          AND  NVL(mn_rec.deactivate_recruit_status,'~') = NVL(in_rec.deactivate_recruit_status, NVL(mn_rec.deactivate_recruit_status,'~') )
          AND  NVL(mn_rec.degree_goal_id, -99)           = NVL(in_rec.degree_goal_id, NVL(mn_rec.degree_goal_id, -99))
          AND  NVL(mn_rec.employment_id, -99)            = NVL(in_rec.employment_id,  NVL(mn_rec.employment_id, -99))
          AND  NVL(mn_rec.honors_classes, -99)           = NVL(in_rec.honors_classes,NVL(mn_rec.honors_classes, -99) )
          AND  NVL(mn_rec.housing_id, -99)               = NVL(in_rec.housing_id, NVL(mn_rec.housing_id, -99))
          AND  NVL(mn_rec.institution_control_id, -99)   = NVL(in_rec.institution_control_id, NVL(mn_rec.institution_control_id, -99))
          AND  NVL(mn_rec.institution_location_id, -99)  = NVL(in_rec.institution_location_id, NVL(mn_rec.institution_location_id, -99))
          AND  NVL(mn_rec.institution_setting_id, -99)   = NVL(in_rec.institution_setting_id,NVL(mn_rec.institution_setting_id, -99) )
          AND  NVL(mn_rec.institution_size_id, -99)      = NVL(in_rec.institution_size_id, NVL(mn_rec.institution_size_id, -99))
          AND  NVL(mn_rec.percent_plan_higher_edu, -99)  = NVL(in_rec.percent_plan_higher_edu, NVL(mn_rec.percent_plan_higher_edu, -99))
          AND  NVL(mn_rec.person_id, -99)                = NVL(in_rec.person_id,NVL(mn_rec.person_id, -99) )
          AND  NVL(mn_rec.priority,'~')                  = NVL(in_rec.priority,NVL(mn_rec.priority,'~'))
          AND  NVL(mn_rec.program_interest_id, -99)      = NVL(in_rec.program_interest_id,NVL(mn_rec.program_interest_id,-99))
          AND  NVL(mn_rec.religion_cd, -99)              = NVL(in_rec.religion_cd, NVL(mn_rec.religion_cd, -99))
          AND  NVL(mn_rec.sec_school_location_id, -99)   = NVL(in_rec.sec_school_location_id,NVL(mn_rec.sec_school_location_id, -99) )
          AND  NVL(mn_rec.special_interest_id, -99)      = NVL(in_rec.special_interest_id,NVL(mn_rec.special_interest_id, -99) )
          AND  NVL(mn_rec.special_services_id, -99)      = NVL(in_rec.special_services_id,NVL(mn_rec.special_services_id, -99) )
          AND  NVL(mn_rec.unit_set_id, -99)              = NVL(in_rec.unit_set_id, NVL(mn_rec.unit_set_id, -99))
          AND  NVL(mn_rec.vip,'~')                       = NVL(in_rec.vip, NVL(mn_rec.vip,'~'))
         );
     COMMIT;
  END IF;

  -- Set STATUS to 3 and MATCH IND = 20 for interface records with RULE = R and MATCH IND
  -- <> 21, 25, ones failed discrepancy check
  IF p_rule IN ('R') THEN
     UPDATE igs_ad_recruit_int in_rec
     SET
     status = cst_s_val_3
     , match_ind = cst_mi_val_20
     , dup_recruitment_id = ( SELECT recruitment_id FROM igs_ad_recruitments mn_rec
                              WHERE mn_rec.person_id = in_rec.person_id)
     WHERE interface_run_id = p_interface_run_id
     AND status = cst_s_val_2
     AND NVL (match_ind, cst_mi_val_15) = cst_mi_val_15
     AND EXISTS (  SELECT rowid FROM igs_ad_recruitments mn_rec
                              WHERE mn_rec.person_id = in_rec.person_id);
     COMMIT;
  END IF;

  -- Set STATUS to 3 for interface records with RULE = R and invalid MATCH IND
  IF p_rule IN ('R') THEN
     UPDATE igs_ad_recruit_int
     SET
     status = cst_s_val_3
     , error_code = cst_ec_val_E700
     , error_text = cst_et_val_E700
     WHERE interface_run_id = p_interface_run_id
     AND status = cst_s_val_2
     AND match_ind IS NOT NULL;
     COMMIT;
  END IF;


END prc_pe_recruitments_dtl;

END Igs_Ad_Imp_014;

/
