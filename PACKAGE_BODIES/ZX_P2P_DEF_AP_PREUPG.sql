--------------------------------------------------------
--  DDL for Package Body ZX_P2P_DEF_AP_PREUPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_P2P_DEF_AP_PREUPG" AS
/* $Header: zxappreupgb.pls 120.0 2006/04/05 12:14:01 asengupt noship $ */

PG_DEBUG CONSTANT VARCHAR(1) := 'Y';
ID_CLASH VARCHAR2(1) default NULL;

l_multi_org_flag FND_PRODUCT_GROUPS.MULTI_ORG_FLAG%TYPE;
l_org_id         NUMBER(15);


/*===========================================================================+
|  Procedure  :     OU_EXTRACT						    |
|                                                                           |
|                                                                           |
|  Description:    This procedure is a part of party tax                    |
|		   profile migration which does the data		    |
|		   migration for Operating Unit details.                    |
|                                                                           |
|                                                                           |
|  ARGUMENTS  : 							    |
|                                                                           |
|                                                                           |
|  NOTES      : Handle case for Non-Multi Org Environments                  |
|                                                                           |
|                                                                           |
|  MODIFICATION HISTORY                                                     |
|									    |
|  06-Mar-06    Arnab Sengupta        Created. 		                    |
|                                                                           |
|    									    |
+===========================================================================*/

PROCEDURE OU_EXTRACT(p_party_id in NUMBER) IS
   BEGIN

	NULL;
    	 EXCEPTION
	 	WHEN OTHERS THEN
	 	arp_util_tax.debug('Exception: Error Occurred during Operating Units Extract in PTP'||SQLERRM );

	 END;

/*===========================================================================+
|  Procedure  :     load_results_for_ap					    |
|                                                                           |
|                                                                           |
|  Description:    This procedure is used to load data                      |
|		   into zx_update_criteria_results		            |
|		   which is the driving table for rates data load           |
|                                                                           |
|                                                                           |
|  ARGUMENTS  : 							    |
|                                                                           |
|                                                                           |
|  MODIFICATION HISTORY                                                     |
|									    |
|  06-Mar-06    Arnab Sengupta        Created. 		                    |
|                                                                           |
|    									    |
+===========================================================================*/
PROCEDURE load_results_for_ap (p_tax_id   NUMBER) AS
  BEGIN
	NULL;
END load_results_for_ap;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_normal_tax_codes                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine processes AP normal Tax codes and inserts appropriate    |
 |     data into the following zx base tables.                               |
 |               ZX_RATES_B                                                  |
 |               ZX_RATES_TL                                                 |
 |               ZX_ACCOUNTS                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |==========================================================================*/

PROCEDURE Migrate_Normal_Tax_Codes(p_tax_id IN NUMBER DEFAULT NULL) IS
BEGIN
 null;


EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_normal_tax_codes ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_Normal_Tax_Codes(-)');
            END IF;
            --app_exception.raise_exception;


END migrate_normal_tax_codes;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_assign_offset_codes                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine processes assigned OFFSET Tax codes and inserts          |
 |     appropriate data into the following zx base tables.                   |
 |               ZX_RATES_B                                                  |
 |               ZX_RATES_TL                                                 |
 |               ZX_ACCOUNTS                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |                                                                           |
 |==========================================================================*/



PROCEDURE migrate_assign_offset_codes(p_tax_id IN NUMBER DEFAULT NULL) IS
BEGIN

  NULL;

EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_assign_offset_codes ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_Assign_Offset_Codes(-)');
            END IF;
            --app_exception.raise_exception;

END migrate_assign_offset_codes;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_unassign_offset_codes                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine processes unassigned OFFSET Tax codes and inserts        |
 |     appropriate data into the following zx base tables.                   |
 |               ZX_RATES_B                                                  |
 |               ZX_RATES_TL                                                 |
 |               ZX_ACCOUNTS                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |                                                                           |
 |==========================================================================*/


