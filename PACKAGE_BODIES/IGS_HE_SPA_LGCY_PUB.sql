--------------------------------------------------------
--  DDL for Package Body IGS_HE_SPA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_SPA_LGCY_PUB" AS
/* $Header: IGSHE22B.pls 120.1 2006/02/07 14:53:56 jbaber noship $ */

-- capture the package name in global variable
g_pkg_name        CONSTANT VARCHAR2(30) := 'IGS_HE_SPA_LGCY_PUB';

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: Function to validate the mandatory parameters
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION validate_parameters(
         p_hesa_spa_stats_rec IN hesa_spa_rec_type)
RETURN BOOLEAN AS

l_ret_status BOOLEAN := TRUE;
BEGIN
   IF p_hesa_spa_stats_rec.person_number IS NULL THEN
        l_ret_status := FALSE;
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PER_NUM_NULL');
        FND_MSG_PUB.ADD;
   END IF;
   IF p_hesa_spa_stats_rec.program_cd IS NULL THEN
        l_ret_status := FALSE;
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_NULL');
        FND_MSG_PUB.ADD;
   END IF;
   IF p_hesa_spa_stats_rec.student_inst_number IS NULL THEN
        l_ret_status := FALSE;
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_STD_INST_NUM_MAND');
        FND_MSG_PUB.ADD;
   END IF;

   RETURN l_ret_status;
END validate_parameters;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: Function to validate the data base constraints like
--         primary key, unique key, foreign key and check constraints.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--jtmathew    21-Sep-2004        Added validation for the new fields
--                               described in HEFD350.
------------------------------------------------------------------  */
FUNCTION validate_db_cons(
         p_person_id IN hz_parties.party_id%TYPE,
         p_version_number IN igs_en_stdnt_ps_att.version_number%TYPE,
         p_hesa_spa_stats_rec IN hesa_spa_rec_type)
RETURN VARCHAR2 AS

 l_msg_count NUMBER;
 l_msg_data  VARCHAR2(4000);
 l_db_val_failed BOOLEAN := FALSE;
