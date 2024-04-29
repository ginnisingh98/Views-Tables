--------------------------------------------------------
--  DDL for Package IGS_FI_1098T_BATCHS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_1098T_BATCHS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIF0S.pls 120.0 2005/09/09 18:20:36 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN OUT NOCOPY NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_batch_name                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_filling_mode                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_batch_name                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_filling_mode                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_batch_name                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_filling_mode                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN OUT NOCOPY NUMBER,
    x_tax_year_name                     IN     VARCHAR2,
    x_batch_name                        IN     VARCHAR2,
    x_file_name                         IN     VARCHAR2,
    x_filling_mode                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_batch_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_batch_name                        IN     VARCHAR2,
    x_tax_year_name                     IN     VARCHAR2
  ) RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_tax_year_name                     IN     VARCHAR2    DEFAULT NULL,
    x_batch_name                        IN     VARCHAR2    DEFAULT NULL,
    x_file_name                         IN     VARCHAR2    DEFAULT NULL,
    x_filling_mode                      IN     VARCHAR2    DEFAULT NULL,
    x_object_version_number             IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_1098t_batchs_pkg;

 

/
