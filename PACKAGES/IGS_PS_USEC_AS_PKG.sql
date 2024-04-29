--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_AS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_AS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI1FS.pls 115.6 2002/11/29 02:06:11 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_ASSESSMENT_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_FINAL_EXAM_DATE IN DATE,
       x_EXAM_START_TIME IN DATE,
       x_EXAM_END_TIME IN DATE,
       x_LOCATION_CD IN VARCHAR2,
       x_BUILDING_CODE IN NUMBER,
       x_ROOM_CODE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_ASSESSMENT_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_FINAL_EXAM_DATE IN DATE,
       x_EXAM_START_TIME IN DATE,
       x_EXAM_END_TIME IN DATE,
       x_LOCATION_CD IN VARCHAR2,
       x_BUILDING_CODE IN NUMBER,
       x_ROOM_CODE IN NUMBER  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_ASSESSMENT_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_FINAL_EXAM_DATE IN DATE,
       x_EXAM_START_TIME IN DATE,
       x_EXAM_END_TIME IN DATE,
       x_LOCATION_CD IN VARCHAR2,
       x_BUILDING_CODE IN NUMBER,
       x_ROOM_CODE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_ASSESSMENT_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_FINAL_EXAM_DATE IN DATE,
       x_EXAM_START_TIME IN DATE,
       x_EXAM_END_TIME IN DATE,
       x_LOCATION_CD IN VARCHAR2,
       x_BUILDING_CODE IN NUMBER,
       x_ROOM_CODE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_section_assessment_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_building_code IN NUMBER,
    x_final_exam_date IN DATE,
    x_location_cd IN VARCHAR2,
    x_room_code IN NUMBER,
    x_uoo_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_UFK_Igs_Ps_Unit_Ofr_Opt (
    x_uoo_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_section_assessment_id IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_final_exam_date IN DATE DEFAULT NULL,
    x_exam_start_time IN DATE DEFAULT NULL,
    x_exam_end_time IN DATE DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_building_code IN NUMBER DEFAULT NULL,
    x_room_code IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_usec_as_pkg;

 

/
