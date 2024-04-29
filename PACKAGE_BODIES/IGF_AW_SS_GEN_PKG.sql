--------------------------------------------------------
--  DDL for Package Body IGF_AW_SS_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_SS_GEN_PKG" AS
/* $Header: IGFAW23B.pls 120.13 2006/08/10 17:10:31 museshad noship $ */

  /*************************************************************
  Created By : ugummall
  Date Created On : 2004/10/04
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  museshad        10-Aug-2006     Bug 5337555. Build FA 163. TBH Impact.
  (reverse chronological order - newest change first)
  ***************************************************************/

PROCEDURE apply_certf_resp(p_base_id            NUMBER,
                           p_ci_cal_type        VARCHAR2,
                           p_ci_sequence_number NUMBER,
                           p_award_prd_cd       VARCHAR2,
                           p_cert_code          VARCHAR2,
                           p_response           VARCHAR2)


IS
------------------------------------------------------------------
--Created by  : rasahoo, Oracle India
--Date created:
--
--Purpose:
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------
CURSOR cur_cert_resp_details(cp_base_id            number,
                             cp_ci_cal_type        varchar2,
                             cp_ci_sequence_number number,
                             cp_award_prd_cd       varchar2,
                             cp_cert_code          varchar2)
IS
SELECT rowid row_id, resp.*
from igf_aw_awd_cert_resps resp
where BASE_ID = cp_base_id
and CI_CAL_TYPE = cp_ci_cal_type
and CI_SEQUENCE_NUMBER = cp_ci_sequence_number
and AWARD_PRD_CD = cp_award_prd_cd
and AWD_CERT_CODE = cp_cert_code;

cert_resps_detail cur_cert_resp_details%ROWTYPE;
l_rowid VARCHAR2(25);
Begin

OPEN cur_cert_resp_details(p_base_id,p_ci_cal_type,p_ci_sequence_number,p_award_prd_cd,p_cert_code);
FETCH cur_cert_resp_details INTO cert_resps_detail;

IF cur_cert_resp_details%FOUND THEN
   CLOSE cur_cert_resp_details;
   igf_aw_awd_cert_resps_pkg.update_row( x_rowid                   => cert_resps_detail.row_id,
                                         x_ci_cal_type             => cert_resps_detail.ci_cal_type,
                                         x_ci_sequence_number      => cert_resps_detail.ci_sequence_number,
                                         x_award_prd_cd            => cert_resps_detail.award_prd_cd,
                                         x_base_id                 => cert_resps_detail.base_id,
                                         x_awd_cert_code           => cert_resps_detail.awd_cert_code,
                                         x_response_txt            => p_response,
                                         x_object_version_number   => cert_resps_detail.object_version_number,
                                         x_mode                    => 'R');
ELSE
   CLOSE cur_cert_resp_details;

   igf_aw_awd_cert_resps_pkg.insert_row( x_rowid                   => l_rowid,
                                         x_ci_cal_type             => p_ci_cal_type,
                                         x_ci_sequence_number      => p_ci_sequence_number,
                                         x_award_prd_cd            => p_award_prd_cd,
                                         x_base_id                 => p_base_id,
                                         x_awd_cert_code           => p_cert_code,
                                         x_response_txt            => p_response,
                                         x_object_version_number   => 1,
                                         x_mode                    => 'R');

END IF;

END apply_certf_resp;

PROCEDURE update_awards_from_ss ( p_award_id      igf_aw_award_all.award_id%TYPE,
                                  p_offered_amt   NUMBER,
                                  p_accepted_amt  NUMBER,
                                  p_award_status  VARCHAR2
                                ) AS
------------------------------------------------------------------
--Created by  : rasahoo, Oracle India
--Date created:
--
--Purpose:
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

  CURSOR  c_disb  ( cp_award_id igf_aw_award_all.award_id%TYPE) IS
    SELECT  disb.rowid row_id,
            disb.*
      FROM  IGF_AW_AWD_DISB_ALL disb
     WHERE  award_id = cp_award_id
      AND   trans_type IN ('A', 'P');

    CURSOR  cur_fund_details  (cp_award_id  NUMBER) IS
    SELECT  mast.*
      FROM  igf_aw_award awd,
            igf_aw_fund_mast mast
     WHERE  awd.award_id = cp_award_id
      AND   awd.fund_id = mast.fund_id;

     rec_fund_mast cur_fund_details%ROWTYPE;

  l_dis_amt      NUMBER;
  l_net_amt      NUMBER;
  l_trans_type   VARCHAR2(1);
  l_award_status VARCHAR2(30);
  l_lock_status  VARCHAR2(1);

BEGIN
OPEN cur_fund_details(p_award_id);
FETCH cur_fund_details INTO rec_fund_mast;
CLOSE cur_fund_details;

  IF p_award_status = 'D' THEN
     IF rec_fund_mast.status_after_decline ='LOCKED' THEN
        l_lock_status  := 'Y';
     ELSE
        l_lock_status  := 'N';
     END IF;
    l_award_status := 'DECLINED';

  ELSIF p_award_status = 'A' THEN
    l_award_status := 'ACCEPTED';
    l_lock_status  := 'N';
  ELSE
    l_lock_status  := 'N';
  END IF;

  update_award_status(p_award_id, l_award_status, l_lock_status);
  FOR disb_rec IN c_disb(p_award_id) LOOP
    --Initialize the disbursement amout
    l_dis_amt := 0;
    IF p_award_status = 'D' THEN -- If the award is declined then the disb amt will be 0
      l_dis_amt := 0;
      l_net_amt := disb_rec.disb_net_amt;
      l_trans_type := 'C';
    ELSIF p_award_status = 'A' THEN -- if the award is accepeted then the award is prorated against all the disbursements.

      IF p_accepted_amt = p_offered_amt THEN
        /*
          Reduce calculations if full amount is accepted
        */
        l_dis_amt := disb_rec.disb_gross_amt;
        l_net_amt := disb_rec.disb_net_amt;
      ELSE
      l_dis_amt := (p_accepted_amt/p_offered_amt) * disb_rec.disb_gross_amt;
      l_net_amt := disb_rec.disb_net_amt;
        IF l_dis_amt <> TRUNC(l_dis_amt) AND rec_fund_mast.disb_rounding_code IN ('ONE_FIRST','ONE_LAST') THEN
          l_dis_amt := TRUNC(l_dis_amt);
        END IF;
        IF l_dis_amt <> TRUNC(l_dis_amt,2) AND rec_fund_mast.disb_rounding_code IN ('DEC_FIRST','DEC_LAST') THEN
          l_dis_amt := TRUNC(l_dis_amt,2);
        END IF;
      END IF;
      IF l_trans_type = 'A' THEN
        l_trans_type := 'A';
      ELSE
        l_trans_type := 'P';
      END IF;
    END IF;

    igf_aw_awd_disb_pkg.update_row(
      x_rowid                     => disb_rec.row_id,
      x_award_id                  => disb_rec.award_id,
      x_disb_num                  => disb_rec.disb_num,
      x_tp_cal_type               => disb_rec.tp_cal_type,
      x_tp_sequence_number        => disb_rec.tp_sequence_number,
      x_disb_gross_amt            => disb_rec.disb_gross_amt,
      x_fee_1                     => disb_rec.fee_1,
      x_fee_2                     => disb_rec.fee_2,
      x_disb_net_amt              => l_net_amt,
      x_disb_date                 => disb_rec.disb_date,
      x_trans_type                => l_trans_type,
      x_elig_status               => disb_rec.elig_status,
      x_elig_status_date          => disb_rec.elig_status_date,
      x_affirm_flag               => disb_rec.affirm_flag,
      x_hold_rel_ind              => disb_rec.hold_rel_ind,
      x_manual_hold_ind           => disb_rec.manual_hold_ind,
      x_disb_status               => disb_rec.disb_status,
      x_disb_status_date          => disb_rec.disb_status_date,
      x_late_disb_ind             => disb_rec.late_disb_ind,
      x_fund_dist_mthd            => disb_rec.fund_dist_mthd,
      x_prev_reported_ind         => disb_rec.prev_reported_ind,
      x_fund_release_date         => disb_rec.fund_release_date,
      x_fund_status               => disb_rec.fund_status,
      x_fund_status_date          => disb_rec.fund_status_date,
      x_fee_paid_1                => disb_rec.fee_paid_1,
      x_fee_paid_2                => disb_rec.fee_paid_2,
      x_cheque_number             => disb_rec.cheque_number,
      x_ld_cal_type               => disb_rec.ld_cal_type,
      x_ld_sequence_number        => disb_rec.ld_sequence_number,
      x_disb_accepted_amt         => l_dis_amt,
      x_disb_paid_amt             => disb_rec.disb_paid_amt,
      x_rvsn_id                   => disb_rec.rvsn_id,
      x_int_rebate_amt            => disb_rec.int_rebate_amt,
      x_force_disb                => disb_rec.force_disb,
      x_min_credit_pts            => disb_rec.min_credit_pts,
      x_disb_exp_dt               => disb_rec.disb_exp_dt,
      x_verf_enfr_dt              => disb_rec.verf_enfr_dt,
      x_fee_class                 => disb_rec.fee_class,
      x_show_on_bill              => disb_rec.show_on_bill,
      x_mode                      => 'R',
      x_attendance_type_code      => disb_rec.attendance_type_code,
      x_base_attendance_type_code => disb_rec.base_attendance_type_code,
      x_payment_prd_st_date       => disb_rec.payment_prd_st_date,
      x_change_type_code          => disb_rec.change_type_code,
      x_fund_return_mthd_code     => disb_rec.fund_return_mthd_code,
      x_direct_to_borr_flag       => disb_rec.direct_to_borr_flag
    );
  END LOOP;

END update_awards_from_ss;

FUNCTION  get_action_for_off_awds ( p_ci_cal_type         VARCHAR2,
                                    p_ci_sequence_number  NUMBER,
                                    p_award_prd_cd        VARCHAR2,
                                    p_base_id             NUMBER)
