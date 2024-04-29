--------------------------------------------------------
--  DDL for Package IGS_AD_UNIT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_UNIT_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI98S.pls 120.1 2006/05/30 11:41:49 pbondugu noship $ */

  procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_UNIT_SET_ID IN OUT NOCOPY NUMBER,
    x_PERSON_ID IN NUMBER,
    x_ADMISSION_APPL_NUMBER IN NUMBER,
    x_NOMINATED_COURSE_CD IN VARCHAR2,
    x_SEQUENCE_NUMBER IN NUMBER,
    x_UNIT_SET_CD IN VARCHAR2,
    x_VERSION_NUMBER IN NUMBER,
    x_RANK IN NUMBER,
    X_MODE in VARCHAR2 default 'R'
  );

  procedure LOCK_ROW (
    X_ROWID in  VARCHAR2,
    x_UNIT_SET_ID IN NUMBER,
    x_PERSON_ID IN NUMBER,
    x_ADMISSION_APPL_NUMBER IN NUMBER,
    x_NOMINATED_COURSE_CD IN VARCHAR2,
    x_SEQUENCE_NUMBER IN NUMBER,
    x_UNIT_SET_CD IN VARCHAR2,
    x_VERSION_NUMBER IN NUMBER,
    x_RANK IN NUMBER
  );

  procedure UPDATE_ROW (
    X_ROWID in  VARCHAR2,
    x_UNIT_SET_ID IN NUMBER,
    x_PERSON_ID IN NUMBER,
    x_ADMISSION_APPL_NUMBER IN NUMBER,
    x_NOMINATED_COURSE_CD IN VARCHAR2,
    x_SEQUENCE_NUMBER IN NUMBER,
    x_UNIT_SET_CD IN VARCHAR2,
    x_VERSION_NUMBER IN NUMBER,
    x_RANK IN NUMBER,
    X_MODE in VARCHAR2 default 'R'
  );

  procedure ADD_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_UNIT_SET_ID IN OUT NOCOPY NUMBER,
    x_PERSON_ID IN NUMBER,
    x_ADMISSION_APPL_NUMBER IN NUMBER,
    x_NOMINATED_COURSE_CD IN VARCHAR2,
    x_SEQUENCE_NUMBER IN NUMBER,
    x_UNIT_SET_CD IN VARCHAR2,
    x_VERSION_NUMBER IN NUMBER,
    x_RANK IN NUMBER,
    X_MODE in VARCHAR2 default 'R'
   );

  procedure DELETE_ROW (
    X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION Get_PK_For_Validation (
    x_unit_set_id IN NUMBER
  ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_sequence_number IN NUMBER,
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_person_id IN NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Ps_Appl_Inst (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
  );

  PROCEDURE Get_FK_Igs_En_Unit_Set (
    x_UNIT_SET_CD IN VARCHAR2,
    x_VERSION_NUMBER IN NUMBER
  );

  PROCEDURE Check_Constraints (
    Column_Name IN VARCHAR2  DEFAULT NULL,
    Column_Value IN VARCHAR2  DEFAULT NULL
  );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_rank IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
  PROCEDURE GET_FK_IGS_PS_OFR_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_course_cd VARCHAR2,
    x_crv_version_number NUMBER,
    x_acad_cal_type VARCHAR2
    );
  FUNCTION Validate_Unit_Set(p_version_number      igs_ad_unit_sets.version_number%TYPE
                          ,p_unit_set_cd         igs_ad_unit_sets.unit_set_cd%TYPE
                          ,p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE
                          ,p_crv_version_number  igs_ad_ps_appl_inst_all.crv_version_number%TYPE
                          ,p_admission_cat       igs_ad_appl_all.admission_cat%TYPE
                          ,p_acad_cal_type       igs_ad_appl_all.acad_cal_type%TYPE
                          ,p_location_cd         igs_ad_ps_appl_inst_all.location_cd%TYPE
                          ,p_attendance_mode     igs_ad_ps_appl_inst_all.attendance_mode%TYPE
                          ,p_attendance_type     igs_ad_ps_appl_inst_all.attendance_type%TYPE
 ) RETURN BOOLEAN;

END igs_ad_unit_sets_pkg;

 

/
