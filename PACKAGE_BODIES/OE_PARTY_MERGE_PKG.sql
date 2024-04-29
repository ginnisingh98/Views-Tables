--------------------------------------------------------
--  DDL for Package Body OE_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PARTY_MERGE_PKG" AS
/* $Header: OEXPMRGB.pls 120.0 2005/06/01 23:06:41 appldev noship $ */


G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'OE_PARTY_MERGE_PKG';
G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;

PROCEDURE MERGE_ADJ_ATTRIBS_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
IS

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'ADJ_ATTRIB_PARTY_MERGE';
   l_count                      NUMBER(10)   := 0;
   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
  -- arp_message.set_line('OE_PARTY_MERGE_PKG.MERGE_ADJ_ATTRIBS()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has NOT changed (ie.Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id
   -- This check is not required for oe_price_adj_attribs

   if p_from_fk_id <> p_to_fk_id then
	    -- obtain lock on records to be updated.
      --arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
      --arp_message.set_token( 'TABLE_NAME', 'OE_PRICE_ADJ_ATTRIBS', FALSE );

       UPDATE /*+ index(S OE_PRICE_ADJ_ATTRIBS_N2) */ OE_PRICE_ADJ_ATTRIBS S
       SET  pricing_attr_value_from = to_char(p_to_fk_id),
            last_update_date = hz_utility_v2pub.last_update_date,
       	    last_updated_by = hz_utility_v2pub.user_id,
            last_update_login = hz_utility_v2pub.last_update_login,
      	    request_id =  hz_utility_v2pub.request_id,
     	    program_application_id = hz_utility_v2pub.program_application_id,
       	    program_id = hz_utility_v2pub.program_id,
       	    program_update_date = sysdate
          WHERE pricing_attr_value_from = to_char(p_from_fk_id)
                and (pricing_context = 'ASOPARTYINFO'  AND pricing_attribute = 'QUALIFIER_ATTRIBUTE1'
                     OR pricing_context = 'CUSTOMER' AND pricing_attribute ='QUALIFIER_ATTRIBUTE16'
                     OR pricing_context = 'CUSTOMER_GROUP' AND pricing_attribute = 'QUALIFIER_ATTRIBUTE3'
                     OR pricing_context = 'PARTY' AND pricing_attribute
                                    IN ('QUALIFIER_ATTRIBUTE1', 'QUALIFIER_ATTRIBUTE2')
                    );
         l_count := sql%rowcount;

          --arp_message.set_name('AR', 'AR_ROWS_UPDATED');
          --arp_message.set_token('NUM_ROWS', to_char(l_count) );

   end if;

EXCEPTION

         when others then
             fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
             FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
             FND_MSG_PUB.ADD;
             x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;

END MERGE_ADJ_ATTRIBS_PARTY;

PROCEDURE MERGE_ADJ_ATTRIBS_PARTY_SITE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
IS

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'ADJ_ATTRIB_PARTY_MERGE';
   l_count                      NUMBER(10)   := 0;
   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
  -- arp_message.set_line('OE_PARTY_MERGE_PKG.MERGE_ADJ_ATTRIBS()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has NOT changed (ie.Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id
   -- This check is not required for oe_price_adj_attribs

   if p_from_fk_id <> p_to_fk_id then
	    -- obtain lock on records to be updated.
      --arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
      --arp_message.set_token( 'TABLE_NAME', 'OE_PRICE_ADJ_ATTRIBS', FALSE );

       UPDATE /*+ index(S OE_PRICE_ADJ_ATTRIBS_N2) */ OE_PRICE_ADJ_ATTRIBS S
       SET  pricing_attr_value_from = to_char(p_to_fk_id),
            last_update_date = hz_utility_v2pub.last_update_date,
       	    last_updated_by = hz_utility_v2pub.user_id,
            last_update_login = hz_utility_v2pub.last_update_login,
      	    request_id =  hz_utility_v2pub.request_id,
     	    program_application_id = hz_utility_v2pub.program_application_id,
       	    program_id = hz_utility_v2pub.program_id,
       	    program_update_date = sysdate
          WHERE pricing_attr_value_from = to_char(p_from_fk_id)
          AND   (pricing_context = 'ASOPARTYINFO'
                   AND pricing_attribute IN ('QUALIFIER_ATTRIBUTE10','QUALIFIER_ATTRIBUTE11')
                 OR pricing_context = 'CUSTOMER'
                   AND pricing_attribute IN ('QUALIFIER_ATTRIBUTE17', 'QUALIFIER_ATTRIBUTE18')
                );

         l_count := sql%rowcount;

          --arp_message.set_name('AR', 'AR_ROWS_UPDATED');
          --arp_message.set_token('NUM_ROWS', to_char(l_count) );

   end if;

EXCEPTION

         when others then
             fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
             FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
             FND_MSG_PUB.ADD;
             x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;

END MERGE_ADJ_ATTRIBS_PARTY_SITE;

END OE_PARTY_MERGE_PKG;

/
