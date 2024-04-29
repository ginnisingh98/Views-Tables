--------------------------------------------------------
--  DDL for Package Body IGF_AW_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_GEN_005" AS
/* $Header: IGFAW14B.pls 120.2 2005/07/11 08:44:44 appldev ship $ */

  /*======================================================================+
  |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
  |                            All rights reserved.                       |
  +=======================================================================+
  |                                                                       |
  | DESCRIPTION                                                           |
  |      PL/SQL spec for package: IGF_AW_GEN_005                          |
  |                                                                       |
  | NOTES                                                                 |
  |      Holds all the generic Routines                                   |
  |                                                                       |
  | HISTORY                                                               |
  | Who             When            What                                  |
  | veramach        Oct 2004        FA 152/FA 137 - Changes to wrappers to|
  |                                 bring in the awarding period setup    |
  | bkkumar         4-DEC-2003      FA 131 Bug# 3252832                   |
  |                                 TBH impact of the igf_aw_award        |
  |                                 Added columns LOCK_AWARD_FLAG,        |
  |                                 APP_TRANS_NUM_TXT                     |
  | veramach        1-NOV-2003      FA 125 Multipl Distribution Methods   |
  |                                 Added procedures update_plan,         |
  |                                 update_dist_plan,delete_plan,         |
  |                                 check_plan_code                       |
  | brajendr        08-Jan-2003     Bug # 2710314                         |
  |                                 Added a Function validate_student_efc |
  |                                 for checking the validity of EFC      |
  |                                                                       |
  | brajendr        31-Dec-2002     Bug #  2721995                        |
  |                                 Added an extra condition in first if  |
  |                                 condition. ( fund_code IS NULL )      |
  |                                                                       |
  *======================================================================*/

  PROCEDURE update_plan(
                        p_adplans_id   IN         igf_aw_awd_dist_plans.adplans_id%TYPE,
                        p_method_code  IN         VARCHAR2,
                        p_result       OUT NOCOPY VARCHAR2
                       ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 1-NOV-2003
  --
  --Purpose:Update a distribution plan's distribution percentages
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  -- Get all terms associated with the plan ID
  CURSOR c_terms(
                  cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                ) IS
    SELECT rowid row_id,terms.*
      FROM igf_aw_dp_terms terms
     WHERE adplans_id = cp_adplans_id
       AND ld_perct_num IS NOT NULL;

  BEGIN

    p_result := NULL;

    IF p_method_code <> 'M' THEN

      FOR terms_rec IN c_terms(p_adplans_id) LOOP
          igf_aw_dp_terms_pkg.update_row(
                                          x_rowid              => terms_rec.row_id,
                                          x_adterms_id         => terms_rec.adterms_id,
                                          x_adplans_id         => terms_rec.adplans_id,
                                          x_ld_cal_type        => terms_rec.ld_cal_type,
                                          x_ld_sequence_number => terms_rec.ld_sequence_number,
                                          x_ld_perct_num       => NULL,
                                          x_mode               => 'R'
                                        );
          p_result := 'REQUERY';
      END LOOP;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_AW_GEN_005.UPDATE_PLAN');
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
  END update_plan;

  PROCEDURE update_dist_plan(
                              p_award_id igf_aw_award.award_id%TYPE
                            ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 1-NOV-2003
  --
  --Purpose:To update an award's distribution plan with NULL when disbursements are changed manually
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --bvisvana    11-Jul-2005     TBH impact for notification status code,notification status date and publish in ss flag
  -------------------------------------------------------------------
  -- Get award details
  CURSOR c_award(
                 cp_award_id igf_aw_award.award_id%TYPE
                ) IS
    SELECT *
      FROM igf_aw_award
     WHERE award_id = cp_award_id;

    l_award c_award%ROWTYPE;

  BEGIN
    IF p_award_id IS NOT NULL THEN
      OPEN c_award(p_award_id);
      FETCH c_award INTO l_award;
      IF c_award%FOUND THEN
        igf_aw_award_pkg.update_row(
                                    x_rowid               => l_award.row_id,
                                    x_award_id            => l_award.award_id,
                                    x_fund_id             => l_award.fund_id,
                                    x_base_id             => l_award.base_id,
                                    x_offered_amt         => l_award.offered_amt,
                                    x_accepted_amt        => l_award.accepted_amt,
                                    x_paid_amt            => l_award.paid_amt,
                                    x_packaging_type      => l_award.packaging_type,
                                    x_batch_id            => l_award.batch_id,
                                    x_manual_update       => l_award.manual_update,
                                    x_rules_override      => l_award.rules_override,
                                    x_award_date          => l_award.award_date,
                                    x_award_status        => l_award.award_status,
                                    x_attribute_category  => l_award.attribute_category,
                                    x_attribute1          => l_award.attribute1,
                                    x_attribute2          => l_award.attribute2,
                                    x_attribute3          => l_award.attribute3,
                                    x_attribute4          => l_award.attribute4,
                                    x_attribute5          => l_award.attribute5,
                                    x_attribute6          => l_award.attribute6,
                                    x_attribute7          => l_award.attribute7,
                                    x_attribute8          => l_award.attribute8,
                                    x_attribute9          => l_award.attribute9,
                                    x_attribute10         => l_award.attribute10,
                                    x_attribute11         => l_award.attribute11,
                                    x_attribute12         => l_award.attribute12,
                                    x_attribute13         => l_award.attribute13,
                                    x_attribute14         => l_award.attribute14,
                                    x_attribute15         => l_award.attribute15,
                                    x_attribute16         => l_award.attribute16,
                                    x_attribute17         => l_award.attribute17,
                                    x_attribute18         => l_award.attribute18,
                                    x_attribute19         => l_award.attribute19,
                                    x_attribute20         => l_award.attribute20,
                                    x_rvsn_id             => l_award.rvsn_id,
                                    x_alt_pell_schedule   => l_award.alt_pell_schedule,
                                    x_mode                => 'R',
                                    x_award_number_txt    => l_award.award_number_txt,
                                    x_legacy_record_flag  => l_award.legacy_record_flag,
                                    x_adplans_id          => NULL,
                                    x_lock_award_flag     => l_award.lock_award_flag,
                                    x_app_trans_num_txt   => l_award.app_trans_num_txt,
                                    x_awd_proc_status_code => l_award.awd_proc_status_code,
                                    x_notification_status_code => l_award.notification_status_code,
                                    x_notification_status_date => l_award.notification_status_date,
                                    x_publish_in_ss_flag       => l_award.publish_in_ss_flag
                                   );
      END IF;
      CLOSE c_award;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_AW_GEN_005.UPDATE_DIST_PLAN');
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
  END update_dist_plan;

  PROCEDURE check_plan_code(
                            p_adplans_id IN         igf_aw_awd_dist_plans.adplans_id%TYPE,
                            p_result     OUT NOCOPY VARCHAR2
                           ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 1-NOV-2003
  --
  --Purpose: Check if a distribution plan is associated with any award,award group or formula group
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- check if a distribution plan is associated with a award group
  CURSOR c_check_agrp(
                      cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                     ) IS
    SELECT adplans_id
      FROM igf_aw_target_grp
     WHERE adplans_id = cp_adplans_id;

  -- check if a distribution plan is associated with a target group
  CURSOR c_check_frml(
                      cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                     ) IS
    SELECT adplans_id
      FROM igf_aw_awd_frml_det
     WHERE adplans_id = cp_adplans_id;

  -- check if a distribution plan is associated with a award
  CURSOR c_check_awd(
                     cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE
                    ) IS
    SELECT adplans_id
      FROM igf_aw_award
     WHERE adplans_id = cp_adplans_id;

  l_check_agrp c_check_agrp%ROWTYPE;
  l_check_frml c_check_frml%ROWTYPE;
  l_check_awd  c_check_awd%ROWTYPE;

  BEGIN

    p_result := NULL;

    OPEN c_check_agrp(p_adplans_id);
    FETCH c_check_agrp INTO l_check_agrp;

    IF c_check_agrp%FOUND THEN
      p_result := 'AGRP';
    ELSE
      OPEN c_check_frml(p_adplans_id);
      FETCH c_check_frml INTO l_check_frml;

      IF c_check_frml%FOUND THEN
        p_result := 'AGRP';
      END IF;
    END IF;

    OPEN c_check_awd(p_adplans_id);
    FETCH c_check_awd INTO l_check_awd;

    IF c_check_awd%FOUND THEN
      p_result := 'AWARD';
    END IF;

    IF c_check_agrp%ISOPEN THEN
      CLOSE c_check_agrp;
    END IF;

    IF c_check_frml%ISOPEN THEN
      CLOSE c_check_frml;
    END IF;

    IF c_check_awd%ISOPEN THEN
      CLOSE c_check_awd;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_AW_GEN_005.CHECK_PLAN_CODE');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
  END check_plan_code;

  PROCEDURE delete_plan(
                        p_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                        p_adterms_id igf_aw_dp_terms.adterms_id%TYPE
                       ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 1-NOV-2003
  --
  --Purpose: To delete terms and teaching periods attahced to a distribution plan
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  -- Get all terms attached to a distribution plan
  CURSOR c_terms(
                 cp_adplans_id igf_aw_awd_dist_plans.adplans_id%TYPE,
                 cp_adterms_id igf_aw_dp_terms.adterms_id%TYPE
                ) IS
    SELECT rowid row_id,terms.adterms_id adterms_id
      FROM igf_aw_dp_terms terms
     WHERE adplans_id = cp_adplans_id
       AND adterms_id = NVL(cp_adterms_id,adterms_id);

  -- Get all teaching periods attahced with a term
  CURSOR c_teach_periods(
                         cp_adterms_id igf_aw_dp_terms.adterms_id%TYPE
                        ) IS
    SELECT rowid row_id
      FROM igf_aw_dp_teach_prds
     WHERE adterms_id = cp_adterms_id;


  BEGIN

    FOR l_terms_rec IN c_terms(p_adplans_id,p_adterms_id) LOOP
      FOR l_teaching_periods_rec IN c_teach_periods(l_terms_rec.adterms_id) LOOP
        igf_aw_dp_teach_prds_pkg.delete_row(x_rowid => l_teaching_periods_rec.row_id);
      END LOOP;
      IF p_adterms_id IS NULL THEN
        igf_aw_dp_terms_pkg.delete_row(x_rowid => l_terms_rec.row_id);
      END IF;
    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_AW_GEN_005.DELETE_PLAN');
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
  END delete_plan;

  FUNCTION get_stud_hold_effect(
                                p_orig       IN  VARCHAR2,
                                p_person_id  IN  igf_ap_fa_base_rec_all.person_id%TYPE,
                                p_fund_code  IN  igf_aw_fund_mast_all.fund_code%TYPE,
                                p_date       IN  DATE
                               ) RETURN VARCHAR2 IS

    /*
    ||  Created By : brajendr
    ||  Created On : 7-Nov-2002
    ||  Purpose    : Bug # 2613536
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  brajendr        31-Dec-2002     Bug #  2721995
    ||                                  Added an extra condition in first if condition. ( fund_code IS NULL )
    ||  gmaheswa        25-Aug-2004     Bug 3609966 removed check for closed indicator in c_get_enc_effect cursor.
    ||  (reverse chronological order - newest change first)
    */

    -- Check whether the fund is present in Persons Exclusiions list
    CURSOR c_chk_fund(
                      cp_person_id   igf_ap_fa_base_rec_all.person_id%TYPE,
                      cp_fund_code   igf_aw_fund_mast_all.fund_code%TYPE,
                      cp_encb_type   igs_pe_persenc_effct.encumbrance_type%TYPE,
                      cp_effect_type VARCHAR2,
                      cp_date        DATE
                     ) IS
    SELECT 'x'
      FROM dual
     WHERE EXISTS ( SELECT 1
                      FROM igs_pe_fund_excl
                     WHERE fund_code = cp_fund_code
                       AND person_id = cp_person_id
                       AND encumbrance_type = cp_encb_type
                       AND s_encmb_effect_type = cp_effect_type
                       AND NVL(cp_date,TRUNC(sysdate)) BETWEEN TRUNC(pfe_start_dt) AND NVL(TRUNC(expiry_dt),TRUNC(sysdate))
                  );


    -- Check whether Are there any Holds present for the person
    CURSOR c_get_enc_effect(
                            cp_person_id  igf_ap_fa_base_rec_all.person_id%TYPE,
                            cp_date       DATE
                           ) IS
    SELECT eff.encumbrance_type encb_type, eff.s_encmb_effect_type effect_type
      FROM igs_fi_encmb_type typ,
           igs_pe_pers_encumb enc,
           igs_pe_persenc_effct eff
     WHERE typ.s_encumbrance_cat = 'ACADEMIC'
       AND typ.encumbrance_type = enc.encumbrance_type
       AND NVL(cp_date, TRUNC(sysdate)) BETWEEN TRUNC(eff.pee_start_dt) AND NVL(TRUNC(eff.expiry_dt), TRUNC(sysdate))
       AND enc.person_id =  cp_person_id
       AND enc.encumbrance_type = eff.encumbrance_type
       AND eff.person_id =  enc.person_id
       AND eff.s_encmb_effect_type IN ('EX_AWD', 'EX_SP_AWD', 'EX_DISB', 'EX_SP_DISB');

    lv_valid_fund   VARCHAR2(1);

  BEGIN

    lv_valid_fund  := NULL;

    -- Return 'F' for invalid parameters
    IF p_orig NOT IN ( 'A', 'D') THEN
      RETURN 'F';
    END IF;


    -- Get all Financial Aid Holds at the student level
    FOR c_get_enc_effect_rec IN c_get_enc_effect(p_person_id, p_date) LOOP

      -- If called from Packaging and Person has "All Awards Hold" then return 'F'
      IF p_orig = 'A' AND c_get_enc_effect_rec.effect_type = 'EX_AWD' AND p_fund_code IS NULL THEN
        RETURN 'F';

      -- If called from Packaging and Person has "Hold Specific Fund" then return 'F'
      ELSIF p_orig = 'A' AND c_get_enc_effect_rec.effect_type = 'EX_SP_AWD' AND p_fund_code IS NOT NULL THEN
        OPEN c_chk_fund( p_person_id, p_fund_code, c_get_enc_effect_rec.encb_type, 'EX_SP_AWD', p_date);
        FETCH c_chk_fund INTO lv_valid_fund;
        CLOSE c_chk_fund;

        IF lv_valid_fund = 'x' THEN
          RETURN 'F';
        END IF;

      -- If called from Disbursement and Person has "All Disbursement Hold" then return 'F'
      ELSIF p_orig = 'D' AND c_get_enc_effect_rec.effect_type = 'EX_DISB' THEN
        RETURN 'F';

      -- If called from Disbursement and Person has "Hold Specific Fund Disbursement" then return 'F'
      ELSIF p_orig = 'D' AND c_get_enc_effect_rec.effect_type = 'EX_SP_DISB' AND p_fund_code IS NOT NULL THEN
        OPEN c_chk_fund( p_person_id, p_fund_code, c_get_enc_effect_rec.encb_type, 'EX_SP_DISB', p_date);
        FETCH c_chk_fund INTO lv_valid_fund;
        CLOSE c_chk_fund;

        IF lv_valid_fund = 'x' THEN
          RETURN 'F';
        END IF;

      END IF;

    END LOOP;

    RETURN 'S';
  EXCEPTION
    WHEN others THEN
      RETURN 'F';
  END get_stud_hold_effect;


  FUNCTION validate_student_efc(
                                p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                                p_awd_prd_code igf_aw_awd_prd_term.award_prd_cd%TYPE
                               ) RETURN VARCHAR2 AS
    /*
    ||  Created By : brajendr
    ||  Created On : 08-Jan-2003
    ||  Purpose : This function checks whether the student has got the valid EFC at the ISIR Record or not.
    ||            Returns 'T' if the EFC is calculated.
    ||            Returns 'F' if the EFC is not calculated. ( NULL at ISIR RECORD )
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  veramach      16-Apr-2004     bug 3547237
    ||                                Enforced a check that if auto_zero_efc is set to 'Y' in the active_isir,
 	  ||                                then the EFC shown on the Summary tab must always be zero
    ||  rasahoo       27-Nov-2003     FA 128 Isir Update
    ||                                Changed the Cursor c_chk_valid_efc as part of paid efc impact
    */
  l_efc NUMBER;
  BEGIN
    l_efc := igf_aw_gen_004.efc_f(p_base_id,p_awd_prd_code);
    IF l_efc IS NOT NULL THEN
      RETURN 'T';
    ELSIF l_efc IS NULL THEN
      RETURN 'F';
    END IF;

  END validate_student_efc;


END igf_aw_gen_005;

/
