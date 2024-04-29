--------------------------------------------------------
--  DDL for Package Body PQH_REFRESH_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_REFRESH_DATA" AS
/* $Header: pqrefdat.pkb 120.0 2005/05/29 02:26:24 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_refresh_data.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |                   Private Variables and functions for string parsing
-- ----------------------------------------------------------------------------
--

    /* Package variables used repeatedly throughout the body. */
    len_string	NUMBER;
    start_loc	NUMBER;
    next_loc	NUMBER;
    a_blank CONSTANT VARCHAR2(3) := '';

    /*--------------------- Private Modules ---------------------------
    || The following functions are available only to other modules in
    || package.
    ------------------------------------------------------------------*/

    /*------------------------------------- ---------------------------
    || Function  :  a_delimiter
    ||
    ------------------------------------------------------------------*/


    FUNCTION a_delimiter
        (character_in IN VARCHAR2,
         delimiters_in IN VARCHAR2 := std_delimiters)
    RETURN BOOLEAN
    /*
    || Returns TRUE if the character passsed into the function is found
    || in the list of delimiters.
    */
    IS
    BEGIN
        RETURN INSTR (delimiters_in, character_in) > 0;
    END;


    /*------------------------------------- ---------------------------
    || Function  :  string_length
    ||
    ------------------------------------------------------------------*/


     FUNCTION string_length (string_in IN VARCHAR2)
        RETURN INTEGER
    IS
    BEGIN
        RETURN LENGTH (LTRIM (RTRIM (string_in)));
    END;

    /*------------------------------------- ---------------------------
    || Function  :  get_legislation_code
    ||
    ------------------------------------------------------------------*/


    FUNCTION get_legislation_code (p_business_group_id IN number)
        RETURN VARCHAR2
    IS
     l_leg_code varchar2(30);
     cursor c1 is
     select legislation_code
     from per_business_groups
     where business_group_id = p_business_group_id;
    BEGIN
        open c1;
        fetch c1 into l_leg_code;
        close c1;
        return l_leg_code;
    END;

    /*------------------------------------- ---------------------------
    || Function  :  next_atom_loc
    ||
    ------------------------------------------------------------------*/


     FUNCTION next_atom_loc
        (string_in IN VARCHAR2,
         start_loc_in IN NUMBER,
         scan_increment_in IN NUMBER := +1)
    /*
    || The next_atom_loc function returns the location
    || in the string of the starting point of the next atomic (from the
    || start location). The function scans forward if scan_increment_in is
    || +1, otherwise it scans backwards through the string. Here is the
    || logic to determine when the next atomic starts:
    ||
    ||		1. If current atomic is a delimiter (if, that is, the character
    ||			at the start_loc_in of the string is a delimiter), then the
    ||			the next character starts the next atomic since all
    ||			delimiters are a single character in length.
    ||
    ||		2. If current atomic is a word (if, that is, the character
    ||			at the start_loc_in of the string is a delimiter), then the
    ||			next atomic starts at the next delimiter. Any letters or
    ||			numbers in between are part of the current atomic.
    ||
    || So I loop through the string a character at a time and apply these
    || tests. I also have to check for end of string. If I scan forward
    || the end of string comes when the SUBSTR which pulls out the next
    || character returns NULL. If I scan backward, then the end of the
    || string comes when the location is less than 0.
    */
    RETURN NUMBER
    IS
        /* Boolean variable which uses private function to determine
        || if the current character is a delimiter or not.
        */
        was_a_delimiter BOOLEAN :=
            a_delimiter (SUBSTR (string_in, start_loc_in, 1));

        /* If not a delimiter, then it was a word. */
        was_a_word BOOLEAN := NOT was_a_delimiter;

        /* The next character scanned in the string */
 		next_char VARCHAR2(1);
        /*
        || The value returned by the function. This location is the start
        || of the next atomic found. Initialize it to next character,
        || forward or backward depending on increment.
        */
        return_value NUMBER := start_loc_in + scan_increment_in;
    BEGIN
        LOOP
            -- Extract the next character.
            next_char := SUBSTR (string_in, return_value, 1);

            -- Exit the loop if:
            EXIT WHEN
                /* On a delimiter, since that is always an atomic */
                a_delimiter (next_char)
                         OR
                /* Was a delimiter, but am now in a word. */
                (was_a_delimiter AND NOT a_delimiter (next_char))
                         OR
                /* Reached end of string scanning forward. */
                next_char IS NULL
                         OR
                /* Reached beginning of string scanning backward. */
                return_value < 0;

            /* Shift return_value to move the next character. */
            return_value := return_value + scan_increment_in;
        END LOOP;

        -- If the return_value is negative, return 0, else the return_value
        RETURN GREATEST (return_value, 0);
    END;


    /*----------------------------------------------------------------
    || PROCEDURE : increment_counter
    ||
    ------------------------------------------------------------------*/


    PROCEDURE increment_counter
        (counter_inout IN OUT NOCOPY NUMBER,
         count_type_in IN VARCHAR2,
         atomic_in IN CHAR)
    /*
    || The increment_counter procedure is used by nth_atomic and
    || number_of_atomics to add to the count of of atomics. Since you
    || can request a count by ALL atomics, just the WORD atomics or
    || just the DELIMITER atomics. I use the a_delimiter function to
    || decide whether I should add to the counter. This is not a terribly
    || complex procedure. I bury this logic into a separate module,
    || however, to make it easier to read and debug the main body of
    || the programs.
    */
    IS
    l_counter_inout number := counter_inout;
    BEGIN
        IF count_type_in = 'ALL' OR
            (count_type_in = 'WORD' AND NOT a_delimiter (atomic_in)) OR
            (count_type_in = 'DELIMITER' AND a_delimiter (atomic_in))
        THEN
            counter_inout := counter_inout + 1;
        END IF;
exception when others then
counter_inout := l_counter_inout;
raise;
    END increment_counter;



--
--         End of string parsing private functions
--


    /*----------------------------------------------------------------
    ||
    ||                   PROCEDURE : refresh_data
    ||  This is the MAIN procedure which calls the others
    ------------------------------------------------------------------*/



