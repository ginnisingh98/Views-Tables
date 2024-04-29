--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_011
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_011" AS
/* $Header: IGSAD89B.pls 120.5 2006/09/21 08:57:53 gmaheswa ship $ */

/*
      ||  Created By :
      ||  Created On :
      ||  Purpose :
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
        asbala            13-OCT-2003      Bug 3130316. Import Process Source Category Rule processing changes,
                                          lookup caching related changes, and cursor parameterization.
        asbala            13-OCT-2003        Bug 3130316. Import Process Logging Framework Related changes.

      || npalanis         6-JAN-2      Bug : 2734697
      ||                                  code added to commit after import of every
      ||                                  100 records .New variable l_processed_records added
      ||  ssawhney       21-oct-2002     Bug no.2630860:SWS104
      ||                                 PRC_PE_RES_DTLS added
      ||  pkpatel        23-DEC-2002     Bug No: 2722027
      ||                                 PRC_SPECIAL_NEEDS added and moved the code from IGSAD86B.pls
      ||  pkpatel        7-FEB-2003       Bug No: 2765142
      ||                                  Modified to add the UCAS user hook igs_uc_utils.admission_residency_dtls
      ||  pkpatel        2-JUN-2003       Bug 2986796(special Needs CCR)
      ||                                  Modified the the select statements to use bind variables.
      ||                                  Modified the logic for NONE special needs record as per jul'03 special need CCR
      ||  pkpatel        6-JUN-2003       Bug 2975196
      ||                                  Modified evaluation date validation in prc_pe_res_dtls
      ||  skpandey       11-APR-2006      Bug#5110137: Removed call to upd_res_det procedure

      ||  (reverse chronological order - newest change first)
 */

	cst_mi_val_18  CONSTANT VARCHAR2(2) := '18';
	cst_mi_val_19  CONSTANT VARCHAR2(2) := '19';
	cst_mi_val_20  CONSTANT VARCHAR2(2) := '20';
        cst_mi_val_21  CONSTANT VARCHAR2(2) := '21';
	cst_mi_val_22  CONSTANT VARCHAR2(2) := '22';
	cst_mi_val_23  CONSTANT VARCHAR2(2) := '23';
	cst_mi_val_24  CONSTANT VARCHAR2(2) := '24';
	cst_mi_val_25  CONSTANT VARCHAR2(2) := '25';

	cst_stat_val_1  CONSTANT VARCHAR2(1) := '1';
        cst_stat_val_2  CONSTANT VARCHAR2(1) := '2';
	cst_stat_val_3  CONSTANT VARCHAR2(1) := '3';

        cst_err_val_695 CONSTANT VARCHAR2(4) := 'E695';

PROCEDURE prc_apcnt_acadhnr_dtls (
          p_source_type_id  IN  NUMBER,
          p_batch_id    IN  NUMBER )

AS
/*----------------------------------------------------------------------------------
  ||  Created By : pkpatel
  ||  Created On : 22-JUN-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || npalanis         6-JAN-2003      Bug : 2734697
  ||                                  code added to commit after import of every
  ||                                  100 records .New variable l_processed_records added
  ||  samaresh      24-JAN-2002      The table Igs_ad_appl_int has been obsoleted
  ||                                 new table igs_ad_apl_int has been created
  ||                                 as a part of build ADI - Import Prc Changes
  ||  ssawhney      22-oct           SWS104 : 2630860 : AD_ACAD_HONOR moves to PE_ACAD_HONORS and all the other changes.
  ||--------------------------------------------------------------------------------*/

    l_status    igs_ad_acadhonor_int.status%TYPE;
    l_error_code    igs_ad_acadhonor_int.error_code%TYPE;
    l_match_ind igs_ad_acadhonor_int.match_ind%TYPE;
    l_validate  VARCHAR2(1);
    l_processed_records NUMBER(5) := 0;
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

    --
    -- dld ref 1.  Pick up the records from the tables mentioned below :
    --
    CURSOR hnr_cur (cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
    SELECT mi.*, i.person_id
    FROM igs_ad_acadhonor_int_all mi,igs_ad_interface_all i
    WHERE  mi.interface_run_id = cp_interface_run_id
      AND  mi.interface_id =  i.interface_id
      AND  i.interface_run_id = cp_interface_run_id
      AND  mi.status = '2';

         acadhonor_rec hnr_cur%ROWTYPE;

    --
    -- Cursor to check for the duplicate
    --
    --
    -- Modified By : ssawhney
    -- Date : 1/21/02
    -- Bug # 2630860
    -- Removed the appl_no and modified acad_honor_type_id to acad_honor_type
    --
    CURSOR chk_dup_cur ( acadhonor_rec hnr_cur%ROWTYPE) IS
    SELECT rowid,hi.*
    FROM igs_pe_acad_honors hi
    WHERE hi.person_id = acadhonor_rec.person_id AND
          hi.acad_honor_type  = acadhonor_rec.acad_honor_type AND
          NVL(hi.honor_date,TO_DATE('4712/12/31','YYYY/MM/DD')) = NVL(TRUNC(acadhonor_rec.honor_date),TO_DATE('4712/12/31','YYYY/MM/DD'));

    chk_dup_rec chk_dup_cur%ROWTYPE;
    l_dup_exists NUMBER;
    --
    -- Modified the Null Handling Logic
    --
    --
    -- Modified By : ssawhney
    -- Date : 1/21/02
    -- Bug # 2630860
    -- Removed the appl_no and modified acad_honor_type_id to acad_honor_type

    l_rule VARCHAR2(1);

    -- Begin Local Function
    FUNCTION validate_record ( acadhonor_rec hnr_cur%ROWTYPE) RETURN VARCHAR2
    AS
      l_return_val    VARCHAR2(1) := 'Y';
      l_var VARCHAR2(1);
      CURSOR birth_dt_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
        SELECT birth_date birth_dt
        FROM igs_pe_person_base_v
        WHERE person_id = cp_person_id;
      birth_dt_rec birth_dt_cur%ROWTYPE;
      l_bdate DATE;
    BEGIN

    IF
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_ACAD_HONORS',acadhonor_rec.acad_honor_type,8405))
    THEN
      IF acadhonor_rec.honor_date IS NOT NULL THEN
                -- Get the value of the Birth Date of the person
        OPEN birth_dt_cur(acadhonor_rec.person_id);
        FETCH birth_dt_cur INTO birth_dt_rec;
        CLOSE birth_dt_cur;
        l_bdate := birth_dt_rec.birth_dt;

        IF acadhonor_rec.honor_date > SYSDATE OR acadhonor_rec.honor_date < l_bdate THEN
            l_return_val := 'H';
			IF l_enable_log = 'Y' THEN
			  igs_ad_imp_001.logerrormessage(acadhonor_rec.interface_acadhonor_id,'E052');
			END IF;
        END IF;

      END IF;
    ELSE
      l_return_val := 'N';
		IF l_enable_log = 'Y' THEN
		  igs_ad_imp_001.logerrormessage(acadhonor_rec.interface_acadhonor_id,'E421');
		END IF;
    END IF;

    RETURN l_return_val;
    EXCEPTION
        WHEN OTHERS THEN
            l_return_val := 'N';
            --
            -- Close the cursors
            --
            IF birth_dt_cur%ISOPEN THEN
                CLOSE birth_dt_cur;
            END IF;
            RETURN l_return_val;
    END validate_record;
    -- End Local Function

    -- Begin Local procedure
    PROCEDURE crt_apcnt_acad_hnr(
           acadhonor_rec  hnr_cur%ROWTYPE )
    AS
        l_rowid VARCHAR2(25);
        l_acad_hnr_id NUMBER;
    BEGIN
        -- Call Log header
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_011.crt_apcnt_acad_hnr.begin';
    l_debug_str := 'start of proc crt_apcnt_acad_hnr';

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;



        igs_pe_acad_honors_pkg.insert_row (
                    x_rowid => l_rowid,
                    x_acad_honor_id => l_acad_hnr_id,
                    x_person_id => acadhonor_rec.person_id,
                    x_acad_honor_type => acadhonor_rec.acad_honor_type ,
                    x_comments => acadhonor_rec.comments ,
                    x_honor_date => acadhonor_rec.honor_date ,
                    x_mode => 'R'
                    );
        --
        -- Insertion Successful
        --
        l_status := '1';
        l_error_code := NULL;
    EXCEPTION
        WHEN OTHERS THEN
            --
            -- Insertion Not Successful
            --
            l_status := '3';
            l_error_code := 'E322';

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.crt_apcnt_acad_hnr.exception'||l_error_code;

          l_debug_str :=  'IGS_AD_IMP_011.PRC_APCNT_ACADHNR_DTLS.CRT_APCNT_ACAD_HNR ' ||
                                                  'STATUS : 3' ||  'ERRORCODE : E322 SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(acadhonor_rec.INTERFACE_ACADHONOR_ID,l_error_code);
    END IF;


    END crt_apcnt_acad_hnr;
    -- End Local Procedure

-- Start of the Main Procedure PRC_APCNT_ACADHNR_DTLS
BEGIN
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_prog_label := 'igs.plsql.igs_ad_imp_011.prc_apcnt_acadhnr_dtls';
    l_label := 'igs.plsql.igs_ad_imp_011.prc_apcnt_acadhnr_dtls.';

    --
    -- dld ref 2.  Put them in a record called ACADHONOR_REC.
    --
    l_rule := igs_ad_imp_001.find_source_cat_rule(p_source_type_id,'PERSON_ACAD_HONORS');

  -- If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_ad_acadhonor_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = cst_stat_val_2
      AND interface_run_id = l_interface_run_id;
  END IF;

  -- If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_ad_acadhonor_int_all mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_acad_honors pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
             AND  pe.acad_honor_type = UPPER(mi.acad_honor_type)
             AND  NVL(pe.honor_date,TO_DATE('4712/12/31','YYYY/MM/DD')) = NVL(TRUNC(mi.honor_date),TO_DATE('4712/12/31','YYYY/MM/DD')));
  END IF;

  -- If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_ad_acadhonor_int_all
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status = cst_stat_val_2;
  END IF;

  -- If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_ad_acadhonor_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25));
  END IF;

  -- If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_ad_acadhonor_int_all mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM igs_pe_acad_honors pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
             AND  pe.acad_honor_type  = UPPER(mi.acad_honor_type)
             AND  NVL(pe.honor_date,TO_DATE('4712/12/31','YYYY/MM/DD')) = NVL(TRUNC(mi.honor_date),TO_DATE('4712/12/31','YYYY/MM/DD'))
             AND  NVL(UPPER(pe.comments),'*!*') = NVL(UPPER(mi.comments),'*!*')
             );
  END IF;

  -- If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_ad_acadhonor_int_all mi
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20,
    DUP_ACAD_HONOR_ID = (SELECT pe.acad_honor_id
                           FROM igs_pe_acad_honors pe, igs_ad_interface_all ii
                   WHERE mi.interface_run_id = l_interface_run_id
                         AND  ii.interface_id = mi.interface_id
                     AND  ii.person_id = pe.person_id
                     AND  pe.acad_honor_type = UPPER(mi.acad_honor_type)
                     AND  NVL(pe.honor_date,TO_DATE('4712/12/31','YYYY/MM/DD')) = NVL(TRUNC(mi.honor_date),TO_DATE('4712/12/31','YYYY/MM/DD'))               )
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                  FROM igs_pe_acad_honors pe, igs_ad_interface_all ii
          WHERE  ii.interface_run_id = l_interface_run_id
            AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
             AND pe.acad_honor_type  = UPPER(mi.acad_honor_type)
             AND  NVL(pe.honor_date,TO_DATE('4712/12/31','YYYY/MM/DD')) = NVL(TRUNC(mi.honor_date),TO_DATE('4712/12/31','YYYY/MM/DD')));
  END IF;


    FOR acadhonor_rec IN hnr_cur(l_interface_run_id)
    LOOP
        l_processed_records := l_processed_records + 1 ;
        --
        -- Set the status, error_code, match_ind variables to the existing values
        --
        l_status := acadhonor_rec.status;
        l_error_code := acadhonor_rec.error_code;
        l_match_ind := acadhonor_rec.match_ind;
        acadhonor_rec.acad_honor_type := UPPER(acadhonor_rec.acad_honor_type);
        acadhonor_rec.honor_date := TRUNC(acadhonor_rec.honor_date);

        BEGIN
            --
            -- dld ref 4.  Check to see if the record already exists. Use the following query : Was missing previously
            --
        chk_dup_rec.acad_honor_type := NULL;
            OPEN chk_dup_cur (acadhonor_rec);
            FETCH chk_dup_cur INTO chk_dup_rec;
        CLOSE chk_dup_cur;
             IF chk_dup_rec.acad_honor_type IS NOT NULL THEN
                -- To be changed as a generic change
                IF l_rule = 'I' THEN
                    l_match_ind := '18';
                    l_validate := validate_record ( acadhonor_rec);
                    IF l_validate = 'H' THEN
                    l_error_code := 'E052';
                    l_status := '3';
                    ELSIF l_validate = 'N' THEN
                    l_error_code := 'E421';
                    l_status := '3';
                    ELSIF l_validate = 'Y' THEN
                    --
                    -- Validation Successful

                    BEGIN
                        igs_pe_acad_honors_pkg.update_row (
                                x_rowid => chk_dup_rec.rowid,
                                x_acad_honor_id => chk_dup_rec.acad_honor_id,
                                x_person_id => acadhonor_rec.person_id,
                                x_acad_honor_type => acadhonor_rec.acad_honor_type ,
                                x_comments => NVL(acadhonor_rec.comments ,chk_dup_rec.comments),
                                x_honor_date => NVL(acadhonor_rec.honor_date,chk_dup_rec.honor_date),
                                x_mode => 'R'
                                    );
                        --
                        -- Update is successful the update the status to completed '1'
                        --
                        l_status := '1';
                    EXCEPTION
                        --
                        -- Update Not a Success then update the error_code and the status accordingly
                        --
                        WHEN OTHERS THEN
                            l_status := '3';
                            l_error_code := 'E014';
							IF l_enable_log = 'Y' THEN
							  igs_ad_imp_001.logerrormessage(acadhonor_rec.interface_acadhonor_id,'E014');
							END IF;

								  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

										IF (l_request_id IS NULL) THEN
										  l_request_id := fnd_global.conc_request_id;
										END IF;

										l_label := 'igs.plsql.igs_ad_imp_011.prc_apcnt_acadhnr_dtls.exception_update1'||'E014';

										l_debug_str :=  'IGS_AD_IMP_011.PRC_APCNT_ACADHNR_DTLS ' ||
														  'INTERFACE ACADHONOR ID : ' || (acadhonor_rec.interface_acadhonor_id) ||
														 'STATUS : 3' ||  'ERRORCODE : E014 SQLERRM:' ||  SQLERRM;

										fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
								  END IF;

                    END;
                    END IF; -- for validation
                ELSIF l_rule = 'R' THEN
                  IF acadhonor_rec.match_ind = '21' THEN
                    l_validate := validate_record ( acadhonor_rec);
                    IF l_validate = 'H' THEN
                    l_error_code := 'E052';
                    l_status := '3';
                    ELSIF l_validate = 'N' THEN
                    l_error_code := 'E421';
                    l_status := '3';
                    ELSIF l_validate = 'Y' THEN
                    --
                    -- Validation Successful
                      BEGIN
                        igs_pe_acad_honors_pkg.update_row (
                                    x_rowid => chk_dup_rec.rowid,
                                    x_acad_honor_id => chk_dup_rec.acad_honor_id,
                                    x_person_id =>acadhonor_rec.person_id,
                                    x_acad_honor_type => acadhonor_rec.acad_honor_type,
                                    x_comments => NVL(acadhonor_rec.comments ,chk_dup_rec.comments),
                                    x_honor_date => NVL(acadhonor_rec.honor_date,chk_dup_rec.honor_date),
                                    x_mode => 'R'
                                        );
                            --
                            -- update is success
                            --
                            l_status := '1';
                            l_match_ind := '18';
                        EXCEPTION
                            --
                            -- If  update is not successful then update the error_code and status accordingly
                            --
                            WHEN OTHERS THEN
                                l_status := '3';
                                l_error_code := 'E014';
								IF l_enable_log = 'Y' THEN
								  igs_ad_imp_001.logerrormessage(acadhonor_rec.interface_acadhonor_id,'E014');
								END IF;

								  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

										IF (l_request_id IS NULL) THEN
										  l_request_id := fnd_global.conc_request_id;
										END IF;

										l_label := 'igs.plsql.igs_ad_imp_011.prc_apcnt_acadhnr_dtls.exception_update2'||'E014';

										l_debug_str :=  'IGS_AD_IMP_011.PRC_APCNT_ACADHNR_DTLS ' ||
														  'INTERFACE ACADHONOR ID : ' || (acadhonor_rec.interface_acadhonor_id) ||
														 'STATUS : 3' ||  'ERRORCODE : E014 SQLERRM:' ||  SQLERRM;

										fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
								  END IF;
                        END;
                    END IF;
                     END IF;
                END IF;
            ELSE
                l_validate := validate_record ( acadhonor_rec);
                IF l_validate = 'Y' THEN
                    --
                    -- Validation Successful
                    --
                    --Call the procedure Create_Applicant_Acad_Honors (ACADHONOR_REC)
                    crt_apcnt_acad_hnr( acadhonor_rec);
                ELSIF l_validate = 'H' THEN
                    --
                    -- Honor Date Validation Failed
                    --
                    l_error_code := 'E052';
                    l_status := '3';
                ELSIF l_validate = 'N' THEN
                    --
                    -- Validation Not Successful
                    --
                    l_error_code := 'E421';
                    l_status := '3';
                END IF;
            END IF;
        --
            -- Update the interface record with the status, error_code, match_ind
            --
            UPDATE
                igs_ad_acadhonor_int_all
            SET
                status = l_status,
                error_code = l_error_code,
                match_ind = l_match_ind
            WHERE
                interface_acadhonor_id =  acadhonor_rec.interface_acadhonor_id;

        EXCEPTION
            WHEN OTHERS THEN
                --
                -- Close the cursors if open
                --
                IF chk_dup_cur%ISOPEN THEN
                    CLOSE chk_dup_cur;
                END IF;
                UPDATE
                    igs_ad_acadhonor_int_all
                SET
                    status = '3',
                    error_code = 'E518'
                WHERE
                    interface_acadhonor_id =  acadhonor_rec.interface_acadhonor_id;
      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.prc_apcnt_acadhnr_dtls.exception'||'E518';

            l_debug_str :=  'IGS_AD_IMP_011.PRC_APCNT_ACADHNR_DTLS ' ||
                              'INTERFACE ACADHONOR ID : ' || (acadhonor_rec.interface_acadhonor_id) ||
                             'STATUS : 3' ||  'ERRORCODE : E518 SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(acadhonor_rec.interface_acadhonor_id,'E518');
    END IF;

        END;

        IF l_processed_records = 100 THEN
           COMMIT;
           l_processed_records := 0;
        END IF;

    END LOOP;

