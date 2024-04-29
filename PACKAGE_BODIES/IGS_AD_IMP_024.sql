--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_024
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_024" AS
/* $Header: IGSADB2B.pls 120.4 2006/04/13 05:53:45 stammine ship $ */
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

 PROCEDURE process_term_details(
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2)  ;

PROCEDURE process_term_unit_details(
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2) ;

 PROCEDURE prc_trscrpt(
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2)  AS

   l_status           VARCHAR2(5);
   l_industry         VARCHAR2(5);
   l_schema           VARCHAR2(30);
    l_return           BOOLEAN;

   l_msg_at_index   NUMBER := 0;
   l_return_status   VARCHAR2(1);
   l_msg_count      NUMBER ;
   l_msg_data       VARCHAR2(2000);
   l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;


CURSOR trans_cur(cp_start_int_id  igs_ad_txcpt_int.interface_transcript_id%TYPE,	--ARVSRINI--
		 cp_end_int_id	  igs_ad_txcpt_int.interface_transcript_id%TYPE) IS	--ARVSRINI--
     SELECT  cst_insert dmlmode, trans.rowid,  trans.*
     FROM igs_ad_txcpt_int  trans
     WHERE interface_run_id = p_interface_run_id
     AND  trans.status = '2'
     AND (          NOT EXISTS (SELECT 1
                                            FROM IGS_AD_TRANSCRIPT  trans_oss
                                           WHERE  education_id = trans.education_id
                                            AND TRUNC(date_of_issue) = TRUNC(trans.date_of_issue) )
                  OR ( p_rule = 'R'  AND trans.match_ind IN ('16', '25') )
            )
      AND UPDATE_TRANSCRIPT_ID IS NULL
      AND interface_transcript_id BETWEEN cp_start_int_id AND cp_end_int_id		--ARVSRINI--
     UNION ALL
     SELECT  cst_update dmlmode, trans.rowid, trans.*
     FROM igs_ad_txcpt_int  trans
     WHERE interface_run_id = p_interface_run_id
     AND  status = '2'
     AND (       p_rule = 'I'  OR (p_rule = 'R' AND trans.match_ind = '21'))
     AND interface_transcript_id BETWEEN cp_start_int_id AND cp_end_int_id		--ARVSRINI--
     AND ( EXISTS (SELECT 1 FROM IGS_AD_TRANSCRIPT  trans_oss
                                           WHERE education_id = trans.education_id
                                            AND TRUNC(date_of_issue) = TRUNC(trans.date_of_issue)
                        )
               OR UPDATE_TRANSCRIPT_ID IS NOT NULL
            );

    CURSOR  c_dup_cur(trans_cur_rec  trans_cur%ROWTYPE) IS
    SELECT
       trans_oss.rowid, trans_oss.*
    FROM
	IGS_AD_TRANSCRIPT trans_oss
    WHERE  ( transcript_id = trans_cur_rec.update_transcript_id
                  AND trans_cur_rec.update_transcript_id IS NOT NULL)
     OR ( trans_cur_rec.update_transcript_id IS  NULL
          AND education_id = trans_cur_rec.education_id
          AND TRUNC(date_of_issue) = TRUNC(trans_cur_rec.date_of_issue)
         ) ;

    l_maxint	NUMBER(15);
    l_minint	NUMBER(15);


    dup_cur_rec   c_dup_cur%ROWTYPE;
    l_prog_label  VARCHAR2(100) := 'igs.plsql.igs_ad_imp_024.prc_trscrpt';
    l_label  VARCHAR2(1000) ;
    l_debug_str VARCHAR2(1000) ;
    l_processed_records NUMBER(5) ;
    l_count_interface_txpt_id NUMBER;
    l_total_records_prcessed NUMBER;


 PROCEDURE create_new_transcript_details(p_trans_record IN OUT NOCOPY trans_cur%ROWTYPE)
   AS
 --------------------------------------------------------------------------
 --  Created By : pbondugu
 --  Date Created On : 2003/11/22
 --  Purpose:
 --  Know limitations, enhancements or remarks
 --  Change History
 --  Who             When            What
 --  (reverse chronological order - newest change first)
  --------------------------------------------------------------------------
    l_rowid VARCHAR2(25);
   l_var VARCHAR2(25);
   l_validation_status  NUMBER;
   l_err_code VARCHAR2(25);
   l_transcript_id igs_ad_txcpt_int.transcript_id%TYPE;
   l_error_code VARCHAR2(4) := NULL;
   l_error_text VARCHAR2(2000):= NULL;

    BEGIN
     l_transcript_id := NULL;
      BEGIN
         IF  NVL(p_trans_record.override_ind, 'N')  = 'N'  THEN
            IF p_trans_record.class_size > 0  AND p_trans_record.rank_in_class > 0 THEN
                p_trans_record.percentile_rank := ROUND( ((p_trans_record.class_size - p_trans_record.rank_in_class)/p_trans_record.class_size)*100) ;
                p_trans_record.decile_rank :=  11 - CEIL(p_trans_record.percentile_rank/10)  ;
                p_trans_record.quartile_rank  :=  5 - CEIL(p_trans_record.percentile_rank/25) ;
                p_trans_record.quintile_rank  :=  6 - CEIL(p_trans_record.percentile_rank/20)  ;
            ELSE
                p_trans_record.percentile_rank := NULL;
                p_trans_record.decile_rank :=  NULL;
                p_trans_record.quartile_rank  :=  NULL;
                p_trans_record.quintile_rank  :=  NULL;
            END IF;
         END IF;
        l_msg_at_index := igs_ge_msg_stack.count_msg;
        SAVEPOINT before_create_transcript;
        igs_ad_transcript_pkg.insert_row(
                                     x_rowid			=> l_rowid,
				     x_quintile_rank		=> p_trans_record.quintile_rank,
				     x_percentile_rank		=> p_trans_record.percentile_rank,
				     x_transcript_id		=> l_transcript_id,
				     x_education_id		=> p_trans_record.education_id,
				     x_transcript_status	=> p_trans_record.transcript_status,
				     x_transcript_source	=> p_trans_record.transcript_source,
				     x_date_of_receipt		=> TRUNC(p_trans_record.date_of_receipt),
				     x_entered_gpa		=> p_trans_record.entered_gpa,
				     x_entered_gs_id		=> p_trans_record.entered_gs_id,
				     x_conv_gpa			=> p_trans_record.conv_gpa,
				     x_conv_gs_id		=> p_trans_record.conv_gs_id,
				     x_term_type		=> p_trans_record.term_type,
				     x_rank_in_class		=> p_trans_record.rank_in_class,
				     x_class_size		=> p_trans_record.class_size,
				     x_approximate_rank		=> p_trans_record.approximate_rank,
				     x_weighted_rank		=> p_trans_record.weighted_rank,
				     x_decile_rank		=> p_trans_record.decile_rank,
				     x_quartile_rank		=> p_trans_record.quartile_rank,
				     x_transcript_type		=> p_trans_record.transcript_type,
				     x_mode			=> 'R',
				     x_date_of_issue		=> TRUNC(p_trans_record.date_of_issue),
                                     X_OVERRIDE                =>   NVL(p_trans_record.override_ind, 'N'),
                                     X_OVERRIDE_ID           =>    FND_GLOBAL.USER_ID,
                                     X_OVERRIDE_DATE      =>   TRUNC(SYSDATE)
                      	         );
        UPDATE igs_ad_txcpt_int
          SET status = cst_s_val_1,
              error_code = cst_ec_val_NULL,
              transcript_id = l_transcript_id,
              match_ind = DECODE (
                                       p_trans_record.match_ind,
                                              NULL, cst_mi_val_11,
                                       match_ind)
          WHERE interface_transcript_id = p_trans_record.interface_transcript_id;
         igs_ad_wf_001.transcript_entrd_event(p_trans_record.person_id, p_trans_record.education_id, l_transcript_id);

      EXCEPTION
      WHEN OTHERS THEN
             ROLLBACK TO before_create_transcript;
               igs_ad_gen_016.extract_msg_from_stack (
                          p_msg_at_index                => l_msg_at_index,
                          p_return_status               => l_return_status,
                          p_msg_count                   => l_msg_count,
                          p_msg_data                    => l_msg_data,
                          p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
               IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                   l_error_text := l_msg_data;
                   l_error_code := 'E322';

                   IF p_enable_log = 'Y' THEN
                       igs_ad_imp_001.logerrormessage(p_trans_record.interface_transcript_id,l_msg_data,'IGS_AD_TXCPT_INT');
                   END IF;
               ELSE
                    l_error_text :=  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405) ;
                    l_error_code := 'E518';
                    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		          l_label :='igs.plsql.igs_ad_imp_024.create_new_transcript_details.exception '||l_msg_data;

			  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			  fnd_message.set_token('INTERFACE_ID',p_trans_record.interface_transcript_id);
			  fnd_message.set_token('ERROR_CD','E322');

		          l_debug_str :=  fnd_message.get;

                          fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                      END IF;

               END IF;
           UPDATE igs_ad_txcpt_int
            SET status = cst_s_val_3,
            error_code = l_error_code,
            error_text = l_error_text ,
            match_ind = DECODE (
                                       p_trans_record.match_ind,
                                              NULL, cst_mi_val_11,
                                       match_ind)
            WHERE interface_transcript_id = p_trans_record.interface_transcript_id;
      END;
  END create_new_transcript_details;

   PROCEDURE update_transcript_details(p_trans_record  IN OUT NOCOPY trans_cur%ROWTYPE, dup_cur_rec c_dup_cur%ROWTYPE  )
     AS
   --------------------------------------------------------------------------
   --  Created By : pbondugu
   --  Date Created On : 2003/11/22
   --  Purpose:
   --  Know limitations, enhancements or remarks
   --  Change History
   --  Who             When            What
   --  (reverse chronological order - newest change first)
    --------------------------------------------------------------------------
      l_rowid VARCHAR2(25);
     l_var VARCHAR2(25);
     l_validation_status  NUMBER;
     l_err_code VARCHAR2(25);
     l_transcript_id igs_ad_txcpt_int.transcript_id%TYPE;
     l_msg_at_index   NUMBER := 0;
     l_return_status   VARCHAR2(1);
     l_msg_count      NUMBER ;
     l_msg_data       VARCHAR2(2000);
     l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
   l_error_code VARCHAR2(4) := NULL;
   l_error_text VARCHAR2(2000) := NULL;


      BEGIN
       l_transcript_id := NULL;
        BEGIN
         IF  NVL(p_trans_record.override_ind, 'N')  = 'N'  THEN
            IF p_trans_record.class_size > 0  AND p_trans_record.rank_in_class > 0 THEN
                p_trans_record.percentile_rank := ROUND( ((p_trans_record.class_size - p_trans_record.rank_in_class)/p_trans_record.class_size)*100) ;
                p_trans_record.decile_rank :=  11 - CEIL(p_trans_record.percentile_rank/10)  ;
                p_trans_record.quartile_rank  :=  5 - CEIL(p_trans_record.percentile_rank/25) ;
                p_trans_record.quintile_rank  :=  6 - CEIL(p_trans_record.percentile_rank/20)  ;
           ELSE
                p_trans_record.percentile_rank := NULL;
                p_trans_record.decile_rank :=  NULL;
                p_trans_record.quartile_rank  :=  NULL;
                p_trans_record.quintile_rank  :=  NULL;
            END IF;
         END IF;
        l_msg_at_index := igs_ge_msg_stack.count_msg;
         SAVEPOINT before_update_transcript;
          igs_ad_transcript_pkg.update_row(
                X_ROWID            => dup_cur_rec.rowid,
                X_QUINTILE_RANK    =>NVL(p_trans_record.QUINTILE_RANK, dup_cur_rec.QUINTILE_RANK),
                X_PERCENTILE_RANK  => NVL(p_trans_record.PERCENTILE_RANK, dup_cur_rec.PERCENTILE_RANK),
                X_TRANSCRIPT_ID    =>dup_cur_rec.transcript_id ,
                X_EDUCATION_ID     => p_trans_record.EDUCATION_ID         ,
                X_TRANSCRIPT_STATUS=> p_trans_record.TRANSCRIPT_STATUS    ,
                X_TRANSCRIPT_SOURCE=> p_trans_record.TRANSCRIPT_SOURCE    ,
                X_DATE_OF_RECEIPT  => TRUNC(NVL(p_trans_record.DATE_OF_RECEIPT, dup_cur_rec.DATE_OF_RECEIPT)),
                X_ENTERED_GPA      => NVL(p_trans_record.ENTERED_GPA, dup_cur_rec.ENTERED_GPA),
                X_ENTERED_GS_ID    => p_trans_record.ENTERED_GS_ID        ,
                  X_CONV_GPA         => NVL(p_trans_record.CONV_GPA, dup_cur_rec.CONV_GPA),
                X_CONV_GS_ID       => p_trans_record.CONV_GS_ID           ,
                X_TERM_TYPE        => p_trans_record.TERM_TYPE            ,
                X_RANK_IN_CLASS    => NVL(p_trans_record.RANK_IN_CLASS, dup_cur_rec.RANK_IN_CLASS),
                X_CLASS_SIZE       => NVL(p_trans_record.CLASS_SIZE, dup_cur_rec.CLASS_SIZE),
                X_APPROXIMATE_RANK => NVL(p_trans_record.APPROXIMATE_RANK, dup_cur_rec.APPROXIMATE_RANK),
                X_WEIGHTED_RANK    => NVL(p_trans_record.WEIGHTED_RANK, dup_cur_rec.WEIGHTED_RANK),
                X_DECILE_RANK      => NVL(p_trans_record.DECILE_RANK, dup_cur_rec.DECILE_RANK),
                X_QUARTILE_RANK    => NVL(p_trans_record.QUARTILE_RANK, dup_cur_rec.QUARTILE_RANK),
                X_TRANSCRIPT_TYPE  => NVL(p_trans_record.TRANSCRIPT_TYPE, dup_cur_rec.TRANSCRIPT_TYPE),
              X_DATE_OF_ISSUE	 => TRUNC(NVL(p_trans_record.DATE_OF_ISSUE, dup_cur_rec.DATE_OF_ISSUE)),
               X_OVERRIDE                =>   NVL(p_trans_record.override_ind, 'N'),
               X_OVERRIDE_ID           =>    FND_GLOBAL.USER_ID,
               X_OVERRIDE_DATE      =>   TRUNC(SYSDATE)

                  );

          UPDATE igs_ad_txcpt_int
            SET status = cst_s_val_1,
                error_code = cst_ec_val_NULL,
                transcript_id = dup_cur_rec.transcript_id,
                match_ind = DECODE (
                                       p_trans_record.match_ind,
                                              NULL, cst_mi_val_18,
                                       match_ind)
            WHERE interface_transcript_id = p_trans_record.interface_transcript_id;



        EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO before_update_transcript;
                  igs_ad_gen_016.extract_msg_from_stack (
                            p_msg_at_index                => l_msg_at_index,
                            p_return_status               => l_return_status,
                            p_msg_count                   => l_msg_count,
                            p_msg_data                    => l_msg_data,
                            p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
                 IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                     l_error_text := l_msg_data;
                     l_error_code := 'E014';

                     IF p_enable_log = 'Y' THEN
                         igs_ad_imp_001.logerrormessage(p_trans_record.interface_transcript_id,l_msg_data,'IGS_AD_TXCPT_INT');
                     END IF;
                 ELSE
                      l_error_text :=  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405);
                      l_error_code := 'E518';
                      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

   	          l_label := 'igs.plsql.igs_ad_imp_024.create_new_transcript_details.exception '||l_msg_data;

   		  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
   		  fnd_message.set_token('INTERFACE_ID',p_trans_record.interface_transcript_id);
   		  fnd_message.set_token('ERROR_CD','E014');

   	          l_debug_str :=  fnd_message.get;

                            fnd_log.string_with_context( fnd_log.level_exception,
   							  l_label,
   							  l_debug_str, NULL,
   							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                        END IF;

                 END IF;
             UPDATE igs_ad_txcpt_int
              SET status = cst_s_val_3,
              error_code = l_error_code,
              error_text = l_error_text ,
              match_ind = DECODE (
                                       p_trans_record.match_ind,
                                              NULL, cst_mi_val_18,
                                       match_ind)
              WHERE interface_transcript_id = p_trans_record.interface_transcript_id;
        END;
    END update_transcript_details;



BEGIN
   --If given invalid update transcript ID then error out.
     UPDATE IGS_AD_TXCPT_INT trans
     SET
       status = '3',  error_code =  'E707',
       error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E707', 8405)
     WHERE  interface_run_id = p_interface_run_id
          AND status = '2'
       AND trans.update_transcript_id IS NOT NULL
          AND NOT EXISTS ( SELECT 1 FROM IGS_AD_TRANSCRIPT
                                     WHERE transcript_id = NVL(trans.update_transcript_id,transcript_id)
                                   ) ;
     COMMIT;

     -- jchin - bug 4629226 Put an error in the interface table if the transcript source is external.

     UPDATE IGS_AD_TXCPT_INT trans
     SET
       status = '3',  error_code =  'E334',
       error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E334', 8405)
       WHERE interface_run_id = p_interface_run_id
       AND status = '2'
       AND trans.transcript_source IS NOT NULL
       AND EXISTS ( SELECT 1 FROM igs_ad_code_classes_v code
                    WHERE code.system_status = 'THIRD_PARTY_TRANSFER_EVAL'
                    AND code.class_type_code = 'ADM_CODE_CLASSES'
                    AND code.class = 'TRANSCRIPT_SOURCE'
                    AND code.code_id = trans.transcript_source);
     COMMIT;

       --	1. Set STATUS to 3 for interface records with RULE = E or I and MATCH IND is not null and not '15'
     IF p_rule IN ('E', 'I')  THEN
        UPDATE igs_ad_txcpt_int
          SET
          status = '3'
          , error_code = 'E700'
          , error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405)
          WHERE interface_run_id = p_interface_run_id
          AND status = '2'
         AND NVL (match_ind, '15') <> '15';
     END IF;
     COMMIT;

     --	2. Set STATUS to 1 for interface records with RULE = R and MATCH IND = 17,18,19,22,23,24,27
     IF p_rule = 'R'  THEN
        UPDATE igs_ad_txcpt_int
        SET
        status = '1',  error_code = NULL
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND match_ind IN ('17', '18', '19', '22', '23', '24', '27');
     END IF;
     COMMIT;

