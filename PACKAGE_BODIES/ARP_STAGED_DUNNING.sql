--------------------------------------------------------
--  DDL for Package Body ARP_STAGED_DUNNING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_STAGED_DUNNING" as
/* $Header: ARCUSDLB.pls 115.10 2002/11/15 02:28:51 anukumar ship $ */

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE VARIABLES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/
-- to store SELECT Statement
  sql_statement		VARCHAR2(2000);


/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    staged_dunning( site       IN site_type			              |
 |		     ,parameter  IN parameter_type			      |
 |    		     ,letter_tab IN OUT NOCOPY letter_id_tab  			      |
 |		     ,letter_count IN OUT NOCOPY NUMBER                              |
 |                   ,single_letter_flag IN VARCHAR2) RETURN BOOLEAN AS       |
 |                                                                            |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Given an input list of parameters for a customer/site, get dunning let- |
 |    ters for on which the open payment  schedules of this customer/site will|
 |    be printed. Return FALSE if NO letter could be found                    |
 |                                                                            |
 |                                                                            |
 | MODIFIES                                                                   |
 |    letter_tab  store dunning letter information                            |
 |    letter_count count dunning_letters found				      |
 |                                                                            |
 | RETURNS                                                                    |
 |    TRUE   - at least 1 dunning letter found                                |
 |    FALSE  - no dunning letter found                                        |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |   7/31/95  Christine Vogel  Created                                        |
 |   8/7/96   Paul Rooney      Modified to accept single_letter_flag          |
 |   8/25/96  Simon Jou        Modified for staged dunning/credit memo        |
 *----------------------------------------------------------------------------*/

FUNCTION staged_dunning( site         IN site_type
			,parameter    IN parameter_type
			,letter_tab   IN OUT NOCOPY letter_id_tab
			,letter_count IN OUT NOCOPY NUMBER
                        ,single_letter_flag IN VARCHAR2) RETURN BOOLEAN AS

-- define array to store distinct dunning levels
  TYPE leveltab IS TABLE OF ar_payment_schedules.staged_dunning_level%TYPE
	INDEX BY BINARY_INTEGER;
  level_tab	leveltab;

-- define cursor for the dynamic SELECT of the open payment schedules
  ps_cursor	integer;
  sum_cursor	integer;

-- define variables to select values in
  ps_id		          NUMBER(15);
  inv_code	          VARCHAR2(15);

  curr_code               VARCHAR2(15);
  adr		          NUMBER;
  sum_adr                 NUMBER;
  days_late	          NUMBER;
  st_dunning_level        NUMBER(3);
  dunning_level_override_date       DATE;

-- define other variables
  current_dun_date      DATE;
  ok_flag  		BOOLEAN;
  prev_currency		VARCHAR2(15);
  dun_flag		BOOLEAN;
  dun_ok		BOOLEAN;
  change_flag		BOOLEAN;
  i			NUMBER(4);
  j			NUMBER(4);
  min_dun_amount	NUMBER;
  min_dun_inv_amount	NUMBER;
  help_level		NUMBER(2);
  ignore                INTEGER;
  id		        NUMBER;
  error_message         varchar2(2000);
  level_tab_dummy   leveltab;
  letter_tab_dummy  letter_id_tab;
  t                     NUMBER(4);
  sql_statement_s       VARCHAR2(2000);

BEGIN

  -- initialize the array
  level_tab := level_tab_dummy;
  letter_tab := letter_tab_dummy;

  -- build the SELECT statement to retrieve the open payment schedules for cus-
  -- tomer/site which are not Guarantees and are not unapproved adjustments
  sql_statement :=
	'SELECT	  ps.payment_schedule_id'				||
		',ps.invoice_currency_code'				||
		',ps.amount_due_remaining'				||
		',fnd_date.canonical_to_date(:b_dun_date) - ps.due_date ' 	||
		',ps.staged_dunning_level'	         		||
		',ps.dunning_level_override_date'          		||
	  ' FROM  ar_payment_schedules ps';

  sql_statement_s :=
	'SELECT	  ps.invoice_currency_code, '                           ||
                ' sum(ps.amount_due_remaining) '                        ||
        ' FROM   ar_payment_schedules ps';

  if parameter.transaction_type_from is not null
     OR
     parameter.transaction_type_to is not null then
    sql_statement := sql_statement 					||
	', ra_cust_trx_types t ';
    sql_statement_s := sql_statement_s 					||
	', ra_cust_trx_types t ';

  end if;

