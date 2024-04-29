--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_016
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_016" AS
/* $Header: IGSAD94B.pls 120.4 2006/08/02 13:10:03 pbondugu ship $ */
/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
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


cst_insert     CONSTANT VARCHAR2(6) :=  'INSERT';
cst_update     CONSTANT VARCHAR2(6) :=  'UPDATE';
cst_dsp        CONSTANT VARCHAR2(10) :=  'DSPCHECK';

cst_unique_record   CONSTANT NUMBER :=  1;

cst_et_val_E700 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405);
cst_et_val_E701 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E701', 8405);
cst_et_val_E678 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E678', 8405);
cst_et_val_E347 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E347', 8405);
cst_et_val_E577 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E577', 8405);
cst_et_val_E705 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E705', 8405);
cst_et_val_E322 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E322', 8405);
cst_et_val_E014 VARCHAR2(100) := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E014', 8405);


cst_ec_val_E322  VARCHAR2(4) := 'E322';
cst_ec_val_E014  VARCHAR2(4) := 'E014';
cst_ec_val_E700  VARCHAR2(4) := 'E700';
cst_ec_val_E701  VARCHAR2(4) := 'E701';
cst_ec_val_E347  VARCHAR2(4) := 'E347';
cst_ec_val_E678  VARCHAR2(4) := 'E678';
cst_ec_val_E577  VARCHAR2(4) := 'E577';
cst_ec_val_E705  VARCHAR2(4) := 'E705';


/***************************Status,Discrepancy Rule, Match Indicators, Error Codes********************/

PROCEDURE crt_upd_tst_rslts(p_interface_run_id NUMBER,
                            p_rule VARCHAR2,
                            p_enable_log VARCHAR2)
