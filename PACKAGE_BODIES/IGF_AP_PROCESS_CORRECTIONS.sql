--------------------------------------------------------
--  DDL for Package Body IGF_AP_PROCESS_CORRECTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_PROCESS_CORRECTIONS" AS
/* $Header: IGFAP02B.pls 120.8 2006/04/17 00:09:56 hkodali ship $ */

/*
  ||  Created By : Sridhar
  ||  Created On : 25-NOV-2000
  ||  Purpose : Package creates a flat file with header,corrected records and trailer
  ||            to be sent to CPS. After the file is created igf_ap_isir_corr,
  ||            igf_ap_fa_base_rec tables are updated to change the correction_status.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  bkkumar         07-May-2004     Bug 3598933 Added the fnd logging messages
  ||  veramach        29-Apr-2004     bug 3598067
  ||                                  Changed gv_Trans_Data_Source_Or_Type's value to '1C' rather than 'IC'
  ||  ugummall        31-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
  ||                                  1. Added 5 new parameters to prepare_file.
  ||                                  2. Removed cursors get_school and dest_num_cur and their references.
  ||                                  3. Modified cursor match_isirs to select only those records whose
  ||                                     associated org unit's federal school code match with passed in code.
  ||  cdcruz          17-Sep-2003     # 3085558 FA121-Verification Worksheet.
  ||                                  HOld check added
  ||  masehgal        25-Sep-2002     FA 104 -To Do Enhancements
  ||                                  Added manual_disb_hold in update of Fa Base Rec
  ||  (reverse chronological order - newest change first)
  */


     gn_isir_id                   igf_ap_isir_corr.isir_id%TYPE;
     gv_s_email                   igf_ap_isir_matched.s_email_address%TYPE;
     gv_corr_rec                  VARCHAR2(1000);
     gv_trailer                   VARCHAR2(1000);
     gv_header                    VARCHAR2(1000);
     gn_cnt                       NUMBER;
     gn_std_cnt                   NUMBER  DEFAULT 0;
     gb_nwisr_flg                 BOOLEAN;
     gv_ori_ssn                   VARCHAR2(9);
     gv_ori_name                  VARCHAR2(2);
     gv_trn_num                   VARCHAR2(2);

     g_fed_school_code            VARCHAR2(6);
     gv_datarec_len               NUMBER DEFAULT 580;
     gv_batchnum                  VARCHAR2(23);
     gv_first_name                VARCHAR2(12);
     gv_last_name                 VARCHAR2(16);
     gv_person_number             VARCHAR2(30);
     gn_baseid                    NUMBER(15);
     gv_cal_type                  VARCHAR2(10);
     gn_sequence_number           NUMBER;
     gv_reject_override_3_flag    VARCHAR2(1);
     gv_reject_override_12_flag   VARCHAR2(1);
     gv_reject_override_j_flag    VARCHAR2(1);
     gv_reject_override_k_flag    VARCHAR2(1);
     gv_reject_override_a         VARCHAR2(1);
     gv_reject_override_b         VARCHAR2(1);
     gv_reject_override_c         VARCHAR2(1);
     gv_reject_override_g_flag    VARCHAR2(1);
     gv_reject_override_n         VARCHAR2(1);
     gv_reject_override_w         VARCHAR2(1);
     gv_assum_override_1          VARCHAR2(1);
     gv_assum_override_2          VARCHAR2(1);
     gv_assum_override_3          VARCHAR2(1);
     gv_assum_override_4          VARCHAR2(1);
     gv_assum_override_5          VARCHAR2(1);
     gv_assum_override_6          VARCHAR2(1);
     gv_date                      VARCHAR2(8);
     gv_datetime                  VARCHAR2(6);
     gv_dest_num                  VARCHAR2(10);
     gv_batch_year                VARCHAR2(4);
     gv_Trans_Data_Source_Or_Type VARCHAR2(2) := '1C';


        CURSOR corrs ( cp_corr_status  VARCHAR2 )  IS
        SELECT isir_id, sar_field_number, original_value, corrected_value
          FROM igf_ap_isir_corr
         WHERE correction_status = cp_corr_status
           AND isir_id = gn_isir_id;

        CURSOR corr_hold IS
        SELECT 'x'
          FROM igf_ap_isir_corr
         WHERE
               correction_status = 'HOLD' AND
               isir_id = gn_isir_id and
               rownum = 1;

-- Bug 4403807 - removed the condition isir.payment_isir      = 'Y'
    CURSOR match_isirs (p_base_id NUMBER) IS
    SELECT isirm.isir_id, isirm.s_email_address, isirm.transaction_num, isirm.original_ssn,
           isirm.orig_name_id, isirm.first_name, isirm.last_name, isirm.base_id, PE.party_number person_number
      FROM igf_ap_isir_matched_all isirm,
           igf_ap_fa_base_rec_all far,
           hz_parties pe
     WHERE isirm.base_id            = far.base_id
       AND far.person_id            = pe.party_Id
       AND isirm.system_record_type = 'ORIGINAL'
       AND isirm.base_id            = NVL(p_base_id, isirm.base_id)
       AND far.ci_cal_type          = gv_cal_type
       AND far.ci_sequence_number   = gn_sequence_number
       AND isirm.isir_id            IN (SELECT DISTINCT  c.isir_id
                                          FROM igf_ap_isir_corr_all c
                                         WHERE c.correction_status = 'READY' );


     CURSOR cur_corr_isir (gn_baseid    NUMBER ,
                           cp_rec_type  VARCHAR2) IS
        SELECT
               reject_override_3_flag,
               reject_override_12_flag,
               reject_override_a,
               reject_override_b,
               reject_override_c,
               reject_override_g_flag,
               reject_override_j_flag,
               reject_override_k_flag,
               reject_override_n,
               reject_override_w,
               assum_override_1,
               assum_override_2,
               assum_override_3,
               assum_override_4,
               assum_override_5,
               assum_override_6
          FROM igf_ap_isir_matched
         WHERE base_id            = gn_baseid
           AND system_record_type = cp_rec_type ;

     corr_isir_rec    cur_corr_isir%ROWTYPE ;

     -- Cursor get_school here is removed as p_school_code passed in parameter is being used.

     lc_corr_cur      corrs%ROWTYPE;

     lc_corr_hold     corr_hold%ROWTYPE;

     -- Cursor dest_num_cur here is removed as eti_dest_num passed in parameter is being used.

     CURSOR batch_yr_cur  IS
        SELECT batch_year
          FROM igf_ap_batch_aw_map
         WHERE ci_cal_type        = gv_cal_type
           AND ci_sequence_number = gn_sequence_number;

     -- masehgal  # 2885882  added in FACR113 SAR Updates
     CURSOR  cur_pay_isir (gn_baseid   NUMBER)  IS
        SELECT
               reject_override_3_flag,
               reject_override_12_flag,
               reject_override_a,
               reject_override_b,
               reject_override_c,
               reject_override_g_flag,
               reject_override_j_flag,
               reject_override_k_flag,
               reject_override_n,
               reject_override_w,
               assum_override_1,
               assum_override_2,
               assum_override_3,
               assum_override_4,
               assum_override_5,
               assum_override_6
          FROM igf_ap_isir_matched_all
         WHERE base_id      = gn_baseid
           AND system_record_type = 'ORIGINAL'
           AND payment_isir = 'Y';

     pay_isir_rec    cur_pay_isir%ROWTYPE ;


