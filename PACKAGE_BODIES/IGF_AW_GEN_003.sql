--------------------------------------------------------
--  DDL for Package Body IGF_AW_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_GEN_003" AS
/* $Header: IGFAW12B.pls 120.23 2006/08/04 07:40:11 veramach ship $ */


FUNCTION  get_plan_disb_count(p_adplans_id    IN igf_aw_awd_dist_plans.adplans_id%TYPE,
                              p_awd_prd_code  IN igf_aw_awd_prd_term.award_prd_cd%TYPE
                             ) RETURN NUMBER IS
--
------------------------------------------------------------------
-- Created by  :
-- Date created:
--
-- Purpose:
-- Insert disbursement records
--
-- Known limitations/enhancements and/or remarks:
--
-- Change History:
-------------------------------------------------------------------
-- Who        When            What
-------------------------------------------------------------------
-- veramach    12-Oct-2004     FA 152 - added p_awd_prd_code in the signature
-------------------------------------------------------------------
--
  CURSOR cur_check_terms IS
    SELECT COUNT(*) common_terms
      FROM igf_aw_dp_terms terms,
           igf_aw_dp_teach_prds teach_periods
     WHERE terms.adplans_id = p_adplans_id
       AND terms.adterms_id = teach_periods.adterms_id;
  ln_result  NUMBER;

  CURSOR cur_check_terms_awd IS
    SELECT COUNT(*) common_terms
      FROM igf_aw_awd_dist_plans adplans,
           igf_aw_dp_terms terms,
           igf_aw_dp_teach_prds teach_periods,
           igf_aw_awd_prd_term aprd
     WHERE terms.adplans_id = p_adplans_id
       AND terms.adterms_id = teach_periods.adterms_id
       AND terms.ld_cal_type = aprd.ld_cal_type
       AND terms.ld_sequence_number = terms.ld_sequence_number
       AND aprd.award_prd_cd = p_awd_prd_code
       AND adplans.adplans_id = terms.adplans_id
       AND adplans.cal_type = aprd.ci_cal_type
       AND adplans.sequence_number = aprd.ci_sequence_number;

BEGIN

  ln_result := 0;
  IF p_awd_prd_code IS NULL THEN
    OPEN  cur_check_terms;
    FETCH cur_check_terms INTO ln_result;
    CLOSE cur_check_terms;
  ELSE
    OPEN  cur_check_terms_awd;
    FETCH cur_check_terms_awd INTO ln_result;
    CLOSE cur_check_terms_awd;
  END IF;
  ln_result := NVL(ln_result,0);

  RETURN ln_result;

END get_plan_disb_count;

FUNCTION get_fed_fund_code(
                           p_fund_id NUMBER
                          ) RETURN VARCHAR2
IS
------------------------------------------------------------------
-- Created by  :  museshad
-- Date created:  12-Sep-2005
--
-- Purpose: Returns fed_fund_code for the passed fund_id
-- Insert disbursement records
--
-- Known limitations/enhancements and/or remarks:
--
-- Change History:
-------------------------------------------------------------------
-- Who        When            What

  CURSOR cur_get_fund  (p_fund_id NUMBER)
  IS
  SELECT fcat.fed_fund_code
  FROM   igf_aw_fund_cat fcat,
         igf_aw_fund_mast fmast
 WHERE   fcat.fund_code = fmast.fund_code
   AND   fmast.fund_id = p_fund_id;

  get_fund_rec cur_get_fund%ROWTYPE;

BEGIN
  OPEN  cur_get_fund(p_fund_id);
  FETCH cur_get_fund INTO get_fund_rec;
  CLOSE cur_get_fund;

  RETURN get_fund_rec.fed_fund_code;

END get_fed_fund_code;

FUNCTION isRepackaging(p_award_id IN  igf_aw_award_all.award_id%TYPE)
RETURN BOOLEAN
IS
------------------------------------------------------------------
-- Created by  :  museshad
-- Date created:  26-Sep-2005
--
-- Purpose: Returns FALSE if the award is being created newly (Packaging)
--          Returns TRUE if an existing award is being Repackaged
--
-- Known limitations/enhancements and/or remarks:
--
-- Change History:
-------------------------------------------------------------------
-- Who        When            What
------------------------------------------------------------------
  CURSOR c_chk_repkg(cp_award_id IN  igf_aw_award_all.award_id%TYPE)
  IS
    SELECT  'X'
    FROM    igf_aw_awd_disb_all
    WHERE   award_id = cp_award_id;
  l_repkg_rec c_chk_repkg%ROWTYPE;

BEGIN
  OPEN c_chk_repkg(cp_award_id => p_award_id);
  FETCH c_chk_repkg INTO l_repkg_rec;

  IF (c_chk_repkg%FOUND) THEN
    CLOSE c_chk_repkg;
    RETURN TRUE;
  ELSE
    CLOSE c_chk_repkg;
    RETURN FALSE;
  END IF;
END isRepackaging;

PROCEDURE cancel_extra_disb (
                              p_award_id     IN   igf_aw_award.award_id%TYPE,
                              p_disb_num     IN   igf_aw_awd_disb_all.disb_num%TYPE
                            )
IS
  /*
  ||  Created By :  museshad
  ||  Created On :  26-Sep-2005
  ||  Purpose    :  Cancels those disbursements in the award that exceed the
  ||                disb num passed as parameter
  ||
  ||  Known limitations, enhancements or remarks :
  ||
  ||  Change History :
  ||  Who             When            What
  */

  -- Get all disbursements more than cp_disb_num in the award
  CURSOR c_disb_cancel(
                       cp_award_id    igf_aw_award_all.award_id%TYPE,
                       cp_disb_num    igf_aw_awd_disb_all.disb_num%TYPE
                      )
  IS
    SELECT  *
    FROM    igf_aw_awd_disb
    WHERE   award_id = cp_award_id  AND
            trans_type <> 'C'       AND
            disb_num > cp_disb_num;

BEGIN

  FOR disb_cancel_rec IN c_disb_cancel(cp_award_id  =>  p_award_id,
                                       cp_disb_num  =>  p_disb_num)
  LOOP

    -- Log
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,
                     'igf.plsql.igf_aw_gen_003.cancel_extra_disb',
                     'Cancelling disb num ' ||disb_cancel_rec.disb_num|| ' in award_id:' ||p_award_id);
    END IF;

    -- cancel the disbursement
    igf_aw_awd_disb_pkg.update_row(
                                    x_rowid                     =>      disb_cancel_rec.row_id,
                                    x_award_id                  =>      disb_cancel_rec.award_id,
                                    x_disb_num                  =>      disb_cancel_rec.disb_num,
                                    x_tp_cal_type               =>      disb_cancel_rec.tp_cal_type,
                                    x_tp_sequence_number        =>      disb_cancel_rec.tp_sequence_number,
                                    x_disb_gross_amt            =>      0,
                                    x_fee_1                     =>      disb_cancel_rec.fee_1,
                                    x_fee_2                     =>      disb_cancel_rec.fee_2,
                                    x_disb_net_amt              =>      0,
                                    x_disb_date                 =>      disb_cancel_rec.disb_date,
                                    x_trans_type                =>      'C',
                                    x_elig_status               =>      disb_cancel_rec.elig_status,
                                    x_elig_status_date          =>      disb_cancel_rec.elig_status_date,
                                    x_affirm_flag               =>      disb_cancel_rec.affirm_flag,
                                    x_hold_rel_ind              =>      disb_cancel_rec.hold_rel_ind,
                                    x_manual_hold_ind           =>      disb_cancel_rec.manual_hold_ind,
                                    x_disb_status               =>      disb_cancel_rec.disb_status,
                                    x_disb_status_date          =>      disb_cancel_rec.disb_status_date,
                                    x_late_disb_ind             =>      disb_cancel_rec.late_disb_ind,
                                    x_fund_dist_mthd            =>      disb_cancel_rec.fund_dist_mthd,
                                    x_prev_reported_ind         =>      disb_cancel_rec.prev_reported_ind,
                                    x_fund_release_date         =>      disb_cancel_rec.fund_release_date,
                                    x_fund_status               =>      disb_cancel_rec.fund_status,
                                    x_fund_status_date          =>      disb_cancel_rec.fund_status_date,
                                    x_fee_paid_1                =>      disb_cancel_rec.fee_paid_1,
                                    x_fee_paid_2                =>      disb_cancel_rec.fee_paid_2,
                                    x_cheque_number             =>      disb_cancel_rec.cheque_number,
                                    x_ld_cal_type               =>      disb_cancel_rec.ld_cal_type,
                                    x_ld_sequence_number        =>      disb_cancel_rec.ld_sequence_number,
                                    x_disb_accepted_amt         =>      0,
                                    x_disb_paid_amt             =>      0,
                                    x_rvsn_id                   =>      disb_cancel_rec.rvsn_id,
                                    x_int_rebate_amt            =>      disb_cancel_rec.int_rebate_amt,
                                    x_force_disb                =>      disb_cancel_rec.force_disb,
                                    x_min_credit_pts            =>      disb_cancel_rec.min_credit_pts,
                                    x_disb_exp_dt               =>      disb_cancel_rec.disb_exp_dt,
                                    x_verf_enfr_dt              =>      disb_cancel_rec.verf_enfr_dt,
                                    x_fee_class                 =>      disb_cancel_rec.fee_class,
                                    x_show_on_bill              =>      disb_cancel_rec.show_on_bill,
                                    x_mode                      =>      'R',
                                    x_attendance_type_code      =>      disb_cancel_rec.attendance_type_code,
                                    x_base_attendance_type_code =>      disb_cancel_rec.base_attendance_type_code,
                                    x_payment_prd_st_date       =>      disb_cancel_rec.payment_prd_st_date,
                                    x_change_type_code          =>      disb_cancel_rec.change_type_code,
                                    x_fund_return_mthd_code     =>      disb_cancel_rec.fund_return_mthd_code,
                                    x_direct_to_borr_flag       =>      disb_cancel_rec.direct_to_borr_flag
                                 );

  END LOOP;

END cancel_extra_disb;

PROCEDURE create_pell_disb(  p_award_id      IN NUMBER,
                             p_pell_tab      IN igf_gr_pell_calc.pell_tab )
IS
--
------------------------------------------------------------------
-- Created by  : sjadhav, Oracle India
-- Date created: 1-Dec-2003
--
-- Purpose:
-- Insert disbursement records
--
-- Known limitations/enhancements and/or remarks:
--
-- Change History:
-------------------------------------------------------------------
-- Who        When            What
-------------------------------------------------------------------
-- museshad   17-Oct-2005     Bug# 4608591. Reinstating cancelled
--                            Pell award.
-- sjadhav    1-Dec-2003      FA 131 Build
-- pssahni    7-Dec-2004      Default value of DRI is set to false
--                            for full participant
-------------------------------------------------------------------
--

 CURSOR cur_get_fed_fund_code(
                          cp_award_id igf_aw_award_all.award_id%TYPE
                         ) IS
    SELECT fed_fund_code,ci_cal_type,ci_sequence_number
      FROM igf_aw_award_v
      WHERE award_id = cp_award_id;
  l_get_fed_fund_code cur_get_fed_fund_code%ROWTYPE;

CURSOR c_disb(
              cp_award_id igf_aw_award_all.award_id%TYPE,
              cp_disb_num igf_aw_awd_disb_all.disb_num%TYPE
             ) IS
  SELECT rowid row_id,
         disb.*
    FROM igf_aw_awd_disb_all disb
   WHERE award_id = cp_award_id
     AND disb_num = cp_disb_num;
l_disb c_disb%ROWTYPE;

  lv_row_id ROWID;
  l_hold_ind VARCHAR2(6);
  ln_count   NUMBER := 0;
