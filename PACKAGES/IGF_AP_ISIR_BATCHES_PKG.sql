--------------------------------------------------------
--  DDL for Package IGF_AP_ISIR_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_ISIR_BATCHES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI06S.pls 115.5 2002/11/28 13:55:23 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_number                      IN     VARCHAR2,
    x_batch_year                        IN     VARCHAR2,
    x_batch_type                        IN     VARCHAR2,
    x_batch_count                       IN     NUMBER,
    x_tran_source_site                  IN     NUMBER,
    x_stud_rec_count                    IN     NUMBER,
    x_err_rec_count                     IN     NUMBER,
    x_not_on_db_count                   IN     NUMBER,
    x_batch_creation_date               IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_number                      IN     VARCHAR2,
    x_batch_year                        IN     VARCHAR2,
    x_batch_type                        IN     VARCHAR2,
    x_batch_count                       IN     NUMBER,
    x_tran_source_site                  IN     NUMBER,
    x_stud_rec_count                    IN     NUMBER,
    x_err_rec_count                     IN     NUMBER,
    x_not_on_db_count                   IN     NUMBER,
    x_batch_creation_date               IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_number                      IN     VARCHAR2,
    x_batch_year                        IN     VARCHAR2,
    x_batch_type                        IN     VARCHAR2,
    x_batch_count                       IN     NUMBER,
    x_tran_source_site                  IN     NUMBER,
    x_stud_rec_count                    IN     NUMBER,
    x_err_rec_count                     IN     NUMBER,
    x_not_on_db_count                   IN     NUMBER,
    x_batch_creation_date               IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_number                      IN     VARCHAR2,
    x_batch_year                        IN     VARCHAR2,
    x_batch_type                        IN     VARCHAR2,
    x_batch_count                       IN     NUMBER,
    x_tran_source_site                  IN     NUMBER,
    x_stud_rec_count                    IN     NUMBER,
    x_err_rec_count                     IN     NUMBER,
    x_not_on_db_count                   IN     NUMBER,
    x_batch_creation_date               IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_batch_number                      IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_number                      IN     VARCHAR2    DEFAULT NULL,
    x_batch_year                        IN     VARCHAR2    DEFAULT NULL,
    x_batch_type                        IN     VARCHAR2    DEFAULT NULL,
    x_batch_count                       IN     NUMBER      DEFAULT NULL,
    x_tran_source_site                  IN     NUMBER      DEFAULT NULL,
    x_stud_rec_count                    IN     NUMBER      DEFAULT NULL,
    x_err_rec_count                     IN     NUMBER      DEFAULT NULL,
    x_not_on_db_count                   IN     NUMBER      DEFAULT NULL,
    x_batch_creation_date               IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_isir_batches_pkg;

 

/
