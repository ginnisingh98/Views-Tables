--------------------------------------------------------
--  DDL for Package Body GMS_ENC_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_ENC_ADJUSTMENTS" AS
/* $Header: gmsencab.pls 120.5 2007/03/13 13:14:02 srachako ship $ */


  	dummy                NUMBER;
  	org_id               NUMBER(15);
  	X_user               NUMBER(15);
  	X_module             VARCHAR2(30);
  	copy_mode            VARCHAR2(1);
  	outcome              VARCHAR2(30);
  	X_enc_class_code     VARCHAR2(2);

       INVALID_EXPENDITURE  EXCEPTION;
       INVALID_ITEM         EXCEPTION;
       SUBROUTINE_ERROR  EXCEPTION;
       INVALID_EXP_GROUP    EXCEPTION;


	 function  check_reverse_allowed ( net_zero_flag     varchar2,
                                         related_item      number,
                                         transferred_item  number ) return BOOLEAN  ;




-- ========================================================================
-- PROCEDURE  SetNetZero
-- ========================================================================

  PROCEDURE  SetNetZero( X_enc_item_id   IN NUMBER
                       , X_user          IN NUMBER
                       , X_login         IN NUMBER
                       , X_status        OUT NOCOPY NUMBER )
  IS
    BEGIN
      UPDATE gms_encumbrance_items_all ei
         SET
              ei.net_zero_adjustment_flag = 'Y'
      ,       ei.last_update_date         = sysdate
      ,       ei.last_updated_by          = X_user
      ,       ei.last_update_login        = X_login
       WHERE
              ei.encumbrance_item_id = X_enc_item_id;

      X_status := 0;

    EXCEPTION
      WHEN  OTHERS  THEN
        X_status := SQLCODE;
        RAISE;

  END  SetNetZero;


-- ========================================================================
-- PROCEDURE CheckStatus
-- ========================================================================

  PROCEDURE CheckStatus( status_indicator IN OUT NOCOPY NUMBER )
  IS
  BEGIN

    IF ( status_indicator <> 0 ) THEN
      RAISE SUBROUTINE_ERROR;
    ELSIF ( status_indicator = 0 ) THEN
      status_indicator := NULL;
    END IF;

  END CheckStatus;


-- =======================================================================
-- PROCEDURE BackoutItem
-- ========================================================================

  PROCEDURE  BackoutItem( X_enc_item_id      IN NUMBER
                        , X_encumbrance_id   IN NUMBER
                        , X_adj_activity     IN VARCHAR2
                        , X_module           IN VARCHAR2
                        , X_user             IN NUMBER
                        , X_login            IN NUMBER
                        , X_status           OUT NOCOPY NUMBER )
  IS
    X_backout_id     NUMBER(15);
    temp_status      NUMBER DEFAULT NULL;

  BEGIN
   select gms_encumbrance_items_s.nextval
   into X_backout_id
   from SYS.dual ;