PROCEDURE migrate_unassign_offset_codes(p_tax_id IN NUMBER DEFAULT NULL) IS
BEGIN
null;

EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_unassign_offset_codes ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_UnAssign_Offset_Codes(-)');
            END IF;
            --app_exception.raise_exception;
END migrate_unassign_offset_codes;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_recovery_rates                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine processes distinct recovery rates,inserts appropriate    |
 |     data into the following zx base tables.                               |
 |               ZX_RATES_B                                                  |
 |               ZX_RATES_TL                                                 |
 |               ZX_ACCOUNTS                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |                                                                           |
 |==========================================================================*/


PROCEDURE migrate_recovery_rates(p_tax_id IN NUMBER DEFAULT NULL) IS
BEGIN

 null;

EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_recovery_rates ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_Recovery_Rates(-)');
            END IF;
            --app_exception.raise_exception;
END migrate_recovery_rates;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_disabled_tax_codes                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine is used to migrate disabled tax codes with overlapping   |
 |     into zx_rates_b						             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_disabled_tax_codes                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-Sep-05  Arnab Sengupta      Created.                               |
 |                                                                           |
 |==========================================================================*/

 PROCEDURE migrate_disabled_tax_codes(p_tax_id IN NUMBER DEFAULT NULL) IS

 TYPE  tax_id_table is table of ap_tax_codes_all.tax_id%TYPE index by BINARY_INTEGER;
 tax_id_tab tax_id_table ;
 l_min_start_date date;
 l_max_end_date   date;



 /*The purpose of the following cursor is to pick up data sets in which tax codes are disabled
   and these records have identical org_id set_of_books_id and name but differ only in their
   effective from and effective to dates .These date ranges however overlap*/

/*   Sample Data Set

ORG_ID SOB NAME      START_DATE INACTIVE_DATE ENABLED_FLAG TAX_RATE
====== === ====      ========== ============= ============ ========
204	1  CA-Sales  04-JAN-51  07-JAN-51         N          0
204	1  CA-Sales  NULL       NULL              N          10
204	1  CA-Sales  01-JAN-51  11-JAN-51         N          15

Records 1 and 3 are a case of overlap */




	CURSOR tax_id_csr
	IS
	select aptax2.tax_id tax_id
	from
	(
		select DISTINCT org_id,set_of_books_id,name
		from   ap_tax_codes_all a
		where a.enabled_flag = 'N'
		and    exists
		(
			select 1 from ap_tax_codes_all b
				   where  a.org_id = b.org_id
			       and    a.set_of_books_id = b.set_of_books_id
			       and    a.name =  b.name
			       and
				(          (    Nvl(a.START_DATE,l_min_start_date) > Nvl(b.START_DATE,l_min_start_date)
					    and Nvl(a.INACTIVE_DATE,l_max_end_date)  < Nvl(b.INACTIVE_DATE,l_max_end_date))

				       or  (    Nvl(a.START_DATE,l_min_start_date) < Nvl(b.START_DATE,l_min_start_date)
					    and Nvl(a.INACTIVE_DATE,l_max_end_date) > Nvl(b.START_DATE,l_max_end_date)
					    and Nvl(a.INACTIVE_DATE,l_max_end_date) <Nvl(b.INACTIVE_DATE,l_max_end_date))

				       or (     Nvl(a.START_DATE,l_min_start_date) > Nvl(b.START_DATE,l_min_start_date)
					    and Nvl(a.START_DATE,l_min_start_date) <Nvl(b.INACTIVE_DATE,l_max_end_date)
					    and Nvl(a.INACTIVE_DATE,l_max_end_date) >Nvl(b.INACTIVE_DATE,l_max_end_date))
		                 )
		and     b.enabled_flag = 'N'
     	         )
		and     exists
		(select c.org_id,c.set_of_books_id,c.name ,count(c.org_id) from ap_tax_codes_all c
			 where        a.org_id                 = c.org_id
			       and    a.set_of_books_id        = c.set_of_books_id
			       and    a.name                   = c.name
			 group by c.org_id,c.set_of_books_id,c.name
			 having count(c.org_id) > 1)
	)
	aptax1,
	ap_tax_codes_all aptax2
	where
		aptax1.org_id           = 	aptax2.org_id
	and	aptax1.set_of_books_id  =      	aptax2.set_of_books_id
	and	aptax1.	name            =      	aptax2.	name
	;


 BEGIN
  NULL;

EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_disabled_tax_codes ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_disabled_Tax_Codes(-)');
            END IF;
            --app_exception.raise_exception;


 END migrate_disabled_tax_codes;

/*===========================================================================+
|  Procedure  :     PRE_UPGRADE_WRAPPER					    |
|                                                                           |
|                                                                           |
|  Description:    This is the wrapper procedure for populating             |
|		   the relevant zx entities that ap would require	    |
|                  during their pre upgrade run                             |
|                                                                           |
|                                                                           |
|  ARGUMENTS  : 							    |
|                                                                           |
|                                                                           |
|                                                                           |
|  MODIFICATION HISTORY                                                     |
|									    |
|  06-Mar-06    Arnab Sengupta        Created. 		                    |
|                                                                           |
|    									    |
+===========================================================================*/


PROCEDURE pre_upgrade_wrapper
IS
BEGIN

 NULL;

 EXCEPTION
         WHEN OTHERS THEN

              arp_util_tax.debug('EXCEPTION: pre_upgrade_wrapper ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('pre_upgrade_wrapper(-)');
 END pre_upgrade_wrapper;

/*===========================================================================+
|  Procedure  :     PRE_UPGRADE_WRAPPER					    |
|                                                                           |
|                                                                           |
|  Description:    This is the wrapper procedure for syching up             |
|		   the relevant rates entities        	                    |
|                                                                           |
|                                                                           |
|                                                                           |
|  ARGUMENTS  : 							    |
|                                                                           |
|                                                                           |
|                                                                           |
|  MODIFICATION HISTORY                                                     |
|									    |
|  06-Mar-06    Arnab Sengupta        Created. 		                    |
|                                                                           |
|    									    |
+===========================================================================*/
 PROCEDURE rates_sync_wrapper(p_tax_id IN NUMBER DEFAULT NULL)
 IS
 BEGIN

  NULL;

 EXCEPTION
         WHEN OTHERS THEN

              arp_util_tax.debug('EXCEPTION: pre_upgrade_wrapper ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('pre_upgrade_wrapper(-)');


 END;

  /*Constructor Code*/
  BEGIN
   BEGIN

	    SELECT 'Y' INTO ID_CLASH FROM DUAL
	    WHERE EXISTS (select 1
			  from ap_tax_codes_all,
			       ar_vat_tax_all_b
			  where tax_id = vat_tax_id);
    EXCEPTION
    WHEN no_data_found THEN
      arp_util_tax.debug('No data found exception encountered for tax definition in constructor :'||sqlerrm);

    WHEN OTHERS THEN
      arp_util_tax.debug('Exception in Constructor for AP  tax definition :'||sqlerrm);
    END;

	   BEGIN

	   SELECT NVL(MULTI_ORG_FLAG,'N')  INTO L_MULTI_ORG_FLAG FROM
	    FND_PRODUCT_GROUPS;

	    IF L_MULTI_ORG_FLAG  = 'N' THEN

		  FND_PROFILE.GET('ORG_ID',L_ORG_ID);

			 IF L_ORG_ID IS NULL THEN
			   arp_util_tax.debug('MO: Operating Units site level profile option value not set , resulted in Null Org Id');
			 END IF;
	    ELSE
		 L_ORG_ID := NULL;
	    END IF;

	    EXCEPTION
	    WHEN no_data_found THEN
	      arp_util_tax.debug('No data found exception encountered for tax definition in constructor :'||sqlerrm);

	    WHEN others THEN
	      arp_util_tax.debug('Exception in Constructor for AP  tax definition :'||sqlerrm);
	  END;



END ZX_P2P_DEF_AP_PREUPG;

/
