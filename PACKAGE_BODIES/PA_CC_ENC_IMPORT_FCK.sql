--------------------------------------------------------
--  DDL for Package Body PA_CC_ENC_IMPORT_FCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_ENC_IMPORT_FCK" as
-- $Header: PACCENCB.pls 120.2 2006/03/31 16:51:28 bkattupa noship $

	-- Declare global variables for cache
	G_debug_mode  varchar2(100);
        G_prev_flag_project_id Number;
        G_prev_bdgt_project_id Number;
        G_prev_flag_ext_budget_code varchar2(100);
        G_prev_bdgt_ext_budget_code varchar2(100);
        G_prev_budget_version_id Number;
        G_Prev_budget_control_flag varchar2(100);

PROCEDURE print_msg(p_msg  varchar2) IS

BEGIN
      If g_debug_mode = 'Y' Then
	--r_debug.r_msg('Log:'||p_msg);
	--dbms_output.put_line('Log:'||p_msg);
	pa_debug.g_err_stage := substr(p_msg,1,250);
        pa_debug.write_file('LOG: '||pa_debug.g_err_stage);
      End If;
      null;

END print_msg;

/** This API checks whether the budgetary control is enabled or Not for the given project and budget type
 *  The return status of this API will be 'Y' or 'N' */
FUNCTION get_fc_reqd_flag(p_project_id  number,p_ext_budget_code varchar2) RETURN varchar2 IS

		l_budget_control_flag varchar2(100);

        BEGIN

	    If (g_prev_flag_project_id is Null OR g_prev_flag_project_id <> p_project_id ) OR
	       (g_prev_flag_ext_budget_code is Null OR g_prev_flag_ext_budget_code <> p_ext_budget_code ) Then

		print_msg('Inside get_fc_reqd_flag executing sql');

		/* Modified the sql into exist clause to improve performance */
                select 'Y'
                into  l_budget_control_flag
                FROM DUAL
		WHERE EXISTS (	select null
                		from  pa_budgetary_control_options pbct
                      			,pa_budget_types bv
                		where pbct.project_id = p_project_id
                		AND pbct.BDGT_CNTRL_FLAG = 'Y'
                		AND pbct.BUDGET_TYPE_CODE = bv.budget_type_code
                		AND Nvl(pbct.EXTERNAL_BUDGET_CODE,'GL') = p_ext_budget_code
                		AND bv.budget_amount_code = 'C'
			     );

		g_prev_flag_project_id := p_project_id;
		g_prev_flag_ext_budget_code := p_ext_budget_code;
		g_Prev_budget_control_flag := l_budget_control_flag;

	    Else
		-- Retreive from the cache
		print_msg('Inside get_fc_reqd_flag retreiveing from cache');
		l_budget_control_flag := g_Prev_budget_control_flag;

	    End If;

	    RETURN l_budget_control_flag;


	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_budget_control_flag := 'N';
                        g_prev_flag_project_id := p_project_id;
			g_prev_flag_ext_budget_code := p_ext_budget_code;
		        g_Prev_budget_control_flag := l_budget_control_flag;
			RETURN l_budget_control_flag;
		WHEN TOO_MANY_ROWS  THEN
			l_budget_control_flag := 'Y';
                        g_prev_flag_project_id := p_project_id;
                        g_prev_flag_ext_budget_code := p_ext_budget_code;
                        g_Prev_budget_control_flag := l_budget_control_flag;
			RETURN l_budget_control_flag;
		WHEN OTHERS THEN
			Raise;

END get_fc_reqd_flag;

