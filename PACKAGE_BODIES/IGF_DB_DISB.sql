--------------------------------------------------------
--  DDL for Package Body IGF_DB_DISB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_DISB" AS
/* $Header: IGFDB01B.pls 120.14 2006/08/10 16:48:28 museshad ship $ */

-----------------------------------------------------------------------------------
--  Purpose    :        Disbursement Process evaludates disbursements for
--                      various checks in Fund Setup so that these can be
--                      picked up by SF Integration Process which will
--                      credit / debit the disbursement.
--
-----------------------------------------------------------------------------------
--  Who        When           What
-----------------------------------------------------------------------------------
-- museshad   10-Aug-2006     Bug 5337555. Build FA 163. TBH Impact.
-------------------------------------------------------------------------------------------
-- museshad   26-Apr-2006     Bug 4930323. When Pell award is cancelled, -ve disbursements
--                            were getting inserted for Full Participant. Added validation
--                            to stop this in revert_disb.
-------------------------------------------------------------------------------------------
-- museshad   14-Apr-2006     Bug 5042136. Origination Fee, Guarantor Fee, Interest Rebate
--                            Amount should become 0 when a disb gets cancelled.
--                            Fixed this in revert_disb().
-------------------------------------------------------------------------------------------
-- bvisvana   13-Sept-2005    SBCC Bug # 4575843 - FFELP Disburse Bug. Promissory Note check for CL 4 included.
-------------------------------------------------------------------------------------------
--ridas       08-Nov-2004     Bug 3021287 If the profile_value = 'DISBURSED'
--                            then updating COA at the student level
-----------------------------------------------------------------------------------
--ayedubat    13-OCT-04       FA 149 COD-XML Standards build bug # 3416863
--                            Changed the TBH calls of the packages: igf_aw_awd_disb_pkg and igf_db_awd_disb_dtl_pkg
-----------------------------------------------------------------------------------
-- veramach    Sep 2004       Bug 3871976
--                            Added ability to handle dynamic person id groups
-----------------------------------------------------------------------------------
-- veramach    July 2004      FA 151 HR integration (bug # 3709292)
--                            Impact of obsoleting columns from igf_aw_awd_disb_pkg
-----------------------------------------------------------------------------------
-- veramach   11-Dec-2003     #3184891 Removed calls to igf_ap_gen.write_log and added common logging
-----------------------------------------------------------------------------------
-- sjadhav     3-Dec-2003     FA 131 Build changes, Bug 3252832
--                            Modified Pell Elig Logic
--                            Modified Att Type Compare Logic
--                            Modified Pell Amount comparision Logic
-----------------------------------------------------------------------------------
-- sjadhav     22-Nov-2003    FA 125 Multiple Distribution methods
--                            Added log_parameters
--                            Modified Person ID Group Logic
--                            Modified log file structure
-----------------------------------------------------------------------------------
-- veramach    12-NOV-2003    FA 125 Multiple Distribution methods
--                            As the attendance_type criteria is moved from fund
--                            manager to
--                            terms level, validations are changed accordingly
-----------------------------------------------------------------------------------
-- sjadhav     01-Aug-2003    Bug 3062062
--                            Added igf_gr_pell.pell_calc call to compare award
--                            and pell amounts
-----------------------------------------------------------------------------------
--  nsidana    16-Apr-2003    Bug 2738181
--                            Added new message hasving just one parameter to correct
--                            the bug and make the message more appropriate.
-----------------------------------------------------------------------------------
--  sjadhav    26-Mar-2003    Bug 2863960
--                            Modified routine create_actual to populate disb gross
--                            amount in the adjustment table with disb accepted
--                            amount
-----------------------------------------------------------------------------------
--  sjadhav    22-Feb-2003    FA117 Build - Bug 2758823
--                            Modified the logic to set disbursement activity type
--                            based on the adjustment sequence number
-----------------------------------------------------------------------------------
--  sjadhav    04-Feb-2003    FA116 Build - Bug 2758812
-----------------------------------------------------------------------------------
--  sjadhav    08-Nov-2002    added igf_aw_gen_005 call to check acad holds -
--                            FA101 Build
--  brajendr   18-Oct-2002    Bug : 2591643
--                            Modified the chk_todo_result for FA104 -
--                            To Do Enhancements
-----------------------------------------------------------------------------------
--  sjadhav    29-May-2002    Bug : 2387496
--                            Added get_cut_off_dt call
-----------------------------------------------------------------------------------
--  sjadhav                   Bug : 2360119
--                            1. Credit Points API change.
--                            2. Added excpetion gross_amt_zero
-----------------------------------------------------------------------------------
--  sjadhav    07-Jan-2002    Creation of the Process
-----------------------------------------------------------------------------------


lb_log_detail    BOOLEAN := FALSE;     -- Process Should log in detail or not
ln_plan_disb     NUMBER  := 0;         -- Number of Planned Disbursements Processed
ln_act_disb      NUMBER  := 0;         -- Number of Planned Disbursements made Actual
ln_enfr_disb     NUMBER  := 0;         -- Number of Actual Disbursements Processed for enforcement
                                       -- verification checks
ln_enfr_disb_p   NUMBER  := 0;         -- Number of Actual Disbursements passed enforcement verification checks

gross_amt_zero   EXCEPTION;

lv_locking_success VARCHAR2(1);


FUNCTION get_cl_version(p_loan_number igf_sl_loans.loan_number%TYPE)
RETURN VARCHAR2
IS
/* Created By : bvisvana
   Created On : 13-Sept-2005
   Purpose    : To get the CL Version of an FFELP loan (SBCC Bug # 4575843)
   Change History: (reverse chronological order - newest change first)
   Who          When            What
   --------------------------------------------------------------------------------------------------
*/
l_cl_version  VARCHAR2(20);
l_rel_code    VARCHAR2(50);
CURSOR cur_get_loan_dtls(cp_loan_number igf_sl_loans.loan_number%TYPE)
IS  SELECT
      base_id, ci_cal_type, ci_sequence_number
    FROM igf_sl_loans_v WHERE loan_number = cp_loan_number;

CURSOR cur_get_rel_code(cp_loan_number igf_sl_loans.loan_number%TYPE)
IS SELECT relationship_cd
   FROM igf_sl_lor_v WHERE loan_number =  cp_loan_number;

get_loan_dtls_rec cur_get_loan_dtls%ROWTYPE;
BEGIN
    l_cl_version := NULL;
    l_rel_code   := NULL;
    OPEN cur_get_loan_dtls(cp_loan_number => p_loan_number);
    FETCH cur_get_loan_dtls INTO get_loan_dtls_rec;

    OPEN cur_get_rel_code(cp_loan_number => p_loan_number);
    FETCH cur_get_rel_code INTO l_rel_code;

    l_cl_version := igf_sl_gen.get_cl_version(p_ci_cal_type     => get_loan_dtls_rec.ci_cal_type,        -- IN
                                              p_ci_seq_num      => get_loan_dtls_rec.ci_sequence_number, -- IN
                                              p_relationship_cd =>l_rel_code,                            -- IN
                                              p_base_id         => get_loan_dtls_rec.base_id);           -- IN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.get_cl_version.debug','get_cl_version.l_cl_version:'||l_cl_version);
    END IF;
    RETURN l_cl_version;
END get_cl_version;

PROCEDURE log_parameters(p_alt_code      VARCHAR2,
                         p_run_for       VARCHAR2,
                         p_per_grp_id    NUMBER,
                         p_base_id       NUMBER,
                         p_fund_id       NUMBER,
                         p_log_det       VARCHAR2)
IS
--
--  Created By : sjadhav
--  Created On : 21-Nov-2003
--  Purpose : This process log the parameters in the log file
--  Known limitations, enhancements or remarks :
--  Change History :
--  Who             When            What
--  (reverse chronological order - newest change first)
--

-- Get the values from the lookups


    CURSOR cur_get_fund_code (p_fund_id NUMBER)
    IS
    SELECT fund_code
    FROM
    igf_aw_fund_mast
    WHERE
    fund_id = p_fund_id;

    get_fund_code_rec cur_get_fund_code%ROWTYPE;

    CURSOR cur_get_grp_name (p_per_grp_id NUMBER)
    IS
    SELECT group_cd
    FROM   igs_pe_persid_group_all
    WHERE  group_id = p_per_grp_id;

    get_grp_name_rec     cur_get_grp_name%ROWTYPE;

    CURSOR c_get_parameters
    IS
    SELECT meaning, lookup_code
      FROM igf_lookups_view
     WHERE lookup_type = 'IGF_GE_PARAMETERS'
       AND lookup_code IN ('PARAMETER_PASS',
                           'AWARD_YEAR',
                           'RUN_FOR',
                           'PERSON_ID_GROUP',
                           'PERSON_NUMBER',
                           'FUND_CODE',
                           'LOG_DETAIL'
                           );

    parameter_rec           c_get_parameters%ROWTYPE;

    lv_parameter_pass       VARCHAR2(80);
    lv_award_year           VARCHAR2(80);
    lv_run_for              VARCHAR2(80);
    lv_run_for_m            VARCHAR2(80);
    lv_person_id_group      VARCHAR2(80);
    lv_person_number        VARCHAR2(80);
    lv_fund_code            VARCHAR2(80);
    lv_log_detail           VARCHAR2(80);



BEGIN

     OPEN c_get_parameters;
     LOOP
          FETCH c_get_parameters INTO  parameter_rec;
          EXIT WHEN c_get_parameters%NOTFOUND;

          IF parameter_rec.lookup_code ='PARAMETER_PASS' THEN
            lv_parameter_pass  := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='AWARD_YEAR' THEN
            lv_award_year      := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='RUN_FOR' THEN
            lv_run_for         := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='PERSON_ID_GROUP' THEN
            lv_person_id_group := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='PERSON_NUMBER' THEN
            lv_person_number   := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='FUND_CODE' THEN
            lv_fund_code       := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='LOG_DETAIL' THEN
            lv_log_detail      := TRIM(parameter_rec.meaning);
          END IF;

     END LOOP;
     CLOSE c_get_parameters;

     IF p_fund_id IS NOT NULL THEN
        OPEN  cur_get_fund_code(p_fund_id);
        FETCH cur_get_fund_code INTO get_fund_code_rec;
        CLOSE cur_get_fund_code;
     END IF;

     IF p_per_grp_id IS NOT NULL THEN
         OPEN  cur_get_grp_name(p_per_grp_id);
         FETCH cur_get_grp_name INTO get_grp_name_rec;
         CLOSE cur_get_grp_name;
     END IF;

     IF    p_run_for = 'F' THEN
           lv_run_for_m := igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','FUND');
     ELSIF p_run_for = 'P' THEN
           lv_run_for_m   := lv_person_id_group;
     ELSIF p_run_for = 'S' THEN
           lv_run_for_m   := igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','STUDENT');
     END IF;

     fnd_file.new_line(fnd_file.log,1);
     fnd_file.put_line(fnd_file.log, lv_parameter_pass); --------------Parameters Passed--------------
     fnd_file.new_line(fnd_file.log,1);
     fnd_file.put_line(fnd_file.log, RPAD(lv_award_year,40)       || ' : '|| p_alt_code);
     fnd_file.put_line(fnd_file.log, RPAD(lv_run_for,40)          || ' : '|| lv_run_for_m);
     fnd_file.put_line(fnd_file.log, RPAD(lv_person_id_group,40)  || ' : '|| get_grp_name_rec.group_cd);
     fnd_file.put_line(fnd_file.log, RPAD(lv_person_number,40)    || ' : '|| igf_gr_gen.get_per_num(p_base_id));
     fnd_file.put_line(fnd_file.log, RPAD(lv_fund_code,40)        || ' : '|| get_fund_code_rec.fund_code);
     fnd_file.put_line(fnd_file.log, RPAD(lv_log_detail,40)       || ' : '|| igf_aw_gen.lookup_desc('IGF_AP_YES_NO',p_log_det));

     fnd_file.new_line(fnd_file.log,1);
     fnd_file.put_line(fnd_file.log, '--------------------------------------------------------');
     fnd_file.new_line(fnd_file.log,1);


  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_db_disb.log_parameters.exception','Exception:'||SQLERRM);
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_DB_DISB.LOG_PARAMETERS');
      igs_ge_msg_stack.add;

END log_parameters;

FUNCTION get_cut_off_dt ( p_ld_seq_num  igs_ca_inst_all.sequence_number%TYPE,
                          p_disb_date   igf_aw_awd_disb_all.disb_date%TYPE)
RETURN DATE
IS

--
-- sjadhav,May.30.2002.
-- Bug 2387496
--
-- This function will return the cut off date
-- to be paased to enrolment api for getting
-- poin-in-time credit points
--

     CURSOR cur_get_eff_date ( p_ld_seq_num igs_ca_inst_all.sequence_number%TYPE )
     IS
     SELECT
     start_dt,end_dt
     FROM
     igs_ca_inst
     WHERE
     p_ld_seq_num = sequence_number;

     get_eff_date_rec  cur_get_eff_date%ROWTYPE;

     ld_cut_off_dt  igf_aw_awd_disb_all.disb_date%TYPE;
     ld_system_dt   igf_aw_awd_disb_all.disb_date%TYPE;
     ld_start_dt    igf_aw_awd_disb_all.disb_date%TYPE;
     ld_end_dt      igf_aw_awd_disb_all.disb_date%TYPE;

BEGIN

     ld_system_dt   :=   TRUNC(SYSDATE);
     ld_cut_off_dt  :=   ld_system_dt;

     OPEN  cur_get_eff_date ( p_ld_seq_num );
     FETCH cur_get_eff_date INTO get_eff_date_rec;
     CLOSE cur_get_eff_date;

     ld_start_dt := TRUNC(get_eff_date_rec.start_dt);
     ld_end_dt   := TRUNC(get_eff_date_rec.end_dt);

-- 1.

     IF  p_disb_date < ld_system_dt THEN
         IF  p_disb_date >= ld_start_dt AND p_disb_date <= ld_end_dt THEN
             ld_cut_off_dt := ld_system_dt;
         END IF;
     END IF;

-- 2.

     IF  p_disb_date < ld_start_dt THEN
         IF ld_system_dt > ld_start_dt AND ld_system_dt < ld_end_dt THEN
            ld_cut_off_dt := ld_system_dt;
         END IF;
     END IF;

-- 3.

     IF  p_disb_date < ld_system_dt AND ld_system_dt < ld_start_dt THEN
         ld_cut_off_dt := ld_start_dt;
     END IF;


-- 4.

     IF  p_disb_date > ld_end_dt THEN
         ld_cut_off_dt := ld_end_dt;
     END IF;

     RETURN ld_cut_off_dt;


        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_DB_DISB.GET_CUT_OFF_DT '||SQLERRM);
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;


END get_cut_off_dt;

FUNCTION get_fund_desc ( p_fund_id      igf_aw_fund_mast_all.fund_id%TYPE)
RETURN VARCHAR2
IS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       Returns fund code + description of the fund id passed
--
--------------------------------------------------------------------------------------------

        CURSOR cur_fund_des ( p_fund_id   igf_aw_fund_mast_all.fund_id%TYPE)
        IS
        SELECT fund_code  fdesc
        FROM   igf_aw_fund_mast
        WHERE
        fund_id  = p_fund_id;

        fund_des_rec    cur_fund_des%ROWTYPE;

BEGIN

        OPEN  cur_fund_des(p_fund_id);
        FETCH cur_fund_des INTO fund_des_rec;

        IF    cur_fund_des%NOTFOUND THEN
              CLOSE cur_fund_des;
              RETURN NULL;
        ELSE
              CLOSE cur_fund_des;
              RETURN fund_des_rec.fdesc;
        END IF;


        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_DB_DISB.GET_FUND_DESC ' ||SQLERRM);
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END get_fund_desc;


FUNCTION per_in_fa ( p_person_id            igf_ap_fa_base_rec_all.person_id%TYPE,
                     p_ci_cal_type          VARCHAR2,
                     p_ci_sequence_number   NUMBER,
                     p_base_id     OUT NOCOPY NUMBER
                    )
RETURN VARCHAR2
IS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       Returns person number for the person id passed
--
--------------------------------------------------------------------------------------------

        CURSOR cur_get_pers_num ( p_person_id  igf_ap_fa_base_rec_all.person_id%TYPE)
        IS
        SELECT person_number
        FROM   igs_pe_person_base_v
        WHERE
        person_id  = p_person_id;

        get_pers_num_rec   cur_get_pers_num%ROWTYPE;

        CURSOR cur_get_base (p_cal_type        igs_ca_inst_all.cal_type%TYPE,
                             p_sequence_number igs_ca_inst_all.sequence_number%TYPE,
                             p_person_id       igf_ap_fa_base_rec_all.person_id%TYPE)
        IS
        SELECT
        base_id
        FROM
        igf_ap_fa_base_rec
        WHERE
        person_id          = p_person_id AND
        ci_cal_type        = p_cal_type  AND
        ci_sequence_number = p_sequence_number;

BEGIN

        OPEN  cur_get_pers_num(p_person_id);
        FETCH cur_get_pers_num  INTO get_pers_num_rec;

        IF    cur_get_pers_num%NOTFOUND THEN
              CLOSE cur_get_pers_num;
              RETURN NULL;
        ELSE
              CLOSE cur_get_pers_num;
              OPEN  cur_get_base(p_ci_cal_type,p_ci_sequence_number,p_person_id);
              FETCH cur_get_base INTO p_base_id;
              CLOSE cur_get_base;

              RETURN get_pers_num_rec.person_number;

        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_DB_DISB.PER_IN_FA '||SQLERRM);
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END per_in_fa;

PROCEDURE create_actual ( p_row_id   ROWID,
                          p_lb_flag  BOOLEAN,
                          p_lb_force BOOLEAN,
                          p_fund_id  igf_aw_fund_mast_all.fund_id%TYPE)
AS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This routine creates an actual disbursement
--
--------------------------------------------------------------------------------------------

        CURSOR cur_chk_adj (p_award_id   igf_aw_award_all.award_id%TYPE,
                            p_disb_num   igf_aw_awd_disb_all.disb_num%TYPE)
        IS
        SELECT NVL(MAX(disb_seq_num),0) + 1 disb_seq_num
        FROM
        igf_db_awd_disb_dtl  dtl
        WHERE
        dtl.award_id = p_award_id AND
        dtl.disb_num = p_disb_num;

        chk_adj_rec  cur_chk_adj%ROWTYPE;


        CURSOR cur_get_adisb (p_row_id ROWID)
        IS
        SELECT *
        FROM
        igf_aw_awd_disb adisb
        WHERE
        adisb.row_id = p_row_id
        FOR UPDATE OF elig_status NOWAIT;

        get_adisb_rec   cur_get_adisb%ROWTYPE;

        disb_dtl_rec    igf_db_awd_disb_dtl%ROWTYPE;


        CURSOR cur_update_fund (p_fund_id  igf_aw_fund_mast_all.fund_id%TYPE)
        IS
        SELECT *
        FROM
        igf_aw_fund_mast
        WHERE
        fund_id = p_fund_id
        FOR UPDATE OF total_disbursed NOWAIT;

        update_fund_rec  cur_update_fund%ROWTYPE;

        lv_rowid        ROWID;

BEGIN

        OPEN  cur_get_adisb (p_row_id);
        FETCH cur_get_adisb INTO get_adisb_rec;
        CLOSE cur_get_adisb;

        OPEN  cur_update_fund(p_fund_id);
        FETCH cur_update_fund INTO update_fund_rec;
        CLOSE cur_update_fund;

-- Update transaction type to 'actual'

        get_adisb_rec.trans_type    := 'A';

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.create_actual.debug','set transaction type to A');
        END IF;

-- These assignements are needed, if we are making a cancelled disbursement an actual one

        get_adisb_rec.disb_net_amt  :=  NVL(get_adisb_rec.disb_accepted_amt,get_adisb_rec.disb_gross_amt) -
                                        NVL(get_adisb_rec.fee_1,0)          -
                                        NVL(get_adisb_rec.fee_2,0)          +
                                        NVL(get_adisb_rec.fee_paid_1,0)     +
                                        NVL(get_adisb_rec.fee_paid_2,0)     +
                                        NVL(get_adisb_rec.int_rebate_amt,0); --This has been added in the bug 2421613

        IF  NVL(get_adisb_rec.disb_accepted_amt,0) = 0 THEN
            RAISE gross_amt_zero;
        END IF;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.create_actual.debug','get_adisb_rec.disb_accepted_amt:'||get_adisb_rec.disb_accepted_amt);
        END IF;

-- If it is a forced disbursement, set the eligibility status to forced
        IF p_lb_force = TRUE THEN
          get_adisb_rec.elig_status := 'F';
          get_adisb_rec.elig_status_date := TRUNC(SYSDATE);
        ELSE
          get_adisb_rec.elig_status := 'Y';
          get_adisb_rec.elig_status_date := TRUNC(SYSDATE);
        END IF;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.create_actual.debug','get_adisb_rec.elig_status:'||get_adisb_rec.elig_status);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.create_actual.debug','get_adisb_rec.elig_status_date:'||get_adisb_rec.elig_status_date);
        END IF;

