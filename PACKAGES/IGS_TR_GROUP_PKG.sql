--------------------------------------------------------
--  DDL for Package IGS_TR_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_GROUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSTI09S.pls 115.5 2002/11/29 04:16:18 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_group_id IN NUMBER,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_org_id IN NUMBER
  );

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_tracking_group_id IN NUMBER,
    x_description IN VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid IN VARCHAR2,
    x_tracking_group_id IN NUMBER,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_group_id IN NUMBER,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_org_id IN NUMBER
  );

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_tracking_group_id IN NUMBER
  )RETURN BOOLEAN;

  PROCEDURE check_constraints(
    column_name  IN VARCHAR2 DEFAULT NULL,
    column_value  IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_group_id IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  );

END igs_tr_group_pkg;

 

/
