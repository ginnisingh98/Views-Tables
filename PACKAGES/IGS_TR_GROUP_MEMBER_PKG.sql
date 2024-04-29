--------------------------------------------------------
--  DDL for Package IGS_TR_GROUP_MEMBER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_GROUP_MEMBER_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSTI10S.pls 115.5 2002/11/29 04:16:34 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_group_id IN NUMBER,
    x_tracking_id IN NUMBER,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_tracking_group_id IN NUMBER,
    x_tracking_id IN NUMBER
  );

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_tracking_group_id IN NUMBER,
    x_tracking_id IN NUMBER
  )RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_group_id IN NUMBER DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

  PROCEDURE get_fk_igs_tr_group (
    x_tracking_group_id IN NUMBER
  );

  PROCEDURE get_fk_igs_tr_item (
    x_tracking_id IN NUMBER
    );

END igs_tr_group_member_pkg;

 

/
