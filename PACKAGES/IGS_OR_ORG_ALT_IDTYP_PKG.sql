--------------------------------------------------------
--  DDL for Package IGS_OR_ORG_ALT_IDTYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_ORG_ALT_IDTYP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOI16S.pls 115.7 2002/11/29 01:41:19 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ID_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
	   x_SYSTEM_ID_TYPE IN VARCHAR2 DEFAULT NULL,
       x_PREF_INST_IND IN VARCHAR2 DEFAULT NULL,
	   x_PREF_UNIT_IND IN VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ID_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
   	   x_SYSTEM_ID_TYPE IN VARCHAR2 DEFAULT NULL,
       x_PREF_INST_IND IN VARCHAR2 DEFAULT NULL,
	   x_PREF_UNIT_IND IN VARCHAR2 DEFAULT NULL);

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ID_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
	   x_SYSTEM_ID_TYPE IN VARCHAR2 DEFAULT NULL,
       x_PREF_INST_IND IN VARCHAR2 DEFAULT NULL,
	   x_PREF_UNIT_IND IN VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ID_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
	   x_SYSTEM_ID_TYPE IN VARCHAR2 DEFAULT NULL,
       x_PREF_INST_IND IN VARCHAR2 DEFAULT NULL,
	   x_PREF_UNIT_IND IN VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_org_alternate_id_type IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_alternate_id_type IN VARCHAR2 DEFAULT NULL,
    x_id_type_description IN VARCHAR2 DEFAULT NULL,
    x_inst_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_flag IN VARCHAR2 DEFAULT NULL,
    x_close_ind IN VARCHAR2 DEFAULT NULL,
    x_SYSTEM_ID_TYPE IN VARCHAR2 DEFAULT NULL,
    x_PREF_INST_IND IN VARCHAR2 DEFAULT NULL,
    x_PREF_UNIT_IND IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_or_org_alt_idtyp_pkg;

 

/
