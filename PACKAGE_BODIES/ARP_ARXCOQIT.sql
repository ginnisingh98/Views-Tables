--------------------------------------------------------
--  DDL for Package Body ARP_ARXCOQIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ARXCOQIT" AS
/* $Header: ARCEQITB.pls 120.8 2006/04/07 17:52:33 kmaheswa ship $ */

/* Package private global variables */
TYPE literal_rec_type IS RECORD (
  literal_counter     NUMBER            ,
  bind_var_name       VARCHAR2(1000)    ,
  stripped_value      VARCHAR2(1000)
  );

--
-- Stripped where clause literal table
--
TYPE literal_tbl_type IS TABLE of literal_rec_type
  INDEX BY BINARY_INTEGER;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

-- 3804333
emb_quote          BOOLEAN := FALSE;

PROCEDURE Build_And_Bind ( p_in_where_clause         IN  VARCHAR2         ,
                           p_out_where_clause        OUT NOCOPY VARCHAR2         ,
                           p_literal_tbl             OUT NOCOPY literal_tbl_type ,
                           p_tbl_ctr                 OUT NOCOPY BINARY_INTEGER     );

/*1806931
 The total amount needs to be calculated only when the receipt
 had been applied to invoices in the same currency. If the receipt
 has been applied to invoices in different currencies, the total
 amount need not be computed. Added the local variable l_cur_count to
 get the total number of distinct currencies for the application.
*/
procedure history_total( p_where_clause IN varchar2, p_total IN OUT NOCOPY number)is
 l_select_cursor integer;
 l_ignore integer;
 l_amount number;
 l_cur_count number; /* 1806931 */
