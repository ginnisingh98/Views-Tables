--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_LI_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_LI_IMP_PKG" AS
/* $Header: IGFSL20B.pls 120.6 2006/09/07 13:20:52 bvisvana ship $ */
CURSOR c_interface (cp_batch_id             NUMBER,
                    cp_alternate_code       VARCHAR2,
                    p_import_status_type_1  igf_sl_li_dlor_ints.import_status_type%TYPE,
                    p_import_status_type_2  igf_sl_li_dlor_ints.import_status_type%TYPE
                    ) IS
  SELECT  rowid,
          batch_num                             batch_num  ,
          TRIM(ci_alternate_code)               ci_alternate_code ,
          TRIM(person_number)                   person_number  ,
          TRIM(award_number_txt)                award_number_txt ,
          TRIM(loan_number_txt)                 loan_number_txt,
          TRIM(import_status_type)              import_status_type ,
          loan_seq_num                          loan_seq_num  ,
          TRUNC(loan_per_begin_date)            loan_per_begin_date ,
          TRUNC(loan_per_end_date)              loan_per_end_date ,
          TRIM(loan_status_code)                loan_status_code ,
          TRUNC(loan_status_date)               loan_status_date ,
          TRIM(active_flag)                     active_flag  ,
          TRUNC(active_date)                    active_date  ,
          TRIM(borr_person_number)              borr_person_number ,
          TRIM(grade_level_code)                grade_level_code ,
          TRUNC(orig_acknowledgement_date)      orig_acknowledgement_date ,
          TRUNC(orig_batch_date)                orig_batch_date  ,
          TRIM(orig_send_batch_id_txt)          orig_send_batch_id_txt ,
          TRIM(pnote_status_code)               pnote_status_code  ,
          TRIM(pnote_batch_seq_num_txt)         pnote_batch_seq_num_txt ,
          TRIM(pnote_id_txt)                    pnote_id_txt   ,
          TRIM(pnote_print_ind_code)            pnote_print_ind_code ,
          pnote_accept_amt                      pnote_accept_amt   ,
          TRUNC(pnote_accept_date)              pnote_accept_date  ,
          TRIM(unsub_elig_for_depnt_code)       unsub_elig_for_depnt_code ,
          TRIM(unsub_elig_for_heal_code)        unsub_elig_for_heal_code ,
          TRIM(loan_chg_status)                 loan_chg_status  ,
          TRUNC(loan_chg_status_date)           loan_chg_status_date ,
          TRIM(pnote_status_type)               pnote_status_type ,
          TRIM(pnote_indicator_code)            pnote_indicator_code ,
          TRUNC(mpn_acknowledgement_date)       mpn_acknowledgement_date ,
          TRIM(mpn_reject_code)                 mpn_reject_code ,
          orig_fee_perct_num                    orig_fee_perct_num ,
          TRUNC(credit_decision_date)           credit_decision_date ,
          TRIM(credit_override_code)            credit_override_code ,
          endorser_amount                       endorser_amount,
          TRIM(cr_desc_batch_id_txt)            cr_desc_batch_id_txt,
          TRIM(orig_reject_code)                orig_reject_code ,
          TRIM(disclosure_print_ind_code)       disclosure_print_ind_code ,
          TRIM(s_default_status_code)           s_default_status_code ,
          TRUNC(sch_cert_date)                  sch_cert_date  ,
          TRIM(p_default_status_code)           p_default_status_code ,
          loan_approved_amt                     loan_approved_amt ,
          TRIM(import_record_type)              import_record_type,
          transaction_num                       transaction_num,
          TRIM(atd_entity_id_txt)               atd_entity_id_txt,
          TRIM(rep_entity_id_txt)               rep_entity_id_txt,
          credit_status                         credit_status
  FROM  igf_sl_li_dlor_ints dlint
  WHERE dlint.batch_num             = cp_batch_id
  AND   dlint.ci_alternate_code     = cp_alternate_code
  AND   (dlint.import_status_type = p_import_status_type_1 OR dlint.import_status_type = p_import_status_type_2);

  CURSOR c_disb_interface(cp_alternate_code   VARCHAR2,
                          cp_person_number    VARCHAR2,
                          cp_award_number_txt VARCHAR2,
                          cp_loan_number      VARCHAR2
                         ) IS
  SELECT    rowid,
            TRIM(ci_alternate_code)                     ci_alternate_code ,
            TRIM(person_number)                         person_number ,
            TRIM(award_number_txt)                      award_number_txt,
            disbursement_num                            disbursement_num ,
            disbursement_seq_num                        disbursement_seq_num,
            TRIM(loan_number_txt)                       loan_number_txt,
            TRUNC(disbursement_date)                    disbursement_date,
            gross_disbursement_amt                      gross_disbursement_amt,
            TRIM(booking_batch_id_txt)                  booking_batch_id_txt,
            TRUNC(booked_date)                          booked_date,
            TRIM(disbursement_batch_id_txt)             disbursement_batch_id_txt,
            TRIM(disbursement_activity_code)            disbursement_activity_code ,
            TRIM(disbursement_activity_st_txt)          disbursement_activity_st_txt,
            loc_disbursement_gross_amt                  loc_disbursement_gross_amt,
            loc_fee_1_amt                               loc_fee_1_amt ,
            loc_disbursement_net_amt                    loc_disbursement_net_amt,
            servicer_refund_amt                         servicer_refund_amt ,
            loc_int_rebate_amt                          loc_int_rebate_amt ,
            loc_net_booked_loan_amt                     loc_net_booked_loan_amt ,
            TRUNC(acknowledgement_date)                 acknowledgement_date,
            TRIM(school_code_txt)                       school_code_txt,
            TRIM(confirmation_flag)                     confirmation_flag ,
            interest_rebate_amt                         interest_rebate_amt ,
            TRIM(user_identifier_txt)                   user_identifier_txt,
            TRUNC(disbursement_activity_date)           disbursement_activity_date



  FROM   igf_sl_li_dldb_ints dlint
  WHERE  dlint.ci_alternate_code     = cp_alternate_code
  AND    dlint.person_number         = cp_person_number
  AND    dlint.award_number_txt      = cp_award_number_txt
  AND    dlint.loan_number_txt       = cp_loan_number
  ORDER BY  disbursement_num ,disbursement_seq_num ;

  CURSOR c_chg_interface(p_loan_number VARCHAR2)
  IS
  SELECT  TRIM(loan_number_txt)        loan_number_txt,
          TRIM(change_code)            change_code ,
          TRIM(send_batch_id_txt)      send_batch_id_txt,
          TRIM(resp_batch_id_txt)      resp_batch_id_txt,
          TRIM(reject_code)            reject_code,
          TRIM(new_value_txt)          new_value_txt,
          TRIM(loan_ident_err_code)    loan_ident_err_code

  FROM    igf_sl_li_chg_ints slchg
  WHERE   slchg.loan_number_txt =  p_loan_number ;

  IMPORT_ERROR             EXCEPTION;
  g_igf_sl_message_table   igf_sl_message_table;
  ln_origination_id        NUMBER;
  ln_loan_id               igf_sl_loans.loan_id%TYPE;
  ln_lor_resp_num          NUMBER;
  ln_dbth_id               igf_sl_cl_batch_all.cbth_id%TYPE;
  lv_fed_fund_code         igf_aw_fund_cat.fed_fund_code%TYPE;
  g_award_year             VARCHAR2(3);
  l_award_year_status      VARCHAR2(80);
  g_request_id             NUMBER := NULL;
  l_b_person_id            NUMBER ;
  g_error_string           VARCHAR2(200);
  l_cal_type               igf_ap_fa_base_rec_all.ci_cal_type%TYPE ;
  l_seq_number             igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;

PROCEDURE log_input_params( p_batch_num         IN  igf_aw_li_coa_ints.batch_num%TYPE ,
                            p_alternate_code    IN  igs_ca_inst.alternate_code%TYPE   ,
                            p_delete_flag       IN  VARCHAR2)
IS
/*
||  Created By : rasahoo
||  Created On : 07-July-2003
||  Purpose    : Logs all the Input Parameters
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/

  -- cursor to get batch desc for the batch id from igf_ap_li_bat_ints
     CURSOR c_batch_desc(cp_batch_num     igf_aw_li_coa_ints.batch_num%TYPE ) IS
     SELECT batch_desc, batch_type
       FROM igf_ap_li_bat_ints
      WHERE batch_num = cp_batch_num ;

  l_delete_flag_prmpt    VARCHAR2(80);
  l_error                VARCHAR2(80);
  l_lkup_type            VARCHAR2(60) ;
  l_lkup_code            VARCHAR2(60) ;
  l_batch_desc           igf_ap_li_bat_ints.batch_desc%TYPE ;
  l_batch_type           igf_ap_li_bat_ints.batch_type%TYPE ;
  l_batch_id             igf_ap_li_bat_ints.batch_type%TYPE ;
  l_yes_no               igf_lookups_view.meaning%TYPE ;
  l_award_year_pmpt      igf_lookups_view.meaning%TYPE ;
  l_params_pass_prmpt    igf_lookups_view.meaning%TYPE ;
  l_person_number_prmpt  igf_lookups_view.meaning%TYPE ;
  l_batch_num_prmpt      igf_lookups_view.meaning%TYPE ;

  BEGIN -- begin log parameters

     -- get the batch description
     OPEN  c_batch_desc( p_batch_num) ;
     FETCH c_batch_desc INTO l_batch_desc, l_batch_type ;
     CLOSE c_batch_desc ;

     fnd_message.set_name('IGS','IGS_GE_ASK_DEL_REC');
     l_delete_flag_prmpt := fnd_message.get ;

    l_error               := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
    l_person_number_prmpt := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');
    l_batch_num_prmpt     := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','BATCH_ID');
    l_award_year_pmpt     := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','AWARD_YEAR');
    l_yes_no              := igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_delete_flag);
    l_params_pass_prmpt   := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PARAMETER_PASS');

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE( FND_FILE.LOG, '-------------------------------------------------------------');
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ') ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, l_params_pass_prmpt) ; --Parameters Passed
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ') ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( l_award_year_pmpt, 40)    || ' : '|| p_alternate_code ) ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( l_batch_num_prmpt, 40)     || ' : '|| p_batch_num || '-' || l_batch_desc ) ;


    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( l_delete_flag_prmpt, 40)   || ' : '|| l_yes_no ) ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE( FND_FILE.LOG, '-------------------------------------------------------------');
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');

  END log_input_params ;

PROCEDURE print_message(p_igf_sl_message_table IN igf_sl_message_table) AS
        /*
        ||  Created By : rasahoo
        ||  Created On : 08-July-2003
        ||  Purpose : Print the error messages stored in PL/SQL message table.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        */

   indx       NUMBER;
   l_error    VARCHAR2(30);
  BEGIN
        l_error            := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
        IF p_igf_sl_message_table.COUNT<>0 THEN
          FOR indx IN p_igf_sl_message_table.FIRST..p_igf_sl_message_table.LAST
          LOOP
          fnd_file.put_line(fnd_file.log,p_igf_sl_message_table(indx).msg_text);
          END LOOP;
        END IF;
  EXCEPTION
  WHEN others THEN
   IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_li_imp_pkg.print_message.exception','Exception :'||SQLERRM);
   END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.PRINT_MESSAGE');
   fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

   RAISE IMPORT_ERROR;

END print_message;

FUNCTION is_pnote_id_valid ( l_value VARCHAR2)
RETURN BOOLEAN AS
        /*
        ||  Created By : rasahoo
        ||  Created On : 08-July-2003
        ||  Purpose : It checks for the vlidity promisorry note id.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        */

    l_char_set  VARCHAR2(100) := '0123456789';
    l_ssn       VARCHAR2(9);
    l_loan_type VARCHAR2(1);
    l_pgm_yr    VARCHAR2(2);
    l_sl_code   VARCHAR2(6);
    l_seq_num   VARCHAR2(3);
BEGIN
    l_ssn        := SUBSTR(l_value,1,9);
    l_loan_type  := SUBSTR(l_value,10,1);
    l_pgm_yr     := SUBSTR(l_value,11,2);
    l_sl_code    := SUBSTR(l_value,13,6);
    l_seq_num    := SUBSTR(l_value,19,3);
    -- Check for ssn
    IF  NVL(LENGTH(TRIM(TRANSLATE(l_ssn ,l_char_set,LPAD(' ',LENGTH(l_char_set),' ' )))),0) > 0
    OR  LENGTH(TRIM(l_ssn)) <> 9
    OR  TO_NUMBER(SUBSTR(l_ssn ,1,3)) < 1
    OR  TO_NUMBER(SUBSTR(l_ssn ,4,2)) < 1
    OR  TO_NUMBER(SUBSTR(l_ssn ,6,4)) < 1
    -- check for loan type
    OR  l_loan_type <> 'N'
    -- check for program year
    OR  l_pgm_yr NOT IN ('03','04','05','06')
    -- check for school code
    OR SUBSTR(l_sl_code,1,1) NOT IN ('G','E')
    OR NVL(LENGTH(TRIM(TRANSLATE(SUBSTR(l_sl_code,2,5),l_char_set,LPAD(' ',LENGTH(l_char_set),' ' )))),0) > 0
    -- check for sequence number
    OR LENGTH(TRIM(l_seq_num)) <> 3
    OR TO_NUMBER(l_seq_num) NOT BETWEEN 1 AND 999 THEN

    RETURN FALSE;
    ELSE
    RETURN TRUE;
    END IF;
 EXCEPTION  WHEN OTHERS THEN
 RETURN FALSE;
END is_pnote_id_valid;

FUNCTION is_batch_id_valid ( l_value VARCHAR2)
RETURN BOOLEAN AS
        /*
        ||  Created By : rasahoo
        ||  Created On : 08-July-2003
        ||  Purpose : It checks for the vlidity of batch id.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  bvisvana        25-Aug-2006     Bug 5478287 - Extending the check for cycle year 6 and 7..
        ||  (reverse chronological order - newest change first)
        */

  l_char_set    VARCHAR2(100) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  l_num_set     VARCHAR2(10)  := '1234567890';
  l_batch_type  VARCHAR2(2) := NULL;
  l_cycle_ind   VARCHAR2(1) := NULL;
  l_sl_code     VARCHAR2(6) := NULL;
  l_dt_btch_created VARCHAR2(8) := NULL;
  l_tm_btch_created VARCHAR2(6) := NULL;
BEGIN
  l_batch_type      := SUBSTR(l_value,1,2);
  l_cycle_ind       := SUBSTR(l_value,3,1);
  l_sl_code         := SUBSTR(l_value,4,6);
  l_dt_btch_created := SUBSTR(l_value,10,8);
  l_tm_btch_created := SUBSTR(l_value,18,6);

  IF  LENGTH(TRIM(l_value)) <> 23
  -- check for batch type
  OR  SUBSTR(l_batch_type,1,1) <> '#'
  OR  NVL(LENGTH(TRIM(TRANSLATE(SUBSTR(l_batch_type,2,1),l_char_set,LPAD(' ',LENGTH(l_char_set),' ' )))),0) > 0
  -- check for cycle indicator
  OR  l_cycle_ind NOT IN ('3', '4','5','6','7') -- Bug 5478287
  -- check for school code
  OR  SUBSTR(l_sl_code,1,1) NOT IN ('G','E')
  OR  NVL(LENGTH(TRIM(TRANSLATE(SUBSTR(l_sl_code,2,5),l_num_set,LPAD(' ',LENGTH(l_num_set),' ' )))),0) > 0
  OR  (TRANSLATE(SUBSTR(l_sl_code,2,5),' ','*')) <> (SUBSTR(l_sl_code,2,5))
  THEN
  RETURN FALSE;
  ELSE
  RETURN TRUE;
  END IF;
END is_batch_id_valid;

FUNCTION is_school_code_valid(l_value VARCHAR2)
RETURN BOOLEAN AS
        /*
        ||  Created By : rasahoo
        ||  Created On : 08-July-2003
        ||  Purpose : It checks for the vlidity of school code.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        */
  CURSOR c_get_dl_school IS
    SELECT 'X'
      FROM  HZ_PARTIES HZ,
            IGS_OR_ORG_ALT_IDS OLI,
            IGS_OR_ORG_ALT_IDTYP OLT
     WHERE  OLI.ORG_STRUCTURE_ID = HZ.PARTY_NUMBER
      AND   OLI.ORG_ALTERNATE_ID_TYPE = OLT.ORG_ALTERNATE_ID_TYPE
      AND   SYSDATE BETWEEN OLI.START_DATE AND NVL (END_DATE, SYSDATE)
      AND   HZ.STATUS = 'A'
      AND   OLI.ORG_ALTERNATE_ID = l_value
      AND   system_id_type = 'DL_SCH_CD';

  lv_exists VARCHAR2(1);
l_num_set     VARCHAR2(10)  := '1234567890';
BEGIN
  IF  LENGTH(TRIM(l_value)) <> 6
  OR  SUBSTR(l_value,1,1) NOT IN ('G','E')
  OR  NVL(LENGTH(TRIM(TRANSLATE(SUBSTR(l_value,2,5),l_num_set,LPAD(' ',LENGTH(l_num_set),' ' )))),0) > 0
  OR  (TRANSLATE(SUBSTR(l_value,2,5),' ','*')) <> (SUBSTR(l_value,2,5))
  THEN
    RETURN FALSE;
  ELSE
    OPEN c_get_dl_school;
    FETCH c_get_dl_school INTO lv_exists;
    CLOSE c_get_dl_school;
    IF(NVL(lv_exists,'N')='X')THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END IF;
END is_school_code_valid;

FUNCTION is_loan_number_valid ( l_value VARCHAR2)
RETURN BOOLEAN AS
        /*
        ||  Created By : rasahoo
        ||  Created On : 08-July-2003
        ||  Purpose : It checks for the vlidity of loan number.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  bvisvana        25-Aug-2006     Bug 5478287 - Extending the logic for 2007
        ||  (reverse chronological order - newest change first)
        */

    l_char_set  VARCHAR2(100) := '0123456789';
    l_ssn       VARCHAR2(9);
    l_loan_type VARCHAR2(1);
    l_pgm_yr    VARCHAR2(2);
    l_sl_code   VARCHAR2(6);
    l_seq_num   VARCHAR2(3);
BEGIN
    l_ssn        := SUBSTR(l_value,1,9);
    l_loan_type  := SUBSTR(l_value,10,1);
    l_pgm_yr     := SUBSTR(l_value,11,2);
    l_sl_code    := SUBSTR(l_value,13,6);
    l_seq_num    := SUBSTR(l_value,19,3);
    -- Check for ssn
    IF  NVL(LENGTH(TRIM(TRANSLATE(l_ssn ,l_char_set,LPAD(' ',LENGTH(l_char_set),' ' )))),0) > 0
    OR  LENGTH(TRIM(l_ssn)) <> 9
    OR  TO_NUMBER(SUBSTR(l_ssn ,1,3)) < 1
    OR  TO_NUMBER(SUBSTR(l_ssn ,4,2)) < 1
    OR  TO_NUMBER(SUBSTR(l_ssn ,6,4)) < 1
    -- check for loan type
    OR  l_loan_type NOT IN ('S','U','P')
    -- check for program year
    OR  l_pgm_yr NOT IN ('03','04','05','06','07') -- Bug 5478287
    -- check for school code
    OR SUBSTR(l_sl_code,1,1) NOT IN ('G','E')
    OR NVL(LENGTH(TRIM(TRANSLATE(SUBSTR(l_sl_code,2,5),l_char_set,LPAD(' ',LENGTH(l_char_set),' ' )))),0) > 0
    -- check for sequence number
    OR LENGTH(TRIM(l_seq_num)) <> 3
    OR TO_NUMBER(l_seq_num) NOT BETWEEN 1 AND 999 THEN

    RETURN FALSE;
    ELSE
      -- the school code in the loan number should be a valid school code in the system
      IF(is_school_code_valid(l_sl_code))THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END IF;
 EXCEPTION  WHEN OTHERS THEN
 RETURN FALSE;
END is_loan_number_valid;

FUNCTION Val_Date ( l_value IN  VARCHAR2)
RETURN BOOLEAN AS
        /*
        ||  Created By : rasahoo
        ||  Created On : 08-July-2003
        ||  Purpose : It checks for the vlidity of date which lies between 19000101  AND  20991231 .
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        */

  BEGIN

     IF TO_NUMBER(l_value) BETWEEN  19000101  AND  20991231
      THEN
          RETURN TRUE   ;
      ELSE
          RETURN FALSE;
      END IF;
  EXCEPTION  WHEN OTHERS THEN
  RETURN FALSE;
  END Val_Date;

