--------------------------------------------------------
--  DDL for Package IGS_RU_NAMED_RULE_GR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_NAMED_RULE_GR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSUI17S.pls 115.6 2002/11/29 04:29:37 nsidana ship $ */

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_GROUP_CD IN VARCHAR2,
       x_NAME_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_RETURN_TYPE IN VARCHAR2,
       x_RUG_SEQUENCE_NUMBER IN NUMBER,
       x_SELECT_GROUP IN NUMBER,
       x_MESSAGE_GROUP IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_GROUP_CD IN VARCHAR2,
       x_NAME_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_RETURN_TYPE IN VARCHAR2,
       x_RUG_SEQUENCE_NUMBER IN NUMBER,
       x_SELECT_GROUP IN NUMBER,
       x_MESSAGE_GROUP IN NUMBER  );

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_GROUP_CD IN VARCHAR2,
       x_NAME_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_RETURN_TYPE IN VARCHAR2,
       x_RUG_SEQUENCE_NUMBER IN NUMBER,
       x_SELECT_GROUP IN NUMBER,
       x_MESSAGE_GROUP IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_GROUP_CD IN VARCHAR2,
       x_NAME_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_RETURN_TYPE IN VARCHAR2,
       x_RUG_SEQUENCE_NUMBER IN NUMBER,
       x_SELECT_GROUP IN NUMBER,
       x_MESSAGE_GROUP IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_group_cd IN VARCHAR2,
    x_name_cd IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_Ru_Ret_Type (
    x_s_return_type IN VARCHAR2
    );

  PROCEDURE Get_FK_Igs_Ru_Nrg_Group_Cd (
    x_group_cd IN VARCHAR2
    );

  PROCEDURE Get_FK_Igs_Ru_Group_sg (
    x_sequence_number IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ru_Group_msg (
    x_sequence_number IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ru_Group_seq (
    x_sequence_number IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_group_cd IN VARCHAR2 DEFAULT NULL,
    x_name_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_return_type IN VARCHAR2 DEFAULT NULL,
    x_rug_sequence_number IN NUMBER DEFAULT NULL,
    x_select_group IN NUMBER DEFAULT NULL,
    x_message_group IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ru_named_rule_gr_pkg;

 

/
