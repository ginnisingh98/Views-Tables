--------------------------------------------------------
--  DDL for Package Body XLA_XLAIQACL_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_XLAIQACL_UTILS_PKG" AS
/* $Header: xlafuacl.pkb 120.2 2006/06/28 11:17:48 kprattip noship $ */

-- ************************************************************************
-- PUBLIC PROCEDURES
-- ************************************************************************

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    calc_sums                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Calculates dr and cr totals either for given transaction or for the     |
 |   passed where clause for given application. The function totals the lines|
 |   from the view name passed in. 					     |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |    none                                                                   |
 |                                                                           |
 | ARGUMENTS  : IN:  p_application_id      -- E.g 222 for Receivables        |
 |                   p_trx_hdr_table       -- Transaction header table       |
 |		     p_trx_hdr_id          -- Transaction header id          |
 |                   p_cost_type_id        -- Cost Type Id (Mfg PAC trx)     |
 |                   p_ovr_where_clause    -- Overriding where clause        |
 |                   p_view_name    	   -- View Name                      |
 |                   p_add_col_name_1 	   -- Additional Column Name 1       |
 |                   p_add_col_value_1 	   -- Additional Column Value 1      |
 |                   p_add_col_name_2 	   -- Additional Column Name 2       |
 |                   p_add_col_value_2 	   -- Additional Column Value 2      |
 |              OUT: x_total_entered_dr                                      |
 |                   x_total_entered_cr                                      |
 |		     x_total_accounted_dr                                    |
 |		     x_total_accounted_cr                                    |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-Nov-98  Heli Lankinen       Created                                |
 |     04-Aug-99  Mahesh Sabapthy       Added parameter cost_type_id to      |
 |                                      support Mfg. PAC transactions.       |
 |     15-Sep-99  Dimple Shah         Added parameters -                     |
 |                                    add_col_name_1, add_col_value_1,       |
 |                                    add_col_name_2, add_col_value_2        |
 |                                                                           |
 +===========================================================================*/
PROCEDURE CALC_SUMS (
	p_application_id     	IN  	NUMBER,
	p_set_of_books_id     	IN  	NUMBER,
	p_trx_hdr_table      	IN 	VARCHAR2,
	p_trx_hdr_id         	IN 	NUMBER,
	p_cost_type_id         	IN 	NUMBER,
	p_ovr_where_clause   	IN  	VARCHAR2,
	p_view_name   	     	IN  	VARCHAR2,
	p_add_col_name_1      	IN  	VARCHAR2,
	p_add_col_value_1      	IN  	VARCHAR2,
	p_add_col_name_2      	IN  	VARCHAR2,
	p_add_col_value_2      	IN  	VARCHAR2,
	x_total_entered_dr   	OUT NOCOPY 	NUMBER,
	x_total_entered_cr   	OUT NOCOPY 	NUMBER,
	x_total_accounted_dr 	OUT NOCOPY 	NUMBER,
	x_total_accounted_cr 	OUT NOCOPY 	NUMBER ) IS

  l_total_entered_dr 	NUMBER;
  l_total_entered_cr 	NUMBER;
  l_total_accounted_dr 	NUMBER;
  l_total_accounted_cr 	NUMBER;

  l_trx_hdr_table 	VARCHAR2(50);
  l_trx_hdr_id 		NUMBER;

  c 			INTEGER;
  l_count_cur 		NUMBER;
  select_statement 	VARCHAR2(3000);
  select_clause 	VARCHAR2(3000);
  where_clause   	VARCHAR2(3000);
  rows 			NUMBER;

BEGIN

  select_clause :=
       ' SELECT  SUM(entered_dr),
		 SUM(entered_cr),
		 SUM(accounted_dr),
		 SUM(accounted_cr),
		 COUNT(DISTINCT currency_code) '||
       ' FROM '||p_view_name;

  IF p_ovr_where_clause IS NOT NULL THEN
 	where_clause := p_ovr_where_clause ||
	   ' AND	application_id = :l_appl_id '||
	   ' AND	set_of_books_id = :l_sob_id ';
  ELSE