--  3.	Set STATUS to 3 for interface records with multiple matching duplicate system records for RULE = I
   IF  p_rule = 'I' THEN
     UPDATE igs_ad_txcpt_int trans
     SET
     status = '3'
     , match_ind = '13'
     WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND UPDATE_TRANSCRIPT_ID  IS NULL
     AND 1  <  ( SELECT COUNT(*)
                        FROM IGS_AD_TRANSCRIPT  trans_oss
                         WHERE  education_id = trans.education_id
                         AND TRUNC(date_of_issue) = TRUNC(trans.date_of_issue)
                   );

     END IF;
    COMMIT;
--  4.	Set STATUS to 3 for interface records with multiple matching duplicate system record for RULE = R
--   and either MATCH IND IN (15, 21) OR IS NULL
 IF  p_rule = 'R' THEN
    UPDATE igs_ad_txcpt_int  trans
    SET
    status = '3'
    , match_ind = '13'
    WHERE interface_run_id = p_interface_run_id
    AND status = '2'
    AND UPDATE_TRANSCRIPT_ID  IS NULL
    AND NVL(match_ind, '15')  IN ('15', '21')
    AND 1  <  ( SELECT COUNT(*)
                        FROM IGS_AD_TRANSCRIPT  trans_oss
                         WHERE  education_id = trans.education_id
                         AND TRUNC(date_of_issue) = TRUNC(trans.date_of_issue)
                   );

 END IF;
 COMMIT;
    -- 5. Set STATUS to 1 and MATCH IND to 19 for interface records with RULE = E matching OSS record(s)
  IF  p_rule = 'E' THEN
 --If multiple exact matches are found and child records are present then error out
     UPDATE igs_ad_txcpt_int  trans
      SET
          status = '1'
         , match_ind = '19'
         , transcript_id = update_transcript_id
     WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND  update_transcript_id IS NOT NULL;

      UPDATE igs_ad_txcpt_int  trans
      SET
         status = '3'
        , match_ind = '19'
        ,error_code = 'E708'
       , error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E708', 8405)
     WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND EXISTS( SELECT 1 FROM IGS_AD_TRMDT_INT term
                         WHERE term.interface_transcript_id = trans.interface_transcript_id
                         AND status = '2')
     AND 1 < (  SELECT count(*)  FROM igs_ad_transcript  trans_oss
                         WHERE  education_id = trans.education_id
                         AND TRUNC(date_of_issue) = TRUNC(trans.date_of_issue)
                         );
     COMMIT;
      UPDATE igs_ad_txcpt_int  trans
      SET
         status = '1'
        , match_ind = '19'
        , transcript_id = ( SELECT transcript_id FROM IGS_AD_TRANSCRIPT  trans_oss
                         WHERE  education_id = trans.education_id
                         AND TRUNC(date_of_issue) = TRUNC(trans.date_of_issue)
                         AND rownum <= 1)
      WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND EXISTS (  SELECT 1 FROM IGS_AD_TRANSCRIPT  trans_oss
                         WHERE  education_id = trans.education_id
                         AND TRUNC(date_of_issue) = TRUNC(trans.date_of_issue)
                         );
  END IF;
