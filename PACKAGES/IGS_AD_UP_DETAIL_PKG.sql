--------------------------------------------------------
--  DDL for Package IGS_AD_UP_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_UP_DETAIL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI93S.pls 115.6 2003/10/30 13:17:22 akadam ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UP_DETAIL_ID IN OUT NOCOPY NUMBER,
       x_UP_HEADER_ID IN NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UP_DETAIL_ID IN NUMBER,
       x_UP_HEADER_ID IN NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CLOSED_IND IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UP_DETAIL_ID IN NUMBER,
       x_UP_HEADER_ID IN NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UP_DETAIL_ID IN OUT NOCOPY NUMBER,
       x_UP_HEADER_ID IN NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;

  FUNCTION Get_PK_For_Validation (
    x_up_detail_id IN NUMBER,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN ;


  FUNCTION Get_UK_For_Validation (
    x_up_header_id IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN ;


  PROCEDURE Get_FK_Igs_Ad_Up_Header (
    x_up_header_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ps_Unit_Ver (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_up_detail_id IN NUMBER DEFAULT NULL,
    x_up_header_id IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_up_detail_pkg;

 

/