--    X_backout_id := pa_utils.GetNextEiId;

    INSERT INTO gms_encumbrance_items_all(
          encumbrance_item_id
       ,  task_id
       ,  project_id --Bug 5726575
       ,  encumbrance_type
       ,  system_linkage_function
       ,  encumbrance_item_date
       ,  encumbrance_id
       ,  override_to_organization_id
       ,  last_update_date
       ,  last_updated_by
       ,  creation_date
       ,  created_by
       ,  last_update_login
       ,  amount
       ,  enc_distributed_flag
       ,  adjusted_encumbrance_item_id
       ,  net_zero_adjustment_flag
       ,  attribute_category
       ,  attribute1
       ,  attribute2
       ,  attribute3
       ,  attribute4
       ,  attribute5
       ,  attribute6
       ,  attribute7
       ,  attribute8
       ,  attribute9
       ,  attribute10
       ,  transferred_from_enc_item_id
       ,  transaction_source
       ,  orig_transaction_reference
       ,  source_encumbrance_item_id
       ,  job_id
       ,  org_id
       , denom_currency_code
       , denom_raw_amount
       , acct_currency_code
       , acct_rate_date
       , acct_rate_type
       , acct_exchange_rate
       , acct_raw_cost
       , acct_exchange_rounding_limit
       , project_currency_code
       , project_rate_date
       , project_rate_type
       , project_exchange_rate
       , denom_tp_currency_code
       , denom_transfer_price
       , encumbrance_comment ) /* Added for Bug:5879427 */

    SELECT
          X_backout_id                     -- encumbrance_item_id
       ,  ei.task_id                       -- task_id
       ,  ei.project_id                    -- project_id Bug 5726575
       ,  ei.encumbrance_type              -- encumbrance_type
       ,  ei.system_linkage_function       -- system_linkage_function
       ,  ei.encumbrance_item_date         -- encumbrance_item_date
       ,  nvl( X_encumbrance_id,
                ei.encumbrance_id )        -- encumbrance_id
       ,  ei.override_to_organization_id   -- override enc organization
       ,  sysdate                          -- last_update_date
       ,  X_user                           -- last_updated_by
       ,  sysdate                          -- creation_date
       ,  X_user                           -- created_by
       ,  X_login                          -- last_update_login
       ,  (0 - ei.amount)                  -- quantity
       ,  'N'                              -- enc_distributed_flag
       ,  ei.encumbrance_item_id           -- adjusted_encumbrance_item_id
       ,  'Y'                              -- net_zero_adjustment_flag
       ,  ei.attribute_category            -- attribute_category
       ,  ei.attribute1                    -- attribute1
       ,  ei.attribute2                    -- attribute2
       ,  ei.attribute3                    -- attribute3
       ,  ei.attribute4                    -- attribute4
       ,  ei.attribute5                    -- attribute5
       ,  ei.attribute6                    -- attribute6
       ,  ei.attribute7                    -- attribute7
       ,  ei.attribute8                    -- attribute8
       ,  ei.attribute9                    -- attribute9
       ,  ei.attribute10                   -- attribute10
       ,  ei.transferred_from_enc_item_id  -- tfr from enc item id
       ,  ei.transaction_source            -- transaction_source
       ,  decode(ei.transaction_source,'PTE TIME',NULL,
          decode(ei.transaction_source,'PTE EXPENSE',NULL,
                   ei.orig_transaction_reference)) -- orig_transaction_reference
       ,  ei.source_encumbrance_item_id    -- source_encumbrance_item_id
       ,  ei.job_id                        -- job_id
       ,  ei.org_id                        -- org_id
       ,  ei.denom_currency_code           -- denom_currency_code
       ,  (0 - ei.denom_raw_amount)          -- denom_raw_amount
       ,  ei.acct_currency_code            -- acct_currency_code
       ,  ei.acct_rate_date                -- acct_rate_date
       ,  ei.acct_rate_type                -- acct_rate_type
       ,  ei.acct_exchange_rate            -- acct_exchange_rate
       ,  (0 - ei.acct_raw_cost)           -- acct_raw_cost
       ,  ei.acct_exchange_rounding_limit  -- acct_exchange_rounding_limit
       ,  ei.project_currency_code         -- project_currency_code
       ,  ei.project_rate_date             -- project_rate_date
       ,  ei.project_rate_type             -- project_rate_type
       ,  ei.project_exchange_rate         -- project_exchange_rate
       ,  ei.denom_tp_currency_code        -- denom_tp_currency_code
       ,  (0 - ei.denom_transfer_price)    -- denom_transfer_price
       ,  ei.encumbrance_comment           -- encumbrance_comment
      FROM
            gms_encumbrance_items_all ei

     WHERE
            ei.encumbrance_item_id = X_enc_item_id ;
    /*
      Project Summarization changes:
      Store the backout_id in the global variable
     */
    gms_enc_adjustments.BackOutId := X_backout_id;

    SetNetZero( X_enc_item_id
              , X_user
              , X_login
              , temp_status );
    CheckStatus( temp_status );

  X_status := 0;

  EXCEPTION
    WHEN  OTHERS  THEN
      X_status := SQLCODE;
      RAISE;

  END  BackoutItem;

-- =================================================================================================
--
-- =================================================================================================

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

-- ================================================================================================
--
-- ================================================================================================

  	PROCEDURE  CopyItems ( X_orig_enc_id     IN NUMBER
                            ,  X_new_enc_id      IN NUMBER
                            ,  X_date            IN DATE
                            ,  X_person_id       IN NUMBER )

  	IS

       		temp_outcome         VARCHAR2(30) DEFAULT NULL;
       		temp_outcome_type    VARCHAR2(1) DEFAULT 'E';
       		temp_msg_application VARCHAR2(50) DEFAULT 'GMS';
       		temp_msg_token1      VARCHAR2(240)  DEFAULT NULL;
       		temp_msg_token2      VARCHAR2(240)  DEFAULT NULL;
       		temp_msg_token3      VARCHAR2(240)  DEFAULT NULL;
       		temp_msg_count       NUMBER DEFAULT 1;
       		temp_status          NUMBER DEFAULT NULL;
       		i                    BINARY_INTEGER DEFAULT 0;
                P_Award_Id           NUMBER ;
                P_OUTCOME            VARCHAR2(1000);

       		CURSOR  getEI  IS