END prc_apcnt_acadhnr_dtls;


PROCEDURE prc_pe_res_dtls (
          p_source_type_id  IN  NUMBER,
          p_batch_id    IN  NUMBER )

AS
/*----------------------------------------------------------------------------------
  ||  Created By : ssawhney
  ||  Created On : 21-OCT-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || npalanis         6-JAN-2003      Bug : 2734697
  ||                                  code added to commit after import of every
  ||                                  100 records .New variable l_processed_records added
  ||  pkpatel       17-DEC-2002      Bug No: 2695902
  ||                                 Modified the birth date, overlapping validations logic.
  ||                                 Added the Attribute columns in the discrepancy cursor
  ||  pkpatel        7-FEB-2003       Bug No: 2765142
  ||                                  Modified to add the UCAS user hook igs_uc_utils.admission_residency_dtls
  ||  ssawhney                        update positioning when NOT coming from UCAS changed
  ||  pkpatel        6-JUN-2003      Bug 2975196
  ||                                 Reversed the evaluation date validation. Now it cannot be a future date.
  ||                                 Modified E184 to E203 when evaluation date with Birth date fails
  ||  asbala        3-SEP-2003       Build SWCR01,02
  ||                     Altered parameters of chk_dup_cur and c_null_hdlg_res_cur to reflect the
  ||                    changes in unique index
  ||  pkpatel       9-Nov-2004       Bug 3993967 (Removed Start/End Date. Included Term)
  ||--------------------------------------------------------------------------------*/
l_status         igs_pe_res_dtls_int.status%TYPE;
p_error_code     igs_pe_res_dtls_int.ERROR_CODE%TYPE;
l_match_ind      igs_pe_res_dtls_int.match_ind%TYPE;
l_processed_records NUMBER(5) := 0;
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_rule           VARCHAR2(1);
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

  CURSOR res_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
    SELECT mi.*, i.person_id
    FROM    igs_pe_res_dtls_int mi,igs_ad_interface_all i
    WHERE  mi.interface_run_id = cp_interface_run_id
      AND  mi.interface_id =  i.interface_id
      AND  i.interface_run_id = cp_interface_run_id
      AND  mi.status = '2';

  res_dtl_rec res_cur%ROWTYPE;

CURSOR chk_dup_cur ( res_dtls_cur res_cur%ROWTYPE) IS
SELECT rowid,hi.*
FROM   igs_pe_res_dtls_all hi
WHERE hi.person_id = res_dtls_cur.person_id AND
      hi.residency_class_cd = res_dtls_cur.residency_class_cd AND
      hi.cal_type = res_dtls_cur.cal_type AND
      hi.sequence_number = res_dtls_cur.sequence_number;

chk_dup_rec chk_dup_cur%ROWTYPE;

-- Begin Local procedure
PROCEDURE validate_record ( res_dtls_rec res_cur%ROWTYPE,
                    p_error_code  OUT NOCOPY VARCHAR2,
                    p_mode VARCHAR2)
AS

      CURSOR birth_dt_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
            SELECT  birth_date birth_dt
            FROM    igs_pe_person_base_v
            WHERE   person_id = cp_person_id;

     CURSOR load_cal_cur (cp_cal_type igs_ca_inst_all.cal_type%TYPE, cp_sequence_number igs_ca_inst_all.sequence_number%TYPE)
     IS
     SELECT   1
     FROM   igs_ca_inst_all ca,
     igs_ca_type typ,
     igs_ca_stat stat
     WHERE  typ.cal_type=ca.cal_type AND
     typ.s_cal_cat = 'LOAD' AND
     ca.cal_status = STAT.CAL_STATUS AND
     stat.s_cal_status = 'ACTIVE' AND
     ca.cal_type = cp_cal_type AND
     ca.sequence_number = cp_sequence_number;

        birth_dt_rec birth_dt_cur%ROWTYPE;
        l_bdate DATE;
        l_var VARCHAR2(1);
BEGIN
    p_error_code := NULL;

   -- The Load Calendar and Residency Class should be validated only in the Insert mode. Since the duplicate check is done
   -- on these columns in the Update mode the validation for these is not required.
   IF p_mode = 'I' THEN
    IF
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_RES_CLASS',res_dtls_rec.residency_class_cd,8405))
    THEN
      p_error_code := NULL;
    ELSE
      p_error_code := 'E179'; -- Res code  Validation Failed
      RAISE no_data_found;
    END IF;

    -- Calendar validation
    OPEN load_cal_cur(res_dtls_rec.cal_type,res_dtls_rec.sequence_number);
    FETCH load_cal_cur INTO l_var;
    IF load_cal_cur%NOTFOUND THEN
      p_error_code := 'E181';
      CLOSE load_cal_cur;
      RAISE no_data_found;
    END IF;
    CLOSE load_cal_cur;
   END IF;

    IF
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_RES_STATUS',res_dtls_rec.residency_status_cd,8405))
    THEN
      p_error_code := NULL;
    ELSE
      p_error_code := 'E180'; -- Res status  Validation Failed
      RAISE no_data_found;
    END IF;


    IF res_dtls_rec.evaluation_date > TRUNC(SYSDATE) THEN
      p_error_code := 'E184';
      RAISE no_data_found;
    END IF;
    OPEN birth_dt_cur(res_dtls_rec.person_id);
    FETCH birth_dt_cur INTO birth_dt_rec;
    CLOSE birth_dt_cur;

    IF birth_dt_rec.birth_dt IS NOT NULL THEN
      l_bdate := birth_dt_rec.birth_dt;
      IF  res_dtls_rec.evaluation_date < l_bdate THEN
        p_error_code := 'E203'; -- evaluation date validation failed.
        RAISE no_data_found;
      END IF;

    END IF;

     -- validate DFF
    IF NOT igs_ad_imp_018.validate_desc_flex(
                 p_attribute_category =>res_dtls_rec.attribute_category,
                 p_attribute1         =>res_dtls_rec.attribute1  ,
                 p_attribute2         =>res_dtls_rec.attribute2  ,
                 p_attribute3         =>res_dtls_rec.attribute3  ,
                 p_attribute4         =>res_dtls_rec.attribute4  ,
                 p_attribute5         =>res_dtls_rec.attribute5  ,
                 p_attribute6         =>res_dtls_rec.attribute6  ,
                 p_attribute7         =>res_dtls_rec.attribute7  ,
                 p_attribute8         =>res_dtls_rec.attribute8  ,
                 p_attribute9         =>res_dtls_rec.attribute9  ,
                 p_attribute10        =>res_dtls_rec.attribute10 ,
                 p_attribute11        =>res_dtls_rec.attribute11 ,
                 p_attribute12        =>res_dtls_rec.attribute12 ,
                 p_attribute13        =>res_dtls_rec.attribute13 ,
                 p_attribute14        =>res_dtls_rec.attribute14 ,
                 p_attribute15        =>res_dtls_rec.attribute15 ,
                 p_attribute16        =>res_dtls_rec.attribute16 ,
                 p_attribute17        =>res_dtls_rec.attribute17 ,
                 p_attribute18        =>res_dtls_rec.attribute18 ,
                 p_attribute19        =>res_dtls_rec.attribute19 ,
                 p_attribute20        =>res_dtls_rec.attribute20 ,
                 p_desc_flex_name     =>'IGS_PE_PERS_RESIDENCY_FLEX' ) THEN

      p_error_code:='E255';
      RAISE no_data_found;
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Validation Unsuccessful
        UPDATE igs_pe_res_dtls_int
        SET    status        = '3',
              error_code           = p_error_code
        WHERE  interface_res_id = res_dtls_rec.interface_res_id;
        IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(res_dtls_rec.Interface_res_Id,p_error_code);
        END IF;

    END validate_record;
    -- End Local Function


    -- Begin Local procedure
    PROCEDURE crt_res_dtls(
           res_dtl_rec  res_cur%ROWTYPE)
    AS
        l_rowid VARCHAR2(25);
        l_Resident_Details_Id NUMBER;
                l_count NUMBER(5);

BEGIN
        -- Call Log header
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_011.crt_res_dtls.begin';
    l_debug_str := 'Interface Res Id : ' || res_dtl_rec.interface_res_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

-- there is no need to check for date overlap anymore (SWSCR01,02,04)

      Igs_Pe_Res_Dtls_Pkg.Insert_Row (
        X_Mode                              => 'R',
        X_RowId                             => l_rowid,
        X_Resident_Details_Id               => l_Resident_Details_Id,
        X_Person_Id                         => res_dtl_rec.Person_Id,
        X_Residency_Class_cd                => res_dtl_rec.Residency_Class_cd,
        X_Residency_Status_cd               => res_dtl_rec.Residency_Status_cd,
        X_Evaluation_Date                   => res_dtl_rec.Evaluation_Date,
        X_Evaluator                         => res_dtl_rec.Evaluator,
        X_Comments                          => res_dtl_rec.Comments,
        X_Attribute_Category                => res_dtl_rec.Attribute_Category,
        X_Attribute1                        => res_dtl_rec.Attribute1,
        X_Attribute2                        => res_dtl_rec.Attribute2,
        X_Attribute3                        => res_dtl_rec.Attribute3,
        X_Attribute4                        => res_dtl_rec.Attribute4,
        X_Attribute5                        => res_dtl_rec.Attribute5,
        X_Attribute6                        => res_dtl_rec.Attribute6,
        X_Attribute7                        => res_dtl_rec.Attribute7,
        X_Attribute8                        => res_dtl_rec.Attribute8,
        X_Attribute9                        => res_dtl_rec.Attribute9,
        X_Attribute10                       => res_dtl_rec.Attribute10,
        X_Attribute11                       => res_dtl_rec.Attribute11,
        X_Attribute12                       => res_dtl_rec.Attribute12,
        X_Attribute13                       => res_dtl_rec.Attribute13,
        X_Attribute14                       => res_dtl_rec.Attribute14,
        X_Attribute15                       => res_dtl_rec.Attribute15,
        X_Attribute16                       => res_dtl_rec.Attribute16,
        X_Attribute17                       => res_dtl_rec.Attribute17,
        X_Attribute18                       => res_dtl_rec.Attribute18,
        X_Attribute19                       => res_dtl_rec.Attribute19,
        X_Attribute20                       => res_dtl_rec.Attribute20,
        X_cal_type                          => res_dtl_rec.cal_type,
        X_sequence_number                   => res_dtl_rec.sequence_number,
        X_ORG_ID                            => FND_PROFILE.VALUE('ORG_ID')
        );
        --
        -- Insertion Successful
        --
        l_status := '1';
        p_error_code := NULL;

    EXCEPTION
        WHEN OTHERS THEN
            --
            -- Insertion Not Successful
            --
            l_status := '3';
            p_error_code := 'E322';

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.crt_apcnt_acad_hnr.exception'||'E322';

          l_debug_str := 'IGS_AD_IMP_011.PRC_APCNT_ACADHNR_DTLS.CRT_APCNT_ACAD_HNR ' ||
                                                  'STATUS : 3' ||  'ERRORCODE : E322 SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(res_dtl_rec.interface_res_id,'E322');
    END IF;

  END crt_res_dtls;
    -- End Local Procedure


  PROCEDURE  update_res (c_null_hdlg_res_cur_rec   chk_dup_cur%ROWTYPE,
                         res_dtl_rec res_cur%ROWTYPE) AS

