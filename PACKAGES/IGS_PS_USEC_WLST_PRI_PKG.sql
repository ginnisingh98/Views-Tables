--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_WLST_PRI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_WLST_PRI_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0YS.pls 120.1 2005/10/04 00:38:50 appldev ship $ */
 PROCEDURE insert_row (
      X_ROWID in out NOCOPY VARCHAR2,
       x_unit_sec_wlst_priority_id IN OUT NOCOPY NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
       x_uoo_id IN NUMBER,
       X_MODE in VARCHAR2 default 'R'
  );

 PROCEDURE lock_row (
      X_ROWID in  VARCHAR2,
       x_unit_sec_wlst_priority_id IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
       x_uoo_id IN NUMBER
  );

 PROCEDURE update_row (
      X_ROWID in  VARCHAR2,
       x_unit_sec_wlst_priority_id IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
       x_uoo_id IN NUMBER,
       X_MODE in VARCHAR2 default 'R'
  );

 PROCEDURE add_row (
      X_ROWID in out NOCOPY VARCHAR2,
       x_unit_sec_wlst_priority_id IN OUT NOCOPY NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
       x_uoo_id IN NUMBER,
       X_MODE in VARCHAR2 default 'R'
  ) ;

PROCEDURE delete_row (
  X_ROWID in VARCHAR2
) ;
  FUNCTION get_pk_for_validation (
    x_unit_sec_wlst_priority_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION get_uk_for_validation (
    x_priority_value IN VARCHAR2,
    x_uoo_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id IN NUMBER
    );

  PROCEDURE check_constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_sec_wlst_priority_id IN NUMBER DEFAULT NULL,
    x_priority_number IN NUMBER DEFAULT NULL,
    x_priority_value IN VARCHAR2 DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_usec_wlst_pri_pkg;

 

/