begin
-- arp_standard.enable_debug;
IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('Build_And_Bind: ' || 'where clause:' || p_where_clause );
END IF;
/* 1806931 Code Added Begins. */
/* Bugfix for 2112098 Check if the where clause passed has a payment_schedule_id=.
If yes, then split the where-clause to make use of bind variable.
Else, continues to work just as the way it did before this fix*/

 IF instr(p_where_clause,'PAYMENT_SCHEDULE_ID=') = 0 THEN

   l_select_cursor := dbms_sql.open_cursor;
   dbms_sql.parse(l_select_cursor,
        'select count(distinct(currency)) from ar_app_adj_v
	 where'|| p_where_clause,dbms_sql.v7);
   dbms_sql.define_column(l_select_cursor, 1 , l_cur_count);
   l_ignore := dbms_sql.execute(l_select_cursor);
   if dbms_sql.fetch_rows(l_select_cursor) > 0 then
    dbms_sql.column_value(l_select_cursor, 1, l_cur_count);
   else
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Build_And_Bind: ' || 'no rows');
    END IF;
   end if;
   if (l_cur_count = 1) then
	dbms_sql.close_cursor(l_select_cursor);
/* 1806931 Code added ends. */

 	l_select_cursor := dbms_sql.open_cursor;
 	dbms_sql.parse(l_select_cursor,
        	'select sum(total_amount) from ar_app_adj_v
			where'|| p_where_clause, dbms_sql.v7);
   	dbms_sql.define_column(l_select_cursor, 1 , l_amount);
  	l_ignore := dbms_sql.execute(l_select_cursor);
  	if dbms_sql.fetch_rows(l_select_cursor) > 0 then
   		dbms_sql.column_value(l_select_cursor, 1, l_amount);
 	else
  		IF PG_DEBUG in ('Y', 'C') THEN
  		   arp_standard.debug('Build_And_Bind: ' || 'no rows');
  		END IF;
 	end if;

	p_total := l_amount;
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('Build_And_Bind: ' || 'p_total =' || to_char(p_total) );
	   arp_standard.debug('Build_And_Bind: ' || 'l_amount =' || to_char(l_amount) );
	END IF;
	dbms_sql.close_cursor(l_select_cursor);

/*1806931 Code Added Begins */
   else
	p_total := 0;
	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('Build_And_Bind: ' || 'p_total =' || to_char(p_total) );
	END IF;
	dbms_sql.close_cursor(l_select_cursor);
   end if;
/* 1806931 Code Added Ends */
 ELSE
/* Bugfix for 2112098 begins here. Re-do the cursor with bind var for ps_id
if that is the parameter passed. */

   DECLARE
      l_select_stmt varchar2(1000);
      l_bind_ps_id NUMBER;
      l_where_clause varchar2(1000);
   BEGIN
       l_where_clause := replace(p_where_clause, ')');
       l_bind_ps_id := to_number(substr(l_where_clause,22 ));

       l_select_stmt := 'select count(distinct(currency)) from ar_app_adj_v
         where PAYMENT_SCHEDULE_ID= :ps_id ';

       l_select_cursor := dbms_sql.open_cursor;

       dbms_sql.parse(l_select_cursor, l_select_stmt ,dbms_sql.v7);

       dbms_sql.bind_variable ( l_select_cursor , ':ps_id' , l_bind_ps_id) ;

       dbms_sql.define_column(l_select_cursor, 1 , l_cur_count);
       l_ignore := dbms_sql.execute(l_select_cursor);

       if dbms_sql.fetch_rows(l_select_cursor) > 0 then
           dbms_sql.column_value(l_select_cursor, 1, l_cur_count);
       else
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Build_And_Bind: ' || 'no rows');
           END IF;
       end if;
       if (l_cur_count = 1) then
          dbms_sql.close_cursor(l_select_cursor);

          l_select_stmt := 'select sum(total_amount) from ar_app_adj_v
                         where PAYMENT_SCHEDULE_ID= :ps_id ';
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('Build_And_Bind: ' || l_select_stmt);
          END IF;

           l_select_cursor := dbms_sql.open_cursor;

           dbms_sql.parse(l_select_cursor,l_select_stmt , dbms_sql.v7);

           dbms_sql.bind_variable ( l_select_cursor , ':ps_id' , l_bind_ps_id );

           dbms_sql.define_column(l_select_cursor, 1 , l_amount);
           l_ignore := dbms_sql.execute(l_select_cursor);
           if dbms_sql.fetch_rows(l_select_cursor) > 0 then
                dbms_sql.column_value(l_select_cursor, 1, l_amount);
           else
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug('Build_And_Bind: ' || 'no rows');
                END IF;
           end if;

           p_total := l_amount;
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Build_And_Bind: ' || 'p_total =' || to_char(p_total) );
              arp_standard.debug('Build_And_Bind: ' || 'l_amount =' || to_char(l_amount) );
           END IF;
           dbms_sql.close_cursor(l_select_cursor);
        else
           p_total := 0;
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Build_And_Bind: ' || 'p_total =' || to_char(p_total) );
           END IF;
           dbms_sql.close_cursor(l_select_cursor);
        end if;
    END;
 END IF;
/* End of bugfix 2112438 */

-- arp_standard.enable_debug;
EXCEPTION
	WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Build_And_Bind: ' ||  'Exception:'|| to_char(p_total));
             END IF;
end;

-- Bug No. : 950002 : Removed folder_total and folder_func_total as these are included in fold_total.

/* This Procedure Calculates the entered total balance and the functional total
   balance for the passed in 'where clause ' */
--Bug 1563252 : Added the new argument p_from_clause

/*
1826455 fbreslin: Add a new parameter p_cur_count.  This will pass back to the
                  calling routine the number of distinct currencies that make
                  up the total.
*/

procedure fold_total( p_where_clause IN varchar2,
                      p_total        IN OUT NOCOPY number,
                      p_func_total   IN OUT NOCOPY number,
                      p_from_clause  IN varchar2 DEFAULT 'ar_payment_schedules_v',
                      p_cur_count    OUT NOCOPY number) is
 l_select_cursor    INTEGER;
 l_ignore           INTEGER;
 l_amount           NUMBER;
 l_func_amount      NUMBER;
 l_count            NUMBER;
 l_ctr              BINARY_INTEGER;
 l_tbl_ctr          BINARY_INTEGER;
 l_literal_tbl      literal_tbl_type;
 l_out_where_clause VARCHAR2(32767);
 l_actual_bind_var  VARCHAR2(2000);

 -- 3804333
 l_quote1           NUMBER;
 l_quote2           NUMBER;
 l_where_clause     VARCHAR2(32767);
BEGIN

   l_out_where_clause := '';

   p_total := 0;

   p_func_total := 0;

--  arp_standard.enable_debug;

/*-----------------------------------------------------------------------+
 |Removed the 'WHERE' from the Parse Statement , It now comes in         |
 |p_where_clause before the actual where clause , This is done to take   |
 |care of the Null Where Clause Case.                                    |
 +-----------------------------------------------------------------------*/

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'where clause:' || p_where_clause );
     arp_standard.debug('Build_And_Bind: ' || 'Opening Cursor');
  END IF;

  l_select_cursor := dbms_sql.open_cursor;

/*-----------------------------------------------------------------------+
 |Call the Build and Bind routine to strip where clause from literals and|
 |numeric constants and replace them with bind variables.                |
 +-----------------------------------------------------------------------*/
  IF p_where_clause IS NOT NULL THEN

     -- Bug 3804333 : need to pre-process p_where_clause to check if trx_number has '
     l_quote1 := instr(p_where_clause,'''',1,2);
     l_quote2 := instr(p_where_clause,'''',l_quote1+1,1);
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('l_quote1 = ' || to_char(l_quote1) ||
                           ' l_quote2 = ' || to_char(l_quote2));
     END IF;
     if l_quote2 - l_quote1 = 1 then
        -- trx_number has embedded ', temporarily change ' to ^
        l_where_clause := substrb(p_where_clause,1,l_quote1-1) ||
                          '^' || substrb(p_where_clause, l_quote2+1);
        emb_quote := TRUE;
        arp_standard.debug('l_where_clause = ' || l_where_clause);
     else
        l_where_clause := p_where_clause;
     end if;

     Build_And_Bind(l_where_clause, l_out_where_clause, l_literal_tbl, l_tbl_ctr);
  END IF;

/*-----------------------------------------------------------------------+
 |Parse the built statement along with the where clause.                 |
 +-----------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'Parsing statement ');
   arp_standard.debug('Build_And_Bind: ' || l_out_where_clause);
END IF;
--Bug 1563252 : modified the query string to add the from clause dynamically.

/* 3988361 :If the customer_id is used for selection the use n6 index */

IF p_from_clause = 'AR_PAYMENT_SCHEDULES_TRX2_V' AND INSTR(l_out_where_clause,'CUSTOMER_ID=') <> 0 THEN
  dbms_sql.parse(l_select_cursor,
                 'select /*+ INDEX(AR_PAYMENT_SCHEDULES_TRX2_V.ps AR_PAYMENT_SCHEDULES_N6) */
                             count( distinct invoice_currency_code ),
                             sum(amount_due_remaining),
                             sum(acctd_amount_due_remaining)
                    from '||p_from_clause||' '||l_out_where_clause, dbms_sql.v7);
ELSE
  dbms_sql.parse(l_select_cursor,
                 'select count( distinct invoice_currency_code ),
                         sum(amount_due_remaining),
                         sum(acctd_amount_due_remaining)
                   from '||p_from_clause||' '||l_out_where_clause,
     dbms_sql.v7);
END IF;

/*-----------------------------------------------------------------------+
 |Define columns for the select statement.                               |
 +-----------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'Defining Columns  +');
  END IF;

  dbms_sql.define_column(l_select_cursor, 1 , l_count);
  dbms_sql.define_column(l_select_cursor, 2 , l_amount);
  dbms_sql.define_column(l_select_cursor, 3 , l_func_amount);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'Defining Columns  -');
  END IF;

/*-----------------------------------------------------------------------+
 |Bind the variables built by Build_And_Bind routine with actual values  |
 +-----------------------------------------------------------------------*/
  IF ((l_literal_tbl.EXISTS(l_tbl_ctr)) AND (p_where_clause IS NOT NULL))  THEN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Build_And_Bind: ' || 'Binding Variables +');
     END IF;

     FOR l_ctr in 1..l_tbl_ctr LOOP

       l_actual_bind_var := '';

      --Bind variables
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Build_And_Bind: ' || 'l_literal_tbl('||l_ctr||').bind_var_name  = ' || l_literal_tbl(l_ctr).bind_var_name);
          arp_standard.debug('Build_And_Bind: ' || 'l_literal_tbl('||l_ctr||').stripped_value = ' || l_literal_tbl(l_ctr).stripped_value);
       END IF;

       l_actual_bind_var := rtrim(ltrim(l_literal_tbl(l_ctr).bind_var_name));

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Build_And_Bind: ' || 'l_actual_bind_var = '||l_actual_bind_var);
       END IF;

       dbms_sql.bind_variable(l_select_cursor, l_actual_bind_var, l_literal_tbl(l_ctr).stripped_value);

     END LOOP;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'Binding Variables -');
  END IF;

  END IF;

/*-----------------------------------------------------------------------+
 |Execute the SQL statement to calculate functional amount and accounted |
 |amount totals.                                                         |
 +-----------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'Executing Statement +');
  END IF;

  l_ignore := dbms_sql.execute(l_select_cursor);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'Executing Statement -');
  END IF;

  IF dbms_sql.fetch_rows(l_select_cursor) > 0 then

  /*-----------------------------------------------------------------------+
   |Fetch the column values, into actual variables                         |
   +-----------------------------------------------------------------------*/
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Build_And_Bind: ' || 'Fetching column values +');
     END IF;

     dbms_sql.column_value(l_select_cursor, 1, l_count);
     dbms_sql.column_value(l_select_cursor, 2, l_amount);
     dbms_sql.column_value(l_select_cursor, 3, l_func_amount);

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Build_And_Bind: ' || 'l_count '||l_count);
        arp_standard.debug('Build_And_Bind: ' || 'l_amount'||l_amount);
        arp_standard.debug('Build_And_Bind: ' || 'l_func_amount'||l_func_amount);
     END IF;

      IF l_count = 1 THEN
         p_total := l_amount;
      ELSE
         p_total := to_number(NULL);
      END IF;

      p_cur_count  := l_count;
      p_func_total := l_func_amount;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Build_And_Bind: ' || 'p_total '||p_total);
         arp_standard.debug('Build_And_Bind: ' || 'p_func_total'||p_func_total);
         arp_standard.debug('Build_And_Bind: ' || 'Fetching column values -');
      END IF;

  ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Build_And_Bind: ' || 'no rows');
         END IF;
  END IF;

 /*-----------------------------------------------------------------------+
  |Finally close the cursor                                               |
  +-----------------------------------------------------------------------*/
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Build_And_Bind: ' || 'Closing Cursor');
   END IF;
   dbms_sql.close_cursor(l_select_cursor);

   -- arp_standard.enable_debug;
EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Build_And_Bind: ' ||  'Exception:' );
        END IF;
END;

-- Bug 2089289
procedure fold_currency_code( p_where_clause IN varchar2,
                         p_from_clause  IN varchar2 DEFAULT 'ar_payment_schedules_v',
                         p_currency_code     OUT NOCOPY varchar2) is
 l_select_cursor    INTEGER;
 l_ignore           INTEGER;
 l_currency_code      VARCHAR2(15);
 l_ctr              BINARY_INTEGER;
 l_tbl_ctr          BINARY_INTEGER;
 l_literal_tbl      literal_tbl_type;
 l_out_where_clause VARCHAR2(32767);
 l_actual_bind_var  VARCHAR2(2000);

BEGIN

   l_out_where_clause := '';
   l_currency_code := '';

--  arp_standard.enable_debug;

/*-----------------------------------------------------------------------+
 |Removed the 'WHERE' from the Parse Statement , It now comes in         |
 |p_where_clause before the actual where clause , This is done to take   |
 |care of the Null Where Clause Case.                                    |
 +-----------------------------------------------------------------------*/
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('Build_And_Bind: ' || 'where clause:' || p_where_clause );
     arp_standard.debug('Build_And_Bind: ' || 'Opening Cursor');
  END IF;

  l_select_cursor := dbms_sql.open_cursor;

/*-----------------------------------------------------------------------+
 |Call the Build and Bind routine to strip where clause from literals and|
 |numeric constants and replace them with bind variables.                |
 +-----------------------------------------------------------------------*/
  IF p_where_clause IS NOT NULL THEN
     Build_And_Bind(p_where_clause, l_out_where_clause, l_literal_tbl, l_tbl_ctr);
  END IF;

/*-----------------------------------------------------------------------+
 |Parse the built statement along with the where clause.                 |
 +-----------------------------------------------------------------------*/
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('Build_And_Bind: ' || 'Parsing statement ');
    arp_standard.debug('Build_And_Bind: ' || l_out_where_clause);
 END IF;
  dbms_sql.parse(l_select_cursor,
                 'select invoice_currency_code  from '||p_from_clause||' '||l_out_where_clause,
                dbms_sql.v7);

/*-----------------------------------------------------------------------+
 |Define columns for the select statement.                               |
 +-----------------------------------------------------------------------*/

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'Defining Columns  +');
  END IF;
  dbms_sql.define_column(l_select_cursor, 1 ,l_currency_code,15);
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'Defining Columns  -');
  END IF;

