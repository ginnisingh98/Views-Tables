--------------------------------------------------------
--  DDL for Package Body JTF_FM_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_PARTY_MERGE_PKG" AS
/* $Header: JTFFMPMB.pls 120.0 2005/05/11 09:06:45 appldev ship $ */


G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'JTF_FM_PARTY_MERGE_PKG';
G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;



PROCEDURE JTF_FM_MERGE_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)
IS

   cursor c2 is
   select party_name
   from hz_parties
   where party_id = p_to_fk_id;



   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'JTF_FM_MERGE_PARTY';
   l_count                      NUMBER(10)   := 0;
   l_party_name                VARCHAR2(240);
   l_content_number             NUMBER;
   l_hist_req_id                NUMBER;
   l_submit_dt_tm               DATE;
   l_batch_number               NUMBER;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('JTF_FM_PARTY_MERGE_PKG.JTF_FM_MERGE_PARTY()+');

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

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id


   -- In the case of JTF_FM_CONTENT_HISTORY table, if party id 1000 got merged to party id 2000
   -- then, we have to update all records with customer_id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
      arp_message.set_name('AR', 'AR_LOCKING_TABLE');
      arp_message.set_token('TABLE_NAME', p_entity_name, FALSE);


      open c2;
      fetch c2 into l_party_name;
      close c2;

       IF (upper(p_entity_name) = 'JTF_FM_PREVIEWS_V')
       THEN
          update JTF_FM_PREVIEWS
          set fm_party_id        = p_to_fk_id,
	          last_update_date    = hz_utility_pub.last_update_date,
	          last_updated_by     = hz_utility_pub.user_id,
	          last_update_login   = hz_utility_pub.last_update_login
           where  fm_party_id    = p_from_fk_id;

       ELSIF (upper(p_entity_name) = 'JTF_FM_PROCESSED_V')
       THEN
           update JTF_FM_PROCESSED
           set party_id          = p_to_fk_id,
             party_name          = l_party_name,
	          last_update_date    = hz_utility_pub.last_update_date,
	          last_updated_by     = hz_utility_pub.user_id,
	          last_update_login   = hz_utility_pub.last_update_login
           where  party_id       = p_from_fk_id;
       ELSE
           update JTF_FM_CONTENT_HISTORY
           set party_id          = p_to_fk_id,
             party_name          = l_party_name,
	          last_update_date    = hz_utility_pub.last_update_date,
	          last_updated_by     = hz_utility_pub.user_id,
	          last_update_login   = hz_utility_pub.last_update_login
           where  party_id       = p_from_fk_id;
       END IF;

         l_count := sql%rowcount;

          arp_message.set_name('AR', 'AR_ROWS_UPDATED');
          arp_message.set_token('NUM_ROWS', to_char(l_count) );


      exception
        when resource_busy then
	        arp_message.set_line(g_proc_name || '.' || l_api_name ||
		        '; Could not obtain lock for records in table '  ||
               p_entity_name ||
			    ' for party_id = ' || p_from_fk_id );
              x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	        arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END JTF_FM_MERGE_PARTY;

END JTF_FM_PARTY_MERGE_PKG;

/
