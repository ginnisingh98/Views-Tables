--------------------------------------------------------
--  DDL for Package Body GMF_GL_GET_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GL_GET_BALANCES" AS
/* $Header: gmfbalnb.pls 120.3 2005/10/11 02:50:54 sschinch noship $ */

/** Anand thiyagarajan GL Expense Allocation Enhancement 26-04-2004 Start**/

CURSOR cur_gl_get_balances
                                (
                                in_set_of_books number
                                , in_period_year number
                                , in_period_num number
                                , in_account_type varchar2
                                , in_currency_code varchar2
                                , in_actual_flag varchar2
                                , in_ytd_ptd number
                                , in_from_segments gmf_segment_values_tbl
                                , in_to_segments gmf_segment_values_tbl
                                , l_segment_delimiter VARCHAR2
                                , l_currency_code gl_sets_of_books.currency_code%TYPE     -- Bug 4066174 Added
                                )
    IS
    SELECT  /*+ index(glbal gl_balances_n1 )    */
                    in_set_of_books,
             	      glcc.chart_of_accounts_id,
  		              glbal.period_year,
                    glbal.period_num,
                    glcc.account_type,
		                glbal.currency_code,
	                  glcc.segment1||l_segment_delimiter||
                    glcc.segment2||l_segment_delimiter||
                    glcc.segment3||l_segment_delimiter||
                    glcc.segment4||l_segment_delimiter||
                    glcc.segment5||l_segment_delimiter||
                    glcc.segment6||l_segment_delimiter||
                    glcc.segment7||l_segment_delimiter||
                    glcc.segment8||l_segment_delimiter||
                    glcc.segment9||l_segment_delimiter||
                    glcc.segment10||l_segment_delimiter||
                    glcc.segment11||l_segment_delimiter||
                    glcc.segment12||l_segment_delimiter||
                    glcc.segment13||l_segment_delimiter||
                    glcc.segment14||l_segment_delimiter||
                    glcc.segment15||l_segment_delimiter||
                    glcc.segment16||l_segment_delimiter||
                    glcc.segment17||l_segment_delimiter||
                    glcc.segment18||l_segment_delimiter||
                    glcc.segment19||l_segment_delimiter||
                    glcc.segment20||l_segment_delimiter||
                    glcc.segment21||l_segment_delimiter||
                    glcc.segment22||l_segment_delimiter||
                    glcc.segment23||l_segment_delimiter||
                    glcc.segment24||l_segment_delimiter||
                    glcc.segment25||l_segment_delimiter||
                    glcc.segment26||l_segment_delimiter||
                    glcc.segment27||l_segment_delimiter||
                    glcc.segment28||l_segment_delimiter||
                    glcc.segment29||l_segment_delimiter||
                    glcc.segment30	code_combinations,
		                glbal.actual_flag,
                    DECODE(in_ytd_ptd, 0,  (period_net_dr    - period_net_cr),
                                        1,  (begin_balance_dr - begin_balance_cr) +
                                            (period_net_dr    - period_net_cr),
                                            (begin_balance_dr - begin_balance_cr) +
                                            (period_net_dr    - period_net_cr)),
                    l_segment_delimiter
     FROM
		                gl_code_combinations glcc,
    		            gl_balances glbal
         WHERE
		                  glbal.code_combination_id = glcc.code_combination_id
                AND 	glbal.period_year = in_period_year
                AND 	glbal.period_num = in_period_num
                AND 	glbal.currency_code = nvl( in_currency_code, l_currency_code )
                --AND  	glbal.set_of_books_id = in_set_of_books
                AND     glbal.ledger_id       = in_set_of_books /* this is used as ledger id INVCONV sschinch*/
                AND 	glbal.actual_flag = nvl(in_actual_flag, glbal.actual_flag)
                AND 	glcc.account_type = nvl(in_account_type, glcc.account_type)
		AND 	(in_from_segments(1) IS NULL 	OR in_to_segments(1) IS NULL 	OR (glcc.segment1 IS NULL) OR (glcc.segment1 >= nvl(in_from_segments(1),glcc.segment1) and  glcc.segment1 <= nvl(in_to_segments(1),glcc.segment1)))
		AND 	(in_from_segments(2) IS NULL 	OR in_to_segments(2) IS NULL 	OR (glcc.segment2 IS NULL) OR (glcc.segment2 >= nvl(in_from_segments(2),glcc.segment2) and  glcc.segment2 <= nvl(in_to_segments(2),glcc.segment2)))
		AND 	(in_from_segments(3) IS NULL 	OR in_to_segments(3) IS NULL 	OR (glcc.segment3 IS NULL) OR (glcc.segment3 >= nvl(in_from_segments(3),glcc.segment3) and  glcc.segment3 <= nvl(in_to_segments(3),glcc.segment3)))
		AND 	(in_from_segments(4) IS NULL 	OR in_to_segments(4) IS NULL 	OR (glcc.segment4 IS NULL) OR (glcc.segment4 >= nvl(in_from_segments(4),glcc.segment4) and  glcc.segment4 <= nvl(in_to_segments(4),glcc.segment4)))
		AND 	(in_from_segments(5) IS NULL 	OR in_to_segments(5) IS NULL 	OR (glcc.segment5 IS NULL) OR (glcc.segment5 >= nvl(in_from_segments(5),glcc.segment5) and  glcc.segment5 <= nvl(in_to_segments(5),glcc.segment5)))
		AND 	(in_from_segments(6) IS NULL 	OR in_to_segments(6) IS NULL 	OR (glcc.segment6 IS NULL) OR (glcc.segment6 >= nvl(in_from_segments(6),glcc.segment6) and  glcc.segment6 <= nvl(in_to_segments(6),glcc.segment6)))
		AND 	(in_from_segments(7) IS NULL 	OR in_to_segments(7) IS NULL 	OR (glcc.segment7 IS NULL) OR (glcc.segment7 >= nvl(in_from_segments(7),glcc.segment7) and  glcc.segment7 <= nvl(in_to_segments(7),glcc.segment7)))
		AND 	(in_from_segments(8) IS NULL 	OR in_to_segments(8) IS NULL 	OR (glcc.segment8 IS NULL) OR (glcc.segment8 >= nvl(in_from_segments(8),glcc.segment8) and  glcc.segment8 <= nvl(in_to_segments(8),glcc.segment8)))
		AND 	(in_from_segments(9) IS NULL 	OR in_to_segments(9) IS NULL 	OR (glcc.segment9 IS NULL) OR (glcc.segment9 >= nvl(in_from_segments(9),glcc.segment9) and  glcc.segment9 <= nvl(in_to_segments(9),glcc.segment9)))
		AND 	(in_from_segments(10) IS NULL 	OR in_to_segments(10) IS NULL 	OR (glcc.segment10 IS NULL) OR (glcc.segment10 >= nvl(in_from_segments(10),glcc.segment10) and  glcc.segment10 <= nvl(in_to_segments(10),glcc.segment10)))
		AND 	(in_from_segments(11) IS NULL 	OR in_to_segments(11) IS NULL 	OR (glcc.segment11 IS NULL) OR (glcc.segment11 >= nvl(in_from_segments(11),glcc.segment11) and  glcc.segment11 <= nvl(in_to_segments(11),glcc.segment11)))
		AND 	(in_from_segments(12) IS NULL 	OR in_to_segments(12) IS NULL 	OR (glcc.segment12 IS NULL) OR (glcc.segment12 >= nvl(in_from_segments(12),glcc.segment12) and  glcc.segment12 <= nvl(in_to_segments(12),glcc.segment12)))
		AND 	(in_from_segments(13) IS NULL 	OR in_to_segments(13) IS NULL 	OR (glcc.segment13 IS NULL) OR (glcc.segment13 >= nvl(in_from_segments(13),glcc.segment13) and  glcc.segment13 <= nvl(in_to_segments(13),glcc.segment13)))
		AND 	(in_from_segments(14) IS NULL 	OR in_to_segments(14) IS NULL 	OR (glcc.segment14 IS NULL) OR (glcc.segment14 >= nvl(in_from_segments(14),glcc.segment14) and  glcc.segment14 <= nvl(in_to_segments(14),glcc.segment14)))
		AND 	(in_from_segments(15) IS NULL 	OR in_to_segments(15) IS NULL 	OR (glcc.segment15 IS NULL) OR (glcc.segment15 >= nvl(in_from_segments(15),glcc.segment15) and  glcc.segment15 <= nvl(in_to_segments(15),glcc.segment15)))
		AND 	(in_from_segments(16) IS NULL 	OR in_to_segments(16) IS NULL 	OR (glcc.segment16 IS NULL) OR (glcc.segment16 >= nvl(in_from_segments(16),glcc.segment16) and  glcc.segment16 <= nvl(in_to_segments(16),glcc.segment16)))
		AND 	(in_from_segments(17) IS NULL 	OR in_to_segments(17) IS NULL 	OR (glcc.segment17 IS NULL) OR (glcc.segment17 >= nvl(in_from_segments(17),glcc.segment17) and  glcc.segment17 <= nvl(in_to_segments(17),glcc.segment17)))
		AND 	(in_from_segments(18) IS NULL 	OR in_to_segments(18) IS NULL 	OR (glcc.segment18 IS NULL) OR (glcc.segment18 >= nvl(in_from_segments(18),glcc.segment18) and  glcc.segment18 <= nvl(in_to_segments(18),glcc.segment18)))
		AND 	(in_from_segments(19) IS NULL 	OR in_to_segments(19) IS NULL 	OR (glcc.segment19 IS NULL) OR (glcc.segment19 >= nvl(in_from_segments(19),glcc.segment19) and  glcc.segment19 <= nvl(in_to_segments(19),glcc.segment19)))
		AND 	(in_from_segments(20) IS NULL 	OR in_to_segments(20) IS NULL 	OR (glcc.segment20 IS NULL) OR (glcc.segment20 >= nvl(in_from_segments(20),glcc.segment20) and  glcc.segment20 <= nvl(in_to_segments(20),glcc.segment20)))
		AND 	(in_from_segments(21) IS NULL 	OR in_to_segments(21) IS NULL 	OR (glcc.segment21 IS NULL) OR (glcc.segment21 >= nvl(in_from_segments(21),glcc.segment21) and  glcc.segment21 <= nvl(in_to_segments(21),glcc.segment21)))
		AND 	(in_from_segments(22) IS NULL 	OR in_to_segments(22) IS NULL 	OR (glcc.segment22 IS NULL) OR (glcc.segment22 >= nvl(in_from_segments(22),glcc.segment22) and  glcc.segment22 <= nvl(in_to_segments(22),glcc.segment22)))
		AND 	(in_from_segments(23) IS NULL 	OR in_to_segments(23) IS NULL 	OR (glcc.segment23 IS NULL) OR (glcc.segment23 >= nvl(in_from_segments(23),glcc.segment23) and  glcc.segment23 <= nvl(in_to_segments(23),glcc.segment23)))
		AND 	(in_from_segments(24) IS NULL 	OR in_to_segments(24) IS NULL 	OR (glcc.segment24 IS NULL) OR (glcc.segment24 >= nvl(in_from_segments(24),glcc.segment24) and  glcc.segment24 <= nvl(in_to_segments(24),glcc.segment24)))
		AND 	(in_from_segments(25) IS NULL 	OR in_to_segments(25) IS NULL 	OR (glcc.segment25 IS NULL) OR (glcc.segment25 >= nvl(in_from_segments(25),glcc.segment25) and  glcc.segment25 <= nvl(in_to_segments(25),glcc.segment25)))
		AND 	(in_from_segments(26) IS NULL 	OR in_to_segments(26) IS NULL 	OR (glcc.segment26 IS NULL) OR (glcc.segment26 >= nvl(in_from_segments(26),glcc.segment26) and  glcc.segment26 <= nvl(in_to_segments(26),glcc.segment26)))
		AND 	(in_from_segments(27) IS NULL 	OR in_to_segments(27) IS NULL 	OR (glcc.segment27 IS NULL) OR (glcc.segment27 >= nvl(in_from_segments(27),glcc.segment27) and  glcc.segment27 <= nvl(in_to_segments(27),glcc.segment27)))
		AND 	(in_from_segments(28) IS NULL 	OR in_to_segments(28) IS NULL 	OR (glcc.segment28 IS NULL) OR (glcc.segment28 >= nvl(in_from_segments(28),glcc.segment28) and  glcc.segment28 <= nvl(in_to_segments(28),glcc.segment28)))
		AND 	(in_from_segments(29) IS NULL 	OR in_to_segments(29) IS NULL 	OR (glcc.segment29 IS NULL) OR (glcc.segment29 >= nvl(in_from_segments(29),glcc.segment29) and  glcc.segment29 <= nvl(in_to_segments(29),glcc.segment29)))
		AND 	(in_from_segments(30) IS NULL 	OR in_to_segments(30) IS NULL 	OR (glcc.segment30 IS NULL) OR (glcc.segment30 >= nvl(in_from_segments(30),glcc.segment30) and  glcc.segment30 <= nvl(in_to_segments(30),glcc.segment30)));



   PROCEDURE fetch_segment_values
   (
     p_from_segment IN VARCHAR2
   , p_to_Segment IN VARCHAR2
   , p_delimiter IN VARCHAR2
   , x_from_segment IN OUT NOCOPY GMF_SEGMENT_VALUES_TBL
   , x_to_segment IN OUT NOCOPY GMF_SEGMENT_VALUES_TBL
   )
   IS
        l_from_segment          VARCHAR2(2000);
        l_to_segment            VARCHAR2(2000);
        l_from_value            VARCHAR2(150);
        l_to_value              VARCHAR2(150);
   BEGIN
     l_from_segment := p_from_segment;
     l_to_segment := p_to_segment;
     FOR i IN 1 .. 30
     LOOP
         l_from_value := SUBSTR( l_from_segment , 1, INSTR( l_from_segment, p_delimiter, 1 ) - 1 );
         l_to_value := SUBSTR( l_to_segment , 1, INSTR( l_to_segment, p_delimiter, 1 ) - 1 );
         l_from_segment := SUBSTR( l_from_segment, INSTR( l_from_segment, p_delimiter, 1 ) + 1 );
         l_to_segment := SUBSTR( l_to_segment, INSTR( l_to_segment, p_delimiter, 1 ) + 1 );
         x_from_segment(i) := l_from_value;
         x_to_segment(i) := l_to_value;
         l_from_value := null;
         l_to_value := null;
     END LOOP;
   END fetch_segment_values;

   PROCEDURE open_cur_gl_get_balances
   (
     in_set_of_books         in             number
   , in_chart_of_accounts    in             number
   , in_period_year          in             number
   , in_period_num           in             number
   , in_account_type         in             varchar2
   , in_currency_code        in             varchar2
   , start_segments          in             varchar2
   , to_segments             in             varchar2
   , in_actual_flag          in             varchar2
   , in_ytd_ptd              in             number
   )
   IS
        l_segment_delimiter    fnd_id_flex_structures.concatenated_segment_delimiter%TYPE;
        segment_where_clause   VARCHAR2(4000);
        l_from_segments        gmf_segment_values_tbl;
        l_to_segments          gmf_segment_values_tbl;
      	l_application_id	fnd_application.application_id%TYPE;
	      l_chart_of_accounts_id	gl_sets_of_books.chart_of_accounts_id%TYPE;
        l_currency_code gl_sets_of_books.currency_code%TYPE;
        l_set_of_books_id gl_sets_of_books.set_of_books_id%TYPE;

   BEGIN

   /***** Bug 4066174 - Added the new queries below *****/

        -- Newly added Query 1 for Bug 4066174
  SELECT application_id INTO l_application_id
	FROM	 fnd_application
	WHERE	 application_short_name = 'SQLGL'	;

	SELECT currency_code,set_of_books_id, chart_of_accounts_id
       INTO l_currency_code,  l_set_of_books_id, l_chart_of_accounts_id
	FROM gl_sets_of_books
	WHERE set_of_books_id = in_set_of_books;

        SELECT fifstr.concatenated_segment_delimiter
        INTO   l_segment_delimiter
        FROM   fnd_id_flex_structures fifstr
        WHERE 	fifstr.id_flex_code	= 'GL#'
           AND	fifstr.application_id	=  l_application_id
           AND	fifstr.id_flex_num	=  l_chart_of_accounts_id; --in_chart_of_accounts;


          fetch_segment_values (start_segments, to_segments, l_segment_delimiter, l_from_segments, l_to_segments );

          /***** Bug 4066174 - Performance Improvement - Modified the below cursor and its arguments. *****/

          OPEN cur_gl_get_balances (
                                    in_set_of_books
                                  --  , in_chart_of_accounts -- We don't need anymore as we are spliting the query
                                    , in_period_year
                                    , in_period_num
                                    , in_account_type
                                    , in_currency_code
                                    , in_actual_flag
                                    , in_ytd_ptd
                                    , l_from_segments
                                    , l_to_segments
                                    , l_segment_delimiter   -- Bug 4066174 Added
                                    , l_currency_code   -- Bug 4066174 Added
                                    );
   END open_cur_gl_get_balances;

