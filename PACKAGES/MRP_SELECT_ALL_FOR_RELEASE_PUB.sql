--------------------------------------------------------
--  DDL for Package MRP_SELECT_ALL_FOR_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SELECT_ALL_FOR_RELEASE_PUB" AUTHID CURRENT_USER AS
    /* $Header: MRPSARPS.pls 120.2 2006/02/01 05:11:59 arrsubra noship $ */

	PROCEDURE Update_Implement_Attrib(p_where_clause IN VARCHAR2,
									  p_employee_id IN NUMBER,
									  p_demand_class IN VARCHAR2,
									  p_def_job_class IN VARCHAR2,
									  p_def_firm_jobs IN VARCHAR2,
									  p_total_rows OUT NOCOPY NUMBER,
									  p_succ_rows OUT NOCOPY NUMBER,
									  p_error_rows OUT NOCOPY NUMBER);


	PROCEDURE Update_Recom_Attrib(
								  p_employee_id IN NUMBER,
								  p_demand_class IN VARCHAR2,
								  p_def_job_class IN VARCHAR2,
								  p_def_firm_jobs IN VARCHAR2);

	Procedure Update_Pre_Process_Errors(
			p_no_rec_rows IN NUMBER,
			p_no_rep_rows IN NUMBER);



	PROCEDURE Update_Rep_Attrib(p_demand_class IN VARCHAR2);

	FUNCTION Select_Rec_Rows(p_where_clause IN VARCHAR2) return NUMBER;

	FUNCTION Select_Rep_Rows(p_where_clause IN VARCHAR2) return NUMBER;

	FUNCTION Count_Row_Errors return NUMBER;

	Procedure Rollback_Action;
	Procedure Commit_Action;
	Procedure Update_Job_Name( arg_org_id IN NUMBER,
		  arg_compile_designator IN VARCHAR2) 	; --3463551

	Procedure Update_Identical_Job_Name
		( arg_org_id 			IN 	NUMBER
		, arg_compile_desig 		IN 	VARCHAR2);--4990499

	/*
	** These functions are a duplicate of the general calendar
	** functions that we have in MRP. This is done for PRAGMA
	** reasons. Note that any change made to the code, in either
	** place can be propagated.
	*/

	FUNCTION RELALL_NEXT_WORK_DAY(arg_org_id IN NUMBER,
                         arg_bucket IN NUMBER,
                         arg_date IN DATE) RETURN DATE;
	FUNCTION RELALL_PREV_WORK_DAY(arg_org_id IN NUMBER,
                         arg_bucket IN NUMBER,
                         arg_date IN DATE) RETURN DATE;
    FUNCTION RELALL_PREV_WORK_DAY_SEQNUM(arg_org_id IN NUMBER,
                 arg_bucket IN NUMBER,
                 arg_date IN DATE) RETURN NUMBER;

   	PROCEDURE RELALL_SELECT_CAL_DEFAULTS( arg_org_id IN NUMBER,
                              arg_calendar_code OUT NOCOPY VARCHAR2,
                              arg_exception_set_id OUT NOCOPY NUMBER);

	PROCEDURE RELALL_MRP_CAL_INIT_GLOBAL(
		arg_calendar_code       VARCHAR,
		arg_exception_set_id    NUMBER);

	FUNCTION RELALL_DAYS_BETWEEN( arg_org_id IN NUMBER,
                    arg_bucket IN NUMBER,
                    arg_date1 IN DATE,
                         arg_date2 IN DATE) RETURN NUMBER;


	FUNCTION RELALL_DEFAULT_ACC_CLASS
         (X_ORG_ID       IN     NUMBER,
          X_ITEM_ID      IN     NUMBER,
          X_ENTITY_TYPE  IN     NUMBER,
          X_PROJECT_ID   IN     NUMBER
         )
		RETURN VARCHAR2;

	FUNCTION RELALL_CHECK_DISABLED(
		X_CLASS IN VARCHAR2,
		X_ORG_ID IN NUMBER,
		X_ENTITY_TYPE IN NUMBER)
			RETURN NUMBER;

	FUNCTION RELALL_CHECK_VALID_CLASS(
		X_CLASS IN VARCHAR2,
		X_ORG_ID IN NUMBER)
			RETURN NUMBER;

	PRAGMA RESTRICT_REFERENCES (RELALL_NEXT_WORK_DAY, WNDS);
	PRAGMA RESTRICT_REFERENCES (RELALL_SELECT_CAL_DEFAULTS, WNDS);
	PRAGMA RESTRICT_REFERENCES (RELALL_MRP_CAL_INIT_GLOBAL, WNDS);
	PRAGMA RESTRICT_REFERENCES (RELALL_DAYS_BETWEEN, WNDS);
	PRAGMA RESTRICT_REFERENCES (RELALL_PREV_WORK_DAY, WNDS);
	PRAGMA RESTRICT_REFERENCES (RELALL_PREV_WORK_DAY_SEQNUM, WNDS);
	PRAGMA RESTRICT_REFERENCES (RELALL_DEFAULT_ACC_CLASS, WNDS);
	PRAGMA RESTRICT_REFERENCES (RELALL_CHECK_DISABLED, WNDS);
	PRAGMA RESTRICT_REFERENCES (RELALL_CHECK_VALID_CLASS, WNDS);

	g_rec_query_id NUMBER;
	g_rep_query_id NUMBER;
END MRP_SELECT_ALL_FOR_RELEASE_PUB;

 

/
