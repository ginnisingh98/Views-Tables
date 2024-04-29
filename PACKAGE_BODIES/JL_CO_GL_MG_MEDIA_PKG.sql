--------------------------------------------------------
--  DDL for Package Body JL_CO_GL_MG_MEDIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_GL_MG_MEDIA_PKG" AS
/* $Header: jlcogmgb.pls 120.5.12010000.4 2010/02/24 21:01:01 vspuli ship $ */

  foreign_nit			CONSTANT VARCHAR2(10) := '444444444';
  x_message			VARCHAR2(2000);
  x_trx_count			NUMBER;
  x_bal_count			NUMBER;

  x_nit				jl_co_gl_nits.nit%TYPE;
  x_name			jl_co_gl_nits.name%TYPE;
  x_type			jl_co_gl_nits.type%TYPE;
  x_verifying_digit		jl_co_gl_nits.verifying_digit%TYPE;

  x_literal_code		jl_co_gl_mg_literals.literal_code%TYPE;

  x_reported_flag 		jl_co_gl_mg_lines.reported_flag%TYPE;
  x_first_value  		jl_co_gl_mg_lines.first_reported_value%TYPE;
  x_second_value		jl_co_gl_mg_lines.second_reported_value%TYPE;
  x_mg_header_id		jl_co_gl_mg_headers.mg_header_id%TYPE;

  count_process_flag		NUMBER := 0;
  count_status			NUMBER := 0;

  x_file_handle         	UTL_FILE.FILE_TYPE;

  TYPE get_movement_record IS RECORD	(
  			mg_header_id		jl_co_gl_mg_headers.mg_header_id%TYPE,
  			mg_line_id		jl_co_gl_mg_lines.mg_line_id%TYPE,
                	literal_id         	jl_co_gl_mg_literals.literal_id%TYPE,
           	 	foreign_reported_flag 	jl_co_gl_mg_literals.foreign_reported_flag%TYPE,
           	 	foreign_description 	jl_co_gl_mg_literals.foreign_description%TYPE,
           	 	domestic_reported_flag 	jl_co_gl_mg_literals.domestic_reported_flag%TYPE,
                	reported_value     	jl_co_gl_mg_configs.reported_value%TYPE,
                	nit_id                  jl_co_gl_nits.nit_id%TYPE,
                	config_id          	jl_co_gl_mg_configs.config_id%TYPE,
                	literal_literal_id	jl_co_gl_mg_configs.literal_literal_id%TYPE,
                	range_id           	jl_co_gl_mg_ranges.range_id%TYPE,
      			send_back_flag		jl_co_gl_mg_lines.send_back_flag%TYPE,
      			origin			jl_co_gl_mg_lines.origin%TYPE,
  			amount			jl_co_gl_mg_lines.first_reported_value%TYPE
					);

  get_move_rec			get_movement_record;
  null_get_move_rec		get_movement_record;

  x_error_code 			NUMBER;
  x_error_text 			VARCHAR2(2000);

  x_last_updated_by             NUMBER(15);
  x_last_update_login           NUMBER(15);
  x_request_id                  NUMBER(15);
  x_program_application_id      NUMBER(15);
  x_program_id                  NUMBER(15);
  x_sysdate                     DATE;

  TYPE flat_file_tab_type IS TABLE OF VARCHAR2(2000)
   INDEX BY BINARY_INTEGER;
  tab_flat_file			flat_file_tab_type;
  tab_record_counter		NUMBER := 0;

  LOCATION_ID_DOES_NOT_EXIST	EXCEPTION;
  HEADERS_STATUS_Y		EXCEPTION;



  /***************************************
   Procedure to get standard 'who' columns
   ***************************************/

  PROCEDURE 	find_who_columns IS

  BEGIN

    x_last_updated_by 		:= fnd_global.user_id;
    x_last_update_login 	:= fnd_global.login_id;
    x_request_id 		:= fnd_global.conc_request_id;
    x_program_application_id 	:= fnd_global.prog_appl_id;
    x_program_id  		:= fnd_global.conc_program_id;
    x_sysdate     		:= SYSDATE;

  END find_who_columns;



  /*******************************
   Procedure to write to flat file
   *******************************/

  PROCEDURE     put_line(which          IN      NUMBER,
                         buffer         IN      VARCHAR2) IS

  BEGIN

    fnd_file.put_line(which, buffer);

  EXCEPTION

    WHEN UTL_FILE.INVALID_PATH THEN

      fnd_message.set_name('JL', 'JL_CO_GL_MG_INVALID_PATH');
      x_error_text := SUBSTR(fnd_message.get, 1, 100);
      app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_GL_MG_INVALID_PATH'),
        exception_text => x_error_text);

    WHEN UTL_FILE.INVALID_MODE THEN

      fnd_message.set_name('JL', 'JL_CO_GL_MG_INVALID_MODE');
      x_error_text := SUBSTR(fnd_message.get, 1, 100);
      app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_GL_MG_INVALID_MODE'),
        exception_text => x_error_text);

    WHEN UTL_FILE.WRITE_ERROR THEN

      fnd_message.set_name('JL', 'JL_CO_GL_MG_WRITE_ERROR');
      x_error_text := SUBSTR(fnd_message.get, 1, 100);
      app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_GL_MG_WRITE_ERROR'),
        exception_text => x_error_text);

    WHEN UTL_FILE.INVALID_FILEHANDLE THEN

      fnd_message.set_name('JL', 'JL_CO_GL_MG_INVALID_FILEHANDLE');
      x_error_text := SUBSTR(fnd_message.get, 1, 100);
      app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_GL_MG_INVALID_FILEHANDLE'),
        exception_text => x_error_text);

    WHEN UTL_FILE.INVALID_OPERATION THEN

      fnd_message.set_name('JL', 'JL_CO_GL_MG_INVALID_OPERATION');
      x_error_text := SUBSTR(fnd_message.get, 1, 100);
      app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_GL_MG_INVALID_OPERATION'),
        exception_text => x_error_text);

    WHEN OTHERS THEN

      fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
      x_error_text := SUBSTR(fnd_message.get, 1, 100);
      ROLLBACK;
      app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_FA_GENERAL_ERROR'),
        exception_text => x_error_text);

  END put_line;



  /**********************************************************************
   Procedure to get nit information from jl_co_gl_nits for a given nit_id
   **********************************************************************/

  PROCEDURE 	get_nit_info
		(p_nit_id 	IN jl_co_gl_nits.nit_id%TYPE
		) IS
  BEGIN

    /*****************************************
     Select NIT information from jl_co_gl_nits
     *****************************************/

    SELECT nit,
           name,
	   type,
	   DECODE(verifying_digit, NULL, ' ', verifying_digit)
    INTO   x_nit,
	   x_name,
	   x_type,
	   x_verifying_digit
    FROM   jl_co_gl_nits
    WHERE  nit_id = p_nit_id;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
        'Exception "NO_DATA_FOUND" for selection of nit information from JL_CO_GL_NITS table');
      x_error_text := SUBSTR(fnd_message.get, 1, 100);
      app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('AR', 'GENERIC_MESSAGE'),
        exception_text => x_error_text);

    WHEN OTHERS THEN

      fnd_message.set_name('AR', 'GENERIC_MESSAGE');
      fnd_message.set_token('GENERIC_TEXT',
        'Exception "OTHERS" for selection of nit information from JL_CO_GL_NITS table');
      x_error_text := SUBSTR(fnd_message.get, 1, 100);
      app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('AR', 'GENERIC_MESSAGE'),
        exception_text => x_error_text);

  END get_nit_info;



  /****************************************************************
   Procedure to validate and insert into jl_co_gl_mg_lines table.
   This procedure will be called only when the amount returned from
   cursors trx_cur and bal_cur is more than zero
   ****************************************************************/

  PROCEDURE 	get_movement_insert(in_rec	IN get_movement_record) IS

  BEGIN

    /*******************************************************
     Call the procedure to get nit information for each call
     *******************************************************/

    get_nit_info(in_rec.nit_id);

    /****************************************************************************
     Initialize the x_reported_flag to 'Y', if in_rec.amount is greater than zero
     ****************************************************************************/

    x_reported_flag        	:= 'Y';

    /****************************************
     Report foreign people with NIT 444444444
     ****************************************/

    IF x_type = 'FOREIGN_ENTITY' THEN

       /***********************************************
        Report foreign if literal foreign flag is 'Yes'
        ***********************************************/

       IF in_rec.foreign_reported_flag = 'N' THEN
          x_reported_flag    	:= 'N';
       ELSE
          x_name             	:= in_rec.foreign_description;
       END IF;

    ELSE

       /*************************************************
        Report national if literal national flag is 'Yes'
        *************************************************/

       IF in_rec.domestic_reported_flag = 'N' THEN
          x_reported_flag    	:= 'N';
       END IF;

    END IF;

       IF x_reported_flag = 'Y' THEN

	 /******************************
          First or Second Reported Value
	  ******************************/

         IF in_rec.reported_value = '1' THEN
           x_first_value      := in_rec.amount;
           x_second_value     := 0;
         ELSE
           x_first_value      := 0;
           x_second_value     := in_rec.amount;
         END IF;

	 /****************************************
          Set reported_flag to 'N' if x_nit is '0'
	  ****************************************/

	 IF x_nit = '0' THEN
	    x_reported_flag := 'N';
	 END IF;

	 /**********************************
          Insert rows into jl_co_gl_mg_lines
	  **********************************/

         BEGIN

           INSERT INTO jl_co_gl_mg_lines
               (mg_line_id,
                mg_header_id,
                literal_id,
                reported_value,
                reported_flag,
                send_back_flag,
                origin,
                nit_id,
                third_party_name,
                first_reported_value,
                second_reported_value,
                config_id,
                literal_literal_id,
                range_id,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
               )
           VALUES
               (in_rec.mg_line_id,              /*mg_line_id*/
                in_rec.mg_header_id,            /*mg_header_id*/
                in_rec.literal_id,         	/*literal_id*/
                in_rec.reported_value,     	/*reported_value*/
                x_reported_flag,                /*reported_flag*/
                in_rec.send_back_flag,          /*send_back_flag*/
                in_rec.origin,          	/*origin*/
                in_rec.nit_id,                  /*nit_id*/
                x_name,                         /*third_party_name*/
                x_first_value,                  /*first_reported_value*/
                x_second_value,                 /*second_reported_value*/
                in_rec.config_id,          	/*config_id*/
                in_rec.literal_literal_id, 	/*literal_literal_id*/
                in_rec.range_id,           	/*range_id*/
                x_last_updated_by,              /*created_by*/
                x_sysdate,                      /*creation_date*/
                x_last_updated_by,              /*last_updated_by*/
                x_sysdate,                      /*last_update_date*/
                x_last_update_login             /*last_update_login*/
               );

         EXCEPTION

           WHEN OTHERS THEN

             fnd_message.set_name('AR', 'GENERIC_MESSAGE');
             fnd_message.set_token('GENERIC_TEXT',
               'Exception "OTHERS" while inserting into jl_co_gl_mg_lines table');
      	     x_error_text := SUBSTR(fnd_message.get, 1, 100);
             ROLLBACK;
             app_exception.raise_exception (exception_type => 'APP',
             	exception_code =>
             		jl_zz_fa_utilities_pkg.get_app_errnum('AR', 'GENERIC_MESSAGE'),
             	exception_text => x_error_text);

         END;

    END IF;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

         x_error_code := SQLCODE;
         x_error_text := SUBSTR(SQLERRM, 1, 200);
    	 RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

    WHEN OTHERS THEN

         x_error_code := SQLCODE;
         x_error_text := SUBSTR(SQLERRM, 1, 200);
    	 RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

  END get_movement_insert;



  /*********************************************************************
   PROCEDURE
     get_movement

   DESCRIPTION
     Use this procedure to insert transactions and balances from nit
     tables into jl_co_gl_mg_headers and jl_co_gl_mg_lines tables, for a
     set of literal/sub-literal, reported_value (called report_group)
     for a given range of accounts from magnetic media set-up tables

   PURPOSE:
     Oracle Applications Rel 11.0

   PARAMETERS:
     p_set_of_books_id
     p_reported_year
     p_period_start
     p_period_end
     p_literal_start
     p_literal_end

   HISTORY:
     23-DEC-1998   Raja Reddy Kappera    Created

   **********************************************************************/


  PROCEDURE 	get_movement
		(ERRBUF			OUT NOCOPY	VARCHAR2,
		 RETCODE		OUT NOCOPY	VARCHAR2,
 		 p_set_of_books_id 	IN 	gl_sets_of_books.set_of_books_id%TYPE,
 		 p_reported_year 	IN 	jl_co_gl_mg_literals.reported_year%TYPE,
                 p_period_start 	IN 	gl_periods.period_num%TYPE,
		 p_period_end		IN	gl_periods.period_num%TYPE,
		 p_literal_start	IN	jl_co_gl_mg_literals.literal_code%TYPE,
		 p_literal_end		IN	jl_co_gl_mg_literals.literal_code%TYPE
		) IS

    x_mg_hdr_count		NUMBER;

    /********************************************************************
     Cursor to select rows from jl_co_gl_mg_literals, jl_co_gl_mg_configs
     and jl_co_gl_mg_ranges (accounting ranges) tables
     ********************************************************************/

    CURSOR literal_cur IS

	SELECT 	mgl.literal_id 		literal_id,
		mgl.foreign_reported_flag 	foreign_reported_flag,
		mgl.domestic_reported_flag 	domestic_reported_flag,
		mgl.foreign_description 	foreign_description,
		mgc.config_id 		config_id,
		mgc.reported_value 	reported_value,
		mgc.movement_type 	movement_type,
		mgc.threshold_value 	rep_threshold_value,
		mgc.literal_literal_id	literal_literal_id,
	        mgr.range_id		range_id
	FROM	jl_co_gl_mg_ranges 	mgr,
		jl_co_gl_mg_configs 	mgc,
		jl_co_gl_mg_literals 	mgl
	WHERE 	mgr.config_id 		= mgc.config_id
	AND	mgc.literal_id 		= mgl.literal_id
	AND	mgl.set_of_books_id 	= p_set_of_books_id
	AND	mgl.reported_year 	= p_reported_year
	AND	mgl.literal_code BETWEEN p_literal_start AND p_literal_end
	ORDER BY mgc.movement_type,
		mgl.literal_id,
		mgc.config_id,
		mgr.range_id;

    /*************************************************
     Cursor for selecting rows from jl_co_gl_trx table
     *************************************************/

    CURSOR trx_cur (x_movement_type	jl_co_gl_mg_configs.movement_type%TYPE,
		    x_range_id		jl_co_gl_mg_ranges.range_id%TYPE) IS

	SELECT	t.nit_id nit_id,
		DECODE(x_movement_type,
		 	'1', SUM(NVL(t.accounted_dr, 0)),
			'2', SUM(NVL(t.accounted_cr, 0)),
			'3', SUM(NVL(t.accounted_dr, 0)) - SUM(NVL(t.accounted_cr, 0)),
			'4', SUM(NVL(t.accounted_cr, 0)) - SUM(NVL(t.accounted_dr, 0)),
			0
		      ) amount
	FROM	jl_co_gl_trx 		t,