-- there is no need to check for date overlap anymore (SWSCR01,02,04)
    l_count NUMBER(5);

  BEGIN


      igs_pe_res_dtls_pkg.update_row (
        x_rowid => c_null_hdlg_res_cur_rec.ROWID,
        X_RESIDENT_DETAILS_ID => c_null_hdlg_res_cur_rec.RESIDENT_DETAILS_ID,
        x_person_id => c_null_hdlg_res_cur_rec.person_id,
        X_RESIDENCY_CLASS_CD => res_dtl_rec.RESIDENCY_CLASS_CD ,
        X_RESIDENCY_STATUS_CD => res_dtl_rec.RESIDENCY_STATUS_CD ,
        X_EVALUATION_DATE => res_dtl_rec.EVALUATION_DATE,
        X_EVALUATOR  => res_dtl_rec.EVALUATOR ,
        X_COMMENTS   => NVL(res_dtl_rec.COMMENTS ,c_null_hdlg_res_cur_rec.COMMENTS),
        X_ATTRIBUTE_CATEGORY => NVL(res_dtl_rec.ATTRIBUTE_CATEGORY,c_null_hdlg_res_cur_rec.ATTRIBUTE_CATEGORY),
        X_ATTRIBUTE1    =>  NVL(res_dtl_rec.ATTRIBUTE1, c_null_hdlg_res_cur_rec.ATTRIBUTE1),
        X_ATTRIBUTE2    =>  NVL(res_dtl_rec.ATTRIBUTE2, c_null_hdlg_res_cur_rec.ATTRIBUTE2),
        X_ATTRIBUTE3    =>  NVL(res_dtl_rec.ATTRIBUTE3, c_null_hdlg_res_cur_rec.ATTRIBUTE3),
        X_ATTRIBUTE4    =>  NVL(res_dtl_rec.ATTRIBUTE4, c_null_hdlg_res_cur_rec.ATTRIBUTE4),
        X_ATTRIBUTE5    =>  NVL(res_dtl_rec.ATTRIBUTE5, c_null_hdlg_res_cur_rec.ATTRIBUTE5),
        X_ATTRIBUTE6    =>  NVL(res_dtl_rec.ATTRIBUTE6, c_null_hdlg_res_cur_rec.ATTRIBUTE6),
        X_ATTRIBUTE7    =>  NVL(res_dtl_rec.ATTRIBUTE7, c_null_hdlg_res_cur_rec.ATTRIBUTE7),
        X_ATTRIBUTE8    =>  NVL(res_dtl_rec.ATTRIBUTE8, c_null_hdlg_res_cur_rec.ATTRIBUTE8),
        X_ATTRIBUTE9    =>  NVL(res_dtl_rec.ATTRIBUTE9, c_null_hdlg_res_cur_rec.ATTRIBUTE9),
        X_ATTRIBUTE10   =>  NVL(res_dtl_rec.ATTRIBUTE10, c_null_hdlg_res_cur_rec.ATTRIBUTE10),
        X_ATTRIBUTE11   =>  NVL(res_dtl_rec.ATTRIBUTE11, c_null_hdlg_res_cur_rec.ATTRIBUTE11),
        X_ATTRIBUTE12   =>  NVL(res_dtl_rec.ATTRIBUTE12, c_null_hdlg_res_cur_rec.ATTRIBUTE12),
        X_ATTRIBUTE13   =>  NVL(res_dtl_rec.ATTRIBUTE13, c_null_hdlg_res_cur_rec.ATTRIBUTE13),
        X_ATTRIBUTE14   =>  NVL(res_dtl_rec.ATTRIBUTE14, c_null_hdlg_res_cur_rec.ATTRIBUTE14),
        X_ATTRIBUTE15   =>  NVL(res_dtl_rec.ATTRIBUTE15, c_null_hdlg_res_cur_rec.ATTRIBUTE15),
        X_ATTRIBUTE16   =>  NVL(res_dtl_rec.ATTRIBUTE16, c_null_hdlg_res_cur_rec.ATTRIBUTE16),
        X_ATTRIBUTE17   =>  NVL(res_dtl_rec.ATTRIBUTE17, c_null_hdlg_res_cur_rec.ATTRIBUTE17),
        X_ATTRIBUTE18   =>  NVL(res_dtl_rec.ATTRIBUTE18, c_null_hdlg_res_cur_rec.ATTRIBUTE18),
        X_ATTRIBUTE19   =>  NVL(res_dtl_rec.ATTRIBUTE19, c_null_hdlg_res_cur_rec.ATTRIBUTE19),
        X_ATTRIBUTE20   =>  NVL(res_dtl_rec.ATTRIBUTE20, c_null_hdlg_res_cur_rec.ATTRIBUTE20),
        X_cal_type      =>  res_dtl_rec.cal_type,
        X_sequence_number => res_dtl_rec.sequence_number,
        x_mode => 'R'
        );


    EXCEPTION
    WHEN OTHERS THEN
        l_status := '3';
        p_error_code := 'E014';
      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.update_res.exception'||'E014';
            l_debug_str :=  'IGS_AD_IMP_011.PRC_PE_RES_DTLS.UPDATE_RES ' ||
                                                  'STATUS : 3' ||  'ERROR CODE : E014 SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(res_dtl_rec.interface_res_id,'E014');
    END IF;

    END update_res;

-- Start of the Main Procedure PRC_PE_RES_DTLS

BEGIN

  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_011.prc_pe_res_dtls';
  l_label := 'igs.plsql.igs_ad_imp_011.prc_pe_res_dtls.';

  l_rule := igs_ad_imp_001.find_source_cat_rule(p_source_type_id,'PERSON_RESIDENCY_DETAILS');

  -- If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_pe_res_dtls_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = cst_stat_val_2
      AND interface_run_id = l_interface_run_id;
  END IF;

  -- If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_pe_res_dtls_int mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_res_dtls_all pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
             AND  UPPER(mi.residency_class_cd) = pe.residency_class_cd
             AND  UPPER(mi.cal_type) = pe.cal_type
             AND  mi.sequence_number = pe.sequence_number);
  END IF;

  -- If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_pe_res_dtls_int
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status = cst_stat_val_2;
  END IF;

  -- If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_pe_res_dtls_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25));
  END IF;

  -- If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_pe_res_dtls_int mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM igs_pe_res_dtls_all pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
                     AND  ii.person_id = pe.person_id
             AND  pe.residency_class_cd = UPPER(mi.Residency_class_cd)
             AND  pe.cal_type = UPPER(mi.cal_type)
             AND  pe.sequence_number = mi.sequence_number
             AND  pe.residency_status_cd = UPPER(mi.Residency_status_cd)
             AND  UPPER(pe.evaluator) = UPPER(mi.evaluator)
             AND  TRUNC(pe.evaluation_date) = TRUNC(mi.evaluation_date)
             AND  ((UPPER(pe.attribute1) = UPPER(mi.attribute1)) OR (pe.attribute1 IS NULL AND mi.attribute1 IS NULL))
             AND  ((UPPER(pe.attribute2) = UPPER(mi.attribute2)) OR (pe.attribute2 IS NULL AND mi.attribute2 IS NULL))
             AND  ((UPPER(pe.attribute3) = UPPER(mi.attribute3)) OR (pe.attribute3 IS NULL AND mi.attribute3 IS NULL))
             AND  ((UPPER(pe.attribute4) = UPPER(mi.attribute4)) OR (pe.attribute4 IS NULL AND mi.attribute4 IS NULL))
             AND  ((UPPER(pe.attribute5) = UPPER(mi.attribute5)) OR (pe.attribute5 IS NULL AND mi.attribute5 IS NULL))
             AND  ((UPPER(pe.attribute6) = UPPER(mi.attribute6)) OR (pe.attribute6 IS NULL AND mi.attribute6 IS NULL))
             AND  ((UPPER(pe.attribute7) =  UPPER(mi.attribute7)) OR (pe.attribute7 IS NULL AND mi.attribute7 IS NULL))
             AND  ((UPPER(pe.attribute8) = UPPER(mi.attribute8)) OR (pe.attribute8 IS NULL AND mi.attribute8 IS NULL))
             AND  ((UPPER(pe.attribute9) = UPPER(mi.attribute9)) OR (pe.attribute9 IS NULL AND mi.attribute9 IS NULL))
             AND  ((UPPER(pe.attribute10) = UPPER(mi.attribute10)) OR (pe.attribute10 IS NULL AND mi.attribute10 IS NULL))
             AND  ((UPPER(pe.attribute11) = UPPER(mi.attribute11)) OR (pe.attribute11 IS NULL AND mi.attribute11 IS NULL))
             AND  ((UPPER(pe.attribute12) = UPPER(mi.attribute12)) OR (pe.attribute12 IS NULL AND mi.attribute12 IS NULL))
             AND  ((UPPER(pe.attribute13) = UPPER(mi.attribute13)) OR (pe.attribute13 IS NULL AND mi.attribute13 IS NULL))
             AND  ((UPPER(pe.attribute14) = UPPER(mi.attribute14)) OR (pe.attribute14 IS NULL AND mi.attribute14 IS NULL))
             AND  ((UPPER(pe.attribute15) = UPPER(mi.attribute15)) OR (pe.attribute15 IS NULL AND mi.attribute15 IS NULL))
             AND  ((UPPER(pe.attribute16) = UPPER(mi.attribute16)) OR (pe.attribute16 IS NULL AND mi.attribute16 IS NULL))
             AND  ((UPPER(pe.attribute17) = UPPER(mi.attribute17)) OR (pe.attribute17 IS NULL AND mi.attribute17 IS NULL))
             AND  ((UPPER(pe.attribute18) = UPPER(mi.attribute18)) OR (pe.attribute18 IS NULL AND mi.attribute18 IS NULL))
             AND  ((UPPER(pe.attribute19) = UPPER(mi.attribute19)) OR (pe.attribute19 IS NULL AND mi.attribute19 IS NULL))
             AND  ((UPPER(pe.attribute20) = UPPER(mi.attribute20)) OR (pe.attribute20 IS NULL AND mi.attribute20 IS NULL)));
  END IF;

  -- If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_pe_res_dtls_int mi
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                  FROM igs_pe_res_dtls_all pe, igs_ad_interface_all ii
                  WHERE  ii.interface_run_id = l_interface_run_id
                  AND  ii.interface_id = mi.interface_id
                  AND  ii.person_id = pe.person_id
                  AND  UPPER(mi.residency_class_cd) = pe.residency_class_cd
                  AND  UPPER(mi.cal_type) = pe.cal_type
                  AND  mi.sequence_number = pe.sequence_number);
  END IF;

  FOR res_dtl_rec IN res_cur(l_interface_run_id)
  LOOP
    l_processed_records := l_processed_records + 1 ;
    --
    -- Set the status, error_code, match_ind variables to the existing values
    --
    l_status := res_dtl_rec.status;
    p_error_code := res_dtl_rec.ERROR_CODE;
    l_match_ind := res_dtl_rec.match_ind;
    res_dtl_rec.residency_class_cd := UPPER(res_dtl_rec.residency_class_cd);
    res_dtl_rec.residency_status_cd := UPPER(res_dtl_rec.residency_status_cd);
    res_dtl_rec.evaluation_date := TRUNC(res_dtl_rec.evaluation_date);
    res_dtl_rec.cal_type := UPPER(res_dtl_rec.cal_type);

    BEGIN

      chk_dup_rec.residency_class_cd := NULL;
      OPEN chk_dup_cur(res_dtl_rec);
      FETCH chk_dup_cur INTO chk_dup_rec;
      CLOSE chk_dup_cur;

      IF chk_dup_rec.residency_class_cd IS NOT NULL THEN
                -- To be changed as a generic change
        IF l_rule = 'I' THEN
          BEGIN
           -- validate the record.
            validate_record (res_dtl_rec, p_error_code,'U');
            IF p_error_code IS NULL THEN
              -- call the update.
              update_res (chk_dup_rec , res_dtl_rec);
              l_match_ind := '18';
              l_status := '1';
            ELSIF  p_error_code IS NOT NULL THEN
                l_match_ind := NULL;
                l_status := '3';
            END IF;
          END;
        ELSIF l_rule = 'R' THEN
          IF res_dtl_rec.match_ind = '21' THEN
          BEGIN
            validate_record (  res_dtl_rec, p_error_code,'U');
            IF p_error_code IS NULL THEN
               -- call the update.
              update_res (chk_dup_rec , res_dtl_rec);
              l_match_ind := '18';
              l_status := '1';
            ELSIF  p_error_code IS NOT NULL THEN
              l_match_ind := NULL;
              l_status := '3';
            END IF;
          END;
          END IF;
        END IF;
      ELSE
        validate_record ( res_dtl_rec, p_error_code,'I');
        IF  p_error_code IS NULL THEN
          -- Validation Successful, so create record
          crt_res_dtls( res_dtl_rec);
        ELSIF  p_error_code IS NOT NULL THEN
          l_status := '3';
        END IF;
      END IF;
      --
      -- Update the interface record with the status, error_code, match_ind, only when NOT coming from UCAS.
      --
      UPDATE igs_pe_res_dtls_int
      SET status = l_status,
      error_code = p_error_code,
      match_ind = l_match_ind
      WHERE interface_res_id = res_dtl_rec.interface_res_id;

  EXCEPTION
    WHEN OTHERS THEN
    UPDATE igs_pe_res_dtls_int
    SET
        status = '3',
        error_code = 'E518'
    WHERE interface_res_id = res_dtl_rec.interface_res_id;
      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.prc_pe_res_dtls.exception'||'E518';

          l_debug_str :=  'IGS_AD_IMP_011.PRC_PE_RES_DTLS ' ||
                                   'INTERFACE RES ID : ' || TO_CHAR(res_dtl_rec.interface_res_id) ||
                                    'STATUS : 3' ||  'ERRORCODE : E518 SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(res_dtl_rec.interface_res_id,'E518');
    END IF;

  END ;
    IF l_processed_records = 100 THEN
      COMMIT;
      l_processed_records := 0 ;
    END IF;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
    -- Close the cursors if open
    IF chk_dup_cur%ISOPEN THEN
        CLOSE chk_dup_cur;
    END IF;
