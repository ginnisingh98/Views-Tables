--------------------------------------------------------
--  DDL for Package Body CN_SRP_RATE_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_RATE_ASSIGNS_PKG" as
-- $Header: cnsrplcb.pls 120.0 2005/06/06 17:33:27 appldev noship $
/*

Package Body Name

  Purpose
  Form	- cnsrmt cnpldf
  Block	- rate_assign

  History
  -------------- ------------ -------------------------------------------------+
  26-JAN-94	Tony Lower   Created
  10-FEB-95	P Cook	     Modified for table handlers
  03-AUG-95      P Cook	     Bug 272779. Ignore quota s customixed_flag when
                             propogating cn_rate_tier changes to the srp tiers
  20-NOV-95      P Cook	     Added who columns.

  Notes
  Tiers cannot be manually inserted or deleted in the srp/plan assignment
  block. The insert and delete procedures are called when a plan assignment
  is inserted or deleted OR when tiers are inserted/deleted from the comp
  plans form.
  If the design is changed to allow manual insert and deletion these table
  handlers must be modified to deal with individual records.
  -- Modified
  Delete_record procedure has two more paramenters like calc_formula_id
  and rt_quota_asgn_id

  Calc_formula_id tied with the rate_schedule.

  Two more if condition is added in the delete_record procedure

  */

  --+
  -- Procedure Name
  --  Delete_Record
  -- Purpose
  --  Delete srp rate tier assignments.
  -- +
  -- Notes						   Passed Parameters
  --  o Called once for each deleted srp plan assignment.  x_srp_plan_assign_id

  --  o Called when a quota assignment is deleted from the x_srp_plan_assign_id
  --    source comp plans. Called once for each srp plan   x_quota_id
  --    assignment referencing the comp plan on the deleted
  --    assignment

  --  o Called once for each quota whose rate schedule has x_quota_id
  --    been updated to null or another schedule	   x_rate_schedule_id
  --    Deletes all tiers attached to the quota

  --  o Called after a rate tier is deleted from  	   x_rate_tier_id
  --    cn_rate_tiers					   x_rate_schedule_id
  -- +
  --  o Called once for each quota whose calc_formula_id  has x_quota_id
  --    been updated to null or another calc_formula_id	   x_calc_formula_id
  --    Deletes all tiers attached to the quota

  --  o Called once for each rt_quota_asgns_deleted        x_quota_id
  --    				                   x_rt_quota_asgn_id

  ----------------------------------------------------------------------------+
  -- PROCEDURE DELETE_RECORD
  ----------------------------------------------------------------------------  +
  PROCEDURE delete_record
  ( x_srp_plan_assign_id  	NUMBER
    ,x_srp_rate_assign_id	NUMBER
    ,x_quota_id			NUMBER
    ,x_rate_schedule_id		NUMBER
    ,x_rt_quota_asgn_id         NUMBER := Null
    ,x_rate_tier_id		NUMBER) IS
  BEGIN

     IF x_rate_tier_id IS NOT NULL AND x_rate_schedule_id IS NOT NULL THEN

	-- cn_rate_tiers record deleted
	DELETE FROM cn_srp_rate_assigns_all
	  WHERE rate_tier_id     = x_rate_tier_id
	  AND rate_schedule_id = x_rate_schedule_id;

      ELSE

	IF x_quota_id IS NOT NULL THEN

           IF x_rt_quota_asgn_id IS NOT NULL THEN
	      -- delete the specific rt_quota_asgns_record.

	      DELETE FROM cn_srp_rate_assigns_all
		WHERE  rt_quota_asgn_id = x_rt_quota_asgn_id
		AND  quota_id           = x_quota_id;

	   ELSIF x_srp_plan_assign_id IS NOT NULL THEN

	      -- deleted cn_quota_assign record
	      DELETE FROM cn_srp_rate_assigns_all
		WHERE srp_plan_assign_id = x_srp_plan_assign_id
		AND quota_id 	         = x_quota_id;

	    ELSIF x_rate_schedule_id IS NOT NULL THEN

	      -- quota has been assigned a different schedule
	      DELETE FROM cn_srp_rate_assigns_all
		WHERE  rate_schedule_id = x_rate_schedule_id
		AND  quota_id = x_quota_id;

	   END IF;

	 ELSE
	   -- deleting a srp plan assign
	   DELETE FROM cn_srp_rate_assigns_all
	     WHERE srp_plan_assign_id = x_srp_plan_assign_id;

	END IF;

     END IF;

  END delete_record;

  --+
  -- Procedure Name
  --  Insert_Record
  -- Purpose
  --  Insert srp rate tier assignments.
  -- Notes
  --   o called once for each new srp plan assignment
  --   o called once for each srp plan assignment that references the comp
  --     plan on a newly created comp plan quota assignment
  -- +
  --  Calling event			  		Passed Parameters
  -- 1. after insert of srp plan assignment. 	  	x_srp_plan_assign_id

  -- 2. after insert of comp plan quota assignment 	x_srp_plan_assign_id
  --							x_quota_id

  -- 3. after update of rate schedule assigned to quota x_quota_id
  --							x_rate_schedule_id

  -- 4. after insert of new rate tier			x_rate_schedule_id
  --							x_rate_tier_id
  --+
  ----------------------------------------------------------------------------+
  -- PROCEDURE INSERT_RECORD
  ----------------------------------------------------------------------------  +
  PROCEDURE Insert_Record
    (
       x_srp_plan_assign_id              NUMBER
       ,x_srp_quota_assign_id            NUMBER
       ,x_srp_rate_assign_id             NUMBER
       ,x_quota_id			 NUMBER
       ,x_rate_schedule_id  		 NUMBER
       ,x_rt_quota_asgn_id               NUMBER := NULL
       ,x_rate_tier_id                   NUMBER
       ,x_commission_rate                NUMBER
       ,x_commission_amount		 NUMBER
       ,x_disc_rate_table_flag		 VARCHAR2
       ,x_rate_sequence                  NUMBER := NULL
    ) IS

	  l_user_id  NUMBER(15);
	  l_resp_id  NUMBER(15);
	  l_login_id NUMBER(15);
  BEGIN

     l_user_id  := fnd_global.user_id;
     l_resp_id  := fnd_global.resp_id;
     l_login_id := fnd_global.login_id;

     -- in all cases, only insert if customized_flag = 'Y' - bugfix 3204833
     -- +
     IF x_srp_plan_assign_id IS NOT NULL THEN

	IF x_quota_id IS NOT NULL THEN

	   INSERT INTO cn_srp_rate_assigns_all
	     (
		srp_plan_assign_id
		,srp_quota_assign_id
		,srp_rate_assign_id
		,rate_tier_id
                ,rate_sequence
		,commission_amount
		,quota_id
		,rate_schedule_id
                ,rt_quota_asgn_id
		,creation_date
		,created_by
		,last_update_date
		,last_updated_by
		,last_update_login
		,org_id)
	     SELECT
	     qa.srp_plan_assign_id
	     ,qa.srp_quota_assign_id
	     ,cn_srp_rate_assigns_s.nextval
	     ,t.rate_tier_id
             ,t.rate_sequence
	     ,t.commission_amount
	     ,qa.quota_id
	     ,t.rate_schedule_id
             ,rqa.rt_quota_asgn_id
	     ,sysdate
	     ,l_user_id
	     ,sysdate
	     ,l_user_id
	     ,l_login_id
	     ,qa.org_id
	     FROM  cn_rate_tiers_all   t
	     ,cn_srp_quota_assigns_all qa
	     ,cn_rt_quota_asgns_all    rqa
	     WHERE qa.srp_plan_assign_id = x_srp_plan_assign_id
	     AND qa.quota_id 	         = x_quota_id
	     AND rqa.quota_id            = x_quota_id
	     AND rqa.quota_id            = qa.quota_id
	     AND rqa.rate_schedule_id    = t.rate_schedule_id
	     AND qa.customized_flag      = 'Y'
	     AND qa.quota_type_code IN ('EXTERNAL','FORMULA')
	     AND t.commission_amount <> 0
	     ;

	   --- Insert the Discount Rate SChedule Table when a New Plan element
	   --- is being assigned to a COmp Plan.

	 ELSE
	   -- New plan assignment
	   INSERT INTO cn_srp_rate_assigns_all
	     (srp_plan_assign_id
	      ,srp_quota_assign_id
	      ,srp_rate_assign_id
	      ,rate_tier_id
              ,rate_sequence
	      ,commission_amount
	      ,quota_id
	      ,rate_schedule_id
	      ,rt_quota_asgn_id
	      ,creation_date
	      ,created_by
	      ,last_update_date
	      ,last_updated_by
	      ,last_update_login
	      ,org_id)
	     SELECT qa.srp_plan_assign_id
	     ,qa.srp_quota_assign_id
	     ,cn_srp_rate_assigns_s.nextval
	     ,t.rate_tier_id
             ,t.rate_sequence
	     ,t.commission_amount
	     ,qa.quota_id
	     ,t.rate_schedule_id
	     ,rqa.rt_quota_asgn_id
	     ,sysdate
	     ,l_user_id
	     ,sysdate
	     ,l_user_id
	     ,l_login_id
	     ,qa.org_id
	     FROM  cn_rate_tiers_all   t
	     ,cn_srp_quota_assigns_all qa
             ,cn_rt_quota_asgns_all    rqa
	     WHERE qa.srp_plan_assign_id = x_srp_plan_assign_id
	     AND qa.quota_id             = rqa.quota_id
	     AND rqa.rate_schedule_id    = t.rate_schedule_id
	     AND qa.customized_flag      = 'Y'
	     AND qa.quota_type_code IN ('EXTERNAL','FORMULA')
	     AND t.commission_amount <> 0
	     ;
	END IF; -- x_quota_id is not null

      ELSIF x_quota_id IS NOT NULL AND x_rate_schedule_id IS NOT NULL THEN
	-- create a new rt_quota_assigns
	-- 1 called from cn_rt_quota_assigns insert_record
        IF x_rt_quota_asgn_id IS NOT NULL THEN

	   INSERT INTO cn_srp_rate_assigns_all
	     (srp_plan_assign_id
	      ,srp_quota_assign_id
	      ,srp_rate_assign_id
	      ,rate_tier_id
              ,rate_sequence
	      ,commission_amount
	      ,quota_id
	      ,rate_schedule_id
	      ,rt_quota_asgn_id
	      ,creation_date
	      ,created_by
	      ,last_update_date
	      ,last_updated_by
	      ,last_update_login
	      ,org_id)
	     SELECT   qa.srp_plan_assign_id
	     ,qa.srp_quota_assign_id
	     ,cn_srp_rate_assigns_s.nextval
	     ,t.rate_tier_id
             ,t.rate_sequence
	     ,t.commission_amount
	     ,qa.quota_id
	     ,t.rate_schedule_id
	     ,rqa.rt_quota_asgn_id
	     ,sysdate
	     ,l_user_id
	     ,sysdate
	     ,l_user_id
	     ,l_login_id
	     ,qa.org_id
	     FROM   cn_rate_tiers_all   t
	     ,cn_srp_quota_assigns_all  qa
	     ,cn_rt_quota_asgns_all     rqa
	     WHERE qa.quota_id 	        = x_quota_id
	     AND rqa.quota_id           = x_quota_Id
	     AND rqa.quota_id           = qa.quota_id
	     AND rqa.rate_schedule_id   = x_rate_schedule_id
	     AND t.rate_schedule_id     = x_rate_schedule_id
	     AND rqa.rate_schedule_id   = t.rate_schedule_id
	     AND rqa.rt_quota_asgn_id   = x_rt_quota_asgn_id
	     AND qa.customized_flag     = 'Y'
	     AND qa.quota_type_code IN ('EXTERNAL', 'FORMULA')
	     AND t.commission_amount <> 0
	     ;

	 ELSE

	   INSERT INTO cn_srp_rate_assigns_all
	     (srp_plan_assign_id
	      ,srp_quota_assign_id
	      ,srp_rate_assign_id
	      ,rate_tier_id
              ,rate_sequence
	      ,commission_amount
	      ,quota_id
	      ,rate_schedule_id
	      ,rt_quota_asgn_id
	      ,creation_date
	      ,created_by
	      ,last_update_date
	      ,last_updated_by
	      ,last_update_login
	      ,org_id)
	     SELECT   qa.srp_plan_assign_id
	     ,qa.srp_quota_assign_id
	     ,cn_srp_rate_assigns_s.nextval
	     ,t.rate_tier_id
             ,t.rate_sequence
	     ,t.commission_amount
	     ,qa.quota_id
	     ,t.rate_schedule_id
	     ,rqa.rt_quota_asgn_id
	     ,sysdate
	     ,l_user_id
	     ,sysdate
	     ,l_user_id
	     ,l_login_id
	     ,qa.org_id
	     FROM   cn_rate_tiers_all   t
	     ,cn_srp_quota_assigns_all  qa
	     ,cn_rt_quota_asgns_all     rqa
	     WHERE qa.quota_id 	        = x_quota_id
	     AND rqa.quota_id           = x_quota_Id
	     AND rqa.quota_id           = qa.quota_id
	     AND rqa.rate_schedule_id   = x_rate_schedule_id
	     AND t.rate_schedule_id     = x_rate_schedule_id
	     AND rqa.rate_schedule_id   = t.rate_schedule_id
	     AND qa.customized_flag     = 'Y'
	     AND qa.quota_type_code IN ('EXTERNAL', 'FORMULA')
	     AND t.commission_amount <> 0
	     ;

	END IF;

      ELSIF (    x_quota_id IS NULL AND x_rate_schedule_id IS NOT NULL
		 AND x_rate_tier_id IS NOT NULL) THEN

   	INSERT INTO cn_srp_rate_assigns_all
	  (  srp_plan_assign_id
	     ,srp_quota_assign_id
	     ,srp_rate_assign_id
	     ,rate_tier_id
             ,rate_sequence
	     ,commission_amount
	     ,quota_id
	     ,rate_schedule_id
	     ,rt_quota_asgn_id
	     ,creation_date
	     ,created_by
	     ,last_update_date
	     ,last_updated_by
	     ,last_update_login
	     ,org_id
          )
	  SELECT  qa.srp_plan_assign_id
	  ,qa.srp_quota_assign_id
	  ,cn_srp_rate_assigns_s.nextval
	  ,t.rate_tier_id
          ,t.rate_sequence
	  ,t.commission_amount
	  ,qa.quota_id
	  ,t.rate_schedule_id
	  ,rqa.rt_quota_asgn_id
	  ,sysdate
	  ,l_user_id
	  ,sysdate
	  ,l_user_id
	  ,l_login_id
	  ,qa.org_id
	  FROM  cn_rate_tiers_all     t
	  ,cn_srp_quota_assigns_all   qa
	  ,cn_rt_quota_asgns_all      rqa
	  WHERE rqa.rate_schedule_id = t.rate_schedule_id
	  AND rqa.quota_id           = qa.quota_id
	  AND t.rate_tier_id 	     = x_rate_tier_id
	  AND t.rate_schedule_id     = x_rate_schedule_id
	  AND qa.customized_flag     = 'Y'
	  AND qa.quota_type_code IN ('EXTERNAL', 'FORMULA')
	  AND t.commission_amount <> 0
          ;
     END IF;

  END insert_record;
  ----------------------------------------------------------------------------+
  -- PROCEDURE LOCK_RECORD
  ----------------------------------------------------------------------------  +
  PROCEDURE Lock_Record
    (
     X_Srp_Plan_Assign_Id             NUMBER,
     X_Srp_Quota_Assign_Id            NUMBER,
     X_Srp_Rate_Assign_Id      	      NUMBER,
     X_Rate_Tier_Id                   NUMBER,
     X_Commission_Rate                NUMBER,
     x_commission_amount	      NUMBER ) IS
	CURSOR C IS
	   SELECT *
	     FROM cn_srp_rate_assigns_all
	     WHERE srp_rate_assign_id = x_srp_rate_assign_id
	     FOR UPDATE OF srp_rate_assign_id NOWAIT;
	Recinfo C%ROWTYPE;


  BEGIN
     OPEN C;
     FETCH C INTO Recinfo;

     IF (C%NOTFOUND) THEN
	close C;
	fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
	app_exception.raise_exception;
     END IF;
     CLOSE C;

     IF ( (   recinfo.commission_amount       = x_commission_amount
	      OR (    recinfo.commission_amount IS NULL
		      AND x_commission_amount IS NULL) 		)
	  AND (recinfo.commission_rate       = x_commission_rate
	       OR (    recinfo.commission_rate IS NULL
		       AND x_commission_rate IS NULL) )
	  ) THEN
	RETURN;

      ELSE

	fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	app_exception.raise_exception;
     END IF;

  END Lock_Record;
  ----------------------------------------------------------------------------+
  -- PROCEDURE UPDATE_RECORD
  ----------------------------------------------------------------------------  +
  PROCEDURE Update_Record(
			  x_srp_plan_assign_id           NUMBER
			  ,x_srp_quota_assign_Id         NUMBER
			  ,x_srp_rate_assign_id          NUMBER
			  ,x_rate_tier_id                NUMBER
			  ,x_commission_rate             NUMBER
			  ,x_commission_rate_old         NUMBER
			  ,x_start_period_id		 NUMBER
			  ,x_salesrep_id		 NUMBER
			  ,x_commission_amount		 NUMBER
			  ,x_commission_amount_old	 NUMBER
			  ,x_last_update_date		 DATE
			  ,x_last_updated_by		 NUMBER
			  ,x_last_update_login		 NUMBER) IS
  BEGIN

     UPDATE  cn_srp_rate_assigns_all
       SET  commission_amount  = x_commission_amount
       ,last_update_date       = x_last_update_date
       ,last_updated_by        = x_last_updated_by
       ,last_update_login      = x_last_update_login
       WHERE  srp_rate_assign_id = x_srp_rate_assign_id
       ;

     IF SQL%NOTFOUND THEN
	raise no_data_found;
     END IF;

  END Update_Record;

  -- Procedure Name
  --   Synch_rate
  -- Purpose
  --   Ensure that all rep/plan assignments get the correct commission rates
  -- Notes
  --   Not called unless quota type is target or revenue
  -- +
  -- When the procedure is called		  	Passed Parameters
  -- 1. After update of cn_rate_tiers.commission_rate   x_rate_schedule_id
  --							x_rate_tier_id

  -- 2. After user chooses to not to have custom quotas x_srp_plan_assign_id
  --    and rates at srp level				x_srp_quota_assign_id
  --							x_rate_schedule_id
  ----------------------------------------------------------------------------+
  -- PROCEDURE SYNCH_RATE
  ----------------------------------------------------------------------------  +
  PROCEDURE synch_rate(
		       x_srp_plan_assign_id     NUMBER
		       ,x_srp_quota_assign_id   NUMBER
		       ,x_rate_schedule_id	NUMBER
		       ,x_rate_tier_id	        NUMBER
		       ,x_commission_rate	NUMBER
		       ,x_salesrep_id		NUMBER
		       ,x_start_period_id	NUMBER
		       ,x_commission_amount     NUMBER ) IS
  BEGIN
     -- obsoleted as part of bug fix 3204833
     NULL;
  END synch_rate;

END cn_srp_rate_assigns_pkg;

/