-- bug 9384107
		gl_sets_of_books 	sob1
	WHERE 	t.set_of_books_id	= sob1.set_of_books_id
	AND     exists (SELECT  /*+ NO_UNNEST */  'X'
                          FROM  JL_CO_GL_NITS NIT
                         WHERE  NIT.NIT_ID = T.NIT_ID)
-- bug 9384107
	AND	sob1.set_of_books_id	= p_set_of_books_id
	AND	t.period_name IN (SELECT  p.period_name
				  FROM    gl_periods        	p,
        			  	  gl_period_types       pt,
        				  gl_period_sets        ps,
        				  gl_sets_of_books      sob2
				  WHERE   p.period_year         = p_reported_year
				  AND     p.period_num 	BETWEEN p_period_start
                                		  	AND    	p_period_end
				  AND     p.adjustment_period_flag = 'N'
				  AND     p.period_type         = pt.period_type
				  AND     pt.period_type        = sob2.accounted_period_type
				  AND     p.period_set_name     = ps.period_set_name
				  AND     ps.period_set_name    = sob2.period_set_name
				  AND     sob2.set_of_books_id  = p_set_of_books_id
				 )
	--AND	t.code_combination_id IN
	  AND exists
		(SELECT 1
		 FROM   gl_code_combinations 	cc,
                        jl_co_gl_mg_ranges      r
                 WHERE  cc.code_combination_id = t.code_combination_id
		 AND	r.range_id      	= x_range_id
                 AND    cc.chart_of_accounts_id = sob1.chart_of_accounts_id
                 AND    NVL(cc.segment1,0) BETWEEN NVL(r.segment1_low,0) AND NVL(r.segment1_high,0)
                 AND    NVL(cc.segment2,0) BETWEEN NVL(r.segment2_low,0) AND NVL(r.segment2_high,0)
                 AND    NVL(cc.segment3,0) BETWEEN NVL(r.segment3_low,0) AND NVL(r.segment3_high,0)
                 AND    NVL(cc.segment4,0) BETWEEN NVL(r.segment4_low,0) AND NVL(r.segment4_high,0)
                 AND    NVL(cc.segment5,0) BETWEEN NVL(r.segment5_low,0) AND NVL(r.segment5_high,0)
                 AND    NVL(cc.segment6,0) BETWEEN NVL(r.segment6_low,0) AND NVL(r.segment6_high,0)
                 AND    NVL(cc.segment7,0) BETWEEN NVL(r.segment7_low,0) AND NVL(r.segment7_high,0)
                 AND    NVL(cc.segment8,0) BETWEEN NVL(r.segment8_low,0) AND NVL(r.segment8_high,0)
                 AND    NVL(cc.segment9,0) BETWEEN NVL(r.segment9_low,0) AND NVL(r.segment9_high,0)
                 AND    NVL(cc.segment10,0) BETWEEN NVL(r.segment10_low,0) AND NVL(r.segment10_high,0)
                 AND    NVL(cc.segment11,0) BETWEEN NVL(r.segment11_low,0) AND NVL(r.segment11_high,0)
                 AND    NVL(cc.segment12,0) BETWEEN NVL(r.segment12_low,0) AND NVL(r.segment12_high,0)
                 AND    NVL(cc.segment13,0) BETWEEN NVL(r.segment13_low,0) AND NVL(r.segment13_high,0)
                 AND    NVL(cc.segment14,0) BETWEEN NVL(r.segment14_low,0) AND NVL(r.segment14_high,0)
                 AND    NVL(cc.segment15,0) BETWEEN NVL(r.segment15_low,0) AND NVL(r.segment15_high,0)
                 AND    NVL(cc.segment16,0) BETWEEN NVL(r.segment16_low,0) AND NVL(r.segment16_high,0)
                 AND    NVL(cc.segment17,0) BETWEEN NVL(r.segment17_low,0) AND NVL(r.segment17_high,0)
                 AND    NVL(cc.segment18,0) BETWEEN NVL(r.segment18_low,0) AND NVL(r.segment18_high,0)
                 AND    NVL(cc.segment19,0) BETWEEN NVL(r.segment19_low,0) AND NVL(r.segment19_high,0)
                 AND    NVL(cc.segment20,0) BETWEEN NVL(r.segment20_low,0) AND NVL(r.segment20_high,0)
                 AND    NVL(cc.segment21,0) BETWEEN NVL(r.segment21_low,0) AND NVL(r.segment21_high,0)
                 AND    NVL(cc.segment22,0) BETWEEN NVL(r.segment22_low,0) AND NVL(r.segment22_high,0)
                 AND    NVL(cc.segment23,0) BETWEEN NVL(r.segment23_low,0) AND NVL(r.segment23_high,0)
                 AND    NVL(cc.segment24,0) BETWEEN NVL(r.segment24_low,0) AND NVL(r.segment24_high,0)
                 AND    NVL(cc.segment25,0) BETWEEN NVL(r.segment25_low,0) AND NVL(r.segment25_high,0)
                 AND    NVL(cc.segment26,0) BETWEEN NVL(r.segment26_low,0) AND NVL(r.segment26_high,0)
                 AND    NVL(cc.segment27,0) BETWEEN NVL(r.segment27_low,0) AND NVL(r.segment27_high,0)
                 AND    NVL(cc.segment28,0) BETWEEN NVL(r.segment28_low,0) AND NVL(r.segment28_high,0)
                 AND    NVL(cc.segment29,0) BETWEEN NVL(r.segment29_low,0) AND NVL(r.segment29_high,0)
                 AND    NVL(cc.segment30,0) BETWEEN NVL(r.segment30_low,0) AND NVL(r.segment30_high,0)
		)
	GROUP BY t.nit_id;

    /*****************************************************
     Cursor for selecting rows from jl_co_gl_balance table
     *****************************************************/

    -- Bug 4018828 - Comment out the join to period_name in the subquery retrieving
    -- the max period num. This ensures that only the balances for last active
	-- period for which there exists transactions are taken into account
    CURSOR bal_cur (x_movement_type       jl_co_gl_mg_configs.movement_type%TYPE,
                    x_range_id            jl_co_gl_mg_ranges.range_id%TYPE) IS

	SELECT  b.nit_id 		nit_id,
        	DECODE(x_movement_type,
               		'5', SUM(NVL(b.begin_balance_dr, 0)) - SUM(NVL(b.begin_balance_cr, 0)) +
                    	     SUM(NVL(b.period_net_dr, 0)) - SUM(NVL(b.period_net_cr, 0)),
               		'6', SUM(NVL(b.begin_balance_cr, 0)) - SUM(NVL(b.begin_balance_dr, 0)) +
                     	     SUM(NVL(b.period_net_cr, 0)) - SUM(NVL(b.period_net_dr, 0)),
			0
                      )  		amount
        FROM    jl_co_gl_balances       b,
                gl_sets_of_books        sob1
        WHERE   b.set_of_books_id       = sob1.set_of_books_id
        AND     b.currency_code         = sob1.currency_code
        AND     sob1.set_of_books_id    = p_set_of_books_id
        AND     b.period_num            =
				(SELECT MAX(b1.period_num)
                                 FROM   jl_co_gl_balances       b1
                                 WHERE  b.set_of_books_id 	= b1.set_of_books_id
                                 AND    b.code_combination_id 	= b1.code_combination_id
                                 AND    b.nit_id 		= b1.nit_id
                                 --AND    b.period_name 		= b1.period_name
                                 AND    b1.period_num 		<= p_period_end
                                 AND    b1.period_year          = p_reported_year
                                )
        AND     b.period_name	IN
                                (SELECT  p.period_name
                                 FROM    gl_periods            p,
                                         gl_period_types       pt,
                                         gl_period_sets        ps,
                                         gl_sets_of_books      sob2
                                 WHERE   p.period_year         = p_reported_year
                                 AND     p.period_num          BETWEEN p_period_start
                                                               AND     p_period_end
                                 AND     p.adjustment_period_flag = 'N'
                                 AND     p.period_type         = pt.period_type
                                 AND     pt.period_type        = sob2.accounted_period_type
                                 AND     p.period_set_name     = ps.period_set_name
                                 AND     ps.period_set_name    = sob2.period_set_name
                                 AND     sob2.set_of_books_id  = p_set_of_books_id
                                )
        AND     b.code_combination_id IN
                (SELECT code_combination_id
                 FROM   gl_code_combinations    cc,
                        jl_co_gl_mg_ranges      r,
                        gl_sets_of_books        sob3
                 WHERE  r.range_id      	= x_range_id
                 AND    cc.chart_of_accounts_id = sob3.chart_of_accounts_id
                 AND    sob3.set_of_books_id    = p_set_of_books_id
                 AND    NVL(cc.segment1,0) BETWEEN NVL(r.segment1_low,0) AND NVL(r.segment1_high,0)
                 AND    NVL(cc.segment2,0) BETWEEN NVL(r.segment2_low,0) AND NVL(r.segment2_high,0)
                 AND    NVL(cc.segment3,0) BETWEEN NVL(r.segment3_low,0) AND NVL(r.segment3_high,0)
                 AND    NVL(cc.segment4,0) BETWEEN NVL(r.segment4_low,0) AND NVL(r.segment4_high,0)
                 AND    NVL(cc.segment5,0) BETWEEN NVL(r.segment5_low,0) AND NVL(r.segment5_high,0)
                 AND    NVL(cc.segment6,0) BETWEEN NVL(r.segment6_low,0) AND NVL(r.segment6_high,0)
                 AND    NVL(cc.segment7,0) BETWEEN NVL(r.segment7_low,0) AND NVL(r.segment7_high,0)
                 AND    NVL(cc.segment8,0) BETWEEN NVL(r.segment8_low,0) AND NVL(r.segment8_high,0)
                 AND    NVL(cc.segment9,0) BETWEEN NVL(r.segment9_low,0) AND NVL(r.segment9_high,0)
                 AND    NVL(cc.segment10,0) BETWEEN NVL(r.segment10_low,0) AND NVL(r.segment10_high,0)
                 AND    NVL(cc.segment11,0) BETWEEN NVL(r.segment11_low,0) AND NVL(r.segment11_high,0)
                 AND    NVL(cc.segment12,0) BETWEEN NVL(r.segment12_low,0) AND NVL(r.segment12_high,0)
                 AND    NVL(cc.segment13,0) BETWEEN NVL(r.segment13_low,0) AND NVL(r.segment13_high,0)
                 AND    NVL(cc.segment14,0) BETWEEN NVL(r.segment14_low,0) AND NVL(r.segment14_high,0)
                 AND    NVL(cc.segment15,0) BETWEEN NVL(r.segment15_low,0) AND NVL(r.segment15_high,0)
                 AND    NVL(cc.segment16,0) BETWEEN NVL(r.segment16_low,0) AND NVL(r.segment16_high,0)
                 AND    NVL(cc.segment17,0) BETWEEN NVL(r.segment17_low,0) AND NVL(r.segment17_high,0)
                 AND    NVL(cc.segment18,0) BETWEEN NVL(r.segment18_low,0) AND NVL(r.segment18_high,0)
                 AND    NVL(cc.segment19,0) BETWEEN NVL(r.segment19_low,0) AND NVL(r.segment19_high,0)
                 AND    NVL(cc.segment20,0) BETWEEN NVL(r.segment20_low,0) AND NVL(r.segment20_high,0)
                 AND    NVL(cc.segment21,0) BETWEEN NVL(r.segment21_low,0) AND NVL(r.segment21_high,0)
                 AND    NVL(cc.segment22,0) BETWEEN NVL(r.segment22_low,0) AND NVL(r.segment22_high,0)
                 AND    NVL(cc.segment23,0) BETWEEN NVL(r.segment23_low,0) AND NVL(r.segment23_high,0)
                 AND    NVL(cc.segment24,0) BETWEEN NVL(r.segment24_low,0) AND NVL(r.segment24_high,0)
                 AND    NVL(cc.segment25,0) BETWEEN NVL(r.segment25_low,0) AND NVL(r.segment25_high,0)
                 AND    NVL(cc.segment26,0) BETWEEN NVL(r.segment26_low,0) AND NVL(r.segment26_high,0)
                 AND    NVL(cc.segment27,0) BETWEEN NVL(r.segment27_low,0) AND NVL(r.segment27_high,0)
                 AND    NVL(cc.segment28,0) BETWEEN NVL(r.segment28_low,0) AND NVL(r.segment28_high,0)
                 AND    NVL(cc.segment29,0) BETWEEN NVL(r.segment29_low,0) AND NVL(r.segment29_high,0)
                 AND    NVL(cc.segment30,0) BETWEEN NVL(r.segment30_low,0) AND NVL(r.segment30_high,0)
                )
        GROUP BY b.nit_id;


  BEGIN <<get_movement>>

    x_trx_count	:= 0;
    x_bal_count	:= 0;

    fnd_message.set_name('FND', 'CONC-ARGUMENTS');
    fnd_file.put_line( fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log, '----------------------------------------');
    fnd_message.set_name('JL', 'JL_CO_GL_MG_SET_OF_BOOKS_ID');
    fnd_message.set_token('SET_OF_BOOKS_ID', p_set_of_books_id);
    put_line( fnd_file.log, fnd_message.get);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_REPORTED_YEAR');
    fnd_message.set_token('REPORTED_YEAR', p_reported_year);
    put_line( fnd_file.log, fnd_message.get);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_PERIOD_START');
    fnd_message.set_token('PERIOD_START', p_period_start);
    put_line( fnd_file.log, fnd_message.get);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_PERIOD_END');
    fnd_message.set_token('PERIOD_END', p_period_end);
    put_line( fnd_file.log, fnd_message.get);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_LITERAL_START');
    fnd_message.set_token('LITERAL_START', p_literal_start);
    put_line( fnd_file.log, fnd_message.get);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_LITERAL_END');
    fnd_message.set_token('LITERAL_END', p_literal_end);
    put_line( fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log, '----------------------------------------');


    /******************************************************
     Check for JL_CO_GL_MG_HEADERS.STATUS = 'Y'. If any row
     exists with status of 'Y' then give a message to USER
     and exist the procedure
     ******************************************************/

    BEGIN

      SELECT count(*)
      INTO   count_status
      FROM   jl_co_gl_mg_headers
      WHERE  set_of_books_id = p_set_of_books_id
      AND    reported_year   = p_reported_year
      AND    status 	     = 'Y';

    EXCEPTION

      WHEN OTHERS THEN
	NULL;

    END;

    IF count_status > 0 THEN

      RAISE HEADERS_STATUS_Y;

    END IF;


    /****************************************
     Delete rows from jl_co_gl_mg_lines and
     jl_co_gl_mg_headers for given parameters
     ****************************************/

    BEGIN

      DELETE FROM  jl_co_gl_mg_lines
	     WHERE mg_header_id IN (SELECT mg_header_id
			            FROM   jl_co_gl_mg_headers
				    WHERE  set_of_books_id 	= p_set_of_books_id
				    AND	   reported_year	= p_reported_year
			         )
	     AND   literal_id IN (SELECT literal_id
				  FROM 	 jl_co_gl_mg_literals
				  WHERE  set_of_books_id = p_set_of_books_id
				  AND	 reported_year   = p_reported_year
				  AND	 literal_code BETWEEN p_literal_start
						      AND     p_literal_end
			         )
	     AND   origin = 'A';

      IF SQL%FOUND THEN
         COMMIT;
         fnd_message.set_name('JL', 'JL_CO_GL_MG_DELETE');
         fnd_message.set_token('NUMBER', TO_CHAR(SQL%ROWCOUNT));
         fnd_message.set_token('TABLE', 'JL_CO_GL_MG_LINES');
         put_line( fnd_file.log, fnd_message.get);
      ELSE
	 NULL;
         fnd_message.set_name('JL', 'JL_CO_GL_MG_NOT_DELETE');
         fnd_message.set_token('TABLE', 'JL_CO_GL_MG_LINES');
         put_line( fnd_file.log, fnd_message.get);
      END IF;

    EXCEPTION

      WHEN OTHERS THEN

        x_error_code := SQLCODE;
        x_error_text := SUBSTR(SQLERRM,1,200);
    	RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

    END;

    BEGIN

      DELETE FROM  jl_co_gl_mg_headers
	     WHERE reported_year	= p_reported_year
             AND   set_of_books_id 	= p_set_of_books_id
	     AND   mg_header_id NOT IN (SELECT 	mg_header_id
				        FROM	jl_co_gl_mg_lines
				       );

      IF SQL%FOUND THEN
         COMMIT;
         fnd_message.set_name('JL', 'JL_CO_GL_MG_DELETE');
         fnd_message.set_token('NUMBER', TO_CHAR(SQL%ROWCOUNT));
         fnd_message.set_token('TABLE', 'JL_CO_GL_MG_HEADERS');
         put_line( fnd_file.log, fnd_message.get);
      ELSE
	 NULL;
         fnd_message.set_name('JL', 'JL_CO_GL_MG_NOT_DELETE');
         fnd_message.set_token('TABLE', 'JL_CO_GL_MG_HEADERS');
         put_line( fnd_file.log, fnd_message.get);
      END IF;

    EXCEPTION

      WHEN OTHERS THEN

        x_error_code := SQLCODE;
        x_error_text := SUBSTR(SQLERRM,1,200);
    	RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

    END;

    /***********************
     Find who_columns values
     ***********************/

    find_who_columns;

    /******************************************************************
     Insert a row for the given parameters in jl_co_gl_mg_headers table
     ******************************************************************/

    BEGIN

      BEGIN

        SELECT jl_co_gl_mg_headers_s.NEXTVAL
        INTO   x_mg_header_id
        FROM   SYS.DUAL;

      END;

      INSERT INTO jl_co_gl_mg_headers
	  (mg_header_id,
	   set_of_books_id,
	   reported_year,
	   status,
   	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login
	  )
      VALUES
	  (x_mg_header_id,		/*mg_header_id*/
	   p_set_of_books_id,		/*set_of_books_id*/
	   p_reported_year,		/*reported_year*/
	   'N',				/*status*/
   	   x_last_updated_by,		/*created_by*/
	   x_sysdate,			/*creation_date*/
	   x_last_updated_by,		/*last_updated_by*/
	   x_sysdate,			/*last_update_date*/
	   x_last_update_login		/*last_update_login*/
	  );

      COMMIT;

        fnd_message.set_name('JL', 'JL_CO_GL_MG_INSERT');
        fnd_message.set_token('NUMBER', '1');
        fnd_message.set_token('TYPE', ' ');
        fnd_message.set_token('TABLE', 'JL_CO_GL_MG_HEADERS');
        put_line( fnd_file.log, fnd_message.get);

    EXCEPTION

      WHEN OTHERS THEN

        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
          'Exception "OTHERS" while inserting into jl_co_gl_mg_headers table');
      	x_error_text := SUBSTR(fnd_message.get, 1, 100);
        ROLLBACK;
        app_exception.raise_exception (exception_type => 'APP',
        	exception_code =>
        		jl_zz_fa_utilities_pkg.get_app_errnum('AR', 'GENERIC_MESSAGE'),
        	exception_text => x_error_text);

    END;


    FOR literal_rec IN literal_cur LOOP

      get_move_rec.mg_header_id		:= x_mg_header_id;
      get_move_rec.literal_id		:= literal_rec.literal_id;
      get_move_rec.foreign_reported_flag := literal_rec.foreign_reported_flag;
      get_move_rec.foreign_description 	:= literal_rec.foreign_description;
      get_move_rec.domestic_reported_flag := literal_rec.domestic_reported_flag;
      get_move_rec.reported_value	:= literal_rec.reported_value;
      get_move_rec.config_id		:= literal_rec.config_id;
      get_move_rec.literal_literal_id	:= literal_rec.literal_literal_id;
      get_move_rec.range_id		:= literal_rec.range_id;
      get_move_rec.send_back_flag	:= 'N';
      get_move_rec.origin		:= 'A';

      /****************************************************************************
       Select nit_id and sum(amount) from jl_co_gl_balances and jl_co_gl_trx tables
       ****************************************************************************/

      IF literal_rec.movement_type IN ('1', '2', '3', '4') THEN

	FOR trx_rec IN trx_cur (literal_rec.movement_type,
				literal_rec.range_id) 	LOOP

          IF trx_rec.amount > 0 THEN

            get_move_rec.nit_id		:= trx_rec.nit_id;
            get_move_rec.amount		:= trx_rec.amount;

            SELECT jl_co_gl_mg_lines_s.NEXTVAL
            INTO   get_move_rec.mg_line_id
            FROM   SYS.DUAL;

  	    get_movement_insert (get_move_rec);

	    x_trx_count			:= x_trx_count + 1;

	    /*get_move_rec		:= null_get_move_rec;*/

	  END IF;

        END LOOP;

      ELSE

	FOR bal_rec IN bal_cur (literal_rec.movement_type,
				literal_rec.range_id)   LOOP

          IF bal_rec.amount > 0 THEN

            get_move_rec.nit_id		:= bal_rec.nit_id;
            get_move_rec.amount		:= bal_rec.amount;

            SELECT jl_co_gl_mg_lines_s.NEXTVAL
            INTO   get_move_rec.mg_line_id
            FROM   SYS.DUAL;

  	    get_movement_insert (get_move_rec);

	    x_bal_count			:= x_bal_count + 1;

	    /*get_move_rec		:= null_get_move_rec;*/

	  END IF;

        END LOOP;

      END IF;

    END LOOP;

    IF x_trx_count > 0 THEN

      fnd_message.set_name('JL', 'JL_CO_GL_MG_INSERT');
      fnd_message.set_token('NUMBER', TO_CHAR(x_trx_count));
      fnd_message.set_token('TYPE', 'NIT_TRANSACTIONS');
      fnd_message.set_token('TABLE', 'JL_CO_GL_MG_LINES');
      put_line( fnd_file.log, fnd_message.get);

    END IF;

    IF x_bal_count > 0 THEN

      fnd_message.set_name('JL', 'JL_CO_GL_MG_INSERT');
      fnd_message.set_token('NUMBER', TO_CHAR(x_bal_count));
      fnd_message.set_token('TYPE', 'NIT_BALANCES');
      fnd_message.set_token('TABLE', 'JL_CO_GL_MG_LINES');
      put_line( fnd_file.log, fnd_message.get);

    END IF;

    IF x_trx_count = 0 AND x_bal_count = 0 THEN
      DELETE FROM  jl_co_gl_mg_headers
	     WHERE reported_year	= p_reported_year
             AND   set_of_books_id 	= p_set_of_books_id
	     AND   mg_header_id NOT IN (SELECT 	mg_header_id
				        FROM	jl_co_gl_mg_lines
				       );
      COMMIT;

    END IF;

    /**************************************************************************
     Update JL_CO_GL_MG_LITERALS.PROCESSED_FLAG to 'M' for the given Parameters
     **************************************************************************/

    UPDATE	jl_co_gl_mg_literals
    SET		processed_flag = 'M'
    WHERE	set_of_books_id	= p_set_of_books_id
    AND		reported_year	= p_reported_year
    AND		literal_code BETWEEN p_literal_start AND p_literal_end;

    IF SQL%FOUND THEN
       COMMIT;
    END IF;

  EXCEPTION

    WHEN HEADERS_STATUS_Y THEN

    x_message := '----***************** W A R N I N G **********************----';
    put_line( fnd_file.log, x_message);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_FILE_SENT');
    fnd_message.set_token('YEAR', p_reported_year);
    x_error_text := fnd_message.get;
    put_line( fnd_file.log, x_error_text);
    x_error_text := SUBSTR(x_error_text, 1, 100);
    x_message := '----******************************************************----';
    put_line( fnd_file.log, x_message);
    app_exception.raise_exception (exception_type => 'APP',
       	exception_code =>
       		jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_GL_MG_FILE_SENT'),
       	exception_text => x_error_text);

    WHEN OTHERS THEN

      fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
      fnd_file.put_line( fnd_file.log, fnd_message.get);
      x_error_code := SQLCODE;
      x_error_text := SUBSTR(SQLERRM,1,200);
      ROLLBACK;
      RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

  END get_movement;




  /*******************************************************************
   PROCEDURE
     threshold

   DESCRIPTION
     Use this procedure to apply Parent Report Grouping Threshold,
     Literal Threshold and Child Report Grouping Threshold to the rows
     in jl_co_gl_mg_lines table.

   PURPOSE:
     Oracle Applications Rel 11.0

   PARAMETERS:
     p_set_of_books_id
     p_reported_year
     p_literal_start
     p_literal_end

   HISTORY:
     23-DEC-1998   Raja Reddy Kappera    Created

   *******************************************************************/


  PROCEDURE 	threshold
		(ERRBUF			OUT NOCOPY	VARCHAR2,
		 RETCODE		OUT NOCOPY	VARCHAR2,
 		 p_set_of_books_id 	IN 	gl_sets_of_books.set_of_books_id%TYPE,
 		 p_reported_year 	IN 	jl_co_gl_mg_literals.reported_year%TYPE,
		 p_literal_start	IN	jl_co_gl_mg_literals.literal_code%TYPE,
		 p_literal_end		IN	jl_co_gl_mg_literals.literal_code%TYPE
		) IS

    x_foreign_reported_flag		jl_co_gl_mg_literals.foreign_reported_flag%TYPE;
    x_domestic_reported_flag		jl_co_gl_mg_literals.domestic_reported_flag%TYPE;
    x_threshold_foreign_flag		jl_co_gl_mg_literals.threshold_foreign_flag%TYPE;
    x_threshold_domestic_flag		jl_co_gl_mg_literals.threshold_domestic_flag%TYPE;
    x_lit_threshold_value		jl_co_gl_mg_literals.threshold_value%TYPE;
    x_config_id_parent			jl_co_gl_mg_configs.config_id_parent%TYPE;

    /************************************
     Parent Report Group Threshold Cursor
     ************************************/

    CURSOR rg_threshold_cur IS

      SELECT 	mgl.mg_header_id		mg_header_id,
		mgl.literal_id			literal_id,
		mgl.reported_value		reported_value,
		mgl.reported_flag		reported_flag,
		mgl.nit_id			nit_id,
		mgl.third_party_name		third_party_name,
		mgl.config_id			config_id,
		c.threshold_value               threshold_value,
		SUM(mgl.first_reported_value) 	first_reported_value,
		SUM(mgl.second_reported_value)	second_reported_value
      FROM	jl_co_gl_mg_configs		c,
		jl_co_gl_mg_literals		l,
		jl_co_gl_mg_lines		mgl,
		jl_co_gl_mg_headers		mgh
      WHERE	mgl.mg_header_id	= mgh.mg_header_id
      AND	mgh.reported_year	= p_reported_year
      AND	mgh.set_of_books_id	= p_set_of_books_id
      AND	mgl.literal_id		= l.literal_id
      AND	l.literal_code BETWEEN p_literal_start AND p_literal_end
      AND	mgl.config_id		= c.config_id
      AND	c.config_id_parent IS NULL
      GROUP BY  mgl.mg_header_id,
		mgl.literal_id,
		mgl.reported_value,
		mgl.reported_flag,
		mgl.nit_id,
		mgl.third_party_name,
		mgl.config_id,
		c.threshold_value
      ORDER BY  mgl.mg_header_id,
		mgl.literal_id,
		mgl.reported_value,
		mgl.reported_flag,
		mgl.nit_id,
		mgl.third_party_name,
		mgl.config_id,
		c.threshold_value;

    /************************
     Literal Threshold Cursor
     ************************/

    CURSOR lit_threshold_cur IS

      SELECT 	mgl.mg_header_id		mg_header_id,
		mgl.nit_id			nit_id,
		mgl.literal_literal_id		literal_literal_id,
                l.threshold_value               threshold_value,
                l.threshold_foreign_flag        threshold_foreign_flag,
                l.threshold_domestic_flag       threshold_domestic_flag,
		SUM(mgl.first_reported_value) 	first_reported_value,
		SUM(mgl.second_reported_value)	second_reported_value
      FROM	jl_co_gl_mg_literals		l,
		jl_co_gl_mg_lines		mgl,
		jl_co_gl_mg_headers		mgh
      WHERE	mgl.mg_header_id	= mgh.mg_header_id
      AND	mgh.reported_year	= p_reported_year
      AND	mgh.set_of_books_id	= p_set_of_books_id
      AND	mgl.literal_literal_id	= l.literal_id
      AND	l.literal_code BETWEEN p_literal_start AND p_literal_end
      GROUP BY  mgl.mg_header_id,
		mgl.nit_id,
		mgl.literal_literal_id,
                l.threshold_value,
                l.threshold_foreign_flag,
                l.threshold_domestic_flag
      ORDER BY  mgl.mg_header_id,
		mgl.nit_id,
		mgl.literal_literal_id,
                l.threshold_value,
                l.threshold_foreign_flag,
                l.threshold_domestic_flag;

    /***********************************
     Child Report Group Threshold Cursor
     ***********************************/

    CURSOR child_threshold_cur IS

      SELECT 	mgl.mg_header_id		mg_header_id,
		mgl.config_id			config_id,
		mgl.nit_id			nit_id
      FROM	jl_co_gl_mg_configs		c,
      		jl_co_gl_mg_literals		l,
		jl_co_gl_mg_lines		mgl,
		jl_co_gl_mg_headers		mgh
      WHERE	mgl.mg_header_id	= mgh.mg_header_id
      AND	mgh.reported_year	= p_reported_year
      AND	mgh.set_of_books_id	= p_set_of_books_id
      AND	mgl.config_id		= c.config_id
      AND	c.literal_id		= l.literal_id
      AND	c.config_id_parent IS NULL
      AND	l.literal_code BETWEEN p_literal_start AND p_literal_end
      AND	mgl.reported_flag	= 'N'
      GROUP BY  mgl.mg_header_id,
		mgl.config_id,
		mgl.nit_id
      ORDER BY  mgl.mg_header_id,
		mgl.config_id,
		mgl.nit_id;


  BEGIN <<threshold>>

    fnd_message.set_name('FND', 'CONC-ARGUMENTS');
    fnd_file.put_line( fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log, '----------------------------------------');
    fnd_message.set_name('JL', 'JL_CO_GL_MG_SET_OF_BOOKS_ID');
    fnd_message.set_token('SET_OF_BOOKS_ID', p_set_of_books_id);
    put_line( fnd_file.log, fnd_message.get);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_REPORTED_YEAR');
    fnd_message.set_token('REPORTED_YEAR', p_reported_year);
    put_line( fnd_file.log, fnd_message.get);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_LITERAL_START');
    fnd_message.set_token('LITERAL_START', p_literal_start);
    put_line( fnd_file.log, fnd_message.get);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_LITERAL_END');
    fnd_message.set_token('LITERAL_END', p_literal_end);
    put_line( fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log, '----------------------------------------');

    /******************************************************
     Check for JL_CO_GL_MG_HEADERS.STATUS = 'Y'. If any row
     exists with status of 'Y' then give a message to USER
     and exist the procedure
     ******************************************************/

    BEGIN

      SELECT count(*)
      INTO   count_status
      FROM   jl_co_gl_mg_headers
      WHERE  set_of_books_id = p_set_of_books_id
      AND    reported_year   = p_reported_year
      AND    status 	     = 'Y';

    EXCEPTION

      WHEN OTHERS THEN
	NULL;

    END;

    IF count_status > 0 THEN

      RAISE HEADERS_STATUS_Y;

    END IF;


    FOR rg_threshold_rec IN rg_threshold_cur LOOP

      /**************************************************************
       Call the procedure to get nit info. for each row of the cursor
       **************************************************************/

      get_nit_info(rg_threshold_rec.nit_id);

      /***********************************************************************
       Select Lietarl information and Configs(Reported Group) information from
       jl_co_gl_literals and jl_co_gl_configs for each row of the cursor
       ***********************************************************************/

      BEGIN

        SELECT l.foreign_reported_flag,
	       l.domestic_reported_flag,
	       l.threshold_foreign_flag,
	       l.threshold_domestic_flag
        INTO   x_foreign_reported_flag,
	       x_domestic_reported_flag,
	       x_threshold_foreign_flag,
	       x_threshold_domestic_flag
        FROM   jl_co_gl_mg_literals l
        WHERE  l.literal_id = rg_threshold_rec.literal_id;

      EXCEPTION

        WHEN NO_DATA_FOUND THEN

          fnd_message.set_name('AR', 'GENERIC_MESSAGE');
          fnd_message.set_token('GENERIC_TEXT',
            'Exception "NO_DATA_FOUND" for selection of flags from JL_CO_GL_MG_LITERALS table');
          put_line(fnd_file.log, fnd_message.get);
      	  x_error_code := SQLCODE;
          x_error_text := SUBSTR(SQLERRM,1,200);
          RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

        WHEN TOO_MANY_ROWS THEN

          fnd_message.set_name('AR', 'GENERIC_MESSAGE');
          fnd_message.set_token('GENERIC_TEXT',
            'Exception "TOO_MANY_ROWS" for selection of flags from JL_CO_GL_MG_LITERALS table');
          put_line(fnd_file.log, fnd_message.get);
      	  x_error_code := SQLCODE;
          x_error_text := SUBSTR(SQLERRM,1,200);
          RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

	WHEN OTHERS THEN

          fnd_message.set_name('AR', 'GENERIC_MESSAGE');
          fnd_message.set_token('GENERIC_TEXT',
            'Exception "OTHERS" for selection of flags from JL_CO_GL_MG_LITERALS table');
          put_line(fnd_file.log, fnd_message.get);
      	  x_error_code := SQLCODE;
          x_error_text := SUBSTR(SQLERRM,1,200);
          RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

      END;

      /*********************************************
       Update jl_co_gl_mg_lines.reported_flag to "N"
       that are not required to be reported
       *********************************************/

      IF (x_type			= 'FOREIGN_ENTITY' AND
	  x_foreign_reported_flag 	= 'N') OR
	 (x_type			<> 'FOREIGN_ENTITY' AND
	  x_domestic_reported_flag	= 'N') THEN

	 UPDATE	jl_co_gl_mg_lines
	 SET	reported_flag	= 'N'
	 WHERE	mg_header_id		= rg_threshold_rec.mg_header_id
	 AND    literal_id		= rg_threshold_rec.literal_id
	 AND    reported_value		= rg_threshold_rec.reported_value
	 AND	reported_flag		= rg_threshold_rec.reported_flag
	 AND	nit_id			= rg_threshold_rec.nit_id
	 AND	third_party_name	= rg_threshold_rec.third_party_name
	 AND	config_id		= rg_threshold_rec.config_id;

	 COMMIT;

      ELSE

	 /*********************************************
	  Apply Parent Report Grouping Threshold values
	  *********************************************/

         IF (x_type			= 'FOREIGN_ENTITY' AND
	     x_threshold_foreign_flag 	= 'Y') OR
	    (x_type			<> 'FOREIGN_ENTITY' AND
	     x_threshold_domestic_flag	= 'Y') THEN

	    IF 	(rg_threshold_rec.reported_value = '1' AND
		 rg_threshold_rec.first_reported_value < rg_threshold_rec.threshold_value) OR
	     	(rg_threshold_rec.reported_value = '2' AND
		 rg_threshold_rec.second_reported_value < rg_threshold_rec.threshold_value) THEN

	       	UPDATE	jl_co_gl_mg_lines
	 	SET	reported_flag	= 'N'
	 	WHERE	mg_header_id		= rg_threshold_rec.mg_header_id
	 	AND     literal_id		= rg_threshold_rec.literal_id
	 	AND     reported_value		= rg_threshold_rec.reported_value
	 	AND	reported_flag		= rg_threshold_rec.reported_flag
	 	AND	nit_id			= rg_threshold_rec.nit_id
	 	AND	third_party_name	= rg_threshold_rec.third_party_name
	 	AND	config_id		= rg_threshold_rec.config_id;

	 	COMMIT;

	    END IF;

	 END IF;

      END IF;

    END LOOP;


    FOR lit_threshold_rec IN lit_threshold_cur LOOP

      /**************************************************************
       Call the procedure to get nit info. for each row of the cursor
       **************************************************************/

      get_nit_info(lit_threshold_rec.nit_id);

      /******************************
       Apply Literal Threshold values
       ******************************/

      IF (x_type					= 'FOREIGN_ENTITY' AND
          lit_threshold_rec.threshold_foreign_flag 	= 'Y') OR
	 (x_type					<> 'FOREIGN_ENTITY' AND
	  lit_threshold_rec.threshold_domestic_flag	= 'Y') THEN

	 IF ((lit_threshold_rec.first_reported_value +
	     lit_threshold_rec.second_reported_value) >=
					lit_threshold_rec.threshold_value) THEN

	    UPDATE	jl_co_gl_mg_lines
	    SET		reported_flag	= 'Y'
	    WHERE	mg_header_id		= lit_threshold_rec.mg_header_id
	    AND     	literal_literal_id	= lit_threshold_rec.literal_literal_id
	    AND		nit_id			= lit_threshold_rec.nit_id;

	    COMMIT;

	 END IF;

      END IF;

    END LOOP;


    FOR child_threshold_rec IN child_threshold_cur LOOP

      /************************************************************************
       Update jl_co_gl_mg_lines for the selected parent config_id in the cursor
       ************************************************************************/

      UPDATE	jl_co_gl_mg_lines
      SET	reported_flag	= 'N'
      WHERE	mg_header_id		= child_threshold_rec.mg_header_id
      AND     	config_id	IN     (SELECT 	config_id
					FROM 	jl_co_gl_mg_configs
					WHERE 	config_id_parent = child_threshold_rec.config_id
				       )
      AND	nit_id			= child_threshold_rec.nit_id;

      COMMIT;

    END LOOP;

    /**************************************************************************
     Update JL_CO_GL_MG_LITERALS.PROCESSED_FLAG to 'M' for the given Parameters
     **************************************************************************/

    UPDATE	jl_co_gl_mg_literals
    SET		processed_flag = 'T'
    WHERE	set_of_books_id	= p_set_of_books_id
    AND		reported_year	= p_reported_year
    AND		literal_code BETWEEN p_literal_start AND p_literal_end
    AND		processed_flag = 'M';

    IF SQL%FOUND THEN
       COMMIT;
    END IF;

    /****************************************************
     Check for JL_CO_GL_MG_LITERALS.PROCESSED_FLAG = 'N'.
     If any row exists, give a message to USER
     ****************************************************/

    SELECT count(*)
    INTO   count_process_flag
    FROM   jl_co_gl_mg_literals
    WHERE  set_of_books_id = p_set_of_books_id
    AND    reported_year   = p_reported_year
    AND    LENGTH(literal_code) = 4
    AND    processed_flag = 'N';

    IF count_process_flag > 0 THEN

      x_message := '----***************** W A R N I N G **********************----';
      put_line( fnd_file.log, x_message);
      fnd_message.set_name('JL', 'JL_CO_GL_MG_TH_ALERT');
      fnd_message.set_token('NUMBER', TO_CHAR(count_process_flag));
      fnd_message.set_token('TABLE', 'JL_CO_GL_MG_LITERALS');
      x_error_text := fnd_message.get;
      put_line( fnd_file.log, x_error_text);
      x_error_text := SUBSTR(x_error_text, 1, 100);
      x_message := '----******************************************************----';
      put_line( fnd_file.log, x_message);
      app_exception.raise_exception (exception_type => 'APP',
       	exception_code =>
       		jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_GL_MG_TH_ALERT'),
       	exception_text => x_error_text);

    END IF;

  EXCEPTION

    WHEN HEADERS_STATUS_Y THEN

    x_message := '----***************** W A R N I N G **********************----';
    put_line( fnd_file.log, x_message);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_FILE_SENT');
    fnd_message.set_token('YEAR', p_reported_year);
    x_error_text := fnd_message.get;
    put_line( fnd_file.log, x_error_text);
    x_error_text := SUBSTR(x_error_text, 1, 100);
    x_message := '----******************************************************----';
    put_line( fnd_file.log, x_message);
    app_exception.raise_exception (exception_type => 'APP',
       	exception_code =>
       		jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_GL_MG_FILE_SENT'),
       	exception_text => x_error_text);

    WHEN OTHERS THEN

      fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
      fnd_file.put_line( fnd_file.log, fnd_message.get);
      x_error_code := SQLCODE;
      x_error_text := SUBSTR(SQLERRM,1,200);
      ROLLBACK;
      RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

  END threshold;



  /*********************************************************************
   PROCEDURE
     generate_mg_media

   DESCRIPTION
     Use this procedure to generate magnetic media flat file in standard
     out directory of application i.e. $APPLCSF/$APPLOUT
     with a file name consisting of request_id

   PURPOSE:
     Oracle Applications Rel 11.0

   PARAMETERS:
     p_set_of_books_id
     p_reported_year
     p_label

   HISTORY:
     23-DEC-1998   Raja Reddy Kappera    Created

   *********************************************************************/


  PROCEDURE	generate_mg_media
		(ERRBUF			OUT NOCOPY	VARCHAR2,
		 RETCODE		OUT NOCOPY	VARCHAR2,
 		 p_set_of_books_id 	IN 	gl_sets_of_books.set_of_books_id%TYPE,
                 p_legal_entity_id  IN          xle_entity_profiles.legal_entity_id%TYPE,
 		 p_reported_year 	IN 	jl_co_gl_mg_literals.reported_year%TYPE,
		 p_label		IN	VARCHAR2
		) IS

    /*************************************************************************
     Get the location id from jg_zz_company_info.get_location_id.
     Profile option JGZZ_COMP_ID is to be setup for non multi org environments
     *************************************************************************/

    --p_location_id	 hr.hr_locations_all.location_id%TYPE := jg_zz_company_info.get_location_id;

    company_name		xle_firstparty_information_v.name%TYPE;
    company_nit			xle_firstparty_information_v.registration_number%TYPE;
    --company_vdigit		hr.hr_locations_all.global_attribute12%TYPE;
    economic_activity_code	xle_firstparty_information_v.activity_code%TYPE;
    company_address		xle_firstparty_information_v.address_line_1%TYPE;
    area_code			hr.hr_locations_all.telephone_number_1%TYPE;
    telephone_number		hr.hr_locations_all.telephone_number_2%TYPE;
    city_code			xle_firstparty_information_v.town_or_city%TYPE;
    identifi_register		VARCHAR2(2000);
    movement_register		VARCHAR2(2000);
    closed_register		VARCHAR2(2000);
    count_literal		NUMBER;
    total_value			NUMBER;
    MG_GENERAL_ALERT		EXCEPTION;


    CURSOR generate_cur IS

      SELECT    mglit.literal_code              literal_code,
                DECODE(n.type, 'FOREIGN_ENTITY', foreign_nit, n.nit)
                                                nit_number,
                SUM(mgl.first_reported_value)   first_reported_value,
                SUM(mgl.second_reported_value)  second_reported_value
      FROM      jl_co_gl_mg_lines               mgl,
                jl_co_gl_nits                   n,
		jl_co_gl_mg_literals		mglit,
                jl_co_gl_mg_headers             mgh
      WHERE     mgl.mg_header_id        = mgh.mg_header_id
      AND       mgh.reported_year       = p_reported_year
      AND       mgh.set_of_books_id     = p_set_of_books_id
      AND       mgl.reported_flag       = 'Y'
      AND       mgl.nit_id              = n.nit_id
      AND	mgl.literal_id		= mglit.literal_id
      GROUP BY  mglit.literal_code,
                DECODE(n.type, 'FOREIGN_ENTITY', foreign_nit, n.nit)
      ORDER BY  mglit.literal_code,
                DECODE(n.type, 'FOREIGN_ENTITY', foreign_nit, n.nit);


  BEGIN <<generate_mg_media>>

    fnd_message.set_name('FND', 'CONC-ARGUMENTS');
    fnd_file.put_line( fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log, '----------------------------------------');
    fnd_message.set_name('JL', 'JL_CO_GL_MG_LEGAL_ENTITY_ID');
    fnd_message.set_token('LEGAL_ENTITY_ID', p_legal_entity_id);
    put_line( fnd_file.log, fnd_message.get);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_SET_OF_BOOKS_ID');
    fnd_message.set_token('SET_OF_BOOKS_ID', p_set_of_books_id);
    put_line( fnd_file.log, fnd_message.get);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_REPORTED_YEAR');
    fnd_message.set_token('REPORTED_YEAR', p_reported_year);
    put_line( fnd_file.log, fnd_message.get);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_LABEL');
    fnd_message.set_token('LABEL', p_label);
    put_line( fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log, '----------------------------------------');


    /******************************************************
     Check for JL_CO_GL_MG_HEADERS.STATUS = 'Y'. If any row
     exists with status of 'Y' then give a message to USER
     and exist the procedure
     ******************************************************/

    BEGIN

      SELECT count(*)
      INTO   count_status
      FROM   jl_co_gl_mg_headers
      WHERE  set_of_books_id = p_set_of_books_id
      AND    reported_year   = p_reported_year
      AND    status 	     = 'Y';

    EXCEPTION

      WHEN OTHERS THEN
	NULL;

    END;

    IF count_status > 0 THEN

      RAISE HEADERS_STATUS_Y;

    END IF;

    /*********************************************************
     Check for JL_CO_GL_MG_LITERALS.PROCESSED_FLAG = 'T'. If
     any row exists other than 'T' then give a message to USER
     and exit the procedure
     *********************************************************/

    BEGIN

      SELECT count(*)
      INTO   count_process_flag
      FROM   jl_co_gl_mg_literals
      WHERE  set_of_books_id = p_set_of_books_id
      AND    reported_year   = p_reported_year
      AND    LENGTH(literal_code) = 4
      AND    processed_flag <> 'T';

    EXCEPTION

      WHEN OTHERS THEN
	NULL;

    END;

    IF count_process_flag > 0 THEN

      RAISE MG_GENERAL_ALERT;

    END IF;

    /***************************************************************
     Select Company Information required for identification register
     and closed register from HR_LOCATIONS Table
     ***************************************************************/

    BEGIN

      SELECT	NVL(le.address_line_1||DECODE(le.address_line_2, NULL, ' ', ',')||
		    le.address_line_2||DECODE(le.address_line_3, NULL, ' ', ',')||
		    le.address_line_3, 'No Address') address,
		NVL(hr.telephone_number_1, '0'),
		NVL(hr.telephone_number_2, '0'),
		NVL(le.name, 'No Company Name'),
		NVL(le.registration_number, 'No Nit'),
		--NVL(global_attribute12, 'x'),
		NVL(le.town_or_city, 'x'),
		NVL(le.activity_code, 'x')
      INTO	company_address,
		area_code,
		telephone_number,
		company_name,
		company_nit,
		--company_vdigit,
		city_code,
		economic_activity_code
      FROM	xle_firstparty_information_v le,
                hr_locations hr
      WHERE	le.legal_entity_id	= p_legal_entity_id
        AND     hr.location_id = le.location_id;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN

        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
          'Exception "NO_DATA_FOUND" while selecting company information');
        put_line(fnd_file.log, fnd_message.get);
        x_error_code := SQLCODE;
        x_error_text := SUBSTR(SQLERRM,1,200);
        RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

      WHEN TOO_MANY_ROWS THEN

        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
          'Exception "TOO_MANY_ROWS" while selecting company information');
        put_line(fnd_file.log, fnd_message.get);
        x_error_code := SQLCODE;
        x_error_text := SUBSTR(SQLERRM,1,200);
        RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

      WHEN OTHERS THEN

        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT',
          'Exception "OTHERS" while selecting company information');
        put_line(fnd_file.log, fnd_message.get);
        x_error_code := SQLCODE;
        x_error_text := SUBSTR(SQLERRM,1,200);
        RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

    END;


    identifi_register	:=	'1'||
				TO_CHAR(p_reported_year)||
				'31'||
				LPAD(RTRIM(company_nit), 14, '0')||
				--RTRIM(company_vdigit)||
				' '||
				RPAD(company_name, 60, ' ')||
				LPAD(RTRIM(economic_activity_code), 4, '0')||
				'           '||
				TO_CHAR(SYSDATE, 'YYYYMMDD')||
				LPAD(RTRIM(p_label), 4, '0')||
				'                    ';

    count_literal		:= 0;
    total_value			:= 0;

    FOR generate_rec IN generate_cur LOOP

      IF generate_rec.nit_number = foreign_nit THEN

	/***********************************************
   	 Report foreign if literal foreign flag is 'Yes'
	 ***********************************************/

	x_verifying_digit	:= ' ';

	  BEGIN

	    SELECT foreign_description
	    INTO   x_name
	    FROM   jl_co_gl_mg_literals
	    WHERE  set_of_books_id	= p_set_of_books_id
	    AND    reported_year 	= p_reported_year
	    AND    literal_code 	= generate_rec.literal_code;

	  EXCEPTION

	    WHEN NO_DATA_FOUND THEN
	      NULL;

	    WHEN OTHERS THEN
	      NULL;

	  END;

      ELSE

	BEGIN

	  SELECT name,
		 NVL(verifying_digit, ' ') vd
	  INTO   x_name,
		 x_verifying_digit
	  FROM   jl_co_gl_nits
	  WHERE  nit = generate_rec.nit_number;

 	EXCEPTION

	  WHEN NO_DATA_FOUND THEN
	    NULL;

    	  WHEN OTHERS THEN
	    NULL;

        END;

      END IF;

      x_literal_code	:= generate_rec.literal_code;

      x_nit		:= generate_rec.nit_number;

      count_literal	:= count_literal + 1;

      movement_register	     :=	'2'||
				TO_CHAR(x_literal_code)||
				LPAD(x_nit, 14, '0')||
				x_verifying_digit||
				' '||
				SUBSTR(RPAD(x_name, 60, ' '), 1, 60)||
				LPAD(TO_CHAR(generate_rec.first_reported_value), 20, '0')||
				LPAD(TO_CHAR(generate_rec.second_reported_value), 20, '0')||
				'  '||
				'       ';

      tab_record_counter	:= tab_record_counter + 1;
      tab_flat_file (tab_record_counter) := movement_register;
      movement_register		:= null;

      total_value	     := total_value +
				generate_rec.first_reported_value +
				generate_rec.second_reported_value;

    END LOOP;

    /**********************************************
     Write identification register to the flat file
     **********************************************/

    put_line(fnd_file.output, identifi_register);

    fnd_message.set_name('JL', 'JL_CO_GL_MG_INDENTI_REGISTER');
    put_line( fnd_file.log, fnd_message.get);

    /****************************************
     Write movement_register to the flat file
     ****************************************/

    IF tab_record_counter > 0 THEN

      FOR g_count IN 1..tab_record_counter LOOP

	movement_register := tab_flat_file (g_count);

        put_line(fnd_file.output, movement_register);

      END LOOP;

        fnd_message.set_name('JL', 'JL_CO_GL_MG_MOVE_REGISTER');
        fnd_message.set_token('NUMBER', tab_record_counter);
        put_line( fnd_file.log, fnd_message.get);

    ELSE

      NULL;

      fnd_message.set_name('JL', 'JL_CO_GL_MG_NO_MOVE_REGISTER');
      x_message	:= fnd_message.get;
      put_line( fnd_file.log, x_message);
      put_line( fnd_file.output, x_message);

    END IF;

    closed_register     :=	'3'||
				'     '||
				LPAD(RTRIM(area_code), 5, '0')||
				LPAD(RTRIM(telephone_number), 7, '0')||
				SUBSTR(RPAD(company_address, 40, ' '), 1, 40)||
				LPAD(RTRIM(city_code), 5, '0')||
				LPAD(TO_CHAR(count_literal), 10, '0')||
				LPAD(total_value, 20, '0')||
				'                                     ';

    /**************************************
     Write closed_register to the flat file
     **************************************/

    put_line(fnd_file.output, closed_register);

    fnd_message.set_name('JL', 'JL_CO_GL_MG_CLOSE_REGISTER');
    put_line( fnd_file.log, fnd_message.get);

    /********************************************
     Update the jl_co_gl_mg_headers.status to 'Y'
     for final generation is done for DIAN
     ********************************************/

    UPDATE jl_co_gl_mg_headers
    SET    status = 'Y'
    WHERE  reported_year 	= p_reported_year
    AND    set_of_books_id	= p_set_of_books_id
    AND	   EXISTS      (SELECT 1
			FROM   	gl_period_statuses 	stat,
				gl_periods		p,
				gl_sets_of_books	sob,
				gl_period_types		pt,
				gl_period_sets		ps,
				fnd_application		a
			WHERE	a.application_short_name = 'SQLGL'
			AND 	stat.application_id	= a.application_id
			AND	stat.closing_status	= 'P'
			AND	stat.period_year	= p_reported_year
			AND	stat.set_of_books_id	= sob.set_of_books_id
			AND	sob.set_of_books_id	= p_set_of_books_id
			AND	stat.period_type	= pt.period_type
			AND	stat.period_name	= p.period_name
			AND	p.period_set_name	= ps.period_set_name
			AND	p.period_type		= pt.period_type
			AND	p.period_year		= p_reported_year
			AND	sob.accounted_period_type = pt.period_type
			AND	sob.period_set_name	= ps.period_set_name);

    IF SQL%FOUND THEN
       COMMIT;
    END IF;

  EXCEPTION

    WHEN HEADERS_STATUS_Y THEN

    x_message := '----***************** W A R N I N G **********************----';
    put_line( fnd_file.log, x_message);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_FILE_SENT');
    fnd_message.set_token('YEAR', p_reported_year);
    x_error_text := fnd_message.get;
    put_line( fnd_file.log, x_error_text);
    x_error_text := SUBSTR(x_error_text, 1, 100);
    x_message := '----******************************************************----';
    put_line( fnd_file.log, x_message);
    app_exception.raise_exception (exception_type => 'APP',
       	exception_code =>
       		jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_GL_MG_FILE_SENT'),
       	exception_text => x_error_text);


    WHEN MG_GENERAL_ALERT THEN

    x_message := '----***************** W A R N I N G **********************----';
    put_line( fnd_file.log, x_message);
    fnd_message.set_name('JL', 'JL_CO_GL_MG_GEN_ALERT');
    fnd_message.set_token('NUMBER', TO_CHAR(count_process_flag));
    fnd_message.set_token('TABLE', 'JL_CO_GL_MG_LITERALS');
    x_error_text := SUBSTR(fnd_message.get, 1, 200);
    put_line( fnd_file.log, x_error_text);
    x_error_text := SUBSTR(x_error_text, 1, 100);
    x_message := '----******************************************************----';
    put_line( fnd_file.log, x_message);
    app_exception.raise_exception (exception_type => 'APP',
       	exception_code =>
       		jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_GL_MG_GEN_ALERT'),
       	exception_text => x_error_text);

    WHEN LOCATION_ID_DOES_NOT_EXIST THEN

      fnd_message.set_name('JL', 'JL_CO_GL_MG_NO_LOCATION_ID');
      x_error_text := SUBSTR(fnd_message.get, 1, 100);
      app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_GL_MG_NO_LOCATION_ID'),
        exception_text => x_error_text);

    WHEN OTHERS THEN

      fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
      fnd_file.put_line( fnd_file.log, fnd_message.get);
      x_error_code := SQLCODE;
      x_error_text := SUBSTR(SQLERRM,1,200);
      RAISE_APPLICATION_ERROR( x_error_code, x_error_text);

  END generate_mg_media;


END JL_CO_GL_MG_MEDIA_PKG;

/
