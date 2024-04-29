--------------------------------------------------------
--  DDL for Package Body PSP_AUTOPOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_AUTOPOP" AS
/* $Header: PSPAUTOB.pls 120.6.12010000.2 2009/06/02 06:07:47 amakrish ship $  */
g_error_api_path VARCHAR2(2000) := '';

TYPE lookup_recTyp IS RECORD(
data_type varchar2(20),
charres varchar2(80),
numres number,
dateres date);
TYPE lookup_array_type is TABLE of lookup_recTyp
INDEX by BINARY_INTEGER;
lookup_array lookup_array_type;

---------- P R O C E D U R E: DynamicQuery ---------------------------------------
--
--
--  Purpose:
--  Author : Jason T. McKnight
--
----------------------------------------------------------------------------------

PROCEDURE DynamicQuery(
    p_person_id     	IN NUMBER,
    p_assignment_id	IN NUMBER,
    p_element_type_id   IN NUMBER,
    p_project_id        IN NUMBER,
    p_expenditure_organization_id   IN NUMBER,
    p_task_id                       IN NUMBER,
    p_award_id                      IN NUMBER,
    p_payroll_date      IN DATE,
    p_expenditure_type  IN VARCHAR2,
    p_set_of_books_id   In NUMBER,
    p_business_group_id  IN NUMBER,
    p_gl_code_combination_id  IN NUMBER,
    p_return_status     OUT NOCOPY VARCHAR2
    )  IS


v_CursorID	  INTEGER;
v_Dummy       INTEGER;
v_ret_varchar VARCHAR2(80) := null;
v_ret_number  NUMBER := null;
v_ret_date    DATE := null;
l_no_rows BOOLEAN:=FALSE;

l_lookup_id number;
l_data_type varchar2(20);
l_dyn_sql_stmt VARCHAR2(1000);
l_date_tracked BOOLEAN;
l_parameter  VARCHAR2(80);

p_bind_var number;
l_bind_var varchar2(80);


NO_ROWS_FOUND EXCEPTION;

CURSOR LOOKUPS_C IS
SELECT  b.lookup_id, b.parameter,b.datatype,
       b.dyn_sql_stmt, b.bind_var
FROM    psp_auto_lookups b
 where business_group_id=p_business_group_id
and set_of_books_id=p_set_of_books_id
order by lookup_id;


BEGIN
  -- Open the cursor for processing.
OPEN LOOKUPS_C;
loop

/*  reinitialized each time   */

v_ret_varchar  := null;
v_ret_number   := null;
v_ret_date     := null;

FETCH LOOKUPS_C INTO l_lookup_id,l_parameter,l_data_type,l_dyn_sql_stmt, l_bind_var;
 EXIT WHEN LOOKUPS_C%NOTFOUND;
   IF l_parameter='Expenditure Type' then
      v_ret_varchar:=p_expenditure_type;
   ELSE


  v_CursorID := DBMS_SQL.OPEN_CURSOR;
 --   --dbms_output.put_line('After open  in DQ');

          IF l_bind_var = 'l_person_id' THEN
             p_bind_var := p_person_id;
             l_date_tracked := TRUE;
       	    ELSIF l_bind_var = 'l_assignment_id' THEN
             p_bind_var := p_assignment_id;
             l_date_tracked := TRUE;
  	    ELSIF l_bind_var = 'l_element_type_id' THEN
             p_bind_var := p_element_type_id;
            --  l_date_tracked := FALSE;
                l_date_tracked := TRUE;   /* added date tracking of element type id */
  	    ELSIF l_bind_var = 'l_project_id' THEN
   	   	 p_bind_var := p_project_id;
             l_date_tracked := FALSE;
	    ELSIF l_bind_var = 'l_expenditure_organization_id' THEN
		 p_bind_var := p_expenditure_organization_id;
             l_date_tracked := FALSE;
	    ELSIF l_bind_var = 'l_task_id' THEN
		 p_bind_var := p_task_id;
             l_date_tracked := FALSE;
  	    ELSIF l_bind_var = 'l_award_id' THEN
		 p_bind_var := p_award_id;
             l_date_tracked := FALSE;
            ELSIF l_bind_var = 'l_glcc_id' THEN
                 p_bind_var := p_gl_code_combination_id;
             l_date_tracked := FALSE;
	    END IF;

  -- Parse the query.
  ----dbms_output.put_line('Before parse statement');
   dbms_sql.parse(v_CursorID, l_dyn_sql_stmt, DBMS_SQL.V7);
   ----dbms_output.put_line('After parse statement');

  -- Bind the input variable.
   --v_CursorId:=v_cursor(l_lookup_id);
  if l_date_tracked then
    dbms_sql.bind_variable(v_CursorID, ':VAR1', p_bind_var);
    dbms_sql.bind_variable(v_CursorID, ':EFFDATE', p_payroll_date);
  else
    dbms_sql.bind_variable(v_CursorID, ':VAR1', p_bind_var);
  end if;

  -- Define the output variable depending on datatype.
  if l_data_type = 'VARCHAR2' then
  dbms_sql.define_column(v_CursorID, 1, v_ret_varchar, 500);
  elsif l_data_type = 'NUMBER' then
  dbms_sql.define_column(v_CursorID, 1, v_ret_number);
  elsif l_data_type = 'DATE' then
  dbms_sql.define_column(v_CursorID, 1, v_ret_date);
  end if;

  -- Execute the statement. We don't care about the return
  -- value, but we do need to declare a variable for it.
  v_Dummy := dbms_sql.execute(v_CursorID);
    ----dbms_output.put_line('After execute in DQ');

  -- Fetch the row into the buffer. We only expect one row and
  -- will not loop through to get multiple rows.
    IF dbms_sql.fetch_rows(v_CursorID) = 0 THEN
     BEGIN
      RAISE NO_ROWS_FOUND;
     EXCEPTION
      WHEN NO_ROWS_FOUND THEN
      dbms_sql.close_cursor(v_CursorID);
      l_no_rows:=TRUE;
     END;

   /* Added for Exception Handling    if no rows are returned .  */

    ----dbms_output.put_line('fetch returned no values in DQ');

  -- insert into psp_autotemp values(l_lookup_id,l_data_type,v_ret_varchar,v_ret_number,v_ret_date,NULL);

 --   RAISE NO_ROWS_FOUND;
 ELSE
    -- Retrieve the rows from the buffer into PL/SQL variables.
    -- The correct call depends on the datatype.
    IF l_data_type = 'VARCHAR2' THEN
      dbms_sql.column_value(v_CursorID, 1, v_ret_varchar);
    ELSIF l_data_type = 'NUMBER' THEN
      dbms_sql.column_value(v_CursorID, 1, v_ret_number);
    ELSIF l_data_type = 'DATE' THEN
      dbms_sql.column_value(v_CursorID, 1, v_ret_date);
    END IF;
  dbms_sql.close_cursor(v_CursorID);


   END IF;

  END IF;
 /*  insert into psp_autotemp values(p_runid,l_lookup_id,l_data_type,v_ret_varchar,v_ret_number,v_ret_date
);
*/
--   IF NOT(l_no_rows) THEN
  lookup_array(l_lookup_id).data_type:=l_data_type;
  lookup_array(l_lookup_id).charres:=v_ret_varchar;
  lookup_array(l_lookup_id).numres:=v_ret_number;
  lookup_array(l_lookup_id).dateres:=v_ret_date;
 --  END IF;
   ----dbms_output.put_line('after insert into temp');


  -- Close the cursor.

