--------------------------------------------------------
--  DDL for Package IGS_AS_GRD_SCH_TRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GRD_SCH_TRN_PKG" AUTHID CURRENT_USER as
 /* $Header: IGSDI15S.pls 115.4 2002/11/28 23:14:13 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_TO_GRADING_SCHEMA_CD in VARCHAR2,
  X_TO_VERSION_NUMBER in NUMBER,
  X_TO_GRADE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_TO_GRADING_SCHEMA_CD in VARCHAR2,
  X_TO_VERSION_NUMBER in NUMBER,
  X_TO_GRADE in VARCHAR2
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );
FUNCTION Get_PK_For_Validation (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2,
    x_to_grading_schema_cd IN VARCHAR2,
    x_to_version_number IN NUMBER,
    x_to_grade IN VARCHAR2
    )RETURN BOOLEAN;
  PROCEDURE GET_FK_IGS_AS_GRD_SCH_GRADE (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2
    );
 	PROCEDURE Check_Constraints (




	Column_Name	IN	VARCHAR2	DEFAULT NULL,




	Column_Value 	IN	VARCHAR2	DEFAULT NULL




	);




PROCEDURE Before_DML (




    p_action IN VARCHAR2,




    x_rowid IN  VARCHAR2 DEFAULT NULL,


   x_org_id IN NUMBER DEFAULT NULL,

    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,




    x_version_number IN NUMBER DEFAULT NULL,




    x_grade IN VARCHAR2 DEFAULT NULL,




    x_to_grading_schema_cd IN VARCHAR2 DEFAULT NULL,




    x_to_version_number IN NUMBER DEFAULT NULL,




    x_to_grade IN VARCHAR2 DEFAULT NULL,




    x_creation_date IN DATE DEFAULT NULL,




    x_created_by IN NUMBER DEFAULT NULL,




    x_last_update_date IN DATE DEFAULT NULL,




    x_last_updated_by IN NUMBER DEFAULT NULL,




    x_last_update_login IN NUMBER DEFAULT NULL




  ) ;
end IGS_AS_GRD_SCH_TRN_PKG;

 

/
