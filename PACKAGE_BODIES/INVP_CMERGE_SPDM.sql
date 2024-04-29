--------------------------------------------------------
--  DDL for Package Body INVP_CMERGE_SPDM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVP_CMERGE_SPDM" as
/* $Header: invcmspb.pls 120.1 2005/07/01 13:55:46 appldev ship $ */

/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count               NUMBER := 0;

/*--------------------------- PRIVATE ROUTINES ------------------------------*/

/*--------------------------- MTL_DEMAND ------------------------------------*/

procedure INV_MD (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

--Split the cursor C1 into three cursors C1, C1 and C3 for BUG # 1084777

   CURSOR C1 IS
   SELECT NULL
   FROM   MTL_DEMAND
   WHERE  bill_to_site_use_id in (select racm.duplicate_site_id
                       from   ra_customer_merges  racm
                       where  racm.process_flag = 'N'
                       and    racm.request_id = req_id
                       and    racm.set_number = set_num)
   FOR UPDATE NOWAIT;

   CURSOR C2 IS
   SELECT NULL
   FROM   MTL_DEMAND
   WHERE  ship_to_site_use_id  in (select racm.duplicate_site_id
                       from   ra_customer_merges  racm
                       where  racm.process_flag = 'N'
                       and    racm.request_id = req_id
                       and    racm.set_number = set_num)
   FOR UPDATE NOWAIT;

   CURSOR C3 IS
   SELECT NULL
   FROM   MTL_DEMAND
   WHERE  customer_id in (select racm.duplicate_id
                           from   ra_customer_merges  racm
                           where  racm.process_flag = 'N'
                           and    racm.request_id = req_id
                           and    racm.set_number = set_num)
          and ship_to_site_use_id is NULL
          and bill_to_site_use_id is NULL
   FOR UPDATE NOWAIT;


BEGIN
 arp_message.set_line( 'INVP_CMERGE_SPDM.INV_MD()+' );

/*------------+
 | MTL_DEMAND |
 +------------*/
 /* try to lock the table first */
 IF (process_mode = 'LOCK') then
  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'MTL_DEMAND', FALSE );

  OPEN C1;
  CLOSE C1;

  OPEN C2;
  CLOSE C2;

  OPEN C3;
  CLOSE C3;

 ELSE