END LOOP;
  close lookups_c;
  p_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
--  WHEN NO_ROWS_FOUND THEN
--    p_return_status := fnd_api.g_ret_sts_success;
  WHEN OTHERS THEN
    -- Close the cursor.
    dbms_sql.close_cursor(v_CursorID);
    close lookups_c;
    g_error_api_path := 'DynamicQuery:WHEN OTHERS:'||g_error_api_path;
    p_return_status := fnd_api.g_ret_sts_unexp_error;
END DynamicQuery;


/********************************************************************************
 New procedure added for bug fix  for resolve_rules along with  autopop performance optimization patch
    Bug 2023955
********************************************************************************/

FUNCTION resolve_rules_new(x_string IN VARCHAR2)  RETURN BOOLEAN is


v_CursorID	  INTEGER;
v_Dummy       INTEGER;
v_ret_Number number:=0;
v_return_value BOOLEAN;
new_sql_string varchar2(1000);
BEGIN

  v_CursorID := DBMS_SQL.OPEN_CURSOR;
new_sql_string :='SELECT 1 from dual where '||x_string;
   dbms_sql.parse(v_CursorID, new_sql_string, DBMS_SQL.V7);
  dbms_sql.define_column(v_CursorID, 1, v_ret_number);
  v_Dummy := dbms_sql.execute(v_CursorID);

  IF dbms_sql.fetch_rows(v_CursorID) = 0 THEN
      v_return_value := FALSE;
  ELSE
      v_return_value := TRUE ;
  END IF;

  dbms_sql.close_cursor(v_CursorID);
return v_return_value;
EXCEPTION when others then

/* when rule is invalid */
 v_return_value:=FALSE;
 dbms_sql.close_cursor(v_CursorID);  -- Added for bug 8564153
 return v_return_value;

end resolve_rules_new;


/**************************************************************************


This function has been obsoleted and replaced by the resolve_ruleS_new function above
---------- F U N C T I O N: resolve_rules ---------------------------------------
--
--
--  Purpose:
--  Author : Chandra Kalyana
--
----------------------------------------------------------------------------------

FUNCTION resolve_rules (x_string IN VARCHAR2)
                           RETURN BOOLEAN IS

  v_return_value  BOOLEAN;
  str_len         BINARY_INTEGER;
  new_str_len     BINARY_INTEGER;
  op_counter      BINARY_INTEGER :=0;
  str_pos         BINARY_INTEGER :=1;
  left_paren_pos  BINARY_INTEGER;
  right_paren_pos BINARY_INTEGER;

  new_string      VARCHAR2(1000);
  original_string VARCHAR2(1000);
  result_string   VARCHAR2(100);

BEGIN

--dbms_output.put_line ('resolve rules string '||x_string);

original_string := x_string ;
str_len := length(original_string) ;
str_pos := 1 ;

-- Checking for NOT operator followed by a TRUE or FALSE, and change the string with
 -- the appropriate boolean value

while str_pos <= str_len LOOP
      if substr(original_string,str_pos,3) = 'NOT'
      then
         if substr(original_string,str_pos+4,1) = 'T'
         then
            original_string := replace(original_string,'NOT TRUE','FALSE') ;
         elsif substr(original_string,str_pos+4,1) = 'F'
         then
            original_string := replace(original_string,'NOT FALSE','TRUE') ;
         end if;

      end if;
      str_pos := str_pos + 1 ;
end LOOP;

-- Looping through the entire string passed till final boolean value is obtained

while TRUE loop

str_pos := 1 ;
str_len := length(original_string) ;
left_paren_pos := 0 ;
right_paren_pos := 0;


-- Checking for last occurence of left parenthesis

  str_pos := 1 ;

  while str_pos <= str_len LOOP

      if substr(original_string,str_pos,1) = '('
      then
          left_paren_pos := str_pos ;
      end if;
      str_pos := str_pos + 1;
  end loop;

 --dbms_output.put_line('left( '||left_paren_pos);


--  Initialising starting position

  str_pos := left_paren_pos ;

--  Checking for first occurence of right parenthesis

  while str_pos <= str_len LOOP

      if substr(original_string,str_pos,1) = ')'
      then
          right_paren_pos := str_pos ;
          exit ;
      end if;
      str_pos := str_pos + 1;

  end loop;

 --dbms_output.put_line('right) '||right_paren_pos);

--  Read the string between the parenthesis

    if left_paren_pos <> 0 AND right_paren_pos <> 0
    then
       if right_paren_pos - left_paren_pos = 6
       then
          new_string := replace(original_string,'(FALSE)','FALSE');
          original_string := new_string;
       elsif right_paren_pos - left_paren_pos = 5
       then
          new_string := replace(original_string,'(TRUE)','TRUE');
          original_string := new_string;
       else
          new_string := substr(original_string,left_paren_pos+1,right_paren_pos-left_paren_pos-1);
       end if;
    else
       new_string := original_string ;
    end if;


--dbms_output.put_line('new_string '||new_string);

 -- To find length of the new string

    new_str_len := length(new_string);

--  Initialising starting position


  str_pos := 1 ;
 -- Checking for NOT operator followed by a TRUE or FALSE,
-- and change the string with the appropriate boolean value

while str_pos <= str_len LOOP
      if substr(original_string,str_pos,3) = 'NOT'
      then
         if substr(original_string,str_pos+4,1) = 'T'
         then
            original_string := replace(original_string,'NOT TRUE','FALSE') ;
         elsif substr(original_string,str_pos+4,1) = 'F'
         then
            original_string := replace(original_string,'NOT FALSE','TRUE') ;
         end if;

      end if;
      str_pos := str_pos + 1 ;
end LOOP;


    -- Checking for the number of OR and AND operators in the new string

  --    Initialising starting position

       str_pos := 1 ;

       new_str_len := length(new_string);

       while str_pos <= new_str_len LOOP
             if substr(new_string,str_pos,3) = 'AND' or substr(new_string,str_pos,2) = 'OR'
             then
                op_counter := op_counter + 1;

             end if;
             str_pos := str_pos + 1 ;
       end loop;
       --dbms_output.put_line('counter '||op_counter);
   -- If there is only one operand, then we can now resolve this string

       if op_counter = 0
       then
           result_string := new_string ;
       end if;

       if op_counter = 1
       then
          if new_string = 'TRUE AND TRUE'
          then
	     result_string := 'TRUE' ;
	  elsif new_string = 'TRUE OR TRUE'
          then
             result_string := 'TRUE' ;
          elsif new_string = 'TRUE OR FALSE'
          then
             result_string := 'TRUE' ;
          elsif new_string = 'FALSE OR TRUE'
          then
             result_string := 'TRUE' ;
          elsif new_string = 'FALSE OR FALSE'
          then
             result_string := 'FALSE' ;
          elsif new_string = 'FALSE AND FALSE'
          then
             result_string := 'FALSE' ;
          elsif new_string = 'TRUE AND FALSE'
          then
             result_string := 'FALSE' ;
          elsif new_string = 'FALSE AND TRUE'
          then
             result_string := 'FALSE' ;
          end if;

       elsif op_counter > 1
--   we have to break this string into smaller boolen expressions
       then
          str_pos := 1 ;

          while str_pos <= new_str_len LOOP
          --dbms_output.put_line('str_pos '||str_pos);
               if substr(new_string,str_pos,3) = 'AND'
               then

                  if substr(new_string,str_pos+4,1) = 'T'
                  then
                     new_string := substr(new_string,1,str_pos+7);

 	          elsif substr(new_string,str_pos+4,1) = 'F'
 	          then
	             new_string := substr(new_string,1,str_pos+8);

	          end if;
	          exit;
               end if;
               str_pos := str_pos + 1 ;
          end loop;

          str_pos := 1 ;

          while str_pos <= new_str_len LOOP

               if substr(new_string,str_pos,2) = 'OR'

               then
                  if substr(new_string,str_pos+3,1) = 'T'
                  then
                     new_string := substr(new_string,1,str_pos+6);
                     --dbms_output.put_line('string1 '||new_string);
 	          elsif substr(new_string,str_pos+3,1) = 'F'
 	          then
	             new_string := substr(new_string,1,str_pos+7);
                     --dbms_output.put_line('string2 '||new_string);
	          end if;
	          exit;
               end if;
               str_pos := str_pos + 1 ;
          end loop;

          if new_string = 'TRUE AND TRUE'
          then
	     result_string := 'TRUE' ;
	  elsif new_string = 'TRUE OR TRUE'
          then
             result_string := 'TRUE' ;
          elsif new_string = 'TRUE OR FALSE'
          then
             result_string := 'TRUE' ;
          elsif new_string = 'FALSE OR TRUE'
          then
             result_string := 'TRUE' ;
          elsif new_string = 'FALSE OR FALSE'
          then
             result_string := 'FALSE' ;
          elsif new_string = 'FALSE AND FALSE'
          then
             result_string := 'FALSE' ;
          elsif new_string = 'TRUE AND FALSE'
          then
             result_string := 'FALSE' ;
          elsif new_string = 'FALSE AND TRUE'
          then
             result_string := 'FALSE' ;
          end if;

       end if ;

--dbms_output.put_line('new string '||new_string);
--dbms_output.put_line('result string '||result_string);
--dbms_output.put_line('original string '||original_string);

if result_string is not null
then
   original_string := replace(original_string,new_string,result_string);
end if;

  --dbms_output.put_line('original string '||original_string);
       if original_string = 'TRUE' or original_string = 'FALSE'
       then
          exit;
       else
        op_counter := 0 ;
        result_string := null ;
    end if;

end loop;

  ----dbms_output.put_line('final result '||original_string);


  if  original_string = 'TRUE'
  then
      v_return_value := TRUE ;
  elsif original_string = 'FALSE'
  then
      v_return_value := FALSE ;
  end if;

  RETURN v_return_value;

end resolve_rules ;

*/


