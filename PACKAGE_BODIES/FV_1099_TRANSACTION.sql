--------------------------------------------------------
--  DDL for Package Body FV_1099_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_1099_TRANSACTION" AS
--$Header: FVR1099B.pls 120.16 2006/08/10 08:47:58 ckappaga ship $
--	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');
  g_module_name VARCHAR2(100) ;


PROCEDURE  fvr1099p
(errbuf   	 OUT NOCOPY varchar2,
 retcode	 OUT NOCOPY number,
 v_creditors_tin IN  varchar2,
 v_year      	 IN  number,
 v_rec_activity	 IN  number,
 v_include_charges IN varchar2)
IS
 l_module_name     VARCHAR2(200) ;
 v_cust_name       hz_parties.party_name%TYPE;
 v_tax_ref         hz_parties.tax_reference%TYPE;
 v_address1        hz_locations.address1%TYPE;
 v_address2       hz_locations.address2%TYPE;
 v_address3       hz_locations.address3%TYPE;
 v_address4       hz_locations.address4%TYPE;
 v_city           hz_locations.city%TYPE;
 v_state          hz_locations.state%TYPE;
 v_postal_code    hz_locations.postal_code%TYPE;
 v_province       hz_locations.province%TYPE;
 v_country         hz_locations.country%TYPE;
 v_trx_number      ra_customer_trx.trx_number%TYPE;
 v_process_inv_id  ra_customer_trx.customer_trx_id%TYPE;
 v_customer_id     ra_customer_trx.bill_to_customer_id%TYPE;
 v_apply_date      ar_adjustments.apply_date%TYPE;
 v_debit_memo_sum  number;
 v_begin_date      date;
 v_end_date        date;
 v_org_id          number;
 v_user_id	   number;
 v_login_id 	   number;
 v_sob_id        number;
 v_sob_name      varchar2(30);

 CURSOR debit_memos_c IS
    select nvl(sum(nvl(amount,0)),0)
    from ar_adjustments
    where customer_trx_id in (select customer_trx_id
			from ra_customer_trx,
                             fv_finance_charge_controls fcc
			where related_customer_trx_id = v_process_inv_id
                        and  cust_trx_type_id  in (select cust_trx_type_id
			   			from ra_cust_trx_types
						where type = 'DM')
                        and interface_header_attribute3 = fcc.charge_type
                        and fcc.set_of_books_id = v_sob_id)
    and set_of_books_id    = v_sob_id
    and status             = 'A'
    and receivables_trx_id = v_rec_activity
    and apply_date between v_begin_date and v_end_date;

 CURSOR all_adjustments_c(p_sob_id number) IS
    select nvl(sum(nvl(amount,0)),0) sum_adjustments,
            nvl(related_customer_trx_id, aa.customer_trx_id) id,
            bill_to_customer_id
    from ar_adjustments aa,
         ra_customer_trx rct
    where (aa.customer_trx_id = rct.customer_trx_id
    or     aa.customer_trx_id in (select customer_trx_id
			from ra_customer_trx
			where related_customer_trx_id = aa.customer_trx_id))
    and  aa.set_of_books_id    = p_sob_id
    and  aa.status             = 'A'
    and  aa.receivables_trx_id = v_rec_activity
    and  aa.apply_date between v_begin_date and v_end_date
    group by nvl(related_customer_trx_id, aa.customer_trx_id),
             bill_to_customer_id;

BEGIN

	 l_module_name      := g_module_name || 'fvr1099p';

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BEGIN');
    END IF;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BEGIN');
    END IF;

    /*  Multi org changes */
---    v_org_id  := to_number(fnd_profile.value('ORG_ID'));
       v_org_id  := mo_global.get_current_org_id;
       mo_utils.Get_Ledger_Info(v_org_id,v_sob_id,v_sob_name);

      DELETE from fv_1099c
      WHERE set_of_books_id = v_sob_id;


    -- v_begin_date := to_date('01-JAN-'||substr(v_year,3,2));
    -- v_end_date   := to_date('31-DEC-'||substr(v_year,3,2));

    SELECT to_date('01/01/'|| v_year, 'MM/DD/YYYY')
    INTO v_begin_date
    FROM DUAL;

--    v_begin_date := to_date(l_begin_date, 'DD-MON-YYYY') ;

    SELECT to_date('12/31/'|| v_year, 'MM/DD/YYYY')
    INTO v_end_date
    FROM DUAL;

