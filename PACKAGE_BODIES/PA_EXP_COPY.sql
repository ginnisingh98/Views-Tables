--------------------------------------------------------
--  DDL for Package Body PA_EXP_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EXP_COPY" AS
/* $Header: PAXTEXCB.pls 120.4 2006/07/27 19:31:45 eyefimov noship $ */

  	dummy                NUMBER;
  	org_id               NUMBER(15);
  	X_user               NUMBER(15);
  	X_module             VARCHAR2(30);
  	copy_mode            VARCHAR2(1);
  	outcome              VARCHAR2(30);
  	X_exp_class_code     VARCHAR2(2);

  	INVALID_EXPENDITURE  EXCEPTION;
  	INVALID_ITEM         EXCEPTION;
  	/*
   	* Bug# 728286
   	* New exception defined to check whether the new Exp group (in reverseexpgroup proc.)
   	* already exists in the system or not.
   	*/
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
                            ,  X_person_id       IN NUMBER
			    ,  P_Inc_by_Org_Id   IN NUMBER ) /* Added parameter for bug 2683803 */

  	IS

       		temp_outcome         VARCHAR2(30) DEFAULT NULL;
       		temp_outcome_type    VARCHAR2(1)  DEFAULT 'E';
       		temp_msg_application VARCHAR2(50) DEFAULT 'PA';
       		temp_msg_token1      VARCHAR2(240)  DEFAULT NULL;
       		temp_msg_token2      VARCHAR2(240)  DEFAULT NULL;
       		temp_msg_token3      VARCHAR2(240)  DEFAULT NULL;
       		temp_msg_count       NUMBER DEFAULT 1;
       		temp_status          NUMBER DEFAULT NULL;
       		i                    BINARY_INTEGER DEFAULT 0;

            -- Starts Added for bug#4618898
            temp_acct_rate_type            pa_expenditure_items_all.acct_rate_type%TYPE;
            temp_acct_rate_date            pa_expenditure_items_all.acct_rate_date%TYPE;
            temp_acct_exchange_rate        pa_expenditure_items_all.acct_exchange_rate%TYPE;
            temp_projfunc_rate_type        pa_expenditure_items_all.projfunc_cost_rate_type%TYPE;
            temp_projfunc_rate_date        pa_expenditure_items_all.projfunc_cost_rate_date%TYPE;
            temp_projfunc_exchange_rate    pa_expenditure_items_all.projfunc_cost_exchange_rate%TYPE;
            temp_project_rate_type         pa_expenditure_items_all.project_rate_type%TYPE;
            temp_project_rate_date         pa_expenditure_items_all.project_rate_date%TYPE;
            temp_project_exchange_rate     pa_expenditure_items_all.project_exchange_rate%TYPE;

            l_status VARCHAR2(30);
            l_dummy1 NUMBER;
            l_dummy2 NUMBER;
            l_dummy3 NUMBER;
            -- Ends Added for bug#4618898

		    l_labor_cost_multiplier_name  pa_expenditure_items_all.labor_cost_multiplier_name%TYPE;

            l_denom_burdened_cost pa_expenditure_items_all.denom_burdened_cost%TYPE; /* bug#2794006 */

       		CURSOR  getEI  IS
         	SELECT
         	        pa_expenditure_items_s.nextval expenditure_item_id
         	,       X_new_exp_id   expenditure_id
         	,       i.task_id
         	,       to_number( NULL ) raw_cost
         	,       to_number( NULL ) raw_cost_rate
         	,       decode( copy_mode, 'O',
         	          next_day((X_date-7),  /* bug 3693848 : Removed to_date function because X_date is already a date parameter */
         	              to_char(i.expenditure_item_date, 'DAY')),
         	                 X_date ) expenditure_item_date
                ,       i.organization_id                                /*added for bug-2478552*/
                ,       i.non_labor_resource                             /*added for bug-2478552*/
         	,       i.expenditure_type
         	,       i.system_linkage_function
         	,       decode( copy_mode, 'S', NULL, i.quantity ) quantity
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
		,       i.work_type_id
		,       i.assignment_id
		,       i.projfunc_currency_code
		,       i.projfunc_cost_rate_type
		,       i.projfunc_cost_rate_date
		,       i.projfunc_cost_exchange_rate
                ,       com.expenditure_comment    --bug 3066137
           	FROM
                 	pa_tasks t
          	,       pa_expenditure_items i
                ,       pa_expenditure_comments com  --bug 3066137
          	WHERE
                 	(    X_exp_class_code = 'OE'
                         /**  OR i.system_linkage_function = 'ST' ) Bug fix : 2329146 **/
                          OR i.system_linkage_function IN ('ST','OT','ER','USG','PJ','INV','WIP','BTC') )
                        /* bug#2794006 added 'PJ','INV','WIP','BTC' */
			/* Found during unit testing for bug 2683803.  Was not picking up eis whose slf is OT */
            	AND  i.task_id = t.task_id
                AND  i.expenditure_item_id = com.expenditure_item_id(+)   --bug 3066137
            	AND  i.expenditure_id = X_orig_exp_id
            	AND  i.adjusted_expenditure_item_id IS NULL
            	AND  nvl(i.net_zero_adjustment_flag, 'N' ) <> 'Y'
            	AND  i.source_expenditure_item_id IS NULL;

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
           				pa_transactions.FlushEiTabs;

           				IF ( copy_mode = 'M' ) THEN
             					RAISE INVALID_EXPENDITURE;
           				ELSE
             					RAISE INVALID_ITEM;
           				END IF;
        			END IF;
      			END IF;

    		END CheckOutcome;

		Function GetTpAmtTypeCode (P_Work_Type_Id IN NUMBER) Return Varchar2

		Is

			l_Tp_Amt_Type_Code Pa_Expenditure_Items_All.Tp_Amt_Type_Code%TYPE;

		Begin
                 IF P_Work_Type_Id is NOT NULL THEN /* IF Added for Bug2220691*/
			Select Tp_Amt_Type_Code
			into l_Tp_Amt_Type_Code
			from Pa_Work_Types_Vl
			where Work_Type_Id = P_Work_Type_Id;
                  ELSE
	                l_Tp_Amt_Type_Code:=NULL;    /* Bug 2220691 */
                  END IF;
                  Return l_Tp_Amt_Type_Code;

		End GetTpAmtTypeCode;

  	BEGIN

		FOR  EI  IN  getEI  LOOP

      			i := i + 1;

      			/* IF ( X_exp_class_code <> 'PT' ) THEN commented for bug#2527749 */
                        IF EI.person_id IS NOT NULL THEN    /* added for bug#2527749 */

        			ValidateEmp ( EI.person_id
                                            , EI.expenditure_item_date
                                            , temp_outcome );
                                CheckOutcome ( temp_outcome );

                        END IF;

      			IF ( NOT pa_utils.CheckExpTypeActive( EI.expenditure_type
                                                            , EI.expenditure_item_date ) ) THEN
        			temp_outcome := 'PA_TR_EXP_TYPE_INACTIVE';
        			CheckOutcome( temp_outcome );

      			END IF;

      			IF ( X_exp_class_code = 'OE' ) THEN

        			EI.raw_cost_rate := pa_utils.GetExpTypeCostRate( EI.expenditure_type
                                                                               , EI.expenditure_item_date );
                                EI.raw_cost := PA_CURRENCY.ROUND_CURRENCY_AMT( ( EI.quantity * EI.raw_cost_rate ) );

      			END IF;

      			pa_transactions_pub.validate_transaction(
				           X_project_id                  => EI.project_id
            			,  X_task_id                     => EI.task_id
            			,  X_ei_date                     => EI.expenditure_item_date
            			,  X_expenditure_type            => EI.expenditure_type
            			,  X_non_labor_resource          => EI.non_labor_resource /* bug-2478552*/
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
            			,  X_incurred_by_org_id          => P_Inc_by_Org_Id
            			,  X_nl_resource_org_id          => EI.organization_id  /*bug-2478552*/
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
            			,  X_billable_flag               => EI.billable_flag
				        ,  P_ProjFunc_Currency_Code      => EI.ProjFunc_Currency_Code
				        ,  P_ProjFunc_Cost_Rate_Type     => EI.ProjFunc_Cost_Rate_Type
				        ,  P_ProjFunc_Cost_Rate_Date     => EI.ProjFunc_Cost_Rate_Date
				        ,  P_ProjFunc_Cost_Exchg_Rate    => EI.ProjFunc_Cost_Exchange_Rate
				        ,  P_Assignment_Id               => EI.Assignment_Id
				        ,  P_Work_Type_Id                => EI.Work_Type_Id
				        ,  P_sys_link_function           => EI.system_linkage_function );

      			CheckOutcome( temp_outcome ,temp_outcome_type);
                        /* Start of Bug 2648550 */
			    EI.Assignment_Id := PATC.G_OVERIDE_ASSIGNMENT_ID;
			    EI.Work_Type_Id := PATC.G_OVERIDE_WORK_TYPE_ID;
			    /* End of Bug 2648550 */

               	/* NO IC Changes, Copy just creates new EI from existing EI's
                   So they should be treated as New txns.  For any new EI created
                   through form we do not derive the ic attributes.  Following
                   the same approach here, loadei will insert the defaults for
                   all IC columns.
               	*/

			    -- Begin bug 2678790
			    l_labor_cost_multiplier_name := Check_lcm(P_lcm_name => ei.labor_cost_multiplier_name,
								                      P_ei_Date  => EI.expenditure_item_date);
			    -- End bug 2678790

                select decode(EI.system_linkage_function,'BTC',EI.denom_burdened_cost,NULL)
                into l_denom_burdened_cost
                from dual; /* bug#2794006 */

                --BLOCK ADDED FOR CALCULATING THE EXCHANGE RATES FOR THE NEW ITEM for bug #4618898

                -- Copy the rate types from the source EI.

                temp_acct_rate_type        := EI.acct_rate_type;
                temp_projfunc_rate_type    := EI.projfunc_cost_rate_type;
                temp_project_rate_type     := EI.project_rate_type;

                -- New Item rate date will be the expenditure_item_date
                IF ( EI.acct_rate_date is NOT NULL) THEN
                     temp_acct_rate_date  := EI.expenditure_item_date;
                END IF;

                IF ( EI.projfunc_cost_rate_date is NOT NULL) THEN
                     temp_projfunc_rate_date  := EI.expenditure_item_date;
                END IF;

                IF ( EI.project_rate_date is NOT NULL) THEN
                     temp_project_rate_date  := EI.expenditure_item_date;
                END IF;
                -- If the rate type is User then copy the exchange rates from the source EI.
                IF (EI.acct_rate_type = 'User') THEN
                     temp_acct_exchange_rate := EI.acct_exchange_rate;
                ELSE
                     temp_acct_exchange_rate        := NULL;
                END IF;

                IF (EI.project_rate_type = 'User') THEN
                     temp_project_exchange_rate := EI.project_exchange_rate;
                ELSE
                     temp_project_exchange_rate        := NULL;
                END IF;

                IF (EI.projfunc_cost_rate_type = 'User') THEN
                     temp_projfunc_exchange_rate := EI.projfunc_cost_exchange_rate;
                ELSE
                     temp_projfunc_exchange_rate        := NULL;
                END IF;

                -- calling API's to calculate the acct and projfunc cost exchange rates

                If temp_acct_rate_type is not null and
                   temp_acct_rate_type <> 'User' and
                   temp_acct_rate_date is not null and
                   EI.denom_currency_code is not null Then

                     pa_multi_currency.convert_amount(
                                                 EI.denom_currency_code,
                                                 EI.acct_currency_code,
                                                 temp_acct_rate_date,
                                                 temp_acct_rate_type,
                                                 null,
                                                 'N',
                                                 'Y',
                                                 l_dummy1,
                                                 l_dummy2,
                                                 l_dummy3,
                                                 temp_acct_exchange_rate,
                                                 l_status);

                End If;

                If temp_projfunc_rate_type is not null and
                   temp_projfunc_rate_type <> 'User' and
                   temp_projfunc_rate_date is not null Then

                     pa_multi_currency.convert_amount(
                                                 nvl(EI.denom_currency_code,EI.acct_currency_code),
                                                 EI.projfunc_currency_code,
                                                 temp_projfunc_rate_date,
                                                 temp_projfunc_rate_type,
                                                 null,
                                                 'N',
                                                 'Y',
                                                 l_dummy1,
                                                 l_dummy2,
                                                 l_dummy3,
                                                 temp_projfunc_exchange_rate,
                                                 l_status);

                End If; -- projfunc check

        -- Proj curr changes

                If temp_project_rate_type is not null and
                   temp_project_rate_type <> 'User' and
                   temp_project_rate_date is not null Then

                     pa_multi_currency.convert_amount(
                                                 nvl(EI.denom_currency_code,EI.acct_currency_code),
                                                 EI.project_currency_code,
                                                 temp_project_rate_date,
                                                 temp_project_rate_type,
                                                 null,
                                                 'N',
                                                 'Y',
                                                 l_dummy1,
                                                 l_dummy2,
                                                 l_dummy3,
                                                 temp_project_exchange_rate,
                                                 l_status);

                End If;
                --Block ends for bug #4618898

      		    pa_transactions.LoadEi(
					 X_expenditure_item_id          => EI.expenditure_item_id
                    ,X_expenditure_id               => EI.expenditure_id
                    ,X_expenditure_item_date        => EI.expenditure_item_date
                    ,X_project_id                   => EI.project_id --bugfix:2201207 NULL
                    ,X_task_id                      => EI.task_id
                    ,X_expenditure_type             => EI.expenditure_type
                    ,X_non_labor_resource           => EI.non_labor_resource /* bug-2478552*/
                    ,X_nl_resource_org_id           => EI.organization_id    /* bug-2478552*/
                    ,X_quantity                     => EI.quantity
                    ,X_raw_cost                     => NULL
                    ,X_raw_cost_rate                => NULL
                    ,X_override_to_org_id           => NULL
                    ,X_billable_flag                => EI.billable_flag
                    ,X_bill_hold_flag               => 'N'
                    ,X_orig_transaction_ref         => NULL
                    ,X_transferred_from_ei          => NULL
                    ,X_adj_expend_item_id           => NULL
                    ,X_attribute_category           => EI.attribute_category
                    ,X_attribute1                   => EI.attribute1
                    ,X_attribute2                   => EI.attribute2
                    ,X_attribute3                   => EI.attribute3
                    ,X_attribute4                   => EI.attribute4
                    ,X_attribute5                   => EI.attribute5
                    ,X_attribute6                   => EI.attribute6
                    ,X_attribute7                   => EI.attribute7
                    ,X_attribute8                   => EI.attribute8
                    ,X_attribute9                   => EI.attribute9
                    ,X_attribute10                  => EI.attribute10
                    ,X_ei_comment                   => EI.expenditure_comment  /*Bug 3066137 */                  			       ,X_transaction_source           => NULL
                    ,X_source_exp_item_id           => NULL
                    ,i                              => i
                    ,X_job_id                       => EI.job_id
                    ,X_org_id                       => EI.org_id
                    ,X_labor_cost_multiplier_name   => l_labor_cost_multiplier_name
                    ,X_drccid                       => NULL
                    ,X_crccid                       => NULL
                    ,X_cdlsr1                       => NULL
                    ,X_cdlsr2                       => NULL
                    ,X_cdlsr3                       => NULL
                    ,X_gldate                       => NULL
                    ,X_bcost                        => NULL
                    ,X_bcostrate                    => NULL
                    ,X_etypeclass                   => EI.system_linkage_function
                    ,X_burden_sum_dest_run_id       => NULL
                    ,X_burden_compile_set_id        => NULL
                    ,X_receipt_currency_amount      => NULL
                    ,X_receipt_currency_code        => EI.receipt_currency_code
                    ,X_receipt_exchange_rate        => EI.receipt_exchange_rate
                    ,X_denom_currency_code          => EI.denom_currency_code
                    ,X_denom_raw_cost               => NULL
                    ,X_denom_burdened_cost          => l_denom_burdened_cost /* bug#2794006 */
                    ,X_acct_currency_code           => EI.acct_currency_code
                    ,X_acct_rate_date               => EI.acct_rate_date
                    ,X_acct_rate_type               => EI.acct_rate_type
                    ,X_acct_exchange_rate           => EI.acct_exchange_rate
                    ,X_acct_raw_cost                => NULL
                    ,X_acct_burdened_cost           => NULL
                    ,X_acct_exchange_rounding_limit => EI.acct_exchange_rounding_limit
                    ,X_project_currency_code        => EI.project_currency_code
                    ,X_project_rate_date            => EI.project_rate_date
                    ,X_project_rate_type            => EI.project_rate_type
                    ,X_project_exchange_rate        => EI.project_exchange_rate
				    ,P_Assignment_Id                => EI.Assignment_Id
                   	,P_Work_type_Id                 => EI.Work_Type_Id
                   	,P_Projfunc_Currency_Code       => EI.ProjFunc_Currency_Code
                   	,P_Projfunc_Cost_Rate_Date      => EI.ProjFunc_Cost_Rate_Date
                   	,P_Projfunc_Cost_Rate_Type      => EI.ProjFunc_Cost_Rate_Type
                   	,P_Projfunc_Cost_Exchange_Rate  => EI.ProjFunc_Cost_Exchange_Rate
				    ,P_Tp_Amt_Type_Code             => GetTpAmtTypeCode(EI.Work_Type_Id));

		END LOOP;

    	pa_transactions.InsItems(
                    X_user              =>	X_user
                  , X_login             =>	NULL
                  , X_module            =>	X_module
                  , X_calling_process   =>	'EXPEND_COPY'
                  , Rows                =>	i
                  , X_status            => 	temp_status
                  , X_gl_flag           =>	NULL  );

    	pa_adjustments.CheckStatus( status_indicator => temp_status );

  	END  CopyItems;

	PROCEDURE preapproved (
                        copy_option             IN VARCHAR2
    			     ,  copy_items              IN VARCHAR2
    			     ,  orig_exp_group          IN VARCHAR2
    			     ,  new_exp_group           IN VARCHAR2
    			     ,  orig_exp_id             IN NUMBER
    			     ,  exp_ending_date         IN DATE
    			     ,  new_inc_by_person       IN NUMBER
    			     ,  userid                  IN NUMBER
    			     ,  procedure_num_copied    IN OUT NOCOPY NUMBER
    			     ,  procedure_num_rejected  IN OUT NOCOPY NUMBER
    			     ,  procedure_return_code   IN OUT NOCOPY VARCHAR2
			         /** start of Bug fix 2329146 **/
		             ,  p_sys_link_function     IN VARCHAR2 default null
                     ,  p_exp_type_class_code   IN VARCHAR2 default 'PT'
			         /** end of bug fix **/
			         ,  P_Update_Emp_Orgs       IN VARCHAR2 default null)

  	IS

       		num_copied              NUMBER := 0;
       		num_rejected            NUMBER := 0;
		    new_exp_id              NUMBER;
            old_org_id              NUMBER;
		    l_Inc_By_Org_Id         NUMBER;  /* Added local variable for bug 2683803 */

            l_org_id                NUMBER  := pa_moac_utils.get_current_org_id;

            /* Bug 954856  Added ORDER BY expenditure_id to cursor getEXP */
            /* Bug 1118913 Removed pa_expenditures_s.nextval new_exp_id from
                           cursor. Whereever EXP.new_exp_id change to
                           new_exp_id */

       		CURSOR  getEXP  IS
         	SELECT
         	        expenditure_id  orig_exp_id
         	,       description
            ,       incurred_by_organization_id        /* Included for Bug#2366542 */
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
            ,       person_type -- fix for bug : 3645842
          	FROM
                 	pa_expenditures
         	WHERE
                 	expenditure_group = orig_exp_group
           	AND     expenditure_id = nvl( orig_exp_id, expenditure_id )
		    ORDER BY expenditure_id;

		    EXP			getEXP%ROWTYPE;

            -- Starts Added for bug#4618898
            temp_acct_rate_type        pa_expenditures.acct_rate_type%TYPE;
            temp_acct_rate_date            pa_expenditures.acct_rate_date%TYPE;
            temp_acct_exchange_rate        pa_expenditures.acct_exchange_rate%TYPE;
            l_status VARCHAR2(30);
            l_dummy1 NUMBER;
            l_dummy2 NUMBER;
            l_dummy3 NUMBER;
            -- Ends Added for bug#4618898

  	BEGIN

    	copy_mode := copy_option;
    	X_user    := userid;
    	/** commented for bug fix : 2329146 X_exp_class_code := 'PT'; **/
	    IF nvl(p_exp_type_class_code,'X') <> 'X' Then
    		      X_exp_class_code := p_exp_type_class_code;
		Else
		      X_exp_class_code := 'PT';
		End if;

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

			 /* Enhancement bug 2683803
			     Remming out the assigning of a value to the org_id and doing it conditionally
			    further down in the process.  To provide the customer option to choose
			    what they want to populate in the new expenditure being created
			    incurred by organization id field. */
             -- org_id := EXP.incurred_by_organization_id;  /* Included Bug#2366542 */

        	 EXIT WHEN getEXP%NOTFOUND;

             --
             -- Bug # 1118913
             --
             -- Earlier the new expenditure id was generated
             -- in the select statement.  But there was problem
             -- using the sequence generator in the SELECT statement

             SELECT pa_expenditures_s.nextval
             INTO new_exp_id
             FROM DUAL ;

             --
             -- End bug 1118913
             --

        	 BEGIN

			      -- Begin of enhancement bug 2683803
			      If Nvl(P_Update_Emp_Orgs,'Y') = 'Y' Then

          	           ValidateEmp (  EXP.person_id
                                    , exp_ending_date
                                    , outcome );

				       l_Inc_By_Org_Id := Org_Id;

          		       If ( outcome IS NOT NULL ) Then

            	            If ( copy_mode = 'M' ) Then
              		             Raise INVALID_EXPENDITURE;
            		        Else
              				     Raise INVALID_ITEM;
            		        End If;

          		       End If;

			      Else

				       l_Inc_by_Org_Id := Exp.Incurred_By_Organization_Id;

			      End If;
			      -- End of enhancement bug 2683803

          	      IF ( copy_items = 'Y' ) THEN

                       CopyItems ( EXP.orig_exp_id
                           	     , new_exp_id
                      	         , exp_ending_date
                      	         , EXP.person_id
						         , l_Inc_By_Org_Id ); /* Added parameter for bug 2683803 */

          	      END IF;

                  --BLOCK ADDED FOR CALCULATING THE EXCHANGE RATES FOR THE NEW Expenditure for bug #4618898
                  -- Copy the rate types from the source EXP.
                  temp_acct_rate_type        := EXP.acct_rate_type;

                  -- New Item rate date will be the expenditure_ending_date
                  IF ( EXP.acct_rate_date is NOT NULL) THEN
                       temp_acct_rate_date  := exp_ending_date;
                  END IF;

                  -- If the rate type is User then copy the exchange rates from the source EXP.
                  IF (EXP.acct_rate_type = 'User') THEN
                       temp_acct_exchange_rate := EXP.acct_exchange_rate;
                  ELSE
                       temp_acct_exchange_rate        := NULL;
                  END IF;

                  -- calling API's to calculate the acct and projfunc cost exchange rates

                  If temp_acct_rate_type is not null and
                     temp_acct_rate_type <> 'User' and
                     temp_acct_rate_date is not null and
                     EXP.denom_currency_code is not null Then

                       pa_multi_currency.convert_amount(
                                                   EXP.denom_currency_code,
                                                   EXP.acct_currency_code,
                                                   temp_acct_rate_date,
                                                   temp_acct_rate_type,
                                                   null,
                                                   'N',
                                                   'Y',
                                                   l_dummy1,
                                                   l_dummy2,
                                                   l_dummy3,
                                                   temp_acct_exchange_rate,
                                                   l_status);

                  End If;
                  --Block ends for bug #4618898

          	      pa_transactions.InsertExp(
                           			X_expenditure_id      => new_exp_id,
                           			X_expend_status       => 'WORKING',
                           			X_expend_ending       => exp_ending_date,
                           			/** X_expend_class        => 'PT', bug fix : 2329146 **/
                           			X_expend_class        => X_exp_class_code,
                           			X_inc_by_person       => EXP.person_id,
						            /* X_inc_by_org       => org_id, remmed out for bug 2683803 */
						            /* Used a local variable to hold the inc by org id instead
						               old the global variable because it get changed when validateemp()
						               gets called.  Part of bug 2683803 enhancement unit testing */
                           			X_inc_by_org          => l_Inc_By_Org_id,
                           			X_expend_group        => new_exp_group,
                           			X_entered_by_id       => X_user,
                           			X_created_by_id       => X_user,
                           			X_attribute_category  => EXP.attribute_category,
                           			X_attribute1          => EXP.attribute1,
                           			X_attribute2          => EXP.attribute2,
                           			X_attribute3          => EXP.attribute3,
                           			X_attribute4          => EXP.attribute4,
                           			X_attribute5          => EXP.attribute5,
                           			X_attribute6          => EXP.attribute6,
                           			X_attribute7          => EXP.attribute7,
                           			X_attribute8          => EXP.attribute8,
                           			X_attribute9          => EXP.attribute9,
                           			X_attribute10         => EXP.attribute10,
                           			X_description         => EXP.description,
                           			X_control_total       => EXP.control_total_amount,
                           			X_denom_currency_code => EXP.denom_currency_code,
	                   			    X_acct_currency_code  => EXP.acct_currency_code,
	                   			    X_acct_rate_type      => EXP.acct_rate_type,
	                   			    X_acct_rate_date      => EXP.acct_rate_date,
	                  			    X_acct_exchange_rate  => EXP.acct_exchange_rate,
                                    X_person_type         => EXP.person_type,
                                    P_Org_Id              => l_Org_Id);  -- 12i MOAC changes

           	     num_copied := num_copied + 1;

      		     --  Copies the attachments for the original expenditure
      		     --  to the newly created expenditure

      		     fnd_attached_documents2_pkg.copy_attachments(
                                                         'PA_EXPENDITURES',
                                       	                 EXP.orig_exp_id,
                                                         null,
                                                         null,
                                                         null,
                                                         null,
                                                         'PA_EXPENDITURES',
                                                         new_exp_id,
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
		l_inc_by_org_id NUMBER; /* Added due to unit testing for enhancement bug 2683803 */

  	BEGIN

    		copy_mode := 'O';
    		X_user    := userid;

    		SELECT
            		e.expenditure_class_code,
			e.incurred_by_organization_id
      		INTO
            		X_exp_class_code,
			l_inc_by_org_id
      		FROM
            		pa_expenditures e
     		WHERE
            		e.expenditure_id = orig_exp_id;

     		IF ( X_exp_class_code = 'OT' ) THEN
       			X_module := 'PAXEXEER/PAXTEXCB';
     		ELSIF ( X_exp_class_code = 'OE' ) THEN
       			X_module := 'PAXEXTCE/PAXTEXCB';
     		END IF;

    		CopyItems ( orig_exp_id
                          , new_exp_id
                          , exp_ending_date
                          , X_inc_by_person
			  , l_inc_by_org_id ); /* Added parameter due to unit testing for enhancement bug 2683803 */

  	EXCEPTION
    		WHEN INVALID_ITEM THEN
      			procedure_return_code := outcome;

  	END  online;

  	/*
	    Bug#: 728286
	    New parameter added: X_expgrp_status (status of the exp group to be created)
	    All the program/function calls are changed to named parameter method.
	*/

  	PROCEDURE ReverseExpGroup( X_orig_exp_group          IN VARCHAR2
                                ,  X_new_exp_group           IN VARCHAR2
                          ,  X_user_id                 IN NUMBER
                          ,  X_module                  IN VARCHAR2
                          ,  X_num_reversed            IN OUT NOCOPY NUMBER
                          ,  X_num_rejected            IN OUT NOCOPY NUMBER
                          ,  X_return_code             IN OUT NOCOPY VARCHAR2
                          ,  X_expgrp_status           IN VARCHAR2 DEFAULT 'WORKING')
	IS

     		InsertExp            Boolean := TRUE  ;
     		InsertBatch          Boolean := FALSE ;
     		no_of_items          Number := 0 ;
     		num_reversed         Number := 0 ;
     		num_rejected         Number := 0 ;
     		exp_status           Varchar2(20);
		    l_OtlItem_Reversable Boolean := TRUE;   -- OTL Change
            l_BackOutExp_Id      Number := 0; -- added for bug 5405636

     		CURSOR RevExp is
         	SELECT
                 	e.expenditure_id  orig_exp_id
         	,       pa_expenditures_s.nextval  new_exp_id
         	,       e.expenditure_ending_date
         	,       e.description
         	,       e.incurred_by_person_id  person_id
         	,       e.incurred_by_organization_id inc_by_org_id
         	,       e.expenditure_class_code
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
            ,       e.person_type   -- CWK change
          	FROM
                 	pa_expenditures e
         	WHERE
			e.expenditure_group = X_orig_exp_group ;

     		cursor RevExpItems(expend_id NUMBER ) is
        	select
			    ei.expenditure_item_id
            , 	ei.net_zero_adjustment_flag
            , 	ei.source_expenditure_item_id
            , 	ei.transferred_from_exp_item_id
            ,   ei.task_id
		    ,   ei.transaction_source               -- OTC changes
	        ,   ei.orig_transaction_reference       -- OTC changes
          	from
			    pa_expenditure_items_all ei
         	where
			    expenditure_id = expend_id ;

      		cursor ReverseGroup is
        	select
			    expenditure_group
            , 	expenditure_ending_date
            , 	system_linkage_function
            , 	control_count
            , 	control_total_amount
            , 	request_id
            , 	program_id
            , 	program_application_id
            , 	transaction_source
          	from
			    pa_expenditure_groups
         	where
			    expenditure_group = X_orig_exp_group ;

     		Exp             RevExp%rowtype ;
     		ExpEi           RevExpItems%rowtype ;
     		ExpGroup        ReverseGroup%rowtype ;
     		outcome         VARCHAR2(100);
     		Dummy           NUMBER;
     		l_project_id    pa_tasks.project_id%TYPE;
            l_org_id        NUMBER := pa_moac_utils.get_current_org_id;

	BEGIN
		/*
		Bug#: 728286
		Check: The new Exp Group already exists in the system or not.
		Note: This check is not required when it's called from the Form PAXTREPE because
		this validation is already done there.
		*/

		IF X_module <> 'PAXTREPE' THEN
			BEGIN
				SELECT 1
				INTO   Dummy
      				FROM   pa_expenditure_groups
      				WHERE  expenditure_group = X_new_exp_group;

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

             	SELECT project_id
                INTO l_project_id
                FROM pa_tasks
             	WHERE task_id = ExpEi.task_id;

				/* OTL item is checked in OTL to see if change has been made in OTL. */
				If ExpEi.transaction_source = 'ORACLE TIME AND LABOR' and
			       ExpEi.Orig_Transaction_Reference is not null Then

				     Pa_Otc_Api.AdjustAllowedToOTCItem(ExpEi.Orig_Transaction_Reference,
									                   l_OtlItem_Reversable);
				End If;

				-- The OR clause and pa_project_utils.check_project_action_allowed
				-- condition is added to the code for checking whether for project
				-- belonging to expenditure items have status for which new transactions
				-- are allowed. If new transactions are not allowed for particular
				-- project, the corresponding expenditure item will be rejected and
				-- will not be reversed. The corresponding bug# is 1257100

				/* Added OTL Boolean Flag to if condition. Don't want to allow
				 * the reversal of an OTL item that has already been changed in OTL. */
             	if ((Not Check_Reverse_Allowed(
			                ExpEi.Net_Zero_Adjustment_Flag,
                            ExpEi.Source_Expenditure_Item_Id,
                            ExpEi.Transferred_From_Exp_Item_Id))  OR
                     (Pa_Project_Utils.Check_Project_Action_Allowed(l_Project_Id,'NEW_TXNS') ='N') OR
				     (Not l_OtlItem_Reversable) ) Then

                     num_rejected := num_rejected + 1 ;

              	else  -- reversal is allowed

                	pa_adjustments.BackOutItem(
                         X_exp_item_id    => ExpEi.expenditure_item_id,
                         X_expenditure_id => Exp.new_exp_id,
                         X_adj_activity   => 'REVERSE BATCH',
                         X_module         => 'PAXTREPE',
                         X_user           => x_user_id,
                         X_login          => x_user_id,
                         X_status         => outcome );

                    IF outcome <> 0  then
                         num_rejected := num_rejected + 1 ;
                         RAISE INVALID_ITEM ;
                    END IF;

                    /* Code added for bug 5405636 : Start*/

                    SELECT  expenditure_item_id
                    INTO  l_BackOutExp_Id
                    FROM  pa_expenditure_items_all
                    WHERE  adjusted_expenditure_item_id   =  ExpEi.expenditure_item_id;

                    pa_costing.CreateReverseCdl(
                         X_exp_item_id => ExpEi.expenditure_item_id,
                         X_backout_id  => l_BackOutExp_Id,
                         X_user        => x_user_id,
                         X_status      => outcome );

                    /* Code added for bug 5405636  : End */

                    IF outcome <> 0  then
                         num_rejected := num_rejected + 1 ;
                         RAISE INVALID_ITEM ;
                    END IF;

                	pa_adjustments.ReverseRelatedItems(
                         X_source_exp_item_id => ExpEi.expenditure_item_id,
                         X_expenditure_id     => NULL,
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

              	end if; -- Is reversal allowed?

         	END LOOP ;
         	CLOSE RevExpItems ;

         	If ( InsertExp ) and (no_of_items > 0) then

                 IF  X_expgrp_status = 'WORKING' THEN
                      exp_status := 'SUBMITTED';
               	 ELSE
                 	  exp_status := 'APPROVED';
               	 END IF;

               	 pa_transactions.InsertExp(
                      X_expenditure_id      =>   Exp.new_exp_id,
                  	  X_expend_status       =>   exp_status,
                  	  X_expend_ending       =>   Exp.expenditure_ending_date ,
                  	  X_expend_class        =>   Exp.expenditure_class_code ,
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
	               	  X_acct_exchange_rate  =>   Exp.acct_exchange_rate,
                      X_person_type         =>   Exp.person_type,
                      P_Org_Id              =>   l_Org_Id);   -- CWK change

              	 --  Copies the attachments for the original expenditure
              	 --  to the newly created expenditure

               	 fnd_attached_documents2_pkg.copy_attachments(
                      X_from_entity_name        =>  'PA_EXPENDITURES',
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

         	  /* Bug#: 728286
          	 	 The supplied exp_group name is used to create the new Expenditure Group.
      	         The status is set as supplied by the calling program (thru param x_expgrp_status)
              */
         	  pa_transactions.InsertExpGroup(
                   X_expenditure_group     =>   X_new_exp_group ,
               	   X_exp_group_status_code =>   X_expgrp_status ,
               	   X_ending_date           =>   ExpGroup.expenditure_ending_date ,
               	   X_system_linkage        =>   ExpGroup.system_linkage_function ,
               	   X_created_by            =>   X_user_id ,
               	   X_transaction_source    =>   ExpGroup.transaction_source,
                   P_Org_Id                =>   l_Org_Id); -- 12i MOAC changes

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
     		/*
       		Bug#: 728286
       		Error handling
      		*/
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

	Function Check_lcm(P_Lcm_Name IN Pa_Expenditure_Items_All.Labor_Cost_Multiplier_Name%TYPE,
                       P_Ei_Date  IN Pa_Expenditure_Items_All.Expenditure_Item_Date%TYPE) RETURN VARCHAR2

	Is

		l_lcm_Name     Pa_Expenditure_Items_All.Labor_Cost_Multiplier_Name%TYPE := NULL;

	Begin

		If P_lcm_name is not null Then

			select
				labor_cost_multiplier_name
			into
				l_lcm_Name
			from
				pa_labor_cost_multipliers
			where
				labor_cost_multiplier_name = P_Lcm_Name
			and   	P_Ei_Date Between Start_Date_Active
					      And End_Date_Active;

		End If;

		Return ( l_lcm_Name );


	Exception
		When Others Then
			Return ( NULL );

	End Check_lcm;


END  PA_EXP_COPY;

/