BEGIN

  l_hold_ind := NULL;
  IF p_award_id IS NOT NULL AND
     p_pell_tab.COUNT > 0 THEN

      OPEN cur_get_fed_fund_code(p_award_id);
      FETCH cur_get_fed_fund_code INTO l_get_fed_fund_code;
      CLOSE cur_get_fed_fund_code;
      IF   (l_get_fed_fund_code.fed_fund_code = 'PELL' AND
             igf_sl_dl_validation.check_full_participant (l_get_fed_fund_code.ci_cal_type,l_get_fed_fund_code.ci_sequence_number,'PELL'))
          THEN
        l_hold_ind := 'FALSE';
      END IF;

     FOR i IN 1..p_pell_tab.COUNT LOOP

        lv_row_id := NULL;
        ln_count := i;

        OPEN c_disb(cp_award_id => p_award_id, cp_disb_num => i);
        FETCH c_disb INTO l_disb;

        IF isRepackaging(p_award_id => p_award_id) AND (c_disb%FOUND) THEN
          l_hold_ind := NVL(l_disb.hold_rel_ind, 'FALSE');

          igf_aw_awd_disb_pkg.update_row (
                      x_mode                       => 'R',
                      x_rowid                      => l_disb.row_id,
                      x_award_id                   => p_award_id,
                      x_disb_num                   => i,
                      x_tp_cal_type                => p_pell_tab(i).tp_cal_type,
                      x_tp_sequence_number         => p_pell_tab(i).tp_sequence_number,
                      x_disb_gross_amt             => p_pell_tab(i).offered_amt,
                      x_fee_1                      => 0,
                      x_fee_2                      => 0,
                      x_disb_net_amt               => p_pell_tab(i).offered_amt,
                      x_disb_date                  => p_pell_tab(i).disb_dt,
                      x_trans_type                 => 'P',
                      x_elig_status                => 'N',
                      x_elig_status_date           => TRUNC(SYSDATE),
                      x_affirm_flag                => l_disb.affirm_flag,
                      x_hold_rel_ind               => l_hold_ind,
                      x_manual_hold_ind            => 'N',
                      x_disb_status                => l_disb.disb_status,
                      x_disb_status_date           => l_disb.disb_status_date,
                      x_late_disb_ind              => l_disb.late_disb_ind,
                      x_fund_dist_mthd             => l_disb.fund_dist_mthd,
                      x_prev_reported_ind          => l_disb.prev_reported_ind,
                      x_fund_release_date          => l_disb.fund_release_date,
                      x_fund_status                => l_disb.fund_status,
                      x_fund_status_date           => l_disb.fund_status_date,
                      x_fee_paid_1                 => 0,
                      x_fee_paid_2                 => 0,
                      x_cheque_number              => l_disb.cheque_number,
                      x_ld_cal_type                => p_pell_tab(i).ld_cal_type,
                      x_ld_sequence_number         => p_pell_tab(i).ld_sequence_number,
                      x_disb_accepted_amt          => p_pell_tab(i).accepted_amt,
                      x_disb_paid_amt              => 0,
                      x_rvsn_id                    => l_disb.rvsn_id,
                      x_int_rebate_amt             => 0,
                      x_force_disb                 => 'N',
                      x_min_credit_pts             => p_pell_tab(i).min_credit_pts,
                      x_disb_exp_dt                => p_pell_tab(i).disb_exp_dt,
                      x_verf_enfr_dt               => p_pell_tab(i).verf_enfr_dt,
                      x_fee_class                  => l_disb.fee_class,
                      x_show_on_bill               => p_pell_tab(i).show_on_bill,
                      x_attendance_type_code       => p_pell_tab(i).attendance_type_code,
                      x_base_attendance_type_code  => p_pell_tab(i).base_attendance_type_code,
                      x_payment_prd_st_date        => l_disb.payment_prd_st_date,
                      x_change_type_code           => l_disb.change_type_code,
                      x_fund_return_mthd_code      => l_disb.fund_return_mthd_code,
                      x_direct_to_borr_flag        => l_disb.direct_to_borr_flag
                      );
        ELSE
          igf_aw_awd_disb_pkg.insert_row (
                      x_mode                       => 'R',
                      x_rowid                      => lv_row_id,
                      x_award_id                   => p_award_id,
                      x_disb_num                   => i,
                      x_tp_cal_type                => p_pell_tab(i).tp_cal_type,
                      x_tp_sequence_number         => p_pell_tab(i).tp_sequence_number,
                      x_disb_gross_amt             => p_pell_tab(i).offered_amt,
                      x_fee_1                      => 0,
                      x_fee_2                      => 0,
                      x_disb_net_amt               => p_pell_tab(i).offered_amt,
                      x_disb_date                  => p_pell_tab(i).disb_dt,
                      x_trans_type                 => 'P',
                      x_elig_status                => 'N',
                      x_elig_status_date           => TRUNC(SYSDATE),
                      x_affirm_flag                => NULL,
                      x_hold_rel_ind               => l_hold_ind,
                      x_manual_hold_ind            => 'N',
                      x_disb_status                => NULL,
                      x_disb_status_date           => NULL,
                      x_late_disb_ind              => NULL,
                      x_fund_dist_mthd             => NULL,
                      x_prev_reported_ind          => NULL,
                      x_fund_release_date          => NULL,
                      x_fund_status                => NULL,
                      x_fund_status_date           => NULL,
                      x_fee_paid_1                 => 0,
                      x_fee_paid_2                 => 0,
                      x_cheque_number              => NULL,
                      x_ld_cal_type                => p_pell_tab(i).ld_cal_type,
                      x_ld_sequence_number         => p_pell_tab(i).ld_sequence_number,
                      x_disb_accepted_amt          => p_pell_tab(i).accepted_amt,
                      x_disb_paid_amt              => 0,
                      x_rvsn_id                    => NULL,
                      x_int_rebate_amt             => 0,
                      x_force_disb                 => 'N',
                      x_min_credit_pts             => p_pell_tab(i).min_credit_pts,
                      x_disb_exp_dt                => p_pell_tab(i).disb_exp_dt,
                      x_verf_enfr_dt               => p_pell_tab(i).verf_enfr_dt,
                      x_fee_class                  => NULL,
                      x_show_on_bill               => p_pell_tab(i).show_on_bill,
                      x_attendance_type_code       => p_pell_tab(i).attendance_type_code,
                      x_base_attendance_type_code  => p_pell_tab(i).base_attendance_type_code,
                      x_payment_prd_st_date        => NULL,
                      x_change_type_code           => NULL,
                      x_fund_return_mthd_code      => NULL,
                      x_direct_to_borr_flag        => 'N'
                      );
        END IF;
        CLOSE c_disb;

     END LOOP;

    -- museshad (Bug# 4608591)
    -- While repackaging any extra disbursements present in the
    -- award needs to be cancelled
    IF isRepackaging(p_award_id => p_award_id) THEN
      cancel_extra_disb (
                          p_award_id  =>  p_award_id,
                          p_disb_num  =>  ln_count
                        );
    END IF;
    -- museshad (Bug# 4608591)
  END IF;

EXCEPTION

WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_AW_GEN_003.CREATE_PELL_DISB'||' ' ||SQLERRM);
   app_exception.raise_exception;

END create_pell_disb;

PROCEDURE updating_coa_in_fa_base (p_base_id        igf_ap_fa_base_rec.base_id%TYPE)
IS
--
------------------------------------------------------------------
-- Created by  : Amit Dhawan, Oracle India (adhawan)
-- Date created: 10-apr-2002
--
-- Purpose:This is used to update the Financial Aid base record with
-- The cost of Attendance (Fixed Coa , Pell Coa , COA for Federal
-- COA for Institutional)
--
--
-- Known limitations/enhancements and/or remarks:
--
-- Change History:
-------------------------------------------------------------------
-- Who        When            What
-------------------------------------------------------------------
-- rasahoo    01-Dec-2003     FA 128 Isir Update
--                            Added new parameter award_fmly_contribution_type
--                            to igf_ap_fa_base_rec_pkg.update_row
-------------------------------------------------------------------
--ugummall    13-OCT-2003     FA 126 Multiple FA Offices
--                            added new parameter assoc_org_num to
--                            igf_ap_fa_base_rec_pkg.update_row call.
-------------------------------------------------------------------
-- sjadhav    09-Apr-2003     Bug 2890177
--                            Modified updating_coa_in_fa_base
--                            If pell coa and alt exp for coa items
--                            have not been defined then update
--                            fabase record with null values for
--                            these
-------------------------------------------------------------------
-- masehgal   11-Nov-2002     FA 101 - SAP Obsoletion
--                            Removed packaging hold
-------------------------------------------------------------------
-- adhawan    25-oct-2002     Bug 2613546
--                            Obsoletion of igf_aw_cit_ssn ,
--                            using igf_aw_coa_items instead
--                            Getting pell_coa_amount,
--                            pell_alt_expense
--                            and updating in Fa base
--                            Added pell_alt_exp in update
--                            row of fabase
--                            c_stud_det modified to
--                            select from igf_ap_fa_base_rec
--                            instead of fa_con_v
--                            Removed p_coa , p_ci_cal_type ,
--                            p_sequence_number passed as
--                            paramters
-------------------------------------------------------------------
-- masehgal   25-Sep-2002     Bug 2315112
--                            FA 104 - To Do Enhancements
--                            Added manual_disb_hold in FA
--                            Base update
-------------------------------------------------------------------
-- adhawan    12-apr-2002     Updating the Fa Record
-------------------------------------------------------------------
--

   CURSOR c_stud_det (p_base_id igf_ap_fa_base_rec.base_id%TYPE)
   IS
      SELECT fa_detail.*
      FROM   igf_ap_fa_base_rec fa_detail
      WHERE  fa_detail.base_id = p_base_id;

   l_stud_det c_stud_det%ROWTYPE ;
--
-- Modified for bug Id 2613546
--
   CURSOR cur_tot_coa (p_base_id igf_ap_fa_base_rec.base_id%TYPE)
   IS
      SELECT
             SUM(NVL(citsn.amount,0))          coa_total,
             SUM(NVL(citsn.pell_coa_amount,0)) pell_coa,
             SUM(NVL(citsn.alt_pell_amount,0)) pell_alt_expense,
             SUM(DECODE(citsn.fixed_cost,'Y',NVL(citsn.amount,0),0) ) fixed_coa
      FROM   igf_aw_coa_items citsn
      WHERE  citsn.base_id = p_base_id ;

   tot_coa_rec cur_tot_coa%ROWTYPE;

   --
   -- Bug 2890177
   --
   CURSOR cur_tot_coa_null (p_base_id igf_ap_fa_base_rec.base_id%TYPE)
   IS
      SELECT
             SUM(NVL(citsn.pell_coa_amount,-1)) pell_coa,
             SUM(NVL(citsn.alt_pell_amount,-1)) pell_alt_expense
      FROM   igf_aw_coa_items citsn
      WHERE  citsn.base_id = p_base_id ;

   tot_coa_null_rec cur_tot_coa_null%ROWTYPE;

   CURSOR cur_tot_coa_cnt (p_base_id igf_ap_fa_base_rec.base_id%TYPE)
   IS
      SELECT
             COUNT(base_id) rec_cnt
      FROM   igf_aw_coa_items citsn
      WHERE  citsn.base_id = p_base_id ;

   tot_coa_cnt_rec cur_tot_coa_cnt%ROWTYPE;

   --
   -- Bug 2890177
   --


BEGIN

   --
   -- 1.open the student record.
   -- 2.get the cost of attendance code assigned to the student
   --

   OPEN c_stud_det(p_base_id);
   FETCH c_stud_det INTO l_stud_det;
   IF c_stud_det%NOTFOUND THEN
      CLOSE c_stud_det;
      RETURN;
   END IF;

   OPEN  cur_tot_coa(p_base_id);
   FETCH cur_tot_coa INTO tot_coa_rec;
   CLOSE cur_tot_coa;

   --
   -- Bug 2890177
   --

   OPEN  cur_tot_coa_cnt(p_base_id);
   FETCH cur_tot_coa_cnt INTO tot_coa_cnt_rec;
   CLOSE cur_tot_coa_cnt;

   OPEN  cur_tot_coa_null(p_base_id);
   FETCH cur_tot_coa_null INTO tot_coa_null_rec;
   CLOSE cur_tot_coa_null;

   IF tot_coa_null_rec.pell_coa <> tot_coa_cnt_rec.rec_cnt       AND
      tot_coa_cnt_rec.rec_cnt   = ABS(tot_coa_null_rec.pell_coa) THEN
      tot_coa_rec.pell_coa      := NULL;
   END IF;

   IF tot_coa_null_rec.pell_alt_expense <> tot_coa_cnt_rec.rec_cnt          AND
      tot_coa_cnt_rec.rec_cnt      = ABS(tot_coa_null_rec.pell_alt_expense) THEN
      tot_coa_rec.pell_alt_expense := NULL;
   END IF;

   --
   -- Bug 2890177
   --

   igf_ap_fa_base_rec_pkg.update_row(
                                      x_rowid                          =>  l_stud_det.row_id,
                                      x_base_id                        =>  l_stud_det.base_id,
                                      x_ci_cal_type                    =>  l_stud_det.ci_cal_type,
                                      x_person_id                      =>  l_stud_det.person_id,
                                      x_ci_sequence_number             =>  l_stud_det.ci_sequence_number,
                                      x_org_id                         =>  l_stud_det.org_id,
                                      x_coa_pending                    =>  l_stud_det.coa_pending,
                                      x_verification_process_run       =>  l_stud_det.verification_process_run,
                                      x_inst_verif_status_date         =>  l_stud_det.inst_verif_status_date,
                                      x_manual_verif_flag              =>  l_stud_det.manual_verif_flag,
                                      x_fed_verif_status               =>  l_stud_det.fed_verif_status,
                                      x_fed_verif_status_date          =>  l_stud_det.fed_verif_status_date,
                                      x_inst_verif_status              =>  l_stud_det.inst_verif_status,
                                      x_nslds_eligible                 =>  l_stud_det.nslds_eligible,
                                      x_ede_correction_batch_id        =>  l_stud_det.ede_correction_batch_id,
                                      x_fa_process_status_date         =>  l_stud_det.fa_process_status_date,
                                      x_isir_corr_status               =>  l_stud_det.isir_corr_status,
                                      x_isir_corr_status_date          =>  l_stud_det.isir_corr_status_date,
                                      x_isir_status                    =>  l_stud_det.isir_status,
                                      x_isir_status_date               =>  l_stud_det.isir_status_date,
                                      x_coa_code_f                     =>  NULL,
                                      x_coa_code_i                     =>  NULL,
                                      x_coa_f                          =>  tot_coa_rec.coa_total,
                                      x_coa_i                          =>  tot_coa_rec.coa_total,
                                      x_disbursement_hold              =>  l_stud_det.disbursement_hold,
                                      x_fa_process_status              =>  l_stud_det.fa_process_status,
                                      x_notification_status            =>  l_stud_det.notification_status,
                                      x_notification_status_date       =>  l_stud_det.notification_status_date,
                                      x_packaging_status               =>  l_stud_det.packaging_status,
                                      x_packaging_status_date          =>  l_stud_det.packaging_status_date,
                                      x_total_package_accepted         =>  l_stud_det.total_package_accepted,
                                      x_total_package_offered          =>  l_stud_det.total_package_offered,
                                      x_admstruct_id                   =>  l_stud_det.admstruct_id,
                                      x_admsegment_1                   =>  l_stud_det.admsegment_1,
                                      x_admsegment_2                   =>  l_stud_det.admsegment_2,
                                      x_admsegment_3                   =>  l_stud_det.admsegment_3,
                                      x_admsegment_4                   =>  l_stud_det.admsegment_4,
                                      x_admsegment_5                   =>  l_stud_det.admsegment_5,
                                      x_admsegment_6                   =>  l_stud_det.admsegment_6,
                                      x_admsegment_7                   =>  l_stud_det.admsegment_7,
                                      x_admsegment_8                   =>  l_stud_det.admsegment_8,
                                      x_admsegment_9                   =>  l_stud_det.admsegment_9,
                                      x_admsegment_10                  =>  l_stud_det.admsegment_10,
                                      x_admsegment_11                  =>  l_stud_det.admsegment_11,
                                      x_admsegment_12                  =>  l_stud_det.admsegment_12,
                                      x_admsegment_13                  =>  l_stud_det.admsegment_13,
                                      x_admsegment_14                  =>  l_stud_det.admsegment_14,
                                      x_admsegment_15                  =>  l_stud_det.admsegment_15,
                                      x_admsegment_16                  =>  l_stud_det.admsegment_16,
                                      x_admsegment_17                  =>  l_stud_det.admsegment_17,
                                      x_admsegment_18                  =>  l_stud_det.admsegment_18,
                                      x_admsegment_19                  =>  l_stud_det.admsegment_19,
                                      x_admsegment_20                  =>  l_stud_det.admsegment_20,
                                      x_packstruct_id                  =>  l_stud_det.packstruct_id,
                                      x_packsegment_1                  =>  l_stud_det.packsegment_1,
                                      x_packsegment_2                  =>  l_stud_det.packsegment_2,
                                      x_packsegment_3                  =>  l_stud_det.packsegment_3,
                                      x_packsegment_4                  =>  l_stud_det.packsegment_4,
                                      x_packsegment_5                  =>  l_stud_det.packsegment_5,
                                      x_packsegment_6                  =>  l_stud_det.packsegment_6,
                                      x_packsegment_7                  =>  l_stud_det.packsegment_7,
                                      x_packsegment_8                  =>  l_stud_det.packsegment_8,
                                      x_packsegment_9                  =>  l_stud_det.packsegment_9,
                                      x_packsegment_10                 =>  l_stud_det.packsegment_10,
                                      x_packsegment_11                 =>  l_stud_det.packsegment_11,
                                      x_packsegment_12                 =>  l_stud_det.packsegment_12,
                                      x_packsegment_13                 =>  l_stud_det.packsegment_13,
                                      x_packsegment_14                 =>  l_stud_det.packsegment_14,
                                      x_packsegment_15                 =>  l_stud_det.packsegment_15,
                                      x_packsegment_16                 =>  l_stud_det.packsegment_16,
                                      x_packsegment_17                 =>  l_stud_det.packsegment_17,
                                      x_packsegment_18                 =>  l_stud_det.packsegment_18,
                                      x_packsegment_19                 =>  l_stud_det.packsegment_19,
                                      x_packsegment_20                 =>  l_stud_det.packsegment_20,
                                      x_miscstruct_id                  =>  l_stud_det.miscstruct_id,
                                      x_miscsegment_1                  =>  l_stud_det.miscsegment_1,
                                      x_miscsegment_2                  =>  l_stud_det.miscsegment_2,
                                      x_miscsegment_3                  =>  l_stud_det.miscsegment_3,
                                      x_miscsegment_4                  =>  l_stud_det.miscsegment_4,
                                      x_miscsegment_5                  =>  l_stud_det.miscsegment_5,
                                      x_miscsegment_6                  =>  l_stud_det.miscsegment_6,
                                      x_miscsegment_7                  =>  l_stud_det.miscsegment_7,
                                      x_miscsegment_8                  =>  l_stud_det.miscsegment_8,
                                      x_miscsegment_9                  =>  l_stud_det.miscsegment_9,
                                      x_miscsegment_10                 =>  l_stud_det.miscsegment_10,
                                      x_miscsegment_11                 =>  l_stud_det.miscsegment_11,
                                      x_miscsegment_12                 =>  l_stud_det.miscsegment_12,
                                      x_miscsegment_13                 =>  l_stud_det.miscsegment_13,
                                      x_miscsegment_14                 =>  l_stud_det.miscsegment_14,
                                      x_miscsegment_15                 =>  l_stud_det.miscsegment_15,
                                      x_miscsegment_16                 =>  l_stud_det.miscsegment_16,
                                      x_miscsegment_17                 =>  l_stud_det.miscsegment_17,
                                      x_miscsegment_18                 =>  l_stud_det.miscsegment_18,
                                      x_miscsegment_19                 =>  l_stud_det.miscsegment_19,
                                      x_miscsegment_20                 =>  l_stud_det.miscsegment_20,
                                      x_prof_judgement_flg             =>  l_stud_det.prof_judgement_flg,
                                      x_nslds_data_override_flg        =>  l_stud_det.nslds_data_override_flg ,
                                      x_target_group                   =>  l_stud_det.target_group,
                                      x_coa_fixed                      =>  tot_coa_rec.fixed_coa,
                                      x_coa_pell                       =>  tot_coa_rec.pell_coa,
                                      x_profile_status                 =>  l_stud_det.profile_status,
                                      x_profile_status_date            =>  l_stud_det.profile_status_date,
                                      x_profile_fc                     =>  l_stud_det.profile_fc,
                                      x_tolerance_amount               =>  l_stud_det.tolerance_amount,
                                      x_pell_alt_expense               =>  tot_coa_rec.pell_alt_expense,
                                      x_manual_disb_hold               =>  l_stud_det.manual_disb_hold,
                                      x_mode                           =>  'R',
                                      x_assoc_org_num                  =>  l_stud_det.assoc_org_num,
                                      x_award_fmly_contribution_type   =>  l_stud_det.award_fmly_contribution_type,
                                      x_isir_locked_by                 =>  l_stud_det.isir_locked_by,
                                      x_adnl_unsub_loan_elig_flag      =>  l_stud_det.adnl_unsub_loan_elig_flag,
                                      x_lock_coa_flag                  =>  l_stud_det.lock_coa_flag,
                                      x_lock_awd_flag                  =>  l_stud_det.lock_awd_flag
                                      );

EXCEPTION

WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_AW_GEN_003.UPDATING_COA_IN_FA_BASE'||' ' ||SQLERRM);
   app_exception.raise_exception;

END updating_coa_in_fa_base;

PROCEDURE round_off_disbursements(
                                    p_fund_id             IN  igf_aw_award_t_all.fund_id%TYPE,
                                    p_award_id            IN  igf_aw_award_t_all.award_id%TYPE,
                                    p_offered_amt         IN  igf_aw_award_t_all.offered_amt%TYPE,
                                    p_award_status        IN  igf_aw_award_all.award_status%TYPE,
                                    p_dist_plan_code      IN  igf_aw_awd_dist_plans.dist_plan_method_code%TYPE,
                                    p_disb_count          IN  NUMBER
                                  )
IS
      /*
      ||  Created By : bvisvana
      ||  Created On : 01-July-2005
      ||  Purpose :
      ||
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             WHEN            What
      ||  museshad        27-Sep-2005     Bug 4608591.
      ||                                  Modified the cursor cur_get_all_disb
      ||                                  so that it ignores cancelled disb.
      ||  (reverse chronological order - newest change first)
      */

    -- Returns all the disbursements for an award
    -- The ORDER BY clause ensures that the disbursements are returned in the order of their creation
    CURSOR cur_get_all_disb (p_award_id igf_aw_award_all.award_id%TYPE)
    IS
        SELECT disb.rowid, disb.*
        FROM igf_aw_awd_disb disb
        WHERE
              award_id = p_award_id AND
              trans_type <> 'C'
              ORDER BY disb_num ;

    l_disb_amt            NUMBER(12,3)  := 0;
    l_disb_prelim_amt     NUMBER(12,3)  := 0;
    l_disb_amt_extra      NUMBER(12,3)  := 0;
    l_disb_inter_sum_amt  NUMBER(12,3)  := 0;
    l_disb_diff           NUMBER        := 0;
    l_trunc_factor        NUMBER        := 0;
    l_extra_factor        NUMBER        := 0;
    l_disb_no             NUMBER        := 0;
    l_special_disb_no     NUMBER        := 0;
    l_disb_limit1         NUMBER        := 0;
    l_disb_limit2         NUMBER        := 0;
    l_step                NUMBER        := 0;
    l_accepted_amt        NUMBER(12,3)  := 0;
    l_disb_round_factor   igf_aw_fund_mast.disb_rounding_code%TYPE;

  TYPE l_disb_structure IS RECORD(
                                   fund_id    igf_aw_fund_mast.fund_id%TYPE,
                                   disb_num   NUMBER,
                                   disb_amt   NUMBER
                                 );
  TYPE l_disb_structure_tab IS TABLE OF l_disb_structure INDEX BY BINARY_INTEGER;
  l_disb_structure_rec l_disb_structure_tab;

  -- Get fed fund code
  CURSOR cur_get_fund  (p_fund_id NUMBER)
  IS
  SELECT fcat.fed_fund_code
  FROM   igf_aw_fund_cat fcat,
         igf_aw_fund_mast fmast
 WHERE   fcat.fund_code = fmast.fund_code
   AND   fmast.fund_id = p_fund_id;

  get_fund_rec cur_get_fund%ROWTYPE;
  l_disb_net_amt NUMBER(12,3) := 0;

BEGIN
    l_disb_round_factor := igf_aw_packaging.get_disb_round_factor(p_fund_id);

    OPEN cur_get_fund(p_fund_id => p_fund_id);
    FETCH cur_get_fund INTO get_fund_rec;
    CLOSE cur_get_fund;

    IF  l_disb_round_factor IN ('ONE_FIRST','DEC_FIRST','ONE_LAST','DEC_LAST') THEN  -- disb_round_factor

        -- Log useful values
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.round_off_disbursements.debug ','ROUND FACTOR = '||l_disb_round_factor);
        END IF;

        -- Set the attributes common to ONEs rounding factor
        IF l_disb_round_factor = 'ONE_FIRST' OR l_disb_round_factor = 'ONE_LAST' THEN
          l_trunc_factor      :=    0;
          l_extra_factor      :=    1;
        -- Set the attributes common to DECIMALs rounding factor
        ELSIF l_disb_round_factor = 'DEC_FIRST' OR l_disb_round_factor = 'DEC_LAST' THEN
          l_trunc_factor      :=    2;
          l_extra_factor      :=    0.01;
        END IF;

        -- Set the attributes common to FIRST rounding factor
        IF l_disb_round_factor = 'ONE_FIRST' OR l_disb_round_factor = 'DEC_FIRST' THEN
          IF UPPER(p_dist_plan_code) = 'E' THEN
            l_disb_limit1     :=    1;
            l_disb_limit2     :=    p_disb_count;
            l_step            :=    1;
            l_disb_no         :=    l_disb_limit1;
         ELSIF UPPER(p_dist_plan_code) IN ('C', 'M') THEN
            l_special_disb_no :=    1;
          END IF;

        -- Set the attributes common to LAST rounding factor
        ELSIF l_disb_round_factor = 'ONE_LAST' OR l_disb_round_factor = 'DEC_LAST' THEN
          IF UPPER(p_dist_plan_code) = 'E' THEN
            l_disb_limit1     :=    1;
            l_disb_limit2     :=    p_disb_count;
            l_step            :=    -1;
            l_disb_no         :=    l_disb_limit2;
          ELSIF UPPER(p_dist_plan_code) IN ('C', 'M') THEN
            l_special_disb_no :=    p_disb_count;
          END IF;
        END IF;

        -- Equal Distribution
        IF UPPER(p_dist_plan_code) = 'E' THEN                              -- p_dist_plan_code

            IF get_fund_rec.fed_fund_code <> 'PELL'  THEN
              -- Normal disbursement amount
              l_disb_amt := TRUNC(NVL((p_offered_amt/p_disb_count), 0), l_trunc_factor);
              -- Preliminary disbursement amount
              l_disb_prelim_amt := TRUNC(NVL((p_offered_amt - (l_disb_amt * (p_disb_count-1))), 0), l_trunc_factor);
              -- Difference in disbursement amount
              l_disb_diff := TRUNC(NVL((l_disb_prelim_amt - l_disb_amt), 0), l_trunc_factor);
              -- Extra disbursement amount
              IF l_disb_diff > 0 THEN
                  l_disb_amt_extra := TRUNC(NVL((l_disb_amt + l_extra_factor), 0), l_trunc_factor);
              ELSIF l_disb_diff < 0 THEN
                  l_disb_amt_extra := TRUNC(NVL((l_disb_amt - l_extra_factor), 0), l_trunc_factor);
              ELSE
                  l_disb_amt_extra := TRUNC(NVL(l_disb_amt, 0), l_trunc_factor);
              END IF;

              -- Get the absolute difference value between preliminary and normal disbursement amount
              l_disb_diff := ABS(l_disb_diff);

              -- Calculate each disbursement and distribute the extra
              -- amount starting from the first/last disbursement
              WHILE l_disb_no BETWEEN l_disb_limit1 AND l_disb_limit2
              LOOP
                  l_disb_structure_rec(l_disb_no).disb_num    :=  l_disb_no;

                  IF l_disb_diff >= l_extra_factor THEN
                      l_disb_structure_rec(l_disb_no).disb_amt    :=  l_disb_amt_extra;
                      l_disb_diff := NVL((l_disb_diff - l_extra_factor), 0);
                  ELSE
                      l_disb_structure_rec(l_disb_no).disb_amt    :=  l_disb_amt;
                  END IF;

                  l_disb_no := NVL(l_disb_no, 0) + l_step;

                  -- Log useful values
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.round_off_disbursements.debug ','l_disb_no = '||l_disb_no);
                  END IF;
              END LOOP;
            END IF;

        -- Match COA/Manual Distribution
        ELSIF UPPER(p_dist_plan_code) IN ('C', 'M') THEN
          -- Initialize disbursement counter
          l_disb_no := 1;
          -- Loop thru all the disbursement records and round the disbursement amount
          FOR l_disb_rec_all IN cur_get_all_disb(p_award_id)
          LOOP
              -- Skip the first/last disbursement
              IF l_disb_no <> l_special_disb_no THEN
                  -- Calculate disbursement amount truncated to correct decimal place
                  l_disb_amt := TRUNC(NVL(l_disb_rec_all.disb_gross_amt, 0), l_trunc_factor);
                  -- Add the disbursement to PL/SQL table
                  l_disb_structure_rec(l_disb_no).disb_num    :=  l_disb_no;
                  l_disb_structure_rec(l_disb_no).disb_amt    :=  l_disb_amt;

                  l_disb_inter_sum_amt := NVL((l_disb_inter_sum_amt + l_disb_amt), 0);

                  -- Log useful values
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_gen_003.round_off_disbursements.debug ',
                                                            'Disbursement number: '||l_disb_structure_rec(l_disb_no).disb_num ||
                                                            'Disbursement amount: ' ||  to_char(l_disb_structure_rec(l_disb_no).disb_amt));
                  END IF;
             END IF;
             l_disb_no := NVL(l_disb_no, 0) + 1;
          END LOOP;

          -- Calculate first/last disbursement. Unlike other disbursements,
          l_disb_amt := TRUNC(NVL((p_offered_amt - l_disb_inter_sum_amt), 0), l_trunc_factor);

          -- Add the first/last disbursement to PL/SQL table
          l_disb_structure_rec(l_special_disb_no).disb_num    :=  l_special_disb_no;
          l_disb_structure_rec(l_special_disb_no).disb_amt    :=  l_disb_amt;

          -- Log useful values
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          ' igf.plsql.igf_aw_gen_003.round_off_disbursements.debug ',
                          ' Disbursement number: '|| l_disb_structure_rec(l_special_disb_no).disb_num ||
                          ' Disbursement amount: ' ||  to_char(l_disb_structure_rec(l_special_disb_no).disb_amt));
          END IF;

        END IF; -- End of p_dist_plan_code
    END IF; -- End of disb_round_factor

    -- All the rounded disbursement amounts are now available in the RECORD
    -- Update these to the disbursement table
    l_disb_no := 0;
    FOR l_disb_rec IN cur_get_all_disb(p_award_id)
    LOOP
        -- Get all disbursements
        l_disb_no := NVL(l_disb_no, 0) + 1;

        -- Check if the PL/SQL table has got a valid value for that disbursement number
        IF l_disb_structure_rec.EXISTS(l_disb_no) THEN        -- Disbursement existence check

            -- If the Status is accepted then disb_accepted_amt = the new disb amt after rounding
            IF p_award_status = 'ACCEPTED' THEN
                l_accepted_amt := NVL(l_disb_structure_rec(l_disb_no).disb_amt,0);
            END IF;

            l_disb_net_amt := NVL(l_disb_structure_rec(l_disb_no).disb_amt,0) -
                              NVL(l_disb_rec.fee_1,0)          -
                              NVL(l_disb_rec.fee_2,0)          +
                              NVL(l_disb_rec.fee_paid_1,0)     +
                              NVL(l_disb_rec.fee_paid_2,0)     +
                              NVL(l_disb_rec.int_rebate_amt,0);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,
                            ' igf.plsql.igf_aw_gen_003.round_off_disbursements.debug ',
                            'Disbursement amounts before and after applying rounding logic');

              fnd_log.string(fnd_log.level_statement,
                            'igf.plsql.igf_aw_packaging.round_off_disbursements.debug ',
                            ' Disbursement number: ' ||l_disb_no||
                            ' Old Disbursement amount: ' ||l_disb_rec.disb_gross_amt||
                            ' New disbursement amount after applying rounding logic: ' ||NVL(l_disb_structure_rec(l_disb_no).disb_amt, 0));
            END IF;

            igf_aw_awd_disb_pkg.update_row(
                                            x_rowid                    => l_disb_rec.rowid ,
                                            x_award_id                 => l_disb_rec.award_id ,
                                            x_disb_num                 => l_disb_rec.disb_num ,
                                            x_tp_cal_type              => l_disb_rec.tp_cal_type,
                                            x_tp_sequence_number       => l_disb_rec.tp_sequence_number ,
                                            x_disb_gross_amt           => NVL(l_disb_structure_rec(l_disb_no).disb_amt,0),
                                            x_fee_1                    => l_disb_rec.fee_1 ,
                                            x_fee_2                    => l_disb_rec.fee_2 ,
                                            x_disb_net_amt             => l_disb_net_amt ,
                                            x_disb_date                => l_disb_rec.disb_date ,
                                            x_trans_type               => l_disb_rec.trans_type ,
                                            x_elig_status              => l_disb_rec.elig_status ,
                                            x_elig_status_date         => l_disb_rec.elig_status_date ,
                                            x_affirm_flag              => l_disb_rec.affirm_flag ,
                                            x_hold_rel_ind             => l_disb_rec.hold_rel_ind ,
                                            x_manual_hold_ind          => l_disb_rec.manual_hold_ind ,
                                            x_disb_status              => l_disb_rec.disb_status ,
                                            x_disb_status_date         => l_disb_rec.disb_status_date ,
                                            x_late_disb_ind            => l_disb_rec.late_disb_ind ,
                                            x_fund_dist_mthd           => l_disb_rec.fund_dist_mthd ,
                                            x_prev_reported_ind        => l_disb_rec.prev_reported_ind ,
                                            x_fund_release_date        => l_disb_rec.fund_release_date ,
                                            x_fund_status              => l_disb_rec.fund_status ,
                                            x_fund_status_date         => l_disb_rec.fund_status_date ,
                                            x_fee_paid_1               => l_disb_rec.fee_paid_1 ,
                                            x_fee_paid_2               => l_disb_rec.fee_paid_2 ,
                                            x_cheque_number            => l_disb_rec.cheque_number ,
                                            x_ld_cal_type              => l_disb_rec.ld_cal_type ,
                                            x_ld_sequence_number       => l_disb_rec.ld_sequence_number ,
                                            x_disb_accepted_amt        => l_accepted_amt  ,
                                            x_disb_paid_amt            => l_disb_rec.disb_paid_amt  ,
                                            x_rvsn_id                  => l_disb_rec.rvsn_id ,
                                            x_int_rebate_amt           => l_disb_rec.int_rebate_amt ,
                                            x_force_disb               => l_disb_rec.force_disb ,
                                            x_min_credit_pts           => l_disb_rec.min_credit_pts ,
                                            x_disb_exp_dt              => l_disb_rec.disb_exp_dt  ,
                                            x_verf_enfr_dt             => l_disb_rec.verf_enfr_dt ,
                                            x_fee_class                => l_disb_rec.fee_class ,
                                            x_show_on_bill             => l_disb_rec.show_on_bill ,
                                            x_mode                     => 'R' ,
                                            x_attendance_type_code     => l_disb_rec.attendance_type_code ,
                                            x_base_attendance_type_code=> l_disb_rec.base_attendance_type_code ,
                                            x_payment_prd_st_date      => l_disb_rec.payment_prd_st_date ,
                                            x_change_type_code         => l_disb_rec.change_type_code ,
                                            x_fund_return_mthd_code    => l_disb_rec.fund_return_mthd_code,
                                            x_direct_to_borr_flag      => l_disb_rec.direct_to_borr_flag
                                            );
        END IF;             -- End of Disbursement existence check
    END LOOP;               -- End of Get all disbursements loop
END round_off_disbursements;

PROCEDURE create_auto_disb(  p_fund_id      IN  igf_aw_award.fund_id%TYPE,
                             p_award_id     IN  igf_aw_award.award_id%TYPE,
                             p_offered_amt  IN  igf_aw_award.offered_amt%TYPE,
                             p_award_status IN  igf_aw_award.award_status%TYPE,
                             p_adplans_id   IN  igf_aw_awd_dist_plans.adplans_id%TYPE,
                             p_method_code  IN  igf_aw_awd_dist_plans.dist_plan_method_code%TYPE,
                             p_awd_prd_code IN  igf_aw_awd_prd_term.award_prd_cd%TYPE
                            )
AS
  /*
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || museshad         24-Apr-2006   Bug 5116534.
  ||                                1. Modified cursor cur_nslds_hist to chk for
  ||                                   valid nslds_loan_prog_code_1 data.
  ||                                2. Modified the logic used to derive lb_nslds_ind
  || museshad         27-Sep-2005   Bug 4608591.
  ||                                Implemented repackaging of awards.
  || museshad         26-Aug-2005   Join condition was incorrect in the cursor
  ||                                'cur_terms_count'. Corrected this.
  || veramach         22-Dec-2004   bug 4077735 - Added a check to see if there are common terms
  ||                                when awarding without COA
  ||  veramach        12-Oct-2004   FA 152 - changed signature to include p_awd_prd_code
  ||  bkkumar         02-04-04      FACR116 - Added the new paramter p_alt_rel_code to the
  ||                                get_loan_fee1 , get_loan_fee2 , get_cl_hold_rel_ind
  ||                                , get_cl_auto_late_ind
  ||  veramach        17-NOV-2003   FA 125 added 2 new parameters - adplans_id,dist_plan_method_code
  ||  bkkumar         30-sep-03     Added base_id to the get_loan_fee1 and
  ||                                get_loan_fee2 and added call to get_cl_hold_rel_ind
  ||                                , get_cl_auto_late_ind
  ||  (reverse chronological order - newest change first)
  */

  --cursor to get fund details
  CURSOR cur_get_fund_dtls(
                           cp_fund_id igf_aw_award.fund_id%TYPE
                          ) IS
    SELECT fcat.fund_code,
           fcat.fed_fund_code,
           fund.disb_exp_da,
           fund.ci_cal_type awd_cal_type,
           fund.ci_sequence_number awd_sequence_number,
           fund.disb_verf_da,
           fund.show_on_bill,
           fund.nslds_disb_da
      FROM igf_aw_fund_mast fund,
           igf_aw_fund_cat  fcat
     WHERE fund_id = cp_fund_id
       AND fund.fund_code = fcat.fund_code;
  l_get_fund_dtls cur_get_fund_dtls%ROWTYPE;

