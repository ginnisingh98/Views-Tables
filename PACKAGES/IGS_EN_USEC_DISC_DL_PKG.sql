--------------------------------------------------------
--  DDL for Package IGS_EN_USEC_DISC_DL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_USEC_DISC_DL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI49S.pls 115.4 2002/11/28 23:44:31 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usec_disc_dl_id                   IN OUT NOCOPY NUMBER,
    x_non_std_disc_dl_stp_id            IN     NUMBER,
    x_administrative_unit_status        IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_usec_disc_dl_date                 IN     DATE,
    x_usec_disc_total_days              IN     NUMBER,
    x_usec_disc_offset_days             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_usec_disc_dl_id                   IN     NUMBER,
    x_non_std_disc_dl_stp_id            IN     NUMBER,
    x_administrative_unit_status        IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_usec_disc_dl_date                 IN     DATE,
    x_usec_disc_total_days              IN     NUMBER,
    x_usec_disc_offset_days             IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_usec_disc_dl_id                   IN     NUMBER,
    x_non_std_disc_dl_stp_id            IN     NUMBER,
    x_administrative_unit_status        IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_usec_disc_dl_date                 IN     DATE,
    x_usec_disc_total_days              IN     NUMBER,
    x_usec_disc_offset_days             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usec_disc_dl_id                   IN OUT NOCOPY NUMBER,
    x_non_std_disc_dl_stp_id            IN     NUMBER,
    x_administrative_unit_status        IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_usec_disc_dl_date                 IN     DATE,
    x_usec_disc_total_days              IN     NUMBER,
    x_usec_disc_offset_days             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_usec_disc_dl_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_administrative_unit_status        IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_nsd_dlstp_all (
    x_non_std_disc_dl_stp_id            IN     NUMBER
  );

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_usec_disc_dl_id                   IN     NUMBER      DEFAULT NULL,
    x_non_std_disc_dl_stp_id            IN     NUMBER      DEFAULT NULL,
    x_administrative_unit_status        IN     VARCHAR2    DEFAULT NULL,
    x_definition_code                   IN     VARCHAR2    DEFAULT NULL,
    x_org_unit_code                     IN     VARCHAR2    DEFAULT NULL,
    x_formula_method                    IN     VARCHAR2    DEFAULT NULL,
    x_round_method                      IN     VARCHAR2    DEFAULT NULL,
    x_offset_dt_code                    IN     VARCHAR2    DEFAULT NULL,
    x_offset_duration                   IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_usec_disc_dl_date                 IN     DATE        DEFAULT NULL,
    x_usec_disc_total_days              IN     NUMBER      DEFAULT NULL,
    x_usec_disc_offset_days             IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_usec_disc_dl_pkg;

 

/
