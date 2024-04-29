--------------------------------------------------------
--  DDL for Package IGS_EN_NSC_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_NSC_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI62S.pls 115.2 2002/11/28 23:47:39 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_opt_type                          IN     VARCHAR2,
    x_opt_val                           IN     VARCHAR2,
    x_priority                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_opt_type                          IN     VARCHAR2,
    x_opt_val                           IN     VARCHAR2,
    x_priority                          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_opt_type                          IN     VARCHAR2,
    x_opt_val                           IN     VARCHAR2,
    x_priority                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_opt_type                          IN     VARCHAR2,
    x_opt_val                           IN     VARCHAR2,
    x_priority                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_uk_for_validation (
    x_opt_type                          IN     VARCHAR2,
    x_opt_val                           IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_opt_type                          IN     VARCHAR2    DEFAULT NULL,
    x_opt_val                           IN     VARCHAR2    DEFAULT NULL,
    x_priority                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_nsc_options_pkg;

 

/
