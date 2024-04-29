--------------------------------------------------------
--  DDL for Package Body IGS_EN_HESA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_HESA_PKG" AS
/* $Header: IGSHE16B.pls 120.1 2006/02/07 14:53:06 jbaber noship $ */

---------------------------------------------------------------------
-- Change History
-- Who          When              What
--rshergil   23-Jan-2002   Created program for pre-enrollment process
--                         relating to HESA details
--                         1. UK Statistics - SPA
--                         2. Student Unit Set Attempt HESA Details
--sbaliga   16-Apr-2002   Modified HESA_SUSA_ENR procedure
--                        corresponding to changes in IGS_HE_POOUS_ALL
--                        and IGS_HE_EN_SUSA table
--smaddali  14-may-2002  added new parameter p_old_sequence_number and
--                       renamed p_sequence_number to p_new_sequence_number in procedure hesa_susa_enr  for bug#2350629
--Bayadav   22-OCT-2002  Included four new columns qual_aim_subj1,qual_aim_subj2,qual_aim_subj3,qual_aim_proportion
--                       in IGS_HE_ST_SPA_ALL table as a part of bug 2636897
--Bayadav   22-OCT-2002  Included one new column type_of_year and corresponding validation |
--                       in IGS_HE_EN_SUSA table as a part of bug 2636897    |
--knaraset  14-Nov-2002  Added the functions validate_program_aim,val_sub_qual_proportion,
--                       val_highest_qual_entry,get_unit_set_cat,check_teach_inst,check_grading_sch_grade
--                       as part of Build TD Legacy SPA Bug 2661533
--smaddali               modified cursor cur_hqual_grade  for bug 2730388
--pmarada   13-feb-03    Modified the validate_program_aim procedure
--                       added the closed_ind condition in the cursor where clause, bug 2801518
--pmarada   20-aug-2003  Added code to derive the student instance number field value as per
--                       HECR008-Alphsnumeric student instance number Bug 2893557
--gmahesa   13-Nov-2003  Bug No: 3227107 address changes, Modified gc_addr_rec cursor to select records with active status.
--smaddali  08-Jan-2004  Bug#3291399 , modified procedure hesa_susa_enr for modifying logic for copying fields
--jbaber    24-Nov-2004  Bug No: 3949136. Modified hesa_stats_enr procedure to prevent enrollment HESA data from being overwritten
--jbaber    16-Jan-2006  Updated igs_he_st_spa_all_pkg call to include exclud_flag column for HE305
--------------------------------------------------------------------

PROCEDURE hesa_stats_enr(
      p_person_id IN NUMBER,
      p_course_cd IN VARCHAR2,
      p_crv_version_number IN NUMBER,
      p_message OUT NOCOPY VARCHAR2,
      p_status OUT NOCOPY NUMBER)

