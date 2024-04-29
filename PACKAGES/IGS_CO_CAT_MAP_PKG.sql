--------------------------------------------------------
--  DDL for Package IGS_CO_CAT_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_CAT_MAP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI04S.pls 115.5 2002/11/29 01:03:12 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_correspondence_cat                IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_dflt_cat_ind                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_correspondence_cat                IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_dflt_cat_ind                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_correspondence_cat                IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_dflt_cat_ind                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_correspondence_cat                IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_dflt_cat_ind                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE check_constraints (
    column_name                         IN     VARCHAR2    DEFAULT NULL,
    column_value                        IN     VARCHAR2    DEFAULT NULL
  );

  FUNCTION get_pk_for_validation (
    x_correspondence_cat                IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_co_cat (
    x_correspondence_cat                IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ad_cat (
    x_admission_cat                     IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_correspondence_cat                IN     VARCHAR2    DEFAULT NULL,
    x_admission_cat                     IN     VARCHAR2    DEFAULT NULL,
    x_dflt_cat_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_co_cat_map_pkg;

 

/
