--------------------------------------------------------
--  DDL for Package IGF_SE_PAYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SE_PAYMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFSI02S.pls 120.0 2005/06/01 14:06:21 appldev noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGF_SE_PAYMENT_PKG
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | This package has a flag on the end of some of the procedures called   |
 | X_MODE. Pass either 'R' for runtime, or 'I' for Install-time.         |
 | This will control how the who columns are filled in; If you are       |
 | running in runtime mode, they are taken from the profiles, whereas in |
 | install-time mode they get defaulted with special values to indicate  |
 | that they were inserted by datamerge.                                 |
 |                                                                       |
 | The ADD_ROW routine will see whether a row exists by selecting        |
 | based on the primary key, and updates the row if it exists,           |
 | or inserts the row if it doesn't already exist.                       |
 |                                                                       |
 | This module is called by AutoInstall (afplss.drv) on install and      |
 | upgrade.  The WHENEVER SQLERROR and EXIT (at bottom) are required.    |
 |                                                                       |
 | HISTORY                                                               |
 | Who             When         What                                     |
 | veramach        July 2004    Obsoleted ld_cal_type,ld_sequence_number,|
 |                              hrs_worked                               |
 *=======================================================================*/

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_transaction_id                    IN OUT NOCOPY NUMBER,
    x_payroll_id                        IN     NUMBER,
    x_payroll_date                      IN     DATE,
    x_auth_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_paid_amount                       IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_source                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_transaction_id                    IN     NUMBER,
    x_payroll_id                        IN     NUMBER,
    x_payroll_date                      IN     DATE,
    x_auth_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_paid_amount                       IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_source                            IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_transaction_id                    IN     NUMBER,
    x_payroll_id                        IN     NUMBER,
    x_payroll_date                      IN     DATE,
    x_auth_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_paid_amount                       IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_source                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_transaction_id                    IN OUT NOCOPY NUMBER,
    x_payroll_id                        IN     NUMBER,
    x_payroll_date                      IN     DATE,
    x_auth_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_paid_amount                       IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_source                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_transaction_id                    IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_transaction_id                    IN     NUMBER      DEFAULT NULL,
    x_payroll_id                        IN     NUMBER      DEFAULT NULL,
    x_payroll_date                      IN     DATE        DEFAULT NULL,
    x_auth_id                           IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_paid_amount                       IN     NUMBER      DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_source                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_se_payment_pkg;

 

/