BEGIN

   -- Check whether Hesa program statistics details already exists for the given program attempt
   IF igs_he_st_spa_all_pkg.get_uk_for_validation(x_person_id => p_person_id,
                                                  x_course_cd => p_hesa_spa_stats_rec.program_cd) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_SPA_STATS_EXIST');
        FND_MSG_PUB.ADD;
        RETURN 'W';
   END IF;

   -- start of Foreign Key validations
   --
   -- Check whether the program attempt exists
   IF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation(x_person_id => p_person_id,
                                                        x_course_cd => p_hesa_spa_stats_rec.program_cd) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_EXT_SPA_DTL_NOT_FOUND');
        FND_MSG_PUB.ADD;
        l_db_val_failed := TRUE;
   END IF;
   -- Check whether the Domicile code exists
   IF p_hesa_spa_stats_rec.domicile_cd IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_DOM',
                                                           x_value => p_hesa_spa_stats_rec.domicile_cd) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_DOM_CD_NOT_EXIST');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;

   -- Check whether the Occupation Code exists
   IF p_hesa_spa_stats_rec.occupation_code IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_OCC',
                                                           x_value => p_hesa_spa_stats_rec.occupation_code) THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_HE_OCCUP_CD_NOT_EXIST');
          FND_MSG_PUB.ADD;
          l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Teaching training program ID exists
   IF p_hesa_spa_stats_rec.teacher_train_prog_id IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_TTCID',
                                                           x_value => p_hesa_spa_stats_rec.teacher_train_prog_id) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_TEACH_TRNPRG_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the ITT Phase exists
   IF p_hesa_spa_stats_rec.itt_phase IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_ITTPHSC',
                                                           x_value => p_hesa_spa_stats_rec.itt_phase) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_ITT_PHASE_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Bilingual ITT marker exists
   IF p_hesa_spa_stats_rec.bilingual_itt_marker IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_BITTM',
                                                           x_value => p_hesa_spa_stats_rec.bilingual_itt_marker) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_BILINGUAL_ITT_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Teaching Qualification Gain Sector exists
   IF p_hesa_spa_stats_rec.teaching_qual_gain_sector IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_TQSEC',
                                                           x_value => p_hesa_spa_stats_rec.teaching_qual_gain_sector) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_TCH_QUAL_GSEC_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Teaching Qualification Gain subject 1 exists
   IF p_hesa_spa_stats_rec.teaching_qual_gain_subj1 IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_TQSUB123',
                                                           x_value => p_hesa_spa_stats_rec.teaching_qual_gain_subj1) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_TCH_QUAL_SUB1_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Teaching Qualification Gain subject 2 exists
   IF p_hesa_spa_stats_rec.teaching_qual_gain_subj2 IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_TQSUB123',
                                                           x_value => p_hesa_spa_stats_rec.teaching_qual_gain_subj2) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_TCH_QUAL_SUB2_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Teaching Qualification Gain subject 3 exists
   IF p_hesa_spa_stats_rec.teaching_qual_gain_subj3 IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_TQSUB123',
                                                           x_value => p_hesa_spa_stats_rec.teaching_qual_gain_subj3) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_TCH_QUAL_SUB3_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Destination exists
   IF p_hesa_spa_stats_rec.destination IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_DEST',
                                                           x_value => p_hesa_spa_stats_rec.destination) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_DESTINATION_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the ITT Program Outcome exists
   IF p_hesa_spa_stats_rec.itt_prog_outcome IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_OUTCOME',
                                                           x_value => p_hesa_spa_stats_rec.itt_prog_outcome) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_ITT_PRG_OC_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the NHS Funding Source exists
   IF p_hesa_spa_stats_rec.nhs_funding_source IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_NHS_FUSRC',
                                                           x_value => p_hesa_spa_stats_rec.nhs_funding_source) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_NHS_FUND_SRC_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the UFI Place exists
   IF p_hesa_spa_stats_rec.ufi_place IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_UFI_PLACE',
                                                           x_value => p_hesa_spa_stats_rec.ufi_place) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_UFI_PLACE_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Social Class Indicator exists
   IF p_hesa_spa_stats_rec.social_class_ind IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_SOC',
                                                           x_value => p_hesa_spa_stats_rec.social_class_ind) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_SOCIAL_CLS_IND_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the NHS Employer exists
   IF p_hesa_spa_stats_rec.nhs_employer IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_NHS_EMPLOYER',
                                                           x_value => p_hesa_spa_stats_rec.nhs_employer) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_NHS_EMP_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Return Type exists
   IF p_hesa_spa_stats_rec.return_type IS NOT NULL THEN
      IF NOT igs_lookups_view_pkg.get_pk_for_validation (x_lookup_type => 'IGS_HE_RED_RTN',
                                                         x_lookup_code => p_hesa_spa_stats_rec.return_type) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_RET_TYPE_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Student Qualification Aim exists
   IF p_hesa_spa_stats_rec.student_qual_aim IS NOT NULL THEN
      IF NOT igs_en_hesa_pkg.validate_program_aim (p_award_cd => p_hesa_spa_stats_rec.student_qual_aim) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_STD_PRG_AIM_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Student FE Qualification Aim exists
   IF p_hesa_spa_stats_rec.student_fe_qual_aim IS NOT NULL THEN
      IF NOT igs_en_hesa_pkg.validate_program_aim (p_award_cd => p_hesa_spa_stats_rec.student_fe_qual_aim) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_STD_FE_PRG_AIM_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Subject Qualification Aim 1 exists
   IF p_hesa_spa_stats_rec.subj_qualaim1 IS NOT NULL THEN
      IF NOT igs_ps_fld_of_study_pkg.Get_Pk_For_Validation ( x_field_of_study => p_hesa_spa_stats_rec.subj_qualaim1) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_SUBQ1_FS_INVALID');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;

   -- Check whether the Subject Qualification Aim 2 exists
   IF p_hesa_spa_stats_rec.subj_qualaim2 IS NOT NULL THEN
      IF NOT igs_ps_fld_of_study_pkg.Get_Pk_For_Validation ( x_field_of_study => p_hesa_spa_stats_rec.subj_qualaim2) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_SUBQ2_FS_INVALID');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Subject Qualification Aim 3 exists
   IF p_hesa_spa_stats_rec.subj_qualaim3 IS NOT NULL THEN
      IF NOT igs_ps_fld_of_study_pkg.Get_Pk_For_Validation ( x_field_of_study => p_hesa_spa_stats_rec.subj_qualaim3) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_SUBQ3_FS_INVALID');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;

   -- Check whether the Qualification Aim Proportion exists
   IF p_hesa_spa_stats_rec.qualaim_proportion IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_PROPORTION',
                                                           x_value => p_hesa_spa_stats_rec.qualaim_proportion) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_QUAL_PROP_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the Special Student exists
   IF p_hesa_spa_stats_rec.special_student IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_SPEC_STUD',
                                                           x_value => p_hesa_spa_stats_rec.special_student) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_SPEC_STUD_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;
   -- Check whether the FE Student Marker exists
   IF p_hesa_spa_stats_rec.fe_student_marker IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type => 'OSS_FESTUMK',
                                                           x_value => p_hesa_spa_stats_rec.fe_student_marker) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_HE_FE_STUD_MARKER_NEX');
         FND_MSG_PUB.ADD;
         l_db_val_failed := TRUE;
      END IF;
   END IF;

   -- Check whether the Dependants Code exists
   IF p_hesa_spa_stats_rec.dependants_cd IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation(x_code_type => 'OSS_DEPEND',
                                                          x_value => p_hesa_spa_stats_rec.dependants_cd) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_HE_DEP_CD_NEX');
      FND_MSG_PUB.ADD;
      l_db_val_failed := TRUE;
      END IF;
   END IF;

   -- Check whether the Government Initiatives Code exists
   IF p_hesa_spa_stats_rec.gov_initiatives_cd IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation(x_code_type => 'OSS_GOVINIT',
                                                          x_value => p_hesa_spa_stats_rec.gov_initiatives_cd) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_HE_GOV_INIT_NEX');
      FND_MSG_PUB.ADD;
      l_db_val_failed := TRUE;
      END IF;
   END IF;

   -- Check whether Eligibility for Disadvantage Uplift Indicator exists
   IF p_hesa_spa_stats_rec.disadv_uplift_elig_cd IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation(x_code_type => 'OSS_ELIDISUP',
                                                          x_value => p_hesa_spa_stats_rec.disadv_uplift_elig_cd) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_HE_ELIG_DIS_NEX');
      FND_MSG_PUB.ADD;
      l_db_val_failed := TRUE;
      END IF;
   END IF;

   -- Check whether Franchise Partner Indicator exists
   IF p_hesa_spa_stats_rec.franch_partner_cd IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation(x_code_type => 'OSS_FRANPART',
                                                          x_value => p_hesa_spa_stats_rec.franch_partner_cd) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_HE_FRAN_PART_NEX');
      FND_MSG_PUB.ADD;
      l_db_val_failed := TRUE;
      END IF;
   END IF;

   -- Check whether Franchised Out Arrangement Indicator exists
   IF p_hesa_spa_stats_rec.franch_out_arr_cd IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation(x_code_type => 'OSS_FROUTARR',
                                                          x_value => p_hesa_spa_stats_rec.franch_out_arr_cd) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_HE_FRAN_OUT_ARR_NEX');
      FND_MSG_PUB.ADD;
      l_db_val_failed := TRUE;
      END IF;
   END IF;

   -- Check whether Employer Role Code exists
   IF p_hesa_spa_stats_rec.employer_role_cd IS NOT NULL THEN
      IF NOT igs_he_code_values_pkg.get_pk_for_validation(x_code_type => 'OSS_EMPROLE',
                                                          x_value => p_hesa_spa_stats_rec.employer_role_cd) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_HE_EMP_ROLE_CD_NEX');
      FND_MSG_PUB.ADD;
      l_db_val_failed := TRUE;
      END IF;
   END IF;

   -- Check whether the Implied Rate of Council Partial Funding field is
   -- within the range 0 to 100 (inclusive)
   IF p_hesa_spa_stats_rec.implied_fund_rate IS NOT NULL THEN
       IF NOT p_hesa_spa_stats_rec.implied_fund_rate between 0 and 100 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_HE_IMP_RATE_INVALID');
       FND_MSG_PUB.ADD;
       l_db_val_failed := TRUE;
       END IF;
   END IF;

   -- Check whether the Number of Units To Achieve Full Qualification field is
   -- within the range 0 to 99 (inclusive)
   IF p_hesa_spa_stats_rec.units_for_qual IS NOT NULL THEN
      IF NOT p_hesa_spa_stats_rec.units_for_qual between 0 and 99 THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_HE_UNITS_QUAL_INVALID');
      FND_MSG_PUB.ADD;
      l_db_val_failed := TRUE;
      END IF;
   END IF;

   -- Check whether the Number of Units Completed field is within the range 0 to 99 (inclusive)
   IF p_hesa_spa_stats_rec.units_completed IS NOT NULL THEN
      IF NOT p_hesa_spa_stats_rec.units_completed between 0 and 99 THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_HE_UNITS_COMP_INVALID');
      FND_MSG_PUB.ADD;
      l_db_val_failed := TRUE;
      END IF;
   END IF;

    -- Check if the Eligibility for Enhanced Funding Indicator exists
    IF p_hesa_spa_stats_rec.enh_fund_elig_cd IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_ELIGENFD',
                                                             x_value        => p_hesa_spa_stats_rec.enh_fund_elig_cd) THEN
        -- ADD excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_ELIG_ENH_FUND_NEX');
        FND_MSG_PUB.ADD;
        l_db_val_failed := TRUE;
        END IF;
    END IF;

    -- Check whether the Disadvantage Uplift Factor field is within
    -- range 0.0000 to 9.9999 (inclusive)
    IF p_hesa_spa_stats_rec.disadv_uplift_factor IS NOT NULL THEN
       IF NOT p_hesa_spa_stats_rec.disadv_uplift_factor between 0.0000 and 9.9999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_HE_DIS_UPLIFT_FTR_INVALID');
       FND_MSG_PUB.ADD;
       l_db_val_failed := TRUE;
       END IF;
    END IF;

   -- Validating the check constraints
   --
   -- Check whether the Associate UCAS Number has valid value
   IF p_hesa_spa_stats_rec.associate_ucas_number IS NOT NULL THEN
      BEGIN
         igs_he_st_spa_all_pkg.check_constraints (column_name => 'ASSOCIATE_UCAS_NUMBER',
                                                  column_value => p_hesa_spa_stats_rec.associate_ucas_number);

      EXCEPTION
         WHEN OTHERS THEN
            FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                        p_data  => l_msg_data);
            FND_MSG_PUB.DELETE_MSG(l_msg_count);
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_HE_ASSOC_UCAS_NUM_Y_N');
            FND_MSG_PUB.ADD;
            l_db_val_failed := TRUE;
      END;
   END IF;
   -- Check whether the Associate Scottish Candidate has valid value
   IF p_hesa_spa_stats_rec.associate_scott_cand IS NOT NULL THEN
      BEGIN
         igs_he_st_spa_all_pkg.check_constraints (column_name => 'ASSOCIATE_SCOTT_CAND',
                                                  column_value => p_hesa_spa_stats_rec.associate_scott_cand);
      EXCEPTION
         WHEN OTHERS THEN
            FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                        p_data  => l_msg_data);
            FND_MSG_PUB.DELETE_MSG(l_msg_count);
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_HE_ASSOC_SCT_CAND_Y_N');
            FND_MSG_PUB.ADD;
            l_db_val_failed := TRUE;
      END;
   END IF;
   -- Check whether the Associate Teaching Reference Number has valid value
   IF p_hesa_spa_stats_rec.associate_teach_ref_num IS NOT NULL THEN
      BEGIN
         igs_he_st_spa_all_pkg.check_constraints (column_name => 'ASSOCIATE_TEACH_REF_NUM',
                                                  column_value => p_hesa_spa_stats_rec.associate_teach_ref_num);
      EXCEPTION
         WHEN OTHERS THEN
            FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                        p_data  => l_msg_data);
            FND_MSG_PUB.DELETE_MSG(l_msg_count);
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_HE_ASSOC_TCH_REF_Y_N');
            FND_MSG_PUB.ADD;
            l_db_val_failed := TRUE;
      END;
   END IF;
   -- Check whether the Associate NHS Registration Number has valid value
   IF p_hesa_spa_stats_rec.associate_nhs_reg_num IS NOT NULL THEN
      BEGIN
         igs_he_st_spa_all_pkg.check_constraints (column_name => 'ASSOCIATE_NHS_REG_NUM',
                                                  column_value => p_hesa_spa_stats_rec.associate_nhs_reg_num);
      EXCEPTION
         WHEN OTHERS THEN
            FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                        p_data  => l_msg_data);
            FND_MSG_PUB.DELETE_MSG(l_msg_count);
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_HE_ASSOC_NHS_REG_Y_N');
            FND_MSG_PUB.ADD;
            l_db_val_failed := TRUE;
      END;
   END IF;

   -- Check whether any validation failed, if yes then return Error status otherwise return success status
   IF l_db_val_failed THEN
     RETURN 'E';
   ELSE
     RETURN 'S';
   END IF;

