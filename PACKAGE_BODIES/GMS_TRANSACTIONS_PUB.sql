--------------------------------------------------------
--  DDL for Package Body GMS_TRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_TRANSACTIONS_PUB" AS
-- $Header: gmstpubb.pls 120.2.12010000.6 2009/12/09 08:32:04 anuragar ship $

	-- --------------------------------------------------------
	-- Declare global variables.
	-- -------------------------------------------------------

    g_award_id   number;
    g_award_distribution_option varchar2(1);

    INVALID_DATA EXCEPTION;

    PROCEDURE set_award IS
        BEGIN
            select default_dist_award_id,award_distribution_option
            into g_award_id,g_award_distribution_option
            from gms_implementations;
        EXCEPTION
        WHEN OTHERS THEN
            null ;
        END set_award;


	-- --------------------------------------
	-- Sponsored projects need to have award
	-- entered.
	-- -------------------------------------
	Function AWARD_REQUIRED(P_Task_Id             IN NUMBER,
							X_Outcome             OUT NOCOPY VARCHAR2)
	RETURN BOOLEAN IS
			Sponsor_Flag VARCHAR2(150);
	Begin

	--Bug 9090618 added org_id join between p and gpt
		 	Select nvl(gpt.sponsored_flag,'N')
		 	  into Sponsor_Flag
		 	  from 	pa_tasks t,
		 			pa_projects_all p,
		 			gms_project_types gpt
		 	 where 	t.task_id              = P_Task_Id             and
		 			p.project_id           = t.project_id          and
		 			gpt.project_type        = p.project_type       and
					gpt.org_id             = p.org_id;

			 If Sponsor_Flag = 'Y' then
				RETURN TRUE;
			 Else
				RETURN FALSE;
			 End If;

	EXCEPTION
		 WHEN OTHERS THEN
			  --   X_Outcome := to_char(SQLCODE);
			 If P_Task_Id IS NOT NULL THEN
           		X_Outcome := 'GMS_INV_ITEM_TASK';
       		 End If;
             raise ;

       		 --RETURN FALSE;

	End AWARD_REQUIRED;
	-- ============= END of AWARD_REQUIRED ===================

	-- -------------------------------------------------------------
	-- Common Table handler for Table GMS_transaction Interface all
	-- -------------------------------------------------------------

	PROCEDURE LOAD_GMS_XFACE_API ( p_rec gms_transaction_interface_all%ROWTYPE,
								   p_outcome OUT NOCOPY varchar2 ) is
		x_rec gms_transaction_interface_all%ROWTYPE ;
		p_err_code     NUMBER ;
		p_err_buf      varchar2(2000) ;

	BEGIN

		x_rec := p_rec ;

		IF x_rec.created_by is NULL THEN
			x_rec.created_by := nvl(fnd_global.user_id,0) ;
		END IF ;

		IF x_rec.last_updated_by is NULL THEN
			x_rec.last_updated_by := nvl(fnd_global.user_id,0) ;
		END IF ;

		IF x_rec.creation_date is NULL THEN
			x_rec.creation_date := sysdate ;
		END IF ;

		IF x_rec.last_update_date is NULL THEN
			x_rec.last_update_date := sysdate ;
		END IF ;

		-- Bug 3465939 :Modified code to insert original_encumbrance_item_id
		-- passed by Oracle Labor distribution system/External system.

		insert into gms_transaction_interface_all (
								TXN_INTERFACE_ID,
								BATCH_NAME,
								TRANSACTION_SOURCE,
								EXPENDITURE_ENDING_DATE,
								EXPENDITURE_ITEM_DATE,
								PROJECT_NUMBER,
								TASK_NUMBER,
								AWARD_ID,
								EXPENDITURE_TYPE,
								TRANSACTION_STATUS_CODE,
								ORIG_TRANSACTION_REFERENCE,
								ORG_ID,
								SYSTEM_LINKAGE,
								USER_TRANSACTION_SOURCE,
								TRANSACTION_TYPE,
								BURDENABLE_RAW_COST,
								FUNDING_PATTERN_ID,
								CREATED_BY,
								CREATION_DATE,
								LAST_UPDATED_BY,
								LAST_UPDATE_DATE,
                                                                AWARD_NUMBER  ,-- Fix for bug : 2439320
								ORIGINAL_ENCUMBRANCE_ITEM_ID -- Bug 3465936
							) Values
							(
								x_rec.TXN_INTERFACE_ID,
								x_rec.BATCH_NAME,
								x_rec.TRANSACTION_SOURCE,
								x_rec.EXPENDITURE_ENDING_DATE,
								x_rec.EXPENDITURE_ITEM_DATE,
								x_rec.PROJECT_NUMBER,
								x_rec.TASK_NUMBER,
								x_rec.AWARD_ID,
								x_rec.EXPENDITURE_TYPE,
								x_rec.TRANSACTION_STATUS_CODE,
								x_rec.ORIG_TRANSACTION_REFERENCE,
								x_rec.ORG_ID,
								x_rec.SYSTEM_LINKAGE,
								x_rec.USER_TRANSACTION_SOURCE,
								x_rec.TRANSACTION_TYPE,
								x_rec.BURDENABLE_RAW_COST,
								x_rec.FUNDING_PATTERN_ID,
								x_rec.CREATED_BY,
								x_rec.CREATION_DATE,
								x_rec.LAST_UPDATED_BY,
								x_rec.LAST_UPDATE_DATE,
                                                                x_rec.AWARD_NUMBER  ,-- Fix for bug : 2439320
         					                x_rec.ORIGINAL_ENCUMBRANCE_ITEM_ID -- Bug 3465936
							) ;

	EXCEPTION
		WHEN OTHERS THEN
			  GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
										  x_token_name1   =>  'PROGRAM_NAME', x_token_val1    => 'GMS_TRANSACTIONS_PUB : LOAD_GMS_XFACE_API',
										  x_token_name2   =>  'OERRNO',       x_token_val2    => SQLCODE,
										  x_token_name3   =>  'OERRM',        x_token_val3    => SQLERRM ,
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf
									   ) ;
         		p_outcome := 'GMS_UNEXPECTED_ERROR';
	END LOAD_GMS_XFACE_API ;

	PROCEDURE UPDATE_GMS_XFACE_API ( p_rec gms_transaction_interface_all%ROWTYPE
									 , p_outcome OUT NOCOPY varchar2 ) is
		x_rec gms_transaction_interface_all%ROWTYPE ;
		p_err_code     NUMBER ;
		p_err_buf      varchar2(2000) ;
	BEGIN
		x_rec := p_rec ;

		IF x_rec.created_by is NULL THEN
			x_rec.created_by := nvl(fnd_global.user_id,0) ;
		END IF ;

		IF x_rec.last_updated_by is NULL THEN
			x_rec.last_updated_by := nvl(fnd_global.user_id,0) ;
		END IF ;

		IF x_rec.creation_date is NULL THEN
			x_rec.creation_date := sysdate ;
		END IF ;

		IF x_rec.last_update_date is NULL THEN
			x_rec.last_update_date := sysdate ;
		END IF ;

		-- Bug 3465939 :Modified code to update original_encumbrance_item_id
		-- passed by Oracle Labor distribution system/External system.

		UPDATE gms_transaction_interface_all
		   SET  	BATCH_NAME				= 	x_rec.BATCH_NAME,
					TRANSACTION_SOURCE		= 	x_rec.TRANSACTION_SOURCE,
					EXPENDITURE_ENDING_DATE	= 	x_rec.EXPENDITURE_ENDING_DATE,
					EXPENDITURE_ITEM_DATE	= 	x_rec.EXPENDITURE_ITEM_DATE,
					PROJECT_NUMBER			= 	x_rec.PROJECT_NUMBER,
					TASK_NUMBER				= 	x_rec.TASK_NUMBER,
					AWARD_ID				= 	x_rec.AWARD_ID,
					EXPENDITURE_TYPE		= 	x_rec.EXPENDITURE_TYPE,
					TRANSACTION_STATUS_CODE	= 	x_rec.TRANSACTION_STATUS_CODE,
					ORIG_TRANSACTION_REFERENCE	= 	x_rec.ORIG_TRANSACTION_REFERENCE,
					ORG_ID					= 	x_rec.ORG_ID,
					SYSTEM_LINKAGE			= 	x_rec.SYSTEM_LINKAGE,
					USER_TRANSACTION_SOURCE	= 	x_rec.USER_TRANSACTION_SOURCE,
					TRANSACTION_TYPE		= 	x_rec.TRANSACTION_TYPE,
					BURDENABLE_RAW_COST		= 	x_rec.BURDENABLE_RAW_COST,
					FUNDING_PATTERN_ID		= 	x_rec.FUNDING_PATTERN_ID,
					CREATED_BY				= 	x_rec.CREATED_BY,
					CREATION_DATE			= 	x_rec.CREATION_DATE,
					LAST_UPDATED_BY			= 	x_rec.LAST_UPDATED_BY,
					LAST_UPDATE_DATE		= 	x_rec.LAST_UPDATE_DATE,
                                        AWARD_NUMBER                    =       x_rec.AWARD_NUMBER ,-- Fix for bug : 2439320
                   		        ORIGINAL_ENCUMBRANCE_ITEM_ID    =       x_rec.ORIGINAL_ENCUMBRANCE_ITEM_ID -- Bug 3465936
	     WHERE TXN_INTERFACE_ID = x_rec.TXN_INTERFACE_ID ;

	EXCEPTION
		When others then
			  GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
										  x_token_name1   =>  'PROGRAM_NAME', x_token_val1    => 'GMS_TRANSACTIONS_PUB : UPDATE_GMS_XFACE_API',
										  x_token_name2   =>  'OERRNO',       x_token_val2    => SQLCODE,
										  x_token_name3   =>  'OERRM',        x_token_val3    => SQLERRM ,
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf
									   ) ;
         		p_outcome := 'GMS_UNEXPECTED_ERROR';
	END UPDATE_GMS_XFACE_API ;


	PROCEDURE DELETE_GMS_XFACE_API ( p_rec gms_transaction_interface_all%ROWTYPE
									 , p_outcome OUT NOCOPY varchar2 ) is
		x_rec gms_transaction_interface_all%ROWTYPE ;
		p_err_code     NUMBER ;
		p_err_buf      varchar2(2000) ;
	BEGIN
		x_rec	:= p_rec ;

		delete from gms_transaction_interface_all
		 WHERE  TXN_INTERFACE_ID = x_rec.TXN_INTERFACE_ID ;

	EXCEPTION
		When others then
			  GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
										  x_token_name1   =>  'PROGRAM_NAME', x_token_val1    => 'GMS_TRANSACTIONS_PUB : DELETE_GMS_XFACE_API',
										  x_token_name2   =>  'OERRNO',       x_token_val2    => SQLCODE,
										  x_token_name3   =>  'OERRM',        x_token_val3    => SQLERRM ,
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf
									   ) ;
         		p_outcome := 'GMS_UNEXPECTED_ERROR';
	END DELETE_GMS_XFACE_API ;

    -- -------------------------------------------------------------------
    -- Validations for award distributions for default award -999
    -- -------------------------------------------------------------------
    PROCEDURE
     DIST_AWARD_VALIDATIONS         (P_project_id               	IN NUMBER
           							,  P_task_id              		IN NUMBER
    								,  P_award_id		         	IN NUMBER
           							,  P_expenditure_type      	 	IN VARCHAR2
           							,  P_expenditure_item_date  	IN DATE
           							,  x_err_code        		IN OUT NOCOPY NUMBER
                                    ,  x_err_buff           	IN OUT NOCOPY VARCHAR2
									,  p_outcome				   OUT NOCOPY VARCHAR2) IS


    -- =================================================================================
    -- BUG: 3358176 Award Distribution not recognized for sub tasks when funding
    -- pattern is defined at top task level.
    -- top_task_id and pa_tasks join was added.
    -- =================================================================================
         CURSOR FUND_PATTERN_EXIST IS
                select fp.funding_name,
                       fp.funding_pattern_id
                  from gms_funding_patterns_all fp,
		       pa_tasks t
                 where nvl(fp.retroactive_flag, 'N') = 'N'
                   and NVL(fp.status, 'N')           = 'A'
                   and fp.project_id                 = p_project_id
		   and t.task_id                     = p_task_id
                   and fp.task_id                    = t.top_task_id
                   and P_expenditure_item_date between fp.start_date and NVL(fp.end_date, P_expenditure_item_date )
                 union
                select gfpa.funding_name,
                       gfpa.funding_pattern_id
                  from gms_funding_patterns_all gfpa
                 where nvl(gfpa.retroactive_flag, 'N') = 'N'
                   and NVL(gfpa.status, 'N')           = 'A'
                   and gfpa.project_id                 = p_project_id
                   and gfpa.task_id is null
                   and not exists (select '1' from gms_funding_patterns_all b, pa_tasks t
                                                where gfpa.project_id = b.project_id
						and nvl(b.status,'x') = 'A'
						and t.task_id         = p_task_id
                                                and b.task_id         = t.top_task_id)
                   and P_expenditure_item_date between start_date and NVL(end_date, P_expenditure_item_date )
                   order by 1;


               x_funding_pattern_id     NUMBER;
               x_funding_name           VARCHAR2(100);


         CURSOR GET_FP_AWARDS(x_funding_pattern_id number) IS
			Select 	a.Allowable_Schedule_Id,
					nvl(a.Preaward_Date,a.START_DATE_ACTIVE) awd_Date,
					a.End_Date_Active,
					a.Close_Date,
					a.Status
			from 	GMS_AWARDS a,
                    gms_fp_distributions b
			where 	a.award_id =  b.award_id
            and     b.funding_pattern_id = x_funding_pattern_id;


              X_Allowable_Schedule_Id   NUMBER(15);
		      X_Preaward_Date 		    DATE;
		      X_End_Date   			    DATE;
		      X_Close_Date 			    DATE;
		      X_Status     			    VARCHAR2(30);



            INVALID_FUNDING_PATTERN     EXCEPTION;
            INVALID_EXP_ITEM_DATE       EXCEPTION;
            INVALID_EXP_ITEM_DATE_1     EXCEPTION;
            INVALID_EXP_ITEM_DATE_2     EXCEPTION;
            INVALID_EXP_ITEM_DATE_3     EXCEPTION;

            X_Failed_test               BOOLEAN ;
            X_Failed_test_1             BOOLEAN ;
            X_Failed_test_2             BOOLEAN ;
            X_Failed_test_3             BOOLEAN ;

            x_error_program_name     VARCHAR2 ( 30 );
            x_error_procedure_name   VARCHAR2 ( 30 );
            x_error_stage            VARCHAR2 ( 30 );

    BEGIN
            x_error_program_name     := 'GMS_TRANSACTIONS_PUB';

            x_error_procedure_name := 'DIST_AWARD_VALIDATIONS';
            -- ------------------------------------------------------------------
            -- Check if a funding pattern exists for the project,task combination
            -- Check if the expenditure type exists in the allowed cost schedule
            -- for the award.
            -- ------------------------------------------------------------------
                x_error_stage:= 'FUND_PATTERN_EXIST';

				if PA_TRX_IMPORT.Get_GVal_ProjTskEi_Date ='N' then --Added for bug6931778
                    return;
			    end if;


                OPEN FUND_PATTERN_EXIST ;

                FETCH FUND_PATTERN_EXIST
                 into x_funding_name,
                      x_funding_pattern_id ;

                IF    FUND_PATTERN_EXIST%NOTFOUND THEN
                    CLOSE FUND_PATTERN_EXIST ;
                    RAISE INVALID_FUNDING_PATTERN;
                END IF ;

                CLOSE FUND_PATTERN_EXIST ;

                X_failed_test   := FALSE;
                X_failed_test_1 := FALSE;
                X_failed_test_2 := FALSE;
                X_failed_test_3 := FALSE;

                FOR FP_REC in  FUND_PATTERN_EXIST LOOP

                        x_error_stage   := 'EXP_ITEM_DATE_VALIDATION';
                        X_failed_test   := FALSE;
                        X_failed_test_1 := FALSE;
                        X_failed_test_2 := FALSE;
                        X_failed_test_3 := FALSE;

                        FOR FP_AWARDS_REC in GET_FP_AWARDS(x_funding_pattern_id) LOOP
	                     IF  PA_TRX_IMPORT.Get_GVal_ProjTskEi_Date ='Y'  THEN -- S.N Bug#4138033
				IF  (P_Expenditure_Item_Date <  TRUNC(fp_awards_rec.awd_Date)) then
                                    x_failed_test_1 := TRUE ;
                                    EXIT ;
                                END IF;

                                IF (P_Expenditure_Item_Date >  TRUNC(fp_awards_rec.End_Date_active)) then
                                   x_failed_test_2 := TRUE ;
                                    EXIT ;
                                END IF;
                                IF (fp_awards_rec.Close_Date < TRUNC(SYSDATE)) then
                                    x_failed_test_3 := TRUE ;
                                    EXIT ;
                                END IF;
                            END IF;
			 END LOOP;

						 IF X_failed_test_1 OR X_failed_test_2 OR X_failed_test_3 THEN
							X_failed_test	:= TRUE ;
						 END IF ;

                        IF not X_failed_test THEN
                            EXIT ;
                        END IF ;

                END LOOP;

                IF X_failed_test_1 THEN
                    RAISE INVALID_EXP_ITEM_DATE_1;
                END IF ;

                IF X_failed_test_2 THEN
                    RAISE INVALID_EXP_ITEM_DATE_2;
                END IF ;

                IF X_failed_test_3 THEN
                    RAISE INVALID_EXP_ITEM_DATE_3;
                END IF ;

        x_err_code := 0;
    EXCEPTION
      		WHEN INVALID_FUNDING_PATTERN THEN
			    GMS_ERROR_PKG.gms_message( 	x_err_name => 'GMS_INVALID_FUNDING_PATTERN',
										  	x_err_code      => x_err_code,
									     	x_err_buff      => x_err_buff) ;

         		P_outcome := FND_MESSAGE.GET;

      		WHEN INVALID_EXP_ITEM_DATE THEN
			    GMS_ERROR_PKG.gms_message( 	x_err_name => 'GMS_EXP_ITEM_DATE_INVALID',
										  	x_err_code      => x_err_code,
										   	x_err_buff      => x_err_buff) ;

         		P_outcome := FND_MESSAGE.GET;

            WHEN INVALID_EXP_ITEM_DATE_1 THEN
			    GMS_ERROR_PKG.gms_message( 	x_err_name => 'GMS_EXP_ITEM_DT_BEFORE_AWD_ST',
										  	x_err_code      => x_err_code,
										   	x_err_buff      => x_err_buff) ;

         		P_outcome := FND_MESSAGE.GET;

            WHEN INVALID_EXP_ITEM_DATE_2 THEN
			    GMS_ERROR_PKG.gms_message( 	x_err_name => 'GMS_EXP_ITEM_DT_AFTER_AWD_END',
										  	x_err_code      => x_err_code,
										   	x_err_buff      => x_err_buff) ;

         		P_outcome := FND_MESSAGE.GET;

            WHEN INVALID_EXP_ITEM_DATE_3 THEN
			    GMS_ERROR_PKG.gms_message( 	x_err_name => 'GMS_AWARD_IS_CLOSED',
										  	x_err_code      => x_err_code,
										   	x_err_buff      => x_err_buff) ;

         		P_outcome := FND_MESSAGE.GET;

        WHEN OTHERS THEN
        gms_error_pkg.gms_message ( x_err_name=> 'GMS_UNEXPECTED_ERROR',
            x_token_name1              => 'PROGRAM_NAME',
            x_token_val1               => x_error_program_name || '.' || x_error_procedure_name || '.' || x_error_stage,
            x_token_name2              => 'SQLCODE',
            x_token_val2               => SQLCODE,
            x_token_name3              => 'SQLERRM',
            x_token_val3               => SQLERRM,
            x_err_code                 => x_err_code,
            x_err_buff                 => x_err_buff );

    END DIST_AWARD_VALIDATIONS;
	----------------------------------------------------------------------
	-- Please refer to package spec for detailed description of the
	-- procedure.
	----------------------------------------------------------------------

	PROCEDURE validate_transaction( P_project_id               IN NUMBER
           							,  P_task_id              IN NUMBER
    								,  P_award_id		         IN NUMBER
           							,  P_expenditure_type       IN VARCHAR2
           							,  P_expenditure_item_date  IN DATE
									,  P_calling_module IN VARCHAR2
           							,  P_OUTCOME        OUT NOCOPY VARCHAR2)
	IS

		CURSOR GET_VALID_AWARDS IS
			Select 	Allowable_Schedule_Id,
					nvl(Preaward_Date,START_DATE_ACTIVE),
					End_Date_Active,
					Close_Date,
					Status
			from 	GMS_AWARDS
			where 	award_id =  P_award_id;
			--where 	award_id = to_number( P_award_id);

		X_Allowable_Schedule_Id NUMBER(15);

		X_Preaward_Date 		DATE;
		X_End_Date   			DATE;
		X_Close_Date 			DATE;

		X_Status     			VARCHAR2(30);

		--
		-- BUG: 3628884 Performance issue due to non mergable view.
		--
		CURSOR GET_FUNDING_AWARD IS
                        select aw.award_id award_id
                          from pa_tasks t ,
	                       gms_installments ins,
	                       gms_summary_project_fundings su,
		               gms_budget_versions bv,
			       gms_awards aw
			 where bv.budget_status_code     = 'B'
			   and bv.project_id             = P_Project_Id
			   and bv.award_id               = P_award_id
			   and su.project_id             = bv.project_id
			   and t.project_id              = bv.project_id
			   and t.task_id                 = P_Task_Id
			   and ((su.task_id= t.task_id) or (su.task_id is null) or (su.task_id = t.top_task_id ) )
			   and ins.installment_id        = su.installment_id
			   and ins.award_id              = aw.award_id
			   and aw.award_id               = P_award_id
		           and aw.status                <> 'CLOSED'
		           and aw.award_template_flag    = 'DEFERRED' ;

			--Select 	award_id
			--from 	GMS_AWARDS_BASIC_V
			--where 	project_id 	 = P_Project_Id
			--and 	task_id      = P_Task_Id
			--and 	award_id     = P_award_id;
			--and 	award_id     = to_number(P_award_id);

		Funding_Award_Id  NUMBER(15);

		CURSOR GET_EXP_TYPE IS
		Select 	Expenditure_Type
		from 	GMS_ALLOWABLE_EXPENDITURES
		where 	ALLOWABILITY_SCHEDULE_ID = X_Allowable_Schedule_Id and
				EXPENDITURE_TYPE         = P_expenditure_type;

		St_Expenditure_Type         VARCHAR2(30);




		AWARD_IS_REQUIRED           EXCEPTION;
		NOT_FUNDING_AWARD           EXCEPTION;
		INVALID_AWARD_SCHEDULE      EXCEPTION;
		INVALID_EXP_TYPE            EXCEPTION;
		AWARD_NOT_ALLOWED           EXCEPTION;
		EXP_ITEM_DATE_INVALID       EXCEPTION;
               INVALID_AWARD                EXCEPTION; --bug 2305262
        EXP_ITEM_DATE_INVALID_1     EXCEPTION;
        EXP_ITEM_DATE_INVALID_2     EXCEPTION;
        EXP_ITEM_DATE_INVALID_3     EXCEPTION;
		AWARD_NOT_ACTIVE            EXCEPTION;
		p_err_code     NUMBER ;
		p_err_buf      varchar2(2000) ;
        imp_award_id    NUMBER;
	BEGIN
  			fnd_msg_pub.initialize;

  			P_outcome := NULL;

			If (P_Calling_Module =  'PAVVIT' ) then
				RETURN ;
			END IF ;

			if PA_TRX_IMPORT.Get_GVal_ProjTskEi_Date ='N' then --Added for bug6931778
                return;
			end if;

            set_award;

            if g_award_distribution_option = 'Y'THEN


                IF P_AWARD_ID = g_award_id THEN
                     DIST_AWARD_VALIDATIONS (P_project_id
           							,  P_task_id
    								,  P_award_id
           							,  P_expenditure_type
           							,  P_expenditure_item_date
           							,  p_err_code
                                    ,  p_err_buf
									,  p_outcome );
					RETURN ;
                END IF ;
            end if;
			-- ===========================
			-- Check if GMS is enabled
			-- ===========================

			IF not gms_install.enabled THEN
				return ;
			END IF ;

			If NOT AWARD_REQUIRED(P_Task_Id,P_Outcome) then

 						If ( P_award_id is NOT NULL )  then
     						RAISE AWARD_NOT_ALLOWED;
						ELSE
						    -- =====================================================
						    -- BUG : 3008734
						    -- GMS Validation failed for non sponsored project.
						    -- =====================================================
							return ;
 						End If;

			End If; --End for AWARD_REQUIRED Check

			-- -------------------------------------
			-- Award is REQUIRED..
			-- -------------------------------------

   			/* If Award is required then Attribute1 should not be null */
     		Begin
        		If ( P_award_id is NULL) then
            		RAISE AWARD_IS_REQUIRED;
        		End If;
     		End;

			-- ----------------------------
			-- Check for valid award.
			-- ---------------------------

     		Begin

     			open GET_VALID_AWARDS;
     			Fetch 	GET_VALID_AWARDS
       			into 	X_Allowable_Schedule_Id,
       					X_Preaward_Date,
       					X_End_Date,
       					X_Close_Date,
       					X_Status;

      			/* Check for Valid Award */
       			If GET_VALID_AWARDS%NOTFOUND  THEN
       				RAISE INVALID_AWARD; -- bug 2305262
       			End If;

       			CLOSE GET_VALID_AWARDS;
     		End;
			-- ======== End of valid award ============

			--------------------------------------------------
     		/* Check for Valid Expenditure Item Date */
		-- The following validation should NOT be performed if the
		-- calling module is GMS-SSP since we don't have the expenditure_item_date
		-- while calling this from SSP.


		IF  PA_TRX_IMPORT.Get_GVal_ProjTskEi_Date ='Y'  THEN   -- S.N Bug#4138033

                   If (P_Expenditure_Item_Date <  TRUNC(X_Preaward_Date))then
	           		RAISE EXP_ITEM_DATE_INVALID_1;
                   End If;

                   If 	(P_Expenditure_Item_Date >  TRUNC(X_End_Date)) then
       	       		        RAISE EXP_ITEM_DATE_INVALID_2;
                   End If;

                   If (X_Close_Date < TRUNC(SYSDATE)) then
	        		RAISE EXP_ITEM_DATE_INVALID_3;
                   End If;

               END IF; -- E.N Bug#4138033
			-- ==== End of Expenditure Item Date  check ==========

			--------------------------------------------------
      		/* Check for Award Status */
       		If X_Status not in ('ACTIVE','AT_RISK') then
       			RAISE AWARD_NOT_ACTIVE;
       		End If;
			-- ====== End of Award Status check =============

			--------------------------------------------------
      		/* Check to see if Award is funding Project */
     		Begin

       			Open GET_FUNDING_AWARD;
       			Fetch 	GET_FUNDING_AWARD
       			into 	Funding_Award_Id;

       			If GET_FUNDING_AWARD%NOTFOUND THEN
       				RAISE NOT_FUNDING_AWARD;
       			End If;

       			CLOSE GET_FUNDING_AWARD;
     		End;
			-- ========= End Of Award is funding Project check ===========


			-------------------------------------------------------
     		/* Check for Valid Expenditure Type (Should be in the Allowability Schedule) */
     		Begin
           		open GET_EXP_TYPE;

           		Fetch GET_EXP_TYPE
           		into  St_Expenditure_Type;

           		If GET_EXP_TYPE%NOTFOUND  then
               		RAISE INVALID_EXP_TYPE;
           		End If;

           		CLOSE GET_EXP_TYPE;
     		End;
			-- ======== End of  Valid Expenditure Type check ==============

    EXCEPTION
      		WHEN  AWARD_IS_REQUIRED THEN
			    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_AWARD_REQUIRED',
										  x_err_code      =>  p_err_code,
                                          x_err_buff      => p_err_buf) ;
         		P_outcome := FND_MESSAGE.GET;

				-- ==============================================================
				-- BUG: 1961436 (PA/GMS IMPORT DOES NOT GIVE SPECIFIC REASON CODE
				-- FOR REJECTED INTERFACE TXNS.
				-- ==============================================================
				IF P_calling_module in ( 'PSPLDCDB', 'PSPLDPGB','PSPENLNB' ,'TXNVALID','APTXNIMP') THEN  --bug:6817867
					p_outcome := 'GMS_AWARD_REQUIRED' ;
				END IF ;

      		WHEN NOT_FUNDING_AWARD THEN
			    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_NOT_FUNDING_AWARD',
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf) ;
         		P_outcome := FND_MESSAGE.GET;

				IF P_calling_module in ( 'PSPLDCDB', 'PSPLDPGB','PSPENLNB','PAXTTRXB','TXNVALID','APTXNIMP') THEN  --bug:6817867
					p_outcome := 'GMS_NOT_FUNDING_AWARD' ;
				END IF ;


      		WHEN  INVALID_AWARD THEN    -- Change from INVALID_AWARD_SECHEDULE for bug 2305262
			    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_INVALID_AWARD',
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf) ;
         		P_outcome := FND_MESSAGE.GET;

				IF P_calling_module in ( 'PSPLDCDB', 'PSPLDPGB','PSPENLNB','PAXTTRXB','TXNVALID' ,'APTXNIMP') THEN  --bug:6817867
	          		p_outcome := 'GMS_INVALID_AWARD' ; -- Change from GMS_INV_AWARD_SCHEDULE bug 2305262
				END IF ;

      		WHEN INVALID_EXP_TYPE THEN
			    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_INVALID_EXP_TYPE',
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf) ;
         		P_outcome := FND_MESSAGE.GET;

				IF P_calling_module in ( 'PSPLDCDB', 'PSPLDPGB','PSPENLNB','PAXTTRXB','TXNVALID','APTXNIMP') THEN  --bug:6817867
					p_outcome := 'GMS_INVALID_EXP_TYPE' ;
				END IF ;


      		WHEN AWARD_NOT_ALLOWED THEN
			    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_NOT_A_SPONSORED_PROJECT',
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf) ;
         		P_outcome := FND_MESSAGE.GET;

				IF P_calling_module in ( 'PSPLDCDB', 'PSPLDPGB','PSPENLNB','PAXTTRXB','TXNVALID' ,'APTXNIMP') THEN  --bug:6817867
					p_outcome := 'GMS_NOT_A_SPONSORED_PROJECT' ;
				END IF ;


      		WHEN EXP_ITEM_DATE_INVALID THEN
			    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_EXP_ITEM_DATE_INVALID',
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf) ;
         		P_outcome := FND_MESSAGE.GET;

				IF P_calling_module in ( 'PSPLDCDB', 'PSPLDPGB','PSPENLNB','PAXTTRXB','TXNVALID','APTXNIMP') THEN  --bug:6817867
					p_outcome := 'GMS_EXP_ITEM_DATE_INVALID' ;
				END IF ;


            WHEN EXP_ITEM_DATE_INVALID_1 THEN
			    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_EXP_ITEM_DT_BEFORE_AWD_ST',
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf) ;
         		P_outcome := FND_MESSAGE.GET;

				IF P_calling_module in ( 'PSPLDCDB', 'PSPLDPGB','PSPENLNB','PAXTTRXB','TXNVALID','APTXNIMP') THEN  --bug:6817867
					p_outcome := 'GMS_EXP_ITEM_DT_BEFORE_AWD_ST' ;
				END IF ;


            WHEN EXP_ITEM_DATE_INVALID_2 THEN
			    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_EXP_ITEM_DT_AFTER_AWD_END',
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf) ;
         		P_outcome := FND_MESSAGE.GET;

				IF P_calling_module in ( 'PSPLDCDB', 'PSPLDPGB','PSPENLNB','PAXTTRXB','TXNVALID','APTXNIMP') THEN  --bug:6817867
					p_outcome := 'GMS_EXP_ITEM_DT_AFTER_AWD_END' ;
				END IF ;


            WHEN EXP_ITEM_DATE_INVALID_3 THEN
			    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_AWARD_IS_CLOSED',
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf) ;
         		P_outcome := FND_MESSAGE.GET;

				IF P_calling_module in ( 'PSPLDCDB', 'PSPLDPGB','PSPENLNB','PAXTTRXB','TXNVALID','APTXNIMP') THEN  --bug:6817867
					p_outcome := 'GMS_AWARD_IS_CLOSED' ;
				END IF ;


      		WHEN AWARD_NOT_ACTIVE THEN
			    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_AWARD_NOT_ACTIVE',
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf
									   ) ;
            	P_outcome := FND_MESSAGE.GET;

				IF P_calling_module in ( 'PSPLDCDB', 'PSPLDPGB','PSPENLNB','PAXTTRXB','TXNVALID','APTXNIMP') THEN  --bug:6817867
					p_outcome := 'GMS_AWARD_NOT_ACTIVE' ;
				END IF ;


      		WHEN OTHERS THEN
		  GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
										  x_token_name1   =>  'PROGRAM_NAME', x_token_val1    => 'GMS_TRANSACTIONS_PUB : VALIDATE_TRANSACTION',
										  x_token_name2   =>  'OERRNO',       x_token_val2    => SQLCODE,
										  x_token_name3   =>  'OERRM',        x_token_val3    => SQLERRM ,
										  x_err_code      =>  p_err_code,     x_err_buff      => p_err_buf
									   ) ;
				RAISE ;
  	END VALIDATE_TRANSACTION;
	-- =============== End Of VALIDATE_TRANSACTION ===========================

        FUNCTION  IS_SPONSORED_PROJECT( x_project_id in NUMBER ) return BOOLEAN
        is
                cursor C_spon_project is
                        select pt.sponsored_flag
                          from pa_projects_all b,
                               gms_project_types pt
                         where b.project_id     = X_project_id
                           and b.project_type   = pt.project_type
                           and pt.sponsored_flag = 'Y' ;

                x_return  BOOLEAN ;
                x_flag    varchar2(1) ;
        BEGIN

                x_return := FALSE ;

                open C_spon_project ;
                fetch C_spon_project into x_flag ;
                close C_spon_project ;

                IF nvl(x_flag, 'N') = 'Y' THEN
                   x_return := TRUE ;
                END IF ;

                return x_return ;

        END IS_SPONSORED_PROJECT ;


        PROCEDURE validate_award ( X_project_id         IN NUMBER,
                                   X_task_id            IN NUMBER,
                                   X_award_id           IN NUMBER,
                                   X_award_number       IN VARCHAR2,
                                   X_expenditure_type   IN VARCHAR2,
                                   X_expenditure_item_date IN DATE,
                                   X_calling_module     IN VARCHAR2,
                                   X_status             IN OUT NOCOPY VARCHAR2,
                                   X_err_msg            OUT NOCOPY VARCHAR2 ) is -- return boolean is

	l_project_type_class_code 	varchar2(30);
	l_row_found		 	varchar2(1);
	l_award_id			NUMBER ;

	cursor valid_award_csr is
	select 	'Y'
	from 	dual
	where exists
		(select 1
		from gms_awards
		where award_number = X_award_number
		and   nvl(award_id,0) = nvl(l_award_id,0));


	BEGIN

		-- ==============================================================
		-- Do not proceed if grants is not enabled for an implementation
		-- Org.
		-- ==============================================================
		IF not gms_install.enabled then
			return ;
		END IF ;


		-- ============================================
		-- No need to proceed if project/award details
		-- are null.
		-- ============================================
		IF x_project_id	is NULL AND
		   x_award_id	is NULL AND
		   x_award_number is NULL THEN

		   return ;
		END IF ;

		IF (x_award_number is not null and (x_project_id is null or x_task_id is null
							or x_project_id= 0 or x_task_id = 0))
		then
			fnd_message.set_name('GMS','GMS_INVALID_PROJ_TASK_ID');
			X_status :=  'E';
			X_err_msg :=  fnd_message.get;
			return;

		END IF;

		-- =======================================================
		-- List of validations done here
		-- 1. Check for contract project. contract project shouldn't
		--    entered if grants is enabled.
		-- 2. Nonsponsored project having award should fail.
		-- 3. Invalid award should stop here.
		-- 4. Populate award id if required.
		--    Award id passed null and award_number is not null.
		-- 5. Sponsored project missing award should error out.
		-- 6. Check expenditure type belongs to allowable exp's.
		-- 7. Call gms standard validations defined in
		--    gms_transaction_pub.
		-- ================================================================

		l_award_id := X_award_id ;

		-- 1. Check for contract project. contract project shouldn't
		--    entered if grants is enabled.

		IF X_project_id is not NULL THEN
		begin
			select project_type_class_code
			into   l_project_type_class_code
			from pa_project_types_all a,
			     pa_projects_all b
			where a.project_type = b.project_type
                        and   a.org_id = b.org_id               /*For Bug 5414832*/
			and   b.project_id = X_project_id;

		exception
		   when no_data_found then
			fnd_message.set_name('GMS','GMS_INVALID_PROJ_TASK_ID');
			X_status :=  'E';
			X_err_msg :=  fnd_message.get;
			return;

		END;

		END IF ;

		if l_project_type_class_code = 'CONTRACT' then

			fnd_message.set_name('GMS','GMS_IP_INVALID_PROJ_TYPE');

			X_status :=  'E';
			X_err_msg :=  fnd_message.get;

			return;
		end if;

		IF is_sponsored_project (X_project_id) THEN

		   -- 5. Sponsored project missing award should error out.
		   IF X_award_number is NULL then
			fnd_message.set_name('GMS','GMS_AWARD_REQUIRED');
			X_status :=  'E';
			X_err_msg :=  fnd_message.get;
			return;
		   END IF ;

		ELSE

		   -- 2. Nonsponsored project having award should fail.
		   IF X_award_number is NOT NULL then
			fnd_message.set_name('GMS','GMS_AWARD_NOT_ALLOWED');
			X_status :=  'E';
			X_err_msg :=  fnd_message.get;
			return;
		   ELSIF X_award_number is NULL then
			return;
		   END IF ;

		END IF ;

		-- 3. Populate award id if required.
		--    Award id passed null and award_number is not null.

		l_award_id 	:= X_award_id ;

		if X_award_id is NULL and
		   X_award_number is not NULL then

		   begin
			select 	award_id
			into	l_award_id
			from 	gms_awards
			where 	award_number = X_award_number;

		   exception
		     when no_data_found then
		       fnd_message.set_name('GMS','GMS_INVALID_AWARD');
			X_status :=  'E';
			X_err_msg :=  fnd_message.get;
		       return;
		   end;

		end if;

		-- 4. Invalid award should stop here.

		open valid_award_csr;
		fetch valid_award_csr into l_row_found;
		close valid_award_csr;

		if NVL(l_row_found,'N') <> 'Y' then

			fnd_message.set_name('GMS','GMS_INVALID_AWARD');

			X_status :=  'E';
			X_err_msg :=  fnd_message.get;

			return;

		end if;

		-- 7. Call gms standard validations defined in
		--    gms_transaction_pub.

		gms_transactions_pub.validate_transaction(p_project_id => X_project_id,
							  p_task_id => X_task_id,
							  p_award_id => l_award_id,
							  p_expenditure_type => X_expenditure_type,
							  p_expenditure_item_date => X_expenditure_item_date,
							  p_calling_module => X_calling_module,
							  p_outcome => X_err_msg );

		if X_err_msg is NOT NULL then

			X_status := 'E';
			return;

		end if;

		return;

	END validate_award ;

END GMS_TRANSACTIONS_PUB;

/
