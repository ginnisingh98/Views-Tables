--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_028
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_028" AS
/* $Header: IGSADC8B.pls 115.8 2003/12/09 13:32:42 pbondugu noship $ */

/*************************************
|| Change History
||  who           when			what
||  pbondugu   22-Apr-2003        Admissions Legacy Import to import person legacy data
*/

/***************************Status,Discrepancy Rule, Match Indicators, Error Codes********************/
	cst_rule_val_I  CONSTANT VARCHAR2(1) := 'I';
	cst_rule_val_E CONSTANT VARCHAR2(1) := 'E';
	cst_rule_val_R CONSTANT VARCHAR2(1) := 'R';


	cst_mi_val_11 CONSTANT  VARCHAR2(2) := '11';
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

	cst_s_val_1  CONSTANT   VARCHAR2(1) := '1';
        cst_s_val_2  CONSTANT VARCHAR2(1) := '2';
	cst_s_val_3  CONSTANT VARCHAR2(1) := '3';
	cst_s_val_4  CONSTANT VARCHAR2(1) := '4';

       cst_ec_val_E322 CONSTANT VARCHAR2(4) := 'E322';
       cst_ec_val_E014 CONSTANT VARCHAR2(4) := 'E014';
       cst_ec_val_NULL CONSTANT VARCHAR2(4)  := NULL;

       cst_insert  CONSTANT VARCHAR2(6) :=  'INSERT';
       cst_update CONSTANT VARCHAR2(6) :=  'UPDATE';
       cst_unique_record  CONSTANT  NUMBER :=  1;
       l_request_id   NUMBER :=  fnd_global.conc_request_id;
/***************************Status,Discrepancy Rule, Match Indicators, Error Codes*******************/

PROCEDURE prc_pe_qual_details (
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2)  AS

/*************************************
||   Created By :Praveen Bondugula
||  Date Created By :24-apr-2003
||  Purpose : To import Qualification details
|| Know limitations, enhancements or remarks
||  Change History
||  Who             When            What
||
*/

  l_rowid VARCHAR2(20);
  l_qual_dets_id  igs_uc_qual_dets.qual_dets_id%TYPE;
  l_status           VARCHAR2(1);
  l_error_code       VARCHAR2(30);
  l_error_text       VARCHAR2(2000);
  l_interface_qual_id  igs_uc_qual_ints.interface_qual_id%TYPE;
  l_person_id   igs_ad_interface_all.person_id%TYPE;
  l_person_id_errored igs_ad_interface_all.person_id%TYPE;

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);

  l_msg_at_index   NUMBER := 0;
  l_return_status   VARCHAR2(1);
  l_msg_count      NUMBER ;
  l_msg_data       VARCHAR2(2000);
  l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;