END prc_pe_res_dtls;


PROCEDURE  prc_special_needs (
                   p_source_type_id     IN      NUMBER,
                   p_batch_id   IN      NUMBER )
    AS
 /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 06-Jul-2001
  ||  Purpose : This procedure is for importing person Special Need Information.
  ||            DLD: Person Interface DLD.  Enh Bug# 2103692.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || npalanis         6-JAN-2003      Bug : 2734697
  ||                                  code added to commit after import of every
  ||                                  100 records .New variable l_processed_records added
  ||  pkpatel         23-DEC-2002     Bug No: 2722027
  ||                                  Added NVL in the cursor dup_chk_disability_cur
  ||  pkpatel       22-JUN-2001       Bug no.2466466
  ||                                  Modified the parent/child processing.
  ||  pkpatel       2-JUN-2003        Bug no.2986796 (special Needs CCR, jul'03)
  ||                                  MOdified the processing for NONE records. Modified to use bind variables.
  ||  pkpatel       20-Sep-2005       Bug 3716764 (Modified the Update to disability_int table under sp_disability_cur loop)
  ||  (reverse chronological order - newest change first)
  */

        l_default_date  DATE := TO_DATE('4712/12/31','YYYY/MM/DD');

       -- Variable to hold the Disability ID of the Parent Person Disability Record
        l_disability_id  igs_pe_pers_disablty.igs_pe_pers_disablty_id%TYPE;
        l_processed_records NUMBER(5) := 0;
      -- Variables for logging
      l_prog_label  VARCHAR2(4000);
      l_label  VARCHAR2(4000);
      l_debug_str VARCHAR2(4000);
      l_enable_log VARCHAR2(1);
      l_request_id NUMBER(10);
      l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
      l_rule igs_ad_source_cat.discrepancy_rule_cd%TYPE;

        --Pick up the records for processing from the Special Needs Disability Interface Table
        CURSOR disability_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
        SELECT  mi.*,i.person_id
        FROM    igs_ad_disablty_int_all  mi,igs_ad_interface_all i
        WHERE  mi.interface_run_id = cp_interface_run_id
          AND  i.interface_run_id = cp_interface_run_id
          AND  mi.interface_id =  i.interface_id
          AND  mi.status = '2';

        -- Pick up the records processed before the loop from the Disability Interface Table
    CURSOR sp_disability_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
    SELECT mi.*,i.person_id
        FROM   igs_ad_disablty_int_all  mi,igs_ad_interface_all i
        WHERE  mi.interface_run_id = cp_interface_run_id
          AND  i.interface_run_id = cp_interface_run_id
          AND  mi.interface_id =  i.interface_id
          AND  mi.status = '1'
          AND  mi.match_ind IN (cst_mi_val_23,cst_mi_val_19);

    --Pick up the records for processing from the Special Needs Service Interface Table
        CURSOR sn_service_cur(cp_interface_disablty_id igs_ad_disablty_int.interface_disablty_id%TYPE,
                          cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE ) IS
        SELECT  ai.*
        FROM    igs_pe_sn_srvce_int ai,
                igs_ad_disablty_int_all ad
        WHERE   ai.interface_run_id = cp_interface_run_id AND
            ad.interface_run_id = cp_interface_run_id AND
                ai.interface_disablty_id = cp_interface_disablty_id AND
        ai.interface_disablty_id = ad.interface_disablty_id AND
        ai.status = '2';

        --Pick up the records for processing from the Special Needs Contact Interface Table
        CURSOR sn_contact_cur(cp_interface_disablty_id igs_ad_disablty_int.interface_disablty_id%TYPE,
                          cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE ) IS
        SELECT  ai.*
        FROM    igs_pe_sn_conct_int ai,
                igs_ad_disablty_int_all ad
        WHERE   ai.interface_run_id = cp_interface_run_id AND
                ad.interface_run_id = cp_interface_run_id AND
                ai.interface_disablty_id = cp_interface_disablty_id AND
        ai.interface_disablty_id = ad.interface_disablty_id AND
                ai.status = '2';



        --Cursor to check whether the Record in Interface Table already exists in OSS table for Disability
        CURSOR dup_chk_disability_cur(cp_disability_rec disability_cur%ROWTYPE) IS
        SELECT  rowid, pd.*
        FROM     igs_pe_pers_disablty pd
        WHERE    pd.disability_type = cp_disability_rec.disability_type AND
                 pd.person_id = cp_disability_rec.person_id AND
                 NVL(TRUNC(pd.start_date),l_default_date) = NVL(TRUNC(cp_disability_rec.start_date),l_default_date);

        --Cursor to check whether the Record in Interface Table already exists in OSS table for Special Need Service
    -- kumma, changed the duplicate check criteria to include the start_dt as a part of the unique key

        CURSOR dup_chk_sn_service_cur(cp_disability_id igs_pe_sn_service.disability_id%TYPE,
                               cp_special_service_cd igs_pe_sn_service.special_service_cd%TYPE,
                               cp_start_dt           igs_pe_sn_service.start_dt%TYPE) IS
        SELECT  rowid, sn.*
        FROM    igs_pe_sn_service sn
        WHERE   sn.disability_id = cp_disability_id  AND
                sn.special_service_cd = cp_special_service_cd AND
                NVL(TRUNC(sn.start_dt),l_default_date) = NVL(TRUNC(cp_start_dt),l_default_date);

        --Cursor to check whether the Record in Interface Table already exists in OSS table for Special Need Contact
        CURSOR dup_chk_sn_contact_cur(cp_disability_id igs_pe_sn_contact.disability_id%TYPE,
                               cp_contact_name igs_pe_sn_contact.contact_name%TYPE,
                   cp_contact_date igs_pe_sn_contact.contact_date%TYPE) IS
        SELECT  rowid, sn.*
        FROM    igs_pe_sn_contact sn
        WHERE   sn.disability_id = cp_disability_id  AND
                NVL(sn.contact_name,'~') = NVL(cp_contact_name,'~') AND
                NVL(TRUNC(sn.contact_date),l_default_date) = NVL(TRUNC(cp_contact_date),l_default_date);


        CURSOR check_none_disablity_cur(cp_disability_type igs_ad_disbl_type.disability_type%TYPE,
                                        cp_govt_disability_type igs_ad_disbl_type.govt_disability_type%TYPE) IS
        SELECT 'X'
        FROM   igs_ad_disbl_type
        WHERE  disability_type = cp_disability_type AND
               govt_disability_type = cp_govt_disability_type;

        disability_rec                disability_cur%ROWTYPE;
    sp_disability_rec             sp_disability_cur%ROWTYPE;
        sn_service_rec                sn_service_cur%ROWTYPE;
        sn_contact_rec                sn_contact_cur%ROWTYPE;
        dup_chk_disability_rec        dup_chk_disability_cur%ROWTYPE;
        dup_chk_sn_service_rec        dup_chk_sn_service_cur%ROWTYPE;
        dup_chk_sn_contact_rec        dup_chk_sn_contact_cur%ROWTYPE;

        -- Start of Local Procedure validate_disability
        --
        PROCEDURE validate_disability(p_disability_rec  disability_cur%ROWTYPE,
                                      l_success OUT NOCOPY VARCHAR2,
                                      l_error_code OUT NOCOPY VARCHAR2)
        IS
        /*
        ||  Created By : prabhat.patel@Oracle.com
        ||  Created On : 22-NOV-2001
        ||  Purpose : This is a private procedure is for validating Person Disability Information.
        ||            DLD: Person Interface DLD.  Enh Bug# 2103692.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        || npalanis        16-JUN-2002      Bug -2327077
        ||                                  Validation done to check if the disability type is None or not.
        || npalanis        23-JUL-2002      Bug - 2421897
        ||                                  Error codes E008 changed to valid ones
        */
                CURSOR validate_disablty_cur(cp_disability_type igs_ad_disbl_type.disability_type%TYPE,
                                             cp_closed_ind      igs_ad_disbl_type.closed_ind%TYPE) IS
                SELECT  'X'
                FROM    igs_ad_disbl_type
                WHERE   disability_type = cp_disability_type AND
                        closed_ind = cp_closed_ind;

                CURSOR validate_interviewer_cur(cp_interviewer_id igs_pe_person_base_v.person_id%TYPE) IS
                SELECT birth_date
                FROM   igs_pe_person_base_v
                WHERE  person_id = cp_interviewer_id;

                CURSOR birth_dt_cur(p_person_id IGS_AD_INTERFACE.PERSON_ID%TYPE) IS
                SELECT birth_date
                FROM igs_pe_person_base_v
                WHERE  person_id= p_person_id;

                l_birth_date IGS_AD_INTERFACE.BIRTH_DT%TYPE;
                l_person_id  IGS_AD_INTERFACE.PERSON_ID%TYPE;
                l_count NUMBER(5);
                l_var VARCHAR2(2);

                validate_disablty_rec validate_disablty_cur%ROWTYPE;
                validate_interviewer_rec     validate_interviewer_cur%ROWTYPE;
        BEGIN

    -- Disability Validation
    OPEN validate_disablty_cur(p_disability_rec.disability_type,'N');
    FETCH validate_disablty_cur INTO validate_disablty_rec;
    IF validate_disablty_cur%NOTFOUND THEN
        CLOSE validate_disablty_cur;
        l_error_code := 'E098' ;
        RAISE NO_DATA_FOUND;
    ELSE
        CLOSE validate_disablty_cur;
        l_error_code := NULL;
    END IF;

    -- Early Registration Indicator Validation
    IF p_disability_rec.elig_early_reg_ind NOT IN('Y','N') THEN
         l_error_code := 'E139' ;
         RAISE NO_DATA_FOUND;
    END IF;

    -- Special Allowance Validation
    IF ( p_disability_rec.special_allow_cd IS NOT NULL)  THEN
        IF NOT
          (igs_pe_pers_imp_001.validate_lookup_type_code('PE_SN_ALLOW',p_disability_rec.special_allow_cd,8405))
        THEN
            l_error_code := 'E140' ;
            RAISE NO_DATA_FOUND;
        ELSE
            l_error_code := NULL;
        END IF;
    END IF;

    -- Support Level Validation
    IF ( p_disability_rec.support_level_cd IS NOT NULL)  THEN
      IF NOT
        (igs_pe_pers_imp_001.validate_lookup_type_code('PE_SN_ADD_SUP_LVL',p_disability_rec.support_level_cd,8405))
      THEN
        l_error_code := 'E141' ;
        RAISE NO_DATA_FOUND;
      ELSE
        l_error_code := NULL;
      END IF;
    END IF;
    --
        -- Start Date and End Date validation
        --
        IF p_disability_rec.start_date > NVL(p_disability_rec.end_date,l_default_date) THEN
                            l_error_code := 'E142' ;
                            RAISE NO_DATA_FOUND;
        END IF;

               -- Validate that birth date , start date and  interviewer_date ,  birth date
                  OPEN birth_dt_cur(p_disability_rec.person_id) ;
                  FETCH birth_dt_cur INTO l_birth_date;
                  IF l_birth_date IS NOT NULL THEN
                     IF p_disability_rec.start_date < l_birth_date THEN
                             l_error_code := 'E222' ;
                             CLOSE birth_dt_cur;
                             RAISE NO_DATA_FOUND;
                     END IF;
                     IF p_disability_rec.interviewer_date IS NOT NULL AND p_disability_rec.interviewer_date < l_birth_date THEN
                             l_error_code := 'E281' ;
                             CLOSE birth_dt_cur;
                             RAISE NO_DATA_FOUND;
                     END IF;
                  END IF;
                  CLOSE birth_dt_cur;


        --Validation check of Descriptive Flexfield
        --
        IF NOT igs_ad_imp_018.validate_desc_flex(
                                 p_attribute_category =>p_disability_rec.attribute_category,
                                 p_attribute1         =>p_disability_rec.attribute1  ,
                                 p_attribute2         =>p_disability_rec.attribute2  ,
                                 p_attribute3         =>p_disability_rec.attribute3  ,
                                 p_attribute4         =>p_disability_rec.attribute4  ,
                                 p_attribute5         =>p_disability_rec.attribute5  ,
                                 p_attribute6         =>p_disability_rec.attribute6  ,
                                 p_attribute7         =>p_disability_rec.attribute7  ,
                                 p_attribute8         =>p_disability_rec.attribute8  ,
                                 p_attribute9         =>p_disability_rec.attribute9  ,
                                 p_attribute10        =>p_disability_rec.attribute10 ,
                                 p_attribute11        =>p_disability_rec.attribute11 ,
                                 p_attribute12        =>p_disability_rec.attribute12 ,
                                 p_attribute13        =>p_disability_rec.attribute13 ,
                                 p_attribute14        =>p_disability_rec.attribute14 ,
                                 p_attribute15        =>p_disability_rec.attribute15 ,
                                 p_attribute16        =>p_disability_rec.attribute16 ,
                                 p_attribute17        =>p_disability_rec.attribute17 ,
                                 p_attribute18        =>p_disability_rec.attribute18 ,
                                 p_attribute19        =>p_disability_rec.attribute19 ,
                                 p_attribute20        =>p_disability_rec.attribute20 ,
                                 p_desc_flex_name     =>'IGS_PE_PERS_DISABLTY_FLEX' ) THEN

                                l_error_code := 'E143' ;
                                RAISE NO_DATA_FOUND;
            END IF;

                --
                -- Interviewer ID Validation
                --
                IF ( p_disability_rec.interviewer_id IS NOT NULL)  THEN

                        IF p_disability_rec.person_id = p_disability_rec.interviewer_id THEN
                             l_error_code := 'E144' ;
                             RAISE NO_DATA_FOUND;
                        END IF;

                        OPEN validate_interviewer_cur(p_disability_rec.interviewer_id);
                        FETCH validate_interviewer_cur INTO validate_interviewer_rec;

                        IF validate_interviewer_cur%NOTFOUND THEN
                                CLOSE validate_interviewer_cur;
                                l_error_code := 'E144' ;
                                RAISE NO_DATA_FOUND;
                        ELSE
                                CLOSE validate_interviewer_cur;
                                l_error_code := NULL;
                        END IF;
                END IF;

                UPDATE  igs_ad_disablty_int_all
                SET     status = '1',
                        ERROR_CODE = NULL
                WHERE   interface_disablty_id = p_disability_rec.interface_disablty_id;

                l_success := 'Y';
        EXCEPTION
                WHEN  NO_DATA_FOUND THEN

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(p_disability_rec.interface_disablty_id,l_error_code,'IGS_AD_DISABLTY_INT_ALL');
        END IF;

                  UPDATE  igs_ad_disablty_int_all
                  SET     status = '3',
                          ERROR_CODE = l_error_code
                  WHERE   interface_disablty_id = p_disability_rec.interface_disablty_id;

                        l_success := 'N';
        END validate_disability;
        --
        -- End Local Validate_Disability
        --

-- Start of Local Procedure validate_sn_service
--
        PROCEDURE validate_sn_service(p_sn_service_rec  sn_service_cur%ROWTYPE,
                                      p_person_id       igs_ad_interface.person_id%type,
                                      l_success OUT NOCOPY VARCHAR2,
                                      l_error_code OUT NOCOPY VARCHAR2)
        IS
        /*
        ||  Created By : prabhat.patel@Oracle.com
        ||  Created On : 22-NOV-2001
        ||  Purpose : This is a private procedure is for validating Person Special Need Information.
        ||            DLD: Person Interface DLD.  Enh Bug# 2103692.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  kumma           21-OCT-2002     Added validations for start date and end date
        ||  (reverse chronological order - newest change first)
        */

                CURSOR birth_dt_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
                SELECT birth_date
                FROM igs_pe_person_base_v
                WHERE  person_id= cp_person_id;

                l_birth_date IGS_AD_INTERFACE.BIRTH_DT%TYPE;
        BEGIN
            --
        -- Special Service code
        --

        IF  NOT
        (igs_pe_pers_imp_001.validate_lookup_type_code('PE_SN_SERVICE',p_sn_service_rec.special_service_cd,8405))
        THEN
                  l_error_code := 'E149';
                  RAISE NO_DATA_FOUND;
            ELSE
                  l_error_code := NULL;
            END IF;

                --
        --Documented Indicator
        --

        IF p_sn_service_rec.documented_ind NOT IN ('N', 'Y') THEN

                  l_error_code := 'E150';
                  RAISE NO_DATA_FOUND;
        END IF;


                -- kumma, 2608360 Added validations for start date and end_date

        IF p_sn_service_rec.start_dt IS NULL AND p_sn_service_rec.end_dt IS NOT NULL THEN

              l_error_code := 'E326';
              RAISE NO_DATA_FOUND;
        END IF;



        IF p_sn_service_rec.start_dt IS NOT NULL AND p_sn_service_rec.end_dt IS NOT NULL THEN
          IF TRUNC(p_sn_service_rec.start_dt) > TRUNC(p_sn_service_rec.end_dt) THEN

                          l_error_code := 'E208';
              RAISE NO_DATA_FOUND;
          END IF;
        END IF;


                IF p_sn_service_rec.start_dt IS NOT NULL THEN
                          OPEN birth_dt_cur(p_person_id);
                               FETCH birth_dt_cur INTO l_birth_date;
                               IF l_birth_date IS NOT NULL AND TRUNC(p_sn_service_rec.start_dt) < TRUNC(l_birth_date) THEN
                                  l_error_code := 'E222';
                                  CLOSE birth_dt_cur;
                                  RAISE NO_DATA_FOUND;
                               END IF;
                          CLOSE birth_dt_cur;
                END IF;

                UPDATE  igs_pe_sn_srvce_int
                SET     status = '1',
                        ERROR_CODE = NULL
                WHERE   interface_sn_service_id = p_sn_service_rec.interface_sn_service_id;

                l_success := 'Y';

        EXCEPTION

              WHEN NO_DATA_FOUND THEN
                  IF l_enable_log = 'Y' THEN
                    igs_ad_imp_001.logerrormessage(p_sn_service_rec.interface_sn_service_id,l_error_code,'IGS_PE_SN_SRVCE_INT');
                  END IF;


                UPDATE     igs_pe_sn_srvce_int
                SET        status = '3',
                           ERROR_CODE = l_error_code
                WHERE      interface_sn_service_id = p_sn_service_rec.interface_sn_service_id;

                        l_success := 'N';

        END validate_sn_service;
-- Start of Local Procedure validate_sn_contact
--
        PROCEDURE validate_sn_contact(p_sn_contact_rec  sn_contact_cur%ROWTYPE,
                                      p_person_id       igs_ad_interface.person_id%TYPE,
                                      l_success OUT NOCOPY VARCHAR2,
                                      l_error_code OUT NOCOPY VARCHAR2)
        IS
        /*
        ||  Created By : npalanis
        ||  Created On : 21-May-2002
        ||  Purpose : Adding validation to make it consistent with form functions
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        */
                CURSOR birth_dt_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
                SELECT birth_date
                FROM igs_pe_person_base_v
                WHERE  person_id= cp_person_id;

                l_birth_date IGS_AD_INTERFACE.BIRTH_DT%TYPE;
        BEGIN
              IF  p_sn_contact_rec.contact_date IS NOT NULL THEN
                      OPEN birth_dt_cur(p_person_id);
                      FETCH birth_dt_cur INTO l_birth_date;
                          IF l_birth_date IS NOT NULL AND p_sn_contact_rec.contact_date < l_birth_date THEN
                                  l_error_code := 'E282';
                                  CLOSE birth_dt_cur;
                                  RAISE NO_DATA_FOUND;
                          END IF;
                      CLOSE birth_dt_cur;
               END IF;

                l_success := 'Y';

        EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  IF l_enable_log = 'Y' THEN
                    igs_ad_imp_001.logerrormessage(p_sn_contact_rec.interface_sn_contact_id,l_error_code,'IGS_PE_SN_CONCT_INT');
                  END IF;

                UPDATE     igs_pe_sn_conct_int
                SET        status = '3',
                           ERROR_CODE = l_error_code
                WHERE      interface_sn_contact_id = p_sn_contact_rec.interface_sn_contact_id;

                        l_success := 'N';

        END validate_sn_contact;



    --Local Procedure to create a Disability record
    PROCEDURE  create_disability(p_disability_rec  disability_cur%ROWTYPE,
                                 p_error_code    OUT NOCOPY  igs_ad_disablty_int.ERROR_CODE%TYPE)
    AS
    /*
        ||  Created By : prabhat.patel@Oracle.com
        ||  Created On : 22-NOV-2001
        ||  Purpose : This is a private procedure is for creating Person Disability Record.
        ||            DLD: Person Interface DLD.  Enh Bug# 2103692.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        */
            l_rowid VARCHAR2(25);
            l_success    VARCHAR2(1);
            l_message_name VARCHAR2(30);
            l_app          VARCHAR2(50);

  BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_011.create_disability.begin';
    l_debug_str := 'Interface Disability Id : ' || p_disability_rec.interface_disablty_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

                validate_disability(p_disability_rec, l_success, p_error_code);
                IF l_success = 'Y' THEN -- Successful Validation

                        igs_pe_pers_disablty_pkg.insert_row (
                        x_rowid => l_rowid ,
                        X_IGS_PE_PERS_DISABLTY_ID => l_disability_id,
                        x_person_id => p_disability_rec.person_id,
                        x_disability_type  => p_disability_rec.disability_type,
                        x_contact_ind  => NULL,
                        x_special_allow_cd  => p_disability_rec.special_allow_cd,
                        x_support_level_cd  => p_disability_rec.support_level_cd,
                        x_documented  => NULL,
                        x_special_service_id  => NULL,
                        x_attribute_category  => p_disability_rec.attribute_category,
                        x_attribute1  =>  p_disability_rec.attribute1,
                        x_attribute2  =>  p_disability_rec.attribute2,
                        x_attribute3  =>  p_disability_rec.attribute3,
                        x_attribute4  =>  p_disability_rec.attribute4,
                        x_attribute5  =>  p_disability_rec.attribute5,
                        x_attribute6  =>  p_disability_rec.attribute6,
                        x_attribute7  =>  p_disability_rec.attribute7,
                        x_attribute8  =>  p_disability_rec.attribute8,
                        x_attribute9  =>  p_disability_rec.attribute9,
                        x_attribute10  => p_disability_rec.attribute10,
                        x_attribute11  => p_disability_rec.attribute11,
                        x_attribute12  => p_disability_rec.attribute12,
                        x_attribute13  => p_disability_rec.attribute13,
                        x_attribute14  => p_disability_rec.attribute14,
                        x_attribute15  => p_disability_rec.attribute15,
                        x_attribute16  => p_disability_rec.attribute16,
                        x_attribute17  => p_disability_rec.attribute17,
                        x_attribute18  => p_disability_rec.attribute18,
                        x_attribute19  => p_disability_rec.attribute19,
                        x_attribute20  => p_disability_rec.attribute20,
                        x_elig_early_reg_ind => NVL(p_disability_rec.elig_early_reg_ind,'N'),
                        x_start_date => p_disability_rec.start_date,
                        x_end_date => p_disability_rec.end_date,
                        x_info_source => p_disability_rec.info_source,
                        x_interviewer_id => p_disability_rec.interviewer_id,
                        x_interviewer_date => p_disability_rec.interviewer_date,
                        x_mode => 'R'
                    );
                        p_error_code := NULL;

                        UPDATE igs_ad_disablty_int_all
                        SET    status ='1',
                               ERROR_CODE = p_error_code
                        WHERE interface_disablty_id = p_disability_rec.interface_disablty_id;

                --ELSE 'Validation is Unsuccessful. It has been taken care in Validate_Disability Procedure'

                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                    FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);
                    IF l_message_name = 'IGS_PE_NO_NONE_SN' THEN
                      p_error_code := 'E269';
                    ELSIF l_message_name = 'IGS_EN_PRSN_NOTHAVE_DIABREC' THEN
                      p_error_code := 'E270';
                    ELSE
                      p_error_code := 'E145';
                    END IF;


                        UPDATE igs_ad_disablty_int_all
                        SET    status ='3',
                               ERROR_CODE = p_error_code
                        WHERE interface_disablty_id = p_disability_rec.interface_disablty_id;

                    IF  p_error_code = 'E145' THEN
              IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                IF (l_request_id IS NULL) THEN
                  l_request_id := fnd_global.conc_request_id;
                END IF;
                l_label := 'igs.plsql.igs_ad_imp_011.create_disability.exception'||'E145';
                  l_debug_str :=  'Igs_Ad_Imp_011.Prc_Pe_Spl_Needs.Create_Disability '||'Unhandled Exception'
                ||' for INTERFACE DISABLTY ID :'|| p_disability_rec.interface_disablty_id|| ' Status : 3'||
                ' ErrorCode :'|| p_error_code||' SQLERRM :'|| SQLERRM;
                fnd_log.string_with_context( fnd_log.level_exception,
                              l_label,
                              l_debug_str, NULL,
                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
              END IF;
            IF l_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(p_disability_rec.interface_disablty_id,'E145','IGS_AD_DISABLTY_INT_ALL');
            END IF;
                    ELSE
              IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                IF (l_request_id IS NULL) THEN
                  l_request_id := fnd_global.conc_request_id;
                END IF;
                l_label := 'igs.plsql.igs_ad_imp_011.create_disability.exception'||p_error_code;
                  l_debug_str :=  'Igs_Ad_Imp_011.Prc_Pe_Spl_Needs.Create_Disability '||'Ovelapping records exist'
                             ||' for INTERFACE DISABLTY ID :'|| p_disability_rec.interface_disablty_id|| ' Status : 3'
                 ||  ' ErrorCode :'|| p_error_code|| SQLERRM;
                fnd_log.string_with_context( fnd_log.level_exception,
                              l_label,
                              l_debug_str, NULL,
                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
              END IF;
            IF l_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(p_disability_rec.interface_disablty_id,p_error_code,'IGS_AD_DISABLTY_INT_ALL');
            END IF;
        END IF;


        END create_disability;

    PROCEDURE  update_disability(p_disability_rec  disability_cur%ROWTYPE,
                                 p_dup_chk_disability_rec  dup_chk_disability_cur%ROWTYPE)
    AS
    /*
        ||  Created By : prabhat.patel@Oracle.com
        ||  Created On : 2-JUN-2003
        ||  Purpose : This is a private procedure is for updating Person Disability Record.
                      Enh Bug: 2986796.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        */
            l_rowid VARCHAR2(25);
            l_success    VARCHAR2(1);
            l_message_name VARCHAR2(30);
            l_app          VARCHAR2(50);
        l_error_code   VARCHAR2(30);
  BEGIN
    igs_pe_pers_disablty_pkg.update_row(
            x_rowid                 => p_dup_chk_disability_rec.rowid,
            x_igs_pe_pers_disablty_id => p_dup_chk_disability_rec.igs_pe_pers_disablty_id,
            x_person_id             => p_dup_chk_disability_rec.person_id,
            x_disability_type       => p_dup_chk_disability_rec.disability_type,
            x_contact_ind           => p_dup_chk_disability_rec.contact_ind,
            x_special_allow_cd      => NVL( p_disability_rec.special_allow_cd, p_dup_chk_disability_rec.special_allow_cd),
            x_support_level_cd      => NVL( p_disability_rec.support_level_cd, p_dup_chk_disability_rec.support_level_cd),
            x_documented            => p_dup_chk_disability_rec.documented,
            x_special_service_id    => p_dup_chk_disability_rec.special_service_id,
            x_attribute_category    => NVL(p_disability_rec.attribute_category,p_dup_chk_disability_rec.attribute_category),
            x_attribute1            => NVL(p_disability_rec.attribute1,p_dup_chk_disability_rec.attribute1),
            x_attribute2            => NVL(p_disability_rec.attribute2,p_dup_chk_disability_rec.attribute2),
            x_attribute3            => NVL(p_disability_rec.attribute3,p_dup_chk_disability_rec.attribute3),
            x_attribute4            => NVL(p_disability_rec.attribute4,p_dup_chk_disability_rec.attribute4),
            x_attribute5            => NVL(p_disability_rec.attribute5,p_dup_chk_disability_rec.attribute5),
            x_attribute6            => NVL(p_disability_rec.attribute6,p_dup_chk_disability_rec.attribute6),
            x_attribute7            => NVL(p_disability_rec.attribute7,p_dup_chk_disability_rec.attribute7),
            x_attribute8            => NVL(p_disability_rec.attribute8,p_dup_chk_disability_rec.attribute8),
            x_attribute9            => NVL(p_disability_rec.attribute9,p_dup_chk_disability_rec.attribute9),
            x_attribute10           => NVL(p_disability_rec.attribute10,p_dup_chk_disability_rec.attribute10),
            x_attribute11           => NVL(p_disability_rec.attribute11,p_dup_chk_disability_rec.attribute11),
            x_attribute12           => NVL(p_disability_rec.attribute12,p_dup_chk_disability_rec.attribute12),
            x_attribute13           => NVL(p_disability_rec.attribute13,p_dup_chk_disability_rec.attribute13),
            x_attribute14           => NVL(p_disability_rec.attribute14,p_dup_chk_disability_rec.attribute14),
            x_attribute15           => NVL(p_disability_rec.attribute15,p_dup_chk_disability_rec.attribute15),
            x_attribute16           => NVL(p_disability_rec.attribute16,p_dup_chk_disability_rec.attribute16),
            x_attribute17           => NVL(p_disability_rec.attribute17,p_dup_chk_disability_rec.attribute17),
            x_attribute18           => NVL(p_disability_rec.attribute18,p_dup_chk_disability_rec.attribute18),
            x_attribute19           => NVL(p_disability_rec.attribute19,p_dup_chk_disability_rec.attribute19),
            x_attribute20           => NVL(p_disability_rec.attribute20,p_dup_chk_disability_rec.attribute20),
            x_elig_early_reg_ind    => NVL(p_disability_rec.elig_early_reg_ind,p_dup_chk_disability_rec.elig_early_reg_ind),
            x_start_date            => NVL(p_disability_rec.start_date,p_dup_chk_disability_rec.start_date),
            x_end_date              => NVL(p_disability_rec.end_date,p_dup_chk_disability_rec.end_date),
            x_info_source           => NVL(p_disability_rec.info_source,p_dup_chk_disability_rec.info_source),
            x_interviewer_id        => NVL(p_disability_rec.interviewer_id,p_dup_chk_disability_rec.interviewer_id),
            x_interviewer_date      => NVL(p_disability_rec.interviewer_date,p_dup_chk_disability_rec.interviewer_date),
            x_mode                  => 'R'
                );
        l_error_code := NULL;

        UPDATE igs_ad_disablty_int_all
        SET    status =cst_stat_val_1,
            error_code = l_error_code,
            match_ind = cst_mi_val_18 -- '18' Match occured and used import values
        WHERE interface_disablty_id = p_disability_rec.interface_disablty_id;

        EXCEPTION
           WHEN OTHERS THEN
            FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);
            IF l_message_name = 'IGS_PE_NO_NONE_SN' THEN
              l_error_code := 'E269';
            ELSIF l_message_name = 'IGS_EN_PRSN_NOTHAVE_DIABREC' THEN
              l_error_code := 'E270';
            ELSE
              l_error_code := 'E146';
            END IF;

             UPDATE igs_ad_disablty_int_all
             SET    status ='3',
                    error_code = l_error_code
             WHERE interface_disablty_id = p_disability_rec.interface_disablty_id;

              IF l_error_code = 'E146' THEN
          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.update_disability.exception'||l_error_code;

              l_debug_str :=  'Igs_Ad_Imp_011.Prc_Pe_Spl_Needs.update_disability '||'Unhandled Exception'
                 ||' for INTERFACE DISABLTY ID :'
             || p_disability_rec.interface_disablty_id|| ' Status : 3'||  ' ErrorCode :' ||
             l_error_code||' SQLERRM: '|| SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(p_disability_rec.interface_disablty_id,l_error_code,'IGS_AD_DISABLTY_INT_ALL');
        END IF;

              ELSE
          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.update_disability.exception'||l_error_code;

              l_debug_str :=  'Igs_Ad_Imp_011.Prc_Pe_Spl_Needs.update_disability '||
                              ' for INTERFACE DISABLTY ID :'
                    || p_disability_rec.interface_disablty_id|| ' Status : 3'||
                    ' ErrorCode :' || l_error_code ||' SQLERRM:'|| SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(p_disability_rec.interface_disablty_id,l_error_code,'IGS_AD_DISABLTY_INT_ALL');
        END IF;

        END IF;

    END update_disability;

    --Local Procedure to create a Special Need Service Record
    PROCEDURE  create_sn_service(p_sn_service_rec  sn_service_cur%ROWTYPE,
                                 p_disability_id igs_pe_sn_service.disability_id%TYPE,
                                 p_person_id     igs_ad_interface.person_id%TYPE,
                                 p_status    OUT NOCOPY VARCHAR2)
    AS
        /*
        ||  Created By : prabhat.patel@Oracle.com
        ||  Created On : 22-NOV-2001
        ||  Purpose : This is a private procedure is for creating Person Special Need Service Record.
        ||            DLD: Person Interface DLD.  Enh Bug# 2103692.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  kumma           21-OCT-2002     Added 2 more parameters for start date and end date
        ||  pkpatel       22-JUN-2001       Bug no.2466466
        ||                                  Added p_status
        ||  (reverse chronological order - newest change first)
        */
            l_rowid          VARCHAR2(25);
            l_success        VARCHAR2(1);
            l_error_code     igs_pe_sn_srvce_int.error_code%TYPE;
            l_sn_service_id  igs_pe_sn_service.sn_service_id%TYPE;

  BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_011.create_sn_service.begin';
    l_debug_str := 'Interface sn service Id : ' || p_sn_service_rec.interface_sn_service_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

                validate_sn_service(p_sn_service_rec, p_person_id, l_success, l_error_code);

                -- kumma, 2608360 Added two more parameters for start_dt and end_dt

                IF l_success = 'Y' THEN -- Successful Validation

                        igs_pe_sn_service_pkg.insert_row (
                        x_rowid => l_rowid ,
                        x_sn_service_id => l_sn_service_id,
                        x_disability_id => p_disability_id,
                        x_special_service_cd => p_sn_service_rec.special_service_cd,
                        x_documented_ind => p_sn_service_rec.documented_ind,
                        x_start_dt       => p_sn_service_rec.start_dt,
                        x_end_dt         => p_sn_service_rec.end_dt,
                        x_mode => 'R'
                    );
                        l_error_code := NULL;

                        UPDATE igs_pe_sn_srvce_int
                        SET    status ='1',
                               error_code = l_error_code
                        WHERE interface_sn_service_id = p_sn_service_rec.interface_sn_service_id;

                ELSE --'Validation is Unsuccessful.
                    p_status := '3';
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                l_error_code := 'E151';
                p_status := '3';

                        UPDATE igs_pe_sn_srvce_int
                        SET    status ='3',
                               error_code = l_error_code
                        WHERE interface_sn_service_id = p_sn_service_rec.interface_sn_service_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.create_sn_service.exception'||l_error_code;

              l_debug_str :=  'Igs_Ad_Imp_011.Prc_Pe_Spl_Needs.Create_SN_Service '
                         ||'Unhandled Exception in call to igs_pe_sn_service_pkg.insert_row'
                         ||' for INTERFACE SN SERVICE ID :'
                         || p_sn_service_rec.interface_sn_service_id
                         || ' Status : 3'
                         ||  ' ErrorCode :' || l_error_code
                         ||' SQLERRM '|| SQLERRM ;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(p_sn_service_rec.interface_sn_service_id,l_error_code,'IGS_PE_SN_SRVCE_INT');
        END IF;

        END create_sn_service;


    --Local Procedure to create a Special Need Contact Record
    PROCEDURE  create_sn_contact(p_sn_contact_rec  sn_contact_cur%ROWTYPE,
                                 p_disability_id igs_pe_sn_contact.disability_id%TYPE,
                                 p_person_id     igs_ad_interface.person_id%TYPE,
                                 p_status    OUT NOCOPY VARCHAR2)
    AS
    /*
        ||  Created By : prabhat.patel@Oracle.com
        ||  Created On : 22-NOV-2001
        ||  Purpose : This is a private procedure is for creating Person Special Need Contact Record.
        ||            DLD: Person Interface DLD.  Enh Bug# 2103692.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  pkpatel       22-JUN-2001       Bug no.2466466
        ||                                  Added p_status
        ||  (reverse chronological order - newest change first)
        */
            l_rowid          VARCHAR2(25);
        l_success        VARCHAR2(1);
        l_error_code     igs_pe_sn_conct_int.error_code%TYPE;
        l_sn_contact_id  igs_pe_sn_contact.sn_contact_id%TYPE;

  BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_011.create_sn_contact.begin';
    l_debug_str := 'Interface sn contact Id : ' || p_sn_contact_rec.interface_sn_contact_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;


                validate_sn_contact(p_sn_contact_rec, p_person_id, l_success, l_error_code);

                IF l_success = 'Y' THEN -- Successful Validation

                    igs_pe_sn_contact_pkg.insert_row (
                        x_rowid => l_rowid ,
                        x_sn_contact_id => l_sn_contact_id,
                        x_disability_id => p_disability_id,
                        x_contact_name => p_sn_contact_rec.contact_name,
                        x_contact_date => TRUNC(p_sn_contact_rec.contact_date),
                        x_comments => p_sn_contact_rec.comments,
                        x_mode => 'R'
                    );
                        l_error_code := NULL;


                        UPDATE igs_pe_sn_conct_int
                        SET    status ='1',
                               error_code = l_error_code
                        WHERE interface_sn_contact_id = p_sn_contact_rec.interface_sn_contact_id;

              ELSE -- validation failed
                       p_status := '3';
              END IF;

        EXCEPTION
                WHEN OTHERS THEN
                l_error_code := 'E153';
                p_status := '3';

        UPDATE igs_pe_sn_conct_int
        SET    status ='3',
               error_code = l_error_code
        WHERE interface_sn_contact_id = p_sn_contact_rec.interface_sn_contact_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.create_sn_contact.exception'||l_error_code;

              l_debug_str :=  'Igs_Ad_Imp_011.Prc_Pe_Spl_Needs.Create_SN_Contact '
                         ||'Unhandled Exception in call to igs_pe_sn_contact_pkg.insert_row'
                         ||' for INTERFACE SN CONTACT ID :'
                         || p_sn_contact_rec.interface_sn_contact_id
                         || 'Status : 3'
                         ||  'ErrorCode :' || l_error_code
                         ||' SQLERRM '|| SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(p_sn_contact_rec.interface_sn_contact_id,l_error_code,'IGS_PE_SN_CONCT_INT');
        END IF;

        END create_sn_contact;


        PROCEDURE process_sn_service(p_interface_disability_id IN igs_ad_disablty_int.interface_disablty_id%TYPE,
                                     p_disability_id IN igs_pe_sn_service.disability_id%TYPE,
                                     p_person_id     IN igs_ad_interface.person_id%TYPE,
                                     p_status        OUT NOCOPY VARCHAR2)
        AS
        --------------------------------------------------------------------------
        --  Created By : pkpatel
        --  Date Created On : 19-NOV-2001
        --  Purpose:This is a private procedure  for processing Person Special Need Service Records.
        --            DLD: Person Interface DLD.  Enh Bug# 2103692.
        --  Know limitations, enhancements or remarks
        --  Change History
        --  Who             When            What
        --  kumma           21-OCT-2002     Passed a additional parameter for start date in dup_chk_sn_service_cur to check
        --                                  for duplicate record # 2608360
        --  pkpatel       22-JUN-2001       Bug no.2466466
        --                                  Added p_status
        --  (reverse chronological order - newest change first)
        --------------------------------------------------------------------------
            l_success    VARCHAR2(1);
            l_error_code VARCHAR2(100);

  BEGIN

    -- Call Log header
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_011.prcess_sn_service.begin';
    l_debug_str := 'Interface sn service Id : ' || sn_service_rec.interface_sn_service_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  --1. If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_pe_sn_srvce_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = cst_stat_val_2
      AND interface_run_id = l_interface_run_id;
  END IF;

  --2. If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_pe_sn_srvce_int mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = cst_stat_val_2
      AND mi.interface_disablty_id = p_interface_disability_id
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_sn_service pe
                   WHERE  pe.disability_id = p_disability_id  AND
                          mi.special_service_cd = pe.special_service_cd AND
                          NVL(TRUNC(mi.start_dt),l_default_date) = NVL(pe.start_dt,l_default_date)
          );
  END IF;

  --3. If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_pe_sn_srvce_int
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status = cst_stat_val_2;
  END IF;

  --4. If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_pe_sn_srvce_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25));
  END IF;

  --5. If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_pe_sn_srvce_int mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND mi.interface_disablty_id = p_interface_disability_id
      AND EXISTS ( SELECT '1'
                   FROM igs_pe_sn_service pe
                   WHERE  pe.disability_id = p_disability_id AND
                  mi.special_service_cd = pe.special_service_cd AND
                          UPPER(mi.documented_ind)       = UPPER(pe.documented_ind) AND
                          (TRUNC(mi.start_dt) = TRUNC(pe.start_dt) OR (mi.start_dt IS NULL AND  pe.start_dt  IS NULL)) AND
                          (TRUNC(mi.end_dt) = TRUNC(pe.end_dt) OR (mi.end_dt IS NULL AND  pe.end_dt  IS NULL)));
  END IF;



  --6. If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_pe_sn_srvce_int mi
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20,
        dup_sn_service_id = (SELECT sn_service_id
                         FROM igs_pe_sn_service pe
                             WHERE  pe.disability_id = p_disability_id AND
                                    mi.special_service_cd = pe.special_service_cd AND
                                    NVL(TRUNC(mi.start_dt),l_default_date) = NVL(TRUNC(pe.start_dt),l_default_date))
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND mi.interface_disablty_id = p_interface_disability_id
      AND EXISTS (SELECT '1'
                   FROM   igs_pe_sn_service pe
                   WHERE  pe.disability_id = p_disability_id  AND
                          mi.special_service_cd = pe.special_service_cd AND
                          NVL(TRUNC(mi.start_dt),l_default_date) = NVL(TRUNC(pe.start_dt),l_default_date));
  END IF;
    FOR sn_service_rec IN sn_service_cur(p_interface_disability_id,l_interface_run_id) LOOP
        -- For each record picked up do the following :
        -- Check to see if the record already exists.
        -- commented the following duplicate check code, #2608360, kumma
      sn_service_rec.special_service_cd := UPPER(sn_service_rec.special_service_cd);
      sn_service_rec.start_dt := TRUNC(sn_service_rec.start_dt);
      sn_service_rec.end_dt := TRUNC(sn_service_rec.end_dt);
      dup_chk_sn_service_rec.sn_service_id := NULL;
      OPEN  dup_chk_sn_service_cur(p_disability_id,sn_service_rec.special_service_cd, sn_service_rec.start_dt);
      FETCH dup_chk_sn_service_cur INTO dup_chk_sn_service_rec;
      CLOSE dup_chk_sn_service_cur;

      --If its a duplicate record find the source category rule for that Source Category.
      IF dup_chk_sn_service_rec.sn_service_id IS NOT NULL THEN
        dup_chk_sn_service_rec.start_dt := TRUNC(dup_chk_sn_service_rec.start_dt);
    dup_chk_sn_service_rec.end_dt := TRUNC(dup_chk_sn_service_rec.end_dt);
        IF l_rule = 'I' THEN
        BEGIN
          validate_sn_service(sn_service_rec, p_person_id, l_success, l_error_code);
          IF l_success = 'Y' THEN -- Successful Validation
            igs_pe_sn_service_pkg.update_row (
               x_rowid => dup_chk_sn_service_rec.ROWID,
               x_sn_service_id => dup_chk_sn_service_rec.sn_service_id,
               x_disability_id => dup_chk_sn_service_rec.disability_id,
               x_special_service_cd => sn_service_rec.special_service_cd,
               x_documented_ind => sn_service_rec.documented_ind,
               x_start_dt       => NVL(sn_service_rec.start_dt,dup_chk_sn_service_rec.start_dt),
               x_end_dt       => NVL(sn_service_rec.end_dt,dup_chk_sn_service_rec.end_dt),
               x_mode => 'R'
            );
            l_error_code := NULL;
            UPDATE igs_pe_sn_srvce_int
            SET    status =cst_stat_val_1,
               error_code = l_error_code,
           match_ind = cst_mi_val_18 -- '18' Match occured and used import values
        WHERE interface_sn_service_id = sn_service_rec.interface_sn_service_id;

          ELSE --Validation Failed.
            p_status := '3';
          END IF; -- End of condition check for successful validation
        EXCEPTION
          WHEN OTHERS THEN
            l_error_code := 'E152';
            p_status := '3';

            UPDATE igs_pe_sn_srvce_int
            SET    status ='3',
                   error_code = l_error_code
            WHERE interface_sn_service_id = sn_service_rec.interface_sn_service_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.process_sn_service.exception'||l_error_code;

              l_debug_str :=  'Igs_Ad_Imp_011.Prc_Pe_Spl_Needs.Process_SN_Service '
                         ||'Unhandled Exception in call to igs_pe_sn_service_pkg.update_row'
                         ||' for INTERFACE SN SERVICE ID :'
                         || sn_service_rec.interface_sn_service_id
                         || ' Status : 3'
                         ||  ' ErrorCode :' || l_error_code
                         ||' SQLERRM '|| SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(sn_service_rec.interface_sn_service_id,l_error_code,'IGS_PE_SN_SRVCE_INT');
        END IF;

        END;
        ELSIF l_rule = 'R' THEN
          IF sn_service_rec.match_ind = '21' THEN
          BEGIN

            validate_sn_service(sn_service_rec, p_person_id, l_success, l_error_code);

            IF l_success = 'Y' THEN -- Successful Validation
              igs_pe_sn_service_pkg.update_row (
                   x_rowid => dup_chk_sn_service_rec.rowid ,
                   x_sn_service_id => dup_chk_sn_service_rec.sn_service_id,
                   x_disability_id => p_disability_id,
                   x_special_service_cd => sn_service_rec.special_service_cd,
                   x_documented_ind => sn_service_rec.documented_ind,
                   x_start_dt       => nvl(sn_service_rec.start_dt,dup_chk_sn_service_rec.start_dt),
                   x_end_dt       => nvl(sn_service_rec.end_dt,dup_chk_sn_service_rec.end_dt),
                   x_mode => 'R'
                                                );
             l_error_code := NULL;

             UPDATE igs_pe_sn_srvce_int
             SET    status =cst_stat_val_1,
                    error_code = l_error_code,
                    match_ind = cst_mi_val_18 -- '18' Match occured and used import values
             WHERE interface_sn_service_id = sn_service_rec.interface_sn_service_id;

            ELSE -- Validation Failed.
              p_status := '3';
            END IF; -- End of condition check for successful validation
          EXCEPTION
            WHEN OTHERS THEN
         l_error_code := 'E152';
         p_status := '3';

        UPDATE igs_pe_sn_srvce_int
        SET    status ='3',
            error_code = l_error_code
        WHERE  interface_sn_service_id = sn_service_rec.interface_sn_service_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.process_sn_service.exception'||l_error_code;

              l_debug_str :=  'Igs_Ad_Imp_011.Prc_Pe_Spl_Needs.Process_SN_Service '
                         ||'Unhandled Exception in call to igs_pe_sn_service_pkg.update_row'
                         ||' for INTERFACE SN SERVICE ID :'
                         || sn_service_rec.interface_sn_service_id
                         || ' Status : 3'
                         ||  ' ErrorCode :' || l_error_code
                         ||' SQLERRM '|| SQLERRM ;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(sn_service_rec.interface_sn_service_id,l_error_code,'IGS_PE_SN_SRVCE_INT');
        END IF;

          END;
          END IF;  -- service_rec.MATCH_IND check

        END IF;--  l_cat_rule  check for 'I','R' or 'E'.
      ELSE -- Its not a duplicate record, So create a new record
        create_sn_service(sn_service_rec, p_disability_id, p_person_id,p_status);
      END IF;
      END LOOP;
    END process_sn_service;



    PROCEDURE process_sn_contact(p_interface_disability_id IN igs_ad_disablty_int.interface_disablty_id%TYPE,
                                     p_disability_id IN igs_pe_sn_contact.disability_id%TYPE,
                                     p_person_id     IN igs_ad_interface.person_id%TYPE,
                                     p_status    OUT NOCOPY VARCHAR2)
        AS
        --------------------------------------------------------------------------
        --  Created By : pkpatel
        --  Date Created On : 19-NOV-2001
        --  Purpose:This is a private procedure for processing of Person Special Need Contact Records.
        --          DLD: Person Interface DLD.  Enh Bug# 2103692.
        --  Know limitations, enhancements or remarks
        --  Change History
        --  Who             When            What
        --  pkpatel       22-JUN-2001       Bug no.2466466
        --                                  Added p_status
        --  (reverse chronological order - newest change first)
        --------------------------------------------------------------------------

            l_success    VARCHAR2(1);
            l_error_code VARCHAR2(100);

        BEGIN
    -- Call Log header
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_011.process_sn_contact.begin';
    l_debug_str := 'Interface Disability Id : ' || p_interface_disability_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                  l_label,
                  l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  --1. If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_pe_sn_conct_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = cst_stat_val_2
      AND interface_run_id = l_interface_run_id;
  END IF;

  --2. If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_pe_sn_conct_int mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = cst_stat_val_2
      AND mi.interface_disablty_id = p_interface_disability_id
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_sn_contact pe
                   WHERE  pe.disability_id = p_disability_id  AND
                  NVL(UPPER(mi.contact_name),'~') = NVL(UPPER(pe.contact_name),'~') AND
                          NVL(TRUNC(mi.contact_date),l_default_date) = NVL(TRUNC(pe.contact_date),l_default_date)
             );
  END IF;

  --3. If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_pe_sn_conct_int
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status = cst_stat_val_2;
  END IF;

  --4. If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_pe_sn_conct_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25));
  END IF;

  --5. If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_pe_sn_conct_int mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND mi.interface_disablty_id = p_interface_disability_id
      AND EXISTS ( SELECT '1'
                   FROM igs_pe_sn_contact pe
                   WHERE  pe.disability_id = p_disability_id AND
                  NVL(UPPER(mi.contact_name),'*') = NVL(UPPER(pe.contact_name),'*') AND
                          NVL(TRUNC(mi.contact_date), l_default_date) = NVL(TRUNC(pe.contact_date),l_default_date) AND
                          NVL(UPPER(mi.comments),'*')  = NVL(UPPER(pe.comments), '*'));
  END IF;

  --6. If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_pe_sn_conct_int mi
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20,
        dup_sn_contact_id = (SELECT sn_contact_id
                         FROM igs_pe_sn_contact pe
                             WHERE  pe.disability_id = p_disability_id  AND
                                    NVL(UPPER(mi.contact_name),'*') = NVL(UPPER(pe.contact_name),'*') AND
                                    NVL(TRUNC(mi.contact_date), l_default_date) = NVL(TRUNC(pe.contact_date),l_default_date)
                              )
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND mi.interface_disablty_id = p_interface_disability_id
      AND EXISTS (SELECT '1'
                   FROM   igs_pe_sn_contact pe
                   WHERE  pe.disability_id = p_disability_id  AND
                          NVL(UPPER(mi.contact_name),'*') = NVL(UPPER(pe.contact_name),'*') AND
                          NVL(TRUNC(mi.contact_date), l_default_date) = NVL(TRUNC(pe.contact_date),l_default_date));
  END IF;

  FOR sn_contact_rec IN sn_contact_cur(p_interface_disability_id,l_interface_run_id) LOOP

        -- For each record picked up do the following :
            -- Check to see if the record already exists.
    dup_chk_sn_contact_rec.sn_contact_id := NULL;
    OPEN  dup_chk_sn_contact_cur(p_disability_id,sn_contact_rec.contact_name,sn_contact_rec.contact_date);
    FETCH dup_chk_sn_contact_cur INTO dup_chk_sn_contact_rec;
    CLOSE dup_chk_sn_contact_cur;
                   --If its a duplicate record find the source category rule for that Source Category.
    IF dup_chk_sn_contact_rec.sn_contact_id IS NOT NULL THEN
      dup_chk_sn_contact_rec.contact_date := TRUNC(dup_chk_sn_contact_rec.contact_date);
      IF l_rule = 'I' THEN
      BEGIN

        validate_sn_contact(sn_contact_rec, p_person_id, l_success, l_error_code);
        IF l_success = 'Y' THEN -- Successful Validation
          igs_pe_sn_contact_pkg.update_row (
               x_rowid => dup_chk_sn_contact_rec.rowid ,
               x_sn_contact_id => dup_chk_sn_contact_rec.sn_contact_id,
               x_disability_id => dup_chk_sn_contact_rec.disability_id,
               x_contact_name  => NVL(sn_contact_rec.contact_name,dup_chk_sn_contact_rec.contact_name),
               x_contact_date  => NVL(sn_contact_rec.contact_date,dup_chk_sn_contact_rec.contact_date),
               x_comments      => NVL(sn_contact_rec.comments, dup_chk_sn_contact_rec.comments),
               x_mode => 'R'
            );
      l_error_code := NULL;
          UPDATE igs_pe_sn_conct_int
          SET    status =cst_stat_val_1,
                 error_code = l_error_code,
                 match_ind = cst_mi_val_18 -- '18' Match occured and used import values
          WHERE interface_sn_contact_id = sn_contact_rec.interface_sn_contact_id;
        ELSE
          p_status := '3';
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          l_error_code := 'E154';
          p_status := '3';

          UPDATE igs_pe_sn_conct_int
          SET    status ='3',
                 error_code = l_error_code
          WHERE interface_sn_contact_id = sn_contact_rec.interface_sn_contact_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.process_sn_contact.exception'||l_error_code;

              l_debug_str :=  'Igs_Ad_Imp_011.Prc_Pe_Spl_Needs.Process_SN_Contact '
                         ||'Unhandled Exception in call to igs_pe_sn_contact_pkg.update_row'
                         ||' for INTERFACE SN CONTACT ID :'
                         || sn_contact_rec.interface_sn_contact_id
                         || ' Status : 3'
                         ||  ' ErrorCode :' || l_error_code
                         ||' SQLERRM '|| SQLERRM ;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(sn_contact_rec.interface_sn_contact_id,l_error_code,'IGS_PE_SN_CONCT_INT');
        END IF;


      END;
      ELSIF l_rule = 'R' THEN
        IF sn_contact_rec.match_ind = '21' THEN
        BEGIN

          validate_sn_contact(sn_contact_rec, p_person_id, l_success, l_error_code);

          IF l_success = 'Y' THEN -- Successful Validation

            igs_pe_sn_contact_pkg.update_row (
               x_rowid => dup_chk_sn_contact_rec.rowid ,
               x_sn_contact_id => dup_chk_sn_contact_rec.sn_contact_id,
               x_disability_id => dup_chk_sn_contact_rec.disability_id,
               x_contact_name  => NVL(sn_contact_rec.contact_name,dup_chk_sn_contact_rec.contact_name),
               x_contact_date  => NVL(sn_contact_rec.contact_date,dup_chk_sn_contact_rec.contact_date),
               x_comments      => NVL(sn_contact_rec.comments, dup_chk_sn_contact_rec.comments),
               x_mode => 'R'
            );
        l_error_code := NULL;

         UPDATE igs_pe_sn_conct_int
         SET    status =cst_stat_val_1,
            error_code = l_error_code,
            match_ind = cst_mi_val_18 -- '18' Match occured and used import values
         WHERE interface_sn_contact_id = sn_contact_rec.interface_sn_contact_id;
      ELSE
         p_status := '3';
      END IF;

    EXCEPTION
       WHEN OTHERS THEN
             l_error_code := 'E154';
             p_status := '3';

         UPDATE igs_pe_sn_conct_int
         SET    status ='3',
            error_code = l_error_code
         WHERE  interface_sn_contact_id = sn_contact_rec.interface_sn_contact_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_011.process_sn_contact.exception'||l_error_code;

              l_debug_str :=  'Igs_Ad_Imp_011.Prc_Pe_Spl_Needs.Process_SN_Contact '
             ||'Unhandled Exception in call to igs_pe_sn_contact_pkg.update_row'
             ||' for INTERFACE SN CONTACT ID :'
                         || sn_contact_rec.interface_sn_contact_id
                         || ' Status : 3'
                         ||  ' ErrorCode :' || l_error_code
                         ||' SQLERRM '|| SQLERRM ;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(sn_contact_rec.interface_sn_contact_id,l_error_code,'IGS_PE_SN_CONCT_INT');
        END IF;


        END;
        END IF;  -- discrepancy_sn_contact_rec.MATCH_IND check

      END IF;--  l_cat_rule  check for 'I','R' or 'E'.
    ELSE -- Its not a duplicate record, So create a new record

      create_sn_contact(sn_contact_rec, p_disability_id ,p_person_id,p_status);

    END IF;

    END LOOP;
    END process_sn_contact;

        --Private Procedure for the Processing of Person Disability Records
    PROCEDURE process_disability
    AS
        --------------------------------------------------------------------------
        --  Created By : pkpatel
        --  Date Created On : 19-NOV-2001
        --  Purpose:This is a private procedure is for processing Person Disability Records.
        --           DLD: Person Interface DLD.  Enh Bug# 2103692.
        --  Know limitations, enhancements or remarks
        --  Change History
        --  Who             When            What
        --  (reverse chronological order - newest change first)
        --  npalanis        16-JUN-2002     Bug -2327077
        --                                  The child records special needs service and contact records
        --                                  are errored out if the disability type is NONE
	--  gmaheswa        21-Sep-2006     Modified Update statement in 5. If rule is R, set duplicated records
	--				    with no discrepancy to status 1 and match_ind 23 case to reduce shared memory.
        --------------------------------------------------------------------------


                l_person_id IGS_AD_INTERFACE.PERSON_ID%TYPE;
                l_var VARCHAR2(2);
                l_success    VARCHAR2(1);
                l_error_code VARCHAR2(100);
                l_contact_status  VARCHAR2(1);
                l_service_status  VARCHAR2(1);

  BEGIN
    -- Call Log header
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_011.process_disability.begin';
    l_debug_str := 'igs_ad_imp_011.process_disability begin';

    fnd_log.string_with_context( fnd_log.level_procedure,
                  l_label,
                  l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  l_rule :=  igs_ad_imp_001.find_source_cat_rule(
               p_source_type_id     =>  p_source_type_id,
               p_category       =>  'PERSON_SPECIAL_NEEDS');



  --1. If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_ad_disablty_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = cst_stat_val_2
      AND interface_run_id = l_interface_run_id;
  END IF;

  --2. If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
--skpandey, Bug#3702774, Changed select statement for optimization
    UPDATE igs_ad_disablty_int_all mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19,
        dup_disability_id = ( SELECT pe.igs_pe_pers_disablty_id
                          FROM igs_pe_pers_disablty pe, igs_ad_interface_all ii
                  WHERE  ii.interface_id = mi.interface_id AND
                    pe.disability_type = UPPER(mi.disability_type) AND
                    ROWNUM = 1 AND
                    ii.person_id = pe.person_id AND
                    ((TRUNC(mi.start_date) = pe.start_date) OR (mi.start_date IS NULL AND pe.start_date IS NULL)))
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_pers_disablty pe, igs_ad_interface_all ii
                   WHERE  pe.disability_type = UPPER(mi.disability_type) AND
                          ii.interface_id = mi.interface_id AND
                          ii.person_id = pe.person_id AND
			  ((TRUNC(mi.start_date) = pe.start_date) OR (mi.start_date IS NULL AND pe.start_date IS NULL))
			  );
 END IF;

  --3. If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_ad_disablty_int_all
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status = cst_stat_val_2;
  END IF;

  --4. If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_ad_disablty_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25));
  END IF;

  --5. If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    --skpandey, Bug#3702774, Changed select statement for optimization
    UPDATE igs_ad_disablty_int_all mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23,
        dup_disability_id = ( SELECT pe.igs_pe_pers_disablty_id
                  FROM igs_pe_pers_disablty pe, igs_ad_interface_all ii
                  WHERE ii.person_id = pe.person_id
                    AND ii.interface_id = mi.interface_id
                    AND pe.disability_type = UPPER(mi.disability_type)
		    AND ((TRUNC(mi.start_date) = pe.start_date) OR (mi.start_date IS NULL AND pe.start_date IS NULL)))
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT 1
                   FROM igs_pe_pers_disablty pe, igs_AD_interface_all ii
                   WHERE ii.person_id = pe.person_id
             AND ii.interface_id = mi.interface_id
             AND UPPER(mi.disability_type) = pe.disability_type
             AND NVL(mi.special_allow_cd, -99) = NVL(pe.special_allow_cd, -99) AND
                     NVL(pe.support_level_cd, -99) = NVL(mi.support_level_cd, -99) AND
                     NVL(UPPER(pe.elig_early_reg_ind),'N') = NVL(UPPER(mi.elig_early_reg_ind),'N') AND
                     pe.start_date = TRUNC(mi.start_date)  AND
                     NVL(pe.end_date,l_default_date) = NVL(TRUNC(mi.end_date),l_default_date) AND
            NVL(UPPER(pe.info_source),'*') = NVL(UPPER(mi.info_source),'*') AND
            NVL(pe.interviewer_id, -99) = NVL(mi.interviewer_id, -99) AND
            NVL(TRUNC(pe.interviewer_date), l_default_date) = NVL(TRUNC(mi.interviewer_date), l_default_date)
            AND NVL(pe.attribute_category, '*') = NVL(mi.attribute_category, '*')
            AND (pe.attribute1||'*'||pe.attribute2||'*'||pe.attribute3||'*'||pe.attribute4||'*'||pe.attribute5||'*'||
	    pe.attribute6||'*'||pe.attribute7||'*'||pe.attribute8||'*'||pe.attribute9||'*'||pe.attribute10||'*'||pe.attribute11||'*'||
	    pe.attribute12||'*'||pe.attribute13||'*'||pe.attribute14||'*'||pe.attribute15||'*'||pe.attribute16||'*'||pe.attribute17||'*'||
	    pe.attribute18||'*'||pe.attribute19||'*'||pe.attribute20||'*') = (mi.attribute1||'*'
            ||mi.attribute2||'*'||mi.attribute3||'*'||mi.attribute4||'*'||mi.attribute5||'*'||mi.attribute6||'*'||
	    mi.attribute7||'*'||mi.attribute8||'*'||mi.attribute9||'*'||mi.attribute10||'*'||mi.attribute11||'*'||
	    mi.attribute12||'*'||mi.attribute13||'*'||mi.attribute14||'*'||mi.attribute15||'*'||mi.attribute16||
	    '*'||mi.attribute17||'*'||mi.attribute18||'*'||mi.attribute19||'*'||mi.attribute20||'*'));
   END IF;

  --6. If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
