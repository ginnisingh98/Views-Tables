--------------------------------------------------------
--  DDL for Package Body FV_FUNDS_AVAILABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FUNDS_AVAILABLE_PKG" AS
--$Header: FVIFUNDB.pls 120.14.12010000.3 2009/06/17 16:39:17 sharoy ship $
--	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
  g_module_name VARCHAR2(100) := 'fv.plsql.fv_funds_available_pkg.';


/*******************************************************************/
/*****        Variable Declaration For All Processes          ******/
/*******************************************************************/
v_budget        fv_fund_parameters.budget_authority%TYPE;
v_commitment    fv_fund_parameters.unliquid_commitments%TYPE;
v_obligation    fv_fund_parameters.unliquid_obligations%TYPE;
v_expenditure   fv_fund_parameters.expended_amount%TYPE;
v_transfers_in   fv_fund_parameters.transfers_in%TYPE;
v_transfers_out   fv_fund_parameters.transfers_out%TYPE;
v_delimiter	fnd_id_flex_structures.concatenated_segment_delimiter%TYPE;
v_fund_value    fv_fund_parameters.fund_value%TYPE;
v_acct_seg_name varchar2(30);
v_bal_seg_name  varchar2(30);
bud_authority_type varchar2(50);

--Changed treasury_symbol to treasury_symbol_id #Bug :1575992
v_treasury_symbol_id   fv_treasury_symbols.treasury_symbol_id%TYPE;
temp_v_treasury_symbol_id varchar2(20) ; --Bug 1575992
v_statement      varchar2(100);
err_message     varchar2(300);
acct_flex_id    fnd_flex_values.flex_value_id%TYPE;
v_ca_id		gl_ledgers_public_v.chart_of_accounts_id%TYPE;
bud_child_value_low	 fnd_flex_value_hierarchies.child_flex_value_low%TYPE;
bud_child_value_high	 fnd_flex_value_hierarchies.child_flex_value_high%TYPE;
spd_child_value_low	 fnd_flex_value_hierarchies.child_flex_value_low%TYPE;
spd_child_value_high	 fnd_flex_value_hierarchies.child_flex_value_high%TYPE;
x_period_num    gl_period_statuses.period_num%TYPE;
v_segment_low_name  number;
v_segment_num       number;
v_segment_low_value varchar2(25);
v_segment_high_name  number;
v_segment_high_value varchar2(25);
v_child_budget  number;
v_child_obligations number;
v_child_commitments number;
v_child_expenditure number;
v_child_transfers_in number;
v_child_transfers_out number;
v_delim_occur   number;
v_diff       	number;
v_substr_to	number;
v_substr_from	number;
v_last_seg      number;
parent_flag     varchar2(1);
rollup_type     varchar2(1);
v_compiled_value varchar2(1);
bal_seg_name_num number(2);
acct_ff_low     varchar2(2000);
acct_ff_high	varchar2(2000);
tot_budget_bal  number;
tot_budget_packet number;
budget_bal      number;
budget_packet   number;
tot_transfers_bal  number;
tot_transfers_packet number;
transfers_bal      number;
transfers_packet   number;
x_transfers_in  number;
x_transfers_out number;
x_budget	number;
segment_2       varchar2(25);
segment_3       varchar2(25);
segment_4       varchar2(25);
segment_5       varchar2(25);
segment_6       varchar2(25);
segment_7       varchar2(25);
acct_seg_name_num number(2);
--sob_id          gl_balances.set_of_books_id%TYPE;
sob_id          gl_balances.ledger_id%TYPE;
curr_code       gl_balances.currency_code%TYPE;
pd_name         gl_balances.period_name%TYPE;
v_period_year   gl_period_statuses.period_year%TYPE;
v_period_status gl_period_statuses.closing_status%TYPE;
v_effective_period_num gl_period_statuses.effective_period_num%TYPE;


g_curr_code       gl_balances.currency_code%TYPE;

TYPE t_segment_name_table IS TABLE OF varchar2(25)
  INDEX BY BINARY_INTEGER;
v_segment_name t_segment_name_table;

TYPE t_value_low_table IS TABLE OF varchar2(25)
  INDEX BY BINARY_INTEGER;
v_value_low t_value_low_table;

TYPE t_value_high_table IS TABLE OF varchar2(25)
  INDEX BY BINARY_INTEGER;