/*----------P R O C E D U R E: MAIN ------------------------------------------------
--
--
--  Purpose:
--  Author : Jason T. McKnight
--
--  Subha Ramachandran      03-Feb-2000  Changes made for Multiorg Implementation
--                                        added SOB and  BG in the parameter class
--  V.V.Lavanya		    27-AUG-2001	 Added for the Enhancement Natural By Pass Account
--					 For Bug : 1907209
----------------------------------------------------------------------------------*/

PROCEDURE main(
    p_acct_type        			IN VARCHAR2,
    p_person_id				IN NUMBER,
    p_assignment_id			IN NUMBER,
    p_element_type_id      		IN NUMBER,
    p_project_id                    IN NUMBER,
    p_expenditure_organization_id   IN NUMBER,
    p_task_id                       IN NUMBER,
    p_award_id                      IN NUMBER,
    p_expenditure_type              IN VARCHAR2,
    p_gl_code_combination_id	    IN NUMBER,
    p_payroll_date		    IN DATE,
    p_set_of_books_id               IN NUMBER,
    p_business_group_id             IN NUMBER,
    ret_expenditure_type	    OUT NOCOPY VARCHAR2,
    ret_gl_code_combination_id      OUT NOCOPY NUMBER,
    retcode                         OUT NOCOPY VARCHAR2)  IS
/**************************************************************************************************

Segment Number will now be picked from PSP_AUTO_SEGMENTS

l_segment_num    NUMBER(3):= TO_NUMBER(FND_PROFILE.VALUE('PSP_AUTOP_SEG_NUM'));

***************************************************************************************************/
l_segment_num NUMBER(3);
l_seg_no            	NUMBER(2);
-- For Bug 1907209 : Moved the variables up : Natural Bypass Account Enhancement -lveerubh
nsegs        NUMBER;
cat_segs     VARCHAR2(2000);
segs         FND_FLEX_EXT.SegmentArray;
ccid_exists  BOOLEAN;
combo_valid  BOOLEAN;
new_gl_ccid  NUMBER;


CURSOR exp_accts_c(p_period_type in VARCHAR2) IS
SELECT acct_id, expenditure_type,
       acct_seq_num    --added for debug purposes
FROM   psp_auto_accts a
WHERE  acct_type = 'E'
AND    period_type = p_period_type
AND    p_payroll_date BETWEEN start_date_active AND NVL(end_date_active, p_payroll_date)
AND business_group_id=p_business_group_id
and set_of_books_id=p_set_of_books_id
AND EXISTS
(SELECT '1' from psp_auto_rules where acct_id=a.acct_id)
ORDER BY acct_seq_num;

CURSOR na_accts_c(p_period_type in VARCHAR2) IS
SELECT acct_id,segment_num, natural_account,
       acct_seq_num    --added for debug purposes
FROM   psp_auto_accts a
WHERE  acct_type = 'N'
AND    period_type = p_period_type
AND segment_num = l_segment_num
and business_group_id=p_business_group_id
and set_of_books_id=p_set_of_books_id
AND    p_payroll_date BETWEEN start_date_active AND NVL(end_date_active, p_payroll_date)
AND EXISTS
(SELECT '1' from psp_auto_rules where acct_id=a.acct_id)
ORDER BY acct_seq_num;

CURSOR params_c(p_acct_id IN NUMBER) IS
SELECT a.param_line_num, a.lookup_id,
       a.operand, a.user_value
