--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_LOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_LOCATION_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0LS.pls 115.6 2002/11/29 01:58:05 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_LOCATION_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_LOCATION_CODE IN VARCHAR2,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_LOCATION_ID IN NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_LOCATION_CODE IN VARCHAR2,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_ID IN NUMBER  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_LOCATION_ID IN NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_LOCATION_CODE IN VARCHAR2,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_LOCATION_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_LOCATION_CODE IN VARCHAR2,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_location_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_location_code IN VARCHAR2,
    x_room_id IN NUMBER,
    x_unit_code IN VARCHAR2,
    x_unit_version_number IN NUMBER,
    x_building_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Location (
    x_location_cd IN VARCHAR2
    );

  PROCEDURE Get_FK_Igs_Ps_Unit_Ver (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ad_Room (
    x_room_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ad_Building (
    x_building_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_location_id IN NUMBER DEFAULT NULL,
    x_unit_code IN VARCHAR2 DEFAULT NULL,
    x_unit_version_number IN NUMBER DEFAULT NULL,
    x_location_code IN VARCHAR2 DEFAULT NULL,
    x_building_id IN NUMBER DEFAULT NULL,
    x_room_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_unit_location_pkg;

 

/
