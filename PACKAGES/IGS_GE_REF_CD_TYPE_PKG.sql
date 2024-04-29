--------------------------------------------------------
--  DDL for Package IGS_GE_REF_CD_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_REF_CD_TYPE_PKG" AUTHID CURRENT_USER as
/* $Header: IGSMI04S.pls 115.7 2003/05/09 06:30:55 sarakshi ship $ */
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sbeerell        09-MAY-2000     Changed according to DLD version 2
  (reverse chronological order - newest change first)
  ***************************************************************/

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  x_SELF_SERVICE_FLAG IN VARCHAR2,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_REFERENCE_CD_TYPE in VARCHAR2,
  x_CLOSED_IND in VARCHAR2,
  x_PROGRAM_FLAG IN VARCHAR2,
  x_PROGRAM_OFFERING_OPTION_FLAG IN VARCHAR2,
  x_UNIT_FLAG IN VARCHAR2,
  x_UNIT_SECTION_FLAG IN VARCHAR2,
  x_UNIT_SECTION_OCCURRENCE_FLAG IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  x_mandatory_flag IN VARCHAR2 DEFAULT NULL ,
  x_restricted_flag IN VARCHAR2 DEFAULT NULL
  );

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  x_SELF_SERVICE_FLAG IN VARCHAR2,
  x_REFERENCE_CD_TYPE IN VARCHAR2,
  x_DESCRIPTION IN VARCHAR2,
  x_S_REFERENCE_CD_TYPE IN VARCHAR2,
  x_CLOSED_IND IN VARCHAR2,
  x_PROGRAM_FLAG IN VARCHAR2,
  x_PROGRAM_OFFERING_OPTION_FLAG IN VARCHAR2,
  x_UNIT_FLAG IN VARCHAR2,
  x_UNIT_SECTION_FLAG IN VARCHAR2,
  x_UNIT_SECTION_OCCURRENCE_FLAG IN VARCHAR2,
  x_mandatory_flag IN VARCHAR2 DEFAULT NULL ,
  x_restricted_flag IN VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  x_SELF_SERVICE_FLAG IN VARCHAR2,
  x_REFERENCE_CD_TYPE IN VARCHAR2,
  x_DESCRIPTION IN VARCHAR2,
  x_S_REFERENCE_CD_TYPE IN VARCHAR2,
  x_CLOSED_IND IN VARCHAR2,
  x_PROGRAM_FLAG IN VARCHAR2,
  x_PROGRAM_OFFERING_OPTION_FLAG IN VARCHAR2,
  x_UNIT_FLAG IN VARCHAR2,
  x_UNIT_SECTION_FLAG IN VARCHAR2,
  x_UNIT_SECTION_OCCURRENCE_FLAG IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_mandatory_flag IN VARCHAR2 DEFAULT NULL ,
  x_restricted_flag IN VARCHAR2 DEFAULT NULL
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  x_SELF_SERVICE_FLAG IN VARCHAR2,
  x_REFERENCE_CD_TYPE IN VARCHAR2,
  x_DESCRIPTION IN VARCHAR2,
  x_S_REFERENCE_CD_TYPE IN VARCHAR2,
  x_CLOSED_IND IN VARCHAR2,
  x_PROGRAM_FLAG IN VARCHAR2,
  x_PROGRAM_OFFERING_OPTION_FLAG IN VARCHAR2,

  x_UNIT_FLAG IN VARCHAR2,
  x_UNIT_SECTION_FLAG IN VARCHAR2,
  x_UNIT_SECTION_OCCURRENCE_FLAG IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  x_mandatory_flag IN VARCHAR2 DEFAULT NULL ,
  x_restricted_flag IN VARCHAR2 DEFAULT NULL
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION GET_PK_FOR_VALIDATION (
    x_reference_cd_type IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_reference_cd_type IN VARCHAR2
   );
PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_self_service_flag IN VARCHAR2 DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_program_flag IN VARCHAR2 DEFAULT NULL,
    x_program_offering_option_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_section_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_section_occurrence_flag IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_mandatory_flag IN VARCHAR2 DEFAULT NULL,
    x_restricted_flag IN VARCHAR2 DEFAULT NULL
  ) ;


end IGS_GE_REF_CD_TYPE_PKG;

 

/
