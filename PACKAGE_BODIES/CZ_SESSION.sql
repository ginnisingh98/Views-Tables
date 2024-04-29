--------------------------------------------------------
--  DDL for Package Body CZ_SESSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_SESSION" AS
/*	$Header: czsesb.pls 115.7 2002/11/27 17:16:41 askhacha ship $		  */

FUNCTION PROJECT_ID RETURN INTEGER IS
	P_ID INTEGER;
BEGIN
	P_ID:=CZ_SESSION.CURRENT_PROJECT;
RETURN P_ID;
END PROJECT_ID;
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
FUNCTION POPULATOR_ID RETURN INTEGER IS
	POP_ID INTEGER;
BEGIN
	POP_ID:=CZ_SESSION.CURRENT_POPULATOR;
RETURN POP_ID;
END POPULATOR_ID;
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
PROCEDURE POP_VIEW_FILTER (PROJECT_ID IN INTEGER DEFAULT NULL,POPULATOR_ID IN INTEGER DEFAULT NULL) IS
BEGIN
	CZ_SESSION.CURRENT_PROJECT:=PROJECT_ID;
	CZ_SESSION.CURRENT_POPULATOR:=POPULATOR_ID;
END POP_VIEW_FILTER;
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure ENABLE_PROJ_TIMESTAMP_TRIGS is
begin
	PROJ_TIMESTAMP_TRIGGERS_ON := TRUE;
end ENABLE_PROJ_TIMESTAMP_TRIGS;

procedure DISABLE_PROJ_TIMESTAMP_TRIGS is
begin
	PROJ_TIMESTAMP_TRIGGERS_ON := FALSE;
end DISABLE_PROJ_TIMESTAMP_TRIGS;

procedure STAMP_STRUCT_UPDATED (for_project_id in NUMBER) is
begin
	update CZ_DEVL_PROJECTS
	set LAST_STRUCT_UPDATE = SYSDATE
	where DEVL_PROJECT_ID = for_project_id;
end STAMP_STRUCT_UPDATED;

procedure STAMP_LOGIC_UPDATED (for_project_id in NUMBER) is
begin
	update CZ_DEVL_PROJECTS
	set LAST_LOGIC_UPDATE = SYSDATE
	where DEVL_PROJECT_ID = for_project_id;
end STAMP_LOGIC_UPDATED;

procedure STAMP_PROJECT_UPDATED (for_project_id in NUMBER) is
begin
	update CZ_DEVL_PROJECTS
	set LAST_STRUCT_UPDATE = SYSDATE,
		LAST_LOGIC_UPDATE = SYSDATE
	where DEVL_PROJECT_ID = for_project_id;
end STAMP_PROJECT_UPDATED;


END  CZ_SESSION;

/
