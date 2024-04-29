--------------------------------------------------------
--  DDL for Package Body ISC_DEPOT_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DEPOT_PARTY_MERGE_PKG" AS
/* $Header: iscdepotetlpb.pls 120.0 2005/05/25 17:21:47 appldev noship $ */
procedure REPAIR_ORDERS_F_M(
                        p_entity_name in varchar2,
                        p_from_id in number,
                        p_to_id in out nocopy number,
                        p_from_fk_id in number,
                        p_to_fk_id in number,
                        p_parent_entity_name in varchar2,
                        p_batch_id in number,
                        p_batch_party_id in number,
                        p_return_status in out nocopy varchar2)
IS

  l_merge_reason_code	hz_merge_batch.merge_reason_code%type;

BEGIN

  arp_message.set_line('ISC_DEPOT_PARTY_MERGE_PKG.REPAIR_ORDERS_F_M()+');

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT merge_reason_code
     INTO   l_merge_reason_code
     FROM   hz_merge_batch
    WHERE  batch_id  = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' THEN
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      NULL;
   ELSE
      -- if there are any validations to be done, include it in this section
      NULL;
   END IF;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   IF p_from_fk_id = p_to_fk_id THEN
      p_to_id := p_from_id;
      RETURN;
   ELSE
    update isc_dr_repair_orders_f
    set customer_id = p_to_fk_id,
        last_update_date = hz_utility_pub.last_update_date,
      	last_updated_by = hz_utility_pub.user_id,
     	last_update_login = hz_utility_pub.last_update_login
    where customer_id = p_from_fk_id;
  END IF;

END REPAIR_ORDERS_F_M;
END ISC_DEPOT_PARTY_MERGE_PKG;

/
