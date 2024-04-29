--------------------------------------------------------
--  DDL for Package Body CS_CH_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CH_PARTY_MERGE_PKG" AS
/* $Header: cschmpgb.pls 120.0 2006/02/09 16:38:32 spusegao noship $ */

-- Start of Comments
-- Package name     : CS_CH_PARTY_MERGE_PKG
-- Purpose          : Merges duplicate party_sites in Service tables. The
--                    Service tables that need to be considered
--                    are:
--                    CS_ESTIMATE_DETAILS and CS_CHG_SUB_RESTRICTIONS.
--
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 11-20-2000    aseethep      Created.
-- 10-22-2001    tkochend      Removed commit statement
-- 11-08-2002    mviswana      Added NOCOPY Functionality to file
-- 12-04-2002    tkochend      Moved to correct driver phase
-- 05-04-2003    mviswana      Added the new 11.5.9 TCA FK from cs_estimate_details
-- 06-04-2003    mviswana      Changed the procedure to merge sites to follow TCA stds of using
--                             p_from_fk_id
-- 08-12-2003    cnemalik      For 11.5.10, added the new Bill To Customer Restriction in the
--                             Auto Submission Restriction Table.
-- 04-28-2004    mviswana      Added logic to check for duplicate active restrictions after the merge is done
--                             Fix for Bug # 3599517
-- End of Comments

G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'CS_CH_PARTY_MERGE_PKG';
G_FILE_NAME        CONSTANT  VARCHAR2(12)  := 'cschpmgb.pls';
G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.CONC_LOGIN_ID;


TYPE ROWID_TBL IS TABLE OF ROWID
INDEX BY BINARY_INTEGER;


-- The following procedure merges CS_ESTIMATE_DETAILS columns:
-- bill_to_party_id
-- ship_to_party_id
-- bill_to_contact_id
-- ship_to_contact_id
-- The above columns are FKs to HZ_PARTIES.PARTY_ID

PROCEDURE CS_CHG_ALL_MERGE_PARTY (
    p_entity_name                IN          VARCHAR2,
    p_from_id                    IN          NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN          NUMBER,
    p_to_fk_id                   IN          NUMBER,
    p_parent_entity_name         IN          VARCHAR2,
    p_batch_id                   IN          NUMBER,
    p_batch_party_id             IN          NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)

IS
   -- cursor fetches all the records that need to be merged.
   cursor c1 is
   select rowid
   from   cs_estimate_details
   where  p_from_fk_id in (bill_to_contact_id, ship_to_contact_id,
                           bill_to_party_id, ship_to_party_id )
   for    update nowait;

   l_rowid_tbl                  ROWID_TBL;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CS_CHG_ALL_MERGE_PARTY';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

  BEGIN

     arp_message.set_line('CS_CH_PARTY_MERGE_PKG.CS_CH_ALL_MERGE_SITE_ID()+');

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

     if p_from_fk_id <> p_to_fk_id then
       begin
         -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CS_ESTIMATE_DETAILS', FALSE);

         open  c1;
         fetch c1 bulk collect into l_rowid_tbl;
         close c1;

         -- if no records were found to be updated then stop and return to calling prg.
         if l_rowid_tbl.count = 0 then
            RETURN;
         end if;

         forall i in 1..l_rowid_tbl.count
         update cs_estimate_details
         set    bill_to_contact_id    = decode(bill_to_contact_id, p_from_fk_id, p_to_fk_id, bill_to_contact_id),
                ship_to_contact_id    = decode(ship_to_contact_id, p_from_fk_id, p_to_fk_id, ship_to_contact_id),
                bill_to_party_id      = decode(bill_to_party_id,   p_from_fk_id, p_to_fk_id, bill_to_party_id),
                ship_to_party_id      = decode(ship_to_party_id,   p_from_fk_id, p_to_fk_id, ship_to_party_id),
                object_version_number = object_version_number + 1,
                last_update_date      = SYSDATE,
                last_updated_by       = G_USER_ID,
                last_update_login     = G_LOGIN_ID
         where  rowid                 = l_rowid_tbl(i);

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

       exception
           when resource_busy then
             arp_message.set_line(g_proc_name || '.' || l_api_name || '; Could not obtain lock for records in table '  ||
                          'CS_ESTIMATE_DETAILS  for bill_to_party_id / ship_to_party_id ' ||
                          'bill_to_contact_id / ship_to_contact_id  = ' || p_from_fk_id );
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;

           when others then
             arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       end;

     end if;  -- if p_from_fk_id <> p_to_fk_id

  END  CS_CHG_ALL_MERGE_PARTY ;