--skpandey, Bug#3702774, Changed select statement for optimization
    UPDATE igs_ad_disablty_int_all mi
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                   FROM   igs_pe_pers_disablty pe, igs_Ad_interface_all ii
                   WHERE  pe.disability_type = UPPER(mi.disability_type) AND
                          ii.person_id = pe.person_id AND
                          ii.interface_id = mi.interface_id AND
			  ((TRUNC(mi.start_date) = pe.start_date) OR (mi.start_date IS NULL AND pe.start_date IS NULL))
		  );

  END IF;

  FOR disability_rec IN disability_cur(l_interface_run_id) LOOP
        l_processed_records := l_processed_records + 1 ;

    BEGIN
      disability_rec.disability_type  := UPPER(disability_rec.disability_type);
      disability_rec.special_allow_cd := UPPER(disability_rec.special_allow_cd);
      disability_rec.support_level_cd := UPPER(disability_rec.support_level_cd);
      disability_rec.start_date       := TRUNC(disability_rec.start_date);
      disability_rec.end_date         := TRUNC(disability_rec.end_date);

       l_error_code := NULL;
       l_disability_id := NULL;

       -- For each record picked up do the following :
       -- Check to see if the record already exists.
       dup_chk_disability_rec.igs_pe_pers_disablty_id := NULL;

       OPEN  dup_chk_disability_cur(disability_rec);
       FETCH dup_chk_disability_cur INTO dup_chk_disability_rec;
       CLOSE dup_chk_disability_cur;
                   --If its a duplicate record find the source category rule for that Source Category.
           IF dup_chk_disability_rec.igs_pe_pers_disablty_id IS NOT NULL THEN
         dup_chk_disability_rec.start_date := TRUNC(dup_chk_disability_rec.start_date);
         dup_chk_disability_rec.end_date := TRUNC(dup_chk_disability_rec.end_date);

            -- Assign the value to the variable l_disability_id which will be passed as a parameter to the processing
            -- of the Child Records i.e. for the processing of Special Need Service and Contact
                    l_disability_id := dup_chk_disability_rec.igs_pe_pers_disablty_id ;
             IF l_rule = 'I' THEN
        validate_disability(disability_rec, l_success, l_error_code);
        IF l_success = 'Y' THEN -- Successful Validation
          update_disability(disability_rec,dup_chk_disability_rec);
        END IF; -- End of condition check for successful validation

             ELSIF l_rule = 'R' THEN
                IF disability_rec.match_ind = '21' THEN

          validate_disability(disability_rec, l_success, l_error_code);

                  IF l_success = 'Y' THEN -- Successful Validation

            update_disability(disability_rec,dup_chk_disability_rec);

                  END IF; -- End of condition check for successful validation

               END IF;  -- discrepancy_disability_rec.MATCH_IND check
             END IF;--  l_cat_rule  check for 'I','R' or 'E'.

      ELSE  -- Its not a duplicate record, So create a new record

             create_disability(disability_rec,l_error_code);

      END IF;