RETURN VARCHAR2 AS

  lv_awd_by_term_prof_val VARCHAR2(10); -- Place holder for the profile value "IGF: Award Acceptance By Term via Student Self-Service" : Scope - local
  lv_ret_status VARCHAR2(30) := ''; -- The computed return status, returned by the function : Scope - local

  -- Cursor to get the all the terms in an award period
  CURSOR  cur_all_terms_awd_prd ( cp_ci_cal_type varchar2,
                                  cp_ci_sequence_number number,
                                  cp_award_prd_cd varchar2) IS
  SELECT  apt.ld_cal_type ld_cal_type,
          apt.ld_sequence_number ld_sequence_number
    FROM  IGF_AW_AWD_PRD_TERM apt,
          IGS_CA_INST cal
   WHERE  apt.ci_sequence_number = cp_ci_sequence_number
    AND   apt.ci_cal_type = cp_ci_cal_type
    AND   award_prd_cd = cp_award_prd_cd
    AND   apt.ld_cal_type = cal.cal_type
    AND   apt.ld_sequence_number = cal.sequence_number
  ORDER BY  cal.start_dt ASC;

  lc_all_terms_awd_prd  cur_all_terms_awd_prd%ROWTYPE; -- place holder for the fetched value for cursor cur_all_terms_awd_prd
  lc_program_cd         igs_ps_ver_all.course_cd%TYPE;
  lc_version_num        igs_ps_ver_all.version_number%TYPE;
  lc_program_type       igs_ps_ver_all.course_type%TYPE;
  lc_org_unit           igs_ps_ver_all.responsible_org_unit_cd%TYPE;

  p_last_accept_date    DATE;

BEGIN
  -- Get the value of profile "IGF: Award Acceptance By Term via Student Self-Service"
  lv_awd_by_term_prof_val := fnd_profile.value('IGF_AW_AWD_ACCPT_BY_TERM');

  IF lv_awd_by_term_prof_val = 'N' THEN
    -- do term related things here
    -- Get the first term associated with the context awarding period and award year.
    OPEN cur_all_terms_awd_prd (p_ci_cal_type, p_ci_sequence_number, p_award_prd_cd);
    FETCH cur_all_terms_awd_prd INTO lc_all_terms_awd_prd;
    CLOSE cur_all_terms_awd_prd;

    -- Get context data for the first term.
    igf_ap_gen_001.get_context_data_for_term(
                p_base_id, --IN
                lc_all_terms_awd_prd.ld_cal_type, --IN
                lc_all_terms_awd_prd.ld_sequence_number, --IN
                lc_program_cd,  --OUT
                lc_version_num, --OUT
                lc_program_type, --OUT
                lc_org_unit --OUT
               );

    --Get the Last Accept Date by using the API igs_ca_compute_da_val_pkg.cal_da_elt_val
    p_last_accept_date := igs_ca_compute_da_val_pkg.cal_da_elt_val(
                                                                'LAST_ACCEPT_DATE',                     --IN
                                                                lc_all_terms_awd_prd.ld_cal_type,       --IN
                                                                lc_all_terms_awd_prd.ld_sequence_number,--IN
                                                                lc_org_unit,                            --IN
                                                                lc_program_type,                        --IN
                                                                lc_program_cd || '/' || lc_version_num  --IN
                                                               );
    IF SYSDATE <= p_last_accept_date THEN
      lv_ret_status := 'AF';
    ELSE
      lv_ret_status := 'VO';
    END IF;
  ELSE
    -- do non term related things here
    FOR l_cur_all_terms_awd_prd IN cur_all_terms_awd_prd (p_ci_cal_type, p_ci_sequence_number, p_award_prd_cd)
    LOOP
      -- Get context data for the first term.
      igf_ap_gen_001.get_context_data_for_term(
                p_base_id, --IN
                l_cur_all_terms_awd_prd.ld_cal_type, --IN
                l_cur_all_terms_awd_prd.ld_sequence_number, --IN
                lc_program_cd,  --OUT
                lc_version_num, --OUT
                lc_program_type, --OUT
                lc_org_unit --OUT
               );

      --Get the Last Accept Date by using the API igs_ca_compute_da_val_pkg.cal_da_elt_val
      p_last_accept_date := igs_ca_compute_da_val_pkg.cal_da_elt_val(
                                                                'LAST_ACCEPT_DATE',                         --IN
                                                                l_cur_all_terms_awd_prd.ld_cal_type,        --IN
                                                                l_cur_all_terms_awd_prd.ld_sequence_number, --IN
                                                                lc_org_unit,                                --IN
                                                                lc_program_type,                            --IN
                                                                lc_program_cd || '/' || lc_version_num      --IN
                                                              );


      IF SYSDATE <= p_last_accept_date THEN
        lv_ret_status := 'AF';
      END IF;
    END LOOP;

    IF (NVL(lv_ret_status,'N') <> 'AF') THEN
      lv_ret_status := 'VO';
    END IF;
  END IF; -- end of non term

  RETURN lv_ret_status;
END get_action_for_off_awds;

FUNCTION  get_action_for_non_off_awds ( p_ci_cal_type         VARCHAR2,
                                        p_ci_sequence_number  NUMBER,
                                        p_award_prd_cd        VARCHAR2,
                                        p_base_id             NUMBER)
RETURN VARCHAR2 AS

  lv_awd_by_term_prof_val varchar2(10); -- Place holder for the profile value "IGF: Award Acceptance By Term via Student Self-Service" : Scope - local
  lv_ret_status varchar2(30) := ''; -- The computed return status, returned by the function : Scope - local

  -- Cursor to get the all the terms in an award period
  CURSOR  cur_all_terms_awd_prd ( cp_ci_cal_type VARCHAR2, cp_ci_sequence_number NUMBER, cp_award_prd_cd VARCHAR2) IS
    SELECT  apt.ld_cal_type ld_cal_type,
            apt.ld_sequence_number ld_sequence_number
      FROM  IGF_AW_AWD_PRD_TERM apt,
            IGS_CA_INST cal
     WHERE  apt.ci_sequence_number = cp_ci_sequence_number
      AND   apt.ci_cal_type = cp_ci_cal_type
      AND   award_prd_cd = cp_award_prd_cd
      AND   apt.ld_cal_type = cal.cal_type
      AND   apt.ld_sequence_number = cal.sequence_number
    ORDER BY  cal.start_dt ASC;

  lc_all_terms_awd_prd cur_all_terms_awd_prd%ROWTYPE; -- place holder for the fetched value for cursor cur_all_terms_awd_prd
  lc_program_cd    igs_ps_ver_all.course_cd%TYPE;
  lc_version_num   igs_ps_ver_all.version_number%TYPE;
  lc_program_type  igs_ps_ver_all.course_type%TYPE;
  lc_org_unit      igs_ps_ver_all.responsible_org_unit_cd%TYPE;

  p_last_accept_date DATE;

BEGIN
  -- Get the value of profile "IGF: Award Acceptance By Term via Student Self-Service"
  lv_awd_by_term_prof_val := fnd_profile.value('IGF_AW_AWD_ACCPT_BY_TERM');

  IF lv_awd_by_term_prof_val = 'N' THEN
    -- do term related things here
    -- Get the first term asciciated with the context awarding period and award year.
    OPEN cur_all_terms_awd_prd (p_ci_cal_type, p_ci_sequence_number, p_award_prd_cd);
    FETCH cur_all_terms_awd_prd INTO lc_all_terms_awd_prd;
    CLOSE cur_all_terms_awd_prd;

    -- Get context data for the first term.
    igf_ap_gen_001.get_context_data_for_term(
                p_base_id, --IN
                lc_all_terms_awd_prd.ld_cal_type, --IN
                lc_all_terms_awd_prd.ld_sequence_number, --IN
                lc_program_cd,  --OUT
                lc_version_num, --OUT
                lc_program_type, --OUT
                lc_org_unit --OUT
    );

    --Get the Last Accept Date by using the API igs_ca_compute_da_val_pkg.cal_da_elt_val
    p_last_accept_date := igs_ca_compute_da_val_pkg.cal_da_elt_val(
                                                                'LAST_ACCEPT_DATE',                     --IN
                                                                lc_all_terms_awd_prd.ld_cal_type,       --IN
                                                                lc_all_terms_awd_prd.ld_sequence_number,--IN
                                                                lc_org_unit,                            --IN
                                                                lc_program_type,                        --IN
                                                                lc_program_cd || '/' || lc_version_num  --IN
                                                               );
    IF SYSDATE <= p_last_accept_date THEN
      lv_ret_status := 'VM';
    ELSE
      lv_ret_status := 'VO';
    END IF;

  ELSE

    -- do non term related things here
    FOR l_cur_all_terms_awd_prd IN cur_all_terms_awd_prd(p_ci_cal_type, p_ci_sequence_number, p_award_prd_cd)
    LOOP
      -- Get context data for the first term.
      igf_ap_gen_001.get_context_data_for_term(
                p_base_id, --IN
                l_cur_all_terms_awd_prd.ld_cal_type, --IN
                l_cur_all_terms_awd_prd.ld_sequence_number, --IN
                lc_program_cd,  --OUT
                lc_version_num, --OUT
                lc_program_type, --OUT
                lc_org_unit --OUT
      );

      --Get the Last Accept Date by using the API igs_ca_compute_da_val_pkg.cal_da_elt_val
      p_last_accept_date := igs_ca_compute_da_val_pkg.cal_da_elt_val(
                                                                'LAST_ACCEPT_DATE',                         --IN
                                                                l_cur_all_terms_awd_prd.ld_cal_type,        --IN
                                                                l_cur_all_terms_awd_prd.ld_sequence_number, --IN
                                                                lc_org_unit,                                --IN
                                                                lc_program_type,                            --IN
                                                                lc_program_cd || '/' || lc_version_num      --IN
                                                             );
      IF SYSDATE <= p_last_accept_date THEN
        lv_ret_status := 'VM';
      END IF;
    END LOOP;

    IF (NVL(lv_ret_status, 'N') <> 'VM') THEN
      lv_ret_status := 'VO';
    END IF;

  END IF; -- end of non term
  RETURN lv_ret_status;
END get_action_for_non_off_awds;

FUNCTION  get_awd_action  ( p_ci_cal_type         VARCHAR2,
                            p_ci_sequence_number  NUMBER,
                            p_award_prd_cd        VARCHAR2,
                            p_base_id             NUMBER)