/* Refered to bug # 436336
   Transaction types such as CM or PMT are also needed in deciding a
   dunning letter.
   The idea is that: besides just taking the individual INV type trx into
   account, the sum of INV, CM and PMT of the same currency should be greater
   or equal than minimum dunning amount for single dunning letter option.
   Otherwise, the program may pick up some single trx which appears that it
   should be dunned, and use that as an indication to choose a dunning letter.
   But in actual fact, the program should have calculated the sum of the trxs
   (INV, PMT and CM) and found out NOCOPY the sum would have been lesser than min
   dunning amount and that letter should never have be chosen.
 */

   sql_statement := sql_statement					||
	 ' WHERE  ps.customer_id	= :b_customer_id '		||
	   ' AND  ps.status		= ''OP'''			||
	   ' AND  nvl(ps.exclude_from_dunning_flag,''N'') = ''N'''      ||
           ' AND  ps.class NOT in (''GUAR'')';
   sql_statement_s := sql_statement_s	           			||
         ' WHERE  ps.customer_id	= :b_customer_id '		||
	   ' AND  ps.status		= ''OP'''			||
	   ' AND  nvl(ps.exclude_from_dunning_flag,''N'') = ''N'''      ||
           ' AND  ps.class NOT in (''GUAR'')';
  -- bug # 436336: changed form the below:
  --         ' AND  ps.class NOT in (''GUAR'', ''CM'', ''PMT'')';
 /* 2107939
 On Account and Unapplied Payments should only be considered if the
 Dunning Letter Set has the 'Include Unapplied Receipts' field set to
 Yes. Added the If condition below.
 Start of bug fix for 2107939. */

   IF site.include_payments = 'N' THEN
	sql_statement := sql_statement                                  ||
              ' AND ps.class NOT IN (''PMT'')';
   	sql_statement_s := sql_statement_s				||
           ' AND  ps.class NOT IN (''PMT'')';
   END IF;
 /* End of bug fix for 2107939.*/
  if site.grace_days = 'Y' then
       sql_statement := sql_statement					||
	  ' AND  nvl(ps.trx_date,fnd_date.canonical_to_date(:b_dun_date))+'||
               ' to_number(:b_payment_grace_days) '		        ||
		  ' <= fnd_date.canonical_to_date(:b_dun_date)';
       sql_statement_s := sql_statement_s				||
	  ' AND  nvl(ps.trx_date,fnd_date.canonical_to_date(:b_dun_date))+'||
               ' to_number(:b_payment_grace_days) '		        ||
		  ' <= fnd_date.canonical_to_date(:b_dun_date)';

  else
       sql_statement := sql_statement					||
	   ' AND  nvl(ps.trx_date,fnd_date.canonical_to_date(:b_dun_date))'||
		  ' <= fnd_date.canonical_to_date(:b_dun_date)';
       sql_statement_s := sql_statement_s				||
	   ' AND  nvl(ps.trx_date,fnd_date.canonical_to_date(:b_dun_date))'||
		  ' <= fnd_date.canonical_to_date(:b_dun_date)';

  end if;

  if parameter.transaction_type_from is not null
     OR
     parameter.transaction_type_to is not null
  then
	sql_statement := sql_statement					||
	' AND ps.cust_trx_type_id = t.cust_trx_type_id ';
	sql_statement_s := sql_statement_s				||
	' AND ps.cust_trx_type_id = t.cust_trx_type_id ';

  end if;

  if parameter.transaction_type_from is not null
     AND
     parameter.transaction_type_to is not null
     AND
      parameter.transaction_type_from = parameter.transaction_type_to
  then
      sql_statement := sql_statement					||
 	' AND t.name = :b_transaction_type_from ';
      sql_statement_s := sql_statement_s				||
 	' AND t.name = :b_transaction_type_from ';
  else
     if parameter.transaction_type_from is not null
     then
       sql_statement := sql_statement					||
 	' AND t.name||'''' >= :b_transaction_type_from ';
       sql_statement_s := sql_statement_s				||
 	' AND t.name||'''' >= :b_transaction_type_from ';
     end if;
     if parameter.transaction_type_to is not null
     then
       sql_statement := sql_statement					||
 	' AND t.name||'''' <= :b_transaction_type_to ';
       sql_statement_s := sql_statement_s				||
 	' AND t.name||'''' <= :b_transaction_type_to ';
     end if;
  end if;

  if site.dunning_level = 'S' then
    sql_statement := sql_statement					||
	    ' AND ps.customer_site_use_id	= :b_site_use_id';
    sql_statement_s := sql_statement_s					||
	    ' AND ps.customer_site_use_id	= :b_site_use_id';
  end if;

  if site.dun_disputed_items = 'N' then
    sql_statement  := sql_statement					||
	' AND  nvl(ps.amount_in_dispute, 0) = 0 '			||
	' AND NOT EXISTS('						||
		'SELECT ''Unapproved Adjustments '''			||
		  ' FROM  ar_adjustments adj'				||
		 ' WHERE  adj.payment_schedule_id = ps.payment_schedule_id'||
		   ' AND  adj.status NOT IN (''A'',''R'',''U''))';
    sql_statement_s  := sql_statement_s					||
	' AND  nvl(ps.amount_in_dispute, 0) = 0 '			||
	' AND NOT EXISTS('						||
		'SELECT ''Unapproved Adjustments '''			||
		  ' FROM  ar_adjustments adj'				||
		 ' WHERE  adj.payment_schedule_id = ps.payment_schedule_id'||
		   ' AND  adj.status NOT IN (''A'',''R'',''U''))';
  end if;

  sql_statement_s  := sql_statement_s					||
  ' AND ps.invoice_currency_code = :curr';

  sql_statement := sql_statement					||
	' ORDER BY ps.invoice_currency_code';
  sql_statement_s := sql_statement_s					||
	' GROUP BY ps.invoice_currency_code'                            ||
	' ORDER BY ps.invoice_currency_code';
  -- bug #436336 : changed from the below:
  --    ' ORDER BY ps.staged_dunning_level';

  ps_cursor   := dbms_sql.open_cursor;

  dbms_sql.parse(ps_cursor, sql_statement, dbms_sql.v7 );

  -- bind variables into placeholder
  dbms_sql.bind_variable(ps_cursor,':b_dun_date',parameter.dun_date);
  if site.dunning_level = 'S' then
      dbms_sql.bind_variable(ps_cursor,':b_site_use_id',site.site_use_id);
  end if;
  dbms_sql.bind_variable(ps_cursor,':b_customer_id',site.customer_id);
  if site.grace_days = 'Y' then
      dbms_sql.bind_variable(ps_cursor,':b_payment_grace_days',
                    site.payment_grace_days);
  end if;

  if parameter.transaction_type_from is not null
     AND
     parameter.transaction_type_to is not null
     AND
     parameter.transaction_type_from = parameter.transaction_type_to
  then
        dbms_sql.bind_variable(ps_cursor,':b_transaction_type_from',
			parameter.transaction_type_from );
  else
       if parameter.transaction_type_from is not null
       then
         dbms_sql.bind_variable(ps_cursor,':b_transaction_type_from',
			parameter.transaction_type_from );
        end if;
       if parameter.transaction_type_to is not null
       then
         dbms_sql.bind_variable(ps_cursor,':b_transaction_type_to',
			parameter.transaction_type_to );
        end if;
  end if;

  -- specify columns to be selected in
  dbms_sql.define_column(ps_cursor,1,ps_id);
  dbms_sql.define_column(ps_cursor,2,curr_code,15);
  dbms_sql.define_column(ps_cursor,3,adr);
  dbms_sql.define_column(ps_cursor,4,days_late);
  dbms_sql.define_column(ps_cursor,5,st_dunning_level);
  dbms_sql.define_column(ps_cursor,6,dunning_level_override_date);

  sum_adr := 0;
  dun_ok        := FALSE;
  ignore        := dbms_sql.execute(ps_cursor);
  prev_currency := '0';
  current_dun_date := fnd_date.canonical_to_date(parameter.dun_date);

  <<Open_Payment_Loop>>