--    v_end_date   := to_date(l_end_date, 'DD-MON-YYYY') ;



    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BEGIN_DATE ='||TO_CHAR(V_BEGIN_DATE, 'DD-MON-YYYY'));
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BEGIN_DATE ='||TO_CHAR(V_END_DATE, 'DD-MON-YYYY'));
    END IF;
     v_user_id  := FND_GLOBAL.USER_ID;
     v_login_id := FND_GLOBAL.LOGIN_ID;

    FOR v_adjustment_rec IN all_adjustments_c(v_sob_id) LOOP

	-- sum all adjustments for the type specified including
	-- all finance charges

    	-- reassign variables.
    	v_process_inv_id := v_adjustment_rec.id;
    	v_customer_id    := v_adjustment_rec.bill_to_customer_id;

    	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'INVOICE_ID ='||V_PROCESS_INV_ID);
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CUSTOMER_ID = '||V_CUSTOMER_ID);
    	END IF;

    	-- sum all finance charge debit memos for an invoice and specified type.
    	OPEN  debit_memos_c;
    	FETCH debit_memos_c into v_debit_memo_sum;

    	IF debit_memos_c%NOTFOUND THEN
            v_debit_memo_sum := 0;
    	END IF;

    	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'DEBIT_MEMO_SUM ='||V_DEBIT_MEMO_SUM);
    	END IF;
    	CLOSE debit_memos_c;

	BEGIN
	    SELECT hzp.party_name,hzp.tax_reference
      	    INTO v_cust_name, v_tax_ref
      	    FROM hz_parties hzp, hz_cust_accounts hzca
      	    WHERE hzca.cust_account_id = v_customer_id
                 AND  hzca.party_id = hzp.party_id;

	EXCEPTION
           when others then
		retcode := 2;
       		errbuf  := 'A-'||sqlerrm;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error1', errbuf) ;
       		/* Bug No: 1979347
       		   Bug Desc: 1099-C SET-UP PROCESS FAILS WITH ERROR*/
       		--CLOSE all_adjustments_c;
       		--rollback;

    	END;

        BEGIN

	    SELECT address1, address2, address3, address4, city, state,
               postal_code, country, province
            INTO v_address1, v_address2, v_address3, v_address4, v_city,
		v_state, v_postal_code, v_country, v_province
            FROM hz_locations hzl, hz_cust_acct_sites hzcas, hz_party_sites hzps
            WHERE hzcas.cust_account_id = v_customer_id
	       	AND hzcas.party_site_id = hzps.party_site_id
		AND hzps.location_id = hzl.location_id;


	EXCEPTION
            when others then
       		retcode := 2;
       		errbuf  := 'B-'||sqlerrm;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error2', errbuf) ;
       		/* Bug No: 1979347
       		   Bug Desc: 1099-C SET-UP PROCESS FAILS WITH ERROR*/
       		--CLOSE all_adjustments_c;
       		--rollback;

    	END;

    	BEGIN
            SELECT trx_number
            INTO v_trx_number
            FROM ra_customer_trx
            WHERE customer_trx_id = v_process_inv_id;
    	EXCEPTION
      	    when others then
		retcode := 2;
       		errbuf  := 'C-'||sqlerrm;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error3', errbuf) ;
       		/* Bug No: 1979347
       		   Bug Desc: 1099-C SET-UP PROCESS FAILS WITH ERROR*/
       		--CLOSE all_adjustments_c;
       		--rollback;
    	END;

    	BEGIN

            SELECT max(apply_date)
            INTO v_apply_date
            FROM ar_adjustments
            WHERE customer_trx_id = v_process_inv_id;

            IF v_apply_date is null THEN
         	-- there are only adjustments for a finance charge(s), find
	 	-- the max date for the fc(s). (the main cursor will return
		-- trx_number so the case when only fc are written off there
		-- will not be a record in the adjustment table for the
		-- invoice only the fc record.)
         	BEGIN
            	    SELECT max(apply_date)
                    INTO v_apply_date
              FROM ar_adjustments
             WHERE customer_trx_id in (select customer_trx_id
				      from ra_customer_trx
				     where related_customer_trx_id =
						v_process_inv_id)
	 	     AND set_of_books_id = v_sob_id
		     AND apply_date between v_begin_date and v_end_date
	             AND receivables_trx_id = v_rec_activity;
            IF v_apply_date is null THEN
               retcode := 2;
               errbuf  := 'D-Apply Date is null for Invoice Number '
							||v_trx_number;
               ROLLBACK;
               RETURN;
            END IF;
         EXCEPTION
            WHEN others THEN
 	     retcode := 2;
     	     errbuf  := 'D-'||sqlerrm;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error4', errbuf) ;
     	     /* Bug No: 1979347
       		Bug Desc: 1099-C SET-UP PROCESS FAILS WITH ERROR*/
	     --CLOSE all_adjustments_c;
	     --rollback;
         END;
      END IF;
    EXCEPTION
      when others THEN
       retcode := 2;
       errbuf  := 'E-'||sqlerrm;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error5', errbuf) ;
       /* Bug No: 1979347
       	  Bug Desc: 1099-C SET-UP PROCESS FAILS WITH ERROR*/
       --CLOSE all_adjustments_c;
    END;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'APPLY_DATE = '||V_APPLY_DATE);
  END IF;
    INSERT INTO fv_1099c
    (set_of_books_id,
     creditors_tin,
     customer_id,
     date_canceled,
     customer_name,
     tax_id,
     trx_number,
     amount,
     finance_charge_amount,
     address1,
     address2,
     address3,
     address4,
     city,
     state,
     postal_code,
     province,
     country,
     reportable_flag,
     org_id,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     last_update_login )
    values
    (v_sob_id,
     v_creditors_tin,
     v_customer_id,
     v_apply_date,
     v_cust_name,
     v_tax_ref,
     v_trx_number,
     decode(v_include_charges,'Y',(v_adjustment_rec.sum_adjustments*-1),
       ((v_adjustment_rec.sum_adjustments - v_debit_memo_sum)*-1)),
     decode(v_include_charges,'Y',(v_debit_memo_sum*-1),0),
     v_address1,
     v_address2,
     v_address3,
     v_address4,
     v_city,
     v_state,
     v_postal_code,
     v_province,
     v_country,
     'Y',
     v_org_id,
     SYSDATE,
     v_user_id,
     SYSDATE,
     v_user_id,
     v_login_id     );
  END LOOP;
  commit;
  retcode := 0;
  errbuf  := null;
 EXCEPTION
  WHEN others then
  retcode := 2;
  errbuf  := sqlerrm;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception', errbuf) ;
  rollback;
END;
BEGIN

	g_module_name  := 'fv.plsql.fv_1099_transaction.';


END fv_1099_transaction;

/