PROCEDURE refresh_data
     ( p_txn_category_id        IN pqh_transaction_categories.transaction_category_id%TYPE,
       p_txn_id                 IN number,
       p_refresh_criteria       IN varchar2,
       p_items_changed          OUT NOCOPY varchar2
      )
    IS
      -- local variables
      --
     l_proc                  varchar2(72) := g_package||'refresh_data';
     l_txn_id                number;
     l_txn_tab_id            pqh_table_route.table_route_id%TYPE;
     l_shd_tab_id            pqh_table_route.table_route_id%TYPE;
     l_mas_tab_id            pqh_table_route.table_route_id%TYPE;
     l_column_name           pqh_attributes.column_name%TYPE;
     l_attribute_name        pqh_attributes.attribute_name%TYPE;
     l_column_prompt         varchar2(100);
     l_refresh_flag          pqh_txn_category_attributes.refresh_flag%TYPE;
     l_column_type           pqh_attributes.column_type%TYPE;
     l_from_clause_txn       pqh_table_route.from_clause%TYPE;
     l_where_clause_txn      pqh_table_route.where_clause%TYPE;
     l_rep_where_clause_txn  pqh_table_route.where_clause%TYPE;
     l_from_clause_shd       pqh_table_route.from_clause%TYPE;
     l_where_clause_shd      pqh_table_route.where_clause%TYPE;
     l_rep_where_clause_shd  pqh_table_route.where_clause%TYPE;
     l_from_clause_main      pqh_table_route.from_clause%TYPE;
     l_where_clause_main     pqh_table_route.where_clause%TYPE;
     l_rep_where_clause_main pqh_table_route.where_clause%TYPE;
     l_select_stmt           t_where_clause_typ;
     l_tot_txn_columns       NUMBER;
     l_tot_txn_rows          NUMBER;
     l_all_txn_rows_array    DBMS_SQL.VARCHAR2_TABLE;
     l_txn_row_cnt           NUMBER := 0;
     l_ordered_txn_row       DBMS_SQL.VARCHAR2_TABLE;
     l_tot_shd_columns       NUMBER;
     l_tot_shd_rows          NUMBER;
     l_all_shd_rows_array    DBMS_SQL.VARCHAR2_TABLE;
     l_tot_main_columns      NUMBER;
     l_tot_main_rows         NUMBER;
     l_all_main_rows_array   DBMS_SQL.VARCHAR2_TABLE;
     l_legislation_code      varchar2(30)
            := get_legislation_code(fnd_profile.value('PER_BUSINESS_GROUP_ID'));
     type t_string is table of pqh_attributes_tl.attribute_name%type
                                  index by binary_integer;
     l_change_items     t_string;
     l_chg_items_index  integer := 0;
     l_found  boolean := false;
     --
     -- BINARY_INTEGER
     i   BINARY_INTEGER:= 1;  -- for column_name and refresh_flag cursor


     -- This cursor will get the list of all tables to be refreshed
     CURSOR c1_table_lists IS
      SELECT DISTINCT tca.transaction_table_route_id,
                      tr.shadow_table_route_id,
                      att.master_table_route_id
      FROM  pqh_attributes att,   pqh_table_route tr,
		pqh_txn_category_attributes tca
      WHERE  tca.transaction_table_route_id  = tr.table_route_id
	AND  att.attribute_id = tca.attribute_id
        AND  tca.transaction_category_id = p_txn_category_id
        AND  tr.shadow_table_route_id IS NOT NULL
        AND  tr.table_alias  = DECODE(p_refresh_criteria, 'A', tr.table_alias,
                                                              p_refresh_criteria);

    -- This cursor will get the list of all column_names for the current txn
    -- and master tables
    CURSOR c2_column_names ( p_txn_tab_id IN pqh_table_route.table_route_id%TYPE,
                             p_mas_tab_id IN pqh_table_route.table_route_id%TYPE) IS
      SELECT att.refresh_col_name, nvl(tca.refresh_flag,'N') ,
	     att.column_type,
	     nvl(at2.attribute_name, att.attribute_name) attribute_name
      FROM   pqh_attributes_vl att, pqh_txn_category_attributes tca,
             pqh_attributes_vl at2
      WHERE   att.attribute_id = tca.attribute_id
        AND  att.column_name = at2.column_name(+)
	AND  att.master_table_route_id = at2.master_table_route_id(+)
	AND  at2.legislation_code(+) = l_legislation_code
        AND  tca.transaction_category_id     = p_txn_category_id
        AND  tca.transaction_table_route_id  = p_txn_tab_id
        AND  att.master_table_route_id       = p_mas_tab_id
       ORDER BY tca.refresh_flag DESC, att.attribute_name;

     -- This cursor will get the FROM and WHERE columns from pqh_table_route
     CURSOR c3_from_where ( p_tab_id  IN pqh_table_route.table_route_id%TYPE ) IS
        SELECT tr.from_clause, tr.where_clause
        FROM pqh_table_route tr
        WHERE tr.table_route_id = p_tab_id ;

BEGIN

--   hr_utility.trace_on;
  hr_utility.set_location('Entering: '||l_proc, 5);

  -- populate the local variable l_txn_id and global g_txn_category_id with IN param value
  -- These variables are passed to some procedures

   l_txn_id := p_txn_id;
   g_txn_category_id  := p_txn_category_id;

  hr_utility.set_location('Transaction Id: '||l_txn_id, 6);
  hr_utility.set_location('Transaction Category Id: '||g_txn_category_id, 7);
  hr_utility.set_location('Refresh Criteria: '||p_refresh_criteria, 8);


  OPEN c1_table_lists;
  LOOP
  -- This is the MAIN LOOP which has table lists to be Refreshed
  hr_utility.set_location('Inside MAIN LOOP of table list c1_table_lists', 9);

  -- Initialize all the variables for each table set
     i                       := 1;  -- for column_name, type and refresh_flag cursor
     l_select_stmt           := '';
     l_tot_txn_columns       := 0;
     l_tot_txn_rows          := 0;
     l_txn_row_cnt           := 0;
     l_tot_shd_columns       := 0;
     l_tot_shd_rows          := 0;
     l_tot_main_columns      := 0;
     l_tot_main_rows         := 0;

   -- initialize all the PL/SQL tables
     l_all_txn_rows_array.DELETE;
     l_ordered_txn_row.DELETE;
     l_all_shd_rows_array.DELETE;
     l_all_main_rows_array.DELETE;
     g_refresh_tab.DELETE;
     g_refresh_tab_all.DELETE;

     FETCH c1_table_lists INTO l_txn_tab_id, l_shd_tab_id, l_mas_tab_id ;
     EXIT WHEN c1_table_lists%NOTFOUND;

     hr_utility.set_location('Txn Tab Id:'||l_txn_tab_id, 10);
     hr_utility.set_location('Shd Tab Id:'||l_shd_tab_id, 11);
     hr_utility.set_location('Main Tab Id:'||l_mas_tab_id, 12);

      -- open the column_name cursor and populate the arrys columns 1 , 2  and 3
      OPEN c2_column_names ( l_txn_tab_id , l_mas_tab_id );
      LOOP
        -- This loop will fetch all the column_name and refresh_flag into array

       FETCH  c2_column_names  INTO l_column_name , l_refresh_flag , l_column_type, l_attribute_name;
       EXIT WHEN c2_column_names%NOTFOUND;

        hr_utility.set_location('Col Name'||l_column_name, 13);
        hr_utility.set_location('Refresh Flag'||l_refresh_flag, 14);
        hr_utility.set_location('Col Type'||l_column_type, 15);
        hr_utility.set_location('Attr Name'||l_attribute_name, 15);

       -- populate the arrys col1 , col2 and col3
       g_refresh_tab(i).column_name   := l_column_name;
       g_refresh_tab(i).refresh_flag  := l_refresh_flag;
       g_refresh_tab(i).column_type   := l_column_type;
       g_refresh_tab(i).attribute_name   := l_attribute_name;
       i := i + 1;
      END LOOP; -- for column_name , type and refresh flags
      CLOSE c2_column_names;


  -- array g_refresh_tab has all the column_names of txn table in col1
  --
  -- TRANSACTION TABLE
  --
  -- Build a dynamic select statement for the TRANSACTION TABLE

   build_dynamic_select
  ( p_flag          => 'A',
    p_select_stmt   =>  l_select_stmt,
    p_tot_columns   =>  l_tot_txn_columns );


  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,1,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,51,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,101,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,151,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,201,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,251,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,301,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,351,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,401,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,451,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,501,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,551,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,601,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,651,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,701,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,751,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,801,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,851,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,901,50), 16);
  hr_utility.set_location('Txn Sel : '||substr(l_select_stmt,951,50), 16);
  hr_utility.set_location('Txn Total Columns : '||l_tot_txn_columns, 17);


  -- get the FROM and WHERE clause from pqh_table_route for TRANSACTION TABLE

      OPEN c3_from_where ( l_txn_tab_id  ) ;
      LOOP
        -- this gets the from and where clause , one row only
        FETCH c3_from_where INTO l_from_clause_txn, l_where_clause_txn;
        EXIT WHEN c3_from_where%NOTFOUND;
       END LOOP;
      CLOSE c3_from_where ;

  hr_utility.set_location('Txn From  : '||l_from_clause_txn, 18);
  hr_utility.set_location('Txn Where : '||l_where_clause_txn, 19);

 --  replace the WHERE clause txn_id parameter with the actual value
 --  for TRANSACTION TABLE
 replace_where_params
 ( p_where_clause_in   =>  l_where_clause_txn,
   p_txn_tab_flag      =>  'Y',
   p_txn_id            =>  l_txn_id,
   p_where_clause_out  =>  l_rep_where_clause_txn );

  hr_utility.set_location('Txn Replaced Where : '||l_rep_where_clause_txn, 20);


 -- get ALL ROWS for the TRANSACTION TABLE
 get_all_rows
