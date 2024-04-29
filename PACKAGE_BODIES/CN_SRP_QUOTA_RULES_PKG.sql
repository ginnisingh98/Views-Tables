--------------------------------------------------------
--  DDL for Package Body CN_SRP_QUOTA_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_QUOTA_RULES_PKG" as
/* $Header: cnsrpqrb.pls 120.1 2005/06/09 11:52:49 appldev  $ */

/*
Date      Name          Description
---------------------------------------------------------------------------+
24-JUL-95 P Cook	Prevent insert of quota rules for 'manual' and 'draw'
			quota types
28-AUG-95 P Cook	Bug: 304207. Default the srp quota rule targets from
			the source quota rule.
10-JUN-99 S Kumar       Modified the where condition if all the Quota types
                        noew we have only formula, external quota types.

25-AUG-99 S Kumar       Added more procedure to handle the locks and
                        modified the update_record with more parameters
                        like srp_quota_rule_id, using this you can update
                        record from forms.

*/
  ---------------------------------------------------------------------------+
  -- PROCEDURE SYNCH_TARGET
  ---------------------------------------------------------------------------+
 PROCEDURE synch_target (x_srp_quota_assign_id NUMBER) IS

    l_target NUMBER;
    l_payment_amount NUMBER;
    l_performance_goal NUMBER;

    CURSOR sqr_curs IS
      SELECT qr.target,
	 qr.payment_amount,
	qr.performance_goal,
	sqr.srp_quota_rule_id
	 FROM cn_quota_rules_all qr,
	 cn_srp_quota_rules_all sqr
	 WHERE qr.quota_rule_id      = sqr.quota_rule_id
         AND sqr.srp_quota_assign_id = x_srp_quota_assign_id
	;
    l_recinfo sqr_curs%ROWTYPE;

 BEGIN
    IF x_srp_quota_assign_id IS NOT NULL THEN

       OPEN sqr_curs;
       LOOP
       FETCH sqr_curs INTO l_recinfo;
	  EXIT WHEN sqr_curs%notfound;

	  UPDATE cn_srp_quota_rules_all
	    SET target = l_recinfo.target,
	    payment_amount = l_recinfo.payment_amount,
	    performance_goal = l_recinfo.performance_goal
	    WHERE srp_quota_rule_id = l_recinfo. srp_quota_rule_id
	    ;
       END LOOP;
       CLOSE sqr_curs;
    END IF;

 END synch_target;

 ---------------------------------------------------------------------------+
 -- PROCEDURE UPDATE_RECORD
 -- Descr: This program will be called from cn_quota_rules, when the user
 -- modifiy the target, payment_amount, performance goal
 -- Case1: x_quota_rule_id is NOT NULL when called from cn_quota_rules
 -- Case2: x_srp_quota_rule_id IS NOT NULL FROM forms Only.
 ---------------------------------------------------------------------------+
 PROCEDURE update_record (   x_quota_rule_id      NUMBER
			    ,x_srp_quota_rule_id  NUMBER := NULL
			    ,x_target	          NUMBER
			    ,x_payment_amount     NUMBER
			    ,x_performance_goal   NUMBER
			    )
  IS
     l_target            cn_srp_quota_rules.target%TYPE;
     l_payment_amount    cn_srp_quota_rules.payment_amount%TYPE;
     l_performance_goal  cn_srp_quota_rules.performance_goal%TYPE;

     l_srp_quota_assign_id cn_srp_quota_assigns.srp_quota_assign_id%TYPE;
     l_addup_flag          cn_quotas.ADDUP_FROM_REV_CLASS_FLAG%TYPE;
  BEGIN

     IF x_quota_rule_id IS NOT NULL AND x_srp_quota_rule_id IS NOT NULL THEN

	UPDATE cn_srp_quota_rules_all r
	  SET r.target      = x_target,
	  r.payment_amount   = x_payment_amount,
	  r.performance_goal = x_performance_goal
	  WHERE r.quota_rule_id = x_quota_rule_id
	  AND r.srp_quota_rule_id = x_srp_quota_rule_id
	  AND EXISTS (SELECT 'quota rule belongs to a customized quota'
		      FROM cn_srp_quota_assigns_all q
		      WHERE q.srp_quota_assign_id = r.srp_quota_assign_id
		      AND q.customized_flag = 'Y')
	  ;

      ELSIF x_srp_quota_rule_id IS NOT NULL THEN


       UPDATE cn_srp_quota_rules_all r
       SET r.target      = x_target,
      r.payment_amount   = x_payment_amount,
      r.performance_goal = x_performance_goal
      WHERE r.srp_quota_rule_id = x_srp_quota_rule_id
       AND EXISTS (SELECT 'quota rule belongs to a customized quota'
		     FROM cn_srp_quota_assigns_all q
		    WHERE q.srp_quota_assign_id = r.srp_quota_assign_id
		   AND q.customized_flag = 'Y')
	  ;

      ELSIF x_quota_rule_id IS NOT NULL THEN

	UPDATE cn_srp_quota_rules_all r
	  SET r.target       = x_target,
	  r.payment_amount    = x_payment_amount,
	  r.performance_goal = x_performance_goal
	  WHERE r.quota_rule_id = x_quota_rule_id
	  AND EXISTS (SELECT 'quota rule belongs to a uncustomized quota'
		      FROM cn_srp_quota_assigns_all q
		      WHERE q.srp_quota_assign_id = r.srp_quota_assign_id
		      AND q.customized_flag = 'N')
	  ;
     END IF;

     IF x_srp_quota_rule_id IS NOT NULL THEN

       SELECT q.srp_quota_assign_id, q.ADDUP_REV_CLASS_FLAG
         INTO l_srp_quota_assign_id, l_addup_flag
         FROM cn_srp_quota_assigns_v q,
              cn_srp_quota_rules_all r
        WHERE q.srp_quota_assign_id = r.srp_quota_assign_id
          AND r.srp_quota_rule_id = x_srp_quota_rule_id
           ;

       IF l_addup_flag = 'Y' THEN

         SELECT SUM(nvl(target,0)),
	        SUM(nvl(payment_amount,0)),
	        SUM(nvl(performance_goal,0))
	   INTO l_target,
	        l_payment_amount,
	        l_performance_goal
	   FROM cn_srp_quota_rules_all
   	  WHERE srp_quota_assign_id = l_srp_quota_assign_id;

       	UPDATE cn_srp_quota_assigns_all
	   SET target       = l_target,
	       payment_amount    = l_payment_amount,
	       performance_goal = l_performance_goal
	 WHERE srp_quota_assign_id = l_srp_quota_assign_id
	     ;

       END IF;

     END IF;

 END update_record;

  -- Procedure Name
  --
  -- Purpose
  --
  -- Notes
  --   Manual and draw quota types do not have revenue classes
  ---------------------------------------------------------------------------+
  -- PROCEDURE INSERT_RECORD
  ---------------------------------------------------------------------------+
 PROCEDURE insert_record
   (
    x_srp_plan_assign_id    NUMBER
    ,x_quota_id		    NUMBER
    ,x_quota_rule_id	    NUMBER
    ,x_revenue_class_id	    NUMBER ) IS

 BEGIN

    IF (    x_srp_plan_assign_id IS NOT NULL AND x_quota_id IS NOT NULL) THEN

       -- Inserting a new cn_quota_assign
       -- Bug             2507490

       INSERT INTO cn_srp_quota_rules_all
	 (   srp_quota_rule_id
	     ,srp_plan_assign_id
	     ,srp_quota_assign_id
	     ,quota_rule_id
	     ,revenue_class_id
	     ,target
	     ,payment_amount
	     ,performance_goal
	     ,creation_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_date
	     ,last_update_login
	     ,org_id)
	 SELECT cn_srp_quota_rules_s1.nextval
	 ,sqa.srp_plan_assign_id
	 ,sqa.srp_quota_assign_id
	 ,qr.quota_rule_id
	 ,qr.revenue_class_id
	 ,qr.target
	 ,qr.payment_amount
	 ,qr.performance_goal
	 ,Sysdate
	 ,fnd_global.user_id
	 ,fnd_global.user_id
	 ,Sysdate
	 ,fnd_global.login_id
	 ,sqa.org_id
	 FROM  cn_srp_quota_assigns_all sqa
	 ,cn_quota_rules_all  	   qr
	 WHERE sqa.srp_plan_assign_id = x_srp_plan_assign_id
	 AND sqa.quota_id	      = x_quota_id
	 AND qr.quota_id	      = sqa.quota_id
	 AND sqa.quota_type_code IN ('FORMULA','EXTERNAL')
	 ;

     ELSIF (    x_srp_plan_assign_id IS NOT NULL AND x_quota_id IS NULL) THEN

       -- Inserting a new plan assignment

       INSERT INTO cn_srp_quota_rules_all
	 (   srp_quota_rule_id
	     ,srp_plan_assign_id
	     ,srp_quota_assign_id
	     ,quota_rule_id
	     ,revenue_class_id
	     ,target
	     ,payment_amount
	     ,performance_goal
	     ,creation_date
	     ,created_by
	     ,last_updated_by
	     ,last_update_date
	     ,last_update_login
	     ,org_id)
	 SELECT cn_srp_quota_rules_s1.nextval
	 ,sqa.srp_plan_assign_id
	 ,sqa.srp_quota_assign_id
	 ,qr.quota_rule_id
	 ,qr.revenue_class_id
	 ,qr.target
	 ,qr.payment_amount
	 ,qr.performance_goal
	 ,Sysdate
	 ,fnd_global.user_id
	 ,fnd_global.user_id
	 ,Sysdate
	 ,fnd_global.login_id
	 ,sqa.org_id
	 FROM  cn_srp_quota_assigns_all sqa
	 ,cn_quota_rules_all  	qr
	 WHERE sqa.srp_plan_assign_id = x_srp_plan_assign_id
	 AND sqa.quota_id	   = qr.quota_id
	 AND sqa.quota_type_code IN ('FORMULA','EXTERNAL')
	 ;

     ELSIF (x_srp_plan_assign_id IS NULL AND x_quota_id IS NOT NULL) THEN

       -- Inserting a new cn_quota_rules record
       IF x_quota_rule_id IS NOT NULL THEN

          -- Bug 2507490
	  INSERT INTO cn_srp_quota_rules_all
	    ( srp_quota_rule_id
	      ,srp_plan_assign_id
	      ,srp_quota_assign_id
	      ,quota_rule_id
	      ,revenue_class_id
              ,target
	      ,payment_amount
	      ,performance_goal
	      ,creation_date
	      ,created_by
	      ,last_updated_by
	      ,last_update_date
	      ,last_update_login
	      ,org_id)
	    SELECT
	    cn_srp_quota_rules_s1.nextval
	    ,sqa.srp_plan_assign_id
	    ,sqa.srp_quota_assign_id
	    ,qr.quota_rule_id
	    ,qr.revenue_class_id
 	    ,qr.target
	    ,qr.payment_amount
	    ,qr.performance_goal
	    ,Sysdate
	    ,fnd_global.user_id
	    ,fnd_global.user_id
	    ,Sysdate
	    ,fnd_global.login_id
	    ,sqa.org_id
	    FROM  cn_srp_quota_assigns_all sqa
	    ,cn_quota_rules_all  	   qr
	    WHERE sqa.quota_id	= x_quota_id
	    AND qr.quota_id		= sqa.quota_id
	    AND qr.quota_rule_id	= x_quota_rule_id
	    AND sqa.quota_type_code IN ('FORMULA','EXTERNAL')
	    ;

	ELSIF x_quota_rule_id IS NULL THEN

	  -- Inserting after quota type was changed to 'target' or 'revenue'
          -- Bug 2507490
	  INSERT INTO cn_srp_quota_rules_all
	    ( srp_quota_rule_id
	      ,srp_plan_assign_id
	      ,srp_quota_assign_id
	      ,quota_rule_id
	      ,revenue_class_id
              ,target
	      ,payment_amount
	      ,performance_goal
	      ,creation_date
	      ,created_by
	      ,last_updated_by
	      ,last_update_date
	      ,last_update_login
	      ,org_id)
	    SELECT
	    cn_srp_quota_rules_s1.nextval
	    ,sqa.srp_plan_assign_id
	    ,sqa.srp_quota_assign_id
	    ,qr.quota_rule_id
	    ,qr.revenue_class_id
            ,qr.target
	    ,qr.payment_amount
	    ,qr.performance_goal
	    ,Sysdate
	    ,fnd_global.user_id
	    ,fnd_global.user_id
	    ,Sysdate
	    ,fnd_global.login_id
	    ,sqa.org_id
	    FROM  cn_srp_quota_assigns_all sqa
	    ,cn_quota_rules_all  	    qr
	    WHERE sqa.quota_id	= x_quota_id
	    AND qr.quota_id	= sqa.quota_id
	    AND sqa.quota_type_code IN ('FORMULA', 'EXTERNAL')
	    ;

       END IF;

    END IF;

    cn_srp_per_quota_rc_pkg.insert_record
      (
       x_srp_plan_assign_id    => x_srp_plan_assign_id
       ,x_quota_id		=> x_quota_id
       ,x_revenue_class_id	=> x_revenue_class_id
       ,x_start_period_id       => null
       ,x_end_period_id         => null);

   -- Srp Quota Rule uplifts
     cn_srp_rule_uplifts_pkg.insert_record
     ( p_srp_plan_assign_id  => x_srp_plan_assign_id
      ,p_quota_id            => x_quota_id
      ,p_quota_rule_id       => x_quota_rule_id
      ,p_quota_rule_uplift_id=> null
    );

 END insert_record;
 ---------------------------------------------------------------------------+
  -- PROCEDURE DELETE_RECORD
  ---------------------------------------------------------------------------+
 PROCEDURE delete_record
   ( x_srp_plan_assign_id	 NUMBER
     ,x_srp_quota_assign_id      NUMBER
     ,x_quota_id                 NUMBER
     ,x_quota_rule_id	         NUMBER
     ,x_revenue_class_id	 NUMBER ) IS
 BEGIN

    IF (    x_srp_plan_assign_id IS NOT NULL
	    AND x_quota_id       IS NOT NULL
	    AND x_quota_rule_id  IS NULL   ) THEN

       -- cn_quota_assigns record has been deleted.
       -- This procedure is called once for each srp_plan_assign record
       -- the plan belongs to
       -- We really needed another foreign key to avoid the subquery

       -- before delete the srp rules, delete the uplifts.

       cn_srp_rule_uplifts_pkg.Delete_record
	 (
	  p_srp_plan_assign_id    => x_srp_plan_assign_id
	  ,p_quota_id              => x_quota_id
	  ,p_quota_rule_id         => NULL
	  ,p_quota_rule_uplift_id  => NULL);

       DELETE FROM cn_srp_quota_rules_all qr
	 WHERE qr.srp_plan_assign_id = x_srp_plan_assign_id
	 AND qr.srp_quota_assign_id IN
	 (SELECT sqa.srp_quota_assign_id
	  FROM cn_srp_quota_assigns sqa
	  WHERE sqa.quota_id 		= x_quota_id
	  AND sqa.srp_plan_assign_id  = x_srp_plan_assign_id)
	 ;

     ELSIF (    x_srp_plan_assign_id IS NOT NULL
		AND x_quota_id 	     IS NULL
		AND x_quota_rule_id  IS NULL    ) THEN

       -- cn_srp_plan_assigns record has been deleted
       -- delete srp rule uplifs before delete the srp rules.

       cn_srp_rule_uplifts_pkg.Delete_record
	 (
	 p_srp_plan_assign_id    => x_srp_plan_assign_id
	  ,p_quota_id              => NULL
	  ,p_quota_rule_id         => NULL
	  ,p_quota_rule_uplift_id  => NULL);

       DELETE FROM cn_srp_quota_rules_all qr
	 WHERE qr.srp_plan_assign_id = x_srp_plan_assign_id;

     ELSIF (    x_srp_plan_assign_id IS NULL
		AND x_quota_id 	   IS NOT NULL
		AND x_quota_rule_id 	   IS NOT NULL) THEN

       -- cn_quota_rules record deleted
       -- The revenue_class_id is also passed to ensure we can delete the
       -- per_quota_rc records.

       -- **  Delete SRp Quota rule uplifs before delete the srp quota rules
       cn_srp_rule_uplifts_pkg.Delete_record
	 (
	  p_srp_plan_assign_id    => NULL
	  ,p_quota_id              => x_quota_id
	  ,p_quota_rule_id         => x_quota_rule_id
	  ,p_quota_rule_uplift_id  => NULL);

       DELETE FROM cn_srp_quota_rules_all
	 WHERE quota_rule_id = x_quota_rule_id;

     ELSIF (    x_srp_plan_assign_id IS NULL
		AND x_quota_id       IS NOT NULL
		AND x_quota_rule_id  IS NULL   ) THEN

       -- Quota's type has changed to 'manual' or 'draw' which do not support
       -- revenue classes
       -- delete srp quota rule uplifts

       cn_srp_rule_uplifts_pkg.Delete_record
	 (
	  p_srp_plan_assign_id    => NULL
	  ,p_quota_id              => x_quota_id
	  ,p_quota_rule_id         => NULL
	  ,p_quota_rule_uplift_id  => NULL);

       DELETE FROM cn_srp_quota_rules_all
	 WHERE quota_rule_id IN (SELECT quota_rule_id
				 FROM cn_quota_rules
				 WHERE quota_id = x_quota_id);

    END IF;

    cn_srp_per_quota_rc_pkg.delete_record
      (
	x_srp_plan_assign_id => x_srp_plan_assign_id
	,x_quota_id		=> x_quota_id
	,x_revenue_class_id   => x_revenue_class_id
	,x_start_period_id    => null
	,x_end_period_id      => null);

 END delete_record;

 ---------------------------------------------------------------------------+
 -- PROCEDURE SELECT_SUMMARY
 ---------------------------------------------------------------------------+
  PROCEDURE select_summary( x_srp_quota_assign_id              NUMBER
			   ,x_total		 IN OUT nocopy NUMBER)  IS
  BEGIN
    SELECT nvl(sum(target_amount),0)
      INTO x_total
      FROM cn_srp_period_quotas_all
     WHERE srp_quota_assign_id = x_srp_quota_assign_id
    ;

    EXCEPTION
      WHEN no_data_found THEN null;
   END select_summary;


