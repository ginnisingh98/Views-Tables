--------------------------------------------------------
--  DDL for Package IGS_AD_ROOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_ROOM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIB5S.pls 115.8 2003/10/30 13:17:33 akadam ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
			X_ORG_ID in NUMBER,
       x_ROOM_ID IN OUT NOCOPY NUMBER,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PRIMARY_USE_CD IN VARCHAR2,
       x_CAPACITY IN NUMBER,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_ROOM_ID IN NUMBER,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PRIMARY_USE_CD IN VARCHAR2,
       x_CAPACITY IN NUMBER,
       x_CLOSED_IND IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_ROOM_ID IN NUMBER,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PRIMARY_USE_CD IN VARCHAR2,
       x_CAPACITY IN NUMBER,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
			X_ORG_ID in NUMBER,
       x_ROOM_ID IN OUT NOCOPY NUMBER,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PRIMARY_USE_CD IN VARCHAR2,
       x_CAPACITY IN NUMBER,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_room_id IN NUMBER ,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_building_id IN NUMBER,
    x_room_cd IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Building (
    x_building_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
		X_ORG_ID IN NUMBER DEFAULT NULL,
    x_room_id IN NUMBER DEFAULT NULL,
    x_building_id IN NUMBER DEFAULT NULL,
    x_room_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_primary_use_cd IN VARCHAR2 DEFAULT NULL,
    x_capacity IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_room_pkg;

 

/
