--------------------------------------------------------
--  DDL for Package Body PSB_WS_ACCT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_ACCT2" AS
/* $Header: PSBVWA2B.pls 120.46.12010000.12 2010/04/30 09:31:37 rkotha ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_WS_ACCT2';

  -- Select all Account Sets assigned to a Budget Group
  CURSOR c_AccSet (budgetgroup_id NUMBER)
  IS
  SELECT account_position_set_id,
         effective_start_date,
         effective_end_date
  FROM   psb_set_relations_v
  WHERE  account_or_position_type = 'A'
  AND    budget_group_id          = budgetgroup_id ;

  -- Select Budget Groups in Hierarchy; 'connect by' does a depth-first search
  CURSOR c_BudGrp (budgetgroup_id NUMBER)
  IS
  SELECT budget_group_id,
         num_proposed_years
  FROM   psb_budget_groups
  WHERE  budget_group_type    = 'R'
  AND    effective_start_date <= PSB_WS_ACCT1.g_startdate_pp
  AND    ( effective_end_date is null or effective_end_date >=
           PSB_WS_ACCT1.g_enddate_cy )
  START  WITH budget_group_id      = budgetgroup_id
  CONNECT BY prior budget_group_id = parent_budget_group_id;

  TYPE g_currency_tbl_type IS TABLE OF VARCHAR2(15)
    INDEX BY BINARY_INTEGER;
  --
  g_currency                g_currency_tbl_type;

  TYPE g_baltyp_tbl_type IS TABLE OF VARCHAR2(1)
    INDEX BY BINARY_INTEGER;
  --
  g_balance_type            g_baltyp_tbl_type;

  TYPE g_budgetgroup_tbl_type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  TYPE TokNameArray IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;

  TYPE TokValArray IS TABLE OF VARCHAR2(1000)
    INDEX BY BINARY_INTEGER;

  g_gl_actual_periods       PSB_WS_ACCT1.g_budgetperiod_tbl_type;
  g_num_actual_periods      NUMBER;
  g_gl_budget_periods       PSB_WS_ACCT1.g_budgetperiod_tbl_type;
  g_num_budget_periods      NUMBER;
  g_alloc_periods           PSB_WS_ACCT1.g_budgetperiod_tbl_type;

  -- Bug#3514350: To check if CY estimates need to be processed.
  g_process_cy_estimates    BOOLEAN := TRUE;

  g_sql_budget_balance      VARCHAR2(1000);
  g_cur_budget_balance      PLS_INTEGER;
  g_sql_actual_balance      VARCHAR2(1000);
  g_cur_actual_balance      PLS_INTEGER;
  g_sql_encum_balance       VARCHAR2(1000);
  g_cur_encum_balance       PLS_INTEGER;

  g_map_criteria            VARCHAR2(1);
  g_create_zero_bal         VARCHAR2(1);

  g_actuals_func_total      NUMBER;
  g_actuals_stat_total      NUMBER;

  --bug 3704360 made the following variable as public by declaring it in the spec
  --g_running_total           NUMBER;
  g_period_amount           PSB_WS_ACCT1.g_prdamt_tbl_type;

  g_summary_ccid            NUMBER;
  g_summ_bgroup_id          NUMBER;

  /*Bug:5929875:start*/

   TYPE g_bal_ccid IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE g_bal_actual_flag IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
   TYPE g_bal_start_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
   TYPE g_bal_end_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
   TYPE g_bal_currency IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
   TYPE g_bal_period_amt IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE g_bal_fwd_bal_amt IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE g_ccid_type IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
   TYPE g_ccid_start_period IS TABLE OF DATE INDEX BY BINARY_INTEGER;
   TYPE g_ccid_end_period IS TABLE OF DATE INDEX BY BINARY_INTEGER;

   TYPE g_actuals_total IS RECORD
   (
     act_func_total        NUMBER,
     act_stat_total        NUMBER
   );

   TYPE g_actuals_total_type IS TABLE OF g_actuals_total INDEX BY BINARY_INTEGER;

   g_actuals_total_tbl  g_actuals_total_type;


   g_ccid_tbl        g_bal_ccid;
   g_actual_flag_tbl g_bal_actual_flag;
   g_start_date_tbl  g_bal_start_date;
   g_end_date_tbl    g_bal_end_date;
   g_currency_tbl    g_bal_currency;
   g_period_amt_tbl  g_bal_period_amt;
   g_fwd_bal_amt_tbl g_bal_fwd_bal_amt;
   g_ccid_type_tbl   g_ccid_type;
   g_ccid_start_period_tbl  g_ccid_start_period;
   g_ccid_end_period_tbl    g_ccid_end_period;

   TYPE g_bal_ind_type IS RECORD (
      ccid              NUMBER,
      bud_start_index   NUMBER,
      bud_end_index     NUMBER,
      act_start_index   NUMBER,
      act_end_index     NUMBER,
      encum_start_index NUMBER,
      encum_end_index   NUMBER
   );

   TYPE g_bal_ind_range IS TABLE OF g_bal_ind_type INDEX BY BINARY_INTEGER;

   g_bal_ind_range_tbl g_bal_ind_range;

   g_act_start_index   NUMBER := 0;
   g_act_end_index     NUMBER := 0;
   g_bud_start_index   NUMBER := 0;
   g_bud_end_index     NUMBER := 0;
   g_encum_start_index NUMBER := 0;
   g_encum_end_index   NUMBER := 0;


   g_old_ccid              NUMBER      :=  0; --bug:5929875
  /*Bug:5929875:end*/


  -- Bug#2719865
  g_first_ccid		    BOOLEAN := TRUE;

  -- Number of Message Tokens
  no_msg_tokens             NUMBER := 0;
  msg_tok_names             TokNameArray;
  msg_tok_val               TokValArray;

  g_dbug                    VARCHAR2(1000);

  /* start bug 4256345 */
  TYPE g_bud_ccid_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_ws_gl_budget_set_ccids g_bud_ccid_tbl_type;

  -- forward declaration
  PROCEDURE check_ccid_bal (x_return_status      out nocopy varchar2,
                            p_gl_budget_set_id   in  number);
  /* end bug 4256345 */


/*===========================================================================+
 |                             PROCEDURE pd                                  |
 +===========================================================================*/
PROCEDURE pd( p_message   IN     VARCHAR2)
IS
BEGIN
  NULL ;
  --DBMS_OUTPUT.Put_Line(p_message) ;
  --FND_FILE.put_line(FND_FILE.LOG, p_message);
END pd ;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
-- Add Token and Value to the Message Token array
PROCEDURE message_token(tokname IN VARCHAR2,
			tokval  IN VARCHAR2)
IS
BEGIN

  if no_msg_tokens is null then
    no_msg_tokens := 1;
  else
    no_msg_tokens := no_msg_tokens + 1;
  end if;

  msg_tok_names(no_msg_tokens) := tokname;
  msg_tok_val(no_msg_tokens) := tokval;

END message_token;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE add_message(appname IN VARCHAR2,
		      msgname IN VARCHAR2) IS
  i  PLS_INTEGER;
BEGIN

  if ((appname is not null) and
      (msgname is not null)) then

    FND_MESSAGE.SET_NAME(appname, msgname);

    if no_msg_tokens is not null then
      for i in 1..no_msg_tokens loop
	FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
      end loop;
    end if;
    FND_MSG_PUB.Add;

  end if;

  -- Clear Message Token stack
  no_msg_tokens := 0;
END add_message;
/* ----------------------------------------------------------------------- */


--
-- Find GL Balances for a specific PSB Budget Period identified by the
-- Start and End Dates (p_start_date, p_end_date). This PSB Budget Period
-- is mapped to the corresponding GL Period based on the profile option
-- 'PSB : GL Map Criteria'
--
PROCEDURE Map_GL_Balances
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_ytd_amount         OUT  NOCOPY  NUMBER,
  p_ccid               IN   NUMBER,
  p_account_type       IN   VARCHAR2,
  p_set_of_books_id    IN   NUMBER,
  p_balance_type       IN   VARCHAR2,
  p_currency_code      IN   VARCHAR2,
  p_budgetary_control  IN   VARCHAR2,
  p_budget_version_id  IN   NUMBER,
  p_gl_budget_set_id   IN   NUMBER,
  p_incl_trans_bal     IN   VARCHAR2,
  p_incl_adj_period    IN   VARCHAR2,
  p_start_date         IN   DATE,
  p_end_date           IN   DATE,
  /* bug no 4725091 */
  p_incl_gl_fwd_balance IN  VARCHAR2,
  p_create_wks_flag     IN  VARCHAR2
) IS

  l_period_index       PLS_INTEGER;
  l_ytd_amount         NUMBER;

  l_start_date         DATE;
  l_end_date           DATE;
  l_period_amount      NUMBER;

  num_balances         INTEGER;

  l_period_amt     NUMBER := 0; --Bug:5929875


BEGIN

  l_ytd_amount := 0;

  /*Bug5929875:Instead of Dynamic sqls, global plsql tables are used. These
    plsql tables are populated in the api's - Update_GL_Balances/Create_Worksheet_Accounts
    (Bulk Collect method). This is to improve the program's performance by reducing
    the number of dynamic sql calls. This is implemented for all the three balance
    types 'B','A' and 'E'. */

   if p_balance_type = 'B' then
   begin

    /* start bug 4256345 */
     if p_gl_budget_set_id is not null then
		if not g_ws_gl_budget_set_ccids.exists(p_ccid) then
			p_ytd_amount := l_ytd_amount;
  			p_return_status := FND_API.G_RET_STS_SUCCESS;
  			return;
		end if;
     end if;
     /* end bug 4256345 */

  /*Bug:5929875:Start*/

    if g_old_ccid = p_ccid AND
       g_bud_start_index IS NOT NULL AND
       g_bud_end_index <> 0 THEN

      for l_date_index in
          g_bud_start_index..g_bud_end_index loop


      if g_ccid_tbl(l_date_index) = p_ccid AND
         g_currency_tbl(l_date_index) = p_currency_code THEN

       IF p_gl_budget_set_id IS NOT NULL AND p_budget_version_id IS NULL THEN
         EXIT;
       END IF;

       IF p_account_type IN ('A','E','D') THEN
         l_period_amt := 1 * g_period_amt_tbl(l_date_index);
       ELSIF p_account_type IN ('L','O','R','C') THEN
         l_period_amt := (-1) * g_period_amt_tbl(l_date_index);
       END IF;

  /*Bug:5929875:End*/

   /*Bug:5929875:Replaced references of l_start_date_tbl with g_start_date_tbl,
     l_end_date_tbl with g_end_date_tbl, l_fwd_bal_amt_tbl with g_fwd_bal_amt_tbl*/

        for l_period_index in 1..g_num_budget_periods loop

	  if (((((g_map_criteria = 'S') and
	       (g_start_date_tbl(l_date_index) between g_gl_budget_periods(l_period_index).start_date and g_gl_budget_periods(l_period_index).end_date)) or
	      ((g_map_criteria = 'E') and
	       (g_end_date_tbl(l_date_index) between g_gl_budget_periods(l_period_index).start_date and g_gl_budget_periods(l_period_index).end_date))))
               and (g_actual_flag_tbl(l_date_index) = 'B')) --bug:7393480
	  then
	  begin
	    /* bug no 4725091 */

            /*bug:6775471:removed the condition - fnd_api.to_boolean(p_create_wks_flag) to make sure that
	      fwd balances are added to 1st period irrespective of whether it is wks creation or update gl balances.*/

            if l_period_index = 1 and fnd_api.to_boolean(p_incl_gl_fwd_balance) then

	      g_period_amount(g_gl_budget_periods(l_period_index).long_sequence_no) :=
		   nvl(g_period_amount(g_gl_budget_periods(l_period_index).long_sequence_no), 0) +
                   nvl(l_period_amt, 0) +
                   nvl(g_fwd_bal_amt_tbl(l_date_index), 0);
	      l_ytd_amount := l_ytd_amount + nvl(l_period_amt, 0) + nvl(g_fwd_bal_amt_tbl(l_date_index), 0);

            else

	      g_period_amount(g_gl_budget_periods(l_period_index).long_sequence_no) :=
		   nvl(g_period_amount(g_gl_budget_periods(l_period_index).long_sequence_no), 0) + nvl(l_period_amt, 0);
	      l_ytd_amount := l_ytd_amount + nvl(l_period_amt, 0);
            end if;

	  end;
	  end if;

        end loop;

    --Bug:5929875:start
    end if;
    --Bug:5929875:end

      -- for bug 4256345
      end loop;

   end if; --bug:5929875

  end;
  elsif p_balance_type = 'A' then
  begin

    /*Bug:5929875:start*/

    if g_old_ccid = p_ccid AND
       g_act_start_index IS NOT NULL AND
       g_act_end_index <> 0 THEN

      for l_date_index in g_act_start_index..g_act_end_index loop

      if g_ccid_tbl(l_date_index) = p_ccid AND
         g_currency_tbl(l_date_index) = p_currency_code THEN

       IF p_account_type IN ('A','E','D') THEN
         l_period_amt := 1 * g_period_amt_tbl(l_date_index);
       ELSIF p_account_type IN ('L','O','R','C') THEN
         l_period_amt := (-1) * g_period_amt_tbl(l_date_index);
       END IF;

     /*Bug:5929875:end*/

   /*Bug:5929875:Replaced references of l_start_date_tbl with g_start_date_tbl,
     l_end_date_tbl with g_end_date_tbl, l_fwd_bal_amt_tbl with g_fwd_bal_amt_tbl*/

        for l_period_index in 1..g_num_actual_periods loop

	  if (((((g_map_criteria = 'S') and
	      (g_start_date_tbl(l_date_index) between g_gl_actual_periods(l_period_index).start_date and g_gl_actual_periods(l_period_index).end_date)) or
	      ((g_map_criteria = 'E') and
	       (g_end_date_tbl(l_date_index) between g_gl_actual_periods(l_period_index).start_date and g_gl_actual_periods(l_period_index).end_date))))
               and (g_actual_flag_tbl(l_date_index) = 'A')) --bug:7393480
          then
	  begin

	    g_period_amount(g_gl_actual_periods(l_period_index).long_sequence_no) :=
		   nvl(g_period_amount(g_gl_actual_periods(l_period_index).long_sequence_no), 0) + nvl(l_period_amt, 0);
	    l_ytd_amount := l_ytd_amount + nvl(l_period_amt, 0);

	  end;
	  end if;

        end loop;

    --Bug:5929875:start
    end if;
    --Bug:5929875:end

      -- for bug 4256345
      end loop;

   end if; --bug:5929875

      -- for bug 4256345

  end;
  elsif p_balance_type = 'E' then
  begin

    /*Bug:5929875:start*/

    if g_old_ccid = p_ccid AND
       g_encum_start_index IS NOT NULL AND g_encum_end_index <> 0 THEN


      for l_date_index in g_encum_start_index..g_encum_end_index loop

      if g_ccid_tbl(l_date_index) = p_ccid AND
         g_currency_tbl(l_date_index) = p_currency_code THEN

       IF p_account_type IN ('A','E','D') THEN
         l_period_amt := 1 * g_period_amt_tbl(l_date_index);
       ELSIF p_account_type IN ('L','O','R','C') THEN
         l_period_amt := (-1) * g_period_amt_tbl(l_date_index);
       END IF;

   /*Bug:5929875:end*/

   /*Bug:5929875:Replaced references of l_start_date_tbl with g_start_date_tbl,
     l_end_date_tbl with g_end_date_tbl, l_fwd_bal_amt_tbl with g_fwd_bal_amt_tbl*/

        for l_period_index in 1..g_num_actual_periods loop

	  if (((((g_map_criteria = 'S') and
	       (g_start_date_tbl(l_date_index) between g_gl_actual_periods(l_period_index).start_date and g_gl_actual_periods(l_period_index).end_date)) or
	     ((g_map_criteria = 'E') and
	       (g_end_date_tbl(l_date_index) between g_gl_actual_periods(l_period_index).start_date and g_gl_actual_periods(l_period_index).end_date))))
               and (g_actual_flag_tbl(l_date_index) = 'E'))  --bug:7393480
          then
	  begin

           /* bug no 4725091 */

	    /*bug:6775471:removed the condition - fnd_api.to_boolean(p_create_wks_flag) to make sure that
	      fwd balances are added to 1st period irrespective of whether it is wks creation or update gl balances.*/

            if l_period_index = 1 and fnd_api.to_boolean(p_incl_gl_fwd_balance) then

              g_period_amount(g_gl_actual_periods(l_period_index).long_sequence_no) :=
		   nvl(g_period_amount(g_gl_actual_periods(l_period_index).long_sequence_no), 0) +
                   nvl(l_period_amt, 0) +
                   nvl(g_fwd_bal_amt_tbl(l_date_index), 0);

	      l_ytd_amount := l_ytd_amount + nvl(l_period_amt, 0) + nvl(g_fwd_bal_amt_tbl(l_date_index), 0);

            else

	      g_period_amount(g_gl_actual_periods(l_period_index).long_sequence_no) :=
		   nvl(g_period_amount(g_gl_actual_periods(l_period_index).long_sequence_no), 0) + nvl(l_period_amt, 0);
	      l_ytd_amount := l_ytd_amount + nvl(l_period_amt, 0);

            end if;

	  end;
	  end if;

        end loop;

    --Bug:5929875:start
    end if;
    --Bug:5929875:end

      -- for bug 4256345
      end loop;

   end if; --bug:5929875

  end;
  end if;


  -- Initialize API return status to success

  p_ytd_amount := l_ytd_amount;
  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Map_GL_Balances');
     end if;

END Map_GL_Balances;

/* ----------------------------------------------------------------------- */

-- Get GL Balances for a Budget Year by mapping individual Budget Periods in
-- the Budget Year to GL Periods

PROCEDURE Get_Balances
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_ccid                IN   NUMBER,
  p_account_type        IN   VARCHAR2,
  p_budget_year_id      IN   NUMBER,
  p_year_name           IN   VARCHAR2,
  p_year_start_date     IN   DATE,
  p_year_end_date       IN   DATE,
  p_budget_year_type    IN   VARCHAR2,
  p_incl_stat_bal       IN   VARCHAR2,
  p_incl_trans_bal      IN   VARCHAR2,
  p_incl_adj_period     IN   VARCHAR2,
  p_set_of_books_id     IN   NUMBER,
  p_budget_group_id     IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_func_currency       IN   VARCHAR2,
  p_budgetary_control   IN   VARCHAR2,
  p_budget_version_id   IN   NUMBER,
  p_flex_mapping_set_id IN   NUMBER,
  p_gl_budget_set_id    IN   NUMBER,
  p_flex_code           IN   NUMBER,
  p_worksheet_id        IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_sequence_number     IN   NUMBER,
  p_rounding_factor     IN   NUMBER,
  /* bug no 4725091 */
  p_incl_gl_fwd_balance IN   VARCHAR2,
  p_create_wks_flag     IN   VARCHAR2
) IS

  l_return_status       VARCHAR2(1);

  l_init_index          PLS_INTEGER;
  l_type_index          PLS_INTEGER;
  l_currency_index      PLS_INTEGER;

  l_ytd_amount          NUMBER;

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_budget_version_id   NUMBER;

  l_concat_segments     VARCHAR2(2000);

  l_account_line_id     NUMBER;
  l_balance_type        VARCHAR2(1);

BEGIN

  for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    g_period_amount(l_init_index) := null;
  end loop;

  l_ytd_amount := 0;

  for l_init_index in 1..g_currency.Count loop
    g_currency(l_init_index) := null;
  end loop;

  if p_func_currency <> 'STAT' then
    g_currency(1) := p_func_currency;

    if FND_API.to_Boolean(p_incl_stat_bal) then
      g_currency(2) := 'STAT';
    end if;
  else
    g_currency(1) := 'STAT';
  end if;

  -- Get the budget for the CCID if a budget set is assigned to the worksheet

  if p_gl_budget_set_id is not null then
  begin

    PSB_GL_BUDGET_PVT.Find_GL_Budget
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_msg_count => l_msg_count,
	p_msg_data => l_msg_data,
	p_gl_budget_set_id => p_gl_budget_set_id,
	p_code_combination_id => p_ccid,
	p_start_date => p_year_start_date,
	p_gl_budget_version_id => l_budget_version_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    if l_budget_version_id is null then
    begin

      PSB_GL_BUDGET_PVT.Find_GL_Budget
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_gl_budget_set_id => p_gl_budget_set_id,
	  p_code_combination_id => p_ccid,
	  p_start_date => p_year_start_date,
	  p_gl_budget_version_id => l_budget_version_id,
	  p_dual_posting_type => 'A');

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end;
  end if;

  for l_type_index in 1..g_balance_type.Count loop

    for l_currency_index in 1..g_currency.Count loop

      if g_currency(l_currency_index) is not null then
      begin

	Map_GL_Balances
	   (p_ccid => p_ccid,
	    p_account_type => p_account_type,
	    p_set_of_books_id => p_set_of_books_id,
	    p_balance_type => g_balance_type(l_type_index),
	    p_currency_code => g_currency(l_currency_index),
	    p_budgetary_control => p_budgetary_control,
	    p_budget_version_id => l_budget_version_id,
	    p_gl_budget_set_id => p_gl_budget_set_id,
	    p_incl_trans_bal => p_incl_trans_bal,
	    p_incl_adj_period => p_incl_adj_period,
	    p_start_date => p_year_start_date,
	    p_end_date => p_year_end_date,
	    p_return_status => l_return_status,
	    p_ytd_amount => l_ytd_amount,
            /* bug no 4725091 */
            p_incl_gl_fwd_balance => p_incl_gl_fwd_balance,
            p_create_wks_flag     => p_create_wks_flag);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

	-- Store the Actual Balances for Functional Currency and STAT so that allocation of
	-- CY Balances only includes the Estimate part

	if ((p_budget_year_type = 'CY') and (g_balance_type(l_type_index) = 'A')) then
	begin

	  if g_currency(l_currency_index) = p_func_currency then
	    g_actuals_func_total := l_ytd_amount;
	  else
	    g_actuals_stat_total := l_ytd_amount;
	  end if;

	end;
	end if;

	-- Create Account Distribution if YTD Amount > 0 or YTD Amount is 0 and allowed by
	-- the profile option


       --Commented the following line for bug 3305778
       -- Bug 3543845: Reactivate the following line

       -- Bug 4250468 added the variable g_ws_first_time_creation_flag
       -- in the IF condition
        IF ( PSB_WORKSHEET.g_ws_first_time_creation_flag AND
            ((l_ytd_amount <> 0)
             OR
             ( l_ytd_amount = 0 and g_create_zero_bal = 'Y' )
            )
           )
        OR NOT PSB_WORKSHEET.g_ws_first_time_creation_flag THEN

	begin

	  if g_balance_type(l_type_index) = 'E' then
	    l_balance_type := 'X';
	  else
	    l_balance_type := g_balance_type(l_type_index);
	  end if;

          --pd('1: Call Create_Account_Dist=> ccid=' || TO_CHAR(p_ccid) ||
          --   ', p_budget_year_id=' || TO_CHAR(p_budget_year_id) ||
          --   ', l_balance_type=' || l_balance_type ||
          --   ', p_ytd_amount=' || TO_CHAR(l_ytd_amount));

	  PSB_WS_ACCT1.Create_Account_Dist
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_account_line_id => l_account_line_id,
	      p_worksheet_id => p_worksheet_id,
	      p_service_package_id => p_service_package_id,
	      p_check_spal_exists => FND_API.G_FALSE,
	      p_gl_cutoff_period => null,
	      p_allocrule_set_id => null,
	      p_budget_calendar_id => null,
	      p_rounding_factor => p_rounding_factor,
	      p_stage_set_id => p_stage_set_id,
	      p_start_stage_seq => p_sequence_number,
	      p_current_stage_seq => p_sequence_number,
	      p_budget_group_id => p_budget_group_id,
	      p_budget_year_id => p_budget_year_id,
	      p_ccid => p_ccid,
	      p_flex_mapping_set_id => p_flex_mapping_set_id,
	      p_map_accounts => TRUE,
	      p_currency_code => g_currency(l_currency_index),
	      p_balance_type => l_balance_type,
	      p_ytd_amount => l_ytd_amount,
	      p_period_amount => g_period_amount);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
	    g_period_amount(l_init_index) := null;
	  end loop;

	  l_ytd_amount := 0;

	end;
	end if;

      end;
      end if;

    end loop; /* Currency */

  end loop; /* Balance Type */


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Get_Balances');
     end if;

END Get_Balances;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                        PROCEDURE Create_Worksheet_Accounts                |
 +===========================================================================*/
PROCEDURE Create_Worksheet_Accounts
( p_return_status              OUT  NOCOPY  VARCHAR2,
  p_worksheet_id               IN   NUMBER,
  p_rounding_factor            IN   NUMBER,
  p_stage_set_id               IN   NUMBER,
  p_service_package_id         IN   NUMBER,
  p_start_stage_seq            IN   NUMBER,
  p_allocrule_set_id           IN   NUMBER,
  p_budget_group_id            IN   NUMBER,
  p_flex_code                  IN   NUMBER,
  p_parameter_set_id           IN   NUMBER,
  p_budget_calendar_id         IN   NUMBER,
  p_gl_cutoff_period           IN   DATE,
  p_include_gl_commit_balance  IN   VARCHAR2,
  p_include_gl_oblig_balance   IN   VARCHAR2,
  p_include_gl_other_balance   IN   VARCHAR2,
  p_budget_version_id          IN   NUMBER,
  p_flex_mapping_set_id        IN   NUMBER,
  p_gl_budget_set_id           IN   NUMBER,
  p_set_of_books_id            IN   NUMBER,
  p_set_of_books_name          IN   VARCHAR2,
  p_func_currency              IN   VARCHAR2,
  p_budgetary_control          IN   VARCHAR2,
  p_incl_stat_bal              IN   VARCHAR2,
  p_incl_trans_bal             IN   VARCHAR2,
  p_incl_adj_period            IN   VARCHAR2,
  p_num_proposed_years         IN   NUMBER,
  p_num_years_to_allocate      IN   NUMBER,
  p_budget_by_position         IN   VARCHAR2,
  /* Bug No 4725091 */
  P_incl_gl_fwd_balance        IN   VARCHAR2
)
IS
  --

  l_ccid_index              PLS_INTEGER;
  l_year_index              PLS_INTEGER;
  l_period_index            PLS_INTEGER;
  l_init_index              PLS_INTEGER;

  l_userid                  NUMBER;
  l_loginid                 NUMBER;

  l_account_type            VARCHAR2(1);
  l_template_id             NUMBER;

  l_ccid_type               VARCHAR2(30);
  l_ccid_start_period       DATE;
  l_ccid_end_period         DATE;

  l_num_projected_years     NUMBER;
  l_year_start_date         DATE;
  l_year_end_date           DATE;

  /*bug:7393480:start*/
  l_ind_process             NUMBER := 0;
  /*bug:7393480:end*/

  l_num_accounts            NUMBER := 0;
  l_return_status           VARCHAR2(1);

  TYPE ccid_arr IS TABLE OF NUMBER(15);
  TYPE date_arr IS TABLE OF DATE;

  /* start bug 4256345 */

  /*bug:5929875:added start_date and end_date in the record type definition.
    It is to fetch the effective date info using c_ccids cursor */
  TYPE ccid_rec IS RECORD   (  ccid       ccid_arr ,
                               start_date date_arr ,
                               end_date   date_arr ) ;
  l_ccids                   ccid_rec;

/*bug:5929875:start*/

 CURSOR c_ccids ( c_account_set_id NUMBER)
  IS
  SELECT b.code_combination_id, b.start_date_active, b.end_date_active
  FROM   gl_code_combinations b,psb_budget_accounts a
  WHERE  b.detail_budgeting_allowed_flag = 'Y'
  AND    b.enabled_flag            = 'Y'
  AND    b.code_combination_id     = a.code_combination_id
  /* Bug 3692601 Start */
  AND    a.account_position_set_id = c_account_set_id
  /* Bug 3692601 End */
  AND    b.code_combination_id = g_old_ccid;


 l_gl_budget_id          NUMBER;
 l_budget_version_id     NUMBER;

 l_incl_adj_flag         VARCHAR2(1) := 'N';
 l_commit_enc_type_id    NUMBER;
 l_oblig_enc_type_id     NUMBER;
 l_gl_other_bal_flag     VARCHAR2(1) := 'N';
 l_gl_commit_bal_flag    VARCHAR2(1) := 'N';
 l_gl_oblig_bal_flag     VARCHAR2(1) := 'N';
 l_bud_actual_flag       VARCHAR2(1) := 'B';
 l_act_actual_flag       VARCHAR2(1) := 'A';
 l_encum_actual_flag     VARCHAR2(1) := 'E';
 l_cy_flag               VARCHAR2(1) := 'Y';
 l_cn_flag               VARCHAR2(1) := 'N';

 l_old_bal_flag          VARCHAR2(1) := 'X';
 l_index                 NUMBER      :=  0;

 cursor c_fin is
 select purch_encumbrance_type_id, req_encumbrance_type_id
 from financials_system_parameters;

 /*Bug:7393480:Modified cursor - c_bal_csr to make sure that record is returned with
   null details when there is no balance on gl side for a given ccid which
   is part of the account set(s) attached to PSB Budget group hierarchy.*/

 /*Order by code_combination_id,actual_flag is required in both the
   cursors c_bal_csr,c_bal_budcntl_csr as the processing of the
   records depends on this.*/ --Bug:5929875

/*bug:5929875: Cursor to fetch balances from GL*/
 CURSOR c_bal_csr(p_account_position_set_id NUMBER,
                      p_budget_version_id NUMBER,
                      p_year_start_date DATE,
                      p_year_end_date   DATE,
                      p_map_criteria    VARCHAR2) IS
 select a.code_combination_id, gb.actual_flag,
        gs.start_date, gs.end_date,
        gb.currency_code,
 (nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0)),
  (nvl(gb.BEGIN_BALANCE_DR, 0) - nvl(gb.BEGIN_BALANCE_CR,0))
 from
       GL_BALANCES gb,
       GL_PERIOD_STATUSES gs,
       psb_budget_accounts  a
 where gb.ledger_id = p_set_of_books_id
 and ((gb.translated_flag is null) or (gb.translated_flag = l_cy_flag))
 and gb.period_name = gs.period_name
 and gb.period_type = gs.period_type
 and gb.period_year = gs.period_year
 and gb.period_num = gs.period_num
 and (((l_incl_adj_flag = l_cn_flag) and (gs.adjustment_period_flag = l_cn_flag))
      or (l_incl_adj_flag = l_cy_flag))
 and gs.set_of_books_id = p_set_of_books_id
 and gs.application_id = 101
 and decode(p_map_criteria,'S',gs.start_date,gs.end_date) between
     p_year_start_date and p_year_end_date
 and gb.code_combination_id = a.code_combination_id
 and a.account_position_set_id = p_account_position_set_id
 and  ((gb.actual_flag = l_bud_actual_flag
 and ((p_gl_budget_set_id IS NOT NULL
      AND gb.budget_version_id = nvl(p_budget_version_id,l_budget_version_id)) OR
      (p_gl_budget_set_id IS NULL))) OR (gb.actual_flag = l_act_actual_flag)
      OR (gb.actual_flag = l_encum_actual_flag
      and ((l_gl_other_bal_flag = l_cy_flag and
((l_gl_commit_bal_flag = l_cn_flag and
((l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id not in (l_oblig_enc_type_id,l_commit_enc_type_id)) OR
 (l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id not in (l_commit_enc_type_id))))  OR
 (l_gl_commit_bal_flag = l_cy_flag and
  (l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id not in (l_oblig_enc_type_id) OR
  (l_gl_oblig_bal_flag = l_cy_flag)))))  OR
 (l_gl_other_bal_flag = l_cn_flag and
  (l_gl_commit_bal_flag = l_cn_flag and l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id in (l_oblig_enc_type_id)) OR
  (l_gl_commit_bal_flag = l_cn_flag and l_gl_oblig_bal_flag = l_cn_flag) OR
  (l_gl_commit_bal_flag = l_cy_flag and
   ((l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id in (l_commit_enc_type_id))  OR
    (l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id in (l_commit_enc_type_id,l_oblig_enc_type_id))))))))
 union
 select a.code_combination_id, null,
        gs.start_date, gs.end_date,
        null,0,0
 from  GL_PERIOD_STATUSES gs,
       psb_budget_accounts  a
where (((l_incl_adj_flag = l_cn_flag) and (gs.adjustment_period_flag = l_cn_flag))
      or (l_incl_adj_flag = l_cy_flag))
 and gs.set_of_books_id = p_set_of_books_id
 and gs.application_id = 101
 and a.account_position_set_id = p_account_position_set_id
 and decode(p_map_criteria,'S',gs.start_date,gs.end_date) between
     p_year_start_date and p_year_end_date
 and not exists
 (select 1
  from gl_balances gb
  where gb.code_combination_id = a.code_combination_id
    and gb.period_name = gs.period_name
    and gb.period_type = gs.period_type
    and gb.period_year = gs.period_year
    and gb.period_num = gs.period_num
    and gb.ledger_id = p_set_of_books_id
    )
order by code_combination_id,actual_flag,start_date;

 /*Bug:7393480:Modified cursor - c_bal_budcntl_csr to make sure that record is
   returned with null details when there is no balance on gl side for a given ccid
   which is part of the account set(s) attached to PSB Budget group hierarchy.*/

/*bug:5929875: Cursor to fetch balances from GL when budgetary control is turned on*/
 CURSOR c_bal_budcntl_csr(p_account_position_set_id NUMBER,
                      p_budget_version_id NUMBER,
                      p_year_start_date DATE,
                      p_year_end_date   DATE,
                      p_map_criteria    VARCHAR2) IS
 select a.code_combination_id, gb.actual_flag,
        gs.start_date, gs.end_date,
        gb.currency_code,
 (nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0)),
  (nvl(gb.BEGIN_BALANCE_DR, 0) - nvl(gb.BEGIN_BALANCE_CR,0))
 from
       GL_BALANCES gb,
       GL_PERIOD_STATUSES gs,
       psb_budget_accounts  a
 where gb.ledger_id = p_set_of_books_id
 and ((gb.translated_flag is null) or (gb.translated_flag = l_cy_flag))
 and gb.period_name = gs.period_name
 and gb.period_type = gs.period_type
 and gb.period_year = gs.period_year
 and gb.period_num = gs.period_num
 and (((l_incl_adj_flag = l_cn_flag) and (gs.adjustment_period_flag = l_cn_flag))
      or (l_incl_adj_flag = l_cy_flag))
 and gs.set_of_books_id = p_set_of_books_id
 and gs.application_id = 101
 and decode(p_map_criteria,'S',gs.start_date,gs.end_date) between
     p_year_start_date and p_year_end_date
 and gb.code_combination_id = a.code_combination_id
 and a.account_position_set_id = p_account_position_set_id
 and  ((gb.actual_flag = l_bud_actual_flag
   and exists(
    select 1
    from   GL_BUDGET_ASSIGNMENTS ga,GL_BUDORG_BC_OPTIONS  gc
    where  ga.code_combination_id = a.code_combination_id
    and    gb.budget_version_id = gc.funding_budget_version_id
    and    ga.range_id = gc.range_id))
    OR (gb.actual_flag = l_act_actual_flag)
      OR (gb.actual_flag = l_encum_actual_flag
      and ((l_gl_other_bal_flag = l_cy_flag and
((l_gl_commit_bal_flag = l_cn_flag and
((l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id not in (l_oblig_enc_type_id,l_commit_enc_type_id)) OR
 (l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id not in (l_commit_enc_type_id))))  OR
 (l_gl_commit_bal_flag = l_cy_flag and
  (l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id not in (l_oblig_enc_type_id) OR
  (l_gl_oblig_bal_flag = l_cy_flag)))))  OR
 ( l_gl_other_bal_flag = l_cn_flag and
  (l_gl_commit_bal_flag = l_cn_flag and l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id in (l_oblig_enc_type_id)) OR
  (l_gl_commit_bal_flag = l_cn_flag and l_gl_oblig_bal_flag = l_cn_flag) OR
  (l_gl_commit_bal_flag = l_cy_flag and
   ((l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id in (l_commit_enc_type_id))  OR
    (l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id in (l_commit_enc_type_id,l_oblig_enc_type_id))))))))
 union
 select a.code_combination_id, null,
        gs.start_date, gs.end_date,
        null,0,0
 from  GL_PERIOD_STATUSES gs,
       psb_budget_accounts  a
where (((l_incl_adj_flag = l_cn_flag) and (gs.adjustment_period_flag = l_cn_flag))
      or (l_incl_adj_flag = l_cy_flag))
 and gs.set_of_books_id = p_set_of_books_id
 and gs.application_id = 101
 and a.account_position_set_id = p_account_position_set_id
 and decode(p_map_criteria,'S',gs.start_date,gs.end_date) between
     p_year_start_date and p_year_end_date
 and not exists
 (select 1
  from gl_balances gb
  where gb.code_combination_id = a.code_combination_id
    and gb.period_name = gs.period_name
    and gb.period_type = gs.period_type
    and gb.period_year = gs.period_year
    and gb.period_num = gs.period_num
    and gb.ledger_id = p_set_of_books_id)
order by code_combination_id,actual_flag,start_date;

/*bug:5929875:end*/

  lt_start_date_active	DATE;
  lt_end_date_active	DATE;
  lt_valid_ccid			VARCHAR2(30) := 'FALSE';
  /* end bug 4256345 */

BEGIN

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  -- g_deferred_ccids holds CCIDs that are deferred for parameter processing;
  -- these CCIDs are deferred because they depend on CCID(s) that have not been
  -- computed yet. This problem arises as we follow a depth first search of
  -- the Budget Group Hierarchy and (consequently) the Account Sets that are
  -- assigned to Budget Groups in the Hierarchy

  for l_init_index in 1..g_deferred_ccids.Count loop
    g_deferred_ccids(l_init_index).budget_group_id := null;
    g_deferred_ccids(l_init_index).num_proposed_years := null;
    g_deferred_ccids(l_init_index).ccid := null;
    g_deferred_ccids(l_init_index).ccid_start_period := null;
    g_deferred_ccids(l_init_index).ccid_end_period := null;
  end loop;

  g_num_defccids := 0;

  -- g_dependent_ccids stores dependency between CCIDs; this is used to sort
  -- CCIDs to avoid circular loops; e.g CCID-1 depends on CCID-2 that depends
  -- on CCID-3 : we sort the CCIDs so that CCID-3 is processed first, followed
  -- by CCID-2 followed by CCID-1

  for l_init_index in 1..g_dependent_ccids.Count loop
    g_dependent_ccids(l_init_index).ccid := null;
    g_dependent_ccids(l_init_index).dependent_ccid := null;
  end loop;

  g_num_depccids := 0;

  -- g_sorted_ccids stores the deferred CCIDs sorted so that there are no
  -- dependencies between the sorted CCIDs
  for l_init_index in 1..g_sorted_ccids.Count loop
    g_sorted_ccids(l_init_index).budget_group_id := null;
    g_sorted_ccids(l_init_index).num_proposed_years := null;
    g_sorted_ccids(l_init_index).ccid := null;
    g_sorted_ccids(l_init_index).ccid_start_period := null;
    g_sorted_ccids(l_init_index).ccid_end_period := null;
  end loop;

  g_num_sortccids := 0;

