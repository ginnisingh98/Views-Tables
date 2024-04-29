--------------------------------------------------------
--  DDL for Package IGS_PE_PERS_ENCUMB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PERS_ENCUMB_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSNI18S.pls 120.1 2005/09/30 04:19:26 appldev ship $ */

------------------------------------------------------------------
-- Change History
--
-- Bug ID : 2000408
-- who      when          what
-- CDCRUZ   Sep 24,2002   New Col's added for
--                        Person DLD / cal_type , sequence_number added
-- pkpatel  30-SEP-2002   Bug No: 2600842
--                        Added the column auth_resp_id and the variable 'initialised' was declared
------------------------------------------------------------------

initialised VARCHAR2(1);

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  x_spo_course_cd IN VARCHAR2,
  x_spo_sequence_number IN NUMBER,
  X_CAL_TYPE           IN   VARCHAR2 DEFAULT NULL,
  X_SEQUENCE_NUMBER    IN   NUMBER DEFAULT NULL,
  X_AUTH_RESP_ID  IN NUMBER DEFAULT NULL,
  X_EXTERNAL_REFERENCE in VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  x_spo_course_cd IN VARCHAR2,
  x_spo_sequence_number IN NUMBER,
  X_COMMENTS in VARCHAR2,
  X_CAL_TYPE           IN   VARCHAR2 DEFAULT NULL,
  X_SEQUENCE_NUMBER    IN   NUMBER DEFAULT NULL,
  X_AUTH_RESP_ID  IN NUMBER DEFAULT NULL,
  X_EXTERNAL_REFERENCE in VARCHAR2 DEFAULT NULL
);

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  x_spo_course_cd IN VARCHAR2,
  x_spo_sequence_number IN NUMBER,
  X_CAL_TYPE           IN   VARCHAR2 DEFAULT NULL,
  X_SEQUENCE_NUMBER    IN   NUMBER DEFAULT NULL,
  X_AUTH_RESP_ID  IN NUMBER DEFAULT NULL,
  X_EXTERNAL_REFERENCE in VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_AUTHORISING_PERSON_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  x_spo_course_cd IN VARCHAR2,
  x_spo_sequence_number IN NUMBER,
  X_CAL_TYPE           IN   VARCHAR2 DEFAULT NULL,
  X_SEQUENCE_NUMBER    IN   NUMBER DEFAULT NULL,
  X_AUTH_RESP_ID  IN NUMBER DEFAULT NULL,
  X_EXTERNAL_REFERENCE in VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_encumbrance_type IN VARCHAR2,
    x_start_dt IN DATE
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number  NUMBER
    );

  PROCEDURE GET_FK_IGS_FI_ENCMB_TYPE (
    x_encumbrance_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    );
 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_encumbrance_type IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_authorising_person_id IN NUMBER DEFAULT NULL,
    x_spo_course_cd IN VARCHAR2 DEFAULT NULL,
    x_spo_sequence_number IN NUMBER DEFAULT NULL,
    X_CAL_TYPE           IN   VARCHAR2 DEFAULT NULL,
    X_SEQUENCE_NUMBER    IN   NUMBER DEFAULT NULL,
    X_AUTH_RESP_ID  IN NUMBER DEFAULT NULL,
    X_EXTERNAL_REFERENCE in VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );


end IGS_PE_PERS_ENCUMB_PKG;

 

/