RETURN VARCHAR2 AS

  -- Cursor to return award status for all awards in an award period
  CURSOR  c_ap_award  (cp_ci_cal_type VARCHAR2, cp_ci_sequence_number NUMBER, cp_award_prd_cd VARCHAR2, cp_base_id NUMBER) IS
    SELECT  awd.*
      FROM  IGF_AW_AWARD_ALL awd,
            IGF_AW_AWD_DISB_ALL disb,
            IGF_AW_AWD_PRD_TERM ap
     WHERE  awd.base_id = cp_base_id
      AND   awd.publish_in_ss_flag = 'Y'
      AND   awd.award_id = disb.award_id
      AND   disb.ld_cal_type = ap.ld_cal_type
      AND   disb.ld_sequence_number = ap.ld_sequence_number
      AND   ap.ci_cal_type = cp_ci_cal_type
      AND   ap.ci_sequence_number = cp_ci_sequence_number
      AND   ap.award_prd_cd = cp_award_prd_cd;


  -- Cursor to return award status for all awards in an award period
  CURSOR  c_ap_award_terms  (cp_ci_cal_type VARCHAR2, cp_ci_sequence_number NUMBER, cp_award_prd_cd VARCHAR2, cp_base_id NUMBER) IS
    SELECT  *
      FROM  IGF_AW_SS_DISB_V
     WHERE  base_id = cp_base_id
      AND   ci_cal_type = cp_ci_cal_type
      AND   ci_sequence_number = cp_ci_sequence_number
      AND   award_prd_cd = cp_award_prd_cd;

  cursor c_person_id(cp_base_id Number) IS
  Select Person_Id
  from igf_ap_fa_con_v
  where base_id = cp_base_id;

  l_person_id number(15);

  CURSOR c_person_awd_status (cp_base_id NUMBER) IS
    SELECT fa.lock_awd_flag
      FROM igf_ap_fa_base_rec fa
     WHERE fa.base_id = cp_base_id;

  l_person_awd_status igf_ap_fa_base_rec.lock_awd_flag%TYPE;

  lb_has_offered          BOOLEAN;  -- Place holder for Offered award status : Scope - local
  lb_has_accepted         BOOLEAN; -- Place holder for Accepted award status : Scope - local
  lb_has_declined         BOOLEAN; -- Place holder for Declined award status : Scope - local
  lb_has_cancelled        BOOLEAN;
  lv_ret_status           VARCHAR2(30) := ''; -- The computed return status, returned by the function : Scope - local
  lv_view_only_prof_val   VARCHAR2(10); -- Place holder for the profile value "IGF: View-only Awards via Student Self-Service" : Scope - local
  l_ret_stat_for_acc_amt  VARCHAR2(30);
  l_ret_stat_for_acc      VARCHAR2(30);
  l_ret_stat_for_dec      VARCHAR2(30);
  l_drive_status          VARCHAR2(1);
  l_hold                  VARCHAR2(10);
  lv_accept_by_term       VARCHAR2(10);

BEGIN

  -- Get the award status for all awards in an award period for the student (for above base id).
  -- Set the flag lb_has_accepted if there is any award with the status ACCEPTED
  -- Set the flag lb_has_offered if there is any award with the status OFFERED
  -- Set the flag lb_has_declined if there is any award with the status DECLINED

  lb_has_offered := FALSE;
  lb_has_accepted := FALSE;
  lb_has_declined := FALSE;
  lb_has_cancelled := FALSE;

  FOR l_ap_award IN c_ap_award(p_ci_cal_type, p_ci_sequence_number, p_award_prd_cd, p_base_id)
  LOOP
    IF l_ap_award.award_status = 'ACCEPTED' THEN
      lb_has_accepted := true;
    ELSIF l_ap_award.award_status = 'OFFERED' THEN
      lb_has_offered := true;
    ELSIF l_ap_award.award_status = 'DECLINED' THEN
      lb_has_declined := true;
    ELSIF l_ap_award.award_status =  'CANCELLED' THEN
      lb_has_cancelled := true;
    END IF;
  END LOOP;

  -- Get the value of profile "IGF: View-only Awards via Student Self-Service"
  lv_view_only_prof_val := fnd_profile.value('IGF_AW_AWARD_VIEW_ONLY_IN_SS');

  IF (lv_view_only_prof_val = 'Y') THEN -- If the profile value is Yes
    lv_ret_status := 'VO'; -- All the awards will be shown in View Only mode in the Student Self-Service page.
    RETURN lv_ret_status;
  ELSIF (lb_has_offered) THEN -- If the profile value is No and there are any awards with an offered status
    lv_ret_status := get_action_for_off_awds(p_ci_cal_type, p_ci_sequence_number, p_award_prd_cd, p_base_id);
  ELSE -- There are NO awards with an offered status
    lv_ret_status := get_action_for_non_off_awds(p_ci_cal_type, p_ci_sequence_number, p_award_prd_cd, p_base_id);
  END IF;

  /*
  Hold Logic goes here
  If student has a hold on awarding, then all of the student's awards should be view only.
  */
  OPEN c_person_id(p_base_id);
  FETCH c_person_id into l_person_id;
  CLOSE c_person_id;

  l_hold := igf_aw_gen_005.get_stud_hold_effect('A', l_person_id, NULL );

  IF NVL(l_hold,'X') = 'F' THEN
    lv_ret_status := 'VO';
    RETURN lv_ret_status;
  END IF;

  /*
  If the Lock Award checkbox is checked at the Person Context Level,
  then all of the awards are view-only on the Student Awards self-service page for the student in context.
  */
  OPEN c_person_awd_status(p_base_id);
  FETCH c_person_awd_status INTO l_person_awd_status;
  CLOSE c_person_awd_status;

  IF l_person_awd_status = 'Y' THEN
    lv_ret_status := 'VO';
    RETURN lv_ret_status;
  END IF;

  -- new validations for awards page synch up
  l_drive_status := 'V';
  l_ret_stat_for_acc_amt := '';
  l_ret_stat_for_acc := '';
  l_ret_stat_for_dec := '';


  lv_accept_by_term :=  fnd_profile.value('IGF_AW_AWD_ACCPT_BY_TERM');
  IF lv_accept_by_term = 'Y' THEN
   -- By term logic
    FOR l_ap_award_terms IN c_ap_award_terms(p_ci_cal_type, p_ci_sequence_number, p_award_prd_cd, p_base_id)
    LOOP
      l_ret_stat_for_acc_amt := get_acc_amt_display_mode_term(l_ap_award_terms.award_id,
                                                              l_ap_award_terms.accepted_amt,
                                                              l_ap_award_terms.offered_amt,
                                                              l_ap_award_terms.ld_cal_type,
                                                              l_ap_award_terms.ld_sequence_number);

      IF l_ret_stat_for_acc_amt = 'MODIFY' THEN
        IF l_ap_award_terms.award_status = 'OFFERED' THEN
          l_drive_status := 'A';
        ELSE
          l_drive_status := 'M';
        END IF;
      END IF;

      l_ret_stat_for_acc := get_acc_display_mode_term(l_ap_award_terms.award_id,
                                                      l_ap_award_terms.accepted_amt,
                                                      l_ap_award_terms.offered_amt,
                                                      l_ap_award_terms.ld_cal_type,
                                                      l_ap_award_terms.ld_sequence_number);
      IF l_ret_stat_for_acc = 'MD' THEN
        IF l_ap_award_terms.award_status = 'OFFERED' THEN
          l_drive_status := 'A';
        ELSE
          l_drive_status := 'M';
        END IF;
      END IF;

      l_ret_stat_for_dec := get_dec_display_mode_term(l_ap_award_terms.award_id,
                                                      l_ap_award_terms.accepted_amt,
                                                      l_ap_award_terms.offered_amt,
                                                      l_ap_award_terms.ld_cal_type,
                                                      l_ap_award_terms.ld_sequence_number);
      IF l_ret_stat_for_dec = 'M' THEN
        IF l_ap_award_terms.award_status = 'OFFERED' THEN
          l_drive_status := 'A';
        ELSE
          l_drive_status := 'M';
        END IF;
      END IF;

      IF l_drive_status = 'A' THEN
        EXIT;
      END IF;

    END LOOP;

    IF l_drive_status ='A' THEN
      lv_ret_status := 'AF';
    ELSIF l_drive_status ='M' THEN
      lv_ret_status := 'VM';
    ELSE
      lv_ret_status := 'VO';
    END IF;

  ELSE
   -- By Awd Prd logic
    FOR l_ap_award IN c_ap_award(p_ci_cal_type, p_ci_sequence_number, p_award_prd_cd, p_base_id)
    LOOP
      l_ret_stat_for_acc_amt := get_accept_amt_display_mode(l_ap_award.award_id, l_ap_award.accepted_amt, l_ap_award.offered_amt);
      IF l_ret_stat_for_acc_amt = 'MODIFY' THEN
        l_drive_status := 'M';
      END IF;

      l_ret_stat_for_acc := get_accept_display_mode(l_ap_award.award_id, l_ap_award.accepted_amt, l_ap_award.offered_amt);
      IF l_ret_stat_for_acc = 'MD' THEN
        l_drive_status := 'M';
      END IF;

      l_ret_stat_for_dec := get_decline_display_mode(l_ap_award.award_id, l_ap_award.accepted_amt, l_ap_award.offered_amt);
      IF l_ret_stat_for_dec = 'M' THEN
        l_drive_status := 'M';
      END IF;
    END LOOP;

    IF l_drive_status <> 'M' THEN
      lv_ret_status := 'VO';
    END IF;

  END IF;

  RETURN lv_ret_status;

END get_awd_action;

FUNCTION  get_accept_amt_display_mode ( p_award_id      NUMBER,
                                        p_accepted_amt  NUMBER,
                                        p_offered_amt   NUMBER)