--
-- Cursor to Create Disbursement Records
-- Please note that disb_dt, the first field is needed for
-- ordering disbursement records by disbursement dates
-- This is used only in case the distribution method is MANUAL
--
CURSOR c_auto_disb(
                   cp_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                   cp_adplans_id   igf_aw_awd_dist_plans.adplans_id%TYPE,
                   cp_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                  ) IS
  SELECT NVL(igf_aw_packaging.get_date_instance(cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
         terms.ld_cal_type ld_cal_type,
         terms.ld_sequence_number ld_sequence_number,
         teach_periods.tp_cal_type tp_cal_type,
         teach_periods.tp_sequence_number tp_sequence_number,
         (teach_periods.tp_perct_num * terms.ld_perct_num)/100 perct,
         teach_periods.start_date start_dt,
         teach_periods.date_offset_cd tp_offset_da,
         teach_periods.credit_points_num min_credit_points,
         teach_periods.attendance_type_code attendance_type_code
    FROM igf_aw_dp_terms        terms,
         igf_aw_dp_teach_prds_v teach_periods,
         (SELECT base_id,
                 ld_cal_type,
                 ld_sequence_number
            FROM igf_aw_coa_itm_terms
           WHERE base_id = cp_base_id
           GROUP BY base_id,ld_cal_type, ld_sequence_number) coaterms,
         igf_aw_awd_dist_plans dp,
         igf_aw_awd_prd_term aprd
   WHERE terms.adplans_id = cp_adplans_id
     AND terms.adterms_id = teach_periods.adterms_id
     AND coaterms.ld_cal_type = terms.ld_cal_type
     AND coaterms.ld_sequence_number = terms.ld_sequence_number
     AND coaterms.base_id = cp_base_id
     AND terms.adplans_id = dp.adplans_id
     AND dp.cal_type   = aprd.ci_cal_type
     AND dp.sequence_number = aprd.ci_sequence_number
     AND aprd.award_prd_cd = cp_awd_prd_code
     AND coaterms.ld_cal_type = aprd.ld_cal_type
     AND coaterms.ld_sequence_number = aprd.ld_sequence_number
   ORDER BY 1;

 lc_auto_disb   c_auto_disb%ROWTYPE;


--
-- Awarding WITHOUT COA, Manual Method
--

CURSOR c_auto_disb_wcoa(
                        cp_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                        cp_adplans_id   igf_aw_awd_dist_plans.adplans_id%TYPE,
                        cp_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                       ) IS
  SELECT NVL(igf_aw_packaging.get_date_instance(cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
         terms.ld_cal_type ld_cal_type,
         terms.ld_sequence_number ld_sequence_number,
         teach_periods.tp_cal_type tp_cal_type,
         teach_periods.tp_sequence_number tp_sequence_number,
         (teach_periods.tp_perct_num * terms.ld_perct_num)/100 perct,
         teach_periods.start_date start_dt,
         teach_periods.date_offset_cd tp_offset_da,
         teach_periods.credit_points_num min_credit_points,
         teach_periods.attendance_type_code attendance_type_code
    FROM igf_aw_dp_terms        terms,
         igf_aw_dp_teach_prds_v teach_periods,
         igf_aw_awd_prd_term aprd,
         igf_aw_awd_dist_plans dp
   WHERE terms.adplans_id = cp_adplans_id
     AND terms.adterms_id = teach_periods.adterms_id
     AND terms.ld_cal_type = aprd.ld_cal_type
     AND terms.ld_sequence_number = aprd.ld_sequence_number
     AND aprd.award_prd_cd = cp_awd_prd_code
     AND dp.adplans_id = terms.adplans_id
     AND dp.cal_type = aprd.ci_cal_type
     AND dp.sequence_number = aprd.ci_sequence_number
   ORDER BY 1;

 --
 -- cursor to create disbursment records
 -- this cursor is used in case the distribution method is EQUAL
 --

CURSOR c_auto_disb_equal(
                         cp_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                         cp_adplans_id   igf_aw_awd_dist_plans.adplans_id%TYPE,
                         cp_num_terms    NUMBER,
                         cp_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                        ) IS
  SELECT NVL(igf_aw_packaging.get_date_instance (cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
         terms.ld_cal_type ld_cal_type,
         terms.ld_sequence_number ld_sequence_number,
         teach_periods.tp_cal_type tp_cal_type,
         teach_periods.tp_sequence_number tp_sequence_number,
         teach_periods.tp_perct_num/cp_num_terms perct,
         teach_periods.start_date start_dt,
         teach_periods.date_offset_cd tp_offset_da,
         teach_periods.credit_points_num min_credit_points,
         teach_periods.attendance_type_code attendance_type_code
    FROM igf_aw_dp_terms        terms,
         igf_aw_dp_teach_prds_v teach_periods,
         (SELECT base_id,
                 ld_cal_type,
                 ld_sequence_number
            FROM igf_aw_coa_itm_terms
           WHERE base_id = cp_base_id
           GROUP BY base_id,ld_cal_type,ld_sequence_number) coaterms,
         igf_aw_awd_dist_plans dp,
         igf_aw_awd_prd_term aprd
   WHERE terms.adplans_id = cp_adplans_id
     AND terms.adterms_id = teach_periods.adterms_id
     AND coaterms.ld_cal_type = terms.ld_cal_type
     AND coaterms.ld_sequence_number = terms.ld_sequence_number
     AND coaterms.base_id = cp_base_id
     AND terms.adplans_id = dp.adplans_id
     AND dp.cal_type = aprd.ci_cal_type
     AND dp.sequence_number = aprd.ci_sequence_number
     AND coaterms.ld_cal_type = aprd.ld_cal_type
     AND coaterms.ld_sequence_number = aprd.ld_sequence_number
     AND aprd.award_prd_cd = cp_awd_prd_code
   ORDER BY 1;

 --
 -- Adding UNION clause to take care of Awarding without COA
 --
CURSOR c_auto_disb_equal_wcoa(
                              cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                              cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                              cp_num_terms  NUMBER,
                              cp_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                             ) IS
  SELECT NVL(igf_aw_packaging.get_date_instance (cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
         terms.ld_cal_type ld_cal_type,
         terms.ld_sequence_number ld_sequence_number,
         teach_periods.tp_cal_type tp_cal_type,
         teach_periods.tp_sequence_number tp_sequence_number,
         teach_periods.tp_perct_num/cp_num_terms perct,
         teach_periods.start_date start_dt,
         teach_periods.date_offset_cd tp_offset_da,
         teach_periods.credit_points_num min_credit_points,
         teach_periods.attendance_type_code attendance_type_code
    FROM igf_aw_dp_terms        terms,
         igf_aw_dp_teach_prds_v teach_periods,
         igf_aw_awd_dist_plans dp,
         igf_aw_awd_prd_term aprd
   WHERE terms.adplans_id = cp_adplans_id
     AND terms.adterms_id = teach_periods.adterms_id
     AND terms.adplans_id = dp.adplans_id
     AND dp.cal_type      = aprd.ci_cal_type
     AND dp.sequence_number = aprd.ci_sequence_number
     AND aprd.award_prd_cd = cp_awd_prd_code
     AND aprd.ld_cal_type = terms.ld_cal_type
     AND aprd.ld_sequence_number = terms.ld_sequence_number
   ORDER BY 1;

--cursor to create disbursment records
--this cursor is used if distribution method is MATCH COA
CURSOR c_auto_disb_coa_match(
                             cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                             cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                             cp_total_coa_amount NUMBER,
                             cp_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                            ) IS
  SELECT NVL(igf_aw_packaging.get_date_instance (cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
         terms.ld_cal_type ld_cal_type,
         terms.ld_sequence_number ld_sequence_number,
         teach_periods.tp_cal_type tp_cal_type,
         teach_periods.tp_sequence_number tp_sequence_number,
         (coa_term_amount/cp_total_coa_amount) * teach_periods.tp_perct_num perct,
         teach_periods.start_date start_dt,
         teach_periods.date_offset_cd tp_offset_da,
         teach_periods.credit_points_num min_credit_points,
         teach_periods.attendance_type_code attendance_type_code
    FROM igf_aw_dp_terms        terms,
         igf_aw_dp_teach_prds_v teach_periods,
         (SELECT base_id,
                 ld_cal_type,
                 ld_sequence_number,
                 amount coa_term_amount
            FROM igf_aw_coa_term_tot_v
           WHERE base_id = cp_base_id) coaterms,
         igf_aw_awd_dist_plans dp,
         igf_aw_awd_prd_term aprd
   WHERE terms.adplans_id = cp_adplans_id
     AND terms.adterms_id = teach_periods.adterms_id
     AND coaterms.ld_cal_type = terms.ld_cal_type
     AND coaterms.ld_sequence_number = terms.ld_sequence_number
     AND coaterms.base_id = cp_base_id
     AND dp.adplans_id = terms.adplans_id
     AND dp.cal_type = aprd.ci_cal_type
     AND dp.sequence_number = aprd.ci_sequence_number
     AND aprd.award_prd_cd = cp_awd_prd_code
     AND aprd.ld_cal_type = coaterms.ld_cal_type
     AND aprd.ld_sequence_number = coaterms.ld_sequence_number
   ORDER BY 1;
-------------bug 4077735----------------------
CURSOR c_auto_disb_pell(
                        cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                        cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                       ) IS
  SELECT NVL(igf_aw_packaging.get_date_instance(cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
         terms.ld_cal_type ld_cal_type,
         terms.ld_sequence_number ld_sequence_number,
         teach_periods.tp_cal_type tp_cal_type,
         teach_periods.tp_sequence_number tp_sequence_number,
         (teach_periods.tp_perct_num * terms.ld_perct_num)/100 perct,
         teach_periods.start_date start_dt,
         teach_periods.date_offset_cd tp_offset_da,
         teach_periods.credit_points_num min_credit_points,
         teach_periods.attendance_type_code attendance_type_code
    FROM igf_aw_dp_terms        terms,
         igf_aw_dp_teach_prds_v teach_periods,
         (SELECT base_id,
                 ld_cal_type,
                 ld_sequence_number
            FROM igf_aw_coa_itm_terms
           WHERE base_id = cp_base_id
           GROUP BY base_id,ld_cal_type, ld_sequence_number) coaterms
   WHERE terms.adplans_id = cp_adplans_id
     AND terms.adterms_id = teach_periods.adterms_id
     AND coaterms.ld_cal_type = terms.ld_cal_type
     AND coaterms.ld_sequence_number = terms.ld_sequence_number
     AND coaterms.base_id = cp_base_id
   ORDER BY 1;


--
-- Awarding WITHOUT COA, Manual Method
--

CURSOR c_auto_disb_wcoa_pell(
                             cp_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                             cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                            ) IS
  SELECT NVL(igf_aw_packaging.get_date_instance(cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
         terms.ld_cal_type ld_cal_type,
         terms.ld_sequence_number ld_sequence_number,
         teach_periods.tp_cal_type tp_cal_type,
         teach_periods.tp_sequence_number tp_sequence_number,
         (teach_periods.tp_perct_num * terms.ld_perct_num)/100 perct,
         teach_periods.start_date start_dt,
         teach_periods.date_offset_cd tp_offset_da,
         teach_periods.credit_points_num min_credit_points,
         teach_periods.attendance_type_code attendance_type_code
    FROM igf_aw_dp_terms        terms,
         igf_aw_dp_teach_prds_v teach_periods
   WHERE terms.adplans_id = cp_adplans_id
     AND terms.adterms_id = teach_periods.adterms_id
   ORDER BY 1;

 --
 -- cursor to create disbursment records
 -- this cursor is used in case the distribution method is EQUAL
 --

CURSOR c_auto_disb_equal_pell(
                              cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                              cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                              cp_num_terms  NUMBER
                             ) IS
  SELECT NVL(igf_aw_packaging.get_date_instance(cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
         terms.ld_cal_type ld_cal_type,
         terms.ld_sequence_number ld_sequence_number,
         teach_periods.tp_cal_type tp_cal_type,
         teach_periods.tp_sequence_number tp_sequence_number,
         teach_periods.tp_perct_num/cp_num_terms perct,
         teach_periods.start_date start_dt,
         teach_periods.date_offset_cd tp_offset_da,
         teach_periods.credit_points_num min_credit_points,
         teach_periods.attendance_type_code attendance_type_code
    FROM igf_aw_dp_terms        terms,
         igf_aw_dp_teach_prds_v teach_periods,
         (SELECT base_id,
                 ld_cal_type,
                 ld_sequence_number
            FROM igf_aw_coa_itm_terms
           WHERE base_id = cp_base_id
           GROUP BY base_id,ld_cal_type,ld_sequence_number) coaterms
   WHERE terms.adplans_id = cp_adplans_id
     AND terms.adterms_id = teach_periods.adterms_id
     AND coaterms.ld_cal_type = terms.ld_cal_type
     AND coaterms.ld_sequence_number = terms.ld_sequence_number
     AND coaterms.base_id = cp_base_id
   ORDER BY 1;


CURSOR c_auto_disb_equal_wcoa_pell(
                                   cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                                   cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                                   cp_num_terms  NUMBER
                                  ) IS
  SELECT NVL(igf_aw_packaging.get_date_instance(cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
         terms.ld_cal_type ld_cal_type,
         terms.ld_sequence_number ld_sequence_number,
         teach_periods.tp_cal_type tp_cal_type,
         teach_periods.tp_sequence_number tp_sequence_number,
         teach_periods.tp_perct_num/cp_num_terms perct,
         teach_periods.start_date start_dt,
         teach_periods.date_offset_cd tp_offset_da,
         teach_periods.credit_points_num min_credit_points,
         teach_periods.attendance_type_code attendance_type_code
    FROM igf_aw_dp_terms        terms,
         igf_aw_dp_teach_prds_v teach_periods
   WHERE terms.adplans_id = cp_adplans_id
     AND terms.adterms_id = teach_periods.adterms_id
   ORDER BY 1;

--cursor to create disbursment records
--this cursor is used if distribution method is MATCH COA
CURSOR c_auto_disb_coa_match_pell(
                                  cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                                  cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                                  cp_total_coa_amount NUMBER
                                 ) IS
  SELECT NVL(igf_aw_packaging.get_date_instance(cp_base_id,teach_periods.date_offset_cd,terms.ld_cal_type,terms.ld_sequence_number),teach_periods.start_date) disb_dt,
         terms.ld_cal_type ld_cal_type,
         terms.ld_sequence_number ld_sequence_number,
         teach_periods.tp_cal_type tp_cal_type,
         teach_periods.tp_sequence_number tp_sequence_number,
         (coa_term_amount/cp_total_coa_amount) * teach_periods.tp_perct_num perct,
         teach_periods.start_date start_dt,
         teach_periods.date_offset_cd tp_offset_da,
         teach_periods.credit_points_num min_credit_points,
         teach_periods.attendance_type_code attendance_type_code
    FROM igf_aw_dp_terms        terms,
         igf_aw_dp_teach_prds_v teach_periods,
         (SELECT base_id,
                 ld_cal_type,
                 ld_sequence_number,
                 amount coa_term_amount
            FROM igf_aw_coa_term_tot_v
           WHERE base_id = cp_base_id) coaterms
   WHERE terms.adplans_id = cp_adplans_id
     AND terms.adterms_id = teach_periods.adterms_id
     AND coaterms.ld_cal_type = terms.ld_cal_type
     AND coaterms.ld_sequence_number = terms.ld_sequence_number
     AND coaterms.base_id = cp_base_id
   ORDER BY 1;

CURSOR cur_terms_count_pell(
                            cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                            cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                           ) IS
  SELECT COUNT(*)
    FROM igf_aw_dp_terms terms,
         (SELECT base_id,
                 ld_cal_type,
                 ld_sequence_number
            FROM igf_aw_coa_itm_terms
           WHERE base_id = cp_base_id
           GROUP BY base_id,ld_cal_type,ld_sequence_number) coaterms
   WHERE terms.adplans_id            = cp_adplans_id
     AND coaterms.ld_cal_type        = terms.ld_cal_type
     AND coaterms.ld_sequence_number = terms.ld_sequence_number
     AND coaterms.base_id            = cp_base_id;

CURSOR cur_terms_count_wcoa_pell(
                                 cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                                ) IS
  SELECT COUNT(*)
    FROM igf_aw_dp_terms terms
   WHERE terms.adplans_id = cp_adplans_id;

CURSOR c_coa_pell(
                  cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                  cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                 ) IS
  SELECT SUM(amount) coa
    FROM igf_aw_coa_itm_terms coa_terms,
         (SELECT ld_cal_type,
                 ld_sequence_number
            FROM igf_aw_dp_terms
           WHERE adplans_id = cp_adplans_id
         )dist_terms
  WHERE dist_terms.ld_cal_type = coa_terms.ld_cal_type
    AND dist_terms.ld_sequence_number = coa_terms.ld_sequence_number
    AND coa_terms.base_id = cp_base_id;

-------------bug 4077735----------------------
-- Get COA
CURSOR c_coa(
             cp_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
             cp_adplans_id   igf_aw_awd_dist_plans.adplans_id%TYPE,
             cp_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
            ) IS
  SELECT SUM(amount) coa
    FROM igf_aw_coa_itm_terms coa_terms,
         (SELECT ld_cal_type,
                 ld_sequence_number
            FROM igf_aw_dp_terms
           WHERE adplans_id = cp_adplans_id
         )dist_terms,
         igf_ap_fa_base_rec_all fa,
         igf_aw_awd_prd_term aprd
  WHERE dist_terms.ld_cal_type = coa_terms.ld_cal_type
    AND dist_terms.ld_sequence_number = coa_terms.ld_sequence_number
    AND coa_terms.base_id = cp_base_id
    AND coa_terms.base_id = fa.base_id
    AND fa.ci_cal_type = aprd.ci_cal_type
    AND fa.ci_sequence_number = aprd.ci_sequence_number
    AND aprd.award_prd_cd = cp_awd_prd_code
    AND aprd.ld_cal_type = coa_terms.ld_cal_type
    AND aprd.ld_sequence_number = coa_terms.ld_sequence_number;

ln_coa igf_ap_fa_base_rec_all.coa_f%TYPE;

--
-- get terms count
--
CURSOR cur_terms_count(
                       cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                       cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                       cp_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                      ) IS
  SELECT COUNT(*)
    FROM igf_aw_dp_terms terms,
         (SELECT base_id,
                 ld_cal_type,
                 ld_sequence_number
            FROM igf_aw_coa_itm_terms
           WHERE base_id = cp_base_id
           GROUP BY base_id,ld_cal_type,ld_sequence_number) coaterms,
           igf_aw_awd_prd_term aprd,
           igf_ap_fa_base_rec_all fa
   WHERE terms.adplans_id            = cp_adplans_id
     AND coaterms.ld_cal_type        = terms.ld_cal_type
     AND coaterms.ld_sequence_number = terms.ld_sequence_number
     AND coaterms.base_id            = cp_base_id
     AND coaterms.base_id            = fa.base_id
     AND fa.ci_cal_type              = aprd.ci_cal_type
     AND fa.ci_sequence_number       = aprd.ci_sequence_number
     AND aprd.award_prd_cd         = cp_awd_prd_code
     AND aprd.ld_cal_type            = coaterms.ld_cal_type
     AND aprd.ld_sequence_number     = coaterms.ld_sequence_number;

   l_terms_count      NUMBER := 0;

CURSOR cur_terms_count_wcoa(
                            cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                            cp_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                           )
  IS
  SELECT COUNT(*)
    FROM igf_aw_dp_terms terms,
         igf_aw_awd_dist_plans dp,
         igf_aw_awd_prd_term aprd
   WHERE terms.adplans_id        = cp_adplans_id
     AND terms.adplans_id        = dp.adplans_id
     AND dp.cal_type             = aprd.ci_cal_type
     AND dp.sequence_number      = aprd.ci_sequence_number
     AND aprd.award_prd_cd     = cp_awd_prd_code
     AND aprd.ld_cal_type        = terms.ld_cal_type
     AND aprd.ld_sequence_number = terms.ld_sequence_number;

  -- Get a specific disbursment for an award
  CURSOR c_disb(
                cp_award_id igf_aw_award_all.award_id%TYPE,
                cp_disb_num igf_aw_awd_disb_all.disb_num%TYPE
               ) IS
    SELECT rowid row_id,
           disb.*
      FROM igf_aw_awd_disb_all disb
     WHERE award_id = cp_award_id
       AND disb_num = cp_disb_num;

  l_disb c_disb%ROWTYPE;

  CURSOR    cur_get_base ( p_award_id igf_aw_award_all.award_id%TYPE)  IS
     SELECT base_id
       FROM igf_aw_award_all
      WHERE award_id = p_award_id;

  get_base_rec cur_get_base%ROWTYPE;

   CURSOR cur_nslds_hist ( p_base_id   igf_ap_fa_base_rec.base_id%type ) IS
    SELECT  'x'
    FROM    igf_ap_nslds_data nslds,
            igf_ap_fa_base_rec_all fabase
    WHERE   fabase.person_id = (SELECT person_id from igf_ap_fa_base_rec_all WHERE base_id = p_base_id) AND
            fabase.base_id = nslds.base_id AND
            nslds.nslds_loan_prog_code_1 IS NOT NULL;

   x_nslds_hist cur_nslds_hist%ROWTYPE;

    -- Get distribution plan name
    CURSOR c_adplans_dtls(
                          cp_adplans_id    igf_aw_awd_dist_plans.adplans_id%TYPE
                         ) IS
      SELECT awd_dist_plan_cd_desc
        FROM igf_aw_awd_dist_plans
       WHERE adplans_id = cp_adplans_id;

    l_adplans_dtls c_adplans_dtls%ROWTYPE;

   NO_COMMON_TERMS           EXCEPTION;
   NO_AP_DP_COMM_TERMS       EXCEPTION;
   lb_nslds_ind              BOOLEAN := TRUE;
   lb_coa_exist              BOOLEAN := TRUE;

   lv_row_id                 ROWID;
   ln_total_disbs            NUMBER       := 0;
   ln_count                  NUMBER       := 0;
   ln_disb_accepted_amt      NUMBER(12,3) := 0;
   ln_disb_gross_amt         NUMBER(12,3) := 0;
   ln_disb_net_amt           NUMBER(12,3) := 0;
   ln_run_disb_gross_amt     NUMBER(12,3) := 0;
   ln_fee_1                  NUMBER(12,2) := 0;
   ln_fee_2                  NUMBER(12,2) := 0;
   ln_int_rebate_amt         NUMBER(12,2) := 0;
   ln_dummy_net_amt          NUMBER(12,2) := 0;
   ln_dummy_fee_1            NUMBER(12,2) := 0;
   lv_base_att_type          VARCHAR2(1);
   ld_verf_enfr_dt           igf_aw_awd_disb_all.verf_enfr_dt%TYPE;
   ld_disb_date              igf_aw_awd_disb_all.disb_date%TYPE;
   ld_disb_date1             igf_aw_awd_disb_all.disb_date%TYPE;
   ld_disb_exp_dt            igf_aw_awd_disb_all.disb_exp_dt%TYPE;
   l_hold_ind                igf_sl_cl_setup_all.hold_rel_ind%TYPE;
   l_auto_ind                igf_sl_cl_setup_all.auto_late_disb_ind%TYPE;
   l_adplans_name            igf_aw_awd_dist_plans.awd_dist_plan_cd_desc%TYPE;

BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','p_fund_id:'||p_fund_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','p_award_id:'||p_award_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','p_adplans_id:'||p_adplans_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','p_method_code:'||p_method_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','p_offered_amt:'||p_offered_amt);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','p_awd_prd_code:'||p_awd_prd_code);
    END IF;

    OPEN  cur_get_base(p_award_id);
    FETCH cur_get_base INTO get_base_rec;
    CLOSE cur_get_base;

    OPEN  c_adplans_dtls(p_adplans_id);
    FETCH c_adplans_dtls INTO l_adplans_dtls;
    CLOSE c_adplans_dtls;

    ln_run_disb_gross_amt  := 0;
    l_adplans_name := l_adplans_dtls.awd_dist_plan_cd_desc;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','base_id:'||get_base_rec.base_id);
    END IF;

    --
    -- Check for common terms only if COA is present
    --
    lb_coa_exist := TRUE;
    lb_coa_exist := check_coa(get_base_rec.base_id,p_awd_prd_code);

    IF lb_coa_exist THEN
      check_common_terms(p_adplans_id,get_base_rec.base_id,ln_total_disbs,p_awd_prd_code);
      IF ln_total_disbs = 0 THEN
        RAISE NO_COMMON_TERMS;
      END IF;
    ELSE
      ln_total_disbs := get_plan_disb_count(p_adplans_id,p_awd_prd_code);
    END IF;

    OPEN cur_get_fund_dtls(p_fund_id);
    FETCH cur_get_fund_dtls INTO l_get_fund_dtls;
    CLOSE cur_get_fund_dtls;

    lc_auto_disb := NULL;

    /* method check */
    IF p_method_code = 'M' THEN  -- Manual distribution

      IF lb_coa_exist THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','opening c_auto_disb');
        END IF;
        IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
          OPEN c_auto_disb_pell(get_base_rec.base_id,p_adplans_id);
          IF c_auto_disb_pell%NOTFOUND THEN
            CLOSE c_auto_disb_pell;
          ELSE
            FETCH c_auto_disb_pell INTO lc_auto_disb;
          END IF;
        ELSE
          OPEN c_auto_disb(get_base_rec.base_id,p_adplans_id,p_awd_prd_code);
          IF c_auto_disb%NOTFOUND THEN
            CLOSE c_auto_disb;
          ELSE
            FETCH c_auto_disb INTO lc_auto_disb;
          END IF;
        END IF;
      ELSE
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','opening c_auto_disb_wcoa');
        END IF;
        IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
          OPEN c_auto_disb_wcoa_pell(get_base_rec.base_id,p_adplans_id);
          IF c_auto_disb_wcoa_pell%NOTFOUND THEN
            CLOSE c_auto_disb_wcoa_pell;
          ELSE
            FETCH c_auto_disb_wcoa_pell INTO lc_auto_disb;
          END IF;
        ELSE
          OPEN c_auto_disb_wcoa(get_base_rec.base_id,p_adplans_id,p_awd_prd_code);
          IF c_auto_disb_wcoa%NOTFOUND THEN
            CLOSE c_auto_disb_wcoa;
          ELSE
            FETCH c_auto_disb_wcoa INTO lc_auto_disb;
          END IF;
        END IF;
      END IF;

    ELSIF p_method_code = 'E' THEN   -- Equal Distribution
      --Find the number of terms

      IF lb_coa_exist THEN
        IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
          OPEN  cur_terms_count_pell(get_base_rec.base_id,p_adplans_id);
          FETCH cur_terms_count_pell INTO l_terms_count;
          CLOSE cur_terms_count_pell;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','opening c_auto_disb_equal_pell with l_terms_count:'||l_terms_count);
          END IF;
          OPEN c_auto_disb_equal_pell(get_base_rec.base_id,p_adplans_id,l_terms_count);
          IF c_auto_disb_equal_pell%NOTFOUND THEN
            CLOSE c_auto_disb_equal_pell;
          ELSE
            FETCH c_auto_disb_equal_pell INTO lc_auto_disb;
          END IF;
        ELSE
          OPEN  cur_terms_count(get_base_rec.base_id,p_adplans_id,p_awd_prd_code);
          FETCH cur_terms_count INTO l_terms_count;
          CLOSE cur_terms_count;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','opening c_auto_disb_equal with l_terms_count:'||l_terms_count);
          END IF;
          OPEN c_auto_disb_equal(get_base_rec.base_id,p_adplans_id,l_terms_count,p_awd_prd_code);
          IF c_auto_disb_equal%NOTFOUND THEN
            CLOSE c_auto_disb_equal;
          ELSE
            FETCH c_auto_disb_equal INTO lc_auto_disb;
          END IF;
        END IF;
      ELSE
        IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
          OPEN  cur_terms_count_wcoa_pell(p_adplans_id);
          FETCH cur_terms_count_wcoa_pell INTO l_terms_count;
          CLOSE cur_terms_count_wcoa_pell;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','opening c_auto_disb_equal_wcoa_pell with l_terms_count:'||l_terms_count);
          END IF;
          IF l_terms_count = 0 THEN
            RAISE NO_AP_DP_COMM_TERMS;
          END IF;
          OPEN c_auto_disb_equal_wcoa_pell(get_base_rec.base_id,p_adplans_id,l_terms_count);
          IF c_auto_disb_equal_wcoa_pell%NOTFOUND THEN
            CLOSE c_auto_disb_equal_wcoa_pell;
          ELSE
            FETCH c_auto_disb_equal_wcoa_pell INTO lc_auto_disb;
          END IF;
        ELSE
          OPEN  cur_terms_count_wcoa(p_adplans_id,p_awd_prd_code);
          FETCH cur_terms_count_wcoa INTO l_terms_count;
          CLOSE cur_terms_count_wcoa;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','opening c_auto_disb_equal_wcoa with l_terms_count:'||l_terms_count);
          END IF;
          IF l_terms_count = 0 THEN
            RAISE NO_AP_DP_COMM_TERMS;
          END IF;
          OPEN c_auto_disb_equal_wcoa(get_base_rec.base_id,p_adplans_id,l_terms_count,p_awd_prd_code);
          IF c_auto_disb_equal_wcoa%NOTFOUND THEN
            CLOSE c_auto_disb_equal_wcoa;
          ELSE
            FETCH c_auto_disb_equal_wcoa INTO lc_auto_disb;
          END IF;
        END IF;
      END IF;

    ELSIF p_method_code = 'C' THEN  -- Match COA distribution

      --
      -- For Match COA method cannot award if
      -- there is no COA
      --

      IF lb_coa_exist THEN
        IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
          OPEN c_coa_pell(get_base_rec.base_id,p_adplans_id);
          FETCH c_coa_pell INTO ln_coa;
          CLOSE c_coa_pell;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','opening c_auto_disb_coa_match_pell with ln_coa:'||ln_coa);
          END IF;
          OPEN c_auto_disb_coa_match_pell(get_base_rec.base_id,p_adplans_id,NVL(ln_coa,0));
          IF c_auto_disb_coa_match_pell%NOTFOUND THEN
            CLOSE c_auto_disb_coa_match_pell;
          ELSE
            FETCH c_auto_disb_coa_match_pell INTO lc_auto_disb;
          END IF;
        ELSE
          OPEN c_coa(get_base_rec.base_id,p_adplans_id,p_awd_prd_code);
          FETCH c_coa INTO ln_coa;
          CLOSE c_coa;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','opening c_auto_disb_coa_match with ln_coa:'||ln_coa);
          END IF;
          OPEN c_auto_disb_coa_match(get_base_rec.base_id,p_adplans_id,NVL(ln_coa,0),p_awd_prd_code);
          IF c_auto_disb_coa_match%NOTFOUND THEN
            CLOSE c_auto_disb_coa_match;

          ELSE
            FETCH c_auto_disb_coa_match INTO lc_auto_disb;
          END IF;
        END IF;
      ELSE
        RAISE NO_COMMON_TERMS;
      END IF;

    END IF;/* end method check*/


    LOOP

      -- Initialize all the variables.
      ln_disb_gross_amt  := 0;
      ln_disb_net_amt    := 0;
      ln_dummy_net_amt   := 0;
      ln_dummy_fee_1     := 0;
      ln_fee_1           := 0;
      ln_fee_2           := 0;
      ln_int_rebate_amt  := 0;
      ld_verf_enfr_dt    := NULL;
      ld_disb_date       := NULL;
      ld_disb_exp_dt     := NULL;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','disb_dt:'||lc_auto_disb.disb_dt);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','ld_cal_type:'||lc_auto_disb.ld_cal_type);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','ld_sequence_number:'||lc_auto_disb.ld_sequence_number);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','tp_cal_type:'||lc_auto_disb.tp_cal_type);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','tp_sequence_number:'||lc_auto_disb.tp_sequence_number);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','perct:'||lc_auto_disb.perct);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','start_dt:'||lc_auto_disb.start_dt);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','tp_offset_da:'||lc_auto_disb.tp_offset_da);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','min_credit_points:'||lc_auto_disb.min_credit_points);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','attendance_type_code:'||lc_auto_disb.attendance_type_code);
      END IF;

      IF p_method_code = 'E' THEN
        IF l_get_fund_dtls.fed_fund_code = 'PELL' AND lb_coa_exist THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','calling num_disb with plan/cal_type/seq_num->'||p_adplans_id||'/'||lc_auto_disb.ld_cal_type||'/'||lc_auto_disb.ld_sequence_number);
          END IF;
          lc_auto_disb.perct := 100 / igf_gr_pell_calc.num_disb(p_adplans_id,lc_auto_disb.ld_cal_type,lc_auto_disb.ld_sequence_number);
        ELSIF l_get_fund_dtls.fed_fund_code = 'PELL' AND NOT lb_coa_exist THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','calling num_disb with plan/cal_type/seq_num->'||p_adplans_id||'/NULL/NULL');
          END IF;
          lc_auto_disb.perct := 100 / igf_gr_pell_calc.num_disb(p_adplans_id,NULL,NULL);
        ELSE
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','calling num_disb with plan/cal_type/seq_num->'||p_adplans_id||'/NULL/NULL');
          END IF;
          lc_auto_disb.perct := 100 / igf_gr_pell_calc.num_disb(p_adplans_id,NULL,NULL);
        END IF;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','reset lc_auto_disb.perct to:'||lc_auto_disb.perct);
        END IF;
      END IF;

      -- Calculate the Disbursement Gross Amount.
      ln_disb_gross_amt := NVL(((p_offered_amt) * lc_auto_disb.perct)/100, 0);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','ln_disb_gross_amt:'||ln_disb_gross_amt);
      END IF;

      ln_count            := ln_count + 1;
      -- Calculate the running totals
        ln_run_disb_gross_amt    := ln_run_disb_gross_amt    + ln_disb_gross_amt;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','all others ln_count: '||ln_count||' ln_disb_gross_amt: '||ln_disb_gross_amt);
        END IF;
      -- Calculate the Fee_1, Rebate Amount and the net amount for Direct Loans
      IF igf_sl_gen.chk_dl_fed_fund_code(l_get_fund_dtls.fed_fund_code) = 'TRUE' THEN
         -- we are passing dummys here for Net and Fee amount as they will
         -- be calculated later on
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','before round off call chk_dl_fed_fund_code = TRUE!ln_disb_net_amt:'||ln_disb_net_amt);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','before round off call ln_disb_gross_amt:'||ln_disb_gross_amt);
         END IF;

        igf_sl_roundoff_digits_pkg.gross_fees_roundoff (
	                      p_last_disb_num      => ln_total_disbs,
                              p_offered_amt        => p_offered_amt,
                              p_fee_perct          => igf_sl_award.get_loan_fee1(l_get_fund_dtls.fed_fund_code,
			                                                         l_get_fund_dtls.awd_cal_type,
										 l_get_fund_dtls.awd_sequence_number,
										 get_base_rec.base_id,
										 igf_sl_award.get_alt_rel_code(l_get_fund_dtls.fund_code)),
			      p_disb_gross_amt     => ln_disb_gross_amt,
                              p_disb_net_amt       => ln_dummy_net_amt,
                              p_fee                => ln_dummy_fee_1
			     ) ;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','after round off call ln_disb_net_amt:'||ln_disb_net_amt);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','after round off call ln_disb_gross_amt:'||ln_disb_gross_amt);
         END IF;

         -- This routine will return Net Amount/ Fee Amounts / Interest Rebate Amount
         igf_sl_award.get_loan_amts( l_get_fund_dtls.awd_cal_type,
                                     l_get_fund_dtls.awd_sequence_number,
                                     l_get_fund_dtls.fed_fund_code,
                                     ln_disb_gross_amt,
                                     ln_int_rebate_amt,
                                     ln_fee_1,
                                     ln_disb_net_amt);

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','After get loan amts ln_disb_net_amt:'||ln_disb_net_amt);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','After get loan amts ln_disb_gross_amt:'||ln_disb_gross_amt);
         END IF;

      ELSIF igf_sl_gen.chk_cl_fed_fund_code(l_get_fund_dtls.fed_fund_code) = 'TRUE' THEN

        -- FA 122 Loan Enhancemnts  Add base_id to the call of get_loan_fee1 , get_loan_fee2
        -- added call to get_cl_hold_rel_ind , get_cl_auto_late_ind

         l_hold_ind := igf_sl_award.get_cl_hold_rel_ind(l_get_fund_dtls.fed_fund_code,l_get_fund_dtls.awd_cal_type,l_get_fund_dtls.awd_sequence_number,get_base_rec.base_id,igf_sl_award.get_alt_rel_code(l_get_fund_dtls.fund_code));
         l_auto_ind := igf_sl_award.get_cl_auto_late_ind(l_get_fund_dtls.fed_fund_code,l_get_fund_dtls.awd_cal_type,l_get_fund_dtls.awd_sequence_number,get_base_rec.base_id,igf_sl_award.get_alt_rel_code(l_get_fund_dtls.fund_code));

         -- Calculate Origination Fee
         ln_fee_1 := igf_sl_award.get_loan_fee1( l_get_fund_dtls.fed_fund_code,
                                                 l_get_fund_dtls.awd_cal_type,
                                                 l_get_fund_dtls.awd_sequence_number,
                                                 get_base_rec.base_id,
						 igf_sl_award.get_alt_rel_code(l_get_fund_dtls.fund_code));
         ln_fee_1 := ln_fee_1 * ln_disb_gross_amt/100 ;
         ln_fee_1 := TRUNC(ln_fee_1);

         -- Calculate the Guaratee Fee
         ln_fee_2 := igf_sl_award.get_loan_fee2( l_get_fund_dtls.fed_fund_code,
                                                 l_get_fund_dtls.awd_cal_type,
                                                 l_get_fund_dtls.awd_sequence_number,
                                                 get_base_rec.base_id,
						 igf_sl_award.get_alt_rel_code(l_get_fund_dtls.fund_code));
         ln_fee_2 := ln_fee_2 * ln_disb_gross_amt/100;
         ln_fee_2 := TRUNC(ln_fee_2);

         -- get the rounded off gross amount by using this routine
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','before round off call chk_cl_fed_fund_code = TRUE!ln_disb_net_amt:'||ln_disb_net_amt);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','before round off call ln_disb_gross_amt:'||ln_disb_gross_amt);
         END IF;

         igf_sl_roundoff_digits_pkg.cl_gross_fees_roundoff ( p_last_disb_num      => ln_total_disbs,
                                                             p_offered_amt        => p_offered_amt,
                                                             p_disb_gross_amt     => ln_disb_gross_amt );

         ln_disb_net_amt := NVL(ln_disb_gross_amt,0) - NVL(ln_fee_1,0) - NVL(ln_fee_2,0);
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','after round off call chk_cl_fed_fund_code = TRUE!ln_disb_net_amt:'||ln_disb_net_amt);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','after round off call ln_disb_gross_amt:'||ln_disb_gross_amt);
         END IF;

      ELSE
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','chk_dl_fed_fund_code,chk_cl_fed_fund_code = FALSE!ln_disb_net_amt:'||ln_disb_net_amt);
         END IF;

         ln_disb_net_amt := NVL(ln_disb_gross_amt,0);
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','ln_count:'||ln_count);
      END IF;

      --
      -- For all types of loans and it it is a first disbursement disbursement date
      -- should be NSLDS date else its an offset date or start date of term.
      --

      IF     (ln_count = 1)
         AND (   igf_sl_gen.chk_dl_fed_fund_code (l_get_fund_dtls.fed_fund_code) = 'TRUE'
              OR igf_sl_gen.chk_cl_fed_fund_code (l_get_fund_dtls.fed_fund_code) = 'TRUE'  )
         AND (l_get_fund_dtls.nslds_disb_da IS NOT NULL)       THEN

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','inside fed_fund_code checks');
          END IF;

          ld_disb_date1      := NULL;

          OPEN  cur_nslds_hist (get_base_rec.base_id);
          FETCH cur_nslds_hist INTO x_nslds_hist;

          IF cur_nslds_hist%NOTFOUND THEN
          --
          -- No NSLDS History exists for current student , so delay the disbursement
          --
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','student has no NSLDS history, so applying NSLDS date offset.');
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','lc_auto_disb.tp_offset_da:'||lc_auto_disb.tp_offset_da);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','lc_auto_disb.ld_cal_type:'||lc_auto_disb.ld_cal_type);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','lc_auto_disb.ld_sequence_number:'||lc_auto_disb.ld_sequence_number);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','l_get_fund_dtls.nslds_disb_da:'||l_get_fund_dtls.nslds_disb_da);
               END IF;

               ld_disb_date1 := igf_ap_gen_001.get_date_alias_val(
                                                                  get_base_rec.base_id,
                                                                  lc_auto_disb.ld_cal_type,
                                                                  lc_auto_disb.ld_sequence_number,
                                                                  l_get_fund_dtls.nslds_disb_da
                                                                 );

               IF ld_disb_date1 IS NOT NULL THEN
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','NSLDS Disb Offset date, ld_disb_date1:' ||ld_disb_date1);
                END IF;
               ELSE
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug',
                                'Cannot compute NSLDS offset date. Some error in computing NSLDS offset date. So using the actual disb date.');
                 END IF;
               END IF;
          ELSE
            -- NSLDS history exists. Do not delay disb date.
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','Student has NSLDS history, so NOT applying NSLDS date offset.');
            END IF;
          END IF;

          CLOSE cur_nslds_hist;
      END IF;
      --
      -- Calculate the actual Disbursement expiration date and
      -- verification enforcement date from the offset dates.
      --

      ld_disb_exp_dt := igf_ap_gen_001.get_date_alias_val(
                                                          get_base_rec.base_id,
                                                          lc_auto_disb.ld_cal_type,
                                                          lc_auto_disb.ld_sequence_number,
                                                          l_get_fund_dtls.disb_exp_da
                                                          );

      ld_verf_enfr_dt := igf_ap_gen_001.get_date_alias_val(
                                                           get_base_rec.base_id,
                                                           lc_auto_disb.ld_cal_type,
                                                           lc_auto_disb.ld_sequence_number,
                                                           l_get_fund_dtls.disb_verf_da
                                                          );

      IF ld_disb_date1 IS NOT NULL AND ln_count = 1 THEN
        -- Student does NOT have NSLDS history, apply NSLDS date offset to delay disb date
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','Setting lb_nslds_ind to FALSE, so that NSLDS date offset will be applied.');
        END IF;

        lb_nslds_ind := FALSE;
      END IF;

      IF p_award_status = 'ACCEPTED' THEN
         ln_disb_accepted_amt := ln_disb_gross_amt;
      ELSE
         ln_disb_accepted_amt := 0;
      END IF;

      lv_base_att_type := NULL;
      IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
         lv_base_att_type := '1';
      END IF;

      IF l_get_fund_dtls.fed_fund_code IN ('FWS','SPNSR') THEN
         lc_auto_disb.attendance_type_code := NULL;
      END IF;

      IF     (l_get_fund_dtls.fed_fund_code = 'PELL' AND
             igf_sl_dl_validation.check_full_participant (l_get_fund_dtls.awd_cal_type,l_get_fund_dtls.awd_sequence_number,'PELL'))
          OR (l_get_fund_dtls.fed_fund_code IN ('DLP','DLS','DLU') AND
             igf_sl_dl_validation.check_full_participant (l_get_fund_dtls.awd_cal_type,l_get_fund_dtls.awd_sequence_number,'DL'))
          THEN
        l_hold_ind := 'FALSE';
      END IF;

      -- museshad (Bug# 4608591)
      OPEN c_disb(cp_award_id => p_award_id, cp_disb_num => ln_count);
      FETCH c_disb INTO l_disb;

      IF isRepackaging(p_award_id => p_award_id) AND (c_disb%FOUND) THEN
        -- If you reach here, it means this existing award already has this
        -- disbursement. So, update it.

        /*
        This Repackaging holds good (and gets executed) only when an
        existing CANCELLED award is reinstated to OFFERED/ACCEPTED status.
        */

        -- Log
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','Updating existing disbursement (Repackaging)');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','award_id:'||p_award_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','disb_num:'||ln_count);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','disb_gross_amt:'||ln_disb_gross_amt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','ln_disb_net_amt:'||ln_disb_net_amt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','p_award_status: ' || p_award_status);
        END IF;

        l_hold_ind := NVL(l_disb.hold_rel_ind, 'FALSE');

        igf_aw_awd_disb_pkg.update_row (
                      x_mode                       => 'R',
                      x_rowid                      => l_disb.row_id,
                      x_award_id                   => p_award_id,
                      x_disb_num                   => ln_count,
                      x_tp_cal_type                => lc_auto_disb.tp_cal_type,
                      x_tp_sequence_number         => lc_auto_disb.tp_sequence_number,
                      x_disb_gross_amt             => ln_disb_gross_amt,
                      x_fee_1                      => ln_fee_1,
                      x_fee_2                      => ln_fee_2,
                      x_disb_net_amt               => ln_disb_net_amt,
                      x_disb_date                  => lc_auto_disb.disb_dt,
                      x_trans_type                 => 'P',
                      x_elig_status                => 'N',
                      x_elig_status_date           => TRUNC(SYSDATE),
                      x_affirm_flag                => l_disb.affirm_flag,
                      x_hold_rel_ind               => l_hold_ind,
                      x_manual_hold_ind            => 'N',
                      x_disb_status                => l_disb.disb_status,
                      x_disb_status_date           => l_disb.disb_status_date,
                      x_late_disb_ind              => l_auto_ind,
                      x_fund_dist_mthd             => l_disb.fund_dist_mthd,
                      x_prev_reported_ind          => l_disb.prev_reported_ind,
                      x_fund_release_date          => l_disb.fund_release_date,
                      x_fund_status                => l_disb.fund_status,
                      x_fund_status_date           => l_disb.fund_status_date,
                      x_fee_paid_1                 => 0,
                      x_fee_paid_2                 => 0,
                      x_cheque_number              => l_disb.cheque_number,
                      x_ld_cal_type                => lc_auto_disb.ld_cal_type,
                      x_ld_sequence_number         => lc_auto_disb.ld_sequence_number,
                      x_disb_accepted_amt          => ln_disb_accepted_amt,
                      x_disb_paid_amt              => 0,
                      x_rvsn_id                    => l_disb.rvsn_id,
                      x_int_rebate_amt             => ln_int_rebate_amt,
                      x_force_disb                 => 'N',
                      x_min_credit_pts             => lc_auto_disb.min_credit_points,
                      x_disb_exp_dt                => ld_disb_exp_dt,
                      x_verf_enfr_dt               => ld_verf_enfr_dt,
                      x_fee_class                  => l_disb.fee_class,
                      x_show_on_bill               => l_get_fund_dtls.show_on_bill,
                      x_attendance_type_code       => lc_auto_disb.attendance_type_code,
                      x_base_attendance_type_code  => lv_base_att_type,
                      x_payment_prd_st_date        => l_disb.payment_prd_st_date,
                      x_change_type_code           => l_disb.change_type_code,
                      x_fund_return_mthd_code      => l_disb.fund_return_mthd_code,
                      x_direct_to_borr_flag        => l_disb.direct_to_borr_flag
                     );
      ELSE
        -- If you reach here, it means this is either - an existing award without this
        -- disbursement (or) it is a new award whose disbursement needs to be
        -- created. So, create the disbursement

        -- Log
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','Creating new disbursement (Packaging)');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','award_id:'||p_award_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','disb_num:'||ln_count);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','disb_gross_amt:'||ln_disb_gross_amt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','ln_disb_net_amt:'||ln_disb_net_amt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','p_award_status: ' || p_award_status);
        END IF;

        igf_aw_awd_disb_pkg.insert_row (
                      x_mode                       => 'R',
                      x_rowid                      => lv_row_id,
                      x_award_id                   => p_award_id,
                      x_disb_num                   => ln_count,
                      x_tp_cal_type                => lc_auto_disb.tp_cal_type,
                      x_tp_sequence_number         => lc_auto_disb.tp_sequence_number,
                      x_disb_gross_amt             => ln_disb_gross_amt,
                      x_fee_1                      => ln_fee_1,
                      x_fee_2                      => ln_fee_2,
                      x_disb_net_amt               => ln_disb_net_amt,
                      x_disb_date                  => lc_auto_disb.disb_dt,
                      x_trans_type                 => 'P',
                      x_elig_status                => 'N',
                      x_elig_status_date           => TRUNC(SYSDATE),
                      x_affirm_flag                => NULL,
                      x_hold_rel_ind               => l_hold_ind,
                      x_manual_hold_ind            => 'N',
                      x_disb_status                => NULL,
                      x_disb_status_date           => NULL,
                      x_late_disb_ind              => l_auto_ind,
                      x_fund_dist_mthd             => NULL,
                      x_prev_reported_ind          => NULL,
                      x_fund_release_date          => NULL,
                      x_fund_status                => NULL,
                      x_fund_status_date           => NULL,
                      x_fee_paid_1                 => 0,
                      x_fee_paid_2                 => 0,
                      x_cheque_number              => NULL,
                      x_ld_cal_type                => lc_auto_disb.ld_cal_type,
                      x_ld_sequence_number         => lc_auto_disb.ld_sequence_number,
                      x_disb_accepted_amt          => ln_disb_accepted_amt,
                      x_disb_paid_amt              => 0,
                      x_rvsn_id                    => NULL,
                      x_int_rebate_amt             => ln_int_rebate_amt,
                      x_force_disb                 => 'N',
                      x_min_credit_pts             => lc_auto_disb.min_credit_points,
                      x_disb_exp_dt                => ld_disb_exp_dt,
                      x_verf_enfr_dt               => ld_verf_enfr_dt,
                      x_fee_class                  => NULL,
                      x_show_on_bill               => l_get_fund_dtls.show_on_bill,
                      x_attendance_type_code       => lc_auto_disb.attendance_type_code,
                      x_base_attendance_type_code  => lv_base_att_type,
                      x_payment_prd_st_date        => l_disb.payment_prd_st_date,
                      x_change_type_code           => NULL,
                      x_fund_return_mthd_code      => NULL,
                      x_direct_to_borr_flag        => 'N'
                     );
      END IF;
      CLOSE c_disb;

      IF p_method_code = 'M' THEN /*Manual distribution */
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','-----fetching next disbursment-----');
        END IF;
        IF lb_coa_exist THEN
          IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
            FETCH c_auto_disb_pell INTO lc_auto_disb;
            EXIT WHEN c_auto_disb_pell%NOTFOUND;
          ELSE
            FETCH c_auto_disb INTO lc_auto_disb;
            EXIT WHEN c_auto_disb%NOTFOUND;
          END IF;
        ELSE
          IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
            FETCH c_auto_disb_wcoa_pell INTO lc_auto_disb;
            EXIT WHEN c_auto_disb_wcoa_pell%NOTFOUND;
          ELSE
            FETCH c_auto_disb_wcoa INTO lc_auto_disb;
            EXIT WHEN c_auto_disb_wcoa%NOTFOUND;
          END IF;
        END IF;

      ELSIF p_method_code = 'E' THEN /* Equal Distribution */
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','-----fetching next disbursment-----');
        END IF;
        IF lb_coa_exist THEN
          IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
            FETCH c_auto_disb_equal_pell INTO lc_auto_disb;
            EXIT WHEN c_auto_disb_equal_pell%NOTFOUND;
          ELSE
            FETCH c_auto_disb_equal INTO lc_auto_disb;
            EXIT WHEN c_auto_disb_equal%NOTFOUND;
          END IF;
        ELSE
          IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
            FETCH c_auto_disb_equal_wcoa_pell INTO lc_auto_disb;
            EXIT WHEN c_auto_disb_equal_wcoa_pell%NOTFOUND;
          ELSE
            FETCH c_auto_disb_equal_wcoa INTO lc_auto_disb;
            EXIT WHEN c_auto_disb_equal_wcoa%NOTFOUND;
          END IF;
        END IF;

      ELSIF p_method_code = 'C' THEN /* Match COA distribution */
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','-----fetching next disbursment-----');
        END IF;
        IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
          FETCH c_auto_disb_coa_match_pell INTO lc_auto_disb;
          EXIT WHEN c_auto_disb_coa_match_pell%NOTFOUND;
        ELSE
          FETCH c_auto_disb_coa_match INTO lc_auto_disb;
          EXIT WHEN c_auto_disb_coa_match%NOTFOUND;
        END IF;

      END IF;/* end method check*/

    END LOOP;

    IF p_method_code = 'M' THEN /*Manual distribution */
     IF lb_coa_exist THEN
      IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
        CLOSE c_auto_disb_pell;
      ELSE
        CLOSE c_auto_disb;
      END IF;
     ELSE
       IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
        CLOSE c_auto_disb_wcoa_pell;
       ELSE
        CLOSE c_auto_disb_wcoa;
       END IF;
     END IF;

    ELSIF p_method_code = 'E' THEN /* Equal Distribution */
     IF lb_coa_exist THEN
      IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
        CLOSE c_auto_disb_equal_pell;
      ELSE
        CLOSE c_auto_disb_equal;
      END IF;
     ELSE
      IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
        CLOSE c_auto_disb_equal_wcoa_pell;
      ELSE
        CLOSE c_auto_disb_equal_wcoa;
      END IF;
     END IF;

    ELSIF p_method_code = 'C' THEN /* Match COA distribution */
      IF l_get_fund_dtls.fed_fund_code = 'PELL' THEN
        CLOSE c_auto_disb_coa_match_pell;
      ELSE
        CLOSE c_auto_disb_coa_match;
      END IF;
    END IF;/* end method check*/

    --
    -- Add To Do Items to student which are defined at the fund level
    --

    igf_aw_packaging.add_todo(p_fund_id,get_base_rec.base_id);

    -- Apply NSLDS offset to the first disbursment
    IF NOT lb_nslds_ind THEN
      OPEN c_disb(p_award_id,1);
      FETCH c_disb INTO l_disb;
      CLOSE c_disb;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.create_auto_disb.debug','Flag set - updating disb num 1 with NSLDS disb offset date: ' ||ld_disb_date1);
      END IF;

      igf_aw_awd_disb_pkg.update_row(
                                     x_mode                       => 'R',
                                     x_rowid                      => l_disb.row_id,
                                     x_award_id                   => l_disb.award_id,
                                     x_disb_num                   => l_disb.disb_num,
                                     x_tp_cal_type                => l_disb.tp_cal_type,
                                     x_tp_sequence_number         => l_disb.tp_sequence_number,
                                     x_disb_gross_amt             => l_disb.disb_gross_amt,
                                     x_fee_1                      => l_disb.fee_1,
                                     x_fee_2                      => l_disb.fee_2,
                                     x_disb_net_amt               => l_disb.disb_net_amt,
                                     x_disb_date                  => ld_disb_date1,
                                     x_trans_type                 => l_disb.trans_type,
                                     x_elig_status                => l_disb.elig_status,
                                     x_elig_status_date           => l_disb.elig_status_date,
                                     x_affirm_flag                => l_disb.affirm_flag,
                                     x_hold_rel_ind               => l_disb.hold_rel_ind,
                                     x_manual_hold_ind            => l_disb.manual_hold_ind,
                                     x_disb_status                => l_disb.disb_status,
                                     x_disb_status_date           => l_disb.disb_status_date,
                                     x_late_disb_ind              => l_disb.late_disb_ind,
                                     x_fund_dist_mthd             => l_disb.fund_dist_mthd,
                                     x_prev_reported_ind          => l_disb.prev_reported_ind ,
                                     x_fund_release_date          => l_disb.fund_release_date,
                                     x_fund_status                => l_disb.fund_status,
                                     x_fund_status_date           => l_disb.fund_status_date,
                                     x_fee_paid_1                 => l_disb.fee_paid_1,
                                     x_fee_paid_2                 => l_disb.fee_paid_2,
                                     x_cheque_number              => l_disb.cheque_number,
                                     x_ld_cal_type                => l_disb.ld_cal_type,
                                     x_ld_sequence_number         => l_disb.ld_sequence_number,
                                     x_disb_accepted_amt          => l_disb.disb_accepted_amt,
                                     x_disb_paid_amt              => l_disb.disb_paid_amt,
                                     x_rvsn_id                    => l_disb.rvsn_id,
                                     x_int_rebate_amt             => l_disb.int_rebate_amt,
                                     x_force_disb                 => l_disb.force_disb,
                                     x_min_credit_pts             => l_disb.min_credit_pts,
                                     x_disb_exp_dt                => l_disb.disb_exp_dt,
                                     x_verf_enfr_dt               => l_disb.verf_enfr_dt,
                                     x_fee_class                  => l_disb.fee_class,
                                     x_show_on_bill               => l_disb.show_on_bill,
                                     x_attendance_type_code       => l_disb.attendance_type_code,
                                     x_base_attendance_type_code  => l_disb.base_attendance_type_code,
                                     x_payment_prd_st_date        => l_disb.payment_prd_st_date,
                                     x_change_type_code           => l_disb.change_type_code,
                                     x_fund_return_mthd_code      => l_disb.fund_return_mthd_code,
                                     x_direct_to_borr_flag        => l_disb.direct_to_borr_flag
                                    );

    END IF;

    -- museshad (Bug# 4608591)
    -- While repackaging any extra disbursements present in the
    -- award needs to be cancelled
    IF isRepackaging(p_award_id => p_award_id) THEN
      cancel_extra_disb (
                          p_award_id  =>  p_award_id,
                          p_disb_num  =>  ln_count
                        );
    END IF;
    -- museshad (Bug# 4608591)

    -- bvisvana - FA 157 - To enable rounding options at the time of award creation
    -- museshad (12-Sep-2005) - Pell disbursement rounding is handled separately in IGFGR11B
    IF get_fed_fund_code(p_fund_id => p_fund_id) <> 'PELL'  THEN
      round_off_disbursements ( p_fund_id        => p_fund_id,
                                p_award_id       => p_award_id,
                                p_offered_amt    => p_offered_amt,
                                p_award_status   => p_award_status,
                                p_dist_plan_code => p_method_code  ,
                                p_disb_count     => ln_count
                              );
    END IF;

  EXCEPTION

    WHEN NO_COMMON_TERMS THEN
      fnd_message.set_name('IGF','IGF_AW_COA_COMMON_TERMS_FAIL');
      fnd_message.set_token('PLAN_CD',l_adplans_name);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_gen_003.create_auto_disb.exception','no common terms between COA and distribution plan');
      END IF;

    WHEN NO_AP_DP_COMM_TERMS THEN
      fnd_message.set_name('IGF','IGF_AW_NO_APDP_COM_TERM');
      app_exception.raise_exception;

    WHEN others THEN
      IF c_auto_disb%ISOPEN THEN
        CLOSE c_auto_disb;
      END IF;
      IF c_auto_disb_wcoa%ISOPEN THEN
        CLOSE c_auto_disb_wcoa;
      END IF;
      IF  c_auto_disb_equal%ISOPEN THEN
          CLOSE c_auto_disb_equal;
      END IF;
      IF  c_auto_disb_equal_wcoa%ISOPEN  THEN
          CLOSE c_auto_disb_equal_wcoa;
      END IF;
      IF  c_auto_disb_coa_match%ISOPEN THEN
          CLOSE c_auto_disb_coa_match;
      END IF;

      IF c_auto_disb_pell%ISOPEN THEN
        CLOSE c_auto_disb_pell;
      END IF;
      IF c_auto_disb_wcoa_pell%ISOPEN THEN
        CLOSE c_auto_disb_wcoa_pell;
      END IF;
      IF  c_auto_disb_equal_pell%ISOPEN THEN
          CLOSE c_auto_disb_equal_pell;
      END IF;
      IF  c_auto_disb_equal_wcoa_pell%ISOPEN  THEN
          CLOSE c_auto_disb_equal_wcoa_pell;
      END IF;
      IF  c_auto_disb_coa_match_pell%ISOPEN THEN
          CLOSE c_auto_disb_coa_match_pell;
      END IF;

      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_GEN_003.CREATE_AUTO_DISB' || ' ' || SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_gen_003.create_auto_disb.exception','sql error message:'|| SQLERRM);
      END IF;
      app_exception.raise_exception;

END create_auto_disb;


PROCEDURE remove_awd_rules_override(p_award_id   IN  igf_aw_award.award_id%TYPE)
AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Fuction to remove the rules override check on the award
    ||               This function checks for over awaqrd holds on all the disbursements, if no
    ||               holds on the disbursements then updates the rules override to 'N' for award.
    ||  Parameter : Award_Id  -  Incates the Award ID for which override rules need to be removed.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    --
    -- Get the details of Disbursement Holds for a given award if any holds exists
    --
    CURSOR c_chk_sys_disb_holds(p_award_id   igf_aw_award.award_id%TYPE)
    IS
      SELECT 'x'
      FROM igf_db_disb_holds dh
      WHERE dh.award_id = p_award_id
      AND   dh.hold_type = 'SYSTEM'
      AND   dh.hold      = 'OVERAWARD'
      AND   dh.release_flag = 'N';

    --
    -- Get the details of the award for updating the override rules.
    --
    CURSOR c_get_awd_dtls(p_award_id   igf_aw_award.award_id%TYPE)
    IS
      SELECT awd.*
      FROM   igf_aw_award awd
      WHERE  awd.award_id = p_award_id;

    lc_get_awd_dtls         c_get_awd_dtls%ROWTYPE;
    lc_chk_sys_disb_holds   c_chk_sys_disb_holds%ROWTYPE;

BEGIN

    OPEN c_chk_sys_disb_holds( p_award_id);
    FETCH c_chk_sys_disb_holds INTO lc_chk_sys_disb_holds;

    -- Check whether the Holds are present if not present then remove the rules override at award level
    IF c_chk_sys_disb_holds%NOTFOUND THEN

      -- Fetch the details for the award and update the rules override with 'N'
      OPEN c_get_awd_dtls( p_award_id);
      FETCH c_get_awd_dtls INTO lc_get_awd_dtls;
      CLOSE c_get_awd_dtls;

      igf_aw_award_pkg.update_row(
                x_mode                 => 'R',
                x_rowid                => lc_get_awd_dtls.row_id,
                x_award_id             => lc_get_awd_dtls.award_id,
                x_fund_id              => lc_get_awd_dtls.fund_id,
                x_base_id              => lc_get_awd_dtls.base_id,
                x_offered_amt          => lc_get_awd_dtls.offered_amt,
                x_accepted_amt         => lc_get_awd_dtls.accepted_amt,
                x_paid_amt             => lc_get_awd_dtls.paid_amt,
                x_packaging_type       => lc_get_awd_dtls.packaging_type,
                x_batch_id             => lc_get_awd_dtls.batch_id,
                x_manual_update        => lc_get_awd_dtls.manual_update,
                x_rules_override       => 'N',
                x_award_date           => lc_get_awd_dtls.award_date,
                x_award_status         => lc_get_awd_dtls.award_status,
                x_attribute_category   => lc_get_awd_dtls.attribute_category,
                x_attribute1           => lc_get_awd_dtls.attribute1,
                x_attribute2           => lc_get_awd_dtls.attribute2,
                x_attribute3           => lc_get_awd_dtls.attribute3,
                x_attribute4           => lc_get_awd_dtls.attribute4,
                x_attribute5           => lc_get_awd_dtls.attribute5,
                x_attribute6           => lc_get_awd_dtls.attribute6,
                x_attribute7           => lc_get_awd_dtls.attribute7,
                x_attribute8           => lc_get_awd_dtls.attribute8,
                x_attribute9           => lc_get_awd_dtls.attribute9,
                x_attribute10          => lc_get_awd_dtls.attribute10,
                x_attribute11          => lc_get_awd_dtls.attribute11,
                x_attribute12          => lc_get_awd_dtls.attribute12,
                x_attribute13          => lc_get_awd_dtls.attribute13,
                x_attribute14          => lc_get_awd_dtls.attribute14,
                x_attribute15          => lc_get_awd_dtls.attribute15,
                x_attribute16          => lc_get_awd_dtls.attribute16,
                x_attribute17          => lc_get_awd_dtls.attribute17,
                x_attribute18          => lc_get_awd_dtls.attribute18,
                x_attribute19          => lc_get_awd_dtls.attribute19,
                x_attribute20          => lc_get_awd_dtls.attribute20,
                x_rvsn_id              => lc_get_awd_dtls.rvsn_id,
                x_award_number_txt     => lc_get_awd_dtls.award_number_txt,
                x_legacy_record_flag   => NULL,
                x_adplans_id           => lc_get_awd_dtls.adplans_id,
                x_lock_award_flag      => lc_get_awd_dtls.lock_award_flag,
                x_app_trans_num_txt    => lc_get_awd_dtls.app_trans_num_txt,
                x_awd_proc_status_code => lc_get_awd_dtls.awd_proc_status_code,
                x_notification_status_code => lc_get_awd_dtls.notification_status_code,
                x_notification_status_date => lc_get_awd_dtls.notification_status_date,
                x_publish_in_ss_flag       => lc_get_awd_dtls.publish_in_ss_flag
      );

    END IF;
    CLOSE c_chk_sys_disb_holds;

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_GEN_003.REMOVE_AWD_RULES_OVERRIDE'||' ' ||SQLERRM);
      app_exception.raise_exception;

END remove_awd_rules_override;

FUNCTION place_ovawd_holds (p_award_id   igf_aw_award.award_id%TYPE,
                            p_disb_num   igf_aw_awd_disb.disb_num%TYPE)

RETURN BOOLEAN
IS

--
-- Get the details of disbursement hold for the given disbursement if present
-- If this function returns TRUE, it means new overaward hold
-- can be placed
--
  CURSOR cur_chk_holds( p_award_id   igf_aw_award.award_id%TYPE,
                        p_disb_num   igf_aw_awd_disb.disb_num%TYPE) IS
     SELECT  dh.release_flag
     FROM    igf_db_disb_holds dh
     WHERE   dh.award_id      = p_award_id
     AND     dh.disb_num      = p_disb_num
     AND     dh.hold_type     = 'SYSTEM'
     AND     dh.hold          = 'OVERAWARD';

  rec_chk_holds     cur_chk_holds%ROWTYPE;

BEGIN

  OPEN  cur_chk_holds(p_award_id,p_disb_num);
  FETCH cur_chk_holds INTO  rec_chk_holds;

  IF    cur_chk_holds%NOTFOUND THEN
        CLOSE cur_chk_holds;
        RETURN TRUE;
  ELSIF cur_chk_holds%FOUND THEN
     IF NVL(rec_chk_holds.release_flag,'N') = 'Y' THEN
        CLOSE cur_chk_holds;
        RETURN TRUE;
     ELSE
        CLOSE cur_chk_holds;
        RETURN FALSE;
     END IF;
  ELSE
        RETURN FALSE;
  END IF;

EXCEPTION

WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_AW_GEN_003.PLACE_OVAWD_HOLDS'||' ' ||SQLERRM);
   app_exception.raise_exception;

END place_ovawd_holds;


PROCEDURE create_over_awd_holds(
                                  p_award_id        IN  igf_aw_award.award_id%TYPE
                                 ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : This function creates the disbursement holds if any over award amount.
    ||               For over awards, function checks for existing holds, and then create
    ||               disbursement holds if holds are not present.
    ||  Parameter  : Award_Id  -  Incates the Award ID for which all the disbursements should be put on hold
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    -- Get the details of all planned disbursements of the given award.
    CURSOR c_get_planned_awd_disb(
                                  p_award_id   igf_aw_award.award_id%TYPE
                                 ) IS
      SELECT disb.award_id, disb.disb_num
      FROM   igf_aw_awd_disb disb
      WHERE  disb.award_id = p_award_id
      AND    disb.trans_type = 'P';

    lc_row_id                 VARCHAR2(30);
    ln_hold_id                igf_db_disb_holds.hold_id%TYPE;


    l_app  VARCHAR2(50);
    l_name VARCHAR2(30);

BEGIN

    -- Get all the Planned disbursements for the given award.
    FOR rec_c_get_planned_awd_disb IN c_get_planned_awd_disb( p_award_id) LOOP

            BEGIN

              -- Check whether the over award system is already pleased for the each disbursement.

              IF place_ovawd_holds (p_award_id,rec_c_get_planned_awd_disb.disb_num) THEN

                -- If Hold is not present, then create the hold on the disbursement.
                igf_db_disb_holds_pkg.insert_row(
                            x_mode                              => 'R',
                            x_rowid                             => lc_row_id,
                            x_hold_id                           => ln_hold_id,
                            x_award_id                          => rec_c_get_planned_awd_disb.award_id,
                            x_disb_num                          => rec_c_get_planned_awd_disb.disb_num,
                            x_hold                              => 'OVERAWARD',
                            x_hold_date                         => TRUNC(sysdate),
                            x_hold_type                         => 'SYSTEM',
                            x_release_date                      => NULL,
                            x_release_flag                      => 'N',
                            x_release_reason                    => NULL
                );
              END IF;


              EXCEPTION

                 WHEN others THEN
                      --
                      -- This will ensure exception raised from the insert hold tbh
                      -- are is not thrown in the form
                      --
                      fnd_message.parse_encoded(fnd_message.get_encoded, l_app, l_name);
                      IF l_name = 'IGF_DB_HOLD_EXISTS' THEN
                         NULL;
                      ELSE
                         RAISE;
                      END IF;
              END;
    END LOOP;  -- Planned disbursements loop

    COMMIT;

EXCEPTION

WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_AW_GEN_003.CREATE_OVER_AWD_HOLDS'||' ' ||SQLERRM);
   app_exception.raise_exception;

END create_over_awd_holds;

PROCEDURE update_accept_amount (p_award_id       IN  igf_aw_award.award_id%TYPE )
IS

/*
-----------------------------------------------------------------------------
--
-- adhawan, May 12th 2002
--This procedure ensures that whenever the Award Status is changed to Accepted from Offered
--and the Accepted amount is null or Zero then updation of the accepted amounts should take
-- place with the offered amounts to the Disbursement table.
--   who                    when                      what
--   adhawan               12-May-2002               Added this procedure
--  Bug ID : 2332588
-----------------------------------------------------------------------------
*/


  CURSOR c_accept_null IS
     SELECT disb.*,disb.rowid row_id
     FROM   igf_aw_awd_disb_all disb
     WHERE  disb.award_id  = p_award_id
     AND    disb.trans_type <> 'C'
     AND    NVL(disb.disb_accepted_amt,0) = 0
     FOR UPDATE OF disb.disb_gross_amt NOWAIT;

--
-- This would select all the disb records which have accepted amount as null or zero
--

BEGIN

  FOR c_null_rec IN c_accept_null LOOP

--
-- As accepted amount made equal to Offered amount,
-- net amount is based on accepted amt
--
     c_null_rec.disb_net_amt  :=  c_null_rec.disb_gross_amt        -
                                  NVL(c_null_rec.fee_1,0)          -
                                  NVL(c_null_rec.fee_2,0)          +
                                  NVL(c_null_rec.fee_paid_1,0)     +
                                  NVL(c_null_rec.fee_paid_2,0)     +
                                  NVL(c_null_rec.int_rebate_amt,0);

    igf_aw_awd_disb_pkg.update_row (
         x_mode                           => 'R',
         x_rowid                          => c_null_rec.row_id,
         x_award_id                       => c_null_rec.award_id,
         x_disb_num                       => c_null_rec.disb_num,
         x_tp_cal_type                    => c_null_rec.tp_cal_type,
         x_tp_sequence_number             => c_null_rec.tp_sequence_number,
         x_disb_gross_amt                 => c_null_rec.disb_gross_amt,
         x_fee_1                          => c_null_rec.fee_1,
         x_fee_2                          => c_null_rec.fee_2,
         x_disb_net_amt                   => c_null_rec.disb_net_amt,
         x_disb_date                      => c_null_rec.disb_date,
         x_trans_type                     => c_null_rec.trans_type,
         x_elig_status                    => c_null_rec.elig_status,
         x_elig_status_date               => c_null_rec.elig_status_date,
         x_affirm_flag                    => c_null_rec.affirm_flag,
         x_hold_rel_ind                   => c_null_rec.hold_rel_ind,
         x_manual_hold_ind                => c_null_rec.manual_hold_ind,
         x_disb_status                    => c_null_rec.disb_status,
         x_disb_status_date               => c_null_rec.disb_status_date,
         x_late_disb_ind                  => c_null_rec.late_disb_ind,
         x_fund_dist_mthd                 => c_null_rec.fund_dist_mthd,
         x_prev_reported_ind              => c_null_rec.prev_reported_ind,
         x_fund_release_date              => c_null_rec.fund_release_date,
         x_fund_status                    => c_null_rec.fund_status,
         x_fund_status_date               => c_null_rec.fund_status_date,
         x_fee_paid_1                     => c_null_rec.fee_paid_1,
         x_fee_paid_2                     => c_null_rec.fee_paid_2,
         x_cheque_number                  => c_null_rec.cheque_number,
         x_ld_cal_type                    => c_null_rec.ld_cal_type,
         x_ld_sequence_number             => c_null_rec.ld_sequence_number,
         x_disb_accepted_amt              => c_null_rec.disb_gross_amt,--Accepted amount made equal to Offered amount
         x_disb_paid_amt                  => c_null_rec.disb_paid_amt,
         x_rvsn_id                        => c_null_rec.rvsn_id,
         x_int_rebate_amt                 => c_null_rec.int_rebate_amt,
         x_force_disb                     => c_null_rec.force_disb,
         x_min_credit_pts                 => c_null_rec.min_credit_pts,
         x_disb_exp_dt                    => c_null_rec.disb_exp_dt,
         x_verf_enfr_dt                   => c_null_rec.verf_enfr_dt,
         x_fee_class                      => c_null_rec.fee_class,
         x_show_on_bill                   => c_null_rec.show_on_bill,
         x_attendance_type_code           => c_null_rec.attendance_type_code,
         x_base_attendance_type_code      => c_null_rec.base_attendance_type_code,
         x_payment_prd_st_date            => c_null_rec.payment_prd_st_date,
         x_change_type_code               => c_null_rec.change_type_code,
         x_fund_return_mthd_code          => c_null_rec.fund_return_mthd_code,
         x_direct_to_borr_flag            => c_null_rec.direct_to_borr_flag
    );


  END LOOP;

EXCEPTION

WHEN app_exception.record_lock_exception THEN
   ROLLBACK;

WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_AW_GEN_003.UPDATE_ACCEPT_AMOUNT'||' ' ||SQLERRM);
   app_exception.raise_exception;

END update_accept_amount;

PROCEDURE update_awd_cancell_to_offer(p_award_id       IN  igf_aw_award.award_id%TYPE,
                                      p_award_stat     IN  VARCHAR2,
                                      p_fed_fund_code  IN  VARCHAR2,
                                      p_base_id        IN  NUMBER,
                                      p_message        OUT NOCOPY VARCHAR2)
IS
/*-----------------------------------------------------------------------------
--
-- adhawan, May 12th 2002
--This procedure ensures that whenever the Award Status is changed to Accepted OR Offered
-- from Cancelled or Declined the Transaction type , eligibility status , elig date should get updated
-- who                    when                      what
--smadathi              24-NOV-2004               Enh. Bug 3416936. Modified the update_row call to
--                                                igf_aw_awd_disb table
--adhawan               24-May-2002               Added this procedure
--Bug ID : 2375571
-----------------------------------------------------------------------------*/


    CURSOR cur_active_isir(
                         cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                        ) IS
      SELECT transaction_num
        FROM igf_ap_isir_matched_all
       WHERE base_id     = cp_base_id
         AND NVL(active_isir,'N') = 'Y';

    active_isir_rec cur_active_isir%ROWTYPE;

--
-- Cursor to get term totals for a disbursement
--
      CURSOR cur_term_amounts (p_award_id       NUMBER)
      IS
      SELECT disb.ld_cal_type,
             disb.ld_sequence_number,
             disb.base_attendance_type_code,
             SUM(disb.disb_gross_amt) term_total
      FROM   igf_aw_awd_disb_all disb,
             igf_aw_award_all    awd
      WHERE  awd.award_id = disb.award_id
        AND  awd.award_id = p_award_id
        GROUP BY disb.ld_cal_type,disb.ld_sequence_number,disb.base_attendance_type_code;

      term_amounts_rec cur_term_amounts%ROWTYPE;

    CURSOR c_change_trans IS
    SELECT disb.*,disb.rowid row_id
      FROM igf_aw_awd_disb_all disb
     WHERE disb.award_id   = p_award_id
       AND disb.trans_type = 'C'
    FOR UPDATE OF disb.disb_gross_amt NOWAIT;

    p_term_aid              NUMBER;
    p_return_status         VARCHAR2(30);
    lv_pell_mat             VARCHAR2(30);

BEGIN

    IF p_fed_fund_code = 'PELL' THEN
      IF igf_aw_gen_003.check_coa(p_base_id) THEN

         OPEN   cur_active_isir(p_base_id);
         FETCH  cur_active_isir INTO active_isir_rec;
         IF cur_active_isir%FOUND THEN
           CLOSE cur_active_isir;
           --
           -- FA 131 Check
           -- Check if the amount is less, raise error
           --
           FOR term_amounts_rec IN cur_term_amounts(p_award_id)
           LOOP
              p_message := NULL;
              igf_gr_pell_calc.calc_term_pell(p_base_id,
                                              term_amounts_rec.base_attendance_type_code,
                                              term_amounts_rec.ld_cal_type,term_amounts_rec.ld_sequence_number,
                                              p_term_aid,
                                              p_return_status,
                                              p_message,
                                              'IGFGR005',
                                              lv_pell_mat);

              IF NVL(p_return_status,'N') = 'E' THEN
                 RETURN;
              ELSIF NVL(p_term_aid,0) < term_amounts_rec.term_total THEN
                 fnd_message.set_name('IGF','IGF_AW_PELL_DISB_ERR');
                 fnd_message.set_token('LD_ALT_CODE',igf_gr_gen.get_alt_code(term_amounts_rec.ld_cal_type,term_amounts_rec.ld_sequence_number));
                 fnd_message.set_token('ATT_TYPE',igf_aw_gen.lookup_desc('IGF_GR_RFMS_ENROL_STAT',term_amounts_rec.base_attendance_type_code));
                 fnd_message.set_token('TERM_TOTAL',term_amounts_rec.term_total);
                 fnd_message.set_token('CALC_AMT',p_term_aid);
                 p_message := fnd_message.get;
                 RETURN;
              END IF;
           END LOOP;

         ELSE
            CLOSE cur_active_isir;
         END IF;
      END IF;
    END IF;

    IF p_award_stat ='CDA' THEN
       FOR c_change_trans_rec IN c_change_trans  LOOP

--
-- As accepted amount made equal to Offered amount,
-- net amount is based on accepted amt
--
       c_change_trans_rec.disb_net_amt  :=  c_change_trans_rec.disb_gross_amt        -
                                            NVL(c_change_trans_rec.fee_1,0)          -
                                            NVL(c_change_trans_rec.fee_2,0)          +
                                            NVL(c_change_trans_rec.fee_paid_1,0)     +
                                            NVL(c_change_trans_rec.fee_paid_2,0)     +
                                            NVL(c_change_trans_rec.int_rebate_amt,0);
           -- x_called_from  passed to igf_aw_awd_disb_pkg.update_row is hard coded
           -- as IGFAW016 as this procedural update_awd_cancell_to_offer call out
           -- happens only through IGFAW016 - Student Awards form

           igf_aw_awd_disb_pkg.update_row (
                 x_mode                           =>   'R',
                 x_rowid                          =>   c_change_trans_rec.row_id,
                 x_award_id                       =>   c_change_trans_rec.award_id,
                 x_disb_num                       =>   c_change_trans_rec.disb_num,
                 x_tp_cal_type                    =>   c_change_trans_rec.tp_cal_type,
                 x_tp_sequence_number             =>   c_change_trans_rec.tp_sequence_number,
                 x_disb_gross_amt                 =>   c_change_trans_rec.disb_gross_amt,
                 x_fee_1                          =>   c_change_trans_rec.fee_1,
                 x_fee_2                          =>   c_change_trans_rec.fee_2,
                 x_disb_net_amt                   =>   c_change_trans_rec.disb_net_amt,
                 x_disb_date                      =>   c_change_trans_rec.disb_date,
                 x_trans_type                     =>   'P',
                 x_elig_status                    =>   'N',
                 x_elig_status_date               =>   TRUNC(SYSDATE),
                 x_affirm_flag                    =>   c_change_trans_rec.affirm_flag,
                 x_hold_rel_ind                   =>   c_change_trans_rec.hold_rel_ind,
                 x_manual_hold_ind                =>   c_change_trans_rec.manual_hold_ind,
                 x_disb_status                    =>   c_change_trans_rec.disb_status,
                 x_disb_status_date               =>   c_change_trans_rec.disb_status_date,
                 x_late_disb_ind                  =>   c_change_trans_rec.late_disb_ind,
                 x_fund_dist_mthd                 =>   c_change_trans_rec.fund_dist_mthd,
                 x_prev_reported_ind              =>   c_change_trans_rec.prev_reported_ind,
                 x_fund_release_date              =>   c_change_trans_rec.fund_release_date,
                 x_fund_status                    =>   c_change_trans_rec.fund_status,
                 x_fund_status_date               =>   c_change_trans_rec.fund_status_date,
                 x_fee_paid_1                     =>   c_change_trans_rec.fee_paid_1,
                 x_fee_paid_2                     =>   c_change_trans_rec.fee_paid_2,
                 x_cheque_number                  =>   c_change_trans_rec.cheque_number,
                 x_ld_cal_type                    =>   c_change_trans_rec.ld_cal_type,
                 x_ld_sequence_number             =>   c_change_trans_rec.ld_sequence_number,
                 x_disb_accepted_amt              =>   c_change_trans_rec.disb_gross_amt,--Accepted amount made equal to Offered amount
                 x_disb_paid_amt                  =>   c_change_trans_rec.disb_paid_amt,
                 x_rvsn_id                        =>   c_change_trans_rec.rvsn_id,
                 x_int_rebate_amt                 =>   c_change_trans_rec.int_rebate_amt,
                 x_force_disb                     =>   c_change_trans_rec.force_disb,
                 x_min_credit_pts                 =>   c_change_trans_rec.min_credit_pts,
                 x_disb_exp_dt                    =>   c_change_trans_rec.disb_exp_dt,
                 x_verf_enfr_dt                   =>   c_change_trans_rec.verf_enfr_dt,
                 x_fee_class                      =>   c_change_trans_rec.fee_class,
                 x_show_on_bill                   =>   c_change_trans_rec.show_on_bill,
                 x_attendance_type_code           =>   c_change_trans_rec.attendance_type_code,
                 x_base_attendance_type_code      =>   c_change_trans_rec.base_attendance_type_code,
                 x_payment_prd_st_date            =>   c_change_trans_rec.payment_prd_st_date,
                 x_change_type_code               =>   c_change_trans_rec.change_type_code,
                 x_fund_return_mthd_code          =>   c_change_trans_rec.fund_return_mthd_code,
                 x_called_from                    =>   'IGFAW016',
                 x_direct_to_borr_flag            =>   c_change_trans_rec.direct_to_borr_flag
             );
        END LOOP;
    ELSIF p_award_stat ='CDO' THEN
       FOR c_change_trans_rec IN c_change_trans  LOOP
           igf_aw_awd_disb_pkg.update_row (
                 x_mode                           =>   'R',
                 x_rowid                          =>   c_change_trans_rec.row_id,
                 x_award_id                       =>   c_change_trans_rec.award_id,
                 x_disb_num                       =>   c_change_trans_rec.disb_num,
                 x_tp_cal_type                    =>   c_change_trans_rec.tp_cal_type,
                 x_tp_sequence_number             =>   c_change_trans_rec.tp_sequence_number,
                 x_disb_gross_amt                 =>   c_change_trans_rec.disb_gross_amt,
                 x_fee_1                          =>   c_change_trans_rec.fee_1,
                 x_fee_2                          =>   c_change_trans_rec.fee_2,
                 x_disb_net_amt                   =>   c_change_trans_rec.disb_net_amt,
                 x_disb_date                      =>   c_change_trans_rec.disb_date,
                 x_trans_type                     =>   'P',
                 x_elig_status                    =>   'N',
                 x_elig_status_date               =>   TRUNC(SYSDATE),
                 x_affirm_flag                    =>   c_change_trans_rec.affirm_flag,
                 x_hold_rel_ind                   =>   c_change_trans_rec.hold_rel_ind,
                 x_manual_hold_ind                =>   c_change_trans_rec.manual_hold_ind,
                 x_disb_status                    =>   c_change_trans_rec.disb_status,
                 x_disb_status_date               =>   c_change_trans_rec.disb_status_date,
                 x_late_disb_ind                  =>   c_change_trans_rec.late_disb_ind,
                 x_fund_dist_mthd                 =>   c_change_trans_rec.fund_dist_mthd,
                 x_prev_reported_ind              =>   c_change_trans_rec.prev_reported_ind,
                 x_fund_release_date              =>   c_change_trans_rec.fund_release_date,
                 x_fund_status                    =>   c_change_trans_rec.fund_status,
                 x_fund_status_date               =>   c_change_trans_rec.fund_status_date,
                 x_fee_paid_1                     =>   c_change_trans_rec.fee_paid_1,
                 x_fee_paid_2                     =>   c_change_trans_rec.fee_paid_2,
                 x_cheque_number                  =>   c_change_trans_rec.cheque_number,
                 x_ld_cal_type                    =>   c_change_trans_rec.ld_cal_type,
                 x_ld_sequence_number             =>   c_change_trans_rec.ld_sequence_number,
                 x_disb_accepted_amt              =>   c_change_trans_rec.disb_accepted_amt,
                 x_disb_paid_amt                  =>   c_change_trans_rec.disb_paid_amt,
                 x_rvsn_id                        =>   c_change_trans_rec.rvsn_id,
                 x_int_rebate_amt                 =>   c_change_trans_rec.int_rebate_amt,
                 x_force_disb                     =>   c_change_trans_rec.force_disb,
                 x_min_credit_pts                 =>   c_change_trans_rec.min_credit_pts,
                 x_disb_exp_dt                    =>   c_change_trans_rec.disb_exp_dt,
                 x_verf_enfr_dt                   =>   c_change_trans_rec.verf_enfr_dt,
                 x_fee_class                      =>   c_change_trans_rec.fee_class,
                 x_show_on_bill                   =>   c_change_trans_rec.show_on_bill,
                 x_attendance_type_code           =>   c_change_trans_rec.attendance_type_code,
                 x_base_attendance_type_code      =>   c_change_trans_rec.base_attendance_type_code,
                 x_payment_prd_st_date            =>   c_change_trans_rec.payment_prd_st_date,
                 x_change_type_code               =>   c_change_trans_rec.change_type_code,
                 x_fund_return_mthd_code          =>   c_change_trans_rec.fund_return_mthd_code,
                 x_direct_to_borr_flag            =>   c_change_trans_rec.direct_to_borr_flag
             );
        END LOOP;
    END IF;
EXCEPTION
WHEN app_exception.record_lock_exception THEN
   ROLLBACK;

WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_AW_GEN_003.UPDATE_AWD_CANCELL_TO_OFFER'||' ' || SQLERRM);
   app_exception.raise_exception;

END update_awd_cancell_to_offer;


FUNCTION check_disbdts ( p_award_id          IN      igf_aw_award_all.award_id%TYPE,
                         p_ld_seq_number     IN      NUMBER)
RETURN VARCHAR2
IS


--------------------------------------------------------------------------------------
-- sjadhav       18-Feb-2003       Bug 2758823
--                                 check if disbursement dates are in order with
--                                 disbursement numbers for Planned and Actual
--                                 Disbursements
--------------------------------------------------------------------------------------

--mesriniv
--Bug 2394012
--Disbursement message to be modified
--Removed TOKENS for message IGF_DB_DISB_ORDER

-- sjadhav
-- Bug 2387496
-- Added new function to check dates

     CURSOR  cur_disb_num ( p_award_id igf_aw_award_all.award_id%TYPE) IS
     SELECT  disb_num,disb_date,trans_type
     FROM
     igf_aw_awd_disb_all
     WHERE
     award_id = p_award_id
     AND
     trans_type IN ('P','A')
     ORDER BY
     disb_num;

     disb_num_rec cur_disb_num%ROWTYPE;

     CURSOR  cur_disb_dat ( p_award_id igf_aw_award_all.award_id%TYPE) IS
     SELECT  disb_num,disb_date
     FROM
     igf_aw_awd_disb
     WHERE
     award_id = p_award_id
     AND
     trans_type IN ('P','A')
     ORDER BY
     disb_date;

     disb_dat_rec cur_disb_dat%ROWTYPE;

     TYPE disb_record IS RECORD
                     ( disb_num  igf_aw_awd_disb.disb_num%TYPE,
                       disb_date igf_aw_awd_disb.disb_date%TYPE
                     );

     TYPE disb_num_list IS TABLE OF disb_record INDEX BY BINARY_INTEGER;
     disb_num_ele  disb_num_list;

     TYPE disb_dat_list IS TABLE OF disb_record INDEX BY BINARY_INTEGER;
     disb_dat_ele  disb_dat_list;

     ln_count_i              BINARY_INTEGER := 0;
     ln_tot_rec              NUMBER := 0;
     lv_message              fnd_new_messages.message_text%TYPE;

BEGIN

    lv_message    := 'NULL';

    IF p_ld_seq_number IS NOT NULL THEN

        FOR  disb_num_rec IN cur_disb_num (p_award_id)
        LOOP
             ln_count_i := ln_count_i + 1;
             disb_num_ele(ln_count_i).disb_num  := disb_num_rec.disb_num;
             disb_num_ele(ln_count_i).disb_date := disb_num_rec.disb_date;

        END LOOP;

        ln_count_i := 0;

        FOR  disb_dat_rec IN cur_disb_dat ( p_award_id)
        LOOP
             ln_count_i := ln_count_i + 1;
             disb_dat_ele(ln_count_i).disb_num  := disb_dat_rec.disb_num;
             disb_dat_ele(ln_count_i).disb_date := disb_dat_rec.disb_date;
        END LOOP;

        ln_tot_rec := ln_count_i;
        ln_count_i := 0;

        IF ln_tot_rec > 0 THEN

            LOOP
                 ln_count_i := ln_count_i + 1;
                 EXIT WHEN ln_count_i >  ln_tot_rec;
                 IF disb_num_ele(ln_count_i).disb_num <> disb_dat_ele(ln_count_i).disb_num THEN
                      fnd_message.set_name('IGF','IGF_DB_DISB_ORDER');

                      lv_message := fnd_message.get;
                      RETURN lv_message;
                 END IF;

             END LOOP;

        END IF;

    END IF;

  RETURN lv_message;

EXCEPTION

WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_GEN_003.CHECK_DISBDTS'||' ' || SQLERRM);
      app_exception.raise_exception;

END check_disbdts;


FUNCTION check_amounts ( p_calling_form      IN OUT NOCOPY  VARCHAR2,
                         p_base_id           IN      igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_fund_id           IN      igf_aw_fund_mast_all.fund_id%TYPE,
                         p_fund_code         IN      igf_aw_fund_mast_all.fund_code%TYPE,
                         p_fed_fund_code     IN      igf_aw_fund_cat_all.fed_fund_code%TYPE,
                         p_person_number     IN      igf_aw_award_v.person_number%TYPE,
                         p_award_id          IN      igf_aw_award_all.award_id%TYPE,
                         p_act_isir          IN      VARCHAR2,
                         p_ld_seq_number     IN      NUMBER,
                         p_awd_prd_code      IN      igf_aw_awd_prd_term.award_prd_cd%TYPE,
                         p_chk_holds         OUT NOCOPY     VARCHAR2)
RETURN VARCHAR2
IS

--------------------------------------------------------------------------------------------
-- rajagupt  16-Sep-2005      Bug # 2425618. Changed the if condition to check whether
--                            the award amount is exceeding the remaining amount in the fund
--                            Added an if condition for over awards for FWS

---------------------------------------------------------------------------------------------
-- cdcruz    28-Oct-2004      Bug # 3021287
--                            p_chk_holds parameter declared as varchar2(1) in the pld
---------------------------------------------------------------------------------------------
-- cdcruz    28-Oct-2004      Bug # 3021287
--                            p_chk_holds parameter changed from boolean to varchar2
--                            will return the following values
--                            Null -> No Overawd situation
--                            'A'  -> Overawd situation at Awd Period
--                            'Y'  -> Overawd situation at Awd Yr Level
---------------------------------------------------------------------------------------------
-- veramach   14-Apr-2004     Bug # 3547237
--                            Obsoleted igf_aw_gen_002.get_fed_efc and replaced references
--                            with igf_aw_packng_subfns.get_fed_efc
---------------------------------------------------------------------------------------------
-- bkkumar    14-Jan-04       Bug# 3360702
--                            Passed the ln_corrected_amt paramter as 0 to the check_loan_limits and also displayed the
--                            error message correctly.
---------------------------------------------------------------------------------------------
--
-- sjadhav     Jan-30-2003    Bug 2776704. Removed emulate_fed check
--                            as we are having all funds with fed method
--                            this check is removed from check amounts
--                            added a cursor to sum up all awards for student
--                            to check for overaward
--
---------------------------------------------------------------------------------------------
--
-- sjadhav
-- Bug 2255279
-- Added procedure check_amounts
---------------------------------------------------------------------------------------------

--
-- Gets the max amt + max terms the student got a fund in a lifetime
--

    CURSOR cur_max_lf_count ( cp_fund_code   igf_aw_fund_mast_all.fund_code%TYPE ,
                              cp_person_id   igf_ap_fa_base_rec_all.person_id%TYPE)
    IS
    SELECT
    NVL(SUM(NVL(disb.disb_gross_amt,0)),0)    lf_total,
    COUNT(DISTINCT awd.award_id)         lf_count
    FROM
    igf_aw_awd_disb_all  disb,
    igf_aw_award_all     awd,
    igf_aw_fund_mast_all fmast,
    igf_ap_fa_base_rec_all fabase
    WHERE fmast.fund_code  = cp_fund_code
      AND disb.award_id    = awd.award_id
      AND awd.fund_id      = fmast.fund_id
      AND awd.base_id      = fabase.base_id
      AND fabase.person_id = cp_person_id
      AND disb.trans_type <> 'C'
      AND awd.award_status IN ('OFFERED', 'ACCEPTED');

    max_lf_count_rec      cur_max_lf_count%ROWTYPE;

--
-- Cursor to Aggregate Award and Count
--
    CURSOR cur_agg_lf_count ( cp_fund_code   igf_aw_fund_mast_all.fund_code%TYPE ,
                              cp_person_id   igf_ap_fa_base_rec_all.person_id%TYPE)
    IS
    SELECT NVL(SUM(NVL(awd.offered_amt,0)),0) lf_total,
           COUNT(awd.award_id)           lf_count
      FROM igf_aw_award_all          awd,
           igf_aw_fund_mast_all      fmast,
           igf_ap_fa_base_rec        fabase,
           igf_ap_batch_aw_map_all   bam
    WHERE fmast.fund_code  = cp_fund_code
      AND awd.fund_id      = fmast.fund_id
      AND awd.base_id      = fabase.base_id
      AND fabase.person_id = cp_person_id
      AND fabase.ci_cal_type         = bam.ci_cal_type
      AND fabase.ci_sequence_number  = bam.ci_sequence_number
      AND awd.award_status IN ('OFFERED', 'ACCEPTED')
      AND bam.award_year_status_code IN ('LA','LE');

    agg_lf_count_rec      cur_agg_lf_count%ROWTYPE;
--
--  This cursor retrives Total Award for a Fund - This is Yearly amount
--

      CURSOR cur_total_fund_awd (p_base_id      igf_aw_award.base_id%TYPE,
                                 p_fund_id      igf_aw_fund_mast_all.fund_id%TYPE)
      IS
      SELECT SUM(disb.disb_gross_amt) total_fund_amt
      FROM
      igf_aw_award  awd,
      igf_aw_awd_disb disb
      WHERE awd.base_id  = p_base_id
        AND awd.fund_id  = p_fund_id
        AND awd.award_id = disb.award_id
        AND awd.award_status IN ('OFFERED', 'ACCEPTED')
        AND disb.trans_type <> 'C';

      total_fund_awd_rec  cur_total_fund_awd%ROWTYPE;
--
--  This cursor retrives Total Amount for a Award -
--
      CURSOR cur_total_award_amt (p_award_id     igf_aw_award_all.award_id%TYPE)
      IS
      SELECT
      SUM(disb.disb_gross_amt) total_award_amt
      FROM
      igf_aw_awd_disb disb
      WHERE
      disb.award_id = p_award_id AND
      disb.trans_type <> 'C';

      total_award_amt_rec  cur_total_award_amt%ROWTYPE;

--
-- Cursor to determine if the Fund uses federal methodology or not
--
      CURSOR cur_chk_fdl_fund (p_fund_id      igf_aw_fund_mast_all.fund_id%TYPE)
      IS
      SELECT
      fm.replace_fc
      FROM
      igf_aw_fund_mast    fm
      WHERE
      fm.fund_id     = p_fund_id;

      chk_fdl_fund_rec  cur_chk_fdl_fund%ROWTYPE;

      CURSOR cur_fund_details( p_fund_id  igf_aw_fund_mast.fund_id%TYPE)
      IS
      SELECT
      DECODE(
             NVL(allow_overaward,'N'),'N',
             NVL(fmast.remaining_amt,0),
             NVL(fmast.remaining_amt,0) +
                (
                   DECODE (
                            NVL(over_award_amt,0),0,
                            NVL(over_award_perct,0) * NVL(fmast.available_amt,0) / 100,
                            NVL(over_award_amt,0)
                           )
                )
           )remaining_amt,
      NVL(fmast.max_yearly_amt,0) max_yearly_amt,
      NVL(fmast.max_award_amt,0)  max_award_amt,
      NVL(fmast.max_life_amt,0)   max_life_amt,
      NVL(fmast.max_life_term,0)  max_life_term,
      fmast.min_award_amt,
      fmast.max_num_disb,
      fmast.min_num_disb
      FROM
      igf_aw_fund_mast_all fmast
      WHERE
      fmast.fund_id = p_fund_id;

      fund_details_rec           cur_fund_details%ROWTYPE;


--
-- Cursor to get total disbursements for award
--
      CURSOR cur_get_count ( p_award_id igf_aw_award_all.award_id%TYPE)
      IS
      SELECT
      COUNT(ld_cal_type) disb_count
      FROM igf_aw_awd_disb
      WHERE
      award_id = p_award_id;


      CURSOR  cur_disb_num ( p_award_id igf_aw_award_all.award_id%TYPE) IS
      SELECT  disb_num,disb_date,trans_type,disb_accepted_amt accepted_amt
      FROM
      igf_aw_awd_disb_all
      WHERE
      award_id = p_award_id;

      disb_num_rec cur_disb_num%ROWTYPE;


      CURSOR c_award_status
      IS
      SELECT
      *
      FROM
      igf_aw_award
      WHERE
      award_id = p_award_id ;

      c_award_status_rec  c_award_status%ROWTYPE;

--
-- Cursor to get term totals for a disbursement
--
      CURSOR cur_term_amounts (p_award_id       NUMBER,
                               p_ld_seq_number  NUMBER)
      IS
      SELECT disb.ld_cal_type,
             disb.ld_sequence_number,
             disb.base_attendance_type_code,
             SUM(disb.disb_gross_amt) term_total
      FROM   igf_aw_awd_disb_all disb,
             igf_aw_award_all    awd
      WHERE  disb.trans_type <> 'C'
        AND  awd.award_id = disb.award_id
        AND  awd.award_id = p_award_id
        AND  disb.ld_sequence_number = p_ld_seq_number
        GROUP BY disb.ld_cal_type,disb.ld_sequence_number,disb.base_attendance_type_code;

      term_amounts_rec cur_term_amounts%ROWTYPE;

      ln_count_i              BINARY_INTEGER := 0;
      ln_tot_rec              NUMBER := 0;
      ln_aid                  NUMBER;
      lnf_resource            NUMBER;
      lni_resource            NUMBER;
      ln_unmet_need_f         NUMBER;
      ln_unmet_need_i         NUMBER;
      ln_resource_f_fc        NUMBER;
      ln_resource_i_fc        NUMBER;
      lv_pell_mat             VARCHAR2(60) ;
      ln_corrected_amt        NUMBER;
      ln_count_rec            NUMBER  := 0;
      p_term_aid              NUMBER;
      p_return_status         VARCHAR2(30);
      p_message               VARCHAR2(4000);
      lv_message              fnd_new_messages.message_text%TYPE;
      l_std_loan_tab          igf_aw_packng_subfns.std_loan_tab := igf_aw_packng_subfns.std_loan_tab();
      l_msg_name              fnd_new_messages.message_name%TYPE;
      l_efc                   NUMBER;
      l_dummy_pell_efc        NUMBER;
      l_no_of_months          NUMBER;
      l_subz_loan             VARCHAR2(1);
      l_efc_ay                NUMBER;

BEGIN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','Parameter List - START');
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','p_calling_form: ' ||p_calling_form);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','p_base_id: ' ||p_base_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','p_fund_id: ' ||p_fund_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','p_fund_code: ' ||p_fund_code);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','p_fed_fund_code: ' ||p_fed_fund_code);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','p_person_number: ' ||p_person_number);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','p_award_id: ' ||p_award_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','p_act_isir: ' ||p_act_isir);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','p_ld_seq_number: ' ||p_ld_seq_number);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','p_awd_prd_code: ' ||p_awd_prd_code);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','Parameter List - END');
      END IF;

      lv_message    := 'NULL';
      p_chk_holds   := '*';

      OPEN  cur_fund_details( p_fund_id);
      FETCH cur_fund_details INTO fund_details_rec;
      CLOSE cur_fund_details;

      OPEN  cur_total_fund_awd (p_base_id,p_fund_id);
      FETCH cur_total_fund_awd INTO total_fund_awd_rec;
      CLOSE cur_total_fund_awd;

      OPEN  cur_total_award_amt(p_award_id);
      FETCH cur_total_award_amt INTO total_award_amt_rec;
      CLOSE cur_total_award_amt;

      OPEN  cur_max_lf_count( p_fund_code,igf_gr_gen.get_person_id(p_base_id));
      FETCH cur_max_lf_count INTO max_lf_count_rec;
      CLOSE cur_max_lf_count;

      OPEN  cur_agg_lf_count( p_fund_code,igf_gr_gen.get_person_id(p_base_id));
      FETCH cur_agg_lf_count INTO agg_lf_count_rec;
      CLOSE cur_agg_lf_count;

      max_lf_count_rec.lf_total := max_lf_count_rec.lf_total + agg_lf_count_rec.lf_total;
      max_lf_count_rec.lf_count := max_lf_count_rec.lf_count + agg_lf_count_rec.lf_count;

      OPEN  cur_get_count( p_award_id);
      FETCH cur_get_count INTO ln_count_rec;
      CLOSE cur_get_count;

      -- Getting the award status for the award
      OPEN  c_award_status ;
      FETCH c_award_status INTO c_award_status_rec;
      CLOSE c_award_status;


      IF ln_count_rec = 0 THEN
           fnd_message.set_name('IGF','IGF_DB_NO_DISB_AWD');
           lv_message := fnd_message.get;
           RETURN lv_message;
      END IF;

      --
      -- Check Whether the award amount is exceeding the remaining amount in the fund
      --
      IF  fund_details_rec.remaining_amt < 0 THEN
           fnd_message.set_name('IGF','IGF_AW_NO_ENUGH_FNDS');
           lv_message := fnd_message.get;
           RETURN lv_message;
      END IF;

      -- l_subz_loan is set to 'Y' for Subsidized loans. This is needed bcoz for Subsidized
      -- loans, VA30 and AMERICORPS awards are not considered as a resource. This flag is used
      -- down the line in the call to get_resource_need()
      IF p_fed_fund_code IN ('DLS','FLS') THEN
        l_subz_loan := 'Y';

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','Fund is DLS/FLS, so set l_subz_loan to Y');
        END IF;
      ELSE
        l_subz_loan := 'N';

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','Fund is NOT DLS/FLS, so set l_subz_loan to N');
        END IF;
      END IF;

      -- This would ensure that if the Award Status is accepted and the disb number's transaction type
      -- is Actual or Planned then the Accepted amount must be entered;
      -- Bug id :
      FOR disb_num_rec IN cur_disb_num  (p_award_id) LOOP
          IF  disb_num_rec.trans_type IN ('P','A')AND c_award_status_rec.award_status ='ACCEPTED' THEN
            IF disb_num_rec.accepted_amt IS NULL THEN
              fnd_message.set_name('IGF','IGF_DB_ENTER_ACCEPT_AMT');
              fnd_message.set_token('DISB_NUM',disb_num_rec.disb_num);
              lv_message := fnd_message.get;
              RETURN lv_message;
            END IF;
          END IF;
      END LOOP;

      IF p_ld_seq_number IS NOT NULL THEN

    --
    -- Min / Max Number of Disbursement Check
    --


        IF fund_details_rec.min_num_disb IS NOT NULL THEN
             IF ln_count_rec < fund_details_rec.min_num_disb THEN
                fnd_message.set_name('IGF','IGF_AW_MIN_NUM_DISB_NOT_EXCEED');
                lv_message := fnd_message.get;
                RETURN lv_message;
             END IF;
        END IF;

        IF fund_details_rec.max_num_disb IS NOT NULL THEN
             IF ln_count_rec > fund_details_rec.max_num_disb THEN
                fnd_message.set_name('IGF','IGF_AW_MAX_NUM_DISB_EXCEEDED');
                lv_message := fnd_message.get;
                RETURN lv_message;
             END IF;
        ELSE

             IF  p_calling_form IN ('IGFAW038','IGFAW039') THEN
                  --
                  -- If the maximum disb num is not specified, for PLUS it is 4/ For Sub/unsub 20
                  --
                       IF p_fed_fund_code IN ('DLP','FLP') THEN   -- PLUS
                          IF ln_count_rec > 4 THEN
                             fnd_message.set_name('IGF','IGF_AW_PLUS_DISB');
                             lv_message := fnd_message.get;
                             RETURN lv_message;
                          END IF;
                       ELSIF p_fed_fund_code IN ('DLS','FLS','DLU','FLU') THEN   -- S.UNS.
                          IF ln_count_rec > 20 THEN
                             fnd_message.set_name('IGF','IGF_AW_SUNS_DISB');
                             lv_message := fnd_message.get;
                             RETURN lv_message;
                          END IF;
                       END IF;

             ELSIF  p_calling_form = 'IGFGR005' THEN

                  --
                  -- If the maximum disb num is not specified, for Pell it can be 90
                  --
                       IF ln_count_rec > 90 THEN
                              fnd_message.set_name('IGF','IGF_AW_PELL_DISB');
                              lv_message := fnd_message.get;
                              RETURN lv_message;
                       END IF;
             END IF;

        END IF; -- max num disb check

      END IF; -- term seq no is not null


      IF  UPPER(p_calling_form) = 'IGFGR005' THEN

           --
           -- FA 131 Check
           -- Check if the amount is less, add as warning message
           -- if calc_term_pell does not error out
           --
           FOR term_amounts_rec IN cur_term_amounts(p_award_id,p_ld_seq_number)
           LOOP

              p_message := NULL;
              igf_gr_pell_calc.calc_term_pell(p_base_id,
                                              term_amounts_rec.base_attendance_type_code,
                                              term_amounts_rec.ld_cal_type,term_amounts_rec.ld_sequence_number,
                                              p_term_aid,
                                              p_return_status,
                                              p_message,
                                              'IGFGR005',
                                              lv_pell_mat);

              IF NVL(p_return_status,'N') = 'E' THEN
                 lv_message := p_message;
                 RETURN lv_message;
              ELSIF NVL(p_term_aid,0) < term_amounts_rec.term_total THEN
                 fnd_message.set_name('IGF','IGF_AW_PELL_DISB_WARN');
                 fnd_message.set_token('LD_ALT_CODE',igf_gr_gen.get_alt_code(term_amounts_rec.ld_cal_type,term_amounts_rec.ld_sequence_number));
                 fnd_message.set_token('ATT_TYPE',igf_aw_gen.lookup_desc('IGF_GR_RFMS_ENROL_STAT',term_amounts_rec.base_attendance_type_code));
                 fnd_message.set_token('TERM_TOTAL',term_amounts_rec.term_total);
                 fnd_message.set_token('CALC_AMT',p_term_aid);
                 fnd_msg_pub.add;
              END IF;
           END LOOP;
           --
           -- if the pell matrix changes for calculation
           -- we need to update igf_aw_award with the new value for lv_pell_mat
           --
           IF lv_pell_mat <> c_award_status_rec.alt_pell_schedule THEN

                   c_award_status_rec.alt_pell_schedule := lv_pell_mat;

                   igf_aw_award_pkg.update_row(x_rowid               => c_award_status_rec.row_id,
                                              x_award_id             => c_award_status_rec.award_id,
                                              x_fund_id              => c_award_status_rec.fund_id,
                                              x_base_id              => c_award_status_rec.base_id,
                                              x_offered_amt          => c_award_status_rec.offered_amt,
                                              x_accepted_amt         => c_award_status_rec.accepted_amt,
                                              x_paid_amt             => c_award_status_rec.paid_amt,
                                              x_packaging_type       => c_award_status_rec.packaging_type,
                                              x_batch_id             => c_award_status_rec.batch_id,
                                              x_manual_update        => c_award_status_rec.manual_update,
                                              x_rules_override       => c_award_status_rec.rules_override,
                                              x_award_date           => c_award_status_rec.award_date,
                                              x_award_status         => c_award_status_rec.award_status,
                                              x_attribute_category   => c_award_status_rec.attribute_category,
                                              x_attribute1           => c_award_status_rec.attribute1,
                                              x_attribute2           => c_award_status_rec.attribute2,
                                              x_attribute3           => c_award_status_rec.attribute3,
                                              x_attribute4           => c_award_status_rec.attribute4,
                                              x_attribute5           => c_award_status_rec.attribute5,
                                              x_attribute6           => c_award_status_rec.attribute6,
                                              x_attribute7           => c_award_status_rec.attribute7,
                                              x_attribute8           => c_award_status_rec.attribute8,
                                              x_attribute9           => c_award_status_rec.attribute9,
                                              x_attribute10          => c_award_status_rec.attribute10,
                                              x_attribute11          => c_award_status_rec.attribute11,
                                              x_attribute12          => c_award_status_rec.attribute12,
                                              x_attribute13          => c_award_status_rec.attribute13,
                                              x_attribute14          => c_award_status_rec.attribute14,
                                              x_attribute15          => c_award_status_rec.attribute15,
                                              x_attribute16          => c_award_status_rec.attribute16,
                                              x_attribute17          => c_award_status_rec.attribute17,
                                              x_attribute18          => c_award_status_rec.attribute18,
                                              x_attribute19          => c_award_status_rec.attribute19,
                                              x_attribute20          => c_award_status_rec.attribute20,
                                              x_rvsn_id              => c_award_status_rec.rvsn_id,
                                              x_alt_pell_schedule    => c_award_status_rec.alt_pell_schedule,
                                              x_mode                 => 'R',
                                              x_award_number_txt     => c_award_status_rec.award_number_txt,
                                              x_legacy_record_flag   => NULL,
                                              x_adplans_id           => c_award_status_rec.adplans_id,
                                              x_lock_award_flag      => c_award_status_rec.lock_award_flag,
                                              x_app_trans_num_txt    => c_award_status_rec.app_trans_num_txt,
                                              x_awd_proc_status_code => c_award_status_rec.awd_proc_status_code,
                                              x_notification_status_code => c_award_status_rec.notification_status_code,
                                              x_notification_status_date => c_award_status_rec.notification_status_date,
                                              x_publish_in_ss_flag       => c_award_status_rec.publish_in_ss_flag
                                             );


           END IF; -- pell schdl has changed
      END IF; -- calling form is igfgr005

--
-- Start Bug 2431276
-- These five validatons changed to warnings from errors
--
-- start of warnings

--
-- Check Whether the award amount is exceeding the Min Limit Amounts in the fund
--

      IF  NVL(total_award_amt_rec.total_award_amt,0) < fund_details_rec.min_award_amt  THEN
          fnd_message.set_name('IGF','IGF_AW_MIN_AMT_FAILED');
          fnd_message.set_token('AMOUNT',fund_details_rec.min_award_amt);
          fnd_message.set_token('FUND',p_fund_code);
          fnd_msg_pub.add;
      END IF;

--
-- Check if the Award Amount is exceeding the Max Award Amount in the fund
--
      IF  NVL(total_award_amt_rec.total_award_amt,0) > fund_details_rec.max_award_amt THEN
          fnd_message.set_name('IGF','IGF_AW_MAX_AMT_EXCEED');
          fnd_message.set_token('AMOUNT',fund_details_rec.max_award_amt);
          fnd_message.set_token('FUND',p_fund_code);
          fnd_msg_pub.add;
      END IF;

--
-- Check if the Award Amount is exceeding the Max Yearly Amounts in the fund
--
      IF  fund_details_rec.max_yearly_amt > 0  THEN
        IF  NVL(total_fund_awd_rec.total_fund_amt,0) > fund_details_rec.max_yearly_amt THEN
            fnd_message.set_name('IGF','IGF_AW_STD_EXCED_MAX_YR_AMT');
            fnd_message.set_token('AMOUNT',fund_details_rec.max_yearly_amt);
            fnd_message.set_token('FUND',p_fund_code);
            fnd_msg_pub.add;
        END IF;
      END IF;
--
-- Check whether the Award Amount is exceeding the LifeTime Amount in the fund
--
      IF fund_details_rec.max_life_amt >0 THEN
         IF NVL(max_lf_count_rec.lf_total,0) > fund_details_rec.max_life_amt THEN
            fnd_message.set_name('IGF','IGF_AW_STD_EXCED_MAX_LF_AMT');
            fnd_message.set_token('AMOUNT',fund_details_rec.max_life_amt);
            fnd_message.set_token('FUND',p_fund_code);
            fnd_msg_pub.add;
        END IF;
      END IF;
--
-- Check whether the Award count is exceeding the LifeTime count in the fund
--

      IF fund_details_rec.max_life_term >0 THEN
          IF NVL(max_lf_count_rec.lf_count,0) > fund_details_rec.max_life_term THEN
                fnd_message.set_name('IGF','IGF_DB_MAX_LIFE_TERM_EXCEED');
                fnd_message.set_token('TERM',fund_details_rec.max_life_term );
                fnd_message.set_token('FUND',p_fund_code);
                fnd_msg_pub.add;
          END IF;
      END IF;

--
-- end of warnings
-- End Bug 2431276
--

      --
      -- Check for the Federal Loan Limits
      --
      --
      -- The check for active isir will not be needed once igfaw016 comes up with
      -- the validation which will not allow addition of awards if there is no isir present
      --

      IF p_act_isir IS NOT NULL AND
         UPPER(p_calling_form) IN ('IGFAW038','IGFAW039')THEN
       IF p_fed_fund_code IN ('DLS','DLU','FLS','FLU') THEN
          ln_corrected_amt := 0;
          l_msg_name := NULL;
          -- since the fund amount is already awarded to the student then ln_corrected_amt is passed as 0.
          igf_aw_packng_subfns.check_loan_limits(l_base_id => p_base_id,
                                                 fund_type => p_fed_fund_code,
                                                 l_award_id => p_award_id,
                                                 l_adplans_id => NULL,
                                                 l_aid => ln_corrected_amt,
                                                 l_std_loan_tab => l_std_loan_tab,
                                                 p_msg_name => l_msg_name,
                                                 l_awd_period => p_awd_prd_code,
                                                 l_called_from => 'PACKAGING'
                                                 );
          -- If the returned ln_corrected_amt is 0 with no message returned or ln_corrected_amt is greater than 0 then
          -- the set up is fine ,so no warning message.
          IF ln_corrected_amt = 0 AND l_msg_name IS NOT NULL THEN
            IF l_msg_name = 'IGF_AW_CLS_STD_NOT_FND'  THEN
              l_msg_name := 'IGF_AW_CLS_STD_NOT_FND_WNG';
            ELSIF l_msg_name = 'IGF_AW_CLSSTD_MAP_NOT_FND'  THEN
              l_msg_name := 'IGF_AW_CLSSTD_MAP_NOT_FND_WNG';
            ELSIF l_msg_name = 'IGF_AW_DEP_STAT_NOT_FND'  THEN
              l_msg_name := 'IGF_AW_DEP_STAT_NOT_FND';
            ELSIF l_msg_name = 'IGF_AW_LOAN_LMT_NOT_FND'  THEN
              l_msg_name := 'IGF_AW_LOAN_LMT_NOT_FND_WNG';
            END IF;
            fnd_message.set_name('IGF',l_msg_name);
            fnd_msg_pub.add;
          ELSIF  ln_corrected_amt < 0 THEN
              -- if the ln_corrected_amt is less than 0 then some of the Stafford loan limit check has failed so
              -- we are displaying the appropriate warning message since the user can override the message.
              -- add yes no message to the stack
              --
               IF l_msg_name = 'IGF_AW_AGGR_LMT_ERR'  THEN
                 l_msg_name := 'IGF_AW_AGGR_LMT_WNG';
               ELSIF l_msg_name = 'IGF_AW_ANNUAL_LMT_ERR'  THEN
                 l_msg_name := 'IGF_AW_ANNUAL_LMT_WNG';
               ELSIF l_msg_name = 'IGF_AW_SUB_AGGR_LMT_ERR'  THEN
                 l_msg_name := 'IGF_AW_SUB_AGGR_LMT_WNG';
               ELSIF l_msg_name = 'IGF_AW_SUB_LMT_ERR'  THEN
                 l_msg_name := 'IGF_AW_SUB_LMT_ERR_WNG';
               ELSIF l_msg_name = 'IGF_AW_UNSUB_AGGR_LMT_ERR'  THEN
                 l_msg_name := 'IGF_AW_UNSUB_AGGR_LMT_WNG';
               ELSIF l_msg_name = 'IGF_AW_UNSUB_LMT_ERR'  THEN
                 l_msg_name := 'IGF_AW_UNSUB_LMT_WNG';
               END IF;
              fnd_message.set_name('IGF',l_msg_name);
              fnd_message.set_token('FUND_CODE',p_fund_code);
              fnd_msg_pub.add;
          END IF;
       END IF;
      END IF;

      --
      -- Over Award is created only for Federal Funds
      -- Check If the Fund Uses Feferal Methodology to calculate Need
      -- Check IF  the award is not of FWS type

      IF p_calling_form <> 'IGFSE003' THEN
      OPEN  cur_chk_fdl_fund(p_fund_id);
      FETCH cur_chk_fdl_fund INTO chk_fdl_fund_rec;
      CLOSE cur_chk_fdl_fund;

      -- Get the EFC months for the Award Period and for the Award Yr
      igf_aw_packng_subfns.get_fed_efc(
                                       l_base_id      => p_base_id,
                                       l_awd_prd_code => p_awd_prd_code,
                                       l_efc_f        => l_efc,
                                       l_pell_efc     => l_dummy_pell_efc,
                                       l_efc_ay       => l_efc_ay
                                       );

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','l_efc:'||l_efc);
      END IF;

      IF l_efc IS NOT NULL THEN

        -- Check for Overaward within the Awardin Period first

       IF p_awd_prd_code IS NOT NULL THEN

        igf_aw_gen_002.get_resource_need(
                                         p_base_id        => p_base_id,
                                         p_resource_f     => lnf_resource,
                                         p_resource_i     => lni_resource,
                                         p_unmet_need_f   => ln_unmet_need_f,
                                         p_unmet_need_i   => ln_unmet_need_i,
                                         p_resource_f_fc  => ln_resource_f_fc,
                                         p_resource_i_fc  => ln_resource_i_fc,
                                         p_awd_prd_code       =>    p_awd_prd_code,
                                         p_calc_for_subz_loan =>    l_subz_loan
                                        );


        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','P_AWD_PRD_CODE>ln_unmet_need_f:'|| P_AWD_PRD_CODE || ' >' || ln_unmet_need_f);
        END IF;

        IF NVL(ln_unmet_need_f,0) < 0  THEN

           -- Overawad at Awarding Period itself
           p_chk_holds := 'A';

           -- No need to proceed further for Award Year level validation
           RETURN lv_message;

        END IF;

       END IF;

        -- Now check for OverAwd scenario for the Entire Award Year

        igf_aw_gen_002.get_resource_need(
                                         p_base_id        => p_base_id,
                                         p_resource_f     => lnf_resource,
                                         p_resource_i     => lni_resource,
                                         p_unmet_need_f   => ln_unmet_need_f,
                                         p_unmet_need_i   => ln_unmet_need_i,
                                         p_resource_f_fc  => ln_resource_f_fc,
                                         p_resource_i_fc  => ln_resource_i_fc,
                                         p_awd_prd_code       =>    NULL,
                                         p_calc_for_subz_loan =>    l_subz_loan
                                        );


        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_003.check_amounts.debug','Award Year >ln_unmet_need_f: > '|| ln_unmet_need_f);
        END IF;

        IF NVL(ln_unmet_need_f,0) < 0  THEN

           -- Overawad at Awarding Period itself
           p_chk_holds := 'Y';

        END IF;

      END IF; -- EFC not null

     END IF;
   RETURN lv_message;

   EXCEPTION
WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_GEN_003.CHECK_AMOUNTS'|| ' ' ||SQLERRM );
      app_exception.raise_exception;

END check_amounts;


--
-- sjadhav
-- Bug 2306310
--
-- Procedure to update show_on_bill flag based on the fund manager value
--
PROCEDURE update_bill_flag ( p_fund_id IN igf_aw_award_all.fund_id%TYPE,
                             p_new_val IN igf_aw_fund_mast_all.show_on_bill%TYPE)
IS

--
-- Cursor to get awards of the fund
--
   CURSOR cur_get_awd ( p_fund_id IN igf_aw_award_all.fund_id%TYPE )
   IS
   SELECT award_id
   FROM
   igf_aw_award
   WHERE
   fund_id = p_fund_id;


--
-- Cursor to get Planned Disbursements for the award
--
   CURSOR cur_get_adisb ( p_award_id IN igf_aw_award_all.award_id%TYPE,
                          p_new_val IN igf_aw_fund_mast_all.show_on_bill%TYPE)
   IS
   SELECT *
   FROM
   igf_aw_awd_disb
   WHERE
   award_id   = p_award_id  AND
   trans_type = 'P'         AND
   NVL(show_on_bill,'*') <> p_new_val
   FOR UPDATE OF
   show_on_bill NOWAIT;


BEGIN

   SAVEPOINT bill_upd_sp;

   FOR get_awd_rec IN cur_get_awd ( p_fund_id )
   LOOP
       FOR get_adisb_rec IN cur_get_adisb( get_awd_rec.award_id,p_new_val)
       LOOP

           igf_aw_awd_disb_pkg.update_row( x_rowid               =>   get_adisb_rec.row_id,
                                           x_award_id            =>   get_adisb_rec.award_id,
                                           x_disb_num            =>   get_adisb_rec.disb_num,
                                           x_tp_cal_type         =>   get_adisb_rec.tp_cal_type,
                                           x_tp_sequence_number  =>   get_adisb_rec.tp_sequence_number,
                                           x_disb_gross_amt      =>   get_adisb_rec.disb_gross_amt,
                                           x_fee_1               =>   get_adisb_rec.fee_1,
                                           x_fee_2               =>   get_adisb_rec.fee_2,
                                           x_disb_net_amt        =>   get_adisb_rec.disb_net_amt,
                                           x_disb_date           =>   get_adisb_rec.disb_date,
                                           x_trans_type          =>   get_adisb_rec.trans_type,
                                           x_elig_status         =>   get_adisb_rec.elig_status,
                                           x_elig_status_date    =>   get_adisb_rec.elig_status_date,
                                           x_affirm_flag         =>   get_adisb_rec.affirm_flag,
                                           x_hold_rel_ind        =>   get_adisb_rec.hold_rel_ind,
                                           x_manual_hold_ind     =>   get_adisb_rec.manual_hold_ind,
                                           x_disb_status         =>   get_adisb_rec.disb_status,
                                           x_disb_status_date    =>   get_adisb_rec.disb_status_date,
                                           x_late_disb_ind       =>   get_adisb_rec.late_disb_ind,
                                           x_fund_dist_mthd      =>   get_adisb_rec.fund_dist_mthd,
                                           x_prev_reported_ind   =>   get_adisb_rec.prev_reported_ind,
                                           x_fund_release_date   =>   get_adisb_rec.fund_release_date,
                                           x_fund_status         =>   get_adisb_rec.fund_status,
                                           x_fund_status_date    =>   get_adisb_rec.fund_status_date,
                                           x_fee_paid_1          =>   get_adisb_rec.fee_paid_1,
                                           x_fee_paid_2          =>   get_adisb_rec.fee_paid_2,
                                           x_cheque_number       =>   get_adisb_rec.cheque_number,
                                           x_ld_cal_type         =>   get_adisb_rec.ld_cal_type,
                                           x_ld_sequence_number  =>   get_adisb_rec.ld_sequence_number,
                                           x_disb_accepted_amt   =>   get_adisb_rec.disb_accepted_amt,
                                           x_disb_paid_amt       =>   get_adisb_rec.disb_paid_amt,
                                           x_rvsn_id             =>   get_adisb_rec.rvsn_id,
                                           x_int_rebate_amt      =>   get_adisb_rec.int_rebate_amt,
                                           x_force_disb          =>   get_adisb_rec.force_disb,
                                           x_min_credit_pts      =>   get_adisb_rec.min_credit_pts,
                                           x_disb_exp_dt         =>   get_adisb_rec.disb_exp_dt,
                                           x_verf_enfr_dt        =>   get_adisb_rec.verf_enfr_dt,
                                           x_fee_class           =>   get_adisb_rec.fee_class,
                                           x_show_on_bill        =>   p_new_val,
                                           x_mode                =>   'R',
                                           x_attendance_type_code  => get_adisb_rec.attendance_type_code,
                                           x_payment_prd_st_date   => get_adisb_rec.payment_prd_st_date,
                                           x_change_type_code      => get_adisb_rec.change_type_code,
                                           x_fund_return_mthd_code => get_adisb_rec.fund_return_mthd_code,
                                           x_direct_to_borr_flag   => get_adisb_rec.direct_to_borr_flag
                                           );

       END LOOP;
   END LOOP;


EXCEPTION

    WHEN app_exception.record_lock_exception THEN
      ROLLBACK to bill_upd_sp;
      fnd_message.set_name('IGF','IGF_GE_LOCK_ERROR');
      fnd_message.set_token('NAME','IGF_AW_GEN_003.UPDATE_BILL_FLAG' );
      app_exception.raise_exception;

    WHEN others THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_GEN_003.UPDATE_BILL_FLAG'|| ' ' || SQLERRM);
      app_exception.raise_exception;


END update_bill_flag;


FUNCTION delete_awd_disb ( p_award_id    IN     igf_aw_award_all.award_id%TYPE ,
                           p_ld_seq_num  IN     igf_aw_awd_disb_all.ld_sequence_number%TYPE ,
                           p_disb_num    IN     igf_aw_awd_disb_all.disb_num%TYPE )
RETURN VARCHAR2
IS

--
--------------------------------------------------------------------------------------------
-- Who       when           what
--------------------------------------------------------------------------------------------
-- Brajendr  14-Jun-2002    Bug 2415009
--                          Added a check for not deleting of award
--                          and disbursement if auth id is generated.
--------------------------------------------------------------------------------------------
-- mesriniv  29-may-2002    Added this line of code
--                          igf_aw_gen.update_fabase_awds(get_awds_rec.base_id,'REVISED');
--------------------------------------------------------------------------------------------
-- sjadhav   Bug 2306310    Function to delete disbursements
--------------------------------------------------------------------------------------------
--
-- check if award has pell or loan record
--
   CURSOR cur_pell_awd (p_award_id igf_aw_award_all.award_id%TYPE)
   IS
   SELECT
   COUNT(origination_id)  awd_count
   FROM
   igf_gr_rfms
   WHERE
   award_id = p_award_id;

   pell_awd_rec   cur_pell_awd%ROWTYPE;

   CURSOR cur_loan_awd (p_award_id igf_aw_award_all.award_id%TYPE)
   IS
   SELECT
   COUNT(loan_id)  awd_count
   FROM
   igf_sl_loans
   WHERE
   award_id = p_award_id;

   loan_awd_rec   cur_loan_awd%ROWTYPE;


--
-- check if award has pell or loan record
--
   CURSOR cur_fws_awd (p_award_id igf_aw_award_all.award_id%TYPE) IS
   SELECT COUNT(auth_id)  awd_count
     FROM igf_se_auth
    WHERE award_id = p_award_id
      AND flag = 'A';

   fws_awd_rec   cur_fws_awd%ROWTYPE;


--
-- Cursor to get disbursements
--

   CURSOR cur_get_adisb  ( p_award_id    igf_aw_award_all.award_id%TYPE,
                           p_ld_seq_num  igf_aw_awd_disb_all.ld_sequence_number%TYPE,
                           p_disb_num    igf_aw_awd_disb_all.disb_num%TYPE)
   IS
   SELECT
   row_id,
   disb_num
   FROM
   igf_aw_awd_disb
   WHERE
   award_id           = p_award_id AND
   disb_num           = NVL(p_disb_num,disb_num) AND
   ld_sequence_number = NVL(p_ld_seq_num,ld_sequence_number);

   get_adisb_rec   cur_get_adisb%ROWTYPE;


--
-- Cursor to get Holds
--

   CURSOR cur_get_holds  ( p_award_id    igf_aw_award_all.award_id%TYPE,
                           p_disb_num    igf_aw_awd_disb_all.disb_num%TYPE)
   IS
   SELECT
   row_id
   FROM
   igf_db_disb_holds
   WHERE
   award_id           = p_award_id AND
   disb_num           = NVL(p_disb_num,disb_num);

   get_holds_rec   cur_get_holds%ROWTYPE;

--
-- Cursor to get Holds
--

   CURSOR cur_get_awds  ( p_award_id    igf_aw_award_all.award_id%TYPE)
   IS
   SELECT
   row_id,base_id
   FROM
   igf_aw_award
   WHERE
   award_id           = p_award_id ;

   get_awds_rec   cur_get_awds%ROWTYPE;

    CURSOR cur_fed_fund_code(
                             p_award_id NUMBER
                            ) IS
    SELECT fcat.fed_fund_code
      FROM igf_aw_fund_cat fcat,
           igf_aw_fund_mast fmast,
           igf_aw_award_all awd
     WHERE fcat.fund_code = fmast.fund_code
       AND fmast.fund_id = awd.fund_id
       AND awd.award_id = p_award_id;

    get_fund_rec cur_fed_fund_code%ROWTYPE;


    CURSOR cur_chg_dtls(
                        cp_award_id igf_aw_award_all.award_id%TYPE,
                        cp_disb_num igf_aw_awd_disb_all.disb_num%TYPE
                       ) IS
      SELECT ROWID row_id,
             disb_status
        FROM igf_aw_db_chg_dtls
       WHERE award_id = cp_award_id
         AND disb_num = cp_disb_num;

   lv_message     fnd_new_messages.message_text%TYPE;
   l_app  VARCHAR2(50);
   l_name VARCHAR2(30);

--
-- check if the award has any adjustments
--

BEGIN

   lv_message := 'NULL';
--
-- Do this check only when it is called from igfaw016
--
   IF p_ld_seq_num IS NULL THEN
           OPEN  cur_pell_awd(p_award_id);
           FETCH cur_pell_awd INTO pell_awd_rec;
           CLOSE cur_pell_awd;

           IF pell_awd_rec.awd_count > 0 THEN
              fnd_message.set_name('IGF','IGF_AW_NO_DEL_PELL');
              lv_message := fnd_message.get;
              RETURN  lv_message;
           END IF;


           OPEN  cur_loan_awd(p_award_id);
           FETCH cur_loan_awd INTO loan_awd_rec;
           CLOSE cur_loan_awd;

           IF loan_awd_rec.awd_count > 0 THEN
              fnd_message.set_name('IGF','IGF_AW_NO_DEL_LOAN');
              lv_message := fnd_message.get;
              RETURN  lv_message;
           END IF;

           -- Check for the FWS fund before detion of the Awards and its Disbursements
           -- If Auth Id is present then the data is already sent to 3rd party system,
           -- so should not allow to delete the Award and its disbursement.
           OPEN  cur_fws_awd(p_award_id);
           FETCH cur_fws_awd INTO fws_awd_rec;
           CLOSE cur_fws_awd;

           IF fws_awd_rec.awd_count > 0 THEN
              fnd_message.set_name('IGF','IGF_SE_AUTH_OR_PAID_PRSNT');
              lv_message := fnd_message.get;
              RETURN  lv_message;
           END IF;

   END IF;

   IF p_ld_seq_num IS NOT NULL THEN
     FOR get_adisb_rec IN cur_get_adisb (p_award_id,p_ld_seq_num,p_disb_num) LOOP
       FOR get_holds_rec IN cur_get_holds (p_award_id,get_adisb_rec.disb_num) LOOP
          igf_db_disb_holds_pkg.delete_row(get_holds_rec.row_id);
       END LOOP;

       OPEN cur_fed_fund_code(p_award_id);
       FETCH cur_fed_fund_code INTO get_fund_rec;
       CLOSE cur_fed_fund_code;

       IF get_fund_rec.fed_fund_code IN ('DLS','DLP','DLU') THEN
         FOR get_chg_dtls IN cur_chg_dtls(p_award_id,get_adisb_rec.disb_num) LOOP
           IF get_chg_dtls.disb_status IN ('G') THEN
             igf_aw_db_chg_dtls_pkg.delete_row(get_chg_dtls.row_id);
           ELSE
            fnd_message.set_name('IGF','IGF_DB_DISB_DBCHG_FK');
            lv_message := fnd_message.get;
            RETURN lv_message;
           END IF;
         END LOOP;
       END IF;
       igf_aw_awd_disb_pkg.delete_row(get_adisb_rec.row_id);

     END LOOP;
   END IF;


   RETURN  lv_message;

EXCEPTION

 WHEN others THEN
      --
      -- Return Adjustment fk message
      --
      ROLLBACK;
      fnd_message.parse_encoded(fnd_message.get_encoded, l_app, l_name);
      IF   l_name = 'IGF_DB_DDTL_AWDD_FK' THEN
           fnd_message.set_name('IGF','IGF_DB_DDTL_AWDD_FK');
           lv_message := fnd_message.get;
           RETURN lv_message;
      ELSIF
           l_name = 'IGS_FI_FIPC_ADISB_FK' THEN
           fnd_message.set_name('IGS','IGS_FI_FIPC_ADISB_FK');
           lv_message := fnd_message.get;
           RETURN lv_message;
      ELSE
          fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP' );
          fnd_message.set_token('NAME','IGF_AW_GEN_003.DELETE_AWD_DISB'||' '||SQLERRM);
          app_exception.raise_exception;
      END IF;


END delete_awd_disb;


FUNCTION get_total_disb ( p_award_id    IN  igf_aw_award_all.award_id%TYPE,
                          p_ld_seq_num  IN  igf_aw_awd_disb_all.ld_sequence_number%TYPE )
RETURN NUMBER
IS
--
-- sjadhav
-- Bug 2306310
-- Function to return number of disbursements
--

     CURSOR cur_disb_nums ( p_award_id    igf_aw_award_all.award_id%TYPE,
                            p_ld_seq_num  igf_aw_awd_disb_all.ld_sequence_number%TYPE)
     IS
     SELECT COUNT(disb_num) tot_num
     FROM
     igf_aw_awd_disb
     WHERE
     award_id           =  p_award_id AND
     ld_sequence_number =  NVL(p_ld_seq_num,ld_sequence_number);

     disb_nums_rec  cur_disb_nums%ROWTYPE;

BEGIN

     OPEN   cur_disb_nums (p_award_id,p_ld_seq_num);
     FETCH  cur_disb_nums INTO disb_nums_rec;
     CLOSE  cur_disb_nums;

     RETURN disb_nums_rec.tot_num;

EXCEPTION

    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_GEN_003.GET_TOTAL_DISB' || ' ' || SQLERRM);
      app_exception.raise_exception;

END get_total_disb;

PROCEDURE awd_group_freeze(p_award_grp IN  VARCHAR2,
                           p_base_id   IN  NUMBER,
                           p_out       OUT NOCOPY VARCHAR2 )
IS
---------------------------------------------------------------------
  --Created by  : gmuralid
  --Date created: 08-04-2003
  --Purpose:

  --Known limitations/enhancements and/or remarks:

  --Change History:

  --Who         When            What
  --bkkumar    6-Aug-2003      Bug# 3085852 Changed the cursors to
  --                           remove the check for existence of awards
  --                           and award status in 'accepted' or 'offered'
--------------------------------------------------------------------

CURSOR c_chk_awd_grp(c_grp igf_aw_target_grp.group_cd%TYPE)
   IS
   SELECT
    'Y'
   FROM
       igf_ap_fa_base_rec fa,
       igf_aw_award awd,
       igf_aw_awd_frml_det fdet
   WHERE
       fa.target_group     = c_grp                        AND
       awd.base_id         = fa.base_id                   AND
       fa.packaging_status IN ('AUTO_PACKAGED','REVISED') AND
       fdet.formula_code   = fa.target_group              AND
       awd.request_id IS NOT NULL                         AND
       ROWNUM = 1;


 CURSOR c_chk_awd_grp_per(c_baseid NUMBER)
    IS
    SELECT
     'Y'
    FROM
        igf_ap_fa_base_rec fa,
        igf_aw_award awd,
        igf_aw_awd_frml_det fdet
    WHERE
        fa.base_id          = c_baseid                     AND
        awd.base_id         = fa.base_id                   AND
        fa.packaging_status IN ('AUTO_PACKAGED','REVISED') AND
        fdet.formula_code   = fa.target_group              AND
        awd.request_id IS NOT NULL                         AND
        ROWNUM = 1;

 l_val VARCHAR2(1);

BEGIN

   p_out := 'N';
   IF (p_base_id IS NULL AND p_award_grp IS NOT NULL) THEN

       OPEN c_chk_awd_grp(p_award_grp);
       FETCH c_chk_awd_grp INTO l_val;
       CLOSE c_chk_awd_grp;
       p_out := NVL(l_val,'N');

   ELSIF (p_base_id IS NOT NULL AND p_award_grp IS NULL) THEN

       OPEN c_chk_awd_grp_per(p_base_id);
       FETCH c_chk_awd_grp_per INTO l_val;
       CLOSE c_chk_awd_grp_per;
       p_out := NVL(l_val,'N');

   END IF;

EXCEPTION

      WHEN OTHERS THEN

        IF (c_chk_awd_grp%ISOPEN)THEN
           CLOSE c_chk_awd_grp;
        END IF;

        IF (c_chk_awd_grp_per%ISOPEN) THEN
           CLOSE c_chk_awd_grp_per;
        END IF;

        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP' );
        fnd_message.set_token('NAME','IGF_AW_GEN_003.AWD_GROUP_FREEZE'||' '|| SQLERRM);
        app_exception.raise_exception;

END awd_group_freeze;

  PROCEDURE get_common_perct(
                             p_adplans_id IN         igf_aw_awd_dist_plans.adplans_id%TYPE,
                             p_base_id    IN         igf_ap_fa_base_rec_all.base_id%TYPE,
                             p_perct      OUT NOCOPY NUMBER,
                             p_awd_prd_code IN         igf_aw_awd_prd_term.award_prd_cd%TYPE
                            ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 11-NOV-2003
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    --Get common COA terms %
    CURSOR cur_get_perct IS
      SELECT SUM((teach_periods.tp_perct_num * terms.ld_perct_num)/100) perct
        FROM igf_aw_dp_terms terms,
             igf_aw_dp_teach_prds teach_periods,
             (SELECT base_id,
                     ld_cal_type,
                     ld_sequence_number
                FROM igf_aw_coa_itm_terms
               WHERE base_id = p_base_id
               GROUP BY base_id,ld_cal_type,ld_sequence_number) coaterms
       WHERE terms.adplans_id = p_adplans_id
         AND terms.adterms_id = teach_periods.adterms_id
         AND coaterms.ld_cal_type = terms.ld_cal_type
         AND coaterms.ld_sequence_number = terms.ld_sequence_number
         AND coaterms.base_id = p_base_id;

    CURSOR cur_get_perct_awd IS
      SELECT SUM((teach_periods.tp_perct_num * terms.ld_perct_num)/100) perct
        FROM igf_aw_dp_terms terms,
             igf_aw_dp_teach_prds teach_periods,
             igf_aw_awd_prd_term aprd,
             igf_ap_fa_base_rec_all fa,
             (SELECT   base_id,
                       ld_cal_type,
                       ld_sequence_number
                  FROM igf_aw_coa_itm_terms
                 WHERE base_id = p_base_id
              GROUP BY base_id, ld_cal_type, ld_sequence_number) coaterms
       WHERE terms.adplans_id = p_adplans_id
         AND terms.adterms_id = teach_periods.adterms_id
         AND coaterms.ld_cal_type = terms.ld_cal_type
         AND coaterms.ld_sequence_number = terms.ld_sequence_number
         AND coaterms.base_id = p_base_id
         AND coaterms.base_id = fa.base_id
         AND fa.ci_cal_type = aprd.ci_cal_type
         AND fa.ci_sequence_number = aprd.ci_sequence_number
         AND coaterms.ld_cal_type = aprd.ld_cal_type
         AND coaterms.ld_sequence_number = aprd.ld_sequence_number
         AND aprd.award_prd_cd = p_awd_prd_code;


  BEGIN

    p_perct := 0;
    IF p_awd_prd_code IS NULL THEN
      OPEN cur_get_perct;
      FETCH cur_get_perct INTO p_perct;
      CLOSE cur_get_perct;
    ELSE
      OPEN cur_get_perct_awd;
      FETCH cur_get_perct_awd INTO p_perct;
      CLOSE cur_get_perct_awd;
    END IF;
  END get_common_perct;

  PROCEDURE check_common_terms(
                               p_adplans_id IN         igf_aw_awd_dist_plans.adplans_id%TYPE,
                               p_base_id    IN         igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_result     OUT NOCOPY NUMBER,
                               p_awd_prd_code IN         igf_aw_awd_prd_term.award_prd_cd%TYPE
                              ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 11-NOV-2003
  --
  --Purpose: Checks if the distribution plan's terms and COA terms of the base_id
  -- have atleast one common term. If p_awd_prd_code is also passed, the procedure checks
  -- if there is atleast one common term between the base_id's COA terms,DP's terms and
  -- terms attached to the award period
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR cur_check_terms IS
    SELECT COUNT(*) common_terms
      FROM igf_aw_dp_terms terms,
           igf_aw_dp_teach_prds teach_periods,
           (SELECT base_id,
                   ld_cal_type,
                   ld_sequence_number
              FROM igf_aw_coa_itm_terms
             WHERE base_id = p_base_id
             GROUP BY base_id,ld_cal_type,ld_sequence_number) coaterms
     WHERE terms.adplans_id = p_adplans_id
       AND terms.adterms_id = teach_periods.adterms_id
       AND coaterms.ld_cal_type = terms.ld_cal_type
       AND coaterms.ld_sequence_number = terms.ld_sequence_number
       AND coaterms.base_id = p_base_id;

  CURSOR cur_check_terms_awd IS
    SELECT COUNT(*) common_terms
      FROM igf_aw_dp_terms terms,
           igf_aw_dp_teach_prds teach_periods,
           (SELECT base_id,
                   ld_cal_type,
                   ld_sequence_number
              FROM igf_aw_coa_itm_terms
             WHERE base_id = p_base_id
             GROUP BY base_id,ld_cal_type,ld_sequence_number) coaterms,
             igf_ap_fa_base_rec_all fa,
             igf_aw_awd_prd_term aprd
     WHERE terms.adplans_id = p_adplans_id
       AND terms.adterms_id = teach_periods.adterms_id
       AND coaterms.ld_cal_type = terms.ld_cal_type
       AND coaterms.ld_sequence_number = terms.ld_sequence_number
       AND coaterms.base_id = p_base_id
       AND coaterms.base_id = fa.base_id
       AND fa.ci_cal_type = aprd.ci_cal_type
       AND fa.ci_sequence_number = aprd.ci_sequence_number
       AND aprd.award_prd_cd = p_awd_prd_code
       AND coaterms.ld_cal_type = aprd.ld_cal_type
       AND coaterms.ld_sequence_number = aprd.ld_sequence_number;

  BEGIN
    p_result := 0;

    IF p_awd_prd_code IS NULL THEN
      OPEN cur_check_terms;
      FETCH cur_check_terms INTO p_result;
      CLOSE cur_check_terms;
    ELSE
      OPEN cur_check_terms_awd;
      FETCH cur_check_terms_awd INTO p_result;
      CLOSE cur_check_terms_awd;
    END IF;

    p_result := NVL(p_result,0);

  END check_common_terms;

PROCEDURE update_award_app_trans(  p_award_id      IN NUMBER,
                                   p_base_id       IN NUMBER)
IS
  ------------------------------------------------------------------
  --Created by  : sjadhav, Oracle India
  --Date created: 4-Dec-2003
  --
  --Purpose: Update Application Transaction Number in AWARD table
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR cur_active_isir(
                       cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                      ) IS
    SELECT transaction_num
      FROM igf_ap_isir_matched_all
     WHERE base_id     = cp_base_id
       AND NVL(active_isir,'N') = 'Y';

  active_isir_rec cur_active_isir%ROWTYPE;

  CURSOR cur_award_app_num(
                       cp_award_id igf_aw_award_all.award_id%TYPE
                      ) IS
    SELECT *
      FROM igf_aw_award
     WHERE award_id    = p_award_id;

BEGIN

  OPEN  cur_active_isir(p_base_id);
  FETCH cur_active_isir INTO active_isir_rec;
  CLOSE cur_active_isir;

  IF active_isir_rec.transaction_num IS NOT NULL THEN
    FOR rec IN cur_award_app_num(p_award_id)
    LOOP
      IF rec.app_trans_num_txt  <> active_isir_rec.transaction_num THEN
          rec.app_trans_num_txt  := active_isir_rec.transaction_num;
          igf_aw_award_pkg.update_row(
                x_mode                 => 'R',
                x_rowid                => rec.row_id,
                x_award_id             => rec.award_id,
                x_fund_id              => rec.fund_id,
                x_base_id              => rec.base_id,
                x_offered_amt          => rec.offered_amt,
                x_accepted_amt         => rec.accepted_amt,
                x_paid_amt             => rec.paid_amt,
                x_packaging_type       => rec.packaging_type,
                x_batch_id             => rec.batch_id,
                x_manual_update        => rec.manual_update,
                x_rules_override       => 'N',
                x_award_date           => rec.award_date,
                x_award_status         => rec.award_status,
                x_attribute_category   => rec.attribute_category,
                x_attribute1           => rec.attribute1,
                x_attribute2           => rec.attribute2,
                x_attribute3           => rec.attribute3,
                x_attribute4           => rec.attribute4,
                x_attribute5           => rec.attribute5,
                x_attribute6           => rec.attribute6,
                x_attribute7           => rec.attribute7,
                x_attribute8           => rec.attribute8,
                x_attribute9           => rec.attribute9,
                x_attribute10          => rec.attribute10,
                x_attribute11          => rec.attribute11,
                x_attribute12          => rec.attribute12,
                x_attribute13          => rec.attribute13,
                x_attribute14          => rec.attribute14,
                x_attribute15          => rec.attribute15,
                x_attribute16          => rec.attribute16,
                x_attribute17          => rec.attribute17,
                x_attribute18          => rec.attribute18,
                x_attribute19          => rec.attribute19,
                x_attribute20          => rec.attribute20,
                x_rvsn_id              => rec.rvsn_id,
                x_award_number_txt     => rec.award_number_txt,
                x_legacy_record_flag   => NULL,
                x_adplans_id           => rec.adplans_id,
                x_lock_award_flag      => rec.lock_award_flag,
                x_app_trans_num_txt    => rec.app_trans_num_txt,
                x_awd_proc_status_code => rec.awd_proc_status_code,
                x_notification_status_code	=> rec.notification_status_code,
                x_notification_status_date	=> rec.notification_status_date,
                x_publish_in_ss_flag        => rec.publish_in_ss_flag
                );
      END IF;
    END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_AW_GEN_003.UPDATE_AWARD_APP_TRANS '||SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END update_award_app_trans;

FUNCTION check_coa(
                   p_base_id       IN NUMBER,
                   p_awd_prd_code  IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL
                  ) RETURN BOOLEAN IS
------------------------------------------------------------------
-- Created by  : sjadhav, Oracle India
-- Date created: 4-Dec-2003
--
-- Purpose: Checks if Person has COA
--
--
-- Known limitations/enhancements and/or remarks:
--
-- Change History:
-- Who         When            What
-------------------------------------------------------------------

BEGIN
  IF igf_aw_coa_gen.coa_amount(p_base_id,p_awd_prd_code) IS NULL THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_AW_GEN_003.CHECK_COA '||SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END check_coa;
END igf_aw_gen_003;

/