FROM   psp_auto_params a
WHERE  a.acct_id = p_acct_id
and exists
(select lookup_id from psp_auto_lookups where
lookup_id=a.lookup_id);

CURSOR rules_c(p_acct_id IN NUMBER) IS
SELECT calculator_rule
FROM   psp_auto_rules
WHERE  acct_id = p_acct_id;

CURSOR by_pass_c IS
SELECT expenditure_type
FROM   psp_auto_bypass
WHERE  expenditure_type = p_expenditure_type
and set_of_books_id=p_set_of_books_id
and business_group_id=p_business_group_id;

--For Bug 1907209 : Natural By Pass Account Enhancement
--Added new cursor to obtain the bypass account.
CURSOR	by_pass_na_cur
IS
SELECT	panb.natural_account
FROM	psp_auto_na_bypass 	panb
WHERE	panb.natural_account		=	segs(l_seg_no)
AND	panb.segment_num		=	l_segment_num
AND	panb.set_of_books_id 		= 	p_set_of_books_id
And	panb.business_group_id 		= 	p_business_group_id;


CURSOR period_type_c IS
SELECT distinct(ppf.period_type)
FROM   per_all_assignments_f paf,
       pay_all_payrolls_f ppf
WHERE  paf.assignment_id = p_assignment_id
AND    p_payroll_date BETWEEN paf.effective_start_date AND NVL(paf.effective_end_date,p_payroll_date)
AND    paf.payroll_id = ppf.payroll_id;

/* Bug Fix 5439154: Support for non Consecutive GL Segments*/
CURSOR Segment_number_csr IS
SELECT	SEGMENT_NUM
FROM	fnd_id_flex_segments fifs,
	gl_sets_of_books gsob,
	fnd_application fa
WHERE	gsob.set_of_books_id = p_set_of_books_id
AND	fifs.id_flex_num = gsob.chart_of_accounts_id
AND	fifs.id_flex_code = 'GL#'
AND enabled_flag = 'Y'
AND	fifs.application_id = fa.application_id
AND	fa.application_short_name = 'SQLGL'
ORDER BY SEGMENT_NUM ASC;

l_segment_number        NUMBER(3);
l_segment_index         NUMBER(3);

l_acct_id           	NUMBER(10);
l_param_line_num    	NUMBER(3);
l_lookup_id		NUMBER(10);
l_operand		VARCHAR2(20);
l_user_value	  	VARCHAR2(80);
l_parameter	        VARCHAR2(50);
l_datatype          	VARCHAR2(20);
l_bind_var		VARCHAR2(30);
l_date_tracked	  	BOOLEAN := FALSE;
l_expenditure_type  	VARCHAR2(30);
l_natural_account   	VARCHAR2(150);
--l_bind_param        	VARCHAR2(30);
l_varchar_results   	VARCHAR2(80);
l_number_results    	NUMBER;
l_date_results      	DATE;
l_return_status     	VARCHAR2(1);
l_by_pass	    	VARCHAR2(30);
l_period_type       	VARCHAR2(30);


--For Bug 1907209 : Natural Bypass Account Enhancement : Added the following variable
l_by_pass_na		VARCHAR2(150);
l_acct_seq_num           number; ---- added for tracing

TYPE t_resolved IS TABLE OF VARCHAR2(5)
  INDEX BY BINARY_INTEGER;
v_resolved t_resolved;
v_param_count 	INTEGER 	:= 0;
v_false 	VARCHAR2(5) 	:= 'FALSE';
v_true  	VARCHAR2(4) 	:= 'TRUE';

v_counter 	INTEGER;
last_line_num 	INTEGER;
first_line_num 	INTEGER;

-- bug fxi 3986100 l_calculator_rule 	VARCHAR2(500) := NULL;
l_calculator_rule 	VARCHAR2(1000) := NULL;


-- bug fix 3986100 resolved_rule     	VARCHAR2(500) := NULL;
resolved_rule     	VARCHAR2(4000) := NULL;

l_rule_match 		BOOLEAN := FALSE;
l_chart_of_accts 	VARCHAR2(20);
l_struc_num 		NUMBER :=psp_general.find_chart_of_accts(p_set_of_books_id,l_chart_of_accts);
short_name   		CONSTANT VARCHAR2(50) := 'SQLGL';
flex_code    		CONSTANT VARCHAR2(4)  := 'GL#';
struct_num   		CONSTANT NUMBER       :=to_number(l_chart_of_accts);

/*  For Bug 1907209 : Natural Bypass Acount - Moved the declaration of variables up as they are referenced by the
Cursor by_na_pass_cur -lveerubh
nsegs        NUMBER;
cat_segs     VARCHAR2(2000);
segs         FND_FLEX_EXT.SegmentArray;
ccid_exists  BOOLEAN;
combo_valid  BOOLEAN;
new_gl_ccid  NUMBER;
*/

BY_PASS_FOUND   EXCEPTION;
NO_PERIOD_TYPE  EXCEPTION;

--For Bug 1907209 : Natural Bypass Account : Added the following Exception
BY_PASS_NA_FOUND	EXCEPTION;

BEGIN
/* Instead of profile , the segment number is now picked from the table */
--For Bug Fix : 1760311 : Introducing Conditional Checking for NA while selecting segment Number
-- hr_utility.trace_on(null,'autodebug');  Commented by tbalacha
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: Inside main Param values
p_acct_type = ' || p_acct_type ||' p_person_id = ' || p_person_id ||' p_assignment_id = '
|| p_assignment_id ||' p_element_type_id = ' || p_element_type_id ||' p_project_id     = ' || p_project_id );
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: Inside main Param values Contd:
p_expenditure_organization_id = ' || p_expenditure_organization_id
||' p_task_id = ' || p_task_id ||' p_award_id = ' || p_award_id ||' p_expenditure_type  = ' || p_expenditure_type );
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: Inside main Param values Contd:
p_gl_code_combination_id = ' || p_gl_code_combination_id ||' p_payroll_date = ' || p_payroll_date );
	IF p_acct_type = 'N' THEN
          SELECT 	segment_number
	  INTO 		l_segment_num
	  FROM 		psp_auto_segments
	  WHERE 	business_group_id 	= p_business_group_id
	  AND   	set_of_books_id 	= p_set_of_books_id;

hr_utility.trace('Autodebug Message:PSP_AUTOPOP: Getting the value of l_segment_num'|| l_segment_num);
--	END IF;   should  be moved down otherwise will result in unexpected error
-- when processing exp --type  for correction of bug fix 1907209

	g_error_api_path := '';
/******
For Bug 1907209 : Natural Bypass Account Enhancement : Added following code for Skipping the
Autopop for Natural Account-lveerubh
****/
-- get the original segments
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: before  FND_FLEX_EXT.get_segments');

	ccid_exists := FND_FLEX_EXT.get_segments(	application_short_name 	=> 	short_name,
							key_flex_code	 	=>	flex_code,
						        structure_number	=>	struct_num,
							combination_id		=>	p_gl_code_combination_id,
							n_segments		=>	nsegs,
							segments		=>	segs);

