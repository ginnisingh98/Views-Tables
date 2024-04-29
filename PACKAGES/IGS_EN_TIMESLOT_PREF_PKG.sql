--------------------------------------------------------
--  DDL for Package IGS_EN_TIMESLOT_PREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_TIMESLOT_PREF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI40S.pls 115.8 2002/11/28 23:42:08 nsidana ship $ */
 PROCEDURE insert_row (
   x_rowid IN OUT NOCOPY VARCHAR2,
   x_igs_en_timeslot_pref_id IN OUT NOCOPY NUMBER,
   x_igs_en_timeslot_prty_id IN NUMBER,
   x_preference_order IN NUMBER,
   x_preference_code IN VARCHAR2,
   x_preference_version IN NUMBER,
   x_mode IN VARCHAR2 DEFAULT 'R',
   x_sequence_number IN NUMBER
  );

 PROCEDURE lock_row (
   x_rowid IN VARCHAR2,
   x_igs_en_timeslot_pref_id IN NUMBER,
   x_igs_en_timeslot_prty_id IN NUMBER,
   x_preference_order IN NUMBER,
   x_preference_code IN VARCHAR2,
   x_preference_version IN  NUMBER,
   x_sequence_number IN NUMBER
  );

 PROCEDURE update_row (
   x_rowid IN VARCHAR2,
   x_igs_en_timeslot_pref_id IN NUMBER,
   x_igs_en_timeslot_prty_id IN NUMBER,
   x_preference_order IN NUMBER,
   x_preference_code IN VARCHAR2,
   x_preference_version IN  NUMBER,
   x_mode IN VARCHAR2 DEFAULT 'R',
   x_sequence_number IN NUMBER
  );

 PROCEDURE add_row (
   x_rowid IN OUT NOCOPY VARCHAR2,
   x_igs_en_timeslot_pref_id IN OUT NOCOPY NUMBER,
   x_igs_en_timeslot_prty_id IN NUMBER,
   x_preference_order IN NUMBER,
   x_preference_code IN VARCHAR2,
   x_preference_version IN  NUMBER,
   x_mode IN VARCHAR2 DEFAULT 'R',
   x_sequence_number IN NUMBER
  ) ;

 PROCEDURE delete_row (
   x_rowid IN VARCHAR2
 ) ;
 FUNCTION get_pk_for_validation (
   x_igs_en_timeslot_pref_id IN NUMBER
   ) RETURN BOOLEAN ;

 FUNCTION get_uk_for_validation (
   x_igs_en_timeslot_prty_id IN NUMBER,
    x_preference_code IN VARCHAR2,
    x_preference_version IN  NUMBER,
    x_sequence_number IN  NUMBER
   ) RETURN BOOLEAN;

 PROCEDURE get_fk_igs_en_timeslot_prty (
   x_igs_en_timeslot_prty_id IN NUMBER
    );

 PROCEDURE check_constraints (
   column_name IN VARCHAR2  DEFAULT NULL,
   column_value IN VARCHAR2  DEFAULT NULL ) ;
 PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_igs_en_timeslot_pref_id IN NUMBER DEFAULT NULL,
    x_igs_en_timeslot_prty_id IN NUMBER DEFAULT NULL,
    x_preference_order IN NUMBER DEFAULT NULL,
    x_preference_code IN VARCHAR2 DEFAULT NULL,
    x_preference_version IN  NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL
 );
END igs_en_timeslot_pref_pkg;

 

/