-- The following procedure merges CS_ESTIMATE_DETAILS columns:
-- invoice_to_org_id
-- ship_to_org_id

PROCEDURE  CS_CHG_ALL_MERGE_SITE_ID(
    p_entity_name                IN         VARCHAR2,
    p_from_id                    IN         NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN         NUMBER,
    p_to_fk_id                   IN         NUMBER,
    p_parent_entity_name         IN         VARCHAR2,
    p_batch_id                   IN         NUMBER,
    p_batch_party_id             IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)

IS

 -- Added for bug # 2983666
 -- cursor fetches all the records that need to be merged.
   cursor c1 is
   select rowid
   from   cs_estimate_details
   where  p_from_fk_id in (invoice_to_org_id, ship_to_org_id)
   for    update nowait;

   l_rowid_tbl                  ROWID_TBL;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CS_CH_ALL_MERGE_SITE_ID';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('CS_CH_PARTY_MERGE_PKG.CS_CH_ALL_MERGE_SITE_ID()+');

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


   -- In the case of CS_ESTIMATE_DETAILS table, we store invoice_to_org_id
   -- and ship_to_org_id  which are forign keys to HZ_PARTY_SITES.PARTY_SITE_ID.
   -- If the party who is tied to this site has been merged then, it is possible
   -- that this site use id is being transferred under the new party or it
   -- may have been deleted if its a duplicate party_site_use_id


   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CS_ESTIMATE_DETAILS', FALSE);

	    open  c1;
            fetch c1 bulk collect into l_rowid_tbl;
	    close c1;

            -- if no records were found to be updated then stop and return to calling prg.
            if l_rowid_tbl.count = 0 then
              RETURN;
            end if;


          -- Commented for bug # 2983666
          /*

          --   dbms_output.put_line('Beggining of Update');
	    update cs_estimate_details
	    set    invoice_to_org_id = decode(invoice_to_org_id, p_from_fk_id, p_to_fk_id, invoice_to_org_id),
			 ship_to_org_id = decode(ship_to_org_id,p_from_fk_id,p_to_fk_id,ship_to_org_id),
	           last_update_date    = SYSDATE,
	           last_updated_by     = G_USER_ID,
	           last_update_login   = G_LOGIN_ID
			 where estimate_detail_id = p_from_id;

           */

         -- Added for bug # 2983666
         --   dbms_output.put_line('Beggining of Update');
         forall i in 1..l_rowid_tbl.count
         update cs_estimate_details
            set    invoice_to_org_id = decode(invoice_to_org_id, p_from_fk_id, p_to_fk_id, invoice_to_org_id),
                   ship_to_org_id = decode(ship_to_org_id,p_from_fk_id,p_to_fk_id,ship_to_org_id),
                   last_update_date    = SYSDATE,
                   last_updated_by     = G_USER_ID,
                   last_update_login   = G_LOGIN_ID
         where  rowid = l_rowid_tbl(i);



         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
	    when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'CS_ESTIMATE_DETAILS  for invoice_to_org_id/ship_to_org_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;

END CS_CHG_ALL_MERGE_SITE_ID;

-- The following procedure merges CS_CHG_SUB_RESTRICTIONS columns:
-- value_object_id

PROCEDURE  CS_CHG_ALL_SETUP_PARTY(
    p_entity_name                IN         VARCHAR2,
    p_from_id                    IN         NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN         NUMBER,
    p_to_fk_id                   IN         NUMBER,
    p_parent_entity_name         IN         VARCHAR2,
    p_batch_id                   IN         NUMBER,
    p_batch_party_id             IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)