/*bug:5929875:start*/

  if (p_incl_adj_period is null or p_incl_adj_period = 'N') then
    l_incl_adj_flag   := 'N';
  else
    l_incl_adj_flag   := 'Y';
  end if;

  if (p_include_gl_commit_balance is null or p_include_gl_commit_balance = 'N')
  then
        l_gl_commit_bal_flag := 'N';
  else
        l_gl_commit_bal_flag := 'Y';
  end if;

  if (p_include_gl_oblig_balance is null or p_include_gl_oblig_balance = 'N')
  then
    l_gl_oblig_bal_flag := 'N';
  else
    l_gl_oblig_bal_flag := 'Y';
  end if;

  if (p_include_gl_other_balance is null or p_include_gl_other_balance = 'N')
  then
    l_gl_other_bal_flag := 'N';
  else
    l_gl_other_bal_flag := 'Y';
  end if;

/*bug:5929875:end*/


  --
  -- If Budget Set is not defined for the worksheet, the funding budget must
  -- be selected in the 'Define Worksheet' form for Set of Books that do not
  -- have budgetary control turned on.
  --
  if p_gl_budget_set_id is null then

    if (not FND_API.to_Boolean(p_budgetary_control)) then
      message_token('SOB', p_set_of_books_name);
      message_token('WORKSHEET_ID', p_worksheet_id);
      add_message('PSB', 'PSB_BUDGET_VERSION');
      raise FND_API.G_EXC_ERROR;
    end if;

  end if;


  -- GL Mapping Criteria Profile Option : this specifies how to map the PSB
  -- Budget Periods to the GL Budget Periods.  'S' indicates that the Start
  -- Date for a GL Period should be within a PSB Budget Period specified by
  -- Start and End Dates; 'E' indicates that the End Date for a GL Period
  -- should be within a PSB Budget Period specified by Start and End Dates.

  FND_PROFILE.GET( name => 'PSB_GL_MAP_CRITERIA' ,
                   val => g_map_criteria         ) ;
  if g_map_criteria is null then
    g_map_criteria := 'S';
  end if;


  -- Create Zero Balances Profile Option : this specifies whether non-Position
  -- CCIDs with zero YTD Amounts should be created in PSB_WS_ACCOUNT_LINES

  FND_PROFILE.GET
     (name => 'PSB_CREATE_ZERO_BALANCE_ACCT',
      val => g_create_zero_bal);

  if g_create_zero_bal is null then
    -- Bug 3543845: Change default behavior to not creating zero balance
    g_create_zero_bal := 'N';
  end if;

  /*Bug:5929875:Dynamic sqls replaced with Static Sqls*/

  /* start bug 4256345 */
  IF p_gl_budget_set_id IS NOT NULL THEN
    check_ccid_bal (x_return_status  		=> l_return_status,
                    p_gl_budget_set_id    => p_gl_budget_set_id);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  /* end bug 4256345 */


  -- Currently, only Actual and Budget Balances are extracted from GL

  g_balance_type(1) := 'A';
  g_balance_type(2) := 'B';

  if ((FND_API.to_Boolean(p_include_gl_commit_balance)) or
      (FND_API.to_Boolean(p_include_gl_oblig_balance)) or
      (FND_API.to_Boolean(p_include_gl_other_balance))) then
    g_balance_type(3) := 'E';
  end if;

  for c_BudGrp_Rec in c_BudGrp (p_budget_group_id) loop
    -- Find Account Sets for the Budget Group

    for c_AccSet_Rec in c_AccSet (c_BudGrp_Rec.budget_group_id) loop

    g_ccid_type_tbl.delete;
    g_ccid_start_period_tbl.delete;
    g_ccid_end_period_tbl.delete;

  /*Bug:5929875:start*/
     for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

     g_ccid_tbl.delete;
     g_actual_flag_tbl.delete;
     g_start_date_tbl.delete;
     g_end_date_tbl.delete;
     g_currency_tbl.delete;
     g_period_amt_tbl.delete;
     g_fwd_bal_amt_tbl.delete;

     g_bal_ind_range_tbl.delete;

     l_year_start_date := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
     l_year_end_date :=   PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;

  FOR l_gl_budget_rec IN
  (
    SELECT gl_budget_id,
	   gl_budget_version_id
    FROM   psb_gl_budgets
    WHERE  gl_budget_set_id = p_gl_budget_set_id
    AND    l_year_start_date BETWEEN start_date AND end_date
    AND    NVL( dual_posting_type, 'P' ) = 'P'

  )
  LOOP
     l_gl_budget_id := l_gl_budget_rec.gl_budget_id;
     l_budget_version_id := l_gl_budget_rec.gl_budget_version_id;
  END LOOP;

  -- Get the budget for the CCID if a budget set is assigned to the worksheet

    if l_budget_version_id is null then
    begin

      FOR l_gl_budget_rec IN
      (
        SELECT gl_budget_id,
         gl_budget_version_id
        FROM   psb_gl_budgets
        WHERE  gl_budget_set_id = p_gl_budget_set_id
        AND    l_year_start_date BETWEEN start_date AND end_date
        AND    NVL( dual_posting_type, 'P' ) = 'A'

      )
      LOOP
         l_gl_budget_id := l_gl_budget_rec.gl_budget_id;
         l_budget_version_id := l_gl_budget_rec.gl_budget_version_id;
      END LOOP;

    end;
    end if;

  for c_fin_rec in c_fin loop
    l_commit_enc_type_id := c_fin_rec.req_encumbrance_type_id;
    l_oblig_enc_type_id := c_fin_rec.purch_encumbrance_type_id;
  end loop;

 if p_gl_budget_set_id is null then
  if FND_API.to_Boolean(p_budgetary_control) then

  OPEN c_bal_budcntl_csr(c_AccSet_Rec.account_position_set_id,
                         nvl(p_budget_version_id,l_budget_version_id),
                         l_year_start_date,
                         l_year_end_date,
                         g_map_criteria);

  /*Bug:5929875:Bulk collect GL balances into plsql tables*/
  FETCH c_bal_budcntl_csr BULK COLLECT INTO
                      g_ccid_tbl,
                      g_actual_flag_tbl,
                      g_start_date_tbl,
                      g_end_date_tbl,
                      g_currency_tbl,
                      g_period_amt_tbl,
                      g_fwd_bal_amt_tbl;

  IF c_bal_budcntl_csr%NOTFOUND THEN
    CLOSE c_bal_budcntl_csr;
  END IF;

  IF c_bal_budcntl_csr%ISOPEN THEN
    CLOSE c_bal_budcntl_csr;
  END IF;
  end if;
else

  OPEN c_bal_csr(c_AccSet_Rec.account_position_set_id,
                 nvl(p_budget_version_id,l_budget_version_id),
                 l_year_start_date,
                 l_year_end_date,
                 g_map_criteria);

  /*Bug:5929875:Bulk collect GL balances into plsql tables*/
  FETCH c_bal_csr BULK COLLECT INTO
                    g_ccid_tbl,
                    g_actual_flag_tbl,
                    g_start_date_tbl,
                    g_end_date_tbl,
                    g_currency_tbl,
                    g_period_amt_tbl,
                    g_fwd_bal_amt_tbl;

  IF c_bal_csr%NOTFOUND THEN
    CLOSE c_bal_csr;
  END IF;

  IF c_bal_csr%ISOPEN THEN
    CLOSE c_bal_csr;
  END IF;
end if;

  g_old_ccid := 0;
  l_old_bal_flag := 'X';
  l_index := 0;

  g_bud_start_index   := 0;
  g_bud_end_index     := 0;
  g_act_start_index   := 0;
  g_act_end_index     := 0;
  g_encum_start_index := 0;
  g_encum_end_index   := 0;
  l_ind_process       := 0;--bug:7393480

  /*Bug:5929875: g_act_start_index, g_act_end_index are assigned with
    start and end indexes of Actual balances for a given ccid (g_old_ccid).
    Similarly  g_bud_start_index,g_bud_end_index for Budget balances and
    g_encum_start_index, g_encum_end_index for Encumbrance balances*/

  FOR l_cc_index IN 1..g_ccid_tbl.count LOOP

    /*bug:7393480:start*/
    IF l_cc_index < g_ccid_tbl.LAST THEN
      l_ind_process := l_cc_index+1;
    ELSIF l_cc_index = g_ccid_tbl.LAST THEN
      l_ind_process := l_cc_index;
    END IF;
    /*bug:7393480:end*/

    IF g_old_ccid = 0 THEN
       g_old_ccid := g_ccid_tbl(l_cc_index);
       IF g_actual_flag_tbl(l_cc_index) = 'A' THEN
          g_act_start_index := l_cc_index;
          g_act_end_index   := l_cc_index;
       ELSIF g_actual_flag_tbl(l_cc_index) = 'B' THEN
          g_bud_start_index := l_cc_index;
          g_bud_end_index   := l_cc_index;
       ELSIF g_actual_flag_tbl(l_cc_index) = 'E' THEN
          g_encum_start_index := l_cc_index;
          g_encum_end_index := l_cc_index;
        /*bug:7393480:start*/
       ELSIF g_actual_flag_tbl(l_cc_index) IS NULL THEN
          g_act_start_index := l_cc_index;
          g_act_end_index   := l_cc_index;

          g_bud_start_index := l_cc_index;
          g_bud_end_index   := l_cc_index;

          g_encum_start_index := l_cc_index;
          g_encum_end_index := l_cc_index;
        /*bug:7393480:end*/
       END IF;

    ELSIF g_old_ccid = g_ccid_tbl(l_cc_index) THEN
      IF g_actual_flag_tbl(l_cc_index) = 'A' THEN
         IF g_act_start_index = 0 THEN
            g_act_start_index := l_cc_index;
            g_act_end_index   := l_cc_index;
         ELSE
            g_act_end_index := l_cc_index;
         END IF;
      ELSIF g_actual_flag_tbl(l_cc_index) = 'B' THEN
         IF g_bud_start_index = 0 THEN
            g_bud_start_index := l_cc_index;
            g_bud_end_index   := l_cc_index;
         ELSE
            g_bud_end_index := l_cc_index;
         END IF;
      ELSIF g_actual_flag_tbl(l_cc_index) = 'E' THEN
         IF g_encum_start_index = 0 THEN
            g_encum_start_index := l_cc_index;
            g_encum_end_index   := l_cc_index;
         ELSE
            g_encum_end_index := l_cc_index;
         END IF;
       /*bug:7393480:start*/
      ELSIF g_actual_flag_tbl(l_cc_index) IS NULL THEN
         IF g_act_start_index = 0 THEN
            g_act_start_index := l_cc_index;
            g_act_end_index   := l_cc_index;
         ELSIF g_act_end_index - g_act_start_index = 0 THEN    --bug:7393480:modified
            g_act_end_index := l_cc_index;
         END IF;

         IF g_bud_start_index = 0 THEN
            g_bud_start_index := l_cc_index;
            g_bud_end_index   := l_cc_index;
         ELSIF g_bud_end_index - g_bud_start_index = 0 THEN   --bug:7393480:modified
            g_bud_end_index := l_cc_index;
         END IF;

         IF g_encum_start_index = 0 THEN
            g_encum_start_index := l_cc_index;
            g_encum_end_index   := l_cc_index;
         ELSIF g_encum_end_index - g_encum_start_index = 0 THEN  --bug:7393480:modified
            g_encum_end_index := l_cc_index;
         END IF;
      END IF;
       /*bug:7393480:end*/
      END IF;

     /*bug:7393480:modified the below condition. This is to make sure that Get_Balances api
       is called for the last record of a given ccid in g_ccid_tbl*/

    IF (((l_cc_index < g_ccid_tbl.LAST) AND (g_old_ccid <> g_ccid_tbl(l_ind_process))) OR
       (l_cc_index = g_ccid_tbl.LAST))  THEN

  /*Bug:5929875:end */

      -- for bug 4256345

   /*bug:5929875:Modified the cursor c_ccids to fetch start_date and end_dates of ccids. */

        open c_ccids(c_AccSet_Rec.account_position_set_id);

      loop

        -- for bug 4256345

        fetch c_ccids BULK COLLECT INTO l_ccids.ccid, l_ccids.start_date,
                                        l_ccids.end_date;


	for l_ccid_index in 1..l_ccids.ccid.count loop

	  -- Check whether CCID belongs to Personnel or Non Personnel Services.
	  PSB_WS_ACCT1.Check_CCID_Type
	  ( p_api_version     => 1.0,
	    p_return_status   => l_return_status,
	    p_ccid_type       => l_ccid_type,
	    p_flex_code       => p_flex_code,
	    p_ccid            => l_ccids.ccid(l_ccid_index),
	    p_budget_group_id => c_BudGrp_Rec.budget_group_id
          ) ;

          --
	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  g_actuals_func_total := 0;
	  g_actuals_stat_total := 0;

	  GL_CODE_COMBINATIONS_PKG.Select_Columns
	  ( X_code_combination_id => l_ccids.ccid(l_ccid_index) ,
	    X_account_type        => l_account_type             ,
	    X_template_id         => l_template_id              ) ;


          /* start bug 4256345 */

             l_ccid_start_period := greatest(NVL(l_ccids.start_date(l_ccid_index),
				          	c_AccSet_Rec.effective_start_date),
                                            c_AccSet_Rec.effective_start_date);
          /* end bug 4256345 */

          /* Bug No 2640277 Start */
          -- l_ccid_end_period := least(nvl(l_ccids.end_date(l_ccid_index),
          --                            c_AccSet_Rec.effective_end_date),
          --                            c_AccSet_Rec.effective_end_date);

          /* start bug 4256345 */

          l_ccid_end_period := least(nvl(l_ccids.end_date(l_ccid_index),
		  		     c_AccSet_Rec.effective_end_date),
				     nvl(c_AccSet_Rec.effective_end_date,
                                     l_ccids.end_date(l_ccid_index)));
	   /* end bug 4256345 */

	  /*Bug:5929875:start*/
          g_ccid_type_tbl(l_ccids.ccid(l_ccid_index)) := l_ccid_type;
	  g_ccid_start_period_tbl(l_ccids.ccid(l_ccid_index)) := l_ccid_start_period;
          g_ccid_end_period_tbl(l_ccids.ccid(l_ccid_index)) := l_ccid_end_period;
	  /*Bug:5929875:end*/

          /* Bug No 2640277 End */

            -- Check if CCID is valid for the year being processed.
	    if (((l_ccid_start_period <= l_year_end_date) and (l_ccid_end_period is null))
	     or ((l_ccid_start_period between l_year_start_date and l_year_end_date)
	      or (l_ccid_end_period between l_year_start_date and l_year_end_date)
	      or ((l_ccid_start_period < l_year_start_date)
	      and (l_ccid_end_period > l_year_end_date))))
            then

              -- Process PY and CY balances.
              if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type
                 IN ('PY', 'CY')
              then

                for l_init_index in 1..g_gl_actual_periods.Count loop
		  g_gl_actual_periods(l_init_index).budget_period_id := null;
		  g_gl_actual_periods(l_init_index).long_sequence_no := null;
		  g_gl_actual_periods(l_init_index).start_date := null;
		  g_gl_actual_periods(l_init_index).end_date := null;
		  g_gl_actual_periods(l_init_index).budget_year_id := null;
                end loop;

                for l_init_index in 1..g_gl_budget_periods.Count loop
		  g_gl_budget_periods(l_init_index).budget_period_id := null;
		  g_gl_budget_periods(l_init_index).long_sequence_no := null;
		  g_gl_budget_periods(l_init_index).start_date := null;
		  g_gl_budget_periods(l_init_index).end_date := null;
		  g_gl_budget_periods(l_init_index).budget_year_id := null;
                end loop;

		l_init_index := 1;

		g_num_actual_periods := 0;
		g_num_budget_periods := 0;

                -- Process budget periods for the year being processed.
		for l_period_index in 1..PSB_WS_ACCT1.g_num_budget_periods loop

		  -- Extract Budget Balances for Budget Periods in CY

		  if (PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id =
		    PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id)
                  then

		    g_gl_budget_periods(l_init_index).budget_period_id :=
						      PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_id;
		    g_gl_budget_periods(l_init_index).long_sequence_no :=
						      PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no;
		    g_gl_budget_periods(l_init_index).start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
		    g_gl_budget_periods(l_init_index).end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
		    g_gl_budget_periods(l_init_index).budget_year_id := PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id;

		    g_num_budget_periods := g_num_budget_periods + 1;

		    -- Extract Actuals for Budget Periods in CY up to GL
                    -- Cutoff Date

		    if ((p_gl_cutoff_period is null) or
			(p_gl_cutoff_period > PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date))
                    then
		      g_gl_actual_periods(l_init_index).budget_period_id :=
							PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_id;
		      g_gl_actual_periods(l_init_index).long_sequence_no :=
							PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no;
		      g_gl_actual_periods(l_init_index).start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
		      g_gl_actual_periods(l_init_index).end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
		      g_gl_actual_periods(l_init_index).budget_year_id := PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id;

		      g_num_actual_periods := g_num_actual_periods + 1;

		    end if;

		    l_init_index := l_init_index + 1;

		  end if;

		end loop;
                -- End processing budget periods for the year being processed.

		-- Get GL Balances for CCID
		Get_Balances
		( p_return_status => l_return_status,
		  p_ccid => l_ccids.ccid(l_ccid_index),
		  p_account_type => l_account_type,
		  p_budget_year_id =>
                      PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
		  p_year_name =>
                           PSB_WS_ACCT1.g_budget_years(l_year_index).year_name,
		  p_year_start_date =>
                          PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
		  p_year_end_date =>
                            PSB_WS_ACCT1.g_budget_years(l_year_index).end_date,
		  p_budget_year_type =>
                           PSB_WS_ACCT1.g_budget_years(l_year_index).year_type,
		  p_incl_stat_bal => p_incl_stat_bal,
		  p_incl_trans_bal => p_incl_trans_bal,
		  p_incl_adj_period => p_incl_adj_period,
		  p_set_of_books_id => p_set_of_books_id,
		  p_budget_group_id => c_BudGrp_Rec.budget_group_id,
		  p_stage_set_id => p_stage_set_id,
		  p_func_currency => p_func_currency,
		  p_budgetary_control => p_budgetary_control,
		  p_budget_version_id => p_budget_version_id,
		  p_flex_mapping_set_id => p_flex_mapping_set_id,
		  p_gl_budget_set_id => p_gl_budget_set_id,
		  p_flex_code => p_flex_code,
		  p_worksheet_id => p_worksheet_id,
		  p_service_package_id => p_service_package_id,
		  p_sequence_number => p_start_stage_seq,
		  p_rounding_factor => p_rounding_factor,
                  /* bug no 4725091 */
                  p_incl_gl_fwd_balance => p_incl_gl_fwd_balance,
                  p_create_wks_flag     => fnd_api.g_true
                ) ;
                --
                if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
	        end if;

         /*bug:5929875:start*/
 	       IF g_actuals_func_total <> 0 THEN
	         g_actuals_total_tbl(l_ccids.ccid(l_ccid_index)).act_func_total := g_actuals_func_total;
               END IF;

	       IF g_actuals_stat_total <> 0 THEN
                 g_actuals_total_tbl(l_ccids.ccid(l_ccid_index)).act_stat_total := g_actuals_stat_total;
	       END IF;
        /*bug:5929875:end*/

	      end if;
              -- End processing PY and CY balances.

	    end if;
            -- Check if CCID is valid for the year being processed.

	  end loop;

    /*bug:5929875:start*/
	  l_num_accounts := l_num_accounts + 1;
	  if l_num_accounts > PSB_WS_ACCT1.g_checkpoint_save then
	    commit work;
	    l_num_accounts := 0;
	  end if;

          exit when c_ccids%NOTFOUND;

	end loop; -- loop c_ccids
        close c_ccids;


     /*bug:7393480:start*/
      if g_old_ccid <> g_ccid_tbl(l_ind_process) then
        g_bud_start_index := 0;
        g_bud_end_index   := 0;

        g_act_start_index := 0;
        g_act_end_index   := 0;

        g_encum_start_index := 0;
        g_encum_end_index   := 0;
      end if;

     g_old_ccid := g_ccid_tbl(l_ind_process);

     /*bug:7393480:end*/

   end if; -- if g_old_ccid <> g_ccid_tbl(l_cc_index)
 end loop; -- for l_cc_index IN 1..g_ccid_tbl.count loop

 end loop; -- for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

 /*bug:5929875:end*/

    IF p_parameter_set_id IS NOT NULL THEN

	    -- Number of Years to project a CCID is max of number of years
            -- specified for Budget Group to which CCID is assigned (through
            -- Account Set) and number of years specified in WS definition
	    l_num_projected_years :=
                   greatest( nvl(c_BudGrp_Rec.num_proposed_years, 0),
                             nvl(p_num_proposed_years, 0) );

	    if l_num_projected_years = 0 then
	      l_num_projected_years := null;
	    end if;

	    -- Compute CY and PP Balances for CCID by applying Parameters
      /*bug:5929875:start*/
      IF g_ccid_type_tbl.COUNT <> 0 THEN
        for l_ccid_index in g_ccid_type_tbl.FIRST..g_ccid_type_tbl.LAST loop

  	 IF g_ccid_type_tbl.EXISTS(l_ccid_index) THEN
      /*bug:5929875:end*/
            IF ( g_ccid_type_tbl(l_ccid_index) <> 'PERSONNEL_SERVICES'
                 AND
                 fnd_api.to_boolean(p_budget_by_position)
               )
               OR
               NOT fnd_api.to_boolean(p_budget_by_position)
            THEN

          /*bug:5929875:start*/
	      g_actuals_func_total := 0;
              g_actuals_stat_total := 0;

	      IF g_actuals_total_tbl.EXISTS(l_ccid_index) THEN
	        g_actuals_func_total := g_actuals_total_tbl(l_ccid_index).act_func_total;
              END IF;
	      IF g_actuals_total_tbl.EXISTS(l_ccid_index) THEN
                g_actuals_stat_total := g_actuals_total_tbl(l_ccid_index).act_stat_total;
	      END IF;
          /*bug:5929875:end*/

	      Apply_Account_Parameters
	      ( p_api_version           => 1.0,
                p_return_status         => l_return_status,
                p_worksheet_id          => p_worksheet_id,
                p_service_package_id    => p_service_package_id,
                p_start_stage_seq       => p_start_stage_seq,
                p_current_stage_seq     => p_start_stage_seq,
                p_rounding_factor       => p_rounding_factor,
                p_stage_set_id          => p_stage_set_id,
                p_budget_group_id       => c_BudGrp_Rec.budget_group_id,
                p_allocrule_set_id      => p_allocrule_set_id,
                p_gl_cutoff_period      => p_gl_cutoff_period,
                p_flex_code             => p_flex_code,
                p_func_currency         => p_func_currency,
                p_flex_mapping_set_id   => p_flex_mapping_set_id,
                p_ccid                  => l_ccid_index,                          --bug:5929875
                p_ccid_start_period     => g_ccid_start_period_tbl(l_ccid_index), --bug:5929875
                p_ccid_end_period       => g_ccid_end_period_tbl(l_ccid_index),   --bug:5929875
                p_num_proposed_years    => l_num_projected_years,
                p_num_years_to_allocate => p_num_years_to_allocate,
                p_parameter_set_id      => p_parameter_set_id,
                p_budget_calendar_id    => p_budget_calendar_id,
                p_budget_by_position    => p_budget_by_position
              ) ;
              --
	      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
	      END IF ;
              --
	    END IF ;
      /*bug:5929875:start*/
         END IF;
        END LOOP;
      END IF;
      /*bug:5929875:end*/

	  END IF ;
	  -- End computing CY and PP Balances for CCID by applying Parameters

    end loop; /* Account Set */

    commit work;

  end loop; /* Budget Group */

  -- Process CCIDs that were deferred for processing during the initial phase

  if g_num_defccids <> 0 then

    Process_Deferred_CCIDs
    ( p_return_status         => l_return_status,
      p_worksheet_id          => p_worksheet_id,
      p_service_package_id    => p_service_package_id,
      p_sequence_number       => p_start_stage_seq,
      p_gl_cutoff_period      => p_gl_cutoff_period,
      p_allocrule_set_id      => p_allocrule_set_id,
      p_rounding_factor       => p_rounding_factor,
      p_stage_set_id          => p_stage_set_id,
      p_flex_mapping_set_id   => p_flex_mapping_set_id,
      p_flex_code             => p_flex_code,
      p_func_currency         => p_func_currency,
      p_num_years_to_allocate => p_num_years_to_allocate,
      p_parameter_set_id      => p_parameter_set_id,
      p_budget_calendar_id    => p_budget_calendar_id,
      p_budget_by_position    => p_budget_by_position
    ) ;

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Create_Worksheet_Accounts');
     end if;

END Create_Worksheet_Accounts;
/* ----------------------------------------------------------------------- */


/*===========================================================================+
 |                  PROCEDURE Distribute_Prorated_Amount_Pvt                 |
 +===========================================================================*/
--
-- This API distributes a given amount over a set of periods using a prorated
-- basis. The prorated basis is dervied based on existing amounts in periods.
--
/*Bug:7148726:Added parameters p_estimate_amount and p_rounding_factor */

PROCEDURE Distribute_Prorated_Amount_Pvt
(
  x_return_status            OUT    NOCOPY  VARCHAR2,
  --
  p_spread_amount            IN             NUMBER,
  p_estimate_amount          IN             NUMBER,
  p_rounding_factor          IN             NUMBER,
  x_period_amount            IN OUT NOCOPY  PSB_WS_Acct1.g_prdamt_tbl_type
)
IS
  --
  l_api_name       CONSTANT  VARCHAR2(30) := 'Distribute_Prorated_Amount_Pvt';
  l_return_status            VARCHAR2(1);
  --
  l_start_index              NUMBER;
  l_end_index                NUMBER;
  l_non_zero_periods_count   NUMBER;
  l_non_zero_periods_total   NUMBER;
  l_spread_amount            NUMBER;
  l_total_est_amount         NUMBER:= 0; --bug:7148726
  --
BEGIN
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  -- Initialize variables.
  l_spread_amount          := p_spread_amount ;
  l_non_zero_periods_count := 0 ;
  l_non_zero_periods_total := 0 ;

  -- Return if there are no periods to process.
  IF g_alloc_periods.COUNT <= 0 THEN
    RETURN ;
  END IF ;

  -- Get indexes related to start and end periods.
  l_start_index := g_alloc_periods.FIRST;
  l_end_index   := g_alloc_periods.LAST ;

  -- Find number of periods having null or zero amounts.
  FOR i IN l_start_index..l_end_index
  LOOP
    --pd('Before :' || i || ':' || x_period_amount(i) ) ;
    IF NVL(x_period_amount(i),0) <> 0 THEN
      l_non_zero_periods_count := l_non_zero_periods_count + 1 ;
      l_non_zero_periods_total := l_non_zero_periods_total +
                                  NVL(x_period_amount(i),0) ;
    END IF ;
  END LOOP ;

  --pd('l_non_zero_periods_count:'||l_non_zero_periods_count) ;
  --pd('l_non_zero_periods_total:'||l_non_zero_periods_total) ;

  --
  -- We need to consider negative spread and period amounts. The following
  -- table illustrates such combinations.
  --
  -- Net Period Amt   Spread   Make Spread
  -- +ve              +ve      no change
  -- +ve              -ve      no change
  -- -ve              +ve      spread * -1
  -- -ve              -ve      spread * -1
  --
  IF l_non_zero_periods_total < 0 THEN
    l_spread_amount := l_spread_amount * -1 ;
  END IF ;

  -- Get absolute divide by factor.
  l_non_zero_periods_total := ABS(l_non_zero_periods_total) ;

  --
  -- If l_non_zero_periods_total is 0, this means we cannot use existing period
  -- amounts for proration as the end result will always be 0. For this case we
  -- will do uniform distribution by resetting l_non_zero_periods_count to 0.
  --
  IF l_non_zero_periods_total = 0 THEN
    l_non_zero_periods_count := 0 ;
  END IF ;

  -- Check different spreading conditions.
  IF l_spread_amount = 0 THEN

    -- Check if there is any need to reset period amounts.
    IF l_non_zero_periods_total <> 0 THEN
      FOR i IN l_start_index..l_end_index
      LOOP
        x_period_amount(i) := 0 ;
      END LOOP ;
    END IF ;

  -- If all the periods are 0s, do the uniform distribution.
  ELSIF l_non_zero_periods_count = 0 THEN

    FOR i IN l_start_index..l_end_index
    LOOP
      x_period_amount(i) := l_spread_amount/g_alloc_periods.COUNT ;
    END LOOP ;

  -- Othewise do prorate distribution based on existing amounts.
  ELSE

   FOR i IN l_start_index..l_end_index
   LOOP
      x_period_amount(i) := ( x_period_amount(i) / l_non_zero_periods_total ) *
                            l_spread_amount ;
    END LOOP ;

  END IF ;
  -- End checking different spreading conditions.

  /*bug:7148726:start*/
  FOR i in 1..x_period_amount.COUNT LOOP
   IF p_rounding_factor is null then
       l_total_est_amount := l_total_est_amount + nvl(x_period_amount(i),0);
   ELSE
       l_total_est_amount := l_total_est_amount + nvl(ROUND(x_period_amount(i)/p_rounding_factor)*p_rounding_factor,0);
   END IF;
  END LOOP;

  IF nvl(p_estimate_amount,0) <> nvl(l_total_est_amount,0) THEN
      x_period_amount(l_end_index) := nvl(ROUND(x_period_amount(l_end_index)/p_rounding_factor)*p_rounding_factor,0) + (nvl(p_estimate_amount,0) - nvl(l_total_est_amount,0));
  END IF;
  /*bug:7148726:end*/

EXCEPTION
  WHEN OTHERS THEN
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
                                 l_api_name ) ;
    END IF;
    --
END Distribute_Prorated_Amount_Pvt ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Update_CY_Estimates                         |
 +===========================================================================*/
--
-- This API updates CY estimates amounts. It copies actuals from CY Actual
-- balances upto GL cutoff date and then spreads 'CY Estimates - CY Actuals'
-- over post GL cutoff periods.
--
PROCEDURE Update_CY_Estimates
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN           NUMBER,
  p_service_package_id  IN           NUMBER,
  p_rounding_factor     IN           NUMBER,
  p_start_stage_seq     IN           NUMBER,
  p_budget_group_id     IN           NUMBER,
  p_stage_set_id        IN           NUMBER,
  p_budget_year_id      IN           NUMBER,
  p_ccid                IN           NUMBER,
  p_currency_code       IN           VARCHAR2
)
IS
  --
  l_return_status       VARCHAR2(1);
  l_start_index         PLS_INTEGER;
  l_end_index           PLS_INTEGER;
  l_account_line_id     NUMBER;
  l_period_amount       PSB_WS_Acct1.g_prdamt_tbl_type;
  -- Bug 3548345
  -- l_create_zero_bal     VARCHAR2(1);
  --
  l_ytd_actual_amount   NUMBER := 0;
  l_ytd_estimate_amount NUMBER := 0;
  l_ytd_spread_amount   NUMBER := 0;
  --
  /*Bug:5876100:start*/
  l_est_exists          VARCHAR2(1) := 'N';
  l_actuals_exists      VARCHAR2(1) := 'N';
   /*Bug:5876100:end*/

  --
  -- There are 2 separate cursors c_WAL_Act (for Actuals) and c_WAL_Est
  -- (for Estimates) to avoid static binding of cursors.
  --
  CURSOR c_WAL_Act IS
    SELECT ytd_amount,
           period1_amount,  period2_amount,  period3_amount,  period4_amount,
           period5_amount,  period6_amount,  period7_amount,  period8_amount,
           period9_amount,  period10_amount, period11_amount, period12_amount,
           period13_amount, period14_amount, period15_amount, period16_amount,
           period17_amount, period18_amount, period19_amount, period20_amount,
           period21_amount, period22_amount, period23_amount, period24_amount,
           period25_amount, period26_amount, period27_amount, period28_amount,
           period29_amount, period30_amount, period31_amount, period32_amount,
           period33_amount, period34_amount, period35_amount, period36_amount,
           period37_amount, period38_amount, period39_amount, period40_amount,
           period41_amount, period42_amount, period43_amount, period44_amount,
           period45_amount, period46_amount, period47_amount, period48_amount,
           period49_amount, period50_amount, period51_amount, period52_amount,
           period53_amount, period54_amount, period55_amount, period56_amount,
           period57_amount, period58_amount, period59_amount, period60_amount
      FROM PSB_WS_ACCOUNT_LINES a
     WHERE template_id IS NULL
       AND position_line_id IS NULL
       AND currency_code = p_currency_code
       AND p_start_stage_seq BETWEEN start_stage_seq AND current_stage_seq
       AND balance_type = 'A'
       AND EXISTS
          (SELECT 1
             FROM PSB_WS_LINES b
            WHERE b.account_line_id = a.account_line_id
              AND b.worksheet_id = p_worksheet_id)
       AND stage_set_id        = p_stage_set_id
       AND service_package_id  = p_service_package_id
       AND budget_year_id      = p_budget_year_id
       AND budget_group_id     = p_budget_group_id
       AND code_combination_id = p_ccid;
  --
  CURSOR c_WAL_Est IS
    SELECT code_combination_id,ytd_amount,
           period1_amount, period2_amount, period3_amount, period4_amount,
           period5_amount, period6_amount, period7_amount, period8_amount,
           period9_amount, period10_amount, period11_amount, period12_amount,
           period13_amount, period14_amount, period15_amount, period16_amount,
           period17_amount, period18_amount, period19_amount, period20_amount,
           period21_amount, period22_amount, period23_amount, period24_amount,
           period25_amount, period26_amount, period27_amount, period28_amount,
           period29_amount, period30_amount, period31_amount, period32_amount,
           period33_amount, period34_amount, period35_amount, period36_amount,
           period37_amount, period38_amount, period39_amount, period40_amount,
           period41_amount, period42_amount, period43_amount, period44_amount,
           period45_amount, period46_amount, period47_amount, period48_amount,
           period49_amount, period50_amount, period51_amount, period52_amount,
           period53_amount, period54_amount, period55_amount, period56_amount,
           period57_amount, period58_amount, period59_amount, period60_amount
      FROM PSB_WS_ACCOUNT_LINES a
     WHERE template_id IS NULL
       AND position_line_id IS NULL
       AND currency_code = p_currency_code
       AND p_start_stage_seq BETWEEN start_stage_seq AND current_stage_seq
       AND balance_type = 'E'
       AND EXISTS
          (SELECT 1
             FROM PSB_WS_LINES b
            WHERE b.account_line_id = a.account_line_id
              AND b.worksheet_id = p_worksheet_id)
       AND stage_set_id        = p_stage_set_id
       AND service_package_id  = p_service_package_id
       AND budget_year_id      = p_budget_year_id
       AND budget_group_id     = p_budget_group_id
       AND code_combination_id = p_ccid;
  --
