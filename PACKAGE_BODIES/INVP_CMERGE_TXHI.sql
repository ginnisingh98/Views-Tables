--------------------------------------------------------
--  DDL for Package Body INVP_CMERGE_TXHI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVP_CMERGE_TXHI" as
/* $Header: invcmtb.pls 120.1 2006/11/24 12:44:12 pannapra noship $ */

/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count               NUMBER := 0;

/*--------------------------- PRIVATE ROUTINES ------------------------------*/

/*--------------------------- MTL_DEMAND ------------------------------------*/

procedure INV_MUT (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

   CURSOR C1 IS
   SELECT NULL
   FROM   MTL_UNIT_TRANSACTIONS
   WHERE  customer_id in  (select racm.duplicate_id
                           from   ra_customer_merges  racm
                           where  racm.process_flag = 'N'
                           and    racm.request_id = req_id
			   and    racm.set_number = set_num)
      FOR UPDATE NOWAIT;
   mut_cust_flag NUMBER; /*Bug#5574255.*/

BEGIN
 arp_message.set_line( 'INVP_CMERGE_TXHI.INV_MUT()+' );
 /*Bug#5574255. Modified code in such a way that LOCKING of rows of
   MTL_UNIT_TRANSACTIONS or updation of customer_id in MTL_UNIT_TRANSACTIONS
   happens only if there is at least one row in MTL_UNIT_TRANSACTIONS with
   non-zero and non-null customer_id.*/

 BEGIN
   SELECT 1
   INTO mut_cust_flag
   FROM dual
   WHERE EXISTS ( SELECT  1
                  FROM  mtl_unit_transactions
                  WHERE customer_id <> 0);
 EXCEPTION WHEN OTHERS THEN
     mut_cust_flag := 0;
 END;

/*-----------------------+
 | MTL_UNIT_TRANSACTIONS |
 +-----------------------*/
 /* try to lock the table first */
 IF ( mut_cust_flag <> 0) THEN
   IF (process_mode = 'LOCK') then
    arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'MTL_UNIT_TRANSACTIONS', FALSE );

    OPEN C1;
    CLOSE C1;

   ELSE