v_value_high t_value_high_table;

CURSOR c_segment_info
    IS
SELECT UPPER(application_column_name) application_column_name
  FROM fnd_id_flex_segments
 WHERE application_id = 101
   AND id_flex_code   = 'GL#'
   AND id_flex_num    = v_ca_id
 ORDER BY segment_num;

--Changed from treasury_symbol to treasury_symbol_id #Bug:1575992
--Changed from v_treasury_symbol_id to temp_v_treasury_symbol_id for BUG 1575992
CURSOR c_treasury_fund_values
     IS
 SELECT fp.fund_value,
	fp.budget_authority,
	fp.unliquid_commitments,
        fp.unliquid_obligations,
	fp.expended_amount,
	fp.transfers_in,
	fp.transfers_out
   FROM   fv_fund_parameters fp
  WHERE fp.set_of_books_id = sob_id
     and decode(rollup_type,'F',fp.fund_value,'T',treasury_symbol_id)
     between decode(rollup_type,
          'T',temp_v_treasury_symbol_id,
          'F',nvl(v_value_low(bal_seg_name_num),v_value_high(bal_seg_name_num))
               ) --fund segment
     and decode(rollup_type,
          'T',temp_v_treasury_symbol_id,
          'F',nvl(v_value_high(bal_seg_name_num),v_value_low(bal_seg_name_num))
              ); --fund segment


/******************************************************************/
/* This procedure sums the spending accounts for the account      */
/* passed to it.                                                  */
/******************************************************************/
PROCEDURE sum_children_spending
 (v_parent_value    IN fnd_flex_values.flex_value%TYPE,
  parent_value_id   IN fnd_flex_values.flex_value_id%TYPE,
  grand_total       OUT NOCOPY number)

IS
  l_module_name VARCHAR2(200) := g_module_name || 'sum_children_spending';
 balances     number;
 packets      number;
 tot_balances number;

 v_bal_stmt VARCHAR2(5000) := NULL;
 v_pac_stmt VARCHAR2(5000) := NULL;

 tot_packets  number;

 CURSOR c_parent_value_spending  IS
   SELECT child_flex_value_low, child_flex_value_high
     FROM fnd_flex_value_hierarchies
    WHERE parent_flex_value = v_parent_value
      AND flex_value_set_id = parent_value_id;
