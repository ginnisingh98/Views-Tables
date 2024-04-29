--------------------------------------------------------
--  DDL for Package Body PA_XLA_SWEEP_TXN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_XLA_SWEEP_TXN_PKG" 	PA_XLA_SWEEP_TXN_PKG AS
--  $Header: PACCGLEB.pls 120.6 2005/10/26 03:04:36 rshaik noship $
G_Debug_Mode Varchar2(1);

--Forward declaration
PROCEDURE UPD_BTC_TBC_RELATED_CMT_GLDATE;

Procedure InitPLSQLTab Is
Begin
	g_expenditure_item_id.delete;
	g_adjusted_expenditure_item_id.delete;
	g_system_linkage_function.delete;
	g_PERIOD_ACCRUAL_FLAG.delete;
	g_cdl_rowid.delete;
	g_gl_date_new_tab.delete;
	g_gl_period_new_tab.delete;
	g_line_num.delete;
	-- R12 Funds Management Uptake
	g_cdl_line_type.delete;
	g_liquidate_encum_flag.delete;
        g_buren_Sum_Dest_Run_Id.delete;
	g_document_header_Id.delete;
	g_document_distribution_Id.delete;
	g_expenditure_type.delete;
	g_cdl_acct_event_id.delete;
End;



PROCEDURE Log_Message(p_message in VARCHAR2,
                     p_mode    in NUMBER DEFAULT 0) IS
BEGIN

    If (G_Debug_Mode = 'Y') Then
       pa_cc_utils.log_message(p_message,1);
    End If;

END Log_Message;


Procedure SWEEP_TXNS  (P_ORG_ID    PA_IMPLEMENTATIONS_ALL.ORG_ID%TYPE,
                       P_GL_PERIOD GL_PERIOD_STATUSES.PERIOD_NAME%TYPE,
		       P_TRAN_TYPE VARCHAR2)
Is

	Cursor ACC_EVENT_ERROR(p_start_date date, p_end_date date)
            Is Select EV.Event_Id  From xla_entity_events_v EV
	        where EV.EVENT_DATE between p_start_date and p_end_Date
	          and EV.process_status_code <> 'P'
		  and EV.security_id_int_1 = g_org_id
		  and EV.Application_Id = 275
		  and EV.EVENT_TYPE_CODE IN     ( SELECT EVENT_TYPE_CODE
		                                    from XLA_EVENT_TYPES_VL
						   Where
						    (	(    ENTITY_CODE = 'EXPENDITURES'
							AND  P_TRAN_TYPE = 'EXPENDITURES'
							AND EVENT_CLASS_CODE NOT IN ('BORROWED_AND_LENT',
										     'PRVDR_RECVR_RECLASS')
							)
							OR
							(
							     ENTITY_CODE = 'EXPENDITURES'
							AND  P_TRAN_TYPE = 'CROSSCHARGE'
							AND EVENT_CLASS_CODE IN ('BORROWED_AND_LENT',
										 'PRVDR_RECVR_RECLASS')
							)
							OR
							(
							     ENTITY_CODE = 'REVENUE'
							AND  P_TRAN_TYPE = 'REVENUE'
							)
							OR
							(
							     P_TRAN_TYPE Is Null
							AND  ENTITY_CODE IN ('EXPENDITURES', 'REVENUE')
							)
						     )
						     AND Application_ID = 275

					         );

	l_prof_new_gldate_derivation	Varchar2(1) := 'N';


	p_first_date Date;
	p_last_date  Date;

	l_err_msg       fnd_new_messages.MESSAGE_TEXT%TYPE;