FUNCTION Val_Date_2 ( l_value IN  VARCHAR2)
         RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :Validate the validity of date
  ||           date should be between  20020622  AND  20050927
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

     IF TO_NUMBER(l_value) BETWEEN  20020622  AND  20050927
      THEN
          RETURN TRUE   ;
      ELSE
          RETURN FALSE;
      END IF;
  EXCEPTION  WHEN OTHERS THEN
  RETURN FALSE;
  END Val_Date_2;

FUNCTION is_pnote_batch_id_valid ( l_value VARCHAR2)
RETURN BOOLEAN
AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose : Checks for the validity of Promissory note batch id.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  bvisvana        25-Aug-20006    Bug 5478287 - Extending for cycle year 6 and 7
  ||  (reverse chronological order - newest change first)
  */
  l_char_set    VARCHAR2(100) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  l_num_set     VARCHAR2(10)  := '1234567890';
  l_batch_type  VARCHAR2(2) := NULL;
  l_cycle_ind   VARCHAR2(1) := NULL;
  l_sl_code     VARCHAR2(6) := NULL;
  l_dt_btch_created VARCHAR2(8) := NULL;
  l_tm_btch_created VARCHAR2(6) := NULL;
BEGIN
  l_batch_type := SUBSTR(l_value,1,2);
  l_cycle_ind  := SUBSTR(l_value,3,1);
  l_sl_code    := SUBSTR(l_value,4,6);
  l_dt_btch_created := SUBSTR(l_value,10,8);
  l_tm_btch_created := SUBSTR(l_value,18,6);

  IF  LENGTH(TRIM(l_value)) <> 23
  -- check for batch type
  OR  SUBSTR(l_batch_type,1,2) NOT IN ('#A','#D','PF')
  -- check for cycle indicator
  OR  l_cycle_ind NOT IN ('3', '4','5','6','7') -- Bug 5478287
  -- check for school code
  OR  SUBSTR(l_sl_code,1,1) NOT IN ('G','E')
  OR  NVL(LENGTH(TRIM(TRANSLATE(SUBSTR(l_sl_code,2,5),l_num_set,LPAD(' ',LENGTH(l_num_set),' ' )))),0) > 0
  OR  (TRANSLATE(SUBSTR(l_sl_code,2,5),' ','*')) <> (SUBSTR(l_sl_code,2,5))
  THEN
  RETURN FALSE;
  ELSE
  RETURN TRUE;
  END IF;
END is_pnote_batch_id_valid;

FUNCTION is_disb_batch_id_valid ( l_value VARCHAR2)
RETURN BOOLEAN
AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose : Checks for validity of disbursement batch id.
  ||  Change History :
  ||  Who             When            What
  ||  bvisvana        25-Aug-2006     Bug 5478287 - Extending for 6 and 7
  ||  (reverse chronological order - newest change first)
  */
  l_char_set    VARCHAR2(100) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  l_num_set     VARCHAR2(10)  := '1234567890';
  l_batch_type  VARCHAR2(2) := NULL;
  l_cycle_ind   VARCHAR2(1) := NULL;
  l_sl_code     VARCHAR2(6) := NULL;
  l_dt_btch_created VARCHAR2(8) := NULL;
  l_tm_btch_created VARCHAR2(6) := NULL;
BEGIN
  l_batch_type := SUBSTR(l_value,1,2);
  l_cycle_ind  := SUBSTR(l_value,3,1);
  l_sl_code    := SUBSTR(l_value,4,6);
  l_dt_btch_created := SUBSTR(l_value,10,8);
  l_tm_btch_created := SUBSTR(l_value,18,6);

  IF  LENGTH(TRIM(l_value)) <> 23
  -- check for batch type
  OR  SUBSTR(l_batch_type,1,2) NOT IN ('#H','#B','SP')
  -- check for cycle indicator
  OR  l_cycle_ind NOT IN ('3', '4','5','6','7') -- bug 5478287
  -- check for school code
  OR  SUBSTR(l_sl_code,1,1) NOT IN ('G','E')
  OR  NVL(LENGTH(TRIM(TRANSLATE(SUBSTR(l_sl_code,2,5),l_num_set,LPAD(' ',LENGTH(l_num_set),' ' )))),0) > 0
  OR  (TRANSLATE(SUBSTR(l_sl_code,2,5),' ','*')) <> (SUBSTR(l_sl_code,2,5))
  THEN
  RETURN FALSE;
  ELSE
  RETURN TRUE;
  END IF;
END is_disb_batch_id_valid;

FUNCTION is_booking_batch_id_valid ( l_value VARCHAR2)
RETURN BOOLEAN
AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose : Checks for validity of disbursement batch id.
  ||  Change History :
  ||  Who             When            What
  ||  bvisvana        25-Aug-2006     Bug 5478287 - Extending for cycle year 6 and 7
  ||  (reverse chronological order - newest change first)
  */
  l_char_set    VARCHAR2(100) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  l_num_set     VARCHAR2(10)  := '1234567890';
  l_batch_type  VARCHAR2(2) := NULL;
  l_cycle_ind   VARCHAR2(1) := NULL;
  l_sl_code     VARCHAR2(6) := NULL;
  l_dt_btch_created VARCHAR2(8) := NULL;
  l_tm_btch_created VARCHAR2(6) := NULL;
BEGIN
  l_batch_type := SUBSTR(l_value,1,2);
  l_cycle_ind  := SUBSTR(l_value,3,1);
  l_sl_code    := SUBSTR(l_value,4,6);
  l_dt_btch_created := SUBSTR(l_value,10,8);
  l_tm_btch_created := SUBSTR(l_value,18,6);

  IF  LENGTH(TRIM(l_value)) <> 23
  -- check for batch type
  OR  SUBSTR(l_batch_type,1,2) <>'#B'
  -- check for cycle indicator
  OR  l_cycle_ind NOT IN ('3', '4','5','6','7') -- Bug 5478287
  -- check for school code
  OR  SUBSTR(l_sl_code,1,1) NOT IN ('G','E')
  OR  NVL(LENGTH(TRIM(TRANSLATE(SUBSTR(l_sl_code,2,5),l_num_set,LPAD(' ',LENGTH(l_num_set),' ' )))),0) > 0
  OR  (TRANSLATE(SUBSTR(l_sl_code,2,5),' ','*')) <> (SUBSTR(l_sl_code,2,5))
  THEN
  RETURN FALSE;
  ELSE
  RETURN TRUE;
  END IF;
END is_booking_batch_id_valid;

FUNCTION is_numeric ( l_value VARCHAR2)
RETURN BOOLEAN
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose : Checks whether the value is numeric or not.
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  l_num_set     VARCHAR2(10)  := '1234567890';
BEGIN
  IF  NVL(LENGTH(TRIM(TRANSLATE(l_value,l_num_set,LPAD(' ',LENGTH(l_num_set),' ' )))),0) > 0
  OR  (TRANSLATE(l_value,' ','*')) <> l_value THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END is_numeric;

FUNCTION is_credit_batch_id_valid ( l_value VARCHAR2)
RETURN BOOLEAN
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose : Checks for the validity of credit batch id..
  ||  Change History :
  ||  Who             When            What
  ||  bvisvana        25-Aug-2006     bug 5478287 - Extending for cycle year 6 and 7
  ||  (reverse chronological order - newest change first)
  */
  l_char_set    VARCHAR2(100) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  l_num_set     VARCHAR2(10)  := '1234567890';
  l_batch_type  VARCHAR2(2) := NULL;
  l_cycle_ind   VARCHAR2(1) := NULL;
  l_sl_code     VARCHAR2(6) := NULL;
  l_dt_btch_created VARCHAR2(8) := NULL;
  l_tm_btch_created VARCHAR2(6) := NULL;
BEGIN
  l_batch_type := SUBSTR(l_value,1,2);
  l_cycle_ind  := SUBSTR(l_value,3,1);
  l_sl_code    := SUBSTR(l_value,4,6);
  l_dt_btch_created := SUBSTR(l_value,10,8);
  l_tm_btch_created := SUBSTR(l_value,18,6);

  IF  LENGTH(TRIM(l_value)) <> 23
  -- check for batch type
  OR  SUBSTR(l_batch_type,1,2) NOT IN ('#D','PF')
  -- check for cycle indicator
  OR  l_cycle_ind NOT IN ('3', '4','5','6','7')
  -- check for school code
  OR  SUBSTR(l_sl_code,1,1) NOT IN ('G','E')
  OR  NVL(LENGTH(TRIM(TRANSLATE(SUBSTR(l_sl_code,2,5),l_num_set,LPAD(' ',LENGTH(l_num_set),' ' )))),0) > 0
  OR  (TRANSLATE(SUBSTR(l_sl_code,2,5),' ','*')) <> (SUBSTR(l_sl_code,2,5))
  THEN
  RETURN FALSE;
  ELSE
  RETURN TRUE;
  END IF;
END is_credit_batch_id_valid;

PROCEDURE validate_loan_disb( p_disb_interface    IN c_disb_interface%ROWTYPE,
                              p_award_id          IN NUMBER,
                              p_d_status          OUT NOCOPY BOOLEAN,
                              p_igf_sl_msg_table  OUT NOCOPY igf_sl_message_table
                             )
AS
/*
    ||  Created By : rasahoo
    ||  Created On : 08-July-2003
    ||  Purpose : This procedure is used to validate the loan origination disbursement interface record
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
*/
  indx               NUMBER := 0;
  l_error            VARCHAR2(10);
  l_valid            BOOLEAN;
  CURSOR c_gross_amt(cp_award_id     NUMBER,
                     cp_disb_num     NUMBER,
                     cp_disb_seq_num NUMBER )
  IS
  SELECT disb_gross_amt
  FROM  igf_db_awd_disb_dtl_all
  WHERE award_id     = cp_award_id
  AND   disb_num     = cp_disb_num
  AND   disb_seq_num = cp_disb_seq_num;

  l_gross_amt c_gross_amt%ROWTYPE;
BEGIN
  l_valid    := TRUE;
  l_error    := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
  p_d_status := TRUE;


  p_igf_sl_msg_table.DELETE;

  IF (p_disb_interface.disbursement_num < 0) OR (p_disb_interface.disbursement_num > 99) THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'DISBURSEMENT_NUM';
  p_d_status := FALSE;
  END IF;


    IF p_disb_interface.booking_batch_id_txt IS NOT NULL THEN
    l_valid := is_booking_batch_id_valid(p_disb_interface.booking_batch_id_txt);
    IF NOT l_valid THEN
       indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'BOOKING_BATCH_ID_TXT';
       p_d_status := FALSE;
    END IF;
    END IF;

  IF l_award_year_status = 'O' THEN
    OPEN c_gross_amt(p_award_id,p_disb_interface.disbursement_num,p_disb_interface.disbursement_seq_num);
    FETCH c_gross_amt INTO l_gross_amt;
    CLOSE c_gross_amt;

    IF  (NVL(l_gross_amt.disb_gross_amt ,0)<> NVL(p_disb_interface.gross_disbursement_amt,0))
    OR NVL(p_disb_interface.gross_disbursement_amt ,0) < 0
    OR p_disb_interface.gross_disbursement_amt IS NULL THEN
    indx := indx + 1;
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'GROSS_DISBURSEMENT_AMT';
    p_d_status := FALSE;
    END IF;
  ELSE
    IF NVL(p_disb_interface.gross_disbursement_amt,0) < 0
    OR p_disb_interface.gross_disbursement_amt IS NULL THEN
    indx := indx + 1;
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'GROSS_DISBURSEMENT_AMT';
    p_d_status := FALSE;
    END IF;

  END IF;


  IF  igf_ap_gen.get_lookup_meaning('IGF_DB_DL_ACTIVITY',p_disb_interface.DISBURSEMENT_ACTIVITY_CODE) IS NULL
  OR  p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IS NULL THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'DISBURSEMENT_ACTIVITY_CODE';
  p_d_status := FALSE;
  END IF;

  l_valid := Val_Date_2(TO_CHAR(p_disb_interface.DISBURSEMENT_ACTIVITY_DATE,'YYYYMMDD'));
  IF  NOT l_valid THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'DISBURSEMENT_ACTIVITY_DATE';
  p_d_status := FALSE;
  END IF;

  l_valid := Val_Date_2(TO_CHAR(p_disb_interface.DISBURSEMENT_DATE,'YYYYMMDD'));
  IF  NOT l_valid THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'DISBURSEMENT_DATE';
  p_d_status := FALSE;
  END IF;

  -- validations for INTEREST_REBATE_AMT

  IF NVL(p_disb_interface.INTEREST_REBATE_AMT,0) <= 0 THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'INTEREST_REBATE_AMT';
  p_d_status := FALSE;
  END IF;

  -- Validations for LOC_DISBURSEMENT_GROSS_AMT

   IF l_award_year_status = 'O' THEN
      IF     g_award_year = '3' THEN

       IF   ( p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IN ('A','D')
       AND   NVL(p_disb_interface.LOC_DISBURSEMENT_GROSS_AMT,0) <= 0) THEN
             indx := indx + 1;
             p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_DISBURSEMENT_GROSS_AMT';
             p_d_status := FALSE;
       ELSIF p_disb_interface.DISBURSEMENT_ACTIVITY_CODE = 'Q'  THEN
        IF   p_disb_interface.LOC_DISBURSEMENT_GROSS_AMT IS NOT NULL THEN
          IF NVL(p_disb_interface.LOC_DISBURSEMENT_GROSS_AMT,0) > 0
          OR NVL(p_disb_interface.LOC_DISBURSEMENT_GROSS_AMT,0) < 0 THEN
             indx := indx + 1;
             p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_DISBURSEMENT_GROSS_AMT';
             p_d_status := FALSE;
          END IF;
        END IF;
       END IF;
      ELSIF  g_award_year IN ('4','5') THEN

       IF    ( p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IN ('A','D')
       AND    NVL(p_disb_interface.LOC_DISBURSEMENT_GROSS_AMT,0) < 0) THEN
              indx := indx + 1;
              p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_DISBURSEMENT_GROSS_AMT';
              p_d_status := FALSE;

       ELSIF  p_disb_interface.DISBURSEMENT_ACTIVITY_CODE = 'Q' THEN
         IF   p_disb_interface.LOC_DISBURSEMENT_GROSS_AMT IS NOT NULL THEN
           IF NVL(p_disb_interface.LOC_DISBURSEMENT_GROSS_AMT,0) > 0
           OR NVL(p_disb_interface.LOC_DISBURSEMENT_GROSS_AMT,0) < 0 THEN
              indx := indx + 1;
              p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_DISBURSEMENT_GROSS_AMT';
              p_d_status := FALSE;
           END IF;
         END IF;

       END IF;

      END IF;
  ELSE
    IF  NVL(p_disb_interface.LOC_DISBURSEMENT_GROSS_AMT,0) < 0 THEN
        indx := indx + 1;
        p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_DISBURSEMENT_GROSS_AMT';
        p_d_status := FALSE;

    END IF;
  END IF;
    -- validations for LOC_FEE_1_AMT
   IF l_award_year_status = 'O' THEN
    IF     g_award_year = '3' THEN

     IF    ( p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IN ('A','D')
     AND   NVL(p_disb_interface.LOC_FEE_1_AMT,0) <= 0) THEN
           indx := indx + 1;
           p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_FEE_1_AMT';
           p_d_status := FALSE;
     ELSIF p_disb_interface.DISBURSEMENT_ACTIVITY_CODE = 'Q'  THEN
      IF   p_disb_interface.LOC_FEE_1_AMT IS NOT NULL THEN
        IF p_disb_interface.LOC_FEE_1_AMT > 0
        OR  p_disb_interface.LOC_FEE_1_AMT < 0 THEN
           indx := indx + 1;
           p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_FEE_1_AMT';
           p_d_status := FALSE;
        END IF;
      END IF;
     END IF;
    ELSIF  g_award_year IN ('4','5') THEN

     IF    ( p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IN ('A','D')
     AND    NVL(p_disb_interface.LOC_FEE_1_AMT,0) < 0) THEN
            indx := indx + 1;
            p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_FEE_1_AMT';
            p_d_status := FALSE;

     ELSIF  p_disb_interface.DISBURSEMENT_ACTIVITY_CODE = 'Q' THEN
       IF   p_disb_interface.LOC_FEE_1_AMT IS NOT NULL THEN
         IF p_disb_interface.LOC_FEE_1_AMT > 0
         OR p_disb_interface.LOC_FEE_1_AMT < 0 THEN
            indx := indx + 1;
            p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_FEE_1_AMT';
            p_d_status := FALSE;
         END IF;
       END IF;

     END IF;

    END IF;
  ELSE
    IF NVL(p_disb_interface.LOC_FEE_1_AMT,0) <= 0 THEN
       indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_FEE_1_AMT';
       p_d_status := FALSE;

    END IF;
  END IF;

    -- validations for LOC_INT_REBATE_AMT

   IF l_award_year_status = 'O' THEN
     IF     g_award_year = '3' THEN

       IF   ( p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IN ('A','D')
       AND   NVL(p_disb_interface.LOC_INT_REBATE_AMT,0) <= 0) THEN
             indx := indx + 1;
             p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_INT_REBATE_AMT';
             p_d_status := FALSE;
       ELSIF  p_disb_interface.DISBURSEMENT_ACTIVITY_CODE = 'Q' THEN
         IF  p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IS NOT NULL THEN
           IF p_disb_interface.LOC_INT_REBATE_AMT > 0
           OR p_disb_interface.LOC_INT_REBATE_AMT < 0 THEN
              indx := indx + 1;
              p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_INT_REBATE_AMT';
              p_d_status := FALSE;
           END IF;
         END IF;
       END IF;

      ELSIF  g_award_year IN ('4','5') THEN

       IF    ( p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IN ('A','D')
       AND    p_disb_interface.LOC_INT_REBATE_AMT < 0) THEN
              indx := indx + 1;
              p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_INT_REBATE_AMT';
              p_d_status := FALSE;

       ELSIF  p_disb_interface.DISBURSEMENT_ACTIVITY_CODE = 'Q' THEN
         IF  p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IS NOT NULL THEN
           IF p_disb_interface.LOC_INT_REBATE_AMT > 0
           OR p_disb_interface.LOC_INT_REBATE_AMT < 0 THEN
              indx := indx + 1;
              p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_INT_REBATE_AMT';
              p_d_status := FALSE;
           END IF;
         END IF;

       END IF;

     END IF;
   ELSE
    IF NVL(p_disb_interface.LOC_INT_REBATE_AMT,0) <= 0 THEN
       indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_INT_REBATE_AMT';
       p_d_status := FALSE;

    END IF;
   END IF;

  -- validations for LOC_DISBURSEMENT_NET_AMT

 IF l_award_year_status = 'O' THEN
     IF     g_award_year = '3' THEN

       IF   ( p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IN ('A','D')
       AND   NVL(p_disb_interface.LOC_DISBURSEMENT_NET_AMT,0) <= 0) THEN
             indx := indx + 1;
             p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_DISBURSEMENT_NET_AMT';
             p_d_status := FALSE;
       ELSIF p_disb_interface.DISBURSEMENT_ACTIVITY_CODE = 'Q'  THEN
        IF   p_disb_interface.LOC_DISBURSEMENT_NET_AMT IS NOT NULL THEN
          IF NVL(p_disb_interface.LOC_DISBURSEMENT_NET_AMT,0) > 0
          OR NVL(p_disb_interface.LOC_DISBURSEMENT_NET_AMT,0) < 0 THEN
             indx := indx + 1;
             p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_DISBURSEMENT_NET_AMT';
             p_d_status := FALSE;
          END IF;
        END IF;
       END IF;
      ELSIF  g_award_year IN ('4','5') THEN

       IF    ( p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IN ('A','D')
       AND    NVL(p_disb_interface.LOC_DISBURSEMENT_NET_AMT,0) < 0) THEN
              indx := indx + 1;
              p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_DISBURSEMENT_NET_AMT';
              p_d_status := FALSE;

       ELSIF  p_disb_interface.DISBURSEMENT_ACTIVITY_CODE = 'Q' THEN
         IF p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IS NOT NULL THEN
           IF NVL(p_disb_interface.LOC_DISBURSEMENT_NET_AMT,0) > 0
           OR NVL(p_disb_interface.LOC_DISBURSEMENT_NET_AMT,0) < 0 THEN
              indx := indx + 1;
              p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_DISBURSEMENT_NET_AMT';
              p_d_status := FALSE;
           END IF;
         END IF;

       END IF;

     END IF;
  ELSE
    IF NVL(p_disb_interface.LOC_DISBURSEMENT_NET_AMT,0) <= 0 THEN
       indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_DISBURSEMENT_NET_AMT';
       p_d_status := FALSE;

    END IF;
  END IF;

  -- Validations for DISBURSEMENT_BATCH_ID_TXT

    l_valid := is_disb_batch_id_valid(p_disb_interface.DISBURSEMENT_BATCH_ID_TXT);
    IF p_disb_interface.DISBURSEMENT_BATCH_ID_TXT IS NULL
    OR NOT l_valid THEN
       indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'DISBURSEMENT_BATCH_ID_TXT';
       p_d_status := FALSE;
    END IF;

  -- Validations for SERVICER_REFUND_AMT
    IF l_award_year_status = 'O' THEN
      IF p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IN ('A','D','Q') THEN
       IF p_disb_interface.SERVICER_REFUND_AMT IS NOT NULL THEN
          indx := indx + 1;
          p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'SERVICER_REFUND_AMT';
          p_d_status := FALSE;
       END IF;
      ELSE
        IF NVL(p_disb_interface.SERVICER_REFUND_AMT,0) < 0 THEN
          indx := indx + 1;
          p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'SERVICER_REFUND_AMT';
          p_d_status := FALSE;
        END IF;
      END IF;
    ELSE
       IF NVL(p_disb_interface.SERVICER_REFUND_AMT,0) < 0 THEN
          indx := indx + 1;
          p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'SERVICER_REFUND_AMT';
          p_d_status := FALSE;
       END IF;
    END IF;

     -- validations for loc_net_booked_loan_amt
    IF l_award_year_status = 'O' THEN
      IF p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IN ('A','D','Q') THEN
       IF p_disb_interface.LOC_NET_BOOKED_LOAN_AMT IS NOT NULL THEN
          indx := indx + 1;
          p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_NET_BOOKED_LOAN_AMT';
          p_d_status := FALSE;
       END IF;
      ELSIF NVL(p_disb_interface.LOC_NET_BOOKED_LOAN_AMT,0) < 0 THEN
          indx := indx + 1;
          p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_NET_BOOKED_LOAN_AMT';
          p_d_status := FALSE;
      END IF;
    ELSIF NVL(p_disb_interface.LOC_NET_BOOKED_LOAN_AMT,0) < 0 THEN
          indx := indx + 1;
          p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOC_NET_BOOKED_LOAN_AMT';
          p_d_status := FALSE;

    END IF;

    -- validations for acknowledgement_date
    l_valid := Val_Date(TO_CHAR(p_disb_interface.ACKNOWLEDGEMENT_DATE,'YYYYMMDD'));
    IF  NOT l_valid THEN
    indx := indx + 1;
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'ACKNOWLEDGEMENT_DATE';
    p_d_status := FALSE;
    END IF;

  -- validations for confirmation_flag
    IF l_award_year_status = 'O' THEN
      IF p_disb_interface.DISBURSEMENT_ACTIVITY_CODE IN ('A','D') THEN
        IF p_disb_interface.CONFIRMATION_FLAG IS NOT NULL THEN
           IF p_disb_interface.CONFIRMATION_FLAG <> 'Y' THEN
              indx := indx + 1;
              p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'CONFIRMATION_FLAG';
              p_d_status := FALSE;
           END IF;
        END IF;
      ELSIF p_disb_interface.DISBURSEMENT_ACTIVITY_CODE = 'Q' THEN
         IF p_disb_interface.CONFIRMATION_FLAG IS NOT NULL THEN
            indx := indx + 1;
            p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'CONFIRMATION_FLAG';
            p_d_status := FALSE;
         END IF;
      END IF;
    END IF;

    -- validations for school_code_txt
    IF p_disb_interface.SCHOOL_CODE_TXT IS NOT NULL THEN
      l_valid := is_school_code_valid(p_disb_interface.SCHOOL_CODE_TXT);
      IF  NOT l_valid THEN
      indx := indx + 1;
      p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'SCHOOL_CODE_TXT';
      p_d_status := FALSE;
      END IF;
    END IF;

 EXCEPTION

   WHEN others THEN
   IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_li_imp_pkg.validate_loan_disb.exception','Exception: '||SQLERRM);
   END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.VALIDATE_LOAN_DISB');
   fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

   RAISE IMPORT_ERROR;