LOOP
	if dbms_sql.fetch_rows(ps_cursor) <= 0 then
	   exit Open_Payment_Loop;
	end if;

 	-- get fetched values from the variables
	dbms_sql.column_value(ps_cursor,1,ps_id);
	dbms_sql.column_value(ps_cursor,2,curr_code);
	dbms_sql.column_value(ps_cursor,3,adr);
	dbms_sql.column_value(ps_cursor,4,days_late);
	dbms_sql.column_value(ps_cursor,5,st_dunning_level);
	dbms_sql.column_value(ps_cursor,6,dunning_level_override_date);

	if curr_code <> prev_currency then
	  ok_flag := ARP_STAGED_DUNNING.get_cpa(site,curr_code,min_dun_amount,
			min_dun_inv_amount);
	  if ok_flag = FALSE then
		exit Open_Payment_Loop;
	  end if;
	  prev_currency := curr_code;
	end if;

       dun_flag := FALSE;
       if ((site.grace_days = 'N' and days_late >= 0 )
	or
	(site.grace_days = 'Y' and days_late >= site.payment_grace_days ))
	AND
	( adr >= min_dun_inv_amount ) then
  --	bug # 436336: changed from below:
  --    ( adr >= min_dun_inv_amount ) then

	dun_flag := ARP_STAGED_DUNNING.get_new_dunning_level(ps_id
				,st_dunning_level
				,current_dun_date
				,dunning_level_override_date
                                ,days_late
                                ,site.letter_set_id);

 -- For bug# 436336
 -- for this ps_id find out NOCOPY if the sum of INV, PMT or CM of the same currency
 -- is <0. if so, then don't insert this transaction into the level tab;
 -- Only will be done if a new dunning level has been assigned.

  if (dun_flag = TRUE) then

    -- Open cursor
       sum_cursor  := dbms_sql.open_cursor;
    -- Parse cursor
       dbms_sql.parse(sum_cursor, sql_statement_s, dbms_sql.v7 );
    -- Bind variables

       dbms_sql.bind_variable(sum_cursor,':b_dun_date',parameter.dun_date);
       if site.dunning_level = 'S' then
            dbms_sql.bind_variable(sum_cursor,':b_site_use_id',site.site_use_id);
       end if;
       dbms_sql.bind_variable(sum_cursor,':b_customer_id',site.customer_id);
       if site.grace_days = 'Y' then
           dbms_sql.bind_variable(sum_cursor,':b_payment_grace_days',
                    site.payment_grace_days);
       end if;

      if parameter.transaction_type_from is not null
         AND
          parameter.transaction_type_to is not null
         AND
          parameter.transaction_type_from = parameter.transaction_type_to
      then
         dbms_sql.bind_variable(sum_cursor,':b_transaction_type_from',
			parameter.transaction_type_from );
      else
         if parameter.transaction_type_from is not null
         then
           dbms_sql.bind_variable(sum_cursor,':b_transaction_type_from',
			parameter.transaction_type_from );
          end if;
         if parameter.transaction_type_to is not null
         then
           dbms_sql.bind_variable(sum_cursor,':b_transaction_type_to',
			parameter.transaction_type_to );
        end if;
      end if;
      dbms_sql.bind_variable(sum_cursor,':curr',
		     	curr_code );

    -- Define the output column
       dbms_sql.define_column(sum_cursor, 1, inv_code, 15);
       dbms_sql.define_column(sum_cursor, 2, sum_adr);

    -- Execute
       ignore        := dbms_sql.execute(sum_cursor);

    -- Fetch a row
       if dbms_sql.fetch_rows(sum_cursor) <= 0 then
	  exit Open_Payment_Loop;
       end if;

    -- Get column's value
       dbms_sql.column_value(sum_cursor, 1, inv_code);
       dbms_sql.column_value(sum_cursor, 2, sum_adr);

    -- Close cursor
       dbms_sql.close_cursor(sum_cursor);
  end if;

  if (sum_adr < min_dun_amount) then
      dun_flag := FALSE;
  end if;

