--------------------------------------------------------
--  DDL for Package Body FV_PURGED_TREASURY_SYMBOLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_PURGED_TREASURY_SYMBOLS" as
/* $Header: FVXPRTSB.pls 120.2 2006/07/04 06:12:32 ckappaga noship $ */
   procedure populate_history_tab(tres_id number,v_flag varchar2);  --- private subprogramme
   function inquire_history_tab(tres_id number) return boolean; --- private subprogramme
   procedure update_history_tab(tres_id number,v_flag varchar2); --- private subprogramme
   procedure ins_delete_treasury_symbols; --- private subprogramme
   procedure delete_treasury_symbols; --- private subprogramme
   procedure get_period_year(p_year out nocopy number); --- private subprogramme
   procedure clean_up; --- private subprogramme

   procedure calculate_gl_balances(p_fund_value in varchar2,p_balance out nocopy number,p_cnt out nocopy number); --- private subprogramme

   /*----------------------------+
       Private Global Variables
   +-----------------------------*/

   gbl_error_code		Number := 0;
   gbl_error_buf		Varchar2(200);
   gbl_account_id       gl_code_combinations.chart_of_accounts_id%type;
   gbl_bal_segment_name varchar2(30);
   gbl_acc_segment_name varchar2(30);
   gbl_set_of_books_id 	Gl_ledgers_public_v.ledger_id%TYPE;
   gbl_last_upd_date DATE;
   gbl_last_update_by number(15);
   gbl_last_update_log number(15);
   gbl_creation_date   date;
   gbl_created_by number(15);
   gbl_cancellation_date date;
   gbl_treasury_symbol varchar2(100);
   gbl_treasury_symbol_id fv_treasury_symbols.treasury_symbol_id%type;
   gbl_time_frame  varchar2(100);
   gbl_year_established number;
   gbl_new_established_year number;
   gbl_request_id Number;
   gbl_prelim_req_id Number;
   gbl_period_year gl_periods.period_year%type;
   gbl_period_set_name 	Gl_Ledgers_public_v.period_set_name%type;
   g_module_name VARCHAR2(100) := 'fv.plsql.fv_purged_treasury_symbols.';
   gbl_cursor_cnt NUMBER := 0;
   gbl_acct_segment_num NUMBER;
   gbl_flex_value_set_id NUMBER;
   --gbl_purge_cancel_flg VARCHAR2(1);


   /*-----------------------------------------------------------------+
   Cursor to get Treasury symbols based on the Input Parameters Passed.
   +------------------------------------------------------------------*/

cursor c_treasury_symbols (v_treasury_symbol varchar2,v_sob number,v_time_frame IN VARCHAR2 ,
	                   n_year_established IN NUMBER,
	                   d_cancellation_date IN DATE ,
	                   new_established_year IN NUMBER) is
select treasury_symbol_id,treasury_symbol,
       set_of_books_id,
       fund_group_code
  from fv_treasury_symbols
 where set_of_books_id = gbl_set_of_books_id
   and treasury_symbol= nvl(v_treasury_symbol,treasury_symbol)
   and time_frame = nvl(v_time_frame,time_frame)
   and established_fiscal_yr = NVL(n_year_established,established_fiscal_yr)
   and nvl(to_char(trunc(cancellation_date)),'0') = NVL(to_char(gbl_cancellation_date),nvl(to_char(TRUNC(cancellation_date)),0))
   and trunc(cancellation_date) < trunc(sysdate) - 365;

/*-----------------------------------------------------+
  Cursor to get The Fund Values of the Treasury Symbols
  selected from Cursor "c_treasury_symbols"
+-------------------------------------------------------+*/
cursor c_fund_parameters(tres_id number, v_sob  number) is
select fund_parameter_id,fund_value,
       treasury_symbol,set_of_books_id,
       fund_group_code
  from Fv_fund_parameters
 where treasury_symbol_id = tres_id
   and set_of_books_id = v_sob;

/*-----------------------------------------------------+
  Cursor to get The Natural Account Segmant Values.
+-------------------------------------------------------+*/

CURSOR  parent_child_rollups_cur(p_value_set_id NUMBER) IS
    SELECT flex_value
      FROM  fnd_flex_values
     WHERE  flex_value_set_id = p_value_set_id
     and    flex_value  NOT IN('4350','4201')
     AND   NOT EXISTS ( SELECT 1 from  fnd_flex_value_hierarchies
                                      where Flex_value_set_id = p_value_set_id
                                   AND  flex_value BETWEEN  child_flex_value_low
                                                 AND child_flex_value_high
                                   AND PARENT_FLEX_VALUE in ('4350','4201'))
      AND summary_flag = 'N'