RETURN VARCHAR2 AS

  CURSOR  cur_fund_details  ( cp_award_id NUMBER) IS
    SELECT  awd.lock_award_flag lock_awd_flag, mast.*
      FROM  IGF_AW_AWARD awd,
            IGF_AW_FUND_MAST mast
     WHERE  awd.award_id = cp_award_id
      AND   awd.fund_id = mast.fund_id;
  fund_mast_rec cur_fund_details%ROWTYPE;

  CURSOR  cur_min_disb_date ( cp_award_id NUMBER) IS
    SELECT  MIN(disb_date)
      FROM  IGF_AW_AWD_DISB
     WHERE  award_id = cp_award_id;

  sch_disb_date DATE;

  CURSOR  cur_fund_type (cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE) IS
    SELECT cat.fed_fund_code
      FROM igf_aw_fund_mast_all fund,
           igf_aw_fund_cat_all cat
     WHERE fund.fund_code = cat.fund_code
       AND fund.fund_id = cp_fund_id;

  l_fund_type igf_aw_fund_cat_v.fed_fund_code%TYPE;

  CURSOR  cur_orig_status_pell (cp_award_id  NUMBER) IS
    SELECT  orig_action_code
      FROM  igf_gr_rfms
     WHERE  award_id = cp_award_id;

  l_orig_status_pell igf_gr_rfms.orig_action_code%TYPE;

  CURSOR  cur_orig_status (cp_award_id  NUMBER) IS
    SELECT  loan_status, loan_chg_status
      FROM  igf_sl_loans_all
     WHERE  award_id = cp_award_id;

  l_orig_status cur_orig_status%ROWTYPE;

  CURSOR  cur_award_status  (cp_award_id  NUMBER) IS
    SELECT  award_status
      FROM  IGF_AW_AWARD
     WHERE  award_id = cp_award_id;

  l_award_status  igf_aw_award.AWARD_STATUS%TYPE;


BEGIN

  OPEN cur_fund_details(p_award_id);
  FETCH cur_fund_details INTO fund_mast_rec;
  CLOSE cur_fund_details;

  -- If the award is locked at the award context level, display it as read-only
  IF fund_mast_rec.lock_awd_flag = 'Y' THEN
    RETURN 'VIEW';
  END IF;

  -- Check If the view only check box is checked for the fund in fund manager form.
  --If the View only check box is checked then return V.
  IF NVL(fund_mast_rec.VIEW_ONLY_FLAG,'N') = 'Y' THEN
    RETURN 'VIEW';
  END IF;
  -- Check the fund type.
  -- If the fund type is pell then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  -- If the fund type is Direct or FFELP then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  OPEN cur_fund_type(fund_mast_rec.fund_id);
  FETCH cur_fund_type INTO l_fund_type;
  CLOSE cur_fund_type;
  IF l_fund_type = 'PELL' THEN
    OPEN cur_orig_status_pell(p_award_id);
    FETCH cur_orig_status_pell INTO l_orig_status_pell;
    CLOSE cur_orig_status_pell;
    IF l_orig_status_pell = 'S' THEN
      RETURN 'VIEW';
    END IF;
  ELSIF l_fund_type IN ('DLU', 'DLP', 'DLS', 'FLP', 'FLU', 'FLS', 'ALT') THEN
    OPEN cur_orig_status(p_award_id);
    FETCH cur_orig_status INTO l_orig_status;
    CLOSE cur_orig_status;
    IF l_orig_status.loan_status = 'S'  OR l_orig_status.loan_chg_status = 'S' THEN
      RETURN 'VIEW';
    END IF;

    IF l_fund_type IN ('FLP', 'FLU', 'FLS', 'ALT') THEN
      IF l_orig_status.loan_status = 'A' AND NVL(l_orig_status.loan_chg_status, 'A') = 'A' THEN
        RETURN 'VIEW';
      END IF;
    END IF;

  END IF;

  /*
  If the "Allow Acceptance of Lesser Amount" checkbox IS NOT checked on the Fund Manager form,
  Student Self-Service tab, the student can only accept the entire amount or decline the entire
  amount of an award.  The student cannot accept a lesser amount.
  The Accepted Amount should NOT be editable.
  */
  OPEN cur_award_status(p_award_id);
  FETCH cur_award_status INTO l_award_status;
  CLOSE cur_award_status;

  IF l_award_status = 'CANCELLED' THEN
    RETURN 'VIEW';
  END IF;

  IF NVL(fund_mast_rec.accept_less_amt_flag,'N') <> 'Y' THEN
    RETURN 'VIEW';
  END IF;

  IF (NVL(fund_mast_rec.allow_inc_post_accept_flag,'N') <> 'Y') AND (NVL(fund_mast_rec.allow_dec_post_accept_flag,'N') <> 'Y') THEN
    IF l_award_status = 'ACCEPTED' THEN
      RETURN 'VIEW';
    END IF;
  END IF;

  /*
  If the "View-only After Decline" radio button IS selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  make the award view-only on the Fund Manager form, Student Self-Service tab.
  This award will still be picked up during the repackaging process.

  If the "View-only After Decline" radio button IS NOT selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  the award remains editable. This award will still be picked up during the repackaging process.
  */

  IF l_award_status = 'DECLINED' AND NVL(fund_mast_rec.status_after_decline,'VIEW') = 'VIEW' THEN
    RETURN 'VIEW';
  END IF;

  RETURN 'MODIFY';
END get_accept_amt_display_mode;

FUNCTION  get_accept_display_mode ( p_award_id      NUMBER,
                                    p_accepted_amt  NUMBER,
                                    p_offered_amt   NUMBER)
RETURN VARCHAR2 AS

  CURSOR  cur_fund_details  (cp_award_id  NUMBER) IS
    SELECT  awd.lock_award_flag lock_awd_flag, mast.*
      FROM  IGF_AW_AWARD awd,
            IGF_AW_FUND_MAST mast
     WHERE  awd.award_id = cp_award_id
      AND   awd.fund_id = mast.fund_id;
  fund_mast_rec cur_fund_details%ROWTYPE;

  CURSOR  cur_min_disb_date (cp_award_id  NUMBER) IS
    SELECT  MIN(disb_date)
      FROM  IGF_AW_AWD_DISB
     WHERE  award_id = cp_award_id;

  sch_disb_date DATE;

  CURSOR  cur_fund_type (cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE) IS
    SELECT cat.fed_fund_code
      FROM igf_aw_fund_mast_all fund,
           igf_aw_fund_cat_all cat
     WHERE fund.fund_code = cat.fund_code
       AND fund.fund_id = cp_fund_id;

  l_fund_type igf_aw_fund_cat_v.fed_fund_code%TYPE;

  CURSOR  cur_orig_status_pell (cp_award_id  NUMBER) IS
    SELECT  orig_action_code
      FROM  igf_gr_rfms
     WHERE  award_id = cp_award_id;

  l_orig_status_pell igf_gr_rfms.orig_action_code%TYPE;

  CURSOR  cur_orig_status (cp_award_id  NUMBER) IS
    SELECT  loan_status, loan_chg_status
      FROM  igf_sl_loans_all
     WHERE  award_id = cp_award_id;

  l_orig_status cur_orig_status%ROWTYPE;

  CURSOR  cur_award_status  (cp_award_id  NUMBER) IS
    SELECT  award_status
      FROM  IGF_AW_AWARD
     WHERE  award_id = cp_award_id;

  l_award_status  igf_aw_award.AWARD_STATUS%TYPE;

BEGIN
  OPEN cur_fund_details(p_award_id);
  FETCH cur_fund_details INTO fund_mast_rec;
  CLOSE cur_fund_details;

  -- If the award is locked at the award context level, display it as read-only
  IF fund_mast_rec.lock_awd_flag = 'Y' THEN
    RETURN 'VW';
  END IF;

  -- Check If the view only check box is checked for the fund in fund manager form.
  --If the View only check box is checked then return V.
  IF NVL(fund_mast_rec.VIEW_ONLY_FLAG,'N') = 'Y' THEN
    RETURN 'VW';
  END IF;

  -- Check the fund type.
  -- If the fund type is pell then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  -- If the fund type is Direct or FFELP then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  OPEN cur_fund_type(fund_mast_rec.fund_id);
  FETCH cur_fund_type INTO l_fund_type;
  CLOSE cur_fund_type;

  IF l_fund_type = 'PELL' THEN
    OPEN cur_orig_status_pell(p_award_id);
    FETCH cur_orig_status_pell INTO l_orig_status_pell;
    CLOSE cur_orig_status_pell;
    IF l_orig_status_pell = 'S' THEN
      RETURN 'VW';
    END IF;
  ELSIF l_fund_type IN ('DLU', 'DLP', 'DLS', 'FLP', 'FLU', 'FLS', 'ALT') THEN
    OPEN cur_orig_status(p_award_id);
    FETCH cur_orig_status INTO l_orig_status;
    CLOSE cur_orig_status;
    IF l_orig_status.loan_status = 'S'  OR l_orig_status.loan_chg_status = 'S'  THEN
      RETURN 'VW';
    END IF;

    IF l_fund_type IN ('FLP', 'FLU', 'FLS', 'ALT') THEN
      IF l_orig_status.loan_status = 'A' AND NVL(l_orig_status.loan_chg_status, 'A') = 'A' THEN
        RETURN 'VW';
      END IF;
    END IF;

  END IF;


  OPEN cur_award_status(p_award_id);
  FETCH cur_award_status INTO l_award_status;
  CLOSE cur_award_status;

  IF l_award_status = 'CANCELLED' THEN
    RETURN 'VW';
  END IF;

  /*
  If the "Allow Increases To Accepted Amount After Acceptance" checkbox IS NOT checked
  and the checkbox for "Allow Decreases To Accepted Amount After Acceptance" IS NOT checked
  on the Fund Manager form, Student Self-Service tab,
  then after the award goes into accepted status, disable the Accept radio button
  and the Accepted Amount field to prevent further updates
  */

  IF (NVL(fund_mast_rec.allow_inc_post_accept_flag,'N') <> 'Y') AND (NVL(fund_mast_rec.allow_dec_post_accept_flag,'N') <> 'Y') THEN
    IF l_award_status = 'ACCEPTED' THEN
      RETURN 'VW';
    END IF;
  END IF;


  /*
  If the "View-only After Decline" radio button IS selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  make the award view-only on the Fund Manager form, Student Self-Service tab.
  This award will still be picked up during the repackaging process.

  If the "View-only After Decline" radio button IS NOT selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  the award remains editable. This award will still be picked up during the repackaging process.
  */

  IF l_award_status = 'DECLINED' AND NVL(fund_mast_rec.status_after_decline,'VIEW') = 'VIEW' THEN
    RETURN 'VW';
  END IF;

  RETURN 'MD';
END get_accept_display_mode;

FUNCTION  get_decline_display_mode  ( p_award_id      NUMBER,
                                      p_accepted_amt  NUMBER,
                                      p_offered_amt   NUMBER)