Begin
	pa_debug.set_curr_function('SWEEP_TXNS');

	g_app_id := 101;
	g_org_id := P_ORG_ID;
	g_request_id := fnd_global.conc_request_id;

	g_tran_type := P_TRAN_TYPE;

	If G_debug_mode is NULL Then
		 fnd_profile.get('PA_DEBUG_MODE',G_debug_mode);
	         G_debug_mode := NVL(G_debug_mode, 'N');
		 pa_debug.set_process(x_process    => 'PLSQL'	  ,
				      x_debug_mode => G_debug_mode);
	End If;

	Select set_of_books_id
	  into g_sob_id
	  from pa_implementations_all where org_id = g_org_id;

	Select START_DATE, End_Date into p_first_date , p_last_date
	  From gl_period_statuses
	 where period_name = P_GL_PERIOD
	   and set_of_books_id = g_sob_id
	   and application_id = g_app_id ;

	g_new_period_date := pa_utils2.get_prvdr_gl_date(p_first_date
							,g_app_id
							,g_sob_id);

	If g_new_period_date Is null Then
		FND_MESSAGE.SET_NAME('PA','PA_SWEEP_NO_GL_PERIOD');
		l_err_msg := FND_MESSAGE.GET;
		app_exception.RAISE_EXCEPTION( exception_text =>l_err_msg);
	End If;

	g_new_period_name := pa_utils2.get_gl_period_name ( g_new_period_date , g_org_id);

	Log_Message ( 'New Period ' || g_new_period_name || ', New Date ' || g_new_period_date );

	Open ACC_EVENT_ERROR (p_first_date, p_last_date);
	Loop
		g_event_tab.delete;

		Log_Message ( 'Before fetching from ACC_EVENT_ERROR bulk size of ' || g_bulk_size);

		Fetch ACC_EVENT_ERROR bulk collect into g_event_tab limit g_bulk_size;

		Log_Message ( 'After fetching from ACC_EVENT_ERROR, total cnt ' || g_event_tab.count );

		If g_event_tab.count = 0 Then
			Exit;
		End If;

		If NVL(P_TRAN_TYPE,'EXPENDITURES') = 'EXPENDITURES' Then
			FORALL i IN 1..g_event_tab.count
				Update PA_COST_DISTRIBUTION_LINES_ALL
				   SET TRANSFER_STATUS_CODE = 'X' ,
				       Request_Id = g_request_id
				  Where Acct_Event_ID = g_event_tab(i);

			Log_Message ( SQL%ROWCOUNT || ' Updated CDLs with X');
		End If;

		If NVL(P_TRAN_TYPE,'CROSSCHARGE') = 'CROSSCHARGE' Then
			FORALL i IN 1..g_event_tab.count
				Update pa_cc_dist_lines
				   SET TRANSFER_STATUS_CODE = 'X' ,
				       Request_Id = g_request_id
				  Where Acct_Event_ID = g_event_tab(i);
			Log_Message ( SQL%ROWCOUNT || ' Updated CCDLs with X');
		End If;

		If NVL(P_TRAN_TYPE,'REVENUE') = 'REVENUE' Then
			FORALL i IN 1..g_event_tab.count
				Update PA_DRAFT_REVENUES_ALL
				   SET TRANSFER_STATUS_CODE = 'X' ,
				       Request_Id = g_request_id
				  Where Event_ID = g_event_tab(i);
			Log_Message ( SQL%ROWCOUNT || ' Updated RDLs with X');
		End If;

		Log_Message ( 'Calling Populate_GL_Dates for GL-DAte Rederivation');

		POPULATE_GL_DATE;

		Log_Message ( 'Returning Populate_GL_Dates');


		FORALL i in 1..g_event_tab.count
				Update XLA_EVENTS
				   Set EVENT_DATE = g_new_period_date		,
				       TRANSACTION_DATE = g_new_period_date	,
	                               LAST_UPDATE_DATE = Sysdate		,
	                               LAST_UPDATED_BY = fnd_global.user_id	,
	                               LAST_UPDATE_LOGIN = fnd_global.user_id	,
				       request_id = g_request_id
				  Where event_id = g_event_tab(i);

		Log_Message ( SQL%ROWCOUNT || ' Event(s) updated.');

		FORALL i in 1..g_event_tab.count
			Update XLA_AE_HEADERS
			   SET ACCOUNTING_DATE = g_new_period_date		,
			       PERIOD_NAME =  g_new_period_name			,
	                       LAST_UPDATE_DATE  = Sysdate			,
	                       LAST_UPDATED_BY = fnd_global.user_id		,
	                       LAST_UPDATE_LOGIN = fnd_global.user_id		,
			       request_id = g_request_id
			  Where event_id = g_event_tab(i);

		Log_Message ( SQL%ROWCOUNT || ' Header(s) updated.');

		Commit;

		Log_Message ( 'Commit Sucessful..');

		If g_event_tab.count < g_bulk_size Then
			Exit;
		End If;

	End Loop;

	Close ACC_EVENT_ERROR;

	pa_debug.reset_curr_function;

	Log_Message ( 'Exiting...');
Exception
  When Others Then
	Raise;
End SWEEP_TXNS;