END validate_loan_disb;

PROCEDURE validate_loan_orig_int( p_interface            IN  c_interface%ROWTYPE,
                                  p_award_id             IN NUMBER,
                                  p_status               OUT NOCOPY BOOLEAN,
                                  p_igf_sl_msg_table     OUT NOCOPY igf_sl_message_table
                                  )
AS
/*
    ||  Created By : rasahoo
    ||  Created On : 08-July-2003
    ||  Purpose : This procedure is used to validate the loan origination interface record
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  rasahoo         11-Aug-2003     Removed the validation for Change status type and
    ||                                  added validation logic for loan_chg_status
    ||  (reverse chronological order - newest change first)
*/
 l_valid            BOOLEAN;
 indx               NUMBER := 0;
 l_error            VARCHAR2(20);
 lv_person_id       igs_pe_hz_parties.party_id%TYPE     := NULL;
 lv_base_id         igf_ap_fa_base_rec_all.base_id%TYPE := NULL;

 -- Get the details of
 CURSOR c_accepted_amt(p_award_id       NUMBER)
 IS
 SELECT  accepted_amt
 FROM    igf_aw_award
 WHERE   award_id = p_award_id;

 l_accepted_amt  c_accepted_amt%ROWTYPE;

BEGIN
  l_error            := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
  l_valid := TRUE;

  -- intialize process status
  p_status := TRUE;
  p_igf_sl_msg_table.DELETE;

  -- validate loan number
  l_valid := is_loan_number_valid(p_interface.loan_number_txt);
  IF (p_interface.loan_number_txt IS NULL) OR (l_valid = FALSE) THEN
  indx := indx + 1;
  fnd_message.set_name('IGF','IGF_SL_INVAL_DL_ID');
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get;
  p_status := FALSE;
  END IF;

  -- Validate loan_seq_num
  IF p_interface.loan_seq_num IS NULL
  OR NVL(p_interface.loan_seq_num ,0) < 1 THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOAN_SEQ_NUM';
  p_status := FALSE;
  END IF;

  -- validate loan_per_begin_date
  IF p_interface.loan_per_begin_date IS NULL THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOAN_PER_BEGIN_DATE';
  p_status := FALSE;
  END IF;

  -- validate loan_per_end_date
  IF  p_interface.loan_per_end_date IS NULL
  OR (p_interface.loan_per_end_date < p_interface.loan_per_begin_date) THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOAN_PER_END_DATE';
  p_status := FALSE;
  END IF;

  -- validate loan_status_code
  IF  igf_ap_gen.get_lookup_meaning('IGF_SL_LOAN_STATUS', p_interface.loan_status_code) IS NULL
  OR  p_interface.loan_status_code IN ('B','C','R','S','T')
  OR  p_interface.loan_status_code IS NULL THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOAN_STATUS_CODE';
  p_status := FALSE;
  END IF;

  --Validations for loan_chg_status
  IF p_interface.loan_chg_status IS NOT NULL  THEN
    IF igf_ap_gen.get_lookup_meaning('IGF_SL_LOAN_CHG_STATUS', p_interface.loan_chg_status) IS NULL
    OR p_interface.loan_chg_status IN ('S','B') THEN
    indx := indx + 1;
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOAN_CHG_STATUS';
    p_status := FALSE;
    ELSIF p_interface.loan_chg_status IN ('A','R') AND p_interface.loan_status_code <> 'A' THEN
    indx := indx + 1;
    fnd_message.set_name('IGF','IGF_SL_LI_INVALID_CHG_STAT');
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get;
    p_status := FALSE;
    END IF;
  END IF;

  --Validations for active_flag
  IF p_interface.active_flag IS  NULL
  OR igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.active_flag) IS NULL THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'ACTIVE_FLAG';
  p_status := FALSE;
  END IF;

  --Validations for grade_level_code
  IF  p_interface.grade_level_code IS NULL
  OR igf_ap_gen.get_lookup_meaning('IGF_AP_GRADE_LEVEL',p_interface.grade_level_code) IS NULL
  OR p_interface.grade_level_code = '0/1' THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'GRADE_LEVEL_CODE';
  p_status := FALSE;
  END IF;

  -- Validations for loan_approved_amt
  OPEN  c_accepted_amt(p_award_id);
  FETCH c_accepted_amt INTO l_accepted_amt;
  CLOSE c_accepted_amt;

  IF (p_interface.LOAN_STATUS_CODE = 'A' AND p_interface.loan_approved_amt IS NULL)
  OR NVL(p_interface.loan_approved_amt,0) < 0
  OR p_interface.loan_approved_amt <> l_accepted_amt.accepted_amt THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'LOAN_APPROVED_AMT';
  p_status := FALSE;
  END IF;

  -- Validations for orig_send_batch_id_txt
  IF  p_interface.loan_status_code IN ('A') THEN
    IF p_interface.orig_send_batch_id_txt IS NULL THEN
      -- error out displaying the appropriate message
      indx := indx + 1;
      fnd_message.set_name('IGF','IGF_SL_INVALID_FLD');
      fnd_message.set_token('FIELD','ORIG_SEND_BATCH_ID_TXT');
      p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get();
      p_status := FALSE;
    END IF;
  ELSE
    l_valid := is_batch_id_valid(p_interface.orig_send_batch_id_txt);
    IF (NOT l_valid ) THEN
      indx := indx + 1;
      p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'ORIG_SEND_BATCH_ID_TXT';
      p_status := FALSE;
    END IF;
  END IF;

  -- validations for unsub_elig_for_depnt_code
  IF l_award_year_status <> 'O' AND p_interface.UNSUB_ELIG_FOR_DEPNT_CODE IS NOT NULL THEN
   IF igf_ap_gen.get_lookup_meaning('IGF_SL_DL_DEP_UNSUB_ELIG',p_interface.UNSUB_ELIG_FOR_DEPNT_CODE) IS NULL  THEN
      indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'UNSUB_ELIG_FOR_DEPNT_CODE';
       p_status := FALSE;
   END IF;
  END IF;

  IF l_award_year_status = 'O' THEN
    IF p_interface.LOAN_STATUS_CODE = 'A' AND lv_fed_fund_code = 'DLU' THEN
      IF p_interface.UNSUB_ELIG_FOR_DEPNT_CODE IS NULL THEN
         indx := indx + 1;
         fnd_message.set_name('IGF','IGF_SL_UNSUB_ELIG_REQ');
         p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get;
         p_status := FALSE;
      ELSIF igf_ap_gen.get_lookup_meaning('IGF_SL_DL_DEP_UNSUB_ELIG',p_interface.UNSUB_ELIG_FOR_DEPNT_CODE) IS NULL  THEN
         indx := indx + 1;
         p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'UNSUB_ELIG_FOR_DEPNT_CODE';
         p_status := FALSE;
      END IF;
    END IF;

    IF lv_fed_fund_code IN ('DLP','DLS') THEN
     IF p_interface.UNSUB_ELIG_FOR_DEPNT_CODE IS NOT NULL THEN
       indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'UNSUB_ELIG_FOR_DEPNT_CODE';
       p_status := FALSE;
     END IF;
    END IF;
  END IF;

  -- validations for orig_fee_perct_num
  IF (p_interface.orig_fee_perct_num IS NOT NULL AND p_interface.orig_fee_perct_num < 0) THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'ORIG_FEE_PERCT_NUM';
  p_status := FALSE;
  END IF;

  -- validations for s_default_status_code
  IF l_award_year_status <> 'O' AND p_interface.S_DEFAULT_STATUS_CODE IS NOT NULL THEN
    IF igf_ap_gen.get_lookup_meaning('IGF_SL_S_DEFAULT_STATUS',p_interface.S_DEFAULT_STATUS_CODE) IS NULL
    OR p_interface.S_DEFAULT_STATUS_CODE = 'Y'   THEN
       indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'S_DEFAULT_STATUS_CODE';
       p_status := FALSE;
    END IF;
  END IF;


  IF l_award_year_status = 'O' THEN
    IF p_interface.LOAN_STATUS_CODE = 'A' AND lv_fed_fund_code = 'DLP' THEN
      IF p_interface.S_DEFAULT_STATUS_CODE IS NULL THEN
         indx := indx + 1;
         fnd_message.set_name('IGF','IGF_SL_DEF_STAT_REQ');
         p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get;
         p_status := FALSE;
      ELSIF igf_ap_gen.get_lookup_meaning('IGF_SL_S_DEFAULT_STATUS',p_interface.S_DEFAULT_STATUS_CODE) IS NULL
      OR p_interface.S_DEFAULT_STATUS_CODE = 'Y' THEN
         indx := indx + 1;
         p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'S_DEFAULT_STATUS_CODE';
         p_status := FALSE;
      END IF;
    END IF;


     IF lv_fed_fund_code IN ('DLU','DLS') THEN
        IF p_interface.S_DEFAULT_STATUS_CODE IS NOT NULL THEN
        indx := indx + 1;
        p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'S_DEFAULT_STATUS_CODE';
        p_status := FALSE;
        END IF;
     END IF;
  END IF;

  -- validation for pnote_accept_amt
  IF l_award_year_status = 'O' THEN

   IF p_interface.LOAN_STATUS_CODE = 'A' AND lv_fed_fund_code = 'DLP' THEN
     IF p_interface.PNOTE_ACCEPT_AMT IS NULL THEN
     indx := indx + 1;
     fnd_message.set_name('IGF','IGF_SL_PNOTE_ACCEPT_AMT_REQ');
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get;
     p_status := FALSE;
     ELSIF  NVL(p_interface.PNOTE_ACCEPT_AMT,0) < 0 THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_ACCEPT_AMT';
     p_status := FALSE;
     END IF;
   END IF;
  END IF;

 -- validation for orig_batch_date
 IF (p_interface.LOAN_STATUS_CODE = 'A' AND p_interface.ORIG_BATCH_DATE IS NULL)
 OR ((p_interface.ORIG_BATCH_DATE IS NOT NULL) AND (NOT Val_Date(TO_CHAR(p_interface.ORIG_BATCH_DATE,'YYYYMMDD')))) THEN
 indx := indx + 1;
 p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'ORIG_BATCH_DATE';
 p_status := FALSE;
 END IF;

 -- Validations for unsub_elig_for_heal_code
  IF  l_award_year_status <> 'O' AND p_interface.UNSUB_ELIG_FOR_HEAL_CODE IS NOT NULL THEN
     IF igf_ap_gen.get_lookup_meaning('IGF_SL_DL_HP_UNSUB_ELIG',p_interface.UNSUB_ELIG_FOR_HEAL_CODE) IS NULL THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'UNSUB_ELIG_FOR_HEAL_CODE';
     p_status := FALSE;
     END IF;
  END IF;
  IF l_award_year_status = 'O' THEN
    IF p_interface.LOAN_STATUS_CODE = 'A' AND lv_fed_fund_code = 'DLU' THEN
     IF igf_ap_gen.get_lookup_meaning('IGF_SL_DL_HP_UNSUB_ELIG',p_interface.UNSUB_ELIG_FOR_HEAL_CODE) IS NULL THEN
     indx := indx + 1;
     fnd_message.set_name('IGF','IGF_SL_UNSUB_ELG_HEAL_REQ');
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get;
     p_status := FALSE;
     END IF;
    ELSIF lv_fed_fund_code = 'DLU' AND p_interface.UNSUB_ELIG_FOR_HEAL_CODE IS NOT  NULL THEN
     IF igf_ap_gen.get_lookup_meaning('IGF_SL_DL_HP_UNSUB_ELIG',p_interface.UNSUB_ELIG_FOR_HEAL_CODE) IS NULL THEN
     indx := indx + 1;
     fnd_message.set_name('IGF','IGF_SL_UNSUB_ELG_HEAL_REQ');
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get;
     p_status := FALSE;
     END IF;
    END IF;


    IF lv_fed_fund_code IN ('DLP','DLS') THEN
     IF p_interface.UNSUB_ELIG_FOR_HEAL_CODE IS NOT NULL THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'UNSUB_ELIG_FOR_HEAL_CODE';
     p_status := FALSE;
     END IF;
    END IF;
 END IF;

 -- Validations for disclosure_print_ind_code
  IF  p_interface.DISCLOSURE_PRINT_IND_CODE IS NOT NULL THEN
     IF igf_ap_gen.get_lookup_meaning('IGF_SL_DISCLOSURE_PRINT_IND',p_interface.DISCLOSURE_PRINT_IND_CODE) IS NULL
     OR p_interface.DISCLOSURE_PRINT_IND_CODE  IN ('N','Z') THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'DISCLOSURE_PRINT_IND_CODE';
     p_status := FALSE;
     END IF;
  END IF;

 -- Validations for credit_decision_date
  IF l_award_year_status <> 'O' AND p_interface.CREDIT_DECISION_DATE IS NOT NULL THEN
     IF  NOT Val_Date(TO_CHAR(p_interface.CREDIT_DECISION_DATE,'YYYYMMDD')) THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'CREDIT_DECISION_DATE';
     p_status := FALSE;
     END IF;
  END IF;

  IF l_award_year_status = 'O' THEN
    IF  lv_fed_fund_code = 'DLP' THEN
      IF p_interface.loan_status_code = 'A' AND p_interface.CREDIT_DECISION_DATE IS  NULL THEN
       indx := indx + 1;
       fnd_message.set_name('IGF','IGF_SL_CREDIT_DECS_DATE_REQ');
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get;
       p_status := FALSE;
      ELSIF p_interface.CREDIT_DECISION_DATE IS NOT NULL THEN
        IF  NOT Val_Date(TO_CHAR(p_interface.CREDIT_DECISION_DATE,'YYYYMMDD')) THEN
        indx := indx + 1;
        p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'CREDIT_DECISION_DATE';
        p_status := FALSE;
        END IF;
      END IF;
    END IF;
     IF lv_fed_fund_code IN ('DLU','DLS') THEN
     IF p_interface.CREDIT_DECISION_DATE IS NOT NULL THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'CREDIT_DECISION_DATE';
     p_status := FALSE;
     END IF;
    END IF;
  END IF;

 -- -- Validations for credit_override_code
  IF l_award_year_status <> 'O' AND p_interface.CREDIT_OVERRIDE_CODE IS NOT NULL THEN
     IF igf_ap_gen.get_lookup_meaning('IGF_SL_CREDIT_OVERRIDE',p_interface.CREDIT_OVERRIDE_CODE) IS NULL
     OR p_interface.CREDIT_OVERRIDE_CODE IN ('01','05','10','15','20','25','30','35') THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'CREDIT_OVERRIDE_CODE';
     p_status := FALSE;
     END IF;
  END IF;
  IF l_award_year_status = 'O' THEN
    IF p_interface.LOAN_STATUS_CODE = 'A' AND lv_fed_fund_code = 'DLP' THEN
      IF  p_interface.CREDIT_OVERRIDE_CODE IS NULL  THEN
       indx := indx + 1;
       fnd_message.set_name('IGF','IGF_SL_CREDIT_OVERRIDE_REQ');
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get;
       p_status := FALSE;
      ELSIF igf_ap_gen.get_lookup_meaning('IGF_SL_CREDIT_OVERRIDE',p_interface.CREDIT_OVERRIDE_CODE) IS NULL
      OR p_interface.CREDIT_OVERRIDE_CODE IN ('01','05','10','15','20','25','30','35') THEN
       indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'CREDIT_OVERRIDE_CODE';
       p_status := FALSE;

      END IF;
    END IF;

    IF lv_fed_fund_code IN ('DLU','DLS') THEN
     IF p_interface.CREDIT_OVERRIDE_CODE IS NOT NULL THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'CREDIT_OVERRIDE_CODE';
     p_status := FALSE;
     END IF;
    END IF;
  END IF;

   -- Validations for pnote_id_txt
  IF  p_interface.loan_status_code = 'N' AND p_interface.PNOTE_ID_TXT IS NOT NULL THEN
    indx := indx + 1;
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_ID_TXT';
    p_status := FALSE;

  ELSE
    IF  g_award_year = '3'
    AND lv_fed_fund_code = 'DLP'
    AND p_interface.PNOTE_ID_TXT IS NOT NULL THEN

    indx := indx + 1;
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_ID_TXT';
    p_status := FALSE;
    ELSIF (g_award_year IN ('4','5')
    OR lv_fed_fund_code IN ('DLS','DLU'))
    AND p_interface.PNOTE_ID_TXT IS NOT NULL THEN
        l_valid := is_pnote_id_valid(p_interface.PNOTE_ID_TXT);
        IF NOT l_valid THEN
        indx := indx + 1;
        p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_ID_TXT';
        p_status := FALSE;
        END IF;
    END IF;
  END IF;

   -- -- Validations for pnote_batch_seq_num_txt
  IF  p_interface.loan_status_code = 'N'
  AND p_interface.PNOTE_BATCH_SEQ_NUM_TXT IS NOT NULL THEN
    indx := indx + 1;
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_BATCH_SEQ_NUM_TXT';
    p_status := FALSE;
  ELSIF p_interface.PNOTE_BATCH_SEQ_NUM_TXT IS NOT NULL THEN
    l_valid := is_pnote_batch_id_valid(p_interface.PNOTE_BATCH_SEQ_NUM_TXT);
    IF NOT l_valid  THEN
    indx := indx + 1;
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_BATCH_SEQ_NUM_TXT';
    p_status := FALSE;
    END IF;
  END IF;

  -- validations for pnote_status_code
  IF p_interface.PNOTE_STATUS_CODE IS NULL THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_STATUS_CODE';
     p_status := FALSE;
  ELSE
    IF p_interface.LOAN_STATUS_CODE = 'N'  THEN
      IF p_interface.PNOTE_STATUS_CODE <> 'N' THEN
       indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_STATUS_CODE';
       p_status := FALSE;
      END IF;
    ELSIF p_interface.LOAN_STATUS_CODE = 'G' THEN
       IF igf_ap_gen.get_lookup_meaning('IGF_SL_DL_PNOTE_STATUS',p_interface.PNOTE_STATUS_CODE) IS NULL
       OR p_interface.PNOTE_STATUS_CODE IN ('A','C','F','I','R','X') THEN
       indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_STATUS_CODE';
       p_status := FALSE;
       END IF;
    ELSIF p_interface.LOAN_STATUS_CODE = 'A' THEN
       IF igf_ap_gen.get_lookup_meaning('IGF_SL_DL_PNOTE_STATUS',p_interface.PNOTE_STATUS_CODE) IS NULL THEN
       indx := indx + 1;
       p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_STATUS_CODE';
       p_status := FALSE;
       END IF;
    END IF;
  END IF;

 -- Validatios for pnote_status_type
 IF ( p_interface.loan_status_code = 'N'   OR  lv_fed_fund_code = 'DLP')
 AND p_interface.PNOTE_STATUS_TYPE IS NOT NULL THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_STATUS_TYPE';
  p_status := FALSE;
 ELSIF  p_interface.PNOTE_STATUS_TYPE IS NOT NULL THEN
  IF igf_ap_gen.get_lookup_meaning('IGF_SL_PNOTE_TYPE',p_interface.PNOTE_STATUS_TYPE) IS NULL THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_STATUS_TYPE';
  p_status := FALSE;
  END IF;
 END IF;

  -- Validatios for pnote_indicator_code
  IF ( p_interface.loan_status_code = 'N'   OR ( g_award_year = '3' AND lv_fed_fund_code = 'DLP'))
  AND p_interface.PNOTE_INDICATOR_CODE IS NOT NULL THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_INDICATOR_CODE';
     p_status := FALSE;
  ELSIF p_interface.PNOTE_INDICATOR_CODE NOT IN ('Y','N') THEN
  indx := indx + 1;
  p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_INDICATOR_CODE';
  p_status := FALSE;
  END IF;

 -- Validatios for pnote_print_ind_code
    IF p_interface.loan_status_code = 'A' AND  p_interface.PNOTE_PRINT_IND_CODE IS NULL THEN
        indx := indx + 1;
        p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_PRINT_IND_CODE';
        p_status := FALSE;
    ELSIF  p_interface.PNOTE_PRINT_IND_CODE IS NOT NULL THEN
      IF  g_award_year = '3' THEN
        IF igf_ap_gen.get_lookup_meaning('IGF_SL_PNOTE_PRINT_IND',p_interface.PNOTE_PRINT_IND_CODE) IS NULL
        OR p_interface.PNOTE_PRINT_IND_CODE = 'V' THEN
        indx := indx + 1;
        p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_PRINT_IND_CODE';
        p_status := FALSE;
        END IF;
      ELSIF g_award_year IN ('4','5') THEN
        IF igf_ap_gen.get_lookup_meaning('IGF_SL_PNOTE_PRINT_IND',p_interface.PNOTE_PRINT_IND_CODE) IS NULL  THEN
        indx := indx + 1;
        p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'PNOTE_PRINT_IND_CODE';
        p_status := FALSE;
        END IF;
      END IF;
    END IF;

  -- Validatios for mpn_acknowledgement_date
  IF p_interface.PNOTE_STATUS_CODE IN ('A','I','C') THEN
   IF NOT Val_Date(TO_CHAR(p_interface.MPN_ACKNOWLEDGEMENT_DATE,'YYYYMMDD')) THEN
   indx := indx + 1;
   p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'MPN_ACKNOWLEDGEMENT_DATE';
   p_status := FALSE;
   END IF;
  END IF;

 -- validations for endorser_amount
  IF  l_award_year_status = 'O'
  AND lv_fed_fund_code = 'DLP'
  AND p_interface.endorser_amount IS NOT NULL  THEN
     IF NVL(p_interface.endorser_amount,0) < 0 THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'ENDORSER_AMOUNT';
     p_status := FALSE;
     END IF;
  ELSIF (l_award_year_status = 'O'
  AND   lv_fed_fund_code IN ('DLS','DLU')
  AND   p_interface.endorser_amount IS NOT NULL)
  OR    (g_award_year = '3'
  AND p_interface.endorser_amount IS NOT NULL) THEN
     indx := indx + 1;
     p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'ENDORSER_AMOUNT';
     p_status := FALSE;
  END IF;

  -- Validations for  cr_desc_batch_id_txt
  l_valid := is_credit_batch_id_valid(p_interface.cr_desc_batch_id_txt);
  IF p_interface.loan_status_code = 'A' AND lv_fed_fund_code = 'DLP' THEN
    IF  p_interface.cr_desc_batch_id_txt IS NULL
    OR (NOT l_valid )  THEN
    indx := indx + 1;
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'CR_DESC_BATCH_ID_TXT';
    p_status := FALSE;
    END IF;
  ELSIF  p_interface.loan_status_code IN ('N','R')
     AND lv_fed_fund_code = 'DLP'
     AND p_interface.cr_desc_batch_id_txt IS NOT NULL
     AND (NOT l_valid ) THEN
      indx := indx + 1;
      p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'CR_DESC_BATCH_ID_TXT';
      p_status := FALSE;
  ELSIF  lv_fed_fund_code IN ('DLS','DLU')
     AND p_interface.cr_desc_batch_id_txt IS NOT NULL THEN
      indx := indx + 1;
      p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'CR_DESC_BATCH_ID_TXT';
      p_status := FALSE;
  END IF;

  -- Validations for s_default_status_code
  IF p_interface.S_DEFAULT_STATUS_CODE IS NOT NULL THEN
    IF igf_ap_gen.get_lookup_meaning('IGF_SL_S_DEFAULT_STATUS',p_interface.S_DEFAULT_STATUS_CODE) IS NULL THEN
    indx := indx + 1;
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'S_DEFAULT_STATUS_CODE';
    p_status := FALSE;
    END IF;
  END IF;

  -- Validations for p_default_status_code
  IF p_interface.P_DEFAULT_STATUS_CODE IS NOT NULL THEN
    IF igf_ap_gen.get_lookup_meaning('IGF_SL_P_DEFAULT_STATUS',p_interface.P_DEFAULT_STATUS_CODE) IS NULL THEN
    indx := indx + 1;
    p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || g_error_string|| ' ' || 'P_DEFAULT_STATUS_CODE';
    p_status := FALSE;
    END IF;
  END IF;

  -- If the loan status is 'Acknowlegded' then p_interface.orig_send_batch_id_txt
  -- has to be not null to be inserted in the igf_sl_dl_lor_resp ,igf_sl_dl_batch table
  IF  p_interface.loan_status_code IN ('A') THEN
    IF p_interface.orig_acknowledgement_date IS NULL THEN
      indx := indx + 1;
      fnd_message.set_name('IGF','IGF_SL_INVALID_FLD');
      fnd_message.set_token('FIELD','ORIG_ACKNOWLEDGEMENT_DATE');
      p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get();
      p_status := FALSE;
    END IF;
  END IF;

  IF p_interface.credit_status IS NOT NULL THEN
    IF igf_ap_gen.get_lookup_meaning('IGF_SL_CREDIT_STATUS',p_interface.credit_status) IS NULL THEN
      indx := indx + 1;
      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD','CREDIT_STATUS');
      p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get();
      p_status := FALSE;
    ELSE
      IF p_interface.loan_status_code = 'A' AND p_interface.credit_status = 'D' THEN
        indx := indx + 1;
        fnd_message.set_name('IGF','IGF_SL_DEC_LOAN_CRDT');
        p_igf_sl_msg_table(indx).msg_text := RPAD(l_error,12) || fnd_message.get();
        p_status := FALSE;
      END IF;
    END IF;
  END IF;

 EXCEPTION

   WHEN others THEN
   IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_li_imp_pkg.validate_loan_orig_int.exception','Exception: '||SQLERRM);
   END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.VALIDATE_LOAN_ORIG_INT');
   fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

   RAISE IMPORT_ERROR;