BEGIN

 -- initialize totals
 tot_balances := 0;
 tot_packets  := 0;
 balances     := 0;
 packets      := 0;
 grand_total  := 0;
 parent_flag  := 'N';

 OPEN  c_parent_value_spending;
 LOOP
  FETCH c_parent_value_spending into v_value_low(acct_seg_name_num),
          			     v_value_high(acct_seg_name_num);
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SP CHILD_LOW = '||V_VALUE_LOW(ACCT_SEG_NAME_NUM));
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SP CHILD_HIGH = '||V_VALUE_HIGH(ACCT_SEG_NAME_NUM));
  END IF;

 v_bal_stmt := NULL;
 v_pac_stmt := NULL;

 v_bal_stmt :=
        ' SELECT  sum((nvl(glb.begin_balance_dr,0) - nvl(glb.begin_balance_cr,0)) +
                         (nvl(glb.period_net_dr,0) - nvl(glb.period_net_cr,0)))
          FROM    gl_balances glb,
                  gl_code_combinations      glc
   	  WHERE    glb.code_combination_id = glc.code_combination_id
   	  AND      glc.chart_of_accounts_id     = ' ||v_ca_id ||
  	' AND      glb.ledger_id          = '|| sob_id ||
   	' AND      glb.currency_code            = '||''''|| curr_code ||''''||
   	' AND      glb.actual_flag              = ''A''
   	  AND      glc.enabled_flag             = ''Y''
   	  AND      glc.template_id  IS NULL
   	  AND      glb.period_name              = '||''''||pd_name||'''' ||
    ' AND      FV_BE_UTIL_PKG.has_segments_access( NULL, glc.code_combination_id ,
                                                glc.chart_of_accounts_id ,'
                                                || sob_id || ') = ''TRUE''' ;

 v_pac_stmt :=
        ' SELECT sum(nvl(accounted_dr,0) - nvl(accounted_cr,0))
          FROM   gl_bc_packets pac,
      	         gl_code_combinations glc
    	  WHERE pac.code_combination_id = glc.code_combination_id
   	  AND   glc.chart_of_accounts_id  = '|| v_ca_id ||
   	  ' AND glc.template_id  IS NULL
   	  AND   pac.ledger_id     = '|| sob_id ||
   	  ' AND pac.currency_code       = '||''''||curr_code||''''||
   	  ' AND pac.actual_flag         = ''A''
   	  AND   pac.status_code         in (''A'',''P'')
	  AND   pac.result_code like ''P%''
   	  AND   glc.enabled_flag        = ''Y''
   	  AND   period_year             = '||''''||v_period_year||''''||
   	  ' AND period_num between 1 and '||x_period_num ||
      ' AND FV_BE_UTIL_PKG.has_segments_access( NULL, glc.code_combination_id ,
                                                glc.chart_of_accounts_id  ,'
                                                || sob_id || ') = ''TRUE''' ;


  IF c_parent_value_spending%FOUND THEN
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BAL_SEG_NAME = '||BAL_SEG_NAME_NUM);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SEGMENT2= '||SEGMENT_2);
    END IF;

    FOR app_col_name IN c_segment_info
      LOOP
        v_bal_stmt := v_bal_stmt||' AND '||app_col_name.application_column_name||' BETWEEN '||
   ''''||NVL(v_value_low(substr(app_col_name.application_column_name,8,2)),'0')||''''||' AND '||
         ''''||NVL(v_value_high(substr(app_col_name.application_column_name,8,2)),'zzzzzzzzzzzzzzzzzzzzzzzzz')||'''';
      END LOOP;

	EXECUTE IMMEDIATE v_bal_stmt INTO balances;

    tot_balances :=  nvl(tot_balances,0) + nvl(balances,0);

    FOR app_col_name IN c_segment_info
      LOOP
        v_pac_stmt := v_pac_stmt||' AND '||app_col_name.application_column_name||' BETWEEN '||
   ''''||NVL(v_value_low(substr(app_col_name.application_column_name,8,2)),'0')||''''||' AND '||
         ''''||NVL(v_value_high(substr(app_col_name.application_column_name,8,2)),'zzzzzzzzzzzzzzzzzzzzzzzzz')||'''';

      END LOOP;

	EXECUTE IMMEDIATE v_pac_stmt INTO packets;

    tot_packets := nvl(tot_packets,0) + nvl(packets,0);

    parent_flag := 'Y';
  ELSIF c_parent_value_spending%NOTFOUND THEN
    -- no child record found
    IF parent_flag = 'N' THEN
       -- since there are no children assign account to high and low
       v_value_low(acct_seg_name_num) := v_parent_value;
       v_value_high(acct_seg_name_num) := v_parent_value;

    FOR app_col_name IN c_segment_info
      LOOP
        v_bal_stmt := v_bal_stmt||' AND '||app_col_name.application_column_name||' BETWEEN '||
   ''''||NVL(v_value_low(substr(app_col_name.application_column_name,8,2)),'0')||''''||' AND '||
         ''''||NVL(v_value_high(substr(app_col_name.application_column_name,8,2)),'zzzzzzzzzzzzzzzzzzzzzzzzz')||'''';

      END LOOP;

	EXECUTE IMMEDIATE v_bal_stmt INTO tot_balances;

    FOR app_col_name IN c_segment_info
      LOOP
        v_pac_stmt := v_pac_stmt||' AND '||app_col_name.application_column_name||' BETWEEN '||
   ''''||NVL(v_value_low(substr(app_col_name.application_column_name,8,2)),'0')||''''||' AND '||
         ''''||NVL(v_value_high(substr(app_col_name.application_column_name,8,2)),'zzzzzzzzzzzzzzzzzzzzzzzzz')||'''';

      END LOOP;

        EXECUTE IMMEDIATE v_pac_stmt INTO tot_packets;

    END IF;
    exit;
  END IF;
END LOOP;
CLOSE c_parent_value_spending;

begin
  select substr(compiled_value_attributes,5,1)
  into v_compiled_value
  from fnd_flex_values
  where flex_value = v_parent_value
  and flex_value_set_id = parent_value_id;
  if (v_compiled_value = 'C') then
    grand_total := (nvl(tot_balances,0) + nvl(tot_packets,0))*-1;
  else
    grand_total := (nvl(tot_balances,0) + nvl(tot_packets,0));
  end if;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      grand_total := (nvl(tot_balances,0) + nvl(tot_packets,0));