ORDER BY 1 ;

-- *---------------------------------------------------------------------* --
-- *        	       PROCEDURE MAIN                                    * --
-- *                   ----------------                                  * --
-- * Main procedure of the package, which is called for execution from   * --
-- * Purge Treasury Symbols cincurrent programme.                        * --
-- * It in turn calls all the other procedures to achieve the final      * --
-- * result.                                                             * --
-- *---------------------------------------------------------------------* --
procedure MAIN(errbuf     OUT NOCOPY VARCHAR2,
	       retcode    OUT NOCOPY VARCHAR2,
	       x_run_mode IN  VARCHAR2,
	       v_treasury_symbol IN VARCHAR2 DEFAULT NULL,
               v_time_frame IN VARCHAR2 DEFAULT NULL ,
	       n_year_established IN NUMBER DEFAULT NULL  ,
	       p_sob   Gl_Ledgers_public_v.ledger_id%TYPE DEFAULT NULL,
	       d_cancellation_date IN VARCHAR2 DEFAULT NULL ,
	       new_established_year IN NUMBER,
	       p_dummy IN NUMBER,
	       prelim_req_id IN NUMBER DEFAULT NULL) IS
v_accounts_id      gl_ledgers_public_v.chart_of_accounts_id%type;
v_application_name fnd_segment_attribute_values.application_column_name%type;
n_balance          NUMBER;
n_cnt              NUMBER;
l_segment_status	BOOLEAN;
e_invalid_bal_segment	EXCEPTION;
v_open_flag VARCHAR2(1) :='N';
v_result BOOLEAN;
v_req_status BOOLEAN;
v_rphase VARCHAR2(80);
v_rstatus VARCHAR2(80);
v_wait_req_status boolean;
v_dphase VARCHAR2(30);
v_dstatus VARCHAR2(30);
v_message VARCHAR2(240);
e_no_data EXCEPTION;
l_module_name VARCHAR2(200) := g_module_name || 'MAIN';
l_request_id NUMBER;
BEGIN
 gbl_set_of_books_id := p_sob;
 gbl_last_upd_date := sysdate;
 gbl_last_update_by :=   fnd_global.user_id;
 gbl_last_update_log := fnd_global.login_id;
 gbl_creation_date   := sysdate;
 gbl_created_by  :=   fnd_global.user_id;
 gbl_cancellation_date := trunc(FND_DATE.CANONICAL_TO_DATE(d_cancellation_date));
 gbl_treasury_symbol := v_treasury_symbol ;
 gbl_time_frame := v_time_frame ;
 gbl_year_established := n_year_established ;
 gbl_new_established_year := new_established_year ;
 gbl_request_id := fnd_global.conc_request_id;
 ---gbl_purge_cancel_flg := purge_cancel_flg;
 FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,' Inside Main');

 SELECT chart_of_accounts_id, period_set_name
   INTO gbl_account_id , gbl_period_set_name
   FROM gl_ledgers_public_v GL
  WHERE gl.ledger_id = gbl_set_of_books_id ;

   /*--------------------------------------------------+
                  To get segment Name
   +---------------------------------------------------*/

  BEGIN
 l_segment_status := FND_FLEX_APIS.get_segment_column
  	(101, 'GL#', gbl_account_id, 'GL_BALANCING',
	gbl_bal_segment_name) ;
  IF l_segment_status = FALSE
  THEN
    raise e_invalid_bal_segment;
  END IF;
exception
WHEN e_Invalid_Bal_segment THEN
    retcode := 2 ;
    errbuf  := 'GET SEGMENT NAME - Error Reading Balancing Segments' ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,errbuf);
    return;
END;
------To get the Accounting Segment Name ------------------------
 BEGIN
 l_segment_status := FND_FLEX_APIS.get_segment_column
  	(101, 'GL#', gbl_account_id, 'GL_ACCOUNT',
	gbl_acc_segment_name) ;
  IF l_segment_status = FALSE
  THEN
    raise e_invalid_bal_segment;
  END IF;
exception
WHEN e_Invalid_Bal_segment THEN
    retcode := 2 ;
    errbuf  := 'GET SEGMENT NAME - Error Reading accounting Segments' ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,errbuf);
    return;
END;

----To get the Accounting Segment Number---------
BEGIN
 l_segment_status := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM
                        (101,
                        'GL#',
                        gbl_account_id,
                        'GL_ACCOUNT',
                        gbl_acct_segment_num) ;