BEGIN

  /*bug:5876100:start*/
  g_ugb_create_est_bal := 'N';
  /*bug:5876100:end*/

  -- Initialize period table for the current account line.
  FOR i IN 1..PSB_WS_ACCT1.g_max_num_amounts LOOP
    l_period_amount(i) := NULL ;
  END LOOP ;

  --
  -- Copy CY estimate periods from CY actuals till GL cutoff date. Note these
  -- have been populated by Get_Balances API in main Update_GL_Balances API.
  --
  FOR c_WAL_Rec in c_WAL_Act LOOP

  /*bug:5876100:start*/
    l_actuals_exists := 'Y';
  /*bug:5876100:end*/

    l_ytd_actual_amount := NVL(c_WAL_Rec.ytd_amount,0);

    if c_WAL_Rec.period1_amount is not null then
      l_period_amount(1) := c_WAL_Rec.period1_amount;
    end if;

    if c_WAL_Rec.period2_amount is not null then
      l_period_amount(2) := c_WAL_Rec.period2_amount;
    end if;

    if c_WAL_Rec.period3_amount is not null then
      l_period_amount(3) := c_WAL_Rec.period3_amount;
    end if;

    if c_WAL_Rec.period4_amount is not null then
      l_period_amount(4) := c_WAL_Rec.period4_amount;
    end if;

    if c_WAL_Rec.period5_amount is not null then
      l_period_amount(5) := c_WAL_Rec.period5_amount;
    end if;

    if c_WAL_Rec.period6_amount is not null then
      l_period_amount(6) := c_WAL_Rec.period6_amount;
    end if;

    if c_WAL_Rec.period7_amount is not null then
      l_period_amount(7) := c_WAL_Rec.period7_amount;
    end if;

    if c_WAL_Rec.period8_amount is not null then
      l_period_amount(8) := c_WAL_Rec.period8_amount;
    end if;

    if c_WAL_Rec.period9_amount is not null then
      l_period_amount(9) := c_WAL_Rec.period9_amount;
    end if;

    if c_WAL_Rec.period10_amount is not null then
      l_period_amount(10) := c_WAL_Rec.period10_amount;
    end if;

    if c_WAL_Rec.period11_amount is not null then
      l_period_amount(11) := c_WAL_Rec.period11_amount;
    end if;

    if c_WAL_Rec.period12_amount is not null then
      l_period_amount(12) := c_WAL_Rec.period12_amount;
    end if;

    if c_WAL_Rec.period13_amount is not null then
      l_period_amount(13) := c_WAL_Rec.period13_amount;
    end if;

    if c_WAL_Rec.period14_amount is not null then
      l_period_amount(14) := c_WAL_Rec.period14_amount;
    end if;

    if c_WAL_Rec.period15_amount is not null then
      l_period_amount(15) := c_WAL_Rec.period15_amount;
    end if;

    if c_WAL_Rec.period16_amount is not null then
      l_period_amount(16) := c_WAL_Rec.period16_amount;
    end if;

    if c_WAL_Rec.period17_amount is not null then
      l_period_amount(17) := c_WAL_Rec.period17_amount;
    end if;

    if c_WAL_Rec.period18_amount is not null then
      l_period_amount(18) := c_WAL_Rec.period18_amount;
    end if;

    if c_WAL_Rec.period19_amount is not null then
      l_period_amount(19) := c_WAL_Rec.period19_amount;
    end if;

    if c_WAL_Rec.period20_amount is not null then
      l_period_amount(20) := c_WAL_Rec.period20_amount;
    end if;

    if c_WAL_Rec.period21_amount is not null then
      l_period_amount(21) := c_WAL_Rec.period21_amount;
    end if;

    if c_WAL_Rec.period22_amount is not null then
      l_period_amount(22) := c_WAL_Rec.period22_amount;
    end if;

    if c_WAL_Rec.period23_amount is not null then
      l_period_amount(23) := c_WAL_Rec.period23_amount;
    end if;

    if c_WAL_Rec.period24_amount is not null then
      l_period_amount(24) := c_WAL_Rec.period24_amount;
    end if;

    if c_WAL_Rec.period25_amount is not null then
      l_period_amount(25) := c_WAL_Rec.period25_amount;
    end if;

    if c_WAL_Rec.period26_amount is not null then
      l_period_amount(26) := c_WAL_Rec.period26_amount;
    end if;

    if c_WAL_Rec.period27_amount is not null then
      l_period_amount(27) := c_WAL_Rec.period27_amount;
    end if;

    if c_WAL_Rec.period28_amount is not null then
      l_period_amount(28) := c_WAL_Rec.period28_amount;
    end if;

    if c_WAL_Rec.period29_amount is not null then
      l_period_amount(29) := c_WAL_Rec.period29_amount;
    end if;

    if c_WAL_Rec.period30_amount is not null then
      l_period_amount(30) := c_WAL_Rec.period30_amount;
    end if;

    if c_WAL_Rec.period31_amount is not null then
      l_period_amount(31) := c_WAL_Rec.period31_amount;
    end if;

    if c_WAL_Rec.period32_amount is not null then
      l_period_amount(32) := c_WAL_Rec.period32_amount;
    end if;

    if c_WAL_Rec.period33_amount is not null then
      l_period_amount(33) := c_WAL_Rec.period33_amount;
    end if;

    if c_WAL_Rec.period34_amount is not null then
      l_period_amount(34) := c_WAL_Rec.period34_amount;
    end if;

    if c_WAL_Rec.period35_amount is not null then
      l_period_amount(35) := c_WAL_Rec.period35_amount;
    end if;

    if c_WAL_Rec.period36_amount is not null then
      l_period_amount(36) := c_WAL_Rec.period36_amount;
    end if;

    if c_WAL_Rec.period37_amount is not null then
      l_period_amount(37) := c_WAL_Rec.period37_amount;
    end if;

    if c_WAL_Rec.period38_amount is not null then
      l_period_amount(38) := c_WAL_Rec.period38_amount;
    end if;

    if c_WAL_Rec.period39_amount is not null then
      l_period_amount(39) := c_WAL_Rec.period39_amount;
    end if;

    if c_WAL_Rec.period40_amount is not null then
      l_period_amount(40) := c_WAL_Rec.period40_amount;
    end if;

    if c_WAL_Rec.period41_amount is not null then
      l_period_amount(41) := c_WAL_Rec.period41_amount;
    end if;

    if c_WAL_Rec.period42_amount is not null then
      l_period_amount(42) := c_WAL_Rec.period42_amount;
    end if;

    if c_WAL_Rec.period43_amount is not null then
      l_period_amount(43) := c_WAL_Rec.period43_amount;
    end if;

    if c_WAL_Rec.period44_amount is not null then
      l_period_amount(44) := c_WAL_Rec.period44_amount;
    end if;

    if c_WAL_Rec.period45_amount is not null then
      l_period_amount(45) := c_WAL_Rec.period45_amount;
    end if;

    if c_WAL_Rec.period46_amount is not null then
      l_period_amount(46) := c_WAL_Rec.period46_amount;
    end if;

    if c_WAL_Rec.period47_amount is not null then
      l_period_amount(47) := c_WAL_Rec.period47_amount;
    end if;

    if c_WAL_Rec.period48_amount is not null then
      l_period_amount(48) := c_WAL_Rec.period48_amount;
    end if;

    if c_WAL_Rec.period49_amount is not null then
      l_period_amount(49) := c_WAL_Rec.period49_amount;
    end if;

    if c_WAL_Rec.period50_amount is not null then
      l_period_amount(50) := c_WAL_Rec.period50_amount;
    end if;

    if c_WAL_Rec.period51_amount is not null then
      l_period_amount(51) := c_WAL_Rec.period51_amount;
    end if;

    if c_WAL_Rec.period52_amount is not null then
      l_period_amount(52) := c_WAL_Rec.period52_amount;
    end if;

    if c_WAL_Rec.period53_amount is not null then
      l_period_amount(53) := c_WAL_Rec.period53_amount;
    end if;

    if c_WAL_Rec.period54_amount is not null then
      l_period_amount(54) := c_WAL_Rec.period54_amount;
    end if;

    if c_WAL_Rec.period55_amount is not null then
      l_period_amount(55) := c_WAL_Rec.period55_amount;
    end if;

    if c_WAL_Rec.period56_amount is not null then
      l_period_amount(56) := c_WAL_Rec.period56_amount;
    end if;

    if c_WAL_Rec.period57_amount is not null then
      l_period_amount(57) := c_WAL_Rec.period57_amount;
    end if;

    if c_WAL_Rec.period58_amount is not null then
      l_period_amount(58) := c_WAL_Rec.period58_amount;
    end if;

    if c_WAL_Rec.period59_amount is not null then
      l_period_amount(59) := c_WAL_Rec.period59_amount;
    end if;

    if c_WAL_Rec.period60_amount is not null then
      l_period_amount(60) := c_WAL_Rec.period60_amount;
    end if;

    EXIT;

  END LOOP ;

  -- Get indexes related to start and end periods.
  l_start_index := g_alloc_periods.FIRST;
  l_end_index   := g_alloc_periods.LAST;

  --
  -- Now copy existing CY estimate periods beyond the GL cutoff date from
  -- the existing account line.
  --

  -- Bug#3514350: Check if CY estimates need to be processed.
  IF NOT g_process_cy_estimates THEN

    l_ytd_estimate_amount := l_ytd_actual_amount ;

  ELSE

    FOR c_WAL_Rec IN c_WAL_Est LOOP

  /*bug:5876100:start*/
    l_est_exists := 'Y';
  /*bug:5876100:end*/

    l_ytd_estimate_amount := NVL(c_WAL_Rec.ytd_amount,0) ;

    if 1 between l_start_index and l_end_index then
      l_period_amount(1) := c_WAL_Rec.period1_amount;
    end if;

    if 2 between l_start_index and l_end_index then
      l_period_amount(2) := c_WAL_Rec.period2_amount;
    end if;

    if 3 between l_start_index and l_end_index then
      l_period_amount(3) := c_WAL_Rec.period3_amount;
    end if;

    if 4 between l_start_index and l_end_index then
      l_period_amount(4) := c_WAL_Rec.period4_amount;
    end if;

    if 5 between l_start_index and l_end_index then
      l_period_amount(5) := c_WAL_Rec.period5_amount;
    end if;

    if 6 between l_start_index and l_end_index then
      l_period_amount(6) := c_WAL_Rec.period6_amount;
    end if;

    if 7 between l_start_index and l_end_index then
      l_period_amount(7) := c_WAL_Rec.period7_amount;
    end if;

    if 8 between l_start_index and l_end_index then
      l_period_amount(8) := c_WAL_Rec.period8_amount;
    end if;

    if 9 between l_start_index and l_end_index then
      l_period_amount(9) := c_WAL_Rec.period9_amount;
    end if;

    if 10 between l_start_index and l_end_index then
      l_period_amount(10) := c_WAL_Rec.period10_amount;
    end if;

    if 11 between l_start_index and l_end_index then
      l_period_amount(11) := c_WAL_Rec.period11_amount;
    end if;

    if 12 between l_start_index and l_end_index then
      l_period_amount(12) := c_WAL_Rec.period12_amount;
    end if;

    if 13 between l_start_index and l_end_index then
      l_period_amount(13) := c_WAL_Rec.period13_amount;
    end if;

    if 14 between l_start_index and l_end_index then
      l_period_amount(14) := c_WAL_Rec.period14_amount;
    end if;

    if 15 between l_start_index and l_end_index then
      l_period_amount(15) := c_WAL_Rec.period15_amount;
    end if;

    if 16 between l_start_index and l_end_index then
      l_period_amount(16) := c_WAL_Rec.period16_amount;
    end if;

    if 17 between l_start_index and l_end_index then
      l_period_amount(17) := c_WAL_Rec.period17_amount;
    end if;

    if 18 between l_start_index and l_end_index then
      l_period_amount(18) := c_WAL_Rec.period18_amount;
    end if;

    if 19 between l_start_index and l_end_index then
      l_period_amount(19) := c_WAL_Rec.period19_amount;
    end if;

    if 20 between l_start_index and l_end_index then
      l_period_amount(20) := c_WAL_Rec.period20_amount;
    end if;

    if 21 between l_start_index and l_end_index then
      l_period_amount(21) := c_WAL_Rec.period21_amount;
    end if;

    if 22 between l_start_index and l_end_index then
      l_period_amount(22) := c_WAL_Rec.period22_amount;
    end if;

    if 23 between l_start_index and l_end_index then
      l_period_amount(23) := c_WAL_Rec.period23_amount;
    end if;

    if 24 between l_start_index and l_end_index then
      l_period_amount(24) := c_WAL_Rec.period24_amount;
    end if;

    if 25 between l_start_index and l_end_index then
      l_period_amount(25) := c_WAL_Rec.period25_amount;
    end if;

    if 26 between l_start_index and l_end_index then
      l_period_amount(26) := c_WAL_Rec.period26_amount;
    end if;

    if 27 between l_start_index and l_end_index then
      l_period_amount(27) := c_WAL_Rec.period27_amount;
    end if;

    if 28 between l_start_index and l_end_index then
      l_period_amount(28) := c_WAL_Rec.period28_amount;
    end if;

    if 29 between l_start_index and l_end_index then
      l_period_amount(29) := c_WAL_Rec.period29_amount;
    end if;

    if 30 between l_start_index and l_end_index then
      l_period_amount(30) := c_WAL_Rec.period30_amount;
    end if;

    if 31 between l_start_index and l_end_index then
      l_period_amount(31) := c_WAL_Rec.period31_amount;
    end if;

    if 32 between l_start_index and l_end_index then
      l_period_amount(32) := c_WAL_Rec.period32_amount;
    end if;

    if 33 between l_start_index and l_end_index then
      l_period_amount(33) := c_WAL_Rec.period33_amount;
    end if;

    if 34 between l_start_index and l_end_index then
      l_period_amount(34) := c_WAL_Rec.period34_amount;
    end if;

    if 35 between l_start_index and l_end_index then
      l_period_amount(35) := c_WAL_Rec.period35_amount;
    end if;

    if 36 between l_start_index and l_end_index then
      l_period_amount(36) := c_WAL_Rec.period36_amount;
    end if;

    if 37 between l_start_index and l_end_index then
      l_period_amount(37) := c_WAL_Rec.period37_amount;
    end if;

    if 38 between l_start_index and l_end_index then
      l_period_amount(38) := c_WAL_Rec.period38_amount;
    end if;

    if 39 between l_start_index and l_end_index then
      l_period_amount(39) := c_WAL_Rec.period39_amount;
    end if;

    if 40 between l_start_index and l_end_index then
      l_period_amount(40) := c_WAL_Rec.period40_amount;
    end if;

    if 41 between l_start_index and l_end_index then
      l_period_amount(41) := c_WAL_Rec.period41_amount;
    end if;

    if 42 between l_start_index and l_end_index then
      l_period_amount(42) := c_WAL_Rec.period42_amount;
    end if;

    if 43 between l_start_index and l_end_index then
      l_period_amount(43) := c_WAL_Rec.period43_amount;
    end if;

    if 44 between l_start_index and l_end_index then
      l_period_amount(44) := c_WAL_Rec.period44_amount;
    end if;

    if 45 between l_start_index and l_end_index then
      l_period_amount(45) := c_WAL_Rec.period45_amount;
    end if;

    if 46 between l_start_index and l_end_index then
      l_period_amount(46) := c_WAL_Rec.period46_amount;
    end if;

    if 47 between l_start_index and l_end_index then
      l_period_amount(47) := c_WAL_Rec.period47_amount;
    end if;

    if 48 between l_start_index and l_end_index then
      l_period_amount(48) := c_WAL_Rec.period48_amount;
    end if;

    if 49 between l_start_index and l_end_index then
      l_period_amount(49) := c_WAL_Rec.period49_amount;
    end if;

    if 50 between l_start_index and l_end_index then
      l_period_amount(50) := c_WAL_Rec.period50_amount;
    end if;

    if 51 between l_start_index and l_end_index then
      l_period_amount(51) := c_WAL_Rec.period51_amount;
    end if;

    if 52 between l_start_index and l_end_index then
      l_period_amount(52) := c_WAL_Rec.period52_amount;
    end if;

    if 53 between l_start_index and l_end_index then
      l_period_amount(53) := c_WAL_Rec.period53_amount;
    end if;

    if 54 between l_start_index and l_end_index then
      l_period_amount(54) := c_WAL_Rec.period54_amount;
    end if;

    if 55 between l_start_index and l_end_index then
      l_period_amount(55) := c_WAL_Rec.period55_amount;
    end if;

    if 56 between l_start_index and l_end_index then
      l_period_amount(56) := c_WAL_Rec.period56_amount;
    end if;

    if 57 between l_start_index and l_end_index then
      l_period_amount(57) := c_WAL_Rec.period57_amount;
    end if;

    if 58 between l_start_index and l_end_index then
      l_period_amount(58) := c_WAL_Rec.period58_amount;
    end if;

    if 59 between l_start_index and l_end_index then
      l_period_amount(59) := c_WAL_Rec.period59_amount;
    end if;

    if 60 between l_start_index and l_end_index then
      l_period_amount(60) := c_WAL_Rec.period60_amount;
    end if;

    EXIT;

    END LOOP ;

    --l_ytd_actual_amount := NVL(g_actuals_func_total,0) ;
    l_ytd_spread_amount := l_ytd_estimate_amount - l_ytd_actual_amount ;

    -- Now prorate CY estimate amounts beyond post GL cutoff periods using
    -- new spread computed.
    Distribute_Prorated_Amount_Pvt
    (
      x_return_status          => l_return_status     ,
      --
      p_spread_amount          => l_ytd_spread_amount ,
      /*bug:7148726:start*/
      p_estimate_amount        => nvl(l_ytd_estimate_amount,0),
      p_rounding_factor        => p_rounding_factor,
      /*bug:7148726:end*/
      x_period_amount          => l_period_amount
    ) ;
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    --

  END IF ;
  -- End checking if  CY estimates need to be processed.

  -- Commented out the following statements for bug 3305778
  /* Bug 3543845: Reactivate the following statements, use g_create_zero_bal
     and add a new condition to improve performance
  */
  IF g_create_zero_bal is null THEN
    FND_PROFILE.GET
      ( name => 'PSB_CREATE_ZERO_BALANCE_ACCT' ,
        val  => g_create_zero_bal              ) ;

    if g_create_zero_bal is null then
      -- Bug 3543845: Change default behavior to not creating zero balance
      g_create_zero_bal := 'N';
    end if;
  END IF;

  -- Bug 4250468 added the variable g_ws_first_time_creation_flag
  -- in the IF condition
  IF (PSB_WORKSHEET.g_ws_first_time_creation_flag AND
      ( l_ytd_estimate_amount <> 0
        OR
       (l_ytd_estimate_amount = 0 and g_create_zero_bal = 'Y')
       )
      )
   OR NOT PSB_WORKSHEET.g_ws_first_time_creation_flag THEN


    --pd('2: Call Create_Account_Dist=> ccid=' || TO_CHAR(p_ccid) ||
    --   ', p_budget_year_id=' || TO_CHAR(p_budget_year_id) ||
    --   ', p_ytd_amount=' || TO_CHAR(l_ytd_estimate_amount));

  /*Bug:5876100:start */
   IF l_actuals_exists = 'Y' AND l_est_exists = 'N' AND l_ytd_estimate_amount = 0 THEN
     g_ugb_create_est_bal := 'Y';
   END IF;
   /*Bug:5876100:end */

    PSB_WS_Acct1.Create_Account_Dist
    ( p_api_version        => 1.0,
      p_return_status      => l_return_status,
      p_account_line_id    => l_account_line_id,
      p_worksheet_id       => p_worksheet_id,
      p_service_package_id => p_service_package_id,
      /* bug start 3996052 */
      -- changing the check spal line to true
      p_check_spal_exists  => FND_API.G_TRUE,
      /* bug end : 3996052 */
      p_gl_cutoff_period   => null,
      p_allocrule_set_id   => null,
      p_budget_calendar_id => null,
      p_rounding_factor    => p_rounding_factor,
      p_stage_set_id       => p_stage_set_id,
      p_budget_year_id     => p_budget_year_id,
      p_budget_group_id    => p_budget_group_id,
      p_ccid               => p_ccid,
      p_currency_code      => p_currency_code,
      p_balance_type       => 'E',
      p_ytd_amount         => l_ytd_estimate_amount,
      p_period_amount      => l_period_amount,
      p_start_stage_seq    => p_start_stage_seq,
      p_current_stage_seq  => p_start_stage_seq,
      /* bug start 3996052 */
      p_update_cy_estimate => 'Y'
      /* bug end 3996052 */
    ) ;
    --
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end if;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  --
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                'Update_CY_Estimates') ;
    END IF;
    --
END Update_CY_Estimates ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Update_GL_Balances                          |
 +===========================================================================*/
--
-- API updates CY actuals and budget from GL. It also updated CY estimates as
-- per GL cut off date.
--
PROCEDURE Update_GL_Balances
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
)
IS
  --
  l_api_name          CONSTANT VARCHAR2(30)     := 'Update_GL_Balances';
  l_api_version       CONSTANT NUMBER           := 1.0;

  l_ccid_index                 PLS_INTEGER;
  l_year_index                 PLS_INTEGER;
  l_period_index               PLS_INTEGER;
  l_init_index                 PLS_INTEGER;

  -- Bug#3545533: Added
  l_budget_by_position         VARCHAR2(1);
  l_ps_set_id                  NUMBER ;
  l_process_cy_estimates       VARCHAR2(1);

  l_stage_set_id               NUMBER;
  l_current_stage_seq          NUMBER;
  l_budget_version_id          NUMBER;
  l_flex_mapping_set_id        NUMBER;
  l_gl_budget_set_id           NUMBER;
  l_gl_cutoff_period           DATE;
  l_incl_stat_bal              VARCHAR2(1);
  l_incl_trans_bal             VARCHAR2(1);
  l_incl_adj_period            VARCHAR2(1);
  l_rounding_factor            NUMBER;
  l_budget_group_id            NUMBER;
  l_budget_calendar_id         NUMBER;
  l_include_gl_commit_balance  VARCHAR2(1);
  l_include_gl_oblig_balance   VARCHAR2(1);
  l_include_gl_other_balance   VARCHAR2(1);
  l_incl_gl_fwd_balance        VARCHAR2(1) :='N'; --bug:6775471
  l_service_package_id         NUMBER;

  l_flex_code                  NUMBER;
  l_set_of_books_id            NUMBER;
  l_set_of_books_name          VARCHAR2(30);
  l_budgetary_control          VARCHAR2(1);
  l_func_currency              VARCHAR2(15);

  l_account_type               VARCHAR2(1);
  l_template_id                NUMBER;

  l_ccid_start_period          DATE;
  l_ccid_end_period            DATE;
  l_year_start_date            DATE;
  l_year_end_date              DATE;

  l_num_accounts               NUMBER := 0;
  l_return_status              VARCHAR2(1);

  TYPE ccid_arr IS TABLE OF NUMBER(15);
  TYPE date_arr IS TABLE OF DATE;
  TYPE ccid_rec IS RECORD   (  ccid       ccid_arr ,
                               start_date date_arr ,
                               end_date   date_arr ) ;
  --
  l_ccids                      ccid_rec;
  --
  CURSOR c_ccids ( c_account_set_id NUMBER)
  IS
  SELECT b.code_combination_id, b.start_date_active, b.end_date_active
  FROM   gl_code_combinations b,psb_budget_accounts a
  WHERE  b.detail_budgeting_allowed_flag = 'Y'
  AND    b.enabled_flag            = 'Y'
  AND    b.code_combination_id     = a.code_combination_id
  /* Bug 3692601 Start */
  AND    a.account_position_set_id = c_account_set_id
  /* Bug 3692601 End */
  AND    b.code_combination_id = g_old_ccid; --added for bug:5929875

  -- Bug#3545533: Added
  CURSOR l_check_acct_type ( c_code_combination_id  NUMBER)
  IS
  SELECT '1'
  FROM   dual
  WHERE  EXISTS
         ( SELECT 1
           FROM   psb_budget_accounts
           WHERE  code_combination_id     = c_code_combination_id
           AND    account_position_set_id = l_ps_set_id ) ;

/*Bug:5929875:start*/

 l_gl_budget_id          NUMBER;
 l_incl_adj_flag         VARCHAR2(1) := 'N';
 l_commit_enc_type_id    NUMBER;
 l_oblig_enc_type_id     NUMBER;
 l_gl_other_bal_flag     VARCHAR2(1) := 'N';
 l_gl_commit_bal_flag    VARCHAR2(1) := 'N';
 l_gl_oblig_bal_flag     VARCHAR2(1) := 'N';
 l_bud_actual_flag       VARCHAR2(1) := 'B';
 l_act_actual_flag       VARCHAR2(1) := 'A';
 l_encum_actual_flag     VARCHAR2(1) := 'E';
 l_cy_flag               VARCHAR2(1) := 'Y';
 l_cn_flag               VARCHAR2(1) := 'N';

 l_old_bal_flag          VARCHAR2(1) := 'X';
 l_index                 NUMBER      :=  0;
 l_ind_process           NUMBER      := 0;--bug:7393480

 cursor c_fin is
 select purch_encumbrance_type_id, req_encumbrance_type_id
 from financials_system_parameters;

 /*Bug:7393480:Modified cursor - c_bal_csr to make sure that record is returned with
   null details when there is no balance on gl side for a given ccid which
   is part of the account set(s) attached to PSB Budget group hierarchy.*/

 /*Order by code_combination_id,actual_flag is required in both the
   cursors c_bal_csr,c_bal_budcntl_csr as the processing of the
   records depends on this.*/ --Bug:5929875

/*Bug:5929875:Cursor to fetch GL Balances*/
 CURSOR c_bal_csr(p_account_position_set_id NUMBER,
                      p_budget_version_id NUMBER,
                      p_year_start_date DATE,
                      p_year_end_date   DATE,
                      p_map_criteria    VARCHAR2) IS
 select a.code_combination_id, gb.actual_flag,
        gs.start_date, gs.end_date,
        gb.currency_code,
 (nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0)),
  (nvl(gb.BEGIN_BALANCE_DR, 0) - nvl(gb.BEGIN_BALANCE_CR,0))
 from
       GL_BALANCES gb,
       GL_PERIOD_STATUSES gs,
       psb_budget_accounts  a
 where gb.ledger_id = l_set_of_books_id
 and ((gb.translated_flag is null) or (gb.translated_flag = l_cy_flag))
 and gb.period_name = gs.period_name
 and gb.period_type = gs.period_type
 and gb.period_year = gs.period_year
 and gb.period_num = gs.period_num
 and (((l_incl_adj_flag = l_cn_flag) and (gs.adjustment_period_flag = l_cn_flag))
      or (l_incl_adj_flag = l_cy_flag))
 and gs.set_of_books_id = l_set_of_books_id
 and gs.application_id = 101
 and decode(p_map_criteria,'S',gs.start_date,gs.end_date) between
     p_year_start_date and p_year_end_date
 and gb.code_combination_id = a.code_combination_id
 and a.account_position_set_id = p_account_position_set_id
 and  ((gb.actual_flag = l_bud_actual_flag
 and ((l_gl_budget_set_id IS NOT NULL
      AND gb.budget_version_id = p_budget_version_id) OR
      (l_gl_budget_set_id IS NULL))) OR (gb.actual_flag = l_act_actual_flag)
      OR (gb.actual_flag = l_encum_actual_flag
      and ((l_gl_other_bal_flag = l_cy_flag and
((l_gl_commit_bal_flag = l_cn_flag and
((l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id not in (l_oblig_enc_type_id,l_commit_enc_type_id)) OR
 (l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id not in (l_commit_enc_type_id))))  OR
 (l_gl_commit_bal_flag = l_cy_flag and
  (l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id not in (l_oblig_enc_type_id) OR
  (l_gl_oblig_bal_flag = l_cy_flag)))))  OR
 (l_gl_other_bal_flag = l_cn_flag and
  (l_gl_commit_bal_flag = l_cn_flag and l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id in (l_oblig_enc_type_id)) OR
  (l_gl_commit_bal_flag = l_cn_flag and l_gl_oblig_bal_flag = l_cn_flag) OR
  (l_gl_commit_bal_flag = l_cy_flag and
   ((l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id in (l_commit_enc_type_id))  OR
    (l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id in (l_commit_enc_type_id,l_oblig_enc_type_id))))))))
 union
 select a.code_combination_id, null,
        gs.start_date, gs.end_date,
        null,0,0
 from  GL_PERIOD_STATUSES gs,
       psb_budget_accounts  a
where (((l_incl_adj_flag = l_cn_flag) and (gs.adjustment_period_flag = l_cn_flag))
      or (l_incl_adj_flag = l_cy_flag))
 and gs.set_of_books_id = l_set_of_books_id
 and gs.application_id = 101
 and a.account_position_set_id = p_account_position_set_id
 and decode(p_map_criteria,'S',gs.start_date,gs.end_date) between
     p_year_start_date and p_year_end_date
 and not exists
 (select 1
  from gl_balances gb
  where gb.code_combination_id = a.code_combination_id
    and gb.period_name = gs.period_name
    and gb.period_type = gs.period_type
    and gb.period_year = gs.period_year
    and gb.period_num = gs.period_num
    and gb.ledger_id = l_set_of_books_id)
order by code_combination_id,actual_flag,start_date;

 /*Bug:7393480:Modified cursor - c_bal_budcntl_csr to make sure that record is returned with
   null details when there is no balance on gl side for a given ccid which
   is part of the account set(s) attached to PSB Budget group hierarchy.*/

/*Bug:5929875:Cursor to fetch GL balances when Budgetary Control is turned on*/
 CURSOR c_bal_budcntl_csr(p_account_position_set_id NUMBER,
                      p_budget_version_id NUMBER,
                      p_year_start_date DATE,
                      p_year_end_date   DATE,
                      p_map_criteria    VARCHAR2) IS
 select a.code_combination_id, gb.actual_flag,
        gs.start_date, gs.end_date,
        gb.currency_code,
 (nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0)),
  (nvl(gb.BEGIN_BALANCE_DR, 0) - nvl(gb.BEGIN_BALANCE_CR,0))
 from
       GL_BALANCES gb,
       GL_PERIOD_STATUSES gs,
       psb_budget_accounts  a
 where gb.ledger_id = l_set_of_books_id
 and ((gb.translated_flag is null) or (gb.translated_flag = l_cy_flag))
 and gb.period_name = gs.period_name
 and gb.period_type = gs.period_type
 and gb.period_year = gs.period_year
 and gb.period_num = gs.period_num
 and (((l_incl_adj_flag = l_cn_flag) and (gs.adjustment_period_flag = l_cn_flag))
      or (l_incl_adj_flag = l_cy_flag))
 and gs.set_of_books_id = l_set_of_books_id
 and gs.application_id = 101
 and decode(p_map_criteria,'S',gs.start_date,gs.end_date) between
     p_year_start_date and p_year_end_date
 and gb.code_combination_id = a.code_combination_id
 and a.account_position_set_id = p_account_position_set_id
 and  ((gb.actual_flag = l_bud_actual_flag
   and exists(
    select 1
    from   GL_BUDGET_ASSIGNMENTS ga,GL_BUDORG_BC_OPTIONS  gc
    where  ga.code_combination_id = a.code_combination_id
    and    gc.funding_budget_version_id = gb.budget_version_id
    and    ga.range_id = gc.range_id))
    OR (gb.actual_flag = l_act_actual_flag)
      OR (gb.actual_flag = l_encum_actual_flag
      and ((l_gl_other_bal_flag = l_cy_flag and
((l_gl_commit_bal_flag = l_cn_flag and
((l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id not in (l_oblig_enc_type_id,l_commit_enc_type_id)) OR
 (l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id not in (l_commit_enc_type_id))))  OR
 (l_gl_commit_bal_flag = l_cy_flag and
  (l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id not in (l_oblig_enc_type_id) OR
  (l_gl_oblig_bal_flag = l_cy_flag)))))  OR
 ( l_gl_other_bal_flag = l_cn_flag and
  (l_gl_commit_bal_flag = l_cn_flag and l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id in (l_oblig_enc_type_id)) OR
  (l_gl_commit_bal_flag = l_cn_flag and l_gl_oblig_bal_flag = l_cn_flag) OR
  (l_gl_commit_bal_flag = l_cy_flag and
   ((l_gl_oblig_bal_flag = l_cn_flag and gb.encumbrance_type_id in (l_commit_enc_type_id))  OR
    (l_gl_oblig_bal_flag = l_cy_flag and gb.encumbrance_type_id in (l_commit_enc_type_id,l_oblig_enc_type_id))))))))
 union
 select a.code_combination_id, null,
        gs.start_date, gs.end_date,
        null,0,0
 from  GL_PERIOD_STATUSES gs,
       psb_budget_accounts  a
 where (((l_incl_adj_flag = l_cn_flag) and (gs.adjustment_period_flag = l_cn_flag))
       or (l_incl_adj_flag = l_cy_flag))
   and gs.set_of_books_id = l_set_of_books_id
   and gs.application_id = 101
   and a.account_position_set_id = p_account_position_set_id
   and decode(p_map_criteria,'S',gs.start_date,gs.end_date) between
       p_year_start_date and p_year_end_date
   and not exists
    (select 1
       from gl_balances gb
      where gb.code_combination_id = a.code_combination_id
        and gb.period_name = gs.period_name
        and gb.period_type = gs.period_type
        and gb.period_year = gs.period_year
        and gb.period_num = gs.period_num
        and gb.ledger_id = l_set_of_books_id)
 order by code_combination_id,actual_flag,start_date;


/*Bug:5929875:end*/
 --
BEGIN

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Get worksheet info.
  FOR l_ws_rec IN
  (
    SELECT NVL(budget_by_position, 'N')  budget_by_position,
           stage_set_id                 ,
           current_stage_seq            ,
           budget_version_id            ,
           flex_mapping_set_id          ,
           gl_budget_set_id             ,
           gl_cutoff_period             ,
           include_stat_balance         ,
           include_translated_balance   ,
           include_adjustment_periods   ,
           rounding_factor              ,
           budget_group_id              ,
           budget_calendar_id           ,
           include_gl_commit_balance    ,
           include_gl_oblig_balance     ,
           include_gl_other_balance     ,
	   include_gl_forward_balance      --bug:6775471
    FROM   psb_worksheets_v
    WHERE  worksheet_id = p_worksheet_id
  )
  LOOP
    l_budget_by_position        := l_ws_rec.budget_by_position;
    l_stage_set_id              := l_ws_rec.stage_set_id;
    l_current_stage_seq         := l_ws_rec.current_stage_seq;
    l_budget_version_id         := l_ws_rec.budget_version_id;
    l_flex_mapping_set_id       := l_ws_rec.flex_mapping_set_id;
    l_gl_budget_set_id          := l_ws_rec.gl_budget_set_id;
    l_gl_cutoff_period          := l_ws_rec.gl_cutoff_period;
    l_incl_stat_bal             := l_ws_rec.include_stat_balance;
    l_incl_trans_bal            := l_ws_rec.include_translated_balance;
    l_incl_adj_period           := l_ws_rec.include_adjustment_periods;
    l_rounding_factor           := l_ws_rec.rounding_factor;
    l_budget_group_id           := l_ws_rec.budget_group_id;
    l_budget_calendar_id        := l_ws_rec.budget_calendar_id;
    l_include_gl_commit_balance := l_ws_rec.include_gl_commit_balance;
    l_include_gl_oblig_balance  := l_ws_rec.include_gl_oblig_balance;
    l_include_gl_other_balance  := l_ws_rec.include_gl_other_balance;
    l_incl_gl_fwd_balance       := l_ws_rec.include_gl_forward_balance; --bug:6775471
  END LOOP;

  -- Substitute parameter input values that were passed in

  if (l_incl_stat_bal is null or l_incl_stat_bal = 'N') then
    l_incl_stat_bal := FND_API.G_FALSE;
  else
    l_incl_stat_bal := FND_API.G_TRUE;
  end if;

  if (l_incl_trans_bal is null or l_incl_trans_bal = 'N') then
    l_incl_trans_bal := FND_API.G_FALSE;
  else
    l_incl_trans_bal := FND_API.G_TRUE;
  end if;

  if (l_incl_adj_period is null or l_incl_adj_period = 'N') then
    l_incl_adj_flag   := 'N'; --Bug:5929875
    l_incl_adj_period := FND_API.G_FALSE;
  else
    l_incl_adj_flag   := 'Y'; --Bug:5929875
    l_incl_adj_period := FND_API.G_TRUE;
  end if;

  if (l_include_gl_commit_balance is null or l_include_gl_commit_balance = 'N')
  then
    l_include_gl_commit_balance := FND_API.G_FALSE;
    l_gl_commit_bal_flag := 'N';--Bug:5929875
  else
    l_include_gl_commit_balance := FND_API.G_TRUE;
    l_gl_commit_bal_flag := 'Y';--Bug:5929875
  end if;

  if (l_include_gl_oblig_balance is null or l_include_gl_oblig_balance = 'N')
  then
    l_include_gl_oblig_balance := FND_API.G_FALSE;
    l_gl_oblig_bal_flag := 'N'; --Bug:5929875
  else
    l_include_gl_oblig_balance := FND_API.G_TRUE;
    l_gl_oblig_bal_flag := 'Y'; --Bug:5929875
  end if;

  if (l_include_gl_other_balance is null or l_include_gl_other_balance = 'N')
  then
    l_include_gl_other_balance := FND_API.G_FALSE;
    l_gl_other_bal_flag := 'N'; --Bug:5929875
  else
    l_include_gl_other_balance := FND_API.G_TRUE;
    l_gl_other_bal_flag := 'Y'; --Bug:5929875
  end if;

 /*bug:6775471:start*/
  if (l_incl_gl_fwd_balance is null or l_incl_gl_fwd_balance = 'N')
  then
    l_incl_gl_fwd_balance := FND_API.G_FALSE;
  else
    l_incl_gl_fwd_balance := FND_API.G_TRUE;
  end if;
 /*bug:6775471:end*/

  -- Get service package info.
  FOR l_sp_rec IN
  (
    SELECT a.service_package_id
    FROM   psb_service_packages a,
           psb_worksheets_v     b
    WHERE  a.base_service_package = 'Y'
    AND    ( a.global_worksheet_id = b.worksheet_id
             OR
             a.global_worksheet_id = b.global_worksheet_id
           )
    AND    b.worksheet_id = p_worksheet_id
  )
  LOOP
    l_service_package_id := l_sp_rec.service_package_id;
  END LOOP;

  -- Bug#3545533: Added ps_account_position_set_id in the statement.
  FOR l_bg_rec IN
  (
    SELECT NVL(set_of_books_id, root_set_of_books_id)           set_of_books_id,
           NVL(currency_code, root_currency_code)               currency_code,
           NVL(chart_of_accounts_id, root_chart_of_accounts_id) flex_code,
           ps_account_position_set_id
    FROM   psb_budget_groups_v
    WHERE  budget_group_id = l_budget_group_id
  )
  LOOP
    l_set_of_books_id := l_bg_rec.set_of_books_id;
    l_func_currency   := l_bg_rec.currency_code;
    l_flex_code       := l_bg_rec.flex_code;
    l_ps_set_id       := l_bg_rec.ps_account_position_set_id;
  END LOOP;

  -- Get budgetary control info.
  FOR l_sob_rec IN
  (
    SELECT name, enable_budgetary_control_flag
    FROM   gl_sets_of_books
    WHERE  set_of_books_id = l_set_of_books_id
  )
  LOOP
    l_set_of_books_name := l_sob_rec.name;
    l_budgetary_control := l_sob_rec.enable_budgetary_control_flag;
  END LOOP;

  if (l_budgetary_control is null or l_budgetary_control = 'N') then
    l_budgetary_control := FND_API.G_FALSE;
  else
    l_budgetary_control := FND_API.G_TRUE;
  end if;

  -- If a budget set is not assigned to worksheet, a funding budget must be
  -- entered when Budgetary Control is not enabled for the Set of Books.
  if l_gl_budget_set_id is null then

    if (not FND_API.to_Boolean(l_budgetary_control)) then
      message_token('SOB', l_set_of_books_name);
      message_token('WORKSHEET_ID', p_worksheet_id);
      add_message('PSB', 'PSB_BUDGET_VERSION');
      raise FND_API.G_EXC_ERROR;
    end if;

  end if;

  /* start bug 4256345 */
  IF l_gl_budget_set_id IS NOT NULL THEN
    check_ccid_bal (x_return_status  		=> l_return_status,
                    p_gl_budget_set_id      => l_gl_budget_set_id);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  /* end bug 4256345 */


  --
  -- GL Mapping Criteria Profile Option : This specifies how to map the PSB
  -- Budget Periods to the GL Budget Periods.  Value 'S' indicates that Start
  -- Date for a GL Period should be within a PSB Budget Period specified by
  -- Start and End Dates; 'E' indicates that the End Date for a GL Period
  -- should be within a PSB Budget Period specified by Start and End Dates.
  --
  FND_PROFILE.GET( name => 'PSB_GL_MAP_CRITERIA',
                   val => g_map_criteria ) ;
  --
  if g_map_criteria is null then
    g_map_criteria := 'S';
  end if;

  --
  -- Create Zero Balances Profile: this specifies whether CCIDs with Zero
  -- YTD Balances must be created
  --
  FND_PROFILE.GET ( name => 'PSB_CREATE_ZERO_BALANCE_ACCT',
                    val => g_create_zero_bal ) ;
  --
  if g_create_zero_bal is null then
    -- Bug 3548345: Change efault behavior to not creating zero balance
    g_create_zero_bal := 'N';
  end if;

  /*bug:5929875: Replaced Dynamic SQL Statements for extracting GL Balances
    with the cursors c_bal_budcntl_csr,c_bal_csr.*/

  if l_budget_calendar_id <> NVL( PSB_WS_ACCT1.g_budget_calendar_id,
                                  FND_API.G_MISS_NUM)
  then

    PSB_WS_ACCT1.Cache_Budget_Calendar
    ( p_return_status      => l_return_status,
      p_budget_calendar_id => l_budget_calendar_id
    ) ;
    --
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end if;

  -- Bug#3514350: Check if CY estimates need to be processed or not.
  IF l_gl_cutoff_period = PSB_WS_ACCT1.g_enddate_cy THEN
    g_process_cy_estimates := FALSE;
  ELSE
    g_process_cy_estimates := TRUE;
  END IF;

  -- Extract only Actuals and Budget Balances from GL

  g_balance_type(1) := 'A';
  g_balance_type(2) := 'B';

  if ( FND_API.to_Boolean(l_include_gl_commit_balance) or
       FND_API.to_Boolean(l_include_gl_oblig_balance)  or
       FND_API.to_Boolean(l_include_gl_other_balance)  )
  then
    g_balance_type(3) := 'E';
  end if;

  -- Process budget groups associated with the worksheet.
  for c_BudGrp_Rec in c_BudGrp (l_budget_group_id) loop

    -- Process account sets associated with budget group being processed.
    for c_AccSet_Rec in c_AccSet (c_BudGrp_Rec.budget_group_id) loop

  /*Bug:5929875:start*/

  g_ccid_tbl.delete;
  g_actual_flag_tbl.delete;
  g_start_date_tbl.delete;
  g_end_date_tbl.delete;
  g_currency_tbl.delete;
  g_period_amt_tbl.delete;
  g_fwd_bal_amt_tbl.delete;

  g_bal_ind_range_tbl.delete;

	for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop
     if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'CY' then

  	  l_year_start_date :=
                         PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
	    l_year_end_date :=
                           PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;
    end if;
  end loop;

  l_budget_version_id:= NULL;

  FOR l_gl_budget_rec IN
  (
    SELECT gl_budget_id,
	   gl_budget_version_id
    FROM   psb_gl_budgets
    WHERE  gl_budget_set_id = l_gl_budget_set_id
    AND    l_year_start_date BETWEEN start_date AND end_date
    AND    NVL( dual_posting_type, 'P' ) = 'P'

  )
  LOOP
     l_gl_budget_id := l_gl_budget_rec.gl_budget_id;
     l_budget_version_id := l_gl_budget_rec.gl_budget_version_id;
  END LOOP;

  -- Get the budget for the CCID if a budget set is assigned to the worksheet

    if l_budget_version_id is null then
    begin

      FOR l_gl_budget_rec IN
      (
        SELECT gl_budget_id,
         gl_budget_version_id
        FROM   psb_gl_budgets
        WHERE  gl_budget_set_id = l_gl_budget_set_id
        AND    l_year_start_date BETWEEN start_date AND end_date
        AND    NVL( dual_posting_type, 'P' ) = 'A'

      )
      LOOP
         l_gl_budget_id := l_gl_budget_rec.gl_budget_id;
         l_budget_version_id := l_gl_budget_rec.gl_budget_version_id;
      END LOOP;

    end;
    end if;

  for c_fin_rec in c_fin loop
    l_commit_enc_type_id := c_fin_rec.req_encumbrance_type_id;
    l_oblig_enc_type_id := c_fin_rec.purch_encumbrance_type_id;
  end loop;

 if l_gl_budget_set_id is null then
  if FND_API.to_Boolean(l_budgetary_control) then


  OPEN c_bal_budcntl_csr(c_AccSet_Rec.account_position_set_id,
                         l_budget_version_id,
                         l_year_start_date,
                         l_year_end_date,
                         g_map_criteria);

  FETCH c_bal_budcntl_csr BULK COLLECT INTO
                      g_ccid_tbl,
                      g_actual_flag_tbl,
                      g_start_date_tbl,
                      g_end_date_tbl,
                      g_currency_tbl,
                      g_period_amt_tbl,
                      g_fwd_bal_amt_tbl;

  IF c_bal_budcntl_csr%NOTFOUND THEN
    CLOSE c_bal_budcntl_csr;
  END IF;

  IF c_bal_budcntl_csr%ISOPEN THEN
    CLOSE c_bal_budcntl_csr;
  END IF;
  end if;
