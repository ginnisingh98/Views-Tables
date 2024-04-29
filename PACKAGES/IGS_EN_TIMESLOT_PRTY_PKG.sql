--------------------------------------------------------
--  DDL for Package IGS_EN_TIMESLOT_PRTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_TIMESLOT_PRTY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI39S.pls 115.4 2002/11/28 23:41:53 nsidana ship $ */
 PROCEDURE insert_row (
   x_rowid IN OUT NOCOPY VARCHAR2,
   x_igs_en_timeslot_prty_id IN OUT NOCOPY NUMBER,
   x_igs_en_timeslot_stup_id IN NUMBER,
   x_priority_order IN NUMBER,
   x_priority_value IN VARCHAR2,
   x_mode IN VARCHAR2 DEFAULT 'R'
  );

 PROCEDURE lock_row (
   x_rowid IN VARCHAR2,
   x_igs_en_timeslot_prty_id IN NUMBER,
   x_igs_en_timeslot_stup_id IN NUMBER,
   x_priority_order IN NUMBER,
   x_priority_value IN VARCHAR2  );

 PROCEDURE update_row (
   x_rowid IN VARCHAR2,
   x_igs_en_timeslot_prty_id IN NUMBER,
   x_igs_en_timeslot_stup_id IN NUMBER,
   x_priority_order IN NUMBER,
   x_priority_value IN VARCHAR2,
   x_mode IN VARCHAR2 DEFAULT 'R'
  );

 PROCEDURE add_row (
   x_rowid IN OUT NOCOPY VARCHAR2,
   x_igs_en_timeslot_prty_id IN OUT NOCOPY NUMBER,
   x_igs_en_timeslot_stup_id IN NUMBER,
   x_priority_order IN NUMBER,
   x_priority_value IN VARCHAR2,
   x_mode IN VARCHAR2 DEFAULT 'R'
  ) ;

 PROCEDURE delete_row (
   x_rowid IN VARCHAR2
 ) ;
 FUNCTION get_pk_for_validation (
   x_igs_en_timeslot_prty_id IN NUMBER
   ) RETURN BOOLEAN ;

 FUNCTION get_uk_for_validation (
   x_igs_en_timeslot_stup_id IN NUMBER,
    x_priority_value IN VARCHAR2
   ) RETURN BOOLEAN;

 PROCEDURE get_fk_igs_en_timeslot_stup (
   x_igs_en_timeslot_stup_id IN NUMBER
    );

 PROCEDURE check_constraints (
   column_name IN VARCHAR2  DEFAULT NULL,
   column_value IN VARCHAR2  DEFAULT NULL ) ;
 PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_igs_en_timeslot_prty_id IN NUMBER DEFAULT NULL,
    x_igs_en_timeslot_stup_id IN NUMBER DEFAULT NULL,
    x_priority_order IN NUMBER DEFAULT NULL,
    x_priority_value IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_en_timeslot_prty_pkg;

 

/
