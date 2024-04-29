--------------------------------------------------------
--  DDL for Package IGS_SC_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SC_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSSC06S.pls 120.1 2005/09/08 15:37:27 appldev noship $ */
/******************************************************************
  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.
 Created By         : Don Shellito
 Date Created By    : April 8, 2003
 Purpose            : This package is to be used for the processing and
                      gathering of the security process for Oracle
                      Student System.
 remarks            : None
 Change History
Who             When           What
-----------------------------------------------------------
******************************************************************/
TYPE ATTRIB_REC IS RECORD(
		ADVISOR VARCHAR2(4000) DEFAULT NULL,
		ADVISOR_PERSON_ID VARCHAR2(4000) DEFAULT NULL,
		APPLICATION_PROGRAM_CODE VARCHAR2(4000) DEFAULT NULL,
		APPLICATION_TYPE VARCHAR2(4000) DEFAULT NULL,
		INSTRUCTOR_ID VARCHAR2(4000) DEFAULT NULL,
		INSTRUCTOR_PERSON_ID VARCHAR2(4000) DEFAULT NULL,
		LOCATION  VARCHAR2(4000) DEFAULT NULL,
		NOMINATED_COURSE_CODE VARCHAR2(4000) DEFAULT NULL,
		ORGANIZATIONAL_UNIT_CODE VARCHAR2(4000) DEFAULT NULL,
		OWNING_ORG_UNIT_CODE VARCHAR2(4000) DEFAULT NULL,
		PERSON_ID VARCHAR2(4000) DEFAULT NULL,
		PERSON_TYPE VARCHAR2(4000) DEFAULT NULL,
		PROGRAM_ATTEMPT_ADVISOR VARCHAR2(4000) DEFAULT NULL,
		PROGRAM_ATTEMPT_LOCATION VARCHAR2(4000) DEFAULT NULL,
		PROGRAM_ATT_OWNING_ORG_UNIT_CD VARCHAR2(4000) DEFAULT NULL,
		PROGRAM_ATT_RESP_ORG_UNIT_CD VARCHAR2(4000) DEFAULT NULL,
		PROGRAM_ATTEMPT_TYPE VARCHAR2(4000) DEFAULT NULL,
		PROGRAM_OWNING_ORG_UNIT_CODE VARCHAR2(4000) DEFAULT NULL,
		PROGRAM_RESP_ORG_UNIT_CODE VARCHAR2(4000) DEFAULT NULL,
		PROGRAM_TYPE VARCHAR2(4000) DEFAULT NULL,
		RESPONSIBLE_ORG_UNIT_CODE VARCHAR2(4000) DEFAULT NULL,
		TEACHING_ORG_UNIT_CODE VARCHAR2(4000) DEFAULT NULL,
		UNIT_LOCATION VARCHAR2(4000) DEFAULT NULL,
		UNIT_MODE VARCHAR2(4000) DEFAULT NULL,
		UNIT_ATT_ORG_UNIT_CODE  VARCHAR2(4000) DEFAULT NULL,
		UNIT_ATTEMPT_LOCATION  VARCHAR2(4000) DEFAULT NULL,
		UNIT_ATTEMPT_INSTRUCTOR VARCHAR2(4000) DEFAULT NULL,
		UNIT_ATTEMPT_MODE VARCHAR2(4000) DEFAULT NULL,
		OTHER_UNIT_ORG_UNIT_CODE VARCHAR2(4000) DEFAULT NULL,
		OTHER_UNIT_LOCATION VARCHAR2(4000) DEFAULT NULL,
		OTHER_UNIT_INSTRUCTOR VARCHAR2(4000) DEFAULT NULL,
		OTHER_UNIT_MODE VARCHAR2(4000) DEFAULT NULL
);

PROCEDURE set_ctx(
  p_name VARCHAR2
);
PROCEDURE unset_ctx(
  p_name VARCHAR2
);

FUNCTION check_ins_security(
  p_BO_NAME      IN VARCHAR2,
  p_object_name  IN VARCHAR2,
  p_attrib_tab   IN attrib_rec,
  p_msg_data OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

FUNCTION CHECK_SEL_UPD_DEL_SECURITY (
 P_Tab_Name IN VARCHAR2,
 P_Rowid    IN ROWID,
 P_Action   IN VARCHAR2, --(U/D - Update/Delete)
 P_Msg_data OUT NOCOPY VARCHAR2) -- return the error message in case of any exceptions.
RETURN BOOLEAN; -- TRUE if update/delete privileges are there else return FALSE

FUNCTION CHECK_PERSON_SECURITY (
 P_Table_Name IN VARCHAR2,
 P_Person_id    IN NUMBER,
 P_Action   IN VARCHAR2, --(S/U - Select/Update)
 P_Msg_data OUT NOCOPY VARCHAR2) -- return the error message in case of any exceptions.
RETURN BOOLEAN;

FUNCTION check_user_policy
( P_BUSINESS_OBJECT   IN          varchar2, -- BO name
  P_ACTION            IN          varchar2 , -- S,I,D,U
  P_USER_ID           IN          number DEFAULT NULL) -- fnd user id)
RETURN VARCHAR2;

END IGS_SC_GEN_001;

 

/