FUNCTION blanks(num_spaces IN NUMBER)
RETURN VARCHAR2
IS
/*
  ||  Created By : Sridhar
  ||  Created On : 25-NOV-2000
  ||  Purpose : For right padding the variables to make their length
  ||            fit to the field size in record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  l_chr   VARCHAR2(2000);

BEGIN

--  RETURN(RPAD(fnd_global.local_chr(0),num_spaces,fnd_global.local_chr(0)));
  RETURN(RPAD(' ',num_spaces,' '));

EXCEPTION

   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_process_corrections.blanks.exception','The exception is : ' || SQLERRM );
      END IF;
     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_AP_PROCESS_CORRECTIONS.BLANKS');
     fnd_file.put_line(fnd_file.log,SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;

END blanks;

PROCEDURE create_header
IS
/*
  ||  Created By : Sridhar
  ||  Created On : 25-NOV-2000
  ||  Purpose : Creates the mandatory header record for a batch of corrected records
  ||             and calls write_file to  write this header into the file.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        31-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
  ||                                  gv_dest_num and g_fed_school_code are populated in main prepare_file
  ||                                  procedure. Thus cursors get_school and dest_num_cur are removed.
  ||  (reverse chronological order - newest change first)
  */


BEGIN

--
-- Get ETI Destination Code from Setup
--

-- gv_dest_num is populated with passed in parameter eti_dest_num in prepare_file(main concurrent) procedure

--
-- Give message if the ETI Destination Code is invalid. Continue with the process
--

  IF LENGTH(NVL(gv_dest_num,'TGXXXXX')) <> 7 THEN
     fnd_message.set_name('IGF','IGF_AP_INVALID_DEST_CODE');
     fnd_file.put_line(fnd_file.log, fnd_message.get);
     gv_dest_num := 'TGXXXXX';
  END IF;

  gv_date       := TO_CHAR(SYSDATE,'YYYYMMDD');
  gv_datetime   := TO_CHAR(SYSDATE,'HHMISS');


  IF g_fed_school_code IS NULL THEN
       g_fed_school_code   :=  g_fed_school_code || blanks(6);
  ELSE
       g_fed_school_code   :=  g_fed_school_code || blanks(6-LENGTH(g_fed_school_code));
  END IF;
                                      -- total
  gv_batchnum  := '#C'             || -- 2
                  gv_batch_year    || -- 3
                  g_fed_school_code   || -- 9
                  gv_date          || -- 17
                  gv_datetime;        -- 23