AS
      gv_addr_rec igs_pe_addr_v.postal_code%TYPE;

  CURSOR gc_stats_rec IS
   SELECT hesa_st_spa_id,
   course_cd,
   version_number,
   person_id,
   fe_student_marker,
   domicile_cd,
   inst_last_attended,
   year_left_last_inst,
   highest_qual_on_entry,
   date_qual_on_entry_calc,
   a_level_point_score,
   highers_points_scores,
   occupation_code,
   commencement_dt,
   special_student,
   student_qual_aim,
   student_fe_qual_aim,
   teacher_train_prog_id,
   itt_phase,
   bilingual_itt_marker,
   teaching_qual_gain_sector,
   teaching_qual_gain_subj1,
   teaching_qual_gain_subj2,
   teaching_qual_gain_subj3,
   student_inst_number,
   hesa_return_name,
   hesa_return_id,
   hesa_submission_name,
   associate_ucas_number,
   associate_scott_cand,
   associate_teach_ref_num,
   associate_nhs_reg_num,
   itt_prog_outcome,
   nhs_funding_source,
   ufi_place,
   postcode,
   social_class_ind,
   destination,
   occcode,
   total_ucas_tariff,
   nhs_employer,
   return_type,
   qual_aim_subj1,
   qual_aim_subj2,
   qual_aim_subj3,
   qual_aim_proportion,
   dependants_cd,
   implied_fund_rate,
   gov_initiatives_cd,
   units_for_qual,
   disadv_uplift_elig_cd,
   franch_partner_cd,
   units_completed,
   franch_out_arr_cd,
   employer_role_cd,
   disadv_uplift_factor,
   enh_fund_elig_cd,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login
  FROM igs_he_st_spa
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND version_number = p_crv_version_number;

  gv_stats_rec gc_stats_rec%ROWTYPE;

  CURSOR gc_adm_rec IS
  SELECT a.hesa_sequence_id hesa_sequence_id,
         a.person_id person_id,
         a.admission_appl_number admission_appl_number,
         a.nominated_course_cd nominated_course_cd,
         a.sequence_number sequence_number,
         a.occupation_cd occupation_cd,
         a.domicile_cd domicile_cd,
         a.social_class_cd social_class_cd,
         a.special_student_cd special_student_cd,
         a.creation_date creation_date,
         a.created_by created_by,
         a.last_update_date last_update_date,
         a.last_updated_by last_updated_by,
         a.last_update_login last_update_login
  FROM igs_he_ad_dtl a,
       igs_ad_ps_appl_inst b,
       igs_en_stdnt_ps_att c
  WHERE a.person_id = b.person_id
  AND   a.admission_appl_number = b.admission_appl_number
  AND   a.nominated_course_cd = b.nominated_course_cd
  AND   a.sequence_number = b.sequence_number
  AND   b.admission_appl_number = c.adm_admission_appl_number
  AND   b.person_id = c.person_id
  AND   b.nominated_course_cd = c.adm_nominated_course_cd
  AND   b.sequence_number = c.adm_sequence_number
  AND   c.person_id = p_person_id
  AND   c.course_cd = p_course_cd
  AND   c.version_number = p_crv_version_number;

  gv_adm_rec gc_adm_rec%ROWTYPE;

  CURSOR gc_addr_rec IS
  SELECT  a.postal_code postal_code
  FROM igs_pe_addr_v a
  WHERE a.person_id = p_person_id
  AND (a.status = 'A' AND SYSDATE BETWEEN NVL(a.start_dt,SYSDATE) AND NVL(a.end_dt,SYSDATE))
  AND (EXISTS(SELECT 'X'
             FROM igs_pe_partysiteuse_v b
             WHERE a.party_site_id = b.party_site_id
             AND b.site_use_type = 'HOME'
             AND b.active='Y')
       OR  a.correspondence = 'Y');


  CURSOR gc_upd_stats_rec IS
   SELECT ROWID
   FROM igs_he_st_spa
   WHERE person_id = p_person_id
   AND course_cd = p_course_cd
   AND version_number = p_crv_version_number;

  -- Get the all instance numbers for the student
  CURSOR cur_std_inst_num(cp_person_id igs_he_st_spa.person_id%TYPE) IS
    SELECT student_inst_number
    FROM igs_he_st_spa
    WHERE person_id = cp_person_id;

  l_std_inst_num  NUMBER;

  --Procedure inserts into IGS_HE_ST_SPA_ALL table

  PROCEDURE cr_he_st_spa_rec ( p_person_id igs_he_st_spa.person_id%TYPE,
                             p_course_cd igs_he_st_spa.course_cd%TYPE,
                             p_crv_version_number igs_he_st_spa.version_number%TYPE) IS

  BEGIN

  DECLARE

     v_stat_seq_num  igs_he_st_spa.hesa_st_spa_id%TYPE;

     CURSOR c_stat_seq_num IS
     SELECT igs_he_st_spa_all_s.NEXTVAL
     FROM dual;

    x_rowid VARCHAR2(250);
    l_org_id NUMBER(15);

  BEGIN

    OPEN c_stat_seq_num;
    FETCH c_stat_seq_num INTO v_stat_seq_num;
    CLOSE c_stat_seq_num;

    l_org_id := igs_ge_gen_003.get_org_id;
    x_rowid := NULL;

  OPEN gc_adm_rec;
  FETCH gc_adm_rec INTO gv_adm_rec;
  CLOSE gc_adm_rec;

  OPEN gc_addr_rec;
  FETCH gc_addr_rec INTO gv_addr_rec;
  CLOSE gc_addr_rec;

    -- Derive the student instance number value, added as per
    -- HECR008-alpha numeric student instance number CR
       l_std_inst_num := 1;
    FOR cur_std_inst_num_rec IN cur_std_inst_num(p_person_id) LOOP
      BEGIN

        IF NVL(TO_NUMBER(cur_std_inst_num_rec.Student_inst_number),0) >= l_std_inst_num THEN
          l_std_inst_num := TO_NUMBER(cur_std_inst_num_rec.Student_inst_number) + 1;
        END IF;
        EXCEPTION
          WHEN VALUE_ERROR THEN
          NULL;
      END ;
    END LOOP;

   --Create a reocrd in hesa student program attempt table
  igs_he_st_spa_all_pkg.insert_row(
      x_rowid                    =>x_rowid,
      x_org_id                   =>l_org_id,
      x_hesa_st_spa_id           =>v_stat_seq_num,
      x_person_id                =>p_person_id,
      x_course_cd                =>p_course_cd,
      x_version_number           =>p_crv_version_number,
      x_fe_student_marker        =>NULL,
      x_student_inst_number      =>l_std_inst_num ,
      x_domicile_cd              =>gv_adm_rec.domicile_cd,
      x_inst_last_attended       =>NULL,
      x_year_left_last_inst      =>NULL,
      x_highest_qual_on_entry    =>NULL,
      x_date_qual_on_entry_calc  =>NULL,
      x_a_level_point_score      =>NULL,
      x_highers_points_scores    =>NULL,
      x_occupation_code          =>gv_adm_rec.occupation_cd,
      x_commencement_dt          =>NULL,
      x_social_class_ind         =>gv_adm_rec.social_class_cd,
      x_special_student          =>gv_adm_rec.special_student_cd,
      x_student_qual_aim         =>NULL,
      x_student_fe_qual_aim      =>NULL,
      x_teacher_train_prog_id    =>NULL,
      x_itt_phase                =>NULL,
      x_bilingual_itt_marker     =>NULL,
      x_teaching_qual_gain_sector=>NULL,
      x_teaching_qual_gain_subj1 =>NULL,
      x_teaching_qual_gain_subj2 =>NULL,
      x_teaching_qual_gain_subj3 =>NULL,
      x_destination              =>NULL,
      x_itt_prog_outcome         =>NULL,
      x_hesa_return_name         =>NULL,
      x_hesa_return_id           =>NULL,
      x_hesa_submission_name     =>NULL,
      x_associate_ucas_number    =>NULL,
      x_associate_scott_cand     =>NULL,
      x_associate_teach_ref_num  =>NULL,
      x_associate_nhs_reg_num    =>NULL,
      x_nhs_funding_source       =>NULL,
      x_ufi_place                =>NULL,
      x_postcode                 =>gv_addr_rec,
      x_occcode                  =>NULL,
      x_total_ucas_tariff        =>NULL,
      x_nhs_employer             =>NULL,
      x_return_type              =>NULL,
      x_qual_aim_subj1           =>NULL,
      x_qual_aim_subj2           =>NULL,
      x_qual_aim_subj3           =>NULL,
      x_qual_aim_proportion      =>NULL,
      x_mode                     =>'R',
      x_dependants_cd            =>NULL,
      x_implied_fund_rate        =>NULL,
      x_gov_initiatives_cd       =>NULL,
      x_units_for_qual           =>NULL,
      x_disadv_uplift_elig_cd    =>NULL,
      x_franch_partner_cd        =>NULL,
      x_units_completed          =>NULL,
      x_franch_out_arr_cd        =>NULL,
      x_employer_role_cd         =>NULL,
      x_disadv_uplift_factor     =>NULL,
      x_enh_fund_elig_cd         =>NULL,
      x_exclude_flag             =>NULL);

