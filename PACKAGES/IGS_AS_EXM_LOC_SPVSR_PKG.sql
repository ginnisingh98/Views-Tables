--------------------------------------------------------
--  DDL for Package IGS_AS_EXM_LOC_SPVSR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_EXM_LOC_SPVSR_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSDI25S.pls 115.3 2002/11/28 23:17:25 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXAM_LOCATION_CD in VARCHAR2
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );
FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_exam_location_cd IN VARCHAR2
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AS_EXM_SUPRVISOR (
    x_person_id IN NUMBER
    );
  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    );
	PROCEDURE Check_Constraints (Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	);
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
	x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_exam_location_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
	x_last_update_login IN NUMBER DEFAULT NULL
  ) ;
end IGS_AS_EXM_LOC_SPVSR_PKG;

 

/
