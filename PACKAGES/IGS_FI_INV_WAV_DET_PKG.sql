--------------------------------------------------------
--  DDL for Package IGS_FI_INV_WAV_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_INV_WAV_DET_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIB9S.pls 115.3 2002/11/29 04:06:06 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_invoice_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_start_dt                          IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_inv_int_all (
    x_invoice_id                        IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_balance_type                      IN     VARCHAR2    DEFAULT NULL,
    x_start_dt                          IN     DATE        DEFAULT NULL,
    x_end_dt                            IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_inv_wav_det_pkg;

 

/
