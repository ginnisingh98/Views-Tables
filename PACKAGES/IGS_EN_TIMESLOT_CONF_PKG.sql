--------------------------------------------------------
--  DDL for Package IGS_EN_TIMESLOT_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_TIMESLOT_CONF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI43S.pls 115.3 2002/11/28 23:42:57 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_timeslot_conf_id           IN OUT NOCOPY NUMBER,
    x_timeslot_name                     IN     VARCHAR2,
    x_start_dt_alias                    IN     VARCHAR2,
    x_end_dt_alias                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_org_id 				IN     NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_en_timeslot_conf_id           IN     NUMBER,
    x_timeslot_name                     IN     VARCHAR2,
    x_start_dt_alias                    IN     VARCHAR2,
    x_end_dt_alias                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_en_timeslot_conf_id           IN     NUMBER,
    x_timeslot_name                     IN     VARCHAR2,
    x_start_dt_alias                    IN     VARCHAR2,
    x_end_dt_alias                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_timeslot_conf_id           IN OUT NOCOPY NUMBER,
    x_timeslot_name                     IN     VARCHAR2,
    x_start_dt_alias                    IN     VARCHAR2,
    x_end_dt_alias                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_org_id 				IN     NUMBER
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_igs_en_timeslot_conf_id           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_timeslot_name                     IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk2_for_validation (
    x_start_dt_alias                    IN     VARCHAR2,
    x_end_dt_alias                      IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_da (
    x_dt_alias                          IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_en_timeslot_conf_id           IN     NUMBER      DEFAULT NULL,
    x_timeslot_name                     IN     VARCHAR2    DEFAULT NULL,
    x_start_dt_alias                    IN     VARCHAR2    DEFAULT NULL,
    x_end_dt_alias                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_org_id 				IN     NUMBER  	   DEFAULT NULL
  );

END igs_en_timeslot_conf_pkg;

 

/