end;
IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TOT_BAL = '||TOT_BALANCES);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TOT_PACK = '||TOT_PACKETS);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    err_message  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',err_message) ;
    RAISE;

END sum_children_spending;

/******************************************************************/
/* This function finds the flex_value_id for the account being processed.*/
/******************************************************************/
FUNCTION get_flex_value_id(v_flex_value fnd_flex_values.flex_value%TYPE)
  return number
IS
  l_module_name VARCHAR2(200) := g_module_name || 'get_flex_value_id';
  v_flex_value_id fnd_flex_values.flex_value_id%TYPE;
BEGIN
  v_statement := 'L';
  SELECT flex_value_set_id
    INTO  v_flex_value_id
    FROM fnd_id_flex_segments_vl
   WHERE id_flex_num = v_ca_id
     AND application_id = 101
     AND id_flex_code   = 'GL#'
     AND application_column_name = v_acct_seg_name;

RETURN v_flex_value_id;
EXCEPTION
   when others then
     err_message := 'GET_FLEX_VALUE_ID.L.'||sqlerrm;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',err_message) ;
     app_exception.raise_exception;
END get_flex_value_id;

/******************************************************************/
/* This procedure parses the account flexfield low range using the*/
/* substringed segment name as the index.                         */
/******************************************************************/
PROCEDURE find_low_values
IS
  l_module_name VARCHAR2(200) := g_module_name || 'find_low_values';
BEGIN
 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BEGIN FIND_LOW_VALUES');
 END IF;
 -- delete all segments in table
 FOR v_segment_low_name IN 1..30 LOOP
   v_value_low(v_segment_low_name) := null;
 END LOOP;

 -- set counter to 1
 v_delim_occur := 1;

 v_diff := 0;

 FOR low_segment_info_rec IN c_segment_info LOOP
  v_segment_low_name :=
      to_number(substr(low_segment_info_rec.application_column_name,8,2));
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_SEGMENT_LOW_NAME = '||V_SEGMENT_LOW_NAME);
  END IF;

  IF v_delim_occur = 1 THEN
    -- first time through

    v_statement := 'D';
    SELECT instr(acct_ff_low,v_delimiter,1,1)
      INTO v_substr_to
      FROM dual;
    -- find position of first delimiter

    v_statement := 'E';
    SELECT substr(acct_ff_low,1,v_substr_to - 1)
      INTO v_segment_low_value
      FROM dual;
    -- get first segment value

    v_value_low(v_segment_low_name) := v_segment_low_value;
    -- assign value to table
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_VALUE_LOW = '||V_VALUE_LOW(V_SEGMENT_LOW_NAME));
    END IF;

    v_delim_occur := v_delim_occur + 1;
  ELSE

    v_statement := 'F';
    SELECT instr(acct_ff_low,v_delimiter,1,v_delim_occur)
      INTO v_substr_from
      FROM dual;
    -- find position of delimiter occurance

    v_diff := v_substr_from - v_substr_to;
--bug 7534611. changed the condition from = to < and find value for last segment

    IF v_diff < 0 THEN
      -- this is the last delimiter

        v_last_seg := length(acct_ff_low) - v_substr_to;
        v_value_low(v_segment_low_name) := substr(acct_ff_low,-1 * v_last_seg,v_last_seg);
      --v_value_low(v_segment_low_name) := null;
    ELSIF v_diff = 1 THEN
      -- if = 1 then no value in segment so null
      v_value_low(v_segment_low_name) := null;
    ELSE

      v_statement := 'G';
      SELECT substr(acct_ff_low,v_substr_to + 1,v_diff - 1)
        INTO v_segment_low_value
        FROM dual;
      -- find value of segment

      v_value_low(v_segment_low_name) := v_segment_low_value;
    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_VALUE_LOW = '||V_VALUE_LOW(V_SEGMENT_LOW_NAME));
    END IF;
    v_substr_to := v_substr_from;
    v_delim_occur := v_delim_occur + 1;
  END IF;
END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    err_message  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',err_message) ;
    RAISE;
END find_low_values;

