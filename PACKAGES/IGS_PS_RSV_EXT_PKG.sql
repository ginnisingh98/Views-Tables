--------------------------------------------------------
--  DDL for Package IGS_PS_RSV_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_RSV_EXT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2WS.pls 115.5 2003/02/19 13:55:03 shtatiko ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rsv_ext_id                        IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_id                       IN     NUMBER,
    x_preference_id                     IN     NUMBER,
    x_rsv_level                         IN     VARCHAR2,
    x_actual_seat_enrolled              IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rsv_ext_id                        IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_id                       IN     NUMBER,
    x_preference_id                     IN     NUMBER,
    x_rsv_level                         IN     VARCHAR2,
    x_actual_seat_enrolled              IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_rsv_ext_id                        IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_id                       IN     NUMBER,
    x_preference_id                     IN     NUMBER,
    x_rsv_level                         IN     VARCHAR2,
    x_actual_seat_enrolled              IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rsv_ext_id                        IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_id                       IN     NUMBER,
    x_preference_id                     IN     NUMBER,
    x_rsv_level                         IN     VARCHAR2,
    x_actual_seat_enrolled              IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_rsv_ext_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_uoo_id                            IN     NUMBER,
    x_priority_id                       IN     NUMBER,
    x_preference_id                     IN     NUMBER,
    x_rsv_level                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rsv_ext_id                        IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_priority_id                       IN     NUMBER      DEFAULT NULL,
    x_preference_id                     IN     NUMBER      DEFAULT NULL,
    x_rsv_level                         IN     VARCHAR2    DEFAULT NULL,
    x_actual_seat_enrolled              IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_rsv_ext_pkg;

 

/
