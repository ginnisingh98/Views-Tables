--------------------------------------------------------
--  DDL for Package IGS_EN_TIMESLOT_PARA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_TIMESLOT_PARA_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI41S.pls 115.3 2002/11/28 23:42:25 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_timeslot_para_id           IN OUT NOCOPY NUMBER,
    x_program_type_group_cd             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_student_type                      IN     VARCHAR2,
    x_timeslot_calendar                 IN     VARCHAR2,
    x_timeslot_st_time                  IN     DATE,
    x_timeslot_end_time                 IN     DATE,
    x_ts_mode                           IN     VARCHAR2,
    x_max_head_count                    IN     NUMBER,
    x_length_of_time                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_org_id 				IN     NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_en_timeslot_para_id           IN     NUMBER,
    x_program_type_group_cd             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_student_type                      IN     VARCHAR2,
    x_timeslot_calendar                 IN     VARCHAR2,
    x_timeslot_st_time                  IN     DATE,
    x_timeslot_end_time                 IN     DATE,
    x_ts_mode                           IN     VARCHAR2,
    x_max_head_count                    IN     NUMBER,
    x_length_of_time                    IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_en_timeslot_para_id           IN     NUMBER,
    x_program_type_group_cd             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_student_type                      IN     VARCHAR2,
    x_timeslot_calendar                 IN     VARCHAR2,
    x_timeslot_st_time                  IN     DATE,
    x_timeslot_end_time                 IN     DATE,
    x_ts_mode                           IN     VARCHAR2,
    x_max_head_count                    IN     NUMBER,
    x_length_of_time                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_timeslot_para_id           IN OUT NOCOPY NUMBER,
    x_program_type_group_cd             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_student_type                      IN     VARCHAR2,
    x_timeslot_calendar                 IN     VARCHAR2,
    x_timeslot_st_time                  IN     DATE,
    x_timeslot_end_time                 IN     DATE,
    x_ts_mode                           IN     VARCHAR2,
    x_max_head_count                    IN     NUMBER,
    x_length_of_time                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_org_id  				IN     NUMBER  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_igs_en_timeslot_para_id           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_EN_TIMESLOT_CONF (
    X_TIMESLOT_NAME   IN VARCHAR2
    );

  FUNCTION get_uk_for_validation (
    x_program_type_group_cd             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_student_type                      IN     VARCHAR2,
    x_timeslot_calendar                 IN     VARCHAR2,
    x_ts_mode                           IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_en_timeslot_para_id           IN     NUMBER      DEFAULT NULL,
    x_program_type_group_cd             IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_student_type                      IN     VARCHAR2    DEFAULT NULL,
    x_timeslot_calendar                 IN     VARCHAR2    DEFAULT NULL,
    x_timeslot_st_time                  IN     DATE        DEFAULT NULL,
    x_timeslot_end_time                 IN     DATE        DEFAULT NULL,
    x_ts_mode                           IN     VARCHAR2    DEFAULT NULL,
    x_max_head_count                    IN     NUMBER      DEFAULT NULL,
    x_length_of_time                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_org_id 				IN     NUMBER      DEFAULT NULL
  );

END igs_en_timeslot_para_pkg;

 

/