/** This API returns budget version id for the given project and external budget type */
FUNCTION get_bdgt_version_id(p_project_id  number,p_ext_budget_code varchar2) RETURN NUMBER IS

		l_budget_version_id Number;
	BEGIN

	    If (g_prev_bdgt_project_id is Null OR g_prev_bdgt_project_id <> p_project_id ) OR
	       (g_prev_bdgt_ext_budget_code is Null OR g_prev_bdgt_ext_budget_code <> p_ext_budget_code ) Then
		print_msg('Inside get_bdgt_version_id executing sql');

		/* Added budget_amount_code = 'C' to select cost budget only */

        	SELECT max(pbv.budget_version_id)
        	INTO l_budget_version_id
        	FROM pa_budget_versions pbv
             		,pa_budget_types bdgttype
             		,pa_budgetary_control_options pbct
        	WHERE pbv.project_id = p_project_id
        	AND   pbv.current_flag = 'Y'
        	AND   pbv.budget_status_code = 'B'
        	AND   bdgttype.budget_type_code = pbv.budget_type_code
        	AND   bdgttype.budget_amount_code = 'C'
        	AND   pbct.project_id = pbv.project_id
        	AND   pbct.BDGT_CNTRL_FLAG = 'Y'
        	AND   pbct.BUDGET_TYPE_CODE = pbv.budget_type_code
        	AND   NVL(pbct.EXTERNAL_BUDGET_CODE,'GL') = p_ext_budget_code ;

		g_prev_bdgt_project_id := p_project_id;
		g_prev_bdgt_ext_budget_code := p_ext_budget_code;
		g_prev_budget_version_id := l_budget_version_id;

	    Else
		-- Retreive from the cache
		print_msg('Inside get_bdgt_version_id retreiveing from cache');
		l_budget_version_id := g_prev_budget_version_id;

	    End If;

	    RETURN l_budget_version_id;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        l_budget_version_id := Null;
			g_prev_bdgt_project_id := p_project_id;
			g_prev_bdgt_ext_budget_code := p_ext_budget_code;
			g_prev_budget_version_id := l_budget_version_id;
			RETURN l_budget_version_id;
                WHEN OTHERS THEN
			l_budget_version_id := Null;
			g_prev_bdgt_project_id := p_project_id;
			g_prev_bdgt_ext_budget_code := p_ext_budget_code;
			g_prev_budget_version_id := l_budget_version_id;
			RETURN l_budget_version_id;

END get_bdgt_version_id;
/** This API checks whether the PA is installed in the OU or not to avoid cross charage project
 *  transactions funds check The return status of this API will be 'Y' or 'N'
 **/
FUNCTION IS_PA_INSTALL_IN_OU RETURN VARCHAR2 is

        l_return_var    varchar2(10) := 'Y';

BEGIN
        SELECT 'Y'
        INTO   l_return_var
        FROM  pa_implementations;
        Return l_return_var ;

EXCEPTION
        when NO_data_found then
                return 'N';
        when Too_many_rows then
                return 'Y';
        When others then
                Raise;

END IS_PA_INSTALL_IN_OU;

/** This is an autonmous Transaction API, which inserts records into
 *  pa_bc_packets. If the operation is success ,x_return_status will be set to 'S'
 *  else it will be set to 'T' - for fatal error and x_error_msg will return the sqlcode and sqlerrm
 **/
PROCEDURE Load_pkts(
                p_calling_module    IN varchar2 default 'CCTRXIMPORT'
		,p_ext_budget_type  IN varchar2 default 'GL'
                , p_packet_id       IN number
		, p_fc_rec_tab      IN PA_CC_ENC_IMPORT_FCK.FC_Rec_Table
                , x_return_status   OUT NOCOPY varchar2
                , x_error_msg       OUT NOCOPY varchar2
               ) IS

	PRAGMA AUTONOMOUS_TRANSACTION;
	l_fc_rec_tab PA_CC_ENC_IMPORT_FCK.FC_Rec_Table := p_fc_rec_tab;
	l_tab_count  Number := 0;
	l_ext_budget_code varchar2(100);
	l_budget_version_id Number;
	l_budget_control_flag varchar2(100);
	l_ext_budget_type  varchar2(100);