---------------------------------------------------------------------------+
-- PROCEDURE LOCK_RECORD
-- Descr: New procedure you can call it from cn_srp_quota_rules form
---------------------------------------------------------------------------+
  PROCEDURE lock_record
    ( x_srp_quota_rule_id       NUMBER
      ,x_target                 NUMBER
       ,x_payment_amount        NUMBER
      ,x_performance_goal       NUMBER ) IS

      CURSOR C IS
         SELECT *
           FROM   cn_srp_quota_rules_all
           WHERE  srp_quota_rule_id = x_srp_quota_rule_id
           FOR UPDATE OF srp_quota_rule_id NOWAIT;
      Recinfo C%ROWTYPE;

  BEGIN

     OPEN C;
     FETCH C INTO Recinfo;

     IF (C%NOTFOUND) THEN
     CLOSE C;
     fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
     app_exception.raise_exception;
     END IF;
     CLOSE C;
     IF (  (   recinfo.target  = x_target
	     OR (recinfo.target IS NULL AND
		 x_target IS NULL                 )
	     )
	 AND (   recinfo.payment_amount  = x_payment_amount
		 OR (recinfo.payment_amount IS NULL AND
		     x_payment_amount IS NULL                 )
                 )
	 AND (   recinfo.performance_goal  = x_performance_goal
		 OR (recinfo.performance_goal IS NULL AND
		     x_performance_goal IS NULL                 )
		 )
	 ) THEN
     RETURN;
      ELSE
     fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
     app_exception.raise_exception;
     END IF;

  END Lock_Record;

END cn_srp_quota_rules_pkg;

/