IF l_segment_status = FALSE
  THEN
    raise e_invalid_bal_segment;
  END IF;
exception
WHEN e_Invalid_Bal_segment THEN
    retcode := 2 ;
    errbuf  := 'GET SEGMENT NUMBER- Error Reading accounting Segments' ;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,errbuf);
    return;
END;



 SELECT flex_value_set_id
   INTO gbl_flex_value_set_id
   FROM fnd_id_flex_segments
  WHERE application_id = 101
    AND id_flex_code   = 'GL#'
    AND id_flex_num    = gbl_account_id
    AND segment_num    = gbl_acct_segment_num ;
-------------------------------------------------------------------------
 gbl_cursor_cnt  := 0;
 if x_run_mode = 'P' then
   for c1_treasury_symb in c_treasury_symbols(gbl_treasury_symbol,
                                              gbl_set_of_books_id,
					      gbl_time_frame ,
		                              gbl_year_established ,
		                              gbl_cancellation_date ,
		                              gbl_new_established_year )---- Open first cursor-----
   loop
        gbl_cursor_cnt  := 1;
        gbl_treasury_symbol_id := c1_treasury_symb.treasury_symbol_id;
	v_open_flag := 'N';
	v_result := inquire_history_tab(c1_treasury_symb.treasury_symbol_id );

   for c1_fund_param IN  c_fund_parameters(c1_treasury_symb.treasury_symbol_id ,gbl_set_of_books_id )----open second cursor------
     Loop
      gbl_cursor_cnt  := 2;

	/*-----------------------------------------------------------+
	        To check  balances of fund against Treasury symbols
	+------------------------------------------------------------*/
	if gbl_error_code = 0 then
	 calculate_gl_balances(c1_fund_param.fund_value,n_balance,n_cnt);
	else
	 exit;
	end if;
	-------------------------------------------------------------------------
             if gbl_error_code <> 0 then
	        exit;
	     end if;
	     IF (n_balance <> 0 ) or (n_cnt > 0) then
	       v_open_flag := 'Y';
               FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Balance or Unposted Transactions exists for Fund Values against Treasury Symbol: ' || c1_treasury_symb.treasury_symbol );

	      exit;
	     END IF;
     end loop; ----End of second cursor------
             if gbl_error_code <> 0 then
	        exit;
	     end if;
          if gbl_cursor_cnt  =1 then
	   errbuf := '  No Fund value is defined for Treasury Symbol:'||c1_treasury_symb.treasury_symbol;
	   retcode := 1;
	  ---- FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name ,gbl_error_buf);
	  end if;
	  if v_result = false then
	         if gbl_error_code = 0 then
		  Populate_history_tab(c1_treasury_symb.treasury_symbol_id ,v_open_flag);
		 else
		  exit;
		 end if;
	  elsif v_result = true then
	         if gbl_error_code = 0 then
		   update_history_tab(c1_treasury_symb.treasury_symbol_id ,v_open_flag);
		 else
		   exit;
		 end if;
	  end if;
   end loop; ---- End Of first cursor-----
        elsif x_run_mode = 'F' then
	  gbl_prelim_req_id := prelim_req_id; ---- Request id populated during 'P' Mode ------
	  Ins_delete_treasury_symbols;
 end if;