BEGIN
	--Initialize the out variables
	x_return_status := 'S';
	x_error_msg := Null;

	-- Initialize the error stack;
        pa_debug.init_err_stack('PA_FUNDS_CONTROL_UTILS.Load_pkts');

	--Intialize the debug flag
        fnd_profile.get('PA_DEBUG_MODE',g_debug_mode);
        g_debug_mode := NVL(g_debug_mode, 'N');
        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => g_debug_mode
                          );

	If IS_PA_INSTALL_IN_OU = 'N' Then
		-- PA is not installed in this OU
		print_msg('PA is not installed in this OU');
		Return;

	End If;

	print_msg('Inside Load_pkts p_packet_id['||p_packet_id||']');

	l_tab_count := l_fc_rec_tab.count();

	print_msg('l_tab_count['||l_tab_count);
	print_msg('p_tab_count['||p_fc_rec_tab.count);

	IF l_tab_count > 0 Then     --{

	   FOR i IN 1 .. l_tab_count LOOP

		--derive the budget version id based on the project_id and budget_type
		--If the project is budgetary control enables and if there is no baselined budget exists
                --mark these transactions as error 'F166 : No Baseline budget exists for the this project';

		 l_ext_budget_type := l_fc_rec_tab(i).EXT_BUDGET_TYPE;

		 print_msg('l_ext_budget_type['||l_ext_budget_type);

		 If l_ext_budget_type is Null Then
			l_ext_budget_type := 'GL';
		 End If;
		 l_budget_control_flag := get_fc_reqd_flag(l_fc_rec_tab(i).PROJECT_ID,l_ext_budget_type);
		 l_budget_version_id   := get_bdgt_version_id(l_fc_rec_tab(i).PROJECT_ID,l_ext_budget_type);

		 print_msg('l_budget_control_flag['||l_budget_control_flag||']l_budget_version_id['||l_budget_version_id);


		IF l_budget_control_flag = 'Y' and l_budget_version_id is NULL Then

			l_fc_rec_tab(i).result_code := 'F166';
			l_fc_rec_tab(i).budget_version_id := -1;
		Elsif l_budget_control_flag = 'Y' and l_budget_version_id is NOT NULL Then

			l_fc_rec_tab(i).budget_version_id := l_budget_version_id;

		Else
			l_fc_rec_tab(i).budget_version_id := -1;
			l_fc_rec_tab(i).status_code := 'Z';
			-- set status code to Z to avoid copying project related non-budgetary control records into pa_bc_packets

		End If;

		-- Note: We cannot use Bulk insert due to table of records
	        --PLS-00436: implementation restriction: cannot reference fields of BULK In-BIND table of records
		INSERT INTO PA_BC_PACKETS
 		(PACKET_ID
 		,BC_PACKET_ID
		 ,PARENT_BC_PACKET_ID
		 ,BC_COMMITMENT_ID
		 ,PROJECT_ID
		 ,TASK_ID
		 ,EXPENDITURE_TYPE
		 ,EXPENDITURE_ITEM_DATE
		 ,SET_OF_BOOKS_ID
		 ,JE_CATEGORY_NAME
		 ,JE_SOURCE_NAME
		 ,STATUS_CODE
		 ,DOCUMENT_TYPE
		 ,FUNDS_PROCESS_MODE
		 ,EXPENDITURE_ORGANIZATION_ID
		 ,DOCUMENT_HEADER_ID
		 ,DOCUMENT_DISTRIBUTION_ID
		 ,BUDGET_VERSION_ID
		 ,BURDEN_COST_FLAG
		 ,BALANCE_POSTED_FLAG
		 ,ACTUAL_FLAG
		 ,GL_DATE
		 ,PERIOD_NAME
		 ,PERIOD_YEAR
		 ,PERIOD_NUM
		 ,ENCUMBRANCE_TYPE_ID
		 ,PROJ_ENCUMBRANCE_TYPE_ID
		 ,TOP_TASK_ID
		 ,PARENT_RESOURCE_ID
		 ,RESOURCE_LIST_MEMBER_ID
		 ,ENTERED_DR
		 ,ENTERED_CR
		 ,ACCOUNTED_DR
		 ,ACCOUNTED_CR
		 ,RESULT_CODE
		 ,OLD_BUDGET_CCID
		 ,TXN_CCID
		 ,ORG_ID
		 ,LAST_UPDATE_DATE
		 ,LAST_UPDATED_BY
		 ,CREATED_BY
		 ,CREATION_DATE
		 ,LAST_UPDATE_LOGIN
		) select
 		l_fc_rec_tab(i).PACKET_ID
 		,pa_bc_packets_s.nextval  --l_fc_rec_tab(i).BC_PACKET_ID
		 ,l_fc_rec_tab(i).PARENT_BC_PACKET_ID
		 ,l_fc_rec_tab(i).BC_COMMITMENT_ID
		 ,l_fc_rec_tab(i).PROJECT_ID
		 ,l_fc_rec_tab(i).TASK_ID
		 ,l_fc_rec_tab(i).EXPENDITURE_TYPE
		 ,l_fc_rec_tab(i).EXPENDITURE_ITEM_DATE
		 ,l_fc_rec_tab(i).SET_OF_BOOKS_ID
		 ,l_fc_rec_tab(i).JE_CATEGORY_NAME
		 ,l_fc_rec_tab(i).JE_SOURCE_NAME
		 ,l_fc_rec_tab(i).STATUS_CODE
		 ,l_fc_rec_tab(i).DOCUMENT_TYPE
		 ,l_fc_rec_tab(i).FUNDS_PROCESS_MODE
		 ,l_fc_rec_tab(i).EXPENDITURE_ORGANIZATION_ID
		 ,l_fc_rec_tab(i).DOCUMENT_HEADER_ID
		 ,l_fc_rec_tab(i).DOCUMENT_DISTRIBUTION_ID
		 ,l_fc_rec_tab(i).BUDGET_VERSION_ID
		 ,l_fc_rec_tab(i).BURDEN_COST_FLAG
		 ,l_fc_rec_tab(i).BALANCE_POSTED_FLAG
		 ,l_fc_rec_tab(i).ACTUAL_FLAG
		 ,l_fc_rec_tab(i).GL_DATE
		 ,l_fc_rec_tab(i).PERIOD_NAME
		 ,l_fc_rec_tab(i).PERIOD_YEAR
		 ,l_fc_rec_tab(i).PERIOD_NUM
		 ,l_fc_rec_tab(i).ENCUMBRANCE_TYPE_ID
		 ,l_fc_rec_tab(i).PROJ_ENCUMBRANCE_TYPE_ID
		 ,l_fc_rec_tab(i).TOP_TASK_ID
		 ,l_fc_rec_tab(i).PARENT_RESOURCE_ID
		 ,l_fc_rec_tab(i).RESOURCE_LIST_MEMBER_ID
		 ,l_fc_rec_tab(i).ENTERED_DR
		 ,l_fc_rec_tab(i).ENTERED_CR
		 ,l_fc_rec_tab(i).ACCOUNTED_DR
		 ,l_fc_rec_tab(i).ACCOUNTED_CR
		 ,l_fc_rec_tab(i).RESULT_CODE
		 ,l_fc_rec_tab(i).OLD_BUDGET_CCID
		 ,l_fc_rec_tab(i).TXN_CCID
		 ,l_fc_rec_tab(i).ORG_ID
		 ,l_fc_rec_tab(i).LAST_UPDATE_DATE
		 ,l_fc_rec_tab(i).LAST_UPDATED_BY
		 ,l_fc_rec_tab(i).CREATED_BY
		 ,l_fc_rec_tab(i).CREATION_DATE
		 ,l_fc_rec_tab(i).LAST_UPDATE_LOGIN
		FROM DUAL
		WHERE l_fc_rec_tab(i).status_code <> 'Z' ;

		print_msg('No rec inserted ['||sql%rowcount);

	  END LOOP;

	 Commit;

	End If; -- end of l_tab_count }

	-- Reset the table count
	l_tab_count := 0;

	select count(*)
	into l_tab_count
	from pa_bc_packets
	where packet_id = p_packet_id;

	print_msg('Number of rec inserted ['||l_tab_count);

	If l_tab_count > 0 Then

	     	-- populate burden rows for the above inserted rows
		-- calling the Populate_burden_cost API in TRXIMPORT api will not insert records into pa_bc_packets
        	-- for document type 'CC_C_CO','CC_P_CO','CC_C_PAY','CC_P_PAY','AP' so the api should be called
        	-- with calling mode manipulated with GL or CBC
		If p_ext_budget_type = 'CC' Then
			l_ext_budget_type := 'CBC';
		Else
			l_ext_budget_type := 'GL';
		End If;

		print_msg('calling Populate_burden_cost ');
		PA_FUNDS_CONTROL_PKG1.Populate_burden_cost
        	(p_packet_id            => p_packet_id
        	,p_calling_module       => l_ext_budget_type
        	,x_return_status        => x_return_status
        	,x_err_msg_code         => x_error_msg
        	);
		print_msg('After calling Populate_burden_cost ');

	End If;

	pa_debug.reset_err_stack;
	COMMIT;
	Return;