COMMIT;

/**********************************************************************************
Create / Update the OSS record after validating successfully the interface record
Create
    If RULE I (match indicator will be 15 or NULL by now no need to check) and matching system record not found OR
    RULE = R and MATCH IND = 16, 25
Update
    If RULE = I (match indicator will be 15 or NULL by now no need to check) OR
    RULE = R and MATCH IND = 21

Selecting together the interface records for INSERT / UPDATE with DMLMODE identifying the DML operation.
This is done to have one code section for record validation, exception handling and interface table update.
This avoids call to separate PLSQL blocks, tuning performance on stack maintenance during the process.

**********************************************************************************/

l_total_records_prcessed := 0;

  SELECT COUNT(interface_transcript_id) INTO l_count_interface_txpt_id
  FROM igs_ad_txcpt_int
  WHERE interface_run_id = p_interface_run_id
  AND status =2 ;
	LOOP
  EXIT WHEN l_total_records_prcessed >= l_count_interface_txpt_id;
  SELECT
       MIN(interface_transcript_id) , MAX(interface_transcript_id)
   INTO l_minint , l_maxint
   FROM igs_ad_txcpt_int
   WHERE interface_run_id = p_interface_run_id
   AND status =2
   AND rownum < =100;

	FOR trans_cur_rec IN trans_cur(l_minint,l_maxint)					--arvsrini
	LOOP

	       IF trans_cur_rec.dmlmode =  cst_insert  THEN
	           create_new_transcript_details(trans_cur_rec);
	       ELSIF  trans_cur_rec.dmlmode = cst_update THEN
	          OPEN c_dup_cur(trans_cur_rec);
	          FETCH c_dup_cur INTO dup_cur_rec;
	          CLOSE c_dup_cur;
	           update_transcript_details(trans_cur_rec, dup_cur_rec);
	       END IF;
              l_total_records_prcessed := l_total_records_prcessed + 1;

	 END LOOP;
	         COMMIT;