if gbl_cursor_cnt  = 0 then
raise e_no_data;
end if;

  IF (gbl_error_code <> 0) THEN
      errbuf := gbl_error_buf;
      retcode := 2;
      ROLLBACK;
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_ERROR, l_module_name || gbl_error_code,gbl_error_buf);
      return;
  ELSE
      COMMIT;
      /*---------------------------------------------------------------+
            Calling concurrent request to show the result in Report
      +----------------------------------------------------------------*/
     l_request_id := FND_REQUEST.SUBMIT_REQUEST( 'FV',
						 'FVPGDTSR',
						  null,
						  null,
						  FALSE,
                                                  x_run_mode,
                                                  gbl_request_id,
                                                  gbl_set_of_books_id,
                                                  gbl_treasury_symbol,
                                                  gbl_time_frame,
                                                  gbl_year_established,
                                                  gbl_new_established_year,
                                                  gbl_cancellation_date) ;
	IF l_request_id = 0 then
	   gbl_error_code := '2';
           gbl_error_buf  := 'Cannot submit Purge Treasury Symbol Report';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,gbl_error_buf);
       ELSE
          COMMIT;
	END IF;

	      v_wait_req_status := FND_CONCURRENT.WAIT_FOR_REQUEST(request_id  => l_request_id,
	                                                      interval => 20,
							      max_wait => 0,
							      phase => v_rphase,
							      status => v_rstatus,
							      dev_phase => v_dphase,
							      dev_status => v_dstatus,
							      message => v_message);
               IF v_wait_req_status = FALSE THEN
                 gbl_error_buf := 'Cannot wait for the status of Purge Treasury Symbols Report';
                 retcode := -1;
                 FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error4', gbl_error_buf) ;
              return;
	      END IF;

              v_req_status := FND_CONCURRENT.GET_REQUEST_STATUS(request_id  => l_request_id,
	                                                          appl_shortname => 'FV',
								  program => null,
							          phase       => v_rphase,
							          status      => v_rstatus,
							          dev_phase   => v_dphase,
							          dev_status  => v_dstatus,
							          message     => v_message);

	       IF (x_run_mode = 'F' and v_dphase = 'COMPLETE' and v_dstatus = 'NORMAL') then
		  delete_treasury_symbols; --- procedure to delete treasury symbols  --------
		  clean_up;                --- procedure to clean the junk data from history tables ------
		  IF gbl_error_code <> 0 then
		     errbuf := gbl_error_buf;
                     retcode := 2;
                     ROLLBACK;
		     update_history_tab(null,'R');
		     COMMIT;
		  ELSE
		     COMMIT;
		  END IF;
		  ----- Rollback all the changes done during updation -----------------
	       ELSIF
	       (x_run_mode = 'F' and v_dphase = 'COMPLETE' and v_dstatus <>'NORMAL')  then
		     update_history_tab(null,'R');
		     COMMIT;
	      --- ELSIF (x_run_mode = 'P' and v_dstatus <>'NORMAL') then

		     ---Error Occured while running a request ---------
	       END IF;
  END IF;

EXCEPTION
WHEN e_no_data then
errbuf := '  No Data Found for Treasury Symbol: '||gbl_treasury_symbol;
retcode := 2;
return;
END MAIN;

-- *----------------------------------------------------------------------* --
-- *	       PROCEDURE POPULATE_HISTORY_TAB                             * --
-- *           -------------------------------                            * --
-- *    Called during Preliminary Mode to populate history tables         * --
-- *----------------------------------------------------------------------* --
Procedure populate_history_tab(tres_id number,v_flag varchar2) is
l_module_name VARCHAR2(200):='POPULATE_HISTORY_TAB';
begin
BEGIN
---dbms_output.put_line('inside populate_history_tab');
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_statement, l_module_name,' inside populate_history_tab');
   insert ALL into fv_treasury_symbols_history
            (treasury_symbol_id,
	    treasury_symbol,
            set_of_books_id,
	    sf224_type_code,
            fund_group_code,
	    time_frame,
	    years_available,
            established_fiscal_yr,
	    expiration_date,
            cancellation_date,
            department_id,
	    last_update_date,
            last_updated_by,
	    last_update_login,
            creation_date,
	    created_by,
            federal_acct_symbol_id,
	    dept_transfer,
	    request_id,
	    open_flag)
     select treasury_symbol_id,
            treasury_symbol,
            set_of_books_id,
	    sf224_type_code,
            fund_group_code,
	    time_frame,
	    years_available,
            established_fiscal_yr,
	    expiration_date,
            cancellation_date,
            department_id,
	    gbl_last_upd_date,
            nvl(gbl_last_update_by,1),
            nvl(gbl_last_update_log,1),
            gbl_creation_date,
            nvl(gbl_created_by,1),
            federal_acct_symbol_id,
	    dept_transfer,
	    gbl_request_id,
	    populate_history_tab.v_flag
       from fv_treasury_symbols
      where treasury_symbol_id = tres_id
        and set_of_books_id = gbl_set_of_books_id;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   	   gbl_error_code := SQLCODE;
           gbl_error_buf  := SQLERRM ||'-- Error No Data Found in populate_history_tab while populating symbol history table';
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);
	   return;
	 WHEN OTHERS THEN
            gbl_error_code := SQLCODE;
            gbl_error_buf  := SQLERRM ||
		              ' -- Error in populate_history_tab when Inserting';
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);
	    return;
  END;
