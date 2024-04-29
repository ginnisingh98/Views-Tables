--------------------------------------------------------
--  DDL for Package Body CN_SRP_PER_QUOTA_RC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PER_QUOTA_RC_PKG" as
/* $Header: cnsrprcb.pls 120.1 2005/12/19 13:37:22 mblum noship $ */

--Date      Name          Description
----------------------------------------------------------------------------+
--12-FEB-95 P Cook
--24-JUL-95 P Cook	Split up the insert a little more to maintain perf.
--28-JUL-95 P Cook	Removed statment to insert/delete records when
--			the quota type was changed from/to revenue
--04-AUG-95 P Cook	Added insert of mandatory QUARTER_TO_DATE column
--
--08-SEP-99 S Kumar     Modified this package with the date effectivity
--                      Modified the cn_periods to cn_period_statuses
--                      Added start date, end_date parameters.
-- Procedure Name
--
-- Purpose
--  Remove revenue class records
--
-- When the procedure is called		  	        Passed Parameters

-- 1. Once for each deleted srp plan assignment. 	x_srp_plan_assign_id

-- 2. Once for each srp_plan_assign referencing the 	x_srp_plan_assign_id
--	comp plan of a deleted cn_quota_assign.		x_quota_id

-- 3. Once for each deleted cn_quota_rule.		x_quota_id
--							x_revenue_class_id

-- 4. Once for each quota whose type has been		x_quota_id
--    changed to manual or draw.

-- 5. The quota's date range changed			x_quota_id
----------------------------------------------------------------------------+
-- Delete_Record
----------------------------------------------------------------------------+
PROCEDURE Delete_Record( x_srp_plan_assign_id NUMBER
			 ,x_quota_id	      NUMBER
			 ,x_revenue_class_id  NUMBER
			 ,x_start_period_id   NUMBER
			 ,x_end_period_id     NUMBER
			 ,x_start_date        DATE := NULL
			 ,x_end_date          DATE := NULL ) IS
BEGIN

   IF x_srp_plan_assign_id IS NOT NULL THEN
      IF x_quota_id IS NOT NULL THEN
	 -- deleting a plan's quota assignment or quota rule
	 DELETE FROM cn_srp_per_quota_rc_all
           WHERE quota_id 	    = x_quota_id
	   AND srp_plan_assign_id = x_srp_plan_assign_id
	   ;
       ELSE
	 IF x_start_date  IS NULL THEN
	    -- deleting an entire srp_plan_assign or changing the date range
	    DELETE FROM cn_srp_per_quota_rc_all
	      WHERE  srp_plan_assign_id = x_srp_plan_assign_id
	      ;
	  ELSE
           -- Delete the specific periods
	    DELETE FROM cn_srp_per_quota_rc_all
	      WHERE  srp_plan_assign_id = x_srp_plan_assign_id
              AND EXISTS ( select 1 from cn_period_statuses p
			   WHERE  p.start_date >= Nvl(x_start_date,p.start_date)
			   AND  p.end_date  <= Nvl(x_end_date  ,p.end_date)
			   AND cn_srp_per_quota_rc_all.org_id    = p.org_id
			   AND cn_srp_per_quota_rc_all.period_id = p.period_id);
	 END IF; -- start_date is null
      END IF; -- quota_id is not null
    ELSE

      IF x_quota_id IS NOT NULL THEN

	 IF x_revenue_class_id IS NOT NULL THEN

	    -- Deleting a quota rule
	    -- OR the quota type changed to one that doesn not support
	    -- revenue classes

	    DELETE FROM cn_srp_per_quota_rc_all
              WHERE quota_id 	     = x_quota_id
	      AND revenue_class_id = x_revenue_class_id;

          ELSE
	    -- The quota's date range changed and we've deleted all period
	    -- quotas in preparation for insert of the new period quota range
	    -- OR the quota type was changed to one that does not support
	    -- revenue classes

	    -- Modified from cn_periods to cn_period_statuses
	    -- Modified the the start_period_id, end_period_id to
	    -- start date and end date
	    DELETE FROM cn_srp_per_quota_rc_all
              WHERE quota_id = x_quota_id
              AND EXISTS ( select 1 from cn_period_statuses p
			   WHERE  p.start_date >= Nvl(x_start_date,p.start_date)
			   AND  p.end_date  <= Nvl(x_end_date  ,p.end_date)
			   AND cn_srp_per_quota_rc_all.period_id = p.period_id
			   AND cn_srp_per_quota_rc_all.org_id    = p.org_id);

	 END IF; -- revenue_class_id is not null
      END IF; -- quota_id is not null
   END IF; -- srp_plan_assign_id is not null