/* customer level update */

   arp_message.set_name('AR', 'AR_UPDATING_TABLE');
   arp_message.set_token('TABLE_NAME', 'MTL_UNIT_TRANSACTIONS', FALSE);
   arp_message.set_line('customer level : customer_id');

    UPDATE MTL_UNIT_TRANSACTIONS  yt
    set    customer_id = (select distinct racm.customer_id
                          from   ra_customer_merges racm
                          where  yt.customer_id =
                                    racm.duplicate_id
                          and    racm.process_flag = 'N'
                          and    racm.request_id = req_id
			  and    racm.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  customer_id in (select racm.duplicate_id
                           from   ra_customer_merges  racm
                           where  racm.process_flag = 'N'
                           and    racm.request_id = req_id
			   and    racm.set_number = set_num);

     g_count := sql%rowcount;

   /* Number of rows updates */
     arp_message.set_name('AR', 'AR_ROWS_UPDATED');
     arp_message.set_token('NUM_ROWS', to_char(g_count));

   END IF;
 END IF;

  arp_message.set_line( 'INVP_CMERGE_TXHI.INV_MUT()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'INVP_CMERGE_TXHI.INV_MUT');
    raise;

END;
/*------------------------MTL_MOVEMENT_STATISTICS---------------------------*/

/*
PROCEDURE INV_MMS (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) IS

CURSOR c1 IS
    SELECT   movement_id
    FROM     mtl_movement_statistics
      WHERE  ship_to_customer_id IN (
                     SELECT rcm.duplicate_id
                     FROM   ra_customer_merges rcm
                     WHERE  rcm.process_flag = 'N'
                       AND  rcm.request_id   = req_id
                       AND  rcm.set_number   = set_num)
                 OR bill_to_customer_id IN (
                     SELECT rcm.duplicate_id
                     FROM   ra_customer_merges rcm
                     WHERE  rcm.process_flag = 'N'
                       AND  rcm.request_id   = req_id
                       AND  rcm.set_number   = set_num)
       FOR UPDATE NOWAIT;

CURSOR c2 IS
    SELECT   movement_id
    FROM     mtl_movement_statistics
      WHERE ship_to_site_use_id IN (
                     SELECT rcm.duplicate_site_id
                     FROM   ra_customer_merges rcm
                     WHERE  rcm.process_flag = 'N'
                       AND  rcm.request_id   = req_id
                       AND  rcm.set_number   = set_num)
                 OR bill_to_site_use_id IN (
                     SELECT rcm.duplicate_site_id
                     FROM   ra_customer_merges rcm
                     WHERE  rcm.process_flag = 'N'
                       AND  rcm.request_id   = req_id
                       AND  rcm.set_number   = set_num)
        FOR UPDATE NOWAIT;

BEGIN

  arp_message.set_line( 'INV_CMERGE_TXHI.INV_MMS()+' );


 +--------------------------------------------------+
   |         MTL_MOVEMENT_STATISTICS                  |
   +--------------------------------------------------


IF (process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE' );
  arp_message.set_token( 'TABLE_NAME', 'MTL_MOVEMENT_STATISTICS',FALSE );


--     **  Lock For Customer Level Update           **
       open  c1;
       close c1;

--     **  Lock For Site Level Update               **
       open  c2;
       close c2;

ELSE

--     **  CUSTOMER LEVEL UPDATE                    **

 arp_message.set_name('AR', 'AR_UPDATING_TABLE');
 arp_message.set_token('TABLE_NAME', 'MTL_MOVEMENT_STATISTICS', FALSE);
 arp_message.set_line('customer level : customer_id');

          UPDATE mtl_movement_statistics mtl
             SET (ship_to_customer_id,
                  bill_to_customer_id) = (
                   SELECT distinct
                          decode(mtl.ship_to_customer_id, rcm.duplicate_id,
                                 rcm.customer_id, mtl.ship_to_customer_id),
                          decode(mtl.bill_to_customer_id, rcm.duplicate_id,
                                 rcm.customer_id, mtl.bill_to_customer_id)
                   FROM  ra_customer_merges rcm
                   WHERE mtl.ship_to_customer_id = rcm.duplicate_id
                      OR mtl.bill_to_customer_id = rcm.duplicate_id),
                 last_update_date = sysdate,
                 last_updated_by = arp_standard.profile.user_id,
                 last_update_login = arp_standard.profile.last_update_login
              WHERE ship_to_customer_id IN (
                     SELECT rcm.duplicate_id
                     FROM   ra_customer_merges rcm
                     WHERE  rcm.process_flag = 'N'
                       AND  rcm.request_id   = req_id
                       AND  rcm.set_number   = set_num)
                 OR bill_to_customer_id IN (
                     SELECT rcm.duplicate_id
                     FROM   ra_customer_merges rcm
                     WHERE  rcm.process_flag = 'N'
                       AND  rcm.request_id   = req_id
                       AND  rcm.set_number   = set_num);

g_count := sql%rowcount;
   -- Number of rows updates
   arp_message.set_name('AR', 'AR_ROWS_UPDATED');
   arp_message.set_token('NUM_ROWS', to_char(g_count));


--     **  SITE LEVEL UPDATE                       **
 arp_message.set_name('AR', 'AR_UPDATING_TABLE');
 arp_message.set_token('TABLE_NAME', 'MTL_MOVEMENT_STATISTICS', FALSE);
 arp_message.set_line('customer level : customer_site_id');

          UPDATE mtl_movement_statistics mtl
             SET (ship_to_site_use_id,
                  bill_to_site_use_id) = (
                   SELECT distinct
                         decode(mtl.ship_to_site_use_id, rcm.duplicate_site_id,
                                rcm.customer_site_id, mtl.ship_to_site_use_id),
                         decode(mtl.bill_to_site_use_id, rcm.duplicate_site_id,
                                rcm.customer_site_id, mtl.bill_to_site_use_id)
                   FROM  ra_customer_merges rcm
                   WHERE mtl.ship_to_site_use_id = rcm.duplicate_site_id
                      OR mtl.bill_to_site_use_id = rcm.duplicate_site_id),
                 last_update_date = sysdate,
                 last_updated_by = arp_standard.profile.user_id,
                 last_update_login = arp_standard.profile.last_update_login
               WHERE ship_to_site_use_id IN (
                     SELECT rcm.duplicate_site_id
                     FROM   ra_customer_merges rcm
                     WHERE  rcm.process_flag = 'N'
                       AND  rcm.request_id   = req_id
                       AND  rcm.set_number   = set_num)
                 OR bill_to_site_use_id IN (
                     SELECT rcm.duplicate_site_id
                     FROM   ra_customer_merges rcm
                     WHERE  rcm.process_flag = 'N'
                       AND  rcm.request_id   = req_id
                       AND  rcm.set_number   = set_num);


g_count := sql%rowcount;

   -- Number of rows updates
   arp_message.set_name('AR', 'AR_ROWS_UPDATED');
   arp_message.set_token('NUM_ROWS', to_char(g_count));

END IF;

  arp_message.set_line( 'INVP_CMERGE_TXHI.INV_MMS()-' );

EXCEPTION
  when others then
    arp_message.set_error( 'INVP_CMERGE_TXHI.INV_MMS');
    raise;

END;
*/

/*---------------------------- PUBLIC ROUTINES ------------------------------*/

PROCEDURE MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
BEGIN

  arp_message.set_line( 'INVP_CMERGE_TXHI.MERGE()+' );

  INV_MUT( req_id, set_num, process_mode );

-- call INV_MMS to do customer merge on mtl_movement_statistics table
-- Bug 2423619
-- No Movement stat conversion required
-- removing the call
--- INV_MMS ( req_id, set_num, process_mode );
--

  arp_message.set_line ( 'INVP_CMERGE_TXHI.MERGE()-' );

END MERGE;
end INVP_CMERGE_TXHI;

/