BEGIN
  insert ALL into fv_fund_parameters_history
             (fund_parameter_id,
	     fund_value,
             treasury_symbol,
             set_of_books_id,
             fund_group_code,
             fund_category,
             fund_time_frame,
             sf224_type_code,
             last_update_date,
             last_updated_by,
             last_update_login,
             creation_date,
             created_by,
             established_fiscal_yr,
             treasury_symbol_id,
             budget_authority,
             unliquid_commitments,
             unliquid_obligations,
             expended_amount,
             red_status,
             prior_year_recoveries)
      select fund_parameter_id,
             fund_value,
             treasury_symbol,
             set_of_books_id,
             fund_group_code,
             fund_category,
             fund_time_frame,
	     sf224_type_code,
             gbl_last_upd_date,
             nvl(gbl_last_update_by,1),
             nvl(gbl_last_update_log,1),
             gbl_creation_date,
             nvl(gbl_created_by,1),
	     established_fiscal_yr,
             treasury_symbol_id,
	     budget_authority,
             unliquid_commitments,
	     unliquid_obligations,
             expended_amount,
	     red_status,
             prior_year_recoveries
        from Fv_fund_parameters
       where treasury_symbol_id = tres_id
         and set_of_books_id = gbl_set_of_books_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
   	   --gbl_error_code := SQLCODE;
	  --- dbms_output.put_line('No fund found for treasury symbol:'||gbl_treasury_symbol_id);
           gbl_error_buf  := '--No Fund value defined for Treasury_symbol : '||gbl_treasury_symbol_id;
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,gbl_error_buf);
	   return;
	 WHEN OTHERS THEN
            gbl_error_code := SQLCODE;
            gbl_error_buf  := SQLERRM ||
		              ' -- Error in populate_history_tab while Inserting';
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,gbl_error_buf);
	    return;
 END;
end populate_history_tab;

-- *----------------------------------------------------------------------* --
-- *	       PROCEDURE INQUIRE_HISTORY_TAB                              * --
-- *           -------------------------------                            * --
-- * Called during Preliminary Mode, to find if there is any treasury     * --
-- * symbol already there in History Table                                * --
-- *----------------------------------------------------------------------* --

-------------------------------------------------------------------------------------------------------------------
Function inquire_history_tab(tres_id number) return boolean is
n_cnt number;
l_module_name varchar2(200) :=  g_module_name || 'INQUIRE_HISTORY_TAB';
begin
select count(1) into n_cnt
  from fv_treasury_symbols_history
 where treasury_symbol_id = tres_id
   and set_of_books_id = gbl_set_of_books_id
   and date_purged is null;
   if n_cnt > 0 then
      return true;
      else
      return false;
   end if;
end inquire_history_tab;

-- *----------------------------------------------------------------------* --
-- *	       PROCEDURE UPDATE_HISTORY_TAB                               * --
-- *           -------------------------------                            * --
-- * Called during Preliminary Mode or in Final Mode when error occured,  * --
-- * update the open flag for treasury                                    * --
-- * symbols already there in History Table                               * --
-- *----------------------------------------------------------------------* --

procedure update_history_tab(tres_id number,v_flag varchar2) is
l_module_name VARCHAR2(200) := g_module_name || 'UPDATE_HISTORY_TAB';
begin
----dbms_output.put_line(' inside update_history_tab');
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_statement, l_module_name,' inside update_history_tab');
IF v_flag in ('Y','N') then
---dbms_output.put_line(' inside update_history_tab updating for flag <>d');
update fv_treasury_symbols_history
   set open_flag = v_flag ,
       request_id = gbl_request_id,
       last_update_date = sysdate,
       last_updated_by = gbl_last_update_by,
       last_update_login = gbl_last_update_log,
       creation_date = sysdate,
       created_by = gbl_created_by
 where treasury_symbol_id = tres_id
   and set_of_books_id = gbl_set_of_books_id;
ELSIF v_flag = 'D' and gbl_error_code = 0 then   ---called while deleting treasury symbols ---------
    ---dbms_output.put_line(' inside update_history_tab updating for flag = d');
update fv_treasury_symbols_history
   set date_purged = TRUNC(sysdate),
       request_id = gbl_request_id,
       last_update_date = sysdate,
       last_updated_by = gbl_last_update_by,
       last_update_login = gbl_last_update_log,
       creation_date = sysdate,
       created_by = gbl_created_by
 where treasury_symbol_id = tres_id
   and set_of_books_id = gbl_set_of_books_id
   and request_id = gbl_prelim_req_id
   and date_purged is null;
ELSIF v_flag = 'R' then   --- called when report runs unsuccessfully thus rollback all the changes-------

