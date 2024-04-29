--------------------------------------------------------
--  DDL for Package IGF_AW_FUND_ROLLOVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_FUND_ROLLOVER_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI28S.pls 115.5 2002/11/28 14:40:24 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_frol_id                           IN OUT NOCOPY NUMBER,
    x_cr_cal_type                       IN     VARCHAR2,
    x_cr_sequence_number                IN     NUMBER,
    x_sc_sequence_number                IN     NUMBER,
    x_rollover_status                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_frol_id                           IN     NUMBER,
    x_cr_cal_type                       IN     VARCHAR2,
    x_cr_sequence_number                IN     NUMBER,
    x_sc_sequence_number                IN     NUMBER,
    x_rollover_status                   IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_frol_id                           IN     NUMBER,
    x_cr_cal_type                       IN     VARCHAR2,
    x_cr_sequence_number                IN     NUMBER,
    x_sc_sequence_number                IN     NUMBER,
    x_rollover_status                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_frol_id                           IN OUT NOCOPY NUMBER,
    x_cr_cal_type                       IN     VARCHAR2,
    x_cr_sequence_number                IN     NUMBER,
    x_sc_sequence_number                IN     NUMBER,
    x_rollover_status                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_frol_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_cr_cal_type                       IN     VARCHAR2,
    x_cr_sequence_number                IN     NUMBER,
    x_org_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_frol_id                           IN     NUMBER      DEFAULT NULL,
    x_cr_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_cr_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_sc_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_rollover_status                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_fund_rollover_pkg;

 

/
