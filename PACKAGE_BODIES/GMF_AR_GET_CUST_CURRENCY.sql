--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_CUST_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_CUST_CURRENCY" as
/* $Header: gmfcstub.pls 115.0 99/07/16 04:16:20 porting shi $ */
          cursor cur_ar_get_cust_currency( custid     number,
						orgid    number,
                                               siteuseid   number) is
             select BAU.CUSTOMER_ID,
		    BAU.CUSTOMER_SITE_USE_ID,
                    BAC.CURRENCY_CODE
             from   AP_BANK_ACCOUNT_USES_ALL BAU,
                    AP_BANK_ACCOUNTS_ALL BAC
             where  ((BAU.customer_id = nvl(custid, BAU.customer_id)
                     and  BAU.customer_site_use_id =
		          nvl(siteuseid, BAU.customer_site_use_id))
                    or  (BAU.customer_id = nvl(custid, BAU.customer_id)
                        and  BAU.customer_site_use_id is null))
               and  upper(BAU.primary_flag) like 'Y%'
               and  BAU.external_bank_account_id = BAC.bank_account_id
               and  nvl(bau.org_id,0) = nvl(orgid, nvl(bau.org_id,0))
             order by BAU.customer_id, BAU.customer_site_use_id;

    procedure AR_GET_CUST_CURRENCY (cust_id            in number,
                                         site_use_id          in number,
                                         currency_code      out    varchar2,
					 porg_id	    in number,
                                         row_to_fetch       in out number,
                                         error_status       out    number) is

	no_of_site_accounts	number;
	no_of_cust_accounts	number;
	customer_id		number;
	cust_site_use_id	number;

	more_than_1_primary_ac_defined exception;
	no_primary_ac_defined exception;

    BEGIN

	no_of_site_accounts := 1;
	no_of_cust_accounts := 1;

             select count(*)
	     into   no_of_site_accounts
             from   AP_BANK_ACCOUNT_USES_ALL BAU
             where  BAU.customer_id = nvl(cust_id, BAU.customer_id)
                     and  BAU.customer_site_use_id =
		          nvl(site_use_id, BAU.customer_site_use_id)
		     and upper(bau.primary_flag) like  'Y%';

	     if no_of_site_accounts > 1 then
		raise more_than_1_primary_ac_defined;
	     end if;

	     if no_of_site_accounts = 0 then
		select count(*)
		into no_of_cust_accounts
		from   AP_BANK_ACCOUNT_USES_ALL BAU
		where  BAU.customer_id = nvl(cust_id, BAU.customer_id)
			and  BAU.customer_site_use_id IS NULL
		        and  upper(bau.primary_flag) like  'Y%'
               		and  nvl(bau.org_id,0) = nvl(porg_id, nvl(bau.org_id,0));

	     end if;

	     if no_of_cust_accounts > 1 then
		raise more_than_1_primary_ac_defined;
	     end if;

	     if no_of_cust_accounts = 0 then
		raise no_primary_ac_defined;
	     end if;

        if NOT cur_ar_get_cust_currency%ISOPEN then
            open cur_ar_get_cust_currency( cust_id, porg_id, site_use_id);
        end if;

        fetch cur_ar_get_cust_currency
        into  customer_id, cust_site_use_id, currency_code;

        if cur_ar_get_cust_currency%NOTFOUND then
           error_status := 100;
           close cur_ar_get_cust_currency;
	   currency_code := gmf_gl_get_base_cur.get_base_cur(porg_id);
        end if;

        if row_to_fetch = 1 and cur_ar_get_cust_currency%ISOPEN then
           close cur_ar_get_cust_currency;
        end if;

      exception

	  when more_than_1_primary_ac_defined then
		currency_code := gmf_gl_get_base_cur.get_base_cur(porg_id);

	  when no_primary_ac_defined then
		currency_code := gmf_gl_get_base_cur.get_base_cur(porg_id);

          when others then
               error_status := SQLCODE;

  end AR_GET_CUST_CURRENCY;
END GMF_AR_GET_CUST_CURRENCY;

/