-- end of # bug 436336

	-- CONTINUE processing only if open payment schedule should be dunned
	-- get min_dun_amount and min_dun_inv_amount only if new dunning level
	-- is in the range selected by user( parameter )

	if dun_flag = TRUE
	AND
	 st_dunning_level >= parameter.dunning_level_from
	   AND
	   st_dunning_level <= parameter.dunning_level_to then

                -- save distinct dunning level into array
		change_flag := FALSE;
		i := 1;
		<<Level_Loop>>
		LOOP
		  BEGIN
		   if level_tab(i) = st_dunning_level then
			change_flag := TRUE;
			exit Level_Loop;
		   end if;
		   i := i + 1;
		  EXCEPTION
		    when NO_DATA_FOUND then
			exit Level_Loop;
		  END;
		END LOOP Level_Loop;
		if change_flag = FALSE then  -- level not yet in array
			level_tab(i) := st_dunning_level;
		end if;
	end if;     -- end of level in range
        end if;     -- end of open payment dunning
        if dun_flag = TRUE then
  		dun_ok := TRUE;
        end if;
--exit Open_Payment_Loop;
  END LOOP Open_Payment_Loop;

-- return FALSE if no open payment schedule found or function get_cpa returned
-- FALSE
  if ok_flag = FALSE OR dbms_sql.last_row_count <= 0 OR dun_ok = FALSE then
     if dbms_sql.last_row_count <= 0 OR dun_ok = FALSE then
       letter_count := 0;
       dbms_sql.close_cursor(ps_cursor);
       return(TRUE);
    else
       dbms_sql.close_cursor(ps_cursor);
       return( FALSE );
    end if;
  end if;
  dbms_sql.close_cursor(ps_cursor);


  -- sort the array of dunning levels
  change_flag := TRUE;
  <<While_loop>>
  WHILE( change_flag ) LOOP
    i := 1;
    change_flag := FALSE;
    <<Change_Loop>>
    LOOP
	BEGIN
	  if level_tab(i) > level_tab(i+1) then
		help_level     := level_tab(i);
		level_tab(i)   := level_tab(i+1);
		level_tab(i+1) := help_level;
		change_flag    := TRUE;
	  end if;
          i := i + 1;
	EXCEPTION
	  when NO_DATA_FOUND then
		exit Change_Loop;
	END;
    END LOOP Change_Loop;
  END LOOP While_Loop;


  -- for each dunning level from array, find corresponding dunning letter
  -- MAX_STAGED DUNNING distinct dunning letters will be supported. If more
  -- return FALSE;

    if nvl(single_letter_flag,'N') <> 'Y' then
      i := 1;
    end if;
  <<Letter_Loop>>
  LOOP
    -- because NO_DATA_FOUND can be raised from SELECT and from table
    -- define this block for table and next one for SELECT
    BEGIN
      help_level := level_tab(i);
    EXCEPTION
      when NO_DATA_FOUND then
	exit Letter_Loop;
    END ;
    BEGIN
	SELECT	dlsl.dunning_letter_id
	  INTO  id
	  FROM  ar_dunning_letter_set_lines dlsl
	 WHERE  dlsl.dunning_letter_set_id = site.letter_set_id
	   AND  help_level BETWEEN dlsl.range_of_dunning_level_from
				 AND dlsl.range_of_dunning_level_to;

	change_flag := FALSE;
	j := 1;
	<<Distinct_Letter_Loop>>
	LOOP
	  BEGIN

	   if letter_tab(j) = id then
		change_flag := TRUE;
		exit Distinct_Letter_Loop;
	   end if;
	   j := j + 1;
	  EXCEPTION
	    when NO_DATA_FOUND then
		exit Distinct_Letter_Loop;
	  END;
	END LOOP Distinct_Level_Loop;
	if change_flag = FALSE then  -- letter not yet in array

		letter_tab(j) := id;
	end if;

	i := i +1;
    EXCEPTION
	when OTHERS then
		return( FALSE );
    END;
  END LOOP Letter_Loop;

  letter_count := j ;

  if letter_count  >  MAX_STAGED_DUNNING   then
	return(FALSE);
  end if;

  return( TRUE );
