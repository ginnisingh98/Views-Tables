--------------------------------------------------------
--  DDL for Package Body XTR_SETTLEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_SETTLEMENT" as
/* $Header: xtrsettb.pls 120.8 2005/07/29 15:01:42 csutaria ship $ */
---------------------------------------------------------------------------------


PROCEDURE SETTLEMENT_SCRIPTS(errbuf  OUT nocopy   VARCHAR2,
                             retcode OUT nocopy   NUMBER,
		             l_company     IN VARCHAR2,
                             l_paydate     IN VARCHAR2,
			     l_setl_amt_from NUMBER,
			     l_setl_amt_to   NUMBER,
			     l_account     IN VARCHAR2,
			     l_currency    IN VARCHAR2,
			     l_script_name IN VARCHAR2,
			     l_cparty	   IN VARCHAR2,
			     l_prev_run    IN VARCHAR2,
			     l_display_debug IN VARCHAR2,
                             l_transmit_payment IN VARCHAR2,
			     l_transmit_config_id IN VARCHAR2 ) IS


script_name	      VARCHAR2(20);
script_type	      VARCHAR2(20);
package_name	      VARCHAR2(50);
req_id                NUMBER;
request_id            NUMBER;
reqid                 VARCHAR2(30);
number_of_copies      number;
printer               VARCHAR2(30);
print_style           VARCHAR2(30);
save_output_flag      VARCHAR2(30);
save_output_bool      BOOLEAN;
settlement_date	      DATE;
--
-- This script will determine what Reports or EFT Scripts to call
-- based on the parameters submitted by the user
--
cursor HEADER_REC is
 select distinct s.script_name, s.script_type, s.package_name
  from XTR_DEAL_DATE_AMOUNTS_V dda,
       XTR_BANK_ACCOUNTS ba,
       XTR_SETTLEMENT_SCRIPTS s
  WHERE trunc(dda.actual_settlement_date) = trunc(NVL(Settlement_date,dda.actual_settlement_date))
  and dda.company_code = NVL(l_company, dda.company_code)
  and NVL(dda.beneficiary_party,dda.cparty_code)  like NVL(l_cparty,'%')
  and dda.amount >= NVL(l_setl_amt_from, dda.amount)
  and dda.amount <= NVL(l_setl_amt_to, dda.amount)
  and dda.account_no = NVL(l_account, dda.account_no)
  and dda.currency = NVL(l_currency, dda.currency)
  and dda.trans_mts = 'Y'
  and ((upper(l_prev_run) = 'Y') or (upper(l_prev_run) = 'N'
		and dda.settlement_actioned is NULL))
  and ba.account_number = dda.account_no
  and ba.party_code = NVL(l_company, ba.party_code)
  and ba.eft_script_name = NVL(l_script_name, ba.eft_script_name)
  and s.company_code = dda.company_code
  and s.script_name = ba.eft_script_name
  and nvl(s.currency_code,ba.currency) = ba.currency;

BEGIN

xtr_risk_debug_pkg.start_conc_prog;

IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dpush('SELTTLEMENT_SCRIPTS: ' || 'Settlement scripts');
END IF;

IF l_display_debug = 'Y' THEN
 -- cep_standard.enable_debug;
   xtr_debug_pkg.enable_file_debug;
END IF;
IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || '>XTR_SETTLEMENT.settlement_script');
END IF;
settlement_date := to_date(l_paydate, 'YYYY/MM/DD HH24:MI:SS');

IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || '>OPEN Header_Rec');
END IF;
OPEN HEADER_REC;
 FETCH HEADER_REC INTO script_name, script_type, package_name;
WHILE HEADER_REC%FOUND LOOP

IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || '>> Inside Loop... ');
   xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || '>> script_name = '|| script_name
			|| ' script_type = '||script_type
		        || ' package_name = ' || package_name );
END IF;
--
-- Loop thru and generate reports or scripts for each account
--

  --
  -- if script type is report then run report
  --    else run script
  --
  IF (script_type = 'REPORT') THEN
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || '>> REPORT');
	END IF;
      	--
      	-- Get original request id
      	--
      	fnd_profile.get('CONC_REQUEST_ID', reqid);
      	request_id := to_number(reqid);
      	--
      	-- Get print options
      	--
--* bug#2844888, rravunny
--* Here the second concurrent program XTRSTDAY may not necessarily be of the same format as
--* parent concurrent program XTRSETTL.
--* Hence we cannot default the print options used for parent into the child request.
--* commenting out the code which does that.
--*
--*      	IF( NOT FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(request_id,
--*                                                number_of_copies,
--*                                                print_style,
--*                                                printer,
--*                                                save_output_flag))THEN
--*        	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
--*        	   xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || 'Message: get print options failed');
--*        	END IF;
--*      	ELSE
--*    	  IF (save_output_flag = 'Y') THEN
--*      		save_output_bool := TRUE;
--*    	  ELSE
--*      		save_output_bool := FALSE;
--*    	  END IF;
     	  --
    	  -- Set print options
    	  --
--*    	  xtr_debug_pkg.debug('values ='||number_of_copies||' - '||print_style||' - '||printer||' - '||save_output_flag);
--*   	  IF (NOT FND_REQUEST.set_print_options(printer,
--*                                         print_style,
--*                                         number_of_copies,
--*                                         save_output_bool)) THEN
--*    	    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
--*   	       xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || 'Set print options failed');
--*  	    END IF;
--*	  END IF;
--*      	END IF;
      	req_id := FND_REQUEST.SUBMIT_REQUEST('XTR',
                                  package_name,
                                  NULL,
                                  trunc(sysdate),
                                  FALSE,
                                  l_company,
				  l_cparty,
                                  l_currency,
				  l_account,
				  l_paydate,
				  l_prev_run,
				  l_display_debug);

       	COMMIT;

     	IF (req_id = 0) THEN
    		IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
    		   xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || 'ERROR submitting concurrent request');
    		END IF;
       	ELSE
    	        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
    	           xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || 'EXECUTION REPORT SUBMITTED');
    	        END IF;
      	END IF;

  ELSIF (script_type = 'SCRIPT') THEN  -- if it is EFT script
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || '>> EFT Script');
	   xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || '>> l_company = '|| l_company
				|| ' package_name = '|| package_name
				|| ' Settlement_date = '|| Settlement_date
				|| ' l_paydate = ' || l_paydate);
	END IF;

		--
		-- Call concurrent program to generate EFT scripts
		--
          XTR_EFT_SCRIPT_P.call_scripts( l_company,
						     l_cparty,
                                         l_account,
                                         l_currency,
				                 script_name,
                                         l_paydate,
						     l_prev_run,
                                        l_transmit_payment,
					l_transmit_config_id,
					retcode);

 -- added transmit id for payments uptake project


  END IF;

  FETCH HEADER_REC INTO script_name, script_type, package_name;

END LOOP; -- end header_rec loop thru scripts
IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || '> END LOOP ');
   xtr_debug_pkg.debug('SETTLEMENT_SCRIPTS: ' || '> Close Cursor XTR_SETTLEMENT HEADER_REC ');
END IF;
close HEADER_REC; -- close cursor

IF (l_display_debug = 'Y') THEN
   --cep_standard.disable_debug;
   xtr_debug_pkg.disable_file_debug;
END IF;

IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dpop('SELTTLEMENT_SCRIPTS: ' || 'Settlement scripts');
end if;

xtr_risk_debug_pkg.stop_conc_debug;

END SETTLEMENT_SCRIPTS;
-----------------------------------------------------------------------------------

END XTR_SETTLEMENT;

/