-- Check if any adjustment record is present for this award

        OPEN  cur_chk_adj (get_adisb_rec.award_id,get_adisb_rec.disb_num);
        FETCH cur_chk_adj INTO chk_adj_rec;
        CLOSE cur_chk_adj;

-- Create transaction record in disbursement detail table

        disb_dtl_rec.award_id           :=  get_adisb_rec.award_id;
        disb_dtl_rec.disb_num           :=  get_adisb_rec.disb_num;
        disb_dtl_rec.disb_seq_num       :=  chk_adj_rec.disb_seq_num;
        disb_dtl_rec.disb_gross_amt     :=  get_adisb_rec.disb_accepted_amt;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.create_actual.debug','get_adisb_rec.award_id:'||get_adisb_rec.award_id);
        END IF;

        IF  NVL(disb_dtl_rec.disb_gross_amt,0) = 0 THEN
            RAISE gross_amt_zero;
        END IF;

        disb_dtl_rec.fee_1              :=  get_adisb_rec.fee_1;
        disb_dtl_rec.fee_2              :=  get_adisb_rec.fee_2;
        disb_dtl_rec.disb_net_amt       :=  get_adisb_rec.disb_net_amt;
        disb_dtl_rec.disb_date          :=  get_adisb_rec.disb_date;
        disb_dtl_rec.fee_paid_1         :=  get_adisb_rec.fee_paid_1;
        disb_dtl_rec.fee_paid_2         :=  get_adisb_rec.fee_paid_2;
        disb_dtl_rec.sf_status          :=  'R';  -- Ready to Send
        disb_dtl_rec.sf_status_date     :=  TRUNC(SYSDATE);

        -- Obsolte the columns as part of FA 149 enhancement
        disb_dtl_rec.disb_status      := NULL;
        disb_dtl_rec.disb_status_date := NULL;

        IF  disb_dtl_rec.disb_seq_num  = 1 THEN
          disb_dtl_rec.disb_activity :=  'D';
          disb_dtl_rec.disb_adj_amt  :=  0;
        ELSE
          disb_dtl_rec.disb_activity :=  'A';
          disb_dtl_rec.disb_adj_amt  :=  get_adisb_rec.disb_net_amt;
        END IF;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.create_actual.debug','disb_dtl_rec.disb_activity:'||disb_dtl_rec.disb_activity);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.create_actual.debug','disb_dtl_rec.disb_adj_amt:'||disb_dtl_rec.disb_adj_amt);
        END IF;

        lv_rowid := NULL;
        fnd_message.set_name('IGF','IGF_DB_CREATE_ACT');
        fnd_message.set_token('AWARD_ID',TO_CHAR(disb_dtl_rec.award_id));
        fnd_message.set_token('DISB_NUM',TO_CHAR(disb_dtl_rec.disb_num));
        fnd_file.put_line(fnd_file.log,RPAD(' ',28) ||fnd_message.get);
        fnd_file.new_line(fnd_file.log,1);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.create_actual.debug','creating actual disbursment with disb_gross_amt '|| disb_dtl_rec.disb_gross_amt);
        END IF;
        igf_db_awd_disb_dtl_pkg.insert_row(x_rowid              =>   lv_rowid,
                                           x_award_id           =>   disb_dtl_rec.award_id        ,
                                           x_disb_num           =>   disb_dtl_rec.disb_num        ,
                                           x_disb_seq_num       =>   disb_dtl_rec.disb_seq_num    ,
                                           x_disb_gross_amt     =>   disb_dtl_rec.disb_gross_amt  ,
                                           x_fee_1              =>   disb_dtl_rec.fee_1           ,
                                           x_fee_2              =>   disb_dtl_rec.fee_2           ,
                                           x_disb_net_amt       =>   disb_dtl_rec.disb_net_amt    ,
                                           x_disb_adj_amt       =>   disb_dtl_rec.disb_adj_amt    ,
                                           x_disb_date          =>   disb_dtl_rec.disb_date       ,
                                           x_fee_paid_1         =>   disb_dtl_rec.fee_paid_1      ,
                                           x_fee_paid_2         =>   disb_dtl_rec.fee_paid_2      ,
                                           x_disb_activity      =>   disb_dtl_rec.disb_activity   ,
                                           x_disb_batch_id      =>   NULL,
                                           x_disb_ack_date      =>   NULL,
                                           x_booking_batch_id   =>   NULL,
                                           x_booked_date        =>   NULL,
                                           x_disb_status        =>   NULL,
                                           x_disb_status_date   =>   NULL,
                                           x_sf_status          =>   disb_dtl_rec.sf_status       ,
                                           x_sf_status_date     =>   disb_dtl_rec.sf_status_date  ,
                                           x_sf_invoice_num     =>   disb_dtl_rec.sf_invoice_num  ,
                                           x_spnsr_credit_id    =>   disb_dtl_rec.spnsr_credit_id ,
                                           x_spnsr_charge_id    =>   disb_dtl_rec.spnsr_charge_id ,
                                           x_sf_credit_id       =>   disb_dtl_rec.sf_credit_id    ,
                                           x_error_desc         =>   disb_dtl_rec.error_desc      ,
                                           x_mode               =>   'R',
                                           x_notification_date  =>   disb_dtl_rec.notification_date,
                                           x_interest_rebate_amt =>  NULL,
					   x_ld_cal_type	 =>  get_adisb_rec.ld_cal_type,
					   x_ld_sequence_number  =>  get_adisb_rec.ld_sequence_number
                                           );




        ln_act_disb     :=      1 + ln_act_disb;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.create_actual.debug','updating igf_aw_awd_disb for award '||get_adisb_rec.award_id);
        END IF;
        igf_aw_awd_disb_pkg.update_row( x_rowid                     =>    get_adisb_rec.row_id             ,
                                        x_award_id                  =>    get_adisb_rec.award_id           ,
                                        x_disb_num                  =>    get_adisb_rec.disb_num           ,
                                        x_tp_cal_type               =>    get_adisb_rec.tp_cal_type        ,
                                        x_tp_sequence_number        =>    get_adisb_rec.tp_sequence_number ,
                                        x_disb_gross_amt            =>    get_adisb_rec.disb_gross_amt     ,
                                        x_fee_1                     =>    get_adisb_rec.fee_1              ,
                                        x_fee_2                     =>    get_adisb_rec.fee_2              ,
                                        x_disb_net_amt              =>    get_adisb_rec.disb_net_amt       ,
                                        x_disb_date                 =>    get_adisb_rec.disb_date          ,
                                        x_trans_type                =>    get_adisb_rec.trans_type         ,
                                        x_elig_status               =>    get_adisb_rec.elig_status        ,
                                        x_elig_status_date          =>    get_adisb_rec.elig_status_date   ,
                                        x_affirm_flag               =>    get_adisb_rec.affirm_flag        ,
                                        x_hold_rel_ind              =>    get_adisb_rec.hold_rel_ind       ,
                                        x_manual_hold_ind           =>    get_adisb_rec.manual_hold_ind    ,
                                        x_disb_status               =>    get_adisb_rec.disb_status        ,
                                        x_disb_status_date          =>    get_adisb_rec.disb_status_date   ,
                                        x_late_disb_ind             =>    get_adisb_rec.late_disb_ind      ,
                                        x_fund_dist_mthd            =>    get_adisb_rec.fund_dist_mthd     ,
                                        x_prev_reported_ind         =>    get_adisb_rec.prev_reported_ind  ,
                                        x_fund_release_date         =>    get_adisb_rec.fund_release_date  ,
                                        x_fund_status               =>    get_adisb_rec.fund_status        ,
                                        x_fund_status_date          =>    get_adisb_rec.fund_status_date   ,
                                        x_fee_paid_1                =>    get_adisb_rec.fee_paid_1         ,
                                        x_fee_paid_2                =>    get_adisb_rec.fee_paid_2         ,
                                        x_cheque_number             =>    get_adisb_rec.cheque_number      ,
                                        x_ld_cal_type               =>    get_adisb_rec.ld_cal_type        ,
                                        x_ld_sequence_number        =>    get_adisb_rec.ld_sequence_number ,
                                        x_disb_accepted_amt         =>    get_adisb_rec.disb_accepted_amt  ,
                                        x_disb_paid_amt             =>    get_adisb_rec.disb_paid_amt      ,
                                        x_rvsn_id                   =>    get_adisb_rec.rvsn_id            ,
                                        x_int_rebate_amt            =>    get_adisb_rec.int_rebate_amt     ,
                                        x_force_disb                =>    get_adisb_rec.force_disb         ,
                                        x_min_credit_pts            =>    get_adisb_rec.min_credit_pts     ,
                                        x_disb_exp_dt               =>    get_adisb_rec.disb_exp_dt        ,
                                        x_verf_enfr_dt              =>    get_adisb_rec.verf_enfr_dt       ,
                                        x_fee_class                 =>    get_adisb_rec.fee_class          ,
                                        x_show_on_bill              =>    get_adisb_rec.show_on_bill       ,
                                        x_attendance_type_code      =>    get_adisb_rec.attendance_type_code,
                                        x_base_attendance_type_code =>    get_adisb_rec.base_attendance_type_code,
                                        x_mode                      =>    'R',
                                        x_payment_prd_st_date       =>    get_adisb_rec.payment_prd_st_date,
                                        x_change_type_code          =>    get_adisb_rec.change_type_code,
                                        x_fund_return_mthd_code     =>    get_adisb_rec.fund_return_mthd_code,
                                        x_direct_to_borr_flag       =>    get_adisb_rec.direct_to_borr_flag
                                        );

        EXCEPTION

        WHEN  gross_amt_zero THEN
        RAISE gross_amt_zero;

        WHEN app_exception.record_lock_exception THEN
        RAISE;

        WHEN OTHERS THEN
        fnd_message.clear;

        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_DB_DISB.CREATE_ACTUAL '||SQLERRM);
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.initialize;
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END create_actual;


PROCEDURE revert_disb ( p_row_id ROWID,
                        p_flag   VARCHAR2,
                        p_fund_type VARCHAR2)

AS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This routine cancels an actual disbursement
--
--Change History   :
--Bug :- 2272349 Cancel Award Routines
--Who                 When                What
--museshad          26-Apr-2006         Bug# 4930323.
--                                      When Pell award is cancelled, -ve disbursements
--                                      were getting inserted even for Full Participant.
--                                      Added code to stop this. -ve disbursements must
--                                      get inserted only for phase-in participant.
--museshad          14-Apr-2006         Bug 5042136.
--                                      Origination Fee, Guarantor Fee, Interest Rebate Amount
--                                      should become 0 when a disb gets cancelled. Fixed this.
--bvisvana          05-Jul-2005         FA 140 - Disb Gross amount set to ZERO when the award is cancelled
--                                      If Award cancelled, both offered and accepted amount is ZERO and hence the disb gross amount
--                                      is also ZERO. (Added l_disb_gross_amt)
--mesriniv          10-may-2002         Have added code to add a new negative disb for PELL
--                                      whenever the Pell Disb is to be cancelled and
--                                      has  already been reported
--------------------------------------------------------------------------------------------

        ORIG_STATUS     EXCEPTION;

        --Added for update clause while working for Bug 2272349

        CURSOR cur_get_adisb (p_row_id ROWID)
        IS
        SELECT *
        FROM    igf_aw_awd_disb adisb
        WHERE
        adisb.row_id = p_row_id
        FOR UPDATE OF disb_num NOWAIT;

        get_adisb_rec   cur_get_adisb%ROWTYPE;

-- Cursor to get RFMS Origination Details
        CURSOR cur_grant_orig(p_award_id  igf_aw_award.award_id%TYPE)
        IS
        SELECT  origination_id, orig_action_code
        FROM    igf_gr_rfms
        WHERE
        award_id = p_award_id
        FOR UPDATE OF origination_id NOWAIT;

        grant_orig_rec  cur_grant_orig%ROWTYPE;

-- Cursor to get RFMS Disbursement Details
        CURSOR cur_grant_disb(p_origination_id  igf_gr_rfms_all.origination_id%TYPE,
                              p_disb_num        igf_aw_awd_disb.disb_num%TYPE)
        IS
        SELECT  disb_ack_act_status
        FROM    igf_gr_rfms_disb
        WHERE
        origination_id = p_origination_id AND
        disb_ref_num   = p_disb_num;

        grant_disb_rec  cur_grant_disb%ROWTYPE;

-- Cursor to get the last RFMS Disbursement Date
        CURSOR cur_max_disb(p_award_id  igf_aw_award_all.award_id%TYPE)
        IS
        SELECT  disb_date,disb_num
        FROM    igf_aw_awd_disb adisb
        WHERE
        adisb.award_id = p_award_id AND
        disb_num   =
        ( SELECT MAX(disb_num) FROM igf_aw_awd_disb WHERE
          award_id = p_award_id);

        max_disb_rec  cur_max_disb%ROWTYPE;

--
-- Cursor to retrieve Reported but not yet Acknowledged Direct Loan Adjustements
--
        CURSOR cur_reported_adj (p_award_id  igf_aw_awd_disb_all.award_id%TYPE,
                                 p_disb_num  igf_aw_awd_disb_all.disb_num%TYPE)
        IS
        SELECT
        COUNT(disb_seq_num) adj_cnt
        FROM
        igf_db_awd_disb_dtl
        WHERE
        award_id = p_award_id AND
        disb_num = p_disb_num AND
        disb_status = 'S';

        reported_adj_rec cur_reported_adj%ROWTYPE;

--
-- Cursor to retrieve award status
--
        CURSOR c_get_awd_status (p_award_id  igf_aw_award_all.award_id%TYPE)
        IS
        SELECT  award_status
        FROM    igf_aw_award_all
        WHERE   award_id = p_award_id;

        awd_status_rec c_get_awd_status%ROWTYPE;

        CURSOR c_get_awd_det (cp_awd_id igf_aw_award_all.award_id%TYPE)
        IS
          SELECT  fmast.ci_cal_type, fmast.ci_sequence_number
          FROM    igf_aw_fund_mast_all fmast,
                  igf_aw_award_all awd
          WHERE   fmast.fund_id = awd.fund_id AND
                  awd.award_id = cp_awd_id;

        awd_det_rec c_get_awd_det%ROWTYPE;

        lb_create_new         BOOLEAN  :=  FALSE;
        lv_rowid              ROWID;
        l_disb_accepted_amt   igf_aw_awd_disb.disb_accepted_amt%TYPE;
        l_disb_net_amt        igf_aw_awd_disb.disb_net_amt%TYPE;
        l_disb_gross_amt      igf_aw_awd_disb.disb_gross_amt%TYPE;
        l_orig_fee            igf_aw_awd_disb_all.fee_1%TYPE;
        l_guar_fee            igf_aw_awd_disb_all.fee_2%TYPE;
        l_int_rebate_amt      igf_aw_awd_disb_all.int_rebate_amt%TYPE;


