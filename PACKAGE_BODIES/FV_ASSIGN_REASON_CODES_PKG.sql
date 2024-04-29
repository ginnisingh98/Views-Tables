--------------------------------------------------------
--  DDL for Package Body FV_ASSIGN_REASON_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_ASSIGN_REASON_CODES_PKG" AS
-- $Header: FVXPPRCB.pls 120.8.12000000.3 2007/08/16 15:33:50 sasukuma ship $

/*******************************************************************/
/*****        Variable Declaration For All Processes          ******/
/*******************************************************************/
x_set_of_books_id number :=NULL;
	--l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
--   x_set_of_books_id number := to_number(fnd_profile.value('GL_SET_OF_BKS_ID'));
 g_module_name     varchar2(100) := 'fv.plsql.fv_assign_reason_codes_pkg.';
    l_set_of_books_name     gl_ledgers.name%TYPE :=NULL;

x_org_id number :=mo_global.get_current_org_id;
--    mo_utils.get_ledger_info(x_org_id ,x_set_of_books_id ,l_set_of_books_name);




   err_message   varchar2(100);
    v_count number (15) := 0;



procedure set_org(x_org_id IN NUMBER)   IS
BEGIN
--procedure added for as per design in ver 1.0 of design document

   IF (x_org_id IS NOT NULL) THEN


   mo_utils.Get_Ledger_Info
  (  p_operating_unit         =>	x_org_id
   , p_ledger_id                 =>	x_set_of_books_id
   , p_ledger_name            =>	l_set_of_books_name);


End if;


END;



PROCEDURE interest_reason_codes IS


CURSOR reason_codes_cur  IS
  SELECT air.original_invoice_id, air.checkrun_name
  FROM ap_invoice_relationships air,
     ap_invoices api,
     fv_terms_types fvt
  WHERE( air.original_invoice_id NOT IN
            (SELECT farc.invoice_id
       	     FROM  fv_assign_reason_codes farc
             WHERE farc.set_of_books_id = x_set_of_books_id
             AND org_id = x_org_id
	     AND farc.checkrun_name is not null      -- Bug 5037297
             AND   entry_source = 'INTEREST')
      OR
      (air.original_invoice_id IN
            (SELECT farc.invoice_id
       	     FROM  fv_assign_reason_codes farc
             WHERE farc.set_of_books_id = x_set_of_books_id
             AND   org_id = x_org_id
             AND   entry_source = 'INTEREST'
             AND   air.checkrun_name <> farc.checkrun_name)))
      AND api.org_id = x_org_id
      AND air.original_invoice_id = api.invoice_id
      AND fvt.term_id = api.terms_id
      AND fvt.terms_type = 'PROMPT PAY';
      l_module_name      varchar2(200) := g_module_name || 'interest_reason_codes';
      l_errbuf           varchar2(300);
       org_id_tab          mo_global.OrgIdTab;
begin

org_id_tab := mo_global.get_ou_tab;

  FOR i IN 1 .. org_id_tab.count LOOP
        set_org(org_id_tab(i));
        x_org_id := org_id_tab(i);

  FOR reason_code_rec IN reason_codes_cur LOOP

    UPDATE fv_assign_reason_codes
    SET checkrun_name = reason_code_rec.checkrun_name,
        entry_mode = 'SYSTEM',
	last_update_date = SYSDATE,
	last_updated_by = FND_GLOBAL.USER_ID,
	last_update_login = FND_GLOBAL.LOGIN_ID
    WHERE invoice_id = reason_code_rec.original_invoice_id
      AND org_id = x_org_id
      AND set_of_books_id = x_set_of_books_id
      AND entry_source = 'INTEREST';

    IF (SQL%ROWCOUNT = 0) THEN


INSERT INTO fv_assign_reason_codes
	(invoice_id,
	 org_id,
	 set_of_books_id,
	 entry_mode,
	 entry_source,
	 last_update_date,
	 last_updated_by,
	 created_by,
	 creation_date,
	 checkrun_name,
	 last_update_login)
      VALUES
	(reason_code_rec.original_invoice_id,
	 x_org_id,
	 x_set_of_books_id,
	 'SYSTEM',
	 'INTEREST',
	 SYSDATE,
	 FND_GLOBAL.USER_ID,
	 FND_GLOBAL.USER_ID,
	 SYSDATE,
	 reason_code_rec.checkrun_name,
	 FND_GLOBAL.LOGIN_ID);

    END IF;
  END LOOP;