END validate_loan_orig_int;



PROCEDURE loans_insert_row(p_interface              IN c_interface%ROWTYPE,
                           p_award_id               IN NUMBER)
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Inserts legacy data into loans Table .
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
ln_rowid           ROWID;
BEGIN
ln_rowid   := NULL;

igf_sl_loans_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => ln_rowid,
      x_loan_id                           => ln_loan_id,
      x_award_id                          => p_award_id,
      x_seq_num                           => p_interface.loan_seq_num,
      x_loan_number                       => p_interface.loan_number_txt ,
      x_loan_per_begin_date               => p_interface.loan_per_begin_date,
      x_loan_per_end_date                 => p_interface.loan_per_end_date,
      x_loan_status                       => p_interface.loan_status_code,
      x_loan_status_date                  => p_interface.loan_status_date,
      x_loan_chg_status                   => p_interface.loan_chg_status,
      x_loan_chg_status_date              => p_interface.loan_chg_status_date,
      x_active                            => p_interface.active_flag,
      x_active_date                       => p_interface.active_date,
      x_borw_detrm_code                   => NULL,
      x_legacy_record_flag                => 'Y',
      x_external_loan_id_txt              => NULL
    );
EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.LOANS_INSERT_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;
END loans_insert_row;

PROCEDURE loans_orig_insert_row(p_interface              IN c_interface%ROWTYPE)
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Inserts legacy data into loans origination Table .
  ||  Change History :
  ||  Who             When            What
  -----------------------------------------------------------------------------------
    bkkumar    06-oct-2003     Bug 3104228 FA 122 Loans Enhancements
                           a) Impact of adding the relationship_cd
                           in igf_sl_lor_all table and obsoleting
                           BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
                           GUARANTOR_ID, DUNS_GUARNT_ID,
                           LENDER_ID, DUNS_LENDER_ID
                           LEND_NON_ED_BRC_ID, RECIPIENT_ID
                           RECIPIENT_TYPE,DUNS_RECIP_ID
                           RECIP_NON_ED_BRC_ID columns.
-----------------------------------------------------------------------------------
  ||  veramach   23-SEP-2003     Bug 3104228:
  ||                                      1. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
  ||                                      cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
  ||                                      p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
  ||                                      chg_batch_id,appl_send_error_codes from igf_sl_lor
  ||  (reverse chronological order - newest change first)
  */
ln_rowid           ROWID;
l_orig_status      VARCHAR2(1);
BEGIN
l_orig_status := NULL;
 IF p_interface.loan_status_code = 'A' THEN
    l_orig_status := 'B';
 END IF;

 ln_rowid   := NULL;
 igf_sl_lor_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => ln_rowid,
      X_origination_id                    => ln_origination_id,
      X_loan_id                           => ln_loan_id,
      X_sch_cert_date                     => p_interface.sch_cert_date,
      X_orig_status_flag                  => l_orig_status,
      X_orig_batch_id                     => p_interface.orig_send_batch_id_txt,
      X_orig_batch_date                   => p_interface.orig_batch_date,
      X_chg_batch_id                      => NULL,
      X_orig_ack_date                     => p_interface.orig_acknowledgement_date,
      X_credit_override                   => p_interface.credit_override_code,
      X_credit_decision_date              => p_interface.credit_decision_date,
      X_req_serial_loan_code              => NULL,
      X_act_serial_loan_code              => NULL,
      X_pnote_delivery_code               => NULL,
      X_pnote_status                      => p_interface.pnote_status_code,
      x_pnote_status_date                 => p_interface.pnote_accept_date,
      x_pnote_id                          => p_interface.pnote_id_txt,
      x_pnote_print_ind                   => p_interface.pnote_print_ind_code,
      x_pnote_accept_amt                  => p_interface.pnote_accept_amt,
      X_pnote_accept_date                 => p_interface.pnote_accept_date,
      X_unsub_elig_for_heal               => p_interface.unsub_elig_for_heal_code,
      x_disclosure_print_ind              => p_interface.disclosure_print_ind_code,
      x_orig_fee_perct                    => p_interface.orig_fee_perct_num,
      x_borw_confirm_ind                  => NULL,
      X_borw_interest_ind                 => NULL,
      X_borw_outstd_loan_code             => NULL,
      X_unsub_elig_for_depnt              => p_interface.unsub_elig_for_depnt_code,
      X_guarantee_amt                     => NULL,
      X_guarantee_date                    => NULL,
      X_guarnt_amt_redn_code              => NULL,
      X_guarnt_status_code                => NULL,
      X_guarnt_status_date                => NULL,
      X_lend_apprv_denied_code            => NULL,
      X_lend_apprv_denied_date            => NULL,
      X_lend_status_code                  => NULL,
      X_lend_status_date                  => NULL,
      X_guarnt_adj_ind                    => NULL,
      X_grade_level_code                  => p_interface.grade_level_code,
      X_enrollment_code                   => NULL,
      X_anticip_compl_date                => NULL,
      X_borw_lender_id                    => NULL,
      X_duns_borw_lender_id               => NULL,
      X_guarantor_id                      => NULL,
      X_duns_guarnt_id                    => NULL,
      X_prc_type_code                     => NULL,
      X_cl_seq_number                     => NULL,
      X_last_resort_lender                => NULL,
      X_lender_id                         => NULL,
      X_duns_lender_id                    => NULL,
      X_lend_non_ed_brc_id                => NULL,
      X_recipient_id                      => NULL,
      X_recipient_type                    => NULL,
      X_duns_recip_id                     => NULL,
      X_recip_non_ed_brc_id               => NULL,
      X_rec_type_ind                      => NULL,
      X_cl_loan_type                      => NULL,
      X_cl_rec_status                     => NULL,
      X_cl_rec_status_last_update         => NULL,
      X_alt_prog_type_code                => NULL,
      X_alt_appl_ver_code                 => NULL,
      X_mpn_confirm_code                  => NULL,
      X_resp_to_orig_code                 => NULL,
      X_appl_loan_phase_code              => NULL,
      X_appl_loan_phase_code_chg          => NULL,
      X_appl_send_error_codes             => NULL,
      X_tot_outstd_stafford               => NULL,
      X_tot_outstd_plus                   => NULL,
      X_alt_borw_tot_debt                 => NULL,
      X_act_interest_rate                 => NULL,
      X_service_type_code                 => NULL,
      X_rev_notice_of_guarnt              => NULL,
      X_sch_refund_amt                    => NULL,
      X_sch_refund_date                   => NULL,
      X_uniq_layout_vend_code             => NULL,
      X_uniq_layout_ident_code            => NULL,
      X_p_person_id                       => l_b_person_id,
      X_p_ssn_chg_date                    => NULL,
      X_p_dob_chg_date                    => NULL,
      X_p_permt_addr_chg_date             => NULL,
      X_p_default_status                  => p_interface.p_default_status_code,
      X_p_signature_code                  => NULL,
      X_p_signature_date                  => NULL,
      X_s_ssn_chg_date                    => NULL,
      X_s_dob_chg_date                    => NULL,
      X_s_permt_addr_chg_date             => NULL,
      X_s_local_addr_chg_date             => NULL,
      X_s_default_status                  => p_interface.s_default_status_code,
      X_s_signature_code                  => NULL,
      X_pnote_batch_id                    => p_interface.pnote_batch_seq_num_txt ,
      X_pnote_ack_date                    => p_interface.mpn_acknowledgement_date,
      X_pnote_mpn_ind                     => p_interface.pnote_indicator_code,
      X_elec_mpn_ind                      => p_interface.pnote_status_type,
      X_borr_sign_ind                     => NULL,
      X_stud_sign_ind                     => NULL,
      X_borr_credit_auth_code             => NULL,
      x_relationship_cd                   => NULL,
      x_interest_rebate_percent_num       => NULL,
      x_cps_trans_num                     => p_interface.transaction_num,
      x_atd_entity_id_txt                 => p_interface.atd_entity_id_txt,
      x_rep_entity_id_txt                 => p_interface.rep_entity_id_txt,
      x_crdt_decision_status              => p_interface.credit_status,
      x_note_message                      => NULL,
      x_book_loan_amt                     => NULL,
      x_book_loan_amt_date                => NULL,
      x_pymt_servicer_amt                 => NULL,
      x_pymt_servicer_date                => NULL,
      x_external_loan_id_txt              => NULL,
      x_alt_approved_amt                  => NULL,
      x_flp_approved_amt                  => NULL,
      x_fls_approved_amt                  => NULL,
      x_flu_approved_amt                  => NULL,
      x_guarantor_use_txt                 => NULL,
      x_lender_use_txt                    => NULL,
      x_loan_app_form_code                => NULL,
      x_reinstatement_amt                 => NULL,
      x_requested_loan_amt                => NULL,
      x_school_use_txt                    => NULL,
      x_deferment_request_code            => NULL,
      x_eft_authorization_code            => NULL,
      x_actual_record_type_code           => NULL,
      x_override_grade_level_code         => NULL,
      x_b_alien_reg_num_txt               => NULL,
      x_esign_src_typ_cd                  => NULL,
      x_acad_begin_date                   => NULL,
      x_acad_end_date                     => NULL);

EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.LOANS_ORIG_INSERT_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;
END loans_orig_insert_row;

PROCEDURE loans_orig_loc_insert_row(p_interface    IN c_interface%ROWTYPE,
                                    p_award_id     IN NUMBER,
                                    p_base_id      IN NUMBER,
                                    p_fed_fund     IN VARCHAR2)
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Inserts legacy data into loans origination loc Table .
  ||  Change History :
  ||  Who             When            What
  -----------------------------------------------------------------------------------
    pssahni    28-Oct-2004    Bug 3416863 FA149 COD-XML
                              Added columns x_award_id, x_base_id, x_document_id_txt,
                              x_loan_key_num, x_interest_rebate_percent_num, x_fin_award_year,
                              x_cps_trans_num, x_atd_entity_id_txt, x_rep_entity_id_txt,
                              x_source_entity_id_txt, x_pymt_servicer_amt, x_pymt_servicer_date,
                              x_book_loan_amt, x_book_loan_amt_date, x_s_chg_birth_date,
                              x_s_chg_ssn, x_s_chg_last_name, x_b_chg_birth_date, x_b_chg_ssn,
                              x_b_chg_last_name, x_note_message, x_full_resp_code, x_s_permt_county,
                              x_b_permt_county, x_s_permt_country, x_b_permt_country, x_crdt_decision_status
  -----------------------------------------------------------------------------------
    bkkumar    06-oct-2003     Bug 3104228 FA 122 Loans Enhancements
                             The DUNS_BORW_LENDER_ID
                             DUNS_GUARNT_ID
                             DUNS_LENDER_ID
                             DUNS_RECIP_ID columns are osboleted from the
                             igf_sl_lor_loc_all table.
-----------------------------------------------------------------------------------
  ||  veramach   23-SEP-2003     Bug 3104228:
  ||                                      1. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
  ||                                      cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
  ||                                      p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
  ||                                      chg_batch_id from igf_sl_lor _loc
  ||  veramach        16-SEP-2003     FA 122 loan enhancements
  ||                                  1. c_loan_dtls does not select borrower information from igf_sl_lor_dtls_v
  ||                                  2. igf_sl_gen.get_person_details is now used to get borrower information
  ||  (reverse chronological order - newest change first)
  */

CURSOR c_award_amt IS
SELECT offered_amt,
       accepted_amt
FROM   igf_aw_award_all
WHERE  award_id = p_award_id;

l_award_amt c_award_amt%ROWTYPE;

CURSOR c_loan_dtls(p_loan_id          NUMBER,
                   cp_origination_id   NUMBER) IS
      SELECT loans.row_id,
             loans.loan_id,
             lor.s_default_status,
             lor.p_default_status,
             lor.p_person_id,
             fabase.person_id student_id
      FROM   igf_sl_loans       loans,
             igf_sl_lor         lor,
             igf_aw_award       awd,
             igf_ap_fa_base_rec fabase
      WHERE  fabase.base_id   = awd.base_id
      AND    loans.award_id   = awd.award_id
      AND    loans.loan_id    = lor.loan_id
      AND    loans.loan_id    = p_loan_id;


loan_rec   c_loan_dtls%ROWTYPE;