BEGIN

        lb_create_new := FALSE;


        OPEN  cur_get_adisb (p_row_id);
        FETCH cur_get_adisb INTO get_adisb_rec;
        CLOSE cur_get_adisb;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.revert_disb.debug','p_fund_type:'||p_fund_type);
        END IF;

        --If the award is PELL
        IF p_fund_type='P' THEN

          OPEN  cur_grant_orig(get_adisb_rec.award_id);
          FETCH cur_grant_orig INTO grant_orig_rec;
          CLOSE cur_grant_orig;

          OPEN  cur_grant_disb(grant_orig_rec.origination_id,get_adisb_rec.disb_num);
          FETCH cur_grant_disb INTO grant_disb_rec;
          CLOSE cur_grant_disb;

        END IF;


        IF p_fund_type IN ('D','F')  THEN
          IF igf_sl_award.chk_loan_upd_lock(get_adisb_rec.award_id) = 'TRUE' THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.revert_disb.debug','chk_loan_upd_lock returned TRUE');
            END IF;
            RAISE ORIG_STATUS;
          END IF;
        END IF;

        IF p_fund_type = 'D'  THEN
          OPEN  cur_reported_adj(get_adisb_rec.award_id,get_adisb_rec.disb_num);
          FETCH cur_reported_adj INTO reported_adj_rec;
          CLOSE cur_reported_adj;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.revert_disb.debug','reported_adj_rec.adj_cnt:'||reported_adj_rec.adj_cnt);
          END IF;
          IF  reported_adj_rec.adj_cnt > 0 THEN
            RAISE ORIG_STATUS;
          END IF;
        END IF;

        IF p_fund_type = 'P' THEN
          IF grant_orig_rec.origination_id IS NOT NULL THEN
            --Checking if Originated and Sent

            -- Get ci_cal_type and sequence_number
            OPEN c_get_awd_det(cp_awd_id => get_adisb_rec.award_id);
            FETCH c_get_awd_det INTO awd_det_rec;
            CLOSE c_get_awd_det;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.revert_disb.debug','grant_orig_rec.origination_id:'||grant_orig_rec.origination_id);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.revert_disb.debug','grant_orig_rec.orig_action_code:'||grant_orig_rec.orig_action_code);
            END IF;
            IF grant_orig_rec.orig_action_code = 'S' THEN
              RAISE ORIG_STATUS;
            ELSIF NVL(grant_disb_rec.disb_ack_act_status,'*') = 'S'  THEN
              RAISE ORIG_STATUS;
              --Which means the disbursements never went out NOCOPY of OFA to external processor
              --for those disb we need not create a new adjustment record
            ELSIF (
                    NVL(grant_disb_rec.disb_ack_act_status,'*') NOT IN ('R','N') AND
                    (NOT igf_sl_dl_validation.check_full_participant(p_ci_cal_type => awd_det_rec.ci_cal_type,
                                                                   p_ci_sequence_number => awd_det_rec.ci_sequence_number,
                                                                   p_fund_type => 'PELL'))
                  ) THEN
              lb_create_new := TRUE;
            END IF;
          END IF;
        END IF;

        get_adisb_rec.elig_status       := p_flag;
        get_adisb_rec.elig_status_date  := TRUNC(SYSDATE);
        get_adisb_rec.trans_type        := 'C';


        --
        --  Get the award status
        --
        OPEN c_get_awd_status(get_adisb_rec.award_id);
        FETCH c_get_awd_status INTO awd_status_rec;
        CLOSE c_get_awd_status;

        --
        -- While Updating the Disbursements ,if it is PELL and Create New Disb then we should not
        -- update the disb amts,we should only Cancel the disb.
        -- Otherwise we should update as 0-- Bug 2272349
        --

        IF p_fund_type='P' THEN
          IF lb_create_new =TRUE THEN
            -- Phase-in Participant
            l_disb_accepted_amt      := get_adisb_rec.disb_accepted_amt;
            l_disb_net_amt           := get_adisb_rec.disb_net_amt;
            l_disb_gross_amt         := get_adisb_rec.disb_gross_amt;
            l_orig_fee               := get_adisb_rec.fee_1;
            l_guar_fee               := get_adisb_rec.fee_2;
            l_int_rebate_amt         := get_adisb_rec.int_rebate_amt;
          ELSE
            -- Full Participant
            l_disb_accepted_amt      := 0;
            l_disb_net_amt           := 0;
            l_orig_fee               := 0;
            l_guar_fee               := 0;
            l_int_rebate_amt         := 0;

            IF (awd_status_rec.award_status IS NOT NULL) AND (awd_status_rec.award_status = 'CANCELLED') THEN
              l_disb_gross_amt         := 0;
            ELSE
              l_disb_gross_amt         := get_adisb_rec.disb_gross_amt;
            END IF;
          END IF;

        ELSIF p_fund_type <> 'P' THEN
          l_disb_accepted_amt      := 0;
          l_disb_net_amt           := 0;

          IF (awd_status_rec.award_status IS NOT NULL) AND (awd_status_rec.award_status = 'CANCELLED') THEN
            l_disb_gross_amt         := 0;
          ELSE
            l_disb_gross_amt         := get_adisb_rec.disb_gross_amt;
          END IF;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.revert_disb.debug','l_disb_accepted_amt:'||l_disb_accepted_amt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.revert_disb.debug','l_disb_net_amt:'||l_disb_net_amt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.revert_disb.debug','updating the disbursement '||get_adisb_rec.disb_num||' as cancelled');
        END IF;

        --update the current disbursement as Cancelled
        igf_aw_awd_disb_pkg.update_row
                              (x_rowid                        =>    get_adisb_rec.row_id             ,
                               x_award_id                     =>    get_adisb_rec.award_id           ,
                               x_disb_num                     =>    get_adisb_rec.disb_num           ,
                               x_tp_cal_type                  =>    get_adisb_rec.tp_cal_type        ,
                               x_tp_sequence_number           =>    get_adisb_rec.tp_sequence_number ,
                               x_disb_gross_amt               =>    NVL(l_disb_gross_amt,0)          ,
                               x_fee_1                        =>    NVL(l_orig_fee,0)                ,
                               x_fee_2                        =>    NVL(l_guar_fee,0)                ,
                               x_disb_net_amt                 =>    NVL(l_disb_net_amt,0)            ,
                               x_disb_date                    =>    get_adisb_rec.disb_date          ,
                               x_trans_type                   =>    get_adisb_rec.trans_type         ,
                               x_elig_status                  =>    get_adisb_rec.elig_status        ,
                               x_elig_status_date             =>    get_adisb_rec.elig_status_date   ,
                               x_affirm_flag                  =>    get_adisb_rec.affirm_flag        ,
                               x_hold_rel_ind                 =>    get_adisb_rec.hold_rel_ind       ,
                               x_manual_hold_ind              =>    get_adisb_rec.manual_hold_ind    ,
                               x_disb_status                  =>    get_adisb_rec.disb_status        ,
                               x_disb_status_date             =>    get_adisb_rec.disb_status_date   ,
                               x_late_disb_ind                =>    get_adisb_rec.late_disb_ind      ,
                               x_fund_dist_mthd               =>    get_adisb_rec.fund_dist_mthd     ,
                               x_prev_reported_ind            =>    get_adisb_rec.prev_reported_ind  ,
                               x_fund_release_date            =>    get_adisb_rec.fund_release_date  ,
                               x_fund_status                  =>    get_adisb_rec.fund_status        ,
                               x_fund_status_date             =>    get_adisb_rec.fund_status_date   ,
                               x_fee_paid_1                   =>    get_adisb_rec.fee_paid_1         ,
                               x_fee_paid_2                   =>    get_adisb_rec.fee_paid_2         ,
                               x_cheque_number                =>    get_adisb_rec.cheque_number      ,
                               x_ld_cal_type                  =>    get_adisb_rec.ld_cal_type        ,
                               x_ld_sequence_number           =>    get_adisb_rec.ld_sequence_number ,
                               x_disb_accepted_amt            =>    NVL(l_disb_accepted_amt,0)       ,
                               x_disb_paid_amt                =>    get_adisb_rec.disb_paid_amt      ,
                               x_rvsn_id                      =>    get_adisb_rec.rvsn_id            ,
                               x_int_rebate_amt               =>    NVL(l_int_rebate_amt,0)          ,
                               x_force_disb                   =>    get_adisb_rec.force_disb         ,
                               x_min_credit_pts               =>    get_adisb_rec.min_credit_pts     ,
                               x_disb_exp_dt                  =>    get_adisb_rec.disb_exp_dt        ,
                               x_verf_enfr_dt                 =>    get_adisb_rec.verf_enfr_dt       ,
                               x_fee_class                    =>    get_adisb_rec.fee_class          ,
                               x_show_on_bill                 =>    get_adisb_rec.show_on_bill       ,
                               x_attendance_type_code         =>    get_adisb_rec.attendance_type_code,
                               x_base_attendance_type_code    =>    get_adisb_rec.base_attendance_type_code,
                               x_mode                         =>    'R',
                               x_payment_prd_st_date          =>    get_adisb_rec.payment_prd_st_date,
                               x_change_type_code             =>    get_adisb_rec.change_type_code,
                               x_fund_return_mthd_code        =>    get_adisb_rec.fund_return_mthd_code,
                               x_direct_to_borr_flag          =>    get_adisb_rec.direct_to_borr_flag
                               );

  --Create a new adjusted disb only for PELL ,only one adjusted record and not for others
        IF lb_create_new THEN
          OPEN  cur_max_disb (get_adisb_rec.award_id);
          FETCH cur_max_disb INTO max_disb_rec;
          CLOSE cur_max_disb;

          get_adisb_rec.disb_date            := 1 + max_disb_rec.disb_date;
          get_adisb_rec.disb_num             := 1 + max_disb_rec.disb_num;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.revert_disb.debug','get_adisb_rec.disb_date:'||get_adisb_rec.disb_date);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.revert_disb.debug','get_adisb_rec.disb_num:'||get_adisb_rec.disb_num);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.revert_disb.debug','inserting to igf_aw_awd_disb with award_id '||get_adisb_rec.award_id);
          END IF;
          -- table handler for igf_aw_awd_disb table, in case of pell disbursements
          -- should insert / update records in igf_gr_rfms_disb table
          igf_aw_awd_disb_pkg.insert_row( x_rowid                     =>    lv_rowid             ,
                                          x_award_id                  =>    get_adisb_rec.award_id           ,
                                          x_disb_num                  =>    get_adisb_rec.disb_num           ,
                                          x_tp_cal_type               =>    get_adisb_rec.tp_cal_type        ,
                                          x_tp_sequence_number        =>    get_adisb_rec.tp_sequence_number ,
                                          x_disb_gross_amt            =>    -1 * get_adisb_rec.disb_gross_amt,--Negative value
                                          x_fee_1                     =>    get_adisb_rec.fee_1              ,
                                          x_fee_2                     =>    get_adisb_rec.fee_2              ,
                                          x_disb_net_amt              =>    -1 * get_adisb_rec.disb_net_amt  ,--Negative value
                                          x_disb_date                 =>    get_adisb_rec.disb_date          ,
                                          x_trans_type                =>    get_adisb_rec.trans_type         ,
                                          x_elig_status               =>    get_adisb_rec.elig_status        ,
                                          x_elig_status_date          =>    get_adisb_rec.elig_status_date   ,
                                          x_affirm_flag               =>    get_adisb_rec.affirm_flag        ,
                                          x_hold_rel_ind              =>    get_adisb_rec.hold_rel_ind       ,
                                          x_manual_hold_ind           =>    get_adisb_rec.manual_hold_ind    ,
                                          x_disb_status               =>    get_adisb_rec.disb_status        ,
                                          x_disb_status_date          =>    get_adisb_rec.disb_status_date   ,
                                          x_late_disb_ind             =>    get_adisb_rec.late_disb_ind      ,
                                          x_fund_dist_mthd            =>    get_adisb_rec.fund_dist_mthd     ,
                                          x_prev_reported_ind         =>    get_adisb_rec.prev_reported_ind  ,
                                          x_fund_release_date         =>    get_adisb_rec.fund_release_date  ,
                                          x_fund_status               =>    get_adisb_rec.fund_status        ,
                                          x_fund_status_date          =>    get_adisb_rec.fund_status_date   ,
                                          x_fee_paid_1                =>    get_adisb_rec.fee_paid_1         ,
                                          x_fee_paid_2                =>    get_adisb_rec.fee_paid_2         ,
                                          x_cheque_number             =>    get_adisb_rec.cheque_number      ,
                                          x_ld_cal_type               =>    get_adisb_rec.ld_cal_type        ,
                                          x_ld_sequence_number        =>    get_adisb_rec.ld_sequence_number ,
                                          x_disb_accepted_amt         =>    -1 * get_adisb_rec.disb_accepted_amt  ,--Negative value
                                          x_disb_paid_amt             =>    get_adisb_rec.disb_paid_amt      ,
                                          x_rvsn_id                   =>    get_adisb_rec.rvsn_id            ,
                                          x_int_rebate_amt            =>    get_adisb_rec.int_rebate_amt     ,
                                          x_force_disb                =>    get_adisb_rec.force_disb         ,
                                          x_min_credit_pts            =>    get_adisb_rec.min_credit_pts     ,
                                          x_disb_exp_dt               =>    get_adisb_rec.disb_exp_dt        ,
                                          x_verf_enfr_dt              =>    get_adisb_rec.verf_enfr_dt       ,
                                          x_fee_class                 =>    get_adisb_rec.fee_class          ,
                                          x_show_on_bill              =>    get_adisb_rec.show_on_bill       ,
                                          x_attendance_type_code      =>    get_adisb_rec.attendance_type_code,
                                          x_base_attendance_type_code =>    get_adisb_rec.base_attendance_type_code,
                                          x_mode                      =>    'R',
                                          x_payment_prd_st_date       =>    get_adisb_rec.payment_prd_st_date,
                                          x_change_type_code          =>    get_adisb_rec.change_type_code,
                                          x_fund_return_mthd_code     =>    get_adisb_rec.fund_return_mthd_code,
                                          x_direct_to_borr_flag       =>    get_adisb_rec.direct_to_borr_flag
                                          );
        END IF; --for lb_create_new

        EXCEPTION
          WHEN app_exception.record_lock_exception THEN
            RAISE;

          WHEN ORIG_STATUS THEN
            fnd_message.set_name('IGF','IGF_AW_LOAN_SENT');
            fnd_file.put_line(fnd_file.log,RPAD(' ',26) ||fnd_message.get);

          WHEN OTHERS THEN
            fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGF_DB_DISB.REVERT_DISB '||SQLERRM);
            fnd_file.put_line(fnd_file.log,SQLERRM);
            igs_ge_msg_stack.add;
            app_exception.raise_exception;

END revert_disb;


PROCEDURE delete_pays
AS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This routine truncates pays only data used in
--                              previous run of eligibility checks
--
--------------------------------------------------------------------------------------------
        CURSOR cur_pays_prg IS
        SELECT
        db.rowid row_id,db.*
        FROM
        igf_db_pays_prg_t db;

        pays_prg_rec cur_pays_prg%ROWTYPE;

BEGIN
  OPEN  cur_pays_prg;
  LOOP
    FETCH cur_pays_prg INTO pays_prg_rec;
    EXIT WHEN cur_pays_prg%NOTFOUND;
    igf_db_pays_prg_t_pkg.delete_row(pays_prg_rec.row_id);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.delete_pays.debug','deleted from igf_db_pays_prg_t');
    END IF;
  END LOOP;
  CLOSE cur_pays_prg;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_DB_DISB.DELETE_PAYS '||SQLERRM);
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END  delete_pays;


FUNCTION chk_todo_result(p_message_name  OUT NOCOPY VARCHAR2,
                         p_fund_id       IN  igf_aw_fund_mast_all.fund_id%TYPE,
                         p_base_id       IN  igf_ap_fa_base_rec_all.base_id%TYPE
                        ) RETURN BOOLEAN AS
     /*
     ||  Created By : sjadhav
     ||  Created On : 07-Jan-2002
     ||  Purpose    : This routine checks for app process statuses.
     ||
     ||  Known limitations, enhancements or remarks :
     ||  Change History : (reverse chronological order - newest change first)
     ||  Who           When            What
     ||  brajendr      18-Oct-2002     Bug : 2591643
     ||                                Modified the Code for FA104- To Do Enhancements
     */



  CURSOR c_student_details( cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
  IS
  SELECT manual_disb_hold,
         fa_process_status
    FROM igf_ap_fa_base_rec
   WHERE base_id  = cp_base_id;

  CURSOR c_fund_details( cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
  IS
  SELECT ver_app_stat_override
    FROM igf_aw_fund_mast
   WHERE fund_id = cp_fund_id;

  CURSOR c_chk_verif_status( cp_base_id igf_ap_fa_base_rec.base_id%TYPE)
  IS
  SELECT fed_verif_status
    FROM igf_ap_fa_base_rec fab
   WHERE fab.base_id = p_base_id
   AND   fab.fed_verif_status IN ('ACCURATE','CALCULATED','NOTVERIFIED','NOTSELECTED',
                                  'REPROCESSED','TOLERANCE','WAIVED');
  CURSOR c_fnd_todo(
                    cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                    cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
                    cp_status  igf_ap_td_item_inst_all.status%TYPE,
                    cp_inactive igf_ap_td_item_inst_all.inactive_flag%TYPE
                   ) IS
    SELECT 'x'
      FROM igf_aw_fund_mast_all fmast,
           igf_aw_fund_td_map_all fndtd,
           igf_ap_td_item_inst_all tdinst,
           igf_ap_td_item_mst_all tdmst
     WHERE fmast.fund_id = cp_fund_id
       AND tdinst.base_id = cp_base_id
       AND fndtd.fund_id = fmast.fund_id
       AND fndtd.item_sequence_number = tdinst.item_sequence_number
       AND fndtd.item_sequence_number = tdmst.todo_number
       AND NVL(tdmst.career_item,'N') = 'N'
       AND tdinst.status <> cp_status
       AND tdinst.inactive_flag <> cp_inactive
    UNION
    SELECT 'x'
      FROM igf_aw_fund_mast_all fmast,
           igf_aw_fund_td_map_all fndtd,
           igf_ap_td_item_inst_v tdinst,
           igf_ap_td_item_mst_all tdmst,
           igf_ap_fa_base_rec_all fa
     WHERE fmast.fund_id = cp_fund_id
       AND fa.base_id = cp_base_id
       AND fa.person_id = tdinst.person_id
       AND fndtd.fund_id = fmast.fund_id
       AND fndtd.item_sequence_number = tdinst.item_sequence_number
       AND fndtd.item_sequence_number = tdmst.todo_number
       AND NVL(tdmst.career_item,'N') = 'Y'
       AND tdinst.status <> cp_status
       AND tdinst.inactive_flag <> cp_inactive;

  lc_student_details_rec   c_student_details%ROWTYPE;
  lc_fund_details_rec      c_fund_details%ROWTYPE;
  lc_chk_verif_status_rec  c_chk_verif_status%ROWTYPE;
  l_fnd_todo               c_fnd_todo%ROWTYPE;

  lb_result BOOLEAN;

BEGIN

  lb_result := TRUE;

  OPEN c_fund_details( p_fund_id);
  FETCH c_fund_details INTO lc_fund_details_rec;
  CLOSE c_fund_details;

  lc_chk_verif_status_rec := NULL;
  OPEN c_chk_verif_status( p_base_id);
  FETCH c_chk_verif_status INTO lc_chk_verif_status_rec;
  CLOSE c_chk_verif_status;

  -- Return TRUE if Fund has "Verification and Applicaitons status Override" is present, else check for other status
  IF NVL(lc_fund_details_rec.ver_app_stat_override,'N') = 'Y' THEN
    /*
      bug 4747156 - check for incomplete to do items attached to the fund
      these have to be complete.
    */
    OPEN c_fnd_todo(p_base_id,p_fund_id,'COM','Y');
    FETCH c_fnd_todo INTO l_fnd_todo;
    IF c_fnd_todo%FOUND THEN
      CLOSE c_fnd_todo;
      p_message_name := 'IGF_DB_FAIL_TODO';
      lb_result      := FALSE;
    ELSE
      CLOSE c_fnd_todo;
      p_message_name := NULL;
      lb_result      := TRUE;
    END IF;
  ELSE
    OPEN  c_student_details( p_base_id);
    FETCH c_student_details INTO lc_student_details_rec;
    CLOSE c_student_details;

    --
    -- Return FALSE if "Disbursement Hold for manual Re-Award" is present
    --
    IF NVL(lc_student_details_rec.manual_disb_hold,'N') = 'Y' THEN
      p_message_name := 'IGF_DB_FAIL_DISB_HOLD_RE_AWD';
      lb_result      := FALSE;
    --
    -- Return FALSE if students Application Process is not completed i.e. stuatus is not "Applicaiton Complete"
    --
    ELSIF lc_student_details_rec.fa_process_status <> 'COMPLETE' THEN
      p_message_name := 'IGF_DB_FAIL_APPL_NOT_CMPLT';
      lb_result      := FALSE;
    --
    -- Return TRUE if students has "Verification Status" as "Termial" status.
    --
    ELSIF lc_chk_verif_status_rec.fed_verif_status IS NULL THEN
      p_message_name := 'IGF_DB_FAIL_VER_NOT_TERMINAL';
      lb_result      := FALSE;
    ELSE
      /*
        bug 4747156 - check for incomplete to do items attached to the fund
        these have to be complete.
      */
      OPEN c_fnd_todo(p_base_id,p_fund_id,'COM','Y');
      FETCH c_fnd_todo INTO l_fnd_todo;
      IF c_fnd_todo%FOUND THEN
        CLOSE c_fnd_todo;
        p_message_name := 'IGF_DB_FAIL_TODO';
        lb_result      := FALSE;
      ELSE
        CLOSE c_fnd_todo;
      END IF;
    END IF;
  END IF;
  RETURN lb_result;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_DB_DISB.CHK_TODO_RESULT '||SQLERRM);
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END chk_todo_result;


PROCEDURE insert_pays_prg_uts(p_base_id          igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_acad_cal_type    igs_ca_inst_all.cal_type%TYPE,
                              p_acad_ci_seq_num  igs_ca_inst_all.sequence_number%TYPE)
AS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This routine inserts Pays Only Programs, Units into
--                              temporary table igf_db_pays_prg_t
--
--------------------------------------------------------------------------------------------


-- Get all the teaching periods for the academic calendar instance
        CURSOR cur_get_acad_tp (p_acad_ci_cal_type        igs_ca_inst_all.cal_type%TYPE,
                                p_acad_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE)
        IS
        SELECT
        sub_cal_type             tp_cal_type,
        sub_ci_sequence_number   tp_sequence_number
        FROM
        igs_ca_inst_rel cr_1,
        igs_ca_type ct_1,
        igs_ca_type ct_2
        WHERE
        ct_1.cal_type               = cr_1.sup_cal_type  AND
        ct_1.s_cal_cat              = 'ACADEMIC'         AND
        ct_2.cal_type               = cr_1.sub_cal_type  AND
        ct_2.s_cal_cat              = 'TEACHING'         AND
        cr_1.sup_cal_type         = p_acad_ci_cal_type AND
        cr_1.sup_ci_sequence_number = p_acad_ci_sequence_number;

        get_acad_tp_rec  cur_get_acad_tp%ROWTYPE;

-- Get all the programs,unit attempts in which student has 'enrolled'

        CURSOR cur_get_att(p_person_id          igf_ap_fa_base_rec_all.person_id%TYPE,
                            p_acad_cal_type      igs_ca_inst_all.cal_type%TYPE,
                            p_tp_cal_type        igs_ca_inst_all.cal_type%TYPE,
                            p_tp_sequence_number igs_ca_inst_all.sequence_number%TYPE)
        IS
        SELECT
        pg.course_cd       prg_course_cd,
        pg.version_number  prg_ver_num,
        su.unit_cd         unit_course_cd ,
        su.version_number  unit_ver_num
        FROM
        igs_en_su_attempt    su,
        igs_en_stdnt_ps_att  pg
        WHERE
        su.person_id               = p_person_id AND
        pg.person_id               = su.person_id AND
        su.unit_attempt_status IN ('COMPLETED','ENROLLED','DUPLICATE') AND
        su.cal_type                = p_tp_cal_type        AND
        su.ci_sequence_number      = p_tp_sequence_number AND
        pg.cal_type                = p_acad_cal_type      AND
        pg.course_cd(+)            = su.course_cd;

        get_att_rec    cur_get_att%ROWTYPE;

        lv_acad_cal_type        igs_ca_inst_all.cal_type%TYPE;
        ln_acad_seq_num         igs_ca_inst_all.sequence_number%TYPE;
        lv_acad_alt_code        igs_ca_inst_all.alternate_code%TYPE;

        dbpays_rec igf_db_pays_prg_t%ROWTYPE;
        lv_rowid   ROWID;

BEGIN
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.insert_pays_prg_uts.debug','p_acad_cal_type:'||p_acad_cal_type);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.insert_pays_prg_uts.debug','p_acad_ci_seq_num:'||p_acad_ci_seq_num);
  END IF;
  FOR get_acad_tp_rec IN  cur_get_acad_tp(
                                          p_acad_cal_type,
                                          p_acad_ci_seq_num
                                         )
  LOOP
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.insert_pays_prg_uts.debug','igf_gr_gen.get_person_id('||p_base_id||'):'||igf_gr_gen.get_person_id(p_base_id));
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.insert_pays_prg_uts.debug','get_acad_tp_rec.tp_cal_type:'||get_acad_tp_rec.tp_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.insert_pays_prg_uts.debug','get_acad_tp_rec.tp_sequence_number:'||get_acad_tp_rec.tp_sequence_number);
    END IF;
    FOR get_att_rec IN cur_get_att(
                                   igf_gr_gen.get_person_id(p_base_id),
                                   p_acad_cal_type,
                                   get_acad_tp_rec.tp_cal_type,
                                   get_acad_tp_rec.tp_sequence_number
                                  )
    LOOP
      dbpays_rec.base_id              :=      p_base_id;
      dbpays_rec.program_cd           :=      get_att_rec.prg_course_cd;
      dbpays_rec.prg_ver_num          :=      get_att_rec.prg_ver_num;
      dbpays_rec.unit_cd              :=      get_att_rec.unit_course_cd;
      dbpays_rec.unit_ver_num         :=      get_att_rec.unit_ver_num;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.insert_pays_prg_uts.debug','dbpays_rec.program_cd:'||dbpays_rec.program_cd);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.insert_pays_prg_uts.debug','dbpays_rec.prg_ver_num:'||dbpays_rec.prg_ver_num);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.insert_pays_prg_uts.debug','dbpays_rec.unit_cd:'||dbpays_rec.unit_cd);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.insert_pays_prg_uts.debug','dbpays_rec.unit_ver_num:'||dbpays_rec.unit_ver_num);
      END IF;

      lv_rowid                        :=      NULL;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.insert_pays_prg_uts.debug','inserting to igf_db_pays_prg_t');
      END IF;
      igf_db_pays_prg_t_pkg.insert_row(
                                        x_rowid         =>   lv_rowid,
                                        x_dbpays_id     =>   dbpays_rec.dbpays_id,
                                        x_base_id       =>   dbpays_rec.base_id,
                                        x_program_cd    =>   dbpays_rec.program_cd,
                                        x_prg_ver_num   =>   dbpays_rec.prg_ver_num,
                                        x_unit_cd       =>   dbpays_rec.unit_cd,
                                        x_unit_ver_num  =>   dbpays_rec.unit_ver_num,
                                        x_mode          =>   'R'
                                      );
    END LOOP;
  END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_DB_DISB.INSERT_PAYS_PRG_UTS '||SQLERRM);
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END insert_pays_prg_uts;


