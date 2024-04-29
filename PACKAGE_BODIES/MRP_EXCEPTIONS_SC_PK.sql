--------------------------------------------------------
--  DDL for Package Body MRP_EXCEPTIONS_SC_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_EXCEPTIONS_SC_PK" AS
/* $Header: MRPPEPKB.pls 115.0 99/07/16 12:32:12 porting ship $ */

PROCEDURE MRP_COMPUTE_EXCEPTIONS (p_query_id	IN	NUMBER,
    				p_planner	IN      VARCHAR2,
    				p_org_id  	IN      NUMBER,
    				p_plan_org_id	IN      NUMBER,
    				p_plan_name     IN      VARCHAR2,
    				p_plan_start_date IN    DATE) IS
/* Constant declarations */
SYS_YES  CONSTANT NUMBER := 1;

BEGIN

/* $Header: MRPPEPKB.pls 115.0 99/07/16 12:32:12 porting ship $ */

/* Insert one row into mrp_form_query for each exception type:
	1  - Items that are over-committed
	2  - Items with a shortage
	3  - Items with excess inventory
	4  - Items with repetitive variance
  	5  - Items with no activity
  	6  - Orders to be rescheduled in
  	7  - Orders to be rescheduled out
  	8  - Orders to be cancelled
  	9  - Orders with compression days
 	10 - Past due orders

   The column number1 will be set to the exception type.
   The column number2 will be set to the number of items that
   have raised each exception.
   For order level exceptions (6 through 10 above), the column
   number3 will be set to the number of orders that have
   raised the exception.
*/

IF p_planner is NULL THEN
	INSERT INTO mrp_form_query
	   	(query_id,
    	    	last_update_date,
	    	last_updated_by,
	    	creation_date,
	    	created_by,
	    	last_update_login,
	    	number1,   /* exception type */
	    	number2,   /* number of items */
	    	char1,     /* exception type meaning */
	    	number3,   /* number of orders */
	    	char8,     /* compile designator */
            	number4)   /* plan organization id */
	SELECT 	P_QUERY_ID,
	       	sysdate,
	       	1,
	       	sysdate,
	       	1,
	       	1,
	       	lu.lookup_code,
	       	count(ex.organization_id),
	       	lu.meaning,
	       	decode(lu.lookup_code, 6, 0, 7, 0, 8, 0, 9, 0, 10, 0, NULL),
               	p_plan_name,
 	       	orgs.organization_id
	FROM   	mfg_lookups lu,
	       	mrp_item_exceptions ex,
               	mrp_plan_organizations_v orgs
	WHERE  	lu.lookup_type = 'MRP_EXCEPTION_CODE_TYPE'
	AND	lu.lookup_code <=10
	AND    	ex.exception_type  = lu.lookup_code
	AND    	ex.organization_id  = orgs.planned_organization
	AND    	ex.compile_designator  = orgs.compile_designator
	AND     ex.version is null
	AND    	ex.display  = SYS_YES
        AND    	orgs.compile_designator = p_plan_name
        AND    	orgs.organization_id = p_plan_org_id
        AND    	orgs.planned_organization = DECODE(p_org_id,
			p_plan_org_id, orgs.planned_organization,
			p_org_id)
	GROUP BY lu.lookup_code, lu.meaning,
                 orgs.organization_id;

	/*------------------------------------+
	| Update the  number3 column to the   |
	| numbers orders having the exception |
	+------------------------------------*/
	UPDATE 	mrp_form_query q
	SET   	number3 =     /* number of orders */
		(SELECT	COUNT(r.organization_id)
		 FROM  	mrp_recommendations r,
			mrp_item_exceptions e,
			mrp_plan_organizations_v orgs
		 WHERE  ((q.number1 = 6 /* reschedule in */
			  AND r.new_schedule_date < r.old_schedule_date)
			 OR
			 (q.number1 = 7 /* reschedule out */
			  AND r.new_schedule_date> r.old_schedule_date
			  AND r.new_schedule_date > P_PLAN_START_DATE)
			 OR
			 (q.number1 = 8 /* cancel */
			  AND r.DISPOSITION_STATUS_TYPE = 2)
			 OR
			 (q.number1 = 9 /* compression days */
			  AND nvl(r.SCHEDULE_COMPRESSION_DAYS,0) > 0)
			 OR
			 (q.number1 = 10 /* past due */
			  AND r.NEW_SCHEDULE_DATE > r.OLD_SCHEDULE_DATE
			  AND r.OLD_SCHEDULE_DATE < P_PLAN_START_DATE))
		 AND    r.organization_id = e.organization_id
		 AND    r.COMPILE_DESIGNATOR = e.compile_designator
		 AND    r.inventory_item_id = e.inventory_item_id
		 AND    r.NEW_ORDER_QUANTITY > 0
		 AND    e.organization_id = orgs.planned_organization
		 AND    e.compile_designator = orgs.compile_designator
		 AND 	e.version is null
		 AND    orgs.COMPILE_DESIGNATOR = P_PLAN_NAME
		 AND    orgs.planned_organization = DECODE(P_ORG_ID,
				P_PLAN_ORG_ID, orgs.planned_organization, P_ORG_ID)
		 AND    e.display = SYS_YES
		 AND    e.EXCEPTION_TYPE = q.number1)
	WHERE	q.number2 <> 0
	  AND   q.query_id = p_query_id
	  AND   q.number1 IN (6, 7, 8, 9, 10);

