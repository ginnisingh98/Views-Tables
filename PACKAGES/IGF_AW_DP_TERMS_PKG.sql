--------------------------------------------------------
--  DDL for Package IGF_AW_DP_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_DP_TERMS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI60S.pls 115.1 2003/11/21 06:30:06 veramach noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adterms_id                        IN OUT NOCOPY NUMBER,
    x_adplans_id                        IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_adterms_id                        IN     NUMBER,
    x_adplans_id                        IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct_num                      IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_adterms_id                        IN     NUMBER,
    x_adplans_id                        IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adterms_id                        IN OUT NOCOPY NUMBER,
    x_adplans_id                        IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_ld_perct_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ca_inst (
  x_cal_type                          IN     VARCHAR2,
  x_sequence_number                   IN     NUMBER
  );


  FUNCTION get_pk_for_validation (
    x_adterms_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation(
                                 x_adplans_id          IN NUMBER,
                                 x_ld_cal_type         IN VARCHAR2,
                                 x_ld_sequence_number  IN NUMBER
                                ) RETURN BOOLEAN;


  PROCEDURE get_fk_igf_aw_awd_dist_plans (
    x_adplans_id                        IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_adterms_id                        IN     NUMBER      DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ld_perct_num                      IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_dp_terms_pkg;

 

/