END LOOP;


 /*Set STATUS to 1 and MATCH IND to 23 for interface records with RULE = R matching OSS record(s) in
   ALL updateable column values, if column nullification is not allowed then the 2 DECODE should be replaced by a single NVL*/
     IF p_rule = 'R'  THEN
       UPDATE igs_ad_txcpt_int  trans
       SET
         status = '1'
         , match_ind = '23'
       WHERE interface_run_id = p_interface_run_id
       AND status = '2'
       AND NVL (match_ind, '15') = '15'
       AND EXISTS (  SELECT 1 FROM IGS_AD_TRANSCRIPT  trans_oss
                         WHERE education_id = trans.education_id
                         AND TRUNC(date_of_issue) = TRUNC(trans.date_of_issue)
                         AND transcript_type = trans.transcript_type
                         AND TRANSCRIPT_STATUS  =  trans.TRANSCRIPT_STATUS
                         AND  TRANSCRIPT_SOURCE   = trans.TRANSCRIPT_SOURCE
                         AND  TRUNC(NVL(DATE_OF_RECEIPT,IGS_GE_DATE.IGSDATE('1000/01/01')))
                                    = TRUNC( NVL( NVL(trans.DATE_OF_RECEIPT, DATE_OF_RECEIPT ) , IGS_GE_DATE.IGSDATE('1000/01/01')))
                         AND  NVL(ENTERED_GPA,'1')       = NVL(NVL(trans.ENTERED_GPA, ENTERED_GPA),'X')
                         AND  NVL(ENTERED_GS_ID,-1)      = NVL(NVL(trans.ENTERED_GS_ID,ENTERED_GS_ID),-1)
                         AND  NVL(CONV_GPA,'X')          = NVL(NVL(trans.CONV_GPA,CONV_GPA), 'X')
                         AND  NVL(CONV_GS_ID,-1)         = NVL(NVL(trans.CONV_GS_ID,CONV_GS_ID), -1)
                         AND  NVL(TERM_TYPE,'X')         = NVL(NVL(trans.TERM_TYPE,TERM_TYPE) , 'X')
                         AND  NVL(RANK_IN_CLASS,-1)      = NVL(NVL(trans.RANK_IN_CLASS,RANK_IN_CLASS), -1)
                         AND  NVL(CLASS_SIZE,-1)         = NVL(NVL(trans.CLASS_SIZE, CLASS_SIZE), -1)
                         AND  NVL(APPROXIMATE_RANK,'X')  = NVL(NVL(trans.APPROXIMATE_RANK, APPROXIMATE_RANK), 'X')
                         AND  NVL(WEIGHTED_RANK,'X')     = NVL(NVL(trans.DECILE_RANK, WEIGHTED_RANK), -1)
                         AND  NVL(QUARTILE_RANK,-1)      = NVL(NVL(trans.QUARTILE_RANK, QUARTILE_RANK), -1)
                         AND  NVL(QUINTILE_RANK,-1)      = NVL(NVL(trans.QUINTILE_RANK, QUINTILE_RANK), -1)
                         AND  NVL(PERCENTILE_RANK,-1)    = NVL(NVL(trans.PERCENTILE_RANK, PERCENTILE_RANK ), -1)
                         AND  NVL(TRANSCRIPT_TYPE,'X')   = NVL(NVL(trans.TRANSCRIPT_TYPE,TRANSCRIPT_TYPE), 'X')
                         AND  NVL(DECILE_RANK, -1)    =        NVL(NVL(trans.DECILE_RANK,DECILE_RANK),  -1)
                         AND  NVL( OVERRIDE_IND, 'X' ) =   NVL(NVL(trans.OVERRIDE_IND, OVERRIDE_IND), 'X' )
                );
     END IF;

 --Set STATUS to 3 and MATCH IND = 20 for interface records with RULE = R and
 --MATCH IND <> 21, 25, ones failed above discrepancy check
     IF p_rule = 'R'  THEN
        UPDATE igs_ad_txcpt_int  trans
        SET
        status = '3'
        , match_ind = '20'
        , dup_transcript_id = trans.update_transcript_id
        WHERE trans.interface_run_id = p_interface_run_id
        AND status = '2'
        AND update_transcript_id IS NOT NULL;
     COMMIT;
        UPDATE igs_ad_txcpt_int  trans
        SET
        status = '3'
        , match_ind = '20'
        , dup_transcript_id= ( SELECT transcript_id  FROM IGS_AD_TRANSCRIPT  trans_oss
                         WHERE  education_id = trans.education_id
                         AND TRUNC(date_of_issue) = TRUNC(trans.date_of_issue))
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND NVL (match_ind, '15') = '15'
        AND EXISTS (SELECT 1 FROM IGS_AD_TRANSCRIPT  trans_oss
                         WHERE  education_id = trans.education_id
                         AND TRUNC(date_of_issue) = TRUNC(trans.date_of_issue));

     END IF;
     COMMIT;


  --Set STATUS to 3 for interface records with RULE = R and invalid MATCH IND
     IF p_rule = 'R'  THEN
        UPDATE igs_ad_txcpt_int  trans
        SET
        status = '3'
        , error_code = 'E700'
        , error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405)
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND match_ind IS NOT NULL;
     END IF;
     COMMIT;

     --Term and units are not defined as independent categoies
  UPDATE igs_ad_trmdt_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,education_id, transcript_id)
             = (SELECT person_id,education_id, NVL(update_transcript_id, transcript_id)
                FROM   igs_ad_txcpt_int
                WHERE  interface_transcript_id = a.interface_transcript_id)
      WHERE  status IN ('1','2','4')
      AND    interface_transcript_id IN (SELECT interface_transcript_id
                                         FROM   igs_ad_txcpt_int
                                         WHERE  interface_run_id = p_interface_run_id
                                         AND    status IN ('1','4'));

 -- If record failed only due to child record failure
 -- then set status back to 1 and nullify error code/text
      UPDATE igs_ad_trmdt_int
      SET    error_code = NULL,
             error_text = NULL,
             status = '1'
      WHERE  interface_run_id = p_interface_run_id
      AND    error_code = 'E347'
      AND    status = '4';

    -- To fetch table schema name for gather statistics
    l_return := fnd_installation.get_app_info('IGS', l_status, l_industry, l_schema);

-- Gather statistics of the table
   FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                               tabname => 'IGS_AD_TRMDT_INT',
                                cascade => TRUE);

process_term_details (p_interface_run_id, p_rule,p_enable_log);

--Term and units are not defined as independent categoies
UPDATE igs_ad_tundt_int a
    SET    interface_run_id = p_interface_run_id,
           (person_id,education_id , transcript_id, term_details_id )
             = (SELECT person_id,education_id ,
                     transcript_id, term_details_id
                FROM   igs_ad_trmdt_int
                WHERE  interface_term_dtls_id = a.interface_term_dtls_id)
      WHERE  status IN ('1','2','4')
      AND    interface_term_dtls_id IN (SELECT interface_term_dtls_id
                                        FROM   igs_ad_trmdt_int
                                        WHERE  interface_run_id = p_interface_run_id
                                        AND    status IN ('1','4'));

-- Gather statistics of the table
   FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_TUNDT_INT',
                                   cascade => TRUE);

process_term_unit_details (p_interface_run_id, p_rule,p_enable_log);
END  prc_trscrpt;





PROCEDURE process_term_details(
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2)  AS

