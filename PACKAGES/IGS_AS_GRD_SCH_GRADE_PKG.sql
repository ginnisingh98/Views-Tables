--------------------------------------------------------
--  DDL for Package IGS_AS_GRD_SCH_GRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GRD_SCH_GRADE_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSDI21S.pls 120.0 2005/07/05 12:34:54 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_FULL_GRADE_NAME in VARCHAR2,
  X_S_RESULT_TYPE in VARCHAR2,
  X_SHOW_ON_NOTICEBOARD_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2,
  X_S_SPECIAL_GRADE_TYPE in VARCHAR2,
  X_SHOW_IN_NEWSPAPER_IND in VARCHAR2,
  X_SHOW_INTERNALLY_IND in VARCHAR2,
  X_SYSTEM_ONLY_IND in VARCHAR2,
  X_DFLT_OUTSTANDING_IND in VARCHAR2,
  X_EXTERNAL_GRADE in VARCHAR2,
  X_LOWER_MARK_RANGE in NUMBER,
  X_UPPER_MARK_RANGE in NUMBER,
  X_MIN_PERCENTAGE in NUMBER,
  X_MAX_PERCENTAGE in NUMBER,
  X_GPA_VAL in NUMBER,
  X_RANK in NUMBER,
  X_SHOW_IN_EARNED_CRDT_IND in VARCHAR2,
  X_INCL_IN_REPEAT_PROCESS_IND in VARCHAR2,
  X_ADMIN_ONLY_IND in VARCHAR2,
  X_GRADING_PERIOD_CD in VARCHAR2,
  X_REPEAT_GRADE in VARCHAR2,
