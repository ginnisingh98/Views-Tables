--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_CAL_NUMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_CAL_NUMS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0US.pls 120.0 2005/06/01 16:26:38 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_CALL_NUMBER_ID IN out NOCOPY NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_CALL_NUMBER IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_CALL_NUMBER_ID IN NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_CALL_NUMBER IN NUMBER  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_CALL_NUMBER_ID IN NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_CALL_NUMBER IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_CALL_NUMBER_ID IN out NOCOPY  NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_CALL_NUMBER IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_section_call_number_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_calender_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_section_call_number_id IN NUMBER DEFAULT NULL,
    x_calender_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_call_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_usec_cal_nums_pkg;

 

/