AS
/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
******************************************************************/
  CURSOR c_igs_ad_test_int (cp_lower_bound igs_ad_test_int.interface_test_id%TYPE,cp_higher_bound igs_ad_test_int.interface_test_id%TYPE) IS
    SELECT cst_insert dmlmode, rowid, in_rec.*
    FROM   igs_ad_test_int in_rec
    WHERE  interface_run_id = p_interface_run_id
    AND    status = cst_s_val_2
    AND    interface_test_id between cp_lower_bound and cp_higher_bound
    AND    ((    NVL(match_ind,'15') = '15'
             AND NOT EXISTS (SELECT 1
                             FROM igs_ad_test_results mn_rec
                             WHERE mn_rec.person_id = in_rec.person_id
                             AND   mn_rec.admission_test_type = in_rec.admission_test_type
                             AND   TRUNC(mn_rec.test_date) = TRUNC(in_rec.test_date)))
            OR (    p_rule = cst_rule_val_R
                AND match_ind IN (cst_mi_val_16, cst_mi_val_25)))
    UNION ALL
    SELECT cst_update dmlmode, rowid, in_rec.*
    FROM   igs_ad_test_int in_rec
    WHERE  interface_run_id = p_interface_run_id
    AND    status = cst_s_val_2
    AND    interface_test_id between cp_lower_bound and cp_higher_bound
    AND    (   (p_rule = cst_rule_val_I)
            OR (p_rule = cst_rule_val_R AND match_ind = cst_mi_val_21))
    AND    EXISTS (SELECT 1
                   FROM igs_ad_test_results mn_rec
                   WHERE mn_rec.person_id = in_rec.person_id
                   AND   mn_rec.admission_test_type = in_rec.admission_test_type
                   AND   TRUNC(mn_rec.test_date) = TRUNC(in_rec.test_date))

    UNION ALL
    SELECT cst_dsp dmlmode, rowid, in_rec.*
    FROM   igs_ad_test_int in_rec
    WHERE  interface_run_id = p_interface_run_id
    AND    status = cst_s_val_1
    AND    interface_test_id between cp_lower_bound and cp_higher_bound
    AND    NVL(match_ind,cst_mi_val_15) in ( cst_mi_val_15,cst_mi_val_23)
    AND    EXISTS (SELECT 1  FROM IGS_AD_TEST_SEGS_INT testsegsint
	             WHERE  testsegsint.status  = cst_s_val_2
		     AND in_rec.INTERFACE_TEST_ID = testsegsint.interface_test_id
		   );



  CURSOR c_igs_ad_test_segs_int(cp_interface_test_id igs_ad_test_segs_int.interface_test_id%TYPE) IS
    SELECT cst_insert dmlmode, rowid, in_rec.*
    FROM   igs_ad_test_segs_int in_rec
    WHERE  status = cst_s_val_2
    AND    interface_test_id = cp_interface_test_id
    AND    ((    NVL(match_ind,'15') = '15'
             AND NOT EXISTS (SELECT 1
                             FROM igs_ad_tst_rslt_dtls mn_rec
                             WHERE mn_rec.test_results_id = in_rec.test_results_id
                             AND   mn_rec.test_segment_id = in_rec.test_segment_id))
            OR (   p_rule = cst_rule_val_R
                AND match_ind IN (cst_mi_val_16, cst_mi_val_25)))
    UNION ALL
    SELECT cst_update dmlmode, rowid, in_rec.*
    FROM   igs_ad_test_segs_int in_rec
    WHERE  status = cst_s_val_2
    AND    interface_test_id = cp_interface_test_id
    AND    (   (p_rule = cst_rule_val_I)
            OR (p_rule = cst_rule_val_R AND match_ind = cst_mi_val_21))
    AND     EXISTS (SELECT 1
                    FROM igs_ad_tst_rslt_dtls mn_rec
                    WHERE mn_rec.test_results_id = in_rec.test_results_id
                    AND   mn_rec.test_segment_id = in_rec.test_segment_id);

  CURSOR c_null_hdlg_tst_rsl_cur(cp_tst_rsl_cur c_igs_ad_test_int%ROWTYPE) IS
    SELECT ROWID, ar.*
    FROM   igs_ad_test_results ar
    WHERE  ar.person_id = cp_tst_rsl_cur.person_id
    AND    ar.admission_test_type = cp_tst_rsl_cur.admission_test_type
    AND    TRUNC(ar.test_date) = TRUNC(cp_tst_rsl_cur.test_date);

  c_null_hdlg_test_rec c_null_hdlg_tst_rsl_cur%ROWTYPE;

  CURSOR c_null_hdlg_tst_dtls_cur(cp_test_segment_id igs_ad_test_segs_int.test_segment_id%TYPE,
                               cp_test_results_id igs_ad_tst_rslt_dtls.test_results_id%TYPE) IS
    SELECT ROWID, ar.*
    FROM   igs_ad_tst_rslt_dtls ar
    WHERE  test_results_id = cp_test_results_id
    AND    test_segment_id = cp_test_segment_id;

  c_null_hdlg_tst_dtls_rec c_null_hdlg_tst_dtls_cur%ROWTYPE;

  CURSOR c_test_type_cur ( x_admission_test_type  igs_ad_test_type.admission_test_type%TYPE ) IS
    SELECT score_type
    FROM igs_ad_test_type
    WHERE admission_test_type = x_admission_test_type ;


  l_count_seg  NUMBER(15);
  l_success    BOOLEAN := TRUE;

  l_score_type  igs_ad_test_type.score_type%TYPE;
  l_status           VARCHAR2(1);
  l_error_code       VARCHAR2(30);
  l_error_text       VARCHAR2(2000);
  l_msg_at_index   NUMBER := 0;
  l_return_status   VARCHAR2(1);
  l_msg_count      NUMBER ;
  l_msg_data       VARCHAR2(2000);
  l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;

  l_records_processed  NUMBER;
  l_rowid VARCHAR2(30);
  l_tst_rslt_dtls_id igs_ad_tst_rslt_dtls.tst_rslt_dtls_id%TYPE;
  l_test_results_id  igs_ad_test_results.test_results_id%TYPE;

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_request_id NUMBER;

  l_min_tst_interface_id igs_ad_test_int.interface_test_id%TYPE;
  l_max_tst_interface_id igs_ad_test_int.interface_test_id%TYPE;

  l_count_interface_testint_id NUMBER;
  l_total_records_prcessed NUMBER;

  test_seg_failed EXCEPTION;

  PROCEDURE upd_tst_dtls_atm_bef ( p_interface_test_id igs_ad_test_segs_int.interface_test_id%TYPE,
                                   p_test_results_id igs_ad_tst_rslt_dtls.test_results_id%TYPE,
                                   p_success IN OUT NOCOPY BOOLEAN) AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF p_rule IN ('E','I') AND p_success THEN
      UPDATE igs_ad_test_segs_int
      SET
             status = cst_s_val_3
             , error_code = cst_ec_val_E700
             , error_text = cst_et_val_E700
      WHERE status = '2'
      AND NVL (match_ind, cst_mi_val_15) <> cst_mi_val_15
      AND interface_test_id = p_interface_test_id;
      IF SQL%ROWCOUNT > 0 THEN
        p_success := FALSE;
      END IF;
      COMMIT;
    END IF;

    -- Set STATUS to 1 for interface records with RULE = R and
    -- MATCH IND = 17,18,19,22,23,24,27
    IF p_rule IN ('R') AND p_success THEN
        UPDATE igs_ad_test_segs_int
        SET
               status = cst_s_val_1
        WHERE status = '2'
        AND match_ind IN (cst_mi_val_17, cst_mi_val_18, cst_mi_val_19,
                          cst_mi_val_22, cst_mi_val_23, cst_mi_val_24, cst_mi_val_27)
        AND interface_test_id = p_interface_test_id;
        COMMIT;
    END IF;

    -- Set STATUS to 1 and MATCH IND to 19 for interface records with RULE =
    -- E matching OSS record(s)
    IF p_rule IN ('E') AND p_success THEN
        UPDATE igs_ad_test_segs_int in_rec
        SET
               status = cst_s_val_1
               , match_ind = cst_mi_val_19
        WHERE status = '2'
        AND interface_test_id = p_interface_test_id
        AND   EXISTS ( SELECT 1
                       FROM igs_ad_tst_rslt_dtls mn_rec
                       WHERE mn_rec.test_results_id = p_test_results_id
                       AND   mn_rec.test_segment_id = in_rec.test_segment_id);
        COMMIT;
    END IF;

  END upd_tst_dtls_atm_bef;

  PROCEDURE upd_tst_dtls_atm_s3 ( p_interface_test_id igs_ad_test_segs_int.interface_test_id%TYPE,
                                  p_success IN OUT NOCOPY BOOLEAN) AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF p_rule IN ('E','I') AND p_success THEN
      UPDATE igs_ad_test_segs_int
      SET
             status = cst_s_val_3
             , error_code = cst_ec_val_E700
             , error_text = cst_et_val_E700
      WHERE status = '2'
      AND NVL (match_ind, cst_mi_val_15) <> cst_mi_val_15
      AND interface_test_id = p_interface_test_id;
      IF SQL%ROWCOUNT > 0 THEN
        p_success := FALSE;
      END IF;
      COMMIT;
    END IF;

    IF p_rule IN ('R') AND p_success THEN
      UPDATE igs_ad_test_segs_int
      SET
             status = cst_s_val_3
             , error_code = cst_ec_val_E700
             , error_text = cst_et_val_E700
      WHERE status = '2'
      AND NVL (match_ind, cst_mi_val_15) NOT IN (cst_mi_val_15,cst_mi_val_16,cst_mi_val_25)
      AND interface_test_id = p_interface_test_id;
      IF SQL%ROWCOUNT > 0 THEN
        p_success := FALSE;
      END IF;
      COMMIT;
    END IF;
  END upd_tst_dtls_atm_s3;


  PROCEDURE upd_tst_dtls_atm_s1 ( p_rowid VARCHAR2,
                                  p_mode  VARCHAR2) AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE igs_ad_test_segs_int
    SET
           status = cst_s_val_1
           , match_ind =  DECODE(match_ind,
                                 NULL, DECODE (p_mode,
                                               cst_update, cst_mi_val_18,
                                               cst_insert, cst_mi_val_11)
                                 ,match_ind)
    WHERE rowid = p_rowid;
    COMMIT;
  END upd_tst_dtls_atm_s1;


  PROCEDURE upd_tst_dtls_atm_aft ( p_interface_test_id igs_ad_test_segs_int.interface_test_id%TYPE,
                                   p_mode  VARCHAR2,
                                   p_success IN OUT NOCOPY BOOLEAN) AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF (p_mode = cst_update OR p_mode = cst_dsp ) AND p_success THEN
      IF p_rule IN ('R') THEN
	  UPDATE igs_ad_test_segs_int in_rec
          SET
                 status = cst_s_val_1
                 , match_ind = cst_mi_val_23
          WHERE status = cst_s_val_2
          AND interface_test_id = p_interface_test_id
          AND NVL (match_ind, cst_mi_val_15) = cst_mi_val_15
          AND EXISTS (
                        SELECT 1
                        FROM igs_ad_tst_rslt_dtls mn_rec
                        WHERE  mn_rec.test_results_id =                       in_rec.test_results_id
			AND    mn_rec.test_segment_id   =                     in_rec.test_segment_id
			AND    NVL(mn_rec.percentile,-99) =                   NVL(in_rec.percentile,NVL(mn_rec.percentile,-99))
                        AND    NVL(mn_rec.national_percentile,-99) =          NVL(in_rec.national_percentile,NVL(mn_rec.national_percentile,-99))
                        AND    NVL(mn_rec.state_percentile,-99) =             NVL(in_rec.state_percentile,NVL(mn_rec.state_percentile,-99))
                        AND    NVL(mn_rec.percentile_year_rank,-99) =         NVL(in_rec.percentile_year_rank,NVL(mn_rec.percentile_year_rank,-99))
                        AND    NVL(mn_rec.score_band_upper,-99) =             NVL(in_rec.score_band_upper,NVL(mn_rec.score_band_upper,-99))
                        AND    NVL(mn_rec.score_band_lower,-99) =             NVL(in_rec.score_band_lower,NVL(mn_rec.score_band_lower,-99))
                        AND    NVL(mn_rec.irregularity_code_id,-99) =         NVL(in_rec.irregularity_code,NVL(mn_rec.irregularity_code_id,-99))
                        AND    NVL(mn_rec.test_score,-99) =                   NVL(in_rec.test_score,NVL(mn_rec.test_score,-99))
			AND    NVL(mn_rec.attribute_category,-99) =           NVL(in_rec.attribute_category,NVL(mn_rec.attribute_category,-99))
			AND    NVL(mn_rec.attribute1,-99) =                   NVL(in_rec.attribute1,NVL(mn_rec.attribute1,-99))
			AND    NVL(mn_rec.attribute2,-99) =                   NVL(in_rec.attribute2,NVL(mn_rec.attribute2,-99))
			AND    NVL(mn_rec.attribute3,-99) =                   NVL(in_rec.attribute3,NVL(mn_rec.attribute3,-99))
			AND    NVL(mn_rec.attribute4,-99) =                   NVL(in_rec.attribute4,NVL(mn_rec.attribute4,-99))
			AND    NVL(mn_rec.attribute5,-99) =                   NVL(in_rec.attribute5,NVL(mn_rec.attribute5,-99))
			AND    NVL(mn_rec.attribute6,-99) =                   NVL(in_rec.attribute6,NVL(mn_rec.attribute6,-99))
			AND    NVL(mn_rec.attribute7,-99) =                   NVL(in_rec.attribute7,NVL(mn_rec.attribute7,-99))
			AND    NVL(mn_rec.attribute8,-99) =                   NVL(in_rec.attribute8,NVL(mn_rec.attribute8,-99))
			AND    NVL(mn_rec.attribute9,-99) =                   NVL(in_rec.attribute9,NVL(mn_rec.attribute9,-99))
			AND    NVL(mn_rec.attribute10,-99) =                  NVL(in_rec.attribute10,NVL(mn_rec.attribute10,-99))
			AND    NVL(mn_rec.attribute11,-99) =                  NVL(in_rec.attribute11,NVL(mn_rec.attribute11,-99))
			AND    NVL(mn_rec.attribute12,-99) =                  NVL(in_rec.attribute12,NVL(mn_rec.attribute12,-99))
			AND    NVL(mn_rec.attribute13,-99) =                  NVL(in_rec.attribute13,NVL(mn_rec.attribute13,-99))
			AND    NVL(mn_rec.attribute14,-99) =                  NVL(in_rec.attribute14,NVL(mn_rec.attribute14,-99))
			AND    NVL(mn_rec.attribute15,-99) =                  NVL(in_rec.attribute15,NVL(mn_rec.attribute15,-99))
			AND    NVL(mn_rec.attribute16,-99) =                  NVL(in_rec.attribute16,NVL(mn_rec.attribute16,-99))
			AND    NVL(mn_rec.attribute17,-99) =                  NVL(in_rec.attribute17,NVL(mn_rec.attribute17,-99))
			AND    NVL(mn_rec.attribute18,-99) =                  NVL(in_rec.attribute18,NVL(mn_rec.attribute18,-99))
			AND    NVL(mn_rec.attribute19,-99) =                  NVL(in_rec.attribute19,NVL(mn_rec.attribute19,-99))
			AND    NVL(mn_rec.attribute20,-99) =                  NVL(in_rec.attribute20,NVL(mn_rec.attribute20,-99))
                       );
	  COMMIT;
      END IF;

      -- Set STATUS to 3 and MATCH IND = 20 for interface records with RULE = R and MATCH IND
      -- <> 21, 25, ones failed discrepancy check
      IF p_rule IN ('R') AND p_success THEN
          UPDATE igs_ad_test_segs_int in_rec
          SET
                status = cst_s_val_3
                , match_ind = cst_mi_val_20
          WHERE status = cst_s_val_2
          AND interface_test_id = p_interface_test_id
          AND NVL (match_ind, cst_mi_val_15) = cst_mi_val_15
          AND EXISTS ( SELECT rowid
                       FROM igs_ad_tst_rslt_dtls mn_rec
                       WHERE mn_rec.test_results_id = in_rec.test_results_id
                       AND   mn_rec.test_segment_id = in_rec.test_segment_id);
          IF SQL%ROWCOUNT > 0 THEN
            p_success := FALSE;
          END IF;
          COMMIT;
      END IF;
    END IF;

    -- Set STATUS to 3 for interface records with RULE = R and invalid MATCH IND
    IF p_rule IN ('R') AND p_success THEN
        UPDATE igs_ad_test_segs_int
        SET
               status = cst_s_val_3
               , error_code = cst_ec_val_E700
               , error_text = cst_et_val_E700
        WHERE interface_test_id = p_interface_test_id
        AND status = cst_s_val_2
        AND match_ind IS NOT NULL;
        IF SQL%ROWCOUNT > 0 THEN
          p_success := FALSE;
        END IF;
        COMMIT;
    END IF;
  END upd_tst_dtls_atm_aft;


  PROCEDURE upd_tst_dtls_atm_exp ( p_interface_test_id igs_ad_test_segs_int.interface_test_id%TYPE,
                                   p_rowid VARCHAR2,
                                   p_mode  VARCHAR2,
                                   p_error_code VARCHAR2,
                                   p_error_text VARCHAR2) AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

    UPDATE igs_ad_test_segs_int
    SET
           status = cst_s_val_3
           , match_ind =  DECODE(match_ind,
                                 NULL, DECODE (p_mode,
                                               cst_update, cst_mi_val_18,
                                               cst_insert, cst_mi_val_11)
                                 ,match_ind)
           , error_code = p_error_code
           , error_text = p_error_text
    WHERE status IN ('1','2')
    AND interface_test_id = p_interface_test_id
    AND rowid = p_rowid;

    UPDATE igs_ad_test_segs_int
    SET
           status = cst_s_val_3
           , match_ind =  DECODE(match_ind,
                                 NULL, DECODE (p_mode,
                                               cst_update, cst_mi_val_18,
                                               cst_insert, cst_mi_val_11)
                                 ,match_ind)
           , error_code = DECODE (p_mode, cst_update, cst_ec_val_E014,
                                          cst_insert, cst_ec_val_E322)
           , error_text = DECODE (p_mode, cst_update, cst_et_val_E014,
                                          cst_insert, cst_et_val_E322)
    WHERE status IN ('1','2')
    AND interface_test_id = p_interface_test_id
    AND rowid <> p_rowid;

    COMMIT;
  END upd_tst_dtls_atm_exp;

  PROCEDURE upd_tst_dtls_atm_s2 ( p_interface_test_id igs_ad_test_segs_int.interface_test_id%TYPE,
                                  p_test_results_id  igs_ad_test_segs_int.test_results_id%TYPE) AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

    UPDATE igs_ad_test_segs_int
    SET    test_results_id = p_test_results_id
    WHERE status = '2'
    AND interface_test_id = p_interface_test_id;

    COMMIT;
  END upd_tst_dtls_atm_s2;


BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN


    l_label := 'igs.plsql.igs_ad_imp_016.prc_tst_rslts.crt_upd_tst_rslts';
    l_debug_str :=  'Interface Run ID' || p_interface_run_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
    			         l_label,
			         l_debug_str, NULL,
			         NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  l_records_processed := 0;
  l_total_records_prcessed := 0;


 -- Check for current/past dated test result without test segments

  UPDATE igs_ad_test_int tst_int
  SET    status = cst_s_val_3
         ,error_code = cst_ec_val_E705
         ,error_text = cst_et_val_E705
  WHERE  tst_int.interface_run_id = p_interface_run_id
  AND    tst_int.status IN (cst_s_val_2,cst_s_val_1)
  AND    TRUNC(tst_int.test_date) <= TRUNC(SYSDATE)
  AND    NOT EXISTS (SELECT 1
                     FROM   igs_ad_test_segs_int tst_seg_int
                     WHERE  tst_seg_int.interface_test_id = tst_int.interface_test_id
                     AND    status = '2'
                     UNION
                     SELECT 1
                     FROM   igs_ad_tst_rslt_dtls a, igs_ad_test_results b
                     WHERE  person_id = tst_int.person_id
                     AND    admission_test_type = tst_int.admission_test_type
                     AND    TRUNC(test_date) = tst_int.test_date
                     AND    a.test_results_id = b.test_results_id);

  IF SQL%ROWCOUNT > 0 THEN
    COMMIT;
  END IF;

  l_total_records_prcessed := 0;

  SELECT COUNT(interface_test_id) INTO l_count_interface_testint_id
  FROM IGS_AD_TEST_INT testint
  WHERE interface_run_id = p_interface_run_id
  AND (status = cst_s_val_2 OR
        (status = cst_s_val_1 AND NVL(match_ind,cst_mi_val_15) in ( cst_mi_val_15,cst_mi_val_23)
	 AND EXISTS (SELECT 1  FROM IGS_AD_TEST_SEGS_INT testsegsint
	             WHERE  testsegsint.status  = cst_s_val_2
		     AND testint.INTERFACE_TEST_ID = testsegsint.interface_test_id
		     )
	 )
       );


  LOOP
  EXIT WHEN l_total_records_prcessed >= l_count_interface_testint_id;

  SELECT
       MIN(interface_test_id) , MAX(interface_test_id)
   INTO l_min_tst_interface_id , l_max_tst_interface_id
   FROM IGS_AD_TEST_INT  testint
   WHERE interface_run_id = p_interface_run_id
   AND (status = cst_s_val_2 OR
        (status = cst_s_val_1 AND NVL(match_ind,cst_mi_val_15) in ( cst_mi_val_15,cst_mi_val_23)
	 AND EXISTS (SELECT 1  FROM IGS_AD_TEST_SEGS_INT testsegsint
	             WHERE  testsegsint.status  = cst_s_val_2
		     AND testint.INTERFACE_TEST_ID = testsegsint.interface_test_id
		     )
	 )
        )
   AND rownum <= 100;


    FOR test_rec IN c_igs_ad_test_int(l_min_tst_interface_id,l_max_tst_interface_id)
    LOOP

      BEGIN
        l_error_text :='A';
        SAVEPOINT test_results_sp;
        l_msg_at_index := igs_ge_msg_stack.count_msg;

        l_success := TRUE;
        -- Check for future dated test result with test segments

        UPDATE igs_ad_test_int
        SET    status = cst_s_val_3
               ,error_code = cst_ec_val_E577
               ,error_text = cst_et_val_E577
        WHERE  interface_test_id = test_rec.interface_test_id
        AND    TRUNC(test_date) > TRUNC(SYSDATE)
        AND    EXISTS (SELECT 1
                      FROM   igs_ad_test_segs_int
                      WHERE  interface_test_id = test_rec.interface_test_id
                      AND    status = '2');
        IF SQL%ROWCOUNT > 0 THEN
          COMMIT;
        ELSE
          l_error_text := NULL;
        END IF;



        IF l_error_text IS NULL THEN
          l_score_type   := NULL ;

          OPEN c_test_type_cur( test_rec.admission_test_type );
          FETCH c_test_type_cur INTO l_score_type ;
          CLOSE c_test_type_cur;

          IF test_rec.dmlmode = cst_insert THEN
            l_rowid := NULL;
            l_test_results_id := NULL;

            Igs_Ad_Test_Results_Pkg.Insert_Row (
              x_rowid               => l_rowid,
              x_test_results_id     => l_test_results_id,
              x_person_id           => test_rec.person_id,
              x_admission_test_type => test_rec.admission_test_type,
              x_test_date           => test_rec.test_date,
              x_score_report_date   => test_rec.score_report_date,
              x_edu_level_id        => test_rec.edu_level_id,
              x_score_type          => l_score_type,
              x_score_source_id     => test_rec.score_source_id,
              x_non_standard_admin  => NVL(test_rec.non_standard_admin,'N'),
              x_comp_test_score     => NULL,
              x_special_code        => test_rec.special_code,
              x_registration_number => test_rec.registration_number,
              x_grade_id            => test_rec.grade_id,
              x_attribute_category  => test_rec.attribute_category,
              x_attribute1          => test_rec.attribute1,
              x_attribute2          => test_rec.attribute2,
              x_attribute3          => test_rec.attribute3,
              x_attribute4          => test_rec.attribute4,
              x_attribute5          => test_rec.attribute5,
              x_attribute6          => test_rec.attribute6,
              x_attribute7          => test_rec.attribute7,
              x_attribute8          => test_rec.attribute8,
              x_attribute9          => test_rec.attribute9,
              x_attribute10         => test_rec.attribute10,
              x_attribute11         => test_rec.attribute11,
              x_attribute12         => test_rec.attribute12,
              x_attribute13         => test_rec.attribute13,
              x_attribute14         => test_rec.attribute14,
              x_attribute15         => test_rec.attribute15,
              x_attribute16         => test_rec.attribute16,
              x_attribute17         => test_rec.attribute17,
              x_attribute18         => test_rec.attribute18,
              x_attribute19         => test_rec.attribute19,
              x_attribute20         => test_rec.attribute20,
              x_active_ind          => test_rec.active_ind,
              x_mode                => 'R'
              );

          ELSIF test_rec.dmlmode = cst_update THEN

            OPEN  c_null_hdlg_tst_rsl_cur(test_rec);
            FETCH c_null_hdlg_tst_rsl_cur INTO c_null_hdlg_test_rec;
            CLOSE c_null_hdlg_tst_rsl_cur;

            l_test_results_id := c_null_hdlg_test_rec.test_results_id;


            Igs_Ad_Test_Results_Pkg.update_row(
                     x_rowid                => c_null_hdlg_test_rec.ROWID,
                     x_test_results_id      => c_null_hdlg_test_rec.test_results_id,
                     x_person_id            => NVL(test_rec.person_id,c_null_hdlg_test_rec.person_id),
                     x_admission_test_type  => NVL(test_rec.admission_test_type,c_null_hdlg_test_rec.admission_test_type),
                     x_test_date            => NVL(test_rec.test_date,c_null_hdlg_test_rec.test_date),
                     x_score_report_date    => NVL(test_rec.score_report_date,c_null_hdlg_test_rec.score_report_date),
                     x_edu_level_id         => NVL(test_rec.edu_level_id,c_null_hdlg_test_rec.edu_level_id),
                     x_score_type           => NVL(l_score_type, c_null_hdlg_test_rec.score_type) ,
                     x_score_source_id      => NVL(test_rec.score_source_id,c_null_hdlg_test_rec.score_source_id),
                     x_non_standard_admin   => NVL(test_rec.non_standard_admin,c_null_hdlg_test_rec.non_standard_admin),
                     x_comp_test_score      => c_null_hdlg_test_rec.comp_test_score,
                     x_special_code         => NVL(test_rec.special_code,c_null_hdlg_test_rec.special_code),
                     x_registration_number  => NVL(test_rec.registration_number,c_null_hdlg_test_rec.registration_number),
                     x_grade_id             => NVL(test_rec.grade_id,c_null_hdlg_test_rec.grade_id),
                     x_attribute_category   => NVL(test_rec.attribute_category,c_null_hdlg_test_rec.attribute_category),
                     x_attribute1           => NVL(test_rec.attribute1,c_null_hdlg_test_rec.attribute1),
                     x_attribute2           => NVL(test_rec.attribute2,c_null_hdlg_test_rec.attribute2),
                     x_attribute3           => NVL(test_rec.attribute3,c_null_hdlg_test_rec.attribute3),
                     x_attribute4           => NVL(test_rec.attribute4,c_null_hdlg_test_rec.attribute4),
                     x_attribute5           => NVL(test_rec.attribute5,c_null_hdlg_test_rec.attribute5),
                     x_attribute6           => NVL(test_rec.attribute6,c_null_hdlg_test_rec.attribute6),
                     x_attribute7           => NVL(test_rec.attribute7,c_null_hdlg_test_rec.attribute7),
                     x_attribute8           => NVL(test_rec.attribute8,c_null_hdlg_test_rec.attribute8),
                     x_attribute9           => NVL(test_rec.attribute9,c_null_hdlg_test_rec.attribute9),
                     x_attribute10          => NVL(test_rec.attribute10,c_null_hdlg_test_rec.attribute10),
                     x_attribute11          => NVL(test_rec.attribute11,c_null_hdlg_test_rec.attribute11),
                     x_attribute12          => NVL(test_rec.attribute12,c_null_hdlg_test_rec.attribute12),
                     x_attribute13          => NVL(test_rec.attribute13,c_null_hdlg_test_rec.attribute13),
                     x_attribute14          => NVL(test_rec.attribute14,c_null_hdlg_test_rec.attribute14),
                     x_attribute15          => NVL(test_rec.attribute15,c_null_hdlg_test_rec.attribute15),
                     x_attribute16          => NVL(test_rec.attribute16,c_null_hdlg_test_rec.attribute16),
                     x_attribute17          => NVL(test_rec.attribute17,c_null_hdlg_test_rec.attribute17),
                     x_attribute18          => NVL(test_rec.attribute18,c_null_hdlg_test_rec.attribute18),
                     x_attribute19          => NVL(test_rec.attribute19,c_null_hdlg_test_rec.attribute19),
                     x_attribute20          => NVL(test_rec.attribute20,c_null_hdlg_test_rec.attribute20),
                     x_active_ind           => NVL(test_rec.active_ind, c_null_hdlg_test_rec.active_ind),
                     x_mode                 => 'R'
                  );
          ELSIF test_rec.dmlmode = cst_dsp THEN
          l_test_results_id := test_rec.test_results_id;
          END IF;

          BEGIN -- Test Result Details

            upd_tst_dtls_atm_s2(test_rec.interface_test_id,l_test_results_id);

            IF test_rec.dmlmode = cst_insert THEN
              l_success := TRUE;
              upd_tst_dtls_atm_s3(test_rec.interface_test_id,l_success);
            ELSIF test_rec.dmlmode = cst_update OR test_rec.dmlmode = cst_dsp THEN
              l_success := TRUE;
              -- Autonomous Transaction to update error status for Test Details interface table;
              upd_tst_dtls_atm_bef(test_rec.interface_test_id,l_test_results_id,l_success);
            END IF;


            IF l_success THEN
              FOR test_dtls_rec IN c_igs_ad_test_segs_int(test_rec.interface_test_id)
              LOOP
                BEGIN
                  l_msg_at_index := igs_ge_msg_stack.count_msg;

                  IF test_dtls_rec.dmlmode = cst_insert THEN
                    l_rowid := NULL;
                    Igs_Ad_Tst_Rslt_Dtls_Pkg.Insert_Row (
                              x_rowId                => l_rowid,
                              x_tst_rslt_dtls_id     => l_tst_rslt_dtls_id,
                              x_test_results_id      => l_test_results_id,
                              x_test_segment_id      => test_dtls_rec.test_segment_id,
                              x_test_score           => test_dtls_rec.test_score,
                              x_percentile           => test_dtls_rec.percentile,
                              x_national_percentile  => test_dtls_rec.national_percentile,
                              x_state_percentile     => test_dtls_rec.state_percentile,
                              x_percentile_year_rank => test_dtls_rec.percentile_year_rank,
                              x_score_band_lower     => test_dtls_rec.score_band_lower,
                              x_score_band_upper     => test_dtls_rec.score_band_upper,
                              x_irregularity_code_id => test_dtls_rec.irregularity_code,
                              x_attribute_category   => test_dtls_rec.attribute_category,
                              x_attribute1           => test_dtls_rec.attribute1,
                              x_attribute2           => test_dtls_rec.attribute2,
                              x_attribute3           => test_dtls_rec.attribute3,
                              x_attribute4           => test_dtls_rec.attribute4,
                              x_attribute5           => test_dtls_rec.attribute5,
                              x_attribute6           => test_dtls_rec.attribute6,
                              x_attribute7           => test_dtls_rec.attribute7,
                              x_attribute8           => test_dtls_rec.attribute8,
                              x_attribute9           => test_dtls_rec.attribute9,
                              x_attribute10          => test_dtls_rec.attribute10,
                              x_attribute11          => test_dtls_rec.attribute11,
                              x_attribute12          => test_dtls_rec.attribute12,
                              x_attribute13          => test_dtls_rec.attribute13,
                              x_attribute14          => test_dtls_rec.attribute14,
                              x_attribute15          => test_dtls_rec.attribute15,
                              x_attribute16          => test_dtls_rec.attribute16,
                              x_attribute17          => test_dtls_rec.attribute17,
                              x_attribute18          => test_dtls_rec.attribute18,
                              x_attribute19          => test_dtls_rec.attribute19,
                              x_attribute20          => test_dtls_rec.attribute20,
                              x_mode                 => 'R'
                              );

                  ELSIF test_dtls_rec.dmlmode = cst_update THEN
                    OPEN  c_null_hdlg_tst_dtls_cur(test_dtls_rec.test_segment_id,test_dtls_rec.test_results_id);
                    FETCH c_null_hdlg_tst_dtls_cur INTO c_null_hdlg_tst_dtls_rec;
                    CLOSE c_null_hdlg_tst_dtls_cur;

                    Igs_Ad_Tst_Rslt_Dtls_Pkg.Update_Row (
                                 x_rowid                => c_null_hdlg_tst_dtls_rec.rowid,
                                 x_tst_rslt_dtls_id     => c_null_hdlg_tst_dtls_rec.tst_rslt_dtls_id,
                                 x_test_results_id      => c_null_hdlg_tst_dtls_rec.test_results_id ,
                                 x_test_segment_id      => NVL( test_dtls_rec.test_segment_id, c_null_hdlg_tst_dtls_rec.test_segment_id ),
                                 x_test_score           => NVL( test_dtls_rec.test_score, c_null_hdlg_tst_dtls_rec.test_score),
                                 x_percentile           => NVL( test_dtls_rec.percentile, c_null_hdlg_tst_dtls_rec.percentile),
                                 x_national_percentile  => NVL( test_dtls_rec.national_percentile, c_null_hdlg_tst_dtls_rec.national_percentile),
                                 x_state_percentile     => NVL( test_dtls_rec.state_percentile, c_null_hdlg_tst_dtls_rec.state_percentile),
                                 x_percentile_year_rank => NVL( test_dtls_rec.percentile_year_rank, c_null_hdlg_tst_dtls_rec.percentile_year_rank),
                                 x_score_band_lower     => NVL( test_dtls_rec.score_band_lower, c_null_hdlg_tst_dtls_rec.score_band_lower),
                                 x_score_band_upper     => NVL( test_dtls_rec.score_band_upper, c_null_hdlg_tst_dtls_rec.score_band_upper),
                                 x_irregularity_code_id => NVL( test_dtls_rec.irregularity_code, c_null_hdlg_tst_dtls_rec.irregularity_code_id),
                                 x_attribute_category   => NVL( test_dtls_rec.attribute_category, c_null_hdlg_tst_dtls_rec.attribute_category),
                                 x_attribute1           => NVL( test_dtls_rec.attribute1, c_null_hdlg_tst_dtls_rec.attribute1),
                                 x_attribute2           => NVL( test_dtls_rec.attribute2, c_null_hdlg_tst_dtls_rec.attribute2),
                                 x_attribute3           => NVL( test_dtls_rec.attribute3, c_null_hdlg_tst_dtls_rec.attribute3),
                                 x_attribute4           => NVL( test_dtls_rec.attribute4, c_null_hdlg_tst_dtls_rec.attribute4),
                                 x_attribute5           => NVL( test_dtls_rec.attribute5, c_null_hdlg_tst_dtls_rec.attribute5),
                                 x_attribute6           => NVL( test_dtls_rec.attribute6, c_null_hdlg_tst_dtls_rec.attribute6),
                                 x_attribute7           => NVL( test_dtls_rec.attribute7, c_null_hdlg_tst_dtls_rec.attribute7),
                                 x_attribute8           => NVL( test_dtls_rec.attribute8, c_null_hdlg_tst_dtls_rec.attribute8),
                                 x_attribute9           => NVL( test_dtls_rec.attribute9, c_null_hdlg_tst_dtls_rec.attribute9),
                                 x_attribute10          => NVL( test_dtls_rec.attribute10, c_null_hdlg_tst_dtls_rec.attribute10),
                                 x_attribute11          => NVL( test_dtls_rec.attribute11, c_null_hdlg_tst_dtls_rec.attribute11),
                                 x_attribute12          => NVL( test_dtls_rec.attribute12, c_null_hdlg_tst_dtls_rec.attribute12),
                                 x_attribute13          => NVL( test_dtls_rec.attribute13, c_null_hdlg_tst_dtls_rec.attribute13),
                                 x_attribute14          => NVL( test_dtls_rec.attribute14, c_null_hdlg_tst_dtls_rec.attribute14),
                                 x_attribute15          => NVL( test_dtls_rec.attribute15, c_null_hdlg_tst_dtls_rec.attribute15),
                                 x_attribute16          => NVL( test_dtls_rec.attribute16, c_null_hdlg_tst_dtls_rec.attribute16),
                                 x_attribute17          => NVL( test_dtls_rec.attribute17, c_null_hdlg_tst_dtls_rec.attribute17),
                                 x_attribute18          => NVL( test_dtls_rec.attribute18, c_null_hdlg_tst_dtls_rec.attribute18),
                                 x_attribute19          => NVL( test_dtls_rec.attribute19, c_null_hdlg_tst_dtls_rec.attribute19),
                                 x_attribute20          => NVL( test_dtls_rec.attribute20, c_null_hdlg_tst_dtls_rec.attribute20),
                                 x_mode                 => 'R'
                                 );
                  END IF;

                  upd_tst_dtls_atm_s1(test_dtls_rec.rowid,test_dtls_rec.dmlmode);
                EXCEPTION
                  WHEN OTHERS THEN
                    l_msg_data := SQLERRM;
                    l_status := '3';
                    l_success := FALSE;

                    IF test_dtls_rec.dmlmode = cst_insert THEN
                      l_error_code := 'E322'; -- Insertion Failed
                    ELSIF test_dtls_rec.dmlmode = cst_update THEN
                      l_error_code := 'E014'; -- Update Failed
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
                        igs_ad_imp_001.logerrormessage(test_dtls_rec.interface_testsegs_id,l_msg_data,'IGS_AD_TEST_SEGS_INT');
                      END IF;
                    ELSE
                      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                        l_label := 'igs.plsql.igs_ad_imp_010.admp_val_pappl_nots.crt_upd_tst_rslts.for_loop_test_dtls.execption'||l_error_code;

                        fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                        fnd_message.set_token('INTERFACE_ID',test_dtls_rec.interface_testsegs_id);
                        fnd_message.set_token('ERROR_CD',l_error_code);

                        l_debug_str :=  fnd_message.get;
                        fnd_log.string_with_context( fnd_log.level_exception,
                                                     l_label,
                                                     l_debug_str, NULL,
                                                     NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                      END IF;
                    END IF;

                    -- Autonomous Transaction to update error status for Test Details interface table;
                    upd_tst_dtls_atm_exp(test_rec.interface_test_id, test_dtls_rec.rowid
                                         ,test_dtls_rec.dmlmode,l_error_code,l_error_text);
                    EXIT;

                END;
              END LOOP;

              -- Autonomous Transaction to update error status for Test Details interface table;
              upd_tst_dtls_atm_aft(test_rec.interface_test_id,test_rec.dmlmode,l_success);
            END IF;

          END; -- Test Result Details

        END IF;

        IF l_success THEN
          UPDATE igs_ad_test_int
          SET
                 status = cst_s_val_1
                 , match_ind =  DECODE(match_ind,
                                       NULL, DECODE (test_rec.dmlmode,
                                                     cst_update, cst_mi_val_18,
                                                     cst_insert, cst_mi_val_11,
                                                     cst_dsp, cst_mi_val_23)
                                       ,match_ind)
                 , test_results_id = l_test_results_id
          WHERE rowid = test_rec.rowid
          AND status = '2';
        ELSE

          RAISE test_seg_failed;
        END IF;

        l_records_processed := l_records_processed + 1;
	l_total_records_prcessed :=  l_total_records_prcessed +1;

        IF l_records_processed = 100 THEN
          COMMIT;
          l_records_processed := 0;
        END IF;

      EXCEPTION
        WHEN test_seg_failed THEN
          ROLLBACK TO test_results_sp;
          l_error_code :='E347';
          l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405);

          UPDATE igs_ad_test_int
          SET    status =  DECODE (test_rec.dmlmode,cst_dsp,cst_s_val_4,
                                                    cst_s_val_3)
                 ,error_code = l_error_code
                 ,error_text = l_error_text
                 ,match_ind = DECODE (test_rec.dmlmode,cst_dsp,cst_mi_val_23,
                                                    match_ind)
          WHERE  interface_test_id = test_rec.interface_test_id;

          IF p_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(test_rec.interface_test_id,l_error_code,'IGS_AD_TEST_INT');
          END IF;
          l_error_code := NULL;

          l_records_processed := l_records_processed + 1;
  	  l_total_records_prcessed :=  l_total_records_prcessed +1;
          IF l_records_processed = 100 THEN
            COMMIT;
            l_records_processed := 0;
          END IF;

        WHEN OTHERS THEN
          ROLLBACK TO test_results_sp;
          l_msg_data := SQLERRM;
          l_status := '3';

          IF test_rec.dmlmode = cst_insert THEN
            l_error_code := 'E322'; -- Insertion Failed
          ELSIF test_rec.dmlmode = cst_update THEN
            l_error_code := 'E014'; -- Update Failed
          END IF;

          igs_ad_gen_016.extract_msg_from_stack (
                    p_msg_at_index                => l_msg_at_index,
                    p_return_status               => l_return_status,
                    p_msg_count                   => l_msg_count,
                    p_msg_data                    => l_msg_data,
                    p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
          l_error_text := NVL(l_msg_data,igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', l_error_code, 8405));

          IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
            l_error_text := l_msg_data;
            IF p_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(test_rec.interface_test_id,l_msg_data,'IGS_AD_TEST_INT');
            END IF;
          ELSE
            IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

              l_label := 'igs.plsql.igs_ad_imp_016.prc_tst_rslts.crt_upd_tst_rslts.for_loop.execption'||l_error_code;

              fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
          fnd_message.set_token('INTERFACE_ID',test_rec.interface_test_id);
          fnd_message.set_token('ERROR_CD',l_error_code);

              l_debug_str :=  fnd_message.get;
              fnd_log.string_with_context( fnd_log.level_exception,
                       l_label,
                       l_debug_str, NULL,
                       NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
            END IF;
          END IF;

          UPDATE igs_ad_test_int
          SET
                 status = cst_s_val_3
                 , match_ind = DECODE (test_rec.dmlmode,
                                       cst_update, DECODE (match_ind,
                                                           NULL, cst_mi_val_12,
                                                           match_ind),
                                       cst_insert, DECODE (p_rule,
                                                           cst_rule_val_R, DECODE (match_ind,
                                                                                   NULL, cst_mi_val_11,
                                                                                   match_ind),
                                                           cst_mi_val_11),
                                        cst_dsp,cst_mi_val_23 )
                 , error_code = l_error_code
                 , error_text = l_error_text
          WHERE rowid = test_rec.rowid;

          l_records_processed := l_records_processed + 1;
  	  l_total_records_prcessed :=  l_total_records_prcessed +1;

          IF l_records_processed = 100 THEN
            COMMIT;
            l_records_processed := 0;
          END IF;

        END;

        IF l_records_processed = 100 THEN
          COMMIT;
          l_records_processed := 0;
        END IF;

      END LOOP; --Test Results Loop;

    COMMIT;

    END LOOP; -- Cursor Break Up LOOP;

    COMMIT;

END crt_upd_tst_rslts; -- End of local procedure crt_upd_tst_rslts.

-- begin of main process prc_tst_rslts
PROCEDURE prc_tst_rslts(p_interface_run_id  IN NUMBER,
                        p_enable_log        IN VARCHAR2,
                        p_rule              IN VARCHAR2 )
AS
/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
******************************************************************/
  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_request_id NUMBER;
  l_error_code  igs_ad_test_int.error_code%TYPE;

BEGIN

  l_prog_label := 'igs.plsql.igs_ad_imp_016.prc_tst_rslts';
  l_label := 'igs.plsql.igs_ad_imp_016.prc_tst_rslts.';
  l_request_id := fnd_global.conc_request_id;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    l_label := 'igs.plsql.igs_ad_imp_016.prc_tst_rslts.begin';
    l_debug_str :=  'igs_ad_imp_016.prc_tst_rslts';

    fnd_log.string_with_context( fnd_log.level_procedure,
  			         l_label,
			         l_debug_str, NULL,
			         NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  -- Set STATUS to 3 for interface records with RULE = E or I and MATCH IND
  IF p_rule IN ('E','I') THEN
    UPDATE igs_ad_test_int
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
    UPDATE igs_ad_test_int
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
    UPDATE igs_ad_test_int in_rec
    SET
           status = cst_s_val_1
           , match_ind = cst_mi_val_19
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND EXISTS ( SELECT 1
                 FROM igs_ad_test_results mn_rec
                 WHERE mn_rec.person_id = in_rec.person_id
                 AND   mn_rec.admission_test_type = in_rec.admission_test_type
                 AND   TRUNC(mn_rec.test_date) = TRUNC(in_rec.test_date));
    COMMIT;
  END IF;

  -- Set STATUS to 3 for interface records with matching duplicate system
  -- record for RULE = I and either MATCH IND is 15 OR IS NULL (will
  -- require incase of data corruption, do we need in import process)
  IF p_rule IN ('I')  THEN
    UPDATE igs_ad_test_int in_rec
    SET
           status = cst_s_val_3
           , match_ind = cst_mi_val_13
           , error_code = cst_ec_val_E678
           , error_text = cst_et_val_E678
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND NVL (match_ind, cst_mi_val_15) = cst_mi_val_15
    AND 1 < ( SELECT COUNT (*)
              FROM igs_ad_test_results mn_rec
              WHERE mn_rec.person_id = in_rec.person_id
              AND   mn_rec.admission_test_type = in_rec.admission_test_type
              AND   TRUNC(mn_rec.test_date) = TRUNC(in_rec.test_date));
    COMMIT;
  END IF;

  -- Set STATUS to 3 for interface records with matching duplicate system
  -- record for RULE = R and either MATCH IND IN (15, 21) OR IS NULL (will
  -- require incase of data corruption, do we need in import process)
  IF p_rule IN ('R')  THEN
    UPDATE igs_ad_test_int in_rec
    SET
           status = cst_s_val_3
           , match_ind = cst_mi_val_13
           , error_code = cst_ec_val_E678
           , error_text = cst_et_val_E678
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND NVL (match_ind, cst_mi_val_15) IN (cst_mi_val_15, cst_mi_val_21)
    AND 1 < ( SELECT COUNT (*)
              FROM igs_ad_test_results mn_rec
              WHERE mn_rec.person_id = in_rec.person_id
              AND   mn_rec.admission_test_type = in_rec.admission_test_type
              AND   TRUNC(mn_rec.test_date) = TRUNC(in_rec.test_date));
    COMMIT;

    UPDATE igs_ad_test_int in_rec
    SET   test_results_id = (SELECT test_results_id
                             FROM igs_ad_test_results mn_rec
                             WHERE mn_rec.person_id = in_rec.person_id
                             AND   mn_rec.admission_test_type = in_rec.admission_test_type
                             AND   TRUNC(mn_rec.test_date) = TRUNC(in_rec.test_date))
           ,status = cst_s_val_1
           ,match_ind = cst_mi_val_23
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND NVL (match_ind, cst_mi_val_15) IN (cst_mi_val_15)
    AND EXISTS (
                SELECT 1
                FROM igs_ad_test_results mn_rec
                WHERE  NVL(mn_rec.person_id,-99)                     =  NVL(in_rec.person_id, NVL(mn_rec.person_id,-99) )
                AND    NVL(mn_rec.admission_test_type, '~')          =  NVL(in_rec.admission_test_type, NVL(mn_rec.admission_test_type, '~'))
                AND    TRUNC(NVL(mn_rec.test_date, SYSDATE))         =  TRUNC(NVL(in_rec.test_date, NVL(mn_rec.test_date, SYSDATE)))
                AND    TRUNC(NVL(mn_rec.score_report_date, SYSDATE)) =  TRUNC(NVL(in_rec.score_report_date, NVL(mn_rec.score_report_date, SYSDATE)))
                AND    NVL(mn_rec.edu_level_id, -99)                 =  NVL(in_rec.edu_level_id, NVL(mn_rec.edu_level_id, -99))
                AND    NVL(mn_rec.score_type, '~')                   =  NVL(in_rec.score_type, NVL(mn_rec.score_type, '~'))
                AND    NVL(mn_rec.score_source_id, -99)              =  NVL(in_rec.score_source_id, NVL(mn_rec.score_source_id, -99))
                AND    NVL(mn_rec.non_standard_admin, '~')           =  NVL(in_rec.non_standard_admin, NVL(mn_rec.non_standard_admin, '~'))
                AND    NVL(mn_rec.special_code, '~')                 =  NVL(in_rec.special_code, NVL(mn_rec.special_code, '~'))
                AND    NVL(mn_rec.grade_id, -99)                     =  NVL(in_rec.grade_id, NVL(mn_rec.grade_id, -99))
               );
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
  crt_upd_tst_rslts(p_interface_run_id, p_rule,p_enable_log);

  -- Set STATUS to 1 and MATCH IND to 23 for interface records with RULE = R matching
  -- OSS record(s) in ALL updateable column values, if column nullification is not
  -- allowed then the 2 DECODE should be replaced by a single NVL
  -- Set STATUS to 3 and MATCH IND = 20 for interface records with RULE = R and MATCH IND
  -- <> 21, 25, ones failed discrepancy check
  IF p_rule IN ('R') THEN
    UPDATE igs_ad_test_int in_rec
    SET
           status = cst_s_val_3
           , match_ind = cst_mi_val_20
           ,(dup_test_results_id)
                 = (SELECT mn_rec.test_results_id
                    FROM igs_ad_test_results mn_rec
                    WHERE mn_rec.person_id = in_rec.person_id
                    AND   mn_rec.admission_test_type = in_rec.admission_test_type
                    AND   TRUNC(mn_rec.test_date) = TRUNC(in_rec.test_date)
                    AND   ROWNUM = 1)
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND NVL (match_ind, cst_mi_val_15) = cst_mi_val_15
    AND EXISTS ( SELECT rowid
                 FROM igs_ad_test_results mn_rec
                 WHERE mn_rec.person_id = in_rec.person_id
                 AND   mn_rec.admission_test_type = in_rec.admission_test_type
                 AND   TRUNC(mn_rec.test_date) = TRUNC(in_rec.test_date));
    COMMIT;
  END IF;

  -- Set STATUS to 3 for interface records with RULE = R and invalid MATCH IND
  IF p_rule IN ('R') THEN
    UPDATE igs_ad_test_int
    SET
           status = cst_s_val_3
           , error_code = cst_ec_val_E700
           , error_text = cst_et_val_E700
    WHERE interface_run_id = p_interface_run_id
    AND status = cst_s_val_2
    AND match_ind IS NOT NULL;
    COMMIT;
  END IF;

END prc_tst_rslts;

END igs_ad_imp_016;

/
