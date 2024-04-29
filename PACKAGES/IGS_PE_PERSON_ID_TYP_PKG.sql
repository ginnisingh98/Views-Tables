--------------------------------------------------------
--  DDL for Package IGS_PE_PERSON_ID_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PERSON_ID_TYP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI25S.pls 120.0 2005/06/01 16:33:59 appldev noship $ */

------------------------------------------------------------------
-- Change History
--
-- Bug ID : 2000408
-- who      when          what
-- CDCRUZ   Sep 24,2002   New Col added for
--                        Person DLD / FORMAT_MASK
------------------------------------------------------------------

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To create Table Handler Specifications
Know limitations, enhancements or remarks : None
Change History
Who		When		 What
gmuralid  4-dec-2002  included parameter x_region_ind due to column
                      region_ind being included in the table
                      IGS_PE_PERSON_ID_TYP

(reverse chronological order - newest change first)
********************************************************/

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_PERSON_ID_TYPE IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_PREFERRED_IND IN VARCHAR2,
       x_UNIQUE_IND IN VARCHAR2,
       X_FORMAT_MASK IN VARCHAR2 DEFAULT NULL,
       X_REGION_IND IN  VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
      X_CLOSED_IND IN VARCHAR2
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_PERSON_ID_TYPE IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_PREFERRED_IND IN VARCHAR2,
       x_UNIQUE_IND IN VARCHAR2 ,
        X_FORMAT_MASK IN VARCHAR2 DEFAULT NULL,
        X_REGION_IND IN  VARCHAR2
	);

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_PERSON_ID_TYPE IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_PREFERRED_IND IN VARCHAR2,
       x_UNIQUE_IND IN VARCHAR2,
       X_FORMAT_MASK IN VARCHAR2 DEFAULT NULL,
       X_REGION_IND IN  VARCHAR2,
      X_MODE in VARCHAR2 default 'R',
      X_CLOSED_IND IN VARCHAR2
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_PERSON_ID_TYPE IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_PREFERRED_IND IN VARCHAR2,
       x_UNIQUE_IND IN VARCHAR2,
       X_FORMAT_MASK IN VARCHAR2 DEFAULT NULL,
       X_REGION_IND IN  VARCHAR2,
       X_MODE in VARCHAR2 default 'R',
       X_CLOSED_IND IN VARCHAR2
  ) ;

  FUNCTION Get_PK_For_Validation (
    x_person_id_type IN VARCHAR2
    ) RETURN BOOLEAN;

  FUNCTION Get_PID_Type_Validation (
    x_person_id_type IN VARCHAR2
    )  RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_OR_INSTITUTION (
    x_institution_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_person_id_type IN VARCHAR2
    );
PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_person_id_type IN VARCHAR2 DEFAULT NULL,
    x_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_preferred_ind IN VARCHAR2 DEFAULT NULL,
    x_unique_ind IN VARCHAR2 DEFAULT NULL,
    X_FORMAT_MASK IN VARCHAR2 DEFAULT NULL,
    X_REGION_IND IN  VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );

end IGS_PE_PERSON_ID_TYP_PKG;

 

/
