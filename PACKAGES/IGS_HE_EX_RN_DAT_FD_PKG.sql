--------------------------------------------------------
--  DDL for Package IGS_HE_EX_RN_DAT_FD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_EX_RN_DAT_FD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI08S.pls 115.4 2002/11/29 04:36:43 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rn_dat_fd_id                      IN OUT NOCOPY NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_value                             IN     VARCHAR2,
    x_override_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rn_dat_fd_id                      IN     NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_value                             IN     VARCHAR2,
    x_override_value                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_rn_dat_fd_id                      IN     NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_value                             IN     VARCHAR2,
    x_override_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rn_dat_fd_id                      IN OUT NOCOPY NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_value                             IN     VARCHAR2,
    x_override_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_ex_rn_dat_ln (
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rn_dat_fd_id                      IN     NUMBER      DEFAULT NULL,
    x_extract_run_id                    IN     NUMBER      DEFAULT NULL,
    x_line_number                       IN     NUMBER      DEFAULT NULL,
    x_field_number                      IN     NUMBER      DEFAULT NULL,
    x_value                             IN     VARCHAR2    DEFAULT NULL,
    x_override_value                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_ex_rn_dat_fd_pkg;

 

/
