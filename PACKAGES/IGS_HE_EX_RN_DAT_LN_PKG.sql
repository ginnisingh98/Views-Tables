--------------------------------------------------------
--  DDL for Package IGS_HE_EX_RN_DAT_LN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_EX_RN_DAT_LN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI09S.pls 115.7 2003/08/23 12:02:59 pmarada noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rn_dat_ln_id                      IN OUT NOCOPY NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_record_id                         IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_manually_inserted                 IN     VARCHAR2,
    x_exclude_from_file                 IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_student_inst_number               IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_recalculate_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rn_dat_ln_id                      IN     NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_record_id                         IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_manually_inserted                 IN     VARCHAR2,
    x_exclude_from_file                 IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_student_inst_number               IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_recalculate_flag                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_rn_dat_ln_id                      IN     NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_record_id                         IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_manually_inserted                 IN     VARCHAR2,
    x_exclude_from_file                 IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_student_inst_number               IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_recalculate_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rn_dat_ln_id                      IN OUT NOCOPY NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_record_id                         IN     VARCHAR2,
    x_line_number                       IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_manually_inserted                 IN     VARCHAR2,
    x_exclude_from_file                 IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_student_inst_number               IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_recalculate_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_ext_run_dtls (
    x_extract_run_id                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rn_dat_ln_id                      IN     NUMBER      DEFAULT NULL,
    x_extract_run_id                    IN     NUMBER      DEFAULT NULL,
    x_record_id                         IN     VARCHAR2    DEFAULT NULL,
    x_line_number                       IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_manually_inserted                 IN     VARCHAR2    DEFAULT NULL,
    x_exclude_from_file                 IN     VARCHAR2    DEFAULT NULL,
    x_crv_version_number                IN     NUMBER      DEFAULT NULL,
    x_student_inst_number               IN     VARCHAR2    DEFAULT NULL,
    x_uv_version_number                 IN     NUMBER      DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_recalculate_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_ex_rn_dat_ln_pkg;

 

/