RETURN VARCHAR2 AS

  CURSOR  cur_fund_details  (cp_award_id  NUMBER) IS
    SELECT  awd.lock_award_flag lock_awd_flag, mast.*
      FROM  IGF_AW_AWARD awd,
            IGF_AW_FUND_MAST mast
     WHERE  awd.award_id = cp_award_id
      AND   awd.fund_id = mast.fund_id;
  fund_mast_rec cur_fund_details%ROWTYPE;

  CURSOR  cur_min_disb_date (cp_award_id  NUMBER) IS
    SELECT  MIN(disb_date)
      FROM  IGF_AW_AWD_DISB
     WHERE  award_id = cp_award_id;

  sch_disb_date DATE;

  CURSOR  cur_fund_type (cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE) IS
    SELECT cat.fed_fund_code
      FROM igf_aw_fund_mast_all fund,
           igf_aw_fund_cat_all cat
     WHERE fund.fund_code = cat.fund_code
       AND fund.fund_id = cp_fund_id;

  l_fund_type igf_aw_fund_cat_v.fed_fund_code%TYPE;

  CURSOR  cur_orig_status_pell (cp_award_id  NUMBER) IS
    SELECT  orig_action_code
      FROM  igf_gr_rfms
     WHERE  award_id = cp_award_id;

  l_orig_status_pell igf_gr_rfms.orig_action_code%TYPE;

  CURSOR  cur_orig_status (cp_award_id  NUMBER) IS
    SELECT  loan_status,loan_chg_status
      FROM  igf_sl_loans_all
     WHERE  award_id = cp_award_id;

  l_orig_status cur_orig_status%ROWTYPE;

  CURSOR  cur_award_details (cp_award_id  NUMBER) IS
    SELECT  *
      FROM  IGF_AW_AWARD awd
     WHERE  awd.award_id = cp_award_id;

  --rec_award_status igf_aw_award.AWARD_STATUS%TYPE;
  rec_award_details cur_award_details%ROWTYPE;

  CURSOR  cur_award_status  (cp_award_id  NUMBER) IS
    SELECT  award_status
      FROM  IGF_AW_AWARD
     WHERE  award_id = cp_award_id;

  l_award_status  igf_aw_award.AWARD_STATUS%TYPE;

BEGIN

  OPEN cur_fund_details(p_award_id);
  FETCH cur_fund_details INTO fund_mast_rec;
  CLOSE cur_fund_details;

  -- If the award is locked at the award context level, display it as read-only
  IF fund_mast_rec.lock_awd_flag = 'Y' THEN
    RETURN 'V';
  END IF;

  -- Check If the view only check box is checked for the fund in fund manager form.
  --If the View only check box is checked then return V.
  IF NVL(fund_mast_rec.VIEW_ONLY_FLAG,'N') = 'Y' THEN
    RETURN 'V';
  END IF;

  -- Check the fund type.
  -- If the fund type is pell then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  -- If the fund type is Direct or FFELP then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  OPEN cur_fund_type(fund_mast_rec.fund_id);
  FETCH cur_fund_type INTO l_fund_type;
  CLOSE cur_fund_type;

  IF l_fund_type = 'PELL' THEN
    OPEN cur_orig_status_pell(p_award_id);
    FETCH cur_orig_status_pell INTO l_orig_status_pell;
    CLOSE cur_orig_status_pell;
    IF l_orig_status_pell = 'S' THEN
      RETURN 'V';
    END IF;
  ELSIF l_fund_type IN ('DLU', 'DLP', 'DLS', 'FLP', 'FLU', 'FLS', 'ALT') THEN
    OPEN cur_orig_status(p_award_id);
    FETCH cur_orig_status INTO l_orig_status;
    CLOSE cur_orig_status;
    IF l_orig_status.loan_status = 'S'  OR l_orig_status.loan_chg_status = 'S'  THEN
      RETURN 'V';
    END IF;

    IF l_fund_type IN ('FLP', 'FLU', 'FLS', 'ALT') THEN
      IF l_orig_status.loan_status = 'A' AND NVL(l_orig_status.loan_chg_status, 'A') = 'A' THEN
        RETURN 'V';
      END IF;
    END IF;

  END IF;

  /*
  If the "Allow Decline After Accept" checkbox IS selected on the Fund Manager form,
  Student Self-Service tab, then if the award has an accepted status,
  the Decline radio button for that award will be enabled.

  If the "Allow Decline After Accept" checkbox IS NOT selected on the Fund Manager form,
  Student Self-Service tab, then if the award has an accepted status,
  the Decline radio button for that award will NOT be enabled.

  Note:  An award cannot be declined once any part of it has been 'Paid'
  (i.e. if any part of the award is paid, then the decline radio button for that
  award should not be enabled).
  */

  OPEN cur_award_details(p_award_id);
  FETCH cur_award_details INTO rec_award_details;
  CLOSE cur_award_details;

  IF rec_award_details.award_status = 'ACCEPTED' THEN
    IF (NVL(fund_mast_rec.ALLOW_DECLN_POST_ACCEPT_FLAG,'N') <> 'Y') THEN
      RETURN 'V';
    END IF;

    IF NVL(rec_award_details.PAID_AMT,0) > 0 THEN
      RETURN 'V';
    END IF;
  END IF;

  IF rec_award_details.award_status = 'CANCELLED' THEN
    RETURN 'V';
  END IF;


  OPEN cur_award_status(p_award_id);
  FETCH cur_award_status INTO l_award_status;
  CLOSE cur_award_status;


  /*
  If the "View-only After Decline" radio button IS selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  make the award view-only on the Fund Manager form, Student Self-Service tab.
  This award will still be picked up during the repackaging process.

  If the "View-only After Decline" radio button IS NOT selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  the award remains editable. This award will still be picked up during the repackaging process.

  In either case, if the award is declined, it is made read-only.
  */

  IF l_award_status = 'DECLINED' AND NVL(fund_mast_rec.status_after_decline,'VIEW') = 'VIEW' THEN
    RETURN 'V';
  END IF;

  RETURN 'M';
END get_decline_display_mode;

PROCEDURE update_award_status ( p_award_id      igf_aw_award_all.award_id%TYPE,
                                p_award_status  VARCHAR2,
                                p_lock_status   VARCHAR2
                              ) AS
------------------------------------------------------------------
--Created by  : rasahoo, Oracle India
--Date created:
--
--Purpose:
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------
-- Get an award
  CURSOR  c_award (cp_award_id igf_aw_award_all.award_id%TYPE)  IS
    SELECT  awd.rowid row_id,
            awd.*
      FROM  IGF_AW_AWARD_ALL awd
     WHERE  award_id = cp_award_id;
  awd_rec c_award%ROWTYPE;

BEGIN
  OPEN c_award(p_award_id);
  FETCH c_award INTO awd_rec;
  CLOSE c_award;

  igf_aw_award_pkg.set_award_change_source('STDNT_SELF_SERV');

  igf_aw_award_pkg.update_row(
    x_rowid              => awd_rec.row_id,
    x_award_id           => awd_rec.award_id,
    x_fund_id            => awd_rec.fund_id,
    x_base_id            => awd_rec.base_id,
    x_offered_amt        => awd_rec.offered_amt,
    x_accepted_amt       => awd_rec.accepted_amt,
    x_paid_amt           => awd_rec.paid_amt,
    x_packaging_type     => awd_rec.packaging_type,
    x_batch_id           => awd_rec.batch_id,
    x_manual_update      => awd_rec.manual_update,
    x_rules_override     => awd_rec.rules_override,
    x_award_date         => awd_rec.award_date,
    x_award_status       => p_award_status,
    x_attribute_category => awd_rec.attribute_category,
    x_attribute1         => awd_rec.attribute1,
    x_attribute2         => awd_rec.attribute2,
    x_attribute3         => awd_rec.attribute3,
    x_attribute4         => awd_rec.attribute4,
    x_attribute5         => awd_rec.attribute5,
    x_attribute6         => awd_rec.attribute6,
    x_attribute7         => awd_rec.attribute7,
    x_attribute8         => awd_rec.attribute8,
    x_attribute9         => awd_rec.attribute9,
    x_attribute10        => awd_rec.attribute10,
    x_attribute11        => awd_rec.attribute11,
    x_attribute12        => awd_rec.attribute12,
    x_attribute13        => awd_rec.attribute13,
    x_attribute14        => awd_rec.attribute14,
    x_attribute15        => awd_rec.attribute15,
    x_attribute16        => awd_rec.attribute16,
    x_attribute17        => awd_rec.attribute17,
    x_attribute18        => awd_rec.attribute18,
    x_attribute19        => awd_rec.attribute19,
    x_attribute20        => awd_rec.attribute20,
    x_rvsn_id            => awd_rec.rvsn_id,
    x_alt_pell_schedule  => awd_rec.alt_pell_schedule,
    x_mode               => 'R',
    x_award_number_txt   => awd_rec.award_number_txt,
    x_legacy_record_flag => awd_rec.legacy_record_flag,
    x_adplans_id         => awd_rec.adplans_id,
    x_lock_award_flag    => p_lock_status,
    x_app_trans_num_txt  => awd_rec.app_trans_num_txt,
    x_awd_proc_status_code => awd_rec.awd_proc_status_code,
    x_publish_in_ss_flag  => awd_rec.publish_in_ss_flag
  );

  igf_aw_Award_pkg.reset_awd_hist_trans_id;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END update_award_status;



PROCEDURE update_awards_by_term_from_ss ( p_award_id      igf_aw_award_all.award_id%TYPE,
                                          p_ld_cal_type   VARCHAR2,
                                          p_ld_seq_num    NUMBER,
                                          p_offered_amt   NUMBER,
                                          p_accepted_amt  NUMBER,
                                          p_term_awd_status VARCHAR2
                                        ) AS
------------------------------------------------------------------
--Created by  : rasahoo, Oracle India
--Date created:
--
--Purpose:
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

  CURSOR  c_disb  ( cp_award_id   igf_aw_award_all.award_id%TYPE,
                    cp_ld_cal_type VARCHAR2,
                    cp_ld_seq_num  NUMBER) IS
    SELECT  disb.rowid row_id,
            disb.*
      FROM  IGF_AW_AWD_DISB_ALL disb
     WHERE  award_id = cp_award_id
       AND  ld_cal_type = cp_ld_cal_type
       AND  ld_sequence_number = cp_ld_seq_num
       AND   trans_type IN ('A', 'P');

  l_dis_amt      NUMBER;
  l_net_amt      NUMBER;
  l_trans_type   VARCHAR2(1);
  l_award_status VARCHAR2(30);
  l_lock_status  VARCHAR2(1);

  CURSOR c_get_disb_rounding(
                             cp_award_id igf_aw_award_all.award_id%TYPE
                            ) IS
    SELECT fmast.disb_rounding_code
      FROM igf_aw_award_all awd,
           igf_aw_fund_mast_all fmast
     WHERE awd.fund_id  = fmast.fund_id
       AND awd.award_id = cp_award_id;
  rec_fund_mast c_get_disb_rounding%ROWTYPE;