END staged_dunning;

/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    get_cpa( site		  IN site_type                                |
 |	      ,curr_code	  IN VARCHAR2				      |
 |	      ,min_dun_amount	  IN OUT NOCOPY NUMBER				      |
 |	      ,min_dun_inv_amount IN OUT NOCOPY NUMBER ) RETURN BOOLEAN	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    for a given customer/site and currency get the minimum dunning amount   |
 |    and minimum dunning invoice amount				      |
 |    If the site has a CUSTOMER dunning level, then only the customer level  |
 |    profile will be queried. If SITE then the site level profile will be    |
 |    examined first. If this does not exist, then the values will be taken   |
 |    from customer level. If this does not exist the amounts will be 0       |
 |									      |
 | MODIFIES								      |
 |    min_dun_amount     store the amount found				      |
 |    min_dun_inv_amount store amount found				      |
 |									      |
 | RETURNS                                                                    |
 |    TRUE  if no error occured                                               |
 |    FALSE else							      |
 |                                                                            |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |  7/31/95  Christine Vogel  Created                                         |
 |                                                                            |
 *----------------------------------------------------------------------------*/

FUNCTION get_cpa(site			IN site_type
	 	, curr_code		IN VARCHAR2
		, min_dun_amount	OUT NOCOPY NUMBER
		, min_dun_inv_amount	OUT NOCOPY NUMBER ) RETURN BOOLEAN AS
