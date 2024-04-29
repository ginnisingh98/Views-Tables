--------------------------------------------------------
--  DDL for Package Body IGS_FI_WAV_UTILS_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_WAV_UTILS_001" AS
/* $Header: IGSFI95B.pls 120.2 2005/11/07 16:08:58 appldev noship $ */

  /******************************************************************
   Created By      :   Anji Yedubati
   Date Created By :   05-JUL-2005
   Purpose         :   Waiver Utility Package for the generic routines,
                       get_eligible_waiver_amt and apply_waivers, which are
                       required for waiver processing
                       Created as part of FI234 - Tuition Waivers enh. Bug # 3392095

   Known limitations,enhancements,remarks:

   Change History  :
   WHO         WHEN          WHAT
   pathipat    16-Aug-2005   Enh 3392095 - Tuition Waivers Enh
                             Added procedure create_ss_waiver_transactions
  ***************************************************************** */

  --
  -- Global Variables Declaration
  --
  g_v_app   VARCHAR2(3) := 'APP';
  g_v_unapp VARCHAR2(5) := 'UNAPP';

  --
  -- Private Procedures Declaration
  --

  -- Procedure for logging messages at the Statement Level
  PROCEDURE log_to_fnd (p_v_module IN VARCHAR2,
                        p_v_string IN VARCHAR2);

  -- Procedure to validate the parameters passed to get Eligible Waiver Amount
  PROCEDURE validate_elg_wavamt_params(
    p_n_person_id          IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type       IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number  IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name        IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_target_fee_type    IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_v_waiver_method_code IN  igs_fi_waiver_pgms.waiver_method_code%TYPE,
    p_v_waiver_mode_code   IN  igs_fi_waiver_pgms.waiver_mode_code%TYPE,
    p_n_source_invoice_id  IN  igs_fi_inv_int_all.invoice_id%TYPE,
    x_return_status        OUT NOCOPY VARCHAR2);

  -- Procedure to validate the parameters passed to Apply Waivers procedure
  PROCEDURE validate_applywav_params(
    p_n_person_id          IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type       IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number  IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name        IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_target_fee_type    IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_v_adj_fee_type       IN  igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_v_waiver_method_code IN  igs_fi_waiver_pgms.waiver_method_code%TYPE,
    p_v_waiver_mode_code   IN  igs_fi_waiver_pgms.waiver_mode_code%TYPE,
    p_n_source_credit_id   IN  igs_fi_credits_all.credit_id%TYPE,
    p_n_source_invoice_id  IN  igs_fi_inv_int_all.invoice_id%TYPE,
    p_v_currency_cd        IN  igs_fi_inv_int_all.currency_cd%TYPE,
    p_d_gl_date            IN  igs_fi_invln_int.gl_date%TYPE,
    x_return_status        OUT NOCOPY VARCHAR2);

  -- Procedure to Apply the Waiver Credit against the Waiver Adjustment Charges
  PROCEDURE process_wavadj_charges(
    p_n_person_id         IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type      IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_adj_fee_type      IN  igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_v_waiver_name       IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_n_credit_id         IN  igs_fi_credits_all.credit_id%TYPE,
    p_d_gl_date           IN  igs_fi_invln_int.gl_date%TYPE,
    p_n_credit_amount     IN  OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2);

  -- Procedure to Apply the balance Waiver Credit against the charges in the
  -- student account except the Rentension Charges
  PROCEDURE process_stdnt_charges(
    p_n_invoice_id        IN  igs_fi_inv_int_all.invoice_id%TYPE,
    p_n_person_id         IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type      IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_target_fee_type   IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_n_credit_id         IN  igs_fi_credits_all.credit_id%TYPE,
    p_d_gl_date           IN  igs_fi_invln_int.gl_date%TYPE,
    p_n_credit_amount     IN OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2);

  -- Procedure to Un apply existing applications for credits other than
  -- Negative Charge Adjustmnet, Waiver, Enrollment Deposit and Other Depost types
  -- and apply the unapplied charges against the balance Waiver Credit
  PROCEDURE adjust_stdnt_charges(
    p_n_invoice_id        IN  igs_fi_inv_int_all.invoice_id%TYPE,
    p_n_credit_id         IN  igs_fi_credits_all.credit_id%TYPE,
    p_d_gl_date           IN  igs_fi_invln_int.gl_date%TYPE,
    p_n_credit_amount     IN OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2);

  -- Procedure to create the Waiver Adjustment Charge and
  -- apply the charge against the waiver credit
  PROCEDURE create_wavadj_charge(
    p_n_person_id         IN igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type      IN igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number IN igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name       IN igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_adj_fee_type      IN igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_n_credit_id         IN igs_fi_credits_all.credit_id%TYPE,
    p_v_currency_cd       IN igs_fi_inv_int_all.currency_cd%TYPE,
    p_n_waiver_amt        IN igs_fi_inv_int_all.invoice_amount%TYPE,
    p_d_gl_date           IN igs_fi_invln_int.gl_date%TYPE,
    x_return_status       OUT NOCOPY VARCHAR2);

  -- Procedure to apply the Waiver Adjustment Charges for a Waiver Credit,
  -- which has some positive amount due exists
  PROCEDURE process_due_wavadj_charges(
    p_n_source_credit_id  IN igs_fi_credits_all.credit_id%TYPE,
    p_n_person_id         IN igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type      IN igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number IN igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name       IN igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_adj_fee_type      IN igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_d_gl_date           IN igs_fi_invln_int.gl_date%TYPE,
    x_return_status       OUT NOCOPY VARCHAR2);

  --
  -- Public Procedures
  --

  PROCEDURE get_eligible_waiver_amt(
    p_n_person_id          IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type       IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number  IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name        IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_target_fee_type    IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_v_waiver_method_code IN  igs_fi_waiver_pgms.waiver_method_code%TYPE,
    p_v_waiver_mode_code   IN  igs_fi_waiver_pgms.waiver_mode_code%TYPE,
    p_n_source_invoice_id  IN  igs_fi_inv_int_all.invoice_id%TYPE,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_eligible_amount      OUT NOCOPY NUMBER ) AS
  /******************************************************************
   Created By      :   Anji Yedubati
   Date Created By :   11-JUL-2005
   Purpose         :   To calculate the Eligible amount that can be actually waived for the
                       Student, Fee Calendar, Waiver Program and Target Fee Type combination.
                       Created as part of Tuition Waivers Enhancment Bug # 3392095

   Known limitations,enhancements,remarks:

   Change History  :
   WHO        WHEN         WHAT
   AYEDUBAT   22-AUG-05    Fixed the review comments on the new object
  ***************************************************************** */

    -- Fecth the Charges in the Student account except Rentension Charges
    -- for a combination of Person, Fee Type, Fee Period or based on Invoice ID
    CURSOR stdnt_charges_cur (
      cp_n_person_id       igs_fi_inv_int_all.person_id%TYPE,
      cp_v_target_fee_type igs_fi_inv_int_all.fee_type%TYPE,
      cp_v_fee_cal_type    igs_fi_inv_int_all.fee_cal_type%TYPE,
      cp_n_fee_ci_seq_num  igs_fi_inv_int_all.fee_ci_sequence_number%TYPE,
      cp_n_invoice_id      igs_fi_inv_int_all.invoice_id%TYPE) IS
    SELECT inv.invoice_id, inv.invoice_amount
    FROM  igs_fi_inv_int_all inv
    WHERE inv.person_id = cp_n_person_id
      AND inv.fee_type  = cp_v_target_fee_type
      AND inv.fee_cal_type = cp_v_fee_cal_type
      AND inv.fee_ci_sequence_number = cp_n_fee_ci_seq_num
      AND inv.transaction_type  <> 'RETENTION'
      AND (cp_n_invoice_id IS NULL OR inv.invoice_id = cp_n_invoice_id)
    ORDER BY inv.invoice_id;

    -- Fecth the Negative Charge Adjustment application details for a Charge
    CURSOR chgadj_amt_cur (cp_n_invoice_id igs_fi_applications.invoice_id%TYPE) IS
    SELECT appl.amount_applied
    FROM  igs_fi_applications appl,
          igs_fi_credits_all crd,
          igs_fi_cr_types_all cr
    WHERE appl.invoice_id = cp_n_invoice_id
      AND appl.credit_id  = crd.credit_id
      AND appl.application_type = 'APP'
      AND crd.credit_type_id = cr.credit_type_id
      AND cr.credit_class = 'CHGADJ';

    -- Fecth the Waiver Credit Application records applied to the charges having same target fee type
    -- and fee calendar and other than the waiver program passed as in parameter to the procedure
    CURSOR wav_applications_cur(
      cp_n_person_id       igs_fi_inv_int_all.person_id%TYPE,
      cp_v_target_fee_type igs_fi_inv_int_all.fee_type%TYPE,
      cp_v_fee_cal_type    igs_fi_credits_all.fee_cal_type%TYPE,
      cp_n_fee_ci_seq_num  igs_fi_credits_all.fee_ci_sequence_number%TYPE,
      cp_n_invoice_id      igs_fi_applications.invoice_id%TYPE,
      cp_v_waiver_name     igs_fi_credits_all.waiver_name%TYPE) IS
    SELECT
      appl.amount_applied,
      appl.application_id,
      appl.credit_id,
      appl.invoice_id
    FROM igs_fi_inv_int_all inv,
         igs_fi_applications appl,
         igs_fi_credits_all crd,
         igs_fi_cr_types cr
    WHERE inv.person_id    = cp_n_person_id
      AND inv.fee_type     = cp_v_target_fee_type
      AND inv.fee_cal_type = cp_v_fee_cal_type
      AND inv.fee_ci_sequence_number = cp_n_fee_ci_seq_num
      AND (cp_n_invoice_id IS NULL OR inv.invoice_id = cp_n_invoice_id)
      AND appl.invoice_id  = inv.invoice_id
      AND appl.credit_id   = crd.credit_id
      AND appl.application_type = 'APP'
      AND crd.fee_cal_type = cp_v_fee_cal_type
      AND crd.fee_ci_sequence_number = cp_n_fee_ci_seq_num
      AND (cp_v_waiver_name IS NULL OR crd.waiver_name <> cp_v_waiver_name)
      AND crd.status = 'CLEARED'
      AND crd.credit_type_id = cr.credit_type_id
      AND cr.credit_class = 'WAIVER'
    ORDER BY appl.application_id;

    -- Fetch Application records for a given waiver credit
    -- against which waiver adjustment charge applied
    CURSOR wavadj_app_cur(cp_n_credit_id      igs_fi_applications.credit_id%TYPE,
                          cp_v_fee_cal_type   igs_fi_inv_int_all.fee_cal_type%TYPE,
                          cp_n_fee_ci_seq_num igs_fi_inv_int_all.fee_ci_sequence_number%TYPE,
                          cp_n_invoice_id     igs_fi_inv_int_all.invoice_id%TYPE) IS
    SELECT appl.amount_applied
    FROM igs_fi_applications appl,
         igs_fi_inv_int_all inv
    WHERE appl.credit_id = cp_n_credit_id
      AND appl.invoice_id = inv.invoice_id
      AND appl.application_type = 'APP'
      AND inv.fee_cal_type = cp_v_fee_cal_type
      AND inv.fee_ci_sequence_number = cp_n_fee_ci_seq_num
      AND inv.transaction_type = 'WAIVER_ADJ'
      AND EXISTS( SELECT '1'
                  FROM igs_fi_credits_all crd,
                       igs_fi_applications unappl
                  WHERE crd.credit_id = appl.credit_id
                    AND unappl.credit_id = crd.credit_id
                    AND unappl.invoice_id = cp_n_invoice_id
                    AND unappl.application_type = 'UNAPP'
                    AND unappl.amount_applied = - appl.amount_applied );

    l_n_chgadj_amt IGS_FI_APPLICATIONS.amount_applied%TYPE;
    l_n_wavadj_amt IGS_FI_APPLICATIONS.amount_applied%TYPE;
    l_n_net_chg_amount IGS_FI_APPLICATIONS.amount_applied%TYPE;
    l_n_net_waiver_amt IGS_FI_APPLICATIONS.amount_applied%TYPE;

  BEGIN

    -- Invoke the procedure to validate the Inbound Parameters
    validate_elg_wavamt_params(
      p_n_person_id,
      p_v_fee_cal_type,
      p_n_fee_ci_seq_number,
      p_v_waiver_name,
      p_v_target_fee_type,
      p_v_waiver_method_code,
      p_v_waiver_mode_code,
      p_n_source_invoice_id,
      x_return_status);

    -- If the Parameter validation is failed then return the calling procedure with error status
    IF x_return_status = 'E' THEN
      log_to_fnd('get_eligible_waiver_amt','validate_elg_wavamt_params procedure is Failed');
      x_eligible_amount := NULL;
      RETURN;
    END IF;

    log_to_fnd('get_eligible_waiver_amt','validate_elg_wavamt_params procedure is Successfull');

    -- Fetch all the Student Charges except Retention Charges and calculate the Net Charge Amount.
    -- Net Charge Amount = Invoice Amount - Negative Charge Adjustment Amount
    l_n_net_chg_amount := 0;
    FOR stdnt_charges_rec IN stdnt_charges_cur (p_n_person_id,p_v_target_fee_type,p_v_fee_cal_type,
                             p_n_fee_ci_seq_number, p_n_source_invoice_id) LOOP

      log_to_fnd('get_eligible_waiver_amt','Processing the Invoice ID: '||stdnt_charges_rec.invoice_id);

      -- Loop through the negative charge adjustment application records for the context
      -- Charge transaction and cumulate the Amount Applied
      l_n_chgadj_amt := 0;
      FOR chgadj_amt_rec IN chgadj_amt_cur (stdnt_charges_rec.invoice_id) LOOP
        l_n_chgadj_amt := l_n_chgadj_amt + chgadj_amt_rec.amount_applied;
      END LOOP;

      log_to_fnd('get_eligible_waiver_amt','Negative Charge Adjustment amount for the Invoice = '||l_n_chgadj_amt);

      -- Calculate the difference between the Invoice Amount and
      -- negative charge adjustment amount applied for the context Charge record
      l_n_net_chg_amount := l_n_net_chg_amount + (stdnt_charges_rec.invoice_amount - l_n_chgadj_amt);

    END LOOP;

    log_to_fnd('get_eligible_waiver_amt','Net Charge Amount = '||l_n_net_chg_amount);

    -- Loop through the Waiver Credit Application records other than the Waiver Program
    -- passed as inbound parameter against which Waiver Adjustment charge is applied
    -- Net Waiver Amount = Waiver Amount applied - Waiver Adjustment Amount applied
    l_n_net_waiver_amt := 0;
    FOR wav_applications_rec IN wav_applications_cur (p_n_person_id,p_v_target_fee_type,p_v_fee_cal_type,
                                        p_n_fee_ci_seq_number,p_n_source_invoice_id,p_v_waiver_name) LOOP

      log_to_fnd('get_eligible_waiver_amt','Processing the Waiver Application ID: '||wav_applications_rec.application_id);

      -- Loop through the Waiver Adjustment Charges for the Context Waiver Application
      -- and cumulate the Amount Applied
      l_n_wavadj_amt := 0;
      FOR wavadj_app_rec IN wavadj_app_cur (wav_applications_rec.credit_id, p_v_fee_cal_type,
                                            p_n_fee_ci_seq_number, wav_applications_rec.invoice_id) LOOP
        l_n_wavadj_amt := l_n_wavadj_amt + wavadj_app_rec.amount_applied;
      END LOOP;

      log_to_fnd('get_eligible_waiver_amt','Waiver Adjustment Charge amount for the Application = '||l_n_wavadj_amt);

      -- Calculate the difference between waiver amount applied and
      -- Waiver Adjustment amount applied for the context Waiver Application
      l_n_net_waiver_amt := l_n_net_waiver_amt + (wav_applications_rec.amount_applied - l_n_wavadj_amt);

    END LOOP;

    log_to_fnd('get_eligible_waiver_amt','Net Waiver Amount = '||l_n_net_waiver_amt);

    -- Calculate the Eligible Waiver Amount as the difference between
    -- net Charge Amount (l_n_net_chg_amount) and net Waiver Amount(l_n_net_waiver_amt)
    x_eligible_amount := l_n_net_chg_amount - l_n_net_waiver_amt;

    -- Return the Success Status
    x_return_status := 'S';

    log_to_fnd('get_eligible_waiver_amt','Eligible Waiver Amount = '||x_eligible_amount);

  EXCEPTION
    WHEN OTHERS THEN

      -- Set the values to the OUT variables
      x_eligible_amount := NULL;
      x_return_status := 'E';

      -- Log the SQLERRM message
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igs_fi_wav_utils_001.get_eligible_waiver_amt.exception','sqlerrm ' || SQLERRM);
      END IF;

  END get_eligible_waiver_amt;


  PROCEDURE apply_waivers(
    p_n_person_id          IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type       IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number  IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name        IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_target_fee_type    IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_v_adj_fee_type       IN  igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_v_waiver_method_code IN  igs_fi_waiver_pgms.waiver_method_code%TYPE,
    p_v_waiver_mode_code   IN  igs_fi_waiver_pgms.waiver_mode_code%TYPE,
    p_n_source_credit_id   IN  igs_fi_credits_all.credit_id%TYPE,
    p_n_source_invoice_id  IN  igs_fi_inv_int_all.invoice_id%TYPE,
    p_v_currency_cd        IN  igs_fi_inv_int_all.currency_cd%TYPE,
    p_d_gl_date            IN  igs_fi_invln_int.gl_date%TYPE,
    x_return_status        OUT NOCOPY VARCHAR2 ) AS
  /******************************************************************
   Created By      : Anji Yedubati
   Date Created By : 11-JUL-2005
   Purpose         : Procedure to apply the Waiver Credit against the Student Charges
                     Created as part of Tuition Waivers Enhancment Bug # 3392095

   Known limitations,enhancements,remarks:

   Change History  :
   WHO     WHEN       WHAT
  ***************************************************************** */

    -- Declare used defined exception to raise when apply waiver credit fails
    apply_wav_fail EXCEPTION;

    -- Fetch the credit details for a Credit Id
    CURSOR chglvl_waiver_crdits_cur(cp_credit_id igs_fi_credits_all.credit_id%TYPE) IS
    SELECT crd.credit_id,
           crd.unapplied_amount
    FROM igs_fi_credits_all crd
    WHERE crd.credit_id = cp_credit_id
      AND NVL(crd.unapplied_amount, 0) > 0;

    -- Fetch waiver credit records for a combination of Person, Fee Period and Waiver Name
    CURSOR feelvl_waiver_crdits_cur(
      cp_credit_id        igs_fi_credits_all.credit_id%TYPE,
      cp_n_person_id      igs_fi_credits_all.party_id%TYPE,
      cp_v_fee_cal_type   igs_fi_credits_all.fee_cal_type%TYPE,
      cp_n_fee_ci_seq_num igs_fi_credits_all.fee_ci_sequence_number%TYPE,
      cp_v_waiver_name    igs_fi_credits_all.waiver_name%TYPE) IS
    SELECT crd.credit_id,
           crd.unapplied_amount
    FROM igs_fi_credits_all crd
    WHERE (cp_credit_id IS NULL OR crd.credit_id = cp_credit_id)
      AND crd.party_id     = cp_n_person_id
      AND crd.fee_cal_type = cp_v_fee_cal_type
      AND crd.fee_ci_sequence_number = cp_n_fee_ci_seq_num
      AND crd.waiver_name  = cp_v_waiver_name
      AND NVL(crd.unapplied_amount, 0) > 0 ;

    -- Fetch the change records other than Re
    -- for a combination of Person, Fee Type and Fee Period
    CURSOR stnt_charges_cur(
      cp_n_person_id      igs_fi_inv_int_all.person_id%TYPE,
      cp_v_target_fee_type igs_fi_inv_int_all.fee_type%TYPE,
      cp_v_fee_cal_type   igs_fi_credits_all.fee_cal_type%TYPE,
      cp_n_fee_ci_seq_num igs_fi_credits_all.fee_ci_sequence_number%TYPE) IS
    SELECT inv.invoice_id,
           inv.invoice_amount_due
    FROM igs_fi_inv_int_all inv,
         igs_fi_invln_int_all invln
    WHERE inv.person_id    = cp_n_person_id
      AND inv.fee_type     = cp_v_target_fee_type
      AND inv.fee_cal_type = cp_v_fee_cal_type
      AND inv.fee_ci_sequence_number = cp_n_fee_ci_seq_num
      AND inv.transaction_type NOT IN ('RETENTION','WAIVER_ADJ')
      AND invln.invoice_id = inv.invoice_id
      AND NVL(invln.error_account,'N') = 'N'
    ORDER BY inv.invoice_id;

    l_v_return_status VARCHAR2(1);
    l_n_credit_amount IGS_FI_CREDITS_ALL.unapplied_amount%TYPE;

  BEGIN

    -- Create the Save Point
    SAVEPOINT apply_waivers_sp;

    -- Log the inbound parameters in the log file using statement level logging
    log_to_fnd('apply_waivers','Inbound Parameters to the procedure');
    log_to_fnd('apply_waivers','p_n_person_id='||p_n_person_id);
    log_to_fnd('apply_waivers','p_v_fee_cal_type='||p_v_fee_cal_type);
    log_to_fnd('apply_waivers','p_n_fee_ci_seq_number='||p_n_fee_ci_seq_number);
    log_to_fnd('apply_waivers','p_v_waiver_name='||p_v_waiver_name);
    log_to_fnd('apply_waivers','p_v_target_fee_type='||p_v_target_fee_type);
    log_to_fnd('apply_waivers','p_v_adj_fee_type='||p_v_adj_fee_type);
    log_to_fnd('apply_waivers','p_v_waiver_method_code='||p_v_waiver_method_code);
    log_to_fnd('apply_waivers','p_v_waiver_mode_code='||p_v_waiver_mode_code);
    log_to_fnd('apply_waivers','p_n_source_credit_id='||p_n_source_credit_id);
    log_to_fnd('apply_waivers','p_n_source_invoice_id='||p_n_source_invoice_id);

    -- Initialize the Local Variables
    x_return_status := 'S';
    l_n_credit_amount := 0;

    --
    -- Validate the Inbound Parameters
    --
    validate_applywav_params(
      p_n_person_id,
      p_v_fee_cal_type,
      p_n_fee_ci_seq_number,
      p_v_waiver_name,
      p_v_target_fee_type,
      p_v_adj_fee_type,
      p_v_waiver_method_code,
      p_v_waiver_mode_code,
      p_n_source_credit_id,
      p_n_source_invoice_id,
      p_v_currency_cd,
      p_d_gl_date,
      x_return_status);

    -- If the Parameter validations are failed, then Retunr to calling procedure with Error Status
    IF x_return_status = 'E' THEN
      log_to_fnd('apply_waivers','validate_applywav_params procedure is Failed' );
      RETURN;
    END IF;
    log_to_fnd('apply_waivers','validate_applywav_params procedure is Successfull' );

    --
    -- Apply Waivers processing is based on the Mode of Waiver
    -- If Mode of Waiver is Charge Level, apply the Source Waiver Credit against Source Charge
    -- If Mode of Waiver is Charge Level, apply all the Student Waiver Credits
    --
    -- Mode of Waiver is Charge Level
    --
    IF (p_v_waiver_mode_code = 'CHARGE_LEVEL') THEN

      log_to_fnd('apply_waivers','Charge Level Processing');

      -- Fetch the details of the Waiver Credit record, p_n_source_credit_id
      FOR chglvl_waiver_crdits_rec IN chglvl_waiver_crdits_cur(p_n_source_credit_id) LOOP

        -- Initlaize the Waiver Credit Amount local variable with the Unapplied Amount
        l_n_credit_amount := chglvl_waiver_crdits_rec.unapplied_amount;
        l_v_return_status := NULL;

        log_to_fnd('apply_waivers','Processing Credit ID: '||chglvl_waiver_crdits_rec.credit_id||'  Credit Amount='||l_n_credit_amount);

        -- Invoke the local procedure to apply the source Waiver Credit
        -- againt Waiver Adjustment Charge records
        process_wavadj_charges(
          p_n_person_id         => p_n_person_id,
          p_v_fee_cal_type      => p_v_fee_cal_type,
          p_n_fee_ci_seq_number => p_n_fee_ci_seq_number,
          p_v_adj_fee_type      => p_v_adj_fee_type,
          p_v_waiver_name       => p_v_waiver_name,
          p_n_credit_id         => chglvl_waiver_crdits_rec.credit_id,
          p_d_gl_date           => p_d_gl_date,
          p_n_credit_amount     => l_n_credit_amount,
          x_return_status       => l_v_return_status );

        -- If the procedure is returned with Error status then exit the processing
        --  with Error Status, otherwise continue with the processing
        IF l_v_return_status = 'E' THEN
          log_to_fnd('apply_waivers','Procedure, process_wavadj_charges is failed');
          RAISE apply_wav_fail;
        END IF;
        log_to_fnd('apply_waivers','Procedure, process_wavadj_charges completed successfully. Balance Credit Amount='||l_n_credit_amount);

        -- If the balance Waiver Credit Amount is greater then 0
        IF l_n_credit_amount > 0 THEN

          -- Invoke the local procedure to apply the source Waiver Credit againt the source charge
          process_stdnt_charges(
            p_n_invoice_id        => p_n_source_invoice_id,
            p_n_person_id         => p_n_person_id,
            p_v_fee_cal_type      => p_v_fee_cal_type,
            p_n_fee_ci_seq_number => p_n_fee_ci_seq_number,
            p_v_target_fee_type   => p_v_target_fee_type,
            p_n_credit_id         => chglvl_waiver_crdits_rec.credit_id,
            p_d_gl_date           => p_d_gl_date,
            p_n_credit_amount     => l_n_credit_amount,
            x_return_status       => l_v_return_status );

          -- If the procedure is returned with Error status then exit the processing
          --  with Error Status, otherwise continue with the processing
          IF l_v_return_status = 'E' THEN
            log_to_fnd('apply_waivers','Procedure, process_stdnt_charges is failed');
            RAISE apply_wav_fail;
          END IF;
          log_to_fnd('apply_waivers','Procedure, process_stdnt_charges is completed successfully. Balance Credit Amount='||l_n_credit_amount);

        END IF;

        -- If the balance Waiver Credit Amount is greater then 0
        IF l_n_credit_amount > 0 THEN

          -- Invoke the local procedure to un apply the application of source charge, if any
          -- and then apply the same charge againt the source Waiver Credit
          adjust_stdnt_charges(
            p_n_invoice_id        => p_n_source_invoice_id,
            p_n_credit_id         => chglvl_waiver_crdits_rec.credit_id,
            p_d_gl_date           => p_d_gl_date,
            p_n_credit_amount     => l_n_credit_amount,
            x_return_status       => l_v_return_status );

          -- If the procedure is returned with Error status then exit the processing
          --  with Error Status, otherwise continue with the processing
          IF l_v_return_status = 'E' THEN
            log_to_fnd('apply_waivers','Procedure, adjust_stdnt_charges is failed');
            RAISE apply_wav_fail;
          END IF;
          log_to_fnd('apply_waivers','Procedure, adjust_stdnt_charges completed successfully. Balance Credit Amount='||l_n_credit_amount);

        END IF;

        -- If the balance Waiver Credit Amount is greater then 0
        IF l_n_credit_amount > 0 THEN

          -- Invoke the local procedure to create Waiver Adjustment Charge for the
          -- balance credit amount and apply the against the source Waiver Credit
          create_wavadj_charge(
            p_n_person_id         => p_n_person_id,
            p_v_fee_cal_type      => p_v_fee_cal_type,
            p_n_fee_ci_seq_number => p_n_fee_ci_seq_number,
            p_v_waiver_name       => p_v_waiver_name,
            p_n_credit_id         => chglvl_waiver_crdits_rec.credit_id,
            p_v_adj_fee_type      => p_v_adj_fee_type,
            p_v_currency_cd       => p_v_currency_cd,
            p_n_waiver_amt        => l_n_credit_amount,
            p_d_gl_date           => p_d_gl_date,
            x_return_status       => l_v_return_status );

          -- If the procedure is returned with Error status then exit the processing
          --  with Error Status, otherwise continue with the processing
          IF l_v_return_status = 'E' THEN
            log_to_fnd('apply_waivers','Procedure, create_wavadj_charge is failed');
            RAISE apply_wav_fail;
          END IF;
          log_to_fnd('apply_waivers','Procedure, create_wavadj_charge is successfull');
          l_n_credit_amount := 0;

        END IF;

      END LOOP; -- End of Processing the Waiver Credit Record

    --
    -- Mode of Waiver is Fee Level
    --
    ELSIF (p_v_waiver_mode_code = 'FEE_LEVEL' OR p_v_waiver_method_code = 'COMP_RULE') THEN

      -- Log the message to indicate Fee Level processing or Computation Rule based processing
      IF p_v_waiver_mode_code = 'FEE_LEVEL' THEN
        log_to_fnd('apply_waivers','Fee Level Processing');
      ELSE
        log_to_fnd('apply_waivers','Computation Rule based Processing');
      END IF;

      -- Fetch the Waiver Credit details either for the Inbound Waiver Credit record, p_n_source_credit_id or
      -- for a combination of Person, Fee Period and Waiver Name
      FOR feelvl_waiver_crdits_rec IN feelvl_waiver_crdits_cur(p_n_source_credit_id,p_n_person_id,
                                       p_v_fee_cal_type,p_n_fee_ci_seq_number, p_v_waiver_name ) LOOP

        -- Initlaize the Waiver Credit Amount local variable with the Unapplied Amount
        l_n_credit_amount := feelvl_waiver_crdits_rec.unapplied_amount;
        l_v_return_status := NULL;

        log_to_fnd('apply_waivers','Processing Credit ID: '||feelvl_waiver_crdits_rec.credit_id||'  Credit Amount='||l_n_credit_amount);

        -- Invoke the local procedure to apply the context Waiver Credit
        -- againt Waiver Adjustment Charge records
        process_wavadj_charges(
          p_n_person_id         => p_n_person_id,
          p_v_fee_cal_type      => p_v_fee_cal_type,
          p_n_fee_ci_seq_number => p_n_fee_ci_seq_number,
          p_v_adj_fee_type      => p_v_adj_fee_type,
          p_v_waiver_name       => p_v_waiver_name,
          p_n_credit_id         => feelvl_waiver_crdits_rec.credit_id,
          p_d_gl_date           => p_d_gl_date,
          p_n_credit_amount     => l_n_credit_amount,
          x_return_status       => l_v_return_status);

        -- If the procedure is returned with Error status then exit the processing
        --  with Error Status, otherwise continue with the processing
        IF l_v_return_status = 'E' THEN
          log_to_fnd('apply_waivers','Procedure, process_wavadj_charges is failed');
          RAISE apply_wav_fail;
        END IF;
        log_to_fnd('apply_waivers','Procedure, process_wavadj_charges is completed successfully. Balance Credit Amount='||l_n_credit_amount);

        -- If the balance Waiver Credit Amount is greater then 0
        IF l_n_credit_amount > 0 THEN

          -- Invoke the local procedure to apply the context Waiver Credit
          -- againt Student Charges except the Retension Charges
          process_stdnt_charges(
            p_n_invoice_id        => NULL,
            p_n_person_id         => p_n_person_id,
            p_v_fee_cal_type      => p_v_fee_cal_type,
            p_n_fee_ci_seq_number => p_n_fee_ci_seq_number,
            p_v_target_fee_type   => p_v_target_fee_type,
            p_n_credit_id         => feelvl_waiver_crdits_rec.credit_id,
            p_d_gl_date           => p_d_gl_date,
            p_n_credit_amount     => l_n_credit_amount,
            x_return_status       => l_v_return_status );

          -- If the procedure is returned with Error status then exit the processing
          --  with Error Status, otherwise continue with the processing
          IF l_v_return_status = 'E' THEN
            log_to_fnd('apply_waivers','Procedure, process_stdnt_charges is failed');
            RAISE apply_wav_fail;
          END IF;
          log_to_fnd('apply_waivers','Procedure, process_stdnt_charges is completed successfully. Balance Credit Amount='||l_n_credit_amount);

        END IF;

        -- If the balance Waiver Credit Amount is greater then 0
        IF l_n_credit_amount > 0 THEN

          FOR stnt_charges_rec IN stnt_charges_cur(p_n_person_id, p_v_target_fee_type,
                                                   p_v_fee_cal_type, p_n_fee_ci_seq_number) LOOP

            log_to_fnd('apply_waivers','Processing the Invoice ID:'||stnt_charges_rec.invoice_id);

            -- Invoke the local procedure to un apply the applications aginst which the conext charge is already applied
            -- and then apply the same charge againt the source Waiver Credit
            adjust_stdnt_charges(
              p_n_invoice_id        => stnt_charges_rec.invoice_id,
              p_n_credit_id         => feelvl_waiver_crdits_rec.credit_id,
              p_d_gl_date           => p_d_gl_date,
              p_n_credit_amount     => l_n_credit_amount,
              x_return_status       => l_v_return_status );

            -- If the procedure is returned with Error status then exit the processing
            --  with Error Status, otherwise continue with the processing
            IF l_v_return_status = 'E' THEN
              log_to_fnd('apply_waivers','Procedure adjust_stdnt_charges is failed');
              RAISE apply_wav_fail;
            END IF;

            log_to_fnd('apply_waivers','Procedure adjust_stdnt_charges is completed successfully. Balance Credit Amount='||l_n_credit_amount);
            -- If the credit amount is less than or equal to 0 then exit the loop
            IF l_n_credit_amount <= 0 THEN
              EXIT;
            END IF;

          END LOOP;

        END IF;

        -- If the balance Waiver Credit Amount is greater then 0
        IF l_n_credit_amount > 0 THEN

          -- Invoke the local procedure to create Waiver Adjustment Charge for the
          -- balance credit amount and apply the against the context Waiver Credit
          create_wavadj_charge(
            p_n_person_id         => p_n_person_id,
            p_v_fee_cal_type      => p_v_fee_cal_type,
            p_n_fee_ci_seq_number => p_n_fee_ci_seq_number,
            p_v_waiver_name       => p_v_waiver_name,
            p_n_credit_id         => feelvl_waiver_crdits_rec.credit_id,
            p_v_adj_fee_type      => p_v_adj_fee_type,
            p_v_currency_cd       => p_v_currency_cd,
            p_n_waiver_amt        => l_n_credit_amount,
            p_d_gl_date           => p_d_gl_date,
            x_return_status       => l_v_return_status );

          -- If the procedure is returned with Error status then exit the processing
          --  with Error Status, otherwise continue with the processing
          IF l_v_return_status = 'E' THEN
            log_to_fnd('apply_waivers','Procedure create_wavadj_charge is failed');
            RAISE apply_wav_fail;
          END IF;
          log_to_fnd('apply_waivers','Procedure create_wavadj_charge is completed successfully');
          l_n_credit_amount := 0;

        END IF;

      END LOOP;  -- End of Processing the current Waiver Credit Record

    END IF; -- End of Fee Level or Computation Rule processing

    log_to_fnd('apply_waivers','Calling the local Procedure process_due_wavadj_charges');
    -- Invoke the local procedure to apply Waiver Adjustment Charges, if any Waiver Credits
    -- with un applied amount. If still Waiver Adjustment Charge to apply is pending then
    -- un apply the waiver credits which are applied against charges other than Waiver and
    -- apply against the Waiver Adjustment Charge
    process_due_wavadj_charges(
      p_n_source_credit_id  => p_n_source_credit_id,
      p_n_person_id         => p_n_person_id,
      p_v_fee_cal_type      => p_v_fee_cal_type,
      p_n_fee_ci_seq_number => p_n_fee_ci_seq_number,
      p_v_waiver_name       => p_v_waiver_name,
      p_v_adj_fee_type      => p_v_adj_fee_type,
      p_d_gl_date           => p_d_gl_date,
      x_return_status       => l_v_return_status);

    -- If the procedure is returned with Error status then exit the processing
    -- with Error Status, otherwise continue with the processing
    IF l_v_return_status = 'E' THEN
      log_to_fnd('apply_waivers','Procedure process_due_wavadj_charges is failed');
      RAISE apply_wav_fail;
    END IF;
    log_to_fnd('apply_waivers','Procedure process_due_wavadj_charges is completed successfully');

  EXCEPTION

    WHEN apply_wav_fail THEN
      ROLLBACK TO apply_waivers_sp;
      x_return_status := 'E';

    WHEN OTHERS THEN
      ROLLBACK TO apply_waivers_sp;
      x_return_status := 'E';

      -- Log the SQLERRM message
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igs_fi_wav_utils_001.apply_waivers.exception','sqlerrm ' || SQLERRM);
      END IF;

  END apply_waivers;


  --
  -- Local Procedures Definition
  --

  PROCEDURE validate_elg_wavamt_params(
    p_n_person_id          IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type       IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number  IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name        IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_target_fee_type    IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_v_waiver_method_code IN  igs_fi_waiver_pgms.waiver_method_code%TYPE,
    p_v_waiver_mode_code   IN  igs_fi_waiver_pgms.waiver_mode_code%TYPE,
    p_n_source_invoice_id  IN  igs_fi_inv_int_all.invoice_id%TYPE,
    x_return_status        OUT NOCOPY VARCHAR2) AS
  /******************************************************************
   Created By      :  Anji Yedubati
   Date Created By :  19-JUL-2005
   Purpose         :  This Procedure is called from get_eligible_waiver_amt to
                      validate the inbound parameters
   Known limitations,enhancements,remarks:

   Change History  :
   WHO     WHEN       WHAT
  ***************************************************************** */
  BEGIN

    -- Initialize the OUT Parameter to Sucess
    x_return_status := 'S';

    -- Check all the mandatory parameters are passed to the procedure
    IF p_n_person_id IS NULL OR p_v_fee_cal_type IS NULL OR p_n_fee_ci_seq_number IS NULL OR
       p_v_waiver_name IS NULL OR p_v_target_fee_type IS NULL THEN

      log_to_fnd('validate_elg_wavamt_params','Mandatory Parameters are Null');
      x_return_status := 'E';

    END IF;

    -- Waiver Creation Method should be Manual or Computation Rule
    IF p_v_waiver_method_code IS NULL OR
       p_v_waiver_method_code NOT IN ('MANUAL','COMP_RULE') THEN

      log_to_fnd('validate_elg_wavamt_params','p_v_waiver_method_code should be passed as MANUAL or COMP_RULE');
      x_return_status := 'E';

    -- If Waiver Creation Method is Computaion Rule
    ELSIF p_v_waiver_method_code = 'COMP_RULE' THEN
      IF p_v_waiver_mode_code IS NOT NULL THEN
        log_to_fnd('validate_elg_wavamt_params','p_v_waiver_mode_code IS NOT NULL for Computation Waiver Method');
        x_return_status := 'E';
      END IF;

    -- If Waiver Creation Method is Manual
    ELSIF p_v_waiver_method_code = 'MANUAL' THEN

      -- Waiver Mode should be Charge Level or Fee Level
      IF p_v_waiver_mode_code IS NULL OR
         p_v_waiver_mode_code NOT IN ('CHARGE_LEVEL','FEE_LEVEL') THEN

        log_to_fnd('validate_elg_wavamt_params','p_v_waiver_mode_code should be passed as CHARGE_LEVEL or FEE_LEVEL');
        x_return_status := 'E';

      -- If Waiver Mode should be Charge Level then Source Invoice ID should be passed
      ELSIF p_v_waiver_mode_code = 'CHARGE_LEVEL' THEN

        IF p_n_source_invoice_id IS NULL THEN
          log_to_fnd('validate_elg_wavamt_params','p_n_source_invoice_id IS NULL for Charge Level Waiver Mode');
          x_return_status := 'E';
        END IF;

      -- Waiver Mode is Fee Level then Source Invoice ID should not be passed
      ELSIF p_v_waiver_mode_code = 'FEE_LEVEL' THEN

        IF p_n_source_invoice_id IS NOT NULL THEN
          log_to_fnd('validate_elg_wavamt_params','p_n_source_invoice_id IS NOT NULL for Fee Level Waiver Mode');
          x_return_status := 'E';
        END IF;

      END IF;

    END IF;

  END validate_elg_wavamt_params;

  PROCEDURE validate_applywav_params(
    p_n_person_id          IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type       IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number  IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name        IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_target_fee_type    IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_v_adj_fee_type       IN  igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_v_waiver_method_code IN  igs_fi_waiver_pgms.waiver_method_code%TYPE,
    p_v_waiver_mode_code   IN  igs_fi_waiver_pgms.waiver_mode_code%TYPE,
    p_n_source_credit_id   IN  igs_fi_credits_all.credit_id%TYPE,
    p_n_source_invoice_id  IN  igs_fi_inv_int_all.invoice_id%TYPE,
    p_v_currency_cd        IN  igs_fi_inv_int_all.currency_cd%TYPE,
    p_d_gl_date            IN  igs_fi_invln_int.gl_date%TYPE,
    x_return_status        OUT NOCOPY VARCHAR2) AS
  /******************************************************************
   Created By      :  Anji Yedubati
   Date Created By :  19-JUL-2005
   Purpose         :  This Procedure is called from apply_waivers to
                      validate the inbound parameters
   Known limitations,enhancements,remarks:

   Change History  :
   WHO     WHEN       WHAT
  ***************************************************************** */
  BEGIN

    -- Initialize the OUT Parameter to Sucess
    x_return_status := 'S';

    -- Check all the mandatory parameters are passed to the procedure
    IF p_n_person_id IS NULL OR p_v_fee_cal_type IS NULL OR p_n_fee_ci_seq_number IS NULL OR p_v_waiver_name IS NULL OR
       p_v_target_fee_type IS NULL OR p_v_adj_fee_type IS NULL OR p_v_currency_cd IS NULL OR p_d_gl_date IS NULL THEN

      log_to_fnd('validate_applywav_params','Mandatory Parameters are Null');
      x_return_status := 'E';

    END IF;

    -- Waiver Creation Method should be Manual or Computation Rule
    IF p_v_waiver_method_code IS NULL OR
       p_v_waiver_method_code NOT IN ('MANUAL','COMP_RULE') THEN

      log_to_fnd('validate_applywav_params','p_v_waiver_method_code should be passed as MANUAL or COMP_RULE');
      x_return_status := 'E';

    -- If Waiver Creation Method is Computaion Rule
    ELSIF p_v_waiver_method_code = 'COMP_RULE' THEN
      IF p_v_waiver_mode_code IS NOT NULL THEN
        log_to_fnd('validate_applywav_params','p_v_waiver_mode_code IS NOT NULL for Computation Waiver Method');
        x_return_status := 'E';
      END IF;

    -- If Waiver Creation Method is Manual
    ELSIF p_v_waiver_method_code = 'MANUAL' THEN

      -- Waiver Mode should be Charge Level or Fee Level
      IF p_v_waiver_mode_code IS NULL OR
         p_v_waiver_mode_code NOT IN ('CHARGE_LEVEL','FEE_LEVEL') THEN

        log_to_fnd('validate_applywav_params','p_v_waiver_mode_code should be passed as CHARGE_LEVEL or FEE_LEVEL');
        x_return_status := 'E';

      -- If Waiver Mode should be Charge Level then Source Invoice ID should be passed
      ELSIF p_v_waiver_mode_code = 'CHARGE_LEVEL' THEN

        IF p_n_source_credit_id IS NULL OR p_n_source_invoice_id IS NULL THEN
          log_to_fnd('validate_applywav_params','p_n_source_credit_id IS NULL or p_n_source_invoice_id IS NULL for Charge Level Waiver Mode');
          x_return_status := 'E';

        END IF;

      -- Waiver Mode is Fee Level then Source Invoice ID should not be passed
      ELSIF p_v_waiver_mode_code = 'FEE_LEVEL' THEN

        IF p_n_source_credit_id IS NULL OR p_n_source_invoice_id IS NOT NULL THEN
          log_to_fnd('validate_applywav_params','p_n_source_credit_id IS NULL or p_n_source_invoice_id IS NOT NULL for Fee Level Waiver Mode');
          x_return_status := 'E';

        END IF;

      END IF;

    END IF;

  END validate_applywav_params;

  PROCEDURE process_wavadj_charges(
    p_n_person_id         IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type      IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_adj_fee_type      IN  igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_v_waiver_name       IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_n_credit_id         IN  igs_fi_credits_all.credit_id%TYPE,
    p_d_gl_date           IN  igs_fi_invln_int.gl_date%TYPE,
    p_n_credit_amount     IN  OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2) AS
  /******************************************************************
   Created By      :  Anji Yedubati
   Date Created By :  19-JUL-2005
   Purpose         :  This Procedure is called from apply_waivers to
                      apply the waiver credit againt waiver adjustment charges.
   Known limitations,enhancements,remarks:

   Change History  :
   WHO     WHEN       WHAT
  ***************************************************************** */

    -- Fecth the Waiver adjustment charges having some positive amount due exists
    -- for the combination of Person, Adjsutment Fee Type, Fee Period and Waiver Name
    CURSOR waiver_adj_charges_cur(
      cp_n_person_id      igs_fi_inv_int_all.person_id%TYPE,
      cp_v_adj_fee_type   igs_fi_inv_int_all.fee_type%TYPE,
      cp_v_fee_cal_type   igs_fi_credits_all.fee_cal_type%TYPE,
      cp_n_fee_ci_seq_num igs_fi_credits_all.fee_ci_sequence_number%TYPE,
      cp_v_waiver_name    igs_fi_credits_all.waiver_name%TYPE) IS
    SELECT inv.invoice_id,
           inv.invoice_amount_due
    FROM igs_fi_inv_int_all inv,
         igs_fi_invln_int_all invln
    WHERE inv.person_id = cp_n_person_id
      AND inv.fee_type     = cp_v_adj_fee_type
      AND inv.fee_cal_type = cp_v_fee_cal_type
      AND inv.fee_ci_sequence_number = cp_n_fee_ci_seq_num
      AND inv.waiver_name  = cp_v_waiver_name
      AND NVL(inv.invoice_amount_due, 0) > 0
      AND invln.invoice_id = inv.invoice_id
      AND NVL(invln.error_account,'N') = 'N'
    ORDER BY inv.invoice_id;

    l_n_app_id        igs_fi_applications.application_id%TYPE;
    l_n_amount_apply  igs_fi_applications.amount_applied%TYPE;
    l_n_dr_gl_ccid    igs_fi_applications.dr_gl_code_ccid%TYPE;
    l_n_cr_gl_ccid    igs_fi_applications.cr_gl_code_ccid%TYPE;
    l_v_dr_acc_cd     igs_fi_applications.dr_account_cd%TYPE;
    l_v_cr_acc_cd     igs_fi_applications.cr_account_cd%TYPE;
    l_n_unapp_amount  igs_fi_credits.unapplied_amount%TYPE;
    l_n_inv_amt_due   igs_fi_inv_int.invoice_amount_due%TYPE;
    l_v_err_msg       VARCHAR2(2000);
    l_b_status        BOOLEAN;

  BEGIN

    x_return_status := 'S';

    -- Loop through the Waiver Adjustment charge records having some positive amount due exists
    -- for the combination of Person, Adjsutment Fee Type, Fee Period and Waiver Name
    FOR waiver_adj_charges_rec IN waiver_adj_charges_cur(p_n_person_id,p_v_adj_fee_type,
                                  p_v_fee_cal_type,p_n_fee_ci_seq_number,p_v_waiver_name) LOOP

      log_to_fnd('process_wavadj_charges','Processing the Invoice ID: '||waiver_adj_charges_rec.invoice_id);

      -- Calculate the amount to be applied to the Waiver Adjustment charge
      IF waiver_adj_charges_rec.invoice_amount_due >= p_n_credit_amount THEN
        l_n_amount_apply := p_n_credit_amount;
      ELSE
        l_n_amount_apply := waiver_adj_charges_rec.invoice_amount_due;
      END IF;

      -- Invoke the  application procedure to create an application
      l_n_app_id  := NULL;
      l_v_err_msg := NULL;
      igs_fi_gen_007.create_application(
        p_application_id        => l_n_app_id,
        p_credit_id             => p_n_credit_id,
        p_invoice_id            => waiver_adj_charges_rec.invoice_id,
        p_amount_apply          => l_n_amount_apply,
        p_appl_type             => g_v_app,
        p_appl_hierarchy_id     => NULL,
        p_validation            => 'Y',
        p_dr_gl_ccid            => l_n_dr_gl_ccid,
        p_cr_gl_ccid            => l_n_cr_gl_ccid,
        p_dr_account_cd         => l_v_dr_acc_cd,
        p_cr_account_cd         => l_v_cr_acc_cd,
        p_unapp_amount          => l_n_unapp_amount,
        p_inv_amt_due           => l_n_inv_amt_due,
        p_err_msg               => l_v_err_msg,
        p_status                => l_b_status,
        p_d_gl_date             => p_d_gl_date);

      -- Check the Staus of the Waiver Credit Application
      -- If the status of the application is true
      IF l_b_status THEN
        log_to_fnd(p_v_module => 'process_wavadj_charges',
                   p_v_string => 'Application record created. Application ID= '||l_n_app_id);

        -- Deduct the Waiver credit amount to the extent of applied amount(l_n_amount_apply)
        p_n_credit_amount := p_n_credit_amount - l_n_amount_apply;

        -- If the balance Waiver credit is zero then return to apply_waivers procedure with success status
        IF p_n_credit_amount = 0 THEN
          x_return_status := 'S';
          RETURN;
        END IF;

      -- If the status of the application is false
      ELSE
        -- Log the message and return to the apply_waivers Procedure
        log_to_fnd(p_v_module => 'process_wavadj_charges',
                   p_v_string => 'Error: '||fnd_message.get_string('IGS', l_v_err_msg));

        -- Return to apply_waivers procedure with Error status
        x_return_status := 'E';
        RETURN;

      END IF;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN

      -- Log the SQLERRM message and return to the apply_waivers Procedure
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igs_fi_wav_utils_001.process_wavadj_charges.exception','sqlerrm ' || SQLERRM);
      END IF;

      x_return_status := 'E';

  END process_wavadj_charges;

  PROCEDURE process_stdnt_charges(
    p_n_invoice_id        IN  igs_fi_inv_int_all.invoice_id%TYPE,
    p_n_person_id         IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type      IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_target_fee_type   IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_n_credit_id         IN  igs_fi_credits_all.credit_id%TYPE,
    p_d_gl_date           IN  igs_fi_invln_int.gl_date%TYPE,
    p_n_credit_amount     IN OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2) AS
  /******************************************************************
   Created By      : Anji Yedubati
   Date Created By : 19-JUL-2005
   Purpose         : This Procedure is called from apply_waivers to
                     apply the waiver credit againt charges in the
                     student account exception Retension chanrges
   Known limitations,enhancements,remarks:

   Change History  :
   WHO     WHEN       WHAT
  ***************************************************************** */

    -- Fetch the Charges except Retention Charges having some positive amount due exists
    -- for a combination of Person, Fee Type and Fee Period or source invoice id alone
    CURSOR stnt_charges_cur(
      cp_n_invoice_id     igs_fi_inv_int_all.invoice_id%TYPE,
      cp_n_person_id      igs_fi_inv_int_all.person_id%TYPE,
      cp_v_target_fee_type igs_fi_inv_int_all.fee_type%TYPE,
      cp_v_fee_cal_type   igs_fi_credits_all.fee_cal_type%TYPE,
      cp_n_fee_ci_seq_num igs_fi_credits_all.fee_ci_sequence_number%TYPE) IS
    SELECT inv.invoice_id,
           inv.invoice_amount_due
    FROM igs_fi_inv_int_all inv,
         igs_fi_invln_int_all invln
    WHERE (inv.invoice_id = cp_n_invoice_id OR cp_n_invoice_id IS NULL)
      AND inv.person_id    = cp_n_person_id
      AND inv.fee_type     = cp_v_target_fee_type
      AND inv.fee_cal_type = cp_v_fee_cal_type
      AND inv.fee_ci_sequence_number = cp_n_fee_ci_seq_num
      AND NVL (inv.invoice_amount_due, 0) > 0
      AND inv.transaction_type <> 'RETENTION'
      AND invln.invoice_id = inv.invoice_id
      AND NVL(invln.error_account,'N') = 'N'
    ORDER BY inv.invoice_id;

    l_n_app_id        igs_fi_applications.application_id%TYPE;
    l_n_amount_apply  igs_fi_applications.amount_applied%TYPE;
    l_n_dr_gl_ccid    igs_fi_applications.dr_gl_code_ccid%TYPE;
    l_n_cr_gl_ccid    igs_fi_applications.cr_gl_code_ccid%TYPE;
    l_v_dr_acc_cd     igs_fi_applications.dr_account_cd%TYPE;
    l_v_cr_acc_cd     igs_fi_applications.cr_account_cd%TYPE;
    l_n_unapp_amount  igs_fi_credits.unapplied_amount%TYPE;
    l_n_inv_amt_due   igs_fi_inv_int.invoice_amount_due%TYPE;
    l_v_err_msg       VARCHAR2(2000);
    l_b_status        BOOLEAN;

  BEGIN

    x_return_status := 'S';

    -- Loop through the charges except Retention charges having some positive amount due exists
    -- for a combination of Person, Fee Type and Fee Period or source invoice id alone
    FOR stnt_charges_rec IN stnt_charges_cur(p_n_invoice_id, p_n_person_id,
                            p_v_target_fee_type, p_v_fee_cal_type, p_n_fee_ci_seq_number) LOOP

      log_to_fnd('process_stdnt_charges','Processing the Invoice ID: '||stnt_charges_rec.invoice_id);

      -- Calculate the amount to be applied against the context charge
      IF stnt_charges_rec.invoice_amount_due >= p_n_credit_amount THEN
        l_n_amount_apply := p_n_credit_amount;
      ELSE
        l_n_amount_apply := stnt_charges_rec.invoice_amount_due;
      END IF;

      -- Invoke the  application procedure to create an application
      l_n_app_id  := NULL;
      l_v_err_msg := NULL;
      igs_fi_gen_007.create_application(
        p_application_id        => l_n_app_id,
        p_credit_id             => p_n_credit_id,
        p_invoice_id            => stnt_charges_rec.invoice_id,
        p_amount_apply          => l_n_amount_apply,
        p_appl_type             => g_v_app,
        p_appl_hierarchy_id     => NULL,
        p_validation            => 'Y',
        p_dr_gl_ccid            => l_n_dr_gl_ccid,
        p_cr_gl_ccid            => l_n_cr_gl_ccid,
        p_dr_account_cd         => l_v_dr_acc_cd,
        p_cr_account_cd         => l_v_cr_acc_cd,
        p_unapp_amount          => l_n_unapp_amount,
        p_inv_amt_due           => l_n_inv_amt_due,
        p_err_msg               => l_v_err_msg,
        p_status                => l_b_status,
        p_d_gl_date             => p_d_gl_date);

      -- Check the Staus of the Waiver Credit application
      -- If the status of the application is true
      IF l_b_status THEN
        log_to_fnd(p_v_module => 'process_stdnt_charges',
                   p_v_string => 'Application record created. Application ID= '||l_n_app_id);

        -- Deduct the Waiver credit amount to the extent of applied amount(l_n_amount_apply)
        p_n_credit_amount := p_n_credit_amount - l_n_amount_apply;

        -- If the balance Waiver credit is zero then return to apply_waivers with success status
        IF p_n_credit_amount = 0 THEN
          x_return_status := 'S';
          RETURN;
        END IF;

      -- If the status of the application is false
      ELSE
        -- Log the message and return to the apply_waivers procedure
        log_to_fnd(p_v_module => 'process_stdnt_charges',
                   p_v_string => 'Error: '||fnd_message.get_string('IGS', l_v_err_msg));

        x_return_status := 'E';
        RETURN;

      END IF;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN

      -- Log the SQLERRM message and return to the apply_waivers procedure
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igs_fi_wav_utils_001.process_stdnt_charges.exception','sqlerrm ' || SQLERRM);
      END IF;

      -- Return the Error Status
      x_return_status := 'E';

  END process_stdnt_charges;

  PROCEDURE adjust_stdnt_charges(
    p_n_invoice_id        IN  igs_fi_inv_int_all.invoice_id%TYPE,
    p_n_credit_id         IN  igs_fi_credits_all.credit_id%TYPE,
    p_d_gl_date           IN  igs_fi_invln_int.gl_date%TYPE,
    p_n_credit_amount     IN OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2) AS
  /******************************************************************
   Created By      : Anji Yedubati
   Date Created By : 21-JUL-2005
   Purpose         : This procedure is called from apply_waivers to
                     un apply the applications applied against waiver,
                     charge adjustment, enrollment deposit and other deposits
                     and apply against the waiver credit
   Known limitations,enhancements,remarks:

   Change History  :
   WHO       WHEN         WHAT
   AYEDUBAT  03-NOV-2005  Changed the cursor, wav_app_cur to fetch the amount_applied using the
                          function call, igs_fi_gen_007.get_sum_appl_amnt for bug# 4634950
  ***************************************************************** */

    -- Fetch the application records other than negative charge adjustment credit,
    -- enrollment deposit and other deposits and waiver credit for a charge transaction
    CURSOR wav_app_cur (
      cp_n_invoice_id igs_fi_applications.invoice_id%TYPE,
      cp_cst_app      igs_fi_applications.application_type%TYPE) IS
    SELECT igs_fi_gen_007.get_sum_appl_amnt(appl.application_id) amount_applied,
           appl.application_id,
           appl.credit_id,
           appl.invoice_id
    FROM igs_fi_applications appl,
         igs_fi_credits_all crd,
         igs_fi_cr_types cr
    WHERE appl.invoice_id = cp_n_invoice_id
      AND appl.credit_id  = crd.credit_id
      AND appl.application_type = cp_cst_app
      AND crd.credit_type_id    = cr.credit_type_id
      AND cr.credit_class NOT IN ('CHGADJ','WAIVER','ENRDEPOSIT','OTHDEPOSIT')
      AND NOT EXISTS(
          SELECT 'X'
          FROM  igs_fi_applications appl2
          WHERE appl2.application_type = 'UNAPP'
            AND appl2.link_application_id = appl.application_id
            AND appl2.amount_applied = - appl.amount_applied)
    ORDER BY appl.application_id;

    l_n_app_id        igs_fi_applications.application_id%TYPE;
    l_n_amount_apply  igs_fi_applications.amount_applied%TYPE;
    l_n_dr_gl_ccid    igs_fi_applications.dr_gl_code_ccid%TYPE;
    l_n_cr_gl_ccid    igs_fi_applications.cr_gl_code_ccid%TYPE;
    l_v_dr_acc_cd     igs_fi_applications.dr_account_cd%TYPE;
    l_v_cr_acc_cd     igs_fi_applications.cr_account_cd%TYPE;
    l_n_unapp_amount  igs_fi_credits.unapplied_amount%TYPE;
    l_n_inv_amt_due   igs_fi_inv_int.invoice_amount_due%TYPE;
    l_v_err_msg       VARCHAR2(2000);
    l_b_status        BOOLEAN;

  BEGIN

    x_return_status := 'S';

    -- Loop through the application records other than negative charge adjustment credit,
    -- enrollment deposit and other deposits and waiver credit for a charge transaction
    FOR wav_app_rec IN wav_app_cur(p_n_invoice_id, g_v_app) LOOP

      log_to_fnd('adjust_stdnt_charges','Processing the Application ID: '||wav_app_rec.application_id);

      -- Calculate the amount to be un Applied against the context application
      IF wav_app_rec.amount_applied >= p_n_credit_amount THEN
        l_n_amount_apply := p_n_credit_amount;
      ELSE
        l_n_amount_apply := wav_app_rec.amount_applied;
      END IF;

      -- Invoke the application procedure to un apply the context application
      l_n_app_id  := wav_app_rec.application_id;
      l_v_err_msg := NULL;
      igs_fi_gen_007.create_application(
        p_application_id        => l_n_app_id,
        p_credit_id             => wav_app_rec.credit_id,
        p_invoice_id            => wav_app_rec.invoice_id,
        p_amount_apply          => l_n_amount_apply,
        p_appl_type             => g_v_unapp,
        p_appl_hierarchy_id     => NULL,
        p_validation            => 'Y',
        p_dr_gl_ccid            => l_n_dr_gl_ccid,
        p_cr_gl_ccid            => l_n_cr_gl_ccid,
        p_dr_account_cd         => l_v_dr_acc_cd,
        p_cr_account_cd         => l_v_cr_acc_cd,
        p_unapp_amount          => l_n_unapp_amount,
        p_inv_amt_due           => l_n_inv_amt_due,
        p_err_msg               => l_v_err_msg,
        p_status                => l_b_status,
        p_d_gl_date             => p_d_gl_date);

      -- Check the staus of the Un Application
      -- If the status of the un application is true
      IF l_b_status THEN
        log_to_fnd(p_v_module => 'adjust_stdnt_charges',
                   p_v_string => 'Un Application record created. Application ID= '||l_n_app_id);

        -- Invoke the application procedure to craete the application
        l_n_app_id  := NULL;
        l_v_err_msg := NULL;
        igs_fi_gen_007.create_application(
          p_application_id        => l_n_app_id,
          p_credit_id             => p_n_credit_id,
          p_invoice_id            => wav_app_rec.invoice_id,
          p_amount_apply          => l_n_amount_apply,
          p_appl_type             => g_v_app,
          p_appl_hierarchy_id     => NULL,
          p_validation            => 'Y',
          p_dr_gl_ccid            => l_n_dr_gl_ccid,
          p_cr_gl_ccid            => l_n_cr_gl_ccid,
          p_dr_account_cd         => l_v_dr_acc_cd,
          p_cr_account_cd         => l_v_cr_acc_cd,
          p_unapp_amount          => l_n_unapp_amount,
          p_inv_amt_due           => l_n_inv_amt_due,
          p_err_msg               => l_v_err_msg,
          p_status                => l_b_status,
          p_d_gl_date             => p_d_gl_date);

        -- If the status of the application is true
        IF l_b_status THEN
          log_to_fnd(p_v_module => 'adjust_stdnt_charges',
                     p_v_string => 'Application record created. Application ID= '||l_n_app_id);

          -- Deduct the Waiver credit amount to the extent of applied amount(l_n_amount_apply)
          p_n_credit_amount := p_n_credit_amount - l_n_amount_apply;

          -- If the balance Waiver credit is zero then return to apply_waivers with success status
          IF p_n_credit_amount = 0 THEN
            x_return_status := 'S';
            RETURN;
          END IF;

        -- If the status of the application is false
        ELSE

          -- Log the message and return to the apply_waivers Procedure
          log_to_fnd(p_v_module => 'adjust_stdnt_charges',
                     p_v_string => 'Error: '||fnd_message.get_string('IGS', l_v_err_msg));

          x_return_status := 'E';
          RETURN;

        END IF;

      -- If the status of the un application is false
      ELSE

        -- Log the message and return to the apply_waivers Procedure
        log_to_fnd(p_v_module => 'adjust_stdnt_charges',
                   p_v_string => 'Error: '||fnd_message.get_string('IGS', l_v_err_msg) );

        x_return_status := 'E';
        RETURN;

      END IF;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN

      -- Log the SQLERRM message and return to the apply_waivers Procedure
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igs_fi_wav_utils_001.adjust_stdnt_charges.exception','sqlerrm ' || SQLERRM);
      END IF;

      -- Return the Error Status
      x_return_status := 'E';

  END adjust_stdnt_charges;

  PROCEDURE create_wavadj_charge(
    p_n_person_id         IN igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type      IN igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number IN igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name       IN igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_adj_fee_type      IN igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_n_credit_id         IN igs_fi_credits_all.credit_id%TYPE,
    p_v_currency_cd       IN igs_fi_inv_int_all.currency_cd%TYPE,
    p_n_waiver_amt        IN igs_fi_inv_int_all.invoice_amount%TYPE,
    p_d_gl_date           IN igs_fi_invln_int.gl_date%TYPE,
    x_return_status       OUT NOCOPY VARCHAR2) AS
  /******************************************************************
   Created By      : Anji Yedubati
   Date Created By : 21-JUL-2005
   Purpose         : This procedure is called from apply_waivers to create the
                     waiver adjustment charge for the balance waiver credit and apply
                     against the waiver adjustment charge
   Known limitations,enhancements,remarks:

   Change History  :
   WHO     WHEN       WHAT
  ***************************************************************** */

    l_n_invoice_id igs_fi_inv_int_all.invoice_id%TYPE;
    l_b_status        BOOLEAN;

    l_n_app_id        igs_fi_applications.application_id%TYPE;
    l_n_dr_gl_ccid    igs_fi_applications.dr_gl_code_ccid%TYPE;
    l_n_cr_gl_ccid    igs_fi_applications.cr_gl_code_ccid%TYPE;
    l_v_dr_acc_cd     igs_fi_applications.dr_account_cd%TYPE;
    l_v_cr_acc_cd     igs_fi_applications.cr_account_cd%TYPE;
    l_n_unapp_amount  igs_fi_credits.unapplied_amount%TYPE;
    l_n_inv_amt_due   igs_fi_inv_int.invoice_amount_due%TYPE;
    l_v_err_msg       VARCHAR2(2000);

  BEGIN

    x_return_status := 'S';

    log_to_fnd('create_wavadj_charge','Before calling the procedure igs_fi_wav_utils_002.call_charges_api');

    -- Invoke the Charges API to create Waiver Adjustment Charge
    l_n_invoice_id  := NULL;
    igs_fi_wav_utils_002.call_charges_api(
      p_n_person_id          => p_n_person_id,
      p_v_fee_cal_type       => p_v_fee_cal_type,
      p_n_fee_ci_seq_number  => p_n_fee_ci_seq_number,
      p_v_waiver_name        => p_v_waiver_name,
      p_v_adj_fee_type       => p_v_adj_fee_type,
      p_v_currency_cd        => p_v_currency_cd,
      p_n_waiver_amt         => p_n_waiver_amt,
      p_d_gl_date            => p_d_gl_date,
      p_n_invoice_id         => l_n_invoice_id,
      x_return_status        => x_return_status);

    IF x_return_status = 'S' THEN

      log_to_fnd('create_wavadj_charge','Charge created successfully. Invoice ID= '||l_n_invoice_id);

      -- Invoke the application procedure to apply the Waiver Adjustment Charge
      -- against the Waiver Credit record in entirity
      l_n_app_id  := NULL;
      l_v_err_msg := NULL;
      igs_fi_gen_007.create_application(
        p_application_id        => l_n_app_id,
        p_credit_id             => p_n_credit_id,
        p_invoice_id            => l_n_invoice_id,
        p_amount_apply          => p_n_waiver_amt,
        p_appl_type             => g_v_app,
        p_appl_hierarchy_id     => NULL,
        p_validation            => 'Y',
        p_dr_gl_ccid            => l_n_dr_gl_ccid,
        p_cr_gl_ccid            => l_n_cr_gl_ccid,
        p_dr_account_cd         => l_v_dr_acc_cd,
        p_cr_account_cd         => l_v_cr_acc_cd,
        p_unapp_amount          => l_n_unapp_amount,
        p_inv_amt_due           => l_n_inv_amt_due,
        p_err_msg               => l_v_err_msg,
        p_status                => l_b_status,
        p_d_gl_date             => p_d_gl_date);

        -- Check the Staus of the Waiver Credit Application
        IF NOT l_b_status THEN
          -- Log the message and set the Error Status
          log_to_fnd(p_v_module => 'create_wavadj_charge',
                     p_v_string => 'Error: '||fnd_message.get_string('IGS', l_v_err_msg) );
          x_return_status := 'E';

        ELSE
          log_to_fnd('create_wavadj_charge','Application record created. Application ID= '||l_n_app_id);
        END IF;

    ELSE

      -- Log the message and set the Error Status
      log_to_fnd(p_v_module => 'create_wavadj_charge',
                 p_v_string => 'Error: '||fnd_message.get_string('IGS', l_v_err_msg));

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- Log the SQLERRM message and return the Error status
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igs_fi_wav_utils_001.create_wavadj_charge.exception','sqlerrm ' || SQLERRM);
      END IF;

      -- Return the Error Status
      x_return_status := 'E';

  END create_wavadj_charge;

  PROCEDURE process_due_wavadj_charges(
    p_n_source_credit_id  IN igs_fi_credits_all.credit_id%TYPE,
    p_n_person_id         IN igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type      IN igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number IN igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name       IN igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_adj_fee_type      IN igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_d_gl_date           IN igs_fi_invln_int.gl_date%TYPE,
    x_return_status       OUT NOCOPY VARCHAR2) AS
  /******************************************************************
   Created By      : Anji Yedubati
   Date Created By : 21-JUL-2005
   Purpose         : This procedure is called from apply_waivers to apply the
                     waiver adjustment charges, if any to the waiver credits
   Known limitations,enhancements,remarks:

   Change History  :
   WHO     WHEN       WHAT
   AYEDUBAT  03-NOV-2005  Changed the cursor, appls_otherthan_wavadj_cur to fetch the amount_applied
                          using the function call, igs_fi_gen_007.get_sum_appl_amnt.
                          Added the Not exist clause to the cursor,appls_otherthan_wavadj_cur to restrict
                          the records which are already un applied for bug# 4634950
  ***************************************************************** */

    -- Fetch the Waiver charge adjustment records having some positive amount due exists
    -- for the combination of Person, Fee Type, Fee Period and Waiver name
    CURSOR waiver_adj_charges_cur(
      cp_n_person_id      igs_fi_inv_int_all.person_id%TYPE,
      cp_v_adj_fee_type   igs_fi_inv_int_all.fee_type%TYPE,
      cp_v_fee_cal_type   igs_fi_credits_all.fee_cal_type%TYPE,
      cp_n_fee_ci_seq_num igs_fi_credits_all.fee_ci_sequence_number%TYPE,
      cp_v_waiver_name    igs_fi_credits_all.waiver_name%TYPE) IS
    SELECT
      inv.invoice_id,
      inv.invoice_amount,
      inv.invoice_amount_due
    FROM igs_fi_inv_int_all inv,
         igs_fi_invln_int_all invln
    WHERE inv.person_id    = cp_n_person_id
      AND inv.fee_type     = cp_v_adj_fee_type
      AND inv.fee_cal_type = cp_v_fee_cal_type
      AND inv.fee_ci_sequence_number = cp_n_fee_ci_seq_num
      AND inv.waiver_name  = cp_v_waiver_name
      AND NVL (inv.invoice_amount_due, 0) > 0
      AND invln.invoice_id = inv.invoice_id
      AND NVL(invln.error_account,'N') = 'N'
    ORDER BY inv.invoice_id;

    -- Fetch the waiver credit records having some positive amount due exists
    -- for the combination of Person, Fee Period and Waiver Name
    CURSOR stdnt_waiver_crdits_cur(
      cp_n_credit_id      igs_fi_credits_all.credit_id%TYPE,
      cp_n_person_id      igs_fi_credits_all.party_id%TYPE,
      cp_v_fee_cal_type   igs_fi_credits_all.fee_cal_type%TYPE,
      cp_n_fee_ci_seq_num igs_fi_credits_all.fee_ci_sequence_number%TYPE,
      cp_v_waiver_name    igs_fi_credits_all.waiver_name%TYPE) IS
    SELECT
      crd.credit_id,
      crd.unapplied_amount
    FROM igs_fi_credits_all crd
    WHERE (cp_n_credit_id IS NULL OR crd.credit_id = cp_n_credit_id)
      AND crd.party_id     = cp_n_person_id
      AND crd.fee_cal_type = cp_v_fee_cal_type
      AND crd.fee_ci_sequence_number = cp_n_fee_ci_seq_num
      AND crd.waiver_name  = cp_v_waiver_name
      AND NVL(crd.unapplied_amount, 0) > 0
    ORDER BY credit_id;

    -- Fetch the waiver credit records which are fully applied
    -- for the combination of Person, Fee Period and Waiver Name
    CURSOR stdnt_fullapplied_wavcr_cur(
      cp_n_credit_id      igs_fi_credits_all.credit_id%TYPE,
      cp_n_person_id      igs_fi_credits_all.party_id%TYPE,
      cp_v_fee_cal_type   igs_fi_credits_all.fee_cal_type%TYPE,
      cp_n_fee_ci_seq_num igs_fi_credits_all.fee_ci_sequence_number%TYPE,
      cp_v_waiver_name    igs_fi_credits_all.waiver_name%TYPE) IS
    SELECT
      crd.credit_id,
      crd.unapplied_amount
    FROM  igs_fi_credits_all crd
    WHERE (cp_n_credit_id IS NULL OR crd.credit_id = cp_n_credit_id)
      AND crd.party_id     = cp_n_person_id
      AND crd.fee_cal_type = cp_v_fee_cal_type
      AND crd.fee_ci_sequence_number = cp_n_fee_ci_seq_num
      AND crd.waiver_name  = cp_v_waiver_name
    ORDER BY credit_id;

    -- Fetch the application records exist for a waiver credit transaction
    -- excluding the applications between the waiver credit and waiver adjustment charge
    CURSOR appls_otherthan_wavadj_cur(
      cp_n_credit_id  igs_fi_credits_all.credit_id%TYPE) IS
    SELECT
      igs_fi_gen_007.get_sum_appl_amnt(appl.application_id) amount_applied,
      appl.application_id,
      appl.credit_id,
      appl.invoice_id
    FROM igs_fi_applications appl,
         igs_fi_inv_int_all inv
    WHERE appl.credit_id  = cp_n_credit_id
      AND appl.invoice_id = inv.invoice_id
      AND appl.application_type = 'APP'
      AND inv.transaction_type <> 'WAIVER_ADJ'
      AND NOT EXISTS (
          SELECT 'X'
          FROM  igs_fi_applications appl2
          WHERE appl2.application_type = 'UNAPP'
            AND appl2.link_application_id = appl.application_id
            AND appl2.amount_applied      = - appl.amount_applied)
    ORDER BY appl.application_id;

    l_n_invoice_amount igs_fi_inv_int_all.invoice_amount%TYPE;
    l_n_amount_apply NUMBER;

    l_n_app_id        igs_fi_applications.application_id%TYPE;
    l_n_dr_gl_ccid    igs_fi_applications.dr_gl_code_ccid%TYPE;
    l_n_cr_gl_ccid    igs_fi_applications.cr_gl_code_ccid%TYPE;
    l_v_dr_acc_cd     igs_fi_applications.dr_account_cd%TYPE;
    l_v_cr_acc_cd     igs_fi_applications.cr_account_cd%TYPE;
    l_n_unapp_amount  igs_fi_credits.unapplied_amount%TYPE;
    l_n_inv_amt_due   igs_fi_inv_int.invoice_amount_due%TYPE;
    l_v_err_msg       VARCHAR2(2000);
    l_b_status        BOOLEAN;

  BEGIN

    -- Initialize the Variables
    l_n_invoice_amount := 0;
    x_return_status := 'S';

    -- Loop through the Waiver charge adjustment records having some positive amount due exists
    -- for the combination of Person, Fee Type, Fee Period and Waiver name
    FOR waiver_adj_charges_rec IN waiver_adj_charges_cur(p_n_person_id,p_v_adj_fee_type,
                                  p_v_fee_cal_type,p_n_fee_ci_seq_number,p_v_waiver_name) LOOP

      log_to_fnd(p_v_module => 'process_due_wavadj_charges',
                 p_v_string => 'Processing waiver_adj_charges_rec Invoice ID: '||waiver_adj_charges_rec.invoice_id);

      -- Intialize the Invoice Amount Due in a local variable and process the following logic
      -- until Invoice Amount Due is 0 or all the records have been processed successfully
      l_n_invoice_amount := waiver_adj_charges_rec.invoice_amount_due;

      -- Loop through the waiver credit records having some positive amount due exists
      -- for the combination of Person, Fee Period and Waiver Name details
      <<waiver_crdits_loop>>
      FOR stdnt_waiver_crdits_rec IN stdnt_waiver_crdits_cur (p_n_source_credit_id,p_n_person_id, p_v_fee_cal_type,
                                                              p_n_fee_ci_seq_number, p_v_waiver_name) LOOP

        log_to_fnd(p_v_module => 'process_due_wavadj_charges',
                   p_v_string => 'Processing stdnt_waiver_crdits_rec Credit ID= '||stdnt_waiver_crdits_rec.credit_id);

        -- Calculate the Amount to be applied
        -- If the Unapplied amount on the context waiver credit record is greater than or
        -- equal to Invoice Amount(l_n_invoice_amount), apply an amount equal to Invoice Amount
        -- Otherwise , apply an amount equal to Unapplied amount on the context waiver credit record
        IF stdnt_waiver_crdits_rec.unapplied_amount >= l_n_invoice_amount THEN
          l_n_amount_apply := l_n_invoice_amount;
        ELSE
          l_n_amount_apply := stdnt_waiver_crdits_rec.unapplied_amount;
        END IF;

        --Invoke the application procedure to create Application
        l_n_app_id := NULL;
        l_v_err_msg := NULL;
        igs_fi_gen_007.create_application(
          p_application_id        => l_n_app_id,
          p_credit_id             => stdnt_waiver_crdits_rec.credit_id,
          p_invoice_id            => waiver_adj_charges_rec.invoice_id,
          p_amount_apply          => l_n_amount_apply,
          p_appl_type             => g_v_app,
          p_appl_hierarchy_id     => NULL,
          p_validation            => 'Y',
          p_dr_gl_ccid            => l_n_dr_gl_ccid,
          p_cr_gl_ccid            => l_n_cr_gl_ccid,
          p_dr_account_cd         => l_v_dr_acc_cd,
          p_cr_account_cd         => l_v_cr_acc_cd,
          p_unapp_amount          => l_n_unapp_amount,
          p_inv_amt_due           => l_n_inv_amt_due,
          p_err_msg               => l_v_err_msg,
          p_status                => l_b_status,
          p_d_gl_date             => p_d_gl_date);

        IF l_b_status THEN

          log_to_fnd(p_v_module => 'process_due_wavadj_charges',
                     p_v_string => 'Application record created. Application ID= '||l_n_app_id);

          -- Deduct the Invoice Amount to the extent applied (l_n_amount_apply)
          l_n_invoice_amount := l_n_invoice_amount - l_n_amount_apply;
          IF l_n_invoice_amount = 0 THEN
            EXIT waiver_crdits_loop;
          END IF;

        ELSE

          -- Log the message and return to the calling Procedure
          log_to_fnd( p_v_module => 'process_due_wavadj_charges',
                      p_v_string => 'Error: '||fnd_message.get_string('IGS', l_v_err_msg));
          x_return_status := 'E';
          RETURN;
        END IF;

      END LOOP waiver_crdits_loop;

      -- If Invoice Amount is lee than or euqal to 0 then Return from the Procedure
      IF l_n_invoice_amount > 0 THEN

        -- Loop through the waiver credit records which are fully applied
        -- for the combination of Person, Fee Period and Waiver Name details
        <<fullapplied_wavcr_loop>>
        FOR stdnt_fullapplied_wavcr_rec IN stdnt_fullapplied_wavcr_cur(p_n_source_credit_id,p_n_person_id,
                                           p_v_fee_cal_type,p_n_fee_ci_seq_number, p_v_waiver_name ) LOOP

          log_to_fnd(p_v_module => 'process_due_wavadj_charges',
                     p_v_string => 'Processing stdnt_fullapplied_wavcr_rec Credit ID= '||stdnt_fullapplied_wavcr_rec.credit_id);

          -- Loop through the application records exists for the context waiver credit transaction
          -- excluding the applications between the waiver credit and waiver adjustment charge
          FOR appls_otherthan_wavadj_rec IN appls_otherthan_wavadj_cur(stdnt_fullapplied_wavcr_rec.credit_id) LOOP

            -- Calculate the Amount to be applied for Unapplication and Application
            IF appls_otherthan_wavadj_rec.amount_applied >= l_n_invoice_amount THEN
              l_n_amount_apply := l_n_invoice_amount;
            ELSE
              l_n_amount_apply := appls_otherthan_wavadj_rec.amount_applied;
            END IF;

            -- Invoke the application procedure to Un apply the context application
            l_v_err_msg := NULL;
            l_n_app_id := appls_otherthan_wavadj_rec.application_id;
              igs_fi_gen_007.create_application(
              p_application_id        => l_n_app_id,
              p_credit_id             => appls_otherthan_wavadj_rec.credit_id,
              p_invoice_id            => appls_otherthan_wavadj_rec.invoice_id,
              p_amount_apply          => l_n_amount_apply,
              p_appl_type             => g_v_unapp,
              p_appl_hierarchy_id     => NULL,
              p_validation            => 'Y',
              p_dr_gl_ccid            => l_n_dr_gl_ccid,
              p_cr_gl_ccid            => l_n_cr_gl_ccid,
              p_dr_account_cd         => l_v_dr_acc_cd,
              p_cr_account_cd         => l_v_cr_acc_cd,
              p_unapp_amount          => l_n_unapp_amount,
              p_inv_amt_due           => l_n_inv_amt_due,
              p_err_msg               => l_v_err_msg,
              p_status                => l_b_status,
              p_d_gl_date             => p_d_gl_date);

            -- Check the Staus of the Unapplication
            -- If Application failed, then return to the calling procedure
            IF NOT l_b_status THEN

              -- Log the message and return to the calling Procedure
              log_to_fnd(p_v_module => 'process_due_wavadj_charges',
                         p_v_string => 'Error: '||fnd_message.get_string('IGS', l_v_err_msg) );
              -- Return Error Status
              x_return_status := 'E';
              RETURN;

            END IF;

            log_to_fnd(p_v_module => 'process_due_wavadj_charges',
                       p_v_string => 'Un application record created. Application ID= '||l_n_app_id);


            -- Invoke the procedure to apply the context application credit record
            -- against the Waiver Adjustment Charge
            l_n_app_id  := NULL;
            l_v_err_msg := NULL;
            igs_fi_gen_007.create_application(
              p_application_id        => l_n_app_id,
              p_credit_id             => appls_otherthan_wavadj_rec.credit_id,
              p_invoice_id            => waiver_adj_charges_rec.invoice_id,
              p_amount_apply          => l_n_amount_apply,
              p_appl_type             => g_v_app,
              p_appl_hierarchy_id     => NULL,
              p_validation            => 'Y',
              p_dr_gl_ccid            => l_n_dr_gl_ccid,
              p_cr_gl_ccid            => l_n_cr_gl_ccid,
              p_dr_account_cd         => l_v_dr_acc_cd,
              p_cr_account_cd         => l_v_cr_acc_cd,
              p_unapp_amount          => l_n_unapp_amount,
              p_inv_amt_due           => l_n_inv_amt_due,
              p_err_msg               => l_v_err_msg,
              p_status                => l_b_status,
              p_d_gl_date             => p_d_gl_date);

            IF l_b_status THEN
              log_to_fnd(p_v_module => 'process_due_wavadj_charges',
                         p_v_string => 'Application record created. Application ID= '||l_n_app_id);

              -- Deduct the Invoice Amount to the extent applied (l_n_amount_apply)
              l_n_invoice_amount := l_n_invoice_amount - l_n_amount_apply;
              IF l_n_invoice_amount = 0 THEN
                EXIT fullapplied_wavcr_loop;
              END IF;

            ELSE
              -- Log the message and return to the calling Procedure
              log_to_fnd(p_v_module => 'process_due_wavadj_charges',
                         p_v_string => 'Error: '||fnd_message.get_string('IGS', l_v_err_msg));
              -- Return Error Status
              x_return_status := 'E';
              RETURN;

            END IF;

          END LOOP;

        END LOOP fullapplied_wavcr_loop;

      END IF; -- End of Invoice Amount > 0 check

    END LOOP;

  EXCEPTION

    WHEN OTHERS THEN
      -- Log the SQLERRM message
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igs.plsql.igs_fi_wav_utils_001.process_due_wavadj_charges.exception','sqlerrm ' || SQLERRM);
      END IF;

      -- Return the Error Status
      x_return_status := 'E';

  END process_due_wavadj_charges;

  PROCEDURE log_to_fnd (p_v_module IN VARCHAR2,
                        p_v_string IN VARCHAR2) IS
  /******************************************************************
   Created By      :  Anji Yedubati
   Date Created By :  21-JUL-2005
   Purpose         :  Procedure to log messages for Statement Level logging
   Known limitations,enhancements,remarks:

   Change History  :
   WHO     WHEN       WHAT
  ***************************************************************** */

  BEGIN

    -- If current Logging Level is less than or equal to Statement Level, then log the message
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_fi_wav_utils_001.'||p_v_module, p_v_string);
    END IF;

  END log_to_fnd;


  PROCEDURE create_ss_waiver_transactions(
    p_n_person_id          IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type       IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number  IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name        IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_target_fee_type    IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_v_adj_fee_type       IN  igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_n_credit_type_id     IN  igs_fi_waiver_pgms.credit_type_id%TYPE,
    p_v_waiver_method_code IN  igs_fi_waiver_pgms.waiver_method_code%TYPE,
    p_v_waiver_mode_code   IN  igs_fi_waiver_pgms.waiver_mode_code%TYPE,
    p_n_source_invoice_id  IN  igs_fi_inv_int_all.invoice_id%TYPE,
    p_n_waiver_amount      IN  igs_fi_credits_all.amount%TYPE,
    p_v_currency_cd        IN  igs_fi_inv_int_all.currency_cd%TYPE,
    p_d_gl_date            IN  igs_fi_invln_int_all.gl_date%TYPE,
    x_return_status        OUT NOCOPY VARCHAR2) IS
  /******************************************************************
   Created By      :  Priya Athipatla
   Date Created By :  16-Aug-2005
   Purpose         :  Wrapper procedure invoked from SS to create waiver
                      transacations.
   Known limitations,enhancements,remarks:

   Change History  :
   WHO         WHEN         WHAT
  ***************************************************************** */

  -- Cursor to fetch the value of waiver_notify_finaid_flag from igs_fi_control_all
  CURSOR cur_notify_flag IS
    SELECT waiver_notify_finaid_flag
    FROM igs_fi_control_all;

  -- Local variables
  l_n_credit_id       igs_fi_credits_all.credit_id%TYPE;
  l_v_return_status   VARCHAR2(1);
  l_v_notify_fa_flag  igs_fi_control_all.waiver_notify_finaid_flag%TYPE;

  BEGIN

     l_v_return_status := 'S';

     log_to_fnd(p_v_module => 'create_ss_waiver_transactions',
                p_v_string => ' Invoking igs_fi_wav_utils_002.call_credits_api for given Person, Waiver and Fee Period');

     -- Invoke Credits API for the parameters in the context
     igs_fi_wav_utils_002.call_credits_api(p_n_person_id         =>   p_n_person_id,
                                           p_v_fee_cal_type      =>   p_v_fee_cal_type,
                                           p_n_fee_ci_seq_number =>   p_n_fee_ci_seq_number,
                                           p_v_waiver_name       =>   p_v_waiver_name,
                                           p_n_credit_type_id    =>   p_n_credit_type_id,
                                           p_v_currency_cd       =>   p_v_currency_cd,
                                           p_n_waiver_amt        =>   p_n_waiver_amount,
                                           p_d_gl_date           =>   p_d_gl_date,
                                           p_n_credit_id         =>   l_n_credit_id,
                                           x_return_status       =>   l_v_return_status);
     -- If the above call returns E, then rollback and return from the procedure
     IF (l_v_return_status = 'E') THEN
         log_to_fnd(p_v_module => 'create_ss_waiver_transactions',
                    p_v_string => ' Error: Error from igs_fi_wav_utils_002.call_credits_api, returning E after rollback');
         ROLLBACK;
         x_return_status := 'E';
         RETURN;
     END IF;

     log_to_fnd(p_v_module => 'create_ss_waiver_transactions',
                p_v_string => ' Invoking igs_fi_wav_utils_001.apply_waivers for given Person, Waiver and Fee Period');

     -- Invoke procedure to Apply the Waivers.
     igs_fi_wav_utils_001.apply_waivers(p_n_person_id            => p_n_person_id,
                                        p_v_fee_cal_type         => p_v_fee_cal_type,
                                        p_n_fee_ci_seq_number    => p_n_fee_ci_seq_number,
                                        p_v_waiver_name          => p_v_waiver_name,
                                        p_v_target_fee_type      => p_v_target_fee_type,
                                        p_v_adj_fee_type         => p_v_adj_fee_type,
                                        p_v_waiver_method_code   => p_v_waiver_method_code,
                                        p_v_waiver_mode_code     => p_v_waiver_mode_code,
                                        p_n_source_credit_id     => l_n_credit_id,
                                        p_n_source_invoice_id    => p_n_source_invoice_id,
                                        p_v_currency_cd          => p_v_currency_cd,
                                        p_d_gl_date              => p_d_gl_date,
                                        x_return_status          => l_v_return_status);
     -- If the above call returns E, then rollback and return from the procedure
     IF (l_v_return_status = 'E') THEN
         log_to_fnd(p_v_module => 'create_ss_waiver_transactions',
                    p_v_string => ' Error: Error from igs_fi_wav_utils_001.apply_waivers, returning E after rollback');
         ROLLBACK;
         x_return_status := 'E';
         RETURN;
     END IF;

     -- Fetch the value of 'Generate Notification to Financial Aid' (WAIVER_NOTIFY_FINAID_FLAG in IGS_FI_CONTROL_ALL)
     -- If this value is 'Y', then invoke procedure to raise a Workflow event
     OPEN cur_notify_flag;
     FETCH cur_notify_flag INTO l_v_notify_fa_flag;
     IF (cur_notify_flag%NOTFOUND) THEN
         -- If no data was found in IGS_FI_CONTROL_ALL, rollback and return E
         log_to_fnd(p_v_module => 'create_ss_waiver_transactions',
                    p_v_string => ' Error: Error in fetching WAIVER_NOTIFY_FINAID_FLAG from IGS_FI_CONTROL_ALL, returning E after rollback');
         CLOSE cur_notify_flag;
         ROLLBACK;
         x_return_status := 'E';
         RETURN;
     END IF;
     CLOSE cur_notify_flag;

     log_to_fnd(p_v_module => 'create_ss_waiver_transactions',
                p_v_string => ' Fetched WAIVER_NOTIFY_FINAID_FLAG from IGS_FI_CONTROL_ALL, Value is: '||l_v_notify_fa_flag);

     -- If 'Generate Notification to Financial Aid' is Yes, raise Workflow Event.
     IF NVL(l_v_notify_fa_flag,'N') = 'Y' THEN
         log_to_fnd(p_v_module => 'create_ss_waiver_transactions',
                    p_v_string => ' Invoking igs_fi_wav_dtls_wf.raise_wavtrandtlstofa_event for given Person, Waiver and Fee Period');
         -- Invoke procedure to raise WF event
         igs_fi_wav_dtls_wf.raise_wavtrandtlstofa_event(p_n_person_id	       => p_n_person_id,
                                                        p_v_waiver_name	       => p_v_waiver_name,
                                                        p_c_fee_cal_type       => p_v_fee_cal_type,
                                                        p_n_fee_ci_seq_number  => p_n_fee_ci_seq_number,
                                                        p_n_waiver_amount      => p_n_waiver_amount);
     END IF;

  EXCEPTION
     WHEN OTHERS THEN
        -- Log the SQLERRM message
        log_to_fnd(p_v_module => 'create_ss_waiver_transactions.exception',
                   p_v_string => ' Error: Unhandled Exception, returning E after rollback. SQLERRM: '||SQLERRM);
        ROLLBACK;
        -- Return the Error Status
        x_return_status := 'E';

  END create_ss_waiver_transactions;

END igs_fi_wav_utils_001;

/
