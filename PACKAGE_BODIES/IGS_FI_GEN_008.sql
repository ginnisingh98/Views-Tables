--------------------------------------------------------
--  DDL for Package Body IGS_FI_GEN_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GEN_008" AS
/* $Header: IGSFI88B.pls 120.5 2006/05/16 22:58:36 abshriva ship $ */

/***********************************************************************************************
  Created By     : shtatiko
  Date Created By: 25-AUG-2003 ( Created as part of Enh# 3045007 )
  Purpose        : This package contains number of generic procedures called from various places
                   for Payment Plans Funtionality.

  Known limitations,enhancements,remarks:
  Change History
  Who           When            What
  abshriva      17-May-2006     Bug 5113295 - Added function chk_unit_prg_transfer
  uudayapr      8-Oct-2005      BUG 4660773 Added the Function mask_card_number for masking the CC Number
  agairola      27-Sep-2005     Bug # 4625955 Added new PLSQL procedure chk_spa_rec_exists
  svuppala      16-May-2005     Bug # 4226849 Added New PLSQL function which will return the latest standard
                                balance of the student for the personid provided as input to it.
  bannamal      14-Apr-2005     Bug#4297359 ER Registration fee issue.
                                 Modified the function get_complete_withdr_ret_amt. Added the parameter p_v_nonzero_billable_cp_flag.
                                 Modified the where clause of the cursor cur_unit_attmpt.
                                Bug#4304524 Registration Fee Retention not working for the first date of Retention.
                                 Modified the cursor cur_tp_ret
  pathipat      03-Sep-2004     Enh 3880438 - Retention Enhancements
                                Added new functions.
  rmaddipa      26-Jul-2004      Enh#3787816  Added  chk_chg_adj as part of Manual Reversal Build
  uudayapr       20-oct-2003     Enh#3117341 Added get_invoice_number fuction as a part of
                                audit and special Fees Build.
  shtatiko      25-AUG-2003     Enh# 3045007, Created this package.
********************************************************************************************** */

  g_v_opt_fee_decl CONSTANT  VARCHAR2(1) := 'D';
  g_v_waiver_yes   CONSTANT  VARCHAR2(1) := 'Y';

  PROCEDURE get_plan_details( p_n_person_id IN NUMBER,           /* Person Id */
                              p_n_act_plan_id OUT NOCOPY NUMBER,        /* Active Payment Plan Id */
                              p_v_act_plan_name OUT NOCOPY VARCHAR2     /* Active Payment Plan Name */
                            ) IS
  /***********************************************************************************************
    Created By     :  Shtatiko
    Date Created By:  25-AUG-2003 ( Created as part of Enh# 3045007 )
    Purpose        :  Procedure to get Payment Plan Details

    Known limitations,enhancements,remarks:
    Change History
    Who         When            What
  ***********************************************************************************************/
  CURSOR cur_plan_details( cp_n_person_id NUMBER ) IS
    SELECT student_plan_id,
           payment_plan_name
    FROM igs_fi_pp_std_attrs
    WHERE person_id = p_n_person_id
    AND plan_status_code = 'ACTIVE';
  rec_plan_details cur_plan_details%ROWTYPE;

  BEGIN

    OPEN cur_plan_details ( p_n_person_id );
    FETCH cur_plan_details INTO rec_plan_details;
    IF cur_plan_details%NOTFOUND THEN
      p_n_act_plan_id := NULL;
      p_v_act_plan_name := NULL;
    ELSE
      p_n_act_plan_id := rec_plan_details.student_plan_id;
      p_v_act_plan_name := rec_plan_details.payment_plan_name;
    END IF;
    CLOSE cur_plan_details;

  END get_plan_details;

  FUNCTION get_plan_balance( p_n_act_plan_id IN NUMBER,         /* Active Payment Plan Id */
                             p_d_effective_date IN DATE         /* Effective Date */
                           ) RETURN NUMBER IS
  /***********************************************************************************************
    Created By     :  Shtatiko
    Date Created By:  25-AUG-2003 ( Created as part of Enh# 3045007 )
    Purpose        :  Fuction to get Balance Amount for a given Payment Plan as of given date.

    Known limitations,enhancements,remarks:
    Change History
    Who         When            What
  ***********************************************************************************************/
  CURSOR cur_plan_balance ( cp_n_act_plan_id NUMBER, cp_d_effective_date DATE ) IS
    SELECT SUM(due_amt)
    FROM igs_fi_pp_instlmnts
    WHERE student_plan_id = cp_n_act_plan_id
    AND ((TRUNC(due_date) <= TRUNC(cp_d_effective_date)) OR (cp_d_effective_date IS NULL));
  l_n_balance_amount igs_fi_pp_instlmnts.due_amt%TYPE;

  BEGIN

    OPEN cur_plan_balance ( p_n_act_plan_id, p_d_effective_date );
    FETCH cur_plan_balance INTO l_n_balance_amount;
    CLOSE cur_plan_balance;

    RETURN NVL(l_n_balance_amount, 0);

  END get_plan_balance;

  FUNCTION chk_active_pay_plan( p_n_person_id IN NUMBER ) RETURN VARCHAR2 IS
  /***********************************************************************************************
    Created By     :  Shtatiko
    Date Created By:  25-AUG-2003 ( Created as part of Enh# 3045007 )
    Purpose        :  Fucntion to check whether a give Payment Plan is active or not.

    Known limitations,enhancements,remarks:
    Change History
    Who         When            What
  ***********************************************************************************************/
  l_n_act_plan_id   igs_fi_pp_std_attrs.student_plan_id%TYPE;
  l_v_act_plan_name igs_fi_pp_std_attrs.payment_plan_name%TYPE;

  BEGIN

    get_plan_details ( p_n_person_id, l_n_act_plan_id, l_v_act_plan_name );
    IF l_n_act_plan_id IS NULL THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;

  END chk_active_pay_plan;

  FUNCTION get_start_date ( p_d_start_date IN DATE,
                            p_n_due_day IN NUMBER,
                            p_v_last_day IN VARCHAR2,
                            p_n_offset_days IN NUMBER
                          ) RETURN DATE IS
  /***********************************************************************************************
    Created By     :  Shtatiko
    Date Created By:  25-AUG-2003 ( Created as part of Enh# 3045007 )
    Purpose        :  Function to get First Installment Date

    Known limitations,enhancements,remarks:
    Change History
    Who         When            What
  ***********************************************************************************************/

  l_d_ret_start_date DATE;
  l_v_date VARCHAR2(12);
  BEGIN
    -- The first installment must not come due if it is within the given number of days (Offset Days)
    -- past the Start Date as specified by the parameters.
    -- This is to prevent an installment from coming too soon after the Payment Plan start date.

    IF ( p_n_due_day IS NULL AND p_v_last_day = 'N')
       OR ( p_n_due_day IS NOT NULL AND p_v_last_day = 'Y' ) THEN
      RETURN NULL;
    END IF;

    -- First Installment date should not be within offset days of Given Start Date.
    l_d_ret_start_date := p_d_start_date + NVL(p_n_offset_days, 0);

    IF p_n_due_day IS NOT NULL THEN
      IF TO_CHAR(l_d_ret_start_date, 'DD') >= p_n_due_day THEN
        l_d_ret_start_date := ADD_MONTHS(l_d_ret_start_date, 1);
      END IF;
      l_v_date := TO_CHAR(p_n_due_day) || '-' || TO_CHAR(l_d_ret_start_date, 'MON-YYYY') ;
      l_d_ret_start_date := fnd_date.string_to_date( l_v_date, 'DD-MON-YYYY' );
    ELSE
      l_d_ret_start_date := LAST_DAY(l_d_ret_start_date);
    END IF;

    RETURN l_d_ret_start_date;

  END get_start_date;

  FUNCTION get_party_number ( p_n_party_id IN NUMBER ) RETURN VARCHAR2 IS
  /***********************************************************************************************
    Created By     :  Shtatiko
    Date Created By:  25-AUG-2003 ( Created as part of Enh# 3045007 )
    Purpose        :  Function that return Party Number for a given Party Id

    Known limitations,enhancements,remarks:
    Change History
    Who         When            What
  ***********************************************************************************************/
  CURSOR cur_party_number(cp_n_party_id NUMBER) IS
    SELECT party_number
    FROM   hz_parties
    WHERE  party_id = cp_n_party_id;
  l_v_party_number hz_parties.party_number%TYPE;

  BEGIN

    IF p_n_party_id IS NULL THEN
      RETURN NULL;
    END IF;

    OPEN cur_party_number(p_n_party_id);
    FETCH cur_party_number INTO l_v_party_number;
    IF cur_party_number%NOTFOUND THEN
      l_v_party_number := NULL;
    END IF;
    CLOSE cur_party_number;
    RETURN l_v_party_number;

  END get_party_number;


   FUNCTION get_invoice_number ( p_n_invoice_id IN PLS_INTEGER ) RETURN VARCHAR2 IS
  /***********************************************************************************************
    Created By     :  UUDAYAPR
    Date Created By:  20-OCT-2003 ( Created as part of Enh# 3117341 )
    Purpose        :  Function That Return Charge Number For A Given Invoice Id

    Known limitations,enhancements,remarks:
    Change History
    Who         When            What
  ***********************************************************************************************/

  CURSOR cur_charge_number(cp_v_invoice_id igs_fi_inv_int.invoice_id%TYPE) IS
   SELECT invoice_number
   FROM igs_fi_inv_int
   WHERE invoice_id = cp_v_invoice_id;

   l_v_invoice_number cur_charge_number%ROWTYPE;
  BEGIN
    IF p_n_invoice_id IS NULL THEN
      RETURN null;
    ELSE
      OPEN cur_charge_number(p_n_invoice_id);
      FETCH cur_charge_number INTO l_v_invoice_number;
            IF cur_charge_number%NOTFOUND THEN
              CLOSE cur_charge_number;
        RETURN null;
      ELSE
        CLOSE cur_charge_number;
        RETURN l_v_invoice_number.invoice_number;
      END IF;
    END IF;
  END get_invoice_number;



  PROCEDURE chk_chg_adj( p_n_person_id     IN  hz_parties.party_id%TYPE,
                         p_v_location_cd   IN  igs_fi_fee_as_items.location_cd%TYPE,
                         p_v_course_cd     IN  igs_ps_ver.course_cd%TYPE,
                         p_v_fee_cal_type  IN  igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                         p_v_fee_cat       IN  igs_fi_fee_as_items.fee_cat%TYPE,
                         p_n_fee_ci_sequence_number IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                         p_v_fee_type      IN  igs_fi_fee_type.fee_type%TYPE,
                         p_n_uoo_id        IN  igs_ps_unit_ofr_opt.uoo_id%TYPE,
                         p_v_transaction_type IN igs_fi_inv_int_all.transaction_type%TYPE,
                         p_n_invoice_id    IN  igs_fi_inv_int_all.invoice_id%TYPE,
                         p_v_invoice_num   OUT NOCOPY igs_fi_inv_int_all.invoice_number%TYPE,
                         p_b_chg_decl_rev  OUT NOCOPY BOOLEAN
                        ) IS

