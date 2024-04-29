--------------------------------------------------------
--  DDL for Package IGS_AS_ITM_EXAM_MTRL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_ITM_EXAM_MTRL_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSDI03S.pls 115.3 2002/11/28 23:10:59 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ASS_ID in NUMBER,
  X_EXAM_MATERIAL_TYPE in VARCHAR2,
  X_S_MATERIAL_CAT in VARCHAR2,
  X_QUANTITY_PER_STUDENT in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ASS_ID in NUMBER,
  X_EXAM_MATERIAL_TYPE in VARCHAR2,
  X_S_MATERIAL_CAT in VARCHAR2,
  X_QUANTITY_PER_STUDENT in NUMBER,
  X_COMMENTS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ASS_ID in NUMBER,
  X_EXAM_MATERIAL_TYPE in VARCHAR2,
  X_S_MATERIAL_CAT in VARCHAR2,
  X_QUANTITY_PER_STUDENT in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ASS_ID in NUMBER,
  X_EXAM_MATERIAL_TYPE in VARCHAR2,
  X_S_MATERIAL_CAT in VARCHAR2,
  X_QUANTITY_PER_STUDENT in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_ass_id IN NUMBER,
    x_exam_material_type IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AS_ASSESSMNT_ITM (
    x_ass_id IN NUMBER
    );

  PROCEDURE GET_FK_IGS_AS_EXM_MTRL_TYPE (
    x_exam_material_type IN VARCHAR2
    );









	PROCEDURE Check_Constraints (




	Column_Name	IN	VARCHAR2	DEFAULT NULL,




	Column_Value 	IN	VARCHAR2	DEFAULT NULL




);




  PROCEDURE Before_DML (




    p_action IN VARCHAR2,




    x_rowid IN VARCHAR2 DEFAULT NULL,




    x_ass_id IN NUMBER DEFAULT NULL,




    x_exam_material_type IN VARCHAR2 DEFAULT NULL,




    x_s_material_cat IN VARCHAR2 DEFAULT NULL,




    x_quantity_per_student IN NUMBER DEFAULT NULL,




    x_comments IN VARCHAR2 DEFAULT NULL,




    x_creation_date IN DATE DEFAULT NULL,




    x_created_by IN NUMBER DEFAULT NULL,




    x_last_update_date IN DATE DEFAULT NULL,




    x_last_updated_by IN NUMBER DEFAULT NULL,




    x_last_update_login IN NUMBER DEFAULT NULL




  ) ;

end IGS_AS_ITM_EXAM_MTRL_PKG;

 

/