ELSE
	INSERT INTO mrp_form_query
		(query_id,
    		last_update_date,
    		last_updated_by,
	    	creation_date,
	    	created_by,
	    	last_update_login,
	    	number1,   /* exception type */
	    	number2,   /* number of items */
	    	char1,     /* exception type meaning */
	    	number3,   /* number of orders */
		char8,
		number4)
	SELECT 	P_QUERY_ID,
	        sysdate,
	        1,
	        sysdate,
	        1,
	        1,
	        lu.lookup_code,
	        COUNT(ex.organization_id),
	        lu.meaning,
	        DECODE(lu.lookup_code, 6, 0, 7, 0, 8, 0, 9, 0, 10, 0, NULL),
			P_PLAN_NAME,
		orgs.organization_id
	FROM 	mfg_lookups lu,
		mrp_item_exceptions ex,
	        mrp_system_items sys,
  		mrp_plan_organizations_v orgs
	WHERE  	lu.lookup_type = 'MRP_EXCEPTION_CODE_TYPE'
	AND 	lu.lookup_code <=10
	AND	lu.lookup_code = ex.exception_type
	AND	ex.display = SYS_YES
	AND   	ex.version is null
	AND	ex.organization_id = sys.organization_id
	AND     ex.compile_designator = sys.compile_designator
	AND     ex.inventory_item_id  = sys.inventory_item_id
	AND     sys.planner_code = P_PLANNER
	AND 	sys.organization_id = orgs.planned_organization
	AND	sys.compile_designator = orgs.compile_designator
        AND  	orgs.compile_designator = P_PLAN_NAME
	AND    	orgs.organization_id = P_PLAN_ORG_ID
        AND    	orgs.planned_organization = DECODE(P_ORG_ID,
			P_PLAN_ORG_ID, orgs.planned_organization,
			P_ORG_ID)
	GROUP BY lu.lookup_code, lu.meaning, orgs.organization_id;

      /*------------------------------------+
      | Update the  number3 column to the   |
      | numbers orders having the exception |
      +------------------------------------*/

	UPDATE	mrp_form_query q
	SET    	number3 =     /* number of orders */
		(select	COUNT(r.organization_id)
		FROM   	mrp_recommendations r,
			mrp_item_exceptions e,
			mrp_system_items    s
		where  ((q.number1 = 6 /* reschedule in */
			and r.new_schedule_date < r.old_schedule_date)
			or
			(q.number1 = 7 /* reschedule out */
			and r.new_schedule_date> r.old_schedule_date
			and r.new_schedule_date > P_PLAN_START_DATE)
			or
			(q.number1 = 8 /* cancel */
			and r.DISPOSITION_STATUS_TYPE = 2)
			or
			(q.number1 = 9 /* compression days */
			and nvl(r.SCHEDULE_COMPRESSION_DAYS,0) > 0)
			or
			(q.number1 = 10 /* past due */
		and r.new_schedule_date > r.OLD_SCHEDULE_DATE
		and 	r.old_schedule_date < P_PLAN_START_DATE))
		and    r.organization_id = e.organization_id
		and    r.compile_designator = e.compile_designator
		and    r.new_order_quantity > 0
		and    r.inventory_item_id = e.inventory_item_id
		and    e.display = SYS_YES
		and    e.version is null
		and    e.organization_id = s.organization_id
		and    e.compile_designator = s.compile_designator
		and    e.inventory_item_id = s.inventory_item_id
		and    e.exception_type = q.number1
		and    s.organization_id = P_ORG_ID
		and    s.compile_designator = P_PLAN_NAME
		and    s.planner_code = P_PLANNER)
	where 	q.number2 <> 0
	and   	q.query_id = P_QUERY_ID
	and   	q.number1 in (6, 7, 8, 9, 10);
END IF;
END MRP_COMPUTE_EXCEPTIONS;  /* End procedure */

END MRP_EXCEPTIONS_SC_PK;   /* End package */

/