Procedure Populate_Gl_Date
Is
		Cursor c_sel_cdl Is
	        SELECT
	                ei.expenditure_item_id,
	                cdl.billable_flag,
	                cdl.line_type,
			cdl.line_num,
	                ei.transaction_source,
	                tr.gl_accounted_flag,
	                ei.denom_currency_code,
	                ei.acct_currency_code,
	                ei.acct_rate_date,
	                ei.acct_rate_type,
	                ei.acct_exchange_rate,
	                ei.project_currency_code,
	                ei.project_rate_date,
	                ei.project_rate_type,
	                ei.project_exchange_rate,
	                tr.system_linkage_function,
	                ei.projfunc_currency_code,
	                ei.projfunc_cost_rate_date,
	                ei.projfunc_cost_rate_type,
	                ei.projfunc_cost_exchange_rate,
	                ei.work_type_id
	        FROM  pa_expenditure_items_all ei,
	              pa_cost_distribution_lines_all cdl,
	              pa_transaction_sources tr
	        WHERE tr.transaction_source(+) = ei.transaction_source
	        AND   ei.expenditure_item_id = cdl.expenditure_item_id
	        AND   CDL.Transfer_Status_Code = 'Y'
		AND   CDL.request_id = g_request_id;


		Cursor CDL_CUR Is
		Select
			ei.expenditure_item_id			,
			ei.adjusted_expenditure_item_id		,
			ei.system_linkage_function		,
			exp_grp.PERIOD_ACCRUAL_FLAG		,
			rowidtochar(CDL.rowid)		 ROW_ID ,
			cdl.line_num				,
			g_new_period_date		 GL_DATE,
	                g_new_period_name	  GL_PERIOD_NAME,
			cdl.recvr_gl_date			,
			IMP.set_of_books_id	    recvr_sob_id,
			nvl(EI.recvr_org_id,CDL.org_id)  recvr_org_id,
			-- R12 Funds Management uptake
			cdl.line_type                           ,
			cdl.liquidate_encum_flag                ,
			ei.Burden_Sum_Dest_Run_Id               ,
			ei.document_header_id                   ,
                        ei.document_distribution_id             ,
			ei.expenditure_type                     ,
			cdl.Acct_Event_ID
	         From PA_Cost_Distribution_lines_ALL CDL,
		      PA_Expenditure_items_all EI,
		      PA_IMPLEMENTATIONS_ALL IMP ,
		      PA_EXPENDITURES_ALL EXP ,
		      PA_EXPENDITURE_GROUPS_ALL EXP_GRP
	        Where CDL.Transfer_Status_Code  = 'X'
	          AND CDL.expenditure_item_id   = EI.expenditure_item_id
		  AND nvl(EI.recvr_org_id,CDL.org_id) = IMP.ORG_ID
		  AND EXP.EXPENDITURE_ID        = EI.EXPENDITURE_ID
		  AND EXP_GRP.EXPENDITURE_GROUP = EXP.EXPENDITURE_GROUP
		  AND EXP_GRP.ORG_ID		= EXP.ORG_ID
		  AND CDL.REQUEST_ID		= g_request_id
		  AND CDL.ORG_ID = g_org_id
		  AND EI.ORG_ID = g_org_id ;





	l_err_code              NUMBER ;
	l_err_stage             VARCHAR2(2000);
	l_err_stack             VARCHAR2(255) ;