CURSOR term_cur (cp_start_int_id  igs_ad_trmdt_int.INTERFACE_TERM_DTLS_ID%TYPE,	--ARVSRINI--
		 cp_end_int_id	  igs_ad_trmdt_int.INTERFACE_TERM_DTLS_ID%TYPE) IS	--ARVSRINI--IS
     SELECT  cst_insert dmlmode, term.rowid,  term.*
     FROM igs_ad_trmdt_int  term
     WHERE interface_run_id = p_interface_run_id
     AND  term.status = '2'
     AND INTERFACE_TERM_DTLS_ID BETWEEN cp_start_int_id AND cp_end_int_id
     AND  (NOT EXISTS (SELECT 1 FROM IGS_AD_TERM_DETAILS term_oss
                                          WHERE transcript_id  = term.transcript_id
                                           AND  term = term.term
                                           AND  TRUNC(start_Date) = TRUNC(term.start_Date)
                                           AND  TRUNC(end_Date) = TRUNC(term.end_Date) )
                  OR ( p_rule = 'R'  AND term.match_ind IN ('16', '25') )
              )
     UNION ALL
     SELECT  cst_update dmlmode, term.rowid,  term.*
     FROM igs_ad_trmdt_int  term
     WHERE interface_run_id = p_interface_run_id
     AND  status = '2'
     AND INTERFACE_TERM_DTLS_ID BETWEEN cp_start_int_id AND cp_end_int_id
     AND (       p_rule = 'I'  OR (p_rule = 'R' AND term.match_ind = cst_mi_val_21))
     AND EXISTS (SELECT 1 FROM IGS_AD_TERM_DETAILS term_oss
                                          WHERE transcript_id  = term.transcript_id
                                           AND  term = term.term
                                           AND  TRUNC(start_Date) = TRUNC(term.start_Date)
                                           AND  TRUNC(end_Date) = TRUNC(term.end_Date)
                          );

   CURSOR  c_dup_cur(term_cur_rec  term_cur%ROWTYPE) IS
    SELECT
       term_oss.rowid, term_oss.*
    FROM
	IGS_AD_TERM_DETAILS term_oss
    WHERE transcript_id  = term_cur_rec.transcript_id
    AND  term = term_cur_rec.term
    AND  TRUNC(start_Date) = TRUNC(term_cur_rec.start_Date)
    AND  TRUNC(end_Date) = TRUNC(term_cur_rec.end_Date) ;

   l_maxint	NUMBER(15);
   l_minint	NUMBER(15);


    dup_cur_rec   c_dup_cur%ROWTYPE;
    l_prog_label  VARCHAR2(100) := 'igs.plsql.igs_ad_imp_024.process_term_details';
    l_label  VARCHAR2(1000) ;
    l_debug_str VARCHAR2(1000) ;
    l_processed_records NUMBER(5) ;

    l_count_interface_trmdtls_id NUMBER;
    l_total_records_prcessed NUMBER;

 PROCEDURE create_term_details(p_term_dtls_record term_cur%ROWTYPE)
   AS
 --------------------------------------------------------------------------
 --  Created By : rboddu
 --  Date Created On : 2001/07/27
 --  Purpose:
 --  Know limitations, enhancements or remarks
 --  Change History
 --  Who             When            What
 --  (reverse chronological order - newest change first)
  --------------------------------------------------------------------------
    l_rowid VARCHAR2(25);
   l_var VARCHAR2(25);
   l_term_details_id igs_ad_trmdt_int.term_details_id%TYPE;
   l_msg_at_index   NUMBER := 0;
   l_return_status   VARCHAR2(1);
   l_msg_count      NUMBER ;
   l_msg_data       VARCHAR2(2000);
   l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
   l_error_code VARCHAR2(4) := NULL;
   l_error_text VARCHAR2(2000):= NULL;
    BEGIN
        l_msg_at_index := igs_ge_msg_stack.count_msg;
        SAVEPOINT before_create_term;
          igs_ad_term_details_pkg.insert_row(
                                              l_rowid,
                                              l_term_details_id      ,
                                              p_term_dtls_record.TRANSCRIPT_ID        ,
                                              p_term_dtls_record.TERM                 ,
                                              TRUNC(p_term_dtls_record.START_DATE)           ,
                                              TRUNC(p_term_dtls_record.END_DATE)             ,
                                              NULL,
                                              NULL,
                                              NULL,
                                              p_term_dtls_record.TOTAL_GPA_UNITS      ,
                                              p_term_dtls_record.GPA
                                            );
    UPDATE igs_ad_trmdt_int
          SET status =cst_s_val_1,
              error_code = cst_ec_val_NULL,
              term_details_id = l_term_details_id
          WHERE interface_term_dtls_id  = p_term_dtls_record.interface_term_dtls_id;


-- Update Transcript Status

      EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK TO before_create_term;
                igs_ad_gen_016.extract_msg_from_stack (
                          p_msg_at_index                => l_msg_at_index,
                          p_return_status               => l_return_status,
                          p_msg_count                   => l_msg_count,
                          p_msg_data                    => l_msg_data,
                          p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
               IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                   l_error_text := l_msg_data;
                   l_error_code := 'E322';

                   IF p_enable_log = 'Y' THEN
                       igs_ad_imp_001.logerrormessage(p_term_dtls_record.interface_term_dtls_id,l_msg_data,'IGS_AD_TRMDT_INT');
                   END IF;
               ELSE
                    l_error_text :=  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405);
                    l_error_code := 'E518';
                    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		          l_label :='igs.plsql.igs_ad_imp_024.create_term_details.exception '||l_msg_data;

			  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			  fnd_message.set_token('INTERFACE_ID',p_term_dtls_record.interface_term_dtls_id);
			  fnd_message.set_token('ERROR_CD','E322');

		          l_debug_str :=  fnd_message.get;

                          fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                      END IF;

               END IF;
           UPDATE igs_ad_trmdt_int
            SET status = cst_s_val_3,
            error_code = l_error_code,
            error_text = l_error_text,
            match_ind = DECODE (
                                       p_term_dtls_record.match_ind,
                                              NULL, cst_mi_val_11,
                                       match_ind)
          WHERE interface_term_dtls_id  = p_term_dtls_record.interface_term_dtls_id;
  END create_term_details;

   PROCEDURE update_term_details(p_term_dtls_record term_cur%ROWTYPE, dup_cur_rec c_dup_cur%ROWTYPE  )
     AS
   --------------------------------------------------------------------------
   --  Created By : rboddu
   --  Date Created On : 2001/07/27
   --  Purpose:
   --  Know limitations, enhancements or remarks
   --  Change History
   --  Who             When            What
   --  (reverse chronological order - newest change first)
    --------------------------------------------------------------------------
      l_rowid VARCHAR2(25);
     l_var VARCHAR2(25);
     l_term_details_id igs_ad_trmdt_int.term_details_id%TYPE;
     l_msg_at_index   NUMBER := 0;
     l_return_status   VARCHAR2(1);
     l_msg_count      NUMBER ;
     l_msg_data       VARCHAR2(2000);
     l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
     l_error_code VARCHAR2(4) := NULL;
     l_error_text VARCHAR2(2000):= NULL;
      BEGIN
              l_msg_at_index := igs_ge_msg_stack.count_msg;
         SAVEPOINT before_update_term;
          igs_ad_term_details_pkg.update_row(
                          X_ROWID           =>  dup_cur_rec.rowid   ,
                          X_TERM_DETAILS_ID =>  dup_cur_rec.term_details_id      ,
                          X_TRANSCRIPT_ID   =>  p_term_dtls_record.transcript_id        ,
                          X_TERM            =>  p_term_dtls_record.term                 ,
                          X_START_DATE      =>  TRUNC(p_term_dtls_record.start_date)           ,
                          X_END_DATE        =>  TRUNC(p_term_dtls_record.end_date)             ,
                          X_TOTAL_CP_ATTEMPTED => dup_cur_rec.total_cp_attempted,
                          X_TOTAL_CP_EARNED =>  dup_cur_rec.total_cp_earned,
                          X_TOTAL_UNIT_GP   =>  dup_cur_rec.total_unit_gp,
                          X_TOTAL_GPA_UNITS =>  NVL(p_term_dtls_record.total_gpa_units, dup_cur_rec.total_gpa_units),
                          X_GPA             =>  NVL(p_term_dtls_record.gpa, dup_cur_rec.gpa)
                            );
        UPDATE igs_ad_trmdt_int
          SET status =cst_s_val_1,
              error_code = cst_ec_val_NULL,
              term_details_id = dup_cur_rec.term_details_id
          WHERE interface_term_dtls_id  = p_term_dtls_record.interface_term_dtls_id;

        EXCEPTION
        WHEN OTHERS THEN
                  ROLLBACK TO  before_update_term;
                  igs_ad_gen_016.extract_msg_from_stack (
                            p_msg_at_index                => l_msg_at_index,
                            p_return_status               => l_return_status,
                            p_msg_count                   => l_msg_count,
                            p_msg_data                    => l_msg_data,
                            p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
                 IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                     l_error_text := l_msg_data;
                     l_error_code := 'E014';

                     IF p_enable_log = 'Y' THEN
                         igs_ad_imp_001.logerrormessage( p_term_dtls_record.interface_term_dtls_id,l_msg_data,'IGS_AD_TRMDT_INT');
                     END IF;
                 ELSE
                      l_error_text :=  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405);
                      l_error_code := 'E518';
                      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

   	          l_label := 'igs.plsql.igs_ad_imp_024.update_term_details.exception '||l_msg_data;

   		  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
   		  fnd_message.set_token('INTERFACE_ID',p_term_dtls_record.interface_term_dtls_id);
   		  fnd_message.set_token('ERROR_CD','E014');

   	          l_debug_str :=  fnd_message.get;

                            fnd_log.string_with_context( fnd_log.level_exception,
   							  l_label,
   							  l_debug_str, NULL,
   							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                        END IF;

                 END IF;
          UPDATE igs_ad_trmdt_int
            SET status = cst_s_val_3,
            error_code = l_error_code,
            error_text = l_error_text,
            match_ind = DECODE (
                                       p_term_dtls_record.match_ind,
                                              NULL, cst_mi_val_12,
                                       match_ind)
          WHERE interface_term_dtls_id  = p_term_dtls_record.interface_term_dtls_id;
    END update_term_details;



BEGIN
     -- jchin Bug 4629226 Put an error in the int table if record is associated with an external transcript

     UPDATE igs_ad_trmdt_int term
       SET
       status = '3'
       ,error_code = 'E334'
       ,error_Text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E334', 8405)
       WHERE interface_run_id = p_interface_run_id
       AND status = '2'
       AND EXISTS (SELECT 1 FROM igs_ad_txcpt_int trans, igs_ad_code_classes_v code
                   WHERE trans.interface_transcript_id = term.interface_transcript_id
                   AND trans.transcript_source = code.code_id
                   AND code.class = 'TRANSCRIPT_SOURCE'
                   AND code.system_status = 'THIRD_PARTY_TRANSFER_EVAL'
                   AND code.class_type_code = 'ADM_CODE_CLASSES');

     COMMIT;

      --1. Set STATUS to 3 for interface records with RULE = E or I and MATCH IND is not null and not '15'
     IF p_rule IN ('E', 'I')  THEN
        UPDATE igs_ad_trmdt_int
          SET
          status = '3'
          , error_code = 'E700'
          ,error_Text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405)
          WHERE interface_run_id = p_interface_run_id
          AND status = '2'
         AND NVL (match_ind, '15') <> '15';
     END IF;
     COMMIT;

     --	2. Set STATUS to 1 for interface records with RULE = R and MATCH IND = 17,18,19,22,23,24,27
     IF p_rule = 'R'  THEN
        UPDATE igs_ad_trmdt_int
        SET
        status = '1',  error_code = NULL
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND match_ind IN ('17', '18', '19', '22', '23', '24', '27');
     END IF;
     COMMIT;
   -- 5. Set STATUS to 1 and MATCH IND to 19 for interface records with RULE = E matching OSS record(s)
  IF  p_rule = 'E' THEN
      UPDATE igs_ad_trmdt_int  term
      SET
         status = '3'
        , error_code = 'E708'
          ,error_Text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E708', 8405)
      WHERE interface_run_id = p_interface_run_id
      AND status = '2'
      AND  EXISTS ( SELECT 1 FROM igs_ad_tundt_int
                            WHERE  interface_term_dtls_id = term.interface_term_dtls_id
                            AND status ='2')
      AND  1 < (  SELECT COUNT(*)  FROM IGS_AD_TERM_DETAILS term_oss
                                          WHERE transcript_id  = term.transcript_id
                                           AND  term = term.term
                                           AND  TRUNC(start_Date) = TRUNC(term.start_Date)
                                           AND  TRUNC(end_Date) = TRUNC(term.end_Date)
                         );

      UPDATE igs_ad_trmdt_int  term
      SET
         status = '1'
        , match_ind = '19'
        , term_Details_id = (  SELECT term_Details_id  FROM IGS_AD_TERM_DETAILS term_oss
                                          WHERE transcript_id  = term.transcript_id
                                           AND  term = term.term
                                           AND  TRUNC(start_Date) = TRUNC(term.start_Date)
                                           AND  TRUNC(end_Date) = TRUNC(term.end_Date)
                                           AND  rownum <=1
                                      )
      WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND  EXISTS (  SELECT 1 FROM IGS_AD_TERM_DETAILS term_oss
                                          WHERE transcript_id  = term.transcript_id
                                           AND  term = term.term
                                           AND  TRUNC(start_Date) = TRUNC(term.start_Date)
                                           AND  TRUNC(end_Date) = TRUNC(term.end_Date)
                         );
  END IF;