END;

EXCEPTION
  WHEN OTHERS THEN
    p_status :=2;
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_HESA_PKG.cr_he_st_spa_rec');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;

END cr_he_st_spa_rec;


BEGIN

p_status := 0;

-- Check Parameter values passed in correctly

IF p_person_id IS NULL or
   p_course_cd IS NULL or
   p_crv_version_number IS NULL
THEN
   p_status :=2;
   p_message := 'IGS_HE_INV_PARAMS';
   RETURN;
END IF;


-- if record not found in table then insert new record else update existing record

OPEN gc_stats_rec;
FETCH gc_stats_rec INTO gv_stats_rec;
IF gc_stats_rec%NOTFOUND THEN
  cr_he_st_spa_rec(p_person_id,p_course_cd,p_crv_version_number);
END IF;
CLOSE gc_stats_rec;

EXCEPTION

WHEN OTHERS THEN
   P_STATUS :=2;
   FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_HESA_PKG.HESA_STATS_ENR');
   IGS_GE_MSG_STACK.ADD;
   app_exception.raise_exception;
END hesa_stats_enr;


PROCEDURE hesa_susa_enr(
       p_person_id IN NUMBER,
       p_course_cd IN VARCHAR2,
       p_crv_version_number IN NUMBER,
       p_old_unit_set_cd IN VARCHAR2,
       p_old_us_version_number IN NUMBER,
       p_old_sequence_number IN NUMBER ,
       p_new_unit_set_cd IN VARCHAR2,
       p_new_us_version_number IN NUMBER,
       p_new_sequence_number IN NUMBER,
       p_message OUT NOCOPY VARCHAR2,
       p_status OUT NOCOPY NUMBER)
-- smaddali 14-may-2002 added new parameter p_old_sequence_number and
--renamed p_sequence_number to p_new_sequence_number for bug#2350629
-- smaddali 8-jan-2004   Bug#3291399 , modified logic for copying field values
AS
     -- gv_old_susa_rec IGS_HE_EN_SUSA%ROWTYPE;
     --gv_new_susa_rec IGS_HE_EN_SUSA%ROWTYPE;
      gv_old_fte_rec igs_he_poous.fte_intensity%TYPE;
      gv_new_fte_rec igs_he_poous.fte_intensity%TYPE;
      gv_old_fte_rec_type igs_he_poous.fte_calc_type%TYPE;
      gv_new_fte_rec_type igs_he_poous.fte_calc_type%TYPE;
      gv_old_franchising_rec igs_he_poous.franchising_activity%TYPE;
      gv_new_franchising_rec igs_he_poous.franchising_activity%TYPE;
      gv_old_fee_rec igs_he_poous.fee_band%TYPE;
      gv_new_fee_rec igs_he_poous.fee_band%TYPE;

CURSOR gc_old_susa_rec IS
  SELECT hesa_en_susa_id,
         person_id,
         course_cd,
         unit_set_cd,
         us_version_number,
         sequence_number,
         new_he_entrant_cd,
         term_time_accom,
         disability_allow,
         additional_sup_band,
         sldd_discrete_prov,
         study_mode,
         study_location,
         fte_perc_override,
         franchising_activity,
         completion_status,
         good_stand_marker,
         complete_pyr_study_cd,
         credit_value_yop1,
         credit_value_yop2,
         credit_level1,
         credit_level2,
         grad_sch_grade,
         mark,
         teaching_inst1,
         teaching_inst2,
         pro_not_taught,
         fundability_code,
         fee_eligibility,
         fee_band,
         non_payment_reason,
         student_fee,
         fte_intensity,
         fte_calc_type,
         calculated_fte,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login ,
         type_of_year
FROM igs_he_en_susa
WHERE person_id = p_person_id
AND course_cd = p_course_cd
AND unit_set_cd = p_old_unit_set_cd
AND us_version_number = p_old_us_version_number
-- smaddali modified p_sequence_number to p_old_sequence_number for bug#2350629
AND sequence_number = p_old_sequence_number;


