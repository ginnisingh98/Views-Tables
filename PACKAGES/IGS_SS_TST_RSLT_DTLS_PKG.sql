--------------------------------------------------------
--  DDL for Package IGS_SS_TST_RSLT_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SS_TST_RSLT_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSS07S.pls 115.4 2002/11/29 04:08:53 nsidana noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_TST_RSLT_DTLS_ID IN OUT NOCOPY NUMBER,
       x_TEST_RESULTS_ID IN NUMBER,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_TEST_SCORE IN NUMBER,
       X_MODE in VARCHAR2 default 'I'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_TST_RSLT_DTLS_ID IN NUMBER,
       x_TEST_RESULTS_ID IN NUMBER,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_TEST_SCORE IN NUMBER
 );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_TST_RSLT_DTLS_ID IN NUMBER,
       x_TEST_RESULTS_ID IN NUMBER,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_TEST_SCORE IN NUMBER,
       X_MODE in VARCHAR2 default 'I'
  );

 procedure ADD_ROW (
       x_ROWID          IN OUT NOCOPY VARCHAR2,
       x_TST_RSLT_DTLS_ID IN OUT NOCOPY NUMBER,
       x_TEST_RESULTS_ID IN NUMBER,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_TEST_SCORE IN NUMBER,
       X_MODE in VARCHAR2 default 'I',
       x_return_status		OUT NOCOPY     VARCHAR2,
       x_msg_count			OUT NOCOPY     NUMBER,
       x_msg_data			OUT NOCOPY     VARCHAR2
  ) ;


  FUNCTION Get_PK_For_Validation (
    x_tst_rslt_dtls_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_test_results_id IN NUMBER,
    x_test_segment_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Test_Results (
    x_test_results_id IN NUMBER
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
    x_tst_rslt_dtls_id IN NUMBER DEFAULT NULL,
    x_test_results_id IN NUMBER DEFAULT NULL,
    x_test_segment_id IN NUMBER DEFAULT NULL,
    x_test_score IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END IGS_SS_TST_RSLT_DTLS_PKG;

 

/