--
-- Header record format is picked up from the File formats
-- Provided by the US Education department web site
--

  IF gv_batch_year = '3' THEN
                                                            -- total
       gv_header   := 'CPS'                             ||  -- 3
                      blanks(1)                         ||  -- 4
                      'HEADER'                          ||  -- 10
                      blanks(2)                         ||  -- 12
                      LPAD(TO_CHAR(gv_datarec_len),4,0) ||  -- 16
                      'H'                               ||  -- 17
                      gv_dest_num                       ||  -- 24
                      blanks(2)                         ||  -- 26
                      gv_date                           ||  -- 34
                      gv_datetime                       ||  -- 40
                      blanks(12)                        ||  -- 52
                      '0203'                            ||  -- 56
                      gv_batchnum                       ||  -- 79
                      blanks(3)                         ||  -- 82
                      blanks(2)                         ||  -- 84
                      blanks(1)                         ||  -- 85
                      blanks(gv_datarec_len - 85);          -- 580

  ELSIF  gv_batch_year = '4' THEN
                                                            -- total
       gv_header   := 'CPS'                             ||  -- 3
                      blanks(1)                         ||  -- 4
                      'HEADER'                          ||  -- 10
                      blanks(2)                         ||  -- 12
                      LPAD(TO_CHAR(gv_datarec_len),4,0) ||  -- 16
                      'H'                               ||  -- 17
                      gv_dest_num                       ||  -- 24
                      blanks(2)                         ||  -- 26
                      gv_date                           ||  -- 34
                      gv_datetime                       ||  -- 40
                      blanks(12)                        ||  -- 52
                      '0304'                            ||  -- 56
                      gv_batchnum                       ||  -- 79
                      blanks(3)                         ||  -- 82
                      blanks(2)                         ||  -- 84
                      blanks(1)                         ||  -- 85
                      blanks(gv_datarec_len - 85);          -- 580
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_process_corrections.create_header.exception','The exception is : ' || SQLERRM );
      END IF;
     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_AP_PROCESS_CORRECTIONS.CREATE_HEADER');
     fnd_file.put_line(fnd_file.log,SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;

END create_header;

PROCEDURE create_trailer
IS
/*
  ||  Created By : Sridhar
  ||  Created On : 25-NOV-2000
  ||  Purpose : Creates the mandatory trailer record for a batch of corrected records
  ||             and calls write_file to  write this trailer into the file.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


BEGIN

--
-- Trailer record format is picked up from the file formats
-- provided by the US Education department
--

  IF  gv_batch_year = '3' THEN
                                                               -- total
       gv_trailer  :=  'CPS'                               ||  -- 3
                       blanks(1)                           ||  -- 4
                       'TRAILER'                           ||  -- 11
                       blanks(1)                           ||  -- 12
                       LPAD(TO_CHAR(gv_datarec_len),4,'0') ||  -- 16
                       'H'                                 ||  -- 17
                       gv_dest_num                         ||  -- 24
                       gv_date                             ||  -- 32
                       gv_datetime                         ||  -- 38
                       blanks(14)                          ||  -- 52
                       '0203'                              ||  -- 56
                       LPAD(TO_CHAR(gn_std_cnt),5,'0')     ||  -- 61
                       gv_batchnum                         ||  -- 84
                       blanks(1)                           ||  -- 85
                       blanks(2)                           ||  -- 87
                       blanks(7)                           ||  -- 94
                       blanks(7)                           ||  -- 101
                       blanks(7)                           ||  -- 108
                       blanks(1)                           ||  -- 109
                       blanks(gv_datarec_len - 109);           -- 580

  ELSIF gv_batch_year = '4' THEN
                                                               -- total
     gv_trailer  :=    'CPS'                               ||  -- 3
                        blanks(1)                          ||  -- 4
                        'TRAILER'                          ||  -- 11
                        blanks(1)                          ||  -- 12
                        LPAD(TO_CHAR(gv_datarec_len),4,'0')||  -- 16
                        'H'                                ||  -- 17
                        gv_dest_num                        ||  -- 24
                        gv_date                            ||  -- 32
                        gv_datetime                        ||  -- 38
                        blanks(7)                          ||  -- 45
                        '0304'                             ||  -- 49
                        LPAD(TO_CHAR(gn_std_cnt),5,'0')    ||  -- 54
                        gv_batchnum                        ||  -- 77
                        blanks(1)                          ||  -- 78
                        blanks(2)                          ||  -- 80
                        blanks(7)                          ||  -- 87
                        blanks(7)                          ||  -- 94
                        blanks(7)                          ||  -- 101
                        blanks(7)                          ||  -- 108
                        blanks(1)                          ||  -- 109
                        blanks(gv_datarec_len - 109);          -- 580
 END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_process_corrections.create_trailer.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_PROCESS_CORRECTIONS.CREATE_TRAILER');
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END create_trailer;


PROCEDURE format_fields(vsarno  IN OUT NOCOPY  VARCHAR2,
                        vnewval IN OUT NOCOPY  VARCHAR2)
IS
/*
  ||  Created By : Sridhar
  ||  Created On : 25-NOV-2000
  ||  Purpose : Formats the signed numeric and ordinary numeric fields.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  museshad        28-Oct-2005     Bug 4690726
  ||  masehgal        14-May-2003     # 2885882 FACR113 SAR Updates
  ||                                  Precessing based on SAR Names rather than SAR Numbers
  ||  (reverse chronological order - newest change first)
  */


  CURSOR cur_get_sar_name (cp_base_id    igf_ap_fa_base_rec.base_id%TYPE ,
                           l_sar_number  igf_fc_sar_cd_mst.sar_field_number%TYPE ) IS
     SELECT sar.sar_field_name
       FROM igf_ap_batch_aw_map    map,
            igf_ap_fa_base_rec_all   fabase ,
            igf_fc_sar_cd_mst           sar
      WHERE fabase.base_id         = cp_base_id
        AND map.ci_cal_type        = fabase.ci_cal_type
        AND map.ci_sequence_number = fabase.ci_sequence_number
        AND sar.sys_award_year     = map.sys_award_year
        AND sar.sar_field_number   = l_sar_number  ;

  v_last_digit      VARCHAR2(2) ;
  L_sar_column_name VARCHAR2(30) ;

BEGIN

    OPEN  cur_get_sar_name ( gn_baseid, vsarno ) ;
    FETCH cur_get_sar_name INTO  l_sar_column_name ;
    CLOSE cur_get_sar_name ;

    IF RTRIM(vnewval) IS NULL THEN
       vnewval := '*';
    ELSE

         /* These fields are signed numeric fields. The format in which they need
            to be sent to CPS is available in file formats. */

    IF L_sar_column_name IN ('S_ADJUSTED_GROSS_INCOME' ,
                             'S_INCOME_FROM_WORK' ,
                             'SPOUSE_INCOME_FROM_WORK',
                             'P_ADJUSTED_GROSS_INCOME',
                             'F_INCOME_WORK',
                             'M_INCOME_WORK') THEN
       IF TO_NUMBER( vnewval) > 0 THEN
          v_last_digit  := TO_NUMBER (SUBSTR (RTRIM (vnewval), LENGTH (RTRIM (vnewval)),1)) ;
          IF v_last_digit = 0 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 1, LENGTH ( RTRIM(vnewval))-1) || '{' ;
          ELSIF v_last_digit = 1 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 1, LENGTH ( RTRIM(vnewval))-1) || 'A' ;
          ELSIF v_last_digit = 2 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 1, LENGTH ( RTRIM(vnewval))-1) || 'B' ;
          ELSIF v_last_digit = 3 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 1, LENGTH ( RTRIM(vnewval))-1) || 'C' ;
          ELSIF v_last_digit = 4 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 1, LENGTH ( RTRIM(vnewval))-1) || 'D' ;
          ELSIF v_last_digit = 5 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 1, LENGTH ( RTRIM(vnewval))-1) || 'E' ;
          ELSIF v_last_digit = 6 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 1, LENGTH ( RTRIM(vnewval))-1) || 'F' ;
          ELSIF v_last_digit = 7 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 1, LENGTH ( RTRIM(vnewval))-1) || 'G' ;
          ELSIF v_last_digit = 8 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 1, LENGTH ( RTRIM(vnewval))-1) || 'H' ;
          ELSIF v_last_digit = 9 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 1, LENGTH ( RTRIM(vnewval))-1) || 'I' ;
          END IF ;
       ELSIF TO_NUMBER( vnewval) < 0 THEN
          v_last_digit  := TO_NUMBER (SUBSTR (RTRIM (vnewval), LENGTH (RTRIM (vnewval)),1)) ;
          IF v_last_digit = 0 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 2, LENGTH ( RTRIM(vnewval))-2) || '}' ;
          ELSIF v_last_digit = 1 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 2, LENGTH ( RTRIM(vnewval))-2) || 'J' ;
          ELSIF v_last_digit = 2 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 2, LENGTH ( RTRIM(vnewval))-2) || 'K' ;
          ELSIF v_last_digit = 3 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 2, LENGTH ( RTRIM(vnewval))-2) || 'L' ;
          ELSIF v_last_digit = 4 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 2, LENGTH ( RTRIM(vnewval))-2) || 'M' ;
          ELSIF v_last_digit = 5 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 2, LENGTH ( RTRIM(vnewval))-2) || 'N' ;
          ELSIF v_last_digit = 6 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 2, LENGTH ( RTRIM(vnewval))-2) || 'O' ;
          ELSIF v_last_digit = 7 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 2, LENGTH ( RTRIM(vnewval))-2) || 'P' ;
          ELSIF v_last_digit = 8 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 2, LENGTH ( RTRIM(vnewval))-2) || 'Q' ;
          ELSIF v_last_digit = 9 THEN
             vnewval := SUBSTR ( RTRIM (vnewval), 2, LENGTH ( RTRIM(vnewval))-2) || 'R' ;
          END IF ;
       ELSIF TO_NUMBER( vnewval) = 0 THEN
          vnewval := '{' ;
       END IF ;
       vnewval := LPAD(vnewval,6,'0');

    ELSIF l_sar_column_name IN ('S_EXEMPTIONS',
                                'VA_MONTHS',
                                'P_NUM_FAMILY_MEMBER',
                                'P_EXEMPTIONS',
                                'S_NUM_FAMILY_MEMBERS' )  THEN
       vnewval := LPAD(vnewval, 2, '0') ;

    ELSIF l_sar_column_name = 'VA_AMOUNT' THEN
       vnewval := LPAD(vnewval, 4, '0') ;

    ELSIF l_sar_column_name IN ('PERM_ZIP_CODE',
                                'S_FED_TAXES_PAID',
                                'S_TOA_AMT_FROM_WSA',
                                'S_TOA_AMT_FROM_WSB',
                                'S_TOA_AMT_FROM_WSC',
                                'P_INCOME_WSA',
                                'P_INCOME_WSB',
                                'P_INCOME_WSC')  THEN
       vnewval := LPAD(vnewval, 5, '0') ;

    ELSIF l_sar_column_name IN ('S_INVESTMENT_NETWORTH',
                                'S_BUSI_FARM_NETWORTH',
                                'S_CASH_SAVINGS',
                                'P_TAXES_PAID',
                                'P_INVESTMENT_NETWORTH',
                                'P_BUSINESS_NETWORTH',
                                'P_CASH_SAVING')  THEN
       vnewval := LPAD(vnewval, 6, '0') ;

    ELSIF l_sar_column_name IN ('CURRENT_SSN',
                                'FATHER_SSN',
                                'MOTHER_SSN',
                                'PREPARER_SSN',
                                'PREPARER_EMP_ID_NUMBER') THEN
       vnewval := LPAD(vnewval, 9, '0') ;

    ELSIF l_sar_column_name = 'PHONE_NUMBER' THEN
       vnewval := LPAD(vnewval, 10, '0') ;

    ELSIF l_sar_column_name IN ('DATE_OF_BIRTH',
                                'TRANSACTION_RECEIPT_DATE',
                                'DATE_APP_COMPLETED',
                                'FATHER_STEP_FATHER_BIRTH_DATE',
                                'MOTHER_STEP_MOTHER_BIRTH_DATE') THEN
       vnewval := TO_CHAR(fnd_date.chardate_to_date(vnewval),'YYYYMMDD');
       vnewval := LPAD(vnewval,8,'0') ;

-- masehgal    17-Jun-2003    # 2986938 Corrections File formatting Bug
    ELSIF l_sar_column_name IN ('S_MARITAL_STATUS_DATE',
                                'PARENT_MARITAL_STATUS_DATE',
                                'P_LEGAL_RES_DATE',
                                'S_LEGAL_RESD_DATE') THEN
       vnewval := TO_CHAR(fnd_date.chardate_to_date(vnewval),'YYYYMM');
       vnewval := LPAD(vnewval,6,'0');

    END IF;
  END IF;
  vnewval := vnewval || blanks(35 - length(vnewval));

