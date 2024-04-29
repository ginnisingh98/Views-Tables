--------------------------------------------------------
--  DDL for Package IGS_TR_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_ITEM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSTI12S.pls 115.7 2003/02/20 13:40:38 kpadiyar ship $ */

  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_status IN VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_source_person_id IN NUMBER,
    x_start_dt IN DATE,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_originator_person_id IN NUMBER,
    x_s_created_ind IN VARCHAR2,
    x_override_offset_clc_ind IN VARCHAR2 DEFAULT 'N',
    x_completion_due_dt IN DATE DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_org_id IN NUMBER
  );

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_status IN VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_source_person_id IN NUMBER,
    x_start_dt IN DATE,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_originator_person_id IN NUMBER,
    x_s_created_ind IN VARCHAR2,
    x_override_offset_clc_ind IN VARCHAR2 DEFAULT 'N',
    x_completion_due_dt IN DATE DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE update_row (
    x_rowid IN VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_status IN VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_source_person_id IN NUMBER,
    x_start_dt IN DATE,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_originator_person_id IN NUMBER,
    x_s_created_ind IN VARCHAR2,
    x_override_offset_clc_ind IN VARCHAR2 DEFAULT 'N',
    x_completion_due_dt IN DATE DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_status IN VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_source_person_id IN NUMBER,
    x_start_dt IN DATE,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_originator_person_id IN NUMBER,
    x_s_created_ind IN VARCHAR2,
    x_override_offset_clc_ind IN VARCHAR2 DEFAULT 'N',
    x_completion_due_dt IN DATE DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_org_id IN NUMBER
  );

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_tracking_id IN NUMBER
  )RETURN BOOLEAN;

  PROCEDURE check_constraints(
    column_name  IN VARCHAR2 DEFAULT NULL,
    column_value  IN VARCHAR2 DEFAULT NULL
   );

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_tracking_status IN VARCHAR2 DEFAULT NULL,
    x_tracking_type IN VARCHAR2 DEFAULT NULL,
    x_source_person_id IN NUMBER DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_target_days IN NUMBER DEFAULT NULL,
    x_sequence_ind IN VARCHAR2 DEFAULT NULL,
    x_business_days_ind IN VARCHAR2 DEFAULT NULL,
    x_originator_person_id IN NUMBER DEFAULT NULL,
    x_s_created_ind IN VARCHAR2 DEFAULT NULL,
    x_override_offset_clc_ind IN VARCHAR2 DEFAULT NULL,
    x_completion_due_dt IN DATE DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  );

  PROCEDURE get_fk_igs_pe_person (
    x_person_id IN NUMBER
  );

END igs_tr_item_pkg;

 

/
