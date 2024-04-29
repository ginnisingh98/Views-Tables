--------------------------------------------------------
--  DDL for Package IGS_HE_SPA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_SPA_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSHE22S.pls 120.1 2006/02/13 23:26:52 jchakrab noship $ */
/*#
 * The Student Program Attempt HESA Detail Import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_HE_LGCY_SPA_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Legacy Student Program Attempt HESA Detail
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */

TYPE hesa_spa_rec_type IS RECORD (
                person_number             igs_he_lgcy_spa_int.person_number%TYPE,
                program_cd                igs_he_lgcy_spa_int.program_cd%TYPE,
                fe_student_marker         igs_he_lgcy_spa_int.fe_student_marker%TYPE,
                domicile_cd               igs_he_lgcy_spa_int.domicile_cd%TYPE,
                highest_qual_on_entry     igs_he_lgcy_spa_int.highest_qual_on_entry%TYPE,
                occupation_code           igs_he_lgcy_spa_int.occupation_code%TYPE,
                commencement_dt           igs_he_lgcy_spa_int.commencement_dt%TYPE,
                special_student           igs_he_lgcy_spa_int.special_student%TYPE,
                student_qual_aim          igs_he_lgcy_spa_int.student_qual_aim%TYPE,
                student_fe_qual_aim       igs_he_lgcy_spa_int.student_fe_qual_aim%TYPE,
                teacher_train_prog_id     igs_he_lgcy_spa_int.teacher_train_prog_id%TYPE,
                itt_phase                 igs_he_lgcy_spa_int.itt_phase%TYPE,
                bilingual_itt_marker      igs_he_lgcy_spa_int.bilingual_itt_marker%TYPE,
                teaching_qual_gain_sector igs_he_lgcy_spa_int.teaching_qual_gain_sector%TYPE,
                teaching_qual_gain_subj1  igs_he_lgcy_spa_int.teaching_qual_gain_subj1%TYPE,
                teaching_qual_gain_subj2  igs_he_lgcy_spa_int.teaching_qual_gain_subj2%TYPE,
                teaching_qual_gain_subj3  igs_he_lgcy_spa_int.teaching_qual_gain_subj3%TYPE,
                student_inst_number       igs_he_lgcy_spa_int.student_inst_number%TYPE,
                destination               igs_he_lgcy_spa_int.destination%TYPE,
                itt_prog_outcome          igs_he_lgcy_spa_int.itt_prog_outcome%TYPE,
                associate_ucas_number     igs_he_lgcy_spa_int.associate_ucas_number%TYPE,
                associate_scott_cand      igs_he_lgcy_spa_int.associate_scott_cand%TYPE,
                associate_teach_ref_num   igs_he_lgcy_spa_int.associate_teach_ref_num%TYPE,
                associate_nhs_reg_num     igs_he_lgcy_spa_int.associate_nhs_reg_num%TYPE,
                nhs_funding_source        igs_he_lgcy_spa_int.nhs_funding_source%TYPE,
                ufi_place                 igs_he_lgcy_spa_int.ufi_place%TYPE,
                postcode                  igs_he_lgcy_spa_int.postcode%TYPE,
                social_class_ind          igs_he_lgcy_spa_int.social_class_ind%TYPE,
                occcode                   igs_he_lgcy_spa_int.occcode%TYPE,
                nhs_employer              igs_he_lgcy_spa_int.nhs_employer%TYPE,
                return_type               igs_he_lgcy_spa_int.return_type%TYPE,
                subj_qualaim1             igs_he_lgcy_spa_int.subj_qualaim1%TYPE,
                subj_qualaim2             igs_he_lgcy_spa_int.subj_qualaim2%TYPE,
                subj_qualaim3             igs_he_lgcy_spa_int.subj_qualaim3%TYPE,
                qualaim_proportion        igs_he_lgcy_spa_int.qualaim_proportion%TYPE,
                dependants_cd             igs_he_lgcy_spa_int.dependants_cd%TYPE,
                implied_fund_rate         igs_he_lgcy_spa_int.implied_fund_rate%TYPE,
                gov_initiatives_cd        igs_he_lgcy_spa_int.gov_initiatives_cd%TYPE,
                units_for_qual            igs_he_lgcy_spa_int.units_for_qual%TYPE,
                disadv_uplift_elig_cd     igs_he_lgcy_spa_int.disadv_uplift_elig_cd%TYPE,
                franch_partner_cd         igs_he_lgcy_spa_int.franch_partner_cd%TYPE,
                units_completed           igs_he_lgcy_spa_int.units_completed%TYPE,
                franch_out_arr_cd         igs_he_lgcy_spa_int.franch_out_arr_cd%TYPE,
                employer_role_cd          igs_he_lgcy_spa_int.employer_role_cd%TYPE,
                disadv_uplift_factor      igs_he_lgcy_spa_int.disadv_uplift_factor%TYPE,
                enh_fund_elig_cd          igs_he_lgcy_spa_int.enh_fund_elig_cd%TYPE);

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
-- other standard API parameters.
--
--Change History:
--Who         When               What
--jchakrab    10-Jan-2006     Added Integration Repository Annotations for R12
------------------------------------------------------------------  */

/*#
 * The Student Program Attempt HESA Detail Import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_HE_LGCY_SPA_INT interface table.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize Message List.
 * @param p_commit Commit Transaction.
 * @param p_validation_level Validation Level.
 * @param p_hesa_spa_stats_rec Legacy Student Program Attempt HESA Details record type. Refer to IGS_HE_LGCY_SPA_INT for detail column descriptions.
 * @param x_return_status Return Status.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Student Program Attempt HESA Detail
 */

PROCEDURE create_hesa_spa  (p_api_version           IN   NUMBER,
                            p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_commit                IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_validation_level      IN   NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
                            p_hesa_spa_stats_rec    IN   hesa_spa_rec_type,
                            x_return_status         OUT NOCOPY VARCHAR2,
                            x_msg_count             OUT NOCOPY NUMBER,
                            x_msg_data              OUT NOCOPY VARCHAR2);


END IGS_HE_SPA_LGCY_PUB;

 

/