FUNCTION chk_pays_prg( p_fund_id             igf_aw_fund_mast_all.fund_id%TYPE,
                       p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE)
RETURN BOOLEAN
AS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This routine Pays Only Program Check
--
--------------------------------------------------------------------------------------------

--
-- This cursor will retreive records which are
-- common to temp table ( igf_db_pays_prg_t ) and fund setup for pays only program
-- If there are no records, the check is failed else passed
--

        CURSOR cur_std_pays(p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
        IS
        SELECT
        program_cd,
        prg_ver_num
        FROM
        igf_db_pays_prg_t
        WHERE
        base_id     =    p_base_id

        INTERSECT

        SELECT
        course_cd,
        version_number
        FROM
        igf_aw_fund_prg_v  fprg
        WHERE
        fprg.fund_id = p_fund_id;

        std_pays_rec  cur_std_pays%ROWTYPE;

--
-- This cursor will retreive records from fund setup for pays only program
-- If there are no records, then the pays only prog check is passed
--
        CURSOR cur_fund_pprg (p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
        IS
        SELECT
        course_cd,
        version_number
        FROM
        igf_aw_fund_prg_v  fprg
        WHERE
        fprg.fund_id = p_fund_id;

        fund_pprg_rec cur_fund_pprg%ROWTYPE;


BEGIN

        OPEN  cur_fund_pprg(p_fund_id);
        FETCH cur_fund_pprg INTO fund_pprg_rec;

        IF   cur_fund_pprg%NOTFOUND THEN
             CLOSE cur_fund_pprg;
             RETURN TRUE;
        ELSIF cur_fund_pprg%FOUND THEN
              CLOSE cur_fund_pprg;

              OPEN cur_std_pays(p_base_id,p_fund_id);
              FETCH cur_std_pays INTO std_pays_rec;

              IF    cur_std_pays%FOUND THEN
                   CLOSE cur_std_pays;
                   RETURN TRUE;
              ELSIF cur_std_pays%NOTFOUND THEN
                   CLOSE cur_std_pays;
                   RETURN FALSE;
              END IF;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_DB_DISB.CHK_PAYS_PRG '||SQLERRM);
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END chk_pays_prg;

FUNCTION chk_pays_uts( p_fund_id             igf_aw_fund_mast_all.fund_id%TYPE,
                       p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE)
RETURN BOOLEAN
AS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This routine Pays Only Units Check
--                              previous run of eligibility checks
--
--------------------------------------------------------------------------------------------
--
-- This cursor will retreive records which are
-- common to temp table ( igf_db_pays_prg_t ) and fund setup for pays only units
-- If there are no records, the check is failed else passed
--

        CURSOR cur_std_pays(p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
        IS
        SELECT
        unit_cd,
        unit_ver_num
        FROM
        igf_db_pays_prg_t
        WHERE
        base_id     =    p_base_id

        INTERSECT

        SELECT
        unit_cd,
        version_number
        FROM
        igf_aw_fund_unit_v  funit
        WHERE
        funit.fund_id = p_fund_id;

        std_pays_rec  cur_std_pays%ROWTYPE;
--
-- This cursor will retreive records from fund setup for pays only program
-- If there are no records, then the pays only prog check is passed
--
        CURSOR cur_fund_unit (p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
        IS
        SELECT
        unit_cd,
        version_number
        FROM
        igf_aw_fund_unit_v  funit
        WHERE
        funit.fund_id = p_fund_id;

        fund_unit_rec cur_fund_unit%ROWTYPE;

BEGIN

        OPEN  cur_fund_unit(p_fund_id);
        FETCH cur_fund_unit INTO fund_unit_rec;

        IF   cur_fund_unit%NOTFOUND THEN
             CLOSE cur_fund_unit;
             RETURN TRUE;

        ELSIF cur_fund_unit%FOUND THEN
              CLOSE cur_fund_unit;

              OPEN cur_std_pays(p_base_id,p_fund_id);
              FETCH cur_std_pays INTO std_pays_rec;

              IF    cur_std_pays%FOUND THEN
                   CLOSE cur_std_pays;
                   RETURN TRUE;
              ELSIF cur_std_pays%NOTFOUND THEN
                   CLOSE cur_std_pays;
                   RETURN FALSE;
              END IF;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_DB_DISB.CHK_PAYS_UTS '||SQLERRM);
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END chk_pays_uts;


FUNCTION chk_fed_elig( p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                       p_fund_type           VARCHAR2)

RETURN BOOLEAN
AS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This routine is for Federal Eligibility Check
--
--------------------------------------------------------------------------------------------

--Get the eligibility status of the student for an active ISIR for the context Award Year

    CURSOR cur_fedl_elig (p_base_id igf_ap_fa_base_rec_all.base_id%TYPE) IS
    SELECT isir.nslds_match_flag,
           fabase.nslds_data_override_flg
      FROM igf_ap_isir_matched isir,
           igf_ap_fa_base_rec_all fabase
     WHERE isir.base_id = p_base_id
       AND isir.active_isir = 'Y'
       AND isir.base_id = fabase.base_id;

    fedl_elig_rec   cur_fedl_elig%ROWTYPE;

    lv_return_status VARCHAR2(30);

BEGIN

    OPEN  cur_fedl_elig(p_base_id);
    FETCH cur_fedl_elig INTO fedl_elig_rec;
    CLOSE cur_fedl_elig;

    IF    p_fund_type IN ('D','F') AND
          (NVL(fedl_elig_rec.nslds_match_flag,'N')  =  '1' OR fedl_elig_rec.nslds_data_override_flg ='Y')  THEN
            RETURN TRUE;

    ELSIF p_fund_type = 'P' THEN
            --
            -- Use the new wrapper to determine Pell Elig
            -- FA131 Check
            --
            igf_gr_pell_calc.pell_elig(p_base_id,lv_return_status);
            IF NVL(lv_return_status,'*') <> 'E' THEN
             RETURN TRUE;
            ELSE
             RETURN FALSE;
            END IF;
    ELSIF p_fund_type IN ('G','C') THEN
            RETURN TRUE;
    ELSE
            RETURN FALSE;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_DB_DISB.CHK_FED_ELIG '||SQLERRM);
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END chk_fed_elig;

FUNCTION  chk_fclass_result(p_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_fund_id            igf_aw_fund_mast_all.fund_id%TYPE,
                            p_ld_cal_type        igs_ca_inst_all.cal_type%TYPE,
                            p_ld_sequence_number igs_ca_inst_all.sequence_number%TYPE)
RETURN BOOLEAN

AS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This Process evaluates student for fee class
--
--------------------------------------------------------------------------------------------


  p_fee_cal_type                igs_ca_inst.cal_type%TYPE;
  p_fee_ci_sequence_number      igs_ca_inst.sequence_number%TYPE;
  p_message_name                fnd_new_messages.message_name%TYPE;

--
-- This cursor will retreive records from fund setup for pays only Fee Class
-- If there are no records, then the pays only fee class check is passed
--
  CURSOR cur_fund_fcls (p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
  IS
  SELECT
  fee_class
  FROM
  igf_aw_fund_feeclas
  WHERE
  fund_id = p_fund_id;

  fund_fcls_rec cur_fund_fcls%ROWTYPE;

--
-- This cursor will return common fee classes from
-- fund setup and persons charges
--

  CURSOR cur_fee_cls ( p_fund_id                  igf_aw_fund_mast_all.fund_id%TYPE,
                       p_fee_cal_type             igs_ca_inst.cal_type%TYPE,
                       p_fee_ci_sequence_number   igs_ca_inst.sequence_number%TYPE,
                       p_person_id                igf_ap_fa_base_rec_all.person_id%TYPE)
  IS
  SELECT
  fee_class
  FROM
  igf_aw_fund_feeclas
  WHERE
  fund_id = p_fund_id

  INTERSECT

  SELECT
  fee_class
  FROM
  igs_fi_inv_igf_v
  WHERE
  fee_cal_type            =  p_fee_cal_type AND
  fee_ci_sequence_number  =  p_fee_ci_sequence_number AND
  person_id               =  p_person_id;

  fee_cls_rec  cur_fee_cls%ROWTYPE;

  lv_bool BOOLEAN;

BEGIN

  OPEN  cur_fund_fcls(p_fund_id);
  FETCH cur_fund_fcls INTO fund_fcls_rec;

  IF    cur_fund_fcls%NOTFOUND THEN
        CLOSE  cur_fund_fcls;
        RETURN TRUE;

  ELSIF cur_fund_fcls%FOUND THEN
        CLOSE  cur_fund_fcls;
        lv_bool := igs_fi_gen_001.finp_get_lfci_reln(p_ld_cal_type,
                                          p_ld_sequence_number,
                                          'LOAD',
                                          p_fee_cal_type,
                                          p_fee_ci_sequence_number,
                                          p_message_name);

        IF p_message_name is NULL THEN

                OPEN  cur_fee_cls ( p_fund_id,
                                    p_fee_cal_type,
                                    p_fee_ci_sequence_number,
                                    igf_gr_gen.get_person_id(p_base_id));

                FETCH cur_fee_cls INTO fee_cls_rec;

                IF    cur_fee_cls%FOUND THEN
                      CLOSE cur_fee_cls;
                      RETURN TRUE;
                ELSIF cur_fee_cls%NOTFOUND THEN
                      CLOSE cur_fee_cls;
                      RETURN FALSE;
                END IF;

        ELSE
        --
        -- The message if not null means the relation does not exist
        --
                RETURN FALSE;
        END IF;

  END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_DB_DISB.CHK_FCLASS_RESULT '||SQLERRM);
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END chk_fclass_result;

FUNCTION  chk_att_result(p_base_id       igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_ld_cal_type   igs_ca_inst_all.cal_type%TYPE,
                         p_ld_seq_number igs_ca_inst_all.sequence_number%TYPE,
                         p_min_att_type  igs_en_atd_type_all.attendance_type%TYPE,
                         p_result        OUT NOCOPY VARCHAR2
                         )
RETURN BOOLEAN
AS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This Process evaluates min attendance for student
--
--------------------------------------------------------------------------------------------

        CURSOR cur_get_rng(p_ld_cal_type  igs_ca_inst_all.cal_type%TYPE,
                           p_min_att_type igs_en_atd_type_all.attendance_type%TYPE)
        IS
        SELECT
        upper_enr_load_range
        FROM
        igs_en_atd_type_load
        WHERE
        cal_type         =  p_ld_cal_type AND
        attendance_type  =  p_min_att_type;

        get_rng_rec   cur_get_rng%ROWTYPE;

        ln_min_range     igs_en_atd_type_all.upper_enr_load_range%TYPE;
        ln_key_range     igs_en_atd_type_all.upper_enr_load_range%TYPE;
        lv_key_att_type  igs_en_atd_type_all.attendance_type%TYPE;
        l_credit_pts             NUMBER;
        l_fte                    VARCHAR2(10);

BEGIN

        OPEN  cur_get_rng(p_ld_cal_type,p_min_att_type);
        FETCH cur_get_rng INTO get_rng_rec;

        IF cur_get_rng%NOTFOUND THEN
                ln_min_range := 0;
                CLOSE cur_get_rng;
        ELSE
                ln_min_range := get_rng_rec.upper_enr_load_range;
                CLOSE cur_get_rng;
        END IF;


        BEGIN
          igs_en_prc_load.enrp_get_inst_latt (igf_gr_gen.get_person_id(p_base_id),
                                              p_ld_cal_type,
                                              p_ld_seq_number,
                                              lv_key_att_type,
                                              l_credit_pts,
                                              l_fte);

        EXCEPTION
        WHEN OTHERS THEN
          p_result := fnd_message.get;
          RETURN FALSE;
        END;

        OPEN  cur_get_rng(p_ld_cal_type,lv_key_att_type);
        FETCH cur_get_rng INTO get_rng_rec;
        IF cur_get_rng%NOTFOUND THEN
                ln_key_range := 0;
                CLOSE cur_get_rng;
        ELSE
                ln_key_range := get_rng_rec.upper_enr_load_range;
                CLOSE cur_get_rng;
        END IF;


        IF ln_key_range >= ln_min_range THEN
                RETURN TRUE;

        ELSE
                RETURN FALSE;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_DB_DISB.CHK_ATT_RESULT '||SQLERRM);
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END chk_att_result;


PROCEDURE  disb_verf_enf(p_base_id        igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_fund_id        igf_aw_fund_mast_all.fund_id%TYPE,
                         p_key_course_cd  igs_en_stdnt_ps_att.course_cd%TYPE,
                         p_key_ver_num    igs_en_stdnt_ps_att.version_number%TYPE,
                         p_acad_cal_type  igs_ca_inst_all.cal_type%TYPE,
                         p_acad_seq_num   igs_ca_inst_all.sequence_number%TYPE)

AS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This Process evaludates actual disbursements for
--                              Pays Only And Att Type or Credit Pts check
--                              credit / debit the disbursement.
--  WHO         WHEN           WHAT
--  veramach    12-NOV-2003    FA 125 Multiple Distribution methods
--                             As the attendance_type criteria is moved from fund manager to
--                             terms level, validations are changed accordingly
--------------------------------------------------------------------------------------------

-- Cursor to retreive Actual Disbursemenet records for which the
-- disbursement verification enforcement date is passed

        CURSOR cur_awd_disb ( p_base_id   igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_fund_id   igf_aw_fund_mast_all.fund_id%TYPE)
        IS
        SELECT
                adisb.* ,
                awd.base_id,
                fmast.ci_cal_type,
                fmast.ci_sequence_number,
                fmast.fund_id,
                cat.fed_fund_code
        FROM
                igf_aw_awd_disb       adisb,
                igf_aw_fund_mast      fmast,
                igf_aw_award          awd,
                igf_aw_fund_cat       cat
        WHERE
                adisb.award_id          =     awd.award_id               AND
                fmast.fund_code         =     cat.fund_code              AND
                fmast.fund_id           =     awd.fund_id                AND
                awd.base_id             =     p_base_id                  AND
                awd.fund_id             =     NVL(p_fund_id,awd.fund_id) AND
                adisb.trans_type        = 'A'                            AND
                NVL(adisb.verf_enfr_dt,TRUNC(SYSDATE)+1) <= SYSDATE      AND
                awd.award_status        =    'ACCEPTED'                  AND
                cat.fed_fund_code NOT IN ('FWS','SPNSR')                 AND
                cat.sys_fund_type NOT IN ('WORK','SPONSOR')              AND
                adisb.elig_status  <> 'V'                  -- Elig Status NOT VERIFIED

        FOR UPDATE OF elig_status NOWAIT;

        awd_disb_rec    cur_awd_disb%ROWTYPE;


        CURSOR cur_get_adisb (p_row_id ROWID)
        IS
        SELECT *
        FROM    igf_aw_awd_disb adisb
        WHERE
        adisb.row_id = p_row_id
        FOR UPDATE OF elig_status NOWAIT;

        get_adisb_rec   cur_get_adisb%ROWTYPE;

--Variables to Store the validation results

        lb_pays_prg            BOOLEAN := TRUE;  -- Pays Only Program Result
        lb_pays_uts            BOOLEAN := TRUE;  -- Pays Only Units Result
        lb_fclass_result       BOOLEAN := TRUE;  -- Fee Class Result
        lb_att_result          BOOLEAN := TRUE;  -- Attendance Type Result
        lb_cp_result           BOOLEAN := TRUE;  -- Credit Points Result

        lv_fund_type           VARCHAR2(1);
        p_message              VARCHAR2(4000);
        ln_credit_pts          igf_aw_awd_disb_all.min_credit_pts%TYPE;
        lv_acad_cal_type       igs_ca_inst_all.cal_type%TYPE;
        ln_acad_seq_num        igs_ca_inst_all.sequence_number%TYPE;
        lv_acad_alt_code       igs_ca_inst_all.alternate_code%TYPE;


-- following variables are used to make sure that the fund level,award level and term level
-- checks are not repeated for each disbursement belonging to the same fund/award/term

        ln_old_fund            igf_aw_fund_mast_all.fund_id%TYPE;
        ln_new_fund            igf_aw_fund_mast_all.fund_id%TYPE;
        lv_old_ld_c            igf_aw_fund_tp_all.tp_cal_type%TYPE;
        ln_old_ld_n            igf_aw_fund_tp_all.tp_sequence_number%TYPE;
        lv_new_ld_c            igf_aw_fund_tp_all.tp_cal_type%TYPE;
        ln_new_ld_n            igf_aw_fund_tp_all.tp_sequence_number%TYPE;
  BEGIN

    ln_old_fund    := -1 ;
    ln_new_fund    := 0;

    lv_old_ld_c    := '-1';
    ln_old_ld_n    := -1;
    lv_new_ld_c    := '0';
    ln_new_ld_n    := 0;

    OPEN  cur_awd_disb(p_base_id,p_fund_id);
    LOOP
      FETCH cur_awd_disb INTO awd_disb_rec;
      EXIT WHEN cur_awd_disb%NOTFOUND;

      ln_enfr_disb := 1 + ln_enfr_disb;

-- First we need to check if the fund being disbrused is of type either DL or CL or PELL
-- Store the type of fund as we need it in subsequent processing

      lv_fund_type := 'G';     -- General Fund

      IF igf_sl_gen.chk_dl_fed_fund_code(awd_disb_rec.fed_fund_code) = 'TRUE' THEN
        lv_fund_type := 'D';   -- Direct Loan Fund
      ELSIF igf_sl_gen.chk_cl_fed_fund_code(awd_disb_rec.fed_fund_code) = 'TRUE' THEN
        lv_fund_type := 'F';   -- FFELP Fund
      ELSIF awd_disb_rec.fed_fund_code = 'PELL' THEN
        lv_fund_type := 'P';   -- Pell Fund
      ELSIF awd_disb_rec.fed_fund_code IN ('PRK','FSEOG') THEN
        lv_fund_type := 'C';   -- Perkins, FSEOG Fund
      END IF;

      ln_old_fund := ln_new_fund;
      ln_new_fund := awd_disb_rec.fund_id;

      IF ln_old_fund = 0 OR
         (ln_old_fund <> ln_new_fund AND ln_old_fund > 1)
      THEN
           fnd_file.new_line(fnd_file.log,1);
           fnd_message.set_name('IGF','IGF_DB_VERF_ENFR_RTN');
           fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(p_base_id));
           fnd_message.set_token('FDESC',get_fund_desc(awd_disb_rec.fund_id));
           fnd_file.put_line(fnd_file.log,RPAD(' ',15) ||fnd_message.get);
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_verf_enf.debug','ln_enfr_disb:'||ln_enfr_disb);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_verf_enf.debug','lv_fund_type:'||lv_fund_type);
      END IF;

      fnd_file.new_line(fnd_file.log,1);
      fnd_message.set_name('IGF','IGF_DB_PROCESS_AWD_DISB');
-- 'Processing disbursement for award <award id > ,disbursement <disbursement   number>'
      fnd_message.set_token('AWARD_ID',TO_CHAR(awd_disb_rec.award_id));
      fnd_message.set_token('DISB_NUM',TO_CHAR(awd_disb_rec.disb_num));
      fnd_file.put_line(fnd_file.log,RPAD(' ',20) ||fnd_message.get);
      fnd_file.new_line(fnd_file.log,1);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_verf_enf.debug','processing disb '||awd_disb_rec.disb_num||' of award '||awd_disb_rec.award_id);
      END IF;
--
-- Validations
--
-- The checks that are to be done for a fund in the award year context are:
-- 1. Pays Only Program
-- 2. Pays Only Units
--

      IF ln_old_fund <> ln_new_fund THEN

      -- For each new fund that is visible within this scope,
      -- the result variables are initialized

        lb_pays_prg    := TRUE;
        lb_pays_uts    := TRUE;

      -- Pays Only Program Check
        lb_pays_prg    := chk_pays_prg( awd_disb_rec.fund_id,awd_disb_rec.base_id);
      -- Pays Only Units Check
        lb_pays_uts    := chk_pays_uts( awd_disb_rec.fund_id,awd_disb_rec.base_id);

        IF lb_log_detail THEN
          IF NOT lb_pays_prg THEN
            fnd_message.set_name('IGF','IGF_DB_FAIL_PPRG');
            -- 'Disbursement failed Fund Pays Only Program check'
            fnd_file.put_line(fnd_file.log,RPAD(' ',20) ||fnd_message.get);
          END IF;
          IF NOT lb_pays_uts THEN
            fnd_message.set_name('IGF','IGF_DB_FAIL_PUNT');
            -- 'Disbursement failed Fund Pays Only Unit check'
            fnd_file.put_line(fnd_file.log,RPAD(' ',20) ||fnd_message.get);
          END IF;
        END IF;
      END IF;
--
-- Validations
-- Checks that should be done at Term Level
-- 1. Pays Only Fee Class
-- 2. Min Att Type is specified
--
      lv_old_ld_c    := lv_new_ld_c;
      ln_old_ld_n    := ln_new_ld_n;

      lv_new_ld_c    := awd_disb_rec.ld_cal_type;
      ln_new_ld_n    := awd_disb_rec.ld_sequence_number;

      IF lv_old_ld_c <> lv_new_ld_c  AND
         ln_old_ld_n <> ln_new_ld_n  THEN

          lb_fclass_result := TRUE;
          lb_fclass_result := chk_fclass_result(awd_disb_rec.base_id,awd_disb_rec.fund_id,
                                                awd_disb_rec.ld_cal_type,awd_disb_rec.ld_sequence_number);
          IF lb_log_detail THEN
            IF NOT lb_fclass_result THEN
              fnd_message.set_name('IGF','IGF_DB_FAIL_FCLS');
              --Disbursement failed Pays Only Fee Class Check
              fnd_file.put_line(fnd_file.log,RPAD(' ',20) ||fnd_message.get);
            END IF;
          END IF;

      END IF;

-- Min Credit Points

      lb_cp_result := TRUE;
      IF awd_disb_rec.min_credit_pts IS NOT NULL THEN
        igs_en_prc_load.enrp_clc_cp_upto_tp_start_dt(igf_gr_gen.get_person_id(awd_disb_rec.base_id),
                                                     awd_disb_rec.ld_cal_type,
                                                     awd_disb_rec.ld_sequence_number,
                                                     'Y',
                                                     TRUNC(SYSDATE),
                                                     ln_credit_pts);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_verf_enf.debug','awd_disb_rec.min_credit_pts:'||awd_disb_rec.min_credit_pts);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_verf_enf.debug','ln_credit_pts:'||ln_credit_pts);
        END IF;

        IF NVL(ln_credit_pts,0) < NVL(awd_disb_rec.min_credit_pts,0) THEN
          lb_cp_result := FALSE;
          fnd_message.set_name('IGF','IGF_DB_FAIL_CRP');
          fnd_file.put_line(fnd_file.log,RPAD(' ',20) || fnd_message.get);
        END IF;
      END IF;

--Attendance Type
      lb_att_result    := TRUE;
      IF awd_disb_rec.attendance_type_code IS NOT NULL THEN
        lb_att_result := chk_att_result(awd_disb_rec.base_id,
                                        awd_disb_rec.ld_cal_type,
                                        awd_disb_rec.ld_sequence_number,
                                        awd_disb_rec.attendance_type_code,
                                        p_message
                                        );

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_verf_enf.debug','awd_disb_rec.attendance_type_code:'||awd_disb_rec.attendance_type_code);
        END IF;

        IF NOT lb_att_result THEN
          fnd_message.set_name('IGF','IGF_DB_FAIL_ATT');
          IF p_message IS NOT NULL THEN
             fnd_file.put_line(fnd_file.log,RPAD(' ',20) ||p_message);
          END IF;
          --Disbursement failed Attendance Type Check
          fnd_file.put_line(fnd_file.log,RPAD(' ',20) ||fnd_message.get);
        END IF;
      END IF;

      IF lb_pays_prg       AND
         lb_pays_uts       AND
         lb_fclass_result  AND
         lb_att_result     AND
         lb_cp_result      THEN

        OPEN  cur_get_adisb (awd_disb_rec.row_id);
        FETCH cur_get_adisb  INTO  get_adisb_rec;
        CLOSE cur_get_adisb;

        get_adisb_rec.elig_status      := 'V';
        get_adisb_rec.elig_status_date := TRUNC(SYSDATE);

        fnd_message.set_name('IGF','IGF_DB_VERF_ENFR_RTN_PASS');
        fnd_message.set_token('AWARD_ID',TO_CHAR(awd_disb_rec.award_id));
        fnd_message.set_token('DISB_NUM',TO_CHAR(awd_disb_rec.disb_num));
        fnd_file.put_line(fnd_file.log,RPAD(' ',20) ||fnd_message.get);

        ln_enfr_disb_p := 1 + ln_enfr_disb_p;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_verf_enf.debug','updating igf_aw_awd_disb for award '||get_adisb_rec.award_id||' disb '||get_adisb_rec.disb_num);
        END IF;

        igf_aw_awd_disb_pkg.update_row( x_rowid                     =>    get_adisb_rec.row_id             ,
                                        x_award_id                  =>    get_adisb_rec.award_id           ,
                                        x_disb_num                  =>    get_adisb_rec.disb_num           ,
                                        x_tp_cal_type               =>    get_adisb_rec.tp_cal_type        ,
                                        x_tp_sequence_number        =>    get_adisb_rec.tp_sequence_number ,
                                        x_disb_gross_amt            =>    get_adisb_rec.disb_gross_amt     ,
                                        x_fee_1                     =>    get_adisb_rec.fee_1              ,
                                        x_fee_2                     =>    get_adisb_rec.fee_2              ,
                                        x_disb_net_amt              =>    get_adisb_rec.disb_net_amt       ,
                                        x_disb_date                 =>    get_adisb_rec.disb_date          ,
                                        x_trans_type                =>    get_adisb_rec.trans_type         ,
                                        x_elig_status               =>    get_adisb_rec.elig_status        ,
                                        x_elig_status_date          =>    get_adisb_rec.elig_status_date   ,
                                        x_affirm_flag               =>    get_adisb_rec.affirm_flag        ,
                                        x_hold_rel_ind              =>    get_adisb_rec.hold_rel_ind       ,
                                        x_manual_hold_ind           =>    get_adisb_rec.manual_hold_ind    ,
                                        x_disb_status               =>    get_adisb_rec.disb_status        ,
                                        x_disb_status_date          =>    get_adisb_rec.disb_status_date   ,
                                        x_late_disb_ind             =>    get_adisb_rec.late_disb_ind      ,
                                        x_fund_dist_mthd            =>    get_adisb_rec.fund_dist_mthd     ,
                                        x_prev_reported_ind         =>    get_adisb_rec.prev_reported_ind  ,
                                        x_fund_release_date         =>    get_adisb_rec.fund_release_date  ,
                                        x_fund_status               =>    get_adisb_rec.fund_status        ,
                                        x_fund_status_date          =>    get_adisb_rec.fund_status_date   ,
                                        x_fee_paid_1                =>    get_adisb_rec.fee_paid_1         ,
                                        x_fee_paid_2                =>    get_adisb_rec.fee_paid_2         ,
                                        x_cheque_number             =>    get_adisb_rec.cheque_number      ,
                                        x_ld_cal_type               =>    get_adisb_rec.ld_cal_type        ,
                                        x_ld_sequence_number        =>    get_adisb_rec.ld_sequence_number ,
                                        x_disb_accepted_amt         =>    get_adisb_rec.disb_accepted_amt  ,
                                        x_disb_paid_amt             =>    get_adisb_rec.disb_paid_amt      ,
                                        x_rvsn_id                   =>    get_adisb_rec.rvsn_id            ,
                                        x_int_rebate_amt            =>    get_adisb_rec.int_rebate_amt     ,
                                        x_force_disb                =>    get_adisb_rec.force_disb         ,
                                        x_min_credit_pts            =>    get_adisb_rec.min_credit_pts     ,
                                        x_disb_exp_dt               =>    get_adisb_rec.disb_exp_dt        ,
                                        x_verf_enfr_dt              =>    get_adisb_rec.verf_enfr_dt       ,
                                        x_fee_class                 =>    get_adisb_rec.fee_class          ,
                                        x_show_on_bill              =>    get_adisb_rec.show_on_bill       ,
                                        x_attendance_type_code      =>    get_adisb_rec.attendance_type_code,
                                        x_base_attendance_type_code =>    get_adisb_rec.base_attendance_type_code,
                                        x_mode                      =>    'R',
                                        x_payment_prd_st_date       =>    get_adisb_rec.payment_prd_st_date,
                                        x_change_type_code          =>    get_adisb_rec.change_type_code,
                                        x_fund_return_mthd_code     =>    get_adisb_rec.fund_return_mthd_code,
                                        x_direct_to_borr_flag       =>    get_adisb_rec.direct_to_borr_flag
                                        );

      ELSE

        fnd_message.set_name('IGF','IGF_DB_VERF_ENFR_RTN_FAIL');
        fnd_message.set_token('AWARD_ID',TO_CHAR(awd_disb_rec.award_id));
        fnd_message.set_token('DISB_NUM',TO_CHAR(awd_disb_rec.disb_num));
        fnd_file.put_line(fnd_file.log,RPAD(' ',20) ||fnd_message.get);
        revert_disb(awd_disb_rec.row_id,'R',lv_fund_type);   -- 'R' - failed enforcement
      END IF;

    END LOOP;
    CLOSE cur_awd_disb;

    EXCEPTION

      WHEN app_exception.record_lock_exception THEN
        RAISE;

      WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_DB_DISB.DISB_VERF_ENF '||SQLERRM);
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END disb_verf_enf;

PROCEDURE process_student( p_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_result     IN OUT NOCOPY VARCHAR2,
                           p_fund_id    igf_aw_fund_mast_all.fund_id%TYPE,
                           p_award_id   igf_aw_award_all.award_id%TYPE,
                           p_disb_num   igf_aw_awd_disb_all.disb_num%TYPE
                          )
AS
--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This Process evaludates disbursements for
--                              various checks in Fund Setup so that these can be
--                              picked up by SF Integration Process which will
--                              credit / debit the disbursement.
--  Change History :
--   Who             When           What
--  veramach         12-NOV-2003    FA 125 Multiple distribution methods
--                                  As the attendance_type criteria is moved from fund level to term level,
--                                  validations are changed accordingly
--  rasahoo          01-09-2003     Removed the cursor cur_get_inst and all it references
--                                  added call to generic API to get the values of coloumns
--                                  reffered from cursor cur_get_inst
--  (reverse chronological order - newest change first)
--------------------------------------------------------------------------------------------

    SKIP_RECORD     EXCEPTION;

    CURSOR cur_awd_disb(p_base_id  igf_ap_fa_base_rec_all.base_id%TYPE,
                        p_fund_id  igf_aw_fund_mast_all.fund_id%TYPE,
                        p_award_id igf_aw_award_all.award_id%TYPE,
                        p_disb_num igf_aw_awd_disb_all.disb_num%TYPE)
    IS
    SELECT
            adisb.ROWID row_id,
            adisb.*,
            awd.base_id,
            awd.accepted_amt,
            fmast.ci_cal_type,
            fmast.ci_sequence_number,
            fmast.fund_id,
            fmast.fund_code,
            fmast.send_without_doc,
            fmast.ver_app_stat_override,
            NVL(fmast.org_record_req,'N')  org_record_req,
            NVL(fmast.disb_record_req,'N') disb_record_req,
            NVL(fmast.prom_note_req,'N')   prom_note_req,
            NVL(fmast.fund_recv_reqd,'N')  fund_recv_req,
            fmast.fee_type                 fee_type,
            cat.fed_fund_code
    FROM
            igf_aw_awd_disb_all    adisb,
            igf_aw_fund_mast_all   fmast,
            igf_aw_award_all       awd,
            igf_aw_fund_cat_all    cat
    WHERE
            adisb.award_id                  =     awd.award_id             AND
            fmast.fund_code                 =     cat.fund_code            AND
            fmast.fund_id                   =     awd.fund_id              AND
            awd.base_id                     =     p_base_id                AND
            awd.fund_id                     =     NVL(p_fund_id,awd.fund_id)     AND
            adisb.award_id                  =     NVL(p_award_id,adisb.award_id) AND
            adisb.disb_num                  =     NVL(p_disb_num,adisb.disb_num) AND
            adisb.trans_type                =    'P'                       AND
            adisb.disb_date                <=     SYSDATE                  AND
            NVL(adisb.manual_hold_ind,'N')  =    'N'                       AND
            NVL(fmast.disburse_fund,'N')    =    'Y'                       AND
            NVL(fmast.discontinue_fund,'N') <>   'Y'                       AND
            awd.award_status                =    'ACCEPTED'                AND
            cat.fed_fund_code NOT IN ('FWS','SPNSR')                       AND
            cat.sys_fund_type NOT IN ('WORK','SPONSOR')
    ORDER BY
            awd.base_id,awd.award_id,adisb.disb_num;

    awd_disb_rec    cur_awd_disb%ROWTYPE;

-- Get the loan generated for this award

    CURSOR cur_get_loans (p_award_id igf_aw_award_all.award_id%TYPE)
    IS
    SELECT
    loan_id, loan_number, loan_status, active
    FROM
    igf_sl_loans
    WHERE
    award_id  = p_award_id;

    get_loans_rec cur_get_loans%ROWTYPE;


    CURSOR cur_pnote_stat (p_loan_id  igf_sl_loans_all.loan_id%TYPE)
    IS
    SELECT
    origination_id,
    NVL(pnote_status,'N') pnote_status,
    NVL(mpn_confirm_code,'N') mpn_confirm_code
    FROM
    igf_sl_lor
    WHERE
    loan_id = p_loan_id;

    pnote_stat_rec  cur_pnote_stat%ROWTYPE;

    CURSOR cur_get_pell (p_award_id igf_aw_award_all.award_id%TYPE)
    IS
    SELECT
    origination_id,orig_action_code,efc
    FROM
    igf_gr_rfms
    WHERE
    award_id    =    p_award_id;

    get_pell_rec  cur_get_pell%ROWTYPE;

-- Get the PELL disbursement status

    CURSOR cur_get_disb (p_origination_id igf_gr_rfms_all.origination_id%TYPE,
                         p_disb_num       igf_aw_awd_disb_all.disb_num%TYPE)
    IS
    SELECT
    disb_ack_act_status
    FROM
    igf_gr_rfms_disb
    WHERE
    origination_id =  p_origination_id AND
    disb_ref_num   =  p_disb_num;

    get_disb_rec    cur_get_disb%ROWTYPE;

-- Cursor to get Verification Status of Student

    CURSOR cur_get_ver (p_base_id  igf_ap_fa_base_rec_all.base_id%TYPE)
    IS
    SELECT
    NVL(fed_verif_status,'*') fed_verif_status
    FROM
    igf_ap_fa_base_rec
    WHERE
    base_id         = p_base_id;

    get_ver_rec cur_get_ver%ROWTYPE;
--
-- Cursor to get term totals for a disbursement
--
    CURSOR cur_term_amounts (p_award_id    NUMBER,
                             p_ld_cal_type VARCHAR2,
                             p_ld_seq_num  NUMBER)
    IS
    SELECT SUM(disb.disb_gross_amt) term_total
    FROM   igf_aw_awd_disb_all disb,
           igf_aw_award_all    awd
    WHERE  disb.trans_type <> 'C'
      AND  awd.award_id = disb.award_id
      AND  awd.award_id = p_award_id
      AND  disb.ld_cal_type = p_ld_cal_type
      AND  disb.ld_sequence_number = p_ld_seq_num;

    term_amounts_rec cur_term_amounts%ROWTYPE;

    ln_credit_pts           igf_aw_awd_disb_all.min_credit_pts%TYPE;
    lv_acad_cal_type        igs_ca_inst_all.cal_type%TYPE;
    ln_acad_seq_num         igs_ca_inst_all.sequence_number%TYPE;
    lv_acad_alt_code        igs_ca_inst_all.alternate_code%TYPE;

--Variables to Store the validation results

    lb_todo_result         BOOLEAN := TRUE;  -- To Do Result
    lb_pays_prg            BOOLEAN := TRUE;  -- Pays Only Program Result
    lb_pays_uts            BOOLEAN := TRUE;  -- Pays Only Units Result

    lb_elig_result         BOOLEAN := TRUE;  -- Title IV , PELL Eligibility Result

    lb_active_result       BOOLEAN := TRUE;  -- Loan Active Result
    lb_prom_result         BOOLEAN := TRUE;  -- Promissory Note Result
    lb_pell_cal_result     BOOLEAN := TRUE;  -- Pell Calculation Result
    lb_orig_result         BOOLEAN := TRUE;  -- Origination Reqd Result

    lb_fclass_result       BOOLEAN := TRUE;  -- Fee Class Result
    lb_att_result          BOOLEAN := TRUE;  -- Attendance Type Result

    lb_disb_result         BOOLEAN := TRUE;  -- Disbursement Reqd Result
    lb_recv_result         BOOLEAN := TRUE;  -- Fund Receive Result
    lb_cp_result           BOOLEAN := TRUE;  -- Credit Points Result
    lb_hold_result         BOOLEAN := TRUE;  -- Academic Hold Result
    lb_send_wdoc           BOOLEAN := TRUE;  -- Send Without Doc Result

    lv_fund_type           VARCHAR2(1);


-- following variables are used to make sure that the fund level,award level and term level
-- checks are not repeated for each disbursement belonging to the same fund/award/term

    ln_old_fund            igf_aw_fund_mast_all.fund_id%TYPE;
    ln_new_fund            igf_aw_fund_mast_all.fund_id%TYPE;

    ln_old_awd             igf_aw_award_all.award_id%TYPE;
    ln_new_awd             igf_aw_award_all.award_id%TYPE;

    lv_old_ld_c            igf_aw_fund_tp_all.tp_cal_type%TYPE;
    ln_old_ld_n            igf_aw_fund_tp_all.tp_sequence_number%TYPE;
    lv_new_ld_c            igf_aw_fund_tp_all.tp_cal_type%TYPE;
    ln_new_ld_n            igf_aw_fund_tp_all.tp_sequence_number%TYPE;

    lv_pell_mat            VARCHAR2(10);
    ln_ft_pell_amt         NUMBER;
    lv_call_from           VARCHAR2(10);
    lv_message_name        VARCHAR2(30);
    ln_min_num             igf_aw_awd_disb_all.disb_num%TYPE;
    l_course_cd            VARCHAR2(10);
    l_ver_num              NUMBER;

    p_term_aid             NUMBER;
    p_return_status        VARCHAR2(30);
    p_pell_matrix          VARCHAR2(30);
    p_message              VARCHAR2(1000);
    lv_profile_value       VARCHAR2(30);
    l_cl_version           VARCHAR(20);          -- Processing type 'RELEASE-4' or 'RELEASE-5'
    lb_invalid_pnote       BOOLEAN;

BEGIN

    ln_plan_disb     :=      0;
    ln_act_disb      :=      0;
    ln_enfr_disb     :=      0;
    ln_enfr_disb_p   :=      0;
    lv_call_from     :=    ' ';
    ln_min_num       :=      0;

    IF p_result IS NULL THEN
       lv_call_from  := 'FORM';
       lb_log_detail := TRUE;
    END IF;

    OPEN  cur_awd_disb (p_base_id,p_fund_id,p_award_id,p_disb_num);
    FETCH cur_awd_disb INTO awd_disb_rec;


    IF cur_awd_disb%NOTFOUND THEN

    -- Bug : 2738181 (log file should be more appropriate.)
    -- nsidana (4/16/2003)
    -- Added the folowing IF condition to check if the p_fnd_id is null. If yes, display a new message having just one parameter.
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','cur_awd_disb%NOTFOUND');
      END IF;
      IF p_fund_id IS NULL THEN
        -- Add a new message having just one parameter.
        fnd_message.set_name('IGF','IGF_DB_NO_PLAN_REC');
        fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(p_base_id));
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','no planned disbursments for '||igf_gr_gen.get_per_num(p_base_id));
        END IF;
      ELSE
        -- Add old message having two parameters.
        fnd_message.set_name('IGF','IGF_DB_NO_STD_FUND');
        fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(p_base_id));
        fnd_message.set_token('FDESC',get_fund_desc(p_fund_id));
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','no planned disbursments for '||igf_gr_gen.get_per_num(p_base_id));
        END IF;
      END IF;
      p_result := fnd_message.get;
      fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||p_result);
