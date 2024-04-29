--------------------------------------------------------
--  DDL for Package IGS_GE_CFG_NAV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_CFG_NAV_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIA2S.pls 115.2 2002/12/30 14:51:50 kumma noship $ */
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER,
    x_subform_code                      IN     VARCHAR2,
    x_but_label                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );
  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER,
    x_subform_code                      IN     VARCHAR2,
    x_but_label                         IN     VARCHAR2
  );
  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER,
    x_subform_code                      IN     VARCHAR2,
    x_but_label                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );
  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER,
    x_subform_code                      IN     VARCHAR2,
    x_but_label                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );
  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );
  FUNCTION get_pk_for_validation (
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_subform_code                      IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER,
    x_but_label                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_responsibility_id                 IN     NUMBER      DEFAULT NULL,
    x_form_code                         IN     VARCHAR2    DEFAULT NULL,
    x_seq_number                        IN     NUMBER      DEFAULT NULL,
    x_subform_code                      IN     VARCHAR2    DEFAULT NULL,
    x_but_label                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );
END igs_ge_cfg_nav_pkg;

 

/