/*-----------------------------------------------------------------------+
 |Bind the variables built by Build_And_Bind routine with actual values  |
 +-----------------------------------------------------------------------*/
  IF ((l_literal_tbl.EXISTS(l_tbl_ctr)) AND (p_where_clause IS NOT NULL))  THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Build_And_Bind: ' || 'Binding Variables +');
   END IF;

     FOR l_ctr in 1..l_tbl_ctr LOOP

       l_actual_bind_var := '';

      --Bind variables
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Build_And_Bind: ' || 'l_literal_tbl('||l_ctr||').bind_var_name  = ' || l_literal_tbl(l_ctr).bind_var_name);
          arp_standard.debug('Build_And_Bind: ' || 'l_literal_tbl('||l_ctr||').stripped_value = ' || l_literal_tbl(l_ctr).stripped_value);
       END IF;

       l_actual_bind_var := rtrim(ltrim(l_literal_tbl(l_ctr).bind_var_name));

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Build_And_Bind: ' || 'l_actual_bind_var = '||l_actual_bind_var);
       END IF;

       dbms_sql.bind_variable(l_select_cursor, l_actual_bind_var, l_literal_tbl(l_ctr).stripped_value);

     END LOOP;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'Binding Variables -');
  END IF;

  END IF;

/*-----------------------------------------------------------------------+
 |Execute the SQL statement to calculate functional amount and accounted |
 |amount totals.                                                         |
 +-----------------------------------------------------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'Executing Statement +');
  END IF;

  l_ignore := dbms_sql.execute(l_select_cursor);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'Executing Statement -');
  END IF;

  IF dbms_sql.fetch_rows(l_select_cursor) > 0 then

  /*-----------------------------------------------------------------------+
   |Fetch the column values, into actual variables                         |
   +-----------------------------------------------------------------------*/
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Build_And_Bind: ' || 'Fetching column values +');
     END IF;

     dbms_sql.column_value(l_select_cursor, 1, l_currency_code);

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Build_And_Bind: ' || 'l_currency_code '||l_currency_code);
     END IF;

      p_currency_code := l_currency_code;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Build_And_Bind: ' || 'p_currency_code'||p_currency_code);
         arp_standard.debug('Build_And_Bind: ' || 'Fetching column values -');
      END IF;

  ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Build_And_Bind: ' || 'no rows');
         END IF;
  END IF;

 /*-----------------------------------------------------------------------+
  |Finally close the cursor                                               |
  +-----------------------------------------------------------------------*/
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Build_And_Bind: ' || 'Closing Cursor');
   END IF;
   dbms_sql.close_cursor(l_select_cursor);

   -- arp_standard.enable_debug;
EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Build_And_Bind: ' ||  'Exception:' );
        END IF;
END;

-- End bug 2089289


procedure get_date( p_ps_id IN ar_dispute_history.payment_schedule_id%TYPE,
p_last_dispute_date IN OUT NOCOPY ar_dispute_history.start_date%TYPE ) is
begin
 select start_date into
  p_last_dispute_date
  from ar_dispute_history
  where payment_schedule_id = p_ps_id and
  end_date is null;
-- arp_standard.enable_debug;
EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Build_And_Bind: ' ||  'Exception:'|| to_char(p_last_dispute_date));
             END IF;
end;



procedure check_changed( p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
p_amount_in_dispute IN ar_payment_schedules.payment_schedule_id%TYPE, p_dispute_amount_changed IN OUT NOCOPY NUMBER ) IS
begin
 select count(*)
 into p_dispute_amount_changed
 from ar_payment_schedules
 where payment_schedule_id = p_ps_id
 and (( amount_in_dispute <> p_amount_in_dispute) OR
      (amount_in_dispute is NOT NULL and
           p_amount_in_dispute IS NULL ) OR
      ( p_amount_in_dispute IS NOT NULL and
          amount_in_dispute IS NULL ) );
-- arp_standard.enable_debug;
EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Build_And_Bind: ' ||  'Exception:'|| to_char(p_dispute_amount_changed));
             END IF;
