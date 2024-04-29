--------------------------------------------------------
--  DDL for Package IGS_AD_TERM_UNITDTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_TERM_UNITDTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI84S.pls 120.0 2005/06/01 14:22:40 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_DETAILS_ID IN OUT NOCOPY NUMBER,
       x_TERM_DETAILS_ID IN NUMBER,
       x_UNIT IN VARCHAR2,
       x_UNIT_DIFFICULTY IN NUMBER,
       x_UNIT_NAME IN VARCHAR2,
       x_CP_ATTEMPTED IN NUMBER,
       x_CP_EARNED IN NUMBER,
       x_GRADE IN VARCHAR2,
       x_UNIT_GRADE_POINTS IN NUMBER,
       x_DEG_AUD_DETAIL_ID  IN NUMBER DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_DETAILS_ID IN NUMBER,
       x_TERM_DETAILS_ID IN NUMBER,
       x_UNIT IN VARCHAR2,
       x_UNIT_DIFFICULTY IN NUMBER,
       x_UNIT_NAME IN VARCHAR2,
       x_CP_ATTEMPTED IN NUMBER,
       x_CP_EARNED IN NUMBER,
       x_GRADE IN VARCHAR2,
       x_UNIT_GRADE_POINTS IN NUMBER,
       x_DEG_AUD_DETAIL_ID  IN NUMBER DEFAULT NULL
   );

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_DETAILS_ID IN NUMBER,
       x_TERM_DETAILS_ID IN NUMBER,
       x_UNIT IN VARCHAR2,
       x_UNIT_DIFFICULTY IN NUMBER,
       x_UNIT_NAME IN VARCHAR2,
       x_CP_ATTEMPTED IN NUMBER,
       x_CP_EARNED IN NUMBER,
       x_GRADE IN VARCHAR2,
       x_UNIT_GRADE_POINTS IN NUMBER,
       x_DEG_AUD_DETAIL_ID  IN NUMBER DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_DETAILS_ID IN OUT NOCOPY NUMBER,
       x_TERM_DETAILS_ID IN NUMBER,
       x_UNIT IN VARCHAR2,
       x_UNIT_DIFFICULTY IN NUMBER,
       x_UNIT_NAME IN VARCHAR2,
       x_CP_ATTEMPTED IN NUMBER,
       x_CP_EARNED IN NUMBER,
       x_GRADE IN VARCHAR2,
       x_UNIT_GRADE_POINTS IN NUMBER,
       x_DEG_AUD_DETAIL_ID  IN NUMBER DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;


  FUNCTION Get_PK_For_Validation (
    x_unit_details_id IN NUMBER
    ) RETURN BOOLEAN ;


  FUNCTION Get_UK_For_Validation (
    x_term_details_id IN NUMBER,
    x_unit IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ad_Term_Details (
    x_term_details_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_details_id IN NUMBER DEFAULT NULL,
    x_term_details_id IN NUMBER DEFAULT NULL,
    x_unit IN VARCHAR2 DEFAULT NULL,
    x_unit_difficulty IN NUMBER DEFAULT NULL,
    x_unit_name IN VARCHAR2 DEFAULT NULL,
    x_cp_attempted IN NUMBER DEFAULT NULL,
    x_cp_earned IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_unit_grade_points IN NUMBER DEFAULT NULL,
    x_deg_aud_detail_id  IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_term_unitdtls_pkg;

 

/
