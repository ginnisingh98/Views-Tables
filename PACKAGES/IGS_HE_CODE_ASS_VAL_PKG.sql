--------------------------------------------------------
--  DDL for Package IGS_HE_CODE_ASS_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_CODE_ASS_VAL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI02S.pls 115.3 2002/11/29 04:34:32 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER,
    x_association_type                  IN     VARCHAR2,
    x_main_source                       IN     VARCHAR2,
    x_secondary_source                  IN     VARCHAR2,
    x_condition                         IN     VARCHAR2,
    x_display_title                     IN     VARCHAR2,
    x_system_defined                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER,
    x_association_type                  IN     VARCHAR2,
    x_main_source                       IN     VARCHAR2,
    x_secondary_source                  IN     VARCHAR2,
    x_condition                         IN     VARCHAR2,
    x_display_title                     IN     VARCHAR2,
    x_system_defined                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER,
    x_association_type                  IN     VARCHAR2,
    x_main_source                       IN     VARCHAR2,
    x_secondary_source                  IN     VARCHAR2,
    x_condition                         IN     VARCHAR2,
    x_display_title                     IN     VARCHAR2,
    x_system_defined                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER,
    x_association_type                  IN     VARCHAR2,
    x_main_source                       IN     VARCHAR2,
    x_secondary_source                  IN     VARCHAR2,
    x_condition                         IN     VARCHAR2,
    x_display_title                     IN     VARCHAR2,
    x_system_defined                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_code_assoc (
    x_association_code                  IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_association_code                  IN     VARCHAR2    DEFAULT NULL,
    x_sequence                          IN     NUMBER      DEFAULT NULL,
    x_association_type                  IN     VARCHAR2    DEFAULT NULL,
    x_main_source                       IN     VARCHAR2    DEFAULT NULL,
    x_secondary_source                  IN     VARCHAR2    DEFAULT NULL,
    x_condition                         IN     VARCHAR2    DEFAULT NULL,
    x_display_title                     IN     VARCHAR2    DEFAULT NULL,
    x_system_defined                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_code_ass_val_pkg;

 

/