end;



procedure get_flag( p_ps_id IN ar_dispute_history.payment_schedule_id%TYPE,
   p_ever_in_dispute_flag IN OUT NOCOPY varchar2)  IS
begin
  select decode(min(start_date),
                NULL , 'N',
                    'Y' )
  into p_ever_in_dispute_flag
  from ar_dispute_history
  WHERE payment_schedule_id = p_ps_id;
-- arp_standard.enable_debug;
EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Build_And_Bind: ' ||  'Exception in ever_in_dispute_flag' );
             END IF;
end;

procedure get_days_late( p_due_date IN ar_payment_schedules.due_date%TYPE,
   p_days_late IN OUT NOCOPY number)  IS
begin
     select trunc(sysdate) - p_due_date
     into p_days_late
     from dual;
-- arp_standard.enable_debug;
EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Build_And_Bind: ' ||  'Exception in ever_in_dispute_flag' );
             END IF;
end;

/* ===============================================================================
 | PROCEDURE Build_And_Bind
 |
 | DESCRIPTION
 |      Strips a where clause storing the literal values and numeric constants,
 |      replacing them with bind variables. The actual values to be bound later
 |      are stored in a PLSQL table along with the actual bind variable so that
 |      they can be bound later.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |      p_in_where_clause   IN     Input where clause to be stripped
 |      p_out_where_clause  OUT NOCOPY    Output where clause containing bind variables
 |      p_literal_tbl       OUT NOCOPY    Table containing bind variable name and values
 |      p_tbl_ctr           OUT NOCOPY    Count of bind variables
 |
 | Modification History
 | 16th May 99         Vikram Ahluwalia    Created
 *==============================================================================*/
