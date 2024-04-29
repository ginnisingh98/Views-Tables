--------------------------------------------------------
--  DDL for Package IGS_FI_REFUND_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_REFUND_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIB3S.pls 115.8 2002/11/29 04:04:07 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_refund_setup_id                   IN OUT NOCOPY NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_amount_high                       IN     NUMBER,
    x_amount_low                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_refund_setup_id                   IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_amount_high                       IN     NUMBER,
    x_amount_low                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_refund_setup_id                   IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_amount_high                       IN     NUMBER,
    x_amount_low                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_refund_setup_id                   IN OUT NOCOPY NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_amount_high                       IN     NUMBER,
    x_amount_low                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_refund_setup_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_refund_setup_id                   IN     NUMBER      DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_amount_high                       IN     NUMBER      DEFAULT NULL,
    x_amount_low                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_refund_setup_pkg;

 

/
