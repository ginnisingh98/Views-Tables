--------------------------------------------------------
--  DDL for Package IGS_AD_TERM_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_TERM_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI83S.pls 120.0 2005/06/01 22:09:22 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_TERM_DETAILS_ID IN OUT NOCOPY NUMBER,
       x_TRANSCRIPT_ID IN NUMBER,
       x_TERM IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_TOTAL_CP_ATTEMPTED IN NUMBER,
       x_TOTAL_CP_EARNED IN NUMBER,
       x_TOTAL_UNIT_GP IN NUMBER,
       x_TOTAL_GPA_UNITS IN NUMBER,
       x_GPA IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_TERM_DETAILS_ID IN NUMBER,
       x_TRANSCRIPT_ID IN NUMBER,
       x_TERM IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_TOTAL_CP_ATTEMPTED IN NUMBER,
       x_TOTAL_CP_EARNED IN NUMBER,
       x_TOTAL_UNIT_GP IN NUMBER,
       x_TOTAL_GPA_UNITS IN NUMBER,
       x_GPA IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_TERM_DETAILS_ID IN NUMBER,
       x_TRANSCRIPT_ID IN NUMBER,
       x_TERM IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_TOTAL_CP_ATTEMPTED IN NUMBER,
       x_TOTAL_CP_EARNED IN NUMBER,
       x_TOTAL_UNIT_GP IN NUMBER,
       x_TOTAL_GPA_UNITS IN NUMBER,
       x_GPA IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_TERM_DETAILS_ID IN OUT NOCOPY NUMBER,
       x_TRANSCRIPT_ID IN NUMBER,
       x_TERM IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_TOTAL_CP_ATTEMPTED IN NUMBER,
       x_TOTAL_CP_EARNED IN NUMBER,
       x_TOTAL_UNIT_GP IN NUMBER,
       x_TOTAL_GPA_UNITS IN NUMBER,
       x_GPA IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;

  FUNCTION Get_PK_For_Validation (
    x_term_details_id IN NUMBER
    ) RETURN BOOLEAN ;


  PROCEDURE Get_FK_Igs_Ad_Transcript (
    x_transcript_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_term_details_id IN NUMBER DEFAULT NULL,
    x_transcript_id IN NUMBER DEFAULT NULL,
    x_term IN VARCHAR2 DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_total_cp_attempted IN NUMBER DEFAULT NULL,
    x_total_cp_earned IN NUMBER DEFAULT NULL,
    x_total_unit_gp IN NUMBER DEFAULT NULL,
    x_total_gpa_units IN NUMBER DEFAULT NULL,
    x_gpa IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_term_details_pkg;

 

/
