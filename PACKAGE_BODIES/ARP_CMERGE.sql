--------------------------------------------------------
--  DDL for Package Body ARP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CMERGE" as
/* $Header: ARPLARMB.pls 115.5 2003/07/02 11:43:30 hyoshiha ship $ */

procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

-- bug2778646 created
procedure MERGE_VALIDATION (req_id NUMBER, set_num NUMBER) is

   l_dummy   NUMBER;
   draft_cbi EXCEPTION;

   CURSOR c IS
     SELECT 1
     FROM   ra_customer_merges m
     WHERE  m.request_id = req_id
     AND    m.set_number = set_num
     AND EXISTS
     (
      SELECT 1
      FROM  ar_cons_inv ci
      WHERE ci.site_use_id IN (m.customer_site_id, m.duplicate_site_id)
      AND   ci.status = 'DRAFT'
     );

 BEGIN

   -- check if there is DRAFT CBI for merged customer site
   OPEN c;
   FETCH c INTO l_dummy;
   IF (c%FOUND) THEN
     RAISE draft_cbi;
   END IF;
   CLOSE c;

EXCEPTION
   WHEN DRAFT_CBI THEN
      arp_message.set_name('AR','AR_CUST_SITE_DRAFT_CBI') ;
      arp_message.set_error('ARP_CMERGE_ARCON.AR_CIN') ;
      raise;

end MERGE_VALIDATION;

begin

  arp_message.set_line( 'ARP_CMERGE.MERGE()+' );

  merge_validation(req_id , set_num );

  arp_cmerge_aratc.merge(req_id, set_num, process_mode);
  arp_cmerge_arcol.merge(req_id, set_num, process_mode);
  arp_cmerge_ardun.merge(req_id, set_num, process_mode);
  arp_cmerge_artax.merge(req_id, set_num, process_mode);
  arp_cmerge_arcon.merge(req_id, set_num, process_mode);
  arp_cmerge_artrx.merge(req_id, set_num, process_mode);

  arp_message.set_line( 'ARP_CMERGE.MERGE()-' );

EXCEPTION
  when others then
    raise;
end MERGE;

end ARP_CMERGE;

/
