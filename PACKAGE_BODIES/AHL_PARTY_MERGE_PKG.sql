--------------------------------------------------------
--  DDL for Package Body AHL_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PARTY_MERGE_PKG" AS
/* $Header: AHLPMRGB.pls 115.17 2003/05/16 20:57:49 sracha noship $ */
-- Start of Comments
-- Package name     : AHL_PARTY_MERGE_PKG
-- Purpose          : Merges duplicate parties in Advanced Service
--		      Online tables. The
--                    Tables that need to be considered for
--                    Party Merge are:
--			AHL_DOCUMENTS_B
--			AHL_SUPPLIER_DOCUMENTS
--			AHL_RECIPIENT_DOCUEMTNS
--			AHL_SUBSCRIPTIONS_B
--			AHL_DOC_REVISIONS_B
--			AHL_DOC_REVISION_COPIES
--
--			AHL_OPERATIONS_B
--			AHL_OPERATIONS_H_B
--			AHL_ROUTES_B
--			AHL_ROUTES_H_B
--
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 07-30-2001    vrankaiy      Created.
-- 12-20-2001    jeli          Added the four entities for RM.
--
-- 04-11-2002    ssurapan      Bug#2271298
--                Refer to bug # 1539248 for party merge registration details.
-- 04-07-2003    jaramana      Added a routine for OSP (Customer)
--
-- End of Comments


G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'AHL_PARTY_MERGE_PKG';
G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;

-- Merge AHL_DOCUMENTS_B.SOURCE_PARTY_ID

PROCEDURE AHL_DI_SOURCE_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_documents_b
   where  source_party_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_DI_SOURCE_PARTY';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_DI_SOURCE_PARTY()+');

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


   -- In the case of AHL_DOCUMENTS_B table, if source party id 1000 got merged to source party id 2000
   -- then, we have to update all records with source_party_id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'AHL_DOCUMENTS_B', FALSE);

	    open  c1;
	    close c1;

	    update ahl_documents_b
	    set    source_party_id           =  p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  source_party_id    = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_DOCUMENTS_B  for source_party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_DI_SOURCE_PARTY;


-- Merge AHL_SUPPLIER_DOCUMENTS.SUPPLIER_ID

PROCEDURE AHL_DI_SUPPLIER (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_supplier_documents
   where  supplier_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_DI_SUPPLIER';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   if ( AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PO') IN ('I','S') ) then
	return;
   end if;
   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_DI_SUPPLIER()+');

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


   -- In the case of AHL_SUPPLIER_DOCUMENTS table, if supplier id 1000 got merged to supplier id 2000
   -- then, we have to update all records with supplier_id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'AHL_SUPPLIER_DOCUMENTS', FALSE);

	    open  c1;
	    close c1;

	    update ahl_supplier_documents
	    set    supplier_id           =  p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  supplier_id        = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_SUPPLIER_DOCUMENTS  for supplier_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_DI_SUPPLIER;

-- Merge AHL_RECIPIENT_DOCUMENTS.RECIPIENT_PARTY_ID

PROCEDURE AHL_DI_RECIPIENT_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_recipient_documents
   where  recipient_party_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_DI_RECIPIENT_PARTY';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_DI_RECIPIENT_PARTY()+');

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


   -- In the case of AHL_RECIPIENT_DOCUMENTS table, if recipient party id 1000 got merged to recipient party id 2000
   -- then, we have to update all records with recipient_party_id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'AHL_RECIPIENT_DOCUMENTS', FALSE);

	    open  c1;
	    close c1;

	    update ahl_recipient_documents
	    set    recipient_party_id           =  p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  recipient_party_id = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_RECIPIENT_DOCUMENTS  for recipient_party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_DI_RECIPIENT_PARTY;

-- Merge AHL_SUBSCRIPTIONS_B.REQUESTED_BY_PARTY_ID

PROCEDURE AHL_DI_REQUESTED_BY_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_subscriptions_b
   where  requested_by_party_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_DI_REQUESTED_BY_PARTY ';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   if ( AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PER') IN ('I','S') ) then
	return;
   end if;
   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_DI_REQUESTED_BY_PARTY ()+');

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


   -- In the case of AHL_SUBSCRIPTIONS_B table, if requested by party id 1000 got merged to requested by party id 2000
   -- then, we have to update all records with requested by party id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'AHL_SUBSCRIPTIONS_B', FALSE);

	    open  c1;
	    close c1;

	    update ahl_subscriptions_b
	    set    requested_by_party_id           =  p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  requested_by_party_id   = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_SUBSCRIPTIONS_B  for requested_by_party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_DI_REQUESTED_BY_PARTY ;

-- Merge AHL_SUBSCRIPTIONS_B.SUBSCRIBED_FRM_PARTY_ID

PROCEDURE AHL_DI_SUBSCRIBED_FRM_PARTY(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_subscriptions_b
   where  SUBSCRIBED_FRM_PARTY_ID = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_DI_SUBSCRIBED_FRM_PARTY';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   if ( AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PO') IN ('I','S') ) then
	return;
   end if;
   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_DI_SUBSCRIBED_FRM_PARTY()+');

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


   -- In the case of AHL_SUBSCRIPTIONS_B table, if subscribed from party id 1000 got merged to requested by party id 2000
   -- then, we have to update all records with subscribed from  party id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'AHL_SUBSCRIPTIONS_B', FALSE);

	    open  c1;
	    close c1;

	    update ahl_subscriptions_b
	    set    SUBSCRIBED_FRM_PARTY_ID =  p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  SUBSCRIBED_FRM_PARTY_ID = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_SUBSCRIPTIONS_B  for requested_by_party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_DI_SUBSCRIBED_FRM_PARTY;