/******************************************************************/
/* This procedure parses the account flexfield high range using the*/
/* substringed segment name as the index.                         */
/******************************************************************/
PROCEDURE find_high_values
IS
  l_module_name VARCHAR2(200) := g_module_name || 'find_high_values';
BEGIN
 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FIND_HIGH_VALUES');
 END IF;
 -- delete all segments in table
 FOR v_segment_high_name IN 1..30 LOOP
   v_value_high(v_segment_high_name) := null;
 END LOOP;

 -- set counter to 1
 v_delim_occur := 1;

 v_diff := 0;

 FOR high_segment_info_rec IN c_segment_info LOOP
  v_segment_high_name :=
      to_number(substr(high_segment_info_rec.application_column_name,8,2));
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_SEGMENT_HIGH_NAME = '||V_SEGMENT_HIGH_NAME);
  END IF;

  IF v_delim_occur = 1 THEN
    -- first time through

    v_statement := 'H';
    SELECT instr(acct_ff_high,v_delimiter,1,1)
      INTO v_substr_to
      FROM dual;
    -- find position of first delimiter

    v_statement := 'I';
    SELECT substr(acct_ff_high,1,v_substr_to - 1)
      INTO v_segment_high_value
      FROM dual;
    -- get first segment value

    v_value_high(v_segment_high_name) := v_segment_high_value;
    -- assign value to table
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_VALUE_HIGH = '||V_VALUE_HIGH(V_SEGMENT_HIGH_NAME));
    END IF;

    v_delim_occur := v_delim_occur + 1;
  ELSE

    v_statement := 'J';
    SELECT instr(acct_ff_high,v_delimiter,1,v_delim_occur)
      INTO v_substr_from
      FROM dual;
    -- find position of delimiter occurance

    v_diff := v_substr_from - v_substr_to;

--bug 7534611. changed the condition from = to < and find value for last segment
    IF v_diff < 0 THEN
      -- this is the last delimiter
        v_last_seg := length(acct_ff_high) - v_substr_to;
        v_value_high(v_segment_high_name) := substr(acct_ff_high,-1 * v_last_seg,v_last_seg);
      --v_value_high(v_segment_high_name) := null;
    ELSIF v_diff = 1 THEN
      -- if = 1 then no value in segment so null
      v_value_high(v_segment_high_name) := null;
    ELSE

      v_statement := 'K';
      SELECT substr(acct_ff_high,v_substr_to + 1,v_diff - 1)
        INTO v_segment_high_value
        FROM dual;
      -- find value of segment

      v_value_high(v_segment_high_name) := v_segment_high_value;
    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_VALUE_HIGH = '||V_VALUE_HIGH(V_SEGMENT_HIGH_NAME));
    END IF;
    v_substr_to := v_substr_from;
    v_delim_occur := v_delim_occur + 1;
  END IF;
END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    err_message  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',err_message) ;
    RAISE;
END find_high_values;
/******************************************************************/
/* This procedure finds user's segment names and substrings   the */
/* name to use it as the index.  The segment name is then stored  */
/* as the value							  */
/******************************************************************/
PROCEDURE find_segments
IS
  l_module_name VARCHAR2(200) := g_module_name || 'find_segments';
BEGIN
 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BEGIN FIND_SEGMENTS');
 END IF;
 -- delete all segments in table

 FOR v_segment_num IN 1..30 LOOP
  v_segment_name(v_segment_num) := null;
 END LOOP;

 FOR segment_info_rec IN c_segment_info LOOP
   v_segment_num := to_number(substr(segment_info_rec.application_column_name,8,2));

   v_segment_name(v_segment_num) := segment_info_rec.application_column_name;

 END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    err_message  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',err_message) ;
    RAISE;
END find_segments;

-- **********************************************************************
PROCEDURE calc_funds(
            x_acct_ff_low			VARCHAR2,
	    x_acct_ff_high			VARCHAR2,
	    x_rollup_type			VARCHAR2,
	    x_treasury_symbol_id		NUMBER,
            x_balance_seg_name		        VARCHAR2,
            x_acct_seg_name                 	VARCHAR2,
            x_set_of_books_id               NUMBER,
            x_currency_code                 	VARCHAR2,
            x_period_name                   	VARCHAR2,
            x_total_budget                     	IN OUT NOCOPY NUMBER,
            x_commitments                   	IN OUT NOCOPY NUMBER,
            x_obligations                   	IN OUT NOCOPY NUMBER,
            x_expenditure                   	IN OUT NOCOPY NUMBER,
            x_total                         	IN OUT NOCOPY NUMBER,
            x_funds_available               	IN OUT NOCOPY NUMBER) IS

  l_module_name VARCHAR2(200) := g_module_name || 'calc_funds';

