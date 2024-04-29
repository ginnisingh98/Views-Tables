--------------------------------------------------------
--  DDL for Package Body XDP_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_MERGE" AS
/* $Header: XDPPMRGB.pls 120.1 2005/06/09 00:24:59 appldev  $ */
--
-- Start of Comments
-- Package name     : XDP_MERGE
-- Purpose          : Merges duplicate parties in SFM tables. The
--                    SFM tables that need to be considered for
--                    Party Merge are:
--                    XDP_ORDER_HEADERS
--                    Columns : Customer_Id
--
--                    The Customer Id column is populated through the ProcessOrder API
--                    without any validation.  The Flow Through Manager UI further displays it
--                    along with customer name. Customer Name is also populated in the same fashion.
--                    The data stored in these two columns is displayed as it is in the UI.
--                    There no cross validation for the account number and customer as well.
--
--                    Since these parameters are exposed throught the public API 'Process Order' and also they
--                    displayed in the UI it necessary to write a party merge routine in order to keep the data
--                    in sync in case of party merge incidents.
--
--
--
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 05-05-2003    spusegao      Created.

G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'XDP_MERGE';
G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;

TYPE ROWID_TBL IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

-- The following procedure merges XDP_ORDER_HEADERS columns:
-- CUSTOMER_ID
-- The above columns are FKs to HZ_PARTIES.PARTY_ID

PROCEDURE MERGE_CUSTOMER_ID (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                     OUT NOCOPY   NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status             OUT NOCOPY   VARCHAR2)
IS
   -- cursor fetches all the records that need to be merged.
   CURSOR c1 IS
   SELECT rowid
   FROM   xdp_order_headers
   WHERE  p_from_fk_id IN (customer_id)
   FOR    UPDATE NOWAIT;

   l_rowid_tbl                  ROWID_TBL;
   l_customer_name              VARCHAR2(360);
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'MERGE_CUSTOMER_ID';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('CS_SR_PARTY_MERGE_PKG.MERGE_CUSTOMER_ID()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   SELECT merge_reason_code
   INTO   l_merge_reason_code
   FROM   hz_merge_batch
   WHERE  batch_id  = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      NULL;
   ELSE
      -- if there are any validations to be done, include it in this section
      NULL;
   END IF;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   IF p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      RETURN;
   END IF;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   -- In the case of XDP_ORDER_HEADERS table, if party id 1000 gets merged to party
   -- id 2000 then, we have to update all records with customer_id = 1000 to 2000

   IF p_from_fk_id <> p_to_fk_id THEN
      BEGIN
	 -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'XDP_ORDER_HEADERS', FALSE);

	 OPEN  c1;
	 FETCH c1 bulk collect INTO l_rowid_tbl;
         CLOSE c1;

	 -- if no records were found to be updated then stop and return to calling prg.
	 IF l_rowid_tbl.count = 0 THEN
	    RETURN;
         ELSE
            SELECT party_name
              INTO l_customer_name
              FROM hz_parties
             WHERE party_id = p_to_fk_id ;
         END IF;

	 FORALL i IN 1..l_rowid_tbl.COUNT

 	   UPDATE xdp_order_headers
	      SET customer_id           = DECODE(customer_id, p_from_fk_id, p_to_fk_id, customer_id),
                  customer_name         = DECODE(customer_id,p_from_fk_id,substr(l_customer_name,1,80),customer_name),
	          last_update_date      = SYSDATE,
	          last_updated_by       = G_USER_ID,
	          last_update_login     = G_LOGIN_ID
           WHERE  rowid                 = l_rowid_tbl(i);

         l_count := SQL%ROWCOUNT;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      EXCEPTION
        WHEN resource_busy THEN
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
                    '; Could not obtain lock for records in table '  ||
                    'XDP_ORDER_HEADERS  for customer_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       RAISE;

         WHEN others THEN
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       RAISE;
      END;
   END IF;  -- if p_from_fk_id <> p_to_fk_id

END MERGE_CUSTOMER_ID;

END XDP_MERGE ;

/
