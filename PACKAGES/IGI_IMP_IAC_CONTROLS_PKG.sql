--------------------------------------------------------
--  DDL for Package IGI_IMP_IAC_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IMP_IAC_CONTROLS_PKG" AUTHID CURRENT_USER AS
/* $Header: igiimics.pls 120.4.12000000.1 2007/08/01 16:21:17 npandya ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_book_type_code                    IN OUT NOCOPY VARCHAR2,
    x_corp_book                         IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_request_status                    IN     VARCHAR2,
    x_request_id                            IN     NUMBER,
    x_request_date                      IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_book_type_code                    IN     VARCHAR2,
    x_corp_book                         IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_request_status                    IN     VARCHAR2,
    x_request_id                            IN     NUMBER,
    x_request_date                      IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_book_type_code                    IN     VARCHAR2,
    x_corp_book                         IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_request_status                    IN     VARCHAR2,
    x_request_id                            IN     NUMBER,
    x_request_date                      IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_book_type_code                    IN OUT NOCOPY VARCHAR2,
    x_corp_book                         IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_request_status                    IN     VARCHAR2,
    x_request_id                            IN     NUMBER,
    x_request_date                      IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_book_type_code                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_book_type_code                    IN     VARCHAR2    DEFAULT NULL,
    x_corp_book                         IN     VARCHAR2    DEFAULT NULL,
    x_period_counter                    IN     NUMBER      DEFAULT NULL,
    x_request_status                    IN     VARCHAR2    DEFAULT NULL,
    x_request_id                            IN     NUMBER      DEFAULT NULL,
    x_request_date                      IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igi_imp_iac_controls_pkg;

 

/