-- No Planned Disbursements found for Student <person number> and Fund  <fund desc>)
      CLOSE cur_awd_disb;

    ELSIF cur_awd_disb%FOUND THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','cur_awd_disb%FOUND');
      END IF;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','calling delete_pays');
      END IF;
      -- truncate previous records that were used in determining eligibility of the student in the previous run
      delete_pays();
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','called delete_pays');
      END IF;
      ln_old_fund    := -1 ;
      ln_new_fund    := 0;

      ln_old_awd     := -1;
      ln_new_awd     := 0;

      lv_old_ld_c    := '-1';
      ln_old_ld_n    := -1;

      lv_new_ld_c    := '0';
      ln_new_ld_n    := 0;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','calling get_acad_cal_from_awd with the following info');
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','awd_disb_rec.ci_cal_type:'||awd_disb_rec.ci_cal_type);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','awd_disb_rec.ci_sequence_number:'||awd_disb_rec.ci_sequence_number);
      END IF;
      -- Get Academic Calendar Information
      igf_ap_oss_integr.get_acad_cal_from_awd( awd_disb_rec.ci_cal_type,awd_disb_rec.ci_sequence_number,
                                               lv_acad_cal_type,ln_acad_seq_num,lv_acad_alt_code);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','get_acad_cal_from_awd returned the following info');
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','lv_acad_cal_type:'||lv_acad_cal_type);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','ln_acad_seq_num:'||ln_acad_seq_num);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','lv_acad_alt_code:'||lv_acad_alt_code);
      END IF;