BEGIN

  IF p_term_awd_status = 'ACCEPTED' THEN
    IF l_trans_type = 'A' THEN
      l_trans_type := 'A';
    ELSE
      l_trans_type := 'P';
    END IF;
  ELSIF p_term_awd_status = 'DECLINED' THEN
    l_trans_type := 'C';
  END IF;

  OPEN c_get_disb_rounding(p_award_id);
  FETCH c_get_disb_rounding INTO rec_fund_mast;
  CLOSE c_get_disb_rounding;

  FOR disb_rec IN c_disb(p_award_id, p_ld_cal_type, p_ld_seq_num) LOOP
    --Initialize the disbursement amout
    l_dis_amt := 0;
    IF p_accepted_amt = p_offered_amt THEN
      /*
        Reduce calculations if full amount is accepted
      */
      l_dis_amt := disb_rec.disb_gross_amt;
      l_net_amt := disb_rec.disb_net_amt;
    ELSE
    l_dis_amt := (p_accepted_amt/p_offered_amt) * disb_rec.disb_gross_amt;
    l_net_amt := disb_rec.disb_net_amt;
      IF l_dis_amt <> TRUNC(l_dis_amt) AND rec_fund_mast.disb_rounding_code IN ('ONE_FIRST','ONE_LAST') THEN
        l_dis_amt := TRUNC(l_dis_amt);
      END IF;
      IF l_dis_amt <> TRUNC(l_dis_amt,2) AND rec_fund_mast.disb_rounding_code IN ('DEC_FIRST','DEC_LAST') THEN
        l_dis_amt := TRUNC(l_dis_amt,2);
      END IF;
    END IF;

    igf_aw_awd_disb_pkg.update_row(
      x_rowid                     => disb_rec.row_id,
      x_award_id                  => disb_rec.award_id,
      x_disb_num                  => disb_rec.disb_num,
      x_tp_cal_type               => disb_rec.tp_cal_type,
      x_tp_sequence_number        => disb_rec.tp_sequence_number,
      x_disb_gross_amt            => disb_rec.disb_gross_amt,
      x_fee_1                     => disb_rec.fee_1,
      x_fee_2                     => disb_rec.fee_2,
      x_disb_net_amt              => l_net_amt,
      x_disb_date                 => disb_rec.disb_date,
      x_trans_type                => l_trans_type,
      x_elig_status               => disb_rec.elig_status,
      x_elig_status_date          => disb_rec.elig_status_date,
      x_affirm_flag               => disb_rec.affirm_flag,
      x_hold_rel_ind              => disb_rec.hold_rel_ind,
      x_manual_hold_ind           => disb_rec.manual_hold_ind,
      x_disb_status               => disb_rec.disb_status,
      x_disb_status_date          => disb_rec.disb_status_date,
      x_late_disb_ind             => disb_rec.late_disb_ind,
      x_fund_dist_mthd            => disb_rec.fund_dist_mthd,
      x_prev_reported_ind         => disb_rec.prev_reported_ind,
      x_fund_release_date         => disb_rec.fund_release_date,
      x_fund_status               => disb_rec.fund_status,
      x_fund_status_date          => disb_rec.fund_status_date,
      x_fee_paid_1                => disb_rec.fee_paid_1,
      x_fee_paid_2                => disb_rec.fee_paid_2,
      x_cheque_number             => disb_rec.cheque_number,
      x_ld_cal_type               => disb_rec.ld_cal_type,
      x_ld_sequence_number        => disb_rec.ld_sequence_number,
      x_disb_accepted_amt         => l_dis_amt,
      x_disb_paid_amt             => disb_rec.disb_paid_amt,
      x_rvsn_id                   => disb_rec.rvsn_id,
      x_int_rebate_amt            => disb_rec.int_rebate_amt,
      x_force_disb                => disb_rec.force_disb,
      x_min_credit_pts            => disb_rec.min_credit_pts,
      x_disb_exp_dt               => disb_rec.disb_exp_dt,
      x_verf_enfr_dt              => disb_rec.verf_enfr_dt,
      x_fee_class                 => disb_rec.fee_class,
      x_show_on_bill              => disb_rec.show_on_bill,
      x_mode                      => 'R',
      x_attendance_type_code      => disb_rec.attendance_type_code,
      x_base_attendance_type_code => disb_rec.base_attendance_type_code,
      x_payment_prd_st_date       => disb_rec.payment_prd_st_date,
      x_change_type_code          => disb_rec.change_type_code,
      x_fund_return_mthd_code     => disb_rec.fund_return_mthd_code,
      x_direct_to_borr_flag       => disb_rec.direct_to_borr_flag
    );
  END LOOP;
END update_awards_by_term_from_ss;

PROCEDURE submit_business_event (p_description VARCHAR2,
                                      p_award_prd      VARCHAR2,
                                      p_person_number  VARCHAR2,
                                      p_details        VARCHAR2) IS

  l_wf_event_t wf_event_t;
  lv_event_name VARCHAR2(50);
  l_seq_val            VARCHAR2(100);
  l_wf_parameter_list_t wf_parameter_list_t;

BEGIN

  SELECT igs_pe_res_chg_s.nextval INTO l_seq_val FROM DUAL;

  -- Initialize the wf_event_t object
  WF_EVENT_T.Initialize(l_wf_event_t);
  -- Set the event name
  lv_event_name := 'oracle.apps.igf.aw.AcptAmtMod';

  l_wf_event_t.setEventName(pEventName => lv_event_name);

  -- Set the event key
  l_wf_event_t.setEventKey(
                             pEventKey => lv_event_name || l_seq_val
                            );

  -- Set the parameter list
  l_wf_event_t.setParameterList(
                                pParameterList => l_wf_parameter_list_t
                               );

  wf_event.addparametertolist(
                              p_name          => 'AWARD_YEAR',
                              p_value         =>  p_description,
                              p_parameterlist => l_wf_parameter_list_t
                             );
  wf_event.addparametertolist(
                              p_name          => 'AWARDING_PRD',
                              p_value         =>  p_award_prd,
                              p_parameterlist => l_wf_parameter_list_t
                             );
  wf_event.addparametertolist(
                              p_name          => 'STUDENT_NUMBER',
                              p_value         =>  p_person_number,
                              p_parameterlist => l_wf_parameter_list_t
                             );
  wf_event.addparametertolist(
                              p_name          => 'DETAILS',
                              p_value         =>  p_details,
                              p_parameterlist => l_wf_parameter_list_t
                             );

  wf_Event.raise(
                 p_event_name => lv_event_name,
                 p_event_key  => lv_event_name || l_seq_val,
                 p_parameters => l_wf_parameter_list_t
                );

END submit_business_event;

FUNCTION get_acc_amt_display_mode_term( p_award_id      NUMBER,
                                        p_accepted_amt  NUMBER,
                                        p_offered_amt   NUMBER,
                                        p_ld_cal_type   VARCHAR2,
                                        p_ld_seq_num    NUMBER)
RETURN VARCHAR2 AS
  lc_program_cd         igs_ps_ver_all.course_cd%TYPE;
  lc_version_num        igs_ps_ver_all.version_number%TYPE;
  lc_program_type       igs_ps_ver_all.course_type%TYPE;
  lc_org_unit           igs_ps_ver_all.responsible_org_unit_cd%TYPE;

  l_last_accept_date    DATE;

  CURSOR c_get_base_id (cp_award_id NUMBER) IS
    SELECT base_id
      FROM igf_aw_award_all
     WHERE award_id = cp_award_id;

  l_get_base_id c_get_base_id%ROWTYPE;


  CURSOR  cur_fund_details  ( cp_award_id NUMBER) IS
    SELECT  awd.lock_award_flag lock_awd_flag, mast.*
      FROM  IGF_AW_AWARD awd,
            IGF_AW_FUND_MAST mast
     WHERE  awd.award_id = cp_award_id
      AND   awd.fund_id = mast.fund_id;
  fund_mast_rec cur_fund_details%ROWTYPE;

  CURSOR  cur_min_disb_date ( cp_award_id NUMBER) IS
    SELECT  MIN(disb_date)
      FROM  IGF_AW_AWD_DISB
     WHERE  award_id = cp_award_id;

  sch_disb_date DATE;

  CURSOR  cur_fund_type (cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE) IS
    SELECT cat.fed_fund_code
      FROM igf_aw_fund_mast_all fund,
           igf_aw_fund_cat_all cat
     WHERE fund.fund_code = cat.fund_code
       AND fund.fund_id = cp_fund_id;

  l_fund_type igf_aw_fund_cat_v.fed_fund_code%TYPE;

  CURSOR  cur_orig_status_pell (cp_award_id  NUMBER) IS
    SELECT  orig_action_code
      FROM  igf_gr_rfms
     WHERE  award_id = cp_award_id;

  l_orig_status_pell igf_gr_rfms.orig_action_code%TYPE;

  CURSOR  cur_orig_status (cp_award_id  NUMBER) IS
    SELECT  loan_status, loan_chg_status
      FROM  igf_sl_loans_all
     WHERE  award_id = cp_award_id;

  l_orig_status cur_orig_status%ROWTYPE;

  l_award_status igf_aw_award_all.award_status%TYPE;

