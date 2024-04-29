--------------------------------------------------------
--  DDL for Package IGR_I_INQUIRY_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_INQUIRY_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSRH19S.pls 120.0 2005/06/01 19:02:21 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inquiry_type_id                   IN OUT NOCOPY NUMBER,
    x_inquiry_type_cd                   IN     VARCHAR2,
    x_inquiry_type_desc                 IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_imp_source_type_id                IN     NUMBER,
    x_info_type_id                      IN     NUMBER,
    x_configurability_func_name         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_inquiry_type_id                   IN     NUMBER,
    x_inquiry_type_cd                   IN     VARCHAR2,
    x_inquiry_type_desc                 IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_imp_source_type_id                IN     NUMBER,
    x_info_type_id                      IN     NUMBER,
    x_configurability_func_name         IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_inquiry_type_id                   IN     NUMBER,
    x_inquiry_type_cd                   IN     VARCHAR2,
    x_inquiry_type_desc                 IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_imp_source_type_id                IN     NUMBER,
    x_info_type_id                      IN     NUMBER,
    x_configurability_func_name         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inquiry_type_id                   IN OUT NOCOPY NUMBER,
    x_inquiry_type_cd                   IN     VARCHAR2,
    x_inquiry_type_desc                 IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_imp_source_type_id                IN     NUMBER,
    x_info_type_id                      IN     NUMBER,
    x_configurability_func_name         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_inquiry_type_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_inquiry_type_cd                   IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pe_src_types (
    x_source_type_id                    IN     NUMBER
  );

   PROCEDURE get_fk_igr_i_pkg_item (
    x_package_item_id                     IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_inquiry_type_id                   IN     NUMBER      DEFAULT NULL,
    x_inquiry_type_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_inquiry_type_desc                 IN     VARCHAR2    DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_imp_source_type_id                IN     NUMBER      DEFAULT NULL,
    x_info_type_id                      IN     NUMBER      DEFAULT NULL,
    x_configurability_func_name         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );



END igr_i_inquiry_types_pkg;

 

/