hr_utility.trace('Autodebug Message:PSP_AUTOPOP: after  FND_FLEX_EXT.get_segments l_segment_num='||l_segment_num|| 'nsegs='||nsegs);

/* Bug Fix 5439154: Support for non Consecutive GL Segments*/
	OPEN  segment_number_csr;
        l_segment_index :=1 ;
        LOOP
            FETCH segment_number_csr INTO l_segment_number;
            EXIT WHEN segment_number_csr%NOTFOUND;
            IF l_segment_number = l_segment_num THEN
                l_seg_no	:=	l_segment_index;
                EXIT;
            END IF;
            l_segment_index := l_segment_index + 1;
        END LOOP;
        CLOSE segment_number_csr;

--        l_seg_no	:=	l_segment_num;
        IF (l_seg_no >nsegs) OR (l_seg_no IS NULL) THEN
              --dbms_output.put_line('to test failure on exp type');
hr_utility.trace('Autodebug Message:PSP_AUTOPOP:  PSP_AUTOP_SEG_NUM');
               	FND_MESSAGE.SET_NAME('PSP','PSP_AUTOP_SEG_NUM');
            	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: before  IF 	ccid_exists	=	TRUE l_segment_num ='|| l_segment_num || 'segs(l_seg_no)='|| segs(l_seg_no)||'p_set_of_books_id='|| p_set_of_books_id ||'p_business_group_id='|| p_business_group_id);

	IF 	ccid_exists	=	TRUE THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: inside IF 	ccid_exists	=	TRUE THEN');
          OPEN 	by_pass_na_cur;
          FETCH by_pass_na_cur INTO l_by_pass_na;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: inside l_by_pass_na='|| l_by_pass_na);

          IF 	by_pass_na_cur%FOUND THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: inside by_pass_na_cur%FOUND THEN');

            -- By-Pass Natural Account Segment  passed
            -- Skip auto-population.
            	CLOSE by_pass_na_cur;
            	RAISE BY_PASS_NA_FOUND;
          END IF;
         	 CLOSE by_pass_na_cur;
       ELSE
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: FND_FLEX_EXT.get_segments:CCID'||p_gl_code_combination_id||' passed in does not exist'||':'||g_error_api_path);
g_error_api_path := 'FND_FLEX_EXT.get_segments:CCID'||p_gl_code_combination_id||' passed in does not exist'||':'||g_error_api_path;
            	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;  --  end of if_ccid_exists
--End of Fix for Bug :1907209 : Natural By Pass Account -lveerubh
    END IF; -- end of p_acct_type='N' -- subha for correction of bug fix 1907209

hr_utility.trace('Autodebug Message:PSP_AUTOPOP: before  IF p_expenditure_type is NOT NULL THEN ');

        -- Check By-Pass Table to skip following
        -- code if passed expenditure type is in
        -- user defined By-Pass Table.
--DBMS_OUTPUT.PUT_LINE('STRUCT_NUM'||TO_CHAR(struct_num));
        IF p_expenditure_type is NOT NULL THEN

       --dbms_output.put_line('before opening the  bypass cursor');

          OPEN by_pass_c;
          FETCH by_pass_c INTO
               l_by_pass;
          IF by_pass_c%FOUND THEN
            -- By-Pass Expenditure Type passed in.
            -- Skip auto-population.
            CLOSE by_pass_c;
            RAISE BY_PASS_FOUND;
            --dbms_output.put_line('bypass has bene foud ');
          END IF;
          CLOSE by_pass_c;
        END IF;

	-- Determine Period Type of assignment's payroll.
       --dbms_output.put_line('before period type cursor ');
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: before  OPEN period_type_c ');

        OPEN period_type_c;
        FETCH period_type_c INTO
             l_period_type;
             --dbms_output.put_line('period_type , assignment'||l_period_type||' '||p_assignment_id||' '||p_payroll_date);
        IF period_type_c%NOTFOUND THEN
          CLOSE period_type_c;
          RAISE NO_PERIOD_TYPE;


        END IF;
        CLOSE period_type_c;
    --dbms_output.put_line('after det period type');

        /*IF l_period_type NOT IN ('Bi-Week','Calendar Month','Semi-Month','Week') THEN
          RAISE NO_PERIOD_TYPE;
        END IF;*/

	-- Cycle through either expenditure type
	-- or Natural Account rules, depending
	-- on the value of p_acct_type.
     --dbms_output.put_line('before calling dynmaic query ');
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: Before Calling Dynamic Queny');
 DynamicQuery(
    p_person_id                   =>    p_person_id,
    p_assignment_id               =>    p_assignment_id,
    p_element_type_id             =>    p_element_type_id,
    p_project_id                  =>    p_project_id,
    p_expenditure_organization_id =>    p_expenditure_organization_id,
    p_task_id                     =>    p_task_id,
    p_award_id                    =>    p_award_id,
    p_payroll_date                =>    p_payroll_date,
    p_expenditure_type            =>    p_expenditure_type,
    p_set_of_books_id             =>    p_set_of_books_id,
    p_business_group_id           =>    p_business_group_id,
    p_gl_code_combination_id      =>    p_gl_code_combination_id,
    p_return_status               =>    l_return_status
    );
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: after Calling Dynamic Queny l_return_status= '|| l_return_status);


          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            g_error_api_path := 'DYNAMIC QUERY='||to_char(l_lookup_id)||':'||g_error_api_path;
             --dbms_output.put_line(g_error_api_path);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
   --dbms_output.put_line('after return from dynamic query');

      IF p_acct_type = 'E' THEN
        OPEN exp_accts_c(l_period_type);
 	ELSIF p_acct_type = 'N' THEN
        OPEN na_accts_c(l_period_type);
          --dbms_output.put_line('periodc type' ||l_period_type);
      END IF;

	LOOP
        IF p_acct_type = 'E' THEN
          FETCH exp_accts_c into
            l_acct_id,
	      l_expenditure_type, l_acct_seq_num;
	      --dbms_output.put_line('acct_id'||','||to_char(l_acct_id)||','||l_expenditure_type);
          IF exp_accts_c%NOTFOUND THEN
            CLOSE exp_accts_c;
            EXIT;
          END IF;
          hr_utility.trace('Autodebug Message:PSP_AUTOPOP: ***************EXPENDITURE TYPE -  RULE NO ='||l_acct_seq_num||'   ***************');
        ELSIF p_acct_type = 'N' THEN
        --dbms_output.put_line('p_acct_type'||p_acct_type);
        --dbms_output.put_line('p_payroll_date'||to_char(p_payroll_date));
          FETCH na_accts_c into
            l_acct_id,l_segment_num,
	      l_natural_account, l_acct_seq_num;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: inside the loop fetched values:l_period_type=' || l_period_type|| 'l_acct_id='|| l_acct_id||'l_segment_num='||l_segment_num ||'l_natural_account='||l_natural_account );
	      IF l_acct_id is  NULL THEN
	      --dbms_output.put_line('acct_id'||','||to_char(l_acct_id)||','||l_natural_account);
               null;

	      END IF;
          IF na_accts_c%NOTFOUND THEN
            CLOSE na_accts_c;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: exiting from outer loop' );
            EXIT;
          END IF;
             hr_utility.trace('Autodebug Message:PSP_AUTOPOP: ****************NATURAL ACCOUNT  - RULE NO ='||l_acct_seq_num||'   ***************');
	  END IF;

	  -- Delete all records from PL/SQL table that will
	  -- hold the resolved values of the parameter expressions
	  -- for a given rule, either 'TRUE' or 'FALSE'.

	  v_resolved.DELETE;

	  -- Cycle through all parameter expressions for the
	  -- current rule and exit when no parameter exrpressions found.
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: before OPEN params_c(l_acct_id) ACCT_ID ='||l_acct_id);

        OPEN params_c(l_acct_id); LOOP
          FETCH params_c into
               l_param_line_num,
		   l_lookup_id,
               l_operand,
               l_user_value;
          IF params_c %NOTFOUND THEN
            CLOSE params_c;
            EXIT;
          END IF;
      --dbms_output.put_line('open params cursor ');