EXCEPTION
	WHEN OTHERS THEN
		print_msg('When others of exception in Load pkts');
		update pa_bc_packets
		set result_code = decode(substr(nvl(result_code,'P'),1,1),'P','F142'
									 ,'F',result_code
									 ,'F142')
		   ,status_code = 'T'
		where packet_id = p_packet_id;
		x_return_status := 'T';
		x_error_msg := SQLCODE||SQLERRM;
		commit;
		pa_debug.reset_err_stack;
		RAISE;
END Load_pkts;

/** This is a wrapper API created on top of pa_funds_chedk for Contract commitments transactions
 *  During import of CC transactions, since the amounts are already encumbered in GL and CC
 *  the respective funds check process will not be called. Ref to bug:2877072 for further details
 *  so the PA encumbrnace entries were missing. In order to fix the above bug this API is created
 *  which calls pa funds check in TRXIMPORT mode so that, the liquidation entries need not be
 *  posted to GL and CBC.
 *  This API will be called twice for each batch of import.
 *  for documnet type - 'CC_C_CO','CC_P_CO'  create a unique packet_id and p_ext_budget_type = 'CC'
 *      documnet type - 'CC_C_PAY','CC_P_PAY','AP' create a unique packet_id and p_ext_budget_type = 'GL'
 *  The return status of this API will be 'S' - success, 'F' - Failure, 'T' - Fatal error
 *  NOTE: For Transaction import process , the p_partial_flag is always 'N', if Pa_enc_import_fck is called
 *  in partial mode (Y), then calling program should have the logic to update the result and status code
 *  after the successfull completion of import process.
 *  Note: Since we  don't have the origanal transaction reference, we cannot update the partial of
 *  the result code and status of the transactions in partial mode during TRXIMPORT process. so
 *  all the transactions will be marked as failed or passed.
 **/
