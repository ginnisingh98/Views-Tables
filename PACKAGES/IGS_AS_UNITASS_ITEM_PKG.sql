--------------------------------------------------------
--  DDL for Package IGS_AS_UNITASS_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_UNITASS_ITEM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI31S.pls 115.8 2003/12/05 10:51:18 kdande ship $ */
  PROCEDURE insert_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_unit_ass_item_id             IN OUT NOCOPY NUMBER,
    x_unit_cd                      IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_sequence_number              IN     NUMBER,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_unit_class                   IN     VARCHAR2,
    x_unit_mode                    IN     VARCHAR2,
    x_location_cd                  IN     VARCHAR2,
    x_due_dt                       IN     DATE,
    x_reference                    IN     VARCHAR2,
    x_dflt_item_ind                IN     VARCHAR2,
    x_logical_delete_dt            IN     DATE,
    x_action_dt                    IN     DATE,
    x_exam_cal_type                IN     VARCHAR2,
    x_exam_ci_sequence_number      IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_org_id                       IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_release_date                 IN     DATE,
    x_description                  IN     VARCHAR2 DEFAULT NULL,
    x_unit_ass_item_group_id       IN     VARCHAR2 DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                        IN     VARCHAR2,
    x_unit_ass_item_id             IN     NUMBER,
    x_unit_cd                      IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_sequence_number              IN     NUMBER,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_unit_class                   IN     VARCHAR2,
    x_unit_mode                    IN     VARCHAR2,
    x_location_cd                  IN     VARCHAR2,
    x_due_dt                       IN     DATE,
    x_reference                    IN     VARCHAR2,
    x_dflt_item_ind                IN     VARCHAR2,
    x_logical_delete_dt            IN     DATE,
    x_action_dt                    IN     DATE,
    x_exam_cal_type                IN     VARCHAR2,
    x_exam_ci_sequence_number      IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_release_date                 IN     DATE,
    x_description                  IN     VARCHAR2 DEFAULT NULL,
    x_unit_ass_item_group_id       IN     VARCHAR2 DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                        IN     VARCHAR2,
    x_unit_ass_item_id             IN     NUMBER,
    x_unit_cd                      IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_sequence_number              IN     NUMBER,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_unit_class                   IN     VARCHAR2,
    x_unit_mode                    IN     VARCHAR2,
    x_location_cd                  IN     VARCHAR2,
    x_due_dt                       IN     DATE,
    x_reference                    IN     VARCHAR2,
    x_dflt_item_ind                IN     VARCHAR2,
    x_logical_delete_dt            IN     DATE,
    x_action_dt                    IN     DATE,
    x_exam_cal_type                IN     VARCHAR2,
    x_exam_ci_sequence_number      IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_release_date                 IN     DATE,
    x_description                  IN     VARCHAR2 DEFAULT NULL,
    x_unit_ass_item_group_id       IN     VARCHAR2 DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_unit_ass_item_id             IN OUT NOCOPY NUMBER,
    x_unit_cd                      IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_sequence_number              IN     NUMBER,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_unit_class                   IN     VARCHAR2,
    x_unit_mode                    IN     VARCHAR2,
    x_location_cd                  IN     VARCHAR2,
    x_due_dt                       IN     DATE,
    x_reference                    IN     VARCHAR2,
    x_dflt_item_ind                IN     VARCHAR2,
    x_logical_delete_dt            IN     DATE,
    x_action_dt                    IN     DATE,
    x_exam_cal_type                IN     VARCHAR2,
    x_exam_ci_sequence_number      IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_org_id                       IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_release_date                 IN     DATE,
    x_description                  IN     VARCHAR2 DEFAULT NULL,
    x_unit_ass_item_group_id       IN     VARCHAR2 DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL
  );

  PROCEDURE delete_row (x_rowid IN VARCHAR2);

  FUNCTION get_pk_for_validation (x_unit_ass_item_id IN NUMBER)
    RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_unit_cd                      IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_sequence_number              IN     NUMBER
  )
    RETURN BOOLEAN;

  PROCEDURE get_fk_igs_as_assessmnt_itm (x_ass_id IN NUMBER);

  PROCEDURE get_fk_igs_ca_type (x_cal_type IN VARCHAR2);

  -- ADDED BY DDEY FOR BUG # 2162831
  PROCEDURE get_fk_igs_as_grd_schema (
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                     IN     VARCHAR2,
    x_sequence_number              IN     NUMBER
  );

  PROCEDURE get_fk_igs_ad_location (x_location_cd IN VARCHAR2);

  PROCEDURE get_fk_igs_as_unit_class (x_unit_class IN VARCHAR2);

  PROCEDURE get_fk_igs_as_unit_mode (x_unit_mode IN VARCHAR2);

  PROCEDURE get_fk_igs_as_unit_ai_grp (x_unit_ass_item_group_id IN NUMBER);

  PROCEDURE get_fk_igs_ps_unit_ofr_pat (
    x_unit_cd                      IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER
  );

  PROCEDURE check_constraints (
    column_name                    IN     VARCHAR2 DEFAULT NULL,
    column_value                   IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE before_dml (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2 DEFAULT NULL,
    x_unit_ass_item_id             IN     NUMBER DEFAULT NULL,
    x_unit_cd                      IN     VARCHAR2 DEFAULT NULL,
    x_version_number               IN     NUMBER DEFAULT NULL,
    x_cal_type                     IN     VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number           IN     NUMBER DEFAULT NULL,
    x_ass_id                       IN     NUMBER DEFAULT NULL,
    x_sequence_number              IN     NUMBER DEFAULT NULL,
    x_ci_start_dt                  IN     DATE DEFAULT NULL,
    x_ci_end_dt                    IN     DATE DEFAULT NULL,
    x_unit_class                   IN     VARCHAR2 DEFAULT NULL,
    x_unit_mode                    IN     VARCHAR2 DEFAULT NULL,
    x_location_cd                  IN     VARCHAR2 DEFAULT NULL,
    x_due_dt                       IN     DATE DEFAULT NULL,
    x_reference                    IN     VARCHAR2 DEFAULT NULL,
    x_dflt_item_ind                IN     VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt            IN     DATE DEFAULT NULL,
    x_action_dt                    IN     DATE DEFAULT NULL,
    x_exam_cal_type                IN     VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number      IN     NUMBER DEFAULT NULL,
    x_creation_date                IN     DATE DEFAULT NULL,
    x_created_by                   IN     NUMBER DEFAULT NULL,
    x_last_update_date             IN     DATE DEFAULT NULL,
    x_last_updated_by              IN     NUMBER DEFAULT NULL,
    x_last_update_login            IN     NUMBER DEFAULT NULL,
    x_org_id                       IN     NUMBER DEFAULT NULL,
    x_grading_schema_cd            IN     VARCHAR2 DEFAULT NULL,
    x_gs_version_number            IN     NUMBER DEFAULT NULL,
    x_release_date                 IN     DATE DEFAULT NULL,
    x_description                  IN     VARCHAR2 DEFAULT NULL,
    x_unit_ass_item_group_id       IN     VARCHAR2 DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL
  );
END igs_as_unitass_item_pkg;

 

/
