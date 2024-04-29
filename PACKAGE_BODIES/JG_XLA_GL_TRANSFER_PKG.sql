--------------------------------------------------------
--  DDL for Package Body JG_XLA_GL_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_XLA_GL_TRANSFER_PKG" AS
/* $Header: jgzzxlab.pls 115.5 1999/11/03 11:57:02 pkm ship      $ */

PROCEDURE jg_xla_message(p_application  VARCHAR2,
		       p_message_code   VARCHAR2,
		       p_token_1        VARCHAR2,
		       p_token_1_value  VARCHAR2,
		       p_token_2        VARCHAR2,
		       p_token_2_value  VARCHAR2,
		       p_token_3        VARCHAR2,
		       p_token_3_value  VARCHAR2,
		       p_token_4        VARCHAR2,
		       p_token_4_value  VARCHAR2
		       ) IS

BEGIN

      FND_MESSAGE.SET_NAME(p_application,p_message_code);

      IF p_token_1 IS NOT NULL THEN
	 fnd_message.set_token(p_token_1, p_token_1_value);
      END IF;

      IF p_token_2 IS NOT NULL THEN
	 fnd_message.set_token(p_token_2, p_token_2_value);
      END IF;

      IF p_token_3 IS NOT NULL THEN
	 fnd_message.set_token(p_token_3, p_token_3_value);
      END IF;

      IF p_token_4 IS NOT NULL THEN
	 fnd_message.set_token(p_token_4, p_token_4_value);
      END IF;

	fnd_file.put_line(fnd_file.Log,fnd_message.get);

END jg_xla_message;


/**************************************************************************
 *                                                                        *
 * Name       : JG_XLA_GL_TRANSFER 		                  	  *
 * Purpose    : This is share procedure which will verify the Product code*
 *              and run the proper Localization Package.          	  *
 *              This procedure is run during the Common Transfer to GL pro*
 *              cess.							  *
 *                                                                        *
 **************************************************************************/


PROCEDURE JG_XLA_GL_TRANSFER (
			  p_application_id                   NUMBER,
			  p_user_id                          NUMBER,
			  p_org_id                           NUMBER,
			  p_request_id                       NUMBER,
			  p_transfer_run_Id		     NUMBER,
			  p_program_name                     VARCHAR2,
			  p_selection_type                   NUMBER DEFAULT 1,
			  p_batch_name                       VARCHAR2,
			  p_start_date                       DATE,
			  p_end_date                         DATE,
			  p_gl_transfer_mode                 VARCHAR2,
			  p_process_days                     NUMBER   DEFAULT 'N',
			  p_debug_flag                       VARCHAR2 ) IS

   l_product_code 	   VARCHAR2(10);
   l_curr_calling_sequence VARCHAR2(240);
   l_debug_info            VARCHAR2(1000);
   l_parameters            VARCHAR2(2000);
   l_is_there              VARCHAR2(50);
   l_ignore                NUMBER;
   l_cursor                NUMBER;
   l_sqlstmt               VARCHAR2(1000);

   l_request_id             VARCHAR2(15);
   l_transfer_run_Id	    VARCHAR2(15);
   l_start_date             VARCHAR2(50);
   l_end_date               VARCHAR2(50);



BEGIN
    l_curr_calling_sequence:='JG_XLA_GL_TRANSFER_PKG.jg_xla_gl_transfer';

    -------------------------------------
    -- Get Product Code
    -------------------------------------

    fnd_profile.get('JGZZ_PRODUCT_CODE', l_product_code);

    IF l_product_code='JL' THEN
	-----------------------------------------------
	-- Execute LatinAmerica Transfer to GL routine
	-----------------------------------------------
	--
	l_debug_info:='Calling jl_xla_gl_transfer';
        jg_xla_message('JL','JL_ZZ_ZZ_CALL_TRANSFER_TO_GL','','','','','','','','');

        BEGIN

 	        SELECT  DISTINCT 'Procedure Installed'
	        INTO    l_is_there
	        FROM    all_source
	        WHERE   name = 'JL_XLA_GL_TRANSFER_PKG'
	        AND     type = 'PACKAGE BODY';

		BEGIN

	            ---------------------------------------------------
 		    -- Execute dynamically LatinAmerica Transfer to GL routine
		    ---------------------------------------------------
	   	   l_transfer_run_id :=to_char(p_transfer_run_id);
	    	   l_request_id :=to_char(p_request_id);
		   l_start_date := 'to_date(''' || to_char(p_start_date,'dd/mm/yyyy') || '''' || ',''dd/mm/yyyy'')';
		   l_end_date := 'to_date(''' || to_char(p_end_date,'dd/mm/yyyy') || '''' || ',''dd/mm/yyyy'')';

		    -- Create the SQL statement
		    l_cursor := dbms_sql.open_cursor;
		    l_sqlstmt := 'BEGIN jl_xla_gl_transfer_pkg.jl_xla_gl_transfer( ' ||
					l_request_id || ',' ||
					l_transfer_run_id || ',' ||
					l_start_date || ',' ||
					l_end_date || ' ); END;';

		    -- Parse the SQL statement
		    dbms_sql.parse (l_cursor, l_sqlstmt, dbms_sql.native);

		    -- Execute the SQL statement
		    l_ignore := dbms_sql.execute (l_cursor);

		    -- Close the cursor
		    dbms_sql.close_cursor (l_cursor);

		EXCEPTION
		    WHEN others THEN
		       IF (dbms_sql.is_open(l_cursor)) THEN
		           dbms_sql.close_cursor(l_cursor);
		       END IF;
		       APP_EXCEPTION.RAISE_EXCEPTION;
		END;

	 EXCEPTION
		WHEN no_data_found THEN
	        ----------------------------------------
	        -- Regional Procedure is not installed
		----------------------------------------
	            null;
	        WHEN OTHERS THEN
	            APP_EXCEPTION.RAISE_EXCEPTION;
         END;

    ELSIF l_product_code='JA' THEN
	-----------------------------------------------
	-- Execute Asia Transfer to GL routine
	-----------------------------------------------
	l_debug_info:='Calling JA transfer to GL';
        NULL;

    ELSIF l_product_code='JE' THEN
	-----------------------------------------------
	-- Execute Europe Transfer to GL routine
	-----------------------------------------------
	l_debug_info:='Calling JE transfer to GL';
        NULL;

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
       jg_xla_message('XLA','XLA_GLT_DEBUG','ERROR', Sqlerrm, 'DEBUG_INFO', l_debug_info,'CALLING_SEQUENCE', l_curr_calling_sequence,'','');
       APP_EXCEPTION.RAISE_EXCEPTION;

END JG_XLA_GL_TRANSFER;

END JG_XLA_GL_TRANSFER_PKG;

/