/* Changed by Dimple.   */
  -- Standard where clause
     where_clause := ' WHERE application_id = :l_appl_id '||
	             ' AND set_of_books_id = :l_sob_id ';

     IF p_add_col_name_1 IS NOT NULL THEN
	 where_clause := where_clause||
	 ' AND '||p_add_col_name_1||' = :l_add_col_value_1 ';
     END IF;

     IF p_add_col_name_2 IS NOT NULL THEN
	 where_clause := where_clause||' '||
	 ' AND '||p_add_col_name_2||' = :l_add_col_value_2 ';
     END IF;

     IF p_trx_hdr_table IS NOT NULL THEN
	where_clause := where_clause||
	' AND	trx_hdr_table = :l_trx_hdr_table ';
     END IF;

     IF p_trx_hdr_id IS NOT NULL THEN
	where_clause := where_clause||
        ' AND	trx_hdr_id = :l_trx_hdr_id ';
     END IF;

     	-- Mfg PAC support: Filter based on cost_type_id for PAC transactions
     IF ( p_cost_type_id IS NOT NULL ) THEN
       where_clause := where_clause||
	       ' AND	cost_type_id = :l_cost_type_id ';
     END IF;
  END IF;


  -- Final Select Statement

  select_statement := select_clause||' '||where_clause;

  -- open cursor
  c := dbms_sql.open_cursor;

  -- parse cursor
  dbms_sql.parse(c,select_statement,dbms_sql.v7);

  -- bind variables
  IF p_ovr_where_clause IS NULL THEN

     IF p_add_col_name_1 IS NOT NULL THEN
	   dbms_sql.bind_variable(c,'l_add_col_value_1', p_add_col_value_1);
     END IF;
     IF p_add_col_name_2 IS NOT NULL THEN
	   dbms_sql.bind_variable(c,'l_add_col_value_2', p_add_col_value_2);
     END IF;
     IF p_trx_hdr_table IS NOT NULL THEN
	   dbms_sql.bind_variable(c,'l_trx_hdr_table', p_trx_hdr_table);
     END IF;
     IF p_trx_hdr_id IS NOT NULL THEN
	   dbms_sql.bind_variable(c,'l_trx_hdr_id', p_trx_hdr_id);
     END IF;
     IF p_cost_type_id IS NOT NULL THEN
	   dbms_sql.bind_variable(c,'l_cost_type_id', p_cost_type_id);
     END IF;
  END IF;

  IF p_application_id IS NOT NULL THEN
	dbms_sql.bind_variable(c,'l_appl_id', p_application_id);
  END IF;
  IF p_set_of_books_id IS NOT NULL THEN
     dbms_sql.bind_variable(c,'l_sob_id', p_set_of_books_id);
  END IF;

  --define columns in select
  dbms_sql.define_column(c,1,l_total_entered_dr);
  dbms_sql.define_column(c,2,l_total_entered_cr);
  dbms_sql.define_column(c,3,l_total_accounted_dr);
  dbms_sql.define_column(c,4,l_total_accounted_cr);
  dbms_sql.define_column(c,5,l_count_cur);

  rows := dbms_sql.execute(c);
  IF dbms_sql.fetch_rows(c) = 0 THEN

	-- No rows retrieved
	x_total_entered_dr := 0;
	x_total_entered_cr := 0;
	x_total_accounted_dr := 0;
	x_total_accounted_cr := 0;

  ELSE

  	dbms_sql.column_value(c,1,l_total_entered_dr);
  	dbms_sql.column_value(c,2,l_total_entered_cr);
  	dbms_sql.column_value(c,3,l_total_accounted_dr);
  	dbms_sql.column_value(c,4,l_total_accounted_cr);
  	dbms_sql.column_value(c,5,l_count_cur);

	x_total_accounted_dr := l_total_accounted_dr;
	x_total_accounted_cr := l_total_accounted_cr;

	IF l_count_cur = 1 THEN --single currency, show totals
   	       x_total_entered_dr := l_total_entered_dr;
  	       x_total_entered_cr := l_total_entered_cr;
 	ELSE -- this is cross currency, no entered totals
	       x_total_entered_dr := NULL;
 	       x_total_entered_cr := NULL;
	END IF;

  END IF;

  --close cursor
  dbms_sql.close_cursor(c);