student_dtl_rec igf_sl_gen.person_dtl_rec;
student_dtl_cur igf_sl_gen.person_dtl_cur;

parent_dtl_rec igf_sl_gen.person_dtl_rec;
parent_dtl_cur igf_sl_gen.person_dtl_cur;

CURSOR cur_isir_depend_status (cp_person_id NUMBER)
IS
    SELECT  isir.dependency_status
     FROM    igf_ap_fa_base_rec fabase,igf_ap_isir_matched isir
     WHERE   isir.base_id     =   fabase.base_id
     AND     isir.payment_isir = 'Y'
     AND     isir.system_record_type = 'ORIGINAL'
     AND     fabase.person_id =   cp_person_id;

  l_student_license   cur_isir_depend_status%ROWTYPE;

  ln_row_id                    ROWID;
  lv_p_permt_phone             igf_sl_lor_loc_all.s_permt_phone%TYPE;
  lv_s_permt_phone             igf_sl_lor_loc_all.s_permt_phone%TYPE;
  lv_s_license_number          igf_ap_isir_matched.driver_license_number%TYPE;
  lv_s_license_state           igf_ap_isir_matched.driver_license_state%TYPE;
  lv_s_citizenship_status      VARCHAR2(30);
  lv_alien_reg_num             igf_ap_isir_matched.alien_reg_number%TYPE;
  lv_dependency_status         igf_ap_isir_matched.dependency_status%TYPE;
  lv_s_legal_res_date          igf_ap_isir_matched.s_legal_resd_date%TYPE;
  lv_s_legal_res_state         igf_ap_isir_matched.s_state_legal_residence%TYPE;

BEGIN

ln_row_id := NULL;

 OPEN c_award_amt;
 FETCH c_award_amt INTO l_award_amt;
 CLOSE c_award_amt;

 OPEN c_loan_dtls(ln_loan_id,ln_origination_id);
 FETCH c_loan_dtls INTO loan_rec;
     igf_sl_gen.get_person_details(loan_rec.student_id,student_dtl_cur);
     FETCH student_dtl_cur INTO student_dtl_rec;
     igf_sl_gen.get_person_details(loan_rec.p_person_id,parent_dtl_cur);
     FETCH parent_dtl_cur INTO parent_dtl_rec;

     CLOSE c_loan_dtls;
     CLOSE student_dtl_cur;
     CLOSE parent_dtl_cur;

 OPEN cur_isir_depend_status(loan_rec.student_id);
 FETCH cur_isir_depend_status INTO   lv_dependency_status;
 CLOSE cur_isir_depend_status;

 lv_s_permt_phone  := igf_sl_gen.get_person_phone(loan_rec.student_id);
 lv_p_permt_phone  := igf_sl_gen.get_person_phone(loan_rec.p_person_id);

--Code added for bug 3603289 start
lv_s_license_number     := student_dtl_rec.p_license_num;
lv_s_license_state      := student_dtl_rec.p_license_state;
lv_s_citizenship_status := student_dtl_rec.p_citizenship_status;
lv_alien_reg_num        := student_dtl_rec.p_alien_reg_num;
lv_s_legal_res_date     := student_dtl_rec.p_legal_res_date;
lv_s_legal_res_state    := student_dtl_rec.p_state_of_legal_res;
--Code added for bug 3603289 end

 igf_sl_lor_loc_pkg.insert_row (
            x_mode                              => 'R',
            x_rowid                             => ln_row_id,
            x_loan_id                           => ln_loan_id,
            x_origination_id                    => ln_origination_id,
            x_loan_number                       => p_interface.loan_number_txt,
            x_loan_type                         => p_fed_fund,
            x_loan_amt_offered                  => l_award_amt.offered_amt ,
            x_loan_amt_accepted                 => l_award_amt.accepted_amt ,
            x_loan_per_begin_date               => p_interface.loan_per_begin_date,
            x_loan_per_end_date                 => p_interface.loan_per_end_date,
            x_acad_yr_begin_date                => NULL,
            x_acad_yr_end_date                  => NULL,
            x_loan_status                       => p_interface.loan_status_code,
            x_loan_status_date                  => p_interface.loan_status_date,
            x_loan_chg_status                   => p_interface.loan_chg_status,
            x_loan_chg_status_date              => p_interface.loan_chg_status_date,
            x_req_serial_loan_code              => NULL,
            x_act_serial_loan_code              => NULL,
            x_active                            => p_interface.active_flag,
            x_active_date                       => p_interface.active_date,
            x_sch_cert_date                     => p_interface.sch_cert_date,
            x_orig_status_flag                  => NULL,
            x_orig_batch_id                     => p_interface.orig_send_batch_id_txt,
            x_orig_batch_date                   => p_interface.orig_batch_date,
            x_chg_batch_id                      => NULL,
            x_orig_ack_date                     => p_interface.orig_acknowledgement_date,
            x_credit_override                   => p_interface.credit_override_code,
            x_credit_decision_date              => p_interface.credit_decision_date,
            x_pnote_delivery_code               => NULL,
            x_pnote_status                      => p_interface.pnote_status_code,
            x_pnote_status_date                 => NULL,
            x_pnote_id                          => p_interface.pnote_id_txt,
            x_pnote_print_ind                   => p_interface.pnote_print_ind_code,
            x_pnote_accept_amt                  => p_interface.pnote_accept_amt,
            x_pnote_accept_date                 => p_interface.pnote_accept_date      ,
            x_p_signature_code                  => NULL,
            x_p_signature_date                  => NULL,
            x_s_signature_code                  => NULL,
            x_unsub_elig_for_heal               => p_interface.unsub_elig_for_heal_code,
            x_disclosure_print_ind              => p_interface.disclosure_print_ind_code,
            x_orig_fee_perct                    => p_interface.orig_fee_perct_num,
            x_borw_confirm_ind                  => NULL,
            x_borw_interest_ind                 => NULL,
            x_unsub_elig_for_depnt              => p_interface.unsub_elig_for_depnt_code,
            x_guarantee_amt                     => NULL,
            x_guarantee_date                    => NULL,
            x_guarnt_adj_ind                    => NULL,
            x_guarnt_amt_redn_code              => NULL,
            x_guarnt_status_code                => NULL,
            x_guarnt_status_date                => NULL,
            x_lend_apprv_denied_code            => NULL,
            x_lend_apprv_denied_date            => NULL,
            x_lend_status_code                  => NULL,
            x_lend_status_date                  => NULL,
            x_grade_level_code                  => p_interface.grade_level_code,
            x_enrollment_code                   => NULL,
            x_anticip_compl_date                => NULL,
            x_borw_lender_id                    => NULL,
            x_duns_borw_lender_id               => NULL,
            x_guarantor_id                      => NULL,
            x_duns_guarnt_id                    => NULL,
            x_prc_type_code                     => NULL,
            x_rec_type_ind                      => NULL,
            x_cl_loan_type                      => NULL,
            x_cl_seq_number                     => NULL,
            x_last_resort_lender                => NULL,
            x_lender_id                         => NULL,
            x_duns_lender_id                    => NULL,
            x_lend_non_ed_brc_id                => NULL,
            x_recipient_id                      => NULL,
            x_recipient_type                    => NULL,
            x_duns_recip_id                     => NULL,
            x_recip_non_ed_brc_id               => NULL,
            x_cl_rec_status                     => NULL,
            x_cl_rec_status_last_update         => NULL,
            x_alt_prog_type_code                => NULL,
            x_alt_appl_ver_code                 => NULL,
            x_borw_outstd_loan_code             => NULL,
            x_mpn_confirm_code                  => NULL,
            x_resp_to_orig_code                 => NULL,
            x_appl_loan_phase_code              => NULL,
            x_appl_loan_phase_code_chg          => NULL,
            x_tot_outstd_stafford               => NULL,
            x_tot_outstd_plus                   => NULL,
            x_alt_borw_tot_debt                 => NULL,
            x_act_interest_rate                 => NULL,
            x_service_type_code                 => NULL,
            x_rev_notice_of_guarnt              => NULL,
            x_sch_refund_amt                    => NULL,
            x_sch_refund_date                   => NULL,
            x_uniq_layout_vend_code             => NULL,
            x_uniq_layout_ident_code            => NULL,
            x_p_person_id                       => loan_rec.p_person_id,
            x_p_ssn                             => SUBSTR(parent_dtl_rec.p_ssn,1,9),
            x_p_ssn_chg_date                    => NULL,
            x_p_last_name                       => parent_dtl_rec.p_last_name,
            x_p_first_name                      => parent_dtl_rec.p_first_name,
            x_p_middle_name                     => parent_dtl_rec.p_middle_name,
            x_p_permt_addr1                     => parent_dtl_rec.p_permt_addr1,
            x_p_permt_addr2                     => parent_dtl_rec.p_permt_addr2,
            x_p_permt_city                      => parent_dtl_rec.p_permt_city,
            x_p_permt_state                     => parent_dtl_rec.p_permt_state,
            x_p_permt_zip                       => parent_dtl_rec.p_permt_zip,
            x_p_permt_addr_chg_date             => NULL,
            x_p_permt_phone                     => lv_p_permt_phone,
            x_p_email_addr                      => parent_dtl_rec.p_email_addr,
            x_p_date_of_birth                   => parent_dtl_rec.p_date_of_birth,
            x_p_dob_chg_date                    => NULL,
            x_p_license_num                     => parent_dtl_rec.p_license_num,
            x_p_license_state                   => parent_dtl_rec.p_license_state,
            x_p_citizenship_status              => parent_dtl_rec.p_citizenship_status,
            x_p_alien_reg_num                   => parent_dtl_rec.p_alien_reg_num,
            x_p_default_status                  => loan_rec.p_default_status,
            x_p_foreign_postal_code             => NULL,
            x_p_state_of_legal_res              => parent_dtl_rec.p_state_of_legal_res,
            x_p_legal_res_date                  => parent_dtl_rec.p_legal_res_date,
            x_s_ssn                             => SUBSTR(student_dtl_rec.p_ssn,1,9),
            x_s_ssn_chg_date                    => NULL,
            x_s_last_name                       => student_dtl_rec.p_last_name,
            x_s_first_name                      => student_dtl_rec.p_first_name,
            x_s_middle_name                     => student_dtl_rec.p_middle_name,
            x_s_permt_addr1                     => student_dtl_rec.p_permt_addr1,
            x_s_permt_addr2                     => student_dtl_rec.p_permt_addr2,
            x_s_permt_city                      => student_dtl_rec.p_permt_city,
            x_s_permt_state                     => student_dtl_rec.p_permt_state,
            x_s_permt_zip                       => student_dtl_rec.p_permt_zip,
            x_s_permt_addr_chg_date             => NULL,
            x_s_permt_phone                     => lv_s_permt_phone,
            x_s_local_addr1                     => student_dtl_rec.p_local_addr1,
            x_s_local_addr2                     => student_dtl_rec.p_local_addr2,
            x_s_local_city                      => student_dtl_rec.p_local_city,
            x_s_local_state                     => student_dtl_rec.p_local_state,
            x_s_local_zip                       => student_dtl_rec.p_local_zip,
            x_s_local_addr_chg_date             => NULL,
            x_s_email_addr                      => student_dtl_rec.p_email_addr,
            x_s_date_of_birth                   => student_dtl_rec.p_date_of_birth,
            x_s_dob_chg_date                    => NULL,
            x_s_license_num                     => lv_s_license_number,
            x_s_license_state                   => lv_s_license_state,
            x_s_depncy_status                   => lv_dependency_status,
            x_s_default_status                  => p_interface.s_default_status_code,
            x_s_citizenship_status              => lv_s_citizenship_status,
            x_s_alien_reg_num                   => lv_alien_reg_num,
            x_s_foreign_postal_code             => NULL,
            x_pnote_batch_id                    => p_interface.pnote_batch_seq_num_txt,
            x_pnote_ack_date                    => p_interface.mpn_acknowledgement_date,
            x_pnote_mpn_ind                     => p_interface.pnote_indicator_code,
            x_award_id                          => p_award_id,
            x_base_id                           => p_base_id,
            x_document_id_txt                   => NULL,
            x_loan_key_num                      => NULL,
            x_interest_rebate_percent_num       => NULL,
            x_fin_award_year                    => NULL,
            x_cps_trans_num                     => p_interface.transaction_num,
            x_atd_entity_id_txt                 => p_interface.atd_entity_id_txt,
            x_rep_entity_id_txt                 => p_interface.rep_entity_id_txt,
            x_source_entity_id_txt              => NULL,
            x_pymt_servicer_amt                 => NULL,
            x_pymt_servicer_date                => NULL,
            x_book_loan_amt                     => NULL,
            x_book_loan_amt_date                => NULL,
            x_s_chg_birth_date                  => NULL,
            x_s_chg_ssn                         => NULL,
            x_s_chg_last_name                   => NULL,
            x_b_chg_birth_date                  => NULL,
            x_b_chg_ssn                         => NULL,
            x_b_chg_last_name                   => NULL,
            x_note_message                      => NULL,
            x_full_resp_code                    => NULL,
            x_s_permt_county                    => NULL,
            x_b_permt_county                    => NULL,
            x_s_permt_country                   => NULL,
            x_b_permt_country                   => NULL,
            x_crdt_decision_status              => p_interface.credit_status,
            x_external_loan_id_txt              => NULL,
            x_alt_approved_amt                  => NULL,
            x_flp_approved_amt                  => NULL,
            x_fls_approved_amt                  => NULL,
            x_flu_approved_amt                  => NULL,
            x_guarantor_use_txt                 => NULL,
            x_lender_use_txt                    => NULL,
            x_loan_app_form_code                => NULL,
            x_reinstatement_amt                 => NULL,
            x_requested_loan_amt                => NULL,
            x_school_use_txt                    => NULL,
            x_deferment_request_code            => NULL,
            x_eft_authorization_code            => NULL,
            x_actual_record_type_code           => NULL,
            x_alt_borrower_ind_flag             => NULL,
            x_borower_credit_authoriz_flag      => NULL,
            x_borower_electronic_sign_flag      => NULL,
            x_cost_of_attendance_amt            => NULL,
            x_established_fin_aid_amount        => NULL,
            x_expect_family_contribute_amt      => NULL,
            x_mpn_type_flag                     => p_interface.pnote_status_type,
            x_school_id_txt                     => NULL,
            x_student_electronic_sign_flag      => NULL,
	    x_esign_src_typ_cd                  => NULL);


EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.LOANS_ORIG_LOC_INSERT_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;

END loans_orig_loc_insert_row;

PROCEDURE lor_resp_insert_row(p_interface    IN c_interface%ROWTYPE)
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Inserts legacy data into loans origination response Table .
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
ln_rowid            ROWID;

BEGIN

ln_rowid        := NULL;
igf_sl_dl_lor_resp_pkg.insert_row (
              x_mode                              => 'R',
              x_rowid                             => ln_rowid,
              x_lor_resp_num                      => ln_lor_resp_num,
              x_dbth_id                           => ln_dbth_id,
              x_orig_batch_id                     => p_interface.orig_send_batch_id_txt,
              x_loan_number                       => p_interface.loan_number_txt ,
              x_orig_ack_date                     => p_interface.orig_acknowledgement_date ,
              x_orig_status_flag                  => p_interface.loan_status_code ,
              x_orig_reject_reasons               => p_interface.orig_reject_code,
              x_pnote_status                      => p_interface.pnote_status_code,
              x_pnote_id                          => p_interface.pnote_id_txt,
              x_pnote_accept_amt                  => p_interface.pnote_accept_amt,
              x_loan_amount_accepted              => p_interface.loan_approved_amt,
              x_status                            => 'Y',
              x_elec_mpn_ind                      => p_interface.pnote_status_type
             );
EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.LOR_RESP_INSERT_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;

END lor_resp_insert_row;

PROCEDURE lor_crresp_insert_row(p_interface    IN c_interface%ROWTYPE)
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Inserts legacy data into igf_sl_dl_lor_crresp Table .
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
ln_rowid            ROWID;

BEGIN
ln_rowid        := NULL;

igf_sl_dl_lor_crresp_pkg.insert_row (
              x_mode                              => 'R',
              x_rowid                             => ln_rowid,
              X_lor_resp_num                      => ln_lor_resp_num,
              X_dbth_id                           => ln_dbth_id,
              X_loan_number                       => p_interface.loan_number_txt,
              X_credit_override                   => p_interface.credit_override_code,
              X_credit_decision_date              => p_interface.credit_decision_date,
              X_status                            => 'Y' ,
              x_endorser_amount                   => p_interface.pnote_accept_amt,
              x_mpn_status                        => p_interface.pnote_status_code,
              x_mpn_id                            => p_interface.pnote_id_txt,
              x_mpn_type                          => p_interface.pnote_status_type,
              x_mpn_indicator                     => p_interface.pnote_indicator_code
             );
EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.LOR_CRRESP_INSERT_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;

END lor_crresp_insert_row;

PROCEDURE pnote_resp_insert_row (p_interface    IN c_interface%ROWTYPE)
AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Inserts legacy data into igf_sl_dl_pnote_resp Table .
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
ln_rowid            ROWID;
ln_dlpnr_id         NUMBER;
BEGIN
ln_rowid        := NULL;
ln_dlpnr_id     := NULL;
igf_sl_dl_pnote_resp_pkg.insert_row (
    x_rowid                     => ln_rowid,
    x_dlpnr_id                  => ln_dlpnr_id,
    x_dbth_id                   => ln_dbth_id,
    x_pnote_ack_date            => p_interface.pnote_accept_date,
    x_pnote_batch_id            => p_interface.pnote_id_txt,
    x_loan_number               => p_interface.loan_number_txt,
    x_pnote_status              => p_interface.pnote_status_code,
    x_pnote_rej_codes           => p_interface.orig_reject_code,
    x_mpn_ind                   => p_interface.pnote_indicator_code,
    x_pnote_accept_amt          => p_interface.pnote_accept_amt,
    x_status                    => 'Y',
    x_mode                      => 'R',
    x_elec_mpn_ind              => p_interface.pnote_status_type);
EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.PNOTE_RESP_INSERT_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;

END pnote_resp_insert_row;

PROCEDURE pnote_insert_row(p_interface    IN c_interface%ROWTYPE,
                           p_award_id     IN NUMBER)
AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Inserts legacy data into igf_sl_dl_pnote_p_p_all Table .
  ||  Change History :
  ||  Who             When            What
  ||  veramach        16-SEP-2003     FA 122 loan enhancements
  ||                                  1. c_loan_dtls does not select borrower information from igf_sl_lor_dtls_v
  ||                                  2. igf_sl_gen.get_person_details is now used to get borrower information
  ||  (reverse chronological order - newest change first)
  */
CURSOR c_award_amt IS
SELECT offered_amt,
       accepted_amt
FROM   igf_aw_award_all
WHERE  award_id = p_award_id;

l_award_amt c_award_amt%ROWTYPE;

CURSOR c_loan_dtls(p_loan_id          NUMBER,
                   cp_origination_id   NUMBER) IS
      SELECT loans.row_id,
             loans.loan_id,
             lor.s_default_status,
             lor.p_default_status,
             lor.p_person_id,
             fabase.person_id student_id
      FROM   igf_sl_loans       loans,
             igf_sl_lor         lor,
             igf_aw_award       awd,
             igf_ap_fa_base_rec fabase
      WHERE  fabase.base_id    = awd.base_id
      AND    loans.award_id    = awd.award_id
      AND    loans.loan_id     = lor.loan_id
      AND    loans.loan_id     = p_loan_id;

loan_rec   c_loan_dtls%ROWTYPE;

student_dtl_rec igf_sl_gen.person_dtl_rec;
student_dtl_cur igf_sl_gen.person_dtl_cur;

parent_dtl_rec igf_sl_gen.person_dtl_rec;
parent_dtl_cur igf_sl_gen.person_dtl_cur;

CURSOR cur_isir_depend_status (cp_person_id NUMBER)
IS
    SELECT   isir.dependency_status
     FROM    igf_ap_fa_base_rec fabase,igf_ap_isir_matched isir
     WHERE   isir.base_id     =   fabase.base_id
     AND     isir.payment_isir = 'Y'
     AND     isir.system_record_type = 'ORIGINAL'
     AND     fabase.person_id =   cp_person_id;

  l_student_license   cur_isir_depend_status%ROWTYPE;

  ln_rowid         ROWID;
  ln_pnpp_id       NUMBER;
  lv_p_permt_phone             igf_sl_lor_loc_all.s_permt_phone%TYPE;
  lv_s_permt_phone             igf_sl_lor_loc_all.s_permt_phone%TYPE;
  lv_s_license_number          igf_ap_isir_matched.driver_license_number%TYPE;
  lv_s_license_state           igf_ap_isir_matched.driver_license_state%TYPE;
  lv_s_citizenship_status      VARCHAR2(30);
  lv_alien_reg_num             igf_ap_isir_matched.alien_reg_number%TYPE;
  --
  lv_dependency_status         igf_ap_isir_matched.dependency_status%TYPE;
  lv_s_legal_res_date          igf_ap_isir_matched.s_legal_resd_date%TYPE;
  lv_s_legal_res_state         igf_ap_isir_matched.s_state_legal_residence%TYPE;