END validate_db_cons;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose:  function to validate the business rules for the HESA program attempt statistics
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION validate_hesa_spa(
         p_hesa_spa_stats_rec IN hesa_spa_rec_type)
RETURN BOOLEAN AS

l_br_val_failed BOOLEAN := FALSE;
BEGIN
   -- validate whether the specified combination of subj_qualaim's and qualaim_proportion is valid
   IF NOT igs_en_hesa_pkg.val_sub_qual_proportion (
                                                   p_subj_qualaim1 => p_hesa_spa_stats_rec.subj_qualaim1,
                                                   p_subj_qualaim2 => p_hesa_spa_stats_rec.subj_qualaim2,
                                                   p_subj_qualaim3 => p_hesa_spa_stats_rec.subj_qualaim3,
                                                   p_qualaim_proportion => p_hesa_spa_stats_rec.qualaim_proportion) THEN

      l_br_val_failed := TRUE;
   END IF;

   -- Validate whether the given highest qual on entry is exists against the
   -- grading schema defined for HESA code HESA_HIGH_QUAL_ON_ENT.
   IF NOT igs_en_hesa_pkg.val_highest_qual_entry (p_highest_qual_on_entry => p_hesa_spa_stats_rec.highest_qual_on_entry) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_QUAL_ENTRY_NEX');
        FND_MSG_PUB.ADD;
        l_br_val_failed := TRUE;
   END IF;

   -- Check whether any validation failed, if yes then return FALSE otherwise return TRUE
   IF l_br_val_failed THEN
     RETURN FALSE;
   ELSE
     RETURN TRUE;
   END IF;