-- verified the columns with latest table order
         		SELECT gms_encumbrance_items_s.nextval encumbrance_item_id,
                                    i.last_update_date,
                                    i.last_updated_by,
                                    i.creation_date,
                                    i.created_by,
                                    X_new_enc_id  encumbrance_id ,
                                    i.task_id,
          			    decode( copy_mode, 'O',
		                          --next_day((to_date(X_date)-7), --For bug 3066504
		                          next_day((trunc(X_date)-7), --For bug 3066504
               		                    to_char(i.encumbrance_item_date, 'DAY')),
                            		     X_date ) encumbrance_item_date,
                                    i.encumbrance_type,
                                    i.enc_distributed_flag,
                                    i.override_to_organization_id,
                                    i.adjusted_encumbrance_item_id,
                                    i.net_zero_adjustment_flag,
                                    i.transferred_from_enc_item_id,
                                    i.last_update_login,
                                    i.request_id,
                                    i.attribute_category,
                                    i.attribute1,
                                    i.attribute2,
                                    i.attribute3,
                                    i.attribute4,
                                    i.attribute5,
                                    i.attribute6,
                                    i.attribute7,
                                    i.attribute8,
                                    i.attribute9,
                                    i.attribute10,
                                    i.orig_transaction_reference,
                                    i.transaction_source,
                                    t.project_id,
                                    i.source_encumbrance_item_id,
                                    i.job_id,
				    i.org_id,
                                    i.system_linkage_function,
 		       		    i.denom_currency_code,
                                    i.denom_raw_amount,
   		       		    i.acct_currency_code,
 		       		    i.acct_rate_date,
				    i.acct_rate_type,
 		       		    i.acct_exchange_rate,
                                    i.acct_raw_cost,
                                    i.acct_exchange_rounding_limit,
 		       		    i.project_currency_code,
 	       	       		    i.project_rate_date,
 		       		    i.project_rate_type,
 		       		    i.project_exchange_rate,
                                    i.denom_tp_currency_code,
                                    i.denom_transfer_price,
 				    decode( copy_mode, 'S', NULL, i.amount ) amount,
                                    NULL ,   -- Fix for Bugno : 1348099
                                    X_person_id  person_id,
                                    i.incurred_by_person_id,
                                    i.ind_compiled_set_id,
				    i.pa_date,
			            i.gl_date,
				    i.line_num,
				    i.burden_sum_dest_run_id,
				    i.burden_sum_source_run_id,
				    t.billable_flag

           		FROM
                 	pa_tasks t
          	       ,gms_encumbrance_items i
			WHERE
                 	(X_enc_class_code = 'ER'
                          OR i.system_linkage_function = 'ST' )
            	AND  i.task_id = t.task_id
            	AND  i.encumbrance_id = X_orig_enc_id
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
           		--		gms_transactions.FlushEiTabs;

           				IF ( copy_mode = 'M' ) THEN
             					RAISE INVALID_EXPENDITURE;
           				ELSE
             				--	RAISE INVALID_ITEM;
                                        NULL ;
           				END IF;
        			END IF;
      			END IF;

    		END CheckOutcome;

  	BEGIN

   		FOR  EI  IN  getEI  LOOP

             Begin
                select award_id into P_Award_Id
		from gms_award_distributions adl ,gms_encumbrance_items ei,gms_encumbrances es
                where  adl.expenditure_item_id = ei.encumbrance_item_id
                 and   ei.encumbrance_id = es.encumbrance_id
                 and   es.encumbrance_id = X_orig_enc_id
		 and adl.document_type = 'ENC'
                 and nvl(adl.reversed_flag, 'N') = 'N' --Bug  5726575
                 and adl.line_num_reversed IS null --Bug  5726575
                 and adl.adl_status = 'A';
              Exception
		when too_many_rows then
		null ;
 	     End ;

      			i := i + 1;

      			IF ( X_enc_class_code <> 'PT' ) THEN
        			ValidateEmp ( EI.person_id
                                            , EI.encumbrance_item_date
                                            , temp_outcome );
                                CheckOutcome ( temp_outcome );
                        END IF;

      			IF ( NOT pa_utils.CheckExpTypeActive( EI.encumbrance_type
                                                            , EI.encumbrance_item_date ) ) THEN
        			temp_outcome := 'GMS_TR_ENC_TYPE_INACTIVE';
        			CheckOutcome( temp_outcome );
      			END IF;

                --		IF ( X_enc_class_code = 'OE' ) THEN
        	--		EI.raw_cost_rate := pa_utils.GetEncTypeCostRate( EI.encumbrance_type
                --                                                               , EI.encumbrance_item_date );
                --                EI.raw_cost := PA_CURRENCY.ROUND_CURRENCY_AMT( ( EI.quantity * EI.raw_cost_rate ) );
      	        --	END IF;

      			pa_transactions_pub.validate_transaction( X_project_id                  => EI.project_id
            						       ,  X_task_id                     => EI.task_id
            					               ,  X_ei_date                     => EI.encumbrance_item_date
            					               ,  X_expenditure_type            => EI.encumbrance_type
            					               ,  X_non_labor_resource          => NULL
            					               ,  X_person_id                   => X_person_id
            					               ,  X_quantity                    => EI.amount
            					               ,  X_denom_currency_code         => EI.denom_currency_code
            					               ,  X_acct_currency_code          => EI.acct_currency_code
            					               ,  X_denom_raw_cost              => EI.denom_raw_amount
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


	gms_transactions_pub.validate_transaction( EI.project_id
           				,  EI.task_id
	   				,  P_award_id
           				,  EI.encumbrance_type
           				,  EI.encumbrance_item_date
					,  'EXPEND_COPY'
					, P_OUTCOME       ) ;

-- verified the columns with getEI order.(latest table order )

    	gms_encumbrance_items_pkg.insert_row(
                                    x_dummy,
         		            EI.encumbrance_item_id,
                                    EI.last_update_date,
                                    EI.last_updated_by,
                                    EI.creation_date,
                                    EI.created_by,
                                    EI.encumbrance_id ,
                                    EI.task_id,
                                    EI.encumbrance_item_date,
                                    EI.encumbrance_type,
                                   -- fix for bug : 2469854
                                   -- EI.enc_distributed_flag,
                                    'N' ,
 				    EI.amount,
                                    EI.override_to_organization_id,
                                    EI.adjusted_encumbrance_item_id,
                                    EI.net_zero_adjustment_flag,
                                    EI.transferred_from_enc_item_id,
                                    EI.last_update_login,
                                    EI.request_id,
                                    EI.attribute_category,
                                    EI.attribute1,
                                    EI.attribute2,
                                    EI.attribute3,
                                    EI.attribute4,
                                    EI.attribute5,
                                    EI.attribute6,
                                    EI.attribute7,
                                    EI.attribute8,
                                    EI.attribute9,
                                    EI.attribute10,
                                    EI.orig_transaction_reference,
                                    EI.transaction_source,
                                    EI.project_id, --NULL, Bug 5726575
                                    EI.source_encumbrance_item_id,
                                    EI.job_id,
                                    EI.system_linkage_function,
 		       		    EI.denom_currency_code,
                                    EI.denom_raw_amount,
				    EI.acct_exchange_rounding_limit,
   		       		    EI.acct_currency_code,
 		       		    EI.acct_rate_date,
				    EI.acct_rate_type,
 		       		    EI.acct_exchange_rate,
                                    EI.acct_raw_cost,
 		       		    EI.project_currency_code,
 	       	       		    EI.project_rate_date,
 		       		    EI.project_rate_type,
 		       		    EI.project_exchange_rate,
                                    NULL ,
                                    EI.org_id ,
                                    EI.denom_tp_currency_code,
                                    EI.denom_transfer_price,
                                    EI.person_id,
                                    EI.incurred_by_person_id,
                                    EI.ind_compiled_set_id,
				    EI.pa_date,
			            EI.gl_date,
				    EI.line_num,
				    EI.burden_sum_dest_run_id,
				    EI.burden_sum_source_run_id );

    		END LOOP;
 /*   		gms_transactions.InsItems( X_user              =>	X_user
                            		, X_login             =>	NULL
                            		, X_module            =>	X_module
                            		, X_calling_process   =>	'EXPEND_COPY'
                            		, Rows                =>	i
                            		, X_status            => 	temp_status
                            		, X_gl_flag           =>	NULL  );
*/

    		pa_adjustments.CheckStatus( status_indicator => temp_status );

  	END  CopyItems;
--------------------------------------------------------------------------------------------
	PROCEDURE preapproved ( copy_option             IN VARCHAR2
    			     ,  copy_items              IN VARCHAR2
    			     ,  orig_enc_group          IN VARCHAR2
    			     ,  new_enc_group           IN VARCHAR2
    			     ,  orig_enc_id             IN NUMBER
    			     ,  enc_ending_date         IN DATE
    			     ,  new_inc_by_person       IN NUMBER
    			     ,  userid                  IN NUMBER
    			     ,  procedure_num_copied    IN OUT NOCOPY NUMBER
    			     ,  procedure_num_rejected  IN OUT NOCOPY NUMBER
    			     ,  procedure_return_code   IN OUT NOCOPY VARCHAR2 )

  	IS
       		num_copied              NUMBER := 0;
       		num_rejected            NUMBER := 0;
                new_enc_id              NUMBER ;
                x_orig_enc_id            NUMBER ;

       		CURSOR  getENC  IS
         	SELECT         encumbrance_id,
                               last_update_date,
                               last_updated_by,
                               creation_date,
                               created_by,
                               encumbrance_status_code,
                               encumbrance_ending_date,
                               encumbrance_class_code,
                         --    incurred_by_person_id,
                	 --      nvl( new_inc_by_person, incurred_by_person_id ) person_id,
                	        incurred_by_person_id  person_id,
                               incurred_by_organization_id,
                               encumbrance_group,
                         --    control_total_amount,
         	       	       decode( copy_mode, 'S', NULL,
         	               		 decode( copy_items, 'Y', control_total_amount, NULL ))
         	               control_total_amount,
                               entered_by_person_id,
                               description,
                               initial_submission_date,
                               last_update_login,
                               attribute_category,
                               attribute1,
                               attribute2,
                               attribute3,
                               attribute4,
                               attribute5,
                               attribute6,
                               attribute7,
                               attribute8,
                               attribute9,
                               attribute10,
		               denom_currency_code,
		               acct_currency_code,
		               acct_rate_type,
		               acct_rate_date,
		               acct_exchange_rate,
                               orig_enc_txn_reference1,
                               orig_enc_txn_reference2,
                               orig_enc_txn_reference3,
                               orig_user_enc_txn_reference,
                               vendor_id,
                               org_id
          	FROM
                 	gms_encumbrances
         	WHERE
                 	encumbrance_group = orig_enc_group
           	AND     encumbrance_id = nvl( orig_enc_id, encumbrance_id );

		ENC			getENC%ROWTYPE;

  	BEGIN

    		copy_mode := copy_option;
    		X_user    := userid;
    		X_enc_class_code := 'PT';
    --		X_module := 'PAXEXCOP/GMSTEXCB';
                X_module := 'GMSTRENE' ;

    		IF ( orig_enc_group = new_enc_group ) THEN
      			outcome := 'GMS_EX_SAME_EX';
      			RAISE INVALID_ITEM;
    			END IF;

    			OPEN  getENC;

      			LOOP
        			FETCH  getENC  INTO  ENC;

        			IF ( getENC%ROWCOUNT = 0 ) THEN
          				outcome := 'GMS_EX_NO_EX';
          				RAISE INVALID_ITEM;
        			END IF;

        			EXIT WHEN getENC%NOTFOUND;

                          x_orig_enc_id := enc.encumbrance_id ;

                          select gms_encumbrances_s.nextval
                          into new_enc_id
	                  from dual;

        			BEGIN
          				ValidateEmp (  ENC.person_id
                                       		     , enc_ending_date
                                       		     , outcome );

          				IF ( outcome IS NOT NULL ) THEN
            					IF ( copy_mode = 'M' ) THEN
              						RAISE INVALID_EXPENDITURE ;
            					ELSE
              						RAISE INVALID_ITEM;
            					END IF;
          				END IF;

          				IF ( copy_items = 'Y' ) THEN
            					CopyItems ( x_orig_enc_id
                      					  , new_enc_id
                      					  , enc_ending_date
                      					  , ENC.person_id );
          				END IF;

          			            gms_encumbrances_pkg.Insert_row (x_rowid                     => x_dummy ,
								          x_encumbrance_id   	        => new_enc_id,
								          x_last_update_date 	 	=> sysdate ,
								          x_last_updated_by   		=> X_user ,
								          x_creation_date     		=> sysdate ,
       									  x_created_by              	=> X_user ,
								          x_encumbrance_status_code 	=>'SUBMITTED',
       									  x_encumbrance_ending_date 	=> enc_ending_date ,
									  x_encumbrance_class_code 	=> 'PT' ,
								          x_incurred_by_person_id   	=> ENC.person_id ,
								          x_incurred_by_organization_id => ENC.incurred_by_organization_id ,
									  x_encumbrance_group           => new_enc_group ,
								          x_control_total_amount	=> ENC.control_total_amount ,
								          x_entered_by_person_id        => X_user ,
								          x_last_update_login		=> ENC.last_update_login,
								          x_attribute_category          => ENC.attribute_category,
								          x_attribute1                  => ENC.attribute1,
       								          x_attribute2                  => ENC.attribute2,
								          x_attribute3			=> ENC.attribute3,
								          x_attribute4			=> ENC.attribute4,
								          x_attribute5			=> ENC.attribute5,
       								          x_attribute6			=> ENC.attribute6,
								          x_attribute7			=> ENC.attribute7,
								          x_attribute8			=> ENC.attribute8,
								          x_attribute9			=> ENC.attribute9,
								          x_attribute10			=> ENC.attribute10,
								          x_description			=> ENC.description ,
								          x_denom_currency_code		=> ENC.denom_currency_code,
                                                                          x_acct_currency_code          => ENC.acct_currency_code,
								          x_acct_rate_type		=> ENC.acct_rate_type,
								          x_acct_rate_date		=> ENC.acct_rate_date,
								          x_acct_exchange_rate		=> ENC.acct_exchange_rate,
								          x_orig_enc_txn_reference1	=> ENC.orig_enc_txn_reference1,
								          x_orig_enc_txn_reference2	=> ENC.orig_enc_txn_reference2,
								          x_orig_enc_txn_reference3	=> ENC.orig_enc_txn_reference3,
								          x_orig_user_enc_txn_reference => ENC.orig_user_enc_txn_reference,
									  x_vendor_id			=> ENC.vendor_id ,
                                      x_org_id              => ENC.org_id );

           				num_copied := num_copied + 1;

				EXCEPTION
          				WHEN INVALID_EXPENDITURE then
            					num_rejected := num_rejected + 1;
					WHEN INVALID_ITEM THEN
						num_rejected := num_rejected + 1;
					WHEN OTHERS THEN
						RAISE;

        			END;

      			END LOOP;

    			CLOSE  getENC;

    			procedure_return_code  := 'GMS_EN_COPY_OUTCOME';
    			procedure_num_copied   := num_copied;
    			procedure_num_rejected := num_rejected;

  	EXCEPTION
    		WHEN OTHERS THEN
      			RAISE;

  	END  preapproved;
-- ===========================================================================================================
--
-- ==========================================================================================================
  	PROCEDURE ReverseEncGroup( X_orig_enc_group          IN VARCHAR2
                                ,  X_new_enc_group           IN VARCHAR2
                          ,  X_user_id                 IN NUMBER
                          ,  X_module                  IN VARCHAR2
                          ,  X_num_reversed            IN OUT NOCOPY NUMBER
                          ,  X_num_rejected            IN OUT NOCOPY NUMBER
                          ,  X_return_code             IN OUT NOCOPY VARCHAR2
                          ,  X_encgrp_status           IN VARCHAR2 DEFAULT 'WORKING' )
	IS

     		InsertEnc       BOOLEAN := TRUE  ;
     		InsertBatch     BOOLEAN := FALSE ;
     		no_of_items     number := 0 ;
     		num_reversed    number := 0 ;
     		num_rejected    number := 0 ;
     		enc_status      varchar2(20);

     		CURSOR RevEnc is
         	SELECT
                 	e.encumbrance_id  orig_enc_id
         	,       gms_encumbrances_s.nextval  new_enc_id
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
            ,       e.org_id
          	FROM
                 	gms_encumbrances e
         	WHERE
			e.encumbrance_group = X_orig_enc_group ;

     		cursor RevEncItems(encend_id NUMBER ) is
        	select
			ei.encumbrance_item_id
                , 	ei.net_zero_adjustment_flag
                , 	ei.source_encumbrance_item_id
                , 	ei.transferred_from_enc_item_id
          	from
			gms_encumbrance_items_all ei
         	where
			encumbrance_id = encend_id ;

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
                ,       org_id              -- fix for bug : 2376730
          	from
			gms_encumbrance_groups
         	where
			encumbrance_group = X_orig_enc_group ;

     		Enc             RevEnc%rowtype ;
     		EncEi           RevEncItems%rowtype ;
     		EncGroup        ReverseGroup%rowtype ;
     		outcome         VARCHAR2(100);
     		Dummy           NUMBER;

	BEGIN
		/*
		Check: The new Enc Group already exists in the system or not.
		Note: This check is not required when it's called from the Form GMSTRENE because
		this validation is already done there.
		*/
/*
		IF X_module <> 'GMSTRENE' THEN
			BEGIN
				SELECT 1
				INTO   Dummy
      				FROM   gms_encumbrance_groups
      				WHERE  encumbrance_group = X_new_enc_group;

      				outcome := 'PA_TR_EPE_GROUP_NOT_UNIQ';
      				RAISE INVALID_EXP_GROUP;

     			EXCEPTION
      				WHEN NO_DATA_FOUND THEN
					NULL;
     			END;
    		END IF;
*/

      		OPEN RevEnc ;

      		LOOP

         		FETCH RevEnc into  Enc ;

         		IF ( RevEnc%ROWCOUNT = 0 ) THEN
             			outcome := 'GMS_EN_NO_EN';
             			RAISE INVALID_ITEM;
         		END IF;

         		EXIT WHEN RevEnc%NOTFOUND;

         		InsertEnc  := TRUE ;
         		no_of_items := 0 ;

         		OPEN RevEncItems(Enc.orig_enc_id) ;
         		LOOP
             			Fetch RevEncItems into  EncEi ;

             			If ( RevEncItems%ROWCOUNT = 0 ) THEN
                			InsertEnc := FALSE ;
                			EXIT ;
             			END IF;
             			EXIT WHEN RevEncItems%NOTFOUND;

             			if not check_reverse_allowed( net_zero_flag    => EncEi.net_zero_adjustment_flag,
                                           		      related_item     => EncEi.source_encumbrance_item_id,
                                           		      transferred_item => EncEi.transferred_from_enc_item_id) then
                			num_rejected := num_rejected + 1 ;
             			else

                					BackOutItem( X_enc_item_id    => EncEi.encumbrance_item_id,
                        					    X_encumbrance_id => Enc.new_enc_id,
                        					    X_adj_activity   => 'REVERSE BATCH',
                        					    X_module         => 'PAXTREPE',
                        					    X_user           => x_user_id,
                        					    X_login          => x_user_id,
                        					    X_status         => outcome );
                			IF outcome <> 0  then
                   				num_rejected := num_rejected + 1 ;
                   				RAISE INVALID_ITEM ;
                			END IF;
                			no_of_items := no_of_items + 1 ;
                			num_reversed := num_reversed + 1 ;

              			end if;
         		END LOOP ;

         		CLOSE RevEncItems ;
         		If ( InsertEnc ) and (no_of_items > 0) then

               			IF  X_encgrp_status = 'WORKING' THEN
                 			enc_status := 'SUBMITTED';
               			ELSE
                 			enc_status := 'APPROVED';
               			END IF;

               			gms_encumbrances_pkg.Insert_row(x_rowid          =>   x_dummy ,
							   X_encumbrance_id      =>   Enc.new_enc_id,
                                                           X_last_update_date    =>   sysdate ,
							   X_last_updated_by     =>   fnd_global.user_id ,
 						           X_creation_date       =>   sysdate ,
                  					   X_created_by          =>   X_user_id ,
                  					   X_encumbrance_status_code       =>   enc_status,
                  					   X_encumbrance_ending_date       =>   Enc.encumbrance_ending_date ,
                  					   X_encumbrance_class_code        =>   Enc.encumbrance_class_code ,
                  					   X_incurred_by_person_id       =>   Enc.person_id ,
                  					   X_incurred_by_organization_id          =>   Enc.inc_by_org_id ,
                  					   X_encumbrance_group        =>   X_new_enc_group ,
                  					   X_control_total_amount       =>   Enc.control_total_amount,
                  					   X_entered_by_person_id       =>   X_user_id ,
                  					   X_description         =>   Enc.description ,
                  					   X_attribute_category  =>   Enc.attribute_category ,
                  					   X_attribute1          =>   Enc.attribute1  ,
                  					   X_attribute2          =>   Enc.attribute2  ,
                  					   X_attribute3          =>   Enc.attribute3  ,
                  					   X_attribute4          =>   Enc.attribute4  ,
                  					   X_attribute5          =>   Enc.attribute5  ,
                  					   X_attribute6          =>   Enc.attribute6  ,
                  					   X_attribute7          =>   Enc.attribute7  ,
                  					   X_attribute8          =>   Enc.attribute8  ,
                  					   X_attribute9          =>   Enc.attribute9  ,
                  					   X_attribute10         =>   Enc.attribute10 ,
                  					   X_denom_currency_code =>   Enc.denom_currency_code ,
	               					   X_acct_currency_code  =>   Enc.acct_currency_code ,
	               					   X_acct_rate_type      =>   Enc.acct_rate_type ,
	               					   X_acct_rate_date      =>   Enc.acct_rate_date ,
	               					   X_acct_exchange_rate  =>   Enc.acct_exchange_rate,
                                       X_org_id              =>   Enc.org_id );

          			InsertBatch := TRUE ;

          		End if ;

      		END LOOP ;

      		CLOSE RevEnc ;

      		if ((InsertBatch ) AND (X_module <> 'GMSTRENE'))  then
          		OPEN ReverseGroup ;
          		FETCH ReverseGroup into EncGroup ;
          		if ReverseGroup%notfound then
             			return ;
          		end if;

         		/*
        	 	Bug#: 728286
          	 	The supplied enc_group name is used to create the new Encenditure Group.
      	         	The status is set as supplied by the calling program (thru param x_encgrp_status)
                	*/


                         gms_encumbrance_groups_pkg.insert_row (x_rowid                 => x_dummy,
						            x_encumbrance_group		=> X_new_enc_group,
							    x_last_update_date		=> sysdate,
							    x_last_updated_by		=> fnd_global.user_id,
							    x_creation_date		=> sysdate,
							    x_created_by                => X_user_id,
							    x_encumbrance_group_status  => X_encgrp_status,
							    x_encumbrance_ending_date 	=> EncGroup.encumbrance_ending_date,
							    x_system_linkage_function   => EncGroup.system_linkage_function,
                                                        --    x_control_count             => null,
                                                        --    x_control_total_amount      => null,
						        --    x_description               => null,
                                                        --    x_last_update_login        => null,
							    x_transaction_source        => EncGroup.transaction_source ,
                                x_org_id                    => encgroup.org_id );

      		end if;

      		if num_reversed <= 0 then
         		outcome := 'GMS_NO_ITEMS_FOR_REVERSAL' ;
           		null ;
      		end if;

      		X_num_reversed := num_reversed ;
      		X_num_rejected := num_rejected ;
      		X_return_code  := outcome ;

	EXCEPTION
    		WHEN INVALID_ITEM THEN
      			X_return_code := outcome;
    		WHEN  INVALID_EXP_GROUP THEN
      			X_return_code := outcome;
    		WHEN OTHERS THEN
      			RAISE ;

  	End ReverseEncGroup ;
-- =============================================================================================================
--
-- =============================================================================================================

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


-- =======================================================================
-- PROCEDURE revalidate_employee
-- ========================================================================


   procedure revalidate_employee ( p_incurred_by_person_id IN NUMBER,
                                   p_week_end_date         IN DATE,
				   x_count                 OUT NOCOPY NUMBER,
				   x_org_id                OUT NOCOPY NUMBER,
				   x_org_name              OUT NOCOPY VARCHAR2) is


   cursor ORG_CUR is
   select o.organization_id,
          o.name
   from pa_employees p,
        per_assignments_f a,
        hr_organization_units o
   where a.person_id = p.person_id
   and a.effective_start_date <= p_week_end_date
   and nvl(a.effective_end_date,p_week_end_date) >= p_week_end_date - 6
   and a.primary_flag = 'Y'
   and a.organization_id = o.organization_id
   and p.person_id = p_incurred_by_person_id;

   l_org_id_tab      PA_PLSQL_DATATYPES.Num15TabTyp;
   l_org_name_tab    PA_PLSQL_DATATYPES.Char240TabTyp;


 BEGIN

       l_org_id_tab.delete;
       l_org_name_tab.delete;

       Open ORG_CUR;
       Fetch ORG_CUR Bulk Collect INTO
                                l_org_id_tab,
                                l_org_name_tab;
       Close ORG_CUR;

       x_count := l_org_id_tab.count;
       If x_count <> 0 then
       x_org_id := l_org_id_tab(1);
       x_org_name := l_org_name_tab(1);
       End If;
  EXCEPTION
	WHEN OTHERS THEN
		raise;

 END revalidate_employee;



END GMS_ENC_ADJUSTMENTS ;

/
