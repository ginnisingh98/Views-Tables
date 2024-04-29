--------------------------------------------------------
--  DDL for Package IGS_UC_REF_APR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_REF_APR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI24S.pls 115.3 2002/11/29 04:51:39 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dom                               IN OUT NOCOPY NUMBER,
    x_dom_text                          IN     VARCHAR2,
    x_lea_flag                          IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_dom                               IN     NUMBER,
    x_dom_text                          IN     VARCHAR2,
    x_lea_flag                          IN     VARCHAR2,
    x_imported                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_dom                               IN     NUMBER,
    x_dom_text                          IN     VARCHAR2,
    x_lea_flag                          IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dom                               IN OUT NOCOPY NUMBER,
    x_dom_text                          IN     VARCHAR2,
    x_lea_flag                          IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_dom                               IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dom                               IN     NUMBER      DEFAULT NULL,
    x_dom_text                          IN     VARCHAR2    DEFAULT NULL,
    x_lea_flag                          IN     VARCHAR2    DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_ref_apr_pkg;

 

/
