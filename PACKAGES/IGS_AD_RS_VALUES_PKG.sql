--------------------------------------------------------
--  DDL for Package IGS_AD_RS_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_RS_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI74S.pls 115.6 2003/10/30 13:16:41 akadam ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_RATING_VALUES_ID IN OUT NOCOPY NUMBER,
       x_RATING_SCALE_ID IN NUMBER,
       x_RATING_VALUE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_RATING_VALUES_ID IN NUMBER,
       x_RATING_SCALE_ID IN NUMBER,
       x_RATING_VALUE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_RATING_VALUES_ID IN NUMBER,
       x_RATING_SCALE_ID IN NUMBER,
       x_RATING_VALUE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_RATING_VALUES_ID IN OUT NOCOPY NUMBER,
       x_RATING_SCALE_ID IN NUMBER,
       x_RATING_VALUE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_rating_values_id IN NUMBER,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_rating_scale_id IN NUMBER,
    x_rating_value IN VARCHAR2,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Rating_Scales (
    x_rating_scale_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_rating_values_id IN NUMBER DEFAULT NULL,
    x_rating_scale_id IN NUMBER DEFAULT NULL,
    x_rating_value IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_rs_values_pkg;

 

/