BEGIN

  ln_rowid          := NULL;
  ln_pnpp_id        := NULL;

 OPEN c_award_amt;
 FETCH c_award_amt INTO l_award_amt;
 CLOSE c_award_amt;

 OPEN  c_loan_dtls(ln_loan_id,ln_origination_id);
 FETCH c_loan_dtls INTO loan_rec;
 igf_sl_gen.get_person_details(loan_rec.student_id,student_dtl_cur);
 FETCH student_dtl_cur INTO student_dtl_rec;
 igf_sl_gen.get_person_details(loan_rec.p_person_id,parent_dtl_cur);
 FETCH parent_dtl_cur INTO parent_dtl_rec;

 CLOSE c_loan_dtls;
 CLOSE student_dtl_cur;
 CLOSE parent_dtl_cur;

 OPEN cur_isir_depend_status(loan_rec.student_id);
 FETCH cur_isir_depend_status INTO   lv_dependency_status;
 CLOSE cur_isir_depend_status;

 lv_s_permt_phone  := igf_sl_gen.get_person_phone(loan_rec.student_id);
 lv_p_permt_phone  := igf_sl_gen.get_person_phone(loan_rec.p_person_id);

--Code added for bug 3603289 start
lv_s_license_number     := student_dtl_rec.p_license_num;
lv_s_license_state      := student_dtl_rec.p_license_state;
lv_s_citizenship_status := student_dtl_rec.p_citizenship_status;
lv_alien_reg_num        := student_dtl_rec.p_alien_reg_num;
lv_s_legal_res_date     := student_dtl_rec.p_legal_res_date;
lv_s_legal_res_state    := student_dtl_rec.p_state_of_legal_res;
--Code added for bug 3603289 end

 igf_sl_dl_pnote_p_p_pkg.insert_row(
                   x_mode                           => 'R',
                   x_rowid                          => ln_rowid,
                   x_pnpp_id                        => ln_pnpp_id,
                   x_batch_seq_num                  => ln_dbth_id ,
                   x_loan_id                        => ln_loan_id,
                   x_loan_number                    => p_interface.loan_number_txt ,
                   x_loan_amt_offered               => l_award_amt.offered_amt,
                   x_loan_amt_accepted              => l_award_amt.accepted_amt,
                   x_loan_per_begin_date            => p_interface.loan_per_begin_date,
                   x_loan_per_end_date              => p_interface.loan_per_end_date ,
                   x_person_id                      => loan_rec.student_id,
                   x_s_ssn                          => SUBSTR(student_dtl_rec.p_ssn,1,9),
                   x_s_first_name                   => student_dtl_rec.p_first_name,
                   x_s_last_name                    => student_dtl_rec.p_last_name,
                   x_s_middle_name                  => student_dtl_rec.p_middle_name,
                   x_s_date_of_birth                => student_dtl_rec.p_date_of_birth,
                   x_s_citizenship_status           => loan_rec.s_default_status,
                   x_s_alien_reg_number             => lv_alien_reg_num,
                   x_s_license_num                  => lv_s_license_number,
                   x_s_license_state                => lv_s_license_state,
                   x_s_permt_addr1                  => student_dtl_rec.p_permt_addr1,
                   x_s_permt_addr2                  => student_dtl_rec.p_permt_addr2,
                   x_s_permt_city                   => student_dtl_rec.p_permt_city,
                   x_s_permt_state                  => student_dtl_rec.p_permt_state,
                   x_s_permt_province               => NULL,
                   x_s_permt_county                 => NULL,
                   x_s_permt_country                => NULL,
                   x_s_permt_zip                    => student_dtl_rec.p_permt_zip,
                   x_s_email_addr                   => student_dtl_rec.p_email_addr,
                   x_s_phone                        => lv_s_permt_phone,
                   x_p_person_id                    => loan_rec.p_person_id,
                   x_p_ssn                          => SUBSTR(parent_dtl_rec.p_ssn,1,9),
                   x_p_last_name                    => parent_dtl_rec.p_last_name,
                   x_p_first_name                   => parent_dtl_rec.p_first_name,
                   x_p_middle_name                  => parent_dtl_rec.p_middle_name,
                   x_p_date_of_birth                => parent_dtl_rec.p_date_of_birth,
                   x_p_citizenship_status           => parent_dtl_rec.p_citizenship_status,
                   x_p_alien_reg_num                => parent_dtl_rec.p_alien_reg_num,
                   x_p_license_num                  => parent_dtl_rec.p_license_num,
                   x_p_license_state                => parent_dtl_rec.p_license_state,
                   x_p_permt_addr1                  => parent_dtl_rec.p_permt_addr1,
                   x_p_permt_addr2                  => parent_dtl_rec.p_permt_addr2,
                   x_p_permt_city                   => parent_dtl_rec.p_permt_city,
                   x_p_permt_state                  => parent_dtl_rec.p_permt_state,
                   x_p_permt_province               => NULL,
                   x_p_permt_county                 => NULL,
                   x_p_permt_country                => NULL,
                   x_p_permt_zip                    => parent_dtl_rec.p_permt_zip,
                   x_p_email_addr                   => parent_dtl_rec.p_email_addr,
                   x_p_phone                        => lv_p_permt_phone,
                   x_status                         => 'Y'
                 );
EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.PNOTE_INSERT_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;

END pnote_insert_row;


PROCEDURE disb_resp_insert_row(p_disb_interface  c_disb_interface%ROWTYPE)
AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Inserts legacy data into igf_db_dl_disb_resp_all Table .
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
 ln_rowid    ROWID;
 ln_ddrp_id  NUMBER;

BEGIN

 ln_rowid   := NULL;
 ln_ddrp_id := NULL;

 igf_db_dl_disb_resp_pkg.insert_row (
                           x_mode                   => 'R',
                           x_rowid                  => ln_rowid,
                           x_ddrp_id                => ln_ddrp_id,
                           x_dbth_id                => ln_dbth_id,
                           x_loan_number            => p_disb_interface.loan_number_txt,
                           x_disb_num               => p_disb_interface.disbursement_num,
                           x_disb_activity          => p_disb_interface.disbursement_activity_code,
                           x_transaction_date       => p_disb_interface.disbursement_date,
                           x_disb_seq_num           => p_disb_interface.disbursement_seq_num ,
                           x_disb_gross_amt         => p_disb_interface.gross_disbursement_amt,
                           x_fee_1                  => p_disb_interface.loc_fee_1_amt,
                           x_disb_net_amt           => p_disb_interface.gross_disbursement_amt - p_disb_interface.loc_fee_1_amt + p_disb_interface.loc_int_rebate_amt,
                           x_int_rebate_amt         => p_disb_interface.loc_int_rebate_amt,
                           x_user_ident             => p_disb_interface.user_identifier_txt,
                           x_disb_batch_id          => p_disb_interface.disbursement_batch_id_txt,
                           x_school_id              => p_disb_interface.school_code_txt,
                           x_sch_code_status        => NULL,
                           x_loan_num_status        => NULL,
                           x_disb_num_status        => NULL,
                           x_disb_activity_status   => p_disb_interface.disbursement_activity_st_txt,
                           x_trans_date_status      => NULL,
                           x_disb_seq_num_status    => NULL,
                           x_loc_disb_gross_amt     => p_disb_interface.loc_disbursement_gross_amt,
                           x_loc_fee_1              => p_disb_interface.loc_fee_1_amt,
                           x_loc_disb_net_amt       => p_disb_interface.loc_disbursement_net_amt,
                           x_servicer_refund_amt    => p_disb_interface.servicer_refund_amt,
                           x_loc_int_rebate_amt     => p_disb_interface.loc_int_rebate_amt,
                           x_loc_net_booked_loan    => p_disb_interface.loc_net_booked_loan_amt,
                           x_ack_date               => p_disb_interface.acknowledgement_date,
                           x_affirm_flag            => p_disb_interface.confirmation_flag,
                           x_status                 => 'N'
                           );
EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.DISB_RESP_INSERT_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;

END disb_resp_insert_row;

PROCEDURE db_awd_disb_update_row(l_disb_interface  IN c_disb_interface%ROWTYPE,
                               p_award_id        IN NUMBER)
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Updates legacy data into igf_db_awd_disb_dtl Table .
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
ln_rowid    ROWID;
ln_ddrp_id  NUMBER;

CURSOR c_disb_det (cp_disb_num              NUMBER,
                   cp_DISBURSEMENT_SEQ_NUM  VARCHAR2)
IS
SELECT ROWID,adisb.*
FROM   IGF_DB_AWD_DISB_DTL_ALL adisb
WHERE  adisb.award_id     =  p_award_id
AND    adisb.disb_num     =  cp_disb_num
AND    adisb.disb_seq_num =  cp_disbursement_seq_num;
l_rec_disb_dtl   c_disb_det%ROWTYPE;

l_disb_status  igf_db_awd_disb_dtl_all.disb_status%TYPE;
BEGIN

 ln_rowid   := NULL;
 ln_ddrp_id := NULL;
 l_disb_status := NULL;

 OPEN c_disb_det(l_disb_interface.disbursement_num,l_disb_interface.DISBURSEMENT_SEQ_NUM );
 FETCH c_disb_det INTO l_rec_disb_dtl;
 CLOSE c_disb_det;

 IF l_disb_interface.disbursement_activity_st_txt IS NULL THEN
    l_disb_status := 'A';
 ELSE
    l_disb_status := 'R';
 END IF;

 igf_db_awd_disb_dtl_pkg.update_row(    x_rowid               => l_rec_disb_dtl.rowid,
                                        x_award_id            => l_rec_disb_dtl.award_id,
                                        x_disb_num            => l_rec_disb_dtl.disb_num,
                                        x_disb_seq_num        => l_rec_disb_dtl.disb_seq_num,
                                        x_disb_gross_amt      => l_disb_interface.gross_disbursement_amt,
                                        x_fee_1               => l_disb_interface.loc_fee_1_amt,
                                        x_fee_2               => l_rec_disb_dtl.fee_2,
                                        x_disb_net_amt        => l_disb_interface.loc_disbursement_net_amt,
                                        x_disb_adj_amt        => l_rec_disb_dtl.disb_adj_amt,
                                        x_disb_date           => l_disb_interface.disbursement_date,
                                        x_fee_paid_1          => l_rec_disb_dtl.fee_paid_1,
                                        x_fee_paid_2          => l_rec_disb_dtl.fee_paid_2,
                                        x_disb_activity       => l_disb_interface.disbursement_activity_code,
                                        x_disb_batch_id       => l_disb_interface.disbursement_batch_id_txt,
                                        x_disb_ack_date       => l_disb_interface.acknowledgement_date,
                                        x_booking_batch_id    => l_disb_interface.booking_batch_id_txt,
                                        x_booked_date         => l_disb_interface.booked_date,
                                        x_disb_status         => l_disb_status,
                                        x_disb_status_date    => l_disb_interface.disbursement_activity_date,
                                        x_sf_status           => l_rec_disb_dtl.sf_status,
                                        x_sf_status_date      => l_rec_disb_dtl.sf_status_date,
                                        x_sf_invoice_num      => l_rec_disb_dtl.sf_invoice_num,
                                        x_sf_credit_id        => l_rec_disb_dtl.sf_credit_id,
                                        x_spnsr_credit_id     => l_rec_disb_dtl.spnsr_credit_id,
                                        x_spnsr_charge_id     => l_rec_disb_dtl.spnsr_charge_id,
                                        x_error_desc          => l_rec_disb_dtl.error_desc,
                                        x_mode                => 'R' ,
                                        x_notification_date   => l_rec_disb_dtl.notification_date,
                                        x_interest_rebate_amt => l_rec_disb_dtl.interest_rebate_amt,
					x_ld_cal_type         => l_rec_disb_dtl.ld_cal_type,
					x_ld_sequence_number  => l_rec_disb_dtl.ld_sequence_number
                                      );
EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.DB_AWD_DISB_UPDATE_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;

END db_awd_disb_update_row;

PROCEDURE dl_chg_send_insert_row (p_chg_interface  c_chg_interface%ROWTYPE )
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Inserts legacy data into igf_sl_dl_chg_send Table .
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
ln_rowid     ROWID;
ln_chg_num   NUMBER;

BEGIN
  ln_rowid    := NULL;
  ln_chg_num  := NULL;
  igf_sl_dl_chg_send_pkg.insert_row (
                           x_mode                              => 'R',
                           x_rowid                             => ln_rowid,
                           X_chg_num                           => ln_chg_num,
                           X_dbth_id                           => ln_dbth_id,
                           X_loan_number                       => p_chg_interface.LOAN_NUMBER_TXT,
                           X_chg_code                          => p_chg_interface.CHANGE_CODE,
                           X_new_value                         => p_chg_interface.NEW_VALUE_TXT,
                           X_status                            => 'S'
                                                    );

EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.DL_CHG_SEND_INSERT_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;

END dl_chg_send_insert_row;

PROCEDURE dl_chg_resp_insert_row (p_chg_interface  c_chg_interface%ROWTYPE )
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Inserts legacy data into igf_sl_dl_chg_resp Table .
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
 ln_rowid     ROWID;
 ln_resp_num  NUMBER;

 BEGIN
 ln_rowid    := NULL;
 ln_resp_num := NULL;

 igf_sl_dl_chg_resp_pkg.insert_row (
                     x_mode                     => 'R',
                     x_rowid                    => ln_rowid,
                     X_resp_num                 => ln_resp_num,
                     X_dbth_id                  => ln_dbth_id,
                     X_batch_id                 => p_chg_interface.SEND_BATCH_ID_TXT,
                     X_loan_number              => p_chg_interface.LOAN_NUMBER_TXT,
                     X_chg_code                 => p_chg_interface.CHANGE_CODE,
                     X_reject_code              => p_chg_interface.REJECT_CODE,
                     X_new_value                => p_chg_interface.NEW_VALUE_TXT,
                     X_loan_ident_err_code      => p_chg_interface.LOAN_IDENT_ERR_CODE,
                     X_status                   => 'N'
                   );
 EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.DL_CHG_RESP_INSERT_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;

 END dl_chg_resp_insert_row;

 PROCEDURE dl_batch_insert_row(p_interface    IN c_interface%ROWTYPE)
 AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    : Inserts legacy data into igf_sl_dl_batch Table .
  ||  Change History :
  ||  Who             When            What
  ||  bvisvana        24-Aug-2006     Bug 5478287 - Extending batch creation for 2006 and 2007
  ||  (reverse chronological order - newest change first)
  */
  ln_rowid                ROWID;
  l_value                 VARCHAR2(23);
  l_batch_type            VARCHAR2(20);
  l_cycle_ind             VARCHAR2(20);
  l_sl_code               VARCHAR2(20);
  l_dt_btch_created       VARCHAR2(20);
  l_tm_btch_created       VARCHAR2(20);

  CURSOR c_message_class (p_batch_type    VARCHAR2,
                          p_cycle_year    VARCHAR2,
                          p_message_class igf_sl_dl_file_type.message_class%TYPE
                         )
  IS
  SELECT message_class
  FROM   igf_sl_dl_file_type
  WHERE  batch_type   =  p_batch_type
  AND    cycle_year   =  p_cycle_year
  AND    message_class LIKE p_message_class;

  l_message_class c_message_class%ROWTYPE;

 BEGIN
  ln_dbth_id        := NULL;
  l_value           := p_interface.ORIG_SEND_BATCH_ID_TXT;
  l_batch_type      := SUBSTR(l_value,1,2);
  l_cycle_ind       := SUBSTR(l_value,3,1);
  l_sl_code         := SUBSTR(l_value,4,6);
  l_dt_btch_created := SUBSTR(l_value,10,8);
  l_tm_btch_created := SUBSTR(l_value,18,6);

  IF l_cycle_ind = '3' THEN
    OPEN  c_message_class(l_batch_type,'2003','%OP');
    FETCH c_message_class INTO l_message_class;
    CLOSE c_message_class;
  ELSIF l_cycle_ind = '4' THEN
    OPEN c_message_class(l_batch_type,'2004','%OP');
    FETCH c_message_class INTO l_message_class;
    CLOSE c_message_class;
  ELSIF l_cycle_ind = '5' THEN
    OPEN c_message_class(l_batch_type,'2005','%OP');
    FETCH c_message_class INTO l_message_class;
    CLOSE c_message_class;
  -- Bug 5478287
  ELSIF l_cycle_ind = '6' THEN
    OPEN c_message_class(l_batch_type,'2006','%OP');
    FETCH c_message_class INTO l_message_class;
    CLOSE c_message_class;
  ELSIF l_cycle_ind = '7' THEN
    OPEN c_message_class(l_batch_type,'2007','%OP');
    FETCH c_message_class INTO l_message_class;
    CLOSE c_message_class;
  END IF;

  igf_sl_dl_batch_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => ln_rowid,
      x_dbth_id                           => ln_dbth_id,
      x_batch_id                          => p_interface.ORIG_SEND_BATCH_ID_TXT,
      x_message_class                     => l_message_class.message_class,
      x_bth_creation_date                 => TO_DATE(l_dt_btch_created,'YYYYMMDD'),
      x_batch_rej_code                    => NULL,
      x_end_date                          => NULL,
      x_batch_type                        => l_batch_type,
      x_send_resp                         => 'R',
      x_status                            => 'N');

 EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.DL_BATCH_INSERT_ROW');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;

 END dl_batch_insert_row;

PROCEDURE delete_context_records(p_loan_id   igf_sl_loans_all.loan_id%TYPE,
                                 p_loan_num  igf_sl_loans_all.loan_number%TYPE,
                                 p_rowid     ROWID)

AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c_lor(cp_loan_id NUMBER)
    IS
    SELECT rowid, origination_id
    FROM igf_sl_lor_all
    WHERE loan_id = cp_loan_id;

    l_lor c_lor%ROWTYPE;

    CURSOR c_pnote_hist(cp_loan_id NUMBER)
    IS
    SELECT ROWID
    FROM igf_sl_pnote_stat_h
    WHERE loan_id = cp_loan_id;

    l_pnote_hist  c_pnote_hist%ROWTYPE;

    CURSOR c_pnote(cp_loan_id NUMBER)
    IS
    SELECT ROWID
    FROM igf_sl_dl_pnote_p_p_all
    WHERE loan_id = cp_loan_id;

    l_pnote  c_pnote%ROWTYPE;

    CURSOR c_lor_loc(cp_orig_id NUMBER)
    IS
    SELECT rowid
    FROM igf_sl_lor_loc_all
    WHERE origination_id = cp_orig_id;

    l_lor_loc c_lor_loc%ROWTYPE;

    CURSOR c_disb_resp(cp_loan_number VARCHAR2)
    IS
    SELECT rowid
    FROM igf_db_dl_disb_resp_all
    WHERE loan_number = cp_loan_number;

    l_disb_resp c_disb_resp%ROWTYPE;

     CURSOR c_lor_crresp(cp_loan_number VARCHAR2)
    IS
    SELECT rowid,dbth_id
    FROM igf_sl_dl_lor_crresp_all
    WHERE loan_number = cp_loan_number;

    l_lor_crresp c_lor_crresp%ROWTYPE;
    CURSOR c_lor_resp(cp_loan_number VARCHAR2)
    IS
    SELECT rowid,dbth_id
    FROM igf_sl_dl_lor_resp_all
    WHERE loan_number = cp_loan_number;

    l_lor_resp  c_lor_resp%ROWTYPE;

    CURSOR c_pnote_resp(cp_loan_number VARCHAR2)
    IS
    SELECT rowid,dbth_id,dlpnr_id
    FROM igf_sl_dl_pnote_resp_all
    WHERE loan_number = cp_loan_number;

    l_pnote_resp  c_pnote_resp%ROWTYPE;

    CURSOR c_dl_chg_send (p_loan_number VARCHAR2)
    IS
    SELECT ROWID
    FROM igf_sl_dl_chg_send
    WHERE loan_number = p_loan_number;

    l_dl_chg_send  c_dl_chg_send%ROWTYPE;

    CURSOR c_dl_chg_resp (p_loan_number VARCHAR2)
    IS
    SELECT ROWID
    FROM igf_sl_dl_chg_resp_all
    WHERE loan_number = p_loan_number;

    CURSOR c_pdet_resp( cp_dlpnr_id NUMBER)
    IS
    SELECT ROWID
    FROM  igf_sl_dl_pdet_resp
    WHERE dlpnr_id = cp_dlpnr_id;

    l_pdet_resp  c_pdet_resp%ROWTYPE;

    l_dl_chg_resp  c_dl_chg_resp%ROWTYPE;