x_ATTRIBUTE_CATEGORY IN    VARCHAR2 ,
x_ATTRIBUTE1         IN    VARCHAR2 ,
x_ATTRIBUTE2         IN    VARCHAR2 ,
x_ATTRIBUTE3         IN    VARCHAR2 ,
x_ATTRIBUTE4         IN    VARCHAR2 ,
x_ATTRIBUTE5         IN    VARCHAR2 ,
x_ATTRIBUTE6         IN    VARCHAR2 ,
x_ATTRIBUTE7         IN    VARCHAR2 ,
x_ATTRIBUTE8         IN    VARCHAR2 ,
x_ATTRIBUTE9         IN    VARCHAR2 ,
x_ATTRIBUTE10        IN    VARCHAR2 ,
x_ATTRIBUTE11        IN    VARCHAR2 ,
x_ATTRIBUTE12        IN    VARCHAR2 ,
x_ATTRIBUTE13        IN    VARCHAR2 ,
x_ATTRIBUTE14        IN    VARCHAR2 ,
x_ATTRIBUTE15        IN    VARCHAR2 ,
x_ATTRIBUTE16        IN    VARCHAR2 ,
x_ATTRIBUTE17        IN    VARCHAR2 ,
x_ATTRIBUTE18        IN    VARCHAR2 ,
x_ATTRIBUTE19        IN    VARCHAR2 ,
x_ATTRIBUTE20	     IN    VARCHAR2 ,
X_MODE in VARCHAR2 default 'R' ,
X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_FULL_GRADE_NAME in VARCHAR2,
  X_S_RESULT_TYPE in VARCHAR2,
  X_SHOW_ON_NOTICEBOARD_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2,
  X_S_SPECIAL_GRADE_TYPE in VARCHAR2,
  X_SHOW_IN_NEWSPAPER_IND in VARCHAR2,
  X_SHOW_INTERNALLY_IND in VARCHAR2,
  X_SYSTEM_ONLY_IND in VARCHAR2,
  X_DFLT_OUTSTANDING_IND in VARCHAR2,
  X_EXTERNAL_GRADE in VARCHAR2,
  X_LOWER_MARK_RANGE in NUMBER,
  X_UPPER_MARK_RANGE in NUMBER,
  X_MIN_PERCENTAGE in NUMBER,
  X_MAX_PERCENTAGE in NUMBER,
  X_GPA_VAL in NUMBER,
  X_RANK in NUMBER,
  X_SHOW_IN_EARNED_CRDT_IND in VARCHAR2,
  X_INCL_IN_REPEAT_PROCESS_IND in VARCHAR2,
  X_ADMIN_ONLY_IND in VARCHAR2,
  X_GRADING_PERIOD_CD in VARCHAR2,
  X_REPEAT_GRADE in VARCHAR2,
  x_ATTRIBUTE_CATEGORY IN    VARCHAR2 ,
  x_ATTRIBUTE1         IN    VARCHAR2 ,
  x_ATTRIBUTE2         IN    VARCHAR2 ,
  x_ATTRIBUTE3         IN    VARCHAR2 ,
  x_ATTRIBUTE4         IN    VARCHAR2 ,
  x_ATTRIBUTE5         IN    VARCHAR2 ,
  x_ATTRIBUTE6         IN    VARCHAR2 ,
  x_ATTRIBUTE7         IN    VARCHAR2 ,
  x_ATTRIBUTE8         IN    VARCHAR2 ,
  x_ATTRIBUTE9         IN    VARCHAR2 ,
  x_ATTRIBUTE10        IN    VARCHAR2 ,
  x_ATTRIBUTE11        IN    VARCHAR2 ,
  x_ATTRIBUTE12        IN    VARCHAR2 ,
  x_ATTRIBUTE13        IN    VARCHAR2 ,
  x_ATTRIBUTE14        IN    VARCHAR2 ,
  x_ATTRIBUTE15        IN    VARCHAR2 ,
  x_ATTRIBUTE16        IN    VARCHAR2 ,
  x_ATTRIBUTE17        IN    VARCHAR2 ,
  x_ATTRIBUTE18        IN    VARCHAR2 ,
  x_ATTRIBUTE19        IN    VARCHAR2 ,
  x_ATTRIBUTE20	     IN    VARCHAR2 ,
  X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
 );
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_FULL_GRADE_NAME in VARCHAR2,
  X_S_RESULT_TYPE in VARCHAR2,
  X_SHOW_ON_NOTICEBOARD_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2,
  X_S_SPECIAL_GRADE_TYPE in VARCHAR2,
  X_SHOW_IN_NEWSPAPER_IND in VARCHAR2,
  X_SHOW_INTERNALLY_IND in VARCHAR2,
  X_SYSTEM_ONLY_IND in VARCHAR2,
  X_DFLT_OUTSTANDING_IND in VARCHAR2,
  X_EXTERNAL_GRADE in VARCHAR2,
  X_LOWER_MARK_RANGE in NUMBER,
  X_UPPER_MARK_RANGE in NUMBER,
  X_MIN_PERCENTAGE in NUMBER,
  X_MAX_PERCENTAGE in NUMBER,
  X_GPA_VAL in NUMBER,
  X_RANK in NUMBER,
  X_SHOW_IN_EARNED_CRDT_IND in VARCHAR2,
  X_INCL_IN_REPEAT_PROCESS_IND in VARCHAR2,
  X_ADMIN_ONLY_IND in VARCHAR2,
  X_GRADING_PERIOD_CD in VARCHAR2,
  X_REPEAT_GRADE in VARCHAR2,
  x_ATTRIBUTE_CATEGORY IN    VARCHAR2 ,
  x_ATTRIBUTE1         IN    VARCHAR2 ,
  x_ATTRIBUTE2         IN    VARCHAR2 ,
  x_ATTRIBUTE3         IN    VARCHAR2 ,
  x_ATTRIBUTE4         IN    VARCHAR2 ,
  x_ATTRIBUTE5         IN    VARCHAR2 ,
  x_ATTRIBUTE6         IN    VARCHAR2 ,
  x_ATTRIBUTE7         IN    VARCHAR2 ,
  x_ATTRIBUTE8         IN    VARCHAR2 ,
  x_ATTRIBUTE9         IN    VARCHAR2 ,
  x_ATTRIBUTE10        IN    VARCHAR2 ,
  x_ATTRIBUTE11        IN    VARCHAR2 ,
  x_ATTRIBUTE12        IN    VARCHAR2 ,
  x_ATTRIBUTE13        IN    VARCHAR2 ,
  x_ATTRIBUTE14        IN    VARCHAR2 ,
  x_ATTRIBUTE15        IN    VARCHAR2 ,
  x_ATTRIBUTE16        IN    VARCHAR2 ,
  x_ATTRIBUTE17        IN    VARCHAR2 ,
  x_ATTRIBUTE18        IN    VARCHAR2 ,
  x_ATTRIBUTE19        IN    VARCHAR2 ,
  x_ATTRIBUTE20	     IN    VARCHAR2 ,
  X_MODE in VARCHAR2 default 'R',
  X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_FULL_GRADE_NAME in VARCHAR2,
  X_S_RESULT_TYPE in VARCHAR2,
  X_SHOW_ON_NOTICEBOARD_IND in VARCHAR2,
  X_SHOW_ON_OFFICIAL_NTFCTN_IND in VARCHAR2,
  X_S_SPECIAL_GRADE_TYPE in VARCHAR2,
  X_SHOW_IN_NEWSPAPER_IND in VARCHAR2,
  X_SHOW_INTERNALLY_IND in VARCHAR2,
  X_SYSTEM_ONLY_IND in VARCHAR2,
  X_DFLT_OUTSTANDING_IND in VARCHAR2,
  X_EXTERNAL_GRADE in VARCHAR2,
  X_LOWER_MARK_RANGE in NUMBER,
  X_UPPER_MARK_RANGE in NUMBER,
  X_MIN_PERCENTAGE in NUMBER,
  X_MAX_PERCENTAGE in NUMBER,
  X_GPA_VAL in NUMBER,
  X_RANK in NUMBER,
  X_SHOW_IN_EARNED_CRDT_IND in VARCHAR2,
  X_INCL_IN_REPEAT_PROCESS_IND in VARCHAR2,
  X_ADMIN_ONLY_IND in VARCHAR2,
  X_GRADING_PERIOD_CD in VARCHAR2,
  X_REPEAT_GRADE in VARCHAR2,
  x_ATTRIBUTE_CATEGORY IN    VARCHAR2 ,
  x_ATTRIBUTE1         IN    VARCHAR2 ,
  x_ATTRIBUTE2         IN    VARCHAR2 ,
  x_ATTRIBUTE3         IN    VARCHAR2 ,
  x_ATTRIBUTE4         IN    VARCHAR2 ,
  x_ATTRIBUTE5         IN    VARCHAR2 ,
  x_ATTRIBUTE6         IN    VARCHAR2 ,
  x_ATTRIBUTE7         IN    VARCHAR2 ,
  x_ATTRIBUTE8         IN    VARCHAR2 ,
  x_ATTRIBUTE9         IN    VARCHAR2 ,
  x_ATTRIBUTE10        IN    VARCHAR2 ,
  x_ATTRIBUTE11        IN    VARCHAR2 ,
  x_ATTRIBUTE12        IN    VARCHAR2 ,
  x_ATTRIBUTE13        IN    VARCHAR2 ,
  x_ATTRIBUTE14        IN    VARCHAR2 ,
  x_ATTRIBUTE15        IN    VARCHAR2 ,
  x_ATTRIBUTE16        IN    VARCHAR2 ,
  x_ATTRIBUTE17        IN    VARCHAR2 ,
  x_ATTRIBUTE18        IN    VARCHAR2 ,
  x_ATTRIBUTE19        IN    VARCHAR2 ,
  x_ATTRIBUTE20	     IN    VARCHAR2 ,
  X_MODE in VARCHAR2 default 'R',
  X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  );

