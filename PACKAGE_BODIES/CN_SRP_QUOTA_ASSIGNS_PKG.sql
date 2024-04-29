--------------------------------------------------------
--  DDL for Package Body CN_SRP_QUOTA_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_QUOTA_ASSIGNS_PKG" as
-- $Header: cnsrplbb.pls 120.2 2005/09/06 17:40:01 mblum noship $

/****************************************************************************
Package Body Name
  cn_srp_quota_assigns_pkg

  Purpose

  History
  -------
  26-JAN-94 Tony Lower	Created
  10-FEB-94 P Cook	Table handler conversion and unit test
  30-JUN-95 P Cook	Added calls to delete records from cn_srp_quota_rules
  24-JUL-95 P Cook	Update all denormalized quota columns whenever the
                        source quota changes.
  25-JUL-95 P Cook	Modified lock record to deral with null target value
  08-AUG-95 P Cook	Default customized_flag to 'Y' instead of 'N'.
  21-AUG-95 P Cook	Fixed update_srp_quota to prevent tiers being added
                        whenever the source quota is updated.
  12-OCT-95 P Cook	Added period_target_unit_code to table handlers.
  16-FEB-96 P Cook	Removed synching of comm rates and targets from
                        update_record procedure. Now done in salesrep form.
  02-JUN-99 S Kumar     Rate Schedule_id, Disc_rate_schedule_id is no more
                        exists in the quota Table.
                        Quota_type values are changed now we have only
                        Formula, External, None
                        Period_type is obsolete.
                        Added two parameters in Update_srp_quota
                        calc_formula_id, calc_formula_id_old
                        changing calc formula will iimpact the rates

  25-AUG-99  S Kumar    Added the performance goal at the insert statement
                        insert record.

                        Added the performance goal in the lock record, we
                        need to change the goal from the screen

                        Update_record has the new columns performance goal

                        Update Srp_quota has the new columns performance goal

  25-AUG-99   S Kumar   Modified the repective calling programs as well
  23-MAR-01   K Chen    Add changes from customize_flag

  	      rarajara	Added Valid_Assign procedure for payee check
  20-NOV-03   RARAJARA  Bugfix #3241172
  **************************************************************************/


   ----------------------------------------------------------------------------
  -- FUNCTION IS_CUSTOMIZED
  ----------------------------------------------------------------------------
  -- Procedure Name
  --  IS_CUSTOMIZED
  -- Purpose
  --
  -- Notes
  --  o Called from update_record to ensure whether the customer has customized
  --    the plan element at the salesrep level
  FUNCTION IS_CUSTOMIZED
  (
      x_srp_quota_assign_id  NUMBER
    , x_quota_id             NUMBER
  ) RETURN NUMBER
   IS
    l_return NUMBER;
  BEGIN

    l_return := 0 ; -- zero indicates PE not customized


    SELECT count(*)
    INTO   l_return
    FROM
    (
        SELECT 'X'
        FROM   cn_srp_quota_assigns_all csqa
        ,      cn_quotas_all cq
        WHERE  csqa.srp_quota_assign_id = x_srp_quota_assign_id
        AND    cq.quota_id              = x_quota_id
        AND    (
                   csqa.target <> cq.target
                OR csqa.payment_amount <> cq.payment_amount
                OR csqa.performance_goal <> cq.performance_goal
               )
     )           ;

    IF l_return = 0 THEN
        SELECT count(*)
        INTO   l_return
        FROM
        (
            SELECT 'X'
            FROM   cn_srp_period_quotas_all cspq
            ,      cn_period_quotas_all     cpq
            WHERE  cspq.srp_quota_assign_id = x_srp_quota_assign_id
            AND    cpq.quota_id             = x_quota_id
            AND    cspq.period_id           = cpq.period_id
            AND    (
                    cpq.period_target        <> cspq.target_amount
                     OR cpq.period_payment       <> cspq.period_payment
                     OR cpq.performance_goal     <> cspq.performance_goal_ptd
                    )
        );

            IF l_return = 0 THEN
                SELECT count(*)
                INTO   l_return
                FROM
                (
                    SELECT 'X'
                    FROM   cn_srp_quota_assigns_all   csqa
                    ,      cn_quota_rules_all         cqr
                    ,      cn_srp_quota_rules_all     csqr
                    ,      cn_quota_rule_uplifts_all  cqru
                    ,      cn_srp_rule_uplifts_all    csru
                    WHERE  csqa.srp_quota_assign_id = x_srp_quota_assign_id
                    AND   cqr.quota_id = x_quota_id
                    AND   csqr.srp_plan_assign_id  = csqa.srp_plan_assign_id
                    AND   csqr.srp_quota_assign_id = x_srp_quota_assign_id
                    AND   cqr.revenue_class_id     = csqr.revenue_class_id
                    AND   cqru.quota_rule_id = cqr.quota_rule_id
                    AND   csru.srp_quota_rule_id = csqr.srp_quota_rule_id
                    AND   cqru.quota_rule_uplift_id = csru.quota_rule_uplift_id
                    AND   (
                              (
                                cqr.target <> csqr.target
                                OR cqr.payment_amount <> csqr.payment_amount
                                OR cqr.performance_goal <> csqr.performance_goal
                              )
                             OR
                             (
                             cqru.payment_factor <> csru.payment_factor
                             OR cqru.quota_factor   <> csru.quota_factor
                             )
                         )
                 );
            END IF;
        END IF;
     RETURN l_return;
  END IS_CUSTOMIZED;

    ----------------------------------------------------------------------------
  -- PROCEDURE Valid Assign
  ----------------------------------------------------------------------------
  -- Procedure Name
    --  Valid_Assign
    -- Purpose
    --   To check whether a Plan Element with 'Payee Assign Flag' set is
    --   is getting assigned to a salesrep who has payee role.
    --
    -- Parameters
    --  x_srp_plan_assign_id As IN parameter
    --  x_valid As Out parameter

   PROCEDURE Valid_Assign
   (p_srp_plan_assign_id IN NUMBER,
    x_valid	 OUT NOCOPY NUMBER
   ) IS
   Begin
   	x_valid := 0;
   	SELECT	count(*) INTO x_valid
   	FROM 	dual
   	WHERE	EXISTS
	  (
	   SELECT	1
	   FROM	cn_srp_plan_assigns_all csqa
	   WHERE	csqa.srp_plan_assign_id = p_srp_plan_assign_id
	   AND EXISTS
	   (
	    SELECT 1 FROM cn_quota_assigns_all cqa
	    WHERE  cqa.comp_plan_id = csqa.comp_plan_id
	    AND EXISTS
	    (
	     SELECT 1 FROM cn_quotas_all cq
	     WHERE cq.quota_id = cqa.quota_id
	     AND cq.payee_assign_flag = 'Y'
	     )
	    )
	   )
	  AND
	  EXISTS
	  (
	   SELECT	1
	   FROM	cn_srp_plan_assigns_all cspa
	   WHERE	cspa.srp_plan_assign_id = p_srp_plan_assign_id
	   AND EXISTS
	   (
	    SELECT	1
	    FROM	cn_srp_roles csr
	    WHERE	csr.salesrep_id = cspa.salesrep_id
	    AND         csr.org_id = cspa.org_id
	    and 	csr.role_id = 54
	    )
	   );

   End;


  ----------------------------------------------------------------------------
  -- PROCEDURE INSERT RECORD
  ----------------------------------------------------------------------------
  -- Procedure Name
  --  Insert Record
  -- Purpose
  --   Insert srp quota assignment(s) and related records.
  --
  -- Notes						  Parameters
  --   o Called once for each new srp plan assignment.    x_srp_plan_assign_id

  --   o Called when assigning quotas to plans.
  --     Once for each srp plan assignment that    	  x_srp_plan_assign_id
  --     references the comp plan id on the new comp      x_quota_id
  --     plan quota assignment

  PROCEDURE Insert_Record
  ( x_srp_plan_assign_id NUMBER
    ,x_quota_id		NUMBER ) IS

       l_user_id  NUMBER(15);
       l_resp_id  NUMBER(15);
       l_login_id NUMBER(15);
       l_valid	  NUMBER;

       CURSOR l_srp_quota_assign_csr (c_quota_id cn_quotas.quota_id%TYPE,
				      c_srp_plan_assign_id cn_srp_quota_assigns.srp_plan_assign_id%TYPE) IS
	  SELECT srp_quota_assign_id
	    FROM cn_srp_quota_assigns_all
	   WHERE srp_plan_assign_id = c_srp_plan_assign_id
	     AND quota_id = c_quota_id;

       l_srp_quota_assign_c  l_srp_quota_assign_csr%ROWTYPE;

       CURSOR l_srp_quota_assign_csr2 (c_srp_plan_assign_id cn_srp_quota_assigns.srp_plan_assign_id%TYPE) IS
	  SELECT srp_quota_assign_id, quota_id
	    FROM cn_srp_quota_assigns_all
	   WHERE srp_plan_assign_id = c_srp_plan_assign_id;

      l_srp_quota_assign_c2  l_srp_quota_assign_csr2%ROWTYPE;

      CURSOR l_rollover_quota_csr (c_quota_id cn_quotas.quota_id%TYPE) IS
	 SELECT *
	   FROM cn_rollover_quotas_all
	  WHERE quota_id = c_quota_id;

      l_rollover_quota_c  l_rollover_quota_csr%ROWTYPE;

      l_rowid                     VARCHAR2(30);
      l_srp_rollover_quota_id         NUMBER := NULL;

      l_init_msg_list	VARCHAR2(32000) := FND_API.G_FALSE;

  BEGIN

     l_user_id  := fnd_global.user_id;
     l_resp_id  := fnd_global.resp_id;
     l_login_id := fnd_global.login_id;

     Valid_Assign (
		   p_srp_plan_assign_id => x_srp_plan_assign_id,
		   x_valid => l_valid
		   );

     IF ( l_valid > 0 ) THEN
     	--FND_MSG_PUB.initialize;
     	IF FND_API.to_Boolean( l_init_msg_list ) THEN
	   FND_MSG_PUB.initialize;
   	END IF;
     	fnd_message.set_name('CN', 'CN_ROLE_PLAN_ASGN_PAYEE_ERROR');
     	FND_MSG_PUB.Add;
     	RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (x_srp_plan_assign_id IS NOT NULL AND x_quota_id IS NOT NULL) THEN

	-- inserting a new cn_quota_assign
	-- called once for each srp_plan_assignment using the comp_plan_id

	INSERT INTO cn_srp_quota_assigns_all
	  (
	    srp_quota_assign_id
	    ,srp_plan_assign_id
	    ,quota_id
	    ,target
	    ,customized_flag
	    ,period_target_dist_rule_code
	    ,quota_type_code
	    ,payment_amount
            ,performance_goal
	    ,period_target_unit_code
	    ,creation_date
	    ,created_by
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,org_id)
	  SELECT
	  cn_srp_quota_assigns_s.nextval
	  ,x_srp_plan_assign_id
	  ,q.quota_id
	  ,q.target
	  ,cn_system_parameters.value('CN_CUSTOM_FLAG', org_id)
	  ,'EQUAL'  		-- Currently support only one method
          ,q.quota_type_code
	  ,q.payment_amount
	  ,q.performance_goal
	  ,'PERIOD' 		-- Could let the user define this in cn_quotas
	  ,sysdate
	  ,l_user_id
	  ,sysdate
	  ,l_user_id
	  ,l_login_id
	  ,org_id
	  FROM  cn_quotas_all q
	  WHERE q.quota_id = x_quota_id
	  ;

      -- clku, populate_srp_rollover_quotas
	FOR l_srp_quota_assign_c IN l_srp_quota_assign_csr(x_quota_id, x_srp_plan_assign_id) LOOP
	   FOR l_rollover_quota_c IN l_rollover_quota_csr(x_quota_id) LOOP

	      CN_SRP_ROLLOVER_QUOTAS_PKG.INSERT_ROW
              (X_ROWID => l_rowid,
               X_SRP_ROLLOVER_QUOTA_ID => l_srp_rollover_quota_id,
               X_SRP_QUOTA_ASSIGN_ID => l_srp_quota_assign_c.srp_quota_assign_id,
               X_ROLLOVER_QUOTA_ID => l_rollover_quota_c.rollover_quota_id,
               X_QUOTA_ID => x_quota_id,
               X_SOURCE_QUOTA_ID => l_rollover_quota_c.source_quota_id,
               X_ROLLOVER => l_rollover_quota_c.rollover,
               X_ATTRIBUTE_CATEGORY => l_rollover_quota_c.attribute_category,
               X_ATTRIBUTE1 => l_rollover_quota_c.attribute1,
               X_ATTRIBUTE2 => l_rollover_quota_c.attribute2,
               X_ATTRIBUTE3 => l_rollover_quota_c.attribute3,
               X_ATTRIBUTE4 => l_rollover_quota_c.attribute4,
               X_ATTRIBUTE5 => l_rollover_quota_c.attribute5,
               X_ATTRIBUTE6 => l_rollover_quota_c.attribute6,
               X_ATTRIBUTE7 => l_rollover_quota_c.attribute7,
               X_ATTRIBUTE8 => l_rollover_quota_c.attribute8,
               X_ATTRIBUTE9 => l_rollover_quota_c.attribute9,
               X_ATTRIBUTE10 => l_rollover_quota_c.attribute10,
               X_ATTRIBUTE11 => l_rollover_quota_c.attribute11,
               X_ATTRIBUTE12 => l_rollover_quota_c.attribute12,
               X_ATTRIBUTE13 => l_rollover_quota_c.attribute13,
               X_ATTRIBUTE14 => l_rollover_quota_c.attribute14,
               X_ATTRIBUTE15 => l_rollover_quota_c.attribute15,
               X_CREATED_BY => fnd_global.user_id,
               X_CREATION_DATE => sysdate,
               X_LAST_UPDATE_DATE => sysdate,
               X_LAST_UPDATED_BY => fnd_global.user_id,
               X_LAST_UPDATE_LOGIN => fnd_global.login_id
               );

	   END LOOP;

	END LOOP;
      ELSIF (x_srp_plan_assign_id IS NOT NULL AND x_quota_id IS NULL) THEN

	-- called from after insert of srp plan assignment
	-- this is also how plan assign period changes are done
	INSERT INTO cn_srp_quota_assigns_all
	  (
	    srp_quota_assign_id
	    ,srp_plan_assign_id
	    ,quota_id
	    ,target
	    ,customized_flag
	    ,period_target_dist_rule_code
	    ,quota_type_code
	    ,payment_amount
            ,performance_goal
	    ,period_target_unit_code
	    ,creation_date
	    ,created_by
	    ,last_update_date
	    ,last_updated_by
	    ,last_update_login
	    ,org_id)
	  SELECT
	  cn_srp_quota_assigns_s.nextval
	  ,pa.srp_plan_assign_id
	  ,q.quota_id
	  ,q.target
	  ,cn_system_parameters.value('CN_CUSTOM_FLAG', q.org_id)
	  ,'EQUAL'
          ,q.quota_type_code
	  ,q.payment_amount
          ,q.performance_goal
	  ,'PERIOD'
	  ,sysdate
	  ,l_user_id
	  ,sysdate
	  ,l_user_id
	  ,l_login_id
	  ,q.org_id
	  FROM  cn_quotas_all      q
	  ,cn_srp_plan_assigns_all pa
	  ,cn_quota_assigns_all    qa
	  WHERE  pa.srp_plan_assign_id = x_srp_plan_assign_id
	  AND   pa.comp_plan_id	       = qa.comp_plan_id
	  AND   q.quota_id             = qa.quota_id
	  ;

       -- clku, populate_srp_rollover_quotas
       FOR l_srp_quota_assign_c2 IN l_srp_quota_assign_csr2(x_srp_plan_assign_id) LOOP
	  FOR l_rollover_quota_c IN l_rollover_quota_csr(l_srp_quota_assign_c2.quota_id) LOOP

	     CN_SRP_ROLLOVER_QUOTAS_PKG.INSERT_ROW
              (X_ROWID => l_rowid,
               X_SRP_ROLLOVER_QUOTA_ID => l_srp_rollover_quota_id,
               X_SRP_QUOTA_ASSIGN_ID => l_srp_quota_assign_c2.srp_quota_assign_id,
               X_ROLLOVER_QUOTA_ID => l_rollover_quota_c.rollover_quota_id,
               X_QUOTA_ID => l_srp_quota_assign_c2.quota_id,
               X_SOURCE_QUOTA_ID => l_rollover_quota_c.source_quota_id,
               X_ROLLOVER => l_rollover_quota_c.rollover,
               X_ATTRIBUTE_CATEGORY => l_rollover_quota_c.attribute_category,
               X_ATTRIBUTE1 => l_rollover_quota_c.attribute1,
               X_ATTRIBUTE2 => l_rollover_quota_c.attribute2,
               X_ATTRIBUTE3 => l_rollover_quota_c.attribute3,
               X_ATTRIBUTE4 => l_rollover_quota_c.attribute4,
               X_ATTRIBUTE5 => l_rollover_quota_c.attribute5,
               X_ATTRIBUTE6 => l_rollover_quota_c.attribute6,
               X_ATTRIBUTE7 => l_rollover_quota_c.attribute7,
               X_ATTRIBUTE8 => l_rollover_quota_c.attribute8,
               X_ATTRIBUTE9 => l_rollover_quota_c.attribute9,
               X_ATTRIBUTE10 => l_rollover_quota_c.attribute10,
               X_ATTRIBUTE11 => l_rollover_quota_c.attribute11,
               X_ATTRIBUTE12 => l_rollover_quota_c.attribute12,
               X_ATTRIBUTE13 => l_rollover_quota_c.attribute13,
               X_ATTRIBUTE14 => l_rollover_quota_c.attribute14,
               X_ATTRIBUTE15 => l_rollover_quota_c.attribute15,
               X_CREATED_BY => fnd_global.user_id,
               X_CREATION_DATE => sysdate,
               X_LAST_UPDATE_DATE => sysdate,
               X_LAST_UPDATED_BY => fnd_global.user_id,
               X_LAST_UPDATE_LOGIN => fnd_global.login_id
               );

            END LOOP;
       END LOOP;
     END IF;

     -- period quotas maintained for all quota types.
     -- Must be maintained before revenue classes because these records
     -- drive the creation of period dependent rev class records

     -- Feb24,99
     -- Change from ,x_quota_id             => null
     --        to   ,x_quota_id             => x_quota_id
     -- Start Date, End Date added on this package on 10/JUN/99
     cn_srp_period_quotas_pkg.insert_record
       (
	 x_srp_plan_assign_id => x_srp_plan_assign_id
	 ,x_quota_id	      => x_quota_id
	 ,x_start_period_id   => NULL
	 ,x_end_period_id     => NULL
	 ,x_start_date        => NULL
	 ,x_end_date          => NULL );

     -- This procedure will ensure that only target and revenue quota types
     -- get quota rules
     cn_srp_quota_rules_pkg.insert_record
       (
	x_srp_plan_assign_id  => x_srp_plan_assign_id
	,x_quota_id	      => x_quota_id
	,x_quota_rule_id      => NULL
	,x_revenue_class_id   => NULL);

     -- This procedure will ensure that only target and revenue quota types
     -- get rate assignments

     cn_srp_rate_assigns_pkg.insert_record
       (
	 x_srp_plan_assign_id 	 => x_srp_plan_assign_id
	 ,x_srp_quota_assign_id  => NULL
	 ,x_srp_rate_assign_id   => NULL
	 ,x_quota_id		 => x_quota_id
	 ,x_rate_schedule_id	 => NULL
	 ,x_rate_tier_id	 => NULL
	 ,x_commission_rate 	 => NULL
	 ,x_commission_amount    => NULL
	 ,x_disc_rate_table_flag => NULL );

  END insert_record;
  ----------------------------------------------------------------------------
  -- PROCEDURE LOCK_RECORD
  ----------------------------------------------------------------------------
  PROCEDURE lock_record
    ( x_srp_quota_assign_id              NUMBER
      ,x_target                          NUMBER
      ,x_customized_flag		 VARCHAR2
      ,x_period_target_dist_rule_code	 VARCHAR2
      ,x_payment_amount		         NUMBER
      ,x_performance_goal                NUMBER
      ,x_period_target_unit_code	 VARCHAR2) IS

	 CURSOR C IS
	    SELECT *
	      FROM   cn_srp_quota_assigns_all
	      WHERE  srp_quota_assign_id = x_srp_quota_assign_id
	      FOR UPDATE OF srp_quota_assign_id NOWAIT;
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

     -- The target column should be nullable, but it isn't. To get around this
     -- the view decodes the column to null depending upon the quota type
     -- the column value is actually zero. We nvl the x_target to decode the
     -- form field null value into its real column value

     IF (    (recinfo.target 	     	     = nvl(x_target,0)     )
	     AND (recinfo.customized_flag    = x_customized_flag   )
	     AND (recinfo.period_target_dist_rule_code =
		  x_period_target_dist_rule_code                   )
	     ) THEN
	RETURN;
      ELSE

	fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	app_exception.raise_exception;
     END IF;

  END Lock_Record;
  ----------------------------------------------------------------------------
  -- PROCEDURE UPDATE_RECORD
  ----------------------------------------------------------------------------
  -- Procedure Name
  --  Update_Record
  -- Purpose
  --
  -- Notes
  --  o Called when the srp quota target or customized_flag are changed
  --    Simply sets the columns to the field values.

  PROCEDURE update_record(
			  x_srp_quota_assign_id          NUMBER
			  ,x_target                      NUMBER
			  ,x_target_old                  NUMBER
			  ,x_start_period_id		 NUMBER
			  ,x_salesrep_id		 NUMBER
			  ,x_customized_flag             VARCHAR2
			  ,x_customized_flag_old         VARCHAR2
			  ,x_quota_id			 NUMBER
			  ,x_rate_schedule_id		 NUMBER
			  ,x_period_target_dist_rule_code VARCHAR2
			  ,x_attributes_changed		 VARCHAR2
			  ,x_distribute_target_flag	 VARCHAR2
			  ,x_payment_amount		 NUMBER
			  ,x_payment_amount_old		 NUMBER
                          ,x_performance_goal            NUMBER
			  ,x_performance_goal_old        NUMBER
			  ,x_quota_type_code		 VARCHAR2
			  ,x_period_target_unit_code	 VARCHAR2
			  ,x_last_update_date		 DATE
			  ,x_last_updated_by		 NUMBER
			  ,x_last_update_login		 NUMBER) IS


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

    CURSOR srp_rollover_quota_curs IS
       SELECT *
	 FROM cn_srp_rollover_quotas_all
	WHERE srp_quota_assign_id = x_srp_quota_assign_id;

    l_srp_rollover_quota   srp_rollover_quota_curs%ROWTYPE;

    l_count NUMBER := 0;
    l_srp_plan_assign_id cn_srp_quota_assigns.srp_plan_assign_id%TYPE;
    l_quota_id           cn_srp_quota_assigns.quota_id%TYPE;


  BEGIN
     IF x_srp_quota_assign_id IS NOT NULL THEN

	-- Called from srp plan assignment form
	UPDATE cn_srp_quota_assigns_all
	  SET
	  -- Should be an optional column as it can be null for
	  -- quota types 'revenue' and 'draw'. But it is mandatory and
	  -- this nvl protects against a null value coming back from the
	  -- form
	  target           		  = NVL(x_target,0)
	  ,customized_flag  		  = x_customized_flag
	  ,period_target_dist_rule_code   = x_period_target_dist_rule_code
	  ,payment_amount		  = x_payment_amount
	  ,performance_goal               = x_performance_goal
	  ,period_target_unit_code	  = x_period_target_unit_code
	  ,last_update_date  		  = x_last_update_date
	  ,last_updated_by   		  = x_last_updated_by
	  ,last_update_login 		  = x_last_update_login
	  WHERE srp_quota_assign_id       = x_srp_quota_assign_id
	  ;

	IF (sql%notfound) THEN
	   raise no_data_found;
	END IF;

       IF x_customized_flag = 'N'
	 AND  x_customized_flag_old = 'Y' THEN

	  -- get plan assign ID
	  SELECT srp_plan_assign_id, quota_id
	    INTO l_srp_plan_assign_id, l_quota_id
	    FROM cn_srp_quota_assigns_all
	   WHERE srp_quota_assign_id = x_srp_quota_assign_id;

	  IF IS_CUSTOMIZED(x_srp_quota_assign_id,x_quota_id) > 0 THEN
	     -- rollback all the changes

	     -- revert changes on srp_quota_assign
	     -- to do this, simply delete records so calc will use default rate

	     update cn_srp_quota_assigns_all
	       set (target,
		    payment_amount,
		    performance_goal) =
	     (select target,
                     payment_amount,
                     performance_goal
                from cn_quotas_all
               where quota_id = x_quota_id)
             where srp_quota_assign_id = x_srp_quota_assign_id;

	     -- clku, revert changes in cn_srp_rolling_quotas

	     FOR l_srp_rollover_quota IN srp_rollover_quota_curs LOOP

		update cn_srp_rollover_quotas_all csrq
		  set  rollover  =
		  ( select rollover
		    from cn_rollover_quotas_all crq
		    where crq.rollover_quota_id = l_srp_rollover_quota.rollover_quota_id)
		  where srp_rollover_quota_id = l_srp_rollover_quota.srp_rollover_quota_id;
	     END LOOP;

	     -- revert changes on srp_quota_rules and quota_rule_uplifts
	     OPEN sqr_curs;
	     LOOP
		FETCH sqr_curs INTO l_recinfo;
		EXIT WHEN sqr_curs%notfound;

	       UPDATE cn_srp_quota_rules_all
	          SET target = l_recinfo.target,
	              payment_amount = l_recinfo.payment_amount,
	              performance_goal = l_recinfo.performance_goal
	        WHERE srp_quota_rule_id = l_recinfo.srp_quota_rule_id
	           ;

	       UPDATE cn_srp_rule_uplifts_all srp
	          SET (payment_factor, quota_factor)
	          = (SELECT payment_factor, quota_factor
	               FROM cn_quota_rule_uplifts_all q
	              WHERE q.quota_rule_uplift_id  = srp.quota_rule_uplift_id)
		WHERE srp.srp_quota_rule_id = l_recinfo.srp_quota_rule_id
                   ;

             END LOOP;
             CLOSE sqr_curs;

             -- revert srp_period_quota
             SELECT count(1)
               INTO l_count
               FROM cn_srp_period_quotas_all
	      WHERE srp_quota_assign_id = x_srp_quota_assign_id
                AND rownum = 1
                  ;

             IF l_count > 0 THEN
		cn_srp_rate_assigns_pkg.delete_record
		  ( x_srp_plan_assign_id  => l_srp_plan_assign_id
		    ,x_srp_rate_assign_id => null
		    ,x_quota_id           => l_quota_id
		    ,x_rate_schedule_id   => null
		    ,x_rate_tier_id       => null);

               cn_srp_period_quotas_pkg.delete_record
                (
                   x_srp_plan_assign_id => l_srp_plan_assign_id
                  ,x_quota_id           => x_quota_id
                  ,x_start_period_id    => null
                  ,x_end_period_id      => null);

               cn_srp_period_quotas_pkg.insert_record
                 (
                   x_srp_plan_assign_id => l_srp_plan_assign_id
                  ,x_quota_id           => x_quota_id
                  ,x_start_period_id    => null
                  ,x_end_period_id      => null);

             END IF; -- l_count

	  END IF; -- is_customized

	  -- Revert the SRP level Commission Rates, work with arch of
	  -- Sparse Rate Table implementation

	  cn_srp_rate_assigns_pkg.delete_record
	    ( x_srp_plan_assign_id  	=> l_srp_plan_assign_id
	      ,x_quota_id		=> x_quota_id
	      -- not used
	      ,x_srp_rate_assign_id	=> null
	      ,x_rate_schedule_id	=> null
	      ,x_rt_quota_asgn_id    => null
	      ,x_rate_tier_id	=> null);

       END IF; -- custom flag Y -> N

       IF x_customized_flag = 'Y' and
	 x_customized_flag_old = 'N' THEN
	  -- create srp rate assigns
	  SELECT srp_plan_assign_id, quota_id
	    INTO l_srp_plan_assign_id, l_quota_id
	    FROM cn_srp_quota_assigns_all
	   WHERE srp_quota_assign_id = x_srp_quota_assign_id;

	  cn_srp_rate_assigns_pkg.insert_record
	    (x_srp_plan_assign_id    => l_srp_plan_assign_id
	     ,x_srp_quota_assign_id  => NULL
	     ,x_srp_rate_assign_id   => NULL
	     ,x_quota_id             => l_quota_id
	     ,x_rate_schedule_id     => NULL
	     ,x_rate_tier_id         => NULL
	     ,x_commission_rate      => NULL
	     ,x_commission_amount    => NULL
	     ,x_disc_rate_table_flag => NULL );
       END IF; -- custom flag N -> Y
     END IF; -- x_srp_quota_assign_id not null
     -- End Update Record.

  END Update_Record;
  ----------------------------------------------------------------------------
  -- PROCEDURE UPDATE_SRP_QUOTA
  ----------------------------------------------------------------------------
  -- Procedure Name
  --  Update_srp_quota
  -- Purpose
  --  Maintain srp tables after a change to the source quota
  -- Notes
  --  o Called from cn_quotas_pkg.update_record
  --  o Split from main update record for readability

  PROCEDURE update_srp_quota(
			     x_quota_id			  NUMBER
			     ,x_target                    NUMBER
			     ,x_payment_amount		  NUMBER
			     ,x_performance_goal          NUMBER
			     ,x_rate_schedule_id	  NUMBER   -- obsolete
			     ,x_rate_schedule_id_old	  NUMBER   -- obsolete
			     ,x_disc_rate_schedule_id	  NUMBER   -- obsolete
			     ,x_disc_rate_schedule_id_old NUMBER   -- obsolete
			     ,x_payment_type_code	  VARCHAR2 -- obsolete
			     ,x_payment_type_code_old	  VARCHAR2 -- obsolete
			     ,x_quota_type_code		  VARCHAR2
			     ,x_quota_type_code_old	  VARCHAR2
			     ,x_period_type_code	  VARCHAR2 -- obsolete
			     ,x_calc_formula_id           NUMBER := NULL
			     ,x_calc_formula_id_old       NUMBER := NULL ) IS


  Cursor quota_rt_assigns_curs IS
  SELECT rate_schedule_id, calc_formula_id
    FROM cn_rt_quota_asgns_all
   WHERE quota_id        = x_quota_id ;

   l_rate_schedule_id NUMBER;
   l_calc_formula_id  NUMBER;


  BEGIN

     -- update the srp quota assigns.
     -- Payment type code is obsolete, still the below stmt works.
     -- Modified , removed to check the quota type and payment type
     UPDATE cn_srp_quota_assigns_all
       SET target = decode(customized_flag ,'N',x_target ,target)
           ,payment_amount  = decode(customized_flag,'N',x_payment_amount
					,payment_amount)
           ,performance_goal = Decode( customized_flag, 'N', x_performance_goal,
				    performance_goal)
       ,quota_type_code  	= x_quota_type_code
       WHERE quota_id   = x_quota_id
       ;

     IF SQL%FOUND THEN
	--    If the quota type has been changed from one that supports
	--    rate tables to one that does not
	-- OR the a different rate schedule has been assigned to the quota
	--    we delete all the srp tiers.

	IF
	  (( x_quota_type_code IN ('NONE' )
	     AND x_quota_type_code_old IN  ('EXTERNAL',
					    'FORMULA') )
	   OR (nvl(x_calc_formula_id_old,-99) <> nvl(x_calc_formula_id,-99))
	   ) THEN

             open quota_rt_assigns_curs;
             Loop
             fetch quota_rt_assigns_curs into l_rate_schedule_id, l_calc_formula_id;
             exit when quota_rt_assigns_curs%notfound;
	     cn_srp_rate_assigns_pkg.delete_record
	     (
	       x_srp_plan_assign_id   => null
	       ,x_srp_rate_assign_id  => null
	       ,x_quota_id	      => x_quota_id
	       ,x_rate_schedule_id    => l_rate_schedule_id
	       ,x_rate_tier_id	      => null);

             end loop;
             close quota_rt_assigns_curs;

	     -- If the rate schedule has changed we must insert the new tiers
	     -- Pass the Calc formula id, yet to be identified.

	     IF (   nvl(x_calc_formula_id_old,-99)
		  <> nvl(x_calc_formula_id   ,-99) ) THEN

             open quota_rt_assigns_curs;
             Loop
             fetch quota_rt_assigns_curs into l_rate_schedule_id, l_calc_formula_id;

             exit when quota_rt_assigns_curs%notfound;
	      cn_srp_rate_assigns_pkg.insert_record
		(
		  x_srp_plan_assign_id 	  => null
		  ,x_srp_quota_assign_id  => null
		  ,x_srp_rate_assign_id   => null
		  ,x_quota_id		  => x_quota_id
		  ,x_rate_schedule_id	  => l_rate_schedule_id
		  ,x_rate_tier_id	  => null
		  ,x_commission_rate 	  => null
		  ,x_commission_amount	  => null
		  ,x_disc_rate_table_flag => 'N' );

             end loop;
             close quota_rt_assigns_curs;
	   END IF;
	END IF;
     END IF;

  END Update_Srp_Quota;
  ----------------------------------------------------------------------------
  -- PROCEDURE  DELETE_RECORD
  ----------------------------------------------------------------------------
  --
  -- Procedure Name
  --  Delete_Row
  -- Purpose
  --   Delete quota assignment(s) from each rep assigned to the comp plan
  --
  -- Notes						   Passed Parameters
  --  o Called once for each deleted srp plan assignment.  x_srp_plan_assign_id

  --  o Called when a quota assignment is deleted from the x_srp_plan_assign_id
  --    source comp plans. Called once for each srp plan   x_quota_id
  --    assignment referencing the comp plan on the deleted
  --    assignment


  PROCEDURE delete_record
    ( x_srp_plan_assign_id  NUMBER
      ,x_quota_id	         NUMBER ) IS


   CURSOR srp_quota_curs IS
   Select srp_quota_assign_id
          , quota_id
     FROM CN_SRP_QUOTA_ASSIGNS_ALL
    WHERE srp_plan_assign_id = x_srp_plan_assign_id ;

   CURSOR srp_quota_curs_quota IS
   Select srp_quota_assign_id
          , quota_id
     FROM CN_SRP_QUOTA_ASSIGNS_ALL
    WHERE srp_plan_assign_id = x_srp_plan_assign_id
      AND quota_id = x_quota_id;

   recinfo  srp_quota_curs%ROWTYPE;

   CURSOR l_srp_rollover_quota_csr (c_srp_quota_assign_id cn_srp_quota_assigns.srp_quota_assign_id%TYPE) IS
      SELECT *
	FROM cn_srp_rollover_quotas_all
       WHERE srp_quota_assign_id = c_srp_quota_assign_id;

      l_srp_rollover_quota_c  l_srp_rollover_quota_csr%ROWTYPE;

  CURSOR get_payee_del_strdt_cur(p_srp_quota_assign_id NUMBER,
				 p_quota_id            NUMBER) IS
     SELECT srp_payee_assign_id
       FROM cn_srp_payee_assigns
       WHERE srp_quota_assign_id  = p_srp_quota_assign_id
       AND  quota_id             = p_quota_id  ;

  BEGIN

     --  o Called once for each deleted srp plan assignment.  x_srp_plan_assign_id
     IF x_srp_plan_assign_id IS NOT NULL AND x_quota_id IS NULL THEN
	-- Delete srp quota assigns

	open srp_quota_curs;
	Loop
           fetch srp_quota_curs into recinfo;
	   exit when srp_quota_curs%NOTFOUND;

	   -- clean out payee assignments
	   FOR p IN get_payee_del_strdt_cur
	     (recinfo.srp_quota_assign_id,
	      recinfo.quota_id) LOOP

	      cn_srp_payee_assigns_pkg.delete_record
		(p_srp_payee_assign_id => p.srp_payee_assign_id);
	   END LOOP;

	   -- Delete cn_srp_rollover_quotas records

	   FOR l_srp_rollover_quota_c  IN l_srp_rollover_quota_csr(recinfo.srp_quota_assign_id) LOOP
              CN_SRP_ROLLOVER_QUOTAS_PKG.DELETE_ROW
		(X_SRP_ROLLOVER_QUOTA_ID => l_srp_rollover_quota_c.srp_rollover_quota_id);
	   END LOOP;
	END LOOP;
	close srp_quota_curs;

	--   delete from cn_srp_quota_assigns
	--   where srp_plan_assign_id = x_srp_plan_assign_id ;

      ELSIF x_srp_plan_assign_id IS NOT NULL AND x_quota_id IS NOT NULL THEN

	   -- Deleting a source quota assignment from cn_quota_assigns
	   -- Delete srp Payee Assigns

           open srp_quota_curs_quota;
           Loop
	      fetch srp_quota_curs_quota into recinfo;
	      exit when srp_quota_curs_quota%NOTFOUND;

	      -- clean out payee assignments
	      FOR p IN get_payee_del_strdt_cur
		(recinfo.srp_quota_assign_id,
		 recinfo.quota_id) LOOP

		 cn_srp_payee_assigns_pkg.delete_record
		   (p_srp_payee_assign_id => p.srp_payee_assign_id);

	      END LOOP;

	      FOR l_srp_rollover_quota_c  IN l_srp_rollover_quota_csr(recinfo.srp_quota_assign_id) LOOP

		 CN_SRP_ROLLOVER_QUOTAS_PKG.DELETE_ROW
		   (X_SRP_ROLLOVER_QUOTA_ID => l_srp_rollover_quota_c.srp_rollover_quota_id);
	      END LOOP;

	   END LOOP;
           close srp_quota_curs_quota;

     END IF;

     IF x_srp_plan_assign_id IS NOT NULL THEN

	cn_srp_period_quotas_pkg.delete_record
	  (  x_srp_plan_assign_id    => x_srp_plan_assign_id
	    ,x_quota_id		    => x_quota_id
	    ,x_start_period_id 	    => null
	    ,x_end_period_id	    => null);

	-- delete srp quota rules
	cn_srp_quota_rules_pkg.delete_record
	  ( x_srp_plan_assign_id     => x_srp_plan_assign_id
	   ,x_srp_quota_assign_id   => null
	   ,x_quota_id		    => x_quota_id
	   ,x_quota_rule_id	    => null
	   ,x_revenue_class_id	    => null);

	-- delete srp rate assigns

	cn_srp_rate_assigns_pkg.delete_record
	  (  x_srp_plan_assign_id  => x_srp_plan_assign_id
	    ,x_srp_rate_assign_id => null
	    ,x_quota_id		  => x_quota_id
	    ,x_rate_schedule_id	  => null
	    ,x_rate_tier_id	  => null);
     END IF;

     DELETE FROM cn_srp_quota_assigns_all
       WHERE Srp_plan_assign_id  = x_srp_plan_assign_id
         AND quota_id 		    = nvl(x_quota_id, quota_id);
  END delete_record;

  END CN_SRP_Quota_Assigns_PKG;

/