BEGIN
  if site.dunning_level = 'S' then
	SELECT	 nvl(site_cpa.min_dunning_amount,
		    nvl(cust_cpa.min_dunning_amount, 0 ))
		,nvl(site_cpa.min_dunning_invoice_amount,
		    nvl(cust_cpa.min_dunning_invoice_amount, 0 ))
	  INTO 	 min_dun_amount
		,min_dun_inv_amount
	  FROM	 hz_customer_profiles		cust_cp
		,hz_cust_profile_amts		cust_cpa
		,hz_customer_profiles		site_cp
		,hz_cust_profile_amts		site_cpa
	 where   CUST_CP.CUST_ACCOUNT_ID	= site.customer_id
	   AND	 cust_cp.site_use_id IS NULL
	   AND 	 cust_cpa.cust_account_profile_id(+)= cust_cp.cust_account_profile_id
	   AND 	 cust_cpa.currency_code(+)	= curr_code
	   AND	 site_cp.cust_account_id(+)	= cust_cp.cust_account_id
	   AND 	 site_cp.site_use_id(+)		= site.site_use_id
	   AND	 site_cpa.cust_account_profile_id(+)= site_cp.cust_account_profile_id
	   AND   site_cpa.currency_code(+)	= curr_code;
  else
      /* bug 2362943 : depending on profile value change where profile amounts are read from */

      if FND_PROFILE.value( 'AR_USE_STATEMENTS_AND_DUNNING_SITE_PROFILE' ) = 'N' then

	SELECT	 nvl(cust_cpa.min_dunning_amount, 0)
		,nvl(cust_cpa.min_dunning_invoice_amount, 0)
	  INTO 	 min_dun_amount
		,min_dun_inv_amount
	  FROM	 hz_customer_profiles		cust_cp
		,hz_cust_profile_amts		cust_cpa
	 WHERE   cust_cp.cust_account_id	= site.customer_id
	   AND	 cust_cp.site_use_id IS NULL
	   AND 	 cust_cpa.cust_account_profile_id(+)
                               = cust_cp.cust_account_profile_id
	   AND 	 cust_cpa.currency_code(+)	= curr_code;
      else
        SELECT  NVL(min_dunning_amount, 0) ,
                NVL(min_dunning_invoice_amount, 0)
          INTO  min_dun_amount,
                min_dun_inv_amount
          FROM  hz_cust_profile_amts
         WHERE  CUST_ACCOUNT_PROFILE_ID =
                        (SELECT cust_account_profile_id
                           FROM hz_customer_profiles
                          WHERE site_use_id = arpt_sql_func_util.get_bill_id(site.site_use_id))
           AND     currency_code = curr_code
           AND     CUST_ACCOUNT_ID = site.customer_id;
      end if;
  end if;
  return( TRUE );

EXCEPTION
  when OTHERS then
	return( FALSE );
END get_cpa;