IS
--when value_object_id is equal to the from_party_id and restriction type is bill_to_customer
--then process all rows.
--cursor fetches all the records that need to be merged.
   cursor c1 is
   select rowid
   from   cs_chg_sub_restrictions
   where  value_object_id = p_from_fk_id
   and    restriction_type = 'BILL_TO_CUSTOMER'
   for    update nowait;

--add cursor to check for active restrictions which are of p_to_fk_id
--Fix for Bug # 3599517
  cursor c_active_restrictions is
  select restriction_id, value_object_id
    from cs_chg_sub_restrictions
   where restriction_type = 'BILL_TO_CUSTOMER'
     and end_date_active IS NULL;


   l_rowid_tbl                  ROWID_TBL;
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CS_CHG_ALL_SETUP_PARTY';
   l_count                      NUMBER(10)   := 0;
   l_from_restriction_id        NUMBER;
   l_to_match_found             VARCHAR2(1) := 'N';
   l_from_match_found           VARCHAR2(1) := 'N';

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('CS_CH_PARTY_MERGE_PKG.CS_CHG_ALL_SETUP_PARTY()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;


   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if   l_merge_reason_code = 'DUPLICATE' then
        null;
   else
        -- if there are any validations to be done, include it in this section
        null;
   end if;

   if   p_from_fk_id = p_to_fk_id then
        x_to_id := p_from_id;
        return;
   end if;

   if   p_from_fk_id <> p_to_fk_id then
        begin
         -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CS_CHG_SUB_RESTRICTIONS', FALSE);

         open  c1;
         fetch c1 bulk collect into l_rowid_tbl;
         close c1;

         -- if no records were found to be updated then stop and return to calling prg.
         if l_rowid_tbl.count = 0 then
            RETURN;
         end if;

         --check for active restrictions of 'BILL_TO_CIUSTOMER' TYPE
         --Fix for Bug # 3599517
         for  v_active_restrictions IN c_active_restrictions LOOP
           IF v_active_restrictions.value_object_id = p_from_fk_id THEN
             l_from_match_found := 'Y';
             l_from_restriction_id := v_active_restrictions.restriction_id;
           ELSIF v_active_restrictions.value_object_id = p_to_fk_id THEN
             l_to_match_found := 'Y';
           ELSE
             null;
           END IF;
           EXIT WHEN l_from_match_found = 'Y' AND
           l_to_match_found = 'Y';
         END LOOP;

         forall i in 1..l_rowid_tbl.count
         update cs_chg_sub_restrictions
         set    value_object_id    = decode(value_object_id, p_from_fk_id, p_to_fk_id,value_object_id),
                object_version_number = object_version_number + 1,
                last_update_date      = SYSDATE,
                last_updated_by       = G_USER_ID,
                last_update_login     = G_LOGIN_ID
         where  rowid                 = l_rowid_tbl(i);

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

         --go back and end date the active restriction which had p_from_fk_id merged to
         --p_to_fk_id since there can only be one active restriction at any one point
         --Fix for Bug # 3599517
         IF l_to_match_found = 'Y' AND
            l_from_match_found = 'Y' THEN
            update cs_chg_sub_restrictions
               set end_date_active = SYSDATE - 1
             where restriction_id = l_from_restriction_id;
         ELSE
            null;
         END IF;



 exception
           when resource_busy then
             arp_message.set_line(g_proc_name || '.' || l_api_name || '; Could not obtain lock for records in table '  || 'CS_CHG_SUB_RESTRICTIONS  for value_object_id' || 'bill_to_contact_id / ship_to_contact_id  = ' || p_from_fk_id );
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;

           when others then
             arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       end;

     end if;  -- if p_from_fk_id <> p_to_fk_id

END CS_CHG_ALL_SETUP_PARTY;




END  CS_CH_PARTY_MERGE_PKG;

/