/***********************************************************************************************
    Created By     :  RMADDIPA
    Date Created By:  26-Jul-04 ( Created as part of Enh# 3787816 )
    Purpose        :  Procedure that checks if a particular charge has been reversed or declined

    Known limitations,enhancements,remarks:
    Change History
    Who         When            What
  ***********************************************************************************************/
  --cursor to check whether the charge with given invoice id has already been reversed or declined
  CURSOR cur_chk_rev_decl(cp_invoice_id igs_fi_inv_int_all.invoice_id%TYPE) IS
      SELECT inv.invoice_number
      FROM igs_fi_inv_int inv
      WHERE inv.invoice_id=cp_invoice_id
      AND   (inv.optional_fee_flag = g_v_opt_fee_decl OR inv.waiver_flag = g_v_waiver_yes);

  --cursor to check whether a particular charge has been reversed or declined
  CURSOR cur_chk_rev_decl_no_inv_id(
                  cp_person_id    hz_parties.party_id%TYPE,
                  cp_location_cd  igs_fi_fee_as_items.location_cd%TYPE,
                  cp_course_cd    igs_ps_ver.course_cd%TYPE,
                  cp_fee_cal_type igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                  cp_fee_cat      igs_fi_fee_as_items.fee_cat%TYPE,
                  cp_fee_ci_sequence_number igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                  cp_fee_type     igs_fi_fee_type.fee_type%TYPE,
                  cp_uoo_id       igs_ps_unit_ofr_opt.uoo_id%TYPE,
                  cp_transaction_type igs_fi_inv_int_all.transaction_type%TYPE) IS
      SELECT inv.invoice_number
      FROM igs_fi_inv_int inv,
           igs_fi_invln_int invln
      WHERE inv.person_id=cp_person_id
      AND   invln.invoice_id=inv.invoice_id
      AND   inv.fee_cal_type=cp_fee_cal_type
      AND   (inv.fee_cat = cp_fee_cat OR (inv.fee_cat IS NULL AND cp_fee_cat IS NULL))
      AND   inv.fee_type = cp_fee_type
      AND   inv.fee_ci_sequence_number = cp_fee_ci_sequence_number
      AND   (inv.course_cd=cp_course_cd OR (inv.course_cd IS NULL AND cp_course_cd IS NULL))
      AND   (invln.location_cd = cp_location_cd OR (invln.location_cd IS NULL AND cp_location_cd IS NULL))
      AND   NVL(invln.uoo_id,0) = NVL(cp_uoo_id,0)
      AND   inv.transaction_type = cp_transaction_type
      AND   (inv.optional_fee_flag = g_v_opt_fee_decl OR inv.waiver_flag = g_v_waiver_yes);

  BEGIN

     IF (p_n_invoice_id IS NOT NULL) THEN
         -- If the invoice id is known check whether the charge corresponding to the invoice id is reversed or declined
         OPEN cur_chk_rev_decl(p_n_invoice_id);
         FETCH cur_chk_rev_decl INTO p_v_invoice_num;

         IF (cur_chk_rev_decl%NOTFOUND) THEN
             -- if charge is not reversed or declined return false
             p_b_chg_decl_rev := FALSE;
             p_v_invoice_num  := NULL;
         ELSE
             -- if charge has already been declined pass back the invoice number
             p_b_chg_decl_rev := TRUE;
         END IF;

         CLOSE cur_chk_rev_decl;

         RETURN;
     ELSE
         -- If invoice id is not known check whether the charge corresponding
         --   to the context of person and other details is reversed or declined
         OPEN cur_chk_rev_decl_no_inv_id( p_n_person_id,
                                          p_v_location_cd,
                                          p_v_course_cd,
                                          p_v_fee_cal_type,
                                          p_v_fee_cat,
                                          p_n_fee_ci_sequence_number,
                                          p_v_fee_type,
                                          p_n_uoo_id,
                                          p_v_transaction_type);
         FETCH cur_chk_rev_decl_no_inv_id INTO p_v_invoice_num;

         IF (cur_chk_rev_decl_no_inv_id%NOTFOUND) THEN
             -- if charge is not reversed or declined return false
             p_b_chg_decl_rev := FALSE;
             p_v_invoice_num  := NULL;
         ELSE
             -- if charge has already been declined pass back the invoice number
             p_b_chg_decl_rev := TRUE;
         END IF;

         CLOSE cur_chk_rev_decl_no_inv_id;

         RETURN;
     END IF;

  END chk_chg_adj;


  PROCEDURE get_retention_params( p_v_fee_cal_type            IN igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                                  p_n_fee_ci_sequence_number  IN igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE,
                                  p_v_fee_type                IN igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                                  p_v_ret_level               OUT NOCOPY igs_fi_f_typ_ca_inst_all.retention_level_code%TYPE,
                                  p_v_complete_withdr_ret     OUT NOCOPY igs_fi_f_typ_ca_inst_all.complete_ret_flag%TYPE) AS
  /**************************************************************************
    Created By     :  Priya Athipatla
    Date Created By:  03-Sep-2004
    Purpose        :  Procedure to obtain values of columns retention_level_code
                      and complete_ret_flag from table igs_fi_f_typ_ca_inst to
                      be used in determing Retention Amount.
    Known limitations,enhancements,remarks:

    Change History
    Who         When            What
   **************************************************************************/

   CURSOR cur_get_ret_params(cp_v_fee_type              igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                             cp_v_fee_cal_type          igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                             cp_n_fee_ci_sequence_num   igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE) IS
     SELECT retention_level_code,
            NVL(complete_ret_flag,'N')
     FROM  igs_fi_f_typ_ca_inst
     WHERE fee_type               = cp_v_fee_type
     AND   fee_cal_type           = cp_v_fee_cal_type
     AND   fee_ci_sequence_number = cp_n_fee_ci_sequence_num;

  BEGIN

     p_v_ret_level := NULL;
     p_v_complete_withdr_ret := NULL;

     -- Fetch values of retention_level_code and complete_ret_flag from the table
     OPEN cur_get_ret_params(p_v_fee_type, p_v_fee_cal_type, p_n_fee_ci_sequence_number);
     FETCH cur_get_ret_params INTO p_v_ret_level, p_v_complete_withdr_ret;
     CLOSE cur_get_ret_params;

     IF (p_v_ret_level IS NULL AND p_v_complete_withdr_ret = 'N') THEN
        p_v_ret_level := 'FEE_PERIOD';
     END IF;

  END get_retention_params;


  FUNCTION get_teach_retention( p_v_fee_cal_type             IN igs_fi_tp_ret_schd.fee_cal_type%TYPE,
                                p_n_fee_ci_sequence_number   IN igs_fi_tp_ret_schd.fee_ci_sequence_number%TYPE,
                                p_v_fee_type                 IN igs_fi_tp_ret_schd.fee_type%TYPE,
                                p_v_teach_cal_type           IN igs_fi_tp_ret_schd.teach_cal_type%TYPE,
                                p_n_teach_ci_sequence_number IN igs_fi_tp_ret_schd.teach_ci_sequence_number%TYPE,
                                p_d_effective_date           IN DATE,
                                p_n_diff_amount              IN NUMBER) RETURN NUMBER IS
  /**************************************************************************
    Created By     :  Priya Athipatla
    Date Created By:  03-Sep-2004
    Purpose        :  Function to determine the Retention Amount when the
                      Retention Level at FTCI is set to Teaching Period
    Known limitations,enhancements,remarks:

    Change History
    Who         When            What
   **************************************************************************/

   -- Cursor to fetch Retention Schedules defined at Teaching Period level and
   -- overridden at the FTCI level.
   CURSOR cur_tp_ovrd_ret(cp_v_fee_type              igs_fi_tp_ret_schd.fee_type%TYPE,
                          cp_v_fee_cal_type          igs_fi_tp_ret_schd.fee_cal_type%TYPE,
                          cp_n_fee_ci_sequence_num   igs_fi_tp_ret_schd.fee_ci_sequence_number%TYPE,
                          cp_v_teach_cal_type        igs_fi_tp_ret_schd.teach_cal_type%TYPE,
                          cp_n_teach_ci_seq_num      igs_fi_tp_ret_schd.teach_ci_sequence_number%TYPE) IS
     SELECT *
     FROM igs_fi_tp_ret_schd_v
     WHERE teach_cal_type = cp_v_teach_cal_type
     AND teach_ci_sequence_number =  cp_n_teach_ci_seq_num
     AND fee_cal_type = cp_v_fee_cal_type
     AND fee_ci_sequence_number = cp_n_fee_ci_sequence_num
     AND fee_type = cp_v_fee_type
     ORDER BY dai_alias_val;

  -- Cursor to fetch Retention Schedules defined at Teaching Period level
  CURSOR cur_tp_ret(cp_v_teach_cal_type    igs_fi_tp_ret_schd.teach_cal_type%TYPE,
                    cp_n_teach_ci_seq_num  igs_fi_tp_ret_schd.teach_ci_sequence_number%TYPE) IS
    SELECT *
    FROM igs_fi_tp_ret_schd_v
    WHERE teach_cal_type = cp_v_teach_cal_type
    AND teach_ci_sequence_number = cp_n_teach_ci_seq_num
    AND fee_type IS NULL
    AND fee_cal_type IS NULL
    AND fee_ci_sequence_number IS NULL
    ORDER BY dai_alias_val;

  l_n_ret_amount       igs_fi_tp_ret_schd.ret_amount%TYPE := 0;
  l_n_ret_percent      igs_fi_tp_ret_schd.ret_percentage%TYPE := 0;

  -- Flag to indicate whether or not overridden retention schedules were found
  l_b_override_ret     BOOLEAN := FALSE;

  -- Retention Amount calculated
  l_n_amount           NUMBER := 0.0;

  BEGIN
      -- If the Difference Amount is zero, then no Retention is applicable, return 0
      IF (NVL(p_n_diff_amount,0) = 0) THEN
         RETURN 0;
      END IF;

      -- Determine if the Teaching Period Retention Schedules have been overridden at the FTCI level
      -- Use the schedules overridden at FTCI level to calculate the retention amount.
      FOR rec_tp_ovrd_ret IN cur_tp_ovrd_ret(p_v_fee_type, p_v_fee_cal_type, p_n_fee_ci_sequence_number,
                                             p_v_teach_cal_type, p_n_teach_ci_sequence_number)
      LOOP
         l_b_override_ret := TRUE;
         -- Compare the Effective Date parameter against each of the Date Alias values fetched
         IF TRUNC(rec_tp_ovrd_ret.dai_alias_val) <= TRUNC(p_d_effective_date) THEN

            l_n_ret_percent := rec_tp_ovrd_ret.ret_percentage;
            l_n_ret_amount  := rec_tp_ovrd_ret.ret_amount;
         ELSE
            -- If the Effective Date falls before the Date Alias value, then exit loop
            EXIT;
         END IF;
      END LOOP;

      -- If the Retention Schedules were not overridden at the FTCI level, then fetch the schedules from
      -- the Teaching Period level and calculate the retention amount.
      IF NOT l_b_override_ret THEN
         FOR rec_tp_ret IN cur_tp_ret(p_v_teach_cal_type, p_n_teach_ci_sequence_number)
         LOOP
            -- Compare the Effective Date parameter against each of the Date Alias values fetched
            IF TRUNC(rec_tp_ret.dai_alias_val) <= TRUNC(p_d_effective_date) THEN
               l_n_ret_percent := rec_tp_ret.ret_percentage;
               l_n_ret_amount  := rec_tp_ret.ret_amount;
            ELSE
               -- If the Effective Date falls before the Date Alias value, then exit loop
               EXIT;
            END IF;
         END LOOP;
      END IF;

      IF l_n_ret_amount IS NOT NULL THEN
          l_n_amount := l_n_ret_amount;
      ELSIF l_n_ret_percent IS NOT NULL THEN
          l_n_amount := ABS(p_n_diff_amount) * (l_n_ret_percent/100);
      END IF;

      RETURN l_n_amount;

  END get_teach_retention;


  FUNCTION get_fee_retention_amount(p_v_fee_cat                IN igs_fi_fee_ret_schd.fee_cat%TYPE,
                                    p_v_fee_cal_type           IN igs_fi_fee_ret_schd.fee_cal_type%TYPE,
                                    p_n_fee_ci_sequence_number IN igs_fi_fee_ret_schd.fee_ci_sequence_number%TYPE,
                                    p_v_fee_type               IN igs_fi_fee_ret_schd.fee_type%TYPE,
                                    p_n_diff_amount            IN NUMBER) RETURN NUMBER IS
  /**************************************************************************
    Created By     :  Priya Athipatla
    Date Created By:  03-Sep-2004
    Purpose        :  Function to determine Retention Amount when Retention Level
                      is set to Fee Period
    Known limitations,enhancements,remarks:

    Change History
    Who         When            What
   **************************************************************************/

   -- Select retention records for the specified FTCI and Fee Cat
   -- This cursor will be used for non-Special Fee Types
   CURSOR cur_fee_ret(cp_v_fee_type        igs_fi_fee_ret_schd.fee_type%TYPE,
                      cp_v_fee_cal_type    igs_fi_fee_ret_schd.fee_cal_type%TYPE,
                      cp_n_fee_ci_seq_num  igs_fi_fee_ret_schd.fee_ci_sequence_number%TYPE,
                      cp_v_fee_cat         igs_fi_fee_ret_schd.fee_cat%TYPE) IS
     SELECT retention_percentage,
            retention_amount
     FROM igs_fi_fee_ret_schd_f_type_v
     WHERE fee_type             = cp_v_fee_type
     AND fee_cal_type           = cp_v_fee_cal_type
     AND fee_ci_sequence_number = cp_n_fee_ci_seq_num
     AND ( (fee_cat = cp_v_fee_cat) OR (fee_cat IS NULL) )
     AND ( (TRUNC(SYSDATE) >= TRUNC(start_dt)) OR (start_dt IS NULL) )
     AND ( (TRUNC(SYSDATE) <= TRUNC(end_dt)) OR (end_dt IS NULL) )
     ORDER BY start_dt;

   -- Cursor to select retention records for Special Fee Types
   CURSOR cur_ret_special(cp_v_fee_type               igs_fi_fee_type.fee_type%TYPE,
                          cp_v_fee_cal_type           igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                          cp_n_fee_ci_sequence_number igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                          cp_v_relation_ftci          VARCHAR2) IS
     SELECT retention_percentage,
            retention_amount
     FROM  igs_fi_fee_ret_schd_v
     WHERE fee_type               = cp_v_fee_type
     AND   fee_cal_type           = cp_v_fee_cal_type
     AND   fee_ci_sequence_number = cp_n_fee_ci_sequence_number
     AND   s_relation_type        = cp_v_relation_ftci
     AND   ( (TRUNC(SYSDATE) >= TRUNC(start_dt)) OR start_dt IS NULL)
     AND   ( (TRUNC(SYSDATE) <= TRUNC(end_dt)) OR end_dt IS NULL)
     ORDER BY start_dt;

   -- To determine System Fee Type of input Fee Type
   CURSOR cur_fee_type(cp_v_fee_type    igs_fi_fee_type.fee_type%TYPE) IS
     SELECT s_fee_type
     FROM igs_fi_fee_type
     WHERE fee_type = cp_v_fee_type;

   l_v_s_fee_type       igs_fi_fee_type.s_fee_type%TYPE := NULL;

   l_n_ret_amount       igs_fi_fee_ret_schd.retention_amount%TYPE := 0.0;
   l_n_ret_percent      igs_fi_fee_ret_schd.retention_percentage%TYPE := 0.0;

   -- Retention Amount calculated
   l_n_amount           NUMBER := 0.0;

  BEGIN

      -- If the Difference Amount is zero, then no Retention is applicable, return 0
      IF (NVL(p_n_diff_amount,0) = 0) THEN
         RETURN 0;
      END IF;

      -- Determine System Fee Type
      OPEN cur_fee_type(p_v_fee_type);
      FETCH cur_fee_type INTO l_v_s_fee_type;
      CLOSE cur_fee_type;

      IF l_v_s_fee_type = 'SPECIAL' THEN
         -- For Special Fees, obtain the Retention Schedules
         OPEN cur_ret_special(p_v_fee_type,
                              p_v_fee_cal_type,
                              p_n_fee_ci_sequence_number,
                              'FTCI');
         FETCH cur_ret_special INTO l_n_ret_percent, l_n_ret_amount;
         CLOSE cur_ret_special;
      ELSE
         -- For all other System Fee Types, obtain the Retention Schedules
         OPEN cur_fee_ret(p_v_fee_type,
                          p_v_fee_cal_type,
                          p_n_fee_ci_sequence_number,
                          p_v_fee_cat);
         FETCH cur_fee_ret INTO l_n_ret_percent, l_n_ret_amount;
         CLOSE cur_fee_ret;
      END IF;

      IF l_n_ret_amount IS NOT NULL THEN
          l_n_amount := l_n_ret_amount;
      ELSIF l_n_ret_percent IS NOT NULL THEN
          l_n_amount := ABS(p_n_diff_amount) * (l_n_ret_percent/100);
      END IF;

      RETURN l_n_amount;

  END get_fee_retention_amount;


  FUNCTION get_complete_withdr_ret_amt( p_n_person_id                IN igs_en_su_attempt.person_id%TYPE,
                                        p_v_course_cd                IN igs_en_su_attempt.course_cd%TYPE,
                                        p_v_load_cal_type            IN igs_ca_inst.cal_type%TYPE,
                                        p_n_load_ci_sequence_number  IN igs_ca_inst.sequence_number%TYPE,
                                        p_n_diff_amount              IN NUMBER,
                                        p_v_fee_type                 IN igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                                        p_v_nonzero_billable_cp_flag  IN igs_fi_f_typ_ca_inst_all.nonzero_billable_cp_flag%TYPE ) RETURN NUMBER IS
  /**************************************************************************
    Created By     :  Priya Athipatla
    Date Created By:  03-Sep-2004
    Purpose        :  Function to determine the Retention Amount when the
                      Complete Withdrawal Retention checkbox is checked.

    Process Flow:
    1. If Diff Amount = 0, Return 0;
    2. For each Unit Attempt of the student, verify if the Usec still incurs load.
       2.1  If even one Unit Section incurs load, then no Retention is applicable.
       2.2  If none of the Unit Sections incur load, then verify if all the
            Unit sections were dropped in the 0% Retention Period.
            ( Discontinued Date < Date Alias of the Earliest Retention Schedule)
            2.2.1  If Usec is Non-Standard, compare against schedules defined at
                   NS Unit Section level, not from Teaching Period schedules
                   2.2.1.1  Usec + Fee Type level OR  Usec level OR  Institution level
            2.2.2  If Standard Usec,
                   2.2.2.1  If the Usec were dropped in the 0% Retention Period, then no
                            Retention is applicable. Return 0.
                   2.2.2.2  If the Usec were NOT dropped in the 0% Retention Period, then
                            set local flag (l_b_zero_ret_drop) to TRUE. Apply 100% Retention.

    Known limitations,enhancements,remarks:

    Change History
    Who         When            What
    abshriva    17-May-2006     Bug 5113295 - Added call out to function chk_unit_prg_transfer in cur_unit_attmpt
    bannamal   14-Apr-2005     Bug#4297359 ER Registration fee issue.
                                Added one more paramter in the function, p_v_nonzero_billable_cp_flag.
                                Modified the where clause of the cursor cur_unit_attmpt.
                               Bug#4304524 Registration Fee Retention not working for the first date of Retention.
                                Modified the cursor cur_tp_ret
   **************************************************************************/

   CURSOR cur_unit_attmpt(cp_n_person_id                igs_en_su_attempt.person_id%TYPE,
                          cp_v_course_cd                igs_en_su_attempt.course_cd%TYPE,
                          cp_v_load_cal_type            igs_ca_inst_all.cal_type%TYPE,
                          cp_n_load_ci_seq_num          igs_ca_inst_all.sequence_number%TYPE,
                          cp_v_nz_billable_cp_flag      igs_fi_f_typ_ca_inst_all.nonzero_billable_cp_flag%TYPE
                          ) IS
     SELECT sua.*, usec.non_std_usec_ind
     FROM igs_en_su_attempt sua,
          igs_ps_unit_ofr_opt usec
     WHERE sua.person_id = cp_n_person_id
     AND sua.course_cd = cp_v_course_cd
     AND usec.uoo_id = sua.uoo_id
     AND sua.unit_attempt_status NOT IN ('INVALID','DUPLICATE')
     AND ( (NVL(cp_v_nz_billable_cp_flag,'N') = 'Y' AND igs_fi_prc_fee_ass.finpl_clc_sua_cp( sua.unit_cd,
                                              sua.version_number,
                                              sua.cal_type,
                                              sua.ci_sequence_number,
                                              cp_v_load_cal_type,
                                              cp_n_load_ci_seq_num,
                                              sua.override_enrolled_cp,
                                              sua.override_eftsu,
                                              sua.uoo_id,
                                              sua.no_assessment_ind) <> 0)
          OR NVL(cp_v_nz_billable_cp_flag,'N') = 'N' )
     AND (igs_fi_gen_008.chk_unit_prg_transfer(sua.dcnt_reason_cd) = 'N');

   -- Cursor to fetch Retention Schedules defined at Teaching Period level
   -- Also to filter based on the Discontinued Date.
   CURSOR cur_tp_ret(cp_v_teach_cal_type    igs_fi_tp_ret_schd.teach_cal_type%TYPE,
                     cp_n_teach_ci_seq_num  igs_fi_tp_ret_schd.teach_ci_sequence_number%TYPE,
                     cp_d_disc_dt           igs_en_su_attempt.discontinued_dt%TYPE) IS
     SELECT 'X'
     FROM igs_fi_tp_ret_schd_v
     WHERE teach_cal_type = cp_v_teach_cal_type
     AND teach_ci_sequence_number = cp_n_teach_ci_seq_num
     AND fee_type IS NULL
     AND fee_cal_type IS NULL
     AND fee_ci_sequence_number IS NULL
     AND TRUNC(dai_alias_val) <= TRUNC(cp_d_disc_dt);

   -- Cursor to fetch retention schedules defined at Unit Section + Fee Type level
   CURSOR cur_ns_ft_ret(cp_n_uoo_id    igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                        cp_v_fee_type  igs_fi_fee_type.fee_type%TYPE) IS
     SELECT dtl.offset_date
     FROM igs_ps_nsus_rtn_dtl dtl,
          igs_ps_nsus_rtn rtn
     WHERE rtn.non_std_usec_rtn_id = dtl.non_std_usec_rtn_id
     AND rtn.uoo_id = cp_n_uoo_id
     AND rtn.fee_type = cp_v_fee_type
     ORDER BY dtl.offset_date;

   -- Cursor to fetch retention schedules defined at Unit Section level.
   -- This cursor is used when cur_ns_ft_ret does not find any rows
   CURSOR cur_ns_usec_ret(cp_n_uoo_id    igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT dtl.offset_date
     FROM igs_ps_nsus_rtn_dtl dtl,
          igs_ps_nsus_rtn rtn
     WHERE rtn.non_std_usec_rtn_id = dtl.non_std_usec_rtn_id
     AND rtn.uoo_id = cp_n_uoo_id
     AND rtn.fee_type IS NULL
     ORDER BY dtl.offset_date;

   -- Cursor to fetch retention schedules defined at Institution level.
   -- Used if cur_ns_ft_ret and cur_ns_usec_ret both do not return any rows
   CURSOR cur_ns_inst_ret(cp_n_uoo_id    igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT igs_ps_gen_004.f_retention_offset_date(cp_n_uoo_id,
                                                      rtn.formula_method,
                                                      rtn.round_method,
                                                      rtn.incl_wkend_duration_flag,
                                                      dtl.offset_value) offset_date
     FROM igs_ps_nsus_rtn_dtl dtl,
          igs_ps_nsus_rtn rtn
     WHERE rtn.non_std_usec_rtn_id = dtl.non_std_usec_rtn_id
     AND rtn.uoo_id IS NULL
     AND rtn.fee_type IS NULL
     ORDER BY offset_date;

   -- Variable to indicate whether or not load is incurred. Y = Incurred, N = Not Incurred.
   l_v_load_apply   VARCHAR2(1) := NULL;
   l_v_rec_exists   VARCHAR2(1) := NULL;

   -- Variable to indicate whether retention is 0 or Full Amount
   l_b_zero_ret_drop  BOOLEAN := FALSE;

   -- Local variable to indicate whether Retention Schedules have been found
   -- at the (Non Standard Unit Section + Fee Type) level
   l_b_ft_ret_found   BOOLEAN := FALSE;

   -- Local variable to indicate whether Retention Schedules have been found
   -- at the Non Standard Unit Section level
   l_b_usec_ret_found  BOOLEAN := FALSE;


  BEGIN

      -- If the Difference Amount is zero, then no Retention is applicable, return 0
      IF (NVL(p_n_diff_amount,0) = 0) THEN
         RETURN 0;
      END IF;

      -- Loop through all the Unit Attempts for the person and determine if load is incurred
      FOR rec_unit_attmpt IN cur_unit_attmpt(p_n_person_id, p_v_course_cd,p_v_load_cal_type,p_n_load_ci_sequence_number,p_v_nonzero_billable_cp_flag)
      LOOP
         l_v_load_apply := igs_en_prc_load.enrp_get_load_apply(p_teach_cal_type              => rec_unit_attmpt.cal_type,
                                                               p_teach_sequence_number       => rec_unit_attmpt.ci_sequence_number,
                                                               p_discontinued_dt             => rec_unit_attmpt.discontinued_dt,
                                                               p_administrative_unit_status  => rec_unit_attmpt.administrative_unit_status,
                                                               p_unit_attempt_status         => rec_unit_attmpt.unit_attempt_status,
                                                               p_no_assessment_ind           => rec_unit_attmpt.no_assessment_ind,
                                                               p_load_cal_type               => p_v_load_cal_type,
                                                               p_load_sequence_number        => p_n_load_ci_sequence_number,
                                                               p_include_audit               => rec_unit_attmpt.no_assessment_ind);
         -- If even one unit attempt incurs load, then no retention is applicable, return 0.
         IF (l_v_load_apply = 'Y') THEN
             EXIT;
         END IF;

         IF rec_unit_attmpt.non_std_usec_ind = 'Y' THEN

            -- For Non-Standard Unit Sections
            -- If load is not incurred, check the Discontinued Date against the Retention Date Alias defined at Usec level
            -- Fetch Retention Schedules defined at Unit Section + Fee Type level
            FOR rec_ns_ft_ret IN cur_ns_ft_ret(rec_unit_attmpt.uoo_id, p_v_fee_type)
            LOOP
                l_b_ft_ret_found := TRUE;
                IF TRUNC(rec_unit_attmpt.discontinued_dt) > TRUNC(rec_ns_ft_ret.offset_date) THEN
                    -- Unit Section was dropped AFTER the 0% Retention Period
                    l_b_zero_ret_drop := TRUE;
                END IF;
                -- Exit since we check only for the earliest Retention Schedule,i.e. only the first record
                EXIT;
            END LOOP;

            -- Fetch Retention Schedules defined at Unit Section level. This is done only
            -- if the schedules were not defined at the US + Fee Type level.
            IF (l_b_ft_ret_found = FALSE) THEN
                FOR rec_ns_usec_ret IN cur_ns_usec_ret(rec_unit_attmpt.uoo_id)
                LOOP
                    l_b_usec_ret_found := TRUE;
                    IF TRUNC(rec_unit_attmpt.discontinued_dt) > TRUNC(rec_ns_usec_ret.offset_date) THEN
                         -- Unit Section was dropped AFTER the 0% Retention Period
                         l_b_zero_ret_drop := TRUE;
                    END IF;
                    EXIT;
                END LOOP;
            END IF;

            -- Fetch Retention Schedules defined at Institution level. Done only if the schedules
            -- were not defined at (US + Fee Type) or at US level
            IF (l_b_ft_ret_found = FALSE AND l_b_usec_ret_found = FALSE) THEN
                FOR rec_ns_inst_ret IN cur_ns_inst_ret(rec_unit_attmpt.uoo_id)
                LOOP
                    IF TRUNC(rec_unit_attmpt.discontinued_dt) > TRUNC(rec_ns_inst_ret.offset_date) THEN
                         -- Unit Section was dropped AFTER the 0% Retention Period
                         l_b_zero_ret_drop := TRUE;
                    END IF;
                    EXIT;
                END LOOP;
            END IF;

         ELSE  -- rec_unit_attmpt.non_std_usec_ind <> 'Y'

            -- For Standard Unit Sections
            -- If load is not incurred, check the Discontinued Date against the Retention Date Alias (done in cursor cur_tp_ret)
            OPEN cur_tp_ret(rec_unit_attmpt.cal_type,
                            rec_unit_attmpt.ci_sequence_number,
                            rec_unit_attmpt.discontinued_dt);
            FETCH cur_tp_ret INTO l_v_rec_exists;
            IF cur_tp_ret%FOUND THEN
               -- Unit Section does not incur load and was dropped AFTER the 0% Retention Period
               l_b_zero_ret_drop := TRUE;
            END IF;
            CLOSE cur_tp_ret;

         END IF;  -- End if for rec_unit_attmpt.non_std_usec_ind = 'Y'

      END LOOP;  -- End of loop across all Unit Attempts of the Person

      IF l_v_load_apply = 'Y' THEN
         RETURN 0.0;
      END IF;

      -- Check for the zero retention flag
      IF l_b_zero_ret_drop THEN
         -- If no unit sections have incurred load and were
         -- dropped after the 0% Retention Period, then apply 100% retention
         RETURN ABS(p_n_diff_amount);
      ELSE
         -- If atleast one unit section incurs load or the unit sections were all
         -- dropped BEFORE the 0% Retention Period ended, Retention = 0
         RETURN 0;
      END IF;

  END get_complete_withdr_ret_amt;

  FUNCTION get_ns_usec_retention(p_n_uoo_id            IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                                 p_v_fee_type          IN igs_fi_fee_type.fee_type%TYPE,
                                 p_d_effective_date    IN DATE,
                                 p_n_diff_amount       IN NUMBER) RETURN NUMBER IS
  /**************************************************************************
    Created By     :  Priya Athipatla
    Date Created By:  03-Sep-2004
    Purpose        :  Function to determine the Retention Amount for a
                      Non-Standard Unit Section
    Known limitations,enhancements,remarks:

    Change History
    Who         When            What
   **************************************************************************/
   -- Definition of a pl/sql table to hold the Retention details for a NS Unit Section
   TYPE ns_usec_retention_rec IS RECORD ( offset_date        DATE,
                                          retention_amount   NUMBER,
                                          retention_percent  NUMBER);
   TYPE ns_usec_retention_tbl_typ IS TABLE OF  ns_usec_retention_rec  INDEX BY BINARY_INTEGER;
   ns_usec_retention_tbl   ns_usec_retention_tbl_typ;

   -- Cursor to fetch retention schedules defined at Unit Section + Fee Type level
   CURSOR cur_ns_ft_ret(cp_n_uoo_id    igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                        cp_v_fee_type  igs_fi_fee_type.fee_type%TYPE) IS
     SELECT dtl.offset_date,
            dtl.retention_amount,
            dtl.retention_percent
     FROM igs_ps_nsus_rtn_dtl dtl,
          igs_ps_nsus_rtn rtn
     WHERE rtn.non_std_usec_rtn_id = dtl.non_std_usec_rtn_id
     AND rtn.uoo_id = cp_n_uoo_id
     AND rtn.fee_type = cp_v_fee_type
     ORDER BY offset_date;

   -- Cursor to fetch retention schedules defined at Unit Section level.
   -- This cursor is used when cur_ns_ft_ret does not find any rows
   CURSOR cur_ns_usec_ret(cp_n_uoo_id    igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT dtl.offset_date,
            dtl.retention_amount,
            dtl.retention_percent
     FROM igs_ps_nsus_rtn_dtl dtl,
          igs_ps_nsus_rtn rtn
     WHERE rtn.non_std_usec_rtn_id = dtl.non_std_usec_rtn_id
     AND rtn.uoo_id = cp_n_uoo_id
     AND rtn.fee_type IS NULL
     ORDER BY offset_date;

   -- Cursor to fetch retention schedules defined at Institution level.
   -- Used if cur_ns_ft_ret and cur_ns_usec_ret both do not return any rows
   CURSOR cur_ns_inst_ret(cp_n_uoo_id    igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT dtl.retention_amount,
            dtl.retention_percent,
            igs_ps_gen_004.f_retention_offset_date(cp_n_uoo_id,
                                                   rtn.formula_method,
                                                   rtn.round_method,
                                                   rtn.incl_wkend_duration_flag,
                                                   dtl.offset_value) offset_date
    FROM igs_ps_nsus_rtn_dtl dtl,
         igs_ps_nsus_rtn rtn
    WHERE rtn.non_std_usec_rtn_id = dtl.non_std_usec_rtn_id
    AND rtn.uoo_id IS NULL
    AND rtn.fee_type IS NULL
    ORDER BY offset_date;

   l_n_cntr    NUMBER := 0;

   -- Local variable to indicate whether Retention Schedules have been found
   -- at the (Non Standard Unit Section + Fee Type) level or Unit Section level
   -- or at the Institution level
   l_b_ret_found   BOOLEAN := FALSE;

   l_n_ret_amount       igs_ps_nsus_rtn_dtl.retention_amount%TYPE := 0;
   l_n_ret_percent      igs_ps_nsus_rtn_dtl.retention_percent%TYPE := 0;
   l_n_amount           NUMBER := 0.0;

  BEGIN

     -- Initialize the pl/sql table
     ns_usec_retention_tbl.DELETE;

     -- Fetch Retention Schedules defined at Unit Section + Fee Type level
     FOR rec_ns_ft_ret IN cur_ns_ft_ret(p_n_uoo_id, p_v_fee_type)
     LOOP
        l_b_ret_found := TRUE;
        l_n_cntr := l_n_cntr + 1;
        ns_usec_retention_tbl(l_n_cntr).offset_date        := rec_ns_ft_ret.offset_date;
        ns_usec_retention_tbl(l_n_cntr).retention_amount   := rec_ns_ft_ret.retention_amount;
        ns_usec_retention_tbl(l_n_cntr).retention_percent  := rec_ns_ft_ret.retention_percent;
     END LOOP;

     -- Fetch Retention Schedules defined at Unit Section level. This is done only
     -- if the schedules were not defined at the US + Fee Type level.
     IF l_b_ret_found = FALSE THEN
        FOR rec_ns_usec_ret IN cur_ns_usec_ret(p_n_uoo_id)
        LOOP
           l_b_ret_found := TRUE;
           l_n_cntr := l_n_cntr + 1;
           ns_usec_retention_tbl(l_n_cntr).offset_date        := rec_ns_usec_ret.offset_date;
           ns_usec_retention_tbl(l_n_cntr).retention_amount   := rec_ns_usec_ret.retention_amount;
           ns_usec_retention_tbl(l_n_cntr).retention_percent  := rec_ns_usec_ret.retention_percent;
        END LOOP;
     END IF;

     -- Fetch Retention Schedules defined at Institution level. Done only if the schedules
     -- were not defined at (US + Fee Type) or at US level
     IF (l_b_ret_found = FALSE) THEN
        FOR rec_ns_inst_ret IN cur_ns_inst_ret(p_n_uoo_id)
        LOOP
           l_n_cntr := l_n_cntr + 1;
           ns_usec_retention_tbl(l_n_cntr).offset_date        := rec_ns_inst_ret.offset_date;
           ns_usec_retention_tbl(l_n_cntr).retention_amount   := rec_ns_inst_ret.retention_amount;
           ns_usec_retention_tbl(l_n_cntr).retention_percent  := rec_ns_inst_ret.retention_percent;
        END LOOP;
     END IF;

     -- Loop across records of the pl/sql table
     IF (ns_usec_retention_tbl.COUNT > 0) THEN
        FOR i IN ns_usec_retention_tbl.FIRST..ns_usec_retention_tbl.LAST
        LOOP
           IF ns_usec_retention_tbl.EXISTS(i) THEN
              -- If Effective Date falls beyond the Offset Date, apply retention
              IF TRUNC(p_d_effective_date) >= TRUNC(ns_usec_retention_tbl(i).offset_date)  THEN
                 l_n_ret_percent := ns_usec_retention_tbl(i).retention_percent;
                 l_n_ret_amount  := ns_usec_retention_tbl(i).retention_amount;
              ELSE
                 -- If the Effective Date falls before the Offset Date value, then exit loop
                 EXIT;
              END IF;
           END IF; -- End if for ns_usec_retention_tbl.EXISTS(i)
        END LOOP; -- End loop for looping across all records in the pl/sql table

        -- Determine the Retention Amount
        IF l_n_ret_amount IS NOT NULL THEN
            l_n_amount := l_n_ret_amount;
        ELSIF l_n_ret_percent IS NOT NULL THEN
            l_n_amount := ABS(p_n_diff_amount) * (l_n_ret_percent/100);
        END IF; -- End if for l_n_ret_amount IS NOT NULL

     END IF;  -- End if for ns_usec_retention_tbl.COUNT > 0

     RETURN l_n_amount;

  END get_ns_usec_retention;


  FUNCTION get_special_retention_amt(p_n_uoo_id                  IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                                     p_v_fee_cal_type            IN igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                                     p_n_fee_ci_sequence_number  IN igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE,
                                     p_v_fee_type                IN igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                                     p_d_effective_date          IN DATE,
                                     p_n_diff_amount             IN NUMBER) RETURN NUMBER IS
  /**************************************************************************
    Created By     :  Priya Athipatla
    Date Created By:  08-Sep-2004
    Purpose        :  Function to determine the Retention Amount for Special Fees
    Known limitations,enhancements,remarks:

    Change History
    Who         When            What
   **************************************************************************/

   -- Cursor to determine if a given Unit Section is Non-Standard
   CURSOR cur_non_std_usec(cp_n_uoo_id   igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT cal_type,
            ci_sequence_number,
            non_std_usec_ind
     FROM igs_ps_unit_ofr_opt
     WHERE uoo_id = cp_n_uoo_id;

   rec_non_std_usec          cur_non_std_usec%ROWTYPE;
   l_n_retention_amount      NUMBER := 0.0;

   BEGIN

     OPEN cur_non_std_usec(p_n_uoo_id);
     FETCH cur_non_std_usec INTO rec_non_std_usec;
     CLOSE cur_non_std_usec;

     IF (rec_non_std_usec.non_std_usec_ind = 'Y') THEN
          l_n_retention_amount := get_ns_usec_retention(p_n_uoo_id         => p_n_uoo_id,
                                                        p_v_fee_type       => p_v_fee_type,
                                                        p_d_effective_date => p_d_effective_date,
                                                        p_n_diff_amount    => p_n_diff_amount);
         RETURN l_n_retention_amount;
     ELSE
          l_n_retention_amount := get_teach_retention(p_v_fee_cal_type             => p_v_fee_cal_type,
                                                      p_n_fee_ci_sequence_number   => p_n_fee_ci_sequence_number,
                                                      p_v_fee_type                 => p_v_fee_type,
                                                      p_v_teach_cal_type           => rec_non_std_usec.cal_type,
                                                      p_n_teach_ci_sequence_number => rec_non_std_usec.ci_sequence_number,
                                                      p_d_effective_date           => p_d_effective_date,
                                                      p_n_diff_amount              => p_n_diff_amount);
         RETURN l_n_retention_amount;
     END IF;

   END get_special_retention_amt;

FUNCTION get_std_balance(p_partyid  IN igs_fi_balances.party_id%TYPE) RETURN NUMBER AS

/***************************************************************************
  ||  Created By : svuppala
  ||  Created On : 10-Apr-2002
  ||  Purpose :  New PLSQL function which will return the latest standard
  ||             balance for the student for the personid provided as input to it
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 ******************************************************************************/

-- Cursor for fetching the standard balance for the partyid passed as input to the function
  CURSOR cur_partyid(cp_partyid  NUMBER) IS
     SELECT standard_balance
     FROM   igs_fi_balances
     WHERE  party_id = cp_partyid
     ORDER BY balance_date DESC;

  l_std_balance  igs_fi_balances.standard_balance%TYPE;

 BEGIN

-- Fetch the standard Balance
    OPEN cur_partyid(p_partyid);
    FETCH cur_partyid INTO l_std_balance;
    IF cur_partyid%NOTFOUND THEN
      l_std_balance := 0;
    END IF;
    CLOSE cur_partyid;

-- Return the value for the l_std_balance
  RETURN l_std_balance;

END get_std_balance;

PROCEDURE chk_spa_rec_exists(p_n_person_id      IN  igs_en_stdnt_ps_att.person_id%TYPE,
                             p_v_course_cd      IN  igs_en_stdnt_ps_att.course_cd%TYPE,
                             p_v_load_cal_type  IN  igs_ca_inst.cal_type%TYPE,
			     p_n_load_ci_seq    IN  igs_ca_inst.sequence_number%TYPE,
			     p_v_fee_cat        IN  igs_fi_fee_cat.fee_cat%TYPE,
			     p_v_status         OUT NOCOPY VARCHAR2,
			     p_v_message        OUT NOCOPY VARCHAR2) AS
  /***********************************************************************************************
    Created By     :  Amit Gairola
    Date Created By:  27-Sep-2005
    Purpose        :  Procedure to check if a term record exists

    Known limitations,enhancements,remarks:
    Change History
    Who         When            What
  ***********************************************************************************************/

-- Cursor for checking if the Charge exists
  CURSOR cur_chg(cp_n_person_id      igs_en_stdnt_ps_att.person_id%TYPE,
                 cp_v_course_cd      igs_en_stdnt_ps_att.course_cd%TYPE,
	         cp_v_fee_cal_type   igs_ca_inst.cal_type%TYPE,
	         cp_n_fee_ci_seq     igs_ca_inst.sequence_number%TYPE) IS
    SELECT 'x'
    FROM   igs_fi_fee_as_all
    WHERE  person_id = cp_n_person_id
    AND    ((course_cd = cp_v_course_cd OR course_cd IS NULL))
    AND    fee_cal_type = cp_v_fee_cal_type
    AND    fee_ci_sequence_number = cp_n_fee_ci_seq
    AND    s_transaction_type = 'ASSESSMENT';

-- Cursor for checking if Contract Rates exist
  CURSOR cur_cntrct_rates(cp_n_person_id     igs_en_stdnt_ps_att.person_id%TYPE,
                          cp_v_course_cd     igs_en_stdnt_ps_att.course_cd%TYPE,
			  cp_v_fee_cat       igs_fi_fee_cat.fee_cat%TYPE) IS
    SELECT 'x'
    FROM igs_fi_f_cat_fee_lbl_all lbl,
         igs_fi_fee_as_rt rt
    WHERE lbl.fee_type = rt.fee_type
    AND   rt.person_id = cp_n_person_id
    AND   rt.course_cd = cp_v_course_cd
    AND   lbl.fee_cat =  cp_v_fee_cat
    AND TRUNC(SYSDATE) BETWEEN TRUNC(rt.start_dt) AND TRUNC(NVL(rt.end_dt,SYSDATE));

    l_b_bool                BOOLEAN;
    l_v_chr                 VARCHAR2(1);
    l_v_fee_cal_type        igs_ca_inst.cal_type%TYPE;
    l_n_fee_ci_seq          igs_ca_inst.sequence_number%TYPE;


BEGIN
  p_v_status := 'N';
  p_v_message := NULL;

-- Cursor for checking if any of the mandatory parameters are Null
  IF p_n_person_id IS NULL OR
     p_v_course_cd IS NULL OR
     p_v_load_cal_type IS NULL OR
     p_n_load_ci_seq IS NULL THEN
    p_v_status := 'Y';
    p_v_message := 'IGS_GE_INSUFFICIENT_PARAMETER';
  END IF;

-- Derive the Fee Calendar
  l_b_bool := igs_fi_gen_001.finp_get_lfci_reln(p_cal_type                 => p_v_load_cal_type,
                                                p_ci_sequence_number       => p_n_load_ci_seq,
                                                p_cal_category             => 'LOAD',
                                                p_ret_cal_type             => l_v_fee_cal_type,
                                                p_ret_ci_sequence_number   => l_n_fee_ci_seq,
                                                p_message_name             => p_v_message);


  IF NOT l_b_bool THEN
    p_v_status := 'N';
    RETURN;
  END IF;

-- Check if a Fee Assessment record exists
  OPEN cur_chg(p_n_person_id,
               p_v_course_cd,
	       l_v_fee_cal_type,
	       l_n_fee_ci_seq);
  FETCH cur_chg INTO l_v_chr;
  IF cur_chg%FOUND THEN
    p_v_status := 'Y';
    p_v_message := 'IGS_GE_RECORD_ALREADY_EXISTS';
  END IF;
  CLOSE cur_chg;

  IF p_v_status = 'Y' THEN
    RETURN;
  END IF;

-- Check if a Contract Fee Rate exists
  OPEN cur_cntrct_rates(p_n_person_id,
                        p_v_course_cd,
                        p_v_fee_cat);
  FETCH cur_cntrct_rates INTO l_v_chr;
  IF cur_cntrct_rates%FOUND THEN
    p_v_status := 'Y';
    p_v_message := 'IGS_GE_RECORD_ALREADY_EXISTS';
  END IF;
  CLOSE cur_cntrct_rates;

  RETURN;

END chk_spa_rec_exists;


FUNCTION mask_card_number( p_credit_card IN VARCHAR2 )  RETURN VARCHAR2
  IS
  /***********************************************************************************************
    Created By     :  Umesh Udayaprakash
    Date Created By:  10/7/2005
    Purpose        :  Function to Mask the Credit card Number

    Known limitations,enhancements,remarks:
    Change History
    Who         When            What
    uudayapr   8-Oct-2005   BUG 4660773 Added the Function mask_card_number for masking the CC Number
  ***********************************************************************************************/
CURSOR cur_mask_card IS
    SELECT DECODE(  NVL(FND_PROFILE.VALUE('IGS_FI_MASK_CREDIT_CARD_NUMBERS'),'F'),
             'N', p_credit_card,
             'F', RPAD( SUBSTR(p_credit_card,1,4),LENGTH(p_credit_card),'*'),
             'L', LPAD( SUBSTR(p_credit_card,-4),LENGTH(p_credit_card),'*')
                )
    FROM dual;
    l_v_masked_card_num  IGS_FI_CREDITS_ALL.CREDIT_CARD_NUMBER%TYPE;
BEGIN
   OPEN cur_mask_card;
   FETCH cur_mask_card INTO l_v_masked_card_num;
   CLOSE cur_mask_card;
   RETURN l_v_masked_card_num;
END Mask_Card_Number;

  -- Function to check if the Unit in context (UOO_ID) has been part of a Program Transfer or not.
  -- Returns Y or N
  FUNCTION chk_unit_prg_transfer(p_v_disc_reason_code  IN igs_en_dcnt_reasoncd.discontinuation_reason_cd%TYPE) RETURN VARCHAR2 AS
  /***********************************************************************************************
    Created By     :  abshriva
    Date Created   :  17-May-2006
    Purpose        :  Fuction to check if the unit dropped was due to program transfer or not.

    Known limitations,enhancements,remarks:
    Change History
    Who         When            What
  ***********************************************************************************************/

   -- Cursor to find out if the unit has been dropped due to a Program Transfer, in which case Retention
   -- calculation needs to be skipped for the unit drop.
   CURSOR cur_chk_transfer(cp_v_disc_reason_cd  igs_en_dcnt_reasoncd.discontinuation_reason_cd%TYPE) IS
     SELECT 'x'
     FROM igs_en_dcnt_reasoncd
     WHERE s_discontinuation_reason_type = 'UNIT_TRANS'
     AND discontinuation_reason_cd = cp_v_disc_reason_cd;

   l_v_transferred   VARCHAR2(1);

   BEGIN

       OPEN cur_chk_transfer(p_v_disc_reason_code);
       FETCH cur_chk_transfer INTO l_v_transferred;
       -- If cursor found, return Y - this will skip retention from Fee Assessment/Special fees
       IF cur_chk_transfer%FOUND THEN
          l_v_transferred := 'Y';
       ELSE
          l_v_transferred := 'N';
       END IF;

       RETURN l_v_transferred;

   END chk_unit_prg_transfer;


END igs_fi_gen_008;

/
