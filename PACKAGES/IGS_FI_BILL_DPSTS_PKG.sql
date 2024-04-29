--------------------------------------------------------
--  DDL for Package IGS_FI_BILL_DPSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_BILL_DPSTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIC5S.pls 115.0 2002/12/05 07:16:15 shtatiko noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_bill_id                           IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_bill_id                           IN     NUMBER,
    x_credit_activity_id                IN     NUMBER
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_bill_id                           IN     NUMBER,
    x_credit_activity_id                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_bill (
    x_bill_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_cr_activities (
    x_credit_activity_id                IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_credit_activity_id                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_bill_dpsts_pkg;

 

/