EXCEPTION
  WHEN OTHERS THEN
    if ( dbms_sql.is_open(c) ) then
    	dbms_sql.close_cursor(c);
    end if;
    fnd_message.set_name('FND', 'FORM_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'xla_xlaiqacl_total_pkg.calc_sums');
    RAISE;

END CALC_SUMS;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_acct_method_info                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Get Accounting methods and associated SOB info by product.              |
 +===========================================================================*/
PROCEDURE get_acct_method_info (
        p_application_id        IN      NUMBER,
        x_acct_method_info  	OUT NOCOPY     acct_method_info_tbl ) IS

/*  CURSOR ap_acct_method_sob_c IS
	SELECT v.set_of_books_id, v.sob_type, v.accounting_method,
		v.base_currency_code, v.name, sob.short_name,
                ap.displayed_field
	  FROM ap_sob_info_v v, gl_sets_of_books sob, ap_lookup_codes ap
	 WHERE v.set_of_books_id <> -1
	   AND sob.set_of_books_id = v.set_of_books_id
           AND v.accounting_method = ap.lookup_code
           AND ap.lookup_type = 'ACCOUNTING BASIS METHOD';
*/
-- Changed the select from ap_sob_info_v view to actual select from tables
-- since that view was owned by AP and changed to select reporting sobs too.

  CURSOR ap_acct_method_sob_c IS
         SELECT sob1.set_of_books_id set_of_books_id,
               'Primary' sob_type,
               sp1.accounting_method_option accounting_method,
               sp1.base_currency_code base_currency_code,
               sob1.name name ,
               sob1.short_name short_name,
               ap1.displayed_field displayed_field
          FROM gl_sets_of_books sob1, ap_system_parameters sp1,
               ap_lookup_codes ap1
         WHERE sob1.set_of_books_id <> -1
           AND ap1.lookup_code = sp1.accounting_method_option
           AND ap1.lookup_type = 'ACCOUNTING BASIS METHOD'
           AND sob1.set_of_books_id = sp1.set_of_books_id
 UNION
        SELECT sob2.set_of_books_id set_of_books_id,
               'Secondary' sob_type,
               sp2.secondary_accounting_method accounting_method,
               sp2.base_currency_code base_currency_code,
               sob2.name name ,
               sob2.short_name short_name,
               ap2.displayed_field displayed_field
          FROM gl_sets_of_books sob2, ap_system_parameters sp2,
               ap_lookup_codes ap2
         WHERE sob2.set_of_books_id <> -1
           AND ap2.lookup_code = sp2.secondary_accounting_method
           AND ap2.lookup_type = 'ACCOUNTING BASIS METHOD'
           AND sob2.set_of_books_id = sp2.secondary_set_of_books_id;


  i 			BINARY_INTEGER := 1;	-- table subscript
  l_acct_method_info	acct_method_info_tbl;
BEGIN
  xla_util.debug('xla_xlaiqacl_utils_pkg.get_acct_method_info()+');

  IF ( p_application_id = 200 ) THEN

    FOR l_ap_acct_method_info_rec in ap_acct_method_sob_c LOOP

    	l_acct_method_info(i).accounting_method :=
			l_ap_acct_method_info_rec.accounting_method;
    	l_acct_method_info(i).sob_id :=
			l_ap_acct_method_info_rec.set_of_books_id;
    	l_acct_method_info(i).sob_curr :=
			l_ap_acct_method_info_rec.base_currency_code;
    	l_acct_method_info(i).sob_type :=
			substr(l_ap_acct_method_info_rec.sob_type,1,1);
    	l_acct_method_info(i).sob_name :=
			l_ap_acct_method_info_rec.name;
    	l_acct_method_info(i).sob_short_name :=
			l_ap_acct_method_info_rec.short_name;
    	l_acct_method_info(i).accounting_method_name :=
			l_ap_acct_method_info_rec.displayed_field;

	i := i + 1;

    END LOOP;

  END IF;		-- AP?

  -- Copy to Output
  x_acct_method_info := l_acct_method_info;

  xla_util.debug('xla_xlaiqacl_utils_pkg.get_acct_method_info()-');

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('FND', 'FORM_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'xla_xlaiqacl_total_pkg.get_acct_method_info');
    RAISE;

END get_acct_method_info;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_acct_method_info_scalar                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Gets the accounting methods and set of books info associated with the   |
 |   accounting method for a given application.                              |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |    none                                                                   |
 |                                                                           |
 | ARGUMENTS  : IN:  p_application_id      -- E.g 200 for Payables           |
 |              OUT:                                                         |
 |                   acct_method_n                                           |
 |                   sob_id_n                                                |
 |                   sob_curr_n                                              |
 |                   sob_type_n                                              |
 |                   sob_name_n                                              |
 |                   sob_short_name_n                                        |
                     acct_method_name_n
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-Apr-99  Mahesh Sabapathy    Created                                |
 +===========================================================================*/
PROCEDURE get_acct_method_info_scalar (
        p_application_id        IN      NUMBER,
 	x_acct_method_1    	OUT NOCOPY	VARCHAR2,
 	x_sob_id_1        	OUT NOCOPY	NUMBER,
 	x_sob_curr_1     	OUT NOCOPY	VARCHAR2,
 	x_sob_type_1    	OUT NOCOPY	VARCHAR2,
 	x_sob_name_1   		OUT NOCOPY	VARCHAR2,
 	x_sob_short_name_1 	OUT NOCOPY	VARCHAR2,
 	x_acct_method_name_1	OUT NOCOPY	VARCHAR2,
 	x_acct_method_2    	OUT NOCOPY	VARCHAR2,
 	x_sob_id_2        	OUT NOCOPY	NUMBER,
 	x_sob_curr_2     	OUT NOCOPY	VARCHAR2,
 	x_sob_type_2    	OUT NOCOPY	VARCHAR2,
 	x_sob_name_2   		OUT NOCOPY	VARCHAR2,
 	x_sob_short_name_2 	OUT NOCOPY	VARCHAR2,
 	x_acct_method_name_2	OUT NOCOPY	VARCHAR2 ) IS

  l_acct_method_info	acct_method_info_tbl;
  i			BINARY_INTEGER;
BEGIN
  -- Get Acct Method info
  get_acct_method_info( p_application_id,
			l_acct_method_info );

  IF l_acct_method_info.COUNT > 0 THEN

     -- Translate table to scalar parameters
     FOR i in l_acct_method_info.FIRST .. l_acct_method_info.LAST LOOP

       IF l_acct_method_info.EXISTS(i) THEN

         -- First row
          IF i = 1 AND l_acct_method_info(i).sob_id <> -1 THEN
	     x_acct_method_1 := l_acct_method_info(i).accounting_method;
	     x_sob_id_1 := l_acct_method_info(i).sob_id;
	     x_sob_curr_1 := l_acct_method_info(i).sob_curr;
	     x_sob_type_1 := l_acct_method_info(i).sob_type;
	     x_sob_name_1 := l_acct_method_info(i).sob_name;
	     x_sob_short_name_1 := l_acct_method_info(i).sob_short_name;
	     x_acct_method_name_1 := l_acct_method_info(i).accounting_method_name;
          END IF;

    -- Second row
          IF i = 2 AND l_acct_method_info(i).sob_id <> -1 THEN
	     x_acct_method_2 := l_acct_method_info(i).accounting_method;
	     x_sob_id_2 := l_acct_method_info(i).sob_id;
	     x_sob_curr_2 := l_acct_method_info(i).sob_curr;
	     x_sob_type_2 := l_acct_method_info(i).sob_type;
	     x_sob_name_2 := l_acct_method_info(i).sob_name;
	     x_sob_short_name_2 := l_acct_method_info(i).sob_short_name;
	     x_acct_method_name_2 := l_acct_method_info(i).accounting_method_name;
          END IF;

       END IF;

     END LOOP;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('FND', 'FORM_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'xla_xlaiqacl_total_pkg.get_acct_method_info_scalar');
    RAISE;

END get_acct_method_info_scalar;

END xla_xlaiqacl_utils_pkg;

/