else

  OPEN c_bal_csr(c_AccSet_Rec.account_position_set_id,
                 l_budget_version_id,
                 l_year_start_date,
                 l_year_end_date,
                 g_map_criteria);


  FETCH c_bal_csr BULK COLLECT INTO
                    g_ccid_tbl,
                    g_actual_flag_tbl,
                    g_start_date_tbl,
                    g_end_date_tbl,
                    g_currency_tbl,
                    g_period_amt_tbl,
                    g_fwd_bal_amt_tbl;

  IF c_bal_csr%NOTFOUND THEN
    CLOSE c_bal_csr;
  END IF;

  IF c_bal_csr%ISOPEN THEN
    CLOSE c_bal_csr;
  END IF;
end if;

  g_old_ccid := 0;
  l_old_bal_flag := 'X';
  l_index := 0;

  g_bud_start_index   := 0;
  g_bud_end_index     := 0;
  g_act_start_index   := 0;
  g_act_end_index     := 0;
  g_encum_start_index := 0;
  g_encum_end_index   := 0;
  l_ind_process       := 0;--bug:7393480

    /*Bug:5929875: g_act_start_index, g_act_end_index are assigned with
    start and end indexes of Actual balances for a given ccid (g_old_ccid).
    Similarly  g_bud_start_index,g_bud_end_index for Budget balances and
    g_encum_start_index, g_encum_end_index for Encumbrance balances of
    ccid - g_old_ccid  */

  FOR l_cc_index IN 1..g_ccid_tbl.count LOOP

     /*bug:7393480:start*/
     IF l_cc_index < g_ccid_tbl.LAST THEN
        l_ind_process := l_cc_index+1;
     ELSIF l_cc_index = g_ccid_tbl.LAST THEN
        l_ind_process := l_cc_index;
     END IF;
     /*bug:7393480:end*/

    IF g_old_ccid = 0 THEN
       g_old_ccid := g_ccid_tbl(l_cc_index);
       IF g_actual_flag_tbl(l_cc_index) = 'A' THEN
          g_act_start_index := l_cc_index;
          g_act_end_index   := l_cc_index;
       ELSIF g_actual_flag_tbl(l_cc_index) = 'B' THEN
          g_bud_start_index := l_cc_index;
          g_bud_end_index   := l_cc_index;
       ELSIF g_actual_flag_tbl(l_cc_index) = 'E' THEN
          g_encum_start_index := l_cc_index;
          g_encum_end_index := l_cc_index;
        /*bug:7393480:start*/
       ELSIF g_actual_flag_tbl(l_cc_index) IS NULL THEN
          g_act_start_index := l_cc_index;
          g_act_end_index   := l_cc_index;

          g_bud_start_index := l_cc_index;
          g_bud_end_index   := l_cc_index;

          g_encum_start_index := l_cc_index;
          g_encum_end_index := l_cc_index;
        /*bug:7393480:end*/
       END IF;

    ELSIF g_old_ccid = g_ccid_tbl(l_cc_index) THEN
      IF g_actual_flag_tbl(l_cc_index) = 'A' THEN
         IF g_act_start_index = 0 THEN
            g_act_start_index := l_cc_index;
            g_act_end_index   := l_cc_index;
         ELSE
            g_act_end_index := l_cc_index;
         END IF;
      ELSIF g_actual_flag_tbl(l_cc_index) = 'B' THEN
         IF g_bud_start_index = 0 THEN
            g_bud_start_index := l_cc_index;
            g_bud_end_index   := l_cc_index;
         ELSE
            g_bud_end_index := l_cc_index;
         END IF;
      ELSIF g_actual_flag_tbl(l_cc_index) = 'E' THEN
         IF g_encum_start_index = 0 THEN
            g_encum_start_index := l_cc_index;
            g_encum_end_index   := l_cc_index;
         ELSE
            g_encum_end_index := l_cc_index;
         END IF;
       /*bug:7393480:start*/
      ELSIF g_actual_flag_tbl(l_cc_index) IS NULL THEN
         IF g_act_start_index = 0 THEN
            g_act_start_index := l_cc_index;
            g_act_end_index   := l_cc_index;
         ELSIF g_act_end_index - g_act_start_index = 0 THEN    --bug:7393480:modified
            g_act_end_index := l_cc_index;
         END IF;

         IF g_bud_start_index = 0 THEN
            g_bud_start_index := l_cc_index;
            g_bud_end_index   := l_cc_index;
         ELSIF g_bud_end_index - g_bud_start_index = 0 THEN   --bug:7393480:modified
            g_bud_end_index := l_cc_index;
         END IF;

         IF g_encum_start_index = 0 THEN
            g_encum_start_index := l_cc_index;
            g_encum_end_index   := l_cc_index;
         ELSIF g_encum_end_index - g_encum_start_index = 0 THEN   --bug:7393480:modified
            g_encum_end_index := l_cc_index;
         END IF;
       /*bug:7393480:end*/
      END IF;

    END IF;

   /*bug:7393480:modified the below condition*/
    IF (((l_cc_index < g_ccid_tbl.LAST) AND (g_old_ccid <> g_ccid_tbl(l_ind_process))) OR
       (l_cc_index = g_ccid_tbl.LAST))   THEN

  /*Bug:5929875:end */


      -- Process account codes associated with account set being processed.
      open c_ccids(c_AccSet_Rec.account_position_set_id);

      loop

	fetch c_ccids BULK COLLECT INTO l_ccids.ccid, l_ccids.start_date,
                                        l_ccids.end_date;


        -- Process given set of accounts for the curreng fetch.
	for l_ccid_index in 1..l_ccids.ccid.count loop

	  l_ccid_start_period := greatest(nvl(l_ccids.start_date(l_ccid_index),
                                          c_AccSet_Rec.effective_start_date),
                                          c_AccSet_Rec.effective_start_date);
	  l_ccid_end_period   := least(nvl(l_ccids.end_date(l_ccid_index),
                                       c_AccSet_Rec.effective_end_date),
                                       c_AccSet_Rec.effective_end_date);

	  g_actuals_func_total := 0;
	  g_actuals_stat_total := 0;

	  GL_CODE_COMBINATIONS_PKG.Select_Columns
	  ( X_code_combination_id => l_ccids.ccid(l_ccid_index) ,
	    X_account_type        => l_account_type             ,
	    X_template_id         => l_template_id              ) ;


          -- Process all budget years for the CCID.
	  for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

	    l_year_start_date :=
                         PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
	    l_year_end_date :=
                           PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;

            -- Check if CCID is valid for the year being processed.
	    if (((l_ccid_start_period <= l_year_end_date) and (l_ccid_end_period is null))
	     or ((l_ccid_start_period between l_year_start_date and l_year_end_date)
	      or (l_ccid_end_period between l_year_start_date and l_year_end_date)
	      or ((l_ccid_start_period < l_year_start_date)
	      and (l_ccid_end_period > l_year_end_date))))
            then

              -- Process CY balances.
	      if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'CY' then

                for l_init_index in 1..g_gl_actual_periods.Count loop
                  g_gl_actual_periods(l_init_index).budget_period_id := null;
                  g_gl_actual_periods(l_init_index).long_sequence_no := null;
                  g_gl_actual_periods(l_init_index).start_date := null;
                  g_gl_actual_periods(l_init_index).end_date := null;
                  g_gl_actual_periods(l_init_index).budget_year_id := null;
                end loop;

                for l_init_index in 1..g_gl_budget_periods.Count loop
                  g_gl_budget_periods(l_init_index).budget_period_id := null;
                  g_gl_budget_periods(l_init_index).long_sequence_no := null;
                  g_gl_budget_periods(l_init_index).start_date := null;
                  g_gl_budget_periods(l_init_index).end_date := null;
                  g_gl_budget_periods(l_init_index).budget_year_id := null;
                end loop;

                -- Bug#2529886: When we update GL balances, we need to update
                -- CY Estimate balances as well.
                g_alloc_periods.DELETE;

		l_init_index := 1;
		g_num_actual_periods := 0;
		g_num_budget_periods := 0;

                -- Process budget periods for the year being processed.
		for l_period_index in 1..PSB_WS_ACCT1.g_num_budget_periods loop

		  if (PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id =
		      PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id)                   then

		    -- Extract Budget Balances for all Periods in Current Year

		    g_gl_budget_periods(l_init_index).budget_period_id :=
						      PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_id;
		    g_gl_budget_periods(l_init_index).long_sequence_no :=
						      PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no;
		    g_gl_budget_periods(l_init_index).start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
		    g_gl_budget_periods(l_init_index).end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
		    g_gl_budget_periods(l_init_index).budget_year_id := PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id;

		    g_num_budget_periods := g_num_budget_periods + 1;

		    -- Extract Actual Balances for all Periods in Current Year
                    -- upto the GL Cutoff Date

		    if ((l_gl_cutoff_period is null) or
			(l_gl_cutoff_period > PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date))
                    then

		      g_gl_actual_periods(l_init_index).budget_period_id :=
							PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_id;
		      g_gl_actual_periods(l_init_index).long_sequence_no :=
							PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no;
		      g_gl_actual_periods(l_init_index).start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
		      g_gl_actual_periods(l_init_index).end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
		      g_gl_actual_periods(l_init_index).budget_year_id := PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id;

		      g_num_actual_periods := g_num_actual_periods + 1;

                    else

                      -- Bug#2529886: Get information about CY period beyond
                      -- the GL Cutoff Date.
		      g_alloc_periods(l_init_index).budget_period_id := PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_id;
		      g_alloc_periods(l_init_index).long_sequence_no := PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no;
		      g_alloc_periods(l_init_index).start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
		      g_alloc_periods(l_init_index).end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
		      g_alloc_periods(l_init_index).budget_year_id := PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id;
                      -- Bug#2529886: End

		    end if;

		    l_init_index := l_init_index + 1;

		  end if;

		end loop;
                -- End processing budget periods for the year being processed.

		-- Get Balances from GL
		Get_Balances
		( p_return_status => l_return_status,
		  p_ccid => l_ccids.ccid(l_ccid_index),
		  p_account_type => l_account_type,
		  p_budget_year_id =>
                      PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
		  p_year_name =>
                      PSB_WS_ACCT1.g_budget_years(l_year_index).year_name,
		  p_year_start_date =>
                      PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
		  p_year_end_date =>
                      PSB_WS_ACCT1.g_budget_years(l_year_index).end_date,
		  p_budget_year_type =>
                      PSB_WS_ACCT1.g_budget_years(l_year_index).year_type,
		  p_incl_stat_bal => l_incl_stat_bal,
		  p_incl_trans_bal => l_incl_trans_bal,
		  p_incl_adj_period => l_incl_adj_period,
		  p_set_of_books_id => l_set_of_books_id,
		  p_budget_group_id => c_BudGrp_Rec.budget_group_id,
		  p_stage_set_id => l_stage_set_id,
		  p_func_currency => l_func_currency,
		  p_budgetary_control => l_budgetary_control,
		  p_budget_version_id => l_budget_version_id,
		  p_flex_mapping_set_id => l_flex_mapping_set_id,
		  p_gl_budget_set_id => l_gl_budget_set_id,
		  p_flex_code => l_flex_code,
		  p_worksheet_id => p_worksheet_id,
		  p_service_package_id => l_service_package_id,
		  p_sequence_number => l_current_stage_seq,
		  p_rounding_factor => l_rounding_factor,
                  /* bug no 4725091 */
                  p_incl_gl_fwd_balance => l_incl_gl_fwd_balance, --bug:6775471
                  p_create_wks_flag     => fnd_api.g_false
                ) ;
                --
		if l_return_status <> FND_API.G_RET_STS_SUCCESS then

		  raise FND_API.G_EXC_ERROR;
		end if;

                -- Bug#3545533: Update CY estimates only for non-pos accounts.
                l_process_cy_estimates := 'Y' ;

                IF l_budget_by_position = 'Y' THEN

                  -- Check if current ccid is for position or not. This will
                  -- reset l_process_cy_estimates if for position.
                  OPEN  l_check_acct_type ( l_ccids.ccid(l_ccid_index) ) ;
                  FETCH l_check_acct_type INTO l_process_cy_estimates ;
                  CLOSE l_check_acct_type ;

                END IF ;

                IF l_process_cy_estimates = 'Y' THEN
                  --
                  -- Bug#2529886: When updating GL balances, we need to update
                  -- CY Estimate balances as well.
                  --
                  Update_CY_Estimates
                  ( p_return_status      => l_return_status,
                    p_worksheet_id       => p_worksheet_id,
                    p_service_package_id => l_service_package_id,
                    p_rounding_factor    => l_rounding_factor,
                    p_start_stage_seq    => l_current_stage_seq,
                    p_budget_group_id    => c_BudGrp_Rec.budget_group_id,
                    p_stage_set_id       => l_stage_set_id,
                    p_budget_year_id     =>
                      PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
                    p_ccid               => l_ccids.ccid(l_ccid_index),
                    p_currency_code      => l_func_currency
                  ) ;
                  --
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                    RAISE FND_API.G_EXC_ERROR;
                  END IF ;
                  -- Bug#2529886: End

                END IF ;

	      end if;

	    end if;
            -- Check if CCID is valid for the year being processed.

	  end loop;
          -- End processing all budget years for the CCID.

	  l_num_accounts := l_num_accounts + 1;

	  if l_num_accounts > PSB_WS_ACCT1.g_checkpoint_save then
	    commit work;
	    l_num_accounts := 0;
	  end if;


	end loop;
        -- End processing given set of accounts for the curreng fetch.

	exit when c_ccids%NOTFOUND;



      end loop;

      close c_ccids;
      -- End processing accounts associated with account set being processed.

/*Bug:5929875:start*/

   /*bug:7393480:Modification Starts*/

      if g_old_ccid <> g_ccid_tbl(l_ind_process) then
        g_bud_start_index := 0;
        g_bud_end_index   := 0;

        g_act_start_index := 0;
        g_act_end_index   := 0;

        g_encum_start_index := 0;
        g_encum_end_index   := 0;
      end if;

      g_old_ccid := g_ccid_tbl(l_ind_process);

  END IF;
   /*bug:7393480:Modification Ends*/

 END LOOP;
/*Bug:5929875:end*/

    end loop;
    -- End processing account sets associated with budget group being processed.

    commit work;

  end loop;
  -- End processing budget groups associated with the worksheet.

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     if c_ccids%ISOPEN then
       close c_ccids;
     end if;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if c_ccids%ISOPEN then
       close c_ccids;
     end if;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if c_ccids%ISOPEN then
       close c_ccids;
     end if;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Update_GL_Balances;

/* ----------------------------------------------------------------------- */

-- Compute Line Total for Parameter

FUNCTION Compute_Line_Total
( p_worksheet_id         IN  NUMBER,
  p_flex_mapping_set_id  IN  NUMBER,
  p_budget_calendar_id   IN  NUMBER,
  p_ccid                 IN  NUMBER,
  p_budget_year_type_id  IN  NUMBER,
  p_balance_type         IN  VARCHAR2,
  p_currency_code        IN  VARCHAR2,
  p_service_package_id   IN  NUMBER,
  /* start bug no 4256345 */
  p_stage_set_id        IN   NUMBER,
  p_current_stage_seq   IN   NUMBER
  /* end bug no 4256345 */
) RETURN NUMBER IS

  l_mapped_ccid          NUMBER;
  l_ytd_amount           NUMBER := FND_API.G_MISS_NUM;

  /* start bug  4256345 */
  l_budget_year_id NUMBER;
 /* end bug  4256345 */


  -- Compute Line Total for Formula

/* For Bug No. 2214715 : Start  */
/*  Existing Cursor definition is commented and modified one is added as follows :
  cursor c_Type12 is
    select nvl(a.ytd_amount, 0) YTD_Amount
      from PSB_WS_ACCOUNT_LINES a
     where a.code_combination_id = l_mapped_ccid
       and a.currency_code = p_currency_code
       and a.balance_type = p_balance_type
       and a.service_package_id = p_service_package_id
       and a.end_stage_seq is null
       and a.template_id is null
       and exists
	  (select 1
	     from PSB_WORKSHEETS b,
		  PSB_BUDGET_PERIODS c
	    where b.worksheet_id = p_worksheet_id
	      and a.stage_set_id = b.stage_set_id
	      and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
	      and c.budget_calendar_id = p_budget_calendar_id
	      and a.budget_year_id = c.budget_period_id
	      and c.budget_period_type = 'Y'
	      and c.budget_year_type_id = p_budget_year_type_id)
       and exists
	  (select 1
	     from PSB_WS_LINES
	    where account_line_id = a.account_line_id
	      and worksheet_id = p_worksheet_id);
*/

    -- commented as a part of bug fix 4256345
    /* cursor c_Type12 is
    select sum(nvl(a.ytd_amount, 0)) YTD_Amount
      from PSB_WORKSHEETS b,
	   PSB_WS_LINES d,
	   PSB_WS_ACCOUNT_LINES a,
	   PSB_BUDGET_PERIODS c
     where b.worksheet_id = p_worksheet_id
       and d.worksheet_id = b.worksheet_id
       and d.account_line_id = a.account_line_id
       and a.code_combination_id = l_mapped_ccid
       and a.balance_type = p_balance_type
       and a.currency_code = p_currency_code
       and a.service_package_id = p_service_package_id
       and a.end_stage_seq is null
       and a.template_id is null
       and a.stage_set_id = b.stage_set_id
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and c.budget_calendar_id = p_budget_calendar_id
       and a.budget_year_id = c.budget_period_id
       and c.budget_period_type = 'Y'
       and c.budget_year_type_id = p_budget_year_type_id;              */

/* For Bug No. 2214715 : End  */


BEGIN

  l_mapped_ccid := PSB_WS_ACCT1.Map_Account
		      (p_flex_mapping_set_id => p_flex_mapping_set_id,
		       p_ccid => p_ccid,
		       p_budget_year_type_id => p_budget_year_type_id);

  -- commented as a part of bug fix 4256345
  /* for c_Type12_Rec in c_Type12 loop
    l_ytd_amount := c_Type12_Rec.YTD_Amount;
  end loop; */

/* start bug 4256345 */

  FOR l_budget_period_rec IN (select budget_period_id
       						  from psb_budget_periods
       						  where budget_calendar_id = p_budget_calendar_id
                              and budget_period_type = 'Y'
                              and parent_budget_period_id is null
                              and budget_year_type_id = p_budget_year_type_id)
  LOOP
    l_budget_year_id := l_budget_period_rec.budget_period_id;
  END LOOP;


  SELECT
    SUM(NVL(A.YTD_AMOUNT, 0)) YTD_AMOUNT
  INTO
    l_ytd_amount
  FROM
    PSB_WS_LINES WSL
  , PSB_WS_ACCOUNT_LINES A
  WHERE A.CODE_COMBINATION_ID = l_mapped_ccid
  AND   A.BUDGET_YEAR_ID = l_budget_year_id
  AND   A.SERVICE_PACKAGE_ID = p_service_package_id
  AND   A.BALANCE_TYPE = p_balance_type
  AND   A.CURRENCY_CODE = p_currency_code
  AND   A.END_STAGE_SEQ IS NULL
  AND   A.TEMPLATE_ID IS NULL
  AND   A.STAGE_SET_ID = p_stage_set_id
  AND   p_current_stage_seq
  BETWEEN A.START_STAGE_SEQ AND A.CURRENT_STAGE_SEQ
  AND   WSL.WORKSHEET_ID = p_worksheet_id
  AND   WSL.ACCOUNT_LINE_ID = A.ACCOUNT_LINE_ID;

/* end bug 4256345 */

  RETURN l_ytd_amount;

END Compute_Line_Total;

/* ----------------------------------------------------------------------- */

-- Parse Parameter Formulae and compute a YTD total

PROCEDURE Process_Parameter
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_parameter_id        IN   NUMBER,
  p_parameter_name      IN   VARCHAR2,
  p_compound_annually   IN   VARCHAR2,
  p_compound_factor     IN   NUMBER,
  p_budget_calendar_id  IN   NUMBER,
  p_flex_code           IN   NUMBER,
  p_flex_mapping_set_id IN   NUMBER,
  p_ccid                IN   NUMBER,
  p_ccid_start_period   IN   DATE,
  p_ccid_end_period     IN   DATE,
  p_budget_group_id     IN   NUMBER,
  p_num_proposed_years  IN   NUMBER,
  p_defer_ccids         IN   VARCHAR2,
  p_deferred            OUT  NOCOPY  BOOLEAN,
  /* bug no 4256345 */
  p_stage_set_id        IN   NUMBER,
  p_current_stage_seq   IN   NUMBER
  /* bug no 4256345 */
) IS

  -- Formulae is sorted by step number and processed

  cursor c_Formula is
    select step_number,
	   prefix_operator,
	   budget_year_type_id,
	   balance_type,
	   segment1, segment2, segment3,
	   segment4, segment5, segment6,
	   segment7, segment8, segment9,
	   segment10, segment11, segment12,
	   segment13, segment14, segment15,
	   segment16, segment17, segment18,
	   segment19, segment20, segment21,
	   segment22, segment23, segment24,
	   segment25, segment26, segment27,
	   segment28, segment29, segment30,
	   currency_code,
	   nvl(amount, 0) amount,
	   postfix_operator
      from PSB_PARAMETER_FORMULAS
     where parameter_id = p_parameter_id
     order by step_number;

  l_first_line          BOOLEAN := TRUE;
  l_first_time          BOOLEAN := TRUE;

/* Bug No 2719865 Start */
  l_ccid_defined        BOOLEAN := TRUE;
/* Bug No 2719865 End */

  l_num_lines           NUMBER := 0;
  l_compound_total      NUMBER;

  l_type1               BOOLEAN;
  l_type2               BOOLEAN;
  l_type3               BOOLEAN;
  l_type4               BOOLEAN;

  l_line_total          NUMBER;
  l_ytd_amount          NUMBER;

  l_index               PLS_INTEGER;
  l_init_index          PLS_INTEGER;

  l_ccid                NUMBER;
  l_seg_val             FND_FLEX_EXT.SegmentArray;
  l_ccid_val            FND_FLEX_EXT.SegmentArray;

  l_flex_delimiter      VARCHAR2(1);
  l_concat_segments     VARCHAR2(2000);

  l_deferred            BOOLEAN := FALSE;
  l_ccid_found          BOOLEAN;
  l_return_status       VARCHAR2(1);

