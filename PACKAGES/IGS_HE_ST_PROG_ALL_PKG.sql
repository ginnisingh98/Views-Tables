--------------------------------------------------------
--  DDL for Package IGS_HE_ST_PROG_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_ST_PROG_ALL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI26S.pls 120.1 2006/02/06 19:54:29 jbaber noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_st_prog_id                   IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_sought_sector       IN     VARCHAR2,
    x_teaching_qual_sought_subj1        IN     VARCHAR2,
    x_teaching_qual_sought_subj2        IN     VARCHAR2,
    x_teaching_qual_sought_subj3        IN     VARCHAR2,
    x_location_of_study                 IN     VARCHAR2,
    x_other_inst_prov_teaching1         IN     VARCHAR2,
    x_other_inst_prov_teaching2         IN     VARCHAR2,
    x_prop_teaching_in_welsh            IN     NUMBER,
    x_prop_not_taught                   IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_default_award                     IN     VARCHAR2,
    x_program_calc                      IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_fe_program_marker                 IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_fundability                       IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER      DEFAULT NULL,
    x_teach_period_start_dt             IN     DATE        DEFAULT NULL,
    x_teach_period_end_dt               IN     DATE        DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT NULL,
    x_implied_fund_rate                 IN     NUMBER      DEFAULT NULL,
    x_gov_initiatives_cd                IN     VARCHAR2    DEFAULT NULL,
    x_units_for_qual                    IN     NUMBER      DEFAULT NULL,
    x_disadv_uplift_elig_cd             IN     VARCHAR2    DEFAULT NULL,
    x_franch_partner_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_franch_out_arr_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2
  );

 PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hesa_st_prog_id                   IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_sought_sector       IN     VARCHAR2,
    x_teaching_qual_sought_subj1        IN     VARCHAR2,
    x_teaching_qual_sought_subj2        IN     VARCHAR2,
    x_teaching_qual_sought_subj3        IN     VARCHAR2,
    x_location_of_study                 IN     VARCHAR2,
    x_other_inst_prov_teaching1         IN     VARCHAR2,
    x_other_inst_prov_teaching2         IN     VARCHAR2,
    x_prop_teaching_in_welsh            IN     NUMBER,
    x_prop_not_taught                   IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_default_award                     IN     VARCHAR2,
    x_program_calc                      IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_fe_program_marker                 IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_fundability                       IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER    DEFAULT NULL,
    x_teach_period_start_dt             IN     DATE      DEFAULT NULL,
    x_teach_period_end_dt               IN     DATE      DEFAULT NULL,
    x_implied_fund_rate                 IN     NUMBER    DEFAULT NULL,
    x_gov_initiatives_cd                IN     VARCHAR2  DEFAULT NULL,
    x_units_for_qual                    IN     NUMBER    DEFAULT NULL,
    x_disadv_uplift_elig_cd             IN     VARCHAR2  DEFAULT NULL,
    x_franch_partner_cd                 IN     VARCHAR2  DEFAULT NULL,
    x_franch_out_arr_cd                 IN     VARCHAR2  DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hesa_st_prog_id                   IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_sought_sector       IN     VARCHAR2,
    x_teaching_qual_sought_subj1        IN     VARCHAR2,
    x_teaching_qual_sought_subj2        IN     VARCHAR2,
    x_teaching_qual_sought_subj3        IN     VARCHAR2,
    x_location_of_study                 IN     VARCHAR2,
    x_other_inst_prov_teaching1         IN     VARCHAR2,
    x_other_inst_prov_teaching2         IN     VARCHAR2,
    x_prop_teaching_in_welsh            IN     NUMBER,
    x_prop_not_taught                   IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_default_award                     IN     VARCHAR2,
    x_program_calc                      IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_fe_program_marker                 IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_fundability                       IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER      DEFAULT NULL,
    x_teach_period_start_dt             IN     DATE        DEFAULT NULL,
    x_teach_period_end_dt               IN     DATE        DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT NULL,
    x_implied_fund_rate                 IN     NUMBER      DEFAULT NULL,
    x_gov_initiatives_cd                IN     VARCHAR2    DEFAULT NULL,
    x_units_for_qual                    IN     NUMBER      DEFAULT NULL,
    x_disadv_uplift_elig_cd             IN     VARCHAR2    DEFAULT NULL,
    x_franch_partner_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_franch_out_arr_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_st_prog_id                   IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_sought_sector       IN     VARCHAR2,
    x_teaching_qual_sought_subj1        IN     VARCHAR2,
    x_teaching_qual_sought_subj2        IN     VARCHAR2,
    x_teaching_qual_sought_subj3        IN     VARCHAR2,
    x_location_of_study                 IN     VARCHAR2,
    x_other_inst_prov_teaching1         IN     VARCHAR2,
    x_other_inst_prov_teaching2         IN     VARCHAR2,
    x_prop_teaching_in_welsh            IN     NUMBER,
    x_prop_not_taught                   IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_default_award                     IN     VARCHAR2,
    x_program_calc                      IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_fe_program_marker                 IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_fundability                       IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER      DEFAULT NULL,
    x_teach_period_start_dt             IN     DATE        DEFAULT NULL ,
    x_teach_period_end_dt               IN     DATE        DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT NULL,
    x_implied_fund_rate                 IN     NUMBER      DEFAULT NULL,
    x_gov_initiatives_cd                IN     VARCHAR2    DEFAULT NULL,
    x_units_for_qual                    IN     NUMBER      DEFAULT NULL,
    x_disadv_uplift_elig_cd             IN     VARCHAR2    DEFAULT NULL,
    x_franch_partner_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_franch_out_arr_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_hesa_st_prog_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_ver_all (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hesa_st_prog_id                   IN     NUMBER      DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_teacher_train_prog_id             IN     VARCHAR2    DEFAULT NULL,
    x_itt_phase                         IN     VARCHAR2    DEFAULT NULL,
    x_bilingual_itt_marker              IN     VARCHAR2    DEFAULT NULL,
    x_teaching_qual_sought_sector       IN     VARCHAR2    DEFAULT NULL,
    x_teaching_qual_sought_subj1        IN     VARCHAR2    DEFAULT NULL,
    x_teaching_qual_sought_subj2        IN     VARCHAR2    DEFAULT NULL,
    x_teaching_qual_sought_subj3        IN     VARCHAR2    DEFAULT NULL,
    x_location_of_study                 IN     VARCHAR2    DEFAULT NULL,
    x_other_inst_prov_teaching1         IN     VARCHAR2    DEFAULT NULL,
    x_other_inst_prov_teaching2         IN     VARCHAR2    DEFAULT NULL,
    x_prop_teaching_in_welsh            IN     NUMBER      DEFAULT NULL,
    x_prop_not_taught                   IN     NUMBER      DEFAULT NULL,
    x_credit_transfer_scheme            IN     VARCHAR2    DEFAULT NULL,
    x_return_type                       IN     VARCHAR2    DEFAULT NULL,
    x_default_award                     IN     VARCHAR2    DEFAULT NULL,
    x_program_calc                      IN     VARCHAR2    DEFAULT NULL,
    x_level_applicable_to_funding       IN     VARCHAR2    DEFAULT NULL,
    x_franchising_activity              IN     VARCHAR2    DEFAULT NULL,
    x_nhs_funding_source                IN     VARCHAR2    DEFAULT NULL,
    x_fe_program_marker                 IN     VARCHAR2    DEFAULT NULL,
    x_fee_band                          IN     VARCHAR2    DEFAULT NULL,
    x_fundability                       IN     VARCHAR2    DEFAULT NULL,
    x_fte_intensity                     IN     NUMBER      DEFAULT NULL,
    x_teach_period_start_dt             IN     DATE        DEFAULT NULL ,
    x_teach_period_end_dt               IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_implied_fund_rate                 IN     NUMBER      DEFAULT NULL,
    x_gov_initiatives_cd                IN     VARCHAR2    DEFAULT NULL,
    x_units_for_qual                    IN     NUMBER      DEFAULT NULL,
    x_disadv_uplift_elig_cd             IN     VARCHAR2    DEFAULT NULL,
    x_franch_partner_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_franch_out_arr_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2    DEFAULT NULL
  );

END igs_he_st_prog_all_pkg;

 

/