FUNCTION Get_PK_For_Validation (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AS_GRD_SCHEMA (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_s_result_type IN VARCHAR2
    );
 PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_dflt_outstanding_ind IN VARCHAR2 DEFAULT NULL,
    x_external_grade IN VARCHAR2 DEFAULT NULL,
    x_lower_mark_range IN NUMBER DEFAULT NULL,
    x_upper_mark_range IN NUMBER DEFAULT NULL,
    x_min_percentage IN NUMBER DEFAULT NULL,
    x_max_percentage IN NUMBER DEFAULT NULL,
    x_gpa_val IN NUMBER DEFAULT NULL,
    x_rank IN NUMBER DEFAULT NULL,
    x_s_special_grade_type IN VARCHAR2 DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_full_grade_name IN VARCHAR2 DEFAULT NULL,
    x_s_result_type IN VARCHAR2 DEFAULT NULL,
    x_show_on_noticeboard_ind IN VARCHAR2 DEFAULT NULL,
    x_show_on_official_ntfctn_ind IN VARCHAR2 DEFAULT NULL,
    x_show_in_newspaper_ind IN VARCHAR2 DEFAULT NULL,
    x_show_internally_ind IN VARCHAR2 DEFAULT NULL,
    x_system_only_ind IN VARCHAR2 DEFAULT NULL,
    X_SHOW_IN_EARNED_CRDT_IND in VARCHAR2 DEFAULT NULL,
    X_INCL_IN_REPEAT_PROCESS_IND in VARCHAR2 DEFAULT NULL,
    X_ADMIN_ONLY_IND in VARCHAR2 DEFAULT NULL,
    X_GRADING_PERIOD_CD in VARCHAR2 DEFAULT NULL,
    X_REPEAT_GRADE in VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE_CATEGORY IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE1         IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE2         IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE3         IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE4         IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE5         IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE6         IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE7         IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE8         IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE9         IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE10        IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE11        IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE12        IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE13        IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE14        IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE15        IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE16        IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE17        IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE18        IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE19        IN    VARCHAR2 DEFAULT NULL,
  x_ATTRIBUTE20	       IN    VARCHAR2 DEFAULT NULL ,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_CLOSED_IND IN VARCHAR2 DEFAULT NULL
  );

PROCEDURE Check_Constraints ( 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL );
end IGS_AS_GRD_SCH_GRADE_PKG;

 

/