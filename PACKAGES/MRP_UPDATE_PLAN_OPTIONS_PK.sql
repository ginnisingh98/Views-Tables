--------------------------------------------------------
--  DDL for Package MRP_UPDATE_PLAN_OPTIONS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_UPDATE_PLAN_OPTIONS_PK" AUTHID CURRENT_USER AS
/* $Header: MRPPUPLS.pls 115.0 99/07/16 12:35:29 porting ship $ */

	PROCEDURE 	mrp_update_options (
						arg_org_id IN NUMBER,
						arg_user_id IN NUMBER,
						arg_compile_desig IN VARCHAR2);

	PROCEDURE   mrp_set_completion_time (
						arg_org_id IN NUMBER,
						arg_user_id IN NUMBER,
						arg_compile_desig IN VARCHAR2);

	SYS_NO				CONSTANT INTEGER := 2;
	SINGLE_ORG          CONSTANT INTEGER := 1;
	CURRENT_LEVEL		CONSTANT INTEGER := 2;
	LAST_SUBMITTED	  	CONSTANT INTEGER := 3;
	LAST_LAST_SUBMITTED	CONSTANT INTEGER := 4;
	VERSION             CONSTANT CHAR(80) :=
			'$Header: MRPPUPLS.pls 115.0 99/07/16 12:35:29 porting ship $';

END mrp_update_plan_options_pk;

 

/