/*----------------------------------------------------------------------------*
 | PUBLIC  FUNCTION                                                           |
 |    get_new_dunning_level( ps_id		     IN NUMBER                |
 |	                    ,staged_dunning_level    IN OUT NOCOPY NUMBER            |
 |             		    ,current_dun_date	     IN DATE                  |
 |	                    ,dunning_level_override_date  IN DATE             |
 |                          ,days_late IN NUMBER                              |
 |                          ,o_letter_set_id IN NUMBER ) RETURN BOOLEAN       |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    for a payment schedule get the new dunning level. The user has the      |
 |    possibility to update the dunning level. Thatfore , dunning level can   |
 |    not be increased by 1 with every printing of a dunning letter	      |
 |									      |
 |									      |
 | RETURNS                                                                    |
 |    TRUE if open payment should be dunned, else return FALSE                |
 |									      |
 | MODIFIES								      |
 |    staged_dunning_level						      |
 |                                                                            |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |  7/31/95  Christine Vogel  Created                                         |
 |  8/25/96  Simon Jou        Modified for staged dunning/credit memo         |
 *----------------------------------------------------------------------------*/


FUNCTION get_new_dunning_level(ps_id	   IN NUMBER
		  ,staged_dunning_level    IN OUT NOCOPY NUMBER
		  ,current_dun_date	   IN DATE
		  ,dunning_level_override_date IN DATE
                  ,days_late IN NUMBER
                  ,o_letter_set_id IN NUMBER ) RETURN BOOLEAN AS

  last_print_date	DATE;
  min_dunning_days      NUMBER;
  previously_dunned     BOOLEAN := TRUE;

--  cursor to get latest print for a given open payment schedule
--  Note: the new one is not in the ar_correspondence_pay_sched yet,
--  so this is the latest one for the existing records.

  CURSOR last_print IS
	SELECT  c.correspondence_date
	  FROM  ar_correspondence_pay_sched	cp
	       ,ar_correspondences		c
	       ,ar_dunning_letter_set_lines     dlsl
	 WHERE  cp.payment_schedule_id		= ps_id
	   AND  c.preliminary_flag		= 'N'
	   AND  cp.staged_dunning_level is NOT NULL
	   AND  dlsl.dunning_letter_set_id	= c.reference1
	   AND  dlsl.dunning_letter_id		= c.reference2
	   AND  cp.correspondence_id		= c.correspondence_id
      ORDER BY  c.correspondence_date DESC;

BEGIN

  OPEN last_print;
  FETCH last_print INTO last_print_date;

  -- if payment not yet dunned, cursor exception %NOTFOUND
  if last_print%NOTFOUND then
        previously_dunned := FALSE;
  end if;
  CLOSE last_print;

  SELECT min_days_between_dunning
  INTO   min_dunning_days
  FROM   ar_dunning_letter_set_lines
  WHERE  dunning_letter_set_id = o_letter_set_id
    AND  range_of_dunning_level_from <= (NVL(staged_dunning_level, 0)+1)
    AND  range_of_dunning_level_to   >= (NVL(staged_dunning_level, 0)+1);

-- If the open payment was previously dunned then
--    see if its dunning level has been overriden, if not, see the
--    last print date plus the min dunning days < current_dunning_days.
--    If WAS overriden, then both the override date AND the last print date
--    have to satisfy the above criteria at the same time.
-- If not previously dunned then
--   see if minimum dunning days <= days_late
--
-- If any of the above condition is true, increment the dunning level and
-- return true; else return false and dunning stays the same.

IF previously_dunned THEN
  IF dunning_level_override_date IS NULL THEN
      IF last_print_date + min_dunning_days <= current_dun_date THEN
 	 staged_dunning_level := nvl(staged_dunning_level,0) +1;
   	 return(TRUE);
      ELSE
	 return(FALSE);
      END IF;
  ELSE
      IF (dunning_level_override_date + min_dunning_days <= current_dun_date)
         AND (last_print_date + min_dunning_days <= current_dun_date) THEN
 	 staged_dunning_level := nvl(staged_dunning_level,0) +1;
   	 return(TRUE);
      ELSE
	 return(FALSE);
      END IF;
  END IF;
ELSE
 IF min_dunning_days <= days_late THEN
    staged_dunning_level := nvl(staged_dunning_level,0) +1;
    return(TRUE);
 ELSE
    return(FALSE);
 END IF;
END IF;

EXCEPTION
  when NO_DATA_FOUND then
    return(FALSE);

END get_new_dunning_level;


END ARP_STAGED_DUNNING;

/
