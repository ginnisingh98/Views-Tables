--------------------------------------------------------
--  DDL for Package IGS_AS_COURSE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_COURSE_TYPE_PKG" AUTHID CURRENT_USER as
/* $Header: IGSDI01S.pls 115.5 2003/06/05 12:56:35 sarakshi ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_COURSE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ASS_ID in NUMBER,
  X_COURSE_TYPE in VARCHAR2
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2

);
  FUNCTION Get_PK_For_Validation (
    x_ass_id IN NUMBER ,
    x_course_type IN VARCHAR2
) RETURN BOOLEAN;
  PROCEDURE GET_FK_IGS_AS_ASSESSMNT_ITM (
    x_ass_id IN NUMBER
    );

PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,

	Column_Value 	IN	VARCHAR2	DEFAULT NULL

	);

PROCEDURE Before_DML (

   p_action IN VARCHAR2,

    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,

    x_course_type IN VARCHAR2 DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,

    x_created_by IN NUMBER DEFAULT NULL,

    x_last_update_date IN DATE DEFAULT NULL,

    x_last_updated_by IN NUMBER DEFAULT NULL,

    x_last_update_login IN NUMBER DEFAULT NULL

  ) ;
end IGS_AS_COURSE_TYPE_PKG;

 

/