COMMIT;

/**********************************************************************************
Create / Update the OSS record after validating successfully the interface record
Create
    If RULE I (match indicator will be 15 or NULL by now no need to check) and matching system record not found OR
    RULE = R and MATCH IND = 16, 25
Update
    If RULE = I (match indicator will be 15 or NULL by now no need to check) OR
    RULE = R and MATCH IND = 21

Selecting together the interface records for INSERT / UPDATE with DMLMODE identifying the DML operation.
This is done to have one code section for record validation, exception handling and interface table update.
This avoids call to separate PLSQL blocks, tuning performance on stack maintenance during the process.

**********************************************************************************/

l_total_records_prcessed := 0;
  SELECT COUNT( interface_term_dtls_id) INTO l_count_interface_trmdtls_id
  FROM   igs_ad_trmdt_int
  WHERE interface_run_id = p_interface_run_id
  AND status =2 ;

LOOP
EXIT WHEN l_total_records_prcessed >= l_count_interface_trmdtls_id;

SELECT
 MIN(interface_term_dtls_id) , MAX(interface_term_dtls_id)
 INTO l_minint , l_maxint
FROM  igs_ad_trmdt_int
WHERE interface_run_id = p_interface_run_id
 AND status =2
 AND rownum < =100;

FOR term_cur_rec IN term_cur(l_minint,l_minint+99)
LOOP
       IF term_cur_rec.dmlmode =  cst_insert  THEN
           create_term_details(term_cur_rec);
       ELSIF  term_cur_rec.dmlmode = cst_update THEN
          OPEN c_dup_cur(term_cur_rec);
          FETCH c_dup_cur INTO dup_cur_rec;
          CLOSE c_dup_cur;
           update_term_details(term_cur_rec, dup_cur_rec);
       END IF;
       l_total_records_prcessed := l_total_records_prcessed + 1;

 END LOOP;
         COMMIT;





END LOOP;


 /*Set STATUS to 1 and MATCH IND to 23 for interface records with RULE = R matching OSS record(s) in
   ALL updateable column values, if column nullification is not allowed then the 2 DECODE should be replaced by a single NVL*/
     IF p_rule = 'R'  THEN
       UPDATE igs_ad_trmdt_int  term
       SET
         status = '1'
         , match_ind = '23'
       WHERE interface_run_id = p_interface_run_id
       AND status = '2'
       AND NVL (match_ind, '15') = '15'
       AND EXISTS (  SELECT 1  FROM igs_ad_term_details
                                 WHERE
                                    TRANSCRIPT_ID= term.transcript_id AND
                                    TERM           = term.TERM          AND
                                    TRUNC(START_DATE) =  TRUNC(term.START_DATE) AND
                                    TRUNC(END_DATE) = TRUNC(term.END_DATE) AND
                                    NVL(TOTAL_GPA_UNITS,-1)= NVL(term.TOTAL_GPA_UNITS,-1) AND
                                    NVL(GPA,'X')= NVL(term.GPA,'X')
                );
     END IF;
     COMMIT;

 --Set STATUS to 3 and MATCH IND = 20 for interface records with RULE = R and
 --MATCH IND <> 21, 25, ones failed above discrepancy check
     IF p_rule = 'R'  THEN
        UPDATE igs_ad_trmdt_int  term
        SET
        status = '3'
        , match_ind = '20'
        , dup_term_dtls_id = ( SELECT term_details_id FROM IGS_AD_TERM_DETAILS term_oss
                                          WHERE transcript_id  = term.transcript_id
                                           AND  term = term.term
                                           AND  TRUNC(start_Date) = TRUNC(term.start_Date)
                                           AND  TRUNC(end_Date) = TRUNC(term.end_Date) )
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND NVL (match_ind, '15') = '15'
        AND EXISTS (SELECT 1 FROM IGS_AD_TERM_DETAILS term_oss
                                          WHERE transcript_id  = term.transcript_id
                                           AND  term = term.term
                                           AND  TRUNC(start_Date) = TRUNC(term.start_Date)
                                           AND  TRUNC(end_Date) = TRUNC(term.end_Date) );

     END IF;
     COMMIT;


  --Set STATUS to 3 for interface records with RULE = R and invalid MATCH IND
     IF p_rule = 'R'  THEN
        UPDATE igs_ad_trmdt_int  term
        SET
        status = '3'
        , error_code = 'E700'
        ,error_Text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405)
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND match_ind IS NOT NULL;
     END IF;
     COMMIT;

END  process_term_details;




PROCEDURE process_term_unit_details(
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2)  AS

