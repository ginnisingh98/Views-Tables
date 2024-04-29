--------------------------------------------------------
--  DDL for Package IGS_PE_DATA_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_DATA_GROUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI60S.pls 115.8 2003/02/19 10:24:09 npalanis ship $ */
/******************************************************

Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : Creation of Table Handler
Know limitations, enhancements or remarks : None
Change History

Who		When		What


(reverse chronological order - newest change first)
********************************************************/
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DATA_GROUP_ID IN OUT NOCOPY NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_LVL IN VARCHAR2,
       x_LVL_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_DATA_GROUP_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_LVL IN VARCHAR2,
       x_LVL_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2
         );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_DATA_GROUP_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_LVL IN VARCHAR2,
       x_LVL_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'

  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DATA_GROUP_ID IN OUT NOCOPY NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_LVL IN VARCHAR2,
       x_LVL_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  ) ;

  FUNCTION Get_PK_For_Validation (
    x_data_group_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;

  FUNCTION Get_UK_For_Validation (
    x_data_group IN VARCHAR2
    ) RETURN BOOLEAN;

  FUNCTION val_data_group(
    p_data_group_id IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_data_group_id IN NUMBER DEFAULT NULL,
    x_data_group IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_lvl IN VARCHAR2 DEFAULT NULL,
    x_lvl_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER default NULL );
END igs_pe_data_groups_pkg;

 

/