Begin

	pa_debug.set_curr_function('Populate_Gl_Date');

	If NVL(g_tran_type,'EXPENDITURES') = 'EXPENDITURES' Then

	Open CDL_CUR;
	Loop
		 InitPLSQLTab;

		 log_message ('Before Fetching from CDL_CUR, Bulk Size ' || g_cdl_bulk_size);

		 Fetch CDL_CUR Bulk Collect INTO
					g_expenditure_item_id			,
					g_adjusted_expenditure_item_id		,
					g_system_linkage_function		,
					g_PERIOD_ACCRUAL_FLAG			,
					g_cdl_rowid				,
					g_line_num				,
					g_gl_date_new_tab			,
					g_gl_period_new_tab			,
					g_recvr_gl_date_new_tab			,
					g_recvr_sob_id				,
					g_recvr_org_id                          ,
					-- R12 Funds Management uptake
					g_cdl_line_type                         ,
					g_liquidate_encum_flag                  ,
					g_buren_Sum_Dest_Run_Id                 ,
					g_document_header_Id                    ,
                                        g_document_distribution_id              ,
					g_expenditure_type                      ,
					g_cdl_acct_event_id
					limit g_cdl_bulk_size;

		 log_message ('After Fetching from CDL_CUR, CDL(s) Fetched = ' || g_expenditure_item_id.count );

		 If g_expenditure_item_id.count = 0 then
			Exit;
		 End If;

		 FOR i in 1..g_expenditure_item_id.count
		 Loop
			    If g_recvr_sob_id(i) <> g_sob_id  Then

				    log_message ('Reciever SOB , Provider SOB different. Deriving GL-Date for Reciever SOB ');

				    g_recvr_gl_date_new_tab(i) := pa_utils2.get_recvr_gl_date
							(
							g_recvr_gl_date_new_tab(i),
							g_app_id,
							g_recvr_sob_id(i)
							) ;

				    g_recvr_gl_period_new_tab(i) := pa_utils2.get_gl_period_name(
												g_recvr_gl_date_new_tab(i),
												g_recvr_org_id(i)
											     ) ;

				    log_message ('Reciever GL_Date Derived = ' || g_recvr_gl_date_new_tab(i) || ' : ' || g_recvr_gl_period_new_tab(i));
			    Else
				    g_recvr_gl_date_new_tab(i) := g_new_period_date;
				    g_recvr_gl_period_new_tab(i) := g_new_period_name;
			    End If;

		 End Loop;


		log_message ('Updating CDLs with TSC = A if Not Summarised, Y if Summarised');

		 FORALL i IN 1..g_expenditure_item_id.count
			UPDATE PA_Cost_Distribution_lines_ALL CDL
			   SET CDL.request_id = g_request_id,
			       CDL.transfer_status_code = DECODE(g_gl_date_new_tab(i),
									NULL,'R', DECODE(g_recvr_gl_date_new_tab(i)
											,NULL,'R',
											DECODE ( DECODE ( CDL.LINE_TYPE ,'R', CDL.PJI_SUMMARIZED_FLAG, 'N'),
													'N', 'A',
													DECODE (CDL.gl_date,g_gl_date_new_tab(i), 'A','Y')
												)
											)
								)
				,CDL.gl_date        =   DECODE ( DECODE ( CDL.LINE_TYPE ,'R', CDL.PJI_SUMMARIZED_FLAG, 'N'),
								     'N', nvl(g_gl_date_new_tab(i),CDL.gl_date) ,
									CDL.GL_DATE)
				,CDL.gl_period_name =   DECODE ( DECODE ( CDL.LINE_TYPE ,'R', CDL.PJI_SUMMARIZED_FLAG, 'N'),
								     'N', nvl(g_gl_period_new_tab(i),CDL.gl_period_name),
									CDL.gl_period_name)
				,CDL.recvr_gl_date  =   DECODE ( DECODE ( CDL.LINE_TYPE ,'R', CDL.PJI_SUMMARIZED_FLAG, 'N'),
								     'N', nvl(g_recvr_gl_date_new_tab(i),CDL.recvr_gl_date),
									  CDL.recvr_gl_date)
				,CDL.recvr_gl_period_name = DECODE ( DECODE ( CDL.LINE_TYPE ,'R', CDL.PJI_SUMMARIZED_FLAG, 'N'),
									'N', nvl(g_recvr_gl_period_new_tab(i),CDL.recvr_gl_period_name),
									CDL.recvr_gl_period_name)
			WHERE CDL.Expenditure_Item_Id = g_expenditure_item_id(i)
			  AND CDL.Line_nUm = g_line_num(i)
			  AND CDL.Transfer_Status_Code = 'X';

		  log_message ( 'Total CDLs updated ' || SQL%ROWCOUNT);

		  log_message ( 'Call for Pa_Costing.ReverseCdl for CDLs with TSC = Y ');

		  For cdlsel in c_sel_cdl
		  Loop

			log_message ( '....CDL with TSC = Y , Exp Item ID = ' || cdlsel.expenditure_item_id);

			Pa_Costing.ReverseCdl
                                (  X_expenditure_item_id            =>  cdlsel.expenditure_item_id
                                 , X_billable_flag                  =>  cdlsel.billable_flag
                                 , X_amount                         =>  NULL
                                 , X_quantity                       =>  NULL
                                 , X_burdened_cost                  =>  NULL
                                 , X_dr_ccid                        =>  NULL
                                 , X_cr_ccid                        =>  NULL
                                 , X_tr_source_accounted            =>  'Y'
                                 , X_line_type                      =>  cdlsel.line_type
                                 , X_user                           =>  fnd_global.user_id
                                 , X_denom_currency_code            =>  cdlsel.denom_currency_code
                                 , X_denom_raw_cost                 =>  NULL
                                 , X_denom_burden_cost              =>  NULL
                                 , X_acct_currency_code             =>  cdlsel.acct_currency_code
                                 , X_acct_rate_date                 =>  cdlsel.acct_rate_date
                                 , X_acct_rate_type                 =>  cdlsel.acct_rate_type
                                 , X_acct_exchange_rate             =>  cdlsel.acct_exchange_rate
                                 , X_acct_raw_cost                  =>  NULL
                                 , X_acct_burdened_cost             =>  NULL
                                 , X_project_currency_code          =>  cdlsel.project_currency_code
                                 , X_project_rate_date              =>  cdlsel.project_rate_date
                                 , X_project_rate_type              =>  cdlsel.project_rate_type
                                 , X_project_exchange_rate          =>  cdlsel.project_exchange_rate
                                 , X_err_code                       =>  l_err_code
                                 , X_err_stage                      =>  l_err_stage
                                 , X_err_stack                      =>  l_err_stack
                                 , P_Projfunc_currency_code         =>  cdlsel.projfunc_currency_code
                                 , P_Projfunc_cost_rate_date        =>  cdlsel.projfunc_cost_rate_date
                                 , P_Projfunc_cost_rate_type        =>  cdlsel.projfunc_cost_rate_type
                                 , P_Projfunc_cost_exchange_rate    =>  cdlsel.projfunc_cost_exchange_rate
                                 , P_project_raw_cost               =>  null
                                 , P_project_burdened_cost          =>  null
                                 , P_Work_Type_Id                   =>  cdlsel.work_type_id
                                 , P_mode                           =>  'INTERFACE'
				 , X_line_num                       =>  cdlsel.line_num
                                 );

		 End Loop;


		 FORALL i IN 1..g_expenditure_item_id.count
			UPDATE   PA_Cost_Distribution_lines_ALL CDL
			   SET	     CDL.request_id = g_request_id
				    ,CDL.transfer_status_code = 'A'
				    ,CDL.gl_date        = nvl(g_gl_date_new_tab(i),CDL.gl_date)
				    ,CDL.gl_period_name = nvl(g_gl_period_new_tab(i),CDL.gl_period_name)
				    ,CDL.recvr_gl_date  = nvl(g_recvr_gl_date_new_tab(i),CDL.recvr_gl_date)
				    ,CDL.recvr_gl_period_name = nvl(g_recvr_gl_period_new_tab(i),CDL.recvr_gl_period_name)
			    WHERE  CDL.Transfer_Status_Code = 'Y'
			      AND  CDL.reversed_flag is NULL
			      AND  CDL.Expenditure_Item_Id = g_expenditure_item_id(i)
			      AND  CDL.Line_nUm = g_line_num(i);

		 log_message ( SQL%ROWCOUNT  || ' rows updated from TSC = Y to A for PJI Summarized Lines');

                 log_message ( 'Calling UPD_BTC_TBC_RELATED_CMT_GLDATE to stamp GL date on related commitments for BTC and TBC CDLs ');
                 UPD_BTC_TBC_RELATED_CMT_GLDATE;

		 FOR i IN 1..g_expenditure_item_id.count
		 LOOP
			g_currec := i;
			If g_system_linkage_function(i) = 'PJ' and g_PERIOD_ACCRUAL_FLAG(i) = 'Y' Then
				log_message ( 'The EI is from Exp Group with Period Accrual Flag Y ');
				CHECK_MISC_TXNS;
			End If;
		 END LOOP;


		 If g_expenditure_item_id.count < g_cdl_bulk_size Then
			Exit;
		 End If;

	End Loop;

	Close CDL_CUR;

	END IF;

	IF NVL(g_tran_type, 'REVENUE') = 'REVENUE' Then
		Update PA_Draft_Revenues_All
		   set gl_date = g_new_period_date		 ,
	               gl_period_name = g_new_period_name	 ,
		       transfer_status_code = 'A'
		 Where request_id = g_request_id
		   and transfer_status_code = 'X';

		log_message ( SQL%ROWCOUNT || ' RDLs updated for GL-Date Rederivation.');
	End If;

	If NVL(g_tran_type,'CROSSCHARGE') = 'CROSSCHARGE' Then
		Update pa_cc_dist_lines
		   set gl_date = g_new_period_date		 ,
	               gl_period_name =  g_new_period_name	 ,
		       transfer_status_code = 'A'
		 Where request_id = g_request_id
		   and transfer_status_code = 'X';

		log_message ( SQL%ROWCOUNT || ' CCDLs updated for GL-Date Rederivation.');
	End If;

	pa_debug.reset_curr_function;
