--------------------------------------------------------
--  DDL for Package IGS_PS_OF_OPT_UNT_ST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_OF_OPT_UNT_ST_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSPI50S.pls 115.4 2002/11/29 02:30:00 nsidana ship $ */

/* Change History : Bug ID : 1219904 schodava 00/03/02
   Procedure affected : Insert_Row, Add_Row
   Purpose : The parameter Coo_Id is being generated fro
m procedure BeforeRowInsert2, and it is not being copied
 into the             corresponding item in the form IGSPS022.
Hence it is made an IN OUT NOCOPY parameter in the above 2 procedures
 and copied into the form.
*/

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_COO_ID in out NOCOPY NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_COO_ID in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_COO_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_COO_ID in out NOCOPY  NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_crv_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2,
    x_unit_set_cd IN VARCHAR2,
    x_us_version_number IN NUMBER
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_OFR_OPT (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2
    );

  PROCEDURE GET_UFK_IGS_PS_OFR_OPT (
    x_coo_id IN NUMBER
    );

  PROCEDURE GET_FK_IGS_PS_OFR_UNIT_SET (
    x_course_cd IN VARCHAR2,
    x_crv_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_unit_set_cd IN VARCHAR2,
    x_us_version_number IN NUMBER
    );
  PROCEDURE Check_Constraints (
  Column_Name	IN	VARCHAR2	DEFAULT NULL,
  Column_Value 	IN	VARCHAR2	DEFAULT NULL
    );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_coo_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_PS_OF_OPT_UNT_ST_PKG;

 

/