END Delete_Record;

--
-- Procedure Name
--
-- Purpose
--  Insert quota rule for each rep using the quota in a period,
--  The period restrictions have already been applied when creating
--  cn_srp_period_quotas.

--  Period quotas are created for manual and draw qupta types purely for
--  internal use, the user does not have access to them.
--  We cannot create period quota rev class records for them because
--  thee two quota types do not have any revenue classes

--  We do not attempt to explode any of the rolled up rev classes.
--  The table does not currently support rev class explosion.
--
-- Notes						  Parameters

--   1 Called once for each new srp plan assignment.    x_srp_plan_assign_id

--   2 Called once for each srp plan assignment that    x_srp_plan_assign_id
--     references the comp plan id on a new comp        x_quota_id
--     plan quota assignment
--     The quota_id restriction ensures only the newly
--     assigned quota is inserted.

--   3 Called once for each new quota rule		  x_quota_id
--							  x_revenue_class_id

--   4. Called once when the quota date range is changed x_quota_id

-- Notes
--  Using revenue_class_id instead of quota_rule_id as
--  revenue class/quota_id is unique.
----------------------------------------------------------------------------+
-- Insert Record
----------------------------------------------------------------------------+
PROCEDURE insert_record( x_srp_plan_assign_id NUMBER
			 ,x_quota_id	      NUMBER
			 ,x_revenue_class_id  NUMBER
			 ,x_start_period_id   NUMBER
			 ,x_end_period_id     NUMBER
			 ,x_start_date        DATE
			 ,x_end_date          DATE ) IS