(p_select_stmt      => l_select_stmt,
 p_from_clause      => l_from_clause_txn,
 p_where_clause     => l_rep_where_clause_txn,
 p_total_columns    => l_tot_txn_columns,
 p_total_rows       => l_tot_txn_rows,
 p_all_txn_rows     => l_all_txn_rows_array );

 /*
  we now have all the txn rows in the l_all_txn_rows_array
  the array is populated in the following way
  eg:  TXN table has  3 rows and 3 columns then array has following value
  r1.c1, r2.c1, r3.c1, r2.c1, r2.c2, r2.c3, r3.c1, r3.c2, r3.c3
  We will get each row for this random array and process the shadow and main
  tables

  THIS IS THE LOOP FOR EACH ROW IN TRANSACTION TABLE

 */

 -- LOOP FOR EACH ROW IN TRANSACTION TABLE
 FOR row_no in 1..NVL(l_tot_txn_rows,-1)
 LOOP
  l_txn_row_cnt := row_no;
  -- since the array is random, we build a ordered row
  FOR col_no in 1..l_tot_txn_columns
  LOOP
    l_ordered_txn_row(col_no) := NVL(l_all_txn_rows_array(l_txn_row_cnt),'');
    l_txn_row_cnt := l_txn_row_cnt + l_tot_txn_rows;
   END LOOP; -- for all txn columns

  -- the above loop gives ordered value for each txn row in the l_ordered_txn_row
  -- array
  -- populate the g_refresh_tab.txn_val column with these values
   FOR k in NVL(l_ordered_txn_row.FIRST,0)..NVL(l_ordered_txn_row.LAST,-1)
   LOOP
      g_refresh_tab(k).txn_val   := l_ordered_txn_row(k);
     -- dbms_output.put_line('Record : '||row_no||' Values i '||i||' '||a(i) );
   END LOOP;

  -- g_refresh_tab array now has values of txn record in the txn_val column


  /*
            SHADOW TABLE
  */


    -- Build a dynamic select statement for the SHADOW TABLE

   build_dynamic_select
  ( p_flag          => 'R',
    p_select_stmt   =>  l_select_stmt,
    p_tot_columns   =>  l_tot_shd_columns );


  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,1,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,51,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,101,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,151,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,201,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,251,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,301,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,351,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,401,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,451,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,501,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,551,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,601,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,651,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,701,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,751,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,801,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,851,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,901,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,951,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,1001,50), 16);
  hr_utility.set_location('Shd Sel : '||substr(l_select_stmt,1051,50), 16);

  -- get the FROM and WHERE clause from pqh_table_route for SHADOW TABLE

      OPEN c3_from_where ( l_shd_tab_id  ) ;
      LOOP
        -- this gets the from and where clause , one row only
        FETCH c3_from_where INTO l_from_clause_shd, l_where_clause_shd;
        EXIT WHEN c3_from_where%NOTFOUND;
      END LOOP;
      CLOSE c3_from_where ;

  hr_utility.set_location('Shd From  : '||l_from_clause_shd, 18);
  hr_utility.set_location('Shd Where : '||l_where_clause_shd, 19);

 --  replace the WHERE clause parameters with the actual value
 --  for SHADOW TABLE
 replace_where_params
 ( p_where_clause_in   =>  l_where_clause_shd,
   p_txn_tab_flag      =>  'N',
   p_txn_id            =>  l_txn_id,
   p_where_clause_out  =>  l_rep_where_clause_shd );

  hr_utility.set_location('Shd Replaced Where : '||l_rep_where_clause_shd, 20);

 -- get ALL ROWS for the SHADOW TABLE
 -- THERE WILL BE ONLY ONW ROW RETURNED for shadow and main tables as
 -- the where clause has primary key columns

 get_all_rows
(p_select_stmt      => l_select_stmt,
 p_from_clause      => l_from_clause_shd,
 p_where_clause     => l_rep_where_clause_shd,
 p_total_columns    => l_tot_shd_columns,
 p_total_rows       => l_tot_shd_rows,
 p_all_txn_rows     => l_all_shd_rows_array );

 -- the l_all_shd_rows_array has ONLY ONE ROW
 -- populate the g_refresh_tab.shadow_val column with these values
   FOR k in NVL(l_all_shd_rows_array.FIRST,0)..NVL(l_all_shd_rows_array.LAST,-1)
   LOOP
      g_refresh_tab(k).shadow_val   := l_all_shd_rows_array(k);
     -- dbms_output.put_line('Record : '||row_no||' Values i '||i||' '||a(i) );
   END LOOP;

  -- g_refresh_tab array now has values of txn record in the shadow_val column



  /*
            MAIN TABLE
  */


    -- Build a dynamic select statement for the MAIN TABLE

   build_dynamic_select
  ( p_flag          => 'R',
    p_select_stmt   =>  l_select_stmt,
    p_tot_columns   =>  l_tot_main_columns );



  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,1,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,51,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,101,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,151,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,201,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,251,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,301,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,351,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,401,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,451,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,501,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,551,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,601,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,651,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,701,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,751,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,801,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,851,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,901,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,951,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,1001,50), 16);
  hr_utility.set_location('Main Sel : '||substr(l_select_stmt,1051,50), 16);

  -- get the FROM and WHERE clause from pqh_table_route for MAIN TABLE

      OPEN c3_from_where ( l_mas_tab_id  ) ;
      LOOP
        -- this gets the from and where clause , one row only
        FETCH c3_from_where INTO l_from_clause_main, l_where_clause_main;
        EXIT WHEN c3_from_where%NOTFOUND;
      END LOOP;
      CLOSE c3_from_where ;

  hr_utility.set_location('Main From  : '||l_from_clause_main, 18);
  hr_utility.set_location('Main Where : '||substr(l_where_clause_main,1,50), 19);
  hr_utility.set_location('Main Where : '||substr(l_where_clause_main,51,50), 19);
  hr_utility.set_location('Main Where : '||substr(l_where_clause_main,101,50), 19);
  hr_utility.set_location('Main Where : '||substr(l_where_clause_main,151,50), 19);
  hr_utility.set_location('Main Where : '||substr(l_where_clause_main,201,50), 19);
  hr_utility.set_location('Main Where : '||substr(l_where_clause_main,251,50), 19);

 --  replace the WHERE clause parameters with the actual value
 --  for MAIN TABLE
 replace_where_params
 ( p_where_clause_in   =>  l_where_clause_main,
   p_txn_tab_flag      =>  'N',
   p_txn_id            =>  l_txn_id,
   p_where_clause_out  =>  l_rep_where_clause_main );


   hr_utility.set_location('Man Rep where : '||substr(l_rep_where_clause_main,1,50),30);


 -- get ALL ROWS for the MAIN TABLE
 -- THERE WILL BE ONLY ONW ROW RETURNED for shadow and main tables as
 -- the where clause has primary key columns

 get_all_rows