CURSOR term_unit_cur(cp_start_int_id  IGS_AD_TUNDT_INT.INTERFACE_TERM_UNITDTLS_ID%TYPE,	--ARVSRINI--
		 cp_end_int_id	  IGS_AD_TUNDT_INT.INTERFACE_TERM_UNITDTLS_ID%TYPE) IS	--ARVSRINI-- IS
     SELECT  cst_insert dmlmode, unit.rowid,  unit.*
     FROM igs_ad_tundt_int  unit
     WHERE interface_run_id = p_interface_run_id
     AND  unit.status = '2'
     AND INTERFACE_TERM_UNITDTLS_ID BETWEEN cp_start_int_id AND cp_end_int_id		--ARVSRINI--
     AND  (NOT EXISTS (SELECT 1 FROM igs_ad_term_unitdtls unit_oss
                                          WHERE term_details_id =  unit.term_details_id
                                          AND unit = unit.unit )
                  OR ( p_rule = 'R'  AND unit.match_ind IN ('16', '25') )
              )
     UNION ALL
     SELECT  cst_update  dmlmode, unit.rowid,  unit.*
     FROM igs_ad_tundt_int  unit
     WHERE interface_run_id = p_interface_run_id
     AND  status = '2'
     AND INTERFACE_TERM_UNITDTLS_ID BETWEEN cp_start_int_id AND cp_end_int_id		--ARVSRINI--
     AND (       p_rule = 'I'  OR (p_rule = 'R' AND unit.match_ind = cst_mi_val_21))
     AND EXISTS (SELECT 1 FROM igs_ad_term_unitdtls unit_oss
                                          WHERE term_details_id =  unit.term_details_id
                                          AND unit = unit.unit
                        );

   CURSOR  c_dup_cur(term_unit_rec  term_unit_cur%ROWTYPE) IS
    SELECT
       unit_oss.rowid, unit_oss.*
    FROM
	igs_ad_term_unitdtls unit_oss
    WHERE term_details_id =  term_unit_rec.term_details_id
     AND unit = term_unit_rec.unit ;



   l_maxint	NUMBER(15);
   l_minint	NUMBER(15);

    dup_cur_rec   c_dup_cur%ROWTYPE;
    l_prog_label  VARCHAR2(100) := 'igs.plsql.igs_ad_imp_024.process_term_unit_details';
    l_label  VARCHAR2(1000) ;
    l_debug_str VARCHAR2(1000) ;
    l_total_records_prcessed NUMBER;
    l_count_interface_unitdtls_id NUMBER;

 PROCEDURE create_term_unit_details(p_term_unitdtls_record term_unit_cur%ROWTYPE)
   AS
 --------------------------------------------------------------------------
 --  Created By : rboddu
 --  Date Created On : 2001/07/27
 --  Purpose:
 --  Know limitations, enhancements or remarks
 --  Change History
 --  Who             When            What
 --  (reverse chronological order - newest change first)
  --------------------------------------------------------------------------
    l_rowid VARCHAR2(25);
   l_var VARCHAR2(25);
   l_unit_details_id   igs_ad_tundt_int.unit_details_id%TYPE;
   l_msg_at_index   NUMBER := 0;
   l_return_status   VARCHAR2(1);
   l_msg_count      NUMBER ;
   l_msg_data       VARCHAR2(2000);
   l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
   l_error_code VARCHAR2(4) := NULL;
   l_error_text VARCHAR2(2000):= NULL;
    BEGIN
        l_msg_at_index := igs_ge_msg_stack.count_msg;
        SAVEPOINT before_create_unit;
          igs_ad_term_unitdtls_pkg.insert_row(
          l_rowid ,
          l_unit_details_id    ,
          p_term_unitdtls_record.term_details_id ,
          p_term_unitdtls_record.UNIT,
          p_term_unitdtls_record.UNIT_DIFFICULTY ,
          p_term_unitdtls_record.UNIT_NAME,
          p_term_unitdtls_record.CP_ATTEMPTED,
          p_term_unitdtls_record.CP_EARNED ,
          p_term_unitdtls_record.GRADE,
          p_term_unitdtls_record.UNIT_GRADE_POINTS
          );


           UPDATE igs_ad_tundt_int
             SET status = cst_s_val_1,
                 error_code = NULL,
                 unit_details_id = l_unit_details_id
             WHERE interface_term_unitdtls_id = p_term_unitdtls_record.interface_term_unitdtls_id;




      EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK TO before_create_unit;
                igs_ad_gen_016.extract_msg_from_stack (
                          p_msg_at_index                => l_msg_at_index,
                          p_return_status               => l_return_status,
                          p_msg_count                   => l_msg_count,
                          p_msg_data                    => l_msg_data,
                          p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
               IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                   l_error_text := l_msg_data;
                   l_error_code := 'E322';

                   IF p_enable_log = 'Y' THEN
                       igs_ad_imp_001.logerrormessage(p_term_unitdtls_record.interface_term_dtls_id,l_msg_data,'IGS_AD_TUNDT_INT');
                   END IF;
               ELSE
                    l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405);
                    l_error_code := 'E518';
                    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

		          l_label :='igs.plsql.igs_ad_imp_024.create_term_unit_details.exception '||l_msg_data;

			  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			  fnd_message.set_token('INTERFACE_ID', p_term_unitdtls_record.interface_term_dtls_id);
			  fnd_message.set_token('ERROR_CD','E322');

		          l_debug_str :=  fnd_message.get;

                          fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                      END IF;

               END IF;
           UPDATE igs_ad_tundt_int
            SET status = cst_s_val_3,
            error_code = l_error_code,
            error_text = l_error_text,
            match_ind = DECODE (
                                       p_term_unitdtls_record.match_ind,
                                              NULL, cst_mi_val_11,
                                       match_ind)
             WHERE interface_term_unitdtls_id = p_term_unitdtls_record.interface_term_unitdtls_id;
  END create_term_unit_details;

   PROCEDURE update_term_unit_details(p_term_unitdtls_record term_unit_cur%ROWTYPE, dup_cur_rec c_dup_cur%ROWTYPE  )
     AS
   --------------------------------------------------------------------------
   --  Created By : rboddu
   --  Date Created On : 2001/07/27
   --  Purpose:
   --  Know limitations, enhancements or remarks
   --  Change History
   --  Who             When            What
   --  (reverse chronological order - newest change first)
    --------------------------------------------------------------------------
      l_rowid VARCHAR2(25);
     l_var VARCHAR2(25);
     l_msg_at_index   NUMBER := 0;
     l_return_status   VARCHAR2(1);
     l_msg_count      NUMBER ;
     l_msg_data       VARCHAR2(2000);
     l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
     l_error_code VARCHAR2(4) := NULL;
     l_error_text VARCHAR2(2000):= NULL;
      BEGIN
           l_msg_at_index := igs_ge_msg_stack.count_msg;
            SAVEPOINT before_update_unit;
             igs_ad_term_unitdtls_pkg.update_row(
                 X_ROWID             => dup_cur_rec.rowid                        ,
                 X_UNIT_DETAILS_ID   => dup_cur_rec.UNIT_DETAILS_ID      ,
                 X_TERM_DETAILS_ID   => p_term_unitdtls_record.TERM_DETAILS_ID      ,
                 X_UNIT              => p_term_unitdtls_record.UNIT                 ,
                 X_UNIT_DIFFICULTY   => p_term_unitdtls_record.UNIT_DIFFICULTY      ,
                 X_UNIT_NAME         => p_term_unitdtls_record.UNIT_NAME            ,
                 X_CP_ATTEMPTED      => NVL(p_term_unitdtls_record.CP_ATTEMPTED, dup_cur_rec.cp_attempted),
                 X_CP_EARNED         => NVL(p_term_unitdtls_record.CP_EARNED, dup_cur_rec.CP_EARNED),
                 X_GRADE             => NVL(p_term_unitdtls_record.GRADE,dup_cur_rec.GRADE),
                 X_UNIT_GRADE_POINTS => NVL(p_term_unitdtls_record.UNIT_GRADE_POINTS, dup_cur_rec.UNIT_GRADE_POINTS)
                    );

         UPDATE igs_ad_tundt_int
          SET status =cst_s_val_1,
              error_code = cst_ec_val_NULL,
              term_details_id = dup_cur_rec.UNIT_DETAILS_ID
             WHERE interface_term_unitdtls_id = p_term_unitdtls_record.interface_term_unitdtls_id;
        EXCEPTION
        WHEN OTHERS THEN
                  ROLLBACK TO before_update_unit;
                  igs_ad_gen_016.extract_msg_from_stack (
                            p_msg_at_index                => l_msg_at_index,
                            p_return_status               => l_return_status,
                            p_msg_count                   => l_msg_count,
                            p_msg_data                    => l_msg_data,
                            p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
                 IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                     l_error_text := l_msg_data;
                     l_error_code := 'E014';

                     IF p_enable_log = 'Y' THEN
                         igs_ad_imp_001.logerrormessage( p_term_unitdtls_record.interface_term_unitdtls_id,l_msg_data,'IGS_AD_TUNDT_INT');
                     END IF;
                 ELSE
                      l_error_text :=  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405);
                      l_error_code := 'E518';
                      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

   	          l_label := 'igs.plsql.igs_ad_imp_024.update_term_details.exception '||l_msg_data;

   		  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
   		  fnd_message.set_token('INTERFACE_ID',p_term_unitdtls_record.interface_term_unitdtls_id);
   		  fnd_message.set_token('ERROR_CD','E014');

   	          l_debug_str :=  fnd_message.get;

                            fnd_log.string_with_context( fnd_log.level_exception,
   							  l_label,
   							  l_debug_str, NULL,
   							  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                        END IF;

                 END IF;
          UPDATE igs_ad_tundt_int
            SET status = cst_s_val_3,
            error_code = l_error_code,
            error_text = l_error_text,
            match_ind = DECODE (
                                       p_term_unitdtls_record.match_ind,
                                              NULL, cst_mi_val_12,
                                       match_ind)
             WHERE interface_term_unitdtls_id = p_term_unitdtls_record.interface_term_unitdtls_id;
    END update_term_unit_details;



BEGIN

    -- jchin Bug 4629226 Put an error in the int table if record is associated with an external transcript

    UPDATE igs_ad_tundt_int unit
      SET
      status = '3'
      , error_code = 'E334'
      ,error_Text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E334', 8405)
      WHERE interface_run_id = p_interface_run_id
      AND status = '2'
      AND EXISTS (SELECT 1 FROM igs_ad_txcpt_int trans, igs_ad_code_classes_v code,
                  igs_ad_trmdt_int term
                  WHERE trans.interface_transcript_id = term.interface_transcript_id
                  AND term.interface_term_dtls_id = unit.interface_term_dtls_id
                  AND trans.transcript_source = code.code_id
                  AND code.class = 'TRANSCRIPT_SOURCE'
                  AND code.system_status = 'THIRD_PARTY_TRANSFER_EVAL'
                  AND code.class_type_code = 'ADM_CODE_CLASSES');

     COMMIT;

      --1. Set STATUS to 3 for interface records with RULE = E or I and MATCH IND is not null and not '15'
     IF p_rule IN ('E', 'I')  THEN
        UPDATE igs_ad_tundt_int
          SET
          status = '3'
          , error_code = 'E700'
          , error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405)
          WHERE interface_run_id = p_interface_run_id
          AND status = '2'
         AND NVL (match_ind, '15') <> '15';
     END IF;
     COMMIT;

     --	2. Set STATUS to 1 for interface records with RULE = R and MATCH IND = 17,18,19,22,23,24,27
     IF p_rule = 'R'  THEN
        UPDATE igs_ad_tundt_int
        SET
        status = '1',  error_code = NULL
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND match_ind IN ('17', '18', '19', '22', '23', '24', '27');
     END IF;
     COMMIT;

   -- 5. Set STATUS to 1 and MATCH IND to 19 for interface records with RULE = E matching OSS record(s)
  IF  p_rule = 'E' THEN
      UPDATE igs_ad_tundt_int  unit
      SET
         status = '1'
        , match_ind = '19'
      WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND  EXISTS ( SELECT 1 FROM igs_ad_term_unitdtls unit_oss
                                          WHERE term_details_id =  unit.term_details_id
                                          AND unit = unit.unit
                         );
  END IF;
