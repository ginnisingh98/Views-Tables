--------------------------------------------------------
--  DDL for Package IGS_HE_SUSA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_SUSA_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSHE23S.pls 120.1 2006/02/13 23:27:10 jchakrab noship $ */
/*#
 * The Student Unit Set Attempt HESA Detail Import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_HE_LGY_SUSA_INT interface table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Legacy Student Unit Set Attempt HESA Detail
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_STUDENT_PROGRAM
 */

-- Record Type for columns of Interface table IGS_HE_LGY_SUSA_INT
--
TYPE hesa_susa_rec_type IS RECORD ( person_number             igs_he_lgy_susa_int.person_number%TYPE,
                                    program_cd                igs_he_lgy_susa_int.program_cd%TYPE,
                                    unit_set_cd               igs_he_lgy_susa_int.unit_set_cd%TYPE,
                                    new_he_entrant_cd         igs_he_lgy_susa_int.new_he_entrant_cd%TYPE,
                                    term_time_accom           igs_he_lgy_susa_int.term_time_accom%TYPE,
                                    disability_allow          igs_he_lgy_susa_int.disability_allow%TYPE,
                                    additional_sup_band       igs_he_lgy_susa_int.additional_sup_band%TYPE,
                                    sldd_discrete_prov        igs_he_lgy_susa_int.sldd_discrete_prov%TYPE,
                                    study_mode                igs_he_lgy_susa_int.study_mode%TYPE,
                                    study_location            igs_he_lgy_susa_int.study_location%TYPE,
                                    fte_perc_override         igs_he_lgy_susa_int.fte_perc_override%TYPE,
                                    franchising_activity      igs_he_lgy_susa_int.franchising_activity%TYPE,
                                    completion_status         igs_he_lgy_susa_int.completion_status%TYPE,
                                    good_stand_marker         igs_he_lgy_susa_int.good_stand_marker%TYPE,
                                    complete_pyr_study_cd     igs_he_lgy_susa_int.complete_pyr_study_cd%TYPE,
                                    credit_value_yop1         igs_he_lgy_susa_int.credit_value_yop1%TYPE,
                                    credit_value_yop2         igs_he_lgy_susa_int.credit_value_yop2%TYPE,
                                    credit_value_yop3         igs_he_lgy_susa_int.credit_value_yop3%TYPE,
                                    credit_value_yop4         igs_he_lgy_susa_int.credit_value_yop4%TYPE,
                                    credit_level_achieved1    igs_he_lgy_susa_int.credit_level_achieved1%TYPE,
                                    credit_level_achieved2    igs_he_lgy_susa_int.credit_level_achieved2%TYPE,
                                    credit_level_achieved3    igs_he_lgy_susa_int.credit_level_achieved3%TYPE,
                                    credit_level_achieved4    igs_he_lgy_susa_int.credit_level_achieved4%TYPE,
                                    credit_pt_achieved1       igs_he_lgy_susa_int.credit_pt_achieved1%TYPE,
                                    credit_pt_achieved2       igs_he_lgy_susa_int.credit_pt_achieved2%TYPE,
                                    credit_pt_achieved3       igs_he_lgy_susa_int.credit_pt_achieved3%TYPE,
                                    credit_pt_achieved4       igs_he_lgy_susa_int.credit_pt_achieved4%TYPE,
                                    credit_level1             igs_he_lgy_susa_int.credit_level1%TYPE,
                                    credit_level2             igs_he_lgy_susa_int.credit_level2%TYPE,
                                    credit_level3             igs_he_lgy_susa_int.credit_level3%TYPE,
                                    credit_level4             igs_he_lgy_susa_int.credit_level4%TYPE,
                                    grad_sch_grade            igs_he_lgy_susa_int.grad_sch_grade%TYPE,
                                    mark                      igs_he_lgy_susa_int.mark%TYPE,
                                    teaching_inst1            igs_he_lgy_susa_int.teaching_inst1%TYPE,
                                    teaching_inst2            igs_he_lgy_susa_int.teaching_inst2%TYPE,
                                    pro_not_taught            igs_he_lgy_susa_int.pro_not_taught%TYPE,
                                    fundability_code          igs_he_lgy_susa_int.fundability_code%TYPE,
                                    fee_eligibility           igs_he_lgy_susa_int.fee_eligibility%TYPE,
                                    fee_band                  igs_he_lgy_susa_int.fee_band%TYPE,
                                    non_payment_reason        igs_he_lgy_susa_int.non_payment_reason%TYPE,
                                    student_fee               igs_he_lgy_susa_int.student_fee%TYPE,
                                    fte_intensity             igs_he_lgy_susa_int.fte_intensity%TYPE,
                                    calculated_fte            igs_he_lgy_susa_int.calculated_fte%TYPE,
                                    fte_calc_type             igs_he_lgy_susa_int.fte_calc_type%TYPE,
                                    type_of_year              igs_he_lgy_susa_int.type_of_year%TYPE,
                                    year_stu                  igs_he_lgy_susa_int.year_stu%TYPE,
                                    enh_fund_elig_cd          igs_he_lgy_susa_int.enh_fund_elig_cd%TYPE,
                                    additional_sup_cost       igs_he_lgy_susa_int.additional_sup_cost%TYPE,
                                    disadv_uplift_factor      igs_he_lgy_susa_int.disadv_uplift_factor%TYPE);


/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 05-11-2002
||  Purpose : To create a HESA Student Unit Set Attempt
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who        When            What
|| jchakrab    10-Jan-2006     Added Integration Repository Annotations for R12
------------------------------------------------------------------------------*/

/*#
 * The Student Unit Set Attempt HESA Detail Import process is a public API designed for use in populating rows with data during a system conversion.
 * This API is also used by the Legacy Import Process for Enrollment and Records when importing rows from the IGS_HE_LGY_SUSA_INT interface table.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize Message List.
 * @param p_commit Commit Transaction.
 * @param p_validation_level Validation Level.
 * @param p_hesa_susa_rec Legacy Student Unit Set Attempt HESA Details record type. Refer to IGS_HE_LGY_SUSA_INT for detail column descriptions.
 * @param x_return_status Return Status.
 * @param x_msg_count Message count.
 * @param x_msg_data Message data.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Legacy Student Unit Set Attempt HESA Detail
 */

PROCEDURE create_hesa_susa (p_api_version           IN   NUMBER,
                            p_init_msg_list         IN   VARCHAR2              DEFAULT FND_API.G_FALSE,
                            p_commit                IN   VARCHAR2              DEFAULT FND_API.G_FALSE,
                            p_validation_level      IN   NUMBER                DEFAULT FND_API.G_VALID_LEVEL_FULL,
                            p_hesa_susa_rec         IN   hesa_susa_rec_type,
                            x_return_status         OUT  NOCOPY VARCHAR2,
                            x_msg_count             OUT  NOCOPY NUMBER,
                            x_msg_data              OUT  NOCOPY VARCHAR2);



END igs_he_susa_lgcy_pub;

 

/