update fv_treasury_symbols_history
   set date_purged = null,
       request_id = gbl_prelim_req_id,
       last_update_date = sysdate,
       last_updated_by = gbl_last_update_by,
       last_update_login = gbl_last_update_log,
       creation_date = sysdate,
       created_by = gbl_created_by
 where set_of_books_id = gbl_set_of_books_id
   and request_id = gbl_request_id
   and nvl(do_not_purge_flag,'N') = 'N';
END IF;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
           gbl_error_code := SQLCODE;
           gbl_error_buf  := SQLERRM;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception',gbl_error_buf);
	   return;
   WHEN OTHERS THEN
           gbl_error_code := SQLCODE;
           gbl_error_buf := SQLERRM;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',gbl_error_buf);
           return;
end update_history_tab;

-- *----------------------------------------------------------------------* --
-- *	       PROCEDURE INS_DELETE_TREASURY_SYMBOLS                      * --
-- *           -------------------------------------                      * --
-- * Called during Final Mode check Balances and update the History Tables* --
-- *----------------------------------------------------------------------* --

procedure ins_delete_treasury_symbols is
n_balance number;
n_cnt number;
v_open_flag varchar2(1);
l_module_name VARCHAR2(200):='INS_DELETE_TREASURY_SYMBOLS';
cursor c1_treas_symbol is
       select treasury_symbol,treasury_symbol_id,set_of_books_id,do_not_purge_flag,open_flag
         from fv_treasury_symbols_history fts
        where set_of_books_id = gbl_set_of_books_id
	  and treasury_symbol= nvl(gbl_treasury_symbol,treasury_symbol)
          and time_frame = nvl(gbl_time_frame,time_frame)
          and established_fiscal_yr = NVL(gbl_year_established,established_fiscal_yr)
          and nvl(to_char(trunc(cancellation_date)),'0') = NVL(to_char(gbl_cancellation_date),nvl(to_char(TRUNC(cancellation_date)),0))
	  and date_purged is null
          and nvl(do_not_purge_flag,'N') = 'N'
	  and request_id = gbl_prelim_req_id;
	  ---and open_flag in('N');
/*cursor c2_fund_param_hist (tres_id number ) is
       select fund_value
         from fv_fund_parameters_history
	where set_of_books_id = gbl_set_of_books_id
	  and treasury_symbol_id = tres_id;*/
BEGIN
--dbms_output.put_line('inside ins_delete_treasury_symbols');
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_statement, l_module_name,' Inside ins_delete_treasury_symbols');
gbl_cursor_cnt := 0;
for c1 in c1_treas_symbol
loop
gbl_cursor_cnt := 2;
     gbl_treasury_symbol_id := c1.treasury_symbol_id;
     IF  c1.open_flag = 'Y' then
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'Unable To Purge Treasury Symbol '||c1.treasury_symbol ||' as Balances or Unposted Transactions found.');
   -- for c2 in c2_fund_param_hist(c1.treasury_symbol_id)
    -- loop
       --- calculate_gl_balances(c2.fund_value,n_balance,n_cnt);

	-----------------------------------------------------------------------------------------------------
	--- if gbl_error_code <> 0 then
	       --- exit;
	--- end if;
	--- IF (n_balance > 0 ) or (n_cnt > 0) then
	     ---  v_open_flag := 'Y';
	     --ELSE
	      -- v_open_flag := 'N';
	    ---  exit;
	--- END IF;
   ---  end loop;
     ELSE
             if gbl_error_code <> 0 then
	        exit;
	     end if;
       ----   if v_open_flag = 'Y' then
         ----    update_history_tab(c1.treasury_symbol_id,v_open_flag);
	 ----- elsif v_open_flag = 'N' and gbl_error_code = 0 then
              ---delete_treasury_symbols(c1.treasury_symbol_id);
	      update_history_tab(c1.treasury_symbol_id,'D');
        -----  end if;
     END IF;
end loop;
     EXCEPTION
         WHEN OTHERS THEN
            gbl_error_code := SQLCODE;
            gbl_error_buf  := SQLERRM ||
		              ' -- Error in Delete_treasury_symbols when deleting treasury symbol' ;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error1',gbl_error_buf);
END ins_delete_treasury_symbols;

-- *----------------------------------------------------------------------* --
-- *	       PROCEDURE CALCULATE_GL_BALANCES                            * --
-- *           -------------------------------                            * --
-- * Called during Preliminary Mode and Final Mode to claculate banaces   * --
-- * and Transaction for particular fund value.                           * --
-- *----------------------------------------------------------------------* --