PROCEDURE Build_And_Bind ( p_in_where_clause         IN  VARCHAR2         ,
                           p_out_where_clause        OUT NOCOPY VARCHAR2         ,
                           p_literal_tbl             OUT NOCOPY literal_tbl_type ,
                           p_tbl_ctr                 OUT NOCOPY BINARY_INTEGER     ) IS

l_in_where_clause      VARCHAR2(32767)       ;

l_length               BINARY_INTEGER        ;

l_ctr                  BINARY_INTEGER        ;

l_bind_ctr             BINARY_INTEGER := 0   ;

l_bind_var             VARCHAR2(1000)        ;

-- bug2710965 Increased size to (3) for multi-byte characater
l_temp_cell            VARCHAR2(3)           ;

-- bug2710965 Increased size to (3) for multi-byte characater
l_prev_cell            VARCHAR2(3)           ;

l_actual_where_clause  VARCHAR2(32767)       ;

l_balance_clause       VARCHAR2(32767)       ;

char_literal_on        BOOLEAN := FALSE      ;

num_literal_on         BOOLEAN := FALSE      ;

not_bound_flag         BOOLEAN := FALSE      ;

l_build_where          BOOLEAN := FALSE      ;

l_tbl_ctr              BINARY_INTEGER := 0   ;

l_literal_tbl          literal_tbl_type      ;

l_amount               NUMBER ;

l_func_amount          NUMBER ;

l_count                NUMBER ;

l_by_clause_pos        BINARY_INTEGER;

l_actual_length        BINARY_INTEGER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'l_in_where_clause ' || l_in_where_clause);
  END IF;

  l_in_where_clause := p_in_where_clause;

