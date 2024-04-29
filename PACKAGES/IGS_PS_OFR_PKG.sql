--------------------------------------------------------
--  DDL for Package IGS_PS_OFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_OFR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI19S.pls 115.5 2002/11/29 02:04:24 nsidana ship $ */
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sbeerell        10-MAY-2000
  (reverse chronological order - newest change first)
***************************************************************/


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  x_ATTRIBUTE_CATEGORY IN VARCHAR2,
  x_ATTRIBUTE1 IN VARCHAR2,
  x_ATTRIBUTE2 IN VARCHAR2,
  x_ATTRIBUTE3 IN VARCHAR2,
  x_ATTRIBUTE4 IN VARCHAR2,
  x_ATTRIBUTE5 IN VARCHAR2,
  x_ATTRIBUTE6 IN VARCHAR2,
  x_ATTRIBUTE7 IN VARCHAR2,
  x_ATTRIBUTE8 IN VARCHAR2,
  x_ATTRIBUTE9 IN VARCHAR2,
  x_ATTRIBUTE10 IN VARCHAR2,
  x_ATTRIBUTE11 IN VARCHAR2,
  x_ATTRIBUTE12 IN VARCHAR2,
  x_ATTRIBUTE13 IN VARCHAR2,
  x_ATTRIBUTE14 IN VARCHAR2,
  x_ATTRIBUTE15 IN VARCHAR2,
  x_ATTRIBUTE16 IN VARCHAR2,
  x_ATTRIBUTE17 IN VARCHAR2,
  x_ATTRIBUTE18 IN VARCHAR2,
  x_ATTRIBUTE19 IN VARCHAR2,
  x_ATTRIBUTE20 IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  x_ATTRIBUTE_CATEGORY IN VARCHAR2,
  x_ATTRIBUTE1 IN VARCHAR2,
  x_ATTRIBUTE2 IN VARCHAR2,
  x_ATTRIBUTE3 IN VARCHAR2,
  x_ATTRIBUTE4 IN VARCHAR2,
  x_ATTRIBUTE5 IN VARCHAR2,
  x_ATTRIBUTE6 IN VARCHAR2,
  x_ATTRIBUTE7 IN VARCHAR2,
  x_ATTRIBUTE8 IN VARCHAR2,
  x_ATTRIBUTE9 IN VARCHAR2,
  x_ATTRIBUTE10 IN VARCHAR2,
  x_ATTRIBUTE11 IN VARCHAR2,
  x_ATTRIBUTE12 IN VARCHAR2,
  x_ATTRIBUTE13 IN VARCHAR2,
  x_ATTRIBUTE14 IN VARCHAR2,
  x_ATTRIBUTE15 IN VARCHAR2,
  x_ATTRIBUTE16 IN VARCHAR2,
  x_ATTRIBUTE17 IN VARCHAR2,
  x_ATTRIBUTE18 IN VARCHAR2,
  x_ATTRIBUTE19 IN VARCHAR2,
  x_ATTRIBUTE20 IN VARCHAR2
 );


procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2
    )
  RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

PROCEDURE Check_Constraints (
    Column_Name	IN VARCHAR2	DEFAULT NULL,
    Column_Value 	IN VARCHAR2	DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID IN NUMBER DEFAULT NULL
  ) ;

end IGS_PS_OFR_PKG;

 

/