BEGIN

  -- Cache the number of Segments and the application column names for the
  -- Segments for the Chart of Accounts

  if p_flex_code <> nvl(PSB_WS_ACCT1.g_flex_code, 0) then
  begin

    PSB_WS_ACCT1.Flex_Info
       (p_flex_code => p_flex_code,
	p_return_status => l_return_status);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  -- Get the individual Segment values for the Code Combination

  if not FND_FLEX_EXT.Get_Segments
    (application_short_name => 'SQLGL',
     key_flex_code => 'GL#',
     structure_number => p_flex_code,
     combination_id => p_ccid,
     n_segments => PSB_WS_ACCT1.g_num_segs,
     segments => l_ccid_val) then

    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  end if;

  for c_Formula_Rec in c_Formula loop

    -- Each Formula Line is of the following types :
    --
    -- Type1 : Depends on Account Set Assignments
    --        (Step, Prefix Operator, Postfix Operator, Period, Balance Type, Currency, Amount have values; Account is blank)
    --
    -- Type2 : Depends on Account defined in Formula Line
    --        (Step, Prefix Operator, Period, Balance Type, Account, Currency have values;
    --         Amount and Postfix Operator are optional)
    --
    -- Type3 : Flat Amount assignment
    --        (Step, Prefix Operator, Amount have values; Period, Balance Type, Account, Currency, Postfix Operator are blank)
    --

    -- Type4 : Depends on Account Set Assignments (valid only for budget revisions)
    --        (Step, Prefix Operator, Postfix Operator, Balance Type, Currency, Amount have values; Account, Period are blank)
    --
    l_type1 := FALSE;
    l_type2 := FALSE;
    l_type3 := FALSE;
    l_type4 := FALSE;
    l_line_total := 0;

    l_ccid_found := FALSE;

    for l_init_index in 1..PSB_WS_ACCT1.g_num_segs loop
      l_seg_val(l_init_index) := null;
    end loop;

    l_num_lines := l_num_lines + 1;

    -- The prefix operator for the 1st Formula line must be '='; for the other Formula lines, the
    -- prefix operator can be '+', '-', '*', '/'

    if l_first_line then
    begin

      l_first_line := FALSE;

      if c_Formula_Rec.prefix_operator <> '=' then
	message_token('PARAMETER', p_parameter_name);
	message_token('STEPID', c_Formula_Rec.step_number);
	message_token('OPERATOR', '[=]');
	add_message('PSB', 'PSB_INVALID_PARAM_OPR');
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    else
    begin

      if c_Formula_Rec.prefix_operator not in ('+', '-', '*', '/') then
	message_token('PARAMETER', p_parameter_name);
	message_token('STEPID', c_Formula_Rec.step_number);
	message_token('OPERATOR', '[+, -, *, /]');
	add_message('PSB', 'PSB_INVALID_PARAM_OPR');
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

    -- Check Formula Type :

    if ((c_Formula_Rec.prefix_operator is not null) and
	(c_Formula_Rec.postfix_operator is not null) and
	(c_Formula_Rec.budget_year_type_id is not null) and
	(c_Formula_Rec.balance_type is not null) and
	(c_Formula_Rec.currency_code is not null) and
	(c_Formula_Rec.amount is not null) and
       ((c_Formula_Rec.segment1 is null) and (c_Formula_Rec.segment2 is null) and (c_Formula_Rec.segment3 is null) and
	(c_Formula_Rec.segment4 is null) and (c_Formula_Rec.segment5 is null) and (c_Formula_Rec.segment6 is null) and
	(c_Formula_Rec.segment7 is null) and (c_Formula_Rec.segment8 is null) and (c_Formula_Rec.segment9 is null) and
	(c_Formula_Rec.segment10 is null) and (c_Formula_Rec.segment11 is null) and (c_Formula_Rec.segment12 is null) and
	(c_Formula_Rec.segment13 is null) and (c_Formula_Rec.segment14 is null) and (c_Formula_Rec.segment15 is null) and
	(c_Formula_Rec.segment16 is null) and (c_Formula_Rec.segment17 is null) and (c_Formula_Rec.segment18 is null) and
	(c_Formula_Rec.segment19 is null) and (c_Formula_Rec.segment20 is null) and (c_Formula_Rec.segment21 is null) and
	(c_Formula_Rec.segment22 is null) and (c_Formula_Rec.segment23 is null) and (c_Formula_Rec.segment24 is null) and
	(c_Formula_Rec.segment25 is null) and (c_Formula_Rec.segment26 is null) and (c_Formula_Rec.segment27 is null) and
	(c_Formula_Rec.segment28 is null) and (c_Formula_Rec.segment29 is null) and (c_Formula_Rec.segment30 is null))) then
    begin
      l_type1 := TRUE;
    end;
    elsif ((c_Formula_Rec.prefix_operator is not null) and
	   (c_Formula_Rec.budget_year_type_id is not null) and
	   (c_Formula_Rec.balance_type is not null) and
	   (c_Formula_Rec.currency_code is not null) and
	  ((c_Formula_Rec.segment1 is not null) or (c_Formula_Rec.segment2 is not null) or (c_Formula_Rec.segment3 is not null) or
	   (c_Formula_Rec.segment4 is not null) or (c_Formula_Rec.segment5 is not null) or (c_Formula_Rec.segment6 is not null) or
	   (c_Formula_Rec.segment7 is not null) or (c_Formula_Rec.segment8 is not null) or (c_Formula_Rec.segment9 is not null) or
	   (c_Formula_Rec.segment10 is not null) or (c_Formula_Rec.segment11 is not null) or (c_Formula_Rec.segment12 is not null) or
	   (c_Formula_Rec.segment13 is not null) or (c_Formula_Rec.segment14 is not null) or (c_Formula_Rec.segment15 is not null) or
	   (c_Formula_Rec.segment16 is not null) or (c_Formula_Rec.segment17 is not null) or (c_Formula_Rec.segment18 is not null) or
	   (c_Formula_Rec.segment19 is not null) or (c_Formula_Rec.segment20 is not null) or (c_Formula_Rec.segment21 is not null) or
	   (c_Formula_Rec.segment22 is not null) or (c_Formula_Rec.segment23 is not null) or (c_Formula_Rec.segment24 is not null) or
	   (c_Formula_Rec.segment25 is not null) or (c_Formula_Rec.segment26 is not null) or (c_Formula_Rec.segment27 is not null) or
	   (c_Formula_Rec.segment28 is not null) or (c_Formula_Rec.segment29 is not null) or (c_Formula_Rec.segment30 is not null))) then
    begin
      l_type2 := TRUE;
    end;
    elsif ((c_Formula_Rec.prefix_operator is not null) and
	   (c_Formula_Rec.amount is not null) and
	   (c_Formula_Rec.budget_year_type_id is null) and
	   (c_Formula_Rec.balance_type is null) and
	   (c_Formula_Rec.currency_code is null) and
	   (c_Formula_Rec.postfix_operator is null) and
	  ((c_Formula_Rec.segment1 is null) and (c_Formula_Rec.segment2 is null) and (c_Formula_Rec.segment3 is null) and
	   (c_Formula_Rec.segment4 is null) and (c_Formula_Rec.segment5 is null) and (c_Formula_Rec.segment6 is null) and
	   (c_Formula_Rec.segment7 is null) and (c_Formula_Rec.segment8 is null) and (c_Formula_Rec.segment9 is null) and
	   (c_Formula_Rec.segment10 is null) and (c_Formula_Rec.segment11 is null) and (c_Formula_Rec.segment12 is null) and
	   (c_Formula_Rec.segment13 is null) and (c_Formula_Rec.segment14 is null) and (c_Formula_Rec.segment15 is null) and
	   (c_Formula_Rec.segment16 is null) and (c_Formula_Rec.segment17 is null) and (c_Formula_Rec.segment18 is null) and
	   (c_Formula_Rec.segment19 is null) and (c_Formula_Rec.segment20 is null) and (c_Formula_Rec.segment21 is null) and
	   (c_Formula_Rec.segment22 is null) and (c_Formula_Rec.segment23 is null) and (c_Formula_Rec.segment24 is null) and
	   (c_Formula_Rec.segment25 is null) and (c_Formula_Rec.segment26 is null) and (c_Formula_Rec.segment27 is null) and
	   (c_Formula_Rec.segment28 is null) and (c_Formula_Rec.segment29 is null) and (c_Formula_Rec.segment30 is null))) then
    begin
      l_type3 := TRUE;
    end;
    elsif ((c_Formula_Rec.prefix_operator is not null) and
	   (c_Formula_Rec.postfix_operator is not null) and
	   (c_Formula_Rec.balance_type in ('O', 'C')) and
	   (c_Formula_Rec.currency_code is not null) and
	   (c_Formula_Rec.amount is not null) and
	  ((c_Formula_Rec.budget_year_type_id is null) and
	   (c_Formula_Rec.segment1 is null) and (c_Formula_Rec.segment2 is null) and (c_Formula_Rec.segment3 is null) and
	   (c_Formula_Rec.segment4 is null) and (c_Formula_Rec.segment5 is null) and (c_Formula_Rec.segment6 is null) and
	   (c_Formula_Rec.segment7 is null) and (c_Formula_Rec.segment8 is null) and (c_Formula_Rec.segment9 is null) and
	   (c_Formula_Rec.segment10 is null) and (c_Formula_Rec.segment11 is null) and (c_Formula_Rec.segment12 is null) and
	   (c_Formula_Rec.segment13 is null) and (c_Formula_Rec.segment14 is null) and (c_Formula_Rec.segment15 is null) and
	   (c_Formula_Rec.segment16 is null) and (c_Formula_Rec.segment17 is null) and (c_Formula_Rec.segment18 is null) and
	   (c_Formula_Rec.segment19 is null) and (c_Formula_Rec.segment20 is null) and (c_Formula_Rec.segment21 is null) and
	   (c_Formula_Rec.segment22 is null) and (c_Formula_Rec.segment23 is null) and (c_Formula_Rec.segment24 is null) and
	   (c_Formula_Rec.segment25 is null) and (c_Formula_Rec.segment26 is null) and (c_Formula_Rec.segment27 is null) and
	   (c_Formula_Rec.segment28 is null) and (c_Formula_Rec.segment29 is null) and (c_Formula_Rec.segment30 is null))) then
    begin
      l_type4 := TRUE;
    end;
    else
    begin
      message_token('PARAMETER', p_parameter_name);
      add_message('PSB', 'PSB_INVALID_PARAM_FORMULA');
      raise FND_API.G_EXC_ERROR;
    end;
    end if;

    if l_type1 then
    begin

      l_ytd_amount:=Compute_Line_Total(
                      p_worksheet_id => p_worksheet_id,
		      p_flex_mapping_set_id => p_flex_mapping_set_id,
		      p_budget_calendar_id => p_budget_calendar_id,
		      p_ccid => p_ccid,
		      p_budget_year_type_id => c_Formula_Rec.budget_year_type_id,
		      p_balance_type => c_Formula_Rec.balance_type,
		      p_currency_code => c_Formula_Rec.currency_code,
		      p_service_package_id => p_service_package_id,
			  /* bug no 4256345 */
			  p_stage_set_id        => p_stage_set_id,
			  p_current_stage_seq   => p_current_stage_seq
			  /* bug no 4256345 */);

      /* Bug 3499337 start */
      -- Reset the l_ytd_amount to 0 when no line found
      if l_ytd_amount = FND_API.G_MISS_NUM OR l_ytd_amount IS NULL then
        l_ytd_amount := 0;
      end if;

      -- Comment out the following condition since the case will never existed.
      -- if l_ytd_amount <> FND_API.G_MISS_NUM then
      -- begin
      /* Bug 3499337 end */

	if c_Formula_Rec.postfix_operator = '+' then
	  l_line_total := l_ytd_amount + c_Formula_Rec.amount;
	elsif c_Formula_Rec.postfix_operator = '-' then
	  l_line_total := l_ytd_amount - c_Formula_Rec.amount;
	elsif c_Formula_Rec.postfix_operator = '*' then
	begin

	  l_line_total := l_ytd_amount * c_Formula_Rec.amount;

	  if FND_API.to_Boolean(p_compound_annually) then
	    l_compound_total := l_ytd_amount * POWER(c_Formula_Rec.amount, p_compound_factor);
	  end if;

	end;
	elsif c_Formula_Rec.postfix_operator = '/' then
	begin

	  -- Avoid a divide-by-zero error

	  if c_Formula_Rec.amount = 0 then
	    l_line_total := 0;
	  else
	    l_line_total := l_ytd_amount / c_Formula_Rec.amount;
	  end if;

	end;
	else
	begin
	  message_token('PARAMETER', p_parameter_name);
	  add_message('PSB', 'PSB_INVALID_PARAM_FORMULA');
	  raise FND_API.G_EXC_ERROR;
	end;
	end if;

      -- Bug 3499337: comment out the following lines
      -- end;
      -- end if;

    end;

    -- For this type of formula, compose the Segment Combo by merging Segment Values
    -- from the Account field of the Formula with the Segment Values from the CCID itself

    elsif l_type2 then
    begin

      for l_index in 1..PSB_WS_ACCT1.g_num_segs loop

	if ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT1') and
	    (c_Formula_Rec.segment1 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment1;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT2') and
	    (c_Formula_Rec.segment2 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment2;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT3') and
	    (c_Formula_Rec.segment3 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment3;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT4') and
	    (c_Formula_Rec.segment4 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment4;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT5') and
	    (c_Formula_Rec.segment5 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment5;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT6') and
	    (c_Formula_Rec.segment6 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment6;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT7') and
	    (c_Formula_Rec.segment7 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment7;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT8') and
	    (c_Formula_Rec.segment8 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment8;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT9') and
	    (c_Formula_Rec.segment9 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment9;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT10') and
	    (c_Formula_Rec.segment10 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment10;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT11') and
	    (c_Formula_Rec.segment11 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment11;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT12') and
	    (c_Formula_Rec.segment12 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment12;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT13') and
	    (c_Formula_Rec.segment13 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment13;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT14') and
	    (c_Formula_Rec.segment14 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment14;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT15') and
	    (c_Formula_Rec.segment15 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment15;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT16') and
	    (c_Formula_Rec.segment16 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment16;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT17') and
	    (c_Formula_Rec.segment17 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment17;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT18') and
	    (c_Formula_Rec.segment18 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment18;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT19') and
	    (c_Formula_Rec.segment19 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment19;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT20') and
	    (c_Formula_Rec.segment20 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment20;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT21') and
	    (c_Formula_Rec.segment21 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment21;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT22') and
	    (c_Formula_Rec.segment22 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment22;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT23') and
	    (c_Formula_Rec.segment23 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment23;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT24') and
	    (c_Formula_Rec.segment24 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment24;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT25') and
	    (c_Formula_Rec.segment25 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment25;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT26') and
	    (c_Formula_Rec.segment26 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment26;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT27') and
	    (c_Formula_Rec.segment27 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment27;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT28') and
	    (c_Formula_Rec.segment28 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment28;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT29') and
	    (c_Formula_Rec.segment29 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment29;

	elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT30') and
	    (c_Formula_Rec.segment30 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment30;

	else
	  l_seg_val(l_index) := l_ccid_val(l_index);

/* Bug No 2719865 Start */
	  l_ccid_defined := FALSE;
/* Bug No 2719865 End */
	end if;

      end loop;

      l_flex_delimiter := FND_FLEX_EXT.Get_Delimiter
			    (application_short_name => 'SQLGL',
			     key_flex_code => 'GL#',
			     structure_number => p_flex_code);

      l_concat_segments := FND_FLEX_EXT.Concatenate_Segments
			     (n_segments => PSB_WS_ACCT1.g_num_segs,
			      segments => l_seg_val,
			      delimiter => l_flex_delimiter);

      if not FND_FLEX_KEYVAL.Validate_Segs
	(operation => 'FIND_COMBINATION',
	 appl_short_name => 'SQLGL',
	 key_flex_code => 'GL#',
	 structure_number => p_flex_code,
	 concat_segments => l_concat_segments) then

/* Bug No 2719865 Start */
	  if (g_first_ccid) then
  	    FND_MSG_PUB.Add;
	    g_first_ccid := FALSE;
	    message_token('PARAMETER', p_parameter_name);
	    message_token('CCID', l_concat_segments);
	    add_message('PSB', 'PSB_DISABLED_ACCT_PARAMETER');
	  end if;

	  if ((not l_ccid_defined) and (not g_first_ccid)) then
  	    FND_MSG_PUB.Add;
	    message_token('PARAMETER', p_parameter_name);
	    message_token('CCID', l_concat_segments);
	    add_message('PSB', 'PSB_DISABLED_ACCT_PARAMETER');
	  end if;
/* Bug No 2719865 End */

      else
      begin

	l_ccid := FND_FLEX_KEYVAL.Combination_ID;

	l_ytd_amount:=Compute_Line_Total(
                        p_worksheet_id => p_worksheet_id,
			p_flex_mapping_set_id => p_flex_mapping_set_id,
			p_budget_calendar_id => p_budget_calendar_id,
			p_ccid => l_ccid,
			p_budget_year_type_id =>c_Formula_Rec.budget_year_type_id,
			p_balance_type => c_Formula_Rec.balance_type,
			p_currency_code => c_Formula_Rec.currency_code,
			p_service_package_id => p_service_package_id,
			/* bug no 4256345 */
			p_stage_set_id        => p_stage_set_id,
			p_current_stage_seq   => p_current_stage_seq
			/* bug no 4256345 */);

        /* Bug 3499337 start */
        -- Reset the l_ytd_amount to 0 when no line found
        if l_ytd_amount = FND_API.G_MISS_NUM OR l_ytd_amount IS NULL then
          l_ytd_amount := 0;
        end if;

        -- Comment out the following condition since the case will never existed.
  	-- if l_ytd_amount <> FND_API.G_MISS_NUM then
	-- begin
        /* Bug 3499337 end */

	  l_ccid_found := TRUE;

	  if c_Formula_Rec.postfix_operator = '+' then
	    l_line_total := l_ytd_amount + c_Formula_Rec.amount;
	  elsif c_Formula_Rec.postfix_operator = '-' then
	    l_line_total := l_ytd_amount - c_Formula_Rec.amount;
	  elsif c_Formula_Rec.postfix_operator = '*' then
	  begin

	    l_line_total := l_ytd_amount * c_Formula_Rec.amount;

	    if FND_API.to_Boolean(p_compound_annually) then
	      l_compound_total := l_ytd_amount * POWER(c_Formula_Rec.amount, p_compound_factor);
	    end if;

	  end;
	  elsif c_Formula_Rec.postfix_operator = '/' then
	  begin

	    -- Avoid a divide-by-zero error

	    if c_Formula_Rec.amount = 0 then
	      l_line_total := 0;
	    else
	      l_line_total := l_ytd_amount / c_Formula_Rec.amount;
	    end if;

	  end;
	  else
	    l_line_total := l_ytd_amount;
	  end if;

        -- Bug 3499337: Comment out the following lines.
        -- end;
	-- end if;

	-- If YTD Balance for the dependent CCID is not computed as yet, populate the structures
	-- for the deferred CCIDs

	if ((not l_ccid_found) and
	    (FND_API.to_Boolean(p_defer_ccids))) then
	begin

	  if not l_deferred then
	    l_deferred := TRUE;
	  end if;

	  if l_first_time then
	  begin

	    l_first_time := FALSE;

	    g_num_defccids := g_num_defccids + 1;

	    g_deferred_ccids(g_num_defccids).budget_group_id := p_budget_group_id;
	    g_deferred_ccids(g_num_defccids).num_proposed_years := p_num_proposed_years;
	    g_deferred_ccids(g_num_defccids).ccid := p_ccid;
	    g_deferred_ccids(g_num_defccids).ccid_start_period := p_ccid_start_period;
	    g_deferred_ccids(g_num_defccids).ccid_end_period := p_ccid_end_period;

	  end;
	  end if;

	  g_num_depccids := g_num_depccids + 1;

	  g_dependent_ccids(g_num_depccids).ccid := p_ccid;
	  g_dependent_ccids(g_num_depccids).dependent_ccid := l_ccid;

	end;
	end if;

      end;
      end if;

    end;
    elsif l_type3 then
      l_line_total := c_Formula_Rec.amount;
    end if;

    if c_Formula_Rec.prefix_operator = '=' then
      g_running_total := l_line_total;
    elsif c_Formula_Rec.prefix_operator = '+' then
      g_running_total := g_running_total + l_line_total;
    elsif c_Formula_Rec.prefix_operator = '-' then
      g_running_total := g_running_total - l_line_total;
    elsif c_Formula_Rec.prefix_operator = '*' then
      g_running_total := g_running_total * l_line_total;
    elsif c_Formula_Rec.prefix_operator = '/' then
    begin

      -- Avoid divide-by-zero error

      if l_line_total = 0 then
	g_running_total := 0;
      else
	g_running_total := g_running_total / l_line_total;
      end if;

    end;
    end if;

  end loop;

  -- Compound Annually is applicable only for a single line Type1 or Type2 Formula

  if ((l_num_lines = 1) and
     ((l_type1) or (l_type2)) and
      (FND_API.to_Boolean(p_compound_annually))) then
    g_running_total := l_compound_total;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;
  p_deferred := l_deferred;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Process_Parameter');
     end if;

END Process_Parameter;

/* ----------------------------------------------------------------------- */

-- Check if parameter exists for account for this period

FUNCTION AccParam_Exists
(p_parameter_id        NUMBER,
 p_ccid                NUMBER,
 p_year_start_date     DATE,
 p_year_end_date       DATE
) RETURN BOOLEAN IS

  l_parameter_exists   BOOLEAN := FALSE;

  /* Bug 3543845: Eliminate PSB_SET_RELATIONS_V */

/*Bug:5753424:modified the cursor as Local params moved to parameter set.
  Hence, psb_entity table may not have effective_start_date get populated
  in case of parameter sets. Used psb_entity_assignment for effective_start_date
  of the params. */

  cursor c_Exists is
    select 'Exists'
      from PSB_ENTITY a,
           psb_entity_assignment pea  --bug:5753424
     where a.entity_id = p_parameter_id
       and a.entity_id = pea.entity_id  --bug:5753424
       and exists
       /*bug:5753424:modified a.effective_start_date and a.effective_end_date to
          pea.effective_start_date and pea.effective_end_date*/
	  (select 1
	     from PSB_SET_RELATIONS b,
		  PSB_BUDGET_ACCOUNTS c
	    where b.account_position_set_id = c.account_position_set_id
	      and b.parameter_id = p_parameter_id
	      and c.code_combination_id = p_ccid)
       and a.entity_subtype = 'ACCOUNT'
       and (((pea.effective_start_date <= p_year_end_date)
	 and (pea.effective_end_date is null))
	 or ((pea.effective_start_date between p_year_start_date and p_year_end_date)
	  or (pea.effective_end_date between p_year_start_date and p_year_end_date)
	  or ((pea.effective_start_date < p_year_start_date)
	  and (pea.effective_end_date > p_year_end_date))));
BEGIN

  for c_Exists_Rec in c_Exists loop
    l_parameter_exists := TRUE;
  end loop;

  return l_parameter_exists;

END AccParam_Exists;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Revise_Account_Projections                 |
 +===========================================================================*/
--
-- Revise Projections for Line Items by applying account parameter
--
PROCEDURE Revise_Account_Projections
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_parameter_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30) := 'Revise_Account_Projections';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_return_status          VARCHAR2(1);

  l_budget_group_id        NUMBER;
  l_budget_calendar_id     NUMBER;
  l_flex_mapping_set_id    NUMBER;
  l_budget_by_position     BOOLEAN;
  l_flex_code              NUMBER;

  l_parameter_name         VARCHAR2(30);
  l_currency_code          VARCHAR2(15);
  l_effective_start_date   DATE;
  l_effective_end_date     DATE;

  l_parameter_exists       BOOLEAN;
  l_code_combination_id    NUMBER;
  l_ccid_type              VARCHAR2(30);

  l_compound_annually      VARCHAR2(1);
  l_compound_factor        NUMBER;

  l_deferred               BOOLEAN;

  l_init_index             PLS_INTEGER;

  l_year_start_date        DATE;
  l_year_end_date          DATE;
  l_gl_cutoff_period       DATE;

  -- Bug#1584464: Added
  l_note                   VARCHAR2(4000); -- Bug#4571412

  /* start bug no 4256345 */
  l_stage_set_id        NUMBER;
  l_current_stage_seq   NUMBER;
  /* start bug no 4256345 */

  /*bug:9442482:start*/
  l_actline_exists      BOOLEAN;
  l_global_ws_id        NUMBER;
  l_aln_id              NUMBER;
  l_account_line_id     NUMBER;
  l_rounding_factor     NUMBER;
  l_func_currency       VARCHAR2(20);
  l_aln_currency_code   VARCHAR2(20);
  l_allocrule_set_id      NUMBER;
  l_root_budget_group_id  NUMBER;
  l_ccid_budget_group_id  NUMBER;
  l_sprec_exists          BOOLEAN;
  /*bug:9442482:end*/

  cursor c_WS is
    select a.budget_group_id, a.budget_calendar_id, a.flex_mapping_set_id,
	   a.budget_by_position, nvl(b.chart_of_accounts_id, b.root_chart_of_accounts_id) chart_of_accounts_id,
           a.gl_cutoff_period,
	   /* bug no 4256345 */
           a.stage_set_id,
           a.current_stage_seq,
           /* bug no 4256345 */
           /*bug:9442482:start*/
           a.global_worksheet_id,
           a.rounding_factor,
           nvl(b.currency_code, b.root_currency_code) currency_code,
           a.allocrule_set_id,
           nvl(b.root_budget_group_id, b.budget_group_id) root_budget_group_id
           /*bug:9442482:end*/
      from PSB_WORKSHEETS_V a,
	   PSB_BUDGET_GROUPS_V b
     where a.worksheet_id = p_worksheet_id
       and b.budget_group_id = a.budget_group_id;

 /*Bug:5753424: modified the cursor c_parameter to fetch effective_start_date
   and effective_end_date from psb_entity_assignment instead of psb_entity*/

  cursor c_Parameter is
    select pe.name,
	   pe.currency_code,
	   pea.effective_start_date,
	   pea.effective_end_date,
	   pe.parameter_compound_annually
      from PSB_ENTITY pe,
           psb_entity_assignment pea
     where pe.entity_id = p_parameter_id
       and pea.entity_id = pe.entity_id
       and pe.entity_subtype = 'ACCOUNT';

/*bug:9442482:start*/
 CURSOR c_ccids IS
 select c.code_combination_id,
        pbp.start_date,
        pbp.end_date,
        pbp.budget_period_id budget_year_id,
        pbp.budget_year_type_id,
        pbyt.year_category_type,
        psp.service_package_id,
        a.currency_code,
        pbp.name,
        psp.base_service_package
  from  PSB_SET_RELATIONS b,
        PSB_BUDGET_ACCOUNTS c,
        psb_entity a,
        psb_budget_periods pbp,
        psb_worksheets_v pw,
        psb_service_packages psp,
        (select rownum propyearnum,
                budget_year_type_id,
                year_category_type
           from psb_budget_year_types
          where year_category_type IN ('CY','PP')
          order by sequence_number) pbyt
  where b.account_position_set_id = c.account_position_set_id
    and b.parameter_id = p_parameter_id
    and a.entity_id = b.parameter_id
    and a.entity_subtype = 'ACCOUNT'
    and pw.budget_calendar_id = pbp.budget_calendar_id
   and psp.global_worksheet_id = nvl(l_global_ws_id,p_worksheet_id)
    and pbp.budget_period_type = 'Y'
    and pw.worksheet_id = p_worksheet_id
    and pbp.budget_year_type_id = pbyt.budget_year_type_id
    and pbyt.propyearnum <= (pw.num_proposed_years + 1);


  CURSOR c_AcctLine(p_ccid               NUMBER,
                    p_budget_year_id     NUMBER,
                    p_service_package_id NUMBER,
                    p_budget_group_id    NUMBER,
                    p_currency_code      VARCHAR2) IS
  select   b.account_line_id,
           b.code_combination_id,
           b.service_package_id,
           b.budget_group_id,
           b.budget_year_id,
           b.currency_code,
	   c.start_date,
           c.end_date,
           b.note_id,
           d.year_category_type,
           c.name -- Bug#4571412
      FROM PSB_WS_LINES a,
           PSB_WS_ACCOUNT_LINES b,
           PSB_BUDGET_PERIODS c,
           PSB_BUDGET_YEAR_TYPES d
     WHERE a.worksheet_id        = p_worksheet_id
       AND b.account_line_id     = a.account_line_id
       AND b.code_combination_id = p_ccid
       AND b.budget_year_id    = p_budget_year_id
       AND b.end_stage_seq is null
       AND b.balance_type        = 'E'
       AND b.template_id is null
       AND c.budget_period_id    = b.budget_year_id
       AND c.budget_year_type_id = d.budget_year_type_id
       AND b.currency_code       = nvl(p_currency_code, l_func_currency)
       AND b.service_package_id  = p_service_package_id
       AND b.budget_group_id     = p_budget_group_id
       AND c.budget_period_type  = 'Y'
  ORDER BY b.code_combination_id,
           b.budget_year_id;

    CURSOR c_budget_group(p_code_combination_id NUMBER) IS
    select a.budget_group_id,
	   c.code_combination_id
      from PSB_SET_RELATIONS a,
	   PSB_BUDGET_GROUPS b,
	   PSB_BUDGET_ACCOUNTS c
     where a.budget_group_id = b.budget_group_id
       and b.budget_group_type = 'R'
       and ((b.budget_group_id = l_root_budget_group_id) or
	    (b.root_budget_group_id = l_root_budget_group_id))
       and a.account_position_set_id = c.account_position_set_id
       and c.code_combination_id=p_code_combination_id;

    CURSOR c_sp_line_exists(p_service_package_id NUMBER,
                            p_code_combination_id NUMBER,
                            p_currency_code       VARCHAR2) IS
    select 1
    from   psb_ws_account_lines a,
           psb_ws_lines b
    where  a.service_package_id = p_service_package_id
    and    a.code_combination_id = p_code_combination_id
    and    a.account_line_id    = b.account_line_id
    and    b.worksheet_id       = p_worksheet_id
    and    a.end_stage_seq is null
    and    a.template_id is null
    and    a.currency_code       = nvl(p_currency_code, l_func_currency);

  /*bug:9442482:end*/
  --
BEGIN

   /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVWA2B/Revise_Account_Projections',
    'BEGIN Revise_Account_Projections');
   fnd_file.put_line(fnd_file.LOG,'BEGIN Revise_Account_Projections');
   end if;
   /*end bug:5753424:end procedure level log*/


  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  for c_WS_Rec in c_WS loop
    l_budget_group_id       := c_WS_Rec.budget_group_id;
    l_budget_calendar_id    := c_WS_Rec.budget_calendar_id;
    l_flex_mapping_set_id   := c_WS_Rec.flex_mapping_set_id;
    l_flex_code             := c_WS_Rec.chart_of_accounts_id;

    /* bug no 4256345 */
    l_stage_set_id          := c_WS_Rec.stage_set_id;
    l_current_stage_seq     := c_WS_Rec.current_stage_seq;
    /* bug no 4256345 */

    /*bug:9442482:start*/
    l_global_ws_id          := c_WS_Rec.global_worksheet_id;
    l_rounding_factor       := c_WS_Rec.rounding_factor;
    l_func_currency         := c_WS_Rec.currency_code;
    l_allocrule_set_id      := c_WS_Rec.allocrule_set_id;
    l_root_budget_group_id  := c_WS_Rec.root_budget_group_id;
    /*bug:9442482:end*/


    -- Bug#3237740: Added the following.
    l_gl_cutoff_period      := c_WS_Rec.gl_cutoff_period;

    if c_WS_Rec.budget_by_position = 'Y' then
      l_budget_by_position := TRUE;
    else
      l_budget_by_position := FALSE;
    end if;

  end loop;

 /*Bug:9442482:start*/

  -- Create Zero Balances Profile Option
  if g_create_zero_bal is null then

    FND_PROFILE.GET
       (name => 'PSB_CREATE_ZERO_BALANCE_ACCT',
	val => g_create_zero_bal);

    if g_create_zero_bal is null then
      -- Bug 3548345: Change default behavior to not creating zero balance
      g_create_zero_bal := 'N';
    end if;

  end if;

  if l_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id,
                                 FND_API.G_MISS_NUM)
  then

    PSB_WS_ACCT1.Cache_Budget_Calendar
    ( p_return_status      => l_return_status,
      p_budget_calendar_id => l_budget_calendar_id
    ) ;

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end if;


/*Bug:9442482:end*/

  for c_Parameter_Rec in c_Parameter loop
    l_parameter_name := c_Parameter_Rec.name;
    l_currency_code := c_Parameter_Rec.currency_code;
    l_effective_start_date := c_Parameter_Rec.effective_start_date;
    l_effective_end_date := c_Parameter_Rec.effective_end_date;

    if nvl(c_Parameter_Rec.parameter_compound_annually, 'N') = 'N' then
      l_compound_annually := FND_API.G_FALSE;
    else
      l_compound_annually := FND_API.G_TRUE;
    end if;
  end loop;

  for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    g_period_amount(l_init_index) := 0; --bug:9442482:assigned '0' instead of null
  end loop;

/*bug:9442482:start*/
  for c_ccid_rec in c_ccids loop
      l_aln_currency_code := null;
      l_actline_exists := FALSE;
      l_aln_id         := NULL;

      for l_init_index in 1..g_alloc_periods.Count loop
	g_alloc_periods(l_init_index).budget_period_id := null;
	g_alloc_periods(l_init_index).long_sequence_no := null;
	g_alloc_periods(l_init_index).start_date := null;
	g_alloc_periods(l_init_index).end_date := null;
	g_alloc_periods(l_init_index).budget_year_id := null;
      end loop;

      l_init_index := 1;

      for l_period_index in 1..PSB_WS_ACCT1.g_num_budget_periods loop

	if PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id = c_ccid_rec.budget_year_id
        then

	  -- Periods over which to allocate should include all Budget Periods
          -- in the PP Budget Years and all Budget Periods upto the GL Cutoff
          -- Period in the CY Budget Year

	  if ((c_ccid_rec.year_category_type IN ('CY','PP')) and
	     ((l_gl_cutoff_period is null) or
	      (l_gl_cutoff_period < PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date))) then

	    g_alloc_periods(l_init_index).budget_period_id :=
               PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_id;
	    g_alloc_periods(l_init_index).long_sequence_no :=
               PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no;
	    g_alloc_periods(l_init_index).start_date :=
               PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    g_alloc_periods(l_init_index).end_date :=
               PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	    g_alloc_periods(l_init_index).budget_year_id :=
               PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id;

	    l_init_index := l_init_index + 1;
	  end if;

	end if;

      end loop; /* Budget Period */

   for l_budget_rec in c_budget_group(c_ccid_rec.code_combination_id) loop
      l_ccid_budget_group_id := l_budget_rec.budget_group_id;
   end loop;

   l_sprec_exists := FALSE;

   IF c_ccid_rec.base_service_package = 'N' THEN
      for l_sp_rec in c_sp_line_exists(c_ccid_rec.service_package_id,
                                       c_ccid_rec.code_combination_id,
                                       c_ccid_rec.currency_code) loop

            l_sprec_exists := TRUE;
      end loop;
   END IF;


   for c_AcctLine_Rec in c_AcctLine(c_ccid_rec.code_combination_id,
                                    c_ccid_rec.budget_year_id,
                                    c_ccid_rec.service_package_id,
                                    l_ccid_budget_group_id,
                                    c_ccid_rec.currency_code) loop

       l_aln_currency_code  := c_AcctLine_Rec.currency_code;
       l_actline_exists     := TRUE;
       l_aln_id             := c_AcctLine_Rec.account_line_id;
   end loop;
   /*bug:9442482:end*/

    /* Bug 3570461 Start */
    IF l_aln_currency_code = l_currency_code
       OR l_currency_code IS NULL OR
       (NOT l_actline_exists)           --bug:9442482
       THEN
    /* Bug 3570461 End */

    /*Bug:9442482:Replaced references of c_acctline_rec with
     c_ccid_rec wherever required in the rest of the api code */

    if c_ccid_rec.code_combination_id <> nvl(l_code_combination_id, 0) then
    begin

      l_code_combination_id := c_ccid_rec.code_combination_id;

      PSB_WS_ACCT1.Check_CCID_Type
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_ccid_type => l_ccid_type,
	  p_flex_code => l_flex_code,
	  p_ccid => c_ccid_rec.code_combination_id,
	  p_budget_group_id => l_budget_group_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

    l_parameter_exists := AccParam_Exists
                          ( p_parameter_id => p_parameter_id,
                            p_ccid => c_ccid_rec.code_combination_id,
                            p_year_start_date => c_ccid_rec.start_date,
                            p_year_end_date => c_ccid_rec.end_date ) ;

    /* Bug 3237740 Start */
    IF  (c_ccid_rec.year_category_type = 'CY'
         AND  c_ccid_rec.end_date <> l_gl_cutoff_period )
      OR
        (c_ccid_rec.year_category_type = 'PP')
    THEN
    /* Bug 3237740 End */

    if ((l_parameter_exists) and
       (((l_ccid_type <> 'PERSONNEL_SERVICES') and (l_budget_by_position))
       or (not(l_budget_by_position))))
    then

      -- Compute Compound Factor for each year if Compound Annually is set.
      if FND_API.to_Boolean(l_compound_annually) then
        --
        /* Bug No 2627277 Start */
        -- l_compound_factor := greatest(ceil(months_between(l_year_start_date, l_effective_start_date) / 12), 0) + 1;
	l_compound_factor := greatest(ceil(months_between(c_ccid_rec.start_date, l_effective_start_date) / 12), 0) + 1;
        /* Bug No 2627277 End */
        --
      end if;

   /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWA2B/Revise_Account_Projections',
    'Before call - Process_Parameter for parameter:'||p_parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call - Process_Parameter for parameter:'||p_parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

      -- Parse Parameter Formulae and compute a YTD running total to allocate
      -- across Budget Periods
      Process_Parameter
	     (p_worksheet_id => p_worksheet_id,
	      p_service_package_id => c_ccid_rec.service_package_id,
	      p_parameter_id => p_parameter_id,
	      p_parameter_name => l_parameter_name,
	      p_compound_annually => l_compound_annually,
	      p_compound_factor => l_compound_factor,
	      p_budget_calendar_id => l_budget_calendar_id,
	      p_flex_code => l_flex_code,
	      p_flex_mapping_set_id => l_flex_mapping_set_id,
	      p_ccid => c_ccid_rec.code_combination_id,
	      p_ccid_start_period => c_ccid_rec.start_date,
	      p_ccid_end_period => c_ccid_rec.end_date,
	      p_budget_group_id => l_ccid_budget_group_id,
	      p_num_proposed_years => null,
	      p_return_status => l_return_status,
	      p_defer_ccids => FND_API.G_FALSE,
	      p_deferred => l_deferred,
	      /* bug no 4256345 */
              p_stage_set_id          => l_stage_set_id,
	      p_current_stage_seq     => l_current_Stage_seq
  	      /* bug no 4256345 */);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      -- Create Account Distribution for the CCID
    IF l_actline_exists THEN           --bug:9442482
      PSB_WS_ACCT1.Create_Account_Dist
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_distribute_flag => FND_API.G_TRUE,
	  p_account_line_id => l_aln_id,
	  p_ytd_amount => g_running_total,
	  p_period_amount => g_period_amount,
	  p_budget_group_id => l_ccid_budget_group_id);

    /*Bug:9442482:start*/
    ELSIF    ( g_running_total <> 0
               or
               (g_running_total = 0 and g_create_zero_bal = 'Y')
             ) THEN

          IF ((c_ccid_rec.base_service_package = 'Y') OR
             (l_sprec_exists and c_ccid_rec.base_service_package = 'N')) THEN

            Distribute_Account_Lines
            ( p_return_status => l_return_status,
              p_worksheet_id => p_worksheet_id,
              p_flex_mapping_set_id => l_flex_mapping_set_id,
              p_budget_year_type_id => c_ccid_rec.budget_year_type_id,
              p_allocrule_set_id => l_allocrule_set_id,
              p_budget_calendar_id => l_budget_calendar_id,
              p_ccid => c_ccid_rec.code_combination_id,
              p_ytd_amount => g_running_total,
              -- Bug#3401175: Defaulting currency code to functional currency.
              p_currency_code => NVL(l_currency_code, l_func_currency),
              p_allocation_type => null,
              -- Bug#2342169: Added the following parameter.
              p_rounding_factor => l_rounding_factor,
              p_effective_start_date => c_ccid_rec.start_date,
              p_effective_end_date => c_ccid_rec.end_date,
              p_budget_periods => g_alloc_periods,
              p_period_amount => g_period_amount
            ) ;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
            END IF;

	  PSB_WS_ACCT1.Create_Account_Dist
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_account_line_id => l_account_line_id,
	      p_worksheet_id => p_worksheet_id,
	      p_service_package_id => c_ccid_rec.service_package_id,
	      p_check_spal_exists => FND_API.G_FALSE,
	      p_gl_cutoff_period => null,
	      p_allocrule_set_id => null,
	      p_budget_calendar_id => null,
	      p_rounding_factor => l_rounding_factor,
	      p_stage_set_id => l_stage_set_id,
	      p_start_stage_seq => l_current_Stage_seq,
	      p_current_stage_seq => l_current_Stage_seq,
	      p_budget_group_id => l_ccid_budget_group_id,
	      p_budget_year_id => c_ccid_rec.budget_year_id,
	      p_flex_mapping_set_id => l_flex_mapping_set_id,
	      p_map_accounts => TRUE,
	      p_ccid => c_ccid_rec.code_combination_id,
	      p_currency_code => nvl(l_currency_code, l_func_currency),
	      p_balance_type => 'E',
	      p_ytd_amount => g_running_total,
	      p_period_amount => g_period_amount);

           if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         	raise FND_API.G_EXC_ERROR;
          end if;
	 END IF;
    END IF;
    /* Bug:9442482:end */

      /* Bug No 1584464 Start */
      -- Insert note record in PSB_WS_ACCOUNT_LINE_NOTES table
      FND_MESSAGE.SET_NAME('PSB', 'PSB_PARAMETER_NOTE_CREATION');
      FND_MESSAGE.SET_TOKEN('NAME', l_parameter_name);
      FND_MESSAGE.SET_TOKEN('DATE', sysdate);
      l_note := FND_MESSAGE.GET;

      -- Bug#4571412
      -- Added parameters to make the call in
      -- sync wih it's definition.
      PSB_WS_ACCT1.Create_Note
      ( p_return_status         => l_return_status,
        p_account_line_id       => NVL(l_aln_id,l_account_line_id),
        p_note                  => l_note,
        p_chart_of_accounts_id  => l_flex_code,
        p_budget_year           => c_ccid_rec.Name,
        p_cc_id                 => c_ccid_rec.code_combination_id,
        p_concatenated_segments => NULL
      ) ;

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;
      /* Bug No 1584464 End */

    end if;

    END IF;
    END IF;

  end loop;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

   /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVWA2B/Revise_Account_Projections',
    'END Revise_Account_Projections');
   fnd_file.put_line(fnd_file.LOG,'END Revise_Account_Projections');
   end if;
   /*end bug:5753424:end procedure level log*/

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Revise_Account_Projections;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Apply_Account_Parameters                   |
 +===========================================================================*/
--
-- Apply Account Parameters for a CCID for the CY and PP Budget Years
--
PROCEDURE Apply_Account_Parameters
( p_api_version            IN   NUMBER,
  p_validation_level       IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id           IN   NUMBER,
  p_service_package_id     IN   NUMBER,
  p_start_stage_seq        IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq      IN   NUMBER,
  p_rounding_factor        IN   NUMBER := FND_API.G_MISS_NUM,
  p_stage_set_id           IN   NUMBER,
  p_budget_group_id        IN   NUMBER,
  p_allocrule_set_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_gl_cutoff_period       IN   DATE := FND_API.G_MISS_DATE,
  p_flex_code              IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_flex_mapping_set_id    IN   NUMBER := FND_API.G_MISS_NUM,
  p_ccid                   IN   NUMBER,
  p_ccid_start_period      IN   DATE,
  p_ccid_end_period        IN   DATE,
  p_num_proposed_years     IN   NUMBER,
  p_num_years_to_allocate  IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_set_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_by_position     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_defer_ccids            IN   VARCHAR2 := FND_API.G_TRUE
) IS

  l_api_name               CONSTANT VARCHAR2(30) := 'Apply_Account_Parameters';
  l_api_version            CONSTANT NUMBER       := 1.0;

  l_return_status          VARCHAR2(1);
  l_init_index             PLS_INTEGER;
  l_year_index             PLS_INTEGER;
  l_period_index           PLS_INTEGER;
  l_num_budget_years       NUMBER;
  l_num_proposed_years     NUMBER := 0;

  -- Bug 3543845
  l_global_worksheet_id    NUMBER;

  l_allocrule_set_id       NUMBER;
  l_flex_mapping_set_id    NUMBER;
  l_parameter_set_id       NUMBER;
  l_budget_calendar_id     NUMBER;
  l_rounding_factor        NUMBER;
  l_gl_cutoff_period       DATE;
  l_num_years_to_allocate  NUMBER;
  l_budget_by_position     VARCHAR2(1);

  /* Bug No 2640277 Start */
  l_year_start_date        DATE;
  l_year_end_date          DATE;
  /* Bug No 2640277 End */

  l_func_currency          VARCHAR2(15);
  l_flex_code              NUMBER;

  l_start_stage_seq        NUMBER;
  l_num_allocated_years    NUMBER := 0;
  l_currency_code          VARCHAR2(15);
  l_compound_annually      VARCHAR2(1);
  l_allocation_type        VARCHAR2(10);
  l_compound_factor        NUMBER;
  l_account_line_id        NUMBER;
  l_include_calc_periods   VARCHAR2(1);
  l_mapped_ccid            NUMBER;
  l_deferred               BOOLEAN;
  -- bug 4308904
  l_ccid_param_exists	   BOOLEAN;

  -- Local variable to determine whether at least a parameter exists for the
  -- account code being processed.
  l_cy_parameter_exists    BOOLEAN := FALSE;

  /* Bug 3543845: Comment out since the query is spilted into two in the body
  cursor c_WS is
    select nvl(allocrule_set_id, global_allocrule_set_id) allocrule_set_id,
	   flex_mapping_set_id,
	   parameter_set_id,
	   budget_calendar_id,
	   rounding_factor,
	   gl_cutoff_period,
	   num_years_to_allocate,
	   budget_by_position
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;
  */

  cursor c_SOB is
    select nvl(currency_code, root_currency_code) currency_code,
	   nvl(chart_of_accounts_id, root_chart_of_accounts_id) chart_of_accounts_id
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = p_budget_group_id;

  -- Find all Parameters that are applicable for this CCID for the Budget Year
  -- identified by Year_Start_Date, Year_End_Date. The CCID should be valid for
  -- the duration of the parameter. Parameters are sorted by the Parameter Start
  -- Date and Priority within a Budget Year

  -- Bug 3543845: Avoid using PSB_SET_RELATIONS_V
  cursor c_Parameter (Year_Start_Date DATE,
                      Year_End_Date DATE) is
    select parameter_id,
           name,
           priority,
           currency_code,
           effective_start_date,
           parameter_compound_annually
      from PSB_PARAMETER_ASSIGNMENTS_V a
     where exists
           (select 1
            from   PSB_SET_RELATIONS b,
                   PSB_BUDGET_ACCOUNTS c
            where  b.account_position_set_id = c.account_position_set_id
                   and b.parameter_id = a.parameter_id
                   and c.code_combination_id = p_ccid
           )
           and parameter_type = 'ACCOUNT'
           and ( ( effective_start_date
                   <= nvl(p_ccid_end_period, Year_End_Date)
                   and effective_end_date is null
                 )
                 or ( ( effective_start_date
                        between nvl(p_ccid_start_period, Year_Start_Date)
                        and nvl(p_ccid_end_period, Year_End_Date)
                      )
                      or
                      ( effective_end_date
                        between nvl(p_ccid_start_period, Year_Start_Date)
                        and nvl(p_ccid_end_period, Year_End_Date)
                      )
                      or
                      ( effective_start_date
                        < nvl(p_ccid_start_period, Year_Start_Date)
                      and
                      effective_end_date
                      > nvl(p_ccid_end_period, Year_End_Date)
                    )
                 )
               )
           and ( ( effective_start_date <= Year_End_Date
                   and effective_end_date is null)
                 or
                 ( ( effective_start_date
                     between Year_Start_Date and Year_End_Date
                   )
                   or ( effective_end_date
                        between Year_Start_Date and Year_End_Date
                      )
                   or ( effective_start_date < Year_Start_Date
                        and effective_end_date > Year_End_Date
                      )
                 )
               )
           and parameter_set_id = l_parameter_set_id
     order by effective_start_date, priority;
BEGIN

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Select default values for input parameters that were not passed in
  if ((p_allocrule_set_id = FND_API.G_MISS_NUM) or
      (p_flex_mapping_set_id = FND_API.G_MISS_NUM) or
      (p_parameter_set_id = FND_API.G_MISS_NUM) or
      (p_budget_calendar_id = FND_API.G_MISS_NUM) or
      (p_rounding_factor = FND_API.G_MISS_NUM) or
      (p_gl_cutoff_period = FND_API.G_MISS_DATE) or
      (p_num_years_to_allocate = FND_API.G_MISS_NUM) or
      (p_budget_by_position = FND_API.G_MISS_CHAR))
  then
    /* Bug 3543845 start */
    /* comment out the following query and use cached value when possible
    for c_WS_Rec in c_WS loop
      l_allocrule_set_id := c_WS_Rec.allocrule_set_id;
      l_flex_mapping_set_id := c_WS_Rec.flex_mapping_set_id;
      l_parameter_set_id := c_WS_Rec.parameter_set_id;
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
      l_rounding_factor := c_WS_Rec.rounding_factor;
      l_gl_cutoff_period := c_WS_Rec.gl_cutoff_period;
      l_num_years_to_allocate := c_WS_Rec.num_years_to_allocate;
      l_budget_by_position := c_WS_Rec.budget_by_position;
    end loop;
    */
    -- Check the g_ws_creation_flag to determine whether to use the
    -- cached worksheet values.
    IF PSB_WORKSHEET.g_ws_creation_flag
       AND
       PSB_WORKSHEET.g_worksheet_id = p_worksheet_id
    THEN
      -- Retrieve the worksheet values from cache to avoiding extra query
      l_global_worksheet_id := PSB_WORKSHEET.g_global_worksheet_id;
      l_gl_cutoff_period := PSB_WORKSHEET.g_gl_cutoff_period;
      l_allocrule_set_id := PSB_WORKSHEET.g_allocrule_set_id;
      l_budget_calendar_id := PSB_WORKSHEET.g_budget_calendar_id;
      l_rounding_factor := PSB_WORKSHEET.g_rounding_factor;
      l_flex_mapping_set_id := PSB_WORKSHEET.g_flex_mapping_set_id;
      l_parameter_set_id := PSB_WORKSHEET.g_parameter_set_id;
      l_num_years_to_allocate := PSB_WORKSHEET.g_num_years_to_allocate;
      l_budget_by_position := PSB_WORKSHEET.g_budget_by_position;

    ELSE

      SELECT DECODE(global_worksheet_flag, 'Y', worksheet_id,
                    global_worksheet_id) global_worksheet_id
           INTO
             l_global_worksheet_id
      FROM   psb_worksheets
      WHERE  worksheet_id = p_worksheet_id;

      SELECT gl_cutoff_period,
             allocrule_set_id allocrule_set_id,
             budget_calendar_id,
             rounding_factor,
             flex_mapping_set_id,
             parameter_set_id,
             num_years_to_allocate,
             budget_by_position
           INTO
             l_gl_cutoff_period,
             l_allocrule_set_id,
             l_budget_calendar_id,
             l_rounding_factor,
             l_flex_mapping_set_id,
             l_parameter_set_id,
             l_num_years_to_allocate,
             l_budget_by_position
      FROM   psb_worksheets
      WHERE  worksheet_id = l_global_worksheet_id;

    END IF;
    /* Bug 3543845 End */
  end if;

  -- Substitute values from input parameters that were passed in

  if p_allocrule_set_id <> FND_API.G_MISS_NUM then
    l_allocrule_set_id := p_allocrule_set_id;
  end if;

  if p_flex_mapping_set_id <> FND_API.G_MISS_NUM then
    l_flex_mapping_set_id := p_flex_mapping_set_id;
  end if;

  if p_parameter_set_id <> FND_API.G_MISS_NUM then
    l_parameter_set_id := p_parameter_set_id;
  end if;

  if p_budget_calendar_id <> FND_API.G_MISS_NUM then
    l_budget_calendar_id := p_budget_calendar_id;
  end if;

  if p_rounding_factor <> FND_API.G_MISS_NUM then
    l_rounding_factor := p_rounding_factor;
  end if;

  if p_gl_cutoff_period <> FND_API.G_MISS_DATE then
    l_gl_cutoff_period := p_gl_cutoff_period;
  end if;

  if p_num_years_to_allocate <> FND_API.G_MISS_NUM then
    l_num_years_to_allocate := p_num_years_to_allocate;
  end if;

  if ((l_budget_by_position is null) or (l_budget_by_position = 'N')) then
    l_budget_by_position := FND_API.G_FALSE;
  else
    l_budget_by_position := FND_API.G_TRUE;
  end if;

  if p_budget_by_position <> FND_API.G_MISS_CHAR then
    l_budget_by_position := p_budget_by_position;
  end if;

  if ((p_func_currency = FND_API.G_MISS_CHAR) or
      (p_flex_code = FND_API.G_MISS_NUM))
  then

    for c_SOB_Rec in c_SOB loop
      l_func_currency := c_SOB_Rec.currency_code;
      l_flex_code := c_SOB_Rec.chart_of_accounts_id;
    end loop;

  end if;

  if p_func_currency <> FND_API.G_MISS_CHAR then
    l_func_currency := p_func_currency;
  end if;

  if p_flex_code <> FND_API.G_MISS_NUM then
    l_flex_code := p_flex_code;
  end if;

  if p_start_stage_seq = FND_API.G_MISS_NUM then
    l_start_stage_seq := p_current_stage_seq;
  else
    l_start_stage_seq := p_start_stage_seq;
  end if;

  -- Create Zero Balances Profile Option
  if g_create_zero_bal is null then

    FND_PROFILE.GET
       (name => 'PSB_CREATE_ZERO_BALANCE_ACCT',
	val => g_create_zero_bal);

    if g_create_zero_bal is null then
      -- Bug 3548345: Change default behavior to not creating zero balance
      g_create_zero_bal := 'N';
    end if;

  end if;

  if l_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id,
                                 FND_API.G_MISS_NUM)
  then

    PSB_WS_ACCT1.Cache_Budget_Calendar
    ( p_return_status      => l_return_status,
      p_budget_calendar_id => l_budget_calendar_id
    ) ;

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end if;

  -- Number of Budget Years to project
  l_num_budget_years := least(ceil(months_between(nvl(p_ccid_end_period, PSB_WS_ACCT1.g_end_est_date),
						  nvl(p_ccid_start_period, PSB_WS_ACCT1.g_startdate_pp)) / 12),
				nvl(p_num_proposed_years, PSB_WS_ACCT1.g_max_num_years));

  for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

    /* Bug No 2640277 Start */
    -- Following condition has been changed

    l_year_start_date := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
    l_year_end_date := PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;

    -- for bug 4308904
    l_ccid_param_exists := false;

    /*
    if ((PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP')) and
	(PSB_WS_ACCT1.g_budget_years(l_year_index).start_date >= nvl(p_ccid_start_period, PSB_WS_ACCT1.g_startdate_cy)) and
	(PSB_WS_ACCT1.g_budget_years(l_year_index).end_date <= nvl(p_ccid_end_period, PSB_WS_ACCT1.g_end_est_date)))  then
    */

    if (PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP'))
	    and (((nvl(p_ccid_start_period, PSB_WS_ACCT1.g_startdate_cy) between l_year_start_date and l_year_end_date)
	       or (nvl(p_ccid_end_period, PSB_WS_ACCT1.g_end_est_date) between l_year_start_date and l_year_end_date)
	       or ((nvl(p_ccid_start_period, PSB_WS_ACCT1.g_startdate_cy) < l_year_start_date)
		 and (nvl(p_ccid_end_period, PSB_WS_ACCT1.g_end_est_date) > l_year_end_date))))
    then
    /* Bug No 2640277 End */

    begin

      g_running_total := 0;

      for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
	g_period_amount(l_init_index) := null;
      end loop;

      for l_init_index in 1..g_alloc_periods.Count loop
	g_alloc_periods(l_init_index).budget_period_id := null;
	g_alloc_periods(l_init_index).long_sequence_no := null;
	g_alloc_periods(l_init_index).start_date := null;
	g_alloc_periods(l_init_index).end_date := null;
	g_alloc_periods(l_init_index).budget_year_id := null;
      end loop;

      l_init_index := 1;

      for l_period_index in 1..PSB_WS_ACCT1.g_num_budget_periods loop

	if PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id =
	   PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id
        then

	  -- Periods over which to allocate should include all Budget Periods
          -- in the PP Budget Years and all Budget Periods upto the GL Cutoff
          -- Period in the CY Budget Year

	  if ((PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'PP') or
	     ((PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'CY') and
	     ((l_gl_cutoff_period is null) or
	      (l_gl_cutoff_period < PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date))))
          then
	    g_alloc_periods(l_init_index).budget_period_id :=
               PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_id;
	    g_alloc_periods(l_init_index).long_sequence_no :=
               PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no;
	    g_alloc_periods(l_init_index).start_date :=
               PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    g_alloc_periods(l_init_index).end_date :=
               PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	    g_alloc_periods(l_init_index).budget_year_id :=
               PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id;

	    l_init_index := l_init_index + 1;
	  end if;

	end if;

      end loop; /* Budget Period */

      /* Bug 3603538 Start */
      IF PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'CY'
         AND
         l_year_end_date = l_gl_cutoff_period
      THEN
        FOR c_Parameter_Rec IN c_Parameter (PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
					    PSB_WS_ACCT1.g_budget_years(l_year_index).end_date) LOOP

          l_currency_code := c_Parameter_Rec.currency_code;

        END LOOP;

      END IF;
      /* Bug 3603538 End */

      IF PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'CY'
         AND
         l_year_end_date <> l_gl_cutoff_period
      THEN
         -- Added the above condition as part of Bug fix 3469514
      begin

	-- Find all CCIDs that are applicable for the CY
	for c_Parameter_Rec in c_Parameter (PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
					    PSB_WS_ACCT1.g_budget_years(l_year_index).end_date) loop
	  -- Set the local variable.
	  l_cy_parameter_exists := TRUE;

          -- for bug 4308904
          l_ccid_param_exists := TRUE;

	  l_currency_code := c_Parameter_Rec.currency_code;

	  -- Compute a Compound Factor for each Budget Year if Compound Annually is set

	  if ((c_Parameter_Rec.parameter_compound_annually is null) or
	      (c_Parameter_Rec.parameter_compound_annually = 'N')) then
	    l_compound_annually := FND_API.G_FALSE;
	     /*bug:7007854:start*/
	    l_compound_factor   := null;
	     /*bug:7007854:end*/
	  else
	    l_compound_annually := FND_API.G_TRUE;
	    l_compound_factor := greatest(ceil(months_between(PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
							      c_Parameter_Rec.effective_start_date) / 12), 0) + 1;
	  end if;

	  -- Parse the Parameter Formulae and compute a YTD running total to
          -- allocate across Budget Periods. If the CCID was deferred because
          -- of dependency on another yet-to-be-computed CCID, the parameter
          -- l_deferred is set to FND_API.G_TRUE

	  l_deferred := FALSE;

	  Process_Parameter
		 (p_worksheet_id => p_worksheet_id,
		  p_service_package_id => p_service_package_id,
		  p_parameter_id => c_Parameter_Rec.parameter_id,
		  p_parameter_name => c_Parameter_Rec.name,
		  p_compound_annually => l_compound_annually,
		  p_compound_factor => l_compound_factor,
		  p_budget_calendar_id => l_budget_calendar_id,
		  p_flex_code => l_flex_code,
		  p_flex_mapping_set_id => l_flex_mapping_set_id,
		  p_ccid => p_ccid,
		  p_ccid_start_period => p_ccid_start_period,
		  p_ccid_end_period => p_ccid_end_period,
		  p_budget_group_id => p_budget_group_id,
		  p_num_proposed_years => p_num_proposed_years,
		  p_return_status => l_return_status,
		  p_defer_ccids => p_defer_ccids,
		  p_deferred => l_deferred,
		  /* bug no 4256345 */
  		  p_stage_set_id          => p_stage_set_id,
  		  p_current_stage_seq     => p_current_stage_seq
          	 /* bug no 4256345 */);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  if l_deferred then
	    raise FND_API.G_EXC_ERROR;
	  end if;

          /* Bug 4308904 Start */
          -- Bug#3126462: Support Percent type allocation rules for CY estimates
          -- No need to hardcode allocation type to Profile. Process all types.
	  --l_allocation_type := 'PROFILE';
	  l_allocation_type := NULL;

	  /*bug:9224647:start*/
	  IF l_rounding_factor IS NOT NULL THEN
	     g_actuals_func_total := ROUND(g_actuals_func_total/l_rounding_factor) * l_rounding_factor;
	     g_actuals_stat_total := ROUND(g_actuals_stat_total/l_rounding_factor) * l_rounding_factor;
	  END IF;
          /*bug:9224647:end*/

	  -- Subtract the Actual Balances for the CY since g_running_total
          -- computes the Estimate Balance for the full year. Also, Estimate
          -- Balances for CY includes the Actual Balances upto GL Cutoff Period

	  IF l_cy_parameter_exists THEN
	  BEGIN

	    IF nvl(l_currency_code, p_func_currency) = p_func_currency THEN
	      g_running_total := g_running_total - nvl(g_actuals_func_total, 0);
	    ELSE
	      g_running_total := g_running_total - nvl(g_actuals_stat_total, 0);
	    END IF;

	  END;
	  END IF;



	-- If an Allocation Rule Set has been specified in the WS definition,
        -- distribute using the applicable Allocation Rule; otherwise, the YTD
        -- Amount is evenly distributed to the individual Period Amounts


        Distribute_Account_Lines
        ( p_return_status => l_return_status,
          p_worksheet_id => p_worksheet_id,
          p_flex_mapping_set_id => l_flex_mapping_set_id,
          p_budget_year_type_id =>
            PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_type_id,
          p_allocrule_set_id => l_allocrule_set_id,
          p_budget_calendar_id => l_budget_calendar_id,
          p_ccid => p_ccid,
          p_ytd_amount => g_running_total,
          -- Bug#3401175: Defaulting currency code to functional currency.
          p_currency_code => NVL(l_currency_code, l_func_currency),
          p_allocation_type => l_allocation_type,
          -- Bug#2342169: Added the following parameter.
          p_rounding_factor => l_rounding_factor,
          p_effective_start_date =>
            PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
          p_effective_end_date =>
            PSB_WS_ACCT1.g_budget_years(l_year_index).end_date,
          p_budget_periods => g_alloc_periods,
          p_period_amount => g_period_amount
        ) ;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
        END IF;

        -- Bug 3543845: Check whether the worksheet creation process is
        -- executed for the first time. If it is the first time, then check the
        -- running total and create zero balance profile. Otherwise, call the
        -- create_account_Dist without any filtering.
        IF ( PSB_WORKSHEET.g_ws_first_time_creation_flag
             and
             ( g_running_total <> 0
               or
               (g_running_total = 0 and g_create_zero_bal = 'Y')
             )
           )
           OR
           NOT PSB_WORKSHEET.g_ws_first_time_creation_flag
        THEN
        BEGIN



	  -- Create Account Distribution for the CCID
	  PSB_WS_ACCT1.Create_Account_Dist
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_account_line_id => l_account_line_id,
	      p_worksheet_id => p_worksheet_id,
	      p_service_package_id => p_service_package_id,
	      p_check_spal_exists => FND_API.G_FALSE,
	      p_gl_cutoff_period => null,
	      p_allocrule_set_id => null,
	      p_budget_calendar_id => null,
	      p_rounding_factor => l_rounding_factor,
	      p_stage_set_id => p_stage_set_id,
	      p_start_stage_seq => l_start_stage_seq,
	      p_current_stage_seq => p_current_stage_seq,
	      p_budget_group_id => p_budget_group_id,
	      p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
	      p_flex_mapping_set_id => l_flex_mapping_set_id,
	      p_map_accounts => TRUE,
	      p_ccid => p_ccid,
	      p_currency_code => nvl(l_currency_code, l_func_currency),
	      p_balance_type => 'E',
	      p_ytd_amount => g_running_total,
	      p_period_amount => g_period_amount);

	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    raise FND_API.G_EXC_ERROR;
	  END IF;

        END;
	END IF;



        IF nvl(l_flex_mapping_set_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
        BEGIN

	l_mapped_ccid := PSB_WS_ACCT1.Map_Account
			    (p_flex_mapping_set_id => l_flex_mapping_set_id,
			     p_ccid => p_ccid,
			     p_budget_year_type_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_type_id);

        END;
        ELSE
          l_mapped_ccid := p_ccid;
        END IF;

        PSB_WS_ACCT1.Copy_CY_Estimates
	   (p_return_status => l_return_status,
	    p_worksheet_id => p_worksheet_id,
	    p_service_package_id => p_service_package_id,
	    p_rounding_factor => l_rounding_factor,
	    p_start_stage_seq => p_current_stage_seq,
	    p_budget_group_id => p_budget_group_id,
	    p_stage_set_id => p_stage_set_id,
	    p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
	    p_ccid => l_mapped_ccid,
	    p_currency_code => nvl(l_currency_code, l_func_currency));

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  raise FND_API.G_EXC_ERROR;
        END IF;

        /* Bug 4308904 End */

	END LOOP;

        IF l_ccid_param_exists THEN
          l_num_allocated_years := l_num_allocated_years + 1;
        END IF;

        END;

      -- If Pos Budgeting is enabled, CCID is of type 'NON_PERSONNEL_SERVICES'

      ELSIF (PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'PP') THEN
      BEGIN

	IF l_num_proposed_years < l_num_budget_years THEN
	BEGIN

	  -- Find all Parameters that are applicable for the PP Budget Year

	  for c_Parameter_Rec in c_Parameter (PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
					      PSB_WS_ACCT1.g_budget_years(l_year_index).end_date) loop

	    l_currency_code := c_Parameter_Rec.currency_code;

            -- for bug 4308904
            l_ccid_param_exists := TRUE;

	    -- Compute a Compound Factor for the PP Budget Year if Compound Annually is set

	    IF ((c_Parameter_Rec.parameter_compound_annually is null) or
		(c_Parameter_Rec.parameter_compound_annually = 'N')) THEN
	      l_compound_annually := FND_API.G_FALSE;
	       /*bug:7007854:start*/
	      l_compound_factor   := null;
	       /*bug:7007854:end*/
	    ELSE
	      l_compound_annually := FND_API.G_TRUE;
	      l_compound_factor := greatest(ceil(months_between(PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
								c_Parameter_Rec.effective_start_date) / 12), 0) + 1;
	    END IF;

	    -- Parse the Parameter Formulae and compute a running total for the
            -- PP Budget Year. If the CCID is deferred for processing, the
            -- parameter l_deferred is set to FND_API.G_TRUE

	    l_deferred := FALSE;

	    Process_Parameter
		   (p_worksheet_id => p_worksheet_id,
		    p_service_package_id => p_service_package_id,
		    p_parameter_id => c_Parameter_Rec.parameter_id,
		    p_parameter_name => c_Parameter_Rec.name,
		    p_compound_annually => l_compound_annually,
		    p_compound_factor => l_compound_factor,
		    p_budget_calendar_id => l_budget_calendar_id,
		    p_flex_code => l_flex_code,
		    p_flex_mapping_set_id => l_flex_mapping_set_id,
		    p_ccid => p_ccid,
		    p_ccid_start_period => p_ccid_start_period,
		    p_ccid_end_period => p_ccid_end_period,
		    p_budget_group_id => p_budget_group_id,
		    p_num_proposed_years => p_num_proposed_years,
		    p_return_status => l_return_status,
		    p_defer_ccids => p_defer_ccids,
		    p_deferred => l_deferred,
			/* bug no 4256345 */
  			p_stage_set_id		    => p_stage_set_id,
  			p_current_stage_seq     => p_current_stage_seq
                    /* bug no 4256345 */);

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      raise FND_API.G_EXC_ERROR;
	    END IF;

	    IF l_deferred THEN
	      raise FND_API.G_EXC_ERROR;
	    END IF;

           /* Bug 4308904 Start */

           IF   (l_num_allocated_years <= least(l_num_budget_years, nvl(l_num_years_to_allocate, PSB_WS_ACCT1.g_max_num_years)))
           THEN
           begin

            -- Bug#3401175: Support Profile type allocation rules for PP years.
	    --l_allocation_type := 'PERCENT';
	    l_allocation_type := NULL;


            -- If an Allocation Rule Set has been specified in the WS definition,
            -- distribute using the applicable Allocation Rule; otherwise, the YTD
            -- Amount is evenly distributed to the individual Period Amounts

            /* Bug 3352171 start */
            -- Comment out the following two lines. The allocation logic will be
            -- handled in the PSB_WS_ACCT2.Distribute_Account_Lines function.
            --if nvl(l_allocrule_set_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
            --then
            /* Bug 3352171 end */

            Distribute_Account_Lines
            ( p_return_status => l_return_status,
              p_worksheet_id => p_worksheet_id,
              p_flex_mapping_set_id => l_flex_mapping_set_id,
              p_budget_year_type_id =>
               PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_type_id,
              p_allocrule_set_id => l_allocrule_set_id,
              p_budget_calendar_id => l_budget_calendar_id,
              p_ccid => p_ccid,
              p_ytd_amount => g_running_total,
              -- Bug#3401175: Defaulting currency code to functional currency.
              p_currency_code => NVL(l_currency_code, l_func_currency),
              p_allocation_type => l_allocation_type,
              -- Bug#2342169: Added the following parameter.
              p_rounding_factor => l_rounding_factor,
              p_effective_start_date =>
               PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
              p_effective_end_date =>
               PSB_WS_ACCT1.g_budget_years(l_year_index).end_date,
              p_budget_periods => g_alloc_periods,
              p_period_amount => g_period_amount
            ) ;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
            END IF;

            -- l_num_allocated_years := l_num_allocated_years + 1;

         END;
         END IF;


         -- Bug 3543845: Check whether the worksheet creation process is
         -- executed for the first time. If it is the first time, then check the
         -- running total and create zero balance profile. Otherwise, call the
         -- create_account_Dist without any filtering.
         IF ( PSB_WORKSHEET.g_ws_first_time_creation_flag
              and
              ( g_running_total <> 0
                or
                (g_running_total = 0 and g_create_zero_bal = 'Y')
              )
            )
            OR
            NOT PSB_WORKSHEET.g_ws_first_time_creation_flag
         THEN
         BEGIN

	  -- Create Account Distribution for the CCID
	  PSB_WS_ACCT1.Create_Account_Dist
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_account_line_id => l_account_line_id,
	      p_worksheet_id => p_worksheet_id,
	      p_service_package_id => p_service_package_id,
	      p_check_spal_exists => FND_API.G_FALSE,
	      p_gl_cutoff_period => null,
	      p_allocrule_set_id => null,
	      p_budget_calendar_id => null,
	      p_rounding_factor => l_rounding_factor,
	      p_stage_set_id => p_stage_set_id,
	      p_start_stage_seq => l_start_stage_seq,
	      p_current_stage_seq => p_current_stage_seq,
	      p_budget_group_id => p_budget_group_id,
	      p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
	      p_flex_mapping_set_id => l_flex_mapping_set_id,
	      p_map_accounts => TRUE,
	      p_ccid => p_ccid,
	      p_currency_code => nvl(l_currency_code, l_func_currency),
	      p_balance_type => 'E',
	      p_ytd_amount => g_running_total,
	      p_period_amount => g_period_amount);

	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    raise FND_API.G_EXC_ERROR;
	  END IF;
        END;
	END IF;
        /* Bug 4308904 End*/

	END LOOP;

          -- for bug 4308904
          IF l_ccid_param_exists THEN
            l_num_allocated_years := l_num_allocated_years + 1;
          END IF;

	  l_num_proposed_years := l_num_proposed_years + 1;

	end;
	end if;

      end;
      end if;


      -- for bug 4308904
      -- This check is there for CCIDS falling outside
      -- the parameter range or for CCIDS where parameter is
      -- not applicable.

      IF not l_ccid_param_exists THEN
      IF (
           (
            (PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'CY')
             AND
             l_year_end_date <> l_gl_cutoff_period
            -- Added the above condition as part of Bug fix 3469514
           )
             OR
	   (
            (PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'PP')
             AND
            (l_num_allocated_years <= least(l_num_budget_years, nvl(l_num_years_to_allocate, PSB_WS_ACCT1.g_max_num_years)))
           )
         ) THEN
      begin

	if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'CY' then

          -- Bug#3126462: Support Percent type allocation rules for CY estimates
          -- No need to hardcode allocation type to Profile. Process all types.
	  --l_allocation_type := 'PROFILE';
	  l_allocation_type := NULL;

	  -- Subtract the Actual Balances for the CY since g_running_total
          -- computes the Estimate Balance for the full year. Also, Estimate
          -- Balances for CY includes the Actual Balances upto GL Cutoff Period

	  if l_cy_parameter_exists then
	  begin

	    if nvl(l_currency_code, p_func_currency) = p_func_currency then
	      g_running_total := g_running_total - nvl(g_actuals_func_total, 0);
	    else
	      g_running_total := g_running_total - nvl(g_actuals_stat_total, 0);
	    end if;

	  end;
	  end if;

	else
          -- Bug#3401175: Support Profile type allocation rules for PP years.
	  --l_allocation_type := 'PERCENT';
	  l_allocation_type := NULL;
	end if;

	-- If an Allocation Rule Set has been specified in the WS definition,
        -- distribute using the applicable Allocation Rule; otherwise, the YTD
        -- Amount is evenly distributed to the individual Period Amounts


        Distribute_Account_Lines
        ( p_return_status => l_return_status,
          p_worksheet_id => p_worksheet_id,
          p_flex_mapping_set_id => l_flex_mapping_set_id,
          p_budget_year_type_id =>
            PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_type_id,
          p_allocrule_set_id => l_allocrule_set_id,
          p_budget_calendar_id => l_budget_calendar_id,
          p_ccid => p_ccid,
          p_ytd_amount => g_running_total,
          --
          -- Bug#3401175: Defaulting currency code to functional currency.
          p_currency_code => NVL(l_currency_code, l_func_currency),
          --
          p_allocation_type => l_allocation_type,
          --
          -- Bug#2342169: Added the following parameter.
          p_rounding_factor => l_rounding_factor,
          --
          p_effective_start_date =>
            PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
          p_effective_end_date =>
            PSB_WS_ACCT1.g_budget_years(l_year_index).end_date,
          p_budget_periods => g_alloc_periods,
          p_period_amount => g_period_amount
        ) ;
        --

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

        l_num_allocated_years := l_num_allocated_years + 1;



      end;
      end if;



      --if (PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP')) then
      if ( ((PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'CY') AND
	   (PSB_WS_ACCT1.g_budget_years(l_year_index).end_date <> l_gl_cutoff_period)) OR
	   (PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'PP') ) then


      begin

        -- Commented the following line for bug 3305778


        -- Bug 3543845: Check whether the worksheet creation process is
        -- executed for the first time. If it is the first time, then check the
        -- running total and create zero balance profile. Otherwise, call the
        -- create_account_Dist without any filtering.
        if ( PSB_WORKSHEET.g_ws_first_time_creation_flag
             and
             ( g_running_total <> 0
               or
               (g_running_total = 0 and g_create_zero_bal = 'Y')
             )
           )
           OR
           NOT PSB_WORKSHEET.g_ws_first_time_creation_flag
        then
        begin

          --pd('3: Call Create_Account_Dist=> ccid=' || TO_CHAR(p_ccid) ||
          --   ', p_budget_year_id=' ||
          --   TO_CHAR(PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id)
          --   || ', p_ytd_amount=' || TO_CHAR(g_running_total));

	  -- Create Account Distribution for the CCID
	  PSB_WS_ACCT1.Create_Account_Dist
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_account_line_id => l_account_line_id,
	      p_worksheet_id => p_worksheet_id,
	      p_service_package_id => p_service_package_id,
	      p_check_spal_exists => FND_API.G_FALSE,
	      p_gl_cutoff_period => null,
	      p_allocrule_set_id => null,
	      p_budget_calendar_id => null,
	      p_rounding_factor => l_rounding_factor,
	      p_stage_set_id => p_stage_set_id,
	      p_start_stage_seq => l_start_stage_seq,
	      p_current_stage_seq => p_current_stage_seq,
	      p_budget_group_id => p_budget_group_id,
	      p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
	      p_flex_mapping_set_id => l_flex_mapping_set_id,
	      p_map_accounts => TRUE,
	      p_ccid => p_ccid,
	      p_currency_code => nvl(l_currency_code, l_func_currency),
	      p_balance_type => 'E',
	      p_ytd_amount => g_running_total,
	      p_period_amount => g_period_amount);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

        end;
	end if;

      end;
      end if;

    end if;

    end;
    end if;

    -- For the CY the Estimate Balances include the Actual Balances upto the
    -- GL Cutoff Period. This API copies the GL Actual Balances upto the GL
    -- Cutoff Period into the Estimate Balance

  -- for bug 4308904
  IF not l_ccid_param_exists THEN


    IF (PSB_WS_ACCT1.g_budget_years(l_year_index).year_type = 'CY') THEN
    -- AND l_cy_parameter_exists THEN
    -- Commented the above condition as part of bug fix 3469514

    begin

      if nvl(l_flex_mapping_set_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
      begin

	l_mapped_ccid := PSB_WS_ACCT1.Map_Account
			    (p_flex_mapping_set_id => l_flex_mapping_set_id,
			     p_ccid => p_ccid,
			     p_budget_year_type_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_type_id);

      end;
      else
	l_mapped_ccid := p_ccid;
      end if;

      PSB_WS_ACCT1.Copy_CY_Estimates
	 (p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_service_package_id => p_service_package_id,
	  p_rounding_factor => l_rounding_factor,
	  p_start_stage_seq => p_current_stage_seq,
	  p_budget_group_id => p_budget_group_id,
	  p_stage_set_id => p_stage_set_id,
	  p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
	  p_ccid => l_mapped_ccid,
	  p_currency_code => nvl(l_currency_code, l_func_currency));

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  -- for bug 4308904
  end if;

  end loop;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then

     -- Return Success for a deferred CCID because that will be processed
     -- in a later phase

     if l_deferred then
       p_return_status := FND_API.G_RET_STS_SUCCESS;
     else
       p_return_status := FND_API.G_RET_STS_ERROR;
     end if;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Apply_Account_Parameters;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
--
-- Sort the deferred CCIDs to avoid circular dependencies, e.g CCID-1 is
-- dependent on CCID-2 which depends on CCID-3 : sort the CCIDs so that
-- CCID-3 is processed first, followed by CCID-2, followed by CCID-1. The
-- CCIDs are sorted and stored in g_sorted_ccids
--
PROCEDURE Process_Deferred_CCIDs
( p_return_status          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id           IN   NUMBER,
  p_service_package_id     IN   NUMBER,
  p_sequence_number        IN   NUMBER,
  p_gl_cutoff_period       IN   DATE,
  p_allocrule_set_id       IN   NUMBER,
  p_rounding_factor        IN   NUMBER,
  p_stage_set_id           IN   NUMBER,
  p_flex_code              IN   NUMBER,
  p_flex_mapping_set_id    IN   NUMBER,
  p_func_currency          IN   VARCHAR2,
  p_num_years_to_allocate  IN   NUMBER,
  p_parameter_set_id       IN   NUMBER,
  p_budget_calendar_id     IN   NUMBER,
  p_budget_by_position     IN   VARCHAR2
) IS

  l_ccid_insert            BOOLEAN;
  l_depccid_exists         BOOLEAN;

  l_budget_group_id        NUMBER;
  l_num_proposed_years     NUMBER;
  l_ccid_start_period      DATE;
  l_ccid_end_period        DATE;

  l_index                  PLS_INTEGER;
  l_defccid_index          PLS_INTEGER;
  l_depccid_index          PLS_INTEGER;
  l_sortccid_index         PLS_INTEGER;

  l_ccid_exists_index      PLS_INTEGER;
  l_depccid_exists_index   PLS_INTEGER;

  l_return_status          VARCHAR2(1);

BEGIN

  for l_defccid_index in 1..g_num_defccids loop

    l_ccid_exists_index := null;
    l_ccid_insert := FALSE;

    -- For each deferred CCID, loop thru the dependency list

    for l_depccid_index in 1..g_num_depccids loop

      if g_dependent_ccids(l_depccid_index).ccid = g_deferred_ccids(l_defccid_index).ccid then
      begin

	l_depccid_exists_index := null;
	l_depccid_exists := FALSE;

	-- Check if any of the dependent CCIDs are also in the deferred list

	for l_index in 1..g_num_defccids loop

	  if g_deferred_ccids(l_index).ccid = g_dependent_ccids(l_depccid_index).dependent_ccid then
	  begin

	    l_budget_group_id := g_deferred_ccids(l_index).budget_group_id;
	    l_num_proposed_years := g_deferred_ccids(l_index).num_proposed_years;
	    l_ccid_start_period := g_deferred_ccids(l_index).ccid_start_period;
	    l_ccid_end_period := g_deferred_ccids(l_index).ccid_end_period;
	    l_depccid_exists := TRUE;
	    exit;

	  end;
	  end if;

	end loop;

	-- If dependent CCID is also in the deferred list, check if dependent CCID is already in
	-- in the sorted list g_sorted_ccids

	if l_depccid_exists then
	begin

	  if g_num_sortccids <> 0 then
	  begin

	    for l_sortccid_index in 1..g_num_sortccids loop

	      if g_sorted_ccids(l_sortccid_index).ccid = g_dependent_ccids(l_depccid_index).dependent_ccid then
		l_depccid_exists_index := l_sortccid_index;
		exit;
	      end if;

	    end loop;

	  end;
	  end if;

	end;
	end if;

	-- Check if deferred CCID is already in the sorted list g_sorted_ccids

	if g_num_sortccids <> 0 then
	begin

	  for l_sortccid_index in 1..g_num_sortccids loop

	    if g_sorted_ccids(l_sortccid_index).ccid = g_deferred_ccids(l_defccid_index).ccid then
	      l_ccid_exists_index := l_sortccid_index;
	      exit;
	    end if;

	  end loop;

	end;
	end if;

	-- If dependent CCID also exists in the deferred list, arrange the sorted list to avoid
	-- circular dependencies

	if l_depccid_exists then
	begin

	  if nvl(l_depccid_exists_index, g_num_sortccids + 1) > nvl(l_ccid_exists_index, g_num_sortccids + 1) then
	  begin

	    for l_sortccid_index in REVERSE l_ccid_exists_index + 1..nvl(l_depccid_exists_index, g_num_sortccids) loop
	      g_sorted_ccids(l_sortccid_index).budget_group_id := g_sorted_ccids(l_sortccid_index -1).budget_group_id;
	      g_sorted_ccids(l_sortccid_index).num_proposed_years := g_sorted_ccids(l_sortccid_index -1).num_proposed_years;
	      g_sorted_ccids(l_sortccid_index).ccid := g_sorted_ccids(l_sortccid_index -1).ccid;
	      g_sorted_ccids(l_sortccid_index).ccid_start_period := g_sorted_ccids(l_sortccid_index -1).ccid_start_period;
	      g_sorted_ccids(l_sortccid_index).ccid_end_period := g_sorted_ccids(l_sortccid_index -1).ccid_end_period;
	    end loop;

	    g_sorted_ccids(l_ccid_exists_index).budget_group_id := l_budget_group_id;
	    g_sorted_ccids(l_ccid_exists_index).num_proposed_years := l_num_proposed_years;
	    g_sorted_ccids(l_ccid_exists_index).ccid := g_dependent_ccids(l_depccid_index).dependent_ccid;
	    g_sorted_ccids(l_ccid_exists_index).ccid_start_period := l_ccid_start_period;
	    g_sorted_ccids(l_ccid_exists_index).ccid_end_period := l_ccid_end_period;

	    if nvl(l_depccid_exists_index, 0) = 0 then
	      g_num_sortccids := g_num_sortccids + 1;
	    end if;

	  end;
	  else
	  begin

	    if nvl(l_depccid_exists_index, 0) = 0 then
	    begin

	      g_num_sortccids := g_num_sortccids + 1;

	      g_sorted_ccids(g_num_sortccids).budget_group_id := l_budget_group_id;
	      g_sorted_ccids(g_num_sortccids).num_proposed_years := l_num_proposed_years;
	      g_sorted_ccids(g_num_sortccids).ccid := g_dependent_ccids(l_depccid_index).dependent_ccid;
	      g_sorted_ccids(g_num_sortccids).ccid_start_period := l_ccid_start_period;
	      g_sorted_ccids(g_num_sortccids).ccid_end_period := l_ccid_end_period;

	    end;
	    end if;

	    if nvl(l_ccid_exists_index, 0) = 0 then
	      l_ccid_insert := TRUE;
	    end if;

	  end;
	  end if;

	end;
	else
	begin

	  if nvl(l_ccid_exists_index, 0) = 0 then
	    l_ccid_insert := TRUE;
	  end if;

	end;
	end if;

      end;
      end if;

    end loop;

    -- Insert deferred CCID into the sorted list

    if l_ccid_insert then

      g_num_sortccids := g_num_sortccids + 1;

      g_sorted_ccids(g_num_sortccids).budget_group_id := g_deferred_ccids(l_defccid_index).budget_group_id;
      g_sorted_ccids(g_num_sortccids).num_proposed_years := g_deferred_ccids(l_defccid_index).num_proposed_years;
      g_sorted_ccids(g_num_sortccids).ccid := g_deferred_ccids(l_defccid_index).ccid;
      g_sorted_ccids(g_num_sortccids).ccid_start_period := g_deferred_ccids(l_defccid_index).ccid_start_period;
      g_sorted_ccids(g_num_sortccids).ccid_end_period := g_deferred_ccids(l_defccid_index).ccid_end_period;

    end if;

  end loop;

  -- For each deferred CCID in the sorted list, apply Account Parameters and
  -- compute YTD totals. The parameter p_defer_ccids is set to FND_API.G_FALSE
  -- because this is the last phase of processing parameters.

  for l_index in 1..g_num_sortccids loop

    Apply_Account_Parameters
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_service_package_id => p_service_package_id,
	  p_start_stage_seq => p_sequence_number,
	  p_current_stage_seq => p_sequence_number,
	  p_rounding_factor => p_rounding_factor,
	  p_stage_set_id => p_stage_set_id,
	  p_budget_group_id => g_sorted_ccids(l_index).budget_group_id,
	  p_allocrule_set_id => p_allocrule_set_id,
	  p_gl_cutoff_period => p_gl_cutoff_period,
	  p_flex_code => p_flex_code,
	  p_func_currency => p_func_currency,
	  p_flex_mapping_set_id => p_flex_mapping_set_id,
	  p_ccid => g_sorted_ccids(l_index).ccid,
	  p_ccid_start_period => g_sorted_ccids(l_index).ccid_start_period,
	  p_ccid_end_period => g_sorted_ccids(l_index).ccid_end_period,
	  p_num_proposed_years => g_sorted_ccids(l_index).num_proposed_years,
	  p_num_years_to_allocate => p_num_years_to_allocate,
	  p_parameter_set_id => p_parameter_set_id,
	  p_budget_calendar_id => p_budget_calendar_id,
	  p_budget_by_position => p_budget_by_position,
	  p_defer_ccids => FND_API.G_FALSE);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Process_Deferred_CCIDs');
     end if;

END Process_Deferred_CCIDs;

/* ----------------------------------------------------------------------- */

-- Distribute YTD Amount using the Allocation Rules specified in the Allocation
-- Rule Set. All PY balances are extracted from GL by individual periods, all CY
-- balances are distributed by the profile specified in the Allocation Rule and
-- all PP balances are distributed by percentages as specified in the Allocation
-- Rule

PROCEDURE Distribute_Account_Lines
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_flex_mapping_set_id   IN   NUMBER,
  p_budget_year_type_id   IN   NUMBER,
  p_allocrule_set_id      IN   NUMBER,
  p_budget_calendar_id    IN   NUMBER,
  p_currency_code         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ccid                  IN   NUMBER,
  p_ytd_amount            IN   NUMBER,
  p_allocation_type       IN   VARCHAR2,
  /* Bug No 2342169 Start */
  p_rounding_factor       IN   NUMBER,
  /* Bug No 2342169 End */
  p_effective_start_date  IN   DATE,
  p_effective_end_date    IN   DATE,
  p_budget_periods        IN   PSB_WS_ACCT1.g_budgetperiod_tbl_type,
  p_period_amount         OUT  NOCOPY  PSB_WS_ACCT1.g_prdamt_tbl_type
) IS

  cursor c_AllocRule is
    /* Bug 3458191
    -- Remove the usage of PSB_ALLOCRULE_ASSIGNMENTS_V and PSB_SET_RELATIONS_V
    -- Replace PSB_ALLOCRULE_ASSIGNMENTS_V by PSB_ENTITY_ASSIGNMENT, PSB_ENTITY
    -- Replace PSB_SET_RELATIONS_V by PSB_SET_RELATIONS
    */
    select pea.entity_id as allocrule_id,
           pe.budget_year_type_id,
           pe.balance_type
      from PSB_ENTITY_ASSIGNMENT pea, PSB_ENTITY pe
     where pe.entity_type = 'ALLOCRULE'
           and pe.entity_id = pea.entity_id
           and exists
               (select 1
                  from PSB_SET_RELATIONS b,
                       PSB_BUDGET_ACCOUNTS c
                 where b.account_position_set_id = c.account_position_set_id
                       and b.allocation_rule_id = pea.entity_id
                       and c.code_combination_id = p_ccid)
           and pe.entity_subtype = 'ACCOUNT'
           and pe.allocation_type = NVL(p_allocation_type,allocation_type)
           and (((pea.effective_start_date <= p_effective_end_date)
                 and (pea.effective_end_date is null))
                or ((pea.effective_start_date
                     between p_effective_start_date
                             and p_effective_end_date)
                    or (pea.effective_end_date
                        between p_effective_start_date
                                and p_effective_end_date)
                    or ((pea.effective_start_date < p_effective_start_date)
                    and (pea.effective_end_date > p_effective_end_date))))
           and pea.entity_set_id = p_allocrule_set_id
     order by pea.effective_start_date,
              pea.priority;

  cursor c_AllocPct (AllocRule_ID NUMBER,
		     Num_Periods NUMBER) is
    select period_num,
	   percent
      from PSB_ALLOCRULE_PERCENTS
     where number_of_periods = Num_Periods
       and allocation_rule_id = AllocRule_ID
     order by period_num;

/* Bug No 2354918 Start */
  CURSOR c_budyr_type IS
    SELECT year_category_type
      FROM PSB_BUDGET_YEAR_TYPES
     WHERE budget_year_type_id = p_budget_year_type_id;
/* Bug No 2354918 End */

  l_running_total         NUMBER := 0;
/* Bug No 2342169 Start */
  l_rounded_running_total NUMBER := 0;
  l_perc                  NUMBER;
  l_rounding_difference   NUMBER;
  l_year_category_type    VARCHAR2(30);
/* Bug No 2342169 End */

  l_allocated             BOOLEAN := FALSE;

  l_index                 PLS_INTEGER;

  sql_alloc               VARCHAR2(3000);
  cur_alloc               INTEGER;
  num_alloc               INTEGER;

  l_period_amount         PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_num_periods           NUMBER := 0;

  -- Bug#3126462: Support Percent type allocation rules for CY estimates
  l_weight                NUMBER := 0;

  l_amount                NUMBER;
  l_mapped_ccid           NUMBER;

BEGIN

  for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    l_period_amount(l_index) := null;
    p_period_amount(l_index) := null;
  end loop;

  for l_index in 1..p_budget_periods.Count loop

    if p_budget_periods(l_index).long_sequence_no is not null then
      l_num_periods := l_num_periods + 1;
    end if;

  end loop;

/* Bug No 2354918 Start */
  for c_budyr_type_rec in c_budyr_type loop
      l_year_category_type := c_budyr_type_rec.year_category_type;
  end loop;
/* Bug No 2354918 End */

  l_mapped_ccid := PSB_WS_ACCT1.Map_Account
		      (p_flex_mapping_set_id => p_flex_mapping_set_id,
		       p_ccid => p_ccid,
		       p_budget_year_type_id => p_budget_year_type_id);

  if ((p_allocation_type = 'PROFILE') and
      (p_currency_code = FND_API.G_MISS_CHAR)) then

    message_token('ROUTINE', 'PSB_WS_ACCT2.Distribute_Account_Lines');
    add_message('PSB', 'PSB_INVALID_ARGUMENT');
    raise FND_API.G_EXC_ERROR;
  end if;

  if l_num_periods > 0 then
  begin

    -- Bug 3352171: To improving performance, following condition is added to
    -- skip the query and distribute year amount to periods evenly.
    if (p_allocrule_set_id is not NULL) then

    -- Loop thru the Allocation Rules and pick up a percentage profile and period profile
    -- for the PP and CY Budget Years respectively

    -- Loop to process both types of allocation rules.
    for c_AllocRule_Rec in c_AllocRule loop

      -- Begin processing allocation type 'PERCENT'.
      if c_AllocRule_Rec.budget_year_type_id is null then
      begin

/* Bug No 2354918 Start */
	if l_year_category_type <> 'CY' then
/* Bug No 2354918 End */

	for c_AllocPct_Rec in c_AllocPct (c_AllocRule_Rec.allocrule_id, l_num_periods) loop
/* Bug No 2342169 Start */
-- Commented the following 1 line and added the other 4 lines
--          p_period_amount(c_AllocPct_Rec.period_num) := p_ytd_amount * c_AllocPct_Rec.percent / 100;

	if p_rounding_factor is null then
	  p_period_amount(c_AllocPct_Rec.period_num) := p_ytd_amount * nvl(c_AllocPct_Rec.percent,0) / 100;

	  l_running_total := l_running_total + p_period_amount(c_AllocPct_Rec.period_num);
	else
	  l_period_amount(c_AllocPct_Rec.period_num) := (p_ytd_amount * nvl(c_AllocPct_Rec.percent,0) / 100)
							   + (l_running_total - l_rounded_running_total);

	  l_running_total := l_running_total + (p_ytd_amount * nvl(c_AllocPct_Rec.percent,0) / 100);

/* Bug No 2379695 Start */
	  if nvl(c_AllocPct_Rec.percent, 0) <> 0 then
	    p_period_amount(c_AllocPct_Rec.period_num) := Round(l_period_amount(c_AllocPct_Rec.period_num));
	  else
	    p_period_amount(c_AllocPct_Rec.period_num) := 0;
	  end if;
/* Bug No 2379695 End */

	  l_rounded_running_total := l_rounded_running_total + p_period_amount(c_AllocPct_Rec.period_num);
	end if;
/* Bug No 2342169 End */

	  l_allocated := TRUE;
	end loop;

/* Bug No 2354918 Start */

        -- Bug#3126462: Support Percent type allocation rules for CY estimates
	ELSIF l_year_category_type = 'CY' THEN

          --
          -- For the CY estimates, we need to consider period percents for the
          -- periods beyond the GL cutoff date. For such (estimate) periods we
          -- find weighted or prorated ratio from applicable period percents.
          --
          -- Also note we if get to this point, this means we have at least
          -- one estimate period applicable. See "l_num_periods > 0" clause.
          --

          -- Find weight for the estimate periods from the allocation rule.
          FOR c_AllocPct_Rec IN c_AllocPct ( c_AllocRule_Rec.allocrule_id,
                                             PSB_WS_Acct1.g_cy_num_periods )
          LOOP

            -- Check if period percent is applicable for estimate periods.
            IF c_AllocPct_Rec.period_num >= p_budget_periods(1).long_sequence_no
            THEN
              l_weight := l_weight + NVL(c_AllocPct_Rec.percent,0) ;
            END IF ;

          END LOOP ;
          -- End finding weight for the estimate periods.

          -- Check for zero period percent allocation.
          IF l_weight = 0 THEN

            -- For zero allocation, use uniform allocation done later in API.
            l_allocated := FALSE;

          ELSE

            -- Now process period allocation for the current allocation rule.
            FOR c_AllocPct_Rec IN c_AllocPct (c_AllocRule_Rec.allocrule_id,
                                              PSB_WS_Acct1.g_cy_num_periods)
            LOOP

            -- Check if period allocation is for estimate periods.
            IF c_AllocPct_Rec.period_num >= p_budget_periods(1).long_sequence_no
            THEN

              -- Check p_rounding_factor clause.
              IF p_rounding_factor IS NULL THEN
                p_period_amount(c_AllocPct_Rec.period_num) := p_ytd_amount *
                                     nvl(c_AllocPct_Rec.percent,0) / l_weight ;

                l_running_total := l_running_total +
                                   p_period_amount(c_AllocPct_Rec.period_num) ;
              ELSE
                l_period_amount(c_AllocPct_Rec.period_num) :=
                     (p_ytd_amount * nvl(c_AllocPct_Rec.percent,0) / l_weight)
                     + (l_running_total - l_rounded_running_total);

                l_running_total := l_running_total +
                    (p_ytd_amount * nvl(c_AllocPct_Rec.percent,0) / l_weight) ;

                IF nvl(c_AllocPct_Rec.percent, 0) <> 0 THEN
                  p_period_amount(c_AllocPct_Rec.period_num) :=
                            Round(l_period_amount(c_AllocPct_Rec.period_num)) ;
                ELSE
                  p_period_amount(c_AllocPct_Rec.period_num) := 0 ;
                END IF;

                l_rounded_running_total := l_rounded_running_total +
                                   p_period_amount(c_AllocPct_Rec.period_num) ;
              END IF;
              -- End checking p_rounding_factor clause.

            END IF;
            -- End checking if period allocation is for estimate periods.

            l_allocated := TRUE;

            END LOOP ;
            -- End processing period allocation for the current allocation rule.

          END IF ;
          -- End checking for zero period percent allocation.
          -- Bug#3126462: End

	end if;
/* Bug No 2354918 End */

/* Bug No 2342169 Start */
	if p_rounding_factor is null then
	  p_period_amount(l_num_periods) := p_period_amount(l_num_periods) + p_ytd_amount - l_running_total;
	end if;
/* Bug No 2342169 End */

      end;
      -- End processing allocation type 'PERCENT'.
      else
      -- Begin processing allocation type 'PROFILE'.
      begin

	sql_alloc := 'select ';

	for l_index in 1..l_num_periods loop
	  sql_alloc := sql_alloc ||
		      'period' || p_budget_periods(l_index).long_sequence_no || '_amount' || ', ';
	end loop;

	sql_alloc := substr(sql_alloc, 1, length(sql_alloc) -2) || ' ' ||
		     'from PSB_WS_ACCOUNT_LINES a ' ||
		    'where a.template_id is null ' ||
		      'and a.position_line_id is null ' ||
		      'and a.balance_type = ''' || c_AllocRule_Rec.balance_type || ''' ' ||
		      'and a.code_combination_id = ' || l_mapped_ccid || ' ' ||
		      'and a.currency_code = ''' || p_currency_code || ''' ' ||
		      'and exists ' ||
			  '(select 1 ' ||
			     'from PSB_WS_LINES ' ||
			    'where account_line_id = a.account_line_id ' ||
			      'and worksheet_id = ' || p_worksheet_id || ') ' ||
		      'and exists ' ||
			  '(select 1 ' ||
			     'from PSB_BUDGET_PERIODS b ' ||
			    'where b.budget_calendar_id = ' || p_budget_calendar_id || ' ' ||
			      'and b.budget_year_type_id = ' || c_AllocRule_Rec.budget_year_type_id || ' ' ||
			      'and a.budget_year_id = b.budget_period_id)';

	cur_alloc := dbms_sql.open_cursor;
	dbms_sql.parse(cur_alloc, sql_alloc, dbms_sql.v7);

	for l_index in 1..l_num_periods loop
	  dbms_sql.define_column(cur_alloc, l_index, l_amount);
	end loop;

	num_alloc := dbms_sql.execute(cur_alloc);

	loop

	  if dbms_sql.fetch_rows(cur_alloc) = 0 then
	    exit;
	  end if;

	  l_allocated := TRUE;

	  for l_index in 1..l_num_periods loop
	    dbms_sql.column_value(cur_alloc, l_index, l_period_amount(p_budget_periods(l_index).long_sequence_no));
	    l_running_total := l_running_total + nvl(l_period_amount(p_budget_periods(l_index).long_sequence_no), 0);
	  end loop;

	end loop;

	dbms_sql.close_cursor(cur_alloc);

	for l_index in 1..l_num_periods loop

	  if l_running_total = 0 then
	    p_period_amount(p_budget_periods(l_index).long_sequence_no) := null;
	  else
	    p_period_amount(p_budget_periods(l_index).long_sequence_no) := p_ytd_amount *
		     l_period_amount(p_budget_periods(l_index).long_sequence_no) / l_running_total;
	  end if;

	end loop;

      end;
      end if;
      -- End processing allocation type 'PROFILE'.

    end loop;
    -- End loop to process both types of allocation rules.

    -- Bug 3352171: The following line is added to end a condition that used to
    -- improve performance.
    end if;

    -- Allocate Uniformly if there are no allocation rules found : this happens only when an
    -- Allocation Rule Set is specified for the Worksheet but there are no Allocation Rules

    if not l_allocated then
    begin

/* Bug No 2342169 Start */
	if p_rounding_factor is null then
	  l_perc := Round(100 / l_num_periods, 2) / 100;
	end if;
/* Bug No 2342169 End */

      for l_index in 1..l_num_periods loop
/* Bug No 2342169 Start */
-- Commented the following 1 line and added the other 4 lines
--        p_period_amount(p_budget_periods(l_index).long_sequence_no) := p_ytd_amount / l_num_periods;

	if p_rounding_factor is null then
	  p_period_amount(p_budget_periods(l_index).long_sequence_no) := p_ytd_amount * l_perc;

	  l_running_total := l_running_total + p_period_amount(p_budget_periods(l_index).long_sequence_no);
	else
	  l_period_amount(p_budget_periods(l_index).long_sequence_no) := (p_ytd_amount / l_num_periods)
							   + (l_running_total - l_rounded_running_total);

	  l_running_total := l_running_total + (p_ytd_amount / l_num_periods);

	  p_period_amount(p_budget_periods(l_index).long_sequence_no) := Round(l_period_amount(p_budget_periods(l_index).long_sequence_no));

	  l_rounded_running_total := l_rounded_running_total + p_period_amount(p_budget_periods(l_index).long_sequence_no);

	end if;
/* Bug No 2342169 End */

      end loop;

/* Bug No 2342169 Start */
	if p_rounding_factor is null then
	  l_rounding_difference := p_ytd_amount - l_running_total;

	  p_period_amount(p_budget_periods(l_num_periods).long_sequence_no) := p_period_amount(p_budget_periods(l_num_periods).long_sequence_no)
											+ l_rounding_difference;
	end if;
/* Bug No 2342169 End */

    end;
    end if;


  end;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Distribute_Account_Lines');
     end if;

END Distribute_Account_Lines;

/* ----------------------------------------------------------------------- */

-- Redistribute existing period amounts for an Account Line. Redistribution
-- is done by prorating the ratios of the new YTD Amount and the old YTD
-- Amount, e.g new period1_amount = current period1_amount * p_new_ytd_amount /
-- p_old_ytd_amount

PROCEDURE Distribute_Account_Lines
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_current_stage_seq   IN   NUMBER,
  p_account_line_id     IN   NUMBER,
  p_rounding_factor     IN   NUMBER,
  p_old_ytd_amount      IN   NUMBER,
  p_new_ytd_amount      IN   NUMBER,
  -- Bug#3128597: Support prorated allocation during annual amount updation
  p_cy_ytd_amount       IN   NUMBER := NULL,
  -- Bug#3128597: End
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_ytd_amount          NUMBER;
  l_period_amount       PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_init_index          PLS_INTEGER;

/* Bug No 2354918 Start */
  l_running_total       NUMBER := 0;
  l_budget_year_id      NUMBER;
  l_last_period_index   NUMBER;
/* Bug No 2354918 End */

  -- Bug#3128597: Support prorated allocation during annual amount updation
  l_old_ytd_amount      NUMBER;

  l_return_status       VARCHAR2(1);

  cursor c_WAL is
    select period1_amount, period2_amount, period3_amount, period4_amount,
	   period5_amount, period6_amount, period7_amount, period8_amount,
	   period9_amount, period10_amount, period11_amount, period12_amount,
	   period13_amount, period14_amount, period15_amount, period16_amount,
	   period17_amount, period18_amount, period19_amount, period20_amount,
	   period21_amount, period22_amount, period23_amount, period24_amount,
	   period25_amount, period26_amount, period27_amount, period28_amount,
	   period29_amount, period30_amount, period31_amount, period32_amount,
	   period33_amount, period34_amount, period35_amount, period36_amount,
	   period37_amount, period38_amount, period39_amount, period40_amount,
	   period41_amount, period42_amount, period43_amount, period44_amount,
	   period45_amount, period46_amount, period47_amount, period48_amount,
	   period49_amount, period50_amount, period51_amount, period52_amount,
	   period53_amount, period54_amount, period55_amount, period56_amount,
	   period57_amount, period58_amount, period59_amount, period60_amount,
/* Bug No 2354918 Start */
	   budget_year_id
/* Bug No 2354918 End */
      from PSB_WS_ACCOUNT_LINES
     where account_line_id = p_account_line_id;

BEGIN

  -- Bug#3128597: Support prorated allocation during annual amount updation
  -- For CY, we need to consider only estimate periods and balances for
  -- proration. Note for PP years, p_cy_ytd_amount will always be 0.
  l_old_ytd_amount := p_old_ytd_amount - p_cy_ytd_amount ;
  -- Bug#3128597: End

  for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    l_period_amount(l_init_index) := null;
  end loop;

/* Bug No 2354918 Start */
-- Added the logic for adjusting the rounding difference

  if p_rounding_factor is null then
  begin

    l_ytd_amount := p_new_ytd_amount;

    for c_WAL_Rec in c_WAL loop
/* Bug No 2354918 Start */
      l_budget_year_id := c_WAL_Rec.budget_year_id;

      for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop
      if PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id = l_budget_year_id then

	l_last_period_index := PSB_WS_ACCT1.g_budget_years(l_year_index).last_period_index;

      end if;
      end loop;
/* Bug No 2354918 End */

      if c_WAL_Rec.period1_amount is null then
	l_period_amount(1) := null;
      else
	if 1 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(1) := c_WAL_Rec.period1_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period1_amount / l_old_ytd_amount);
	else
	l_period_amount(1) := c_WAL_Rec.period1_amount;
	end if;
      end if;

      if c_WAL_Rec.period2_amount is null then
	l_period_amount(2) := null;
      else
	if 2 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(2) := c_WAL_Rec.period2_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period2_amount / l_old_ytd_amount);
	else
	l_period_amount(2) := c_WAL_Rec.period2_amount;
	end if;
      end if;

      if c_WAL_Rec.period3_amount is null then
	l_period_amount(3) := null;
      else
	if 3 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(3) := c_WAL_Rec.period3_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period3_amount / l_old_ytd_amount);
	else
	l_period_amount(3) := c_WAL_Rec.period3_amount;
	end if;
      end if;

      if c_WAL_Rec.period4_amount is null then
	l_period_amount(4) := null;
      else
	if 4 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(4) := c_WAL_Rec.period4_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period4_amount / l_old_ytd_amount);
	else
	l_period_amount(4) := c_WAL_Rec.period4_amount;
	end if;
      end if;

      if c_WAL_Rec.period5_amount is null then
	l_period_amount(5) := null;
      else
	if 5 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(5) := c_WAL_Rec.period5_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period5_amount / l_old_ytd_amount);
	else
	l_period_amount(5) := c_WAL_Rec.period5_amount;
	end if;
      end if;

      if c_WAL_Rec.period6_amount is null then
	l_period_amount(6) := null;
      else
	if 6 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(6) := c_WAL_Rec.period6_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period6_amount / l_old_ytd_amount);
	else
	l_period_amount(6) := c_WAL_Rec.period6_amount;
	end if;
      end if;

      if c_WAL_Rec.period7_amount is null then
	l_period_amount(7) := null;
      else
	if 7 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(7) := c_WAL_Rec.period7_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period7_amount / l_old_ytd_amount);
	else
	l_period_amount(7) := c_WAL_Rec.period7_amount;
	end if;
      end if;

      if c_WAL_Rec.period8_amount is null then
	l_period_amount(8) := null;
      else
	if 8 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(8) := c_WAL_Rec.period8_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period8_amount / l_old_ytd_amount);
	else
	l_period_amount(8) := c_WAL_Rec.period8_amount;
	end if;
      end if;

      if c_WAL_Rec.period9_amount is null then
	l_period_amount(9) := null;
      else
	if 9 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(9) := c_WAL_Rec.period9_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period9_amount / l_old_ytd_amount);
	else
	l_period_amount(9) := c_WAL_Rec.period9_amount;
	end if;
      end if;

      if c_WAL_Rec.period10_amount is null then
	l_period_amount(10) := null;
      else
	if 10 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(10) := c_WAL_Rec.period10_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period10_amount / l_old_ytd_amount);
	else
	l_period_amount(10) := c_WAL_Rec.period10_amount;
	end if;
      end if;

      if c_WAL_Rec.period11_amount is null then
	l_period_amount(11) := null;
      else
	if 11 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(11) := c_WAL_Rec.period11_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period11_amount / l_old_ytd_amount);
	else
	l_period_amount(11) := c_WAL_Rec.period11_amount;
	end if;
      end if;

      if c_WAL_Rec.period12_amount is null then
	l_period_amount(12) := null;
      else
	if 12 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(12) := c_WAL_Rec.period12_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period12_amount / l_old_ytd_amount);
	else
	l_period_amount(12) := c_WAL_Rec.period12_amount;
	end if;
      end if;

      if c_WAL_Rec.period13_amount is null then
	l_period_amount(13) := null;
      else
	if 13 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(13) := c_WAL_Rec.period13_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period13_amount / l_old_ytd_amount);
	else
	l_period_amount(13) := c_WAL_Rec.period13_amount;
	end if;
      end if;

      if c_WAL_Rec.period14_amount is null then
	l_period_amount(14) := null;
      else
	if 14 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(14) := c_WAL_Rec.period14_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period14_amount / l_old_ytd_amount);
	else
	l_period_amount(14) := c_WAL_Rec.period14_amount;
	end if;
      end if;

      if c_WAL_Rec.period15_amount is null then
	l_period_amount(15) := null;
      else
	if 15 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(15) := c_WAL_Rec.period15_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period15_amount / l_old_ytd_amount);
	else
	l_period_amount(15) := c_WAL_Rec.period15_amount;
	end if;
      end if;

      if c_WAL_Rec.period16_amount is null then
	l_period_amount(16) := null;
      else
	if 16 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(16) := c_WAL_Rec.period16_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period16_amount / l_old_ytd_amount);
	else
	l_period_amount(16) := c_WAL_Rec.period16_amount;
	end if;
      end if;

      if c_WAL_Rec.period17_amount is null then
	l_period_amount(17) := null;
      else
	if 17 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(17) := c_WAL_Rec.period17_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period17_amount / l_old_ytd_amount);
	else
	l_period_amount(17) := c_WAL_Rec.period17_amount;
	end if;
      end if;

      if c_WAL_Rec.period18_amount is null then
	l_period_amount(18) := null;
      else
	if 18 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(18) := c_WAL_Rec.period18_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period18_amount / l_old_ytd_amount);
	else
	l_period_amount(18) := c_WAL_Rec.period18_amount;
	end if;
      end if;

      if c_WAL_Rec.period19_amount is null then
	l_period_amount(19) := null;
      else
	if 19 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(19) := c_WAL_Rec.period19_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period19_amount / l_old_ytd_amount);
	else
	l_period_amount(19) := c_WAL_Rec.period19_amount;
	end if;
      end if;

      if c_WAL_Rec.period20_amount is null then
	l_period_amount(20) := null;
      else
	if 20 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(20) := c_WAL_Rec.period20_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period20_amount / l_old_ytd_amount);
	else
	l_period_amount(20) := c_WAL_Rec.period20_amount;
	end if;
      end if;

      if c_WAL_Rec.period21_amount is null then
	l_period_amount(21) := null;
      else
	if 21 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(21) := c_WAL_Rec.period21_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period21_amount / l_old_ytd_amount);
	else
	l_period_amount(21) := c_WAL_Rec.period21_amount;
	end if;
      end if;

      if c_WAL_Rec.period22_amount is null then
	l_period_amount(22) := null;
      else
	if 22 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(22) := c_WAL_Rec.period22_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period22_amount / l_old_ytd_amount);
	else
	l_period_amount(22) := c_WAL_Rec.period22_amount;
	end if;
      end if;

      if c_WAL_Rec.period23_amount is null then
	l_period_amount(23) := null;
      else
	if 23 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(23) := c_WAL_Rec.period23_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period23_amount / l_old_ytd_amount);
	else
	l_period_amount(23) := c_WAL_Rec.period23_amount;
	end if;
      end if;

      if c_WAL_Rec.period24_amount is null then
	l_period_amount(24) := null;
      else
	if 24 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(24) := c_WAL_Rec.period24_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period24_amount / l_old_ytd_amount);
	else
	l_period_amount(24) := c_WAL_Rec.period24_amount;
	end if;
      end if;

      if c_WAL_Rec.period25_amount is null then
	l_period_amount(25) := null;
      else
	if 25 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(25) := c_WAL_Rec.period25_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period25_amount / l_old_ytd_amount);
	else
	l_period_amount(25) := c_WAL_Rec.period25_amount;
	end if;
      end if;

      if c_WAL_Rec.period26_amount is null then
	l_period_amount(26) := null;
      else
	if 26 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(26) := c_WAL_Rec.period26_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period26_amount / l_old_ytd_amount);
	else
	l_period_amount(26) := c_WAL_Rec.period26_amount;
	end if;
      end if;

      if c_WAL_Rec.period27_amount is null then
	l_period_amount(27) := null;
      else
	if 27 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(27) := c_WAL_Rec.period27_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period27_amount / l_old_ytd_amount);
	else
	l_period_amount(27) := c_WAL_Rec.period27_amount;
	end if;
      end if;

      if c_WAL_Rec.period28_amount is null then
	l_period_amount(28) := null;
      else
	if 28 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(28) := c_WAL_Rec.period28_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period28_amount / l_old_ytd_amount);
	else
	l_period_amount(28) := c_WAL_Rec.period28_amount;
	end if;
      end if;

      if c_WAL_Rec.period29_amount is null then
	l_period_amount(29) := null;
      else
	if 29 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(29) := c_WAL_Rec.period29_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period29_amount / l_old_ytd_amount);
	else
	l_period_amount(29) := c_WAL_Rec.period29_amount;
	end if;
      end if;

      if c_WAL_Rec.period30_amount is null then
	l_period_amount(30) := null;
      else
	if 30 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(30) := c_WAL_Rec.period30_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period30_amount / l_old_ytd_amount);
	else
	l_period_amount(30) := c_WAL_Rec.period30_amount;
	end if;
      end if;

      if c_WAL_Rec.period31_amount is null then
	l_period_amount(31) := null;
      else
	if 31 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(31) := c_WAL_Rec.period31_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period31_amount / l_old_ytd_amount);
	else
	l_period_amount(31) := c_WAL_Rec.period31_amount;
	end if;
      end if;

      if c_WAL_Rec.period32_amount is null then
	l_period_amount(32) := null;
      else
	if 32 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(32) := c_WAL_Rec.period32_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period32_amount / l_old_ytd_amount);
	else
	l_period_amount(32) := c_WAL_Rec.period32_amount;
	end if;
      end if;

      if c_WAL_Rec.period33_amount is null then
	l_period_amount(33) := null;
      else
	if 33 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(33) := c_WAL_Rec.period33_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period33_amount / l_old_ytd_amount);
	else
	l_period_amount(33) := c_WAL_Rec.period33_amount;
	end if;
      end if;

      if c_WAL_Rec.period34_amount is null then
	l_period_amount(34) := null;
      else
	if 34 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(34) := c_WAL_Rec.period34_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period34_amount / l_old_ytd_amount);
	else
	l_period_amount(34) := c_WAL_Rec.period34_amount;
	end if;
      end if;

      if c_WAL_Rec.period35_amount is null then
	l_period_amount(35) := null;
      else
	if 35 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(35) := c_WAL_Rec.period35_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period35_amount / l_old_ytd_amount);
	else
	l_period_amount(35) := c_WAL_Rec.period35_amount;
	end if;
      end if;

      if c_WAL_Rec.period36_amount is null then
	l_period_amount(36) := null;
      else
	if 36 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(36) := c_WAL_Rec.period36_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period36_amount / l_old_ytd_amount);
	else
	l_period_amount(36) := c_WAL_Rec.period36_amount;
	end if;
      end if;

      if c_WAL_Rec.period37_amount is null then
	l_period_amount(37) := null;
      else
	if 37 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(37) := c_WAL_Rec.period37_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period37_amount / l_old_ytd_amount);
	else
	l_period_amount(37) := c_WAL_Rec.period37_amount;
	end if;
      end if;

      if c_WAL_Rec.period38_amount is null then
	l_period_amount(38) := null;
      else
	if 38 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(38) := c_WAL_Rec.period38_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period38_amount / l_old_ytd_amount);
	else
	l_period_amount(38) := c_WAL_Rec.period38_amount;
	end if;
      end if;

      if c_WAL_Rec.period39_amount is null then
	l_period_amount(39) := null;
      else
	if 39 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(39) := c_WAL_Rec.period39_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period39_amount / l_old_ytd_amount);
	else
	l_period_amount(39) := c_WAL_Rec.period39_amount;
	end if;
      end if;

      if c_WAL_Rec.period40_amount is null then
	l_period_amount(40) := null;
      else
	if 40 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(40) := c_WAL_Rec.period40_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period40_amount / l_old_ytd_amount);
	else
	l_period_amount(40) := c_WAL_Rec.period40_amount;
	end if;
      end if;

      if c_WAL_Rec.period41_amount is null then
	l_period_amount(41) := null;
      else
	if 41 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(41) := c_WAL_Rec.period41_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period41_amount / l_old_ytd_amount);
	else
	l_period_amount(41) := c_WAL_Rec.period41_amount;
	end if;
      end if;

      if c_WAL_Rec.period42_amount is null then
	l_period_amount(42) := null;
      else
	if 42 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(42) := c_WAL_Rec.period42_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period42_amount / l_old_ytd_amount);
	else
	l_period_amount(42) := c_WAL_Rec.period42_amount;
	end if;
      end if;

      if c_WAL_Rec.period43_amount is null then
	l_period_amount(43) := null;
      else
	if 43 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(43) := c_WAL_Rec.period43_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period43_amount / l_old_ytd_amount);
	else
	l_period_amount(43) := c_WAL_Rec.period43_amount;
	end if;
      end if;

      if c_WAL_Rec.period44_amount is null then
	l_period_amount(44) := null;
      else
	if 44 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(44) := c_WAL_Rec.period44_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period44_amount / l_old_ytd_amount);
	else
	l_period_amount(44) := c_WAL_Rec.period44_amount;
	end if;
      end if;

      if c_WAL_Rec.period45_amount is null then
	l_period_amount(45) := null;
      else
	if 45 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(45) := c_WAL_Rec.period45_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period45_amount / l_old_ytd_amount);
	else
	l_period_amount(45) := c_WAL_Rec.period45_amount;
	end if;
      end if;

      if c_WAL_Rec.period46_amount is null then
	l_period_amount(46) := null;
      else
	if 46 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(46) := c_WAL_Rec.period46_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period46_amount / l_old_ytd_amount);
	else
	l_period_amount(46) := c_WAL_Rec.period46_amount;
	end if;
      end if;

      if c_WAL_Rec.period47_amount is null then
	l_period_amount(47) := null;
      else
	if 47 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(47) := c_WAL_Rec.period47_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period47_amount / l_old_ytd_amount);
	else
	l_period_amount(47) := c_WAL_Rec.period47_amount;
	end if;
      end if;

      if c_WAL_Rec.period48_amount is null then
	l_period_amount(48) := null;
      else
	if 48 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(48) := c_WAL_Rec.period48_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period48_amount / l_old_ytd_amount);
	else
	l_period_amount(48) := c_WAL_Rec.period48_amount;
	end if;
      end if;

      if c_WAL_Rec.period49_amount is null then
	l_period_amount(49) := null;
      else
	if 49 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(49) := c_WAL_Rec.period49_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period49_amount / l_old_ytd_amount);
	else
	l_period_amount(49) := c_WAL_Rec.period49_amount;
	end if;
      end if;

      if c_WAL_Rec.period50_amount is null then
	l_period_amount(50) := null;
      else
	if 50 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(50) := c_WAL_Rec.period50_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period50_amount / l_old_ytd_amount);
	else
	l_period_amount(50) := c_WAL_Rec.period50_amount;
	end if;
      end if;

      if c_WAL_Rec.period51_amount is null then
	l_period_amount(51) := null;
      else
	if 51 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(51) := c_WAL_Rec.period51_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period51_amount / l_old_ytd_amount);
	else
	l_period_amount(51) := c_WAL_Rec.period51_amount;
	end if;
      end if;

      if c_WAL_Rec.period52_amount is null then
	l_period_amount(52) := null;
      else
	if 52 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(52) := c_WAL_Rec.period52_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period52_amount / l_old_ytd_amount);
	else
	l_period_amount(52) := c_WAL_Rec.period52_amount;
	end if;
      end if;

      if c_WAL_Rec.period53_amount is null then
	l_period_amount(53) := null;
      else
	if 53 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(53) := c_WAL_Rec.period53_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period53_amount / l_old_ytd_amount);
	else
	l_period_amount(53) := c_WAL_Rec.period53_amount;
	end if;
      end if;

      if c_WAL_Rec.period54_amount is null then
	l_period_amount(54) := null;
      else
	if 54 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(54) := c_WAL_Rec.period54_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period54_amount / l_old_ytd_amount);
	else
	l_period_amount(54) := c_WAL_Rec.period54_amount;
	end if;
      end if;

      if c_WAL_Rec.period55_amount is null then
	l_period_amount(55) := null;
      else
	if 55 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(55) := c_WAL_Rec.period55_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period55_amount / l_old_ytd_amount);
	else
	l_period_amount(55) := c_WAL_Rec.period55_amount;
	end if;
      end if;

      if c_WAL_Rec.period56_amount is null then
	l_period_amount(56) := null;
      else
	if 56 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(56) := c_WAL_Rec.period56_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period56_amount / l_old_ytd_amount);
	else
	l_period_amount(56) := c_WAL_Rec.period56_amount;
	end if;
      end if;

      if c_WAL_Rec.period57_amount is null then
	l_period_amount(57) := null;
      else
	if 57 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(57) := c_WAL_Rec.period57_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period57_amount / l_old_ytd_amount);
	else
	l_period_amount(57) := c_WAL_Rec.period57_amount;
	end if;
      end if;

      if c_WAL_Rec.period58_amount is null then
	l_period_amount(58) := null;
      else
	if 58 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(58) := c_WAL_Rec.period58_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period58_amount / l_old_ytd_amount);
	else
	l_period_amount(58) := c_WAL_Rec.period58_amount;
	end if;
      end if;

      if c_WAL_Rec.period59_amount is null then
	l_period_amount(59) := null;
      else
	if 59 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(59) := c_WAL_Rec.period59_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period59_amount / l_old_ytd_amount);
	else
	l_period_amount(59) := c_WAL_Rec.period59_amount;
	end if;
      end if;

      if c_WAL_Rec.period60_amount is null then
	l_period_amount(60) := null;
      else
	if 60 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(60) := c_WAL_Rec.period60_amount +
			     ((p_new_ytd_amount - p_old_ytd_amount) * c_WAL_Rec.period60_amount / l_old_ytd_amount);
	else
	l_period_amount(60) := c_WAL_Rec.period60_amount;
	end if;
      end if;

      l_running_total := l_running_total
		+ nvl(l_period_amount(1),0)   + nvl(l_period_amount(2),0)   + nvl(l_period_amount(3),0)   + nvl(l_period_amount(4),0)   + nvl(l_period_amount(5),0)
		+ nvl(l_period_amount(6),0)   + nvl(l_period_amount(7),0)   + nvl(l_period_amount(8),0)   + nvl(l_period_amount(9),0)   + nvl(l_period_amount(10),0)
		+ nvl(l_period_amount(11),0)  + nvl(l_period_amount(12),0)  + nvl(l_period_amount(13),0)  + nvl(l_period_amount(14),0)  + nvl(l_period_amount(15),0)
		+ nvl(l_period_amount(16),0)  + nvl(l_period_amount(17),0)  + nvl(l_period_amount(18),0)  + nvl(l_period_amount(19),0)  + nvl(l_period_amount(20),0)
		+ nvl(l_period_amount(21),0)  + nvl(l_period_amount(22),0)  + nvl(l_period_amount(23),0)  + nvl(l_period_amount(24),0)  + nvl(l_period_amount(25),0)
		+ nvl(l_period_amount(26),0)  + nvl(l_period_amount(27),0)  + nvl(l_period_amount(28),0)  + nvl(l_period_amount(29),0)  + nvl(l_period_amount(30),0)
		+ nvl(l_period_amount(31),0)  + nvl(l_period_amount(32),0)  + nvl(l_period_amount(33),0)  + nvl(l_period_amount(34),0)  + nvl(l_period_amount(35),0)
		+ nvl(l_period_amount(36),0)  + nvl(l_period_amount(37),0)  + nvl(l_period_amount(38),0)  + nvl(l_period_amount(39),0)  + nvl(l_period_amount(40),0)
		+ nvl(l_period_amount(41),0)  + nvl(l_period_amount(42),0)  + nvl(l_period_amount(43),0)  + nvl(l_period_amount(44),0)  + nvl(l_period_amount(45),0)
		+ nvl(l_period_amount(46),0)  + nvl(l_period_amount(47),0)  + nvl(l_period_amount(48),0)  + nvl(l_period_amount(49),0)  + nvl(l_period_amount(50),0)
		+ nvl(l_period_amount(51),0)  + nvl(l_period_amount(52),0)  + nvl(l_period_amount(53),0)  + nvl(l_period_amount(54),0)  + nvl(l_period_amount(55),0)
		+ nvl(l_period_amount(56),0)  + nvl(l_period_amount(57),0)  + nvl(l_period_amount(58),0)  + nvl(l_period_amount(59),0)  + nvl(l_period_amount(60),0);

    end loop;

    /* Bug 3133240 Start */
    --Added the IF condition

    IF l_last_period_index > 0 THEN
    	l_period_amount(l_last_period_index) := l_period_amount(l_last_period_index) + p_new_ytd_amount - l_running_total;
    END IF;

    /* Bug 3133240 End */

  end;
  else
  begin

    l_ytd_amount := ROUND(p_new_ytd_amount/p_rounding_factor) * p_rounding_factor;

    for c_WAL_Rec in c_WAL loop

/* Bug No 2354918 Start */
      l_budget_year_id := c_WAL_Rec.budget_year_id;

      for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop
      if PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id = l_budget_year_id then

	l_last_period_index := PSB_WS_ACCT1.g_budget_years(l_year_index).last_period_index;

      end if;
      end loop;
/* Bug No 2354918 End */

      if c_WAL_Rec.period1_amount is null then
	l_period_amount(1) := null;
      else
	if 1 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(1) := ROUND((c_WAL_Rec.period1_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				     c_WAL_Rec.Period1_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(1) := c_WAL_Rec.period1_amount;
	end if;
      end if;

      if c_WAL_Rec.period2_amount is null then
	l_period_amount(2) := null;
      else
	if 2 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(2) := ROUND((c_WAL_Rec.period2_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				     c_WAL_Rec.Period2_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(2) := c_WAL_Rec.period2_amount;
	end if;
      end if;

      if c_WAL_Rec.period3_amount is null then
	l_period_amount(3) := null;
      else
	if 3 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(3) := ROUND((c_WAL_Rec.period3_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				     c_WAL_Rec.Period3_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(3) := c_WAL_Rec.period3_amount;
	end if;
      end if;

      if c_WAL_Rec.period4_amount is null then
	l_period_amount(4) := null;
      else
	if 4 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(4) := ROUND((c_WAL_Rec.period4_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				     c_WAL_Rec.Period4_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(4) := c_WAL_Rec.period4_amount;
	end if;
      end if;

      if c_WAL_Rec.period5_amount is null then
	l_period_amount(5) := null;
      else
	if 5 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(5) := ROUND((c_WAL_Rec.period5_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				     c_WAL_Rec.Period5_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(5) := c_WAL_Rec.period5_amount;
	end if;
      end if;

      if c_WAL_Rec.period6_amount is null then
	l_period_amount(6) := null;
      else
	if 6 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(6) := ROUND((c_WAL_Rec.period6_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				     c_WAL_Rec.Period6_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(6) := c_WAL_Rec.period6_amount;
	end if;
      end if;

      if c_WAL_Rec.period7_amount is null then
	l_period_amount(7) := null;
      else
	if 7 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(7) := ROUND((c_WAL_Rec.period7_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				     c_WAL_Rec.Period7_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(7) := c_WAL_Rec.period7_amount;
	end if;
      end if;

      if c_WAL_Rec.period8_amount is null then
	l_period_amount(8) := null;
      else
	if 8 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(8) := ROUND((c_WAL_Rec.period8_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				     c_WAL_Rec.Period8_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(8) := c_WAL_Rec.period8_amount;
	end if;
      end if;

      if c_WAL_Rec.period9_amount is null then
	l_period_amount(9) := null;
      else
	if 9 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(9) := ROUND((c_WAL_Rec.period9_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				     c_WAL_Rec.Period9_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(9) := c_WAL_Rec.period9_amount;
	end if;
      end if;

      if c_WAL_Rec.period10_amount is null then
	l_period_amount(10) := null;
      else
	if 10 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(10) := ROUND((c_WAL_Rec.period10_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period10_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(10) := c_WAL_Rec.period10_amount;
	end if;
      end if;

      if c_WAL_Rec.period11_amount is null then
	l_period_amount(11) := null;
      else
	if 11 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(11) := ROUND((c_WAL_Rec.period11_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period11_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(11) := c_WAL_Rec.period11_amount;
	end if;
      end if;

      if c_WAL_Rec.period12_amount is null then
	l_period_amount(12) := null;
      else
	if 12 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(12) := ROUND((c_WAL_Rec.period12_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period12_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(12) := c_WAL_Rec.period12_amount;
	end if;
      end if;

      if c_WAL_Rec.period13_amount is null then
	l_period_amount(13) := null;
      else
	if 13 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(13) := ROUND((c_WAL_Rec.period13_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period13_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(13) := c_WAL_Rec.period13_amount;
	end if;
      end if;

      if c_WAL_Rec.period14_amount is null then
	l_period_amount(14) := null;
      else
	if 14 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(14) := ROUND((c_WAL_Rec.period14_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period14_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(14) := c_WAL_Rec.period14_amount;
	end if;
      end if;

      if c_WAL_Rec.period15_amount is null then
	l_period_amount(15) := null;
      else
	if 15 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(15) := ROUND((c_WAL_Rec.period15_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period15_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(15) := c_WAL_Rec.period15_amount;
	end if;
      end if;

      if c_WAL_Rec.period16_amount is null then
	l_period_amount(16) := null;
      else
	if 16 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(16) := ROUND((c_WAL_Rec.period16_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period16_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(16) := c_WAL_Rec.period16_amount;
	end if;
      end if;

      if c_WAL_Rec.period17_amount is null then
	l_period_amount(17) := null;
      else
	if 17 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(17) := ROUND((c_WAL_Rec.period17_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period17_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(17) := c_WAL_Rec.period17_amount;
	end if;
      end if;

      if c_WAL_Rec.period18_amount is null then
	l_period_amount(18) := null;
      else
	if 18 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(18) := ROUND((c_WAL_Rec.period18_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period18_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(18) := c_WAL_Rec.period18_amount;
	end if;
      end if;

      if c_WAL_Rec.period19_amount is null then
	l_period_amount(19) := null;
      else
	if 19 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(19) := ROUND((c_WAL_Rec.period19_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period19_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(19) := c_WAL_Rec.period19_amount;
	end if;
      end if;

      if c_WAL_Rec.period20_amount is null then
	l_period_amount(20) := null;
      else
	if 20 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(20) := ROUND((c_WAL_Rec.period20_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period20_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(20) := c_WAL_Rec.period20_amount;
	end if;
      end if;

      if c_WAL_Rec.period21_amount is null then
	l_period_amount(21) := null;
      else
	if 21 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(21) := ROUND((c_WAL_Rec.period21_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period21_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(21) := c_WAL_Rec.period21_amount;
	end if;
      end if;

      if c_WAL_Rec.period22_amount is null then
	l_period_amount(22) := null;
      else
	if 22 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(22) := ROUND((c_WAL_Rec.period22_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period22_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(22) := c_WAL_Rec.period22_amount;
	end if;
      end if;

      if c_WAL_Rec.period23_amount is null then
	l_period_amount(23) := null;
      else
	if 23 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(23) := ROUND((c_WAL_Rec.period23_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period23_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(23) := c_WAL_Rec.period23_amount;
	end if;
      end if;

      if c_WAL_Rec.period24_amount is null then
	l_period_amount(24) := null;
      else
	if 24 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(24) := ROUND((c_WAL_Rec.period24_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period24_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(24) := c_WAL_Rec.period24_amount;
	end if;
      end if;

      if c_WAL_Rec.period25_amount is null then
	l_period_amount(25) := null;
      else
	if 25 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(25) := ROUND((c_WAL_Rec.period25_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period25_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(25) := c_WAL_Rec.period25_amount;
	end if;
      end if;

      if c_WAL_Rec.period26_amount is null then
	l_period_amount(26) := null;
      else
	if 26 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(26) := ROUND((c_WAL_Rec.period26_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period26_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(26) := c_WAL_Rec.period26_amount;
	end if;
      end if;

      if c_WAL_Rec.period27_amount is null then
	l_period_amount(27) := null;
      else
	if 27 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(27) := ROUND((c_WAL_Rec.period27_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period27_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(27) := c_WAL_Rec.period27_amount;
	end if;
      end if;

      if c_WAL_Rec.period28_amount is null then
	l_period_amount(28) := null;
      else
	if 28 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(28) := ROUND((c_WAL_Rec.period28_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period28_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(28) := c_WAL_Rec.period28_amount;
	end if;
      end if;

      if c_WAL_Rec.period29_amount is null then
	l_period_amount(29) := null;
      else
	if 29 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(29) := ROUND((c_WAL_Rec.period29_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period29_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(29) := c_WAL_Rec.period29_amount;
	end if;
      end if;

      if c_WAL_Rec.period30_amount is null then
	l_period_amount(30) := null;
      else
	if 30 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(30) := ROUND((c_WAL_Rec.period30_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period30_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(30) := c_WAL_Rec.period30_amount;
	end if;
      end if;

      if c_WAL_Rec.period31_amount is null then
	l_period_amount(31) := null;
      else
	if 31 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(31) := ROUND((c_WAL_Rec.period31_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period31_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(31) := c_WAL_Rec.period31_amount;
	end if;
      end if;

      if c_WAL_Rec.period32_amount is null then
	l_period_amount(32) := null;
      else
	if 32 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(32) := ROUND((c_WAL_Rec.period32_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period32_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(32) := c_WAL_Rec.period32_amount;
	end if;
      end if;

      if c_WAL_Rec.period33_amount is null then
	l_period_amount(33) := null;
      else
	if 33 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(33) := ROUND((c_WAL_Rec.period33_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period33_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(33) := c_WAL_Rec.period33_amount;
	end if;
      end if;

      if c_WAL_Rec.period34_amount is null then
	l_period_amount(34) := null;
      else
	if 34 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(34) := ROUND((c_WAL_Rec.period34_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period34_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(34) := c_WAL_Rec.period34_amount;
	end if;
      end if;

      if c_WAL_Rec.period35_amount is null then
	l_period_amount(35) := null;
      else
	if 35 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(35) := ROUND((c_WAL_Rec.period35_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period35_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(35) := c_WAL_Rec.period35_amount;
	end if;
      end if;

      if c_WAL_Rec.period36_amount is null then
	l_period_amount(36) := null;
      else
	if 36 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(36) := ROUND((c_WAL_Rec.period36_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period36_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(36) := c_WAL_Rec.period36_amount;
	end if;
      end if;

      if c_WAL_Rec.period37_amount is null then
	l_period_amount(37) := null;
      else
	if 37 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(37) := ROUND((c_WAL_Rec.period37_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period37_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(37) := c_WAL_Rec.period37_amount;
	end if;
      end if;

      if c_WAL_Rec.period38_amount is null then
	l_period_amount(38) := null;
      else
	if 38 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(38) := ROUND((c_WAL_Rec.period38_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period38_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(38) := c_WAL_Rec.period38_amount;
	end if;
      end if;

      if c_WAL_Rec.period39_amount is null then
	l_period_amount(39) := null;
      else
	if 39 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(39) := ROUND((c_WAL_Rec.period39_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period39_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(39) := c_WAL_Rec.period39_amount;
	end if;
      end if;

      if c_WAL_Rec.period40_amount is null then
	l_period_amount(40) := null;
      else
	if 40 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(40) := ROUND((c_WAL_Rec.period40_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period40_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(40) := c_WAL_Rec.period40_amount;
	end if;
      end if;

      if c_WAL_Rec.period41_amount is null then
	l_period_amount(41) := null;
      else
	if 41 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(41) := ROUND((c_WAL_Rec.period41_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period41_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(41) := c_WAL_Rec.period41_amount;
	end if;
      end if;

      if c_WAL_Rec.period42_amount is null then
	l_period_amount(42) := null;
      else
	if 42 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(42) := ROUND((c_WAL_Rec.period42_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period42_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(42) := c_WAL_Rec.period42_amount;
	end if;
      end if;

      if c_WAL_Rec.period43_amount is null then
	l_period_amount(43) := null;
      else
	if 43 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(43) := ROUND((c_WAL_Rec.period43_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period43_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(43) := c_WAL_Rec.period43_amount;
	end if;
      end if;

      if c_WAL_Rec.period44_amount is null then
	l_period_amount(44) := null;
      else
	if 44 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(44) := ROUND((c_WAL_Rec.period44_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period44_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(44) := c_WAL_Rec.period44_amount;
	end if;
      end if;

      if c_WAL_Rec.period45_amount is null then
	l_period_amount(45) := null;
      else
	if 45 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(45) := ROUND((c_WAL_Rec.period45_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period45_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(45) := c_WAL_Rec.period45_amount;
	end if;
      end if;

      if c_WAL_Rec.period46_amount is null then
	l_period_amount(46) := null;
      else
	if 46 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(46) := ROUND((c_WAL_Rec.period46_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period46_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(46) := c_WAL_Rec.period46_amount;
	end if;
      end if;

      if c_WAL_Rec.period47_amount is null then
	l_period_amount(47) := null;
      else
	if 47 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(47) := ROUND((c_WAL_Rec.period47_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period47_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(47) := c_WAL_Rec.period47_amount;
	end if;
      end if;

      if c_WAL_Rec.period48_amount is null then
	l_period_amount(48) := null;
      else
	if 48 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(48) := ROUND((c_WAL_Rec.period48_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period48_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(48) := c_WAL_Rec.period48_amount;
	end if;
      end if;

      if c_WAL_Rec.period49_amount is null then
	l_period_amount(49) := null;
      else
	if 49 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(49) := ROUND((c_WAL_Rec.period49_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period49_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(49) := c_WAL_Rec.period49_amount;
	end if;
      end if;

      if c_WAL_Rec.period50_amount is null then
	l_period_amount(50) := null;
      else
	if 50 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(50) := ROUND((c_WAL_Rec.period50_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period50_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(50) := c_WAL_Rec.period50_amount;
	end if;
      end if;

      if c_WAL_Rec.period51_amount is null then
	l_period_amount(51) := null;
      else
	if 51 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(51) := ROUND((c_WAL_Rec.period51_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period51_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(51) := c_WAL_Rec.period51_amount;
	end if;
      end if;

      if c_WAL_Rec.period52_amount is null then
	l_period_amount(52) := null;
      else
	if 52 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(52) := ROUND((c_WAL_Rec.period52_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period52_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(52) := c_WAL_Rec.period52_amount;
	end if;
      end if;

      if c_WAL_Rec.period53_amount is null then
	l_period_amount(53) := null;
      else
	if 53 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(53) := ROUND((c_WAL_Rec.period53_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period53_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(53) := c_WAL_Rec.period53_amount;
	end if;
      end if;

      if c_WAL_Rec.period54_amount is null then
	l_period_amount(54) := null;
      else
	if 54 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(54) := ROUND((c_WAL_Rec.period54_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period54_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(54) := c_WAL_Rec.period54_amount;
	end if;
      end if;

      if c_WAL_Rec.period55_amount is null then
	l_period_amount(55) := null;
      else
	if 55 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(55) := ROUND((c_WAL_Rec.period55_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period55_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(55) := c_WAL_Rec.period55_amount;
	end if;
      end if;

      if c_WAL_Rec.period56_amount is null then
	l_period_amount(56) := null;
      else
	if 56 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(56) := ROUND((c_WAL_Rec.period56_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period56_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(56) := c_WAL_Rec.period56_amount;
	end if;
      end if;

      if c_WAL_Rec.period57_amount is null then
	l_period_amount(57) := null;
      else
	if 57 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(57) := ROUND((c_WAL_Rec.period57_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period57_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(57) := c_WAL_Rec.period57_amount;
	end if;
      end if;

      if c_WAL_Rec.period58_amount is null then
	l_period_amount(58) := null;
      else
	if 58 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(58) := ROUND((c_WAL_Rec.period58_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period58_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(58) := c_WAL_Rec.period58_amount;
	end if;
      end if;

      if c_WAL_Rec.period59_amount is null then
	l_period_amount(59) := null;
      else
	if 59 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(59) := ROUND((c_WAL_Rec.period59_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period59_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(59) := c_WAL_Rec.period59_amount;
	end if;
      end if;

      if c_WAL_Rec.period60_amount is null then
	l_period_amount(60) := null;
      else
	if 60 between PSB_WS_ACCT1.g_cy_start_index and l_last_period_index then
	l_period_amount(60) := ROUND((c_WAL_Rec.period60_amount + ((p_new_ytd_amount - p_old_ytd_amount) *
				      c_WAL_Rec.Period60_Amount / l_old_ytd_amount)) / p_rounding_factor) * p_rounding_factor;
	else
	l_period_amount(60) := c_WAL_Rec.period60_amount;
	end if;
      end if;

      l_running_total := l_running_total
		+ nvl(l_period_amount(1),0)   + nvl(l_period_amount(2),0)   + nvl(l_period_amount(3),0)   + nvl(l_period_amount(4),0)   + nvl(l_period_amount(5),0)
		+ nvl(l_period_amount(6),0)   + nvl(l_period_amount(7),0)   + nvl(l_period_amount(8),0)   + nvl(l_period_amount(9),0)   + nvl(l_period_amount(10),0)
		+ nvl(l_period_amount(11),0)  + nvl(l_period_amount(12),0)  + nvl(l_period_amount(13),0)  + nvl(l_period_amount(14),0)  + nvl(l_period_amount(15),0)
		+ nvl(l_period_amount(16),0)  + nvl(l_period_amount(17),0)  + nvl(l_period_amount(18),0)  + nvl(l_period_amount(19),0)  + nvl(l_period_amount(20),0)
		+ nvl(l_period_amount(21),0)  + nvl(l_period_amount(22),0)  + nvl(l_period_amount(23),0)  + nvl(l_period_amount(24),0)  + nvl(l_period_amount(25),0)
		+ nvl(l_period_amount(26),0)  + nvl(l_period_amount(27),0)  + nvl(l_period_amount(28),0)  + nvl(l_period_amount(29),0)  + nvl(l_period_amount(30),0)
		+ nvl(l_period_amount(31),0)  + nvl(l_period_amount(32),0)  + nvl(l_period_amount(33),0)  + nvl(l_period_amount(34),0)  + nvl(l_period_amount(35),0)
		+ nvl(l_period_amount(36),0)  + nvl(l_period_amount(37),0)  + nvl(l_period_amount(38),0)  + nvl(l_period_amount(39),0)  + nvl(l_period_amount(40),0)
		+ nvl(l_period_amount(41),0)  + nvl(l_period_amount(42),0)  + nvl(l_period_amount(43),0)  + nvl(l_period_amount(44),0)  + nvl(l_period_amount(45),0)
		+ nvl(l_period_amount(46),0)  + nvl(l_period_amount(47),0)  + nvl(l_period_amount(48),0)  + nvl(l_period_amount(49),0)  + nvl(l_period_amount(50),0)
		+ nvl(l_period_amount(51),0)  + nvl(l_period_amount(52),0)  + nvl(l_period_amount(53),0)  + nvl(l_period_amount(54),0)  + nvl(l_period_amount(55),0)
		+ nvl(l_period_amount(56),0)  + nvl(l_period_amount(57),0)  + nvl(l_period_amount(58),0)  + nvl(l_period_amount(59),0)  + nvl(l_period_amount(60),0);

    end loop;

    /* Bug 3133240 Start */
    --Added the IF condition

    IF l_last_period_index > 0 THEN
    	l_period_amount(l_last_period_index) := l_period_amount(l_last_period_index) + p_new_ytd_amount - l_running_total;
    END IF;

    /* Bug 3133240 End */

  end;
  end if;

  -- Call Create_Account_Dist to update Period Amounts for the Account Line

  PSB_WS_ACCT1.Create_Account_Dist
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id,
      p_account_line_id => p_account_line_id,
      p_check_stages => FND_API.G_FALSE,
      p_ytd_amount => l_ytd_amount,
      p_period_amount => l_period_amount,
      p_service_package_id => p_service_package_id,
      p_current_stage_seq => p_current_stage_seq);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Distribute_Account_Lines');
     end if;

END Distribute_Account_Lines;

/* ----------------------------------------------------------------------- */

PROCEDURE Insert_Summary_Accounts
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_rounding_factor     IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_current_stage_seq   IN   NUMBER,
  p_set_of_books_id     IN   NUMBER,
  p_flex_code           IN   NUMBER,
  p_budget_group_id     IN   NUMBER,
  p_budget_calendar_id  IN   NUMBER
) IS

  first_time            BOOLEAN;

  l_period_amount       PSB_WS_ACCT1.g_prdamt_tbl_type;

  sql_sumbgroup         VARCHAR2(1000);
  cur_sumbgroup         INTEGER;
  num_sumbgroup         INTEGER;

  l_bgroup_id           NUMBER;
  l_parentbgroup_id     NUMBER;
  l_root_budget_group   VARCHAR2(1);

  l_bgroups_tbl         g_budgetgroup_tbl_type;
  l_num_pbgroups        NUMBER;

  l_index               PLS_INTEGER;
  l_init_index          PLS_INTEGER;
  l_bgroups_index       PLS_INTEGER;
  l_search_index        PLS_INTEGER;

  l_parent_found        BOOLEAN;

  l_account_line_id     NUMBER;

  l_num_accounts        NUMBER := 0;
  l_return_status       VARCHAR2(1);
  l_msg_data            VARCHAR2(2000);
  l_msg_count           NUMBER;

  l_api_name       CONSTANT  VARCHAR2(30) := 'Insert_Summary_Accounts';

  -- This cursor sums up the detailed account balances for each summary account
  -- following the mapping in GL_ACCOUNT_HIERARCHIES


  -- Bug 4474717.
  -- Replaced set_of_books_id with ledger_id
  -- in the following cursor.

  cursor c_SumCCID is
    select a.summary_code_combination_id,
	   a.template_id,
	   b.service_package_id,
	   b.start_stage_seq,
	   b.budget_year_id,
	   b.currency_code,
	   b.balance_type,
	   sum(nvl(b.annual_fte, 0)) annual_fte,
	   sum(nvl(b.ytd_amount, 0)) ytd_amount,
	   sum(nvl(b.period1_amount, 0)) p1_amt,
	   sum(nvl(b.period2_amount, 0)) p2_amt,
	   sum(nvl(b.period3_amount, 0)) p3_amt,
	   sum(nvl(b.period4_amount, 0)) p4_amt,
	   sum(nvl(b.period5_amount, 0)) p5_amt,
	   sum(nvl(b.period6_amount, 0)) p6_amt,
	   sum(nvl(b.period7_amount, 0)) p7_amt,
	   sum(nvl(b.period8_amount, 0)) p8_amt,
	   sum(nvl(b.period9_amount, 0)) p9_amt,
	   sum(nvl(b.period10_amount, 0)) p10_amt,
	   sum(nvl(b.period11_amount, 0)) p11_amt,
	   sum(nvl(b.period12_amount, 0)) p12_amt
      from GL_ACCOUNT_HIERARCHIES a,
	   PSB_WS_ACCOUNT_LINES b,
	   PSB_SUMMARY_TEMPLATES c
     where a.detail_code_combination_id = b.code_combination_id
       and a.template_id = c.template_id
       and a.ledger_id       = p_set_of_books_id
       and p_current_stage_seq between b.start_stage_seq and b.current_stage_seq
       and b.template_id is null
       and c.set_of_books_id = p_set_of_books_id
       and exists
	  (select 1
	     from PSB_BUDGET_GROUPS f
	    where f.budget_group_id = b.budget_group_id
	      and (f.budget_group_id = p_budget_group_id or f.root_budget_group_id = p_budget_group_id))
       and exists
	  (select 1
	     from PSB_WS_LINES
	    where account_line_id = b.account_line_id
	      and worksheet_id = p_worksheet_id)
       and exists
	  (select 1
	     from PSB_BUDGET_PERIODS d
	    where d.budget_calendar_id = p_budget_calendar_id
	      and d.budget_period_type = 'Y'
	      and d.start_date >= c.effective_start_date
	      and b.budget_year_id = d.budget_period_id)
     group by a.summary_code_combination_id,
	      a.template_id,
	      b.service_package_id,
	      b.start_stage_seq,
	      b.budget_year_id,
	      b.currency_code,
	      b.balance_type;

  -- Find the distinct budget groups for the detailed CCIDs that map to the
  -- summary CCID

  cursor c_DtlCCID (SumCCID NUMBER,
		    TemplateID NUMBER,
		    YearID NUMBER) is
    select distinct a.budget_group_id
      from PSB_WS_ACCOUNT_LINES a,
	   GL_ACCOUNT_HIERARCHIES b
     where p_current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.code_combination_id = b.detail_code_combination_id
       and a.budget_year_id = YearID
       /*For Bug No : 2586618 Start*/
       and a.template_id is null
       and exists (select 1
		     from PSB_WS_LINES
		    where account_line_id = a.account_line_id
		      and worksheet_id = p_worksheet_id)
       /*For Bug No : 2586618 End*/
       and b.summary_code_combination_id = SumCCID
       and b.template_id = TemplateID;

BEGIN

  g_summary_ccid := 0;--bug:6374881

  for c_SumCCID_Rec in c_SumCCID loop

    -- Determine Budget Group for each Summary CCID. This loop assumes that the Budget Group
    -- for a Summary CCID will remain the same for all Budget Years. Need an efficient way
    -- to determine if Budget Group for Summary CCID changes across Budget Years

    if c_SumCCID_Rec.summary_code_combination_id <> nvl(g_summary_ccid, FND_API.G_MISS_NUM) then
    begin

      g_summary_ccid := c_SumCCID_Rec.summary_code_combination_id;

      first_time := TRUE;

      for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
	l_period_amount(l_init_index) := 0;
      end loop;

      for l_init_index in 1..l_bgroups_tbl.Count loop
	l_bgroups_tbl(l_init_index) := null;
      end loop;

      l_bgroups_index := 0;

      -- Populate l_bgroups_tbl with the distinct Budget Groups for all the detailed CCIDs
      -- that are mapped to a summary CCID. The Budget Group for the summary CCID is the
      -- Budget Group at the lowest common level in the Budget Group Hierarchy that covers
      -- the Budget Groups for the detailed CCIDs

      for c_DtlCCID_Rec in c_DtlCCID (c_SumCCID_Rec.summary_code_combination_id,
				      c_SumCCID_Rec.template_id,
				      c_SumCCID_Rec.budget_year_id) loop

	if first_time then
	  l_bgroup_id := c_DtlCCID_Rec.budget_group_id;
	  first_time := FALSE;
	end if;

	if c_DtlCCID_Rec.budget_group_id <> l_bgroup_id then
	  l_bgroups_index := l_bgroups_index + 1;
	  l_bgroups_tbl(l_bgroups_index) := c_DtlCCID_Rec.budget_group_id;
	end if;

      end loop;

      -- Loop thru l_bgroups_tbl to find the lowest common Budget Group in the
      -- Budget Group Hierarchy that covers the Budget Groups for all the
      -- detailed CCIDs. If no such Budget Group is found, the root Budget Group
      -- is assigned to the Summary CCID

      if l_bgroups_index > 0 then
      begin

	l_bgroups_index := l_bgroups_index + 1;
	l_bgroups_tbl(l_bgroups_index) := l_bgroup_id;

	sql_sumbgroup := 'select parent_budget_group_id, ' ||
				'root_budget_group ' ||
			   'from psb_budget_groups ' ||
			  'where budget_group_id = :budget_group_id';

	cur_sumbgroup := dbms_sql.open_cursor;
	dbms_sql.parse(cur_sumbgroup, sql_sumbgroup, dbms_sql.v7);

	l_parent_found := FALSE;
	l_num_pbgroups := l_bgroups_index;

	while l_num_pbgroups > 1 loop

	  for l_index in 1..l_bgroups_index loop

	    if l_bgroups_tbl(l_index) is not null then
	    begin

	      dbms_sql.bind_variable(cur_sumbgroup, ':budget_group_id', l_bgroups_tbl(l_index));

	      dbms_sql.define_column(cur_sumbgroup, 1, l_parentbgroup_id);
	      dbms_sql.define_column(cur_sumbgroup, 2, l_root_budget_group, 1);

	      num_sumbgroup := dbms_sql.execute(cur_sumbgroup);

	      loop

		if dbms_sql.fetch_rows(cur_sumbgroup) = 0 then
		  exit;
		end if;

		dbms_sql.column_value(cur_sumbgroup, 1, l_parentbgroup_id);
		dbms_sql.column_value(cur_sumbgroup, 2, l_root_budget_group);

		if l_root_budget_group = 'Y' then
		  l_bgroup_id := l_bgroups_tbl(l_index);
		  exit;
		else
		begin

		  for l_search_index in 1..l_bgroups_index loop

		    if ((l_bgroups_tbl(l_search_index) is not null) and
			(l_bgroups_tbl(l_search_index) = l_parentbgroup_id)) then
		      l_parent_found := TRUE;
		      exit;
		    end if;

		  end loop;

		  if l_parent_found then
		    l_bgroups_tbl(l_index) := null;
		    l_num_pbgroups := l_num_pbgroups - 1;
		  else
		    l_bgroups_tbl(l_index) := l_parentbgroup_id;
		  end if;

		end;
		end if;

	      end loop;

	      if l_root_budget_group = 'Y' then
		l_num_pbgroups := 1;
		exit;
	      end if;

	    end;
	    end if;

	  end loop;

	end loop;

	for l_index in 1..l_bgroups_tbl.Count loop

	  if l_bgroups_tbl(l_index) is not null then
	    l_bgroup_id := l_bgroups_tbl(l_index);
	  end if;

	end loop;

	dbms_sql.close_cursor(cur_sumbgroup);

      end;
      end if;

      g_summ_bgroup_id := l_bgroup_id;

    end;
    end if;


    -- Insert into WS Account Distributions

    l_period_amount(1) := c_SumCCID_Rec.p1_amt; l_period_amount(2) := c_SumCCID_Rec.p2_amt;
    l_period_amount(3) := c_SumCCID_Rec.p3_amt; l_period_amount(4) := c_SumCCID_Rec.p4_amt;
    l_period_amount(5) := c_SumCCID_Rec.p5_amt; l_period_amount(6) := c_SumCCID_Rec.p6_amt;
    l_period_amount(7) := c_SumCCID_Rec.p7_amt; l_period_amount(8) := c_SumCCID_Rec.p8_amt;
    l_period_amount(9) := c_SumCCID_Rec.p9_amt; l_period_amount(10) := c_SumCCID_Rec.p10_amt;
    l_period_amount(11) := c_SumCCID_Rec.p11_amt; l_period_amount(12) := c_SumCCID_Rec.p12_amt;

    -- Create Account Distributions for the Summary CCID
    PSB_WS_ACCT1.Create_Account_Dist
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_account_line_id => l_account_line_id,
	p_worksheet_id => p_worksheet_id,
	p_service_package_id => c_SumCCID_Rec.service_package_id,
	p_check_spal_exists => FND_API.G_FALSE,
	p_gl_cutoff_period => null,
	p_allocrule_set_id => null,
	p_budget_calendar_id => null,
	p_rounding_factor => p_rounding_factor,
	p_stage_set_id => p_stage_set_id,
	p_start_stage_seq => c_SumCCID_Rec.start_stage_seq,
	p_current_stage_seq => p_current_stage_seq,
	p_budget_group_id => g_summ_bgroup_id,
	p_budget_year_id => c_SumCCID_Rec.budget_year_id,
	p_ccid => c_SumCCID_Rec.summary_code_combination_id,
	p_template_id => c_SumCCID_Rec.template_id,
	p_currency_code => c_SumCCID_Rec.currency_code,
	p_balance_type => c_SumCCID_Rec.balance_type,
	p_annual_fte => c_SumCCID_Rec.annual_fte,
	p_ytd_amount => c_SumCCID_Rec.ytd_amount,
	p_period_amount => l_period_amount);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    l_num_accounts := l_num_accounts + 1;

    if l_num_accounts > PSB_WS_ACCT1.g_checkpoint_save then
      commit work;
      l_num_accounts := 0;
    end if;

  end loop;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION


   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);


   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if dbms_sql.is_open(cur_sumbgroup) then
       dbms_sql.close_cursor(cur_sumbgroup);
     end if;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data  => l_msg_data);

END Insert_Summary_Accounts;

/* ----------------------------------------------------------------------- */

-- Create Summary Totals for the detailed Accounting Lines using the
-- templates specified in PSB

PROCEDURE Create_Rollup_Totals
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_rounding_factor     IN   NUMBER := FND_API.G_MISS_NUM,
  p_stage_set_id        IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER := FND_API.G_MISS_NUM,
  p_set_of_books_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_flex_code           IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id  IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_Rollup_Totals';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_year_index          PLS_INTEGER;

  l_budget_group_id     NUMBER;
  l_stage_set_id        NUMBER;
  l_current_stage_seq   NUMBER;
  l_budget_calendar_id  NUMBER;
  l_rounding_factor     NUMBER;

  l_set_of_books_id     NUMBER;
  l_flex_code           NUMBER;

  l_return_status       VARCHAR2(1);
  l_msg_data            VARCHAR2(2000);
  l_msg_count           NUMBER;

  cursor c_WS is
    select budget_group_id,
	   stage_set_id,
	   current_stage_seq,
	   budget_calendar_id,
	   rounding_factor
      from PSB_WORKSHEETS
     where worksheet_id = p_worksheet_id;

  cursor c_BG is
    select nvl(set_of_books_id, root_set_of_books_id) set_of_books_id,
	   nvl(chart_of_accounts_id, root_chart_of_accounts_id) chart_of_accounts_id
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = l_budget_group_id;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Delete all Summary Account Lines from PSB_WS_ACCOUNT_LINES to obviate any changes
  -- to the Summary Account - Detailed Account mappings in GL

  PSB_WORKSHEET.Delete_Summary_Lines
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Select default values for input parameters that were not passed in

  if ((p_budget_group_id = FND_API.G_MISS_NUM) or
      (p_stage_set_id = FND_API.G_MISS_NUM) or
      (p_current_stage_seq = FND_API.G_MISS_NUM) or
      (p_budget_calendar_id = FND_API.G_MISS_NUM) or
      (p_rounding_factor = FND_API.G_MISS_NUM)) then
  begin

    for c_WS_Rec in c_WS loop
      l_budget_group_id := c_WS_Rec.budget_group_id;
      l_stage_set_id := c_WS_Rec.stage_set_id;
      l_current_stage_seq := c_WS_Rec.current_stage_seq;
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
      l_rounding_factor := c_WS_Rec.rounding_factor;
    end loop;

  end;
  end if;

  if p_budget_group_id <> FND_API.G_MISS_NUM then
    l_budget_group_id := p_budget_group_id;
  end if;

  if p_stage_set_id <> FND_API.G_MISS_NUM then
    l_stage_set_id := p_stage_set_id;
  end if;

  if p_current_stage_seq <> FND_API.G_MISS_NUM then
    l_current_stage_seq := p_current_stage_seq;
  end if;

  if p_budget_calendar_id <> FND_API.G_MISS_NUM then
    l_budget_calendar_id := p_budget_calendar_id;
  end if;

  if p_rounding_factor <> FND_API.G_MISS_NUM then
    l_rounding_factor := p_rounding_factor;
  end if;

  if ((p_set_of_books_id = FND_API.G_MISS_NUM) or
      (p_flex_code = FND_API.G_MISS_NUM)) then
  begin

    for c_BG_Rec in c_BG loop
      l_set_of_books_id := c_BG_Rec.set_of_books_id;
      l_flex_code := c_BG_Rec.chart_of_accounts_id;
    end loop;

  end;
  end if;

  if p_set_of_books_id <> FND_API.G_MISS_NUM then
    l_set_of_books_id := p_set_of_books_id;
  end if;

  if p_flex_code <> FND_API.G_MISS_NUM then
    l_flex_code := p_flex_code;
  end if;

  Insert_Summary_Accounts
	(p_worksheet_id => p_worksheet_id,
	 p_rounding_factor => l_rounding_factor,
	 p_stage_set_id => l_stage_set_id,
	 p_current_stage_seq => l_current_stage_seq,
	 p_set_of_books_id => l_set_of_books_id,
	 p_flex_code => l_flex_code,
	 p_budget_group_id => l_budget_group_id,
	 p_budget_calendar_id => l_budget_calendar_id,
	 p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     --
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);
END Create_Rollup_Totals;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
FUNCTION Get_Debug RETURN VARCHAR2 IS
BEGIN
  return(g_dbug);
END Get_Debug;
/*---------------------------------------------------------------------------*/

/* start bug 4256345 */
PROCEDURE check_ccid_bal (x_return_status      out nocopy varchar2,
                          p_gl_budget_set_id   in  number)
IS

CURSOR l_ccid_csr
IS
  SELECT code_combination_id
  FROM  psb_budget_accounts a,
        psb_set_relations r,
        psb_gl_budgets b,
        psb_gl_budget_sets c
  WHERE c.gl_budget_set_id  = p_gl_budget_set_id
  AND   c.gl_budget_set_id = b.gl_budget_set_id
  AND   b.gl_budget_id = r.gl_budget_id
  AND   r.account_position_set_id = a.account_position_set_id;

  -- declate a local table variable
  -- populate it using bulk fetch and then populate the global pl/sql table variable
  -- using a loop
  -- local variable (pl/sql table)
  l_ws_gl_budget_set_ccids g_bud_ccid_tbl_type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- clear the table before data is stored into the table
  IF g_ws_gl_budget_set_ccids.count > 0 THEN
    g_ws_gl_budget_set_ccids.delete;
  END IF;

  -- clear the local table also
  IF l_ws_gl_budget_set_ccids.COUNT > 0 THEN
    l_ws_gl_budget_set_ccids.DELETE;
  END IF;

  -- check if the cursor is open
  IF l_ccid_csr%ISOPEN THEN
    CLOSE l_ccid_csr;
  END IF;

  -- bulk collect the CCIDs into the pl/sql table
  OPEN l_ccid_csr;
  FETCH l_ccid_csr BULK COLLECT INTO l_ws_gl_budget_set_ccids;
  CLOSE l_ccid_csr;

  -- store ccids as index to the pl/sql table
  FOR loop_var in 1..l_ws_gl_budget_set_ccids.COUNT LOOP
    g_ws_gl_budget_set_ccids(l_ws_gl_budget_set_ccids(loop_var)) := l_ws_gl_budget_set_ccids(loop_var);
  END LOOP;

  -- commented as we are using a local pl/sql tabe
  /* FOR l_ccid_rec in l_ccid_csr LOOP
      g_ws_gl_budget_set_ccids(l_ccid_rec.code_combination_id) := l_ccid_rec.code_combination_id;
     END LOOP; */


EXCEPTION
  WHEN others THEN
    fnd_file.put_line(fnd_file.log, sqlerrm);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- close the cursor if open
    IF l_ccid_csr%ISOPEN THEN
      CLOSE l_ccid_csr;
    END IF;
END;
/* end bug 4256345 */

END PSB_WS_ACCT2;

/
