--------------------------------------------------------
--  DDL for Package IGS_CO_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_MAPPING_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI29S.pls 120.0 2005/06/01 20:44:47 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_map_id                            IN OUT NOCOPY NUMBER,
    x_map_code                          IN     VARCHAR2,
    x_doc_code                          IN     VARCHAR2,
    x_document_id                       IN     NUMBER,
    x_enable_flag                       IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_map_description                   IN     VARCHAR2,
    x_elapsed_days                      IN     NUMBER,
    x_repeat_times                      IN     NUMBER,
    x_attr_description                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_map_id                            IN     NUMBER,
    x_map_code                          IN     VARCHAR2,
    x_doc_code                          IN     VARCHAR2,
    x_document_id                       IN     NUMBER,
    x_enable_flag                       IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_map_description                   IN     VARCHAR2,
    x_elapsed_days                      IN     NUMBER,
    x_repeat_times                      IN     NUMBER,
    x_attr_description                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_map_id                            IN     NUMBER,
    x_map_code                          IN     VARCHAR2,
    x_doc_code                          IN     VARCHAR2,
    x_document_id                       IN     NUMBER,
    x_enable_flag                       IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_map_description                   IN     VARCHAR2,
    x_elapsed_days                      IN     NUMBER,
    x_repeat_times                      IN     NUMBER,
    x_attr_description                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_map_id                            IN OUT NOCOPY NUMBER,
    x_map_code                          IN     VARCHAR2,
    x_doc_code                          IN     VARCHAR2,
    x_document_id                       IN     NUMBER,
    x_enable_flag                       IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_map_description                   IN     VARCHAR2,
    x_elapsed_days                      IN     NUMBER,
    x_repeat_times                      IN     NUMBER,
    x_attr_description                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_map_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_document_id                       IN     NUMBER,
    x_map_code                          IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2
  ) RETURN BOOLEAN;

   PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_map_id                            IN     NUMBER      DEFAULT NULL,
    x_map_code                          IN     VARCHAR2    DEFAULT NULL,
    x_doc_code                          IN     VARCHAR2    DEFAULT NULL,
    x_document_id                       IN     NUMBER      DEFAULT NULL,
    x_enable_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_sys_ltr_code                      IN     VARCHAR2    DEFAULT NULL,
    x_map_description                   IN     VARCHAR2    DEFAULT NULL,
    x_elapsed_days                      IN     NUMBER      DEFAULT NULL,
    x_repeat_times                      IN     NUMBER      DEFAULT NULL,
    x_attr_description                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_co_mapping_pkg;

 

/
