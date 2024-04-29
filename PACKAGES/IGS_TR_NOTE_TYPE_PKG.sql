--------------------------------------------------------
--  DDL for Package IGS_TR_NOTE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_NOTE_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSTI08S.pls 115.5 2002/11/29 04:16:02 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_trk_note_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_trk_note_type IN VARCHAR2,
    x_description IN VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid IN VARCHAR2,
    x_trk_note_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_trk_note_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_trk_note_type IN VARCHAR2
  )RETURN BOOLEAN;

  PROCEDURE check_constraints(
    column_name  IN VARCHAR2 DEFAULT NULL,
    column_value  IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_trk_note_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

END igs_tr_note_type_pkg;

 

/