(p_select_stmt      => l_select_stmt,
 p_from_clause      => l_from_clause_main,
 p_where_clause     => l_rep_where_clause_main,
 p_total_columns    => l_tot_main_columns,
 p_total_rows       => l_tot_main_rows,
 p_all_txn_rows     => l_all_main_rows_array );

 -- the l_all_main_rows_array has ONLY ONE ROW
 -- populate the g_refresh_tab.main_val column with these values
   FOR k in NVL(l_all_main_rows_array.FIRST,0)..NVL(l_all_main_rows_array.LAST,-1)
   LOOP
      g_refresh_tab(k).main_val   := l_all_main_rows_array(k);
     -- dbms_output.put_line('Record : '||row_no||' Values i '||i||' '||a(i) );
   END LOOP;

  -- g_refresh_tab array now has values of txn record in the main_val column


 /*
     Call the compute_updt_flag procedure which will loop thru the g_refresh_tab
     and populate the updt_flag.

 */
       compute_updt_flag;

 /*
     LOOP thru the g_refresh_tab and update the necessary columns with new values
 */

     FOR k IN NVL(g_refresh_tab.FIRST,0)..NVL(g_refresh_tab.LAST,-1)
     LOOP
        IF g_refresh_tab(k).updt_flag = 'Y' THEN
          -- call the update_table procedure to updt tables
           update_tables
           (p_column_name           => g_refresh_tab(k).column_name,
            p_column_type           => g_refresh_tab(k).column_type,
            p_column_val            => g_refresh_tab(k).main_val,
            p_from_clause_txn       => l_from_clause_txn,
            p_from_clause_shd       => l_from_clause_shd,
            p_rep_where_clause_shd  => l_rep_where_clause_shd);
           --
           l_column_prompt := g_refresh_tab(k).attribute_name;
           l_found := false;
           for i in 1 .. l_chg_items_index  loop
             if l_change_items(i) = l_column_prompt then
                l_found := true;
             end if;
             exit when l_found;
           end loop;
           if not l_found then
             l_chg_items_index := l_chg_items_index +1;
             l_change_items(l_chg_items_index) := l_column_prompt;
             if p_items_changed is null then
               p_items_changed := l_column_prompt;
             else
               p_items_changed :=
                  p_items_changed || fnd_global.local_chr(10) || l_column_prompt;
             end if;
           end if;
	   --
        END IF;
     END LOOP; -- thru the table

 END LOOP; -- For ALL ROWS in TRANSACTION TABLE

  /*
    for forms purpose we will take a backup of g_refresh_tab into g_refresh_bak
    g_refresh_bak will be used by form
  */

      FOR m IN NVL(g_refresh_tab.FIRST,0)..NVL(g_refresh_tab.LAST,-1)
      LOOP
             g_refresh_bak(m).column_name   := g_refresh_tab(m).column_name;
             g_refresh_bak(m).column_type   := g_refresh_tab(m).column_type;
             g_refresh_bak(m).refresh_flag  := g_refresh_tab(m).refresh_flag;
             g_refresh_bak(m).txn_val       := g_refresh_tab(m).txn_val;
             g_refresh_bak(m).shadow_val    := g_refresh_tab(m).shadow_val;
             g_refresh_bak(m).main_val      := g_refresh_tab(m).main_val;
             g_refresh_bak(m).updt_flag     := g_refresh_tab(m).updt_flag;

      END LOOP; -- for copy to backup

  END LOOP; -- main loop of tables to be refreshed
  CLOSE c1_table_lists;

  -- commit the work;
  --  commit;
  hr_utility.set_location('Leaving:'||l_proc, 1000);
--  hr_utility.trace_off;


EXCEPTION
      WHEN OTHERS THEN
      p_items_changed := null;
--        hr_utility.trace_off;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END  refresh_data;


    /*----------------------------------------------------------------
    || PROCEDURE : build_dynamic_select
    ||
    ------------------------------------------------------------------*/

PROCEDURE build_dynamic_select
  ( p_flag           IN  VARCHAR2,
    p_select_stmt    OUT NOCOPY t_where_clause_typ,
    p_tot_columns    OUT NOCOPY NUMBER )  IS

/*
   p_flag has 2 values
   'A' means select all columns from the array , this is for txn table select
   'R' means select ONLY those columns where refresh_flag i.e column 2 in array
       is 'Y' , this is for shadow and master table select
    Depending on the column_type we will format the front and back packing string
*/

--
-- local variables
--
 l_proc          varchar2(72) := g_package||'build_dynamic_select';
 l_front         VARCHAR2(100);
 l_back          VARCHAR2(100);



BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- intitalize the out variable
   p_select_stmt := 'SELECT ';
   p_tot_columns := 0;

  -- loop thru the array and keep appending column 1 into string g_refresh_tab(i).column_name
   FOR i IN NVL(g_refresh_tab.FIRST,0)..NVL(g_refresh_tab.LAST,-1)
   LOOP
     -- form the front and back packing string
       IF    g_refresh_tab(i).column_type = 'D' THEN
          l_front := 'TO_CHAR(';
          l_back  := ',''RRRRMMDD HH24MISS'')';
       ELSIF g_refresh_tab(i).column_type = 'N' THEN
          l_front  := 'TO_CHAR(';
          l_back   := ')';
       ELSE
          l_front :=  ' ';
          l_back  :=  ' ';
       END IF;

       IF p_flag = 'A' THEN
         -- append all columns
           p_select_stmt := p_select_stmt||
                            l_front||g_refresh_tab(i).column_name||l_back||' ';
         -- increment the total no of columns
           p_tot_columns := p_tot_columns + 1;
           -- if this is not the last column_name append a comma at end
           --  IF i <> g_refresh_tab.LAST THEN
               p_select_stmt := p_select_stmt||' ,';
           --  END IF;
       ELSE
          -- append only if refresh flag is 'Y'
            IF g_refresh_tab(i).refresh_flag = 'Y' THEN
               p_select_stmt := p_select_stmt||
                                l_front||g_refresh_tab(i).column_name||l_back||' ';
               -- increment the total no of columns
                p_tot_columns := p_tot_columns + 1;
                -- if this is not the last column_name append a comma at end
                -- IF i <> g_refresh_tab.LAST THEN
                   p_select_stmt := p_select_stmt||' ,';
                -- END IF;  -- for last row check
            END IF;  -- for refresh_flag is Y
       END IF; -- for p_flag
   END LOOP;

  -- remove the last comma
  p_select_stmt := rtrim(p_select_stmt,',');

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
    p_select_stmt    := null;
    p_tot_columns    := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END build_dynamic_select;

    /*----------------------------------------------------------------
    || FUNCTION : ret_value_from_glb_table
    ||
    ------------------------------------------------------------------*/
FUNCTION ret_value_from_glb_table(p_index in number)
RETURN VARCHAR2 IS
--
 l_proc          varchar2(72) := g_package||'ret_value_from_glb_table';
BEGIN
--
 hr_utility.set_location('Entering:'||l_proc, 5);
--
 return pqh_refresh_data.g_refresh_tab_all(p_index).txn_val;
--
 hr_utility.set_location('Entering:'||l_proc, 5);
--
exception when others then
 return null;
--
END;
--
    /*----------------------------------------------------------------
    || FUNCTION : get_value_from_array
    ||
    ------------------------------------------------------------------*/
--
FUNCTION get_value_from_array ( p_column_name  IN  pqh_attributes.column_name%TYPE )
  RETURN VARCHAR2 IS

-- local variables
--
 l_proc          varchar2(72) := g_package||'get_value_from_array';
 l_col_val       VARCHAR2(8000);
 l_col_type      VARCHAR2(1);
 l_front         VARCHAR2(100);
 l_back          VARCHAR2(100);


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  hr_utility.set_location('Col Name : '||p_column_name, 6);

  IF NVL(g_refresh_tab_all.COUNT,0) <> 0 THEN
    -- loop thru the array and get the value in column 3 corresponding to col name
     FOR i IN NVL(g_refresh_tab_all.FIRST,0)..NVL(g_refresh_tab_all.LAST,-1)
     LOOP
        hr_utility.set_location('Searching g_refresh_tab_all:'|| UPPER(g_refresh_tab_all(i).column_name)||','|| UPPER(p_column_name),7);
        IF UPPER(g_refresh_tab_all(i).column_name) = UPPER(p_column_name)  THEN
           hr_utility.set_location('Found match in g_refresh_tab_all',8);
           l_col_val := 'pqh_refresh_data.ret_value_from_glb_table('
                      || to_char(i)
                      || ')';
           l_col_type := g_refresh_tab_all(i).column_type;
           EXIT; -- exit the loop as the column is found
        END IF;
     END LOOP;
  END IF;

     -- form the front and back packing string
       IF    l_col_type = 'D' THEN
          l_front := 'TO_DATE(';
          l_back  := ',''RRRRMMDD HH24MISS'')';
       ELSIF l_col_type = 'V' THEN
          l_front  := ' ';
          l_back   := ' ';
       ELSE
          l_front :=  ' ';
          l_back  :=  ' ';
       END IF;
  /**
  IF NVL(g_refresh_tab.COUNT,0) <> 0 THEN
    -- loop thru the array and get the value in column 3 corresponding to col name
     FOR i IN NVL(g_refresh_tab.FIRST,0)..NVL(g_refresh_tab.LAST,-1)
     LOOP
        IF UPPER(g_refresh_tab(i).column_name) = UPPER(p_column_name)  THEN
           l_col_val := g_refresh_tab(i).txn_val;
           l_col_type := g_refresh_tab(i).column_type;
           EXIT; -- exit the loop as the column is found
        END IF;
     END LOOP;
  END IF;


     -- form the front and back packing string
       IF    l_col_type = 'D' THEN
          l_front := 'TO_DATE(''';
          l_back  := ''',''RRRRMMDD HH24MISS'')';
       ELSIF l_col_type = 'V' THEN
          l_front  := '''';
          l_back   := '''';
       ELSE
          l_front :=  ' ';
          l_back  :=  ' ';
       END IF;
**/

  l_col_val := l_front||l_col_val||l_back;

  hr_utility.set_location('Col Val : '||l_col_val, 10);
  hr_utility.set_location('Leaving:'||l_proc, 1000);

  return l_col_val;