Exception
  When Others Then
	Raise;
End Populate_Gl_Date;

Procedure CHECK_MISC_TXNS
Is
	v_gl_per_end_dt			 DATE;
	l_adj_exp_item_id		 pa_expenditure_items_all.adjusted_expenditure_item_id%type;
	l_exp_item_id			 pa_expenditure_items_all.expenditure_item_id%type;
	l_gl_date			 DATE;
	l_pji_summarized_flag		 VARCHAR2(1);
	l_prvdr_accr_date		 DATE;
	l_billable_flag			 pa_cost_distribution_lines_all.billable_flag%type;
	l_line_type			 VARCHAR2(1);
	l_line_num			 NUMBER ;
	l_denom_currency_code		 pa_expenditure_items_all.denom_currency_code%type;
	l_acct_currency_code		 pa_expenditure_items_all.acct_currency_code%type;
	l_acct_rate_date		 pa_expenditure_items_all.acct_rate_date%type;
	l_acct_rate_type		 pa_expenditure_items_all.acct_rate_type%type;
	l_acct_exchange_rate		 pa_expenditure_items_all.acct_exchange_rate%type;
	l_project_currency_code		 pa_expenditure_items_all.project_currency_code%type;
	l_project_rate_date		 pa_expenditure_items_all.project_rate_date%type;
	l_project_rate_type		 pa_expenditure_items_all.project_rate_type%type;
	l_project_exchange_rate          pa_expenditure_items_all.project_exchange_rate%type;
	l_projfunc_currency_code         pa_expenditure_items_all.projfunc_currency_code%type;
	l_projfunc_cost_rate_date        pa_expenditure_items_all.projfunc_cost_rate_date%type;
	l_projfunc_cost_rate_type        pa_expenditure_items_all.projfunc_cost_rate_type%type;
	l_projfunc_cost_exchange_rate    pa_expenditure_items_all.projfunc_cost_exchange_rate%type;
	l_work_type_id                   pa_expenditure_items_all.work_type_id%type;


	l_acct_event_id			 pa_cost_distribution_lines_all.acct_event_id%type;
	l_transfer_status_Code		 pa_cost_distribution_lines_all.transfer_status_code%type;
	l_accr_period_name		 pa_cost_distribution_lines_all.gl_period_name%type;

	l_err_code              NUMBER ;
	l_err_stage             VARCHAR2(2000);
	l_err_stack             VARCHAR2(255) ;
	l_org_id		Number;