/*****************************************************/
            IF l_disability_id IS NOT NULL AND l_error_code IS NULL THEN -- If the disability ID is NOT NULL proceed with the processing of Children
                     l_var := NULL;
                     OPEN check_none_disablity_cur(disability_rec.disability_type,'NONE');
                     FETCH check_none_disablity_cur INTO l_var;
                     CLOSE check_none_disablity_cur;
                  IF l_var = 'X' THEN
                          UPDATE igs_pe_sn_srvce_int
                          SET    status ='3',
                          error_code = 'E271'
                          WHERE INTERFACE_DISABLTY_ID  = disability_rec.interface_disablty_id;

                          UPDATE igs_pe_sn_conct_int
                          SET    status ='3',
                          error_code = 'E272'
                          WHERE INTERFACE_DISABLTY_ID  = disability_rec.interface_disablty_id;

                          UPDATE igs_ad_disablty_int_all
                          SET    status     = '4',
                                 error_code = 'E347'
                          WHERE interface_disablty_id = disability_rec.interface_disablty_id AND
						        (EXISTS (SELECT 1 FROM igs_pe_sn_conct_int WHERE interface_disablty_id = disability_rec.interface_disablty_id AND status = '3')
								OR EXISTS (SELECT 1 FROM igs_pe_sn_srvce_int WHERE interface_disablty_id = disability_rec.interface_disablty_id AND status = '3'));

            IF ((l_enable_log = 'Y') and (SQL%FOUND)) THEN
              fnd_message.set_name('IGS','IGS_EN_CONIND_NOTSET_NONE');
              fnd_file.put_line(fnd_file.LOG,fnd_message.get);
              igs_ad_imp_001.logerrormessage(disability_rec.interface_disablty_id,'E347','IGS_AD_DISABLTY_INT_ALL');
            END IF;

                   ELSE
             process_sn_service(disability_rec.interface_disablty_id, l_disability_id, disability_rec.person_id,l_contact_status);
                         process_sn_contact(disability_rec.interface_disablty_id, l_disability_id, disability_rec.person_id,l_service_status);
                         IF l_contact_status = '3' AND l_service_status = '3' THEN
                             UPDATE igs_ad_disablty_int_all
                             SET    status     = '4',
                                    error_code = 'E155'
                             WHERE interface_disablty_id = disability_rec.interface_disablty_id;

							  IF l_enable_log = 'Y' THEN
								igs_ad_imp_001.logerrormessage(disability_rec.interface_disablty_id,'E155','IGS_AD_DISABLTY_INT_ALL');
							  END IF;

                         ELSIF l_contact_status = '3' THEN

                             UPDATE igs_ad_disablty_int_all
                             SET    status     = '4',
                                    error_code = 'E148'
                             WHERE interface_disablty_id = disability_rec.interface_disablty_id;

							  IF l_enable_log = 'Y' THEN
								igs_ad_imp_001.logerrormessage(disability_rec.interface_disablty_id,'E148','IGS_AD_DISABLTY_INT_ALL');
							  END IF;

                         ELSIF l_service_status = '3' THEN

                             UPDATE igs_ad_disablty_int_all
                             SET    status     = '4',
                                    error_code = 'E147'
                             WHERE interface_disablty_id = disability_rec.interface_disablty_id;

							  IF l_enable_log = 'Y' THEN
								igs_ad_imp_001.logerrormessage(disability_rec.interface_disablty_id,'E147','IGS_AD_DISABLTY_INT_ALL');
							  END IF;

                         END IF;
                  END IF;
              END IF;
         END;
         IF  l_processed_records = 100 THEN
             COMMIT;
             l_processed_records := 0 ;
         END IF;
  END LOOP;
  l_processed_records := 0;
 -- To call the child processing for records updated to status 1 before the loop
  FOR sp_disability_rec IN sp_disability_cur(l_interface_run_id) LOOP
        l_processed_records := l_processed_records + 1 ;

    BEGIN

      l_disability_id := sp_disability_rec.dup_disability_id;

      l_var := NULL;
      OPEN check_none_disablity_cur(sp_disability_rec.disability_type,'NONE');
      FETCH check_none_disablity_cur INTO l_var;
      CLOSE check_none_disablity_cur;
      IF l_var = 'X' THEN
          UPDATE igs_pe_sn_srvce_int
          SET    status ='3',
          error_code = 'E271'
          WHERE INTERFACE_DISABLTY_ID  = sp_disability_rec.interface_disablty_id;

          UPDATE igs_pe_sn_conct_int
          SET    status ='3',
          error_code = 'E272'
          WHERE INTERFACE_DISABLTY_ID  = sp_disability_rec.interface_disablty_id;

          UPDATE igs_ad_disablty_int_all
          SET    status     = '4',
                 error_code = 'E347'
          WHERE interface_disablty_id = sp_disability_rec.interface_disablty_id AND
          (
		  EXISTS(SELECT 1 FROM igs_pe_sn_conct_int WHERE
		          interface_disablty_id = sp_disability_rec.interface_disablty_id AND status = '3')
    	   OR EXISTS (SELECT 1 FROM igs_pe_sn_srvce_int WHERE
		              interface_disablty_id = sp_disability_rec.interface_disablty_id AND status = '3')
		  );

        IF ((l_enable_log = 'Y') and (SQL%FOUND)) THEN
          fnd_message.set_name('IGS','IGS_EN_CONIND_NOTSET_NONE');
          fnd_file.put_line(fnd_file.LOG,fnd_message.get);
          igs_ad_imp_001.logerrormessage(sp_disability_rec.interface_disablty_id,'E347','IGS_AD_DISABLTY_INT_ALL');
        END IF;

      ELSE
         process_sn_service(sp_disability_rec.interface_disablty_id, l_disability_id, sp_disability_rec.person_id,l_contact_status);
         process_sn_contact(sp_disability_rec.interface_disablty_id, l_disability_id, sp_disability_rec.person_id,l_service_status);
         IF l_contact_status = '3' AND l_service_status = '3' THEN
             UPDATE igs_ad_disablty_int_all
             SET    status     = '4',
                error_code = 'E155'
             WHERE interface_disablty_id = sp_disability_rec.interface_disablty_id;

              IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(sp_disability_rec.interface_disablty_id,'E155','IGS_AD_DISABLTY_INT_ALL');
              END IF;

         ELSIF l_contact_status = '3' THEN

             UPDATE igs_ad_disablty_int_all
             SET    status     = '4',
                error_code = 'E148'
             WHERE interface_disablty_id = sp_disability_rec.interface_disablty_id;
              IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(sp_disability_rec.interface_disablty_id,'E148','IGS_AD_DISABLTY_INT_ALL');
              END IF;

         ELSIF l_service_status = '3' THEN

             UPDATE igs_ad_disablty_int_all
             SET    status     = '4',
                error_code = 'E147'
             WHERE interface_disablty_id = sp_disability_rec.interface_disablty_id;
              IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(sp_disability_rec.interface_disablty_id,'E147','IGS_AD_DISABLTY_INT_ALL');
              END IF;
         END IF;
      END IF;
      END;
      IF  l_processed_records = 100 THEN
        COMMIT;
        l_processed_records := 0 ;
      END IF;
    END LOOP;
    END process_disability;

     --Start of the Main Processing
    BEGIN
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_prog_label := 'igs.plsql.igs_ad_imp_011.prc_special_needs';
    l_label := 'igs.plsql.igs_ad_imp_011.prc_special_needs.';

       process_disability;
    END prc_special_needs;

END IGS_AD_IMP_011;

/