BEGIN

  OPEN c_get_base_id(p_award_id);
  FETCH c_get_base_id INTO l_get_base_id;
  CLOSE c_get_base_id;

  -- Get context data for the first term.
  igf_ap_gen_001.get_context_data_for_term(
              l_get_base_id.base_id, --IN
              p_ld_cal_type, --IN
              p_ld_seq_num, --IN
              lc_program_cd,  --OUT
              lc_version_num, --OUT
              lc_program_type, --OUT
              lc_org_unit --OUT
             );

  --Get the Last Accept Date by using the API igs_ca_compute_da_val_pkg.cal_da_elt_val
  l_last_accept_date := igs_ca_compute_da_val_pkg.cal_da_elt_val(
                                                              'LAST_ACCEPT_DATE',                   --IN
                                                              p_ld_cal_type,                        --IN
                                                              p_ld_seq_num,                         --IN
                                                              lc_org_unit,                          --IN
                                                              lc_program_type,                      --IN
                                                              lc_program_cd || '/' || lc_version_num--IN
                                                             );

  IF SYSDATE > l_last_accept_date THEN
    RETURN 'VIEW';
  END IF;

  OPEN cur_fund_details(p_award_id);
  FETCH cur_fund_details INTO fund_mast_rec;
  CLOSE cur_fund_details;

  -- If the award is locked at the award context level, display it as read-only
  IF fund_mast_rec.lock_awd_flag = 'Y' THEN
    RETURN 'VIEW';
  END IF;

  -- Check If the view only check box is checked for the fund in fund manager form.
  --If the View only check box is checked then return V.
  IF NVL(fund_mast_rec.VIEW_ONLY_FLAG,'N') = 'Y' THEN
    RETURN 'VIEW';
  END IF;

  -- Check the fund type.
  -- If the fund type is pell then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  -- If the fund type is Direct or FFELP then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  OPEN cur_fund_type(fund_mast_rec.fund_id);
  FETCH cur_fund_type INTO l_fund_type;
  CLOSE cur_fund_type;
  IF l_fund_type = 'PELL' THEN
    OPEN cur_orig_status_pell(p_award_id);
    FETCH cur_orig_status_pell INTO l_orig_status_pell;
    CLOSE cur_orig_status_pell;
    IF l_orig_status_pell = 'S' THEN
      RETURN 'VIEW';
    END IF;
  ELSIF l_fund_type IN ('DLU', 'DLP', 'DLS', 'FLP', 'FLU', 'FLS', 'ALT') THEN
    OPEN cur_orig_status(p_award_id);
    FETCH cur_orig_status INTO l_orig_status;
    CLOSE cur_orig_status;
    IF l_orig_status.loan_status = 'S'  OR l_orig_status.loan_chg_status = 'S' THEN
      RETURN 'VIEW';
    END IF;

    IF l_fund_type IN ('FLP', 'FLU', 'FLS', 'ALT') THEN
      IF l_orig_status.loan_status = 'A' AND NVL(l_orig_status.loan_chg_status, 'A') = 'A' THEN
        RETURN 'VIEW';
      END IF;
    END IF;

  END IF;

  l_award_status := igf_aw_ss_gen_pkg.get_term_award_status(p_award_id,p_ld_cal_type,p_ld_seq_num);
  /*
  If the "Allow Acceptance of Lesser Amount" checkbox IS NOT checked on the Fund Manager form,
  Student Self-Service tab, the student can only accept the entire amount or decline the entire
  amount of an award.  The student cannot accept a lesser amount.
  The Accepted Amount should NOT be editable.
  */

  IF l_award_status = 'CANCELLED' THEN
    RETURN 'VIEW';
  END IF;

  IF NVL(fund_mast_rec.accept_less_amt_flag,'N') <> 'Y' THEN
    RETURN 'VIEW';
  END IF;

  IF (NVL(fund_mast_rec.allow_inc_post_accept_flag,'N') <> 'Y') AND (NVL(fund_mast_rec.allow_dec_post_accept_flag,'N') <> 'Y') THEN
    IF l_award_status = 'ACCEPTED' THEN
      RETURN 'VIEW';
    END IF;
  END IF;

  /*
  If the "View-only After Decline" radio button IS selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  make the award view-only on the Fund Manager form, Student Self-Service tab.
  This award will still be picked up during the repackaging process.

  If the "View-only After Decline" radio button IS NOT selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  the award remains editable. This award will still be picked up during the repackaging process.
  */

  IF l_award_status = 'DECLINED' AND NVL(fund_mast_rec.status_after_decline,'VIEW') = 'VIEW' THEN
    RETURN 'VIEW';
  END IF;

  RETURN 'MODIFY';

END get_acc_amt_display_mode_term;

FUNCTION  get_acc_display_mode_term( p_award_id      NUMBER,
                                     p_accepted_amt  NUMBER,
                                     p_offered_amt   NUMBER,
                                     p_ld_cal_type   VARCHAR2,
                                     p_ld_seq_num    NUMBER)
RETURN VARCHAR2 AS
  lc_program_cd         igs_ps_ver_all.course_cd%TYPE;
  lc_version_num        igs_ps_ver_all.version_number%TYPE;
  lc_program_type       igs_ps_ver_all.course_type%TYPE;
  lc_org_unit           igs_ps_ver_all.responsible_org_unit_cd%TYPE;

  l_last_accept_date    DATE;

  CURSOR c_get_base_id (cp_award_id NUMBER) IS
    SELECT base_id
      FROM igf_aw_award_all
     WHERE award_id = cp_award_id;

  l_get_base_id c_get_base_id%ROWTYPE;

  CURSOR  cur_fund_details  (cp_award_id  NUMBER) IS
    SELECT  awd.lock_award_flag lock_awd_flag, mast.*
      FROM  IGF_AW_AWARD awd,
            IGF_AW_FUND_MAST mast
     WHERE  awd.award_id = cp_award_id
      AND   awd.fund_id = mast.fund_id;
  fund_mast_rec cur_fund_details%ROWTYPE;

  CURSOR  cur_min_disb_date (cp_award_id  NUMBER) IS
    SELECT  MIN(disb_date)
      FROM  IGF_AW_AWD_DISB
     WHERE  award_id = cp_award_id;

  sch_disb_date DATE;

  CURSOR  cur_fund_type (cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE) IS
    SELECT cat.fed_fund_code
      FROM igf_aw_fund_mast_all fund,
           igf_aw_fund_cat_all cat
     WHERE fund.fund_code = cat.fund_code
       AND fund.fund_id = cp_fund_id;

  l_fund_type igf_aw_fund_cat_v.fed_fund_code%TYPE;

  CURSOR  cur_orig_status_pell (cp_award_id  NUMBER) IS
    SELECT  orig_action_code
      FROM  igf_gr_rfms
     WHERE  award_id = cp_award_id;

  l_orig_status_pell igf_gr_rfms.orig_action_code%TYPE;

  CURSOR  cur_orig_status (cp_award_id  NUMBER) IS
    SELECT  loan_status, loan_chg_status
      FROM  igf_sl_loans_all
     WHERE  award_id = cp_award_id;

  l_orig_status cur_orig_status%ROWTYPE;

  l_award_status igf_aw_award_all.award_status%TYPE;

BEGIN

  OPEN c_get_base_id(p_award_id);
  FETCH c_get_base_id INTO l_get_base_id;
  CLOSE c_get_base_id;

  -- Get context data for the first term.
  igf_ap_gen_001.get_context_data_for_term(
              l_get_base_id.base_id, --IN
              p_ld_cal_type, --IN
              p_ld_seq_num, --IN
              lc_program_cd,  --OUT
              lc_version_num, --OUT
              lc_program_type, --OUT
              lc_org_unit --OUT
             );

  --Get the Last Accept Date by using the API igs_ca_compute_da_val_pkg.cal_da_elt_val
  l_last_accept_date := igs_ca_compute_da_val_pkg.cal_da_elt_val(
                                                              'LAST_ACCEPT_DATE',                   --IN
                                                              p_ld_cal_type,                        --IN
                                                              p_ld_seq_num,                         --IN
                                                              lc_org_unit,                          --IN
                                                              lc_program_type,                      --IN
                                                              lc_program_cd || '/' || lc_version_num--IN
                                                             );

  IF SYSDATE > l_last_accept_date THEN
    RETURN 'VW';
  END IF;


  OPEN cur_fund_details(p_award_id);
  FETCH cur_fund_details INTO fund_mast_rec;
  CLOSE cur_fund_details;

  -- If the award is locked at the award context level, display it as read-only
  IF fund_mast_rec.lock_awd_flag = 'Y' THEN
    RETURN 'VW';
  END IF;

  -- Check If the view only check box is checked for the fund in fund manager form.
  --If the View only check box is checked then return V.
  IF NVL(fund_mast_rec.VIEW_ONLY_FLAG,'N') = 'Y' THEN
    RETURN 'VW';
  END IF;

  -- Check the fund type.
  -- If the fund type is pell then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  -- If the fund type is Direct or FFELP then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  OPEN cur_fund_type(fund_mast_rec.fund_id);
  FETCH cur_fund_type INTO l_fund_type;
  CLOSE cur_fund_type;

  IF l_fund_type = 'PELL' THEN
    OPEN cur_orig_status_pell(p_award_id);
    FETCH cur_orig_status_pell INTO l_orig_status_pell;
    CLOSE cur_orig_status_pell;
    IF l_orig_status_pell = 'S' THEN
      RETURN 'VW';
    END IF;
  ELSIF l_fund_type IN ('DLU', 'DLP', 'DLS', 'FLP', 'FLU', 'FLS', 'ALT') THEN
    OPEN cur_orig_status(p_award_id);
    FETCH cur_orig_status INTO l_orig_status;
    CLOSE cur_orig_status;
    IF l_orig_status.loan_status = 'S'  OR l_orig_status.loan_chg_status = 'S'  THEN
      RETURN 'VW';
    END IF;

    IF l_fund_type IN ('FLP', 'FLU', 'FLS', 'ALT') THEN
      IF l_orig_status.loan_status = 'A' AND NVL(l_orig_status.loan_chg_status, 'A') = 'A' THEN
        RETURN 'VW';
      END IF;
    END IF;

  END IF;

  l_award_status := igf_aw_ss_gen_pkg.get_term_award_status(p_award_id,p_ld_cal_type,p_ld_seq_num);

  IF l_award_status = 'CANCELLED' THEN
    RETURN 'VW';
  END IF;

  /*
  If the "Allow Increases To Accepted Amount After Acceptance" checkbox IS NOT checked
  and the checkbox for "Allow Decreases To Accepted Amount After Acceptance" IS NOT checked
  on the Fund Manager form, Student Self-Service tab,
  then after the award goes into accepted status, disable the Accept radio button
  and the Accepted Amount field to prevent further updates
  */

  IF (NVL(fund_mast_rec.allow_inc_post_accept_flag,'N') <> 'Y') AND (NVL(fund_mast_rec.allow_dec_post_accept_flag,'N') <> 'Y') THEN
    IF l_award_status = 'ACCEPTED' THEN
      RETURN 'VW';
    END IF;
  END IF;


  /*
  If the "View-only After Decline" radio button IS selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  make the award view-only on the Fund Manager form, Student Self-Service tab.
  This award will still be picked up during the repackaging process.

  If the "View-only After Decline" radio button IS NOT selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  the award remains editable. This award will still be picked up during the repackaging process.
  */

  IF l_award_status = 'DECLINED' AND NVL(fund_mast_rec.status_after_decline,'VIEW') = 'VIEW' THEN
    RETURN 'VW';
  END IF;

  RETURN 'MD';