/*

	    -- Check the type of bind variable to be used with the
	    -- dynamic sql statement for this parameter expression
	    -- and assign the correct raw parameter to the variable
	    -- l_bind_param.

          IF l_bind_var = 'l_person_id' THEN
             l_bind_param := p_person_id;
             l_date_tracked := TRUE;
       	    ELSIF l_bind_var = 'l_assignment_id' THEN
             l_bind_param := p_assignment_id;
             l_date_tracked := TRUE;
  	    ELSIF l_bind_var = 'l_element_type_id' THEN
             l_bind_param := p_element_type_id;
          --   l_date_tracked := FALSE;
             l_date_tracked := TRUE;
  	    ELSIF l_bind_var = 'l_project_id' THEN
   	   	 l_bind_param := p_project_id;
             l_date_tracked := FALSE;
	    ELSIF l_bind_var = 'l_expenditure_organization_id' THEN
		 l_bind_param := p_expenditure_organization_id;
             l_date_tracked := FALSE;
	    ELSIF l_bind_var = 'l_task_id' THEN
		 l_bind_param := p_task_id;
             l_date_tracked := FALSE;
  	    ELSIF l_bind_var = 'l_award_id' THEN
		 l_bind_param := p_award_id;
             l_date_tracked := FALSE;
	    END IF;

	    -- Call procedure DynamicQuery to retrieve the
	    -- current system value of the parameter. The
   	    -- value returned depends on the datatype of
	    -- the parameter, denoted by l_datatype.
          IF l_parameter = 'Expenditure Type' THEN
            l_varchar_results := p_expenditure_type;
          ELSE
          DynamicQuery(p_dyn_sql_stmt  => l_dyn_sql_stmt,
	    		     p_bind_var	   => l_bind_param,
			     p_date_tracked  => l_date_tracked,
	    	           p_datatype      => l_datatype,
                       p_payroll_date  => p_payroll_date,
	    		     l_ret_varchar   => l_varchar_results,
	    		     l_ret_number    => l_number_results,
	    		     l_ret_date	   => l_date_results,
	    		     p_return_status => l_return_status);
          IF l_return_status != fnd_api.g_ret_sts_success THEN
            CLOSE params_c;
  		CLOSE exp_accts_c;
            g_error_api_path := 'LOOKUP_ID='||to_char(l_lookup_id)||':'||g_error_api_path;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          END IF;
	    -- Compare the current system value returned from
	    -- the call to DynamicQuery with the user value
	    -- and operand specified in the parameter expression.
	    -- Assign either 'TRUE' or 'FALSE' to the PL/SQL
	    -- table v_resolved() that will hold the resolved
	    -- values for each of the parameter expressions
	    -- cycled through in the current loop.
*/
         --dbms_output.put_line('before accessing the array');
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: before if lookup_array.EXISTS');
         if lookup_array.EXISTS(l_lookup_id)THEN
            l_datatype:=lookup_array(l_lookup_id).data_type;
            l_varchar_results:=lookup_array(l_lookup_id).charres;
            l_number_results:=lookup_array(l_lookup_id).numres;
            l_date_results:=lookup_array(l_lookup_id).dateres;
        END IF;


          --dbms_output.put_line('after fetch from temp');
	  --dbms_output.put_line('data type '||l_datatype);
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: before seraching for datatype l_param_line_num ='||l_param_line_num);
          IF l_datatype = 'VARCHAR2' THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: in VArchar2');
hr_utility.trace('Autodebug Message:PSP_AUTOPOP:variable ='||l_varchar_results||' user_value='||l_user_value);
           	IF l_operand = '=' THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: in = block');
              IF l_varchar_results IS NULL AND l_user_value IS  NULL THEN
                v_resolved(l_param_line_num) := v_true;
              ELSIF l_varchar_results = l_user_value THEN
                v_resolved(l_param_line_num) := v_true;
              ELSE
 		    v_resolved(l_param_line_num) := v_false;
              END IF;
            ELSIF l_operand = '<>' THEN
              IF l_varchar_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
              ELSIF l_varchar_results <> l_user_value THEN
                v_resolved(l_param_line_num) := v_true;
		  ELSE
 		    v_resolved(l_param_line_num) := v_false;
              END IF;
 		ELSIF l_operand = 'LIKE' THEN
              IF l_varchar_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_true;
              ELSIF l_varchar_results LIKE l_user_value THEN
                v_resolved(l_param_line_num) := v_true;
		  ELSE
   		    v_resolved(l_param_line_num) := v_false;
              END IF;
/* Added for NOT LIKE */
 		ELSIF l_operand = 'NOT LIKE' THEN
              IF l_varchar_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
              ELSIF l_varchar_results NOT LIKE l_user_value THEN
                v_resolved(l_param_line_num) := v_true;
		  ELSE
   		    v_resolved(l_param_line_num) := v_false;
              END IF;

            ELSIF l_operand = 'IS' THEN
              IF l_varchar_results IS NULL THEN
		    v_resolved(l_param_line_num) := v_true;
              ELSE
		    v_resolved(l_param_line_num) := v_false;
  		  END IF;
		ELSIF l_operand = 'IS NOT' THEN
              IF l_varchar_results IS NOT NULL THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
		    v_resolved(l_param_line_num) := v_false;
		  END IF;
            END IF;

	    ELSIF l_datatype = 'NUMBER' THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: in Number  l_param_line_num ='||l_param_line_num);