BEGIN
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BEGIN');
   END IF;

   -- reassign incoming variables
   acct_ff_low        := x_acct_ff_low;
   acct_ff_high	      := x_acct_ff_high;
   rollup_type        := x_rollup_type;
   sob_id             := x_set_of_books_id;
   curr_code          := x_currency_code;
   pd_name            := x_period_name;
   acct_seg_name_num  := to_number(substr(x_acct_seg_name,8,2));
   bal_seg_name_num   := to_number(substr(x_balance_seg_name,8,2));
   v_treasury_symbol_id  := x_treasury_symbol_id; --Modified to Fix Bug 1575992
   temp_v_treasury_symbol_id :=  v_treasury_symbol_id ;  -- Modified for Bug 1575992
	v_acct_seg_name    := x_acct_seg_name;
   v_bal_seg_name     := x_balance_seg_name;

   g_curr_code          := x_currency_code;

   v_statement := 'A';
   -- find period number
   --Bug#3377847
   select distinct period_num,
          period_year,
          closing_status,
          effective_period_num
   into   x_period_num,
          v_period_year,
          v_period_status,
          v_effective_period_num
   from   gl_period_statuses
   where  period_name = x_period_name
     and  ledger_id = sob_id
     and  application_id = 101;

   v_statement := 'A.A';
   if (v_period_status = 'F') THEN
     select gps1.period_name
       into pd_name
       from gl_period_statuses gps1
      where gps1.application_id=101
        and gps1.ledger_id=sob_id
        and effective_period_num = (select max(effective_period_num)
                                     from gl_period_statuses gps2
                                     where gps2.application_id = gps1.application_id
                                      and gps2.ledger_id = gps1.ledger_id
                                      and gps2.closing_status <> 'F'
                                      and gps2.effective_period_num <= v_effective_period_num);
   end if;

   v_statement := 'B';
   -- find chart of account id
   SELECT chart_of_accounts_id
     INTO v_ca_id
     FROM gl_ledgers_public_v
    WHERE ledger_id = sob_id;

   v_statement := 'C';
   -- find delimiter
   SELECT concatenated_segment_delimiter
     INTO v_delimiter
     FROM fnd_id_flex_structures
    WHERE id_flex_num = v_ca_id
      AND id_flex_code = 'GL#'
      and  application_id = 101;

  -- find user's segment names
  find_segments;

  -- parse the accounting flexfield low range
  find_low_values;

  -- parse the accounting flexfield high range
  find_high_values;

/* will use this later.
  EXCEPTION
    when no_data_found then
      fnd_message.set_name('FV','FV_FAI_NO_ACCOUNTS_FOUND');
      app_exception.raise_exception;
    when others then
      err_message := 'FV_FUNDS_AVAILABLE_PKG.CALC_FUNDS '||sqlerrm;
      fnd_message.set_name('FV','FV_FAI_GENERAL');
      fnd_message.set_token('MSG',err_message);
      app_exception.raise_exception;
*/

-- set sums to 0
x_total             := 0;
x_funds_available   := 0;
x_budget            := 0;
x_total_budget      := 0;
x_commitments       := 0;
x_obligations       := 0;
x_expenditure       := 0;
x_transfers_in	    := 0;
x_transfers_out     := 0;
v_child_budget      := 0;
v_child_commitments := 0;
v_child_obligations := 0;
v_child_expenditure := 0;
v_child_transfers_in := 0;
v_child_transfers_out := 0;