END get_acc_display_mode_term;

FUNCTION  get_dec_display_mode_term(p_award_id      NUMBER,
                                    p_accepted_amt  NUMBER,
                                    p_offered_amt   NUMBER,
                                    p_ld_cal_type   VARCHAR2,
                                    p_ld_seq_num    NUMBER)
RETURN VARCHAR2 AS

  lc_program_cd         igs_ps_ver_all.course_cd%TYPE;
  lc_version_num        igs_ps_ver_all.version_number%TYPE;
  lc_program_type       igs_ps_ver_all.course_type%TYPE;
  lc_org_unit           igs_ps_ver_all.responsible_org_unit_cd%TYPE;

  l_last_accept_date    DATE;

  CURSOR c_get_base_id (cp_award_id NUMBER) IS
    SELECT base_id
      FROM igf_aw_award_all
     WHERE award_id = cp_award_id;

  l_get_base_id c_get_base_id%ROWTYPE;

  CURSOR  cur_fund_details  (cp_award_id  NUMBER) IS
    SELECT  awd.lock_award_flag lock_awd_flag, mast.*
      FROM  IGF_AW_AWARD awd,
            IGF_AW_FUND_MAST mast
     WHERE  awd.award_id = cp_award_id
      AND   awd.fund_id = mast.fund_id;
  fund_mast_rec cur_fund_details%ROWTYPE;

  CURSOR  cur_min_disb_date (cp_award_id  NUMBER) IS
    SELECT  MIN(disb_date)
      FROM  IGF_AW_AWD_DISB
     WHERE  award_id = cp_award_id;

  sch_disb_date DATE;

  CURSOR  cur_fund_type (cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE) IS
    SELECT cat.fed_fund_code
      FROM igf_aw_fund_mast_all fund,
           igf_aw_fund_cat_all cat
     WHERE fund.fund_code = cat.fund_code
       AND fund.fund_id = cp_fund_id;

  l_fund_type igf_aw_fund_cat_v.fed_fund_code%TYPE;

  CURSOR  cur_orig_status_pell (cp_award_id  NUMBER) IS
    SELECT  orig_action_code
      FROM  igf_gr_rfms
     WHERE  award_id = cp_award_id;

  l_orig_status_pell igf_gr_rfms.orig_action_code%TYPE;

  CURSOR  cur_orig_status (cp_award_id  NUMBER) IS
    SELECT  loan_status,loan_chg_status
      FROM  igf_sl_loans_all
     WHERE  award_id = cp_award_id;

  l_orig_status cur_orig_status%ROWTYPE;

  CURSOR  cur_award_details (cp_award_id  NUMBER) IS
    SELECT  *
      FROM  IGF_AW_AWARD awd
     WHERE  awd.award_id = cp_award_id;

  --rec_award_status igf_aw_award.AWARD_STATUS%TYPE;
  rec_award_details cur_award_details%ROWTYPE;

  l_award_status igf_aw_award_all.award_status%TYPE;

BEGIN

  OPEN c_get_base_id(p_award_id);
  FETCH c_get_base_id INTO l_get_base_id;
  CLOSE c_get_base_id;

  -- Get context data for the first term.
  igf_ap_gen_001.get_context_data_for_term(
              l_get_base_id.base_id, --IN
              p_ld_cal_type, --IN
              p_ld_seq_num, --IN
              lc_program_cd,  --OUT
              lc_version_num, --OUT
              lc_program_type, --OUT
              lc_org_unit --OUT
             );

  --Get the Last Accept Date by using the API igs_ca_compute_da_val_pkg.cal_da_elt_val
  l_last_accept_date := igs_ca_compute_da_val_pkg.cal_da_elt_val(
                                                              'LAST_ACCEPT_DATE',                     --IN
                                                              p_ld_cal_type,                          --IN
                                                              p_ld_seq_num,                           --IN
                                                              lc_org_unit,                            --IN
                                                              lc_program_type,                        --IN
                                                              lc_program_cd || '/' || lc_version_num  --IN
                                                             );

  IF SYSDATE > l_last_accept_date THEN
    RETURN 'V';
  END IF;


  OPEN cur_fund_details(p_award_id);
  FETCH cur_fund_details INTO fund_mast_rec;
  CLOSE cur_fund_details;

  -- If the award is locked at the award context level, display it as read-only
  IF fund_mast_rec.lock_awd_flag = 'Y' THEN
    RETURN 'V';
  END IF;

  -- Check If the view only check box is checked for the fund in fund manager form.
  --If the View only check box is checked then return V.
  IF NVL(fund_mast_rec.VIEW_ONLY_FLAG,'N') = 'Y' THEN
    RETURN 'V';
  END IF;

  -- Check the fund type.
  -- If the fund type is pell then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  -- If the fund type is Direct or FFELP then check the origination status of the fund.
  -- If the origination staus is Sent then return V.
  OPEN cur_fund_type(fund_mast_rec.fund_id);
  FETCH cur_fund_type INTO l_fund_type;
  CLOSE cur_fund_type;

  IF l_fund_type = 'PELL' THEN
    OPEN cur_orig_status_pell(p_award_id);
    FETCH cur_orig_status_pell INTO l_orig_status_pell;
    CLOSE cur_orig_status_pell;
    IF l_orig_status_pell = 'S' THEN
      RETURN 'V';
    END IF;
  ELSIF l_fund_type IN ('DLU', 'DLP', 'DLS', 'FLP', 'FLU', 'FLS', 'ALT') THEN
    OPEN cur_orig_status(p_award_id);
    FETCH cur_orig_status INTO l_orig_status;
    CLOSE cur_orig_status;
    IF l_orig_status.loan_status = 'S'  OR l_orig_status.loan_chg_status = 'S'  THEN
      RETURN 'V';
    END IF;

    IF l_fund_type IN ('FLP', 'FLU', 'FLS', 'ALT') THEN
      IF l_orig_status.loan_status = 'A' AND NVL(l_orig_status.loan_chg_status, 'A') = 'A' THEN
        RETURN 'V';
      END IF;
    END IF;

  END IF;

  /*
  If the "Allow Decline After Accept" checkbox IS selected on the Fund Manager form,
  Student Self-Service tab, then if the award has an accepted status,
  the Decline radio button for that award will be enabled.

  If the "Allow Decline After Accept" checkbox IS NOT selected on the Fund Manager form,
  Student Self-Service tab, then if the award has an accepted status,
  the Decline radio button for that award will NOT be enabled.

  Note:  An award cannot be declined once any part of it has been 'Paid'
  (i.e. if any part of the award is paid, then the decline radio button for that
  award should not be enabled).
  */

  l_award_status := igf_aw_ss_gen_pkg.get_term_award_status(p_award_id,p_ld_cal_type,p_ld_seq_num);

  OPEN cur_award_details(p_award_id);
  FETCH cur_award_details INTO rec_award_details;
  CLOSE cur_award_details;

  IF l_award_status = 'ACCEPTED' THEN
    IF (NVL(fund_mast_rec.ALLOW_DECLN_POST_ACCEPT_FLAG,'N') <> 'Y') THEN
      RETURN 'V';
    END IF;

    IF NVL(rec_award_details.PAID_AMT,0) > 0 THEN
      RETURN 'V';
    END IF;
  END IF;

  IF l_award_status = 'CANCELLED' THEN
    RETURN 'V';
  END IF;

  /*
  If the "View-only After Decline" radio button IS selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  make the award view-only on the Fund Manager form, Student Self-Service tab.
  This award will still be picked up during the repackaging process.

  If the "View-only After Decline" radio button IS NOT selected on the Fund Manager form,
  Student Self-Service tab, then when a student declines an award via student self-service,
  the award remains editable. This award will still be picked up during the repackaging process.

  In either case, if the award is declined, it is made read-only.
  */

  IF l_award_status = 'DECLINED' AND NVL(fund_mast_rec.status_after_decline,'VIEW') = 'VIEW' THEN
    RETURN 'V';
  END IF;

  RETURN 'M';

END get_dec_display_mode_term;

FUNCTION get_term_award_status (p_award_id      NUMBER,
                                p_ld_cal_type   VARCHAR2,
                                p_ld_seq_num    NUMBER)
RETURN VARCHAR2 AS

  l_accepted_amt   NUMBER;
  l_off_acc        VARCHAR2(2);

  CURSOR c_get_disb_award_status (cp_award_id NUMBER,
                                  cp_ld_cal_type   VARCHAR2,
                                  cp_ld_seq_num    NUMBER) IS
    SELECT award_id, disb_num, trans_type, disb_accepted_amt
      FROM igf_aw_awd_disb_all
     WHERE award_id = cp_award_id
       AND ld_cal_type = cp_ld_cal_type
       AND ld_sequence_number = cp_ld_seq_num;

BEGIN

  l_accepted_amt := 0;
  l_off_acc := 'N';

  FOR l_get_disb_award_status IN c_get_disb_award_status(p_award_id, p_ld_cal_type, p_ld_seq_num) LOOP
    l_accepted_amt := l_accepted_amt + l_get_disb_award_status.disb_accepted_amt;

    IF l_get_disb_award_status.trans_type = 'A' THEN
      RETURN 'ACCEPTED';
    ELSIF l_get_disb_award_status.trans_type = 'P' THEN
      l_off_acc := 'Y';
    END IF;
  END LOOP;

  IF l_off_acc = 'Y' THEN
    IF l_accepted_amt > 0 THEN
      RETURN 'ACCEPTED';
    ELSE
      RETURN 'OFFERED';
    END IF;
  END IF;

  RETURN 'DECLINED';

END get_term_award_status;


END IGF_AW_SS_GEN_PKG;

/