hr_utility.trace('Autodebug Message:PSP_AUTOPOP:variable ='||l_number_results||' user_value='||l_user_value);

   		IF l_operand = '=' THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: in = block');
              IF l_number_results IS NULL AND l_user_value IS  NULL THEN
		    v_resolved(l_param_line_num) := v_true;
              ELSIF l_number_results = to_number(l_user_value) THEN
		    v_resolved(l_param_line_num) := v_true;
              ELSE
		    v_resolved(l_param_line_num) := v_false;
              END IF;
            ELSIF l_operand = '<>' THEN
              IF l_number_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
              ELSIF l_number_results <> to_number(l_user_value) THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
 		    v_resolved(l_param_line_num) := v_false;
              END IF;
		ELSIF l_operand = '>' THEN
              IF l_number_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
              ELSIF l_number_results > to_number(l_user_value) THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
 		    v_resolved(l_param_line_num) := v_false;
              END IF;
		ELSIF l_operand = '<' THEN
              IF l_number_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
              ELSIF l_number_results < to_number(l_user_value) THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
 		    v_resolved(l_param_line_num) := v_false;
              END IF;
		ELSIF l_operand = '>=' THEN
              IF l_number_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
              ELSIF l_number_results >= to_number(l_user_value) THEN
		    v_resolved(l_param_line_num) := v_true;
	        ELSE
 		    v_resolved(l_param_line_num) := v_false;
              END IF;
		ELSIF l_operand = '<=' THEN
              IF l_number_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
              ELSIF l_number_results <= to_number(l_user_value) THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
 		    v_resolved(l_param_line_num) := v_false;
              END IF;
    		ELSIF l_operand = 'IS' THEN
              IF l_number_results IS NULL THEN
		    v_resolved(l_param_line_num) := v_true;
              ELSE
		    v_resolved(l_param_line_num) := v_false;
  		  END IF;
		ELSIF l_operand = 'IS NOT' THEN
              IF l_number_results IS NOT NULL THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
		    v_resolved(l_param_line_num) := v_false;
		  END IF;
            END IF;

	    ELSIF l_datatype = 'DATE' THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: in Date  l_param_line_num ='||l_param_line_num);
hr_utility.trace('Autodebug Message:PSP_AUTOPOP:variable ='||l_date_results||' user_value='||l_user_value);

 	      IF l_operand = '=' THEN
              IF l_date_results IS NULL AND l_user_value IS  NULL THEN
                v_resolved(l_param_line_num) := v_true;
              ELSIF l_date_results = to_date(l_user_value,'YYYY/MM/DD HH24:MI:SS') THEN
		    v_resolved(l_param_line_num) := v_true;
              ELSE
		    v_resolved(l_param_line_num) := v_false;
              END IF;
            ELSIF l_operand = '<>' THEN
              IF l_date_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
        --      ELSIF l_date_results <> to_date(l_user_value,'YYYY/MM/DD HH24:MI:SS') THEN
              ELSIF trunc(l_date_results) <> trunc(to_date(l_user_value,'YYYY/MM/DD HH24:MI:SS')) THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
		    v_resolved(l_param_line_num) := v_false;
              END IF;
		ELSIF l_operand = '>' THEN
              IF l_date_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
              ELSIF trunc(l_date_results) > trunc(to_date(l_user_value,'YYYY/MM/DD HH24:MI:SS')) THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
		    v_resolved(l_param_line_num) := v_false;
              END IF;
		ELSIF l_operand = '<' THEN
              IF l_date_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
              ELSIF trunc(l_date_results) < trunc(to_date(l_user_value,'YYYY/MM/DD HH24:MI:SS')) THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
		    v_resolved(l_param_line_num) := v_false;
              END IF;
		ELSIF l_operand = '>=' THEN
              IF l_date_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
              ELSIF trunc(l_date_results) >= trunc(to_date(l_user_value,'YYYY/MM/DD HH24:MI:SS')) THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
		    v_resolved(l_param_line_num) := v_false;
              END IF;
		ELSIF l_operand = '<=' THEN
              IF l_date_results IS NULL AND l_user_value IS NULL THEN
		    v_resolved(l_param_line_num) := v_false;
              ELSIF trunc(l_date_results) <= trunc(to_date(l_user_value,'YYYY/MM/DD HH24:MI:SS')) THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
		    v_resolved(l_param_line_num) := v_false;
              END IF;
    		ELSIF l_operand = 'IS' THEN
              IF l_date_results IS NULL THEN
		    v_resolved(l_param_line_num) := v_true;
              ELSE
		    v_resolved(l_param_line_num) := v_false;
  		  END IF;
		ELSIF l_operand = 'IS NOT' THEN
              IF l_date_results IS NOT NULL THEN
		    v_resolved(l_param_line_num) := v_true;
		  ELSE
		    v_resolved(l_param_line_num) := v_false;
		  END IF;
            END IF;

          ELSE
             g_error_api_path := 'Invalid Datatype:LOOKUP_ID='||to_char(l_lookup_id)||':'||g_error_api_path;
             CLOSE params_c;
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

        END LOOP;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: after Loop');


	  -- Determine how many parameter expressions were looped
	  -- through. If zero, then raise unexpected error. There
	  -- should never be a rule with a rule definition but
	  -- no parameter expressions.

	  last_line_num := v_resolved.last;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: last_line_num = '||last_line_num );

        IF last_line_num IS NULL THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: NO PARAMETERS:ACCT_ID='||to_char(l_acct_id)||':'||g_error_api_path);
          g_error_api_path := 'NO PARAMETERS:ACCT_ID='||to_char(l_acct_id)||':'||g_error_api_path;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    /* added to fix the case  of the v_counter looping thru to 1,
       when 1 may not exist  :- Subha July19, 2000
*/
           first_line_num:=v_resolved.first;
	  -- Retrieve the calculator rule for the current rule
	  -- being processed. There should always be a calculator
	  -- rule (i.e., 1 AND 2 OR 3 ) for a rule which has a
	  -- rule definition which is criteria of the cursor.

hr_utility.trace('Autodebug Message:PSP_AUTOPOP: before opening the cursor rules_c l_acct_id='|| l_acct_id);
        open rules_c(l_acct_id);
        fetch rules_c into l_calculator_rule;
        --dbms_output.put_line('l_calculator_rule '||','||l_calculator_rule);
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: inside the cursor rules_c l_calculator_rule' || l_calculator_rule);

        IF rules_c%NOTFOUND THEN
        --dbms_output.put_line('no rule found');
          close rules_c;
          g_error_api_path := 'NO RULE:ACCT_ID='||to_char(l_acct_id)||':'||g_error_api_path;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: cursor rules_c not found l_calculator_rule' || l_calculator_rule);

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: after l_cal_rule Raised FND_API.G_EXC_UNEXPECTED_ERROR');
	  END IF;
        close rules_c;

        -- Use the values of the resolved parameter
	  -- expressions held in the PL/SQL table v_resolved()
        -- to replace the parameter line numbers in the
	  -- rule string.

        resolved_rule := ltrim(l_calculator_rule);
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: resolved_rule '||l_calculator_rule);

	  --dbms_output.put_line('after rule assignment '||resolved_rule);

