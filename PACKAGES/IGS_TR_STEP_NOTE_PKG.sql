--------------------------------------------------------
--  DDL for Package IGS_TR_STEP_NOTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_STEP_NOTE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSTI04S.pls 115.4 2002/11/29 04:14:43 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_step_id IN NUMBER,
    x_reference_number IN NUMBER,
    x_trk_note_type IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_step_id IN NUMBER,
    x_reference_number IN NUMBER,
    x_trk_note_type IN VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid IN VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_step_id IN NUMBER,
    x_reference_number IN NUMBER,
    x_trk_note_type IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_step_id IN NUMBER,
    x_reference_number IN NUMBER,
    x_trk_note_type IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_tracking_id IN NUMBER,
    x_tracking_step_id IN NUMBER,
    x_reference_number IN NUMBER
  )RETURN BOOLEAN;

  -- added to take care of check constraints
  PROCEDURE check_constraints(
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_id IN VARCHAR2 DEFAULT NULL,
    x_tracking_step_id IN NUMBER DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_trk_note_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

  PROCEDURE get_fk_igs_ge_note (
    x_reference_number IN NUMBER
  );

  PROCEDURE get_fk_igs_tr_note_type (
    x_trk_note_type IN VARCHAR2
  );

  PROCEDURE get_fk_igs_tr_step (
    x_tracking_id IN NUMBER,
    x_tracking_step_id IN NUMBER
  );

END igs_tr_step_note_pkg;

 

/