EXCEPTION

   WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_process_corrections.format_fields.exception','The exception is : ' || SQLERRM );
    END IF;
   fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_AP_PROCESS_CORRECTIONS.FORMAT_FIELDS'|| '   ' || L_sar_column_name || '   ' || vnewval );
   fnd_file.put_line(fnd_file.log,SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END format_fields;

PROCEDURE start_record
IS
/*
  ||  Created By : Sridhar
  ||  Created On : 25-NOV-2000
  ||  Purpose : Creates a new record to be written into the flat file.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */



BEGIN

  gv_ori_ssn    :=  LPAD(gv_ori_ssn,9,'0');
  gv_trn_num    :=  LPAD(gv_trn_num,2,'0');
  gv_corr_rec   :=  gv_batch_year ||
                    gv_ori_ssn    ||
                    gv_ori_name   ||
                    gv_trn_num;

EXCEPTION

   WHEN OTHERS THEN
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_process_corrections.start_record.exception','The exception is : ' || SQLERRM );
     END IF;
     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_AP_PROCESS_CORRECTIONS.START_RECORD');
     fnd_file.put_line(fnd_file.log,SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;

END start_record;

PROCEDURE fill_string(sar_no IN NUMBER,new_val IN VARCHAR2)
IS
/*
  ||  Created By : Sridhar
  ||  Created On : 25-NOV-2000
  ||  Purpose : Calls format_fields procedure to format the string
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

     v_sarno  VARCHAR2(3);
     v_newval VARCHAR2(35);
BEGIN

     v_sarno     :=  sar_no;
     v_newval    :=  new_val;
     v_sarno     :=  LPAD(v_sarno,3,'0');

     format_fields(v_sarno,v_newval);

     gv_corr_rec :=  gv_corr_rec  ||
                     v_sarno      ||
                     v_newval;
EXCEPTION

   WHEN OTHERS THEN
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_process_corrections.fill_string.exception','The exception is : ' || SQLERRM );
     END IF;
     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_AP_PROCESS_CORRECTIONS.FILL_STRING');
     fnd_file.put_line(fnd_file.log,SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;

END fill_string;

PROCEDURE compare_individual_override
 AS
  /*
  ||  Created By : rasahoo
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ridas           05-Apr-2006     Bug #5064614. Added NVL function to
  ||                                  avoid NULL value in the correction file.
  ||  (reverse chronological order - newest change first)
  */

 BEGIN

    gv_reject_override_3_flag := NVL(corr_isir_rec.reject_override_3_flag,blanks(1));

    gv_reject_override_12_flag := NVL(corr_isir_rec.reject_override_12_flag,blanks(1));

    gv_reject_override_a := NVL(corr_isir_rec.reject_override_a,blanks(1));

    gv_reject_override_b := NVL(corr_isir_rec.reject_override_b,blanks(1));

    gv_reject_override_c := NVL(corr_isir_rec.reject_override_c,blanks(1));

    gv_reject_override_g_flag := NVL(corr_isir_rec.reject_override_g_flag,blanks(1));

    gv_reject_override_j_flag := NVL(corr_isir_rec.reject_override_j_flag,blanks(1));

    gv_reject_override_k_flag := NVL(corr_isir_rec.reject_override_k_flag,blanks(1));

    gv_reject_override_n := NVL(corr_isir_rec.reject_override_n,blanks(1));

    gv_reject_override_w := NVL(corr_isir_rec.reject_override_w,blanks(1));

    gv_assum_override_1 := NVL(corr_isir_rec.assum_override_1,blanks(1));

    gv_assum_override_2 := NVL(corr_isir_rec.assum_override_2,blanks(1));

    gv_assum_override_3 := NVL(corr_isir_rec.assum_override_3,blanks(1));

    gv_assum_override_4 := NVL(corr_isir_rec.assum_override_4,blanks(1));

    gv_assum_override_5 := NVL(corr_isir_rec.assum_override_5,blanks(1));

    gv_assum_override_6 := NVL(corr_isir_rec.assum_override_6,blanks(1));

 EXCEPTION
  WHEN others THEN
       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_process_corrections.compare_individual_override.exception','The exception is : ' || SQLERRM );
       END IF;
       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_AP_PROCESS_CORRECTIONS.COMPARE_INDIVIDUAL_OVERRIDE' );
       fnd_file.put_line(fnd_file.log,SQLERRM);
       igs_ge_msg_stack.add;
       app_exception.raise_exception;

 END compare_individual_override;

PROCEDURE write_file(str_type VARCHAR2)
IS
/*
  ||  Created By : Sridhar
  ||  Created On : 25-NOV-2000
  ||  Purpose : Uses Fnd_file utitlity to write header,data and trailer records
  ||            into the flat file.Header and trailer records are written into
  ||            file as they are constructed. But data records are formated here
  ||            to fill in the last fields.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

     ln_sno              NUMBER;
     lv_sno              VARCHAR2(5);
     lv_trn_dt           VARCHAR2(8);
     lv_email            VARCHAR2(50);
     lv_rowid            VARCHAR2(30);
     ln_ict_id           igf_ap_isircor_tmp.ict_id%TYPE;
     l_rec_type          VARCHAR2(30) ;

BEGIN

   IF str_type = 'DATA' THEN

     IF LENGTH(LTRIM(RTRIM(gv_corr_rec))) < 470 THEN
        gv_corr_rec := RPAD(gv_corr_rec,470,' ');
     END IF;

     IF gv_s_email IS NULL THEN
       lv_email := lv_email||blanks(50);
     ELSE
       lv_email  := LTRIM(RTRIM(gv_s_email));
       lv_email  := lv_email||blanks(50-LENGTH(lv_email));
     END IF;

     -- transaction date
     lv_trn_dt := TO_CHAR(SYSDATE,'YYYYMMDD');
     lv_sno       :=  LPAD(TO_CHAR(gn_std_cnt),5,'0');

/*
  Get the reject override and assumption override fields from the Correction ISIR.
  These fields can be changed through the modify ISIR page.
*/
     -- masehgal   FACR113 SAR Updates - removed overrides from 0203 format file
     IF SUBSTR(gv_corr_rec,1,1) = '3' THEN
          gv_corr_rec := gv_corr_rec||g_fed_school_code; -- 470 - 476
          gv_corr_rec  :=  gv_corr_rec  ||   -- 476
                           lv_email     ||   -- 526
                           blanks (9)   ||   -- 535
                           blanks(17)   ||   -- 552
                           lv_trn_dt    ||   -- 560
                           blanks(14)   ||   -- 574
                           lv_sno       ||   -- 579
                           'H';              -- 580


     -- for 0304
     -- masehgal   FACR113  SAR Updates
     ELSIF SUBSTR(gv_corr_rec,1,1) = '4'  THEN
        -- get the correction isir assumption/reject override values
        l_rec_type := 'CORRECTION' ;
        OPEN  cur_corr_isir (gn_baseid , l_rec_type );
        FETCH cur_corr_isir INTO corr_isir_rec ;
        CLOSE cur_corr_isir;

        -- get the payment isir assumption/reject override values
        OPEN  cur_pay_isir (gn_baseid);
        FETCH cur_pay_isir INTO pay_isir_rec ;
        CLOSE cur_pay_isir;

        -- compare individual overrides
        compare_individual_override;
        gv_corr_rec := gv_corr_rec||g_fed_school_code; -- 471 - 476
        -- append in the correction record          -- total
        gv_corr_rec  :=  gv_corr_rec           ||   -- 476
                         lv_email              ||   -- 526
                         gv_reject_override_a  ||   -- 527
                         gv_reject_override_b  ||   -- 528
                         gv_reject_override_c  ||   -- 529
                         gv_reject_override_n  ||   -- 530
                         gv_reject_override_w  ||   -- 531
                         gv_assum_override_1   ||   -- 532
                         gv_assum_override_2   ||   -- 533
                         gv_assum_override_3   ||   -- 534
                         gv_assum_override_4   ||   -- 535
                         gv_assum_override_5   ||   -- 536
                         gv_assum_override_6   ||   -- 537
                         blanks(17)            ||   -- 554
                         lv_trn_dt             ||   -- 562
                         blanks(12)            ||   -- 574
                         lv_sno                ||   -- 579
                         'H';                       -- 580
      ELSIF SUBSTR(gv_corr_rec,1,1) = '5'  THEN
        -- get the correction isir assumption/reject override values
        l_rec_type := 'CORRECTION' ;

        OPEN  cur_corr_isir (gn_baseid , l_rec_type );
        FETCH cur_corr_isir INTO corr_isir_rec ;
        CLOSE cur_corr_isir;

        -- get the payment isir assumption/reject override values
        OPEN  cur_pay_isir (gn_baseid);
        FETCH cur_pay_isir INTO pay_isir_rec ;
        CLOSE cur_pay_isir;

        -- compare individual overrides
         compare_individual_override;
         gv_corr_rec  :=  gv_corr_rec                       ||   -- 470
                          lv_email                          ||   -- 520
                          gv_Trans_Data_Source_Or_Type      ||   -- 522
                          lv_trn_dt                         ||   -- 530
                          gv_assum_override_1               ||   -- 531
                          gv_assum_override_2               ||   -- 532
                          gv_assum_override_3               ||   -- 533
                          gv_assum_override_4               ||   -- 534
                          gv_assum_override_5               ||   -- 535
                          gv_assum_override_6               ||   -- 536
                          gv_reject_override_a              ||   -- 537
                          gv_reject_override_b              ||   -- 538
                          gv_reject_override_c              ||   -- 539
                          gv_reject_override_g_flag         ||   -- 540
                          gv_reject_override_n              ||   -- 541
                          gv_reject_override_w              ||   -- 542
                          g_fed_school_code                 ||   -- 548
                          blanks(32);                            -- 580

      ELSIF SUBSTR(gv_corr_rec,1,1) = '6'  THEN
        -- get the correction isir assumption/reject override values
        l_rec_type := 'CORRECTION' ;

        OPEN  cur_corr_isir (gn_baseid , l_rec_type );
        FETCH cur_corr_isir INTO corr_isir_rec ;
        CLOSE cur_corr_isir;

        -- get the payment isir assumption/reject override values
        OPEN  cur_pay_isir (gn_baseid);
        FETCH cur_pay_isir INTO pay_isir_rec ;
        CLOSE cur_pay_isir;

        -- compare individual overrides
         compare_individual_override;
         gv_corr_rec  :=  gv_corr_rec                       ||   -- 470
                          lv_email                          ||   -- 520
                          gv_Trans_Data_Source_Or_Type      ||   -- 522
                          lv_trn_dt                         ||   -- 530
                          gv_assum_override_1               ||   -- 531
                          gv_assum_override_2               ||   -- 532
                          gv_assum_override_3               ||   -- 533
                          gv_assum_override_4               ||   -- 534
                          gv_assum_override_5               ||   -- 535
                          gv_assum_override_6               ||   -- 536
                          gv_reject_override_3_flag         ||   -- 537
                          gv_reject_override_12_flag        ||   -- 538
                          gv_reject_override_a              ||   -- 539
                          gv_reject_override_b              ||   -- 540
                          gv_reject_override_c              ||   -- 541
                          blanks(1)                         ||   -- 542
                          gv_reject_override_g_flag         ||   -- 543
                          gv_reject_override_j_flag         ||   -- 544
                          gv_reject_override_k_flag         ||   -- 545
                          gv_reject_override_n              ||   -- 546
                          blanks(1)                         ||   -- 547
                          gv_reject_override_w              ||   -- 548
                          g_fed_school_code                 ||   -- 554
                          blanks(26);                            -- 580


      ELSIF SUBSTR(gv_corr_rec,1,1) = '7'  THEN
       -- get the correction isir assumption/reject override values
       l_rec_type := 'CORRECTION' ;

       OPEN  cur_corr_isir (gn_baseid , l_rec_type );
       FETCH cur_corr_isir INTO corr_isir_rec ;
       CLOSE cur_corr_isir;

       -- get the payment isir assumption/reject override values
       OPEN  cur_pay_isir (gn_baseid);
       FETCH cur_pay_isir INTO pay_isir_rec ;
       CLOSE cur_pay_isir;

       -- compare individual overrides
        compare_individual_override;
        gv_corr_rec  :=  gv_corr_rec                       ||   -- 470
                         lv_email                          ||   -- 520
                         gv_Trans_Data_Source_Or_Type      ||   -- 522
                         lv_trn_dt                         ||   -- 530
                         gv_assum_override_1               ||   -- 531
                         gv_assum_override_2               ||   -- 532
                         gv_assum_override_3               ||   -- 533
                         gv_assum_override_4               ||   -- 534
                         gv_assum_override_5               ||   -- 535
                         gv_assum_override_6               ||   -- 536
                         gv_reject_override_3_flag         ||   -- 537
                         gv_reject_override_12_flag        ||   -- 538
                         gv_reject_override_a              ||   -- 539
                         gv_reject_override_b              ||   -- 540
                         gv_reject_override_c              ||   -- 541
                         blanks(1)                         ||   -- 542
                         gv_reject_override_g_flag         ||   -- 543
                         gv_reject_override_j_flag         ||   -- 544
                         gv_reject_override_k_flag         ||   -- 545
                         gv_reject_override_n              ||   -- 546
                         blanks(1)                         ||   -- 547
                         gv_reject_override_w              ||   -- 548
                         g_fed_school_code                 ||   -- 554
                         blanks(26);                            -- 580

      END IF;

     fnd_file.put_line(fnd_file.output,gv_corr_rec);

   ELSIF str_type = 'HEADER' THEN
      create_header;

      fnd_file.put_line(fnd_file.output,gv_header);


   ELSIF str_type = 'TRAILER' THEN
      create_trailer;

      fnd_file.put_line(fnd_file.output,gv_trailer);

   END IF;

EXCEPTION

   WHEN fnd_file.utl_file_error THEN
        fnd_message.set_name('IGF','IGF_GE_ERROR_OPEN_FILE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

   WHEN OTHERS THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_process_corrections.write_file.exception','The exception is : ' || SQLERRM );
        END IF;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_PROCESS_CORRECTIONS.WRITE_FILE');
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END write_file;

PROCEDURE update_corr
IS
/*
  ||  Created By : Sridhar
  ||  Created On : 25-NOV-2000
  ||  Purpose : Updates the status of the records written into output file to batched
  ||            in IGF_AP_ISIR_CORR and IGF_AP_FA_BASE_REC tables.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        26-SEP-2003     FA 126 - Multiple FA Offices.
  ||                                  added new parameter assoc_org_num to TBH call
  ||                                  igf_ap_fa_base_rec_pkg.update_row  w.r.t. FA 126
  ||
  ||  masehgal        11-Nov-2002     FA 101 - SAP Obsoletion
  ||                                  removed packaging hold
  ||  masehgal        25-Sep-2002     FA 104 -To Do Enhancements
  ||                                  Added manual_disb_hold in update of Fa Base Rec
  ||  rbezawad    22-Jun-2001     igf_ap_fa_base_rec_pkg.update_row call modified by
  ||                              passing gv_batchnum to parameter x_ede_correction_batch_id
  ||                              w.r.t. Bug ID: 1821811
  ||  (reverse chronological order - newest change first)
*/
     CURSOR corr_rec ( cp_corr_stat VARCHAR2)  IS
        SELECT corr.*
          FROM igf_ap_isir_corr corr
         WHERE isir_id           = gn_isir_id
           AND correction_status = cp_corr_stat ;

     CURSOR get_baserec IS
        SELECT f.*
          FROM igf_ap_fa_base_rec f
         WHERE base_id = gn_baseid;

     pn_rec         corr_rec%ROWTYPE;
     base_rec       get_baserec%ROWTYPE;
     corr_stat      igf_ap_isir_corr.correction_status%TYPE;
     lv_curdate     DATE;
     l_corr_stat    VARCHAR2(30) ;

BEGIN

     corr_stat := 'BATCHED';
     l_corr_stat := 'READY';

     OPEN corr_rec ( l_corr_stat );
     LOOP

      FETCH corr_rec INTO pn_rec;
      EXIT WHEN corr_rec%NOTFOUND;
         IF NOT igf_ap_isir_corr_pkg.get_uk_for_validation (pn_rec.isir_id,
                                                            pn_rec.sar_field_number,
                                                            corr_stat)
         THEN

            igf_ap_isir_corr_pkg.update_row(
                      x_mode                    =>        'R',
                      x_rowid                   =>        pn_rec.row_id,
                      x_isirc_id                =>        pn_rec.isirc_id,
                      x_isir_id                 =>        pn_rec.isir_id,
                      x_ci_sequence_number      =>        pn_rec.ci_sequence_number,
                      x_ci_cal_type             =>        pn_rec.ci_cal_type,
                      x_sar_field_number        =>        pn_rec.sar_field_number,
                      x_original_value          =>        pn_rec.original_value,
                      x_batch_id                =>        gv_batchnum,
                      x_corrected_value         =>        pn_rec.corrected_value,
                      x_correction_status       =>        'BATCHED'
                      );
         END IF;

     END LOOP;
     CLOSE corr_rec;

     lv_curdate := TRUNC(SYSDATE);

     OPEN  get_baserec;
     FETCH get_baserec INTO base_rec;

     IF get_baserec%NOTFOUND THEN
         NULL;
     ELSE
       igf_ap_fa_base_rec_pkg.update_row(
                    x_mode                        =>        'R',
                    x_rowid                       =>        base_rec.row_id,
                    x_base_id                     =>        base_rec.base_id,
                    x_ci_cal_type                 =>        base_rec.ci_cal_type,
                    x_person_id                   =>        base_rec.person_id,
                    x_ci_sequence_number          =>        base_rec.ci_sequence_number,
                    x_org_id                      =>        base_rec.org_id,
                    x_coa_pending                 =>        base_rec.coa_pending,
                    x_verification_process_run    =>        base_rec.verification_process_run,
                    x_inst_verif_status_date      =>        base_rec.inst_verif_status_date,
                    x_manual_verif_flag           =>        base_rec.manual_verif_flag,
                    x_fed_verif_status            =>        'CORRSENT' ,
                    x_fed_verif_status_date       =>        base_rec.fed_verif_status_date,
                    x_inst_verif_status           =>        base_rec.inst_verif_status,
                    x_nslds_eligible              =>        base_rec.nslds_eligible,
                    x_ede_correction_batch_id     =>        gv_batchnum, --Modified by rbezawad on 22-Jun-2001 w.r.t. Bug ID: 1821811
                    x_fa_process_status_date      =>        base_rec.fa_process_status_date,
                    x_isir_corr_status            =>        corr_stat,
                    x_isir_corr_status_date       =>        lv_curdate,
                    x_isir_status                 =>        base_rec.isir_status,
                    x_isir_status_date            =>        base_rec.isir_status_date,
                    x_coa_code_f                  =>        base_rec.coa_code_f,
                    x_coa_code_i                  =>        base_rec.coa_code_i,
                    x_coa_f                       =>        base_rec.coa_f,
                    x_coa_i                       =>        base_rec.coa_i,
                    x_disbursement_hold           =>        base_rec.disbursement_hold,
                    x_fa_process_status           =>        base_rec.fa_process_status,
                    x_notification_status         =>        base_rec.notification_status,
                    x_notification_status_date    =>        base_rec.notification_status_date,
                    x_packaging_status            =>        base_rec.packaging_status,
                    x_packaging_status_date       =>        base_rec.packaging_status_date,
                    x_total_package_accepted      =>        base_rec.total_package_accepted,
                    x_total_package_offered       =>        base_rec.total_package_offered,
                    x_admstruct_id                =>        base_rec.admstruct_id,
                    x_admsegment_1                =>        base_rec.admsegment_1,
                    x_admsegment_2                =>        base_rec.admsegment_2,
                    x_admsegment_3                =>        base_rec.admsegment_3,
                    x_admsegment_4                =>        base_rec.admsegment_4,
                    x_admsegment_5                =>        base_rec.admsegment_5,
                    x_admsegment_6                =>        base_rec.admsegment_6,
                    x_admsegment_7                =>        base_rec.admsegment_7,
                    x_admsegment_8                =>        base_rec.admsegment_8,
                    x_admsegment_9                =>        base_rec.admsegment_9,
                    x_admsegment_10               =>        base_rec.admsegment_10,
                    x_admsegment_11               =>        base_rec.admsegment_11,
                    x_admsegment_12               =>        base_rec.admsegment_12,
                    x_admsegment_13               =>        base_rec.admsegment_13,
                    x_admsegment_14               =>        base_rec.admsegment_14,
                    x_admsegment_15               =>        base_rec.admsegment_15,
                    x_admsegment_16               =>        base_rec.admsegment_16,
                    x_admsegment_17               =>        base_rec.admsegment_17,
                    x_admsegment_18               =>        base_rec.admsegment_18,
                    x_admsegment_19               =>        base_rec.admsegment_19,
                    x_admsegment_20               =>        base_rec.admsegment_20,
                    x_packstruct_id               =>        base_rec.packstruct_id,
                    x_packsegment_1               =>        base_rec.packsegment_1,
                    x_packsegment_2               =>        base_rec.packsegment_2,
                    x_packsegment_3               =>        base_rec.packsegment_3,
                    x_packsegment_4               =>        base_rec.packsegment_4,
                    x_packsegment_5               =>        base_rec.packsegment_5,
                    x_packsegment_6               =>        base_rec.packsegment_6,
                    x_packsegment_7               =>        base_rec.packsegment_7,
                    x_packsegment_8               =>        base_rec.packsegment_8,
                    x_packsegment_9               =>        base_rec.packsegment_9,
                    x_packsegment_10              =>        base_rec.packsegment_10,
                    x_packsegment_11              =>        base_rec.packsegment_11,
                    x_packsegment_12              =>        base_rec.packsegment_12,
                    x_packsegment_13              =>        base_rec.packsegment_13,
                    x_packsegment_14              =>        base_rec.packsegment_14,
                    x_packsegment_15              =>        base_rec.packsegment_15,
                    x_packsegment_16              =>        base_rec.packsegment_16,
                    x_packsegment_17              =>        base_rec.packsegment_17,
                    x_packsegment_18              =>        base_rec.packsegment_18,
                    x_packsegment_19              =>        base_rec.packsegment_19,
                    x_packsegment_20              =>        base_rec.packsegment_20,
                    x_miscstruct_id               =>        base_rec.miscstruct_id,
                    x_miscsegment_1               =>        base_rec.miscsegment_1,
                    x_miscsegment_2               =>        base_rec.miscsegment_2,
                    x_miscsegment_3               =>        base_rec.miscsegment_3,
                    x_miscsegment_4               =>        base_rec.miscsegment_4,
                    x_miscsegment_5               =>        base_rec.miscsegment_5,
                    x_miscsegment_6               =>        base_rec.miscsegment_6,
                    x_miscsegment_7               =>        base_rec.miscsegment_7,
                    x_miscsegment_8               =>        base_rec.miscsegment_8,
                    x_miscsegment_9               =>        base_rec.miscsegment_9,
                    x_miscsegment_10              =>        base_rec.miscsegment_10,
                    x_miscsegment_11              =>        base_rec.miscsegment_11,
                    x_miscsegment_12              =>        base_rec.miscsegment_12,
                    x_miscsegment_13              =>        base_rec.miscsegment_13,
                    x_miscsegment_14              =>        base_rec.miscsegment_14,
                    x_miscsegment_15              =>        base_rec.miscsegment_15,
                    x_miscsegment_16              =>        base_rec.miscsegment_16,
                    x_miscsegment_17              =>        base_rec.miscsegment_17,
                    x_miscsegment_18              =>        base_rec.miscsegment_18,
                    x_miscsegment_19              =>        base_rec.miscsegment_19,
                    x_miscsegment_20              =>        base_rec.miscsegment_20,
                    x_prof_judgement_flg          =>        base_rec.prof_judgement_flg,
                    x_nslds_data_override_flg     =>        base_rec.nslds_data_override_flg,
                    x_target_group                =>        base_rec.target_group,
                    x_coa_fixed                   =>        base_rec.coa_fixed,
                    x_profile_status              =>        base_rec.profile_status,
                    x_profile_status_date         =>        base_rec.profile_status_date,
                    x_profile_fc                  =>        base_rec.profile_fc,
                    x_coa_pell                    =>        base_rec.coa_pell,
                    x_tolerance_amount            =>        base_rec.tolerance_amount,
                    x_manual_disb_hold            =>        base_rec.manual_disb_hold,
                    x_pell_alt_expense            =>        base_rec.pell_alt_expense,
                    x_assoc_org_num               =>        base_rec.assoc_org_num,
                    x_award_fmly_contribution_type =>       base_rec.award_fmly_contribution_type,
                    x_isir_locked_by              =>        base_rec.isir_locked_by,
                    x_adnl_unsub_loan_elig_flag   =>        base_rec.adnl_unsub_loan_elig_flag,
                    x_lock_awd_flag               =>        base_rec.lock_awd_flag,
                    x_lock_coa_flag               =>        base_rec.lock_coa_flag

                    );
     END IF;
     CLOSE get_baserec;

EXCEPTION
   WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_process_corrections.update_corr.exception','The exception is : ' || SQLERRM );
    END IF;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_AP_PROCESS_CORRECTIONS.UPDATE_CORR');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END update_corr;

PROCEDURE prepare_file( errbuf         OUT NOCOPY VARCHAR2,
                        retcode        OUT NOCOPY NUMBER,
                        p_award_year   IN         VARCHAR2,
                        p_base_id      IN         NUMBER,
                        school_type    IN         VARCHAR2,
                        p_school_code  IN         VARCHAR2,
                        eti_dest_code  IN         VARCHAR2,
                        eti_dest_num   IN         VARCHAR2
                       )
IS
/*
  ||  Created By : Sridhar
  ||  Created On : 25-NOV-2000
  ||  Purpose : Fetches the Corrected values and formats them into strings
  ||            as per EDE standards and writes them into files.This is the
  ||            main program called from Conccurrent manager.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
  ||  bkkumar         07-May-2004     Bug 3598933 Added the validation for the school code to be 6 characters.
  ||  ugummall        31-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
  ||                                  1. Added 5 new parameters namely
  ||                                     p_base_id,school_type,p_school_code,eti_dest_code,eti_dest_num
  ||                                  2. gv_dest_num populated with new passed in parameter eti_dest_num
  ||                                     g_fed_school_code populated with new passed in parameter p_school_code
  ||                                  3. Processed only those records whose baseid's associated org unit's
  ||                                     federal school code matched with passed in federal school code p_school_code.
  ||  (reverse chronological order - newest change first)
  */


-- Bug 4403807 - removed the condition isir.payment_isir      = 'Y'
     CURSOR get_cnt ( cp_corr_stat   VARCHAR2) IS
        SELECT COUNT(*)
          FROM igf_ap_isir_corr corr,
               igf_ap_isir_matched isir
         WHERE corr.correction_status = cp_corr_stat
           AND corr.isir_id           = isir.isir_id
           AND isir.system_record_type = 'ORIGINAL'
           AND isir.batch_year        = gv_batch_year ;

      CURSOR c_get_corr_isir(cp_base_id NUMBER) IS
        SELECT s_email_address
          FROM igf_ap_isir_matched_all
         WHERE system_record_type='CORRECTION'
           AND base_id = cp_base_id;

     l_get_corr_isir c_get_corr_isir%ROWTYPE;

     l_corr_stat            VARCHAR2(30) ;
     lv_corr_cnt            NUMBER DEFAULT 0;
     l_corr_status          VARCHAR2(30) ;
     x_fed_school_code      igs_or_org_alt_ids.org_alternate_id%TYPE;
     x_return_status        VARCHAR2(1);
     x_msg_data             fnd_new_messages.message_name%TYPE;
     lv_write_header_data   VARCHAR2(1) DEFAULT 'Y';
     l_process_corr_flag    VARCHAR2(1);

BEGIN
  retcode             :=  0;
  errbuf              :=  NULL;
  igf_aw_gen.set_org_id(NULL);
  gv_cal_type         :=  RTRIM(SUBSTR(p_award_year,1,10));
  gn_sequence_number  :=  TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));

  IF p_school_code IS NOT NULL THEN
    IF SUBSTR(p_school_code,1,1) NOT IN ('0','B','E','G')
     OR  LENGTH(p_school_code) <> 6 THEN -- the school code entered is invalid
       fnd_message.set_name('IGF','IGF_AP_INVALID_FED_SCH');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       RETURN;
    END IF;
  END IF;

  gv_dest_num         :=  eti_dest_num;
  g_fed_school_code   :=  p_school_code;

  /*  Get Batch Year Information to get the batch year mapping */

  OPEN  batch_yr_cur;
  FETCH batch_yr_cur INTO gv_batch_year;

  IF batch_yr_cur%NOTFOUND THEN
    gv_batch_year := '****';
    fnd_message.set_name('IGF','IGF_AP_INVALID_BATCH_YR');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;
  CLOSE batch_yr_cur;

  IF ((gv_batch_year = '5') OR (gv_batch_year = '6') OR (gv_batch_year= '7'))    THEN
   IF  gv_dest_num IS NOT NULL THEN
      fnd_message.set_name('IGF','IGF_AP_ETI_DESTNUM_NOT_BLANK');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN;
   END IF;
  ELSIF gv_dest_num IS NULL THEN
      fnd_message.set_name('IGF','IGF_AP_ETI_DESTNUM_BLANK');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN;
  END IF;

    l_corr_stat := 'READY' ;
    OPEN  get_cnt ( l_corr_stat );
    FETCH get_cnt INTO lv_corr_cnt;
    CLOSE get_cnt;

    IF lv_corr_cnt  > 0  THEN     /* if 1*/
      OPEN match_isirs(p_base_id);
      LOOP          /* loop 1*/

        gn_isir_id := NULL;
        gv_s_email := NULL;
        gv_trn_num := NULL;
        gv_ori_ssn := NULL;
        gv_ori_name := NULL;
        gv_first_name := NULL;
        gv_last_name := NULL;
        gn_baseid := NULL;
        gv_person_number := NULL;
        l_process_corr_flag := 'Y';

        FETCH match_isirs INTO  gn_isir_id,gv_s_email,gv_trn_num,gv_ori_ssn,gv_ori_name,
                                gv_first_name,gv_last_name,gn_baseid,gv_person_number;
        EXIT WHEN match_isirs%NOTFOUND;
        --
        -- Log Message indicating Person Record Processed.
        --
        fnd_file.new_line(fnd_file.log,1);
        fnd_message.set_name('IGF','IGF_AP_PROCESSING_STUDENT');
        fnd_message.set_token('PERSON_NAME',gv_first_name||'  '||gv_last_name);
        fnd_message.set_token('PERSON_NUMBER',gv_person_number);
        fnd_file.put_line(fnd_file.log,fnd_message.get);

        x_return_status := NULL;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_process_corrections.prepare_file.debug','The gn_baseid passed to get_stu_fao_code : ' || gn_baseid );
        END IF;


        -- Get baseid's (match_isirs's gn_baseid) associated org unit's federal school code.
        igf_sl_gen.get_stu_fao_code(gn_baseid, 'FED_SCH_CD', x_fed_school_code, x_return_status, x_msg_data);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_process_corrections.prepare_file.debug','The x_fed_school_code returned : ' || x_fed_school_code );
        END IF;

    /* -- Commenting the code for future refference
        IF (x_return_status = 'E') AND (NVL(x_msg_data,'X') = 'IGF_AP_STU_FED_SCH_CD_NFND') THEN
          -- skip this record and do not create the corrections and log the message.
          FND_MESSAGE.SET_NAME('IGF', x_msg_data);
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
    l_process_corr_flag := 'N';  -- Do not process Corrections

        ELSIF (x_return_status = 'E') AND (NVL(x_msg_data,'X') <> 'IGF_AP_STU_FED_SCH_CD_NFND')  THEN
          -- do not skip this record and create the corrections using the school code supplied as parameter and log the message.
          FND_MESSAGE.SET_NAME('IGF', x_msg_data);
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
          x_fed_school_code :=  p_school_code;
    l_process_corr_flag := 'Y'; -- Process Corrections

        ELSIF (x_return_status = 'S') AND (NVL(x_fed_school_code,'X') <> p_school_code) THEN
            -- skip this record and do not create the corrections with the supplied school code and log the message.
            FND_MESSAGE.SET_NAME('IGF', 'IGF_AP_FEDSCH_NOT_CONTEXT');
            FND_MESSAGE.SET_TOKEN('PERSON_NUM',gv_person_number);
            FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
            l_process_corr_flag := 'N';  -- Do not process Corrections

  ELSIF (x_return_status = 'S') AND (x_fed_school_code = p_school_code) THEN
            l_process_corr_flag := 'Y'; -- Process Corrections

  END IF;
    */

        IF (x_return_status = 'E') THEN
          -- skip this record and do not create the corrections and log the message.
          FND_MESSAGE.SET_NAME('IGF', x_msg_data);
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
          l_process_corr_flag := 'N';  -- Do not process Corrections

        ELSIF (NVL(x_fed_school_code,'X') <> p_school_code) THEN
            -- skip this record and do not create the corrections with the supplied school code and log the message.
            FND_MESSAGE.SET_NAME('IGF', 'IGF_AP_FEDSCH_NOT_CONTEXT');
            FND_MESSAGE.SET_TOKEN('PERSON_NUM',gv_person_number);
            FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
            l_process_corr_flag := 'N';  -- Do not process Corrections

  ELSE
            l_process_corr_flag := 'Y'; -- Process Corrections
  END IF;

       IF (l_process_corr_flag = 'Y') THEN  -- Process Corrections
           -- Get the corrected student's email address from the correction isir
            OPEN c_get_corr_isir(gn_baseid);
            FETCH c_get_corr_isir INTO l_get_corr_isir;
            gv_s_email := l_get_corr_isir.s_email_address;
            CLOSE c_get_corr_isir;

            OPEN corr_hold;
            FETCH corr_hold INTO lc_corr_hold;
            IF corr_hold%FOUND THEN     -- If Hold Exists check
              fnd_message.set_name('IGF','IGF_AP_CORR_HOLD_EXIST');
              fnd_message.set_token('PERSON_NUMBER',gv_person_number);
              fnd_file.put_line(fnd_file.log,fnd_message.get);
            ELSE -- No Hold so proceed with corrections
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_process_corrections.prepare_file.debug','Before calling fill_string ');
              END IF;
              gn_std_cnt := gn_std_cnt + 1;
              start_record;
              l_corr_status := 'READY' ;
              OPEN corrs ( l_corr_status ) ;
              LOOP
                FETCH corrs INTO lc_corr_cur;
                EXIT WHEN corrs%NOTFOUND;
                gn_cnt  := corrs%ROWCOUNT;
                IF MOD(gn_cnt,12) = 0 THEN
                  fill_string(lc_corr_cur.sar_field_number, lc_corr_cur.corrected_value);
                  -- write header record only if there are corrections to send.
                  IF(lv_write_header_data = 'Y')THEN
                    -- write header only if the batch year is 3 or 4
                    IF gv_batch_year = '3' OR gv_batch_year = '4' THEN
                      write_file('HEADER');
                      lv_write_header_data := 'N';
                    END IF;
                  END IF;
                  write_file('DATA');
                  start_record;
                ELSE
                  fill_string(lc_corr_cur.sar_field_number, lc_corr_cur.corrected_value);
                END IF;
              END LOOP;

              IF MOD(gn_cnt,12) <> 0 THEN
                IF(lv_write_header_data = 'Y')THEN
                  -- write header only if the batch year is 3 or 4
                  IF gv_batch_year = '3' OR gv_batch_year = '4' THEN
                    write_file('HEADER');
                    lv_write_header_data := 'N';
                  END IF;
                END IF;
                write_file('DATA');
              END IF;

              update_corr;
              CLOSE corrs;
            END IF; -- If Hold Exists check
            CLOSE corr_hold;
       END IF;  -- End process correction check


      END LOOP;         /* end of loop 1*/
      CLOSE match_isirs;
      IF(lv_write_header_data = 'N')THEN
        -- write trailer only if the batch year is 3 or 4
        IF gv_batch_year = '3' OR gv_batch_year = '4' THEN
          write_file('TRAILER');
        END IF;
      END IF;
      COMMIT;
    ELSE
      fnd_message.set_name ('IGF','IGF_AP_NO_ISIR_FOR_BATCH');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;             /* end of if 1*/
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    retcode := 2;
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_process_corrections.prepare_file.exception','The exception is : ' || SQLERRM );
    END IF;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    errbuf  := fnd_message.get;
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.add;
END  prepare_file;

END igf_ap_process_corrections;

/
