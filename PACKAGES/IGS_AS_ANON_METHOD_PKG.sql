--------------------------------------------------------
--  DDL for Package IGS_AS_ANON_METHOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_ANON_METHOD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI60S.pls 115.1 2002/11/28 23:26:04 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_load_cal_type                     IN OUT NOCOPY VARCHAR2,
    x_method                            IN     VARCHAR2,
    x_assessment_type                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_method                            IN     VARCHAR2,
    x_assessment_type                   IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_method                            IN     VARCHAR2,
    x_assessment_type                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_load_cal_type                     IN OUT NOCOPY VARCHAR2,
    x_method                            IN     VARCHAR2,
    x_assessment_type                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_load_cal_type                     IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_as_assessmnt_typ (
    x_assessment_type                   IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ca_type (
    x_cal_type                          IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_load_cal_type                     IN     VARCHAR2    DEFAULT NULL,
    x_method                            IN     VARCHAR2    DEFAULT NULL,
    x_assessment_type                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_anon_method_pkg;

 

/