COMMIT;

/**********************************************************************************
Create / Update the OSS record after validating successfully the interface record
Create
    If RULE I (match indicator will be 15 or NULL by now no need to check) and matching system record not found OR
    RULE = R and MATCH IND = 16, 25
Update
    If RULE = I (match indicator will be 15 or NULL by now no need to check) OR
    RULE = R and MATCH IND = 21

Selecting together the interface records for INSERT / UPDATE with DMLMODE identifying the DML operation.
This is done to have one code section for record validation, exception handling and interface table update.
This avoids call to separate PLSQL blocks, tuning performance on stack maintenance during the process.

**********************************************************************************/

l_total_records_prcessed := 0;
  SELECT COUNT(interface_term_unitdtls_id) INTO l_count_interface_unitdtls_id
  FROM  igs_ad_tundt_int
  WHERE interface_run_id = p_interface_run_id
  AND status =2 ;

LOOP
EXIT WHEN l_total_records_prcessed >= l_count_interface_unitdtls_id;

SELECT
 MIN(interface_term_unitdtls_id) , MAX(interface_term_unitdtls_id)
 INTO l_minint , l_maxint
FROM igs_ad_tundt_int
WHERE interface_run_id = p_interface_run_id
 AND status =2
 AND rownum < =100;

FOR term_unit_cur_rec IN term_unit_cur(l_minint,l_minint+99)					--arvsrini
LOOP
       IF term_unit_cur_rec.dmlmode =  cst_insert  THEN
           create_term_unit_details(term_unit_cur_rec);
       ELSIF  term_unit_cur_rec.dmlmode = cst_update THEN
          OPEN c_dup_cur(term_unit_cur_rec);
          FETCH c_dup_cur INTO dup_cur_rec;
          CLOSE c_dup_cur;
           update_term_unit_details(term_unit_cur_rec, dup_cur_rec);
       END IF;
       l_total_records_prcessed := l_total_records_prcessed + 1;

 END LOOP;
         COMMIT;



END LOOP;

 /*Set STATUS to 1 and MATCH IND to 23 for interface records with RULE = R matching OSS record(s) in
   ALL updateable column values, if column nullification is not allowed then the 2 DECODE should be replaced by a single NVL*/
     IF p_rule = 'R'  THEN
       UPDATE igs_ad_tundt_int  unit
       SET
         status = '1'
         , match_ind = '23'
       WHERE interface_run_id = p_interface_run_id
       AND status = '2'
       AND NVL (match_ind, '15') = '15'
       AND EXISTS (  SELECT 1  FROM igs_ad_term_unitdtls
                             WHERE   NVL(UNIT,'X')          = NVL(unit.UNIT,'X')          AND
                                          NVL(UNIT_DIFFICULTY,-1) = NVL(unit.UNIT_DIFFICULTY,-1) AND
                                          NVL(UNIT_NAME,'X')     = NVL(unit.UNIT_NAME,'X')     AND
                                          NVL(CP_ATTEMPTED,-1)    = NVL(unit.CP_ATTEMPTED,-1)    AND
                                          NVL(CP_EARNED,-1)       = NVL(unit.CP_EARNED,-1)       AND
                                          NVL(GRADE,'X')         = NVL(unit.GRADE,'X')         AND
                                          NVL(UNIT_GRADE_POINTS,-1) = NVL(unit.UNIT_GRADE_POINTS,-1)
                );
     END IF;
     COMMIT;

 --Set STATUS to 3 and MATCH IND = 20 for interface records with RULE = R and
 --MATCH IND <> 21, 25, ones failed above discrepancy check
     IF p_rule = 'R'  THEN
       UPDATE igs_ad_tundt_int  unit
        SET
        status = '3'
        , match_ind = '20'
        , dup_term_unitdtls_id = ( SELECT  unit_details_id
                                          FROM igs_ad_term_unitdtls unit_oss
                                          WHERE term_details_id =  unit.term_details_id
                                          AND unit = unit.unit )
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND NVL (match_ind, '15') = '15'
        AND EXISTS (SELECT  1
                                          FROM igs_ad_term_unitdtls unit_oss
                                          WHERE term_details_id =  unit.term_details_id
                                          AND unit = unit.unit );

     END IF;
     COMMIT;


  --Set STATUS to 3 for interface records with RULE = R and invalid MATCH IND
     IF p_rule = 'R'  THEN
       UPDATE igs_ad_tundt_int  unit
        SET
        status = '3'
        , error_code = 'E700'
        , error_text  = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405)
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND match_ind IS NOT NULL;
     END IF;
     COMMIT;

END  process_term_unit_details;


END igs_ad_imp_024;

/