/** As discussed with Barbara, Dinakar, Sridhar, Prithi :- CC Transaction Import Strategy
 *  1.If the project is burdened, the burdening setup in legacy system may differ from Projects burdening setup.
 *    So we always assume that, the GL and CC encumbrance import process will import the Burdened Amount.
 *    and going forward PA will derive the burden amounts based on PA burden setup
 *
 *  2.When you import CC transactions without calling normal funds check process,
 *    we assume that PA Encumbrance are populated in CC and GL budgets. so we will not post any
 *    liqudiation or burden entries into igc interface or gl_bc_packets
 *
 *  3.The CC calls Pa_enc_import_fck API, we assume that CC is putting raw amount into pa_bc_packets
 *    so this API will derive the burden amounts based on setup on the PA burden setup
 **/

PROCEDURE Pa_enc_import_fck(
		 p_calling_module   IN varchar2 default 'CCTRXIMPORT'
		, p_ext_budget_type IN varchar2 default 'GL'
                , p_conc_flag       IN varchar2 default 'N'
                , p_set_of_book_id  IN number
                , p_packet_id       IN number
                , p_mode            IN varchar2 default 'R'
                , p_partial_flag    IN varchar2 default 'N'
                , x_return_status   OUT NOCOPY varchar2
                , x_error_msg       OUT NOCOPY varchar2
               ) IS

	l_fc_return_status  varchar2(100);
        l_fc_error_stage    varchar2(100);
        l_fc_error_msg      varchar2(1000);

	l_partial_flag      varchar2(100);