/** Anand thiyagarajan GL Expense Allocation Enhancement 26-04-2004 End **/


   PROCEDURE proc_gl_get_balances(
                in_set_of_books         in out  NOCOPY number,
                in_chart_of_accounts    in out  NOCOPY number,
                in_period_year          in out  NOCOPY number,
                in_period_num           in out  NOCOPY number,
                in_account_type         in out  NOCOPY varchar2,
                in_currency_code        in out  NOCOPY varchar2,
                start_segments          in      varchar2,
                to_segments             in out  NOCOPY varchar2,
                in_actual_flag          in out  NOCOPY varchar2,
                in_ytd_ptd              in      number,
                amount                  out     NOCOPY number,
                segment_delimiter       out     NOCOPY varchar2,
                row_to_fetch            in out  NOCOPY number,
                error_status            out     NOCOPY number) IS

   BEGIN   /* Beginning of procedure proc_gl_get_balances*/

    IF( NOT cur_gl_get_balances%ISOPEN )
    THEN
/** Anand thiyagarajan GL Expense Allocation Enhancement 26-04-2004 Start **/

          open_cur_gl_get_balances
                                (
                                  in_set_of_books
                                , in_chart_of_accounts
                                , in_period_year
                                , in_period_num
                                , in_account_type
                                , in_currency_code
                                , start_segments
                                , to_segments
                                , in_actual_flag
                                , in_ytd_ptd
                                );