END LOOP;
  COMMIT;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
	null;
     WHEN OTHERS THEN
       l_errbuf := sqlerrm;
       IF reason_codes_cur%ISOPEN THEN
         close reason_codes_cur;
       END IF;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.final_exception','ERROR = '||l_errbuf);
       END IF;
       err_message := 'FV_ASSIGN_REASON_CODES_PKG.Interest_Reason_Codes '||
			sqlerrm;
       fnd_message.set_name('FV','FV_RC_QUICK_PAY');
       fnd_message.set_token('MSG',err_message);
       IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception');
       END IF;
       app_exception.raise_exception;

END interest_reason_codes;
/**********************************************************************/
PROCEDURE get_quick_payments IS

     -- Select all quick payments which are not on
     -- fv_assign_reason_codes with an entry_source of 'EBD'
     --  NOTE: there may be ones of type 'INTEREST' automatically
     --     loaded, this picks up the 'EBD' side.

    CURSOR c_quick_payments IS

	    SELECT  /*+ USE_MERGE(api) */ api.invoice_id, apc.checkrun_name
    		FROM  fv_terms_types ftt,
			ap_terms apt,
			ap_invoices api,
           		ap_checks  apc,
           		ap_invoice_payments app
    		WHERE app.set_of_books_id = x_set_of_books_id
                 and api.org_id = x_org_id
     		 and app.discount_lost > 0
     		 and api.invoice_id = app.invoice_id
     		 and apc.check_id = app.check_id
     		 and apc.checkrun_name like '%Quick Payment%'
     		 AND apt.term_id = api.terms_id
    		 AND ftt.term_id = apt.term_id
     		 AND ftt.terms_type = 'PROMPT PAY'
             AND apc.void_date is null;
             l_module_name     varchar2(200) := g_module_name || 'get_quick_payment';
             l_errbuf          varchar2(300);
	     org_id_tab		MO_GLOBAL.orgidtab;
BEGIN
   	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BEGIN');
   	END IF;

org_id_tab := mo_global.get_ou_tab;


     FOR i IN 1 .. org_id_tab.count LOOP
        set_org(org_id_tab(i));
        x_org_id := org_id_tab(i);
-- Check to see if the row exists already.  If so, update, otherwise insert.

		FOR v_quick_payments IN c_quick_payments
                 LOOP

			select count (*)
			into v_count
      		from fv_assign_reason_codes fvr
      		where fvr.invoice_id = v_quick_payments.invoice_id
                  and org_id = x_org_id
      		  and fvr.entry_source = 'EBD'
			  and fvr.set_of_books_id = x_set_of_books_id;

		     If v_count > 0 then

   				UPDATE fv_assign_reason_codes
          	   	 	 SET Checkrun_name = v_quick_payments.checkrun_name,
	        	  	  Entry_mode = 'SYSTEM',
             	  	  Last_Update_Date = SYSDATE,
             	  	  Last_Updated_By = FND_GLOBAL.USER_ID,
             	  	  Last_Update_Login = FND_GLOBAL.LOGIN_ID
       		 	where invoice_id = v_quick_payments.invoice_id
       		 	  and set_of_books_id =  x_set_of_books_id
                          and org_id = x_org_id
                          and entry_source = 'EBD';

                  elsif	v_count = 0 then

         			INSERT into fv_assign_reason_codes
		   		(invoice_id, entry_source, set_of_books_id,
				/*-- Version 1.1  RCW.--------*/
    			 	  org_id,
				/*--  end 1.1 RCW  -----------*/
				entry_mode, last_update_date,
	 	   		 last_updated_by, created_by, creation_date, checkrun_name, last_update_login)
	        		VALUES
	  	 		  (v_quick_payments.invoice_id, 'EBD', x_set_of_books_id,
				/*-- Version 1.1  RCW.-------*/
			 	   x_org_id,
				/*--  end 1.1 RCW  ----------*/
				   'SYSTEM', sysdate,
		 		   fnd_global.user_id, fnd_global.user_id, sysdate,
	 	 		   v_quick_payments.checkrun_name, fnd_global.login_id);

		      end if;

		  END LOOP;
END LOOP;
	commit;

--cursor exception
EXCEPTION
     WHEN NO_DATA_FOUND THEN
	null;
     WHEN OTHERS THEN
       l_errbuf := sqlerrm;
       IF c_quick_payments%ISOPEN THEN
         close c_quick_payments;
       END IF;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.final_exception','ERROR = '||l_errbuf);
       END IF;
       err_message := 'FV_ASSIGN_REASON_CODES_PKG.GET_QUICK_PAYMENTS '||sqlerrm;
       fnd_message.set_name('FV','FV_RC_QUICK_PAY');
       fnd_message.set_token('MSG',err_message);
       IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FV_UTILITY.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception');
       END IF;
       app_exception.raise_exception;

 END get_quick_payments;


END fv_assign_reason_codes_pkg;

/