CURSOR gc_new_susa_rec IS
 SELECT hesa_en_susa_id,
        person_id,
         course_cd,
         unit_set_cd,
         us_version_number,
         sequence_number,
         new_he_entrant_cd,
         term_time_accom,
         disability_allow,
         additional_sup_band,
         sldd_discrete_prov,
         study_mode,
         study_location,
         fte_perc_override,
         franchising_activity,
         completion_status,
         good_stand_marker,
         complete_pyr_study_cd,
         credit_value_yop1,
         credit_value_yop2,
         credit_level1,
         credit_level2,
         grad_sch_grade,
         mark,
         teaching_inst1,
         teaching_inst2,
         pro_not_taught,
         fundability_code,
         fee_eligibility,
         fee_band,
         non_payment_reason,
         student_fee,
         fte_intensity,
         calculated_fte,
         fte_calc_type,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login ,
         type_of_year
FROM igs_he_en_susa
WHERE person_id = p_person_id
AND course_cd = p_course_cd
AND unit_set_cd = p_new_unit_set_cd
AND us_version_number = p_new_us_version_number
-- smaddali modified p_sequence_number to p_new_sequence_number for bug#2350629
AND sequence_number = p_new_sequence_number;

--smaddali  modified the join conditions because they are resulting in a cartesian product (bug#2350629)
CURSOR gc_old_poo is
 SELECT a.fte_intensity fte_intensity,
        a.fte_calc_type fte_calc_type,
        a.franchising_activity franchising_activity,
        a.fee_band fee_band,
        a.type_of_year,
        a.fundability_cd
 FROM igs_he_poous a,
      igs_en_stdnt_ps_att b
 WHERE a.course_cd = p_course_cd
 AND   a.crv_version_number = p_crv_version_number
 AND   a.unit_set_cd = p_old_unit_set_cd
 AND   a.us_version_number = p_old_us_version_number
 AND   b.person_id = p_person_id
 AND   b.course_cd = a.course_cd
 AND   b.version_number = a.crv_version_number
 AND   a.cal_type = b.cal_type
 AND   a.location_cd = b.location_cd
 AND   a.attendance_mode = b.attendance_mode
 AND   a.attendance_type = b.attendance_type;
 gc_old_poo_rec gc_old_poo%ROWTYPE;

--smaddali  modified the join conditions because they are resulting in a cartesian product (bug#2350629)
CURSOR gc_new_poo IS
  SELECT a.fte_intensity fte_intensity,
         a.fte_calc_type fte_calc_type,
         a.franchising_activity franchising_activity,
         a.fee_band fee_band,
         a.type_of_year,
         a.fundability_cd
  FROM  igs_he_poous a,
      igs_en_stdnt_ps_att b
  WHERE a.course_cd = p_course_cd
  AND a.crv_version_number = p_crv_version_number
  AND a.unit_set_cd = p_new_unit_set_cd
  AND a.us_version_number = p_new_us_version_number
  AND b.person_id = p_person_id
  AND b.course_cd = a.course_cd
  AND b.version_number = a.crv_version_number
  AND a.cal_type = b.cal_type
  AND a.location_cd = b.location_cd
  AND a.attendance_mode = b.attendance_mode
  AND a.attendance_type = b.attendance_type;
  gc_new_poo_rec  gc_new_poo%ROWTYPE;

  gv_old_susa_rec gc_old_susa_rec%ROWTYPE;
  gv_new_susa_rec gc_new_susa_rec%ROWTYPE;

 --Procedure to create a new record on first pre-enrolment
--smaddali  modified p_sequence_number to p_new_sequence_number (bug#2350629)
PROCEDURE cr_he_new_susa_rec(p_person_id igs_he_en_susa.person_id%TYPE,
                             p_course_cd igs_he_en_susa.course_cd%TYPE,
                             p_new_unit_set_cd igs_he_en_susa.unit_set_cd%TYPE,
                             p_new_us_version_number igs_he_en_susa.us_version_number%TYPE,
                             p_new_sequence_number igs_he_en_susa.sequence_number%TYPE) IS

BEGIN

DECLARE

  v_susa_seq_num igs_he_en_susa.hesa_en_susa_id%TYPE;

  CURSOR c_susa_seq_num IS
   SELECT igs_he_en_susa_s.NEXTVAL
   FROM dual;

  v_rowid VARCHAR2(250);

BEGIN

  OPEN c_susa_seq_num;
  FETCH c_susa_seq_num INTO v_susa_seq_num;
  CLOSE c_susa_seq_num;

  v_rowid := NULL;

igs_he_en_susa_pkg.insert_row(
     x_rowid                 => v_rowid,
     x_hesa_en_susa_id       => v_susa_seq_num,
     x_person_id             => p_person_id,
     x_course_cd             => p_course_cd,
     x_unit_set_cd           => p_new_unit_set_cd,
     x_us_version_number     => p_new_us_version_number,
     x_sequence_number       => p_new_sequence_number,
     x_new_he_entrant_cd     => NULL,
     x_term_time_accom       => NULL,
     x_disability_allow      => NULL,
     x_additional_sup_band   => NULL,
     x_sldd_discrete_prov    => NULL,
     x_study_mode            => NULL,
     x_study_location        => NULL,
     x_fte_perc_override     => NULL,
     x_franchising_activity  => NULL,
     x_completion_status     => NULL,
     x_good_stand_marker     => NULL,
     x_complete_pyr_study_cd => NULL,
     x_credit_value_yop1     => NULL,
     x_credit_value_yop2     => NULL,
     x_credit_level_achieved1 => NULL,
     x_credit_level_achieved2 => NULL,
     x_credit_pt_achieved1   => NULL,
     x_credit_pt_achieved2   => NULL,
     x_credit_level1         => NULL,
     x_credit_level2         => NULL,
     x_grad_sch_grade        => NULL,
     x_mark                  => NULL,
     x_teaching_inst1        => NULL,
     x_teaching_inst2        => NULL,
     x_pro_not_taught        => NULL,
     x_fundability_code      => NULL,
     x_fee_eligibility       => NULL,
     x_fee_band              => NULL,
     x_non_payment_reason    => NULL,
     x_student_fee           => NULL,
     x_fte_intensity         => NULL,
     x_fte_calc_type         => NULL,
     x_calculated_fte        => NULL,
     x_type_of_year          => NULL,
     x_mode                  => 'R',
     x_credit_value_yop3      => NULL,
     x_credit_value_yop4      => NULL,
     x_credit_level_achieved3 => NULL,
     x_credit_level_achieved4 => NULL,
     x_credit_pt_achieved3    => NULL,
     x_credit_pt_achieved4    => NULL,
     x_credit_level3          => NULL,
     x_credit_level4          => NULL,
     x_additional_sup_cost   => NULL,
     x_enh_fund_elig_cd       => NULL,
     x_disadv_uplift_factor   => NULL,
     x_year_stu               => NULL);

END;

EXCEPTION

WHEN OTHERS THEN
  P_STATUS := 2;
  FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_HESA_PKG.CR_HE_NEW_SUSA_REC');
  IGS_GE_MSG_STACK.ADD;
  app_exception.raise_exception;

END cr_he_new_susa_rec;

--smaddali  modified p_sequence_number to p_new_sequence_number (bug#2350629)
PROCEDURE cr_he_add_susa_rec(p_person_id igs_he_en_susa.person_id%TYPE,
                             p_course_cd igs_he_en_susa.course_cd%TYPE,
                             p_old_unit_set_cd igs_he_en_susa.unit_set_cd%TYPE,
                             p_old_us_version_number igs_he_en_susa.us_version_number%TYPE,
                             p_new_unit_set_cd igs_he_en_susa.unit_set_cd%TYPE,
                             p_new_us_version_number igs_he_en_susa.us_version_number%TYPE,
                             p_new_sequence_number igs_he_en_susa.sequence_number%TYPE) IS

BEGIN

DECLARE

v_susa_seq_num          igs_he_en_susa.hesa_en_susa_id%TYPE;

CURSOR c_susa_seq_num IS
 SELECT igs_he_en_susa_s.NEXTVAL
 FROM dual;

x_rowid                 VARCHAR2(250);

v_old_franchising       igs_he_poous.franchising_activity%TYPE;
v_new_franchising       igs_he_poous.franchising_activity%TYPE;
v_franchising           igs_he_en_susa.franchising_activity%TYPE;

v_old_fte               igs_he_poous.fte_intensity%TYPE;
v_new_fte               igs_he_poous.fte_intensity%TYPE;
v_fte                   igs_he_en_susa.fte_intensity%TYPE;

v_old_fee_band          igs_he_poous.fee_band%TYPE;
v_new_fee_band          igs_he_poous.fee_band%TYPE;
v_fee_band              igs_he_en_susa.fee_band%TYPE;

v_old_fte_type          igs_he_poous.fte_calc_type%TYPE;
v_new_fte_type          igs_he_poous.fte_calc_type%TYPE;
v_fte_type              igs_he_en_susa.fte_calc_type%TYPE;
-- smaddali added variables for bug#
l_fundability_code      igs_he_en_susa.fundability_code%TYPE;
l_type_of_year          igs_he_en_susa.type_of_year%TYPE ;
BEGIN

OPEN c_susa_seq_num;
FETCH c_susa_seq_num INTO v_susa_seq_num;
CLOSE c_susa_seq_num;

gc_old_poo_rec          := NULL;
OPEN gc_old_poo;
FETCH gc_old_poo INTO gc_old_poo_rec;
CLOSE gc_old_poo;
gc_new_poo_rec          := NULL ;
OPEN gc_new_poo;
FETCH gc_new_poo INTO gc_new_poo_rec ;
CLOSE gc_new_poo;

-- smaddali added the condition to copy field when both old and new poous values are null
-- for the fields franchising_activity,fte_intensity and fee_band, bug#3291399
IF ( gc_old_poo_rec.franchising_activity IS NULL AND gc_new_poo_rec.franchising_activity IS NULL ) OR
   (gc_old_poo_rec.franchising_activity = gc_new_poo_rec.franchising_activity) THEN
  v_franchising := gv_old_susa_rec.franchising_activity;
ELSE
  v_franchising := NULL;
END IF;

IF ( gc_old_poo_rec.fte_intensity IS NULL AND gc_new_poo_rec.fte_intensity IS NULL  ) OR
   (gc_old_poo_rec.fte_intensity = gc_new_poo_rec.fte_intensity) THEN
  v_fte := gv_old_susa_rec.fte_intensity;
ELSE
  v_fte := NULL;
END IF;

IF ( gc_old_poo_rec.fee_band IS NULL AND gc_new_poo_rec.fee_band IS NULL ) OR
   (gc_old_poo_rec.fee_band = gc_new_poo_rec.fee_band) THEN
  v_fee_band := gv_old_susa_rec.fee_band;
ELSE
  v_fee_band := NULL;
END IF;

-- smaddali added code to copy fundability_code and type_of_year conditionally for bug#3291399
-- copy fte_calc_type and type_of_year if poous.type_of_year is same or null for both programs
IF (gc_old_poo_rec.type_of_year IS NULL AND gc_new_poo_rec.type_of_year IS NULL) OR
   (gc_old_poo_rec.type_of_year = gc_new_poo_rec.type_of_year) THEN
  v_fte_type := gv_old_susa_rec.fte_calc_type;
  l_type_of_year        := gv_old_susa_rec.type_of_year;
ELSE
  v_fte_type            := NULL;
  l_type_of_year        := NULL ;
END IF;

-- copy fundability_code if poous.fundability_code is same or is null for both poous
IF (   gc_old_poo_rec.fundability_cd IS NULL AND gc_new_poo_rec.fundability_cd IS NULL ) OR
   (gc_old_poo_rec.fundability_cd = gc_new_poo_rec.fundability_cd) THEN
  l_fundability_code    := gv_old_susa_rec.fundability_code;
ELSE
  l_fundability_code    := NULL;
END IF;


x_rowid := NULL;
-- smaddali removed copying of x_credit_level_achieved1,x_credit_level_achieved2,
-- x_credit_pt_achieved1 and x_credit_pt_achieved2,fundability_code,calculated_fte
-- copying fundability_code and type_of_year conditionally for bug#3291399
igs_he_en_susa_pkg.insert_row(
    x_rowid                  => x_rowid,
    x_hesa_en_susa_id        => v_susa_seq_num,
    x_person_id              => p_person_id,
    x_course_cd              => p_course_cd,
    x_unit_set_cd            => p_new_unit_set_cd,
    x_us_version_number      => p_new_us_version_number,
    x_sequence_number        => p_new_sequence_number,
    x_new_he_entrant_cd      => NULL,
    x_term_time_accom        => NULL,
    x_disability_allow       => gv_old_susa_rec.disability_allow,
    x_additional_sup_band    => gv_old_susa_rec.additional_sup_band,
    x_sldd_discrete_prov     => gv_old_susa_rec.sldd_discrete_prov,
    x_study_mode             => NULL,
    x_study_location         => NULL,
    x_fte_perc_override      => NULL,
    x_franchising_activity   => v_franchising,
    x_completion_status      => NULL,
    x_good_stand_marker      => NULL,
    x_complete_pyr_study_cd  => NULL,
    x_grad_sch_grade         => NULL,
    x_mark                   => NULL,
    x_credit_value_yop1      => NULL,
    x_credit_value_yop2      => NULL,
    x_credit_level_achieved1 => NULL,
    x_credit_level_achieved2 => NULL,
    x_credit_pt_achieved1    => NULL,
    x_credit_pt_achieved2    => NULL,
    x_credit_level1          => NULL,
    x_credit_level2          => NULL,
    x_teaching_inst1         => NULL,
    x_teaching_inst2         => NULL,
    x_pro_not_taught         => NULL,
    x_fundability_code       => l_fundability_code,
    x_fee_eligibility        => gv_old_susa_rec.fee_eligibility,
    x_fee_band               => v_fee_band,
    x_non_payment_reason     => NULL,
    x_student_fee            => gv_old_susa_rec.student_fee,
    x_fte_intensity          => v_fte,
    x_calculated_fte         => NULL,
    x_fte_calc_type          => v_fte_type,
    x_type_of_year           => l_type_of_year,
    x_mode                   => 'R',
    x_credit_value_yop3      => NULL,
    x_credit_value_yop4      => NULL,
    x_credit_level_achieved3 => NULL,
    x_credit_level_achieved4 => NULL,
    x_credit_pt_achieved3    => NULL,
    x_credit_pt_achieved4    => NULL,
    x_credit_level3          => NULL,
    x_credit_level4          => NULL,
    x_additional_sup_cost   => NULL,
    x_enh_fund_elig_cd       => NULL,
    x_disadv_uplift_factor   => NULL,
    x_year_stu               => NULL);
END;

EXCEPTION
 WHEN OTHERS THEN
   P_STATUS :=2;
   FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_HESA_PKG.CR_HE_ADD_SUSA_REC');
   IGS_GE_MSG_STACK.ADD;
   app_exception.raise_exception;

END cr_he_add_susa_rec;



BEGIN

  p_status := 0;

  -- Check Parameter values passed in correctly

  IF p_person_id IS NULL OR
     p_course_cd IS NULL OR
     p_new_unit_set_cd IS NULL OR
     p_new_us_version_number IS NULL OR
     p_new_sequence_number is NULL
  THEN
     p_status := 2;
     p_message := 'IGS_HE_INV_PARAMS';
     RETURN;
  END IF;


  -- If no record exists in IGS_HE_ENS_SUSA table then create new record
  -- else if record exists then add new record and copy some fields
  -- from previous SUSA record

  OPEN gc_new_susa_rec;
  FETCH gc_new_susa_rec INTO gv_new_susa_rec;
  IF gc_new_susa_rec%NOTFOUND THEN


    OPEN gc_old_susa_rec;
    FETCH gc_old_susa_rec INTO gv_old_susa_rec;
    IF gc_old_susa_rec%NOTFOUND THEN
       cr_he_new_susa_rec(p_person_id,
                    p_course_cd,
                    p_new_unit_set_cd,
                    p_new_us_version_number,
                    p_new_sequence_number); --smaddali  modified p_sequence_number to p_new_sequence_number (bug#2350629)

    ELSE

      IF p_old_unit_set_cd IS NULL or
         p_old_us_version_number IS NULL THEN

         p_status := 2;
         p_message := 'IGS_HE_PCPY_INV_PARAMS';
         app_exception.raise_exception;
         RETURN;
      END IF;


      cr_he_add_susa_rec(p_person_id,
                    p_course_cd,
                    p_old_unit_set_cd,
                    p_old_us_version_number,
                    p_new_unit_set_cd,
                    p_new_us_version_number,
                    p_new_sequence_number); --smaddali  modified p_sequence_number to p_new_sequence_number (bug#2350629)

    END IF;

    CLOSE gc_old_susa_rec;

  END IF;

  CLOSE gc_new_susa_rec;

EXCEPTION
 WHEN OTHERS THEN
  p_status := 2;
  FND_MESSAGE.SET_NAME('IGS','IGS_UNHANDLED_EXCEPTION');
  FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_HESA_PKG.HESA_SUSA_ENR');
  IGS_GE_MSG_STACK.ADD;
  app_exception.raise_exception;

END hesa_susa_enr;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: Function to validate whether the given award code exists
--         against system award type COURSE
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--pmarada   13-feb-03     Modified the cur_award_cd cursor where clause,
--                        added the closed_ind condition, bug 2801518
------------------------------------------------------------------  */
FUNCTION validate_program_aim(
    p_award_cd IN VARCHAR2)
RETURN BOOLEAN AS
--
-- cursor to check whether the given award code exists against system award type COURSE
CURSOR cur_award_cd IS
SELECT 'x'
FROM igs_ps_awd
WHERE s_award_type = 'COURSE' AND
      award_cd = p_award_cd AND
      closed_ind = 'N';

l_dummy varchar2(1);

BEGIN

  IF p_award_cd IS NOT NULL THEN
     OPEN cur_award_cd;
     FETCH cur_award_cd INTO l_dummy;
     IF cur_award_cd%NOTFOUND THEN
       CLOSE cur_award_cd;
       RETURN FALSE;
     END IF;
     CLOSE cur_award_cd;
  END IF;

  RETURN TRUE;
END validate_program_aim;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: function to validate whether the specified combination of subj_qualaim's and qualaim_proportion is valid
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */

FUNCTION val_sub_qual_proportion(
    p_subj_qualaim1 IN VARCHAR2,
    p_subj_qualaim2 IN VARCHAR2,
    p_subj_qualaim3 IN VARCHAR2,
    p_qualaim_proportion IN VARCHAR2)
RETURN BOOLEAN AS
l_val_failed BOOLEAN := FALSE;
BEGIN

   IF p_subj_qualaim1 IS NULL AND p_subj_qualaim2 IS NOT NULL THEN
        l_val_failed := TRUE;
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_SUBQ2_IF_SUBQ1');
        FND_MSG_PUB.ADD;
   END IF;

   IF p_subj_qualaim2 IS NULL AND p_subj_qualaim3 IS NOT NULL THEN
        l_val_failed := TRUE;
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_SUBQ3_IF_SUBQ2');
        FND_MSG_PUB.ADD;
   END IF;

   IF p_subj_qualaim1 IS NOT NULL AND p_subj_qualaim2 IS NOT NULL AND
      p_subj_qualaim3 IS NULL AND p_qualaim_proportion IS NULL THEN
        l_val_failed := TRUE;
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_QUAL_PROP_MUST_COMP');
        FND_MSG_PUB.ADD;
   END IF;

   IF p_subj_qualaim3 IS NOT NULL AND p_qualaim_proportion IS NOT NULL THEN
        l_val_failed := TRUE;
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_QUAL_PROP_CANT_SET');
        FND_MSG_PUB.ADD;
   END IF;

   IF ((p_subj_qualaim1 IS NULL AND (p_subj_qualaim2 IS NOT NULL OR p_subj_qualaim3 IS NOT NULL OR p_qualaim_proportion IS NOT NULL))  OR
       (p_subj_qualaim2 IS NULL AND (p_subj_qualaim3 IS NOT NULL OR p_qualaim_proportion IS NOT NULL)) OR
       (p_subj_qualaim3 IS NULL AND p_qualaim_proportion IS NULL AND (p_subj_qualaim1 IS NOT NULL AND p_subj_qualaim2 IS NOT NULL )) OR
       (p_subj_qualaim1 IS NOT NULL AND p_subj_qualaim2 IS NOT NULL AND p_subj_qualaim3 IS NOT NULL AND p_qualaim_proportion IS NOT NULL)) THEN
          l_val_failed := TRUE;
          FND_MESSAGE.SET_NAME('IGS','IGS_HE_SUBQ_INVALID_SET');
          FND_MSG_PUB.ADD;
   END IF;

   IF l_val_failed THEN
      RETURN FALSE;
   END IF;
   RETURN TRUE;

END val_sub_qual_proportion;


/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: function to check whether the given highest qual on entry is exists against the
--         grading schema defined for HESA code HESA_HIGH_QUAL_ON_ENT.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION val_highest_qual_entry(
    p_highest_qual_on_entry IN VARCHAR2)
RETURN BOOLEAN AS

--
-- cursor to check whether the given grade exists against the grading schema defined for HESA code HESA_HIGH_QUAL_ON_ENT.
-- smaddali added condition to get only open code values for bug 2730388
CURSOR cur_hqual_grade IS
SELECT 'x'
FROM igs_as_grd_sch_grade gsg,
     igs_he_code_values hcv
WHERE gsg.grading_schema_cd = hcv.value AND
      hcv.code_type = 'HESA_HIGH_QUAL_ON_ENT' AND
      gsg.grade = p_highest_qual_on_entry AND
      NVL(hcv.closed_ind,'N') = 'N' ;

l_dummy VARCHAR2(1);
BEGIN
  IF p_highest_qual_on_entry IS NOT NULL THEN
     OPEN cur_hqual_grade;
     FETCH cur_hqual_grade INTO l_dummy;
     IF cur_hqual_grade%NOTFOUND THEN
       CLOSE cur_hqual_grade;
       RETURN FALSE;
     END IF;
     CLOSE cur_hqual_grade;
  END IF;

  RETURN TRUE;

END val_highest_qual_entry;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: function to get the unit set category for the given unit set
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION get_unit_set_cat(
    p_unit_set_cd IN VARCHAR2,
    p_us_version_number IN NUMBER)
RETURN VARCHAR2 AS

--
-- cursor to get the unit set category.
CURSOR cur_us_cat IS
SELECT usc.s_unit_set_cat
FROM igs_en_unit_set us,
     igs_en_unit_set_cat usc
WHERE us.unit_set_cd = p_unit_set_cd AND
      us.version_number = p_us_version_number AND
      us.unit_set_cat = usc.unit_set_cat;

l_us_category igs_en_unit_set_cat.s_unit_set_cat%TYPE;

BEGIN

   l_us_category := NULL;
   IF p_unit_set_cd IS NOT NULL AND p_us_version_number IS NOT NULL THEN
      OPEN cur_us_cat;
      FETCH cur_us_cat INTO l_us_category;
      CLOSE cur_us_cat;
   END IF;
   RETURN l_us_category;
END get_unit_set_cat;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: function to check whether the given institution exists with institution type Post-Secondary
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION check_teach_inst(
    p_teaching_inst IN VARCHAR2)
RETURN BOOLEAN AS
--
-- cursor to check whether the given teaching institution is exists as POST SECONDARY institution type.
CURSOR cur_tech_inst IS
SELECT 'x'
FROM igs_or_inst_outer_v
WHERE institution_cd = p_teaching_inst AND
      system_inst_type='POST-SECONDARY';

l_dummy VARCHAR2(1);
BEGIN

  IF p_teaching_inst IS NOT NULL THEN
     OPEN cur_tech_inst;
     FETCH cur_tech_inst INTO l_dummy;
     IF cur_tech_inst%NOTFOUND THEN
       CLOSE cur_tech_inst;
       RETURN FALSE;
     END IF;
     CLOSE cur_tech_inst;
  END IF;
  RETURN TRUE;
END check_teach_inst;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: function to check whether the given grade is exists against the grading schema defined in Unit set statistics.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION check_grading_sch_grade(
    p_person_id IN NUMBER,
    p_program_cd IN VARCHAR2,
    p_unit_set_cd IN VARCHAR2,
    p_grad_sch_grade IN VARCHAR2)
RETURN BOOLEAN AS
--
-- cursor to check whether the given grade is exists against the grading schema defined in Unit set statistics.
CURSOR cur_grd_sch_grade IS
SELECT 'x'
FROM igs_as_grd_sch_grade gsg,
     igs_he_poous_all poous,
     igs_en_stdnt_ps_att sca,
     igs_as_su_setatmpt susa
WHERE gsg.grading_schema_cd = poous.grading_schema_cd AND
      gsg.version_number = poous.gs_version_number AND
      gsg.grade = p_grad_sch_grade AND
      poous.course_cd = sca.course_cd AND
      poous.crv_version_number = sca.version_number AND
      poous.cal_type = sca.cal_type AND
      poous.location_cd = sca.location_cd AND
      poous.attendance_mode = sca.attendance_mode AND
      poous.attendance_type = sca.attendance_type AND
      poous.unit_set_cd = susa.unit_set_cd AND
      poous.us_version_number = susa.us_version_number  AND
      sca.person_id = p_person_id AND
      sca.course_cd = p_program_cd AND
      susa.person_id= sca.person_id AND
      susa.course_cd = sca.course_cd AND
      susa.unit_set_cd = p_unit_set_cd;

l_dummy VARCHAR2(1);
BEGIN

  IF p_grad_sch_grade IS NOT NULL THEN
     IF p_person_id IS NULL OR p_program_cd IS NULL OR p_unit_set_cd IS NULL THEN
        RETURN FALSE;
     END IF;
     OPEN cur_grd_sch_grade;
     FETCH cur_grd_sch_grade INTO l_dummy;
     IF cur_grd_sch_grade%NOTFOUND THEN
        CLOSE cur_grd_sch_grade;
        RETURN FALSE;
     END IF;
     CLOSE cur_grd_sch_grade;
  END IF;
  RETURN TRUE;

END check_grading_sch_grade;

END igs_en_hesa_pkg;


/