--
-- First get all the enrolled programs, unit sets for the student and insert into IGF_DB_PAYS_PRG_T
-- We are doing this before starting the main loop.
-- It may very well happen that there are no Pays onlu units or programs defined in fund setup
-- Still we need to have the the enrolled programs, unit sets for the student into IGF_DB_PAYS_PRG_T
--

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','calling insert_pays_prg_uts');
      END IF;
      insert_pays_prg_uts(awd_disb_rec.base_id,
                          lv_acad_cal_type,ln_acad_seq_num);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','called insert_pays_prg_uts');
      END IF;
--
-- Get FED_VERIF_STATUS of the Student
--
      OPEN  cur_get_ver(awd_disb_rec.base_id);
      FETCH cur_get_ver INTO get_ver_rec;
      CLOSE cur_get_ver;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','starting processing for '||igf_gr_gen.get_per_num(p_base_id)||' '||get_fund_desc(awd_disb_rec.fund_id));
      END IF;
      LOOP
        BEGIN
          -- clear message stack
          fnd_message.clear;

          -- First we need to check if the fund being disbursed is of type either DL or CL or PELL
          -- Store the type of fund as we need it in subsequent processing

          ln_plan_disb := 1 + ln_plan_disb;

          lv_fund_type := 'G';           -- General Fund

          IF igf_sl_gen.chk_dl_fed_fund_code(awd_disb_rec.fed_fund_code) = 'TRUE' THEN
            lv_fund_type := 'D';   -- Direct Loan Fund
          ELSIF igf_sl_gen.chk_cl_fed_fund_code(awd_disb_rec.fed_fund_code) = 'TRUE' THEN
            lv_fund_type := 'F';   -- FFELP Fund
          ELSIF awd_disb_rec.fed_fund_code = 'PELL' THEN
            lv_fund_type := 'P';   -- Pell Fund
          ELSIF awd_disb_rec.fed_fund_code IN ('PRK','FSEOG') THEN
            lv_fund_type := 'C';   -- Perkins, FSEOG Fund
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','lv_fund_type:'||lv_fund_type);
          END IF;

          ln_old_fund := ln_new_fund;
          ln_new_fund := awd_disb_rec.fund_id;

          IF ln_old_fund = 0 OR
             (ln_old_fund <> ln_new_fund AND ln_old_fund > 1)
              THEN
              fnd_file.new_line(fnd_file.log,1);
              fnd_message.set_name('IGF','IGF_DB_PROCESS_STD_FUND');
              fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(p_base_id));
              fnd_message.set_token('FDESC',get_fund_desc(awd_disb_rec.fund_id));
              fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
          END IF;

          fnd_file.new_line(fnd_file.log,1);
          fnd_message.set_name('IGF','IGF_DB_PROCESS_AWD_DISB');
          -- 'Processing disbursement for award <award id > ,disbursement <disbursement   number>'
          fnd_message.set_token('AWARD_ID',TO_CHAR(awd_disb_rec.award_id));
          fnd_message.set_token('DISB_NUM',TO_CHAR(awd_disb_rec.disb_num));
          fnd_file.put_line(fnd_file.log,RPAD(' ',15) ||fnd_message.get);
          fnd_file.new_line(fnd_file.log,1);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','awd_disb_rec.award_id:'||awd_disb_rec.award_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','awd_disb_rec.disb_num:'||awd_disb_rec.disb_num);
          END IF;

          IF NVL(awd_disb_rec.disb_exp_dt,TRUNC(SYSDATE)+1) <= TRUNC(SYSDATE) THEN
            fnd_message.set_name('IGF','IGF_DB_CANCEL_EXP');
            fnd_message.set_token('AWARD_ID',TO_CHAR(awd_disb_rec.award_id));
            fnd_message.set_token('DISB_NUM',TO_CHAR(awd_disb_rec.disb_num));
            -- 'Cancelling disbursement for award <award id > ,disbursement <disbursement   number> as expiration date has reached'
            p_result := fnd_message.get;
            fnd_file.put_line(fnd_file.log,RPAD(' ',15) ||p_result);
            revert_disb(awd_disb_rec.row_id,'X',lv_fund_type);
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','cancelled award '||awd_disb_rec.award_id||' '||awd_disb_rec.disb_num);
            END IF;
            -- Go to Next Record
            RAISE SKIP_RECORD;
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','awd_disb_rec.force_disb:'||awd_disb_rec.force_disb);
          END IF;
          IF NVL(awd_disb_rec.force_disb,'N') ='Y' THEN
            --
            -- FA131 Changes
            -- If student fails Pell Elig Check then do not make actual
            -- This is only for conc job, on-line disbursement would
            -- bypass this validation
            --
            IF lv_fund_type = 'P' AND NOT chk_fed_elig( awd_disb_rec.base_id,'P') AND lv_call_from <> 'FORM' THEN
               fnd_message.set_name('IGF','IGF_GR_PELL_INELIGIBLE');
               p_result := fnd_message.get;
               fnd_file.put_line(fnd_file.log,RPAD(' ',15) ||p_result);

            ELSIF  ( lv_fund_type = 'P' AND lv_call_from = 'FORM' )
                   OR
                   ( lv_fund_type <> 'P') THEN
               fnd_message.set_name('IGF','IGF_DB_CREATE_ACT_FRC');
               fnd_message.set_token('AWARD_ID',TO_CHAR(awd_disb_rec.award_id));
               fnd_message.set_token('DISB_NUM',TO_CHAR(awd_disb_rec.disb_num));
               --'Creating actual disbursement for award <award id > ,disbursement <disbursement number>   without verification as force disbursement is true'
               p_result := fnd_message.get;
               fnd_file.put_line(fnd_file.log,RPAD(' ',15) ||p_result);

               IF lv_fund_type ='D' THEN
                 create_actual(awd_disb_rec.row_id,TRUE,TRUE,awd_disb_rec.fund_id);
               ELSE
                 create_actual(awd_disb_rec.row_id,FALSE,TRUE,awd_disb_rec.fund_id);
               END IF;
               -- Go to Next Record
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','called create_actual for fund '||awd_disb_rec.fund_id);
               END IF;
            END IF;

            RAISE SKIP_RECORD;

          END IF;

--
-- Validations
--
-- The checks that are to be done for a fund in the award year context are:
-- 1. To Do Item Validations
-- 2. Pays Only Program
-- 3. Pays Only Units
-- 4. Eligibility check for getting loans (NSLDS_ELIGIBLE)
-- 5. Eligibility check for getting PELL Grant (PELL_ELIGIBLE)
--
--
          IF ln_old_fund <> ln_new_fund THEN

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','processing '||igf_gr_gen.get_per_num(p_base_id)||' '||get_fund_desc(awd_disb_rec.fund_id));
            END IF;
            -- For each new fund that is visible within this scope,
            -- the result variables are initialized

            lb_todo_result := TRUE;
            lb_pays_prg    := TRUE;
            lb_pays_uts    := TRUE;
            lb_elig_result := TRUE;
            lb_hold_result := TRUE;

             --
             -- Check for Academic Holds, only if con job is run
             --

             IF lv_call_from <> 'FORM' THEN
               IF igf_aw_gen_005.get_stud_hold_effect('D',igf_gr_gen.get_person_id(p_base_id),awd_disb_rec.fund_code) = 'F' THEN
                 lb_hold_result := FALSE;
               END IF;
             END IF;

             lb_todo_result := chk_todo_result(lv_message_name, awd_disb_rec.fund_id, awd_disb_rec.base_id);
             lb_pays_prg    := chk_pays_prg( awd_disb_rec.fund_id,awd_disb_rec.base_id);
             lb_pays_uts    := chk_pays_uts( awd_disb_rec.fund_id,awd_disb_rec.base_id);
             lb_elig_result := chk_fed_elig( awd_disb_rec.base_id,lv_fund_type);

             IF lb_log_detail THEN
               IF NOT lb_hold_result THEN
                 fnd_message.set_name('IGF','IGF_AW_DISB_FUND_HOLD_FAIL');
                 p_result := fnd_message.get;
                 fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
               END IF;

               IF NOT lb_todo_result AND lv_message_name IS NOT NULL THEN
                 fnd_message.set_name('IGF',lv_message_name);
                 -- 'Disbursement failed Fund To Do check'
                 p_result := fnd_message.get;
                 fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
               END IF;

               IF NOT lb_pays_prg THEN
                 fnd_message.set_name('IGF','IGF_DB_FAIL_PPRG');
                 -- 'Disbursement failed Fund Pays Only Program check'
                 p_result := fnd_message.get;
                 fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
               END IF;

               IF NOT lb_pays_uts THEN
                 fnd_message.set_name('IGF','IGF_DB_FAIL_PUNT');
                 -- 'Disbursement failed Fund Pays Only Unit check'
                 p_result := fnd_message.get;
                 fnd_file.put_line(fnd_file.log,RPAD(' ',17) || p_result);
               END IF;
             END IF;

             IF NOT lb_elig_result THEN
               IF lv_fund_type = 'P' THEN
                 fnd_message.set_name('IGF','IGF_GR_PELL_INELIGIBLE');
                 -- 'Disbursement failed Pell Eligiblity check'
               END IF;
               IF lv_fund_type IN ('D','F') THEN
                 fnd_message.set_name('IGF','IGF_DB_FAIL_FEDL_ELIG');
                 -- 'Disbursement failed NSLDS Eligiblity check'
               END IF;
               p_result := fnd_message.get;
               fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
             END IF;

             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','lv_call_from <> FORM');

               IF NOT lb_hold_result THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','disbursment hold exist');
               ELSE
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','disbursment hold do not exist');
               END IF;

               IF NOT lb_todo_result THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','failed to do items check');
               ELSE
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','passed to do items check');
               END IF;

               IF NOT lb_pays_prg THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','failed pays only prog check');
               ELSE
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','passed pays only prog check');
               END IF;

               IF NOT lb_pays_uts THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','failed pays only units check');
               ELSE
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','passed pays only units check');
               END IF;

               IF NOT lb_elig_result THEN

                 IF lv_fund_type = 'P' THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','failed pell eligibilty check');
                 ELSE
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student..debug','passed pell eligibilty check');
                 END IF;

                 IF lv_fund_type IN ('D','F') THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','failed NSLDS eligibilty check');
                 ELSE
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','passed NSLDS eligibilty check');
                 END IF;

               END IF; -- Pell Elig

             END IF; -- FND Log End If

          END IF; -- old fund id not new fund

