--------------------------------------------------------
--  DDL for Package IGS_AD_UP_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_UP_HEADER_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI92S.pls 115.7 2002/11/28 22:19:56 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_MAX_SCORE IN NUMBER,
       x_UP_HEADER_ID IN OUT NOCOPY NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_DEFINITION_LEVEL IN VARCHAR2,
       x_MIN_SCORE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_MAX_SCORE IN NUMBER,
       x_UP_HEADER_ID IN NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_DEFINITION_LEVEL IN VARCHAR2,
       x_MIN_SCORE IN NUMBER  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_MAX_SCORE IN NUMBER,
       x_UP_HEADER_ID IN NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_DEFINITION_LEVEL IN VARCHAR2,
       x_MIN_SCORE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_MAX_SCORE IN NUMBER,
       x_UP_HEADER_ID IN OUT NOCOPY NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_DEFINITION_LEVEL IN VARCHAR2,
       x_MIN_SCORE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_up_header_id IN NUMBER
    ) RETURN BOOLEAN ;


  FUNCTION Get_UK_For_Validation (
    x_admission_test_type IN VARCHAR2,
        x_test_segment_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Uniqueness;

  PROCEDURE Get_FK_Igs_Ad_Test_Type (
    x_admission_test_type IN VARCHAR2
    );

  PROCEDURE Get_FK_Igs_Ad_Test_Segments (
    x_test_segment_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_max_score IN NUMBER DEFAULT NULL,
    x_up_header_id IN NUMBER DEFAULT NULL,
    x_admission_test_type IN VARCHAR2 DEFAULT NULL,
    x_test_segment_id IN NUMBER DEFAULT NULL,
    x_definition_level IN VARCHAR2 DEFAULT NULL,
    x_min_score IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_up_header_pkg;

 

/