FOR c_treasury_fund_value_rec IN c_treasury_fund_values LOOP
IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'*********************************');
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FUND VALUE = '||V_VALUE_LOW(BAL_SEG_NAME_NUM));
END IF;
  -- assign fund and process
  v_fund_value := c_treasury_fund_value_rec.fund_value;
  v_budget := nvl(c_treasury_fund_value_rec.budget_authority,'-1');
  v_commitment := nvl(c_treasury_fund_value_rec.unliquid_commitments,'-1');
  v_obligation := nvl(c_treasury_fund_value_rec.unliquid_obligations,'-1');
  v_expenditure:= nvl(c_treasury_fund_value_rec.expended_amount,'-1');
  v_transfers_in := nvl(c_treasury_fund_value_rec.transfers_in,'-1');
  v_transfers_out := nvl(c_treasury_fund_value_rec.transfers_out,'-1');


  -- assign the current fund to the segment index
  v_value_low(bal_seg_name_num) := v_fund_value;
  v_value_high(bal_seg_name_num) := v_fund_value;

  -- Processing the budget authority account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_budget);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BUDGET_ID = '||ACCT_FLEX_ID);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BUDGET = '||V_BUDGET);
    END IF;

    -- sum budget authority accounts (parent and children)
    sum_children_spending(v_budget, acct_flex_id,v_child_budget);

    -- running total for the fund(s)
    x_budget := nvl(x_budget,0) + nvl(v_child_budget,0);


  -- Processing the transfers-in account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_transfers_in);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRANSFERS_IN_ID = '||ACCT_FLEX_ID);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRANSFERS_IN = '||V_TRANSFERS_IN);
    END IF;

    -- sum transfers_in accounts (parent and children)
    sum_children_spending(v_transfers_in, acct_flex_id, v_child_transfers_in);

    -- running total for the fund(s)
    x_transfers_in := nvl(x_transfers_in,0) + nvl(v_child_transfers_in,0);

  -- Processing the transfers-out account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_transfers_out);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRANSFERS_OUT_ID = '||ACCT_FLEX_ID);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRANSFERS_OUT = '||V_TRANSFERS_OUT);
    END IF;

    -- sum transfers_out accounts (parent and children)
    sum_children_spending(v_transfers_out,acct_flex_id,v_child_transfers_out);

    -- running total for the fund(s)
    x_transfers_out := nvl(x_transfers_out,0) + nvl(v_child_transfers_out,0);

  -- Processing the commitment account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_commitment);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'COMMIT_ID = '||ACCT_FLEX_ID);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'COMMIT = '||V_COMMITMENT);
    END IF;

    -- sum commitment accounts (parent and children)
    sum_children_spending(v_commitment, acct_flex_id, v_child_commitments);

    -- running total for the fund(s)
    x_commitments := nvl(x_commitments,0) + nvl(v_child_commitments,0);

  -- Processing the obligation account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_obligation);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'OBL_ID = '||ACCT_FLEX_ID);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'OBL = '||V_OBLIGATION);
    END IF;

    -- sum obligation accounts (parent and children)
    sum_children_spending(v_obligation, acct_flex_id, v_child_obligations);

    -- running total for the fund(s)
    x_obligations := nvl(x_obligations,0) + nvl(v_child_obligations,0);

  -- Processing the expenditure account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_expenditure);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'EXP_ID = '||ACCT_FLEX_ID);
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'EXP = '||V_EXPENDITURE);
    END IF;

    -- sum expenditure accounts (parent and children)
    sum_children_spending(v_expenditure, acct_flex_id, v_child_expenditure);

    -- running total for the fund(s)
    x_expenditure := nvl(x_expenditure,0) + nvl(v_child_expenditure,0);

  END LOOP;

  -- calculate totals
  x_total_budget :=x_budget + x_transfers_in - x_transfers_out;
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'X_TOTAL_BUDGET = '||X_TOTAL_BUDGET);
  END IF;
  x_total :=nvl(x_commitments,0) + nvl(x_obligations,0) + nvl(x_expenditure,0);
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'X_TOTAL = '||X_TOTAL);
  END IF;
  x_funds_available :=nvl(x_total_budget,0) - nvl(x_total,0);

EXCEPTION
 when others then
   IF err_message is null then
      err_message := 'CALC_FUNDS.'||v_statement||'.'||sqlerrm;
   END IF;

   IF c_treasury_fund_values%ISOPEN THEN
      close c_treasury_fund_values;
   END IF;
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',err_message);
   fnd_message.set_name('FV','FV_FAI_GENERAL');
   fnd_message.set_token('MSG',err_message);
   app_exception.raise_exception;

END calc_funds;


END fv_funds_available_pkg;

/
