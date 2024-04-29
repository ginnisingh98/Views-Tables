--------------------------------------------------------
--  DDL for Package Body CN_SRP_RULE_UPLIFTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_RULE_UPLIFTS_PKG" as
/* $Header: cnsrprub.pls 120.0 2005/06/06 17:56:22 appldev noship $ */

/*
Date      Name          Description
  ----------------------------------------------------------------------------
  02-JUN-99 S Kumar
  23-Mar-01 Zack        Added srp_quota_assign_id in the where clause for performance fix.

*/
  -- Procedure Name
  -- Insert_record
  -- Purpose
  -- insert the Quota Rule Uplift from
  -- two places
  -- 1.	-- Inserting a new cn_quota_assigns
  -- 2. -- Inserting a new plan assignment
  -- 3. -- Inserting a new Quota Rule Uplifts
  -- Notes
  --

  PROCEDURE insert_record
  (
   p_srp_plan_assign_id      NUMBER
  ,p_quota_id                NUMBER
  ,p_quota_rule_id           NUMBER
   ,p_quota_rule_uplift_id   NUMBER := NULL
   ) IS

  BEGIN

     IF (    p_srp_plan_assign_id IS NOT NULL AND p_quota_id IS NOT NULL) THEN

	-- Inserting a new cn_quota_assigns

	INSERT INTO cn_srp_rule_uplifts_all
	  (
	   srp_rule_uplift_id
	   ,srp_quota_rule_id
	   ,quota_rule_uplift_id
	   ,payment_factor
	   ,quota_factor
	   ,creation_date
	   ,created_by
	   ,last_updated_by
	   ,last_update_date
	   ,last_update_login
	   ,org_id
	   )
	  SELECT
	  cn_srp_rule_uplifts_s.nextval
	  ,sqr.srp_quota_rule_id
	  ,qru.quota_rule_uplift_id
	  ,qru.payment_factor
	  ,qru.quota_factor
	  ,Sysdate
	  ,fnd_global.user_id
	  ,fnd_global.user_id
	  ,Sysdate
	  ,fnd_global.login_id
	  ,sqa.org_id
	  FROM cn_srp_quota_assigns_all    sqa
	  ,cn_srp_quota_rules_all          sqr
	  ,cn_quota_rule_uplifts_all       qru
	  WHERE sqa.srp_plan_assign_id   = p_srp_plan_assign_id
 	  AND   sqa.quota_id	         = p_quota_id
	  AND   sqa.srp_quota_assign_id  = sqr.srp_quota_assign_id
	  AND   sqa.srp_plan_assign_id   = sqr.srp_plan_assign_id
	  AND   sqr.quota_rule_id        = qru.quota_rule_id
	  ;

    ELSIF (    p_srp_plan_assign_id IS NOT NULL AND p_quota_id IS NULL) THEN
       -- Inserting a new plan assignment

	INSERT INTO cn_srp_rule_uplifts_all
	  (
	   srp_rule_uplift_id
	   ,srp_quota_rule_id
	   ,quota_rule_uplift_id
	   ,payment_factor
	   ,quota_factor
	   ,creation_date
	   ,created_by
	   ,last_updated_by
	   ,last_update_date
	   ,last_update_login
	   ,org_id
	   )
	  SELECT
	  cn_srp_rule_uplifts_s.nextval
	  ,sqr.srp_quota_rule_id
	  ,qru.quota_rule_uplift_id
	  ,qru.payment_factor
	  ,qru.quota_factor
	  ,Sysdate
	  ,fnd_global.user_id
	  ,fnd_global.user_id
	  ,Sysdate
	  ,fnd_global.login_id
	  ,sqa.org_id
	  FROM cn_srp_quota_assigns_all    sqa
	  ,cn_srp_quota_rules_all          sqr
	  ,cn_quota_rule_uplifts_all       qru
	  WHERE sqa.srp_plan_assign_id   = p_srp_plan_assign_id
	  AND  sqa.srp_quota_assign_id   = sqr.srp_quota_assign_id
 	  AND  sqa.srp_plan_assign_id    = sqr.srp_plan_assign_id
	  AND   sqr.quota_rule_id        = qru.quota_rule_id
	  ;

      ELSIF ( p_quota_rule_id  IS NOT NULL AND p_quota_rule_uplift_id IS NOT NULL) THEN

	-- Inserting a new Quota Rule Uplifts

	IF p_quota_rule_id IS NOT NULL THEN

	  INSERT INTO cn_srp_rule_uplifts_all
	  (   srp_rule_uplift_id
	      ,srp_quota_rule_id
	      ,quota_rule_uplift_id
	      ,payment_factor
	      ,quota_factor
	      ,creation_date
	      ,created_by
	      ,last_updated_by
	      ,last_update_date
	      ,last_update_login
	      ,org_id)
	  SELECT
	    cn_srp_rule_uplifts_s.nextval
	    ,sqr.srp_quota_rule_id
	    ,qru.quota_rule_uplift_id
	    ,qru.payment_factor
	    ,qru.quota_factor
	    ,Sysdate
	    ,fnd_global.user_id
	    ,fnd_global.user_id
	    ,Sysdate
	    ,fnd_global.login_id
	    ,sqr.org_id
	  FROM  cn_srp_quota_rules_all sqr
	    ,cn_quota_rule_uplifts_all   qru
	    WHERE sqr.quota_rule_id      = p_quota_rule_id
	    AND   qru.quota_rule_id      = p_quota_rule_id
	    AND   qru.quota_rule_id      = sqr.quota_rule_id  --bugfix 3633243
	  AND qru.quota_rule_uplift_id	 = p_quota_rule_uplift_id
	  ;
        END IF;
	-- clku, handle the case of inserting srp quota rules which already have
        -- uplift factor at PE Level. Bug 2788644
        ELSIF ( p_quota_rule_id  IS NOT NULL AND p_quota_rule_uplift_id IS NULL) THEN

          INSERT INTO cn_srp_rule_uplifts_all
	  (   srp_rule_uplift_id
	      ,srp_quota_rule_id
	      ,quota_rule_uplift_id
	      ,payment_factor
	      ,quota_factor
	      ,creation_date
	      ,created_by
	      ,last_updated_by
	      ,last_update_date
	      ,last_update_login
	      ,org_id)
	  SELECT
	    cn_srp_rule_uplifts_s.nextval
	    ,sqr.srp_quota_rule_id
	    ,qru.quota_rule_uplift_id
	    ,qru.payment_factor
	    ,qru.quota_factor
	    ,Sysdate
	    ,fnd_global.user_id
	    ,fnd_global.user_id
	    ,Sysdate
	    ,fnd_global.login_id
	    ,sqr.org_id
	  FROM  cn_srp_quota_rules_all sqr
	  ,cn_quota_rule_uplifts_all   qru
	    WHERE sqr.quota_rule_id      = qru.quota_rule_id
	    AND   qru.quota_rule_id      = p_quota_rule_id;


     END IF;

  END insert_record;

  -- Procedure Name
  -- Update_record
  -- Purpose
  -- Upate  the Quota Rule Uplift from from
  -- Notes
  --

  PROCEDURE update_record(
			  p_srp_rule_uplift_id           NUMBER
                          ,p_payment_factor              NUMBER
			  ,p_quota_factor                NUMBER
			  ,p_last_update_date		 DATE
			  ,p_last_updated_by		 NUMBER
			  ,p_last_update_login		 NUMBER) IS

  BEGIN
     IF p_srp_rule_uplift_id  IS NOT NULL THEN

	-- Called from srp rule Uplift block
	UPDATE cn_srp_rule_uplifts_all
	  SET
	  -- Should be an optional column as it can be null for
	  -- quota types 'revenue' and 'draw'. But it is mandatory and
	  -- this nvl protects against a null value coming back from the
	  -- form
	   payment_factor                 = p_payment_factor
	  ,quota_factor                   = p_quota_factor
	  ,last_update_date  		  = p_last_update_date
	  ,last_updated_by   		  = p_last_updated_by
	  ,last_update_login 		  = p_last_update_login
	  WHERE srp_rule_uplift_id        = p_srp_rule_uplift_id
	  ;

	IF (sql%notfound) THEN
	   raise no_data_found;
   	END IF;
     END IF;

  END update_record;

  -- Procedure Name
  --  Delete_record
  -- Purpose
  -- Delete will be called from different place
  -- 1. Delete the cn_quota_assigns
  -- 2. Delete the srp_plan_assigns
  -- 3. delete the cn_quota_rules
  -- 4. delete the quota_rule_uplifts
   -- Notes
  --

  PROCEDURE Delete_record
  (
   p_srp_plan_assign_id       NUMBER
   ,p_quota_id                NUMBER
   ,p_quota_rule_id           NUMBER
   ,p_quota_rule_uplift_id    NUMBER := NULL
   ) IS

  BEGIN

     IF ( p_srp_plan_assign_id   IS NOT NULL AND
	  p_quota_id             IS NOT NULL AND
	  p_quota_rule_id        IS NULL     AND
	  p_quota_rule_uplift_id IS NULL ) THEN

	-- cn_quota_assigns Record has been deleted
        -- for each srp plan assign record
	DELETE FROM cn_srp_rule_uplifts_all sru
	  WHERE sru.srp_quota_rule_id  IN
	  ( SELECT sqr.srp_quota_rule_id
	    FROM cn_srp_quota_rules_all sqr
	    , cn_srp_quota_assigns sqa
	    WHERE sqa.srp_quota_assign_id = sqr.srp_quota_assign_id
	    AND  sqa.srp_plan_assign_id   = sqr.srp_plan_assign_id
	    AND  sqa.srp_plan_assign_id   = p_srp_plan_assign_id
	    AND  sqa.quota_id             = p_quota_id )
	    ;
      ELSIF (p_srp_plan_assign_id IS NOT NULL
         AND p_quota_id 	  IS NULL
	 AND p_quota_rule_id 	  IS NULL) THEN

	-- cn_srp_plan_assigns record has been deleted
	DELETE FROM cn_srp_rule_uplifts_all sru
	  WHERE sru.srp_quota_rule_id  IN
	  ( SELECT sqr.srp_quota_rule_id
	    FROM cn_srp_quota_rules_all sqr
	    WHERE  sqr.srp_plan_assign_id   = p_srp_plan_assign_id )
	  ;

      ELSIF ( p_srp_plan_assign_id IS NULL
	      AND p_quota_id 	   IS NOT NULL
	      AND p_quota_rule_id  IS NOT NULL) THEN

     -- cn_quota_rules record deleted
     DELETE FROM cn_srp_rule_uplifts_all sru
       WHERE sru.srp_quota_rule_id IN
       (SELECT sqr.srp_quota_rule_id
	FROM cn_srp_quota_rules_all sqr, cn_quota_rules_all qr
	WHERE sqr.quota_rule_id = p_quota_rule_id
	  AND sqr.quota_rule_id = qr.quota_rule_id
          AND sqr.revenue_class_id = qr.revenue_class_id);

      ELSIF (    p_quota_rule_uplift_id  IS NOT  NULL) THEN

	-- cn_quota_rule_uplifts record deleted

	DELETE FROM cn_srp_rule_uplifts_all
	  WHERE quota_rule_uplift_id = p_quota_rule_uplift_id
	  ;

      ELSIF  ( p_quota_id IS NOT NULL ) THEN
	   DELETE FROM cn_srp_rule_uplifts_all sru
	     WHERE sru.srp_quota_rule_id IN
	     (SELECT sqr.srp_quota_rule_id
	      FROM cn_quota_rules_all qr,
	      cn_srp_quota_rules_all sqr
	      WHERE sqr.quota_rule_id = qr.quota_rule_id
	      AND sqr.revenue_class_id = qr.revenue_class_id
	      AND quota_id = p_quota_id )
	     ;

     END IF;

  END delete_record;
 ----------------------------------------------------------------------------
  -- PROCEDURE UPDATE_RECORD
 ----------------------------------------------------------------------------
  PROCEDURE update_record ( p_quota_rule_uplift_id NUMBER
			  ,p_quota_factor	   NUMBER
			  ,p_payment_factor	   NUMBER) IS
 BEGIN
    UPDATE cn_srp_rule_uplifts_all u
      set u.payment_factor        = p_payment_factor
      , u.quota_factor            = p_quota_factor
     WHERE u.quota_rule_uplift_id = p_quota_rule_uplift_id
       AND EXISTS (SELECT 'quota rule uplift belongs to a uncustomized quota'
		     FROM cn_srp_quota_assigns_all q,
                          cn_srp_quota_rules_all   r
		    WHERE q.srp_quota_assign_id = r.srp_quota_assign_id
                      AND r.srp_quota_rule_id   = u.srp_quota_rule_id
		      AND q.customized_flag = 'N')
    ;

 END update_record;


END cn_srp_rule_uplifts_pkg;

/
