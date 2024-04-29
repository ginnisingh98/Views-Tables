--------------------------------------------------------
--  DDL for Package Body IGIRMINP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRMINP" AS
-- $Header: igirminb.pls 120.3.12000000.1 2007/09/13 04:01:21 mbremkum ship $

   -- from arp_arxcoqit start(1)

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

    PROCEDURE Build_And_Bind ( p_in_where_clause         IN  VARCHAR2         ,
                               p_out_where_clause        OUT NOCOPY VARCHAR2         ,
                               p_literal_tbl             OUT NOCOPY literal_tbl_type ,
                               p_tbl_ctr                 OUT NOCOPY BINARY_INTEGER     );

   -- from arp_arxcoqit end(1)

    CURSOR      c_ar_pay_sched ( cp_customer_trx_id in number, cp_status in varchar2) IS
      SELECT    arps.customer_trx_id, arps.payment_schedule_id,
                arps.terms_sequence_number
      FROM      ar_payment_schedules arps
      WHERE     arps.customer_Trx_id = cp_customer_trx_id
      AND       arps.status = cp_status
      order     by arps.due_date asc
      ;
    SUBTYPE     ARPSCHED   IS c_ar_pay_sched%ROWTYPE;
    TYPE        ARPSCHED_TAB is table of ARPSCHED
               INDEX BY BINARY_INTEGER;

 PROCEDURE Reschedule  ( p_customer_trx_id     in number)  IS
  l_arpsched  ARPSCHED_TAB;
  l_idx       BINARY_INTEGER;
  l_idx2      BINARY_INTEGER;
/*  FUNCTION IsCandidate ( fp_customer_trx_id in number )
  return boolean is
    CURSOR c_exists is select distinct  'x'
           from ar_payment_schedules ps1
           where exists ( select 'x'
               from ar_payment_schedules ps2
               where status = 'CL'
               and   ps2.customer_trx_id = fp_customer_trx_id
               )
           and  exists ( select 'x'
               from ar_payment_schedules ps3
               where status = 'OP'
               and   ps3.customer_trx_id = fp_customer_trx_id
            )
            order by ps1.customer_Trx_id
            ;
  begin
     FOR l_exists in C_exists  LOOP
            return TRUE;
     END LOOP;
     return FALSE;
  exception when others then
            return FALSE;
  end IsCandidate;*/
 BEGIN

   if not igi_gen.is_req_installed('INS') then
      return;
   end if;

   l_idx := 0;
   FOR l_sched in  c_ar_pay_sched  ( p_customer_trx_id , 'OP' ) LOOP
          l_idx := l_idx + 1;
          l_arpsched( l_idx ) := l_sched;
          l_arpsched( l_idx ).terms_sequence_number := l_idx;
   END LOOP;
   FOR l_sched in  c_ar_pay_sched  ( p_customer_trx_id , 'CL' ) LOOP
          l_idx := l_idx + 1;
          l_arpsched( l_idx ) := l_sched;
          l_arpsched( l_idx ).terms_sequence_number := l_idx;
   END LOOP;
   if l_idx = 0 THEN
      return;
   end if;
   l_idx2 := l_idx;
   WHILE l_idx2 >= 1 LOOP
       UPDATE   ar_payment_schedules
       SET      terms_sequence_number = l_arpsched( l_idx2 ).terms_sequence_number
       WHERE    customer_trx_id       = l_arpsched( l_idx2 ).customer_trx_id
       AND      payment_schedule_id   = l_arpsched( l_idx2 ).payment_schedule_id
       ;
       l_idx2 := l_idx2 - 1;
  END LOOP;
 EXCEPTION WHEN OTHERS THEN
                raise_application_error ( -20000, SQLERRM );
 END Reschedule;



/* This Procedure Calculates the entered total balance and the functional total
   balance for the passed in 'where clause ' */

--Bug 1563252 : Added the new argument p_from_clause
PROCEDURE fold_total( p_where_clause IN varchar2,
                      p_total        IN OUT NOCOPY number,
                      p_func_total   IN OUT NOCOPY number,
                      p_from_clause  IN varchar2 )
is
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

  arp_standard.debug('where clause:' || p_where_clause );

  arp_standard.debug('Opening Cursor');

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
  arp_standard.debug('Parsing statement ');
arp_standard.debug(l_out_where_clause);
--Bug 1563252 : modified the query string to add the from clause dynamically.
  dbms_sql.parse(l_select_cursor,
                 'select count( distinct invoice_currency_code ), sum(amount_due_remaining), sum(acctd_amount_due_remaining)  from '||p_from_clause||' '||l_out_where_clause,
     dbms_sql.v7);

/*-----------------------------------------------------------------------+
 |Define columns for the select statement.                               |
 +-----------------------------------------------------------------------*/
  arp_standard.debug('Defining Columns  +');

  dbms_sql.define_column(l_select_cursor, 1 , l_count);
  dbms_sql.define_column(l_select_cursor, 2 , l_amount);
  dbms_sql.define_column(l_select_cursor, 3 , l_func_amount);

  arp_standard.debug('Defining Columns  -');