Begin

	pa_debug.set_curr_function('CHECK_MISC_TXNS');


	SELECT
	        ei.expenditure_item_id,
		ei.adjusted_expenditure_item_id,
		cdl.gl_date,
		cdl.pji_summarized_flag,
                cdl.billable_flag,
                cdl.line_type,
		cdl.line_num,
                ei.denom_currency_code,
                ei.acct_currency_code,
                ei.acct_rate_date,
                ei.acct_rate_type,
                ei.acct_exchange_rate,
                ei.project_currency_code,
                ei.project_rate_date,
                ei.project_rate_type,
                ei.project_exchange_rate,
                ei.projfunc_currency_code,
                ei.projfunc_cost_rate_date,
                ei.projfunc_cost_rate_type,
                ei.projfunc_cost_exchange_rate,
                ei.work_type_id ,
		cdl.acct_event_id ,
		cdl.transfer_status_Code ,
		cdl.org_id
	   INTO l_exp_item_id,
	        l_adj_exp_item_id,
		l_gl_date,
		l_pji_summarized_flag,
		l_billable_flag,
                l_line_type,
		l_line_num,
                l_denom_currency_code,
                l_acct_currency_code,
                l_acct_rate_date,
                l_acct_rate_type,
                l_acct_exchange_rate,
                l_project_currency_code,
                l_project_rate_date,
                l_project_rate_type,
                l_project_exchange_rate,
                l_projfunc_currency_code,
                l_projfunc_cost_rate_date,
                l_projfunc_cost_rate_type,
                l_projfunc_cost_exchange_rate,
                l_work_type_id,
		l_acct_event_id,
		l_transfer_status_code,
		l_org_id
	   FROM PA_COST_DISTRIBUTION_LINES_ALL CDL,
	        PA_EXPENDITURE_ITEMS_ALL EI
          WHERE CDL.EXPENDITURE_ITEM_ID = EI.EXPENDITURE_ITEM_ID
	    AND EI.ADJUSTED_EXPENDITURE_ITEM_ID = g_expenditure_item_id(g_currec);

	log_message ('Deriving Next Period for Reversing EI');

	SELECT GPS.start_date
          INTO l_prvdr_accr_date
          FROM gl_period_statuses GPS
         WHERE GPS.application_id = 101
           AND GPS.set_of_books_id = g_sob_id
           AND  GPS.adjustment_period_flag = 'N'
           AND  GPS.start_date = (SELECT min(GPS1.start_date)
                                    FROM gl_period_statuses GPS1
                                   WHERE GPS1.application_id = 101
                                     AND GPS1.set_of_books_id = g_sob_id
                                     AND GPS1.adjustment_period_flag = 'N'
                                     AND GPS1.start_date > g_gl_date_new_tab(g_currec)
				 );

	l_prvdr_accr_date := pa_utils2.get_prvdr_gl_date(l_prvdr_accr_date
							,g_app_id
							,g_sob_id);


	log_message ('Reversing EI ' || l_exp_item_id || ' of ' || g_expenditure_item_id(g_currec) ||
	' re-derived with ' || l_prvdr_accr_date );

	IF (l_pji_summarized_flag  = 'N') THEN

		   UPDATE PA_Cost_Distribution_lines_ALL CDL
	              SET CDL.gl_date = l_prvdr_accr_date
		    WHERE CDL.EXPENDITURE_ITEM_ID = l_exp_item_id;


		   log_message ('Reversing EI is not PJI Summarised. Updated with new GL-Date');

	ELSE

		  log_message ('Reversing EI is PJI Summarised. Creating I Lines....');

		   Pa_Costing.ReverseCdl
                                (  X_expenditure_item_id            =>  l_exp_item_id
                                 , X_billable_flag                  =>  l_billable_flag
                                 , X_amount                         =>  NULL
                                 , X_quantity                       =>  NULL
                                 , X_burdened_cost                  =>  NULL
                                 , X_dr_ccid                        =>  NULL
                                 , X_cr_ccid                        =>  NULL
                                 , X_tr_source_accounted            =>  'Y'
                                 , X_line_type                      =>  l_line_type
                                 , X_user                           =>  fnd_global.user_id
                                 , X_denom_currency_code            =>  l_denom_currency_code
                                 , X_denom_raw_cost                 =>  NULL
                                 , X_denom_burden_cost              =>  NULL
                                 , X_acct_currency_code             =>  l_acct_currency_code
                                 , X_acct_rate_date                 =>  l_acct_rate_date
                                 , X_acct_rate_type                 =>  l_acct_rate_type
                                 , X_acct_exchange_rate             =>  l_acct_exchange_rate
                                 , X_acct_raw_cost                  =>  NULL
                                 , X_acct_burdened_cost             =>  NULL
                                 , X_project_currency_code          =>  l_project_currency_code
                                 , X_project_rate_date              =>  l_project_rate_date
                                 , X_project_rate_type              =>  l_project_rate_type
                                 , X_project_exchange_rate          =>  l_project_exchange_rate
                                 , X_err_code                       =>  l_err_code
                                 , X_err_stage                      =>  l_err_stage
                                 , X_err_stack                      =>  l_err_stack
                                 , P_Projfunc_currency_code         =>  l_projfunc_currency_code
                                 , P_Projfunc_cost_rate_date        =>  l_projfunc_cost_rate_date
                                 , P_Projfunc_cost_rate_type        =>  l_projfunc_cost_rate_type
                                 , P_Projfunc_cost_exchange_rate    =>  l_projfunc_cost_exchange_rate
                                 , P_project_raw_cost               =>  null
                                 , P_project_burdened_cost          =>  null
                                 , P_Work_Type_Id                   =>  l_work_type_id
                                 , P_mode                           =>  'INTERFACE'
				 , X_line_num                       =>  l_line_num
                                 );

			log_message ('I lines created for Reversing EI.');

			l_accr_period_name := pa_utils2.get_gl_period_name (l_prvdr_accr_date,l_org_id);



			UPDATE PA_Cost_Distribution_lines_ALL CDL
			 SET CDL.GL_DATE = l_prvdr_accr_date,
			     CDL.GL_PERIOD_NAME = l_accr_period_name
			 WHERE CDL.EXPENDITURE_ITEM_ID = l_exp_item_id
			  AND CDL.LINE_NUM_REVERSED IS NULL
                          AND CDL.TRANSFER_STATUS_CODE in ('P','R','G','A');

			log_message ('CDLs of Reversing EI updated.');


			If l_transfer_status_code = 'A' and l_acct_event_id is not null then


				log_message ('Events are created for Reversing EI.');

				Update XLA_EVENTS
				   Set EVENT_DATE = l_prvdr_accr_date ,
				       TRANSACTION_DATE = l_prvdr_accr_date,
				       Request_ID  = g_request_id	,
				       LAST_UPDATE_DATE = Sysdate		,
	                               LAST_UPDATED_BY = fnd_global.user_id	,
	                               LAST_UPDATE_LOGIN = fnd_global.user_id
				  Where event_id = l_acct_event_id;

				log_message ('Event updated for reversing EI.');

				Update XLA_AE_HEADERS
				   SET ACCOUNTING_DATE = l_prvdr_accr_date ,
				       PERIOD_NAME =  l_accr_period_name ,
				       Request_ID  = g_request_id,
				       LAST_UPDATE_DATE = Sysdate		,
	                               LAST_UPDATED_BY = fnd_global.user_id	,
	                               LAST_UPDATE_LOGIN = fnd_global.user_id
				 Where event_id = l_acct_event_id;

				log_message ('Header updated for reversing EI.');

			End If;

	End If;

	pa_debug.reset_curr_function;

