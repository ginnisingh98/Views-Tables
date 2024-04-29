--------------------------------------------------------
--  DDL for Package IGS_FI_BILL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_BILL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIB6S.pls 115.5 2002/11/29 04:05:08 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_bill_id                           IN OUT NOCOPY NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_due_date                          IN     DATE,
    x_person_id                         IN     NUMBER,
    x_bill_from_date                    IN     DATE,
    x_opening_balance                   IN     NUMBER,
    x_cut_off_date                      IN     DATE,
    x_closing_balance                   IN     NUMBER,
    x_printed_flag                      IN     VARCHAR2,
    x_print_date                        IN     DATE,
    x_to_pay_amount                     IN     NUMBER      DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_due_date                          IN     DATE,
    x_person_id                         IN     NUMBER,
    x_bill_from_date                    IN     DATE,
    x_opening_balance                   IN     NUMBER,
    x_cut_off_date                      IN     DATE,
    x_closing_balance                   IN     NUMBER,
    x_printed_flag                      IN     VARCHAR2,
    x_print_date                        IN     DATE,
    x_to_pay_amount                     IN     NUMBER DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_due_date                          IN     DATE,
    x_person_id                         IN     NUMBER,
    x_bill_from_date                    IN     DATE,
    x_opening_balance                   IN     NUMBER,
    x_cut_off_date                      IN     DATE,
    x_closing_balance                   IN     NUMBER,
    x_printed_flag                      IN     VARCHAR2,
    x_print_date                        IN     DATE,
    x_to_pay_amount                     IN     NUMBER      DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_bill_id                           IN OUT NOCOPY NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_due_date                          IN     DATE,
    x_person_id                         IN     NUMBER,
    x_bill_from_date                    IN     DATE,
    x_opening_balance                   IN     NUMBER,
    x_cut_off_date                      IN     DATE,
    x_closing_balance                   IN     NUMBER,
    x_printed_flag                      IN     VARCHAR2,
    x_print_date                        IN     DATE,
    x_to_pay_amount                     IN     NUMBER      DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_bill_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_cut_off_date                      IN     DATE,
    x_person_id                         IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_bill_number                       IN     VARCHAR2    DEFAULT NULL,
    x_bill_date                         IN     DATE        DEFAULT NULL,
    x_due_date                          IN     DATE        DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_bill_from_date                    IN     DATE        DEFAULT NULL,
    x_opening_balance                   IN     NUMBER      DEFAULT NULL,
    x_cut_off_date                      IN     DATE        DEFAULT NULL,
    x_closing_balance                   IN     NUMBER      DEFAULT NULL,
    x_printed_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_print_date                        IN     DATE        DEFAULT NULL,
    x_to_pay_amount                     IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_bill_pkg;

 

/