END validate_hesa_spa;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: This is Public API to import the Legacy HESA program attempt statistics details
--         into OSS system.
--
--Known limitations/enhancements and/or remarks:
--
-- This API takes the record type variable of program attempt statistics along with
-- other standard API parameters. following is the flow of the procedure
--
--  1. Validate the Country profile value
--  2. Validate the mandatory parameters
--  3. Derive the required values based on input values
--  4. Validate the database constraints
--  5. Validate the business rules.
--  6. Insert the record into OSS table(igs_he_st_spa_all)
--
--  If any of the above step validation/logic failed then the procudure returns
--  with appropriate message(s) and status.
--
--Change History:
--Who         When               What
--ayedubat    14-Jan-2004      Added the NVL condition for the fields, associate_ucas_number, associate_scott_cand,
--                             associate_teach_ref_num,associate_nhs_reg_num to 'Y' for Bug, 3374555
--jtmathew    21-Sep-2004      Modified INSERT statement to accommodate the new fields described in HEFD350.
------------------------------------------------------------------  */
PROCEDURE create_hesa_spa (p_api_version           IN   NUMBER,
                           p_init_msg_list         IN   VARCHAR2,
                           p_commit                IN   VARCHAR2,
                           p_validation_level      IN   NUMBER,
                           p_hesa_spa_stats_rec    IN   hesa_spa_rec_type,
                           x_return_status         OUT NOCOPY VARCHAR2,
                           x_msg_count             OUT NOCOPY NUMBER,
                           x_msg_data              OUT NOCOPY VARCHAR2) AS

