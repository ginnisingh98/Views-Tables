--------------------------------------------------------
--  DDL for Package IGI_IAC_PROJECTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_PROJECTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: igiiapjs.pls 120.4.12000000.1 2007/08/01 16:16:00 npandya ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_projection_id                     IN OUT NOCOPY NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_start_period_counter              IN     NUMBER,
    x_end_period                        IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_revaluation_period                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_projection_id                     IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_start_period_counter              IN     NUMBER,
    x_end_period                        IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_revaluation_period                IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_projection_id                     IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_start_period_counter              IN     NUMBER,
    x_end_period                        IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_revaluation_period                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_projection_id                     IN OUT NOCOPY NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_start_period_counter              IN     NUMBER,
    x_end_period                        IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_revaluation_period                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_projection_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_projection_id                     IN     NUMBER      DEFAULT NULL,
    x_book_type_code                    IN     VARCHAR2    DEFAULT NULL,
    x_start_period_counter              IN     NUMBER      DEFAULT NULL,
    x_end_period                        IN     NUMBER      DEFAULT NULL,
    x_category_id                       IN     NUMBER      DEFAULT NULL,
    x_revaluation_period                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igi_iac_projections_pkg;

 

/