BEGIN

  FOR l_pnote IN c_pnote(p_loan_id) LOOP
   igf_sl_dl_pnote_p_p_pkg.delete_row(X_ROWID => l_pnote.rowid);
  END LOOP;

  FOR l_pnote_hist IN c_pnote_hist(p_loan_id) LOOP
   igf_sl_pnote_stat_h_pkg.delete_row(X_ROWID => l_pnote_hist.rowid);
  END LOOP;

  FOR l_lor IN c_lor(p_loan_id) LOOP
     FOR l_lor_loc IN c_lor_loc(l_lor.origination_id) LOOP
         igf_sl_lor_loc_pkg.delete_row(X_ROWID => l_lor_loc.rowid);
     END LOOP;
     igf_sl_lor_pkg.delete_row(X_ROWID => l_lor.rowid);
  END LOOP;

    -- Delete all disbursements corresponding to this award_id.
    FOR l_disb_resp IN c_disb_resp(p_loan_id) LOOP
    igf_db_dl_disb_resp_pkg.delete_row(X_ROWID  => l_disb_resp.rowid);
    END LOOP;
    -- Check if there are child records in the Loan Change Origination and Response table
    -- If found then delete those records.
    IF (p_loan_num IS NOT NULL) THEN
      FOR l_lor_crresp IN c_lor_crresp(p_loan_num) LOOP
      -- delete record

      igf_sl_dl_lor_crresp_pkg.delete_row(X_ROWID  => l_lor_crresp.rowid);

      END LOOP;

      FOR l_lor_resp IN c_lor_resp(p_loan_num) LOOP
      -- delete record

      igf_sl_dl_lor_resp_pkg.delete_row(X_ROWID  => l_lor_resp.rowid);

      END LOOP;

      FOR l_pnote_resp IN c_pnote_resp(p_loan_num) LOOP
      -- delete record

        FOR l_pdet_resp IN c_pdet_resp(l_pnote_resp.dlpnr_id) LOOP
        igf_sl_dl_pdet_resp_pkg.delete_row(l_pdet_resp.rowid);
        END LOOP;
        igf_sl_dl_pnote_resp_pkg.delete_row(X_ROWID  => l_pnote_resp.rowid);
      END LOOP;
    END IF;

    FOR l_dl_chg_send IN c_dl_chg_send(p_loan_num) LOOP
    -- delete_row

    igf_sl_dl_chg_send_pkg.delete_row(X_ROWID  => l_dl_chg_send.rowid);

    END LOOP;

    FOR l_dl_chg_resp IN c_dl_chg_resp(p_loan_num) LOOP
    -- delete_row

    igf_sl_dl_chg_resp_pkg.delete_row(X_ROWID  => l_dl_chg_resp.rowid);

    END LOOP;
    IF p_rowid IS NOT NULL THEN

    igf_sl_loans_pkg.delete_row(X_ROWID => p_rowid);

    END IF;
EXCEPTION

WHEN others THEN
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_li_imp_pkg.delete_context_records.exception','Exception:'||SQLERRM);
  END IF;
  fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
  fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.DELETE_CONTEXT_RECORDS');
  fnd_file.put_line(fnd_file.log,fnd_message.get || sqlerrm);

  RAISE IMPORT_ERROR;

END delete_context_records;

PROCEDURE insert_context_records(l_interface       c_interface%ROWTYPE,
                                 l_award_id        igf_aw_award_all.award_id%TYPE,
                                 l_base_id         NUMBER,
                                 l_loan_num        igf_sl_loans_all.loan_number%TYPE)
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  l_chg_interface        c_chg_interface%ROWTYPE;
BEGIN

  IF l_interface.loan_status_code IN ('A','G','N') THEN
    -- Insert into loans table
    loans_insert_row(l_interface,l_award_id);
  END IF;

  IF l_interface.loan_status_code IN ('A','G','N') THEN
    -- Insert into loans origination table
    loans_orig_insert_row(l_interface);
  END IF;

  IF l_interface.loan_status_code = 'A' THEN
    -- Insert into loans orig loc table
    loans_orig_loc_insert_row(l_interface,l_award_id,l_base_id,lv_fed_fund_code);
  END IF;

  IF l_interface.loan_status_code = 'A' THEN
    -- Insert into batch table
    dl_batch_insert_row(l_interface);
  END IF;

  FOR l_chg_interface IN c_chg_interface(l_loan_num) LOOP
    IF l_interface.loan_status_code = 'A' AND NVL(l_interface.loan_chg_status,'*') = 'A' AND ln_dbth_id IS NOT NULL THEN
      -- Insert into change send table
      dl_chg_send_insert_row (l_chg_interface );
      -- insert into change response table
      dl_chg_resp_insert_row (l_chg_interface);
    END IF;
  END LOOP;

  -- insert into pnote table
  -- pnote_insert_row(l_interface,l_award_id);
  -- Insert into response tables
   IF l_interface.pnote_id_txt IS NOT NULL AND l_interface.pnote_accept_date IS NOT NULL AND ln_dbth_id IS NOT NULL THEN
     pnote_resp_insert_row (l_interface);
   END IF;

  -- if the l_interface credit decision date is not null then only insert
  IF l_interface.loan_status_code = 'A' AND l_interface.credit_decision_date IS NOT NULL AND ln_dbth_id IS NOT NULL THEN
    lor_crresp_insert_row(l_interface);
  END IF;

  IF l_interface.loan_status_code = 'A' AND ln_dbth_id IS NOT NULL THEN
    lor_resp_insert_row(l_interface);
  END IF;

EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.INSERT_CONTEXT_RECORDS');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);
     RAISE IMPORT_ERROR;

END insert_context_records;

PROCEDURE insert_context_disb_records( p_disb_interface  c_disb_interface%ROWTYPE,
                                       p_award_id        igf_aw_award_all.award_id%TYPE
                                      )
AS
 /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose    :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

BEGIN
    IF p_disb_interface.acknowledgement_date IS NOT NULL THEN
      -- insert into disbursement table
      disb_resp_insert_row(p_disb_interface);
    END IF;
    -- update disbursement table
    db_awd_disb_update_row(p_disb_interface ,p_award_id);
 EXCEPTION
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.INSERT_CONTEXT_DISB_RECORDS');
     fnd_file.put_line(fnd_file.log,fnd_message.get || SQLERRM);

     RAISE IMPORT_ERROR;

END insert_context_disb_records;



PROCEDURE run ( errbuf         IN OUT NOCOPY VARCHAR2,
                 retcode        IN OUT NOCOPY NUMBER,
                 p_awd_yr       IN VARCHAR2,
                 p_batch_id     IN NUMBER,
                 p_delete_flag  IN VARCHAR2
               )
