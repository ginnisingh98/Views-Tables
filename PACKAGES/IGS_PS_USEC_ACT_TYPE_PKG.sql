--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_ACT_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_ACT_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2JS.pls 115.3 2002/11/29 02:17:18 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_activity_type_id                  IN OUT NOCOPY NUMBER,
    x_activity_type_code                IN     VARCHAR2,
    x_activity_type_description         IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_activity_type_id                  IN     NUMBER,
    x_activity_type_code                IN     VARCHAR2,
    x_activity_type_description         IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_activity_type_id                  IN     NUMBER,
    x_activity_type_code                IN     VARCHAR2,
    x_activity_type_description         IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_activity_type_id                  IN OUT NOCOPY NUMBER,
    x_activity_type_code                IN     VARCHAR2,
    x_activity_type_description         IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_activity_type_id                  IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_activity_type_code                IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_activity_type_id                  IN     NUMBER      DEFAULT NULL,
    x_activity_type_code                IN     VARCHAR2    DEFAULT NULL,
    x_activity_type_description         IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_usec_act_type_pkg;

 

/
