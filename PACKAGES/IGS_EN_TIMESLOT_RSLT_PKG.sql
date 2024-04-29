--------------------------------------------------------
--  DDL for Package IGS_EN_TIMESLOT_RSLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_TIMESLOT_RSLT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI42S.pls 115.4 2002/11/28 23:42:41 nsidana ship $ */
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_timeslot_rslt_id           IN OUT NOCOPY NUMBER,
    x_igs_en_timeslot_para_id           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_start_dt_time                     IN     DATE,
    x_end_dt_time                       IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );
  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_en_timeslot_rslt_id           IN     NUMBER,
    x_igs_en_timeslot_para_id           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_start_dt_time                     IN     DATE,
    x_end_dt_time                       IN     DATE
  );
  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_en_timeslot_rslt_id           IN     NUMBER,
    x_igs_en_timeslot_para_id           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_start_dt_time                     IN     DATE,
    x_end_dt_time                       IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );
  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_timeslot_rslt_id           IN OUT NOCOPY NUMBER,
    x_igs_en_timeslot_para_id           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_start_dt_time                     IN     DATE,
    x_end_dt_time                       IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );
  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );
  FUNCTION get_pk_for_validation (
    x_igs_en_timeslot_rslt_id           IN     NUMBER
  ) RETURN BOOLEAN;
  PROCEDURE get_fk_igs_en_timeslot_para (
    x_igs_en_timeslot_para_id           IN     NUMBER
  );
  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_en_timeslot_rslt_id           IN     NUMBER      DEFAULT NULL,
    x_igs_en_timeslot_para_id           IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_start_dt_time                     IN     DATE        DEFAULT NULL,
    x_end_dt_time                       IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );
END igs_en_timeslot_rslt_pkg;

 

/