BEGIN
        --Initialize the out variables
        x_return_status := 'S';
        x_error_msg := Null;

        -- Initialize the error stack;
        pa_debug.init_err_stack('PA_FUNDS_CONTROL_UTILS.Pa_enc_import_fck');

        --Intialize the debug flag
        fnd_profile.get('PA_DEBUG_MODE',g_debug_mode);
        g_debug_mode := NVL(g_debug_mode, 'N');
        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => g_debug_mode
                          );

	print_msg('Inside Pa_enc_import_fck API');

        If IS_PA_INSTALL_IN_OU = 'N' Then
                -- PA is not installed in this OU
                Return;

        End If;

        -- -----------------------------------------------------------------------+
        -- CC IS DISABLED FOR R12 ....
        -- -----------------------------------------------------------------------+
        If p_calling_module = 'CCTRXIMPORT' then
            x_return_status := 'T';
            return;
        End If;

        -- -----------------------------------------------------------------------+

	-- Call the funds check in Reserve mode and calling module = 'TRXIMPORT'
	-- so that FC process will not pass any entries into GL or CBC tables
	-- Hard coding the l_partial_flag = 'N'

	l_partial_flag := 'N';

	print_msg('Calling pa_funds_check API');
 	IF Pa_Funds_Control_Pkg.pa_funds_check
                (p_calling_module  => 'TRXIMPORT'
                 ,p_conc_flag       => 'N'
                 ,p_set_of_book_id  => p_set_of_book_id
                 ,p_packet_id       => p_packet_id
                 ,p_mode            => p_mode
                 ,p_partial_flag    => l_partial_flag
                 ,x_return_status   => l_fc_return_status
                 ,x_error_stage     => l_fc_error_stage
                 ,x_error_msg       => l_fc_error_msg) THEN

		print_msg('end of pa_funds_check API retur status '||l_fc_return_status);

		If l_fc_return_status = 'S' Then

			x_return_status := 'S';
			x_error_msg := Null;
		Else
		        x_return_status := 'F';
                        x_error_msg := sqlcode||sqlerrm;
		End If;
	End If;

        pa_debug.reset_err_stack;
        Return;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'T';
                x_error_msg := SQLCODE||SQLERRM;
                -- call the status code update api
                pa_funds_control_pkg.status_code_update_autonomous
               ( p_calling_module        => 'TRXIMPORT'
                ,p_packet_id             => p_packet_id
                ,p_mode                  => p_mode
                ,p_partial               => l_partial_flag
                ,p_packet_status         => 'T'
                ,x_return_status         => x_return_status
                );
                pa_debug.reset_err_stack;
                RAISE;
END Pa_enc_import_fck;


/** This is tieback API for Contract commitment import process,Once the import process is completed
 *  this api will be called by passing the cbc result code. based on the cbc_result_code the
 *  status of the pa_bc_packets and pa_bdgt_acct_balances will be updated
 *  The return status of this API will be 'S' - success, 'F' - Failure, 'T' - Fatal error
 **/
PROCEDURE Pa_enc_import_fck_tieback(
		  p_calling_module   IN varchar2
		 ,p_ext_budget_type  IN varchar2 default 'GL'
                 ,p_packet_id       IN number
                 ,p_mode            IN varchar2 default 'R'
                 ,p_partial_flag    IN varchar2 default 'N'
                 ,p_cbc_return_code IN varchar2
                 ,x_return_status   OUT NOCOPY varchar2
               ) IS

	 l_calling_module varchar2(100);
	 l_partial_flag   varchar2(100);

