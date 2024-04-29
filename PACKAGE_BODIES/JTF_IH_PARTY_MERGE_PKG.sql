--------------------------------------------------------
--  DDL for Package Body JTF_IH_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_PARTY_MERGE_PKG" AS
/* $Header: JTFIHPMB.pls 120.2 2006/02/16 23:33:17 nchouras ship $ */

-- Start of Comments
-- Package name     : JTF_IH_PARTY_MERGE_PKG
-- Purpose          : Merges duplicate parties in JTF_IH_INTERACTIONS table.

--
-- History
-- MM-DD-YYYY    NAME          		MODIFICATIONS
-- 01-04-2001    James Baldo Jr.      	Created.
-- 04-01-2002    Igor Aleshin       Fixed Bug 2295015 - itcrm tca merg: crmperf:jtf:party merge perf fixes
--                                  on crmimp (copy of crmap)
-- 06-24-2003    Igor Aleshin       Enh# 1846960 - Added support for Contact Party Ids columns
-- 05-07-2004	Igor Aleshin		Fixed File.sql.35 issue
--
-- End of Comments


G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'JTF_IH_PARTY_MERGE_PKG';
G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;



PROCEDURE JTF_IH_MERGE_PARTY (
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
   cursor c1 is
   select 1
   from   jtf_ih_interactions
   where  party_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30);
   l_count                      NUMBER(10);

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);
   s_Party_Type VARCHAR2(30);
BEGIN
   l_api_name := 'JTF_IH_MERGE_PARTY';
   l_count := 0;
   arp_message.set_line('JTF_IH_PARTY_MERGE_PKG.JTF_IH_MERGE_PARTY()+');

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


   -- In the case of JTF_IH_INTERACTIONS table, if party id 1000 got merged to party id 2000
   -- then, we have to update all records with customer_id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'JTF_IH_INTERACTIONS', FALSE);

	    open  c1;
	    close c1;
        select party_type into s_Party_Type from hz_parties where party_id = p_to_fk_id;
	    update jtf_ih_interactions
--	    set    party_id                = decode(party_id, p_to_fk_id, p_to_fk_id, party_id),
	    set    party_id                = p_to_fk_id,
	           last_update_date        = hz_utility_pub.last_update_date,
	           last_updated_by         = hz_utility_pub.user_id,
	           last_update_login       = hz_utility_pub.last_update_login,
               -- Enh# 1846960
               -- If Primary_Party_Id equals Party_Id then update it to new value.
               primary_party_id        = decode(primary_party_id, party_id, p_to_fk_id,primary_party_id),
               -- If Contact_Party_Id equals Primary_Party_ID and Primary_Party_ID is going to be
               -- not a person, then update Contact_Party_ID to NULL
               contact_party_id         = decode(nvl(contact_party_id,-1),-1,NULL,
                                                    decode(contact_party_id,primary_party_id,
                                                        (decode(s_Party_Type,'PERSON',p_to_fk_id,NULL)), contact_party_id)),
		   request_id              = hz_utility_pub.request_id,
		   program_application_id  = hz_utility_pub.program_application_id,
		   program_id              = hz_utility_pub.program_id,
		   program_update_date     = sysdate,
           object_version_number = object_version_number + 1      -- Bug# 2295015
            -- where  interaction_id = p_from_id;
            where party_id = p_from_fk_id;          -- Bug 2295015

            ----where  customer_id        = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'JTF_IH_INTERACTIONS  for party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
               --dbms_output.put_line('Busy');
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
           --dbms_output.put_line('Other ');
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
      -- update the doc_id value in JTF_IH_ACTIVITES for doc_ref
      -- (object_code) values that populate doc_id with party_id values
      update jtf_ih_activities
      set doc_id = p_to_fk_id
      where doc_id = p_from_fk_id
      and doc_ref IN (
                       select object_code
                       from jtf_objects_b
                       where from_table = 'HZ_PARTIES'
                     );
   end if;
END JTF_IH_MERGE_PARTY;
END  JTF_IH_PARTY_MERGE_PKG;

/
