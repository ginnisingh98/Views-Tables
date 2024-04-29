--------------------------------------------------------
--  DDL for Package IGS_TR_TYPE_STEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_TYPE_STEP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSTI06S.pls 115.9 2003/02/19 12:30:52 kpadiyar ship $ */

  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_tracking_type_step_id IN NUMBER,
    x_tracking_type_step_number IN NUMBER,
    x_description IN VARCHAR2,
    x_s_tracking_step_type IN VARCHAR2,
    x_action_days IN NUMBER,
    x_recipient_id IN NUMBER,
    x_step_group_id IN NUMBER DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_step_catalog_cd IN VARCHAR2 DEFAULT NULL,
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_org_id IN NUMBER
  );

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_tracking_type_step_id IN NUMBER,
    x_tracking_type_step_number IN NUMBER,
    x_description IN VARCHAR2,
    x_s_tracking_step_type IN VARCHAR2,
    x_action_days IN NUMBER,
    x_recipient_id IN NUMBER,
    x_step_group_id IN NUMBER DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_step_catalog_cd IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid IN VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_tracking_type_step_id IN NUMBER,
    x_tracking_type_step_number IN NUMBER,
    x_description IN VARCHAR2,
    x_s_tracking_step_type IN VARCHAR2,
    x_action_days IN NUMBER,
    x_recipient_id IN NUMBER,
    x_step_group_id IN NUMBER DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_step_catalog_cd IN VARCHAR2 DEFAULT NULL,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_tracking_type_step_id IN NUMBER,
    x_tracking_type_step_number IN NUMBER,
    x_description IN VARCHAR2,
    x_s_tracking_step_type IN VARCHAR2,
    x_action_days IN NUMBER,
    x_recipient_id IN NUMBER,
    x_step_group_id IN NUMBER DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_step_catalog_cd IN VARCHAR2 DEFAULT NULL,
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_org_id IN NUMBER
  );

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_tracking_type IN VARCHAR2,
    x_tracking_type_step_id IN NUMBER
  )RETURN BOOLEAN ;

  PROCEDURE get_fk_igs_pe_person (
    x_person_id IN NUMBER
  );

  PROCEDURE get_fk_igs_lookups_view(
    x_s_tracking_step_type IN VARCHAR2
  );

  -- added to take care of check constraints
  PROCEDURE check_constraints(
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_type IN VARCHAR2 DEFAULT NULL,
    x_tracking_type_step_id IN NUMBER DEFAULT NULL,
    x_tracking_type_step_number IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_action_days IN NUMBER DEFAULT NULL,
    x_recipient_id IN NUMBER DEFAULT NULL,
    x_s_tracking_step_type IN VARCHAR2 DEFAULT NULL,
    x_step_group_id IN NUMBER DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT NULL,
    x_step_catalog_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  );

END igs_tr_type_step_pkg;

 

/