/* customer and site level */

 arp_message.set_name('AR', 'AR_UPDATING_TABLE');
 arp_message.set_token('TABLE_NAME', 'MTL_DEMAND',FALSE);
 arp_message.set_line('site level update : ship to and bill to site use id');

    UPDATE MTL_DEMAND yt
    set customer_id = (select distinct racm.customer_id
		        from ra_customer_merges racm
		        where yt.customer_id = racm.duplicate_id
			and (yt.ship_to_site_use_id = racm.duplicate_site_id
                             or yt.bill_to_site_use_id = racm.duplicate_site_id)
                        and racm.process_flag= 'N'
			and racm.request_id = req_id
			and racm.set_number = set_num),
         ship_to_site_use_id = (select distinct racm.customer_site_id
                        from   ra_customer_merges racm
                      	where  yt.customer_id = racm.duplicate_id
                        and    yt.ship_to_site_use_id = racm.duplicate_site_id
                        and    racm.process_flag = 'N'
                        and    racm.request_id = req_id
			and    racm.set_number = set_num),
         bill_to_site_use_id = (select distinct racm.customer_site_id
                        from   ra_customer_merges racm
                      	where  yt.customer_id = racm.duplicate_id
                        and    yt.bill_to_site_use_id = racm.duplicate_site_id
                        and    racm.process_flag = 'N'
                        and    racm.request_id = req_id
			and    racm.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id = arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  ship_to_site_use_id in (select racm.duplicate_site_id
                       		   from   ra_customer_merges  racm
                    		   where  racm.process_flag = 'N'
                   		   and    racm.request_id = req_id
		     	    	   and    racm.set_number = set_num)
    and    bill_to_site_use_id in (select racm.duplicate_site_id
                       		   from   ra_customer_merges  racm
                    		   where  racm.process_flag = 'N'
                   		   and    racm.request_id = req_id
		     	    	   and    racm.set_number = set_num);

   g_count := sql%rowcount;

   /* Number of rows updates */
   arp_message.set_name('AR', 'AR_ROWS_UPDATED');
   arp_message.set_token('NUM_ROWS', to_char(g_count));


/* site level update */
/* for bill to site use id */
 arp_message.set_name('AR', 'AR_UPDATING_TABLE');
 arp_message.set_token('TABLE_NAME', 'MTL_DEMAND',FALSE);
 arp_message.set_line('site level update : bill to site use id');

    UPDATE MTL_DEMAND yt
    set    (customer_id,
            bill_to_site_use_id) = (select distinct racm.customer_id,
                                        racm.customer_site_id
                        from   ra_customer_merges racm
                        where  yt.customer_id = racm.duplicate_id
                        and    yt.bill_to_site_use_id = racm.duplicate_site_id
                        and    racm.process_flag = 'N'
                        and    racm.request_id = req_id
			and    racm.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  bill_to_site_use_id in (select racm.duplicate_site_id
                       		   from   ra_customer_merges  racm
                       		   where  racm.process_flag = 'N'
                       		   and    racm.request_id = req_id
		       		   and    racm.set_number = set_num)
    and    (ship_to_site_use_id is NULL
	    or ship_to_site_use_id not in (select racm.duplicate_site_id
				   from ra_customer_merges racm
			 	   where racm.process_flag = 'N'
			 	   and racm.request_id = req_id
				   and racm.set_number = set_num));

   g_count := sql%rowcount;

   /* Number of rows updates */
   arp_message.set_name('AR', 'AR_ROWS_UPDATED');
   arp_message.set_token('NUM_ROWS', to_char(g_count));


/* site level update */
/* for ship to site use id */

 arp_message.set_name('AR', 'AR_UPDATING_TABLE');
 arp_message.set_token('TABLE_NAME', 'MTL_DEMAND',FALSE);
 arp_message.set_line('site level update : ship to site use id');

    UPDATE MTL_DEMAND yt
    set    (customer_id,
            ship_to_site_use_id) = (select distinct racm.customer_id,
                                        racm.customer_site_id
                        from   ra_customer_merges racm
                        where  yt.customer_id = racm.duplicate_id
                        and    yt.ship_to_site_use_id = racm.duplicate_site_id
                        and    racm.process_flag = 'N'
                        and    racm.request_id = req_id
			and    racm.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  ship_to_site_use_id in (select racm.duplicate_site_id
                       		   from   ra_customer_merges  racm
                       		   where  racm.process_flag = 'N'
                       		   and    racm.request_id = req_id
		       		   and    racm.set_number = set_num)
    and    (bill_to_site_use_id is NULL
	    or bill_to_site_use_id not in (select racm.duplicate_site_id
				   from ra_customer_merges racm
			 	   where racm.process_flag = 'N'
			 	   and racm.request_id = req_id
				   and racm.set_number = set_num));

   g_count := sql%rowcount;

   /* Number of rows updates */
   arp_message.set_name('AR', 'AR_ROWS_UPDATED');
   arp_message.set_token('NUM_ROWS', to_char(g_count));

/* customer level update */

 arp_message.set_name('AR', 'AR_UPDATING_TABLE');
 arp_message.set_token('TABLE_NAME', 'MTL_DEMAND', FALSE);
 arp_message.set_line('customer level : customer_id');

    UPDATE MTL_DEMAND  yt
    set    customer_id = (select distinct racm.customer_id
                          from   ra_customer_merges racm
                          where  yt.customer_id =
                                    racm.duplicate_id
                          and    racm.process_flag = 'N'
                          and    racm.request_id = req_id
			  and    racm.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  customer_id in (select racm.duplicate_id
                           from   ra_customer_merges  racm
                           where  racm.process_flag = 'N'
                           and    racm.request_id = req_id
			   and    racm.set_number = set_num)
    and ship_to_site_use_id is NULL
    and bill_to_site_use_id is NULL;

   g_count := sql%rowcount;

   /* Number of rows updates */
   arp_message.set_name('AR', 'AR_ROWS_UPDATED');
   arp_message.set_token('NUM_ROWS', to_char(g_count));

END IF;

  arp_message.set_line( 'INVP_CMERGE_SPDM.INV_MD()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'INVP_CMERGE_SPDM.INV_MD');
    raise;

END;


/*---------------------------- PUBLIC ROUTINES ------------------------------*/

PROCEDURE MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
BEGIN

  arp_message.set_line( 'INVP_CMERGE_SPDM.MERGE()+' );

  INV_MD( req_id, set_num, process_mode );

  arp_message.set_line( 'INVP_CMERGE_SPDM.MERGE()-' );

END MERGE;
end INVP_CMERGE_SPDM;

/
