--------------------------------------------------------
--  DDL for Package IGS_EN_DL_OFFSET_CONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_DL_OFFSET_CONS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI45S.pls 120.0 2005/06/01 22:11:29 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_enr_dl_offset_cons_id             IN OUT NOCOPY NUMBER,
    x_offset_cons_type_cd               IN     VARCHAR2,
    x_constraint_condition              IN     VARCHAR2,
    x_constraint_resolution             IN     NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_deadline_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_enr_dl_offset_cons_id             IN     NUMBER,
    x_offset_cons_type_cd               IN     VARCHAR2,
    x_constraint_condition              IN     VARCHAR2,
    x_constraint_resolution             IN     NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_deadline_type                     IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_enr_dl_offset_cons_id             IN     NUMBER,
    x_offset_cons_type_cd               IN     VARCHAR2,
    x_constraint_condition              IN     VARCHAR2,
    x_constraint_resolution             IN     NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_deadline_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_enr_dl_offset_cons_id             IN OUT NOCOPY NUMBER,
    x_offset_cons_type_cd               IN     VARCHAR2,
    x_constraint_condition              IN     VARCHAR2,
    x_constraint_resolution             IN     NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_deadline_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_enr_dl_offset_cons_id             IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_offset_cons_type_cd               IN     VARCHAR2,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_deadline_type                     IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_nsu_dlstp_all (
    x_non_std_usec_dls_id               IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_nsus_rtn(
    x_non_std_usec_dls_id               IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_enr_dl_offset_cons_id             IN     NUMBER      DEFAULT NULL,
    x_offset_cons_type_cd               IN     VARCHAR2    DEFAULT NULL,
    x_constraint_condition              IN     VARCHAR2    DEFAULT NULL,
    x_constraint_resolution             IN     NUMBER      DEFAULT NULL,
    x_non_std_usec_dls_id               IN     NUMBER      DEFAULT NULL,
    x_deadline_type                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE check_constraints(
                                Column_Name     IN      VARCHAR2        DEFAULT NULL,
                                Column_Value    IN      VARCHAR2        DEFAULT NULL);


END igs_en_dl_offset_cons_pkg;

 

/