-- Merge AHL_DOC_REVISIONS_B.APPROVED_BY_PARTY_ID

PROCEDURE AHL_DI_APPROVED_BY_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_doc_revisions_b
   where  approved_by_party_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_DI_APPROVED_BY_PARTY ';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   if ( AHL_DI_DOC_INDEX_PVT.GET_PRODUCT_INSTALL_STATUS('PER') IN ('I','S') ) then
	return;
   end if;

   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_DI_APPROVED_BY_PARTY ()+');

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


   -- In the case of AHL_DOC_REVISIONS_B table, if approved by party id 1000 got merged to approved by party id 2000
   -- then, we have to update all records with approved by party id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'AHL_DOC_REVISIONS_B', FALSE);

	    open  c1;
	    close c1;

	    update ahl_doc_revisions_b
	    set    approved_by_party_id           =  p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  approved_by_party_id  = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_DOC_REVSIONS_B  for approved_by_party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_DI_APPROVED_BY_PARTY ;

-- Merge AHL_DOC_REVISION_COPIES.RECEIVED_BY_PARTY_ID

PROCEDURE AHL_DI_RECEIVED_BY_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_doc_revision_copies
   where  received_by_party_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_DI_RECEIVED_BY_PARTY ';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_DI_RECEIVED_BY_PARTY ()+');

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


   -- In the case of AHL_DOC_REVISION_COPIES table, if received by party id 1000 got merged to received by party id 2000
   -- then, we have to update all records with received by party id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'AHL_DOC_REVISION_COPIES', FALSE);

	    open  c1;
	    close c1;

	    update ahl_doc_revision_copies
	    set    received_by_party_id           =  p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  received_by_party_id  = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_DOC_REVISION_COPIES  for received_by_party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_DI_RECEIVED_BY_PARTY ;

-- Merge AHL_OPERATIONS_B.OPERATOR_PARTY_ID
/*
PROCEDURE AHL_RM_OPER_OPERATOR_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_operations_b
   where  operator_party_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_RM_OPER_OPERATOR_PARTY ';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_RM_OPER_OPERATOR_PARTY ()+');

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
         arp_message.set_token('TABLE_NAME', 'AHL_OPERATIONS_B', FALSE);

	    open  c1;
	    close c1;

	    update ahl_operations_b
	    set    operator_party_id           =  p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  operator_party_id  = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_OPERATIONS_B for operator_party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_RM_OPER_OPERATOR_PARTY;
*/
-- Merge AHL_OPER_H_B.OPERATOR_PARTY_ID
/*
PROCEDURE AHL_RM_OPER_H_OPERATOR_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_operations_h_b
   where  operator_party_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_RM_OPER_H_OPERATOR_PARTY ';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_RM_OPER_H_OPERATOR_PARTY ()+');

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
         arp_message.set_token('TABLE_NAME', 'AHL_OPERATIONS_H_B', FALSE);

	    open  c1;
	    close c1;

	    update ahl_operations_h_b
	    set    operator_party_id           =  p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  operator_party_id  = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_OPERATIONS_H_B for operator_party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_RM_OPER_H_OPERATOR_PARTY;
*/
-- Merge AHL_ROUTE_B.OPERATOR_PARTY_ID

PROCEDURE AHL_RM_ROUTE_OPERATOR_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_routes_b
   where  operator_party_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_RM_ROUTE_OPERATOR_PARTY ';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_RM_ROUTE_OPERATOR_PARTY ()+');

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
         arp_message.set_token('TABLE_NAME', 'AHL_ROUTES_B', FALSE);

	    open  c1;
	    close c1;

	    update ahl_routes_b
	    set    operator_party_id           =  p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  operator_party_id  = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_ROUTES_B for operator_party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_RM_ROUTE_OPERATOR_PARTY;

-- Merge AHL_ROUTE_H_B.OPERATOR_PARTY_ID
/*
PROCEDURE AHL_RM_ROUTE_H_OPERATOR_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_routes_h_b
   where  operator_party_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_RM_ROUTE_H_OPERATOR_PARTY ';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_RM_ROUTE_H_OPERATOR_PARTY ()+');

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
         arp_message.set_token('TABLE_NAME', 'AHL_ROUTES_H_B', FALSE);

	    open  c1;
	    close c1;

	    update ahl_routes_h_b
	    set    operator_party_id           =  p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  operator_party_id  = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_ROUTES_H_B for operator_party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_RM_ROUTE_H_OPERATOR_PARTY;
*/

-- Merge AHL_OSP_ORDERS_B.CUSTOMER_ID

PROCEDURE AHL_OSP_CUSTOMER (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS
   cursor c1 is
   select 1
   from   ahl_osp_orders_b
   where  customer_id = p_from_fk_id
   for    update nowait;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'AHL_OSP_CUSTOMER';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('AHL_PARTY_MERGE_PKG.AHL_OSP_CUSTOMER()+');

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


   -- In the case of AHL_OSP_ORDERS_B table, if customer id 1000 got merged to customer id 2000
   -- then, we have to update all records with customer_id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'AHL_OSP_ORDERS_B', FALSE);

	    open  c1;
	    close c1;

	    update ahl_osp_orders_b
	    set    customer_id        = p_to_fk_id,
	           last_update_date   = SYSDATE,
	           last_updated_by    = G_USER_ID,
	           last_update_login  = G_LOGIN_ID
            where  customer_id        = p_from_fk_id;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
        when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'AHL_OSP_ORDERS_B  for customer_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END AHL_OSP_CUSTOMER;

END AHL_PARTY_MERGE_PKG;

/