--
-- Validations
-- Checks that should be done at Award Level
-- 1.Active Loan
-- 2.Loan Status
-- 3.Origination Check
-- 4.Promissory Note Required
--

          ln_old_awd := ln_new_awd;
          ln_new_awd := awd_disb_rec.award_id;

          IF ln_old_awd <> ln_new_awd THEN
            -- For each new fund that is visible within this scope,
            -- the result variables are initialized
            lb_active_result   := TRUE;
            lb_orig_result     := TRUE;
            lb_prom_result     := TRUE;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','lv_fund_type:'||lv_fund_type);
            END IF;

            IF lv_fund_type IN ('D','F') THEN
              OPEN  cur_get_loans (awd_disb_rec.award_id);
              FETCH cur_get_loans INTO get_loans_rec;
              IF cur_get_loans%NOTFOUND THEN
                lb_active_result := FALSE;
                CLOSE cur_get_loans;
                fnd_message.set_name('IGF','IGF_SL_LOAN_ID_NOT_FOUND');
                p_result := fnd_message.get;
                fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                -- message ' Loan Not created for this award <Award ID>'
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','cur_get_loans%NOTFOUND');
                END IF;
              ELSIF cur_get_loans%FOUND THEN
                IF NVL(get_loans_rec.active,'N') <> 'Y' THEN
                  fnd_message.set_name('IGF','IGF_DB_LOAN_INACTIVE');
                  fnd_message.set_token('LOAN_NUMBER',get_loans_rec.loan_number);
                  p_result := fnd_message.get;
                  fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                  lb_active_result := FALSE;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','loan '||get_loans_rec.loan_number||' is inactive');
                  END IF;
                END IF;

                CLOSE cur_get_loans;
                IF lb_active_result THEN
                  OPEN  cur_pnote_stat(get_loans_rec.loan_id);
                  FETCH cur_pnote_stat INTO pnote_stat_rec;
                  IF cur_pnote_stat%NOTFOUND THEN
                    lb_prom_result := FALSE;
                    lb_orig_result := FALSE;

                    CLOSE cur_pnote_stat;
                    fnd_message.set_name('IGF','IGF_DB_LOAN_ORIG_NOT_FOUND');
                    p_result := fnd_message.get;
                    fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                    -- message ' Loan Not created for this award <Award ID>'
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','loan not created for '||get_loans_rec.loan_id);
                    END IF;

                  ELSIF cur_pnote_stat%FOUND THEN
                    CLOSE cur_pnote_stat;
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','awd_disb_rec.org_record_req:'||awd_disb_rec.org_record_req);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','get_loans_rec.loan_status:'||get_loans_rec.loan_status);
                    END IF;
                    IF NVL(awd_disb_rec.org_record_req,'N') = 'Y' THEN
                      IF NVL(get_loans_rec.loan_status,'N') <>'A' THEN
                        fnd_message.set_name('IGF','IGF_DB_LOAN_ORIG_NOT_ACC');
                        fnd_message.set_token('LOAN_NUMBER',get_loans_rec.loan_number);
                        p_result := fnd_message.get;
                        fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);

                        lb_orig_result := FALSE;
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','loan not accepted');
                        END IF;
                      END IF;
                    END IF;
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','awd_disb_rec.prom_note_req:'||awd_disb_rec.prom_note_req);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','pnote_stat_rec.pnote_status:'||pnote_stat_rec.pnote_status);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','pnote_stat_rec.mpn_confirm_code:'||pnote_stat_rec.pnote_status);
                    END IF;
                    IF NVL(awd_disb_rec.prom_note_req,'N')  = 'Y' THEN
                      -- bvisvana - Bug # 4575843 - Promissory Note check for CL 4 also included
                      lb_invalid_pnote := FALSE;
                      IF lv_fund_type = 'D' THEN
                        IF pnote_stat_rec.pnote_status NOT IN ('A') THEN
                           lb_invalid_pnote := TRUE;
                        END IF;
                      ELSIF lv_fund_type = 'F' THEN
                        l_cl_version := get_cl_version(get_loans_rec.loan_number);
                        IF l_cl_version='RELEASE-5' AND pnote_stat_rec.pnote_status NOT IN ('60') THEN
                          lb_invalid_pnote := TRUE;
                        ELSIF l_cl_version='RELEASE-4' AND pnote_stat_rec.mpn_confirm_code NOT IN ('Y') THEN
                          lb_invalid_pnote := TRUE;
                        END IF;
                      END IF;

                      IF lb_invalid_pnote THEN
                        lb_prom_result := FALSE;
                        fnd_message.set_name('IGF','IGF_DB_PNOTE_NOT_ACC');
                        p_result := fnd_message.get;
                        fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                        -- message 'Prom Note not accepted'
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','prom note not accepted');
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;

            IF lv_fund_type ='P' THEN

              IF NVL(awd_disb_rec.org_record_req,'N') = 'Y' THEN
                OPEN  cur_get_pell(awd_disb_rec.award_id);
                FETCH cur_get_pell INTO get_pell_rec;

                IF cur_get_pell%NOTFOUND THEN
                  CLOSE cur_get_pell;
                  lb_orig_result := FALSE;
                  fnd_message.set_name('IGF','IGF_DB_GRANT_ID_NOT_FOUND');
                  p_result := fnd_message.get;
                  fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                  -- message 'Pell Origination record not found'
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','cur_get_pell%NOTFOUND');
                  END IF;
                ELSIF cur_get_pell%FOUND THEN
                  CLOSE cur_get_pell;
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','get_pell_rec.orig_action_code:'||get_pell_rec.orig_action_code);
                  END IF;
                  IF NVL(get_pell_rec.orig_action_code,'N') <> 'A' THEN
                    lb_orig_result := FALSE;
                    fnd_message.set_name('IGF','IGF_DB_GRANT_ORIG_NOT_ACC');
                    fnd_message.set_token('ORIGINATION_ID',get_pell_rec.origination_id);
                    p_result := fnd_message.get;
                    fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                    -- message 'Origination not accepted'
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','orig not accepted');
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF; -- fund type is Pell

          END IF; -- award id check

--
-- Validations
-- Checks that should be done at Term Level
-- This has to be done if the Fund Changes,
-- but terms are same
--
-- 1. Pays Only Fee Class
--
          lv_old_ld_c    := lv_new_ld_c;
          ln_old_ld_n    := ln_new_ld_n;

          lv_new_ld_c    := awd_disb_rec.ld_cal_type;
          ln_new_ld_n    := awd_disb_rec.ld_sequence_number;

          IF ( lv_old_ld_c <> lv_new_ld_c  AND ln_old_ld_n <> ln_new_ld_n ) OR
             ( ln_old_fund <> ln_new_fund )
             THEN

              lb_fclass_result := TRUE;
              lb_fclass_result := chk_fclass_result(awd_disb_rec.base_id,awd_disb_rec.fund_id,
                                                    awd_disb_rec.ld_cal_type,awd_disb_rec.ld_sequence_number);

              IF lb_log_detail THEN
                IF NOT lb_fclass_result THEN
                  fnd_message.set_name('IGF','IGF_DB_FAIL_FCLS');
                  --Disbursement failed Pays Only Fee Class Check
                  p_result := fnd_message.get;
                  fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                END IF;
              END IF;
              --
              -- Check Pell Amounts
              -- FA131 Check
              -- Call this only if award record is not locked and
              -- student is Pell Eligible
              --
              lb_pell_cal_result := TRUE;

              IF lv_fund_type = 'P' AND lb_elig_result THEN

                 OPEN  cur_term_amounts(awd_disb_rec.award_id,
                                        awd_disb_rec.ld_cal_type,
                                        awd_disb_rec.ld_sequence_number);
                 FETCH cur_term_amounts INTO term_amounts_rec;
                 CLOSE cur_term_amounts;

                 igf_gr_pell_calc.calc_term_pell(awd_disb_rec.base_id,
                                                 awd_disb_rec.base_attendance_type_code,
                                                 awd_disb_rec.ld_cal_type,awd_disb_rec.ld_sequence_number,
                                                 p_term_aid,
                                                 p_return_status,
                                                 p_message,
                                                 'DISBPROC',
                                                 p_pell_matrix);


                 IF NVL(p_return_status,'N') = 'E' THEN
                    lb_pell_cal_result := FALSE;
                    p_result := p_message;
                    fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                 ELSIF NVL(p_term_aid,0) < term_amounts_rec.term_total THEN
                    lb_pell_cal_result := FALSE;
                    fnd_message.set_name('IGF','IGF_GR_PELL_DISB_FAIL');
                    fnd_message.set_token('TERM_TOTAL',term_amounts_rec.term_total);
                    fnd_message.set_token('CALC_AMT',p_term_aid);
                    fnd_message.set_token('LD_ALT_CODE',igf_gr_gen.get_alt_code(awd_disb_rec.ld_cal_type,awd_disb_rec.ld_sequence_number));
                    fnd_message.set_token('ATT_TYPE',igf_aw_gen.lookup_desc('IGF_GR_RFMS_ENROL_STAT',awd_disb_rec.base_attendance_type_code));
                    p_result := fnd_message.get;
                    fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);

                 END IF;

              END IF;

          END IF;


--
-- 1. Cumulative Current Credit Points
-- 2. Disbursement Check  (Applicable for PELL/ CL)
-- 3. Fund Status Check (Applicable for CL)
-- 4. Min Att Type is specified

          lb_disb_result := TRUE;
          lb_recv_result := TRUE;

          IF NVL(awd_disb_rec.disb_record_req,'N') ='Y' THEN
            IF lv_fund_type = 'F' THEN
              IF lb_orig_result THEN
                IF NVL(awd_disb_rec.disb_status,'N') NOT IN ('A','D') THEN
                  lb_disb_result  := FALSE;

                  fnd_message.set_name('IGF','IGF_DB_CL_DISB_NOT_ACC');
                  p_result := fnd_message.get;
                  fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','disbursment not accepted');
                  END IF;
                END IF;
              END IF;

            ELSIF lv_fund_type ='P'  THEN
              OPEN  cur_get_disb (get_pell_rec.origination_id,awd_disb_rec.disb_num);
              FETCH cur_get_disb INTO get_disb_rec;

              IF cur_get_disb%NOTFOUND THEN
                CLOSE cur_get_disb;
                lb_disb_result  := FALSE;

                fnd_message.set_name('IGF','IGF_DB_GRANT_DISB_NOT_FOUND');
                p_result := fnd_message.get;
                fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','disbursment records not found');
                END IF;
              ELSIF cur_get_disb%FOUND THEN
                CLOSE cur_get_disb;
                IF NVL(get_disb_rec.disb_ack_act_status,'N') NOT IN ('A','C') THEN
                  lb_disb_result  := FALSE;
                  fnd_message.set_name('IGF','IGF_DB_GRANT_DISB_NOT_ACC');
                  fnd_message.set_token('ORIGINATION_ID',get_pell_rec.origination_id);
                  p_result := fnd_message.get;
                  fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug',get_pell_rec.origination_id||' not accepted');
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;

          IF NVL(awd_disb_rec.fund_recv_req,'N') = 'Y' THEN
            IF lv_fund_type = 'F' THEN
              IF NVL(awd_disb_rec.fund_status,'N') <> 'Y' THEN
                fnd_message.set_name('IGF','IGF_DB_CL_NOT_FUNDED');
                p_result := fnd_message.get;
                fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                lb_recv_result := FALSE;
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','funds are not yet received');
                END IF;
              END IF;
            END IF;
          END IF;


-- Get the Academic Year information

          lb_cp_result   := TRUE;
          IF awd_disb_rec.min_credit_pts IS NOT NULL THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','awd_disb_rec.min_credit_pts:'||awd_disb_rec.min_credit_pts);
            END IF;
            igs_en_prc_load.enrp_clc_cp_upto_tp_start_dt(
                                                         igf_gr_gen.get_person_id(awd_disb_rec.base_id),
                                                         awd_disb_rec.ld_cal_type,
                                                         awd_disb_rec.ld_sequence_number,
                                                         'Y',
                                                         get_cut_off_dt(
                                                                        awd_disb_rec.ld_sequence_number,
                                                                        awd_disb_rec.disb_date
                                                                       ),
                                                         ln_credit_pts
                                                        );

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','ln_credit_pts:'||ln_credit_pts);
            END IF;
            IF NVL(ln_credit_pts,0) < NVL(awd_disb_rec.min_credit_pts,0) THEN
              lb_cp_result := FALSE;
              --
              -- Call to Insert Hold
              --
              fnd_message.set_name('IGF','IGF_DB_FAIL_CRP');
              p_result := fnd_message.get;
              fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
            END IF;
          END IF;

          lb_att_result    := TRUE;
          IF awd_disb_rec.attendance_type_code IS NOT NULL THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','awd_disb_rec.attendance_type_code:'||awd_disb_rec.attendance_type_code);
            END IF;
            p_message     := NULL;
            lb_att_result := chk_att_result(awd_disb_rec.base_id,
                                            awd_disb_rec.ld_cal_type,
                                            awd_disb_rec.ld_sequence_number,
                                            awd_disb_rec.attendance_type_code,
                                            p_message);

          END IF;
          IF NOT lb_att_result THEN
            fnd_message.set_name('IGF','IGF_DB_FAIL_ATT');
            --Disbursement failed Attendance Type Check
            p_result := fnd_message.get;

            IF p_message IS NOT NULL THEN
               p_result := p_message ||fnd_global.newline ||p_result;
            END IF;
            fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','min attendance type check failed');
            END IF;
          END IF;

--
-- Based on these results, create actual record
--
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','get_ver_rec.fed_verif_status:'||get_ver_rec.fed_verif_status);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','awd_disb_rec.ver_app_stat_override:'||awd_disb_rec.ver_app_stat_override);
          END IF;

          IF lv_fund_type = 'D' THEN
            IF lb_todo_result       AND
               lb_pays_prg          AND
               lb_pays_uts          AND
               lb_elig_result       AND
               lb_prom_result       AND
               lb_fclass_result     AND
               lb_att_result        AND
               lb_cp_result         AND
               lb_active_result     AND
               lb_hold_result       AND
               lb_orig_result       THEN
--
-- Check for Allow First Disbu to Non-Verified Student
-- FA116 Bug 2758812 , 04-Feb-2003
--
              IF NVL(awd_disb_rec.ver_app_stat_override,'N')    = 'Y' THEN
                IF  NVL(get_ver_rec.fed_verif_status,'N') = 'WITHOUTDOC' THEN
                  IF NVL(awd_disb_rec.send_without_doc,'N') = 'Y' THEN
                    IF  awd_disb_rec.disb_num   = igf_gr_gen.get_min_disb_number(awd_disb_rec.award_id) THEN
                      lb_send_wdoc := TRUE;
                      fnd_message.set_name('IGF','IGF_DB_ALW_FIRST_VER');
                      p_result := fnd_message.get;
                      fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','first disb without doc');
                      END IF;
                    ELSE
                      lb_send_wdoc := FALSE;
                      fnd_message.set_name('IGF','IGF_DB_FAIL_SEC_VER');
                      p_result := fnd_message.get;
                      fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','without doc.cannot make disb');
                      END IF;
                    END IF;
                  ELSE
                    fnd_message.set_name('IGF','IGF_DB_FAIL_VERF_STAT');
                    p_result := fnd_message.get;
                    fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                    lb_send_wdoc := FALSE;
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','without doc');
                    END IF;
                  END IF;
                END IF;
              END IF;

              IF lb_send_wdoc THEN
                create_actual(awd_disb_rec.row_id,TRUE,FALSE,awd_disb_rec.fund_id);
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','called create_actual with fund_id '||awd_disb_rec.fund_id);
                END IF;
              END IF;
            END IF;
          ELSIF lv_fund_type = 'F' THEN
            IF lb_todo_result       AND
               lb_pays_prg          AND
               lb_pays_uts          AND
               lb_elig_result       AND
               lb_prom_result       AND
               lb_fclass_result     AND
               lb_att_result        AND
               lb_cp_result         AND
               lb_active_result     AND
               lb_orig_result       AND
               lb_disb_result       AND
               lb_hold_result       AND
               lb_recv_result       THEN
--
-- Check for Allow First Disbu to Non-Verified Student
-- FA116 Bug 2758812 , 04-Feb-2003
--

              IF NVL(awd_disb_rec.ver_app_stat_override,'N')    = 'Y' THEN
                IF  NVL(get_ver_rec.fed_verif_status,'N') = 'WITHOUTDOC' THEN
                  IF NVL(awd_disb_rec.send_without_doc,'N') = 'Y' THEN
                    IF  awd_disb_rec.disb_num   = igf_gr_gen.get_min_disb_number(awd_disb_rec.award_id) THEN
                      lb_send_wdoc := TRUE;
                      fnd_message.set_name('IGF','IGF_DB_ALW_FIRST_VER');
                      p_result := fnd_message.get;
                      fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igd_db_disb.process_student.debug','verf is not without doc.first disb without doc');
                      END IF;
                    ELSE
                      lb_send_wdoc := FALSE;
                      fnd_message.set_name('IGF','IGF_DB_FAIL_SEC_VER');
                      p_result := fnd_message.get;
                      fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','without doc.cannot make disb');
                      END IF;
                    END IF;
                  ELSE
                    fnd_message.set_name('IGF','IGF_DB_FAIL_VERF_STAT');
                    p_result := fnd_message.get;
                    fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                    lb_send_wdoc := FALSE;
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','without doc');
                    END IF;
                  END IF;
                END IF;
              END IF;

              IF lb_send_wdoc THEN
                create_actual(awd_disb_rec.row_id,TRUE,FALSE,awd_disb_rec.fund_id);
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','called create_actual with fund_id '||awd_disb_rec.fund_id);
                END IF;
              END IF;
            END IF;
          ELSIF lv_fund_type = 'P' THEN
            IF  lb_todo_result      AND
                lb_pays_prg         AND
                lb_pays_uts         AND
                lb_elig_result      AND
                lb_prom_result      AND
                lb_fclass_result    AND
                lb_att_result       AND
                lb_cp_result        AND
                lb_orig_result      AND
                lb_hold_result      AND
                lb_pell_cal_result  AND
                lb_disb_result      THEN
--
-- Check for Allow First Disbu to Non-Verified Student
-- FA116 Bug 2758812 , 04-Feb-2003
--
              IF NVL(awd_disb_rec.ver_app_stat_override,'N')    = 'Y' THEN
                IF  NVL(get_ver_rec.fed_verif_status,'N') = 'WITHOUTDOC' THEN
                  IF NVL(awd_disb_rec.send_without_doc,'N') = 'Y' THEN
                    IF  awd_disb_rec.disb_num   = igf_gr_gen.get_min_disb_number(awd_disb_rec.award_id) THEN
                      lb_send_wdoc := TRUE;
                      fnd_message.set_name('IGF','IGF_DB_ALW_FIRST_VER');
                      p_result := fnd_message.get;
                      fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igd_db_disb.process_student.debug','verf is not without doc.first disb without doc');
                      END IF;
                    ELSE
                      lb_send_wdoc := FALSE;
                      fnd_message.set_name('IGF','IGF_DB_FAIL_SEC_VER');
                      p_result := fnd_message.get;
                      fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','without doc.cannot make disb');
                      END IF;
                    END IF;
                  ELSE
                    fnd_message.set_name('IGF','IGF_DB_FAIL_VERF_STAT');
                    p_result := fnd_message.get;
                    fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                    lb_send_wdoc := FALSE;
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','without doc');
                    END IF;
                  END IF;
                END IF;
              END IF;

              IF lb_send_wdoc THEN
                create_actual(awd_disb_rec.row_id,TRUE,FALSE,awd_disb_rec.fund_id);
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','called create_actual with fund_id '||awd_disb_rec.fund_id);
                END IF;
              END IF;
            END IF;
          ELSIF lv_fund_type = 'C' THEN
            IF lb_todo_result       AND
               lb_pays_prg          AND
               lb_pays_uts          AND
               lb_fclass_result     AND
               lb_att_result        AND
               lb_hold_result       AND
               lb_cp_result         THEN
