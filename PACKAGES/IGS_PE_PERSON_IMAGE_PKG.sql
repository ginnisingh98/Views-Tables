--------------------------------------------------------
--  DDL for Package IGS_PE_PERSON_IMAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PERSON_IMAGE_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSNI17S.pls 115.3 2002/11/29 01:18:30 nsidana ship $ */


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_IMAGE_DT in out NOCOPY DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_IMAGE_DT in DATE
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_image_dt IN DATE
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    );

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_image_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_PE_PERSON_IMAGE_PKG;

 

/