BEGIN
        --Initialize the out variables
        x_return_status := 'S';

        -- Initialize the error stack;
        pa_debug.init_err_stack('PA_FUNDS_CONTROL_UTILS.Pa_enc_import_fck_tieback');

        --Intialize the debug flag
        fnd_profile.get('PA_DEBUG_MODE',g_debug_mode);
        g_debug_mode := NVL(g_debug_mode, 'N');
        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => g_debug_mode
                          );

        If IS_PA_INSTALL_IN_OU = 'N' Then
                -- PA is not installed in this OU
                Return;

        End If;

        -- -----------------------------------------------------------------------+
        -- CC IS DISABLED FOR R12 ....
        -- -----------------------------------------------------------------------+
        If p_calling_module = 'CCTRXIMPORT' then
            x_return_status := 'T';
            return;
        End If;
        -- -----------------------------------------------------------------------+

	If p_calling_module = 'CCTRXIMPORT' and p_ext_budget_type = 'GL' then
		l_calling_module := 'GL';
	Elsif p_calling_module = 'CCTRXIMPORT' and p_ext_budget_type = 'CC' Then
		l_calling_module := 'CC';
	Else
		l_calling_module := 'TRXIMPORT';
	End If;

	-- Note: Since don't have the origanal transaction reference, we cannot update the partial of
	-- the result code and status of the transactions in partial mode during TRXIMPORT process. so
        -- all the transactions will be marked as failed or passed.
	l_partial_flag := 'N';

	print_msg('Calling tie_back_result_code API');
	PA_CC_ENC_IMPORT_FCK.tie_back_result_code
             (p_calling_module  => l_calling_module
              ,p_packet_id      => p_packet_id
              ,p_partial_flag   => l_partial_flag
              ,p_mode           => p_mode
              ,p_glcbc_return_code => p_cbc_return_code
              ,x_return_status   => x_return_status
	     );
	print_msg(' After tie_back_result_code return status ['||x_return_status||']');

	print_msg('Calling status_code_update');

        -- call the status code update api
        pa_funds_control_pkg.status_code_update
               ( p_calling_module        => 'TRXIMPORT'
                ,p_packet_id             => p_packet_id
                ,p_mode                  => p_mode
                ,p_partial               => l_partial_flag
                ,p_packet_status         => p_cbc_return_code
                ,x_return_status         => x_return_status
                );

	print_msg(' After status_code_update return status ['||x_return_status||']');

        If p_cbc_return_code = 'S' and x_return_status = 'S' Then
		print_msg('calling upd_bdgt_encum_bal api');
                -- call the api to update account balances
                pa_funds_control_pkg.upd_bdgt_encum_bal(
                p_packet_id         => p_packet_id
                ,p_calling_module    => 'TRXIMPORT'
                ,p_mode              => p_mode
                ,p_packet_status     =>p_cbc_return_code
                ,x_return_status     => x_return_status
                   );
	        print_msg(' After upd_bdgt_encum_bal return status ['||x_return_status||']');

        End If;


	pa_debug.reset_err_stack;
	Return;

EXCEPTION
	WHEN OTHERS THEN
        -- call the status code update api
        pa_funds_control_pkg.status_code_update_autonomous
               ( p_calling_module        => 'TRXIMPORT'
                ,p_packet_id             => p_packet_id
                ,p_mode                  => p_mode
                ,p_partial               => l_partial_flag
                ,p_packet_status         => 'T'
                ,x_return_status         => x_return_status
                );
		RAISE;

END Pa_enc_import_fck_tieback;

/** Update the result code of the transactions based on the partial flag, calling mode and p_mode
 *  in autonomous transaction. After updating the result code call the status_code update API
 **/
