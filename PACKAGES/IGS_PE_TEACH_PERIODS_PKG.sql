--------------------------------------------------------
--  DDL for Package IGS_PE_TEACH_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_TEACH_PERIODS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI49S.pls 120.0 2005/06/01 13:24:59 appldev noship $ */
 procedure INSERT_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_TEACHING_PERIOD_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TEACH_PERIOD_RESID_STAT_CD IN VARCHAR2,
       x_CAL_TYPE IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       X_MODE in VARCHAR2 default 'R',
       X_ORG_ID in NUMBER
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_TEACHING_PERIOD_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TEACH_PERIOD_RESID_STAT_CD IN VARCHAR2,
       x_CAL_TYPE IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER
     );
 procedure UPDATE_ROW (
       X_ROWID in  VARCHAR2,
       x_TEACHING_PERIOD_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TEACH_PERIOD_RESID_STAT_CD IN VARCHAR2,
       x_CAL_TYPE IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_TEACHING_PERIOD_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TEACH_PERIOD_RESID_STAT_CD IN VARCHAR2,
       x_CAL_TYPE IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       X_MODE in VARCHAR2 default 'R',
       X_ORG_ID in NUMBER
  ) ;
PROCEDURE DELETE_ROW (
   X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
 ) ;
FUNCTION Get_PK_For_Validation (
       x_teaching_period_id IN NUMBER
) RETURN BOOLEAN ;

FUNCTION Get_UK_For_Validation (
	  x_cal_type IN VARCHAR2,
	  x_sequence_number IN NUMBER,
          x_person_id IN NUMBER
) RETURN BOOLEAN;

PROCEDURE Get_FK_Igs_Pe_Person (
       x_person_id IN NUMBER
);

PROCEDURE Check_Constraints (
      Column_Name IN VARCHAR2  DEFAULT NULL,
      Column_Value IN VARCHAR2  DEFAULT NULL
) ;

PROCEDURE Before_DML (
       p_action IN VARCHAR2,
       x_rowid IN VARCHAR2 DEFAULT NULL,
       x_teaching_period_id IN NUMBER DEFAULT NULL,
       x_person_id IN NUMBER DEFAULT NULL,
       x_teach_period_resid_stat_cd IN VARCHAR2 DEFAULT NULL,
       x_cal_type IN VARCHAR2 DEFAULT NULL,
       x_sequence_number IN NUMBER DEFAULT NULL,
       x_creation_date IN DATE DEFAULT NULL,
       x_created_by IN NUMBER DEFAULT NULL,
       x_last_update_date IN DATE DEFAULT NULL,
       x_last_updated_by IN NUMBER DEFAULT NULL,
       x_last_update_login IN NUMBER DEFAULT NULL,
       X_ORG_ID in NUMBER DEFAULT NULL
 );

END igs_pe_teach_periods_pkg;

 

/