/*-----------------------------------------------------------------------+
 |Bind the variables built by Build_And_Bind routine with actual values  |
 +-----------------------------------------------------------------------*/
  IF ((l_literal_tbl.EXISTS(l_tbl_ctr)) AND (p_where_clause IS NOT NULL))  THEN

     arp_standard.debug('Binding Variables +');

     FOR l_ctr in 1..l_tbl_ctr LOOP

       l_actual_bind_var := '';

      --Bind variables
       arp_standard.debug('l_literal_tbl('||l_ctr||').bind_var_name  = ' || l_literal_tbl(l_ctr).bind_var_name);
       arp_standard.debug('l_literal_tbl('||l_ctr||').stripped_value = ' || l_literal_tbl(l_ctr).stripped_value);

       l_actual_bind_var := rtrim(ltrim(l_literal_tbl(l_ctr).bind_var_name));

       arp_standard.debug('l_actual_bind_var = '||l_actual_bind_var);

       dbms_sql.bind_variable(l_select_cursor, l_actual_bind_var, l_literal_tbl(l_ctr).stripped_value);

     END LOOP;

  arp_standard.debug('Binding Variables -');

  END IF;

/*-----------------------------------------------------------------------+
 |Execute the SQL statement to calculate functional amount and accounted |
 |amount totals.                                                         |
 +-----------------------------------------------------------------------*/
  arp_standard.debug('Executing Statement +');

  l_ignore := dbms_sql.execute(l_select_cursor);

  arp_standard.debug('Executing Statement -');

  IF dbms_sql.fetch_rows(l_select_cursor) > 0 then

  /*-----------------------------------------------------------------------+
   |Fetch the column values, into actual variables                         |
   +-----------------------------------------------------------------------*/
     arp_standard.debug('Fetching column values +');

     dbms_sql.column_value(l_select_cursor, 1, l_count);
     dbms_sql.column_value(l_select_cursor, 2, l_amount);
     dbms_sql.column_value(l_select_cursor, 3, l_func_amount);

     arp_standard.debug('l_count '||l_count);
     arp_standard.debug('l_amount'||l_amount);
     arp_standard.debug('l_func_amount'||l_func_amount);

      IF l_count = 1 THEN
         p_total := l_amount;
      ELSE
         p_total := to_number(NULL);
      END IF;

      p_func_total := l_func_amount;

      arp_standard.debug('p_total '||p_total);
      arp_standard.debug('p_func_total'||p_func_total);
      arp_standard.debug('Fetching column values -');

  ELSE
         arp_standard.debug('no rows');
  END IF;

 /*-----------------------------------------------------------------------+
  |Finally close the cursor                                               |
  +-----------------------------------------------------------------------*/
   arp_standard.debug('Closing Cursor');
   dbms_sql.close_cursor(l_select_cursor);

   -- arp_standard.enable_debug;
EXCEPTION
   WHEN OTHERS THEN
        arp_standard.debug( 'Exception:' );
END;


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

l_temp_cell            VARCHAR2(1)           ;

l_prev_cell            VARCHAR2(1)           ;

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

  arp_standard.debug('l_in_where_clause ' || l_in_where_clause);

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

             arp_standard.debug('l_prev_cell = ' || l_prev_cell); --set values for numeric token
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

          IF ((num_literal_on) AND (l_temp_cell IN (' ',';','(',')','=','!','<','>','*'))) THEN
             num_literal_on := FALSE;    --end point
             l_build_where  := TRUE ;    --set the flag so that the actual where clause can be built

          ELSE
             arp_standard.debug('l_temp_cell = ' || l_temp_cell); --set values
             l_literal_tbl(l_tbl_ctr).stripped_value := l_literal_tbl(l_tbl_ctr).stripped_value || l_temp_cell;

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

  arp_standard.debug('l_actual_where_clause ' || l_actual_where_clause);

/*---------------------------------------------------------------------------+
 |In debug mode dump the contents of the table, which helps bind variables   |
 +---------------------------------------------------------------------------*/
  FOR l_ctr in 1..l_tbl_ctr LOOP

      arp_standard.debug('l_literal_tbl('||l_ctr||').literal_counter = '|| l_literal_tbl(l_ctr).literal_counter);
      arp_standard.debug('l_literal_tbl('||l_ctr||').bind_var_name = '|| l_literal_tbl(l_ctr).bind_var_name);
      arp_standard.debug('l_literal_tbl('||l_ctr||').stripped_value = '|| l_literal_tbl(l_ctr).stripped_value);

  END LOOP; --end loop dump debug statements

  p_out_where_clause := l_actual_where_clause;

  p_literal_tbl      := l_literal_tbl;

  p_tbl_ctr          := l_tbl_ctr;

EXCEPTION
    WHEN OTHERS THEN
         arp_standard.debug( 'ARP_ARXCOQIT.Build_And_Bind Exception: OTHERS EXCEPTION');
         RAISE;

END Build_And_Bind;


END;

/
