--------------------------------------------------------
--  DDL for Package IGS_PS_RSV_USEC_PRI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_RSV_USEC_PRI_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI1WS.pls 115.3 2002/11/29 02:10:45 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rsv_usec_pri_id                   IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_order                    IN     NUMBER,
    x_priority_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rsv_usec_pri_id                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_order                    IN     NUMBER,
    x_priority_value                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_rsv_usec_pri_id                   IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_order                    IN     NUMBER,
    x_priority_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rsv_usec_pri_id                   IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_order                    IN     NUMBER,
    x_priority_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_rsv_usec_pri_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_uoo_id                            IN     NUMBER,
    x_priority_value                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rsv_usec_pri_id                   IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_priority_order                    IN     NUMBER      DEFAULT NULL,
    x_priority_value                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_rsv_usec_pri_pkg;

 

/