BEGIN

     IF (    x_srp_plan_assign_id   IS NULL
	     AND x_quota_id 	    IS NOT NULL
	     AND x_revenue_class_id IS NOT NULL ) THEN

	-- New quota rule inserted
	-- Insert one record for each srp_period_quota record that references
	-- the quota that has been assigned the new quota rule
	-- Note the new revenue_class in the select statement.

        -- clku, fixed for performance bug 2321076

	INSERT INTO cn_srp_per_quota_rc_all
	  ( srp_per_quota_rc_id
	    ,srp_period_quota_id
	    ,srp_plan_assign_id
	    ,salesrep_id
	    ,period_id
	    ,quota_id
	    ,revenue_class_id
	    ,target_amount
	    ,year_to_date
	    ,period_to_date
	    ,quarter_to_date
	    ,creation_date
	    ,created_by
	    ,last_updated_by
	    ,last_update_date
	    ,last_update_login
	    ,org_id)
	  SELECT
	  cn_srp_per_quota_rc_s.nextval
	  ,pq.srp_period_quota_id
	  ,pq.srp_plan_assign_id
	  ,pq.salesrep_id
	  ,pq.period_id
	  ,pq.quota_id
	  ,x_revenue_class_id
	  ,0 -- target amount
	  ,0 -- ytd
	  ,0 -- ptd
          ,0 -- qtd
	  ,Sysdate
	  ,fnd_global.user_id
	  ,fnd_global.user_id
	  ,Sysdate
	  ,fnd_global.login_id
	  ,pq.org_id
	  FROM  cn_srp_period_quotas_all pq -- periods that rep/plan uses quota
	  ,cn_quotas_all		     q
	  WHERE pq.quota_id = x_quota_id
	  AND q.quota_id    = pq.quota_id
	  AND q.quota_type_code IN ('FORMULA','EXTERNAL')

	  AND NOT EXISTS (SELECT 'srp_period_quota_rc already exists'
			  FROM cn_srp_per_quota_rc_all spqr
			  WHERE spqr.srp_period_quota_id = pq.srp_period_quota_id
			  AND spqr.srp_plan_assign_id = pq.srp_plan_assign_id
			  AND spqr.revenue_class_id    = x_revenue_class_id)
	  ;

      ELSIF (    x_srp_plan_assign_id   IS NULL
		 AND x_quota_id 	IS NOT NULL
		 AND x_revenue_class_id IS NULL ) THEN

	-- Quota's period range changed and having just deleted all the
	-- period quotas and their rev class records we will now insert the
	-- records for the new range

	INSERT INTO cn_srp_per_quota_rc_all
	  ( srp_per_quota_rc_id
	    ,srp_period_quota_id
	    ,srp_plan_assign_id
	    ,salesrep_id
	    ,period_id
	    ,quota_id
	    ,revenue_class_id
	    ,target_amount
	    ,year_to_date
	    ,period_to_date
	    ,quarter_to_date
	    ,creation_date
	    ,created_by
	    ,last_updated_by
	    ,last_update_date
	    ,last_update_login
	    ,org_id)
	  SELECT
	  cn_srp_per_quota_rc_s.nextval
	  ,pq.srp_period_quota_id
	  ,pq.srp_plan_assign_id
	  ,pq.salesrep_id
	  ,pq.period_id
	  ,pq.quota_id
	  ,qr.revenue_class_id
	  ,0 -- target amount
	  ,0 -- ytd
	  ,0 -- ptd
	  ,0 -- qtd
	  ,Sysdate
	  ,fnd_global.user_id
	  ,fnd_global.user_id
	  ,Sysdate
	  ,fnd_global.login_id
	  ,pq.org_id
	  FROM  cn_srp_period_quotas_all pq -- periods that rep/plan uses quota
	  ,cn_quota_rules_all            qr
	  ,cn_quotas_all		 q
	  WHERE pq.quota_id		 = q.quota_id
	  AND qr.quota_id 	 	 = x_quota_id
	  AND q.quota_id		 = qr.quota_id
          AND q.quota_type_code IN ('EXTERNAL','FORMULA')

          AND exists (select 'x' from     cn_period_statuses_all p
 		       where pq.period_id     = p.period_id
		         AND pq.org_id        = p.org_id
                         AND p.period_status in ('O','F')
                         AND p.start_date >= nvl(x_start_date, p.start_date)
                         AND p.end_date   <= nvl(x_end_date,   p.end_date))

	      AND NOT EXISTS (SELECT 'srp_period_quota_rc already exists'
			      FROM cn_srp_per_quota_rc_all spqr
			      WHERE spqr.srp_period_quota_id = pq.srp_period_quota_id
			      AND spqr.srp_plan_assign_id = pq.srp_plan_assign_id
			      AND spqr.revenue_class_id    = qr.revenue_class_id)
	      ;

      ELSIF (    x_srp_plan_assign_id   IS NOT NULL
		 AND x_quota_id 	IS NOT NULL
		 AND x_revenue_class_id IS NULL ) THEN

	-- A new cn_quota_assign has been created

	INSERT INTO cn_srp_per_quota_rc
	  ( srp_per_quota_rc_id
	    ,srp_period_quota_id
	    ,srp_plan_assign_id
	    ,salesrep_id
	    ,period_id
	    ,quota_id
	    ,revenue_class_id
	    ,target_amount
	    ,year_to_date
	    ,period_to_date
	    ,quarter_to_date
	    ,creation_date
	    ,created_by
	    ,last_updated_by
	    ,last_update_date
	    ,last_update_login
	    ,org_id)
	  SELECT
	  cn_srp_per_quota_rc_s.nextval
	  ,pq.srp_period_quota_id
	  ,pq.srp_plan_assign_id
	  ,pq.salesrep_id
	  ,pq.period_id
	  ,pq.quota_id
	  ,qr.revenue_class_id
	  ,0 -- target amount
	  ,0 -- ytd
	  ,0 -- ptd
	  ,0 -- qtd
	  ,Sysdate
	  ,fnd_global.user_id
	  ,fnd_global.user_id
	  ,Sysdate
	  ,fnd_global.login_id
	  ,pq.org_id
	  FROM  cn_srp_period_quotas_all pq -- periods that rep/plan uses quota
	  ,cn_quota_rules_all            qr
	  ,cn_quotas_all		 q
	  WHERE pq.srp_plan_assign_id = x_srp_plan_assign_id
	  AND pq.quota_id	      = qr.quota_id
	  AND qr.quota_id 	      = q.quota_id
	  AND q.quota_id	      = x_quota_id
	  AND q.quota_type_code IN ('EXTERNAL','FORMULA')

	  AND NOT EXISTS (SELECT 'srp_period_quota_rc already exists'
			  FROM cn_srp_per_quota_rc_all spqr
			  WHERE spqr.srp_period_quota_id = pq.srp_period_quota_id
			  AND spqr.srp_plan_assign_id  = pq.srp_plan_assign_id
			  AND spqr.revenue_class_id    = qr.revenue_class_id)
	  ;

      ELSIF (    x_srp_plan_assign_id   IS NOT NULL
		 AND x_quota_id         IS NULL
		 AND x_revenue_class_id IS NULL ) THEN

	-- New plan assignment or change in plan assigns date range
	-- only consider difference of the range

	-- modified the cn_periods to cn_period_statuses
	-- modified the start_period_id, end_period_id to
	-- start date end date

	INSERT INTO cn_srp_per_quota_rc
	  ( srp_per_quota_rc_id
	    ,srp_period_quota_id
	    ,srp_plan_assign_id
	    ,salesrep_id
	    ,period_id
	    ,quota_id
	    ,revenue_class_id
	    ,target_amount
	    ,year_to_date
	    ,period_to_date
	    ,quarter_to_date
	    ,creation_date
	    ,created_by
	    ,last_updated_by
	    ,last_update_date
	    ,last_update_login
	    ,org_id)
	  SELECT
	  cn_srp_per_quota_rc_s.nextval
	  ,pq.srp_period_quota_id
	  ,pq.srp_plan_assign_id
	  ,pq.salesrep_id
	  ,pq.period_id
	  ,pq.quota_id
	  ,qr.revenue_class_id
	  ,0 -- target amount
	  ,0 -- ytd
	  ,0 -- ptd
	  ,0 -- qtd
	  ,Sysdate
	  ,fnd_global.user_id
	  ,fnd_global.user_id
	  ,Sysdate
	  ,fnd_global.login_id
	  ,pq.org_id
	  FROM  cn_srp_period_quotas_all pq -- periods that rep/plan uses quota
	  ,cn_quota_rules_all            qr
	  ,cn_quotas_all	         q
	  WHERE pq.srp_plan_assign_id = x_srp_plan_assign_id
	  AND pq.quota_id	      = qr.quota_id
	  AND qr.quota_id	      = q.quota_id
          AND q.quota_type_code IN ('EXTERNAL','FORMULA')

	  AND exists (select 'x' from     cn_period_statuses_all p
                       where pq.period_id      = p.period_id
		         AND pq.org_id         = p.org_id
		         AND p.period_status in ('O','F')
                         AND p.start_date >= nvl(x_start_date, p.start_date)
                         AND p.end_date   <= nvl(x_end_date,   p.end_date))

	      AND NOT EXISTS (SELECT 'srp_period_quota_rc already exists'
			      FROM cn_srp_per_quota_rc_all spqr
			      WHERE spqr.srp_period_quota_id = pq.srp_period_quota_id
			      AND spqr.srp_plan_assign_id = pq.srp_plan_assign_id
			      AND spqr.revenue_class_id    = qr.revenue_class_id)
	      ;
     END IF;

END insert_record;

END CN_SRP_PER_QUOTA_RC_PKG;

/