BEGIN
 l_prog_label := 'igs.plsql.igs_ad_imp_028.prc_pe_qual_details';

 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
  l_label := 'igs.plsql.igs_ad_imp_028.prc_pe_qual_details.begin';
  l_debug_str :=  'igs_ad_imp_028.prc_pe_qual_details.start';

  fnd_log.string_with_context( fnd_log.level_procedure,
  			       l_label,
			       l_debug_str, NULL,
			       NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
 END IF;
-- Error out all the interface records, if the corrospending person already having qualification details
--- in ths OSS transaction table.
 UPDATE IGS_UC_QUAL_INTS  qints
 SET error_code = 'E683'
        ,error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E683', 8405)
        , status ='3'
 WHERE STATUS = '2'
 AND interface_run_id = p_interface_run_id
 AND  EXISTS ( SELECT 1  FROM IGS_UC_QUAL_DETS
                 WHERE  person_id = qints.person_id);

COMMIT;
-- Check for duplicates among interface records. If exists error out all the such records.
 UPDATE IGS_UC_QUAL_INTS  qints
 SET error_code = 'E684'
        ,error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E684', 8405)
        , status ='3'
 WHERE STATUS = '2'
 AND interface_run_id = p_interface_run_id
 AND EXISTS (SELECT 1 FROM IGS_UC_QUAL_INTS  qints2
              WHERE   qints2.person_id = qints.person_id
	  AND qints2.exam_level = qints.exam_level
	  AND NVL(qints2.subject_code, '-1')  = NVL(qints.subject_code, '-1')
          AND NVL(qints2.awarding_body,'-1') =  NVL(qints.awarding_body,'-1')
          AND NVL(qints2.year,1700)  = NVL(qints.year,1700)
          AND NVL(qints2.sitting,'-1') = NVL(qints.sitting,'-1')
          AND NVL( qints2.approved_result,'-1') = NVL( qints.approved_result,'-1')
          AND    qints2.rowid <> qints.rowid
          AND    qints2.interface_run_id = p_interface_run_id
         AND    qints2.status ='2' );
COMMIT;
-- Error out all interface records if the any interface  record with same person_id is errored out.
 UPDATE IGS_UC_QUAL_INTS  qints
 SET error_code = 'E684'
        ,error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E684', 8405)
        , status ='3'
 WHERE STATUS = '2'
 AND interface_run_id = p_interface_run_id
 AND EXISTS (SELECT 1 FROM IGS_UC_QUAL_INTS  qints2
       WHERE STATUS = '3'
       AND    qints2.person_id = qints.person_id
        AND    qints2.interface_run_id = p_interface_run_id) ;


COMMIT;
l_person_id := NULL;
l_person_id_errored := NULL;
FOR uc_qual_rec IN IGS_AD_IMP_028.c_uc_qual_cur(p_interface_run_id )
LOOP
    IF uc_qual_rec.person_id <> NVL(l_person_id, uc_qual_rec.person_id) THEN
       COMMIT;
   END IF;
    l_person_id := uc_qual_rec.person_id;
-- Skipping the record because the record with same person ID ha failed.
    IF uc_qual_rec.person_id <>  NVL(l_person_id_errored, -99)  THEN

        DECLARE
             invalid_record    exception;
        BEGIN
          l_error_Code := NULL;
          l_error_text := NULL;
          igs_uc_qual_dets_imp_pkg.validate_pe_qual(uc_qual_rec,l_Status,l_error_Code);
          IF(l_Status ='3' ) THEN
              RAISE invalid_record;
          END IF;
          l_msg_at_index := igs_ge_msg_stack.count_msg;
           igs_uc_qual_dets_pkg.insert_row(
		x_rowid                => l_rowid,
		 x_qual_dets_id    => l_qual_dets_id,
		x_person_id            => uc_qual_rec.person_id,
		x_exam_level       => uc_qual_rec.exam_level,
		x_subject_code      => uc_qual_rec.subject_code,
		x_year                 => uc_qual_rec.year,
		x_sitting              => uc_qual_rec.sitting,
		x_awarding_body        => uc_qual_rec.awarding_body,
		x_grading_schema_cd    => uc_qual_rec.grading_schema_cd,
		x_version_number       => uc_qual_rec.version_number,
		x_predicted_result     => uc_qual_rec.predicted_result,
		x_approved_result      => uc_qual_rec.approved_result,
		x_claimed_result       => uc_qual_rec.claimed_result,
		x_ucas_tariff          => uc_qual_rec.ucas_tariff,
		x_imported_flag        => uc_qual_rec.imported_flag,
		x_imported_date        => TRUNC(uc_qual_rec.imported_date),
		x_mode                 => 'R');
                UPDATE igs_uc_qual_ints
		SET status = cst_s_val_1,
                       error_code = cst_ec_val_NULL
		WHERE   interface_qual_id = uc_qual_rec.interface_qual_id;
                -- If the all qulaificaton records with same person_id are processed , then commit;
                --If person_id changes from previous one then it means that records with previous person_id are processed

        EXCEPTION
            WHEN invalid_record THEN
               ROLLBACK;
               l_person_id_errored := uc_qual_rec.person_id ;
               UPDATE igs_uc_qual_ints
 		SET status = cst_s_val_3,
                       error_code = l_error_code,
                      error_text = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405)
                WHERE  interface_qual_id = uc_qual_rec.interface_qual_id;

               IF p_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(uc_qual_rec.interface_qual_id,l_error_code,'IGS_UC_QUAL_INTS');
               END IF;
               l_error_code := 'E685';
              UPDATE igs_uc_qual_ints
		SET status = cst_s_val_3
                       , error_code = l_error_code
                       , error_text = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405)
               WHERE  person_id = uc_qual_rec.person_id
               AND status  = cst_s_val_2
               AND interface_qual_id <> uc_qual_rec.interface_qual_id;


           WHEN OTHERS THEN
                ROLLBACK;
                igs_ad_gen_016.extract_msg_from_stack (
                          p_msg_at_index                => l_msg_at_index,
                          p_return_status               => l_return_status,
                          p_msg_count                   => l_msg_count,
                          p_msg_data                    => l_msg_data,
                          p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
               IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                   l_error_text := l_msg_data;
                   l_error_Code := 'E322';

                   IF p_enable_log = 'Y' THEN
                       igs_ad_imp_001.logerrormessage(uc_qual_rec.interface_qual_id,l_msg_data,'IGS_UC_QUAL_INTS');
                   END IF;
               ELSE
                    l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405);
                    l_error_Code := 'E518';
                    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		          l_label := 'igs.plsql.igs_ad_imp_028.prc_uc_qual_dtls.exception '||l_msg_data;

			  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			  fnd_message.set_token('INTERFACE_ID',uc_qual_rec.interface_qual_id);
			  fnd_message.set_token('ERROR_CD','E322');

		          l_debug_str :=  fnd_message.get;

                         fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                      END IF;

               END IF;


              l_person_id_errored := uc_qual_rec.person_id ;
               UPDATE igs_uc_qual_ints
 		SET status = cst_s_val_3,  error_code = l_error_code, error_text = l_error_text
                WHERE  interface_qual_id = uc_qual_rec.interface_qual_id;

               l_error_code := 'E685';
              UPDATE igs_uc_qual_ints
		SET status = cst_s_val_3,
                       error_code = l_error_code,
                       error_text  =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405)
               WHERE  person_id = uc_qual_rec.person_id
               AND status  =cst_s_val_2
               AND interface_qual_id <> uc_qual_rec.interface_qual_id;

        END;
    END IF;
END LOOP;
COMMIT;
END prc_pe_qual_details;

END Igs_Ad_Imp_028;

/
