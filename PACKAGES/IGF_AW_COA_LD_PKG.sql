--------------------------------------------------------
--  DDL for Package IGF_AW_COA_LD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_COA_LD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI33S.pls 115.5 2002/11/28 14:41:27 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_coald_id                          IN OUT NOCOPY NUMBER,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_coald_id                          IN     NUMBER,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct                          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_coald_id                          IN     NUMBER,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_coald_id                          IN OUT NOCOPY NUMBER,
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_coald_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_org_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_coa_group (
    x_coa_code                          IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_coald_id                          IN     NUMBER      DEFAULT NULL,
    x_coa_code                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ld_perct                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_coa_ld_pkg;

 

/
