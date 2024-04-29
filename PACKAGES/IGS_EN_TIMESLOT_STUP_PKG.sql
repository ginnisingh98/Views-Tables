--------------------------------------------------------
--  DDL for Package IGS_EN_TIMESLOT_STUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_TIMESLOT_STUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI38S.pls 115.4 2002/11/28 23:41:36 nsidana ship $ */
 PROCEDURE insert_row (
   x_rowid IN OUT NOCOPY VARCHAR2,
   x_sequence_number IN NUMBER,
   x_student_type IN VARCHAR2,
   x_assign_randomly IN VARCHAR2,
   x_surname_alphabet IN VARCHAR2,
   x_cal_type IN VARCHAR2,
   x_igs_en_timeslot_stup_id IN OUT NOCOPY NUMBER,
   x_program_type_group_cd IN VARCHAR2,
   x_mode IN VARCHAR2 DEFAULT 'R' ,
   X_ORG_ID in NUMBER
   );

 PROCEDURE lock_row (
   x_rowid IN VARCHAR2,
   x_sequence_number IN NUMBER,
   x_student_type IN VARCHAR2,
   x_assign_randomly IN VARCHAR2,
   x_surname_alphabet IN VARCHAR2,
   x_cal_type IN VARCHAR2,
   x_igs_en_timeslot_stup_id IN NUMBER,
   x_program_type_group_cd IN VARCHAR2  );

 PROCEDURE update_row (
   x_rowid IN VARCHAR2,
   x_sequence_number IN NUMBER,
   x_student_type IN VARCHAR2,
   x_assign_randomly IN VARCHAR2,
   x_surname_alphabet IN VARCHAR2,
   x_cal_type IN VARCHAR2,
   x_igs_en_timeslot_stup_id IN NUMBER,
   x_program_type_group_cd IN VARCHAR2,
   x_mode IN VARCHAR2 DEFAULT 'R'
  );

 PROCEDURE add_row (
   x_rowid IN OUT NOCOPY VARCHAR2,
   x_sequence_number IN NUMBER,
   x_student_type IN VARCHAR2,
   x_assign_randomly IN VARCHAR2,
   x_surname_alphabet IN VARCHAR2,
   x_cal_type IN VARCHAR2,
   x_igs_en_timeslot_stup_id IN OUT NOCOPY NUMBER,
   x_program_type_group_cd IN VARCHAR2,
   x_mode IN VARCHAR2 DEFAULT 'R' ,
   X_ORG_ID in NUMBER
   );

 PROCEDURE delete_row (
   x_rowid IN VARCHAR2
 ) ;
 FUNCTION get_pk_for_validation (
   x_igs_en_timeslot_stup_id IN NUMBER
   ) RETURN BOOLEAN ;

 FUNCTION get_uk_for_validation (
   x_program_type_group_cd IN VARCHAR2,
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_student_type IN VARCHAR2
   ) RETURN BOOLEAN;

 PROCEDURE get_fk_igs_ca_inst (
   x_cal_type IN VARCHAR2,
   x_sequence_number IN NUMBER
    );

 PROCEDURE get_fk_igs_ps_type_grp (
   x_course_type_group_cd IN VARCHAR2
    );

 PROCEDURE check_constraints (
   column_name IN VARCHAR2  DEFAULT NULL,
   column_value IN VARCHAR2  DEFAULT NULL ) ;
 PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_student_type IN VARCHAR2 DEFAULT NULL,
    x_assign_randomly IN VARCHAR2 DEFAULT NULL,
    x_surname_alphabet IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_igs_en_timeslot_stup_id IN NUMBER DEFAULT NULL,
    x_program_type_group_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL);

END igs_en_timeslot_stup_pkg;

 

/