procedure calculate_gl_balances(p_fund_value in varchar2,p_balance out nocopy number,p_cnt out nocopy number)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'CALCULATE_GL_BALANCES';
  v_query varchar2(3000);
  prv_year  number;
  curr_year number;
  s_date gl_period_statuses.start_date%type;
  e_date gl_period_statuses.end_date%type;
  ---v_flex_value varchar2(150);
  BEGIN
    get_period_year(curr_year);


    prv_year := curr_year -1;
    BEGIN
    FOR I IN  parent_child_rollups_cur(gbl_flex_value_set_id)
    LOOP
    v_query := 'SELECT NVL(SUM((period_net_dr + begin_balance_dr) - (period_net_cr + begin_balance_cr)),0)
                  FROM gl_code_combinations gcc,gl_balances gb
                 WHERE gb.code_combination_id = gcc.code_combination_id
                   AND gcc.chart_of_accounts_id =' || gbl_account_id ||
                  'AND (GB.PERIOD_NUM,GB.PERIOD_YEAR) IN (SELECT MAX(PERIOD_NUM),PERIOD_YEAR
                                                            FROM gl_period_statuses
						           WHERE period_year IN(' || prv_year ||','|| curr_year  ||')
						             AND application_id ='|| 101||'
							     AND closing_status <>'||'''F'''||
							    'AND closing_status <>'||'''N'''||
							    'AND adjustment_period_flag ='||'''N'''||
							    'AND ledger_id ='|| gbl_set_of_books_id ||
							  'GROUP BY PERIOD_YEAR)
	          AND GB.TEMPLATE_ID IS NULL
	          AND GB.LEDGER_ID =' || gbl_set_of_books_id ||
                 'AND gb.actual_flag ='||'''A'''||
                 'AND gcc.'||gbl_bal_segment_name||' = :P_fund_value
		  AND gcc.'||gbl_acc_segment_name||' = :P_acc_value
                  AND gcc.enabled_flag='||'''Y''';

   execute immediate v_query into p_balance using p_fund_value,I.Flex_value;
	IF p_balance <> 0 then
	   exit;
	END IF;
   END LOOP;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
   	    p_balance := 0;
         WHEN OTHERS THEN
            gbl_error_code := SQLCODE;
            gbl_error_buf  := SQLERRM ||
		              ' -- Error in Calculate_Gl_Balances when finding balances and transactions for fund value';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error1',gbl_error_buf);
    END;
	-------------------------------------------------------------------------------------
	------***** To check if there any transaction unposted against the fund value *****------------
	BEGIN

	    SELECT min(start_date), max(end_date)
	      INTO s_date,e_date
	      FROM gl_period_statuses
	     WHERE period_year = curr_year
	       AND application_id = 101
	       AND closing_status <> 'F'
	       AND closing_status <> 'N'
	       AND adjustment_period_flag = 'N'
	       AND ledger_id = gbl_set_of_books_id;
	  v_query := 'SELECT count(1) FROM gl_je_lines gjl,gl_code_combinations gcc
                       WHERE gjl.ledger_id =' || gbl_set_of_books_id ||
                        'AND gjl.code_combination_id = gcc.code_combination_id
                         AND gcc.chart_of_accounts_id ='|| gbl_account_id ||
                        'AND gcc.'||gbl_bal_segment_name ||' = :p
                         AND gcc.enabled_flag = '||'''Y'''||
                        'AND gcc.account_type ='||'''A'''||
                        'AND gcc.'||gbl_acc_segment_name||' not like'||'''4350%'''||
			'AND gcc.'||gbl_acc_segment_name||' not like'||'''4201%'''||
			'AND effective_date between :s_date
                         AND :e_date
                         AND gjl.status = '||'''U''';

   execute immediate v_query into p_cnt using p_fund_value,s_date,e_date;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN

            p_cnt := 0;
         WHEN OTHERS THEN
            gbl_error_code := SQLCODE;
            gbl_error_buf  := SQLERRM ||
		              ' -- Error in Calculate_Gl_Balances while finding transactions for fund value';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error1',gbl_error_buf);
        END;
  END calculate_gl_balances;

-- *----------------------------------------------------------------------* --
-- *	       PROCEDURE GET_PERIOD_YEAR                                  * --
-- *         -------------------------------                              * --
-- * To get the running Fiscal year                                       * --
-- *----------------------------------------------------------------------* --

procedure get_period_year(p_year out nocopy number)
IS
l_module_name VARCHAR2(200):= 'GET_PERIOD_YEAR';
BEGIN

 --- sysdate := megan date;
 SELECT period_year
   INTO p_year
   FROM gl_periods
  WHERE period_set_name = gbl_period_set_name
    AND adjustment_period_flag = 'N'
  GROUP BY PERIOD_YEAR
 HAVING sysdate between min(start_date) and max(end_date);

 --p_year := 2005;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN

   	    gbl_error_code := SQLCODE;
            gbl_error_buf  := SQLERRM ||
		              ' -- Error in get_period_year finding current fiscal year';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',gbl_error_buf);

         WHEN OTHERS THEN
            gbl_error_code := SQLCODE;
            gbl_error_buf  := SQLERRM ||
		              ' -- Error in Calculate_Gl_Balances when finding balances and transactions for fund value';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error2',gbl_error_buf);
END get_period_year;

-- *----------------------------------------------------------------------* --
-- *	       PROCEDURE DELETE_TREASURY_SYMBOLS                          * --
-- *           ---------------------------------                          * --
-- * Called in Final Mode to Purge The Treasury Symbols                   * --
-- *----------------------------------------------------------------------* --
procedure delete_treasury_symbols IS

l_module_name VARCHAR2(200):= 'DELETE_TREASURY_SYMBOLS';

begin
	BEGIN
	delete from fv_fund_parameters ffp
	 where exists ( select treasury_symbol_id
	                                from fv_treasury_symbols_history fts
				       where fts.set_of_books_id = gbl_set_of_books_id
				         and fts.treasury_symbol_id = ffp.treasury_symbol_id
				         and fts.request_id = gbl_request_id
					 and fts.date_purged is not null)

	   and ffp.set_of_books_id = gbl_set_of_books_id;
	   EXCEPTION
		 WHEN NO_DATA_FOUND THEN
   		 --gbl_error_code := SQLCODE;
		 gbl_error_buf  := SQLERRM ||
		              ' -- Error no-data-found of fund value in delete_treasury_symbols for treasury symbol '||gbl_treasury_symbol_id;
			      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error1',gbl_error_buf);
		 WHEN OTHERS THEN
		 gbl_error_code := SQLCODE;
		 gbl_error_buf  := SQLERRM ||
		              ' -- Error in delete_treasury_symbols while deleting Treasury symbols from Fund Parameters';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error1',gbl_error_buf);
	    return;
         END;

	 BEGIN
	  delete from fv_treasury_symbols fts
	   where  exists ( select treasury_symbol_id
	                                from fv_treasury_symbols_history ftsh
				       where ftsh.set_of_books_id = gbl_set_of_books_id
				         and ftsh.treasury_symbol_id = fts.treasury_symbol_id
				         and ftsh.request_id = gbl_request_id
					 and ftsh.date_purged is not null)
	     and fts.set_of_books_id = gbl_set_of_books_id;
	     EXCEPTION
		 WHEN NO_DATA_FOUND THEN
   		 gbl_error_code := SQLCODE;
		 gbl_error_buf  := SQLERRM ||
		              ' -- Error no-data-found in delete_treasury_symbols ';
			      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error1',gbl_error_buf);
			      return;
		 WHEN OTHERS THEN
		 gbl_error_code := SQLCODE;
		 gbl_error_buf  := SQLERRM ||
		              ' -- Error in delete_treasury_symbols while deleting Treasury symbols';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error2',gbl_error_buf);
	    return;
         END;
end delete_treasury_symbols;


-- *----------------------------------------------------------------------* --
-- *	            PROCEDURE CLEAN_UP                                    * --
-- *                -------------------                                   * --
-- * Called in Final Mode to Delete all the Junk Data from History Tables * --
-- *----------------------------------------------------------------------* --
procedure clean_up is
l_module_name VARCHAR2(200):= 'CLEAN UP';
begin
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_statement, l_module_name,' inside clean up procedure');

      delete from fv_fund_parameters_history ffp
            where ffp.set_of_books_id = gbl_set_of_books_id
              and exists ( select treasury_symbol_id
                             from fv_treasury_symbols_history fts
		            where fts.set_of_books_id= gbl_set_of_books_id
		              and fts.treasury_symbol_id = ffp.treasury_symbol_id
			      and date_purged is null);

      delete from fv_treasury_symbols_history fts
            where fts.set_of_books_id= gbl_set_of_books_id
	      and date_purged is null;


EXCEPTION

WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
		 gbl_error_code := SQLCODE;
		 gbl_error_buf  := SQLERRM ||
		              ' -- Error in clean_up while clearing history tables';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error2',gbl_error_buf);

end clean_up;
-------------------------------------------------------------------------------------------------------------

end FV_PURGED_TREASURY_SYMBOLS;

/
