--------------------------------------------------------
--  DDL for Package Body GMS_ENC_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_ENC_COPY" AS
/* $Header: GMSTEXCB.pls 115.6 2002/11/26 12:33:17 mmalhotr ship $ */

  PROCEDURE  DUMMY  -- Dummy procedure to validate package.
  IS
  BEGIN
     NULL;
  END DUMMY;
/*
  This package is not used...

  	dummy                NUMBER;
  	org_id               NUMBER(15);
  	X_user               NUMBER(15);
  	X_module             VARCHAR2(30);
  	copy_mode            VARCHAR2(1);
  	outcome              VARCHAR2(30);
  	X_exp_class_code     VARCHAR2(2);

  	INVALID_EXPENDITURE  EXCEPTION;
  	INVALID_ITEM         EXCEPTION;

   	--* Bug# 728286
   	--* New exception defined to check whether the new Exp group (in reverseexpgroup proc.)
   	--* already exists in the system or not.

  	INVALID_EXP_GROUP    EXCEPTION;


  	function check_reverse_allowed ( net_zero_flag     varchar2,
                                         related_item      number,
                                         transferred_item  number ) return BOOLEAN  ;

  	PROCEDURE  ValidateEmp ( X_person_id  IN NUMBER
                               , X_date       IN DATE
                               , X_status     OUT NOCOPY VARCHAR2 )

  	IS

  	BEGIN

    		X_status := NULL;
    		org_id   := NULL;
    		dummy    := NULL;

    		org_id := pa_utils.GetEmpOrgId ( X_person_id, X_date );

    		IF ( org_id IS NULL ) THEN
      			X_status := 'PA_EX_NO_ORG_ASSGN';
      			RETURN;
    		END IF;

    		dummy := NULL;
    		dummy := pa_utils.GetEmpJobId ( X_person_id, X_date );

    		IF ( dummy IS NULL ) THEN
      			X_status := 'PA_EX_NO_ASSGN';
      			RETURN;
    		END IF;

  	END  ValidateEmp;

  	PROCEDURE  CopyItems ( X_orig_exp_id     IN NUMBER
                            ,  X_new_exp_id      IN NUMBER
                            ,  X_date            IN DATE
                            ,  X_person_id       IN NUMBER )

  	IS

       		temp_outcome         VARCHAR2(30) DEFAULT NULL;
       		temp_outcome_type    VARCHAR2(1) DEFAULT 'E';
       		temp_msg_application VARCHAR2(50) DEFAULT 'PA';
       		temp_msg_token1      VARCHAR2(240)  DEFAULT NULL;
       		temp_msg_token2      VARCHAR2(240)  DEFAULT NULL;
       		temp_msg_token3      VARCHAR2(240)  DEFAULT NULL;
       		temp_msg_count       NUMBER DEFAULT 1;
       		temp_status          NUMBER DEFAULT NULL;
       		i                    BINARY_INTEGER DEFAULT 0;

       		CURSOR  getEI  IS
         	SELECT
         	        gms_encumbrance_items_s.nextval encumbrance_item_id
         	,       X_new_exp_id   encumbrance_id
         	,       i.task_id
         	,       to_number( NULL ) raw_cost
         	,       to_number( NULL ) raw_cost_rate
         	,       decode( copy_mode, 'O',
         	          next_day((to_date(X_date)-7),
         	              to_char(i.encumbrance_item_date, 'DAY')),
         	                 X_date ) encumbrance_item_date
         	,       i.encumbrance_type
         	,       i.system_linkage_function
         	,       decode( copy_mode, 'S', NULL, i.amount ) amount
         	,       t.project_id
         	,       t.billable_flag
         	,       i.attribute_category
         	,       i.attribute1
         	,       i.attribute2
         	,       i.attribute3
         	,       i.attribute4
         	,       i.attribute5
         	,       i.attribute6
         	,       i.attribute7
         	,       i.attribute8
         	,       i.attribute9
         	,       i.attribute10
         	,       X_person_id  person_id
         	,       job_id
         	,       i.org_id
         	,       i.labor_cost_multiplier_name
         	,       i.receipt_currency_amount
         	,       i.receipt_currency_code
         	,       i.receipt_exchange_rate
         	,       i.denom_currency_code
         	,       i.denom_raw_cost
         	,       i.denom_burdened_cost
         	,       i.acct_currency_code
         	,       i.acct_rate_date
        	,       i.acct_rate_type
        	,       i.acct_exchange_rate
        	,       i.acct_raw_cost
        	,       i.acct_burdened_cost
        	,       i.acct_exchange_rounding_limit
        	,       i.project_currency_code
        	,       i.project_rate_type
        	,       i.project_rate_date
       		,       i.project_exchange_rate
           	FROM
                 	pa_tasks t
          	,       gms_encumbrance_items i
          	WHERE
                 	(    X_exp_class_code = 'OE'
                          OR i.system_linkage_function = 'ST' )
            	AND  i.task_id = t.task_id
            	AND  i.encumbrance_id = X_orig_exp_id
            	AND  i.adjusted_encumbrance_item_id IS NULL
            	AND  nvl(i.net_zero_adjustment_flag, 'N' ) <> 'Y'
            	AND  i.source_encumbrance_item_id IS NULL;


    		PROCEDURE CheckOutcome( X_outcome  IN OUT NOCOPY VARCHAR2,
                                        X_outcome_type IN VARCHAR2 DEFAULT 'E' )

    		IS

    		BEGIN

      			IF ( X_outcome IS NULL ) THEN
        			RETURN;
      			ELSE
        			IF ( X_outcome_type = 'W' ) THEN
           				RETURN;
        			ELSE
           				outcome := X_outcome;
           				gms_transactions.FlushEiTabs;

           				IF ( copy_mode = 'M' ) THEN
             					RAISE INVALID_EXPENDITURE;
           				ELSE
             					RAISE INVALID_ITEM;
           				END IF;
        			END IF;
      			END IF;

    		END CheckOutcome;

  	BEGIN

   		FOR  EI  IN  getEI  LOOP

      			i := i + 1;

      			IF ( X_exp_class_code <> 'PT' ) THEN
        			ValidateEmp ( EI.person_id
                                            , EI.encumbrance_item_date
                                            , temp_outcome );
                                CheckOutcome ( temp_outcome );
                        END IF;

      			IF ( NOT pa_utils.CheckExpTypeActive( EI.encumbrance_type
                                                            , EI.encumbrance_item_date ) ) THEN
        			temp_outcome := 'PA_TR_EXP_TYPE_INACTIVE';
        			CheckOutcome( temp_outcome );
      			END IF;

      			IF ( X_exp_class_code = 'OE' ) THEN
        			EI.raw_cost_rate := pa_utils.GetExpTypeCostRate( EI.encumbrance_type
                                                                               , EI.encumbrance_item_date );
                                EI.raw_cost := PA_CURRENCY.ROUND_CURRENCY_AMT( ( EI.quantity * EI.raw_cost_rate ) );
      			END IF;

      			pa_transactions_pub.validate_transaction( X_project_id                  => EI.project_id
            						       ,  X_task_id                     => EI.task_id
            					               ,  X_ei_date                     => EI.encumbrance_item_date
            					               ,  X_encumbrance_type            => EI.encumbrance_type
            					               ,  X_non_labor_resource          => NULL
            					               ,  X_person_id                   => X_person_id
            					               ,  X_quantity                    => EI.quantity
            					               ,  X_denom_currency_code         => EI.denom_currency_code
            					               ,  X_acct_currency_code          => EI.acct_currency_code
            					               ,  X_denom_raw_cost              => EI.denom_raw_cost
            					               ,  X_acct_raw_cost               => EI.acct_raw_cost
            					               ,  X_acct_rate_type              => EI.acct_rate_type
            					               ,  X_acct_rate_date              => EI.acct_rate_date
            					               ,  X_acct_exchange_rate          => EI.acct_exchange_rate
            					               ,  X_transfer_ei                 => NULL
            					               ,  X_incurred_by_org_id          => org_id
            					               ,  X_nl_resource_org_id          => NULL
            					               ,  X_transaction_source          => NULL
            					               ,  X_calling_module              => X_module
            					               ,  X_vendor_id                   => NULL
            					               ,  X_entered_by_user_id          => X_user
            					               ,  X_attribute_category          => EI.attribute_category
            					               ,  X_attribute1                  => EI.attribute1
            					               ,  X_attribute2                  => EI.attribute2
            					               ,  X_attribute3                  => EI.attribute3
            					               ,  X_attribute4                  => EI.attribute4
            					               ,  X_attribute5                  => EI.attribute5
            					               ,  X_attribute6                  => EI.attribute6
            					               ,  X_attribute7                  => EI.attribute7
            					               ,  X_attribute8                  => EI.attribute8
            					               ,  X_attribute9                  => EI.attribute9
            					               ,  X_attribute10                 => EI.attribute10
            					               ,  X_attribute11                 => NULL
            					               ,  X_attribute12                 => NULL
            					               ,  X_attribute13                 => NULL
            					               ,  X_attribute14                 => NULL
            					               ,  X_attribute15                 => NULL
            					               ,  X_msg_application             => temp_msg_application
            					               ,  X_msg_type                    => temp_outcome_type
            					               ,  X_msg_token1                  => temp_msg_token1
            					               ,  X_msg_token2                  => temp_msg_token2
            					               ,  X_msg_token3                  => temp_msg_token3
            					               ,  X_msg_count                   => temp_msg_count
            					               ,  X_msg_data                    => temp_outcome
            					               ,  X_billable_flag               => EI.billable_flag);

      			CheckOutcome( temp_outcome ,temp_outcome_type);

               -- NO IC Changes, Copy just creates new EI from existing EI's
               -- So they should be treated as New txns.  For any new EI created
               -- through form we do not derive the ic attributes.  Following
               -- the same approach here, loadei will insert the defaults for
               -- all IC columns.

      			gms_transactions.LoadEi( X_encumbrance_item_id     =>	EI.encumbrance_item_id
                                               ,X_encumbrance_id          =>	EI.encumbrance_id
                                               ,X_encumbrance_item_date   =>	EI.encumbrance_item_date
                                               ,X_project_id              =>	NULL
                                               ,X_task_id                 =>	EI.task_id
                                               ,X_encumbrance_type        =>	EI.encumbrance_type
                                               ,X_non_labor_resource      =>	NULL
                                               ,X_nl_resource_org_id      =>	NULL
                                               ,X_quantity                =>	EI.quantity
                                               ,X_raw_cost                =>	NULL
                                               ,X_raw_cost_rate           =>	NULL
                                               ,X_override_to_org_id      =>	NULL
                                               ,X_billable_flag           =>	EI.billable_flag
                                               ,X_bill_hold_flag          =>	'N'
                                               ,X_orig_transaction_ref    =>	NULL
                                               ,X_transferred_from_ei     =>	NULL
                                               ,X_adj_expend_item_id      =>	NULL
                                               ,X_attribute_category      =>	EI.attribute_category
                                               ,X_attribute1              =>	EI.attribute1
                                               ,X_attribute2              =>	EI.attribute2
                                               ,X_attribute3              =>	EI.attribute3
                                               ,X_attribute4              =>	EI.attribute4
                                               ,X_attribute5              =>	EI.attribute5
                                               ,X_attribute6              =>	EI.attribute6
                                               ,X_attribute7              =>	EI.attribute7
                                               ,X_attribute8              =>	EI.attribute8
                                               ,X_attribute9              =>	EI.attribute9
                                               ,X_attribute10             =>	EI.attribute10
                                               ,X_ei_comment              =>	NULL
                                               ,X_transaction_source      =>	NULL
                                               ,X_source_exp_item_id      =>	NULL
                                               ,i                         =>	i
                                               ,X_job_id                  =>	EI.job_id
                                               ,X_org_id                  =>	EI.org_id
                                               ,X_labor_cost_multiplier_name =>	EI.labor_cost_multiplier_name
                                               ,X_drccid                  =>	NULL
                                               ,X_crccid                  =>	NULL
                                               ,X_cdlsr1                  =>	NULL
                                               ,X_cdlsr2                  =>	NULL
                                               ,X_cdlsr3                  =>	NULL
                                               ,X_gldate                  =>	NULL
                                               ,X_bcost                   =>	NULL
                                               ,X_bcostrate               =>	NULL
                                               ,X_etypeclass              =>	EI.system_linkage_function
                                               ,X_burden_sum_dest_run_id  =>	NULL
                                               ,X_burden_compile_set_id   =>	NULL
                                               ,X_receipt_currency_amount =>    NULL
                                               ,X_receipt_currency_code   =>	EI.receipt_currency_code
                                               ,X_receipt_exchange_rate   =>	EI.receipt_exchange_rate
                                               ,X_denom_currency_code     =>	EI.denom_currency_code
                                               ,X_denom_raw_cost          =>    NULL
                                               ,X_denom_burdened_cost     =>    NULL
                                               ,X_acct_currency_code      =>	EI.acct_currency_code
                                               ,X_acct_rate_date          =>	EI.acct_rate_date
                                               ,X_acct_rate_type          =>	EI.acct_rate_type
                                               ,X_acct_exchange_rate      =>	EI.acct_exchange_rate
                                               ,X_acct_raw_cost           =>    NULL
                                               ,X_acct_burdened_cost      =>    NULL
                                               ,X_acct_exchange_rounding_limit =>EI.acct_exchange_rounding_limit
                                               ,X_project_currency_code   =>	EI.project_currency_code
                                               ,X_project_rate_date       =>	EI.project_rate_date
                                               ,X_project_rate_type       =>	EI.project_rate_type
                                               ,X_project_exchange_rate   =>	EI.project_exchange_rate);
    		END LOOP;
    		gms_transactions.InsItems( X_user              =>	X_user
                            		, X_login             =>	NULL
                            		, X_module            =>	X_module
                            		, X_calling_process   =>	'EXPEND_COPY'
                            		, Rows                =>	i
                            		, X_status            => 	temp_status
                            		, X_gl_flag           =>	NULL  );

    		pa_adjustments.CheckStatus( status_indicator => temp_status );

  	END  CopyItems;

	PROCEDURE preapproved ( copy_option             IN VARCHAR2
    			     ,  copy_items              IN VARCHAR2
    			     ,  orig_exp_group          IN VARCHAR2
    			     ,  new_exp_group           IN VARCHAR2
    			     ,  orig_exp_id             IN NUMBER
    			     ,  exp_ending_date         IN DATE
    			     ,  new_inc_by_person       IN NUMBER
    			     ,  userid                  IN NUMBER
    			     ,  procedure_num_copied    IN OUT NOCOPY NUMBER
    			     ,  procedure_num_rejected  IN OUT NOCOPY NUMBER
    			     ,  procedure_return_code   IN OUT NOCOPY VARCHAR2 )

  	IS
       		num_copied              NUMBER := 0;
       		num_rejected            NUMBER := 0;

       		CURSOR  getEXP  IS
         	SELECT
         	        encumbrance_id  orig_exp_id
         	,       gms_encumbrances_s.nextval  new_exp_id
         	,       description
                ,       nvl( new_inc_by_person, incurred_by_person_id ) person_id
         	,       decode( copy_mode, 'S', NULL,
         	                decode( copy_items, 'Y', control_total_amount, NULL ))
         	             control_total_amount
         	,       attribute_category
         	,       attribute1
         	,       attribute2
         	,       attribute3
         	,       attribute4
         	,       attribute5
         	,       attribute6
         	,       attribute7
         	,       attribute8
         	,       attribute9
         	,       attribute10
	 	,       denom_currency_code
	 	,       acct_currency_code
	 	,       acct_rate_type
	 	,       acct_rate_date
	 	,       acct_exchange_rate
          	FROM
                 	gms_encumbrances
         	WHERE
                 	encumbrance_group = orig_exp_group
           	AND     encumbrance_id = nvl( orig_exp_id, encumbrance_id );

		EXP			getEXP%ROWTYPE;

  	BEGIN

    		copy_mode := copy_option;
    		X_user    := userid;
    		X_exp_class_code := 'PT';
    		X_module := 'PAXEXCOP/PAXTEXCB';

    		IF ( orig_exp_group = new_exp_group ) THEN
      			outcome := 'PA_EX_SAME_EX';
      			RAISE INVALID_ITEM;
    			END IF;

    			OPEN  getEXP;

      			LOOP
        			FETCH  getEXP  INTO  EXP;

        			IF ( getEXP%ROWCOUNT = 0 ) THEN
          				outcome := 'PA_EX_NO_EX';
          				RAISE INVALID_ITEM;
        			END IF;

        			EXIT WHEN getEXP%NOTFOUND;

        			BEGIN
          				ValidateEmp (  EXP.person_id
                                       		     , exp_ending_date
                                       		     , outcome );

          				IF ( outcome IS NOT NULL ) THEN
            					IF ( copy_mode = 'M' ) THEN
              						RAISE INVALID_EXPENDITURE;
            					ELSE
              						RAISE INVALID_ITEM;
            					END IF;
          				END IF;

          				IF ( copy_items = 'Y' ) THEN
            					CopyItems ( EXP.orig_exp_id
                      					  , EXP.new_exp_id
                      					  , exp_ending_date
                      					  , EXP.person_id );
          				END IF;

          				gms_transactions.InsertExp(
                           X_encumbrance_id    => EXP.new_exp_id,
                           X_expend_status     => 'SUBMITTED',
                           X_expend_ending     => exp_ending_date,
                           X_expend_class      => 'PT',
                           X_inc_by_person     => EXP.person_id,
                           X_inc_by_org        => org_id,
                           X_expend_group      => new_exp_group,
                           X_entered_by_id     => X_user,
                           X_created_by_id     => X_user,
                           X_attribute_category=> EXP.attribute_category,
                           X_attribute1        => EXP.attribute1,
                           X_attribute2        => EXP.attribute2,
                           X_attribute3        => EXP.attribute3,
                           X_attribute4        => EXP.attribute4,
                           X_attribute5        => EXP.attribute5,
                           X_attribute6        => EXP.attribute6,
                           X_attribute7        => EXP.attribute7,
                           X_attribute8        => EXP.attribute8,
                           X_attribute9        => EXP.attribute9,
                           X_attribute10       => EXP.attribute10,
                           X_description       => EXP.description,
                           X_control_total     => EXP.control_total_amount,
                           X_denom_currency_code => EXP.denom_currency_code,
	                        X_acct_currency_code => EXP.acct_currency_code,
	                        X_acct_rate_type    => EXP.acct_rate_type,
	                        X_acct_rate_date    => EXP.acct_rate_date,
	                        X_acct_exchange_rate=> EXP.acct_exchange_rate);

           				num_copied := num_copied + 1;

      					--  Copies the attachments for the original encumbrance
      					--  to the newly created encumbrance

      					fnd_attached_documents2_pkg.copy_attachments('PA_EXPENDITURES',
                                       	                                             EXP.orig_exp_id,
                                                                                     null,
                                                                                     null,
                                                                                     null,
                                                                                     null,
                                                                                     'PA_EXPENDITURES',
                                                                                     EXP.new_exp_id,
                                                                                     null,
                                                                                     null,
                                                                                     null,
                                                                                     null,
                                                                                     FND_GLOBAL.USER_ID,
                                                                                     FND_GLOBAL.LOGIN_ID,
                                                                                     null,
									             null,
									             null);

				EXCEPTION
          				WHEN INVALID_EXPENDITURE THEN
            					num_rejected := num_rejected + 1;
					WHEN INVALID_ITEM THEN
						num_rejected := num_rejected + 1;
					WHEN OTHERS THEN
						RAISE;

        			END;

      			END LOOP;

    			CLOSE  getEXP;

    			procedure_return_code  := 'PA_EX_COPY_OUTCOME';
    			procedure_num_copied   := num_copied;
    			procedure_num_rejected := num_rejected;

  	EXCEPTION
    		WHEN OTHERS THEN
      			RAISE;

  	END  preapproved;

  	PROCEDURE online ( orig_exp_id            IN NUMBER
                        ,  new_exp_id             IN NUMBER
                        ,  exp_ending_date        IN DATE
                        ,  X_inc_by_person        IN NUMBER
                        ,  userid                 IN NUMBER
                        ,  procedure_return_code  IN OUT NOCOPY VARCHAR2 )

        IS

  	BEGIN

    		copy_mode := 'O';
    		X_user    := userid;

    		SELECT
            		e.encumbrance_class_code
      		INTO
            		X_exp_class_code
      		FROM
            		gms_encumbrances e
     		WHERE
            		e.encumbrance_id = orig_exp_id;

     		IF ( X_exp_class_code = 'OT' ) THEN
       			X_module := 'PAXEXEER/PAXTEXCB';
     		ELSIF ( X_exp_class_code = 'OE' ) THEN
       			X_module := 'PAXEXTCE/PAXTEXCB';
     		END IF;

    		CopyItems ( orig_exp_id
                          , new_exp_id
                          , exp_ending_date
                          , X_inc_by_person );

  	EXCEPTION
    		WHEN INVALID_ITEM THEN
      			procedure_return_code := outcome;

  	END  online;

	    --Bug#: 728286
	    --New parameter added: X_expgrp_status (status of the exp group to be created)
	    --All the program/function calls are changed to named parameter method.


  	PROCEDURE ReverseExpGroup( X_orig_exp_group          IN VARCHAR2
                                ,  X_new_exp_group           IN VARCHAR2
                          ,  X_user_id                 IN NUMBER
                          ,  X_module                  IN VARCHAR2
                          ,  X_num_reversed            IN OUT NOCOPY NUMBER
                          ,  X_num_rejected            IN OUT NOCOPY NUMBER
                          ,  X_return_code             IN OUT NOCOPY VARCHAR2
                          ,  X_expgrp_status           IN VARCHAR2 DEFAULT 'WORKING' )
	IS

     		InsertExp       BOOLEAN := TRUE  ;
     		InsertBatch     BOOLEAN := FALSE ;
     		no_of_items     number := 0 ;
     		num_reversed    number := 0 ;
     		num_rejected    number := 0 ;
     		exp_status      varchar2(20);

     		CURSOR RevExp is
         	SELECT
                 	e.encumbrance_id  orig_exp_id
         	,       gms_encumbrances_s.nextval  new_exp_id
         	,       e.encumbrance_ending_date
         	,       e.description
         	,       e.incurred_by_person_id  person_id
         	,       e.incurred_by_organization_id inc_by_org_id
         	,       e.encumbrance_class_code
         	,       e.control_total_amount
         	,       e.attribute_category
         	,       e.attribute1
         	,       e.attribute2
         	,       e.attribute3
         	,       e.attribute4
         	,       e.attribute5
         	,       e.attribute6
         	,       e.attribute7
         	,       e.attribute8
         	,       e.attribute9
         	,       e.attribute10
         	,       e.denom_currency_code
         	,       e.acct_currency_code
         	,       e.acct_rate_type
         	,       e.acct_rate_date
         	,       e.acct_exchange_rate
          	FROM
                 	gms_encumbrances e
         	WHERE
			e.encumbrance_group = X_orig_exp_group ;

     		cursor RevExpItems(expend_id NUMBER ) is
        	select
			ei.encumbrance_item_id
                , 	ei.net_zero_adjustment_flag
                , 	ei.source_encumbrance_item_id
                , 	ei.transferred_from_exp_item_id
          	from
			gms_encumbrance_items_all ei
         	where
			encumbrance_id = expend_id ;

      		cursor ReverseGroup is
        	select
			encumbrance_group
                , 	encumbrance_ending_date
                , 	system_linkage_function
                , 	control_count
                , 	control_total_amount
                , 	request_id
                , 	program_id
                , 	program_application_id
                , 	transaction_source
          	from
			gms_encumbrance_groups
         	where
			encumbrance_group = X_orig_exp_group ;

     		Exp             RevExp%rowtype ;
     		ExpEi           RevExpItems%rowtype ;
     		ExpGroup        ReverseGroup%rowtype ;
     		outcome         VARCHAR2(100);
     		Dummy           NUMBER;

	BEGIN

		--Bug#: 728286
		--Check: The new Exp Group already exists in the system or not.
		--Note: This check is not required when it's called from the Form PAXTREPE because
		--this validation is already done there.


		IF X_module <> 'PAXTREPE' THEN
			BEGIN
				SELECT 1
				INTO   Dummy
      				FROM   gms_encumbrance_groups
      				WHERE  encumbrance_group = X_new_exp_group;

      				outcome := 'PA_TR_EPE_GROUP_NOT_UNIQ';
      				RAISE INVALID_EXP_GROUP;

     			EXCEPTION
      				WHEN NO_DATA_FOUND THEN
					NULL;
     			END;
    		END IF;


      		OPEN RevExp ;

      		LOOP

         		FETCH RevExp into  Exp ;

         		IF ( RevExp%ROWCOUNT = 0 ) THEN
             			outcome := 'PA_EX_NO_EX';
             			RAISE INVALID_ITEM;
         		END IF;

         		EXIT WHEN RevExp%NOTFOUND;

         		InsertExp  := TRUE ;
         		no_of_items := 0 ;

         		OPEN RevExpItems(Exp.orig_exp_id) ;
         		LOOP
             			Fetch RevExpItems into  ExpEi ;

             			If ( RevExpItems%ROWCOUNT = 0 ) THEN
                			InsertExp := FALSE ;
                			EXIT ;
             			END IF;
             			EXIT WHEN RevExpItems%NOTFOUND;

             			if not check_reverse_allowed( net_zero_flag    => ExpEi.net_zero_adjustment_flag,
                                           		      related_item     => ExpEi.source_encumbrance_item_id,
                                           		      transferred_item => ExpEi.transferred_from_exp_item_id) then
                			num_rejected := num_rejected + 1 ;
             			else

                			pa_adjustments.BackOutItem( X_exp_item_id    => ExpEi.encumbrance_item_id,
                        					    X_encumbrance_id => Exp.new_exp_id,
                        					    X_adj_activity   => 'REVERSE BATCH',
                        					    X_module         => 'PAXTREPE',
                        					    X_user           => x_user_id,
                        					    X_login          => x_user_id,
                        					    X_status         => outcome );

                			pa_adjustments.ReverseRelatedItems( X_source_exp_item_id => ExpEi.encumbrance_item_id,
                       							    X_encumbrance_id     => NULL,
                       							    X_module             => 'PAXTREPE',
                       							    X_user               => x_user_id,
                       							    X_login              => x_user_id,
                       							    X_status             => outcome );

                			IF outcome <> 0  then
                   				num_rejected := num_rejected + 1 ;
                   				RAISE INVALID_ITEM ;
                			END IF;
                			no_of_items := no_of_items + 1 ;
                			num_reversed := num_reversed + 1 ;

              			end if;
         		END LOOP ;

         		CLOSE RevExpItems ;
         		If ( InsertExp ) and (no_of_items > 0) then

               			IF  X_expgrp_status = 'WORKING' THEN
                 			exp_status := 'SUBMITTED';
               			ELSE
                 			exp_status := 'APPROVED';
               			END IF;

               			gms_transactions.InsertExp( X_encumbrance_id      =>   Exp.new_exp_id,
                  					   X_expend_status       =>   exp_status,
                  					   X_expend_ending       =>   Exp.encumbrance_ending_date ,
                  					   X_expend_class        =>   Exp.encumbrance_class_code ,
                  					   X_inc_by_person       =>   Exp.person_id ,
                  					   X_inc_by_org          =>   Exp.inc_by_org_id ,
                  					   X_expend_group        =>   X_new_exp_group ,
                  					   X_entered_by_id       =>   X_user_id ,
                  					   X_created_by_id       =>   X_user_id ,
                  					   X_attribute_category  =>   Exp.attribute_category ,
                  					   X_attribute1          =>   Exp.attribute1  ,
                  					   X_attribute2          =>   Exp.attribute2  ,
                  					   X_attribute3          =>   Exp.attribute3  ,
                  					   X_attribute4          =>   Exp.attribute4  ,
                  					   X_attribute5          =>   Exp.attribute5  ,
                  					   X_attribute6          =>   Exp.attribute6  ,
                  					   X_attribute7          =>   Exp.attribute7  ,
                  					   X_attribute8          =>   Exp.attribute8  ,
                  					   X_attribute9          =>   Exp.attribute9  ,
                  					   X_attribute10         =>   Exp.attribute10 ,
                  					   X_description         =>   Exp.description ,
                  					   X_control_total       =>   Exp.control_total_amount,
                  					   X_denom_currency_code =>   Exp.denom_currency_code ,
	               					   X_acct_currency_code  =>   Exp.acct_currency_code ,
	               					   X_acct_rate_type      =>   Exp.acct_rate_type ,
	               					   X_acct_rate_date      =>   Exp.acct_rate_date ,
	               					   X_acct_exchange_rate  =>   Exp.acct_exchange_rate);

              			--  Copies the attachments for the original encumbrance
              			--  to the newly created encumbrance

               			fnd_attached_documents2_pkg.copy_attachments( X_from_entity_name        =>  'PA_EXPENDITURES',
                 							      X_from_pk1_value          =>  Exp.orig_exp_id,
                 							      X_from_pk2_value          =>  null,
                 							      X_from_pk3_value          =>  null,
                 							      X_from_pk4_value          =>  null,
                 							      X_from_pk5_value          =>  null,
                 							      X_to_entity_name          =>  'PA_EXPENDITURES',
                 							      X_to_pk1_value            =>  Exp.new_exp_id,
                 							      X_to_pk2_value            =>  null,
                 							      X_to_pk3_value            =>  null,
                 							      X_to_pk4_value            =>  null,
                 							      X_to_pk5_value            =>  null,
                 							      X_created_by              =>  FND_GLOBAL.USER_ID,
                 							      X_last_update_login       =>  FND_GLOBAL.LOGIN_ID,
                 							      X_program_application_id  =>  null,
                 							      X_program_id              =>  null,
                 							      X_request_id              =>  null);

          			InsertBatch := TRUE ;

          		End if ;

      		END LOOP ;

      		CLOSE RevExp ;

      		if ((InsertBatch ) AND (X_module <> 'PAXTREPE'))  then
          		OPEN ReverseGroup ;
          		FETCH ReverseGroup into ExpGroup ;
          		if ReverseGroup%notfound then
             			return ;
          		end if;


        	 	--Bug#: 728286
          	 	--The supplied exp_group name is used to create the new Expenditure Group.
      	         	--The status is set as supplied by the calling program (thru param x_expgrp_status)

         		gms_transactions.InsertExpGroup( X_encumbrance_group     =>   X_new_exp_group ,
               				        	X_exp_group_status_code =>   X_expgrp_status ,
               				        	X_ending_date           =>   ExpGroup.encumbrance_ending_date ,
               				        	X_system_linkage        =>   ExpGroup.system_linkage_function ,
               				        	X_created_by            =>   X_user_id ,
               				        	X_transaction_source    =>   ExpGroup.transaction_source );
      		end if;

      		if num_reversed <= 0 then
         		outcome := 'PA_NO_ITEMS_FOR_REVERSAL' ;
           		null ;
      		end if;

      		X_num_reversed := num_reversed ;
      		X_num_rejected := num_rejected ;
      		X_return_code  := outcome ;

	EXCEPTION
    		WHEN INVALID_ITEM THEN
      			X_return_code := outcome;

       		--Bug#: 728286
       		--Error handling

    		WHEN  INVALID_EXP_GROUP THEN
      			X_return_code := outcome;
    		WHEN OTHERS THEN
      			RAISE ;

  	End ReverseExpGroup ;

	FUNCTION check_reverse_allowed ( net_zero_flag     varchar2,
                                         related_item      number,
                                         transferred_item  number ) return BOOLEAN
	IS

	BEGIN

    		if nvl(net_zero_flag, 'N') = 'Y' then
       			return FALSE ;
    		elsif related_item is not null then
       			return FALSE ;
    		elsif transferred_item is not null then
       			return FALSE ;
    		end if;

    		return TRUE ;

	END check_reverse_allowed ;
*/

END GMS_ENC_COPY;

/
