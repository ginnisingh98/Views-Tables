--------------------------------------------------------
--  DDL for Package MRP_LAUNCH_PLAN_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_LAUNCH_PLAN_PK" AUTHID CURRENT_USER AS
/* $Header: MRPPLAPS.pls 115.4 2002/11/26 18:55:08 jhegde ship $ */
	PROCEDURE 	mrp_launch_plan (
						errbuf  OUT NOCOPY VARCHAR2,
						retcode OUT NOCOPY NUMBER,
						arg_org_id IN NUMBER,
						arg_compile_desig IN VARCHAR2,
						arg_launch_snapshot IN NUMBER,
						arg_launch_planner IN NUMBER,
						arg_anchor_date IN VARCHAR2,
						arg_plan_horizon IN VARCHAR2 default NULL);

	FUNCTION get_crp_status (
						app_id IN NUMBER,
						dep_app_id IN NUMBER)
						RETURN VARCHAR2;
     PRAGMA RESTRICT_REFERENCES (get_crp_status, WNDS, WNPS);



	/*-----------------+
	| Define constants |
	+-----------------*/

	SYS_YES         CONSTANT INTEGER := 1;
	SYS_NO          CONSTANT INTEGER := 2;
	VERSION                 CONSTANT CHAR(80) :=
			'$Header: MRPPLAPS.pls 115.4 2002/11/26 18:55:08 jhegde ship $';

END mrp_launch_plan_pk;

 

/