/** Anand thiyagarajan GL Expense Allocation Enhancement 26-04-2004 End **/
      END IF;

      FETCH cur_gl_get_balances
      INTO
                in_set_of_books,
                in_chart_of_accounts,
                in_period_year,
                in_period_num,
                in_account_type,
                in_currency_code,
                to_segments,
                in_actual_flag,
                amount,
                segment_delimiter;

      IF( cur_gl_get_balances%NOTFOUND )
      THEN
            error_status := 100;
      END IF;

      IF( ( cur_gl_get_balances%NOTFOUND ) OR ( row_to_fetch = 1 ) )
      THEN
         CLOSE cur_gl_get_balances;
      END IF;

      EXCEPTION

          WHEN others THEN
               error_status := SQLCODE;

   END proc_gl_get_balances;   /* End of procedure proc_gl_get_balances*/

  /** Anand thiyagarajan GL Expense Allocation Enhancement 26-04-2004 End **/

  PROCEDURE initialize(
    in_set_of_books_id	IN NUMBER
  )
  IS

  BEGIN
    /* Anand thiyagarajan GL Expense Allocation Enhancement 26-04-2004 Start */

    RETURN;

    /* Anand thiyagarajan GL Expense Allocation Enhancement 26-04-2004 End */

  END initialize;


END GMF_GL_GET_BALANCES;   /* END GMF_GL_GET_BALANCES*/

/