PROCEDURE tie_back_result_code
                         (p_calling_module     in varchar2,
                          p_packet_id          in number,
                          p_partial_flag       in varchar2,
                          p_mode               in varchar2,
                          p_glcbc_return_code  in varchar2,
			  x_return_status      OUT NOCOPY varchar2) IS

        PRAGMA AUTONOMOUS_TRANSACTION;

        cursor cur_pkts IS
                     select pkt.rowid
			,pkt.bc_packet_id
			,pkt.status_code
			,pkt.result_code
		     from pa_bc_packets pkt
		     where pkt.packet_id = p_packet_id
                     and substr(nvl(result_code,'P'),1,1) = 'P';

	l_num_rows Number := 500;
	type rowidtabtyp is table of urowid index by binary_integer;
	l_tab_rowid                             rowidtabtyp;
        l_tab_bc_pkt_id                         pa_plsql_datatypes.IdTabTyp;
        l_tab_status_code                       pa_plsql_datatypes.char50TabTyp;
	l_tab_result_code                       pa_plsql_datatypes.char50TabTyp;

BEGIN
        If p_calling_module in('GL','CC','TRXIMPORT') and p_mode in ('C','R','A','F') and p_glcbc_return_code <> 'S'  then

	     OPEN cur_pkts;
	     LOOP
		-- Intialize the tables
                l_tab_rowid.delete;
		l_tab_bc_pkt_id.delete;
                l_tab_status_code.delete;
                l_tab_result_code.delete;
		FETCH cur_pkts BULK COLLECT INTO
		      l_tab_rowid
		     ,l_tab_bc_pkt_id
		     ,l_tab_status_code
		     ,l_tab_result_code
		LIMIT l_num_rows;
                IF NOT l_tab_rowid.EXISTS(1)  then
                       EXIT;
                END IF;
		-- update the result code of the packets where it is passed
                FORALL i IN l_tab_rowid.FIRST .. l_tab_rowid.LAST
                        UPDATE pa_bc_packets
                        SET result_code =
                                 decode(p_calling_module,
                                  'GL',
                                     decode(p_partial_flag,
                                           'Y',decode(p_mode,'C','F150','F156'),
                                           'N',decode(p_mode,'C',decode(p_glcbc_return_code,'F','F150',
                                                                                       'R','F151',
                                                                                       'T','F151')
                                                       ,'R',decode(p_glcbc_return_code,'F','F155',
                                                                                       'R','F155',
                                                                                       'T','F155')
                                                       ,'A',decode(p_glcbc_return_code,'F','F155',
                                                                                       'R','F155',
                                                                                       'T','F155')
                                                       ,'F',decode(p_glcbc_return_code,'F','F155',
                                                                                       'R','F155',
                                                                                       'T','F155'))),
                                'CC',
                                      decode(p_partial_flag,
                                           'Y',decode(p_mode,'C','F152','F158'),
                                           'N',decode(p_mode,'C',decode(p_glcbc_return_code,'F','F152',
                                                                                        'R','F153',
                                                                                        'T','F153')
                                                        ,'R',decode(p_glcbc_return_code,'F','F157',
                                                                                        'R','F157',
                                                                                        'T','F157')
                                                        ,'A',decode(p_glcbc_return_code,'F','F157',
                                                                                        'R','F157',
                                                                                        'T','F157')
                                                        ,'F',decode(p_glcbc_return_code,'F','F157',
                                                                                        'R','F157',
                                                                                        'T','F157'))),
                               'TRXIMPORT',
				     decode(p_partial_flag,
					'Y',decode(substr(nvl(result_code,'P'),1,1),'P',result_code,'F167'),
					'N','F167' ))
                        WHERE packet_id = p_packet_id
			AND bc_packet_id = l_tab_bc_pkt_id(i)
                        AND substr(nvl(result_code,'P'),1,1) = 'P'
			AND nvl(p_glcbc_return_code,'R') <> 'S';

	         EXIT WHEN cur_pkts%notfound;

           END LOOP;
           CLOSE cur_pkts;
        End if;
        commit; -- to end an active autonomous transaction
        return;
EXCEPTION
        WHEN OTHERS THEN
		x_return_status := 'T';
                print_msg('Failed in tie_back_status apiSQLERR:'||sqlcode||sqlerrm);
		COMMIT;
                RAISE;

END tie_back_result_code;

END PA_CC_ENC_IMPORT_FCK;

/
