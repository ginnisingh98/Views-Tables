--------------------------------------------------------
--  DDL for Package Body JL_XLA_GL_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_XLA_GL_TRANSFER_PKG" AS
/* $Header: jlzzxlab.pls 115.1 99/09/13 16:30:24 porting ship  $ */

/**************************************************************************
 *                                                                        *
 * Name       : JL_XLA_MESSAGE	 		                  	  *
 * Purpose    : This procedure will put the message given in the log file *
 *              							  *
 *              			         			  *
 *                                                                        *
 **************************************************************************/

PROCEDURE jl_xla_message( p_message_code   VARCHAR2,
		       p_token_1        VARCHAR2 DEFAULT NULL,
		       p_token_1_value  VARCHAR2 DEFAULT NULL,
		       p_token_2        VARCHAR2 DEFAULT NULL,
		       p_token_2_value  VARCHAR2 DEFAULT NULL,
		       p_token_3        VARCHAR2 DEFAULT NULL,
		       p_token_3_value  VARCHAR2 DEFAULT NULL,
		       p_token_4        VARCHAR2 DEFAULT NULL,
		       p_token_4_value  VARCHAR2 DEFAULT NULL
		       ) IS
BEGIN

      FND_MESSAGE.SET_NAME('JL',p_message_code);
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

END jl_xla_message;


/**************************************************************************
 *                                                                        *
 * Name       : JL_XLA_GL_TRANSFER 		                  	  *
 * Purpose    : This is a procedure which will run the country  Balance   *
 *		Maintenance.					  	  *
 *              							  *
 *  Parameters:								  *
 *  p_request_id contains the concurrent program request id		  *
 *  p_transfer_run_id contains the Transfer Run ID for a batch		  *
 *  p_start_date contains the start date of current commit cycle iteration*
 *  p_end_date contains the end date of current commit cycle iteration.   *
 *              			         			  *
 *                                                                        *
 **************************************************************************/

PROCEDURE jl_xla_gl_transfer (p_request_id 	 NUMBER,
			      p_transfer_run_Id	 NUMBER,
			      p_start_date 	 DATE,
			      p_end_date   	 DATE)
IS

   l_country_code 	    VARCHAR2(10);
   l_apps	 	    VARCHAR2(10);
   l_curr_calling_sequence  VARCHAR2(240);
   l_debug_info             VARCHAR2(1000);
   l_parameters             VARCHAR2(1000);

BEGIN

    l_curr_calling_sequence:='JL_XLA_GL_TRANSFER_PKG.jl_xla_gl_transfer';
    l_parameters:='p_request_id =' || to_char(p_request_id) || ' p_transfer_run_id= ' || TO_CHAR(p_transfer_run_id) ||
	  	  ' p_start_date= ' || TO_CHAR(p_start_date) || ' p_end_date= ' || TO_CHAR(p_end_date);

    -------------------------------------
    -- Get the Country and Product Code
    -------------------------------------
    fnd_profile.get('JGZZ_COUNTRY_CODE', l_country_code);
    fnd_profile.get('JGZZ_APPL_SHORT_NAME', l_apps);

    -------------------------------------------------
    -- Execute the Country Subledger Accounting
    -------------------------------------------------

    IF (l_country_code = 'BR') THEN

	-------------------------------------------------
	-- Execute the Application Subledger Accounting
	-------------------------------------------------

	IF l_apps='SQLAP' then

    	    ----------------------------------------
	    -- CALL AP BALANCE MAINTENANCE ROUTINE
	    ----------------------------------------
		l_debug_info:='Calling jl_br_ap_bal_maintenance';

		jl_br_ap_balance_maintenance.jl_br_ap_bal_maintenance(p_request_id,
								p_transfer_run_id,
								p_start_date,
								p_end_date);

	ELSIF l_apps='AR' then
    	    ----------------------------------------
	    -- CALL AR BALANCE MAINTENANCE ROUTINE
	    ----------------------------------------

	    NULL;

	END IF;

    END IF; -- Country Code

EXCEPTION
    WHEN OTHERS THEN
	  jl_xla_message('JL_ZZ_AP_DEBUG','ERROR',SQLERRM,'CALLING_SEQUENCE',l_curr_calling_sequence,
			 'PARAMETERS', l_parameters,'DEBUG_INFO',l_debug_info);

       APP_EXCEPTION.RAISE_EXCEPTION;

END jl_xla_gl_transfer;

END jl_xla_gl_transfer_pkg;

/