IS
/*
    ||  Created By : RASAHOO
    ||  Created On : 07-July-2003
    ||  Purpose : This procedure is to import legacy data.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  tsailaja                  15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  bvisvana        07-July-2005   Bug # 4008991 - IGF_GR_BATCH_DOES_NOT_EXIST replaced by IGF_SL_GR_BATCH_DOES_NO_EXIST
    ||  rasahoo         14-Aug-2003     #3096267 message in log file added
    ||                                  to indicate when one record successfully get imported.
    ||  (reverse chronological order - newest change first
*/


  l_error                VARCHAR2(80);
  l_chk_profile          VARCHAR2(1) := 'N';
  lv_flag_lo             BOOLEAN := FALSE;
  l_batch_valid          VARCHAR2(1) ;
  l_processing           VARCHAR2(80);
  l_person_number        VARCHAR2(80);
  lv_person_id           igs_pe_hz_parties.party_id%TYPE     := NULL;
  lv_base_id             igf_ap_fa_base_rec_all.base_id%TYPE := NULL;
  l_valid_for_dml        VARCHAR2(2);
  l_error_flag           BOOLEAN := FALSE;
  l_award_id             igf_aw_award_all.award_id%TYPE;
  p_status               BOOLEAN;
  l_disb_interface       c_disb_interface%ROWTYPE;
  l_chg_interface        c_chg_interface%ROWTYPE;
  p_d_status             BOOLEAN;
  p_d_status2             BOOLEAN;
  l_loan_disb            VARCHAR2(80);
  lv_loan_id             igf_sl_loans_all.loan_id%TYPE;
  lv_loan_num            igf_sl_loans_all.loan_number%TYPE;
  lv_rowid               ROWID;
  l_legacy_flag          VARCHAR2(1);
  l_success_record_cnt   NUMBER  := 0;
  l_total_record_cnt     NUMBER  := 0;
  l_debug_str            VARCHAR2(3000) := NULL ;
  l_school_code          VARCHAR2(6);
  l_num_of_disb_rec      NUMBER  := 0;
  lb_write_log           BOOLEAN := FALSE;
  l_loan_id_msg          VARCHAR(10);
   -- cursor to get alternate code for award year
    CURSOR c_alternate_code( cp_ci_cal_type         igs_ca_inst.cal_type%TYPE ,
                             cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE ) IS
    SELECT  alternate_code
    FROM    igs_ca_inst
    WHERE   cal_type        = cp_ci_cal_type
    AND     sequence_number = cp_ci_sequence_number ;

    l_alternate_code   igs_ca_inst.alternate_code%TYPE ;

    CURSOR c_award_year (cp_cal_type VARCHAR2,
                         cp_seq_num  NUMBER)
    IS
    SELECT batch_year
    FROM   igf_ap_batch_aw_map
    WHERE  ci_cal_type        = cp_cal_type
    AND    ci_sequence_number = cp_seq_num;

     l_award_year   c_award_year%ROWTYPE;

    CURSOR c_award_det(cp_cal_type VARCHAR2,
                       cp_seq_number NUMBER) IS
    SELECT batch_year,
           award_year_status_code status,
           sys_award_year
    FROM   igf_ap_batch_aw_map
    WHERE  ci_cal_type = cp_cal_type
    AND    ci_sequence_number = cp_seq_number;

    l_award_det   c_award_det%ROWTYPE;

    CURSOR c_award_ref (cp_base_id       NUMBER,
                        cp_award_number  VARCHAR2)
    IS

    SELECT    awd.award_id,awd.award_status
    FROM      igf_aw_award_all       awd
    WHERE     awd.base_id            = cp_base_id
    AND       awd.award_number_txt   = cp_award_number;

    l_award_ref    c_award_ref%ROWTYPE;

    CURSOR c_act_isir(cp_base_id NUMBER,
                      p_active   igf_ap_isir_matched.active_isir%TYPE
                     )
    IS

    SELECT    1
    FROM      igf_ap_isir_matched   isir
    WHERE     isir.base_id          = cp_base_id
    AND       isir.active_isir      = p_active;

    l_act_isir    c_act_isir%ROWTYPE;

    CURSOR c_fed_fund_code(cp_award_id NUMBER) IS
    SELECT
           fc.fed_fund_code,
           fc.sys_fund_type
     FROM
           igf_aw_award aw,
           igf_aw_fund_mast fm,
           igf_aw_fund_cat fc
     WHERE
           aw.award_id = cp_award_id and
           fm.fund_id = aw.fund_id and
           fc.fund_code = fm.fund_code;
    l_fed_fund_code c_fed_fund_code%ROWTYPE;

    CURSOR c_relationship (cp_person_number   VARCHAR2,
                           cp_b_person_number VARCHAR2)
    IS
    SELECT 'X'
    FROM hz_relationships pr,
         igs_pe_hz_parties pe,
         hz_parties br,
         hz_parties st
    WHERE
         br.party_number = cp_b_person_number
    AND  st.party_number = cp_person_number
    AND  pr.subject_id = st.party_id
    AND  pr.object_id =  br.party_id
    AND  st.party_id = pe.party_id;

    l_relationship c_relationship%ROWTYPE;

    CURSOR c_disb_det(cp_award_id       NUMBER,
                      cp_disb_num       NUMBER,
                      cp_disb_seq_num   NUMBER)
    IS
    SELECT 1
    FROM   igf_db_awd_disb_dtl_all  adisb
    WHERE  adisb.award_id     =  cp_award_id
    AND    adisb.disb_num     =  cp_disb_num
    AND    adisb.disb_seq_num =  cp_disb_seq_num;

    l_disb_det c_disb_det%ROWTYPE;

    CURSOR c_chk_loan_exist (cp_award_id NUMBER)
    IS
    SELECT
    rowid,
    loan_id ,
    loan_number,
    legacy_record_flag
    FROM igf_sl_loans_all
    WHERE award_id = cp_award_id;

    l_chk_loan_exist c_chk_loan_exist%ROWTYPE;

    CURSOR c_chk_loan (cp_loan_num VARCHAR2)
    IS
    SELECT
    rowid,
    award_id
    FROM igf_sl_loans_all
    WHERE loan_number = cp_loan_num ;

    l_chk_loan c_chk_loan%ROWTYPE;

    CURSOR c_alt_borw(cp_loan_id NUMBER)
    IS
    SELECT rowid
    FROM igf_sl_alt_borw_all
    WHERE loan_id = cp_loan_id;

    l_alt_borw c_alt_borw%ROWTYPE;


    CURSOR c_sl_dl_setup(p_ci_cal_type         VARCHAR2,
                         p_ci_sequence_number  NUMBER)
    IS
    SELECT orig_fee_perct_stafford,
           orig_fee_perct_plus
    FROM   igf_sl_dl_setup
    WHERE  ci_cal_type = p_ci_cal_type
    AND    ci_sequence_number = p_ci_sequence_number;


    l_sl_dl_setup   c_sl_dl_setup%ROWTYPE;

    CURSOR c_int_disb_rec( cp_award_id          NUMBER,
                          cp_alternate_code    VARCHAR2,
                          cp_person_number     VARCHAR2,
                          cp_award_number_txt  VARCHAR2,
                          cp_loan_number       VARCHAR2)
    IS
    SELECT disb_num,
           disb_seq_num
    FROM   igf_db_awd_disb_dtl_all  adisb
    WHERE  adisb.award_id     =  cp_award_id
    AND    (disb_num,disb_seq_num) NOT IN
          (
           SELECT disbursement_num,disbursement_seq_num
           FROM   igf_sl_li_dldb_ints dlint
           WHERE  dlint.ci_alternate_code     = cp_alternate_code
           AND    dlint.person_number         = cp_person_number
           AND    dlint.award_number_txt      = cp_award_number_txt
           AND    dlint.loan_number_txt       = cp_loan_number
          );

    l_int_disb_rec  c_int_disb_rec%ROWTYPE;


    CURSOR c_person_id(cp_person_number VARCHAR2,
                       p_party_type     hz_parties.party_type%TYPE
                      )
    IS
    SELECT PARTY_ID
    FROM hz_parties
    WHERE party_number = cp_person_number and party_type = p_party_type;


    CURSOR c_atd_rep_comb(p_atd_entity_id_txt VARCHAR2, p_rep_entity_id_txt VARCHAR2)
    IS
      SELECT atd.atd_entity_id_txt, rep.rep_entity_id_txt
        FROM igf_gr_attend_pell atd, igf_gr_report_pell rep
       WHERE atd.rcampus_id = rep.rcampus_id
         AND atd.atd_entity_id_txt = p_atd_entity_id_txt
         AND rep.rep_entity_id_txt = p_rep_entity_id_txt;

    atd_rep_comb_rec c_atd_rep_comb%ROWTYPE;


    CURSOR c_chk_isir_dtls(p_base_id NUMBER, p_transaction_num NUMBER)
    IS
      SELECT isir_id
        FROM igf_ap_isir_matched_all
       WHERE TO_NUMBER(transaction_num) = p_transaction_num
         AND base_id = p_base_id;

    chk_isir_dtls_rec   c_chk_isir_dtls%ROWTYPE;

 BEGIN
    igf_aw_gen.set_org_id(NULL);
    errbuf             := NULL;
    retcode            := 0;
    l_cal_type         := LTRIM(RTRIM(SUBSTR(p_awd_yr,1,10)));
    l_seq_number       := TO_NUMBER(SUBSTR(p_awd_yr,11));

    l_error            := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
    l_processing       := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PROCESSING');
    l_person_number    := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');
    l_loan_disb        := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','LOAN_DISB');
    l_loan_id_msg      := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','LOAN_ID');


    g_error_string :=  igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG', 'ENTITY_NAME') ;

    -- Get the Award Year Alternate Code
    OPEN  c_alternate_code( l_cal_type, l_seq_number ) ;
    FETCH c_alternate_code INTO l_alternate_code ;
    CLOSE c_alternate_code ;

    -- Log input parameters
    log_input_params(  p_batch_id, l_alternate_code , p_delete_flag);



    OPEN  c_award_year(l_cal_type ,l_seq_number );
    FETCH c_award_year INTO l_award_year;
    CLOSE c_award_year;

    g_award_year := l_award_year.batch_year;

    -- Check if the  profiles are set
    -- if country code is not'US' AND does not participate in financial aidprogram  THEN
    -- write into the log file and exit process
    l_chk_profile      := igf_ap_gen.check_profile;

    IF l_chk_profile = 'N' THEN
       fnd_message.set_name('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
       fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
       RETURN;
    END IF;

    -- Check If the Batch Entered is Valid or Not. If not Valid then error out
    l_batch_valid := igf_ap_gen.check_batch ( p_batch_id, 'LOANS') ;
      IF NVL(l_batch_valid,'N') <> 'Y' THEN
          -- Bug # 4008991
         fnd_message.set_name('IGF','IGF_SL_GR_BATCH_DOES_NO_EXIST');
         fnd_message.set_token('BATCH_ID',p_batch_id);
         fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
         RETURN;
      END IF;

    -- Check If the Award Year Entered is Valid or Not. If not Valid then error out
    OPEN  c_award_det(l_cal_type,l_seq_number);
    FETCH c_award_det INTO l_award_det;
    IF c_award_det%NOTFOUND THEN
          fnd_message.set_name('IGF','IGF_AP_AWD_YR_NOT_FOUND');
          fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
          CLOSE c_award_det;
          RETURN;
    ELSIF l_award_det.status NOT IN ('LD','O') THEN
          fnd_message.set_name('IGF','IGF_AP_LG_INVALID_STAT');
          fnd_message.set_token('AWARD_STATUS',l_award_det.status);
          fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
          CLOSE c_award_det;
          RETURN;
    ELSE
      CLOSE c_award_det;
    END IF;

    l_award_year_status := l_award_det.status ;

    IF (l_award_year_status = 'O') THEN
        lv_flag_lo := TRUE;
    ELSE
        lv_flag_lo := FALSE;
    END IF;

   FOR l_interface IN c_interface(p_batch_id,l_alternate_code,'U','R') LOOP

   BEGIN
    SAVEPOINT sp1;

    l_total_record_cnt := l_total_record_cnt + 1;
    -- Initialize the variables
    l_valid_for_dml   := 'Y' ;
    lv_person_id      := NULL;
    lv_base_id        := NULL;
    l_award_ref       := NULL;
    l_act_isir        := NULL;
    l_fed_fund_code   := NULL;
    l_disb_interface  := NULL;
    ln_loan_id        := NULL;
    ln_origination_id := NULL;
    ln_lor_resp_num   := NULL;
    ln_dbth_id        := NULL;
    l_debug_str       := NULL;
    l_b_person_id     := NULL;





    -- Initialize lb_write_log for writing into debug log table
    IF fnd_log.TEST(FND_LOG.LEVEL_STATEMENT,'IGF_SL_DL_LI_IMP_PKG') THEN
       lb_write_log := TRUE;
    END IF;
    fnd_file.put_line(fnd_file.log,l_processing ||' '||l_person_number||' '||l_interface.person_number);
    fnd_file.new_line(fnd_file.log,1);
    -- check if person exists in oss
   igf_ap_gen.check_person(l_interface.person_number,l_cal_type,l_seq_number,lv_person_id,lv_base_id);
   l_debug_str := l_debug_str ||' Processing for person number ' || l_interface.person_number;
   IF lv_person_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
      fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
      l_valid_for_dml := 'N' ;
      l_error_flag := TRUE;
   END IF;
   l_debug_str := l_debug_str || 'check if person exists in oss- completed';
   -- check if Base record exists in oss

     IF lv_base_id IS NULL THEN
        fnd_message.set_name('IGF','IGF_AP_FABASE_NOT_FOUND');
        fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
        l_valid_for_dml := 'N' ;
        l_error_flag := TRUE;
     END IF;

    l_debug_str := l_debug_str || 'check if Base record exists in oss - completed';
    l_debug_str := l_debug_str || 'Processing for loan number '|| l_interface.loan_number_txt ;
    fnd_file.put_line(fnd_file.log,l_processing ||' '||l_loan_id_msg||' '||l_interface.loan_number_txt);
    fnd_file.new_line(fnd_file.log,1);

    -- FA 149 Enhancements
    -- Check if the award year is COD-XML or not
    IF (igf_sl_dl_validation.check_full_participant(l_cal_type,l_seq_number,'DL')) THEN
        -- Incase of COD-XML award year support loans with ready to send status
        IF l_interface.loan_status_code <> 'G' THEN
            fnd_message.set_name('IGF','IGF_SL_STATUS_NOT_RDY');
            fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
            l_valid_for_dml := 'N' ;
            l_error_flag := TRUE;
        END IF;

        -- Attending and Reporting Pell entity ids must not be null and their combination should be valid

        IF (l_interface.atd_entity_id_txt IS NULL) OR (l_interface.rep_entity_id_txt IS NULL ) THEN
            fnd_message.set_name('IGF','IGF_SL_ATD_REP_PELL_NOT_CORR');
            fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
            l_valid_for_dml := 'N' ;
            l_error_flag := TRUE;

        ELSE
          -- Check if their combination is valid
            OPEN c_atd_rep_comb(l_interface.atd_entity_id_txt, l_interface.rep_entity_id_txt);
            FETCH c_atd_rep_comb INTO atd_rep_comb_rec;

            IF c_atd_rep_comb%NOTFOUND THEN
                fnd_message.set_name('IGF','IGF_SL_ATD_REP_PELL_NOT_CORR');
                fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
                l_valid_for_dml := 'N' ;
                l_error_flag := TRUE;
            END IF;
            CLOSE c_atd_rep_comb;
        END IF;

        -- Transaction number must have a not null value between 1 and 99
        IF (l_interface.transaction_num IS NULL) OR (l_interface.transaction_num < 1 ) OR (l_interface.transaction_num > 99) THEN
             fnd_message.set_name('IGF','IGF_AP_TRANS_NUM_INVLD');
             fnd_message.set_token('TRNM',l_interface.transaction_num);
             fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
             l_valid_for_dml := 'N' ;
             l_error_flag := TRUE;
        ELSE
           --  Person should have an ISIR with the said transaction number
             OPEN c_chk_isir_dtls(lv_base_id, l_interface.transaction_num);
             FETCH c_chk_isir_dtls INTO chk_isir_dtls_rec ;

             IF c_chk_isir_dtls%NOTFOUND THEN
                fnd_message.set_name('IGF','IGF_AP_ISIR_DTLS_NOT_FOUND');
                fnd_message.set_token('STUD',l_interface.person_number);
                fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
                l_valid_for_dml := 'N' ;
                l_error_flag := TRUE;
             END IF;

             CLOSE c_chk_isir_dtls;
        END IF;


    END IF; -- Check if the award year is COD-XML or not

    -- check if corresponding award is present in the awards table

        OPEN c_award_ref(lv_base_id,l_interface.award_number_txt);
        FETCH c_award_ref INTO l_award_ref;
        IF (c_award_ref%NOTFOUND) THEN
            CLOSE c_award_ref;
            fnd_message.set_name('IGF','IGF_SL_CL_LI_NO_AW_REF');
            fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
            l_valid_for_dml := 'N' ;
            l_error_flag := TRUE;
        ELSE
            CLOSE c_award_ref;
            l_award_id := l_award_ref.award_id;
            IF l_award_ref.award_status = 'CANCELLED' THEN
            fnd_message.set_name('IGF','IGF_SL_TERMINATED_LOAN');
            fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
            l_valid_for_dml := 'N' ;
            l_error_flag := TRUE;
            l_award_id := l_award_ref.award_id;
            ELSE
            l_award_id := l_award_ref.award_id;
            END IF;
        END IF;
     l_debug_str := l_debug_str || ' Processing for person number ' || l_interface.person_number ||' And  Award id  ' || TO_CHAR(l_award_id)  ;
     l_debug_str := l_debug_str || 'check if Base record exists in oss - completed';

   -- check for active isir only if open award year

       IF ( lv_flag_lo = TRUE ) THEN
          OPEN c_act_isir(lv_base_id,'Y');
          FETCH c_act_isir INTO l_act_isir;
          IF (c_act_isir%NOTFOUND) THEN
            CLOSE c_act_isir;
            fnd_message.set_name('IGF','IGF_AP_PAY_ISIR_EXCEED_ONE');
            fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
            l_valid_for_dml := 'N' ;
            l_error_flag := TRUE;
          ELSE
            CLOSE c_act_isir;
          END IF;
       END IF;
   l_debug_str := l_debug_str || 'check for active isir only if open award year - completed';

   -- Check if Fed_fund_Code in ('DLP','DLU','DLS'). If Not exist then error out

     OPEN c_fed_fund_code(l_award_id);
     FETCH c_fed_fund_code INTO l_fed_fund_code;
     CLOSE c_fed_fund_code;
     IF l_fed_fund_code.fed_fund_code IS NULL OR l_fed_fund_code.fed_fund_code NOT IN ('DLP','DLU','DLS') THEN
        fnd_message.set_name('IGF','IGF_SL_CL_INV_FED_FND_CD');
        fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
        l_valid_for_dml := 'N' ;
        l_error_flag := TRUE;
     ELSE
        lv_fed_fund_code := l_fed_fund_code.fed_fund_code ;
     END IF;
  l_debug_str := l_debug_str || 'Check if Fed_fund_Code in (DLP,DLU,DLS) - completed';

   -- check if FED_FUND_CODE is 'DLP' AND  the BORR_PERSON_NUMBER is NULL then error out

      IF l_fed_fund_code.fed_fund_code = 'DLP' THEN
            IF l_interface.borr_person_number IS NULL  THEN
              fnd_message.set_name('IGF','IGF_SL_CL_BOR_NUM_REQD');
              fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
              l_valid_for_dml := 'N' ;
              l_error_flag := TRUE;
            ELSE
             OPEN c_relationship(l_interface.person_number,l_interface.borr_person_number);
             FETCH c_relationship INTO l_relationship;

             IF (c_relationship%NOTFOUND) THEN
               fnd_message.set_name('IGF','IGF_SL_CL_INV_BOR_REL');
               fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
               l_valid_for_dml := 'N' ;
               l_error_flag := TRUE;

               -- Fetch the Borrow person ID to check if party exists
               OPEN c_person_id(l_interface.borr_person_number,'PERSON');
               FETCH c_person_id INTO l_b_person_id;
               CLOSE c_person_id;
               IF l_b_person_id IS NULL THEN
               fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
               fnd_file.put_line(fnd_file.log, RPAD(l_error,12) || g_error_string|| ' ' || 'BORR_PERSON_NUMBER' ||'   ' ||fnd_message.get);
               END IF;

               CLOSE c_relationship;
             ELSE
               CLOSE c_relationship;
               -- Fetch the Borrow person ID
               OPEN c_person_id(l_interface.borr_person_number,'PERSON');
               FETCH c_person_id INTO l_b_person_id;
               CLOSE c_person_id;

             END IF;
           END IF;
      ELSE
          IF l_interface.borr_person_number IS NOT NULL  THEN
            fnd_message.set_name('IGF','IGF_SL_CL_BORW_NOT_REQD');
            fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
            l_valid_for_dml := 'N' ;
            l_error_flag := TRUE;
          END IF;
      END IF;

     -- validate loan origination record
     validate_loan_orig_int(l_interface,l_award_id,p_status,g_igf_sl_message_table);



     l_debug_str := l_debug_str || ' validate loan origination record - completed ';
     -- If record is invalid print the error mesages to the log file
     IF p_status = FALSE THEN
     l_valid_for_dml := 'N';
     l_error_flag := TRUE;
     print_message(g_igf_sl_message_table);
     ELSE -- Collect the value for ORIG_FEE_PERCT from DL setup if  ORIG_FEE_PERCT is null
       l_school_code := SUBSTR(l_interface.loan_number_txt,13,6);
       IF l_interface.orig_fee_perct_num IS NULL THEN
        OPEN   c_sl_dl_setup(l_cal_type,l_seq_number);
        FETCH  c_sl_dl_setup INTO  l_sl_dl_setup;
        CLOSE  c_sl_dl_setup;
        IF lv_fed_fund_code = 'DLP' THEN
           l_interface.orig_fee_perct_num := l_sl_dl_setup.orig_fee_perct_plus;
        ELSE
           l_interface.orig_fee_perct_num := l_sl_dl_setup.orig_fee_perct_stafford;
        END IF;
       END IF;
     END IF;


      -- if record is valid then validate corresponding disbursement records
      IF  l_valid_for_dml = 'Y' AND  p_status = TRUE THEN
         p_d_status := TRUE;
         p_d_status2 := TRUE;

         l_debug_str := l_debug_str || ' fetching disbursement records ';
         l_num_of_disb_rec := 0;

         FOR l_disb_interface IN c_disb_interface(l_interface.ci_alternate_code,l_interface.person_number,l_interface.award_number_txt,l_interface.loan_number_txt) LOOP
            l_num_of_disb_rec := l_num_of_disb_rec + 1 ;
            IF l_disb_interface.acknowledgement_date IS NOT NULL THEN
              OPEN c_disb_det(l_award_id,l_disb_interface.disbursement_num,l_disb_interface.disbursement_seq_num);
              FETCH c_disb_det INTO l_disb_det;
              IF (c_disb_det%NOTFOUND) THEN
                 CLOSE c_disb_det;
                 l_valid_for_dml := 'N' ;
                 l_error_flag := TRUE;
                 fnd_message.set_name('IGF','IGF_SL_DISB_SEQ_NO_EXIST');
                 fnd_message.set_token('DISB_NUM',l_disb_interface.disbursement_num);
                 fnd_message.set_token('SEQ_NUM',l_disb_interface.disbursement_seq_num);
                 fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
                 p_d_status := FALSE;
                 p_d_status2 := FALSE;
              ELSE
                 -- Validate Disbursement record
                 CLOSE c_disb_det;
                 l_debug_str := l_debug_str || ' validating disbursement records with Disbursement Number : ' ||
                                TO_CHAR(l_disb_interface.disbursement_num) || ' And disbursement Sequence Number : ' || TO_CHAR(l_disb_interface.disbursement_seq_num) ;

                 fnd_message.set_name('IGF','IGF_SL_VAL_DB_SEQ_NUM');
                 fnd_message.set_token('DISB_NUM',l_disb_interface.disbursement_num);
                 fnd_message.set_token('SEQ_NUM',l_disb_interface.disbursement_seq_num);
                 fnd_file.put_line(fnd_file.log, fnd_message.get);
                 fnd_file.new_line(fnd_file.log,1);
                 validate_loan_disb( l_disb_interface,l_award_id, p_d_status,g_igf_sl_message_table);

                 IF p_d_status = FALSE THEN
                    p_d_status2 := FALSE;
                    print_message(g_igf_sl_message_table);
                    l_error_flag := TRUE;
                    l_valid_for_dml := 'N' ;
                 END IF;
              END IF;
           END IF;
         END LOOP;

         -- Since p_d_status will hold the value of only the last disbursement
         -- p_d_status2 is used which will become false if any 1 disb fails

         p_d_status := p_d_status2;

          -- If no disbursement record found in Interface table then log message
         IF  l_num_of_disb_rec <> 0 THEN
             OPEN  c_int_disb_rec( l_award_id,
                                   l_interface.ci_alternate_code,
                                   l_interface.person_number,
                                   l_interface.award_number_txt,
                                   l_interface.loan_number_txt);
             FETCH c_int_disb_rec INTO l_int_disb_rec;

             IF c_int_disb_rec%FOUND THEN
               CLOSE c_int_disb_rec;
               l_valid_for_dml := 'N' ;
               l_error_flag := TRUE;
               fnd_message.set_name('IGF','IGF_SL_AC_DISB_SEQ_NO_EXIST');
               fnd_message.set_token('DISB_NUM',l_int_disb_rec.disb_num);
               fnd_message.set_token('SEQ_NUM',l_int_disb_rec.disb_seq_num);
               fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
             ELSE
               CLOSE c_int_disb_rec;
             END IF;
         END IF;
      END IF;


     -- check  valid for dml and process status
    IF  l_valid_for_dml = 'Y' AND p_status = TRUE AND p_d_status = TRUE THEN

        -- check for duplicate loan number
        OPEN   c_chk_loan(l_interface.loan_number_txt);
        FETCH  c_chk_loan INTO l_chk_loan;
        CLOSE  c_chk_loan;
        IF l_chk_loan.award_id <> l_award_id THEN
           fnd_message.set_name('IGF','IGF_SL_DUP_LOAN');
           fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
           l_error_flag := TRUE;
        END IF;

        IF NOT l_error_flag THEN
        -- check import record type 'U'
        IF (NVL(l_interface.import_record_type,'X') = 'U' ) THEN
          OPEN c_chk_loan_exist(l_award_id);
          FETCH c_chk_loan_exist INTO l_chk_loan_exist;
            -- check loan exists
            IF (c_chk_loan_exist%NOTFOUND) THEN
              CLOSE c_chk_loan_exist;
              fnd_message.set_name('IGF','IGF_AP_ORIG_REC_NOT_FOUND');
              fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
              l_error_flag := TRUE;
            ELSE
              CLOSE c_chk_loan_exist;
              lv_loan_id    := l_chk_loan_exist.loan_id;
              lv_rowid      := l_chk_loan_exist.ROWID;
              lv_loan_num   := l_chk_loan_exist.loan_number;
              l_legacy_flag := l_chk_loan_exist.legacy_record_flag;
              -- if record exists and legacy flag is not set then error out
              IF  (lv_flag_lo = TRUE) AND (NVL(l_legacy_flag,'N') = 'N') THEN
                  fnd_message.set_name('IGF','IGF_SL_CL_UPD_OPEN');
                  fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
                  l_error_flag := TRUE;
              ELSE

                 delete_context_records(lv_loan_id,lv_loan_num,lv_rowid);
                 l_debug_str := l_debug_str || ' deleted all context records for import record type U ';

                 insert_context_records(l_interface,l_award_id,lv_base_id,lv_loan_num);
                 FOR l_disb_interface IN c_disb_interface(l_interface.ci_alternate_code,l_interface.person_number,l_interface.award_number_txt,l_interface.loan_number_txt) LOOP
                   -- unless the loan origination is acknowledged no disbursement needs to be imported
                   IF ln_dbth_id IS NOT NULL THEN
                     insert_context_disb_records(l_disb_interface,l_award_id);
                   END IF;
                 END LOOP;
                 l_debug_str := l_debug_str || ' inserted all context records for import record type U ';

              END IF; -- check for legacy flag
            END IF; -- check loan exists
        ELSE  --update flag check 'U'
         OPEN c_chk_loan_exist(l_award_id);
         FETCH c_chk_loan_exist INTO l_chk_loan_exist;
         IF (c_chk_loan_exist%FOUND) THEN
            CLOSE c_chk_loan_exist;
            fnd_message.set_name('IGF','IGF_SL_CL_RECORD_EXIST');
            fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
            l_error_flag := TRUE;
         ELSE
              CLOSE c_chk_loan_exist;
              lv_loan_id    := l_chk_loan_exist.loan_id;
              lv_loan_num   := l_chk_loan_exist.loan_number;
              insert_context_records(l_interface,l_award_id,lv_base_id,lv_loan_num);
              FOR l_disb_interface IN c_disb_interface(l_interface.ci_alternate_code,l_interface.person_number,l_interface.award_number_txt,l_interface.loan_number_txt) LOOP
                -- unless the loan origination is acknowledged no disbursement needs to be imported
                IF ln_dbth_id IS NOT NULL THEN
                  insert_context_disb_records( l_disb_interface,l_award_id);
                END IF;
              END LOOP;
              l_debug_str := l_debug_str || ' inserted all context records for import record type not equal  U ';
         END IF;

        END IF;-- check import record type 'U'
        END IF; -- if not error then
    END IF; -- check  valid for dml and process status

   EXCEPTION
   WHEN  IMPORT_ERROR THEN
     l_error_flag  := TRUE;
     fnd_message.set_name('IGF','IGF_SL_CL_LI_UPD_FLD');
     fnd_file.put_line(fnd_file.log,RPAD(l_error,11) || fnd_message.get);
     fnd_file.new_line(fnd_file.log,1);
     ROLLBACK TO sp1;

   WHEN OTHERS THEN
     RAISE;

   END;  -- end of first block for exception handling, if exception occurs it will rollback to the savepoint sp1

   BEGIN  -- Block for updating  and deleting Interface Record
     IF l_error_flag = TRUE
     OR p_status     = FALSE
     OR p_d_status   = FALSE THEN
             l_error_flag := FALSE;
             -- update the legacy interface table column import_status to 'E'
             l_debug_str := l_debug_str || 'Before update of interface table : status E ';
             UPDATE igf_sl_li_dlor_ints
             SET    import_status_type     = 'E',
                    last_update_date       = SYSDATE,
                    last_update_login      = fnd_global.login_id,
                    request_id             = fnd_global.conc_request_id,
                    program_id             = fnd_global.conc_program_id,
                    program_application_id = fnd_global.prog_appl_id,
                    program_update_date    = SYSDATE
             WHERE  ROWID = l_interface.ROWID;
     ELSE

            IF p_delete_flag = 'Y' THEN

                 DELETE
                 FROM    igf_sl_li_chg_ints slchg
                 WHERE   slchg.loan_number_txt =  l_interface.loan_number_txt;

                 l_debug_str := l_debug_str || ' Before deleting disb interface table record ';
                 DELETE
                 FROM   igf_sl_li_dldb_ints
                 WHERE  ci_alternate_code     = l_disb_interface.ci_alternate_code
                 AND    person_number         = l_disb_interface.person_number
                 AND    award_number_txt      = l_disb_interface.award_number_txt
                 AND    loan_number_txt       = l_disb_interface.loan_number_txt;

                 l_debug_str := l_debug_str || ' Before deleting orig interface table record ';

                 DELETE
                 FROM   igf_sl_li_dlor_ints
                 WHERE  ROWID = l_interface.ROWID;

                 l_debug_str := l_debug_str || ' After deleting orig interface table record ';

            ELSE
                 -- update the legacy interface table column import_status to 'I'
                 l_debug_str := l_debug_str || ' Before update of interface table : status I ';
                 UPDATE igf_sl_li_dlor_ints
                 SET    import_status_type     = 'I',
                        last_update_date       = SYSDATE,
                        last_update_login      = fnd_global.login_id,
                        request_id             = fnd_global.conc_request_id,
                        program_id             = fnd_global.conc_program_id,
                        program_application_id = fnd_global.prog_appl_id,
                        program_update_date    = SYSDATE
                 WHERE  ROWID = l_interface.ROWID;

                 l_debug_str := l_debug_str || ' After update of interface table : status I ';
            END IF;
           l_success_record_cnt := l_success_record_cnt + 1;
           fnd_message.set_name('IGF','IGF_SL_LI_IMP_SUCCES');
           fnd_file.put_line(fnd_file.log, fnd_message.get);

    END IF;
    fnd_file.new_line(fnd_file.log,1);
    -- Write debug messages
     IF lb_write_log THEN
        IF  g_request_id IS NULL THEN
        g_request_id  := fnd_global.conc_request_id;
        END IF;
        fnd_log.string_with_context(FND_LOG.LEVEL_STATEMENT,'IGF_SL_DL_LI_IMP_PKG', l_debug_str,NULL,NULL,NULL,NULL,NULL,TO_CHAR(g_request_id));
     END IF;

   END; -- block for updating and deleting interface records
  END LOOP;

    IF l_total_record_cnt = 0  THEN
       fnd_message.set_name('IGF','IGF_SL_DL_LI_NO_RECORDS');
       fnd_message.set_token('AID_YR', l_alternate_code);
       fnd_message.set_token('BATCH_ID',p_batch_id);
       fnd_file.put_line(fnd_file.log,RPAD(l_error,11) || fnd_message.get);
       RETURN;
     END IF;
     -- Print in the out put file the total number of records successfully imported.

     fnd_file.put_line(fnd_file.output, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_PROCESSED'), 40)  || ' : ' || TO_CHAR(l_total_record_cnt));
     fnd_file.put_line(fnd_file.output, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_SUCCESSFUL'), 40) || ' : ' || TO_CHAR(l_success_record_cnt));
     fnd_file.put_line(fnd_file.output, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_REJECTED'), 40)   || ' : ' || TO_CHAR(l_total_record_cnt - l_success_record_cnt));


  EXCEPTION

   WHEN others THEN
   ROLLBACK;
   fnd_log.string_with_context(FND_LOG.LEVEL_STATEMENT,'IGF_SL_DL_LI_IMP_PKG', l_debug_str || SQLERRM,NULL,NULL,NULL,NULL,NULL,TO_CHAR(g_request_id));
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_DL_LI_IMP_PKG.RUN');
   fnd_file.put_line(fnd_file.log,fnd_message.get || sqlerrm);
   retcode := 2;
   errbuf  := fnd_message.get;
   igs_ge_msg_stack.conc_exception_hndl;
 END run;

 END IGF_SL_DL_LI_IMP_PKG;

/
