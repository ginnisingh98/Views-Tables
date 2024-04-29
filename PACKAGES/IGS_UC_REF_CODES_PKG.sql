--------------------------------------------------------
--  DDL for Package IGS_UC_REF_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_REF_CODES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI26S.pls 115.4 2003/06/11 14:35:46 rgangara noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_code_type                         IN     VARCHAR2,
    x_code                              IN     VARCHAR2,
    x_code_text                         IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_code_type                         IN     VARCHAR2,
    x_code                              IN     VARCHAR2,
    x_code_text                         IN     VARCHAR2,
    x_imported                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_code_type                         IN     VARCHAR2,
    x_code                              IN     VARCHAR2,
    x_code_text                         IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_code_type                         IN     VARCHAR2,
    x_code                              IN     VARCHAR2,
    x_code_text                         IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_code_type                         IN     VARCHAR2,
    x_code                              IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_ref_codetyps (
    x_code_type                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_code_type                         IN     VARCHAR2    DEFAULT NULL,
    x_code                              IN     VARCHAR2    DEFAULT NULL,
    x_code_text                         IN     VARCHAR2    DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_ref_codes_pkg;

 

/