/* replaced 1 by first_line_num :- Subha July 19, 2000 */

	  FOR v_counter in REVERSE first_line_num..last_line_num LOOP
	   --dbms_output.put_line('v_counter '||to_char(v_counter));
	   --dbms_output.put_line('v_resolved '||v_resolved(v_counter));
           if v_resolved.exists(v_counter) then
          /*added so that exception is not raised for elements not present */
           resolved_rule := REPLACE(resolved_rule,TO_CHAR(v_counter),v_resolved(v_counter));
	   --dbms_output.put_line('resolved_rule '||resolved_rule);
          end if;
        END LOOP;

           resolved_rule:=REPLACE(resolved_rule,v_true,'1=1');
           resolved_rule:=REPLACE(resolved_rule,v_false,'1=0');

	 -- dbms_output.put_line('Before call to resolve_rule with text string:'||resolved_rule);
hr_utility.trace('Autodebug Message:PSP_AUTOPOP '||resolved_rule);
     --   IF resolve_rules(resolved_rule) THEN   bug fix 2023955
        IF resolve_rules_new(resolved_rule) THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP rule is true ');
        --   dbms_output.put_line('RULE IS TRUE!!!');
          l_rule_match := TRUE;
	    EXIT;
        ELSE
hr_utility.trace('Autodebug Message:PSP_AUTOPOP rule is false');
   	  --   dbms_output.put_line('RULE IS FALSE!!!');
          --null;
  	  END IF;

      END LOOP;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: outside of outer loop');

        lookup_array.delete;
      IF l_rule_match THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: in side IF l_rule_match ' );
        IF p_acct_type = 'E' THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: inside IF p_acct_type = E');
          ret_expenditure_type := l_expenditure_type;
        ELSIF p_acct_type = 'N' THEN
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: inside IF p_acct_type = N');
          -- *************************************************************
          -- Make calls to FND_FLEX_EXT
          -- *************************************************************
/* For Bug 1907209 : Natural Bypass Account :   Call to get the original segments has been moved to the top
becase of the enhancement -lveerubh
	    ccid_exists := FND_FLEX_EXT.get_segments(application_short_name => short_name,
							key_flex_code          => flex_code,
							structure_number       => struct_num,
							combination_id         => p_gl_code_combination_id,
							n_segments		     => nsegs,
							segments		     => segs);
--DBMS_OUTPUT.PUT_LINE('nsegs'||','||to_char(nsegs));
--DBMS_OUTPUT.PUT_LINE('p_gl_code_combination_id'||','||to_char(p_gl_code_combination_id));
	    IF (ccid_exists = TRUE) THEN
	   */

	      /* IF (ccid_exists = TRUE) THEN
		    FOR i in 1..nsegs loop
	      	cat_segs := cat_segs || '(' || segs(i) || ')';
	          end loop;
	        ELSE
                cat_segs := 'INVALID.  Message = ';
		    cat_segs := cat_segs || FND_MESSAGE.GET;
	        END IF;
              --DBMS_OUTPUT.put_line('cat-segs is '||cat_segs);

	        segs(nsegs) := l_natural_account;
              cat_segs := '';
              IF (ccid_exists = TRUE) THEN
		    FOR i in 1..nsegs loop
		      cat_segs := cat_segs || '(' || segs(i) || ')';
		    end loop;
	        ELSE
                cat_segs := 'INVALID.  Message = ';
		    cat_segs := cat_segs || FND_MESSAGE.GET;
	        END IF;
	        --DBMS_OUTPUT.put_line('New cat-segs is '||cat_segs); */
/*Instead of choosing a last segment it is better to give  client a chance to select a
  Natural account seg serial num depending on the profile setting*/

              --  l_seg_no := TO_NUMBER(FND_PROFILE.VALUE('PSP_AUTOP_SEG_NUM'));
/* For Bug 1907209 : Natural By Pass Account Enhancement: Commenting the code
                      l_seg_no:=l_segment_num;
                  if (l_seg_no >nsegs) or (l_seg_no IS NULL) THEN
                   FND_MESSAGE.SET_NAME('PSP','PSP_AUTOP_SEG_NUM');
                  -- APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
*/
   	      --segs(nsegs ) := l_natural_account;
                segs(l_seg_no)  := l_natural_account;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: before calling FND_FLEX_EXT.get_combination_id') ;
		combo_valid := FND_FLEX_EXT.get_combination_id(application_short_name => short_name,
									     key_flex_code          => flex_code,
									     structure_number       => struct_num,
									     validation_date        => SYSDATE,
									     n_segments		    => nsegs,
									     segments		    => segs,
									     combination_id         => new_gl_ccid);
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: after calling FND_FLEX_EXT get_combination_id combo_valid = ');

		IF (combo_valid = TRUE) THEN
		  ret_gl_code_combination_id := new_gl_ccid;
            ELSE
		  g_error_api_path := 'FND_FLEX_EXT.get_combination_id:Error creating new ccid with old CCID = '
						||p_gl_code_combination_id||': Object_code = '||l_natural_account||':'||g_error_api_path;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP:'|| g_error_api_path);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
/* For Bug 1907209 : Natural Bypass Account :   Call to get the original segments has been moved to the top
becase of the enhancement -lveerubh

	    ELSE
            g_error_api_path := 'FND_FLEX_EXT.get_segments:CCID'||p_gl_code_combination_id||' passed in does not exist'
						||':'||g_error_api_path;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
*/
	  END IF;

        retcode := FND_API.G_RET_STS_SUCCESS;
        -- --dbms_output.put_line('Rule was found!!!');
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: SUCCESS RULE FOUND');
      ELSE
        retcode := FND_API.G_RET_STS_ERROR;
        -- --dbms_output.put_line('No rule found that matched.');
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: NO RULE FOUND');
      END IF;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: END MAIN with out Exception'||retcode);
-- hr_utility.trace_off ;  Commented by tbalacha

EXCEPTION
  WHEN BY_PASS_FOUND THEN
    ret_expenditure_type := p_expenditure_type;
    retcode := FND_API.G_RET_STS_SUCCESS;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: EXCEPTIOn BY_PASS_FOUND');

  WHEN NO_PERIOD_TYPE THEN
    retcode := FND_API.G_RET_STS_UNEXP_ERROR;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: EXCEPTIOn NO_PERIOD_TYPE');

 -- For Bug  1907209 : Natrual Bypass Account Enhancement - Added the following Exception -lveerubh
  WHEN BY_PASS_NA_FOUND THEN
    ret_gl_code_combination_id  := 	p_gl_code_combination_id;
    			retcode := 	FND_API.G_RET_STS_SUCCESS;
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: EXCEPTIOn BY_PASS_NA_FOUND');
  WHEN OTHERS THEN
    --dbms_output.put_line('Exception in Auto-Population:PSP_AUTOPOP:'||g_error_api_path);
hr_utility.trace('Autodebug Message:PSP_AUTOPOP: EXCEPTIOn OTHERS');

    retcode := FND_API.G_RET_STS_UNEXP_ERROR;
END main;

END;

/
