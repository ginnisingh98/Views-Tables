--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_WAIVERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_WAIVERS" AS
/* $Header: IGSFI93B.pls 120.9 2006/05/04 07:40:13 abshriva noship $ */

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   10-Aug-2005
     Purpose         :   Package for the waiver processing

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     abshriva   4-May-2006   Bug 5178077: Introduced igs_ge_gen_003.set_org_id in process_waivers
     svuppala   24-Sep-2005   Bug# 4624875 Waiver Adjustment Charge Is Not Created (Manual Reversal Of Charge)
                              In Function validate_params, Changed the cursor cur_wav_pgm and the
                              conditional check for waiver category "COMP_RULE" was removed.

    ***************************************************************** */

  g_v_alternatecode igs_ca_inst.alternate_code%TYPE;

  g_v_seperator      CONSTANT VARCHAR2(1)  := '-';

  -- Procedure for enabling statement level logging
  PROCEDURE log_to_fnd (
    p_v_module IN VARCHAR2,
    p_v_string IN VARCHAR2
  );

  PROCEDURE proc_manual_waiver_adj(p_n_person_id                NUMBER,
                                   p_v_fee_type                 VARCHAR2,
                                   p_v_fee_cal_type             VARCHAR2,
                                   p_n_fee_ci_seq_number        NUMBER,
                                   p_v_currency_cd              VARCHAR2,
                                   p_d_gl_date                  DATE,
                                   p_v_process_mode             VARCHAR2,
                                   x_return_status   OUT NOCOPY VARCHAR2
                                   );


  FUNCTION validate_params(p_v_fee_cal_type             igs_ca_inst.cal_type%TYPE,
                           p_n_fee_ci_seq               igs_ca_inst.sequence_number%TYPE,
                           p_v_fee_type                 igs_fi_fee_type.fee_type%TYPE,
                           p_v_waiver_name              igs_fi_waiver_pgms.waiver_name%TYPE) RETURN BOOLEAN AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   10-Aug-2005
     Purpose         :   Procedure for validating parameters

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     svuppala   24-Sep-2005   Bug# 4624875 Waiver Adjustment Charge Is Not Created (Manual Reversal Of Charge )
                              Changed the cursor cur_wav_pgm and the conditional check for waiver category
                              "COMP_RULE" was removed.

    ***************************************************************** */

    CURSOR cur_wav_pgm(cp_v_fee_cal_type                igs_ca_inst.cal_type%TYPE,
                       cp_n_fee_ci_seq                  igs_ca_inst.sequence_number%TYPE,
                       cp_v_fee_type                    igs_fi_fee_type.fee_type%TYPE,
                       cp_v_waiver_name                 igs_fi_waiver_pgms.waiver_name%TYPE) IS
      SELECT waiver_name
      FROM   igs_fi_waiver_pgms
      WHERE  target_fee_type = cp_v_fee_type
      AND    fee_cal_type    = cp_v_fee_cal_type
      AND    fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    ((waiver_name = cp_v_waiver_name) OR (cp_v_waiver_name IS NULL));

    l_v_var          VARCHAR2(1);
    l_b_rec_found    BOOLEAN;
    l_b_ret_val      BOOLEAN;
    l_v_waiver_name  igs_fi_waiver_pgms.waiver_name%TYPE;

  BEGIN
    l_b_rec_found := FALSE;
    l_b_ret_val := TRUE;

    OPEN cur_wav_pgm(p_v_fee_cal_type,
                     p_n_fee_ci_seq,
                     p_v_fee_type,
                     p_v_waiver_name);

    FETCH cur_wav_pgm INTO l_v_waiver_name;
    -- If the cursor select returns atleast one row, setting the
    --boolean flag l_b_rec_found to TRUE
    IF cur_wav_pgm%FOUND THEN
        l_b_rec_found := TRUE;
    END IF;
    CLOSE cur_wav_pgm;

    IF NOT l_b_rec_found THEN
      IF p_v_waiver_name IS NULL THEN
        fnd_message.set_name('IGS',
                             'IGS_FI_WAV_PGM_NO_REC_FOUND');
        fnd_message.set_token('FEE_ALT_CD',
                              igs_ca_gen_001.calp_get_alt_cd(p_v_fee_cal_type,p_n_fee_ci_seq));
        fnd_message.set_token('FEE_TYPE',
                              p_v_fee_type);
      ELSE
        fnd_message.set_name('IGS',
                             'IGS_FI_WAV_FEE_CAL_INST');
      END IF;
      fnd_msg_pub.add;
      l_b_ret_val := FALSE;
    END IF;

    RETURN l_b_ret_val;
  END validate_params;

  FUNCTION get_calc_old_waiver_amt(p_n_person_id                NUMBER,
                                   p_v_fee_cal_type             VARCHAR2,
                                   p_n_fee_ci_seq_number        NUMBER,
                                   p_v_waiver_name              VARCHAR2) RETURN NUMBER AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   10-Aug-2005
     Purpose         :   Procedure for deriving the old waiver amount

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What

    ***************************************************************** */
    CURSOR cur_wav_crd(cp_n_person_id                igs_fi_credits_all.party_id%TYPE,
                       cp_v_fee_cal_type             igs_fi_credits_all.fee_cal_type%TYPE,
                       cp_n_fee_ci_seq               igs_fi_credits_all.fee_ci_sequence_number%TYPE,
                       cp_v_waiver_name              igs_fi_credits_all.waiver_name%TYPE) IS
      SELECT crd.amount,
             crd.credit_id
      FROM   igs_fi_credits_all crd
      WHERE  crd.party_id = cp_n_person_id
      AND    crd.fee_cal_type = cp_v_fee_cal_type
      AND    crd.fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    crd.waiver_name = cp_v_waiver_name;

    CURSOR cur_chg_appl(cp_n_credit_id         igs_fi_credits_all.credit_id%TYPE,
                        cp_v_fee_cal_type      igs_fi_credits_all.fee_cal_type%TYPE,
                        cp_n_fee_ci_seq        igs_fi_credits_all.fee_ci_sequence_number%TYPE,
                        cp_v_waiver_name       igs_fi_credits_all.waiver_name%TYPE) IS
      SELECT SUM(appl.amount_applied) amt_appl
      FROM   igs_fi_applications appl,
             igs_fi_inv_int_all  inv
      WHERE  appl.credit_id = cp_n_credit_id
      AND    appl.invoice_id = inv.invoice_id
      AND    inv.fee_cal_type = cp_v_fee_cal_type
      AND    inv.fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    inv.waiver_name = cp_v_waiver_name
      AND    appl.application_type = 'APP'
      AND    inv.transaction_type = 'WAIVER_ADJ';



    l_n_old_wav_amt        NUMBER;
  BEGIN
    log_to_fnd(p_v_module => 'get_calc_old_waiver_amt',
               p_v_string => ' Entered Function get_calc_old_waiver_amt: The input parameters are '||
                             ' p_n_person_id         : '  ||p_n_person_id          ||
                             ' p_v_fee_cal_type      : '  ||p_v_fee_cal_type       ||
                             ' p_n_fee_ci_seq_number : '  ||p_n_fee_ci_seq_number  ||
                             ' p_v_waiver_name       : '  ||p_v_waiver_name
              );
    l_n_old_wav_amt := 0;
    FOR l_rec_crd IN cur_wav_crd(p_n_person_id,
                                 p_v_fee_cal_type,
                                 p_n_fee_ci_seq_number,
                                 p_v_waiver_name) LOOP
      l_n_old_wav_amt := l_n_old_wav_amt + NVL(l_rec_crd.amount,0);

      FOR l_rec_chg IN cur_chg_appl(l_rec_crd.credit_id,
                                    p_v_fee_cal_type,
                                    p_n_fee_ci_seq_number,
                                    p_v_waiver_name) LOOP
        l_n_old_wav_amt := l_n_old_wav_amt - NVL(l_rec_chg.amt_appl,0);
      END LOOP;
    END LOOP;
    log_to_fnd(p_v_module => 'get_calc_old_waiver_amt',
               p_v_string => ' Function get_calc_old_waiver_amt returning '||
                             ' old Waiver Amount   : '  ||l_n_old_wav_amt
              );
    RETURN l_n_old_wav_amt;
  END get_calc_old_waiver_amt;

  PROCEDURE  call_fee_calc(p_n_person_id                igs_fi_inv_int_all.person_id%TYPE,
                           p_v_fee_type                 igs_fi_inv_int_all.fee_type%TYPE,
                           p_v_fee_cal_type             igs_fi_inv_int_all.fee_cal_type%TYPE,
                           p_n_fee_ci_seq               igs_fi_inv_int_all.fee_ci_sequence_number%TYPE,
                           p_d_gl_date                  DATE,
                           p_v_real_time_flag           VARCHAR2,
                           p_v_process_mode             VARCHAR2,
                           p_v_career                   VARCHAR2,
                           x_wav_amount      OUT NOCOPY NUMBER,
                           x_ret_status      OUT NOCOPY VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   10-Aug-2005
     Purpose         :   Procedure for calling Fee Calc

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What

    ***************************************************************** */
    l_n_waiver_amount         igs_fi_credits_all.amount%TYPE;
    l_d_date                  DATE;
    l_b_bool                  BOOLEAN;
    l_v_message_name          VARCHAR2(2000);
  BEGIN
    log_to_fnd(p_v_module => 'call_fee_calc',
               p_v_string => ' Entered Procedure call_fee_calc: The input parameters are '||
                             ' p_n_person_id         : '  ||p_n_person_id          ||
                             ' p_v_fee_type          : '  ||p_v_fee_type           ||
                             ' p_v_fee_cal_type      : '  ||p_v_fee_cal_type       ||
                             ' p_n_fee_ci_seq_number : '  ||p_n_fee_ci_seq         ||
                             ' p_d_gl_date           : '  ||p_d_gl_date            ||
                             ' p_v_real_time_flag    : '  ||p_v_real_time_flag     ||
                             ' p_v_process_mode      : '  ||p_v_process_mode       ||
                             ' p_v_career            : '  ||p_v_career
              );
    l_b_bool := igs_fi_prc_fee_ass.finp_ins_enr_fee_ass(p_effective_dt             => SYSDATE,
                                                        p_person_id                => p_n_person_id,
                                                        p_course_cd                => null,
                                                        p_fee_category             => null,
                                                        p_fee_cal_type             => p_v_fee_cal_type,
                                                        p_fee_ci_sequence_num      => p_n_fee_ci_seq,
                                                        p_fee_type                 => p_v_fee_type,
                                                        p_trace_on                 => 'N',
                                                        p_test_run                 => 'Y',
                                                        p_creation_dt              => l_d_date,
                                                        p_message_name             => l_v_message_name,
                                                        p_process_mode             => p_v_process_mode,
                                                        p_c_career                 => p_v_career,
                                                        p_d_gl_date                => p_d_gl_date,
                                                        p_v_wav_calc_flag          => 'Y',
                                                        p_n_waiver_amount          => l_n_waiver_amount);


    IF NOT l_b_bool THEN
      x_wav_amount := 0;
      x_ret_status := 'E';
    ELSE
      x_wav_amount := l_n_waiver_amount;
      x_ret_status := 'S';
    END IF;
    log_to_fnd(p_v_module => 'call_fee_calc',
               p_v_string => ' igs_fi_prc_fee_ass.finp_ins_enr_fee_ass returned '||
                             ' waiver amount : ' ||l_n_waiver_amount
               );
  EXCEPTION
    WHEN OTHERS THEN
      log_to_fnd(p_v_module => 'call_fee_calc',
                 p_v_string => ' Procedure call_fee_calc raised unhandled exception '||SQLERRM
                 );
      x_wav_amount := 0;
      x_ret_status := 'E';
      RAISE;
  END call_fee_calc;

  FUNCTION get_wav_amt(p_n_person_id             igs_fi_inv_int_all.person_id%TYPE,
                       p_v_fee_type              igs_fi_inv_int_all.fee_type%TYPE,
                       p_v_fee_cal_type          igs_fi_inv_int_all.fee_cal_type%TYPE,
                       p_n_fee_ci_seq            igs_fi_inv_int_all.fee_ci_sequence_number%TYPE,
                       p_v_waiver_name           igs_fi_inv_int_all.waiver_name%TYPE) RETURN NUMBER AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   10-Aug-2005
     Purpose         :   Procedure for Waiver Amount

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     smadathi   08-Nov-2005  Bug 4634950. Modified the cursor cur_prewav
                             to include filter criteria
    ***************************************************************** */

    CURSOR cur_inv(cp_n_person_id                  igs_fi_inv_int_all.person_id%TYPE,
                   cp_v_fee_type                   igs_fi_inv_int_all.fee_type%TYPE,
                   cp_v_fee_cal_type               igs_fi_inv_int_all.fee_cal_type%TYPE,
                   cp_n_fee_ci_seq                 igs_fi_inv_int_all.fee_ci_sequence_number%TYPE) IS
      SELECT inv.invoice_amount,
             inv.invoice_id
      FROM   igs_fi_inv_int_all inv
      WHERE  inv.person_id = cp_n_person_id
      AND    inv.fee_type  = cp_v_fee_type
      AND    inv.fee_cal_type = cp_v_fee_cal_type
      AND    inv.fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    inv.transaction_type <> 'RETENTION'
      ORDER BY inv.invoice_id;

    CURSOR cur_chgadj(cp_n_invoice_id       igs_fi_inv_int_all.invoice_id%TYPE) IS
      SELECT SUM(appl.amount_applied) amt_appl
      FROM   igs_fi_applications appl,
             igs_fi_credits_all crd,
             igs_fi_cr_types crt
      WHERE  appl.invoice_id = cp_n_invoice_id
      AND    appl.credit_id = crd.credit_id
      AND    crd.credit_type_id = crt.credit_type_id
      AND    crt.credit_class = 'CHGADJ';

    CURSOR cur_prewav(cp_v_fee_cal_type               igs_fi_inv_int_all.fee_cal_type%TYPE,
                      cp_n_fee_ci_seq                 igs_fi_inv_int_all.fee_ci_sequence_number%TYPE,
                      cp_v_waiver_name                igs_fi_wav_pr_preqs.sub_waiver_name%TYPE) IS
      SELECT fwpp.sup_waiver_name
      FROM   igs_fi_wav_pr_preqs fwpp
      WHERE  fwpp.fee_cal_type  = cp_v_fee_cal_type
      AND    fwpp.fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    fwpp.sub_waiver_name = cp_v_waiver_name;

    CURSOR cur_prewav_appl(cp_n_invoice_id           igs_fi_inv_int_all.invoice_id%TYPE,
                           cp_v_waiver_name          igs_fi_inv_int_all.waiver_name%TYPE,
                           cp_v_fee_cal_type         igs_fi_inv_int_all.fee_cal_type%TYPE,
                           cp_n_fee_ci_seq           igs_fi_inv_int_all.fee_ci_sequence_number%TYPE) IS
      SELECT appl.amount_applied,
             appl.application_id,
             appl.credit_id
      FROM   igs_fi_applications appl,
             igs_fi_credits_all crd,
             igs_fi_cr_types_all crt
      WHERE  appl.invoice_id  = cp_n_invoice_id
      AND    appl.credit_id = crd.credit_id
      AND    appl.application_type = 'APP'
      AND    crd.credit_type_id = crt.credit_type_id
      AND    crt.credit_class = 'WAIVER'
      AND    crd.fee_cal_type = cp_v_fee_cal_type
      AND    crd.fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    crd.waiver_name = cp_v_waiver_name
      ORDER  BY appl.application_id;

    CURSOR cur_wav_adj(cp_n_credit_id         igs_fi_credits_all.credit_id%TYPE,
                       cp_v_fee_cal_type      igs_fi_credits_all.fee_cal_type%TYPE,
                       cp_n_fee_ci_seq        igs_fi_credits_all.fee_ci_sequence_number%TYPE,
                       cp_n_invoice_id        igs_fi_inv_int.invoice_id%TYPE) IS
      SELECT igs_fi_gen_007.get_sum_appl_amnt(application_id) amt_appl
      FROM   igs_fi_applications appl,
             igs_fi_inv_int_all inv
      WHERE  appl.invoice_id = inv.invoice_id
      AND    appl.credit_id  = cp_n_credit_id
      AND    inv.fee_cal_type = cp_v_fee_cal_type
      AND    inv.fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    inv.transaction_type = 'WAIVER_ADJ'
      AND    appl.application_type = 'APP'
      AND    EXISTS (SELECT 'x'
                     FROM   igs_fi_credits_all crd1,
                igs_fi_applications appl1
         WHERE  appl1.credit_id = crd1.credit_id
         AND    crd1.credit_id  = cp_n_credit_id
         AND    appl1.invoice_id = cp_n_invoice_id
         AND    appl1.application_type = 'UNAPP'
         AND    appl1.amount_applied = - appl.amount_applied);

    l_n_inv_amt                         NUMBER;
    l_n_chgadj_amt                      NUMBER;
    l_n_prereq_wavcrd_amt               NUMBER;
    l_n_prereq_wavadj_amt               NUMBER;
    l_n_wav_app_amt                     NUMBER;

    l_n_wav_amt                         NUMBER;
  BEGIN
    log_to_fnd(p_v_module => 'get_wav_amt',
               p_v_string => ' Entered FUNCTION get_wav_amt: The input parameters are '||
                             ' p_n_person_id         : '  ||p_n_person_id          ||
                             ' p_v_fee_type          : '  ||p_v_fee_type           ||
                             ' p_v_fee_cal_type      : '  ||p_v_fee_cal_type       ||
                             ' p_n_fee_ci_seq_number : '  ||p_n_fee_ci_seq         ||
                             ' p_v_waiver_name       : '  ||p_v_waiver_name
              );
-- Loop across all the non-retention charges
    l_n_inv_amt := 0;

    FOR l_rec_inv IN cur_inv(p_n_person_id,
                             p_v_fee_type,
                             p_v_fee_cal_type,
                             p_n_fee_ci_seq) LOOP

      l_n_inv_amt := NVL(l_n_inv_amt,0) +
                     NVL(l_rec_inv.invoice_amount,0);

-- Identify the negative charge adjustments for the Charge
      FOR l_rec_chgadj IN cur_chgadj(l_rec_inv.invoice_id) LOOP
        l_n_inv_amt := NVL(l_n_inv_amt,0) -
                 NVL(l_rec_chgadj.amt_appl,0);
      END LOOP;

      l_n_wav_amt := 0;

-- Loop across the Superior waiver programs for the Fee Period and the waiver
-- passed as input
      FOR l_rec_prewav IN cur_prewav(p_v_fee_cal_type,
                                     p_n_fee_ci_seq,
                                     p_v_waiver_name) LOOP

-- Loop across the application records for the charge in context for the
-- Superior Waiver
        FOR l_rec_prewav_appl IN cur_prewav_appl(cp_n_invoice_id   => l_rec_inv.invoice_id,
                                                 cp_v_waiver_name  => l_rec_prewav.sup_waiver_name,
                                                 cp_v_fee_cal_type => p_v_fee_cal_type,
                                                 cp_n_fee_ci_seq   => p_n_fee_ci_seq
                                                 ) LOOP
          l_n_wav_amt := NVL(l_n_wav_amt,0) +
                   NVL(l_rec_prewav_appl.amount_applied,0);

-- Subtract the waiver adjustment amount
          FOR l_rec_wavchg IN cur_wav_adj(l_rec_prewav_appl.credit_id,
                                          p_v_fee_cal_type,
                                          p_n_fee_ci_seq,
            l_rec_inv.invoice_id) LOOP
            l_n_wav_amt := NVL(l_n_wav_amt,0) -
                     NVL(l_rec_wavchg.amt_appl,0);
          END LOOP;
        END LOOP;
      END LOOP;

      l_n_inv_amt := NVL(l_n_inv_amt,0) -
                     NVL(l_n_wav_amt,0);
    END LOOP;
    log_to_fnd(p_v_module => 'call_fee_calc',
               p_v_string => ' FUNCTION get_wav_amt returning '||
                             ' Calculated Waiver Amount : '    ||l_n_inv_amt
              );
    RETURN l_n_inv_amt;
  END get_wav_amt;

  PROCEDURE get_calc_new_waiver_amt(p_n_person_id                NUMBER,
                                    p_v_fee_cal_type             VARCHAR2,
                                    p_n_fee_ci_seq_number        NUMBER,
                                    p_v_waiver_name              VARCHAR2,
                                    p_v_target_fee_type          igs_fi_fee_type.fee_type%TYPE,
                                    p_v_rule_fee_type            igs_fi_fee_type.fee_type%TYPE,
                                    p_v_wav_criteria_code        VARCHAR2,
                                    p_n_wav_per_alloc            NUMBER,
                                    p_d_gl_date                  DATE,
                                    p_v_real_time_flag           VARCHAR2,
                                    p_v_process_mode             VARCHAR2,
                                    p_v_career                   VARCHAR2,
                                    x_return_wav_amt  OUT NOCOPY NUMBER,
                                    x_return_status   OUT NOCOPY VARCHAR2) AS
   /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   10-Aug-2005
     Purpose         :   Procedure for New Waiver Amount

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What

    ***************************************************************** */

    l_n_inv_amt                         NUMBER;
    l_n_chgadj_amt                      NUMBER;
    l_n_prereq_wavcrd_amt               NUMBER;
    l_n_prereq_wavadj_amt               NUMBER;
    l_n_wav_app_amt                     NUMBER;
  BEGIN

  log_to_fnd(p_v_module => 'get_calc_new_waiver_amt',
             p_v_string => ' Entered Procedure get_calc_new_waiver_amt: The input parameters are '||
                           ' p_n_person_id         : '  ||p_n_person_id          ||
                           ' p_v_target_fee_type   : '  ||p_v_target_fee_type    ||
                           ' p_v_fee_cal_type      : '  ||p_v_fee_cal_type       ||
                           ' p_n_fee_ci_seq_number : '  ||p_n_fee_ci_seq_number  ||
                           ' p_v_rule_fee_type     : '  ||p_v_rule_fee_type      ||
                           ' p_v_waiver_name       : '  ||p_v_waiver_name        ||
                           ' p_v_wav_criteria_code : '  ||p_v_wav_criteria_code  ||
                           ' p_n_wav_per_alloc     : '  ||p_n_wav_per_alloc      ||
                           ' p_v_real_time_flag    : '  ||p_v_real_time_flag     ||
                           ' p_v_process_mode      : '  ||p_v_process_mode       ||
                           ' p_v_career            : '  ||p_v_career
            );

-- If Waiver Criteria Code is passed as Null, return S and 0 amt
    IF p_v_wav_criteria_code IS NULL THEN
      log_to_fnd(p_v_module => 'get_calc_new_waiver_amt',
                 p_v_string => ' Null Waiver Criteria passed '
                 );
      x_return_wav_amt := 0;
      x_return_status := 'S';
    END IF;

-- IF waiver Criteria is Fee Balance
    IF p_v_wav_criteria_code = 'FEE_BALANCE' THEN

-- Calculate the Waiver Amount
      x_return_wav_amt := get_wav_amt(p_n_person_id          => p_n_person_id,
                                      p_v_fee_type           => p_v_rule_fee_type,
                                      p_v_fee_cal_type       => p_v_fee_cal_type,
                                      p_n_fee_ci_seq         => p_n_fee_ci_seq_number,
                                      p_v_waiver_name        => p_v_waiver_name);
      log_to_fnd(p_v_module => 'get_calc_new_waiver_amt',
                 p_v_string => ' get_wav_amt returned the calculated waiver amount '||x_return_wav_amt
                 );
      x_return_status := 'S';
    ELSIF p_v_wav_criteria_code = 'COMPUTE_AMOUNT' THEN

-- If real time flag is set to Y and rule fee type is same as target fee type
      IF p_v_real_time_flag = 'Y' THEN
        IF p_v_rule_fee_type = p_v_target_fee_type THEN
          x_return_wav_amt := get_wav_amt(p_n_person_id          => p_n_person_id,
                                          p_v_fee_type           => p_v_rule_fee_type,
                                          p_v_fee_cal_type       => p_v_fee_cal_type,
                                          p_n_fee_ci_seq         => p_n_fee_ci_seq_number,
                                          p_v_waiver_name        => p_v_waiver_name);
          log_to_fnd(p_v_module => 'get_calc_new_waiver_amt',
                     p_v_string => ' get_wav_amt returned the calculated waiver amount '||x_return_wav_amt
                     );
          x_return_status := 'S';
        ELSE

-- Call Fee Calc
          call_fee_calc(p_n_person_id          => p_n_person_id,
                        p_v_fee_type           => p_v_rule_fee_type,
                        p_v_fee_cal_type       => p_v_fee_cal_type,
                        p_n_fee_ci_seq         => p_n_fee_ci_seq_number,
                        p_d_gl_date            => p_d_gl_date,
                        p_v_real_time_flag     => p_v_real_time_flag,
                        p_v_process_mode       => p_v_process_mode,
                        p_v_career             => p_v_career,
                        x_wav_amount           => x_return_wav_amt,
                        x_ret_status           => x_return_status);
          IF x_return_status <> 'S' THEN
            log_to_fnd(p_v_module => 'get_calc_new_waiver_amt',
                       p_v_string => ' Procedure call_fee_calc errored out'
                      );
            x_return_status := 'E';
            RETURN;
          END IF;
        END IF;
      ELSE

-- Call Fee Calc
        call_fee_calc(p_n_person_id            => p_n_person_id,
                        p_v_fee_type           => p_v_rule_fee_type,
                        p_v_fee_cal_type       => p_v_fee_cal_type,
                        p_n_fee_ci_seq         => p_n_fee_ci_seq_number,
                        p_d_gl_date            => p_d_gl_date,
                        p_v_real_time_flag     => p_v_real_time_flag,
                        p_v_process_mode       => p_v_process_mode,
                        p_v_career             => p_v_career,
                        x_wav_amount           => x_return_wav_amt,
                        x_ret_status           => x_return_status);
          IF x_return_status <> 'S' THEN
            log_to_fnd(p_v_module => 'get_calc_new_waiver_amt',
                       p_v_string => ' Procedure call_fee_calc errored out'
                      );
            x_return_status := 'E';
            RETURN;
          END IF;
      END IF;
    END IF;
    x_return_wav_amt := (NVL(x_return_wav_amt,0)*NVL(p_n_wav_per_alloc,0))/100;
    log_to_fnd(p_v_module => 'get_calc_new_waiver_amt',
               p_v_string => ' Procedure get_calc_new_waiver_amt returning '||
                             ' Calculated new waiver amount : '             ||x_return_wav_amt
              );
  END get_calc_new_waiver_amt;



  PROCEDURE create_waivers(p_n_person_id                NUMBER,
                           p_v_fee_type                 VARCHAR2,
                           p_v_fee_cal_type             VARCHAR2,
                           p_n_fee_ci_seq_number        NUMBER,
                           p_v_waiver_name              VARCHAR2,
                           p_v_currency_cd              VARCHAR2,
                           p_d_gl_date                  DATE,
                           p_v_real_time_flag           VARCHAR2,
                           p_v_process_mode             VARCHAR2,
                           p_v_career                   VARCHAR2,
                           p_b_init_msg_list            BOOLEAN,
                           p_validation_level           NUMBER,
                           p_v_raise_wf_event           VARCHAR2,
                           x_waiver_amount   OUT NOCOPY NUMBER,
                           x_return_status   OUT NOCOPY VARCHAR2,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   10-Aug-2005
     Purpose         :   Procedure for creating waivers

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     agairola   27-Oct-2005  Bug 4704177: Enhancement for Tuition Waiver
                             CCR. Added check for the Error Account = 'Y'

    ***************************************************************** */

    CURSOR cur_wav_pgm(cp_v_fee_cal_type              igs_ca_inst.cal_type%TYPE,
                       cp_n_fee_ci_seq                igs_ca_inst.sequence_number%TYPE,
                       cp_v_fee_type                  igs_fi_fee_type.fee_type%TYPE,
                       cp_v_waiver_name               igs_fi_waiver_pgms.waiver_name%TYPE) IS
      SELECT fwp.*
      FROM   igs_fi_waiver_pgms fwp
      WHERE  fwp.target_fee_type  = cp_v_fee_type
      AND    fwp.fee_cal_type     = cp_v_fee_cal_type
      AND    fwp.fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    ((fwp.waiver_name = cp_v_waiver_name) OR (cp_v_waiver_name IS NULL))
      ORDER BY fwp.creation_date;

    CURSOR cur_wav_std_pgm(cp_n_person_id             igs_pe_person_base_v.person_id%TYPE,
                           cp_v_fee_cal_type          igs_ca_inst.cal_type%TYPE,
                           cp_n_fee_ci_seq            igs_ca_inst.sequence_number%TYPE,
                           cp_v_waiver_name           igs_fi_waiver_pgms.waiver_name%TYPE) IS
      SELECT assignment_status_code
      FROM   igs_fi_wav_std_pgms
      WHERE  person_id = cp_n_person_id
      AND    fee_cal_type = cp_v_fee_cal_type
      AND    fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    waiver_name = cp_v_waiver_name;

    CURSOR cur_ctrl IS
      SELECT NVL(waiver_notify_finaid_flag,'N') waiver_notify_finaid_flag
      FROM   igs_fi_control;

    l_v_manage_acc         igs_fi_control_all.manage_accounts%TYPE;
    l_v_message_name       VARCHAR2(2000);
    l_v_ret_status         VARCHAR2(1);

    l_n_old_wav_amnt       igs_fi_credits_all.amount%TYPE;
    l_n_new_wav_amnt       igs_fi_credits_all.amount%TYPE;

    l_b_wavpgm             BOOLEAN;
    l_b_chr_err_account    NUMBER;
    l_v_var                VARCHAR2(1);

    l_n_comp_wav_amnt       igs_fi_credits_all.amount%TYPE;
    l_n_eligible_amnt       igs_fi_credits_all.amount%TYPE;
    l_n_diff_wav_amnt       igs_fi_credits_all.amount%TYPE;
    l_n_credit_id           igs_fi_credits_all.credit_id%TYPE;
    l_n_invoice_id          igs_fi_inv_int_all.invoice_id%TYPE;

    l_v_finaid_wvr_flag     igs_fi_control.waiver_notify_finaid_flag%TYPE;
    l_n_tot_wav_amnt        igs_fi_credits_all.amount%TYPE;
    l_v_assgn_stat_code     igs_fi_wav_std_pgms.assignment_status_code%TYPE;

    l_n_prc_cnt             NUMBER;
  BEGIN

  -- Create a savepoint
    SAVEPOINT create_waivers_sp;
    IF p_b_init_msg_list THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := 'S';

  log_to_fnd(p_v_module => 'create_waivers',
             p_v_string => ' Entered Procedure create_waivers: The input parameters are '||
                           ' p_n_person_id         : '  ||p_n_person_id          ||
                           ' p_v_fee_type          : '  ||p_v_fee_type           ||
                           ' p_v_fee_cal_type      : '  ||p_v_fee_cal_type       ||
                           ' p_n_fee_ci_seq_number : '  ||p_n_fee_ci_seq_number  ||
                           ' p_v_waiver_name       : '  ||p_v_waiver_name        ||
                           ' p_v_currency_cd       : '  ||p_v_currency_cd        ||
                           ' p_d_gl_date           : '  ||p_d_gl_date            ||
                           ' p_v_real_time_flag    : '  ||p_v_real_time_flag     ||
                           ' p_v_process_mode      : '  ||p_v_process_mode       ||
                           ' p_v_career            : '  ||p_v_career             ||
                           ' p_v_raise_wf_event    : '  ||p_v_raise_wf_event
            );
-- Check for Manage Accounts
    igs_fi_com_rec_interface.chk_manage_account(p_v_manage_acc    => l_v_manage_acc,
                                                p_v_message_name  => l_v_message_name);

    IF l_v_manage_acc IS NULL OR l_v_manage_acc = 'OTHER' THEN
      x_return_status := 'E';
      fnd_message.set_name('IGS',
                           l_v_message_name);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

   -- Validate input parameters

    -- If any of the input parameters is Null, then return status as 'E'
    IF p_n_person_id IS NULL OR
       p_v_fee_type  IS NULL OR
       p_v_fee_cal_type IS NULL OR
       p_n_fee_ci_seq_number IS NULL OR
       p_v_currency_cd IS NULL OR
       p_d_gl_date IS NULL OR
       p_v_raise_wf_event IS NULL
    THEN
      fnd_message.set_name('IGS','IGS_FI_PARAMETER_NULL');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_validation_level = 100 THEN
      IF NOT validate_params(p_v_fee_cal_type   => p_v_fee_cal_type,
                             p_n_fee_ci_seq     => p_n_fee_ci_seq_number,
                             p_v_fee_type       => p_v_fee_type,
                             p_v_waiver_name    => p_v_waiver_name) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

-- call the procedure for manual waiver adjustment
    proc_manual_waiver_adj(p_n_person_id          => p_n_person_id,
                           p_v_fee_type           => p_v_fee_type,
                           p_v_fee_cal_type       => p_v_fee_cal_type,
                           p_n_fee_ci_seq_number  => p_n_fee_ci_seq_number,
                           p_v_currency_cd        => p_v_currency_cd,
                           p_d_gl_date            => p_d_gl_date,
                           p_v_process_mode       => p_v_process_mode,
                           x_return_status        => l_v_ret_status);

    IF l_v_ret_status = 'E' THEN
      log_to_fnd(p_v_module => 'create_waivers',
                 p_v_string => ' proc_manual_waiver_adj errored out'
                );
      fnd_message.set_name('IGS',
                           'IGS_FI_WAV_NO_TRANS_CREATED');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Get the Financial Aid Waiver Flag from System Options
    OPEN cur_ctrl;
    FETCH cur_ctrl INTO l_v_finaid_wvr_flag;
    CLOSE cur_ctrl;

-- Loop across the waiver programs
    FOR l_rec_wavpgm IN cur_wav_pgm(p_v_fee_cal_type,
                                    p_n_fee_ci_seq_number,
                                    p_v_fee_type,
                                    p_v_waiver_name) LOOP
      log_to_fnd(p_v_module => 'create_waivers',
                 p_v_string => ' Processing waiver program '||l_rec_wavpgm.waiver_name          ||
                               ' Fee Calendar '||p_v_fee_cal_type || ' '||p_n_fee_ci_seq_number
                );
      l_n_old_wav_amnt  := 0;
      l_n_new_wav_amnt  := 0;
      l_n_comp_wav_amnt := 0;
      l_n_credit_id     := NULL;
      l_n_invoice_id    := NULL;
      l_n_prc_cnt       := 0;
      l_b_wavpgm        := FALSE;

-- Check if the Student has the Waiver associated
      OPEN cur_wav_std_pgm(p_n_person_id,
                           p_v_fee_cal_type,
                           p_n_fee_ci_seq_number,
                           l_rec_wavpgm.waiver_name);
      FETCH cur_wav_std_pgm INTO l_v_assgn_stat_code;
      IF cur_wav_std_pgm%FOUND THEN
        l_b_wavpgm := TRUE;
      END IF;
      CLOSE cur_wav_std_pgm;

      IF (l_b_wavpgm) THEN
          log_to_fnd(p_v_module => 'create_waivers',
                     p_v_string => ' Waiver Assignments found for '                ||
                                   ' Student           :  '||p_n_person_id         ||
                                   ' Assignment Status :  '||l_v_assgn_stat_code   ||
                                   ' Fee Calendar Type :  '||p_v_fee_cal_type      ||
                                   ' Fee Sequence Num  :  '||p_n_fee_ci_seq_number ||
                                   ' Waiver program    :  '||l_rec_wavpgm.waiver_name
                    );
        IF (l_rec_wavpgm.waiver_status_code = 'ACTIVE') AND
           (l_v_assgn_stat_code = 'ACTIVE') THEN
           -- Check if the Charge transactions for the Person, Fee Type and Fee Period combination
           -- have the Error Account flag set.
          l_b_chr_err_account := igs_fi_wav_utils_002.check_chg_error_account (
                                   p_n_person_id         => p_n_person_id,
                                   p_v_fee_type          => p_v_fee_type,
                                   p_v_fee_cal_type      => p_v_fee_cal_type,
                                   p_n_fee_ci_seq_number => p_n_fee_ci_seq_number
                                 );
          IF (l_b_chr_err_account=1) THEN
            log_to_fnd(p_v_module => 'create_waivers',
                       p_v_string => 'Charges with Error Account exist. Waivers cannot be created');
            fnd_message.set_name('IGS','IGS_FI_WAV_CHG_ERR');
            fnd_message.set_token('PERSON',igs_fi_gen_008.get_party_number(p_n_party_id => p_n_person_id));
            fnd_message.set_token('FEE_TYPE',p_v_fee_type);
            fnd_message.set_token('FEE_PERIOD',
                                  igs_ca_gen_001.calp_get_alt_cd(p_cal_type => p_v_fee_cal_type,
                                                                 p_sequence_number => p_n_fee_ci_seq_number)
                                 );
            fnd_msg_pub.add;
            x_waiver_amount := 0;
            RAISE fnd_api.g_exc_error;
          END IF;
          IF p_v_raise_wf_event = 'Y' THEN
            -- Raise the Student Assignment Event
            log_to_fnd(p_v_module => 'create_waivers',
                       p_v_string => ' Invoking raise_stdntwavassign_event'
                      );
            igs_fi_wav_dtls_wf.raise_stdntwavassign_event(p_n_person_id         => p_n_person_id,
                                                          p_v_waiver_name       => l_rec_wavpgm.waiver_name,
                                                          p_c_fee_cal_type      => p_v_fee_cal_type,
                                                          p_n_fee_ci_seq_number => p_n_fee_ci_seq_number);
          END IF;

          -- Get the new waiver amount
          get_calc_new_waiver_amt(p_n_person_id              => p_n_person_id,
                                  p_v_fee_cal_type           => p_v_fee_cal_type,
                                  p_n_fee_ci_seq_number      => p_n_fee_ci_seq_number,
                                  p_v_waiver_name            => l_rec_wavpgm.waiver_name,
                                  p_v_target_fee_type        => l_rec_wavpgm.target_fee_type,
                                  p_v_rule_fee_type          => l_rec_wavpgm.rule_fee_type,
                                  p_v_wav_criteria_code      => l_rec_wavpgm.waiver_criteria_code,
                                  p_n_wav_per_alloc          => l_rec_wavpgm.waiver_percent_alloc,
                                  p_d_gl_date                => p_d_gl_date,
                                  p_v_real_time_flag         => p_v_real_time_flag,
                                  p_v_process_mode           => p_v_process_mode,
                                  p_v_career                 => p_v_career,
                                  x_return_wav_amt           => l_n_comp_wav_amnt,
                                  x_return_status            => x_return_status);
          IF x_return_status = 'E' THEN
            log_to_fnd(p_v_module => 'create_waivers',
                       p_v_string => ' get_calc_new_waiver_amt errored out'
                      );
            fnd_message.set_name('IGS',
                                 'IGS_FI_WAV_NO_TRANS_CREATED');
            fnd_msg_pub.add;
            x_waiver_amount := 0;
            RAISE fnd_api.g_exc_error;
          END IF;

          -- Calculate eligible waiver amount
          igs_fi_wav_utils_001.get_eligible_waiver_amt(p_n_person_id          => p_n_person_id,
                                                       p_v_fee_cal_type       => p_v_fee_cal_type,
                                                       p_n_fee_ci_seq_number  => p_n_fee_ci_seq_number,
                                                       p_v_waiver_name        => l_rec_wavpgm.waiver_name,
                                                       p_v_target_fee_type    => l_rec_wavpgm.target_fee_type,
                                                       p_v_waiver_method_code => l_rec_wavpgm.waiver_method_code,
                                                       p_v_waiver_mode_code   => null,
                                                       p_n_source_invoice_id  => null,
                                                       x_return_status        => x_return_status,
                                                       x_eligible_amount      => l_n_eligible_amnt);
          IF x_return_status = 'E' THEN
            log_to_fnd(p_v_module => 'create_waivers',
                       p_v_string => ' igs_fi_wav_utils_001.get_eligible_waiver_amt errored out'
                      );
            fnd_message.set_name('IGS',
                                 'IGS_FI_WAV_NO_TRANS_CREATED');
            fnd_msg_pub.add;
            x_waiver_amount := 0;
            RAISE fnd_api.g_exc_error;
          END IF;
          log_to_fnd(p_v_module => 'create_waivers',
                     p_v_string => ' igs_fi_wav_utils_001.get_eligible_waiver_amt returned'||
                                   ' Eligible amount  : '||l_n_eligible_amnt
                );

          l_n_new_wav_amnt := l_n_comp_wav_amnt;

          IF l_n_comp_wav_amnt > l_n_eligible_amnt THEN
            l_n_new_wav_amnt := l_n_eligible_amnt;
          END IF;
        END IF;
        log_to_fnd(p_v_module => 'create_waivers',
                   p_v_string => ' New Waiver Amount : '||l_n_new_wav_amnt
                  );
        -- Calculate Old waiver amount
        l_n_old_wav_amnt := get_calc_old_waiver_amt(p_n_person_id         => p_n_person_id,
                                                    p_v_fee_cal_type      => p_v_fee_cal_type,
                                                    p_n_fee_ci_seq_number => p_n_fee_ci_seq_number,
                                                    p_v_waiver_name       => l_rec_wavpgm.waiver_name);

        -- Calculate the difference
        l_n_diff_wav_amnt := NVL(l_n_new_wav_amnt,0) -
                             NVL(l_n_old_wav_amnt,0);

        log_to_fnd(p_v_module => 'create_waivers',
                   p_v_string => ' Difference in Waiver Amount : '||l_n_diff_wav_amnt
                  );

        -- If the diff > 0 then call Credits API
        IF l_n_diff_wav_amnt > 0 THEN
          igs_fi_wav_utils_002.call_credits_api(p_n_person_id              => p_n_person_id,
                                                p_v_fee_cal_type           => p_v_fee_cal_type,
                                                p_n_fee_ci_seq_number      => p_n_fee_ci_seq_number,
                                                p_v_waiver_name            => l_rec_wavpgm.waiver_name,
                                                p_n_credit_type_id         => l_rec_wavpgm.credit_type_id,
                                                p_v_currency_cd            => p_v_currency_cd,
                                                p_n_waiver_amt             => l_n_diff_wav_amnt,
                                                p_d_gl_date                => p_d_gl_date,
                                                p_n_credit_id              => l_n_credit_id,
                                                x_return_status            => x_return_status);
          IF x_return_status <> 'S' THEN
            log_to_fnd(p_v_module => 'create_waivers',
                       p_v_string => ' igs_fi_wav_utils_002.call_credits_api errored out'
                      );
            fnd_message.set_name('IGS',
                                 'IGS_FI_WAV_NO_TRANS_CREATED');
            fnd_msg_pub.add;
            x_waiver_amount := 0;
            RAISE fnd_api.g_exc_error;
          END IF;
          log_to_fnd(p_v_module => 'create_waivers',
                     p_v_string => ' The call to igs_fi_wav_utils_002.call_credits_api ' ||
                                   ' returned waiver credit id : ' ||l_n_credit_id
                    );
        ELSIF (l_n_diff_wav_amnt < 0) THEN
      -- Else call Charges API
          igs_fi_wav_utils_002.call_charges_api(p_n_person_id              => p_n_person_id,
                                                p_v_fee_cal_type           => p_v_fee_cal_type,
                                                p_n_fee_ci_seq_number      => p_n_fee_ci_seq_number,
                                                p_v_waiver_name            => l_rec_wavpgm.waiver_name,
                                                p_v_adj_fee_type           => l_rec_wavpgm.adjustment_fee_type,
                                                p_v_currency_cd            => p_v_currency_cd,
                                                p_n_waiver_amt             => l_n_diff_wav_amnt,
                                                p_d_gl_date                => p_d_gl_date,
                                                p_n_invoice_id             => l_n_invoice_id,
                                                x_return_status            => x_return_status);
          IF x_return_status <> 'S' THEN
            log_to_fnd(p_v_module => 'create_waivers',
                       p_v_string => ' igs_fi_wav_utils_002.call_charges_api errored out'
                      );
            fnd_message.set_name('IGS',
                                 'IGS_FI_WAV_NO_TRANS_CREATED');
            fnd_msg_pub.add;
            x_waiver_amount := 0;
            RAISE fnd_api.g_exc_error;
          END IF;
          log_to_fnd(p_v_module => 'create_waivers',
                     p_v_string => ' The call to igs_fi_wav_utils_002.call_charges_api ' ||
                                   ' returned waiver Adjustment id : ' ||l_n_invoice_id
                    );
        END IF;
        IF NVL(l_n_diff_wav_amnt,0) <> 0 THEN
        -- Apply waivers
          igs_fi_wav_utils_001.apply_waivers(p_n_person_id          => p_n_person_id,
                                             p_v_fee_cal_type       => p_v_fee_cal_type,
                                             p_n_fee_ci_seq_number  => p_n_fee_ci_seq_number,
                                             p_v_waiver_name        => l_rec_wavpgm.waiver_name,
                                             p_v_target_fee_type    => l_rec_wavpgm.target_fee_type,
                                             p_v_adj_fee_type       => l_rec_wavpgm.adjustment_fee_type,
                                             p_v_waiver_method_code => l_rec_wavpgm.waiver_method_code,
                                             p_v_waiver_mode_code   => l_rec_wavpgm.waiver_mode_code,
                                             p_n_source_credit_id   => l_n_credit_id,
                                             p_n_source_invoice_id  => l_n_invoice_id,
                                             p_v_currency_cd        => p_v_currency_cd,
                                             p_d_gl_date            => p_d_gl_date,
                                             x_return_status        => x_return_status);

          IF x_return_status <> 'S' THEN
            log_to_fnd(p_v_module => 'create_waivers',
                       p_v_string => ' igs_fi_wav_utils_001.apply_waivers errored out'
                      );
            fnd_message.set_name('IGS',
                                 'IGS_FI_WAV_NO_TRANS_CREATED');
            fnd_msg_pub.add;
            x_waiver_amount := 0;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
        -- If the flag is 'Y', raise the business event
        IF l_v_finaid_wvr_flag = 'Y' AND p_v_raise_wf_event = 'Y' THEN
            log_to_fnd(p_v_module => 'create_waivers',
                       p_v_string => ' Invoking raise_wavtrandtlstofa_event'
                      );
          igs_fi_wav_dtls_wf.raise_wavtrandtlstofa_event(p_n_person_id          => p_n_person_id,
                                                         p_v_waiver_name        => l_rec_wavpgm.waiver_name,
                                                         p_c_fee_cal_type       => p_v_fee_cal_type,
                                                         p_n_fee_ci_seq_number  => p_n_fee_ci_seq_number,
                                                         p_n_waiver_amount      => l_n_diff_wav_amnt);

        END IF;

        l_n_tot_wav_amnt := NVL(l_n_tot_wav_amnt,0) +
                                l_n_diff_wav_amnt;
      END IF;
    END LOOP;
    log_to_fnd(p_v_module => 'create_waivers',
               p_v_string => ' The total Waiver Amount : '||l_n_tot_wav_amnt
              );
    x_waiver_amount := l_n_tot_wav_amnt;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_waivers_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      x_waiver_amount := 0;
      fnd_msg_pub.count_and_get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_waivers_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_waiver_amount := 0;
      fnd_msg_pub.count_and_get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_waivers_sp;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(
          p_pkg_name        => 'igs.plsql.igs_fi_prc_waivers',
          p_procedure_name  => 'create_waivers'
        );
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_waiver_amount := 0;
      fnd_msg_pub.count_and_get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);
  END create_waivers;

  PROCEDURE proc_manual_waiver_adj(p_n_person_id                NUMBER,
                                   p_v_fee_type                 VARCHAR2,
                                   p_v_fee_cal_type             VARCHAR2,
                                   p_n_fee_ci_seq_number        NUMBER,
                                   p_v_currency_cd              VARCHAR2,
                                   p_d_gl_date                  DATE,
                                   p_v_process_mode             VARCHAR2,
                                   x_return_status   OUT NOCOPY VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   10-Aug-2005
     Purpose         :   Procedure for manual waiver adjustments

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What

    ***************************************************************** */

    CURSOR cur_wav_pgms(cp_v_fee_type              igs_fi_fee_type.fee_type%TYPE,
                        cp_v_fee_cal_type          igs_fi_inv_int_all.fee_cal_type%TYPE,
                        cp_n_fee_ci_seq            igs_fi_inv_int_all.fee_ci_sequence_number%TYPE) IS
      SELECT fwp.fee_cal_type,
             fwp.fee_ci_sequence_number,
             fwp.waiver_name,
             fwp.waiver_method_code,
             fwp.waiver_status_code,
             fwp.credit_type_id,
             fwp.target_fee_type,
             fwp.waiver_mode_code,
             fwp.adjustment_fee_type
      FROM   igs_fi_waiver_pgms fwp
      WHERE  fwp.target_fee_type = cp_v_fee_type
      AND    fwp.fee_cal_type     = cp_v_fee_cal_type
      AND    fwp.fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    fwp.waiver_method_code = 'MANUAL';

    CURSOR cur_crd(cp_n_person_id             igs_fi_credits_all.party_id%TYPE,
                   cp_v_waiver_name           igs_fi_credits_all.waiver_name%TYPE,
                   cp_v_fee_cal_type          igs_fi_credits_all.fee_cal_type%TYPE,
                   cp_n_fee_ci_seq            igs_fi_credits_all.fee_ci_sequence_number%TYPE) IS
      SELECT credit_id,
             amount,
             unapplied_amount
      FROM   igs_fi_credits_all
      WHERE  party_id = cp_n_person_id
      AND    fee_cal_type = cp_v_fee_cal_type
      AND    fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    waiver_name = cp_v_waiver_name
      AND    unapplied_amount > 0;

    CURSOR cur_app(cp_n_credit_id igs_fi_credits_all.credit_id%TYPE) IS
      SELECT invoice_id
      FROM   igs_fi_applications
      WHERE  credit_id = cp_n_credit_id
      AND    application_type = 'UNAPP'
      ORDER BY application_id;

      l_b_chr_err_account NUMBER;
  BEGIN
    log_to_fnd(p_v_module => 'proc_manual_waiver_adj',
               p_v_string => ' Entered Procedure proc_manual_waiver_adj: The input parameters are '||
                             ' p_n_person_id         : '  ||p_n_person_id          ||
                             ' p_v_fee_type          : '  ||p_v_fee_type           ||
                             ' p_v_fee_cal_type      : '  ||p_v_fee_cal_type       ||
                             ' p_n_fee_ci_seq_number : '  ||p_n_fee_ci_seq_number  ||
                             ' p_v_currency_cd       : '  ||p_v_currency_cd        ||
                             ' p_d_gl_date           : '  ||p_d_gl_date            ||
                             ' p_v_process_mode      : '  ||p_v_process_mode
              );
    x_return_status := 'S';

  -- If any of the input parameters is Null, then return status as 'E'
    IF p_n_person_id IS NULL OR
       p_v_fee_type  IS NULL OR
       p_v_fee_cal_type IS NULL OR
       p_n_fee_ci_seq_number IS NULL OR
       p_v_currency_cd IS NULL OR
       p_d_gl_date IS NULL THEN

      x_return_status := 'E';
      RETURN;
    END IF;

-- Loop across the waiver programs
    FOR l_rec_wav_pgms IN cur_wav_pgms(p_v_fee_type,
                                       p_v_fee_cal_type,
                                       p_n_fee_ci_seq_number) LOOP
-- Loop across the Credits
      FOR l_rec_crd IN cur_crd(p_n_person_id,
                               l_rec_wav_pgms.waiver_name,
                               p_v_fee_cal_type,
                               p_n_fee_ci_seq_number) LOOP

-- If the waiver mode code is Charge Level, then apply waivers
        IF l_rec_wav_pgms.waiver_mode_code = 'CHARGE_LEVEL' THEN
          FOR l_rec_app IN cur_app(l_rec_crd.credit_id) LOOP
            igs_fi_wav_utils_001.apply_waivers(p_n_person_id          => p_n_person_id,
                                               p_v_fee_cal_type       => p_v_fee_cal_type,
                                               p_n_fee_ci_seq_number  => p_n_fee_ci_seq_number,
                                               p_v_waiver_name        => l_rec_wav_pgms.waiver_name,
                                               p_v_target_fee_type    => l_rec_wav_pgms.target_fee_type,
                                               p_v_adj_fee_type       => l_rec_wav_pgms.adjustment_fee_type,
                                               p_v_waiver_method_code => l_rec_wav_pgms.waiver_method_code,
                                               p_v_waiver_mode_code   => l_rec_wav_pgms.waiver_mode_code,
                                               p_n_source_credit_id   => l_rec_crd.credit_id,
                                               p_n_source_invoice_id  => l_rec_app.invoice_id,
                                               p_v_currency_cd        => p_v_currency_cd,
                                               p_d_gl_date            => p_d_gl_date,
                                               x_return_status        => x_return_status);
            IF x_return_status <> 'S' THEN
              log_to_fnd(p_v_module => 'proc_manual_waiver_adj',
                         p_v_string => ' Procedure igs_fi_wav_utils_001.apply_waivers errored out'
                        );
              x_return_status := 'E';
              RETURN;
            END IF;
          END LOOP;
        ELSE
           -- Check if the Charge transactions for the Person, Fee Type and Fee Period combination
           -- have the Error Account flag set.
          l_b_chr_err_account := igs_fi_wav_utils_002.check_chg_error_account (
                                   p_n_person_id         => p_n_person_id,
                                   p_v_fee_type          => l_rec_wav_pgms.target_fee_type,
                                   p_v_fee_cal_type      => p_v_fee_cal_type,
                                   p_n_fee_ci_seq_number => p_n_fee_ci_seq_number
                                 );
          IF (l_b_chr_err_account=1) THEN
            log_to_fnd(p_v_module => 'create_waivers',
                       p_v_string => 'Charges with Error Account exist. Waivers cannot be created');
            x_return_status := 'E';
            RETURN;
          END IF;
          igs_fi_wav_utils_001.apply_waivers(p_n_person_id          => p_n_person_id,
                                             p_v_fee_cal_type       => p_v_fee_cal_type,
                                             p_n_fee_ci_seq_number  => p_n_fee_ci_seq_number,
                                             p_v_waiver_name        => l_rec_wav_pgms.waiver_name,
                                             p_v_target_fee_type    => l_rec_wav_pgms.target_fee_type,
                                             p_v_adj_fee_type       => l_rec_wav_pgms.adjustment_fee_type,
                                             p_v_waiver_method_code => l_rec_wav_pgms.waiver_method_code,
                                             p_v_waiver_mode_code   => l_rec_wav_pgms.waiver_mode_code,
                                             p_n_source_credit_id   => l_rec_crd.credit_id,
                                             p_n_source_invoice_id  => null,
                                             p_v_currency_cd        => p_v_currency_cd,
                                             p_d_gl_date            => p_d_gl_date,
                                             x_return_status        => x_return_status);
          IF x_return_status <> 'S' THEN
            log_to_fnd(p_v_module => 'proc_manual_waiver_adj',
                       p_v_string => ' Procedure igs_fi_wav_utils_001.apply_waivers errored out'
                      );
            x_return_status := 'E';
            RETURN;
          END IF;
        END IF;
      END LOOP;
    END LOOP;

  END proc_manual_waiver_adj;

PROCEDURE log_to_fnd (
  p_v_module IN VARCHAR2,
  p_v_string IN VARCHAR2
) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 31 August 2005
--
-- Purpose:
-- Invoked     : from within API
-- Function    : Private procedure for logging all the statement level
--               messages
-- Parameters  : p_v_module   : IN parameter. Required.
--               p_v_string   : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
BEGIN

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_fi_prc_waivers.'||p_v_module, p_v_string);
  END IF;
END log_to_fnd;

  PROCEDURE validate_params( p_n_person_id              IN  hz_parties.party_id%TYPE,
                             p_n_person_grp_id          IN  igs_pe_persid_group.group_id%TYPE,
                             p_v_fee_cal                IN  VARCHAR2,
                             p_v_waiver_name            IN  IGS_FI_WAIVER_PGMS.WAIVER_NAME%TYPE,
                             p_v_fee_type               IN  IGS_FI_WAIVER_PGMS.TARGET_FEE_TYPE%TYPE,
                             p_d_gl_date                IN  VARCHAR2,
                             p_v_fee_cal_type           OUT NOCOPY igs_ca_inst.cal_type%TYPE,
                             p_n_fee_ci_sequence_number OUT NOCOPY igs_ca_inst.sequence_number%TYPE,
                             p_v_ld_cal_type            OUT NOCOPY igs_ca_inst.cal_type%TYPE,
                             p_n_ld_ci_sequence_number  OUT NOCOPY igs_ca_inst.sequence_number%TYPE,
                             p_val_status               OUT NOCOPY BOOLEAN)   IS
  ------------------------------------------------------------------
    --Created by  :Gurpreet Singh , Oracle India (in)
    --Date created: 08-Aug, 2005
    --
    --Purpose: To Validate the input parameters and log messages to the
    --         Log File.
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
  -------------------------------------------------------------------
    CURSOR cur_chk_per_grp_id(cp_n_person_grp_id IGS_PE_PERSID_GROUP_V.group_id%TYPE)
    IS
     SELECT 'X'
     FROM igs_pe_persid_group_v
     WHERE group_id = cp_n_person_grp_id;

    CURSOR cur_chk_waiver_name(cp_v_fee_cal_type IGS_FI_WAIVER_PGMS.FEE_CAL_TYPE%TYPE,
                               cp_n_fee_ci_seq_nbr IGS_FI_WAIVER_PGMS.FEE_CI_SEQUENCE_NUMBER%TYPE,
                               cp_v_waiver_name IGS_FI_WAIVER_PGMS.WAIVER_NAME%TYPE)
    IS
     SELECT fwp.fee_cal_type,
            fwp.fee_ci_sequence_number,
            fwp.waiver_name,
            fwp.waiver_method_code,
            fwp.target_fee_type
     FROM   igs_fi_waiver_pgms fwp
     WHERE  fwp.fee_cal_type    = cp_v_fee_cal_type
     AND    fwp.fee_ci_sequence_number = cp_n_fee_ci_seq_nbr
     AND    fwp.waiver_name = cp_v_waiver_name;

    CURSOR cur_chk_fee_type(cp_v_fee_cal_type IGS_FI_WAIVER_PGMS.FEE_CAL_TYPE%TYPE,
                            cp_n_fee_ci_seq_nbr IGS_FI_WAIVER_PGMS.FEE_CI_SEQUENCE_NUMBER%TYPE,
                            cp_v_target_fee_type IGS_FI_WAIVER_PGMS.TARGET_FEE_TYPE%TYPE)
    IS
     SELECT 'X'
     FROM  igs_fi_waiver_pgms fwp
     WHERE fwp.fee_cal_type    = cp_v_fee_cal_type
     AND   fwp.fee_ci_sequence_number = cp_n_fee_ci_seq_nbr
     AND   fwp.target_fee_type = cp_v_target_fee_type;

    l_rec_cur_chk_waiver_name cur_chk_waiver_name%ROWTYPE;

    l_v_valid_person VARCHAR2(1);
    l_v_dummy        VARCHAR2(1);
    l_b_parameter_val_status BOOLEAN;

    l_v_ld_cal_type igs_ca_inst.cal_type%TYPE;
    l_n_ld_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_v_message_name fnd_new_messages.message_name%TYPE;

    l_b_return_stat  BOOLEAN;
    l_v_closing_status  igs_fi_gl_periods_v.closing_status%TYPE;

    l_v_fee_cal_type igs_ca_inst.cal_type%TYPE;
    l_n_fee_ci_sequence_number igs_ca_inst.sequence_number%TYPE;

    BEGIN
      l_b_parameter_val_status := TRUE;

     --validate person id
     IF p_n_person_id IS NOT NULL THEN
       l_v_valid_person := igs_fi_gen_007.validate_person(p_person_id  => p_n_person_id);
       IF l_v_valid_person = 'N' THEN
         fnd_message.set_name('IGS','IGS_FI_INVALID_PERSON');
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         l_b_parameter_val_status := FALSE;
       END IF;
     END IF;

     --validate person grp id
     IF p_n_person_grp_id IS NOT NULL THEN
       OPEN cur_chk_per_grp_id(p_n_person_grp_id);
       FETCH cur_chk_per_grp_id into l_v_dummy;
       IF cur_chk_per_grp_id%NOTFOUND THEN
         CLOSE cur_chk_per_grp_id;
         fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
         fnd_message.set_token('PARAMETER',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON_GROUP')||': '||p_n_person_id);
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         l_b_parameter_val_status := FALSE;
       ELSE
        CLOSE cur_chk_per_grp_id;
       END IF;
     END IF;

     --person number and person grp id both cannot be provided.
     IF p_n_person_id IS NOT NULL AND p_n_person_grp_id IS NOT NULL THEN
       fnd_message.set_name('IGS','IGS_FI_NO_PERS_PGRP');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       l_b_parameter_val_status := FALSE;
     END IF;

     IF p_v_fee_cal IS NOT NULL THEN
       l_v_fee_cal_type := RTRIM(SUBSTR(p_v_fee_cal,1,10));
       l_n_fee_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_v_fee_cal,12,8)));

       IF igs_fi_crdapi_util.validate_cal_inst( p_v_cal_type           => l_v_fee_cal_type,
                                                p_n_ci_sequence_number => l_n_fee_ci_sequence_number,
                                                p_v_s_cal_cat          => 'FEE') THEN
         -- Call To The Procedure To Check Whether The Fee Calendar Instance Has
         -- One To One Relation With Load Calendar Instance

         igs_fi_crdapi_util.validate_fci_lci_reln(p_v_fee_cal_type           => l_v_fee_cal_type,
                                                 p_n_fee_ci_sequence_number => l_n_fee_ci_sequence_number,
                                                 p_v_ld_cal_type            => l_v_ld_cal_type ,
                                                 p_n_ld_ci_sequence_number  => l_n_ld_ci_sequence_number ,
                                                 p_v_message_name           => l_v_message_name ,
                                                 p_b_return_stat            =>l_b_return_stat);
         IF NOT l_b_return_stat THEN
           fnd_message.set_name('IGS',l_v_message_name);
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           l_b_parameter_val_status := FALSE;
         END IF;
       ELSE
         -- The Message 'Invalid Fee Period Parameters Passed To The Process.' Is Logged If
         -- The Function Returns False.
         fnd_message.set_name('IGS','IGS_FI_FCI_NOTFOUND');
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         l_b_parameter_val_status := FALSE;
       END IF;
     END IF;

     --validate waiver name
     IF p_v_waiver_name IS NOT NULL THEN
       IF p_v_fee_cal IS NOT NULL THEN
         OPEN cur_chk_waiver_name(l_v_fee_cal_type, l_n_fee_ci_sequence_number, p_v_waiver_name);
         FETCH cur_chk_waiver_name INTO l_rec_cur_chk_waiver_name;
         IF cur_chk_waiver_name%NOTFOUND THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_FI_WPRG_FTYP_NOT_EXIST');
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           l_b_parameter_val_status := FALSE;
         END IF;
         CLOSE cur_chk_waiver_name;

         IF l_rec_cur_chk_waiver_name.WAIVER_METHOD_CODE <> 'COMP_RULE' THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_FI_WAV_CAT_INVALID');
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           l_b_parameter_val_status := FALSE;
         END IF;
       END IF;

       IF p_v_fee_type IS NOT NULL THEN
         IF l_rec_cur_chk_waiver_name.TARGET_FEE_TYPE <> p_v_fee_type THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_FI_WAV_FEE_CAL_INST');
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           l_b_parameter_val_status := FALSE;
         END IF;
       END IF;

     END IF;

     --validate fee type
     IF p_v_fee_type IS NOT NULL THEN
       IF p_v_fee_cal IS NOT NULL THEN
         OPEN cur_chk_fee_type(l_v_fee_cal_type, l_n_fee_ci_sequence_number, p_v_fee_type);
         FETCH cur_chk_fee_type INTO l_v_dummy;
         IF cur_chk_fee_type%NOTFOUND THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_FI_WAV_FEE_CAL_INST');
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           l_b_parameter_val_status := FALSE;
         END IF;

       END IF;
     END IF;

     -- To Validate The Parameter Gl Date
    IF p_d_gl_date IS NULL THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_INSUFFICIENT_PARAMETER');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_b_parameter_val_status := FALSE;
    ELSE
      igs_fi_gen_gl.get_period_status_for_date(p_d_date           => igs_ge_date.igsdate(p_d_gl_date),
                                               p_v_closing_status => l_v_closing_status,
                                               p_v_message_name   => l_v_message_name);
      IF l_v_message_name IS NOT NULL THEN
        fnd_message.set_name('IGS',l_v_message_name);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        l_b_parameter_val_status := FALSE;
      END IF;

      IF l_v_closing_status NOT IN ('O','F') THEN
        fnd_message.set_name('IGS','IGS_FI_INVALID_GL_DATE');
        fnd_message.set_token('GL_DATE',p_d_gl_date);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        l_b_parameter_val_status := FALSE;
      END IF;

    END IF;

    --Assign The Values To The Out Parameters.
    p_v_fee_cal_type  := l_v_fee_cal_type;
    p_n_fee_ci_sequence_number :=l_n_fee_ci_sequence_number;
    p_v_ld_cal_type := l_v_ld_cal_type;
    p_n_ld_ci_sequence_number := l_n_ld_ci_sequence_number;
    p_val_status := l_b_parameter_val_status;

  END validate_params;

  PROCEDURE log_result(p_n_person_id              IN  hz_parties.party_id%TYPE,
                       p_v_waiver_name            IN  IGS_FI_WAIVER_PGMS.WAIVER_NAME%TYPE,
                       p_v_fee_type               IN  IGS_FI_WAIVER_PGMS.TARGET_FEE_TYPE%TYPE,
                       p_n_waiver_amount          IN  NUMBER,
                       p_v_status                 IN  VARCHAR2) IS
  ------------------------------------------------------------------
    --Created by  :Gurpreet Singh , Oracle India (in)
    --Date created: 08-Aug, 2005
    --
    --Purpose: To log Failure or Success of process waivers to the Concurrent Log file.
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
  -------------------------------------------------------------------
  BEGIN
    --Logging Person Number.
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON')||': '||igs_fi_gen_008.get_party_number(p_n_person_id));
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    --Logging Waiver Program Name.
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','WAIVER_NAME')||': '||p_v_waiver_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    --Logging Fee Type
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_TYPE')||': '||p_v_fee_type);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    IF p_v_status = 'SUCCESS' THEN
      --Logging  Waiver Amount
      fnd_message.set_name('IGS','IGS_FI_END_DATE');
      fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','WAIVER_AMOUNT')||': '||p_n_waiver_amount);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

    --Logging Status
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','STATUS')||': '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',p_v_status));
    fnd_file.put_line(fnd_file.log,fnd_message.get);

  END log_result;

  PROCEDURE log_in_parameters(p_n_person_id              IN  hz_parties.party_id%TYPE,
                              p_n_person_grp_id          IN  igs_pe_persid_group.group_id%TYPE,
                              p_v_fee_cal                IN  VARCHAR2,
                              p_v_waiver_name            IN  IGS_FI_WAIVER_PGMS.WAIVER_NAME%TYPE,
                              p_v_fee_type               IN  IGS_FI_WAIVER_PGMS.TARGET_FEE_TYPE%TYPE,
                              p_d_gl_date                IN  VARCHAR2) IS
  ------------------------------------------------------------------
    --Created by  :Gurpreet Singh , Oracle India (in)
    --Date created: 08-Aug, 2005
    --
    --Purpose: To log Inbound Parameters to the Log File.
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
  -------------------------------------------------------------------
    --Cursor For Getting The Alternate Code For The Fee Period.
    CURSOR c_get_alt_code(cp_v_cal_type igs_ca_inst.cal_type%TYPE,
                          cp_n_sequence_number igs_ca_inst.sequence_number%TYPE) IS
      SELECT alternate_code
      FROM igs_ca_inst_all
      WHERE cal_type = cp_v_cal_type
      AND   sequence_number = cp_n_sequence_number;

    l_c_alt_code_desc c_get_alt_code%ROWTYPE;

    --Cursor For Getting The Group Code For The Group Id
    CURSOR c_get_person_grp (c_group_id igs_pe_persid_group_v.group_id%TYPE) IS
      SELECT group_cd
      FROM  igs_pe_persid_group_v
      WHERE group_id = c_group_id;

    l_c_get_person_grp c_get_person_grp%ROWTYPE;

  BEGIN

    --Logging of all the Parameter to the Log File.

    --Logging Fee Period.
    OPEN c_get_alt_code(cp_v_cal_type        => RTRIM(SUBSTR(p_v_fee_cal,1,10)),
                        cp_n_sequence_number => TO_NUMBER(RTRIM(SUBSTR(p_v_fee_cal,12,8))));

    FETCH c_get_alt_code INTO l_c_alt_code_desc;
    CLOSE c_get_alt_code;
    g_v_alternatecode := l_c_alt_code_desc.alternate_code;
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_PERIOD')||': '||l_c_alt_code_desc.alternate_code);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    --Logging Person Number.
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON')||': '||igs_fi_gen_008.get_party_number(p_n_person_id));
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    --Logging  Person Group.
    OPEN c_get_person_grp(p_n_person_grp_id);
    FETCH c_get_person_grp INTO l_c_get_person_grp;
    CLOSE c_get_person_grp;
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON_GROUP')||': '||l_c_get_person_grp.group_cd);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    --Logging  Waiver Program Name.
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','WAIVER_NAME')||': '||p_v_waiver_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    --Logging  Fee Type
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_TYPE')||': '||p_v_fee_type);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    --Logging  GL Date.
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','GL_DATE')||': '||p_d_gl_date);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

  END log_in_parameters;


  PROCEDURE process_waivers( errbuf              OUT NOCOPY VARCHAR2,
                             retcode             OUT NOCOPY NUMBER,
                             p_person_id         IN  hz_parties.party_id%TYPE,
                             p_person_grp_id     IN  igs_pe_persid_group.group_id%TYPE,
                             p_fee_cal           IN  VARCHAR2,
                             p_waiver_name       IN  IGS_FI_WAIVER_PGMS.WAIVER_NAME%TYPE,
                             p_fee_type          IN  IGS_FI_WAIVER_PGMS.TARGET_FEE_TYPE%TYPE,
                             p_gl_date           IN  VARCHAR2 ) IS
  ------------------------------------------------------------------
    --Created by  :Gurpreet Singh, Oracle India (in)
    --Date created: 08-Aug-2005
    --
    --Purpose: - Invoked to create the waiver transactions on the student's account
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --abshriva   4-May-2006   Bug 5178077: Introduced igs_ge_gen_003.set_org_id
  -------------------------------------------------------------------
    TYPE person_grp_ref_cur_type IS REF CURSOR;
    c_ref_person_grp person_grp_ref_cur_type;

    l_n_person_id hz_parties.party_id%TYPE;
    l_dynamic_sql VARCHAR2(32767);
    l_v_status    VARCHAR2(1);
    l_v_manage_acc       igs_fi_control_all.manage_accounts%TYPE;
    l_v_message_name     fnd_new_messages.message_name%TYPE;

    -- Out Parameters from the Process_Waivers procedure.
    l_b_recs_found BOOLEAN;
    l_v_return_status VARCHAR2(1);
    l_b_validate_parm_status BOOLEAN;
    l_v_fee_cal_type igs_ca_inst.cal_type%TYPE;
    l_n_fee_ci_seq_number igs_ca_inst.sequence_number%TYPE;
    l_v_load_cal_type igs_ca_inst.cal_type%TYPE;
    l_n_load_ci_seq_number igs_ca_inst.sequence_number%TYPE;

    l_conv_process_run_ind igs_fi_control.conv_process_run_ind%TYPE;
    l_n_balance_rule_id igs_fi_balance_rules.balance_rule_id%TYPE;
    l_d_last_conversion_date igs_fi_balance_rules.last_conversion_date%TYPE;
    l_n_version_number igs_fi_balance_rules.version_number%TYPE;
    l_msg VARCHAR2(2000);

    l_v_process_mode VARCHAR2(6);
    l_n_waiver_amount IGS_FI_CREDITS_ALL.amount%TYPE;

    l_v_msg_data VARCHAR2(2000);
    l_n_msg_count NUMBER;
    l_org_id     VARCHAR2(15);
    e_resource_busy      EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_resource_busy, -54);

    --Cursor For Getting The Group Code For The Group Id
    CURSOR c_get_person_grp (c_group_id igs_pe_persid_group_v.group_id%TYPE) IS
      SELECT group_cd
      FROM  igs_pe_persid_group_v
      WHERE group_id = c_group_id;
    l_c_get_person_grp c_get_person_grp%ROWTYPE;

    --Cursor For Getting The Alternate Code For The Fee Period.
    CURSOR c_get_alt_code(cp_v_cal_type igs_ca_inst.cal_type%TYPE,
                          cp_n_sequence_number igs_ca_inst.sequence_number%TYPE) IS
      SELECT alternate_code
      FROM igs_ca_inst_all
      WHERE cal_type = cp_v_cal_type
      AND   sequence_number = cp_n_sequence_number;

    l_c_alt_code_desc c_get_alt_code%ROWTYPE;

    CURSOR cur_get_currency_cd
    IS
    SELECT currency_cd
    FROM IGS_FI_CONTROL;
    l_currency_cd IGS_FI_CONTROL.currency_cd%TYPE;

    CURSOR cur_get_stdnt_wvr_assgn(cp_v_fee_cal_type   IGS_FI_WAIVER_PGMS.FEE_CAL_TYPE%TYPE,
                                   cp_n_fee_ci_seq_nbr IGS_FI_WAIVER_PGMS.FEE_CI_SEQUENCE_NUMBER%TYPE,
                                   cp_v_waiver_name    IGS_FI_WAIVER_PGMS.WAIVER_NAME%TYPE,
                                   cp_n_person_id      hz_parties.party_id%TYPE,
                                   cp_v_fee_type       IGS_FI_WAIVER_PGMS.TARGET_FEE_TYPE%TYPE)
    IS
    SELECT FWSP.WAIVER_NAME,
           FWSP.PERSON_ID,
           FWP.TARGET_FEE_TYPE
    FROM   IGS_FI_WAV_STD_PGMS FWSP,
           IGS_FI_WAIVER_PGMS FWP
    WHERE  FWSP.FEE_CAL_TYPE = cp_v_fee_cal_type
    AND    FWSP.FEE_CI_SEQUENCE_NUMBER = cp_n_fee_ci_seq_nbr
    AND    (cp_v_waiver_name IS NULL OR FWSP.WAIVER_NAME = cp_v_waiver_name)
    AND    (FWSP.PERSON_ID = cp_n_person_id OR cp_n_person_id IS NULL)
    AND    FWSP.FEE_CAL_TYPE = FWP.FEE_CAL_TYPE
    AND    FWSP.FEE_CI_SEQUENCE_NUMBER = FWP.FEE_CI_SEQUENCE_NUMBER
    AND    FWSP.WAIVER_NAME = FWP.WAIVER_NAME
    AND    (cp_v_fee_type IS NULL OR FWP.TARGET_FEE_TYPE = cp_v_fee_type);

    l_rec_c_get_stdnt_wvr_assgn cur_get_stdnt_wvr_assgn%ROWTYPE;

    CURSOR cur_get_sys_fee_type(cp_v_target_fee_type IGS_FI_WAIVER_PGMS.TARGET_FEE_TYPE%TYPE)
    IS
    SELECT FT.S_FEE_TYPE
    FROM   IGS_FI_FEE_TYPE_ALL FT
    WHERE  FT.FEE_TYPE = cp_v_target_fee_type;

    l_cur_v_target_fee_type cur_get_sys_fee_type%ROWTYPE;
    l_b_flag BOOLEAN;

  BEGIN
    BEGIN
      l_org_id := NULL;
      igs_ge_gen_003.set_org_id(l_org_id);
    EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        retcode:=2;
        RETURN;
    END;

      SAVEPOINT sp_process_waivers;
      retcode := 0;
      errbuf  := NULL;
      l_b_flag := FALSE;

      -- Log the inbound parameters in the log file using statement level logging
      -- Invoke the local procedure to log all the Inbound Parameters in concurrent log File
      log_in_parameters(
        p_n_person_id              => p_person_id,
        p_n_person_grp_id          => p_person_grp_id,
        p_v_fee_cal                => p_fee_cal,
        p_v_waiver_name            => p_waiver_name,
        p_v_fee_type               => p_fee_type,
        p_d_gl_date                => igs_ge_date.igsdate(p_gl_date));

      --Checking System option value for Manage Accounts.
      igs_fi_com_rec_interface.chk_manage_account(p_v_manage_acc   => l_v_manage_acc,
                                                  p_v_message_name => l_v_message_name);

      IF l_v_manage_acc IS NULL OR l_v_manage_acc = 'OTHER' THEN
        fnd_file.new_line(fnd_file.log);
        fnd_message.set_name('IGS',l_v_message_name);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        retcode := 2;
        RETURN;
      END IF;

      -- To Validate The Parameters And Log The Message.
      validate_params(p_n_person_id              => p_person_id,
                      p_n_person_grp_id          => p_person_grp_id,
                      p_v_fee_cal                => p_fee_cal,
                      p_v_waiver_name            => p_waiver_name,
                      p_v_fee_type               => p_fee_type,
                      p_d_gl_date                => p_gl_date,
                      p_v_fee_cal_type           => l_v_fee_cal_type,
                      p_n_fee_ci_sequence_number => l_n_fee_ci_seq_number,
                      p_v_ld_cal_type            => l_v_load_cal_type,
                      p_n_ld_ci_sequence_number  => l_n_load_ci_seq_number,
                      p_val_status               => l_b_validate_parm_status);

      -- If any of the Parameter validations are failed, return with Error Status
      IF NOT l_b_validate_parm_status THEN
        retcode :=2;
        RETURN;
      END IF;

       --Check whether Holds Balance Conversion Process is running or not. If yes, Error out.
       igs_fi_gen_007.finp_get_conv_prc_run_ind ( p_n_conv_process_run_ind => l_conv_process_run_ind,
                                                  p_v_message_name         => l_v_message_name );

       IF ((l_conv_process_run_ind IS NOT NULL) AND (l_conv_process_run_ind = 1)) THEN
         fnd_file.new_line(fnd_file.log);
         fnd_message.set_name('IGS','IGS_FI_REASS_BAL_PRC_RUN');
         fnd_file.put_line(fnd_file.log,fnd_message.get());
         retcode := 2;
         RETURN;
       END IF;

       IF ((l_v_message_name IS NOT NULL) AND (l_conv_process_run_ind IS NULL)) THEN
         fnd_file.new_line(fnd_file.log);
         fnd_message.set_name('IGS',l_v_message_name);
         fnd_file.put_line(fnd_file.log,fnd_message.get());
         retcode := 2;
         RETURN;
       END IF;

       --Verify if active balance rule for holds balance type has been setup in the balance rules form.
       igs_fi_gen_007.finp_get_balance_rule ( p_v_balance_type => 'HOLDS',
                                              p_v_action => 'ACTIVE',
                                              p_n_balance_rule_id => l_n_balance_rule_id,
                                              p_d_last_conversion_date => l_d_last_conversion_date,
                                              p_n_version_number => l_n_version_number );

       IF l_n_version_number = 0 THEN

         --no active balance rule exists
         fnd_file.new_line(fnd_file.log);
         fnd_message.set_name('IGS','IGS_FI_CANNOT_CRT_TXN');
         fnd_file.put_line(fnd_file.log,fnd_message.get());
         retcode := 2;
         RETURN;
       END IF;

       OPEN cur_get_currency_cd;
       FETCH cur_get_currency_cd INTO l_currency_cd;
       CLOSE cur_get_currency_cd;

       --Process is run for a group of students
       IF p_person_grp_id IS NOT NULL AND p_person_id IS NULL THEN

         l_dynamic_sql := igs_pe_dynamic_persid_group.igs_get_dynamic_sql(p_person_grp_id,l_v_status );
         IF l_v_status <> 'S' THEN

           --Log the error message and stop the processing.
           fnd_message.set_name('IGF','IGF_AP_INVALID_QUERY');
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           retcode := 2;
           RETURN;
         END IF;

         OPEN c_ref_person_grp FOR l_dynamic_sql;
         -- Looping Across All The Valid Person Ids In The Group.
         LOOP
           FETCH c_ref_person_grp INTO l_n_person_id;
           EXIT WHEN c_ref_person_grp%NOTFOUND;

           --get all the student waiver assignments
           FOR l_rec_c_get_stdnt_wvr_assgn IN cur_get_stdnt_wvr_assgn(l_v_fee_cal_type,
                                                                      l_n_fee_ci_seq_number,
                                                                      p_waiver_name,
                                                                      l_n_person_id,
                                                                      p_fee_type)
           LOOP
             --Get the system fee type associated to the target fee type.
             OPEN cur_get_sys_fee_type(l_rec_c_get_stdnt_wvr_assgn.target_fee_type);
             FETCH cur_get_sys_fee_type INTO l_cur_v_target_fee_type;
             CLOSE cur_get_sys_fee_type;
             IF l_cur_v_target_fee_type.s_fee_type IN ('TUTNFEE','AUDIT','OTHER') THEN
               l_v_process_mode := 'ACTUAL';
             ELSE
               l_v_process_mode := NULL;
             END IF;
              --create waivers
              igs_fi_prc_waivers.create_waivers(p_n_person_id            => l_rec_c_get_stdnt_wvr_assgn.person_id,
                                                p_v_fee_type             => l_rec_c_get_stdnt_wvr_assgn.target_fee_type,
                                                p_v_fee_cal_type         => l_v_fee_cal_type,
                                                p_n_fee_ci_seq_number    => l_n_fee_ci_seq_number,
                                                p_v_waiver_name          => l_rec_c_get_stdnt_wvr_assgn.waiver_name,
                                                p_v_currency_cd          => l_currency_cd,
                                                p_d_gl_date              => igs_ge_date.igsdate(p_gl_date),
                                                p_b_init_msg_list        => TRUE,
                                                p_validation_level       => 0,
                                                p_v_real_time_flag       => 'N',
                                                p_v_process_mode         => l_v_process_mode,
                                                p_v_career               => NULL,
                                                p_v_raise_wf_event       => 'Y',
                                                x_waiver_amount          => l_n_waiver_amount,
                                                x_return_status          => l_v_return_status,
                                                x_msg_count              => l_n_msg_count,
                                                x_msg_data               => l_v_msg_data);
              IF l_v_return_status <> 'S' THEN
                fnd_file.new_line(fnd_file.log,2);
                --log the failure in the log file for a person in this cycle of group of persons
                log_result(p_n_person_id     => l_rec_c_get_stdnt_wvr_assgn.person_id,
                           p_v_waiver_name   => l_rec_c_get_stdnt_wvr_assgn.waiver_name,
                           p_v_fee_type      => l_rec_c_get_stdnt_wvr_assgn.target_fee_type,
                           p_n_waiver_amount => NULL,
                           p_v_status        => 'FAIL');

                IF l_n_msg_count = 1 THEN
                  fnd_message.set_encoded(l_v_msg_data);
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                ELSE
                  FOR l_count IN 1 .. l_n_msg_count LOOP
                    l_msg := fnd_msg_pub.get(p_msg_index => l_count, p_encoded => 'T');
                    fnd_message.set_encoded(l_msg);
                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                  END LOOP;
                END IF;
              ELSIF l_v_return_status = 'S' THEN
                fnd_file.new_line(fnd_file.log,2);
                --log the success in the log file for a person in this cycle of group of persons
                log_result(p_n_person_id     => l_rec_c_get_stdnt_wvr_assgn.person_id,
                           p_v_waiver_name   => l_rec_c_get_stdnt_wvr_assgn.waiver_name,
                           p_v_fee_type      => l_rec_c_get_stdnt_wvr_assgn.target_fee_type,
                           p_n_waiver_amount => l_n_waiver_amount,
                           p_v_status        => 'SUCCESS');
              END IF;

              l_b_flag := TRUE;

           END LOOP;--end loop of stdnt assignments
         END LOOP;--end loop of person grp

       END IF;

       --Process is run for a particular person or both person grp and person details are not provided.
       IF (p_person_id IS NOT NULL) OR (p_person_id IS  NULL AND p_person_grp_id IS  NULL) THEN

         --Get waiver assignemnts.
         FOR l_rec_c_get_stdnt_wvr_assgn IN cur_get_stdnt_wvr_assgn(l_v_fee_cal_type,
                                                                    l_n_fee_ci_seq_number,
                                                                    p_waiver_name,
                                                                    p_person_id,
                                                                    p_fee_type)
         LOOP
           --Check system fee type associated with target fee type
           OPEN cur_get_sys_fee_type(l_rec_c_get_stdnt_wvr_assgn.target_fee_type);
           FETCH cur_get_sys_fee_type INTO l_cur_v_target_fee_type;
           CLOSE cur_get_sys_fee_type;

           IF l_cur_v_target_fee_type.s_fee_type IN ('TUTNFEE','AUDIT','OTHER') THEN
             l_v_process_mode := 'ACTUAL';
           ELSE
             l_v_process_mode := NULL;
           END IF;
           --calling create waivers.

           igs_fi_prc_waivers.create_waivers(p_n_person_id            => l_rec_c_get_stdnt_wvr_assgn.person_id,
                                             p_v_fee_type             => l_rec_c_get_stdnt_wvr_assgn.target_fee_type,
                                             p_v_fee_cal_type         => l_v_fee_cal_type,
                                             p_n_fee_ci_seq_number    => l_n_fee_ci_seq_number,
                                             p_v_waiver_name          => l_rec_c_get_stdnt_wvr_assgn.waiver_name,
                                             p_v_currency_cd          => l_currency_cd,
                                             p_d_gl_date              => igs_ge_date.igsdate(p_gl_date),
                                             p_b_init_msg_list        => TRUE,
                                             p_validation_level       => 0,
                                             p_v_real_time_flag       => 'N',
                                             p_v_process_mode         => l_v_process_mode,
                                             p_v_career               => NULL,
                                             p_v_raise_wf_event       => 'Y',
                                             x_waiver_amount          => l_n_waiver_amount,
                                             x_return_status          => l_v_return_status,
                                             x_msg_count              => l_n_msg_count,
                                             x_msg_data               => l_v_msg_data);

             IF l_v_return_status <> 'S' THEN
                 fnd_file.new_line(fnd_file.log,2);
                 --log the failure in the log file.
                 log_result(p_n_person_id     => l_rec_c_get_stdnt_wvr_assgn.person_id,
                            p_v_waiver_name   => l_rec_c_get_stdnt_wvr_assgn.waiver_name,
                            p_v_fee_type      => l_rec_c_get_stdnt_wvr_assgn.target_fee_type,
                            p_n_waiver_amount => NULL,
                            p_v_status        => 'FAIL');

               IF l_n_msg_count = 1 THEN
                 fnd_message.set_encoded(l_v_msg_data);
                 fnd_file.put_line(fnd_file.log,fnd_message.get);
               ELSE
                FOR l_count IN 1 .. l_n_msg_count LOOP
                  l_msg := fnd_msg_pub.get(p_msg_index => l_count, p_encoded => 'T');
                  fnd_message.set_encoded(l_msg);
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                 END LOOP;
               END IF;
             ELSIF l_v_return_status = 'S' THEN
               fnd_file.new_line(fnd_file.log,2);
               --log the success in the log file
               log_result(p_n_person_id     => l_rec_c_get_stdnt_wvr_assgn.person_id,
                          p_v_waiver_name   => l_rec_c_get_stdnt_wvr_assgn.waiver_name,
                          p_v_fee_type      => l_rec_c_get_stdnt_wvr_assgn.target_fee_type,
                          p_n_waiver_amount => l_n_waiver_amount,
                          p_v_status        => 'SUCCESS');
             END IF;

             l_b_flag := TRUE;

         END LOOP;
       END IF;

     IF NOT l_b_flag THEN
       fnd_file.new_line(fnd_file.log);
       fnd_message.set_name('IGS','IGS_GE_NO_DATA_FOUND');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_process_waivers;
        retcode := 2;
        errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' || SQLERRM;
        igs_ge_msg_stack.conc_exception_hndl;

  END process_waivers;
END igs_fi_prc_waivers;

/