/*---------------------------------------------------------------+
 |Get the length in characters of the where clause as Step 1     |
 +---------------------------------------------------------------*/
  select length(l_in_where_clause)
  into l_actual_length
  from dual;

  l_by_clause_pos := 0;

/*--------------------------------------------------------------------+
 |Strip the 'order by' clause if it is present as part of where clause|
 +--------------------------------------------------------------------*/
  select instr(l_in_where_clause, 'order by')
  into l_by_clause_pos
  from dual;

  IF (l_by_clause_pos > 0) THEN
     l_length := l_by_clause_pos -1;
  ELSE

  /*--------------------------------------------------------------------+
   |Strip the 'group by clause' if it is present as part of where clause|
   +--------------------------------------------------------------------*/
     SELECT INSTR(l_in_where_clause, 'group by')
     INTO   l_by_clause_pos
     FROM DUAL;

     IF (l_by_clause_pos > 0) THEN
        l_length := l_by_clause_pos - 1;
     ELSE
        l_length := l_actual_length;
     END IF;

  END IF; --end if l_by_clause_pos > 0

  l_temp_cell := ' ';

/*----------------------------------------------------------------+
 |Loop through the where clause storing it into a table as Step 2 |
 +----------------------------------------------------------------*/
  FOR l_ctr IN 1..(l_length+1) LOOP

      l_prev_cell := l_temp_cell;

      IF (l_ctr = (l_length + 1)) THEN
         l_temp_cell := ' ';
      ELSE
         select substr(l_in_where_clause, l_ctr, 1)
         into l_temp_cell
         from dual;
      END IF;

   /*----------------------------------------------------------------+
    |Check for character literals - they use the de-limiter quote    |
    +----------------------------------------------------------------*/
      IF ((l_temp_cell = '''') AND (NOT num_literal_on)) THEN
         IF (char_literal_on) THEN
            char_literal_on  := FALSE; --end point
         ELSE
            char_literal_on := TRUE; --start point
            not_bound_flag  := TRUE;
            l_build_where   := FALSE;
         END IF;
      END IF;

   /*------------------------------------------------------------------------------------+
    |Check for numeric literals, the check for alphabets A to Z is for database columns  |
    |having names such as col14 so it would not matter if the NLS lang was not english   |
    |as database columns are represented using alphabets A to Z.                         |
    +------------------------------------------------------------------------------------*/
      IF ((l_temp_cell IN ('1','2','3','4','5','6','7','8','9','0'))
              AND (UPPER(l_prev_cell) NOT IN ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','1','2','3','4','5','6','7','8','9','0')) AND (NOT num_literal_on) AND (NOT char_literal_on)) THEN

         num_literal_on  := TRUE; --start point
         not_bound_flag  := TRUE;
         l_build_where   := FALSE;
      END IF;

   /*-------------------------------------------------------------------------+
    |A numeric or character literal requires to be replaced by a bind variable|
    |the value requires to be stored so that it can be bound later.           |
    +-------------------------------------------------------------------------*/
      IF (((char_literal_on) OR (num_literal_on)) AND (not_bound_flag)) THEN
          l_bind_var            := '';
          l_bind_ctr            := l_bind_ctr + 1;
          l_tbl_ctr             := l_tbl_ctr  + 1;
          l_bind_var            := ' :l_var'||l_bind_ctr||' ';

          l_literal_tbl(l_tbl_ctr).stripped_value := '';

      /*---------------------------------------------------------------------------+
       |Its possible for a numeric value to be prefixed by a +, - or . so take care|
       |of that situation.                                                         |
       +---------------------------------------------------------------------------*/
          IF (num_literal_on) AND l_prev_cell IN (',','.','+','-')THEN

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Build_And_Bind: ' || 'l_prev_cell = ' || l_prev_cell);
             END IF; --set values for numeric token
             l_literal_tbl(l_tbl_ctr).stripped_value := l_literal_tbl(l_tbl_ctr).stripped_value || l_prev_cell;
          ELSE
            l_actual_where_clause := l_actual_where_clause || l_prev_cell; --Build the previous cell
          END IF;

      /*--------------------------------------------------------------------------------+
       |Concatenate the actual bind variable to the where clause to enable binding later|
       +---------------------------------------------------------------------------------*/
          IF (num_literal_on) THEN
             l_actual_where_clause := l_actual_where_clause ||'TO_NUMBER('||l_bind_var||')';
          ELSE
             l_actual_where_clause := l_actual_where_clause ||l_bind_var;
          END IF;

          l_literal_tbl(l_tbl_ctr).literal_counter := l_tbl_ctr;
          l_literal_tbl(l_tbl_ctr).bind_var_name   := l_bind_var ;
          not_bound_flag                           := FALSE;

   /*---------------------------------------------------------------------------+
    |Build the actual where clause, this is also built when the literal value is|
    |replaced with a bind variable.                                             |
    +---------------------------------------------------------------------------*/
      ELSIF (l_build_where) THEN

            l_actual_where_clause := l_actual_where_clause || l_prev_cell; --Build the previous cell

            l_build_where         := FALSE;

      END IF;

   /*------------------------------------------------------------------------------+
    | Save the actual values to be bound to variables later                        |
    +------------------------------------------------------------------------------*/
      IF (((char_literal_on) AND (l_temp_cell <> '''')) OR (num_literal_on)) THEN

          IF ((num_literal_on) AND (l_temp_cell IN (' ',';','(',')','=','!','<','>','*','^'))) THEN
             num_literal_on := FALSE;    --end point
             l_build_where  := TRUE ;    --set the flag so that the actual where clause can be built

          ELSE
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Build_And_Bind: ' || 'l_temp_cell = ' || l_temp_cell);
             END IF; --set values
             -- 3804333, determine if there was a ' replaced with ^, now set it back to '
             if emb_quote and l_temp_cell = '^' then
                emb_quote := FALSE;
                l_literal_tbl(l_tbl_ctr).stripped_value := l_literal_tbl(l_tbl_ctr).stripped_value || '''';
             else
                l_literal_tbl(l_tbl_ctr).stripped_value := l_literal_tbl(l_tbl_ctr).stripped_value || l_temp_cell;
             end if;

          END IF;

      ELSIF (l_temp_cell <> '''') THEN
            l_build_where := TRUE;    --set the flag so that the actual where clause can be built

      END IF; --end if character or numeric literal on

  END LOOP; --end loop length of character string

/*--------------------------------------------------------------------+
 |Build the final where clause concatenating the order by or group by |
 +--------------------------------------------------------------------*/
  IF (l_by_clause_pos > 0) THEN

     SELECT SUBSTR(l_in_where_clause, l_by_clause_pos)
     INTO l_balance_clause
     FROM dual;

     l_actual_where_clause := l_actual_where_clause || l_balance_clause;

  END IF; --end if by clause pos greater than 0

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Build_And_Bind: ' || 'l_actual_where_clause ' || l_actual_where_clause);
  END IF;

/*---------------------------------------------------------------------------+
 |In debug mode dump the contents of the table, which helps bind variables   |
 +---------------------------------------------------------------------------*/
  FOR l_ctr in 1..l_tbl_ctr LOOP

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Build_And_Bind: ' || 'l_literal_tbl('||l_ctr||').literal_counter = '|| l_literal_tbl(l_ctr).literal_counter);
         arp_standard.debug('Build_And_Bind: ' || 'l_literal_tbl('||l_ctr||').bind_var_name = '|| l_literal_tbl(l_ctr).bind_var_name);
         arp_standard.debug('Build_And_Bind: ' || 'l_literal_tbl('||l_ctr||').stripped_value = '|| l_literal_tbl(l_ctr).stripped_value);
      END IF;

  END LOOP; --end loop dump debug statements

  p_out_where_clause := l_actual_where_clause;

  p_literal_tbl      := l_literal_tbl;

  p_tbl_ctr          := l_tbl_ctr;

EXCEPTION
    WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug( 'ARP_ARXCOQIT.Build_And_Bind Exception: OTHERS EXCEPTION');
         END IF;
         RAISE;

END Build_And_Bind;

END ARP_ARXCOQIT;

/