-- Derive HESA_ST_SPA_ID from sequence
CURSOR cur_hesa_st_spa_id IS
SELECT igs_he_st_spa_all_s.NEXTVAL
FROM dual;

l_api_name              CONSTANT    VARCHAR2(30) := 'create_hesa_spa';
l_api_version           CONSTANT    NUMBER       := 1.0;

l_validation_failed BOOLEAN := FALSE;
l_db_val_status VARCHAR2(1);
l_person_id hz_parties.party_id%TYPE;
l_version_number igs_en_stdnt_ps_att.version_number%TYPE;
l_hesa_st_spa_id igs_he_st_spa_all.hesa_st_spa_id%TYPE;

BEGIN
-- Create save point
SAVEPOINT create_hesa_spa_pub;

  -- Check for the Compatible API call
  IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- If the calling program has passed the parameter for initializing the message list
  IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
     FND_MSG_PUB.INITIALIZE;
  END IF;

  -- Set the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Check whether the counry profile value is GB
  IF NVL(FND_PROFILE.VALUE('OSS_COUNTRY_CODE'),'NONE') <> 'GB' THEN
     FND_MESSAGE.SET_NAME ('IGS','IGS_UC_HE_NOT_ENABLED');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_validation_failed := TRUE;
  END IF;

  -- If no validation failed then validate parameters
  IF NOT l_validation_failed THEN
     IF NOT validate_parameters(p_hesa_spa_stats_rec => p_hesa_spa_stats_rec) THEN
        l_validation_failed := TRUE;
     END IF;
  END IF;

  -- If no validation failed then derive the required values
  IF NOT l_validation_failed THEN

     -- derive the person Id
     l_person_id := igs_ge_gen_003.get_person_id(p_person_number => p_hesa_spa_stats_rec.person_number);
     IF l_person_id IS NULL THEN
        FND_MESSAGE.SET_NAME ('IGS','IGS_GE_INVALID_PERSON_NUMBER');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_validation_failed := TRUE;
     END IF;

     -- Check whether person ID found then only version number can be derived
     IF NOT l_validation_failed THEN
        -- derive the version number of the program attempt
        l_version_number := igs_ge_gen_003.get_program_version(p_person_id => l_person_id,
                                                               p_program_cd => p_hesa_spa_stats_rec.program_cd);
        IF l_version_number IS NULL THEN
           FND_MESSAGE.SET_NAME ('IGS','IGS_HE_EXT_SPA_DTL_NOT_FOUND');
           FND_MSG_PUB.ADD;
           x_return_status := FND_API.G_RET_STS_ERROR;
           l_validation_failed := TRUE;
        END IF;
     END IF;
  END IF; -- end, derivations

  -- If no validation failed then validate the database constraints
  IF NOT l_validation_failed THEN
     l_db_val_status := validate_db_cons(p_person_id => l_person_id,
                                         p_version_number => l_version_number,
                                         p_hesa_spa_stats_rec => p_hesa_spa_stats_rec);
     IF l_db_val_status = 'W' THEN
        x_return_status := 'W';
        l_validation_failed := TRUE;
     ELSIF l_db_val_status = 'E' THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_validation_failed := TRUE;
     END IF;
  END IF; -- end, validate database constraints

  -- If no validation failed then validate the business rules for Hesa program statistics
  IF NOT l_validation_failed THEN
     IF NOT validate_hesa_spa(p_hesa_spa_stats_rec => p_hesa_spa_stats_rec) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_validation_failed := TRUE;
     END IF;
  END IF;

  -- If no validation failed then insert the record into OSS table(Igs_He_St_Spa_all)
  IF NOT l_validation_failed THEN

     -- get the hesa_st_spa_id from the sequence
     OPEN cur_hesa_st_spa_id;
     FETCH cur_hesa_st_spa_id INTO l_hesa_st_spa_id;
     CLOSE cur_hesa_st_spa_id;

     --
     -- Insert the HESA program statistics record into OSS table igs_he_st_spa_all
     --
     INSERT INTO igs_he_st_spa_all (
                                    hesa_st_spa_id,
                                    org_id,
                                    person_id,
                                    course_cd,
                                    version_number,
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
                                    destination,
                                    itt_prog_outcome,
                                    hesa_return_name,
                                    hesa_return_id,
                                    hesa_submission_name,
                                    associate_ucas_number,
                                    associate_scott_cand,
                                    associate_teach_ref_num,
                                    associate_nhs_reg_num,
                                    nhs_funding_source,
                                    ufi_place,
                                    postcode,
                                    social_class_ind,
                                    occcode,
                                    total_ucas_tariff,
                                    nhs_employer,
                                    creation_date,
                                    created_by,
                                    last_update_date,
                                    last_updated_by,
                                    last_update_login,
                                    return_type,
                                    calculated_fte,
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
                                    exclude_flag)
                                    VALUES (
                                            l_hesa_st_spa_id,
                                            igs_ge_gen_003.get_org_id(),
                                            l_person_id,
                                            p_hesa_spa_stats_rec.program_cd,
                                            l_version_number,
                                            p_hesa_spa_stats_rec.fe_student_marker,
                                            p_hesa_spa_stats_rec.domicile_cd,
                                            NULL, --inst_last_attended,
                                            NULL, --year_left_last_inst,
                                            p_hesa_spa_stats_rec.highest_qual_on_entry,
                                            NULL, --date_qual_on_entry_calc,
                                            NULL, --a_level_point_score,
                                            NULL, --highers_points_scores,
                                            p_hesa_spa_stats_rec.occupation_code,
                                            p_hesa_spa_stats_rec.commencement_dt,
                                            p_hesa_spa_stats_rec.special_student,
                                            p_hesa_spa_stats_rec.student_qual_aim,
                                            p_hesa_spa_stats_rec.student_fe_qual_aim,
                                            p_hesa_spa_stats_rec.teacher_train_prog_id,
                                            p_hesa_spa_stats_rec.itt_phase,
                                            p_hesa_spa_stats_rec.bilingual_itt_marker,
                                            p_hesa_spa_stats_rec.teaching_qual_gain_sector,
                                            p_hesa_spa_stats_rec.teaching_qual_gain_subj1,
                                            p_hesa_spa_stats_rec.teaching_qual_gain_subj2,
                                            p_hesa_spa_stats_rec.teaching_qual_gain_subj3,
                                            p_hesa_spa_stats_rec.student_inst_number,
                                            p_hesa_spa_stats_rec.destination,
                                            p_hesa_spa_stats_rec.itt_prog_outcome,
                                            NULL, --hesa_return_name,
                                            NULL, --hesa_return_id,
                                            NULL, --hesa_submission_name,
                                            NVL(p_hesa_spa_stats_rec.associate_ucas_number,'Y'),
                                            NVL(p_hesa_spa_stats_rec.associate_scott_cand,'Y'),
                                            NVL(p_hesa_spa_stats_rec.associate_teach_ref_num,'Y'),
                                            NVL(p_hesa_spa_stats_rec.associate_nhs_reg_num,'Y'),
                                            p_hesa_spa_stats_rec.nhs_funding_source,
                                            p_hesa_spa_stats_rec.ufi_place,
                                            p_hesa_spa_stats_rec.postcode,
                                            p_hesa_spa_stats_rec.social_class_ind,
                                            p_hesa_spa_stats_rec.occcode,
                                            NULL, --total_ucas_tariff,
                                            p_hesa_spa_stats_rec.nhs_employer,
                                            SYSDATE, --creation_date,
                                            NVL(FND_GLOBAL.USER_ID,-1), --created_by,
                                            SYSDATE, --last_update_date,
                                            NVL(FND_GLOBAL.USER_ID,-1), --last_updated_by,
                                            NVL(FND_GLOBAL.LOGIN_ID,-1), --last_update_login,
                                            p_hesa_spa_stats_rec.return_type,
                                            NULL, --calculated_fte,
                                            p_hesa_spa_stats_rec.subj_qualaim1,
                                            p_hesa_spa_stats_rec.subj_qualaim2,
                                            p_hesa_spa_stats_rec.subj_qualaim3,
                                            p_hesa_spa_stats_rec.qualaim_proportion,
                                            p_hesa_spa_stats_rec.dependants_cd,
                                            p_hesa_spa_stats_rec.implied_fund_rate,
                                            p_hesa_spa_stats_rec.gov_initiatives_cd,
                                            p_hesa_spa_stats_rec.units_for_qual,
                                            p_hesa_spa_stats_rec.disadv_uplift_elig_cd,
                                            p_hesa_spa_stats_rec.franch_partner_cd,
                                            p_hesa_spa_stats_rec.units_completed,
                                            p_hesa_spa_stats_rec.franch_out_arr_cd,
                                            p_hesa_spa_stats_rec.employer_role_cd,
                                            p_hesa_spa_stats_rec.disadv_uplift_factor,
                                            p_hesa_spa_stats_rec.enh_fund_elig_cd,
                                            'N');
     -- Set the return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

  ELSE
     ROLLBACK TO create_hesa_spa_pub;
  END IF;

  -- If no validation failed and p_commit is passed as 'Y' then commit the changes.
  IF NOT l_validation_failed AND FND_API.TO_BOOLEAN(p_commit) THEN
     COMMIT;
  END IF;

  FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                             p_data           => x_msg_data);

  RETURN;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO create_hesa_spa_pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                  p_data           => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO create_hesa_spa_pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                  p_data           => x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO create_hesa_spa_pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,
                                  l_api_name);
       END IF;
       FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                  p_data           => x_msg_data);
END create_hesa_spa;


END IGS_HE_SPA_LGCY_PUB;

/
