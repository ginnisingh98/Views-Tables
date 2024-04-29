--------------------------------------------------------
--  DDL for Package IGS_UC_REF_PRE2KPOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_REF_PRE2KPOC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI47S.pls 115.3 2002/11/29 04:58:30 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pocc                              IN     NUMBER,
    x_social_class                      IN     NUMBER,
    x_occupation_text                   IN     VARCHAR2,
    x_alternative_text                  IN     VARCHAR2,
    x_alternate_class1                  IN     NUMBER,
    x_alternate_class2                  IN     NUMBER,
    x_imported                          IN     VARCHAR2    DEFAULT 'N',
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_pocc                              IN     NUMBER,
    x_social_class                      IN     NUMBER,
    x_occupation_text                   IN     VARCHAR2,
    x_alternative_text                  IN     VARCHAR2,
    x_alternate_class1                  IN     NUMBER,
    x_alternate_class2                  IN     NUMBER,
    x_imported                          IN     VARCHAR2   DEFAULT 'N'
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_pocc                              IN     NUMBER,
    x_social_class                      IN     NUMBER,
    x_occupation_text                   IN     VARCHAR2,
    x_alternative_text                  IN     VARCHAR2,
    x_alternate_class1                  IN     NUMBER,
    x_alternate_class2                  IN     NUMBER,
    x_imported                          IN     VARCHAR2    DEFAULT 'N',
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pocc                              IN     NUMBER,
    x_social_class                      IN     NUMBER,
    x_occupation_text                   IN     VARCHAR2,
    x_alternative_text                  IN     VARCHAR2,
    x_alternate_class1                  IN     NUMBER,
    x_alternate_class2                  IN     NUMBER,
    x_imported                          IN     VARCHAR2    DEFAULT 'N',
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_pocc                              IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_pocc                              IN     NUMBER      DEFAULT NULL,
    x_social_class                      IN     NUMBER      DEFAULT NULL,
    x_occupation_text                   IN     VARCHAR2    DEFAULT NULL,
    x_alternative_text                  IN     VARCHAR2    DEFAULT NULL,
    x_alternate_class1                  IN     NUMBER      DEFAULT NULL,
    x_alternate_class2                  IN     NUMBER      DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT 'N',
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_ref_pre2kpoc_pkg;

 

/