END get_value_from_array;

    /*----------------------------------------------------------------
    || FUNCTION : get_value_from_array_purge
    ||
    ------------------------------------------------------------------*/
FUNCTION get_value_from_array_purge ( p_column_name  IN  pqh_attributes.column_name%TYPE )
  RETURN VARCHAR2 IS

-- local variables
--
 l_proc          varchar2(72) := g_package||'get_value_from_array_purge';
 l_col_val       VARCHAR2(8000);
 l_col_type      VARCHAR2(1);
 l_front         VARCHAR2(100);
 l_back          VARCHAR2(100);


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  hr_utility.set_location('Col Name : '||p_column_name, 6);

  IF NVL(g_refresh_tab.COUNT,0) <> 0 THEN
    -- loop thru the array and get the value in column 3 corresponding to col name
     FOR i IN NVL(g_refresh_tab.FIRST,0)..NVL(g_refresh_tab.LAST,-1)
     LOOP
        IF UPPER(g_refresh_tab(i).column_name) = UPPER(p_column_name)  THEN
           l_col_val := g_refresh_tab(i).txn_val;
           l_col_type := g_refresh_tab(i).column_type;
           EXIT; -- exit the loop as the column is found
        END IF;
     END LOOP;
  END IF;


     -- form the front and back packing string
       IF    l_col_type = 'D' THEN
          l_front := 'TO_DATE(''';
          l_back  := ''',''YYYYMMDD HH24MISS'')';
       ELSIF l_col_type = 'V' THEN
          l_front  := '''';
          l_back   := '''';
       ELSE
          l_front :=  ' ';
          l_back  :=  ' ';
       END IF;

  l_col_val := l_front||l_col_val||l_back;

  hr_utility.set_location('Col Val : '||l_col_val, 10);
  hr_utility.set_location('Leaving:'||l_proc, 1000);

  return l_col_val;


END get_value_from_array_purge;

    /*----------------------------------------------------------------
    || PROCEDURE : replace_where_params
    ||
    ------------------------------------------------------------------*/

PROCEDURE replace_where_params
 ( p_where_clause_in  IN     pqh_table_route.where_clause%TYPE,
   p_txn_tab_flag     IN     VARCHAR2,
   p_txn_id           IN     number,
   p_where_clause_out OUT NOCOPY    pqh_table_route.where_clause%TYPE ) IS

/*
  This procedure will replace all the parameters in the where_clause with their actual values.
  p_txn_tab_flag will be 'Y' for the txn table. In the case of txn table we replace the txn_id
  value with the IN param value to the program. In the case of shadow and main table, we get
  param values from g_refresh_dtata array
*/

--
-- local variables
--
 l_proc          varchar2(72) := g_package||'replace_where_params';
 l_atoms_tab     atoms_tabtype;  -- to hold the where_clause atoms
 l_no_atoms      number;
 l_key_column    pqh_attributes.column_name%TYPE;
 l_key_val       VARCHAR2(8000);
 l_where_out     pqh_table_route.where_clause%TYPE;
 l_key_col_null  VARCHAR2(8000);
--
  l_found boolean    := false;
  l_next  number(10) := 0;
  i       number(10) := 0;
  j       number(10) := 0;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- parse the where_clause and populate the PL/SQL table
  parse_string
  ( p_string_in        => p_where_clause_in,
    p_atomics_list_out => l_atoms_tab,
    p_num_atomics_out  => l_no_atoms
  );

  IF NVL(g_refresh_tab.COUNT,0) <> 0 THEN
    -- loop thru the array g_refresh_tab and add the values in g_refresh_tab_all
     FOR i IN NVL(g_refresh_tab.FIRST,0)..NVL(g_refresh_tab.LAST,-1) LOOP
       l_found := false;
       IF NVL(g_refresh_tab_all.COUNT,0) <> 0 THEN
          FOR j IN NVL(g_refresh_tab_all.FIRST,0)..NVL(g_refresh_tab_all.LAST,-1) loop
              IF UPPER(g_refresh_tab(i).column_name) = UPPER(g_refresh_tab_all(j).column_name)  THEN
                  g_refresh_tab_all(j).txn_val := g_refresh_tab(i).txn_val;
                  g_refresh_tab_all(j).column_type := g_refresh_tab(i).column_type;
                  l_found := true;
                  EXIT; -- exit the loop as the column is found
              END IF;
          END LOOP;
       END IF;
      If not l_found then
         l_next := nvl(g_refresh_tab_all.COUNT,0);
         hr_utility.set_location('Adding row:'||to_char(l_next),10);
         g_refresh_tab_all(l_next).column_name := g_refresh_tab(i).column_name;
         g_refresh_tab_all(l_next).txn_val := g_refresh_tab(i).txn_val;
         g_refresh_tab_all(l_next).column_type := g_refresh_tab(i).column_type;
      End if;
      --
     END LOOP;
  END IF;


  -- loop thru the PL/SQL table and replace params

    FOR table_row IN NVL(l_atoms_tab.FIRST,0)..NVL(l_atoms_tab.LAST,-1)
    LOOP
       IF substr(NVL (l_atoms_tab(table_row), 'NULL') ,1,1) = '<' THEN
          hr_utility.set_location('Parameter:'||l_atoms_tab(table_row),11);
          l_key_column  := substr(l_atoms_tab(table_row),2,(LENGTH(LTRIM(RTRIM(l_atoms_tab(table_row)))) - 2)) ;
          l_key_col_null := l_atoms_tab(table_row -4);

          -- depending on the flag get the param value
          IF p_txn_tab_flag = 'Y' THEN
            -- this is txn table , so param value is IN parameter to the refresh_data procedure
            l_key_val := p_txn_id;
          ELSE
            -- this is shadow OR main table
            -- for the above key_column name get the value from the array
            l_key_val := get_value_from_array(p_column_name => l_key_column);
            hr_utility.set_location(l_key_column||' = '||l_key_val,15);
             -- if value is null pass the column name
             IF RTRIM(l_key_val) IS NULL THEN
                l_key_val := l_key_col_null;
             END IF;
          END IF;

          -- replace the param with the actual value
          l_atoms_tab(table_row) := l_key_val;
       END IF;

    END LOOP;

   -- build the where clause again
    l_where_out := '';   -- initialize variable
    FOR table_row IN NVL(l_atoms_tab.FIRST,0)..NVL(l_atoms_tab.LAST,-1)
    LOOP
       l_where_out := l_where_out||nvl(l_atoms_tab(table_row),' ');
    END LOOP;

    -- assign the out parameter the final where string
    p_where_clause_out := l_where_out;
    hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
      p_where_clause_out := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END replace_where_params;

    /*----------------------------------------------------------------
    || PROCEDURE : replace_where_params_purge
    ||
    ------------------------------------------------------------------*/
PROCEDURE replace_where_params_purge
 ( p_where_clause_in  IN     pqh_table_route.where_clause%TYPE,
   p_txn_tab_flag     IN     VARCHAR2,
   p_txn_id           IN     number,
   p_where_clause_out OUT NOCOPY    pqh_table_route.where_clause%TYPE ) IS

/*
  This procedure will replace all the parameters in the where_clause with their
actual values.
  p_txn_tab_flag will be 'Y' for the txn table. In the case of txn table we replace the txn_id
  value with the IN param value to the program. In the case of shadow and main table, we get
  param values from g_refresh_dtata array
*/

--
-- local variables
--
 l_proc          varchar2(72) := g_package||'replace_where_params_purge';
 l_atoms_tab     atoms_tabtype;  -- to hold the where_clause atoms
 l_no_atoms      number;
 l_key_column    pqh_attributes.column_name%TYPE;
 l_key_val       VARCHAR2(8000);
 l_where_out     pqh_table_route.where_clause%TYPE;
 l_key_col_null  VARCHAR2(8000);


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- parse the where_clause and populate the PL/SQL table
  parse_string
  ( p_string_in        => p_where_clause_in,
    p_atomics_list_out => l_atoms_tab,
    p_num_atomics_out  => l_no_atoms
  );


  -- loop thru the PL/SQL table and replace params

    FOR table_row IN NVL(l_atoms_tab.FIRST,0)..NVL(l_atoms_tab.LAST,-1)
    LOOP
       IF substr(NVL (l_atoms_tab(table_row), 'NULL') ,1,1) = '<' THEN
          l_key_column  := substr(l_atoms_tab(table_row),2,(LENGTH(LTRIM(RTRIM(l_atoms_tab(table_row)))) - 2)) ;
          l_key_col_null := l_atoms_tab(table_row -4);

          -- depending on the flag get the param value
          IF p_txn_tab_flag = 'Y' THEN
            -- this is txn table , so param value is IN parameter to the refresh_data procedure
            l_key_val := p_txn_id;
          ELSE
            -- this is shadow OR main table
            -- for the above key_column name get the value from the array
            l_key_val := get_value_from_array_purge(p_column_name => l_key_column);
             -- if value is null pass the column name
             IF RTRIM(l_key_val) IS NULL THEN
                l_key_val := l_key_col_null;
             END IF;
          END IF;

          -- replace the param with the actual value
          l_atoms_tab(table_row) := l_key_val;
       END IF;

    END LOOP;

   -- build the where clause again
    l_where_out := '';   -- initialize variable
    FOR table_row IN NVL(l_atoms_tab.FIRST,0)..NVL(l_atoms_tab.LAST,-1)
    LOOP
       l_where_out := l_where_out||nvl(l_atoms_tab(table_row),' ');
    END LOOP;

    -- assign the out parameter the final where string
    p_where_clause_out := l_where_out;
    hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
      p_where_clause_out := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END replace_where_params_purge;

    /*----------------------------------------------------------------
    || PROCEDURE : get_all_rows
    ||
    ------------------------------------------------------------------*/
PROCEDURE get_all_rows
(p_select_stmt      IN   t_where_clause_typ,
 p_from_clause      IN   pqh_table_route.from_clause%TYPE,
 p_where_clause     IN   pqh_table_route.where_clause%TYPE,
 p_total_columns    IN   NUMBER,
 p_total_rows       OUT NOCOPY  NUMBER,
 p_all_txn_rows     OUT NOCOPY  DBMS_SQL.VARCHAR2_TABLE )
 IS
/*
  This procedure will get all rows of the table and populate the array
  The OUT array p_all_txn_rows will have the following data .
  eg:  table has  3 rows and 3 columns then array has following value
  r1.c1, r2.c1, r3.c1, r2.c1, r2.c2, r2.c3, r3.c1, r3.c2, r3.c3

*/

--
-- local variables
--
 l_proc            varchar2(72) := g_package||'get_all_rows';
 c                 number;   -- cursor handle
 d                 number;   -- no of rows fetched by cursor
 v_tab             dbMS_SQL.VARCHAR2_TABLE; -- temp array to hold elements
 l_qry_string      VARCHAR2(32000); -- to cinstruct the qry string
 indx              number := 1;   -- start index of the array populated
 l_tot_rows_fetch  number := 0;   -- total of all array elements
 l_tot_cnt           number :=1;    -- index of the OUT array p_all_txn_rows


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- construct the query string
  l_qry_string := p_select_stmt||' FROM '||
                  p_from_clause||' WHERE '||
                  p_where_clause ;

  hr_utility.set_location('Qry Str : ',5);

  hr_utility.set_location(substr(l_qry_string,1,50), 10);
  hr_utility.set_location(substr(l_qry_string,51,50), 10);
  hr_utility.set_location(substr(l_qry_string,101,50), 10);
  hr_utility.set_location(substr(l_qry_string,151,50), 10);
  hr_utility.set_location(substr(l_qry_string,201,50), 10);
  hr_utility.set_location(substr(l_qry_string,251,50), 10);
  hr_utility.set_location(substr(l_qry_string,301,50), 10);
  hr_utility.set_location(substr(l_qry_string,351,50), 10);
  hr_utility.set_location(substr(l_qry_string,401,50), 10);
  hr_utility.set_location(substr(l_qry_string,451,50), 10);
  hr_utility.set_location(substr(l_qry_string,501,50), 10);
  hr_utility.set_location(substr(l_qry_string,551,50), 10);
  hr_utility.set_location(substr(l_qry_string,601,50), 10);
  hr_utility.set_location(substr(l_qry_string,651,50), 10);
  hr_utility.set_location(substr(l_qry_string,701,50), 10);
  hr_utility.set_location(substr(l_qry_string,751,50), 10);
  hr_utility.set_location(substr(l_qry_string,801,50), 10);
  hr_utility.set_location(substr(l_qry_string,851,50), 10);
  hr_utility.set_location(substr(l_qry_string,901,50), 10);
  hr_utility.set_location(substr(l_qry_string,951,50), 10);
  hr_utility.set_location(substr(l_qry_string,1001,50), 10);
  hr_utility.set_location(substr(l_qry_string,1051,50), 10);
  hr_utility.set_location(substr(l_qry_string,1101,50), 10);
  hr_utility.set_location(substr(l_qry_string,1151,50), 10);
  hr_utility.set_location(substr(l_qry_string,1201,50), 10);
  hr_utility.set_location(substr(l_qry_string,1251,50), 10);
  hr_utility.set_location(substr(l_qry_string,1301,50), 10);
  hr_utility.set_location(substr(l_qry_string,1351,50), 10);
  hr_utility.set_location(substr(l_qry_string,1401,50), 10);
  hr_utility.set_location(substr(l_qry_string,1451,50), 10);
  hr_utility.set_location(substr(l_qry_string,1501,50), 10);
  hr_utility.set_location(substr(l_qry_string,1551,50), 10);
  hr_utility.set_location(substr(l_qry_string,1601,50), 10);
  hr_utility.set_location(substr(l_qry_string,1651,50), 10);
  hr_utility.set_location(substr(l_qry_string,1701,50), 10);
  hr_utility.set_location(substr(l_qry_string,1751,50), 10);
  hr_utility.set_location(substr(l_qry_string,1801,50), 10);
  hr_utility.set_location(substr(l_qry_string,1851,50), 10);
  hr_utility.set_location(substr(l_qry_string,1901,50), 10);
  hr_utility.set_location(substr(l_qry_string,1951,50), 10);
  hr_utility.set_location(substr(l_qry_string,2001,50), 10);
  hr_utility.set_location(substr(l_qry_string,2051,50), 10);


 --  open the cursor
   c := dbms_sql.open_cursor;

  hr_utility.set_location('Opened Cursor : '||c, 10);


 -- parse the select stmt for errors
  dbms_sql.parse(c,l_qry_string, dbms_sql.native);

  hr_utility.set_location('Parsed Query String :', 15);

 -- for ALL COLUMNS we will LOOP one column at a time and build the
 -- total array

 FOR j in 1..p_total_columns
 LOOP

--   hr_utility.set_location('Inside first Loop : ', 16);

 -- define v_tab array to hold all the column values
  dbms_sql.define_array(c,j,v_tab,1, indx);

--   hr_utility.set_location('Defining Array : ', 18);

 -- execute the dynamic select for all rows
 -- this will fetch the j th column values in the v_tab array
  d := dbms_sql.execute(c);

--  hr_utility.set_location('Sql Execute : '||d, 20);

   LOOP
     d := dbms_sql.fetch_rows(c);

--     hr_utility.set_location('Fetched rows  : '||d, 25);

     EXIT WHEN d <> 1;
     l_tot_rows_fetch := l_tot_rows_fetch + 1;
     -- associate the fetch value with v_tab
     dbms_sql.column_value(c, j, v_tab);
   END LOOP;

--   hr_utility.set_location('After exec Loop : ', 30);

   -- populate the OUT array with the v_tab values for each column
   -- we do this as the v_tab array index resets for each column
   -- eg : if we have 5 rows and 10 columns the the index resets fro 1 to 5
   -- for each column

   FOR i in NVL(v_tab.FIRST,0)..NVL(v_tab.LAST,-1)
   LOOP

--      hr_utility.set_location('Inside v_tab loop : ', 31);
--      hr_utility.set_location('Table Val :'||v_tab(i), 32);
--      hr_utility.set_location('Inside v_tab loop : ', 33);

    -- dbms_output.put_line('tab Value :'||i||' '||v_tab(i) );

     p_all_txn_rows(l_tot_cnt) := v_tab(i);
     l_tot_cnt := l_tot_cnt + 1;
   END LOOP;

--   hr_utility.set_location('After second Loop : ', 35);

 END LOOP;  -- for all columns


  -- compute the total rows OUT variable
   p_total_rows := l_tot_rows_fetch/p_total_columns ;

   -- dbms_output.put_line('Total Rows : '||tot_rows);
   hr_utility.set_location('Total Rows :'||p_total_rows, 50);

  -- close the cursor
   dbms_sql.close_cursor(c);
   hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_all_rows;




    /*----------------------------------------------------------------
    || PROCEDURE : compute_updt_flag
    ||
    ------------------------------------------------------------------*/


PROCEDURE compute_updt_flag
 IS
/*
    This procedure would be called from the refresh_data. This procedure would loop thru the
    g_refresh_tab table and set the updt_flag column.
    Y =>  update column
    N => don't update column as NO change
    C => don't update column as the USER HAS CHANGED THE COLUMN WHICH CAN BE REFRESHED
    we will use 'C' to set visual attribute of item in the TXN form
    as we plan to give provision to user to refresh a refreshable column with right mouse
    click. This new visual attribute will wrn the user that he or someone who routed this txn to him
    has intentionally changed this value, so be cautious before you refresh this column
*/

--
-- local variables
--
 l_proc            varchar2(72) := g_package||'compute_updt_flag';


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- loop thru the g_refresh_tab array
  FOR i IN NVL(g_refresh_tab.FIRST,0)..NVL(g_refresh_tab.LAST,-1)
  LOOP
     IF NVL(g_refresh_tab(i).refresh_flag,'N') = 'Y' THEN
        -- as this column can be refreshed check for changed
         IF NVL(g_refresh_tab(i).shadow_val,'$$$') = NVL(g_refresh_tab(i).txn_val,'$$$') THEN
          -- value was not changed by user in txn form
          -- compare with the main table value to see if some has updated it
           IF NVL(g_refresh_tab(i).shadow_val,'$$$') = NVL(g_refresh_tab(i).main_val,'$$$') THEN
              -- value is unchanged
               g_refresh_tab(i).updt_flag := 'N';
           ELSE
              -- main table was updated
              -- so update the txn and shadow tables
              g_refresh_tab(i).updt_flag := 'Y';
           END IF;
         ELSE
           -- as shadow_val and txn_val are different
           -- the user has changed the value of this column in the txn form
           -- so don update this column
              g_refresh_tab(i).updt_flag := 'C';

         END IF;

     ELSE
       -- this column is not to be refreshed
       g_refresh_tab(i).updt_flag := 'N';
     END IF;

  /*
      hr_utility.set_location('Col Name     : '||g_refresh_tab(i).column_name,100);
      hr_utility.set_location('Col Type     : '||g_refresh_tab(i).column_type,100);
      hr_utility.set_location('Refresh Flag : '||g_refresh_tab(i).refresh_flag,100);
      hr_utility.set_location('Txn Val      : '||g_refresh_tab(i).txn_val,100);
      hr_utility.set_location('Shadow Val   : '||g_refresh_tab(i).shadow_val,100);
      hr_utility.set_location('Pos Val      : '||g_refresh_tab(i).main_val,100);
      hr_utility.set_location('Updt Flag    : '||g_refresh_tab(i).updt_flag,100);
 */

  END LOOP;
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END compute_updt_flag;



    /*----------------------------------------------------------------
    || PROCEDURE : update_tables
    ||
    ------------------------------------------------------------------*/


PROCEDURE update_tables
(p_column_name           IN pqh_attributes.column_name%TYPE,
 p_column_type           IN pqh_attributes.column_type%TYPE,
 p_column_val            IN VARCHAR2,
 p_from_clause_txn       IN pqh_table_route.from_clause%TYPE,
 p_from_clause_shd       IN pqh_table_route.from_clause%TYPE,
 p_rep_where_clause_shd  IN pqh_table_route.where_clause%TYPE )
IS
/*
  This procedure will update the txn and shadow tables with the new value.
  As the shadow and txn tables are identical, we use the wwhere clause of shadow
  which uniquely identifies only ONE row
*/
--
-- local variables
--
 l_proc            varchar2(72) := g_package||'update_tables';
 l_stmt_str        VARCHAR2(8000);
 l_where_clause    VARCHAR2(8000);
 l_col_val         VARCHAR2(8000);
 l_front           VARCHAR2(100);
 l_back            VARCHAR2(100);

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('p_column_name : '||p_column_name, 5);
  hr_utility.set_location('p_column_type : '||p_column_type, 5);
  hr_utility.set_location('p_column_val : '||p_column_val, 5);
  hr_utility.set_location('from_txn : '||p_from_clause_txn, 5);
  hr_utility.set_location('from_shd : '||p_from_clause_shd, 5);
  hr_utility.set_location('rep__shd : '||p_rep_where_clause_shd, 5);

  l_col_val := p_column_val;

  -- form the front and back packing string
  IF    p_column_type = 'D' THEN
          l_front := 'TO_DATE(';
          l_back  := ',''RRRRMMDD HH24MISS'')';
  ELSE
          l_front :=  ' ';
          l_back  :=  ' ';
  END IF;


  -- construct where clause which is same for BOTH tables
  l_where_clause := ' SET '||p_column_name||' =  '||
                    l_front||':p_col_val '||l_back||
                    ' WHERE '||p_rep_where_clause_shd ;

  /*
         update TRANSACTION TABLE
 */
  -- construct the updt stmt
  l_stmt_str  := ''; -- initialize string
  l_stmt_str := 'UPDATE '||p_from_clause_txn||l_where_clause ;

  hr_utility.set_location('Update Statement ',10);

  hr_utility.set_location(substr(l_stmt_str,1,50), 10);
  hr_utility.set_location(substr(l_stmt_str,51,50), 10);
  hr_utility.set_location(substr(l_stmt_str,101,50), 10);
  hr_utility.set_location(substr(l_stmt_str,151,50), 10);
  hr_utility.set_location(substr(l_stmt_str,201,50), 10);
  hr_utility.set_location(substr(l_stmt_str,251,50), 10);
  hr_utility.set_location(substr(l_stmt_str,301,50), 10);
  hr_utility.set_location(substr(l_stmt_str,351,50), 10);
  hr_utility.set_location(substr(l_stmt_str,401,50), 10);
  hr_utility.set_location(substr(l_stmt_str,451,50), 10);
  hr_utility.set_location(substr(l_stmt_str,501,50), 10);
  hr_utility.set_location(substr(l_stmt_str,551,50), 10);
  hr_utility.set_location(substr(l_stmt_str,601,50), 10);
  hr_utility.set_location(substr(l_stmt_str,651,50), 10);
  hr_utility.set_location(substr(l_stmt_str,701,50), 10);
  hr_utility.set_location(substr(l_stmt_str,751,50), 10);
  hr_utility.set_location(substr(l_stmt_str,801,50), 10);
  hr_utility.set_location(substr(l_stmt_str,851,50), 10);
  hr_utility.set_location(substr(l_stmt_str,901,50), 10);
  hr_utility.set_location(substr(l_stmt_str,951,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1001,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1051,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1101,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1151,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1201,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1251,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1301,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1351,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1401,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1451,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1501,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1551,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1601,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1651,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1701,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1751,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1801,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1851,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1901,50), 10);
  hr_utility.set_location(substr(l_stmt_str,1951,50), 10);
  hr_utility.set_location(substr(l_stmt_str,2001,50), 10);
  hr_utility.set_location(substr(l_stmt_str,2051,50), 10);


 -- execute the updt stmt
  EXECUTE IMMEDIATE l_stmt_str
    USING l_col_val ;

  /*
         update SHADOW TABLE
 */
  -- construct the updt stmt
  l_stmt_str  := ''; -- initialize string
  l_stmt_str := 'UPDATE '||p_from_clause_shd||l_where_clause ;

 -- execute the updt stmt
  EXECUTE IMMEDIATE l_stmt_str
    USING l_col_val ;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END update_tables;

-- Procedures for PQHPCTXN form Visual Attribute Implementation

    /*----------------------------------------------------------------
    || PROCEDURE : count_changed
    ||
    ------------------------------------------------------------------*/

PROCEDURE count_changed
(p_count  OUT NOCOPY  number )
IS
/*
 This procedure will loop thru the g_refresh_data array and populate the
 prvcalc array. This is written for PQHPCTXN for for the visual attributes
 implementation part.
*/


 l_proc              varchar2(72) := g_package||'count_changed';
 l_form_column_name  pqh_txn_category_attributes.form_column_name%TYPE;
 l_mode_flag         varchar2(1) := 'E';
 l_reqd_flag         varchar2(1) := 'C';
 l_cnt               binary_integer := 0;


CURSOR c1(p_column_name  pqh_attributes.column_name%TYPE ) IS
  SELECT tca.form_column_name
  FROM   pqh_attributes att, pqh_txn_category_attributes tca
  WHERE  att.attribute_id = tca.attribute_id
    AND  tca.transaction_category_id = g_txn_category_id
    AND  att.refresh_col_name = p_column_name;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  IF NVL(g_refresh_bak.COUNT,0) <> 0 THEN

      FOR i IN NVL(g_refresh_bak.FIRST,0)..NVL(g_refresh_bak.LAST,-1)
      LOOP

          IF g_refresh_bak(i).updt_flag = 'C' THEN
           -- get the form_column_name for the column_name and populate the prvcalc table

            OPEN c1(pqh_refresh_data.g_refresh_bak(i).column_name);
            FETCH c1 INTO l_form_column_name;
            CLOSE c1;

             -- populate the global prv_tab
             l_cnt := l_cnt + 1;

             g_attrib_prv_tab(l_cnt).form_column_name := l_form_column_name;
             g_attrib_prv_tab(l_cnt).mode_flag        := l_mode_flag;
             g_attrib_prv_tab(l_cnt).reqd_flag        := l_reqd_flag;

          END IF;

      END LOOP;

      -- populate the OUT variable
      p_count := g_attrib_prv_tab.COUNT;

  ELSE
   -- g_refresh_bak is empty
     p_count := 0;

  END IF;


  hr_utility.set_location('Total Items Changed : '||p_count,9);

  hr_utility.set_location('Leaving:'||l_proc, 10);


EXCEPTION
      WHEN OTHERS THEN
      p_count := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END count_changed;



    /*----------------------------------------------------------------
    || PROCEDURE : get_row_prv_calc
    ||
    ------------------------------------------------------------------*/

PROCEDURE get_row_prv_calc
( p_row                IN    number,
  p_form_column_name   OUT NOCOPY   pqh_txn_category_attributes.form_column_name%TYPE,
  p_mode_flag          OUT NOCOPY   varchar2,
  p_reqd_flag          OUT NOCOPY   varchar2
) IS

/*
  This procedure will return the row in the prvcalc table corresponding to p_row
*/

 l_proc            varchar2(72) := g_package||'get_row_prv_calc';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  p_form_column_name  := g_attrib_prv_tab(p_row).form_column_name;
  p_mode_flag         := 'E';
  p_reqd_flag         := 'C';


  hr_utility.set_location('Leaving:'||l_proc, 10);

EXCEPTION
      WHEN OTHERS THEN
      p_form_column_name := null;
      p_mode_flag := null;
      p_reqd_flag := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_row_prv_calc;

-- Procedure to Parse string into atoms

    /*----------------------------------------------------------------
    || PROCEDURE : parse_string
    ||
    ------------------------------------------------------------------*/


PROCEDURE parse_string
  (p_string_in IN pqh_table_route.where_clause%TYPE,
   p_atomics_list_out OUT NOCOPY atoms_tabtype,
   p_num_atomics_out IN OUT NOCOPY NUMBER,
   p_delimiters_in IN VARCHAR2 := std_delimiters)

    /*
    || Version of parse_string which stores the list of atomics
    || in a PL/SQL table.
    ||
    || Parameters:
    ||		p_string_in - the string to be parsed.
    ||		p_atomics_list_out - the table of atomics.
    ||		p_num_atomics_out - the number of atomics found.
    ||		p_delimiters_in - the set of delimiters used in parse.
    */

    IS
BEGIN
        /* Initialize variables. */
        p_num_atomics_out := 0;
        len_string := string_length (p_string_in);

        IF len_string IS NOT NULL
        THEN
            /*
            || Only scan the string if made of something more than blanks.
            || Start at first non-blank character. Remember: INSTR returns 0
            || if a space is not found. Stop scanning if at end of string.
            */
            start_loc := LEAST (1, INSTR (p_string_in, ' ') + 1);
            WHILE start_loc <= len_string
            LOOP
                /*
                || Find the starting point of the NEXT atomic. Go ahead and
                || increment counter for the number of atomics. Then have to
                || actually pull out the atomic. Two cases to consider:
                ||		1. Last atomic goes to end of string.
                ||		2. The atomic is a single blank. Use special constant.
                ||		3. Anything else.
                */
                next_loc := next_atom_loc (p_string_in, start_loc);
                p_num_atomics_out := p_num_atomics_out + 1;
                IF next_loc > len_string
                THEN
                    -- Atomic is all characters right to the end of the string.
                    p_atomics_list_out (p_num_atomics_out) :=
                            SUBSTR (p_string_in, start_loc);
                ELSE
                    /*
                    || Internal atomic. If RTRIMs to NULL, have a blank
                    || Use special-case string to stuff a " " in the table.
                    */
                    p_atomics_list_out (p_num_atomics_out) :=
                        NVL (RTRIM (SUBSTR (p_string_in,
                                                  start_loc, next_loc-start_loc)),
 							  a_blank);
                END IF;

                -- Move starting point of scan for next atomic.
                start_loc := next_loc;
            END LOOP;
        END IF;
END parse_string;

END; -- Package Body PQH_REFRESH_DATA

/
