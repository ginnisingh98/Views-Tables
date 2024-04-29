--------------------------------------------------------
--  DDL for Package IGS_AS_ENTRY_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_ENTRY_CONF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI46S.pls 115.7 2003/12/05 10:51:11 kdande ship $ */
  PROCEDURE insert_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_s_control_num                IN     NUMBER,
    x_key_allow_invalid_ind        IN     VARCHAR2,
    x_key_collect_mark_ind         IN     VARCHAR2,
    x_key_grade_derive_ind         IN     VARCHAR2,
    x_key_mark_mndtry_ind          IN     VARCHAR2,
    x_upld_person_no_exist         IN     VARCHAR2,
    x_upld_crs_not_enrolled        IN     VARCHAR2,
    x_upld_unit_not_enrolled       IN     VARCHAR2,
    x_upld_unit_discont            IN     VARCHAR2,
    x_upld_grade_invalid           IN     VARCHAR2,
    x_upld_mark_grade_invalid      IN     VARCHAR2,
    x_key_mark_entry_dec_points    IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_key_prtl_sbmn_allowed_ind    IN     VARCHAR2,
    x_upld_ug_sbmtd_grade_exist    IN     VARCHAR2,
    x_upld_ug_saved_grade_exist    IN     VARCHAR2,
    x_upld_asmnt_item_not_exist    IN     VARCHAR2,
    x_upld_asmnt_item_grd_exist    IN     VARCHAR2,
    x_key_derive_unit_grade_flag   IN     VARCHAR2,
    x_key_allow_inst_finalize_flag IN     VARCHAR2,
    x_key_ai_collect_mark_flag     IN     VARCHAR2,
    x_key_ai_mark_mndtry_flag      IN     VARCHAR2,
    x_key_ai_grade_derive_flag     IN     VARCHAR2,
    x_key_ai_allow_invalid_flag    IN     VARCHAR2,
    x_key_ai_mark_entry_dec_points IN     NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                        IN     VARCHAR2,
    x_s_control_num                IN     NUMBER,
    x_key_allow_invalid_ind        IN     VARCHAR2,
    x_key_collect_mark_ind         IN     VARCHAR2,
    x_key_grade_derive_ind         IN     VARCHAR2,
    x_key_mark_mndtry_ind          IN     VARCHAR2,
    x_upld_person_no_exist         IN     VARCHAR2,
    x_upld_crs_not_enrolled        IN     VARCHAR2,
    x_upld_unit_not_enrolled       IN     VARCHAR2,
    x_upld_unit_discont            IN     VARCHAR2,
    x_upld_grade_invalid           IN     VARCHAR2,
    x_upld_mark_grade_invalid      IN     VARCHAR2,
    x_key_mark_entry_dec_points    IN     NUMBER,
    x_key_prtl_sbmn_allowed_ind    IN     VARCHAR2,
    x_upld_ug_sbmtd_grade_exist    IN     VARCHAR2,
    x_upld_ug_saved_grade_exist    IN     VARCHAR2,
    x_upld_asmnt_item_not_exist    IN     VARCHAR2,
    x_upld_asmnt_item_grd_exist    IN     VARCHAR2,
    x_key_derive_unit_grade_flag   IN     VARCHAR2,
    x_key_allow_inst_finalize_flag IN     VARCHAR2,
    x_key_ai_collect_mark_flag     IN     VARCHAR2,
    x_key_ai_mark_mndtry_flag      IN     VARCHAR2,
    x_key_ai_grade_derive_flag     IN     VARCHAR2,
    x_key_ai_allow_invalid_flag    IN     VARCHAR2,
    x_key_ai_mark_entry_dec_points IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                        IN     VARCHAR2,
    x_s_control_num                IN     NUMBER,
    x_key_allow_invalid_ind        IN     VARCHAR2,
    x_key_collect_mark_ind         IN     VARCHAR2,
    x_key_grade_derive_ind         IN     VARCHAR2,
    x_key_mark_mndtry_ind          IN     VARCHAR2,
    x_upld_person_no_exist         IN     VARCHAR2,
    x_upld_crs_not_enrolled        IN     VARCHAR2,
    x_upld_unit_not_enrolled       IN     VARCHAR2,
    x_upld_unit_discont            IN     VARCHAR2,
    x_upld_grade_invalid           IN     VARCHAR2,
    x_upld_mark_grade_invalid      IN     VARCHAR2,
    x_key_mark_entry_dec_points    IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_key_prtl_sbmn_allowed_ind    IN     VARCHAR2,
    x_upld_ug_sbmtd_grade_exist    IN     VARCHAR2,
    x_upld_ug_saved_grade_exist    IN     VARCHAR2,
    x_upld_asmnt_item_not_exist    IN     VARCHAR2,
    x_upld_asmnt_item_grd_exist    IN     VARCHAR2,
    x_key_derive_unit_grade_flag   IN     VARCHAR2,
    x_key_allow_inst_finalize_flag IN     VARCHAR2,
    x_key_ai_collect_mark_flag     IN     VARCHAR2,
    x_key_ai_mark_mndtry_flag      IN     VARCHAR2,
    x_key_ai_grade_derive_flag     IN     VARCHAR2,
    x_key_ai_allow_invalid_flag    IN     VARCHAR2,
    x_key_ai_mark_entry_dec_points IN     NUMBER
  );

  PROCEDURE add_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_s_control_num                IN     NUMBER,
    x_key_allow_invalid_ind        IN     VARCHAR2,
    x_key_collect_mark_ind         IN     VARCHAR2,
    x_key_grade_derive_ind         IN     VARCHAR2,
    x_key_mark_mndtry_ind          IN     VARCHAR2,
    x_upld_person_no_exist         IN     VARCHAR2,
    x_upld_crs_not_enrolled        IN     VARCHAR2,
    x_upld_unit_not_enrolled       IN     VARCHAR2,
    x_upld_unit_discont            IN     VARCHAR2,
    x_upld_grade_invalid           IN     VARCHAR2,
    x_upld_mark_grade_invalid      IN     VARCHAR2,
    x_key_mark_entry_dec_points    IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_key_prtl_sbmn_allowed_ind    IN     VARCHAR2,
    x_upld_ug_sbmtd_grade_exist    IN     VARCHAR2,
    x_upld_ug_saved_grade_exist    IN     VARCHAR2,
    x_upld_asmnt_item_not_exist    IN     VARCHAR2,
    x_upld_asmnt_item_grd_exist    IN     VARCHAR2,
    x_key_derive_unit_grade_flag   IN     VARCHAR2,
    x_key_allow_inst_finalize_flag IN     VARCHAR2,
    x_key_ai_collect_mark_flag     IN     VARCHAR2,
    x_key_ai_mark_mndtry_flag      IN     VARCHAR2,
    x_key_ai_grade_derive_flag     IN     VARCHAR2,
    x_key_ai_allow_invalid_flag    IN     VARCHAR2,
    x_key_ai_mark_entry_dec_points IN     NUMBER
  );

  PROCEDURE delete_row (x_rowid IN VARCHAR2);

  FUNCTION get_pk_for_validation (x_s_control_num IN NUMBER)
    RETURN BOOLEAN;

  PROCEDURE check_constraints (
    column_name                    IN     VARCHAR2 DEFAULT NULL,
    column_value                   IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE before_dml (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2 DEFAULT NULL,
    x_s_control_num                IN     NUMBER DEFAULT NULL,
    x_key_allow_invalid_ind        IN     VARCHAR2 DEFAULT NULL,
    x_key_collect_mark_ind         IN     VARCHAR2 DEFAULT NULL,
    x_key_grade_derive_ind         IN     VARCHAR2 DEFAULT NULL,
    x_key_mark_mndtry_ind          IN     VARCHAR2 DEFAULT NULL,
    x_upld_person_no_exist         IN     VARCHAR2 DEFAULT NULL,
    x_upld_crs_not_enrolled        IN     VARCHAR2 DEFAULT NULL,
    x_upld_unit_not_enrolled       IN     VARCHAR2 DEFAULT NULL,
    x_upld_unit_discont            IN     VARCHAR2 DEFAULT NULL,
    x_upld_grade_invalid           IN     VARCHAR2 DEFAULT NULL,
    x_upld_mark_grade_invalid      IN     VARCHAR2 DEFAULT NULL,
    x_key_mark_entry_dec_points    IN     NUMBER DEFAULT NULL,
    x_creation_date                IN     DATE DEFAULT NULL,
    x_created_by                   IN     NUMBER DEFAULT NULL,
    x_last_update_date             IN     DATE DEFAULT NULL,
    x_last_updated_by              IN     NUMBER DEFAULT NULL,
    x_last_update_login            IN     NUMBER DEFAULT NULL,
    x_key_prtl_sbmn_allowed_ind    IN     VARCHAR2 DEFAULT NULL,
    x_upld_ug_sbmtd_grade_exist    IN     VARCHAR2 DEFAULT NULL,
    x_upld_ug_saved_grade_exist    IN     VARCHAR2 DEFAULT NULL,
    x_upld_asmnt_item_not_exist    IN     VARCHAR2 DEFAULT NULL,
    x_upld_asmnt_item_grd_exist    IN     VARCHAR2 DEFAULT NULL,
    x_key_derive_unit_grade_flag   IN     VARCHAR2 DEFAULT NULL,
    x_key_allow_inst_finalize_flag IN     VARCHAR2 DEFAULT NULL,
    x_key_ai_collect_mark_flag     IN     VARCHAR2 DEFAULT NULL,
    x_key_ai_mark_mndtry_flag      IN     VARCHAR2 DEFAULT NULL,
    x_key_ai_grade_derive_flag     IN     VARCHAR2 DEFAULT NULL,
    x_key_ai_allow_invalid_flag    IN     VARCHAR2 DEFAULT NULL,
    x_key_ai_mark_entry_dec_points IN     NUMBER DEFAULT NULL
  );
END igs_as_entry_conf_pkg;

 

/