--
-- Check for Allow First Disbu to Non-Verified Student
-- FA116 Bug 2758812 , 04-Feb-2003
--

              IF NVL(awd_disb_rec.ver_app_stat_override,'N')    = 'Y' THEN
                IF  NVL(get_ver_rec.fed_verif_status,'N') = 'WITHOUTDOC' THEN
                  IF NVL(awd_disb_rec.send_without_doc,'N') = 'Y' THEN
                    IF  awd_disb_rec.disb_num   = igf_gr_gen.get_min_disb_number(awd_disb_rec.award_id) THEN
                      lb_send_wdoc := TRUE;
                      fnd_message.set_name('IGF','IGF_DB_ALW_FIRST_VER');
                      p_result := fnd_message.get;
                      fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igd_db_disb.process_student.debug','verf is not without doc.first disb without doc');
                      END IF;
                    ELSE
                      lb_send_wdoc := FALSE;
                      fnd_message.set_name('IGF','IGF_DB_FAIL_SEC_VER');
                      p_result := fnd_message.get;
                      fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','without doc.cannot make disb');
                      END IF;
                    END IF;
                  ELSE
                    fnd_message.set_name('IGF','IGF_DB_FAIL_VERF_STAT');
                    p_result := fnd_message.get;
                    fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
                    lb_send_wdoc := FALSE;
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','without doc');
                    END IF;
                  END IF;
                END IF;
              END IF;

              IF lb_send_wdoc THEN
                create_actual(awd_disb_rec.row_id,TRUE,FALSE,awd_disb_rec.fund_id);
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','called create_actual with fund_id '||awd_disb_rec.fund_id);
                END IF;
              END IF;
            END IF;
          ELSE
            IF lb_todo_result       AND
               lb_pays_prg          AND
               lb_pays_uts          AND
               lb_fclass_result     AND
               lb_att_result        AND
               lb_hold_result       AND
               lb_cp_result         THEN
                 create_actual(awd_disb_rec.row_id,FALSE,FALSE,awd_disb_rec.fund_id);
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','called create_actual with fund_id '||awd_disb_rec.fund_id);
                 END IF;
            END IF;
          END IF;

          -- clear message stack
          fnd_message.clear;

          FETCH cur_awd_disb INTO awd_disb_rec;
          EXIT WHEN cur_awd_disb%NOTFOUND;

          EXCEPTION

             WHEN app_exception.record_lock_exception THEN
               RAISE;

             WHEN gross_amt_zero THEN
               fnd_message.set_name('IGF','IGF_DB_CREATE_ZERO');
               fnd_message.set_token('AWARD_ID',TO_CHAR(awd_disb_rec.award_id));
               fnd_message.set_token('DISB_NUM',TO_CHAR(awd_disb_rec.disb_num));
               p_result := fnd_message.get;
               fnd_file.put_line(fnd_file.log,RPAD(' ',17) ||p_result);
               fnd_message.clear;
               FETCH cur_awd_disb INTO awd_disb_rec;
               EXIT WHEN cur_awd_disb%NOTFOUND;

             WHEN skip_record THEN
             -- clear message stack
               fnd_message.clear;
               FETCH cur_awd_disb INTO awd_disb_rec;
               EXIT WHEN cur_awd_disb%NOTFOUND;
          END;

      END LOOP;

      CLOSE cur_awd_disb;

    END IF;


    --Call generic API get_key_program to get cource code and version number.
    igf_ap_gen_001.get_key_program(p_base_id ,l_course_cd,l_ver_num );

    -- Call this routine only when submitted as a job
    IF lv_call_from <> 'FORM' THEN
      disb_verf_enf(p_base_id,
                    p_fund_id,
                    l_course_cd,
                    l_ver_num,
                    lv_acad_cal_type,
                    ln_acad_seq_num);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','called disb_verf_enf');
      END IF;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.process_student.debug','lv_call_from:'||lv_call_from);
    END IF;

                            --lock COA at the student level
                            IF lv_profile_value IS NULL THEN
                             --To check whether the profile value is set to a value of 'When Awards are disbursed' or not
                             fnd_profile.get('IGF_AW_LOCK_COA',lv_profile_value);
                            END IF;

                            IF lv_profile_value = 'DISBURSED' THEN

                                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','calling  igf_aw_coa_gen.doLock for base_id '||p_base_id);
                                END IF;

                                IF NOT igf_aw_coa_gen.isCOALocked(p_base_id) THEN
                                 lv_locking_success := igf_aw_coa_gen.doLock(p_base_id);
                                END IF;

                            END IF;




    -- This is to ensure that if and only if process student is called from Disbursement Detail Forms
    IF lv_call_from = 'FORM' THEN
       COMMIT;
    END IF;

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.new_line(fnd_file.log,1);
    fnd_message.set_name('IGF','IGF_DB_PLAN_DISB_TOT');
    fnd_message.set_token('TOT_NUM',TO_CHAR(ln_plan_disb));
    fnd_file.put_line(fnd_file.log,RPAD(' ',15) ||fnd_message.get);

    fnd_message.set_name('IGF','IGF_DB_ACT_DISB_TOT');
    fnd_message.set_token('TOT_NUM',TO_CHAR(ln_act_disb));
    fnd_file.put_line(fnd_file.log,RPAD(' ',15) ||fnd_message.get);

    fnd_message.set_name('IGF','IGF_DB_PLAN_DISB_FAIL');
    fnd_message.set_token('TOT_NUM',TO_CHAR(ln_plan_disb - ln_act_disb));
    fnd_file.put_line(fnd_file.log,RPAD(' ',15) ||fnd_message.get);

    fnd_message.set_name('IGF','IGF_DB_ENFR_DISB_TOT');
    fnd_message.set_token('TOT_NUM',TO_CHAR(ln_enfr_disb));
    fnd_file.put_line(fnd_file.log,RPAD(' ',15) ||fnd_message.get);

    fnd_message.set_name('IGF','IGF_DB_ENFR_DISB_P_TOT');
    fnd_message.set_token('TOT_NUM',TO_CHAR(ln_enfr_disb_p));
    fnd_file.put_line(fnd_file.log,RPAD(' ',15) ||fnd_message.get);

    fnd_message.set_name('IGF','IGF_DB_ENFR_DISB_FAIL');
    fnd_message.set_token('TOT_NUM',TO_CHAR(ln_enfr_disb - ln_enfr_disb_p));
    fnd_file.put_line(fnd_file.log,RPAD(' ',15) ||fnd_message.get);
    fnd_file.new_line(fnd_file.log,1);


EXCEPTION

    WHEN app_exception.record_lock_exception THEN
    RAISE;

    WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_DB_DISB.PROCESS_STUDENT' || SQLERRM);
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END process_student;

PROCEDURE disb_process( errbuf              OUT NOCOPY   VARCHAR2,
                        retcode             OUT NOCOPY   NUMBER,
                        p_award_year        IN    VARCHAR2,
                        p_run_for           IN    VARCHAR2,
                        p_per_grp_id        IN    NUMBER,
                        p_base_id           IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                        p_fund_id           IN    igf_aw_fund_mast_all.fund_id%TYPE,
                        p_log_det           IN    VARCHAR2,
                        p_org_id            IN    NUMBER )
AS

--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This is the callable for concurrent mananger.
--                              This process, depending on the input parameters passed
--                              will call the main process ie process_student()
--
--  Change History :
--  Who             When            What
--  (reverse chronological order - newest change first)
--  ridas           08-Feb-2006    Bug #5021084. Added new parameter 'lv_group_type' in
--                                 call to igf_ap_ss_pkg.get_pid
--  tsailaja		    13/Jan/2006    Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
--  rasahoo         27-aug-2003    Removed the call to IGF_AP_OSS_PROCESS.GET_OSS_DETAILS
--                                 as part of obsoletion of FA base record history
--------------------------------------------------------------------------------------------

        PARAM_EXCEPTION              EXCEPTION;

        l_ci_cal_type                igs_ca_inst.cal_type%TYPE;
        l_ci_sequence_number         igs_ca_inst.sequence_number%TYPE;
        lv_person_number             igf_ap_fa_con_v.person_number%TYPE;



        CURSOR c_award_det(cp_cal_type VARCHAR2,
                           cp_seq_number NUMBER)
        IS
        SELECT alternate_code
        FROM   igs_ca_inst
        WHERE  cal_type        = cp_cal_type
        AND    sequence_number = cp_seq_number;

        l_award_det c_award_det%ROWTYPE;

-- Cursor to retreive Persons from Person Group
        CURSOR cur_per_grp_name(
                                p_per_grp_id igs_pe_persid_group_all.group_id%TYPE
                               ) IS
        SELECT group_cd
          FROM igs_pe_persid_group
         WHERE group_id = p_per_grp_id;
        per_grp_rec     cur_per_grp_name%ROWTYPE;

-- Cursor to retreive Student having awards for a given fund
        CURSOR cur_award_std(p_fund_id  igf_aw_fund_mast_all.fund_id%TYPE)
        IS
        SELECT
        DISTINCT
        awd.base_id,
        fcat.fed_fund_code
        FROM
        igf_aw_award     awd,
        igf_aw_fund_mast fmast,
        igf_aw_fund_cat  fcat
        WHERE
        awd.fund_id      =  p_fund_id AND
        awd.fund_id      =  fmast.fund_id AND
        fmast.fund_code  =  fcat.fund_code AND
        awd.award_status = 'ACCEPTED';

        award_std_rec   cur_award_std%ROWTYPE;

        lv_result VARCHAR2(4000)  := NULL;
        ln_base_id NUMBER;

        l_list    VARCHAR2(32767);
        lv_status VARCHAR2(1);
        TYPE cur_person_id_type IS REF CURSOR;
        cur_per_grp cur_person_id_type;

        l_person_id         hz_parties.party_id%TYPE;
        lv_profile_value    VARCHAR2(30);
        lv_group_type       igs_pe_persid_group_v.group_type%TYPE;
BEGIN

		igf_aw_gen.set_org_id(NULL);
        errbuf    := NULL;
        retcode   := 0;
        lv_result := 'JOB';

        IF NVL(p_log_det,'N') = 'N' THEN
                lb_log_detail := FALSE;
        ELSE
                lb_log_detail := TRUE;
        END IF;

        l_ci_cal_type        := RTRIM(SUBSTR(p_award_year,1,10));
        l_ci_sequence_number := RTRIM(SUBSTR(p_award_year,11));

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','l_ci_cal_type:'||l_ci_cal_type);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','l_ci_sequence_number:'||l_ci_sequence_number);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','p_award_year:'||p_award_year);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','p_run_for:'||p_run_for);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','p_per_grp_id:'||p_per_grp_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','p_base_id:'||p_base_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','p_fund_id:'||p_fund_id);
        END IF;

        IF l_ci_cal_type IS NULL OR l_ci_sequence_number IS NULL THEN

               fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
               fnd_file.new_line(fnd_file.log,2);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               fnd_file.new_line(fnd_file.log,2);
               RAISE PARAM_EXCEPTION;
        END IF;

        OPEN  c_award_det(l_ci_cal_type,l_ci_sequence_number);
        FETCH c_award_det INTO l_award_det;
        IF c_award_det%NOTFOUND THEN
           fnd_message.set_name('IGF','IGF_AP_AWD_YR_NOT_FOUND');
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           fnd_file.new_line(fnd_file.log,1);
           CLOSE c_award_det;
           RETURN;
        ELSE
           CLOSE c_award_det;
        END IF;


        log_parameters( l_award_det.alternate_code,
                        p_run_for,
                        p_per_grp_id,
                        p_base_id,
                        p_fund_id,
                        p_log_det
                       );


        IF     p_run_for ='P' AND (( p_base_id IS NOT NULL )  OR (p_fund_id IS NOT NULL ))  THEN
               fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
               fnd_file.new_line(fnd_file.log,2);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               fnd_file.new_line(fnd_file.log,2);
               RAISE PARAM_EXCEPTION;
        ELSIF  p_run_for ='F' AND (( p_base_id IS NOT NULL )  OR (p_per_grp_id IS NOT NULL ))  THEN
               fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
               fnd_file.new_line(fnd_file.log,2);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               fnd_file.new_line(fnd_file.log,2);
               RAISE PARAM_EXCEPTION;
        ELSIF  p_run_for ='S' AND (( p_per_grp_id IS NOT NULL )  OR (p_fund_id IS NOT NULL ))  THEN
               fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
               fnd_file.new_line(fnd_file.log,2);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               fnd_file.new_line(fnd_file.log,2);
               RAISE PARAM_EXCEPTION;
        END IF;

        fnd_file.new_line(fnd_file.log,2);
        fnd_message.set_name('IGF','IGF_DB_PROCESS_AWD');
        fnd_message.set_token('AWD_YR',igf_gr_gen.get_alt_code (l_ci_cal_type,l_ci_sequence_number));
        -- Processing Disbursements for Award Year
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.new_line(fnd_file.log,1);

        IF p_run_for ='P' AND p_per_grp_id IS NOT NULL THEN

          -- Get all the persons in person group
          -- Bug #5021084
          l_list := igf_ap_ss_pkg.get_pid(p_per_grp_id,lv_status,lv_group_type);

          --Bug #5021084. Passing Group ID if the group type is STATIC.
          IF lv_group_type = 'STATIC' THEN
            OPEN cur_per_grp FOR ' SELECT party_id FROM hz_parties WHERE party_id IN (' || l_list  || ') ' USING p_per_grp_id;
          ELSIF lv_group_type = 'DYNAMIC' THEN
            OPEN cur_per_grp FOR ' SELECT party_id FROM hz_parties WHERE party_id IN (' || l_list  || ') ';
          END IF;

          FETCH cur_per_grp INTO l_person_id;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','Starting to process person group '||p_per_grp_id);
          END IF;

          IF cur_per_grp%NOTFOUND THEN
            CLOSE cur_per_grp;
            fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
            -- No student found in Person Group
            fnd_file.put_line(fnd_file.log,RPAD(' ',5) || fnd_message.get);
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','No persons in group '||p_per_grp_id);
            END IF;
          ELSE
            IF cur_per_grp%FOUND THEN
              fnd_message.set_name('IGF','IGF_DB_PROCESS_PER_GRP');
              -- Processing Disbursements for Person Group
              OPEN cur_per_grp_name(p_per_grp_id);
              FETCH cur_per_grp_name INTO per_grp_rec;
              CLOSE cur_per_grp_name;
              fnd_file.put_line(fnd_file.log,RPAD(' ',5) || fnd_message.get || '  ' || per_grp_rec.group_cd);

              -- Check if the person exists in FA.
              LOOP

                ln_base_id := 0;
                lv_person_number := NULL;

                lv_person_number  := per_in_fa (l_person_id,l_ci_cal_type,l_ci_sequence_number,ln_base_id);

                IF lv_person_number IS NOT NULL THEN

                    IF ln_base_id IS NOT NULL THEN
                          fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
                          fnd_message.set_token('STDNT',lv_person_number);
                          fnd_file.put_line(fnd_file.log,fnd_message.get);

                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','Processing student '||lv_person_number);
                          END IF;
                          --
                          -- Check for Academic Holds, only if con job is run
                          --
                          IF igf_aw_gen_005.get_stud_hold_effect('D',igf_gr_gen.get_person_id(ln_base_id)) = 'F' THEN
                            fnd_message.set_name('IGF','IGF_AW_DISB_FUND_HOLD_FAIL');
                            fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','get_stud_hold_effect returned F');
                            END IF;
                          ELSE
                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','calling process_student for base_id '||ln_base_id);
                            END IF;
                            process_student(ln_base_id,lv_result);


                          END IF;
                          fnd_message.set_name('IGF','IGF_DB_END_PROC_PER');
                          -- End of processing for person number
                          fnd_message.set_token('PER_NUM',lv_person_number);
                          fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
                          fnd_file.new_line(fnd_file.log,1);
                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','end processing '||lv_person_number);
                          END IF;
                    ELSE
                          -- log a message and skip this person
                          fnd_message.set_name('IGF','IGF_GR_LI_PER_INVALID');
                          fnd_message.set_token('PERSON_NUMBER',lv_person_number);
                          fnd_message.set_token('AWD_YR',l_award_det.alternate_code);
                          -- Person PER_NUM does not exist in FA
                          fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug',igf_gr_gen.get_per_num_oss(l_person_id) || ' not in FA');
                          END IF;
                    END IF;

                ELSE
                     fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
                     fnd_file.put_line(fnd_file.log,RPAD(' ',5) ||fnd_message.get);
                END IF;

                FETCH   cur_per_grp INTO l_person_id;
                EXIT WHEN cur_per_grp%NOTFOUND;

              END LOOP;
              CLOSE cur_per_grp;

            END IF;
          END IF;

        ELSIF  p_run_for ='S'  AND p_base_id IS NOT NULL THEN

          lv_person_number  := igf_gr_gen.get_per_num (p_base_id);

          fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
          fnd_message.set_token('STDNT',lv_person_number);
          fnd_file.put_line(fnd_file.log,fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','Starting processing single student '||lv_person_number);
          END IF;
          --
          -- Check for Academic Holds, only if con job is run
          --

          IF igf_aw_gen_005.get_stud_hold_effect('D',igf_gr_gen.get_person_id(p_base_id)) = 'F' THEN
            fnd_message.set_name('IGF','IGF_AW_DISB_FUND_HOLD_FAIL');
            fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','get_stud_hold_effect returned F');
             END IF;

          ELSE
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','calling process_student for base_id '||p_base_id);
            END IF;
            process_student(p_base_id,lv_result);

          END IF;
          fnd_message.set_name('IGF','IGF_DB_END_PROC_PER');
          -- End of processing for person number
          fnd_message.set_token('PER_NUM',lv_person_number);
          fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
          fnd_file.new_line(fnd_file.log,1);
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','end processing '||lv_person_number);
          END IF;

        ELSIF  p_run_for = 'F' AND p_fund_id IS NOT NULL THEN

        -- Get all the Students for which the Award is given
          OPEN    cur_award_std (p_fund_id);
          FETCH   cur_award_std INTO award_std_rec;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','starting processing for fund_id '||p_fund_id);
          END IF;

          IF cur_award_std%NOTFOUND THEN
            CLOSE cur_award_std;
            fnd_message.set_name('IGF','IGF_DB_NO_AWARDS');
            fnd_message.set_token('FDESC',get_fund_desc(p_fund_id));
            -- No Awards found for this Fund <fund code > : < fund desc >
            fnd_file.put_line(fnd_file.log,RPAD(' ',5) ||fnd_message.get);
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','No award for fund '||get_fund_desc(p_fund_id));
            END IF;
          ELSE
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','award_std_rec.fed_fund_code:'||award_std_rec.fed_fund_code);
            END IF;
            IF award_std_rec.fed_fund_code NOT IN ('FWS','SPNSR') THEN
              LOOP
                lv_person_number  := igf_gr_gen.get_per_num (award_std_rec.base_id);

                fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
                fnd_message.set_token('STDNT',lv_person_number);
                fnd_file.put_line(fnd_file.log,fnd_message.get);

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','starting processing '||lv_person_number);
                END IF;
                --
                -- Check for Academic Holds, only if con job is run
                --
                IF igf_aw_gen_005.get_stud_hold_effect('D',igf_gr_gen.get_person_id(award_std_rec.base_id)) = 'F' THEN
                  fnd_message.set_name('IGF','IGF_AW_DISB_FUND_HOLD_FAIL');
                  fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','get_stud_hold_effect returned F');
                  END IF;
                ELSE
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','calling process_student for base_id '||award_std_rec.base_id);
                  END IF;
                  process_student(award_std_rec.base_id,lv_result,p_fund_id);

                END IF;

                fnd_message.set_name('IGF','IGF_DB_END_PROC_PER');
                -- End of processing for person number
                fnd_message.set_token('PER_NUM',lv_person_number);
                fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
                fnd_file.new_line(fnd_file.log,1);

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','end processing '||lv_person_number);
                END IF;

                FETCH   cur_award_std INTO award_std_rec;
                EXIT WHEN cur_award_std%NOTFOUND;

              END LOOP;
              CLOSE cur_award_std;

            ELSE
              fnd_message.set_name('IGF','IGF_DB_NO_FWSS');
              fnd_file.put_line(fnd_file.log,RPAD(' ',10) ||fnd_message.get);
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.disb_process.debug','unsupported fund type '||award_std_rec.fed_fund_code);
              END IF;
            END IF;
          END IF;
        ELSE
          fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
          fnd_file.new_line(fnd_file.log,2);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          fnd_file.new_line(fnd_file.log,2);
          RAISE PARAM_EXCEPTION;

        END IF;


        COMMIT;

        EXCEPTION

        WHEN param_exception THEN

             ROLLBACK;
             retcode :=2;
             fnd_message.set_name('IGF','IGF_DB_PARAM_EX');
             igs_ge_msg_stack.add;
             igs_ge_msg_stack.conc_exception_hndl;

        WHEN app_exception.record_lock_exception THEN

             ROLLBACK;
             retcode := 2;
             fnd_message.set_name('IGF','IGF_GE_LOCK_ERROR');
             igs_ge_msg_stack.add;
             errbuf  := fnd_message.get;

        WHEN OTHERS THEN

             ROLLBACK;
             retcode := 2;
             fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
             fnd_file.put_line(fnd_file.log,SQLERRM);
             igs_ge_msg_stack.add;
             errbuf  := fnd_message.get;

END disb_process;



END igf_db_disb;

/