Exception
  When Others Then
	Raise;
End CHECK_MISC_TXNS;

PROCEDURE UPD_BTC_TBC_RELATED_CMT_GLDATE IS
BEGIN

    log_message (' Start of upd_btc_tbc_related_cmt_gldate');

    log_message (' Updating AP commitment records with newly derived open gl_date for corresponding BTC/TBC CDL');

    FORALL i IN 1..g_expenditure_item_id.count
            UPDATE  pa_bc_commitments bc_cm
	       SET  bc_cm.request_id  = g_request_id,
		    bc_cm.transferred_date = SYSDATE,
		    bc_cm.liquidate_gl_date = g_gl_date_new_tab(i)
   	     WHERE ( bc_cm.document_header_id,bc_cm.document_distribution_id,expenditure_type)
		   IN ( SELECT exp.document_header_id,exp.document_distribution_id,exp.expenditure_type
		          FROM PA_Cost_Distribution_lines  cdl_raw,
			       pa_expenditure_items_all  exp
		         WHERE cdl_raw.burden_sum_source_run_id = g_buren_Sum_Dest_Run_Id(i)
		           AND exp.expenditure_item_id = cdl_raw.expenditure_item_id
		           AND cdl_raw.line_num = 1
		           AND g_cdl_line_type(i) ='R'
		         UNION ALL
		        SELECT g_document_header_id(i),g_document_distribution_id(i),g_expenditure_type(i)
		          FROM dual
		         WHERE g_cdl_line_type(i) ='D' )
	       AND bc_cm.transfer_status_code = 'A'
	       AND bc_cm.bc_event_id = g_cdl_acct_event_id(i)
	       AND bc_cm.document_type = 'AP'
	       AND bc_cm.burden_cost_flag = 'R'
	       AND ((bc_cm.parent_bc_packet_id IS NOT NULL AND g_cdl_line_type(i) ='R') OR g_cdl_line_type(i) ='D')
	       AND NVL(g_liquidate_encum_flag(i),'N') = 'Y'
	       AND ((g_system_linkage_function(i) = 'BTC' AND g_cdl_line_type(i) = 'R' ) OR
		        (g_system_linkage_function(i) IN ('VI','ST','OT') AND g_cdl_line_type(i) = 'D'));

    log_message ( 'Total AP commitment records updated ' || SQL%ROWCOUNT);

    log_message (' Updating PO commitment records with newly derived open gl_date for corresponding BTC/TBC CDL');

    FORALL i IN 1..g_expenditure_item_id.count
	    UPDATE  pa_bc_commitments bc_cm
	       SET  bc_cm.request_id  = g_request_id,
		    bc_cm.transferred_date = SYSDATE,
		    bc_cm.liquidate_gl_date = g_gl_date_new_tab(i)
	     WHERE (bc_cm.exp_item_id,bc_cm.expenditure_type)
		IN ( SELECT  cdl_raw.expenditure_item_id,ei_raw.expenditure_type
		       FROM  PA_Cost_Distribution_lines  cdl_raw,
			     Pa_Expenditure_Items ei_raw
		      WHERE  cdl_raw.burden_sum_source_run_id = g_buren_Sum_Dest_Run_Id(i)
		        AND  cdl_raw.line_num = 1
		        AND  cdl_raw.expenditure_item_id = ei_raw.expenditure_item_id
		        AND  ei_raw.system_linkage_function in ('ST','OT','VI')
		        AND  g_cdl_line_type(i) ='R'
		     UNION ALL
		     SELECT g_expenditure_item_id(i),g_expenditure_type(i)
		       FROM  dual
		      WHERE  g_system_linkage_function(i) IN ('ST','OT','VI')
		        AND  g_cdl_line_type(i) ='D')
	       AND bc_cm.transfer_status_code in ('P','R','X')
	       AND bc_cm.document_type = 'PO'
	       AND bc_cm.burden_cost_flag = 'R'
	       AND ((bc_cm.parent_bc_packet_id is not null AND g_cdl_line_type(i) ='R') OR  g_cdl_line_type(i) ='D')
	       AND NVL(g_liquidate_encum_flag(i),'N') = 'Y'
	       AND ((g_system_linkage_function(i) = 'BTC' AND g_cdl_line_type(i) = 'R' ) OR
		        (g_system_linkage_function(i) IN ('VI','ST','OT') AND g_cdl_line_type(i) = 'D'));

    log_message ( 'Total AP commitment records updated ' || SQL%ROWCOUNT);

EXCEPTION
WHEN OTHERS THEN
        log_message ( 'In when others exception region' || SQL%ROWCOUNT);
        RAISE;
END UPD_BTC_TBC_RELATED_CMT_GLDATE;

END ;


/
