--------------------------------------------------------
--  DDL for Package Body PA_ADMIN_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ADMIN_EXT" as
/* $Header: PAXTRX1B.pls 120.0 2005/05/30 20:15:27 appldev noship $ */


  FUNCTION  allowed_all (X_person_id IN NUMBER) return varchar2 is
--      This function works with view pa_employees_admin_v

	X_dummy NUMBER DEFAULT 0;

	BEGIN
  		  SELECT  COUNT(*)
		  INTO    X_dummy
                  FROM   PER_ASSIGNMENTS_F A
                  ,      PER_ASSIGNMENT_STATUS_TYPES AST
                  WHERE  SUPERVISOR_ID = pa_online_exp.GetAdminPersonId
                  AND    A.PRIMARY_FLAG = 'Y'
                  AND    A.ASSIGNMENT_TYPE IN ('E','C')
		  AND    A.JOB_ID IS NOT NULL
		  AND    A.ORGANIZATION_ID IS NOT NULL
		  AND    AST.ASSIGNMENT_STATUS_TYPE_ID = A.ASSIGNMENT_STATUS_TYPE_ID
		  AND    AST.PER_SYSTEM_STATUS IN ('ACTIVE_ASSIGN','ACTIVE_CWK')
		  AND    A.PERSON_ID = X_person_id;

		IF X_dummy > 0 THEN
			RETURN ( 'TRUE' );
		ELSE
			RETURN ( 'FALSE' );
		END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN ( 'FALSE');
  END allowed_all;

  FUNCTION  allowed_current (X_person_id IN NUMBER,X_ending_date IN DATE) return varchar2 is
--      This function works with view pa_cur_emp_v and the PAXTRONE form LOVs
--      in the New Expenditure Window employee name and employee number fields.

        X_dummy NUMBER DEFAULT 0;
	X_date DATE;

        BEGIN

		  X_date := x_ending_date - 6;

                  SELECT  COUNT(*)
                  INTO    X_dummy
                  FROM   PER_ASSIGNMENTS_F A
                  ,      PER_ASSIGNMENT_STATUS_TYPES AST
                  WHERE  SUPERVISOR_ID = pa_online_exp.GetAdminPersonId
		  AND    (trunc(effective_start_date) between x_date and X_ending_date or
			  trunc(effective_end_date) between X_date and X_ending_date or
			  trunc(sysdate) between effective_start_date and effective_end_date)
                  AND    A.PRIMARY_FLAG = 'Y'
                  AND    A.ASSIGNMENT_TYPE IN ('E','C')
		  AND	 A.JOB_ID IS NOT NULL
		  AND	 A.ORGANIZATION_ID IS NOT NULL
                  AND    AST.ASSIGNMENT_STATUS_TYPE_ID = A.ASSIGNMENT_STATUS_TYPE_ID
                  AND    AST.PER_SYSTEM_STATUS IN ('ACTIVE_ASSIGN','ACTIVE_CWK')
		  AND    A.PERSON_ID = x_person_id;

		IF x_dummy > 0 THEN
                	RETURN ( 'TRUE' );
		ELSE
			RETURN ( 'FALSE' );
		END IF;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        RETURN ( 'FALSE');
  END allowed_current;


end pa_admin_ext;

/
