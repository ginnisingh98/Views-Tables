--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_SP_FEES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_SP_FEES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3MS.pls 115.0 2003/11/11 11:13:49 sarakshi noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usec_sp_fees_id                   IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_sp_fee_amt                        IN     NUMBER,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_usec_sp_fees_id                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_sp_fee_amt                        IN     NUMBER,
    x_closed_flag                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_usec_sp_fees_id                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_sp_fee_amt                        IN     NUMBER,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_usec_sp_fees_id                   IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_sp_fee_amt                        IN     NUMBER,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_usec_sp_fees_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_fee_type (
    x_fee_type                          IN     VARCHAR2
  );

  PROCEDURE Check_Constraints(
    column_name     IN      VARCHAR2        DEFAULT NULL,
    column_value    IN      VARCHAR2        DEFAULT NULL
  );


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_usec_sp_fees_id                   IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_sp_fee_amt                        IN     NUMBER      DEFAULT NULL,
    x_closed_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_usec_sp_fees_pkg;

 

/
