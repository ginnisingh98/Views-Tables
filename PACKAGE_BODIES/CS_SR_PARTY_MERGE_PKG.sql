--------------------------------------------------------
--  DDL for Package Body CS_SR_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_PARTY_MERGE_PKG" AS
/* $Header: cssrpmgb.pls 120.1 2005/12/22 17:29:27 spusegao noship $ */


G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'CS_SR_PARTY_MERGE_PKG';
G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;

TYPE ROWID_TBL IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE NUM_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_30_TBL IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;


-- The following procedure merges CS_INCIDENTS_ALL_B columns:
-- customer_id
-- bill_to_contact_id
-- ship_to_contact_id
-- bill_to_party_id - added for 11.5.9
-- ship_to_party_id - added for 11.5.9
-- The above columns are FKs to HZ_PARTIES.PARTY_ID.

PROCEDURE CS_INC_ALL_MERGE_PARTY (
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
   -- cursor fetches all the records that need to be merged.
   CURSOR C1 IS
   SELECT rowid,
          incident_id,
          customer_id,
          bill_to_contact_id,
          ship_to_contact_id,
          bill_to_party_id,
          ship_to_party_id,
          last_update_program_code
   FROM   cs_incidents_all_b
   WHERE  p_from_fk_id in (customer_id, bill_to_contact_id, ship_to_contact_id,
			   bill_to_party_id, ship_to_party_id )
   FOR    UPDATE NOWAIT;

   l_incident_id		NUM_TBL;
   l_customer_id		NUM_TBL;
   l_bill_to_contact_id		NUM_TBL;
   l_ship_to_contact_id		NUM_TBL;
   l_bill_to_party_id		NUM_TBL;
   l_ship_to_party_id		NUM_TBL;
   l_last_update_program_code	VARCHAR2_30_TBL;
   l_rowid_tbl                  ROWID_TBL;

   l_audit_vals_rec		CS_ServiceRequest_PVT.SR_AUDIT_REC_TYPE;
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CS_INC_ALL_MERGE_PARTY';
   l_count                      NUMBER(10) := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);
   l_return_status               VARCHAR2(3);
   x_msg_count                  NUMBER(15);
   x_msg_data                   VARCHAR2(2000);
   l_audit_id                   NUMBER;
   l_last_fetch                 BOOLEAN := FALSE ;


BEGIN
   arp_message.set_line('CS_SR_PARTY_MERGE_PKG.CS_INC_ALL_MERGE_PARTY()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;


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
      x_to_id := p_from_id;
      RETURN;
   END IF;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   -- In the case of CS_INCIDENTS_ALL_B table, if party id 1000 gets merged to party
   -- id 2000 then, we have to update all records with customer_id = 1000 to 2000

   IF p_from_fk_id <> p_to_fk_id THEN

      BEGIN
	 -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CS_INCIDENTS_ALL_B', FALSE);

	 OPEN  c1;
          LOOP            -- Loop for BULK selecting and  processing the BULK selection in a batch of 1000

	     FETCH c1 BULK COLLECT INTO l_rowid_tbl,
                                    l_incident_id,
                                    l_customer_id,
                                    l_bill_to_contact_id,
                                    l_ship_to_contact_id ,
                                    l_bill_to_party_id,
                                    l_ship_to_party_id ,
                                    l_last_update_program_code
             LIMIT 1000 ;

             IF c1%NOTFOUND THEN
                l_last_fetch := TRUE;
             END IF;

             IF l_rowid_tbl.count = 0 AND l_last_fetch THEN
                EXIT;
             END IF ;
    	     -- if no records were found to be updated then stop and return to calling prg.
--	     IF l_rowid_tbl.count = 0 THEN
--	        RETURN;
--           END IF;

	     FORALL i IN 1..l_rowid_tbl.COUNT
	     UPDATE cs_incidents_all_b
  	        SET customer_id                 = decode(customer_id, p_from_fk_id,
					 		           p_to_fk_id, customer_id),
	            bill_to_contact_id          = decode(bill_to_contact_id, p_from_fk_id,
								       p_to_fk_id, bill_to_contact_id),
	            ship_to_contact_id          = decode(ship_to_contact_id, p_from_fk_id,
							           p_to_fk_id, ship_to_contact_id),
	            bill_to_party_id            = decode(bill_to_party_id,   p_from_fk_id,
							           p_to_fk_id, bill_to_party_id),
	            ship_to_party_id            = decode(ship_to_party_id,   p_from_fk_id,
							           p_to_fk_id, ship_to_party_id),
		    object_version_number       = object_version_number + 1,
                    incident_last_modified_date = sysdate ,
                    last_update_program_code    = 'PARTY_MERGE',
	            last_update_date            = SYSDATE,
	            last_updated_by             = G_USER_ID,
	            last_update_login           = G_LOGIN_ID
             WHERE  rowid                       = l_rowid_tbl(i);

             l_count := sql%rowcount;

             arp_message.set_name('AR', 'AR_ROWS_UPDATED');
             arp_message.set_token('NUM_ROWS', to_char(l_count) );

            FOR i IN 1..l_incident_id.count
              LOOP

                  CS_Servicerequest_UTIL.Prepare_Audit_Record (
      	              p_api_version            => 1,
		      p_request_id             => l_incident_id(i),
	              x_return_status          => l_return_status,
                      x_msg_count              => x_msg_count,
                      x_msg_data               => x_msg_data,
                      x_audit_vals_rec         => l_audit_vals_rec );


		    IF l_return_status <> FND_API.G_RET_STS_ERROR Then

		      IF l_audit_vals_rec.customer_id <> l_customer_id(i) THEN
		         l_audit_vals_rec.old_customer_id	        := l_customer_id(i);
		      END IF;
		      IF l_audit_vals_rec.bill_to_contact_id <> l_bill_to_contact_id(i) THEN
		         l_audit_vals_rec.old_bill_to_contact_id	:= l_bill_to_contact_id(i);
		         l_audit_vals_rec.change_bill_to_flag           := 'Y';
		      END IF;
		      IF l_audit_vals_rec.ship_to_contact_id <> l_ship_to_contact_id(i) THEN
		         l_audit_vals_rec.old_ship_to_contact_id	:= l_ship_to_contact_id(i);
		         l_audit_vals_rec.change_ship_to_FLAG           := 'Y';
		      END IF;
		      IF l_audit_vals_rec.bill_to_party_id <> l_bill_to_party_id(i) THEN
		         l_audit_vals_rec.old_bill_to_party_id         	:= l_bill_to_party_id(i);
		      END IF;
		      IF l_audit_vals_rec.ship_to_party_id <> l_ship_to_party_id(i) THEN
		         l_audit_vals_rec.old_ship_to_party_id	        := l_ship_to_party_id(i);
		      END IF;
                         l_audit_vals_rec.old_last_update_program_code  := l_last_update_program_code(i) ;
                         l_audit_vals_rec.last_update_program_code      := 'PARTY_MERGE' ;
                         l_audit_vals_rec.updated_entity_code           := 'SR_HEADER';
                         l_audit_vals_rec.updated_entity_id             := l_incident_id(i);
                         l_audit_vals_rec.entity_activity_code          := 'U' ;

                   END IF;

  	          CS_ServiceRequest_PVT.Create_Audit_Record
                          ( p_api_version         => 2.0,
                            x_return_status       => l_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data,
                            p_request_id          => l_incident_id(i),
                            p_audit_id            => NULL,
                            p_audit_vals_rec      => l_audit_vals_rec,
                            p_user_id             => G_USER_ID,
                            p_login_id            => G_LOGIN_ID,
                            p_last_update_date    => SYSDATE,
                            p_creation_date       => SYSDATE,
                            p_comments            => NULL,
                            x_audit_id            => l_audit_id);

              END LOOP;

          IF l_last_fetch THEN
             EXIT;
          END IF ;

          END LOOP ;      -- End Loop for BULK selecting and  processing the BULK selection in a batch of 1000

        CLOSE c1;

      EXCEPTION
        WHEN resource_busy THEN
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'CS_INCIDENTS_ALL_B  for customer_id / bill_to_contact_id ' ||
			  '/ ship_to_contact_id / bill_to_party_id / ship_to_part_id = '
			  || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

         WHEN others THEN
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       RAISE;
      END;

   END IF;  -- if p_from_fk_id <> p_to_fk_id

END CS_INC_ALL_MERGE_PARTY;

-- The following procedure will not perform any operations; the update of the
-- bill_to_contact_id is done in procedure CS_INC_ALL_MERGE_PARTY
PROCEDURE CS_INC_ALL_MERGE_BILL_TO_CONT (
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
BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
END CS_INC_ALL_MERGE_BILL_TO_CONT;

-- The following procedure will not perform any operations; the update of the
-- ship_to_contact_id is done in procedure CS_INC_ALL_MERGE_PARTY
PROCEDURE CS_INC_ALL_MERGE_SHIP_TO_CONT (
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
BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
END CS_INC_ALL_MERGE_SHIP_TO_CONT;


-- The following procedure merges CS_INCIDENTS_ALL_B columns:
-- bill_to_site_use_id
-- ship_to_site_use_id
-- The above columns are FKs to HZ_PARTY_SITE_USES.
--old proc. PROCEDURE CS_INC_ALL_MERGE_BILL_SITE_USE (
PROCEDURE CS_INC_ALL_MERGE_SITE_USES (
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
   -- cursor fetches all the records that need to be merged.
   CURSOR c1 IS
   SELECT rowid,incident_id ,
          bill_to_site_use_id ,
          ship_to_site_use_id,
          last_update_program_code
     FROM cs_incidents_all_b
    WHERE p_from_fk_id in (bill_to_site_use_id, ship_to_site_use_id)
      FOR UPDATE NOWAIT;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CS_INC_ALL_MERGE_SITE_USES';
   l_count                      NUMBER(10)   := 0;
   l_rowid_tbl                  ROWID_TBL;
   l_incident_id                NUM_TBL;
   l_bill_to_site_use_id        NUM_TBL;
   l_ship_to_site_use_id        NUM_TBL;
   l_last_update_program_code   VARCHAR2_30_TBL;
   l_last_fetch                 BOOLEAN := FALSE ;
   l_audit_id                   NUMBER;
   l_audit_vals_rec		CS_ServiceRequest_PVT.SR_AUDIT_REC_TYPE;
   l_return_status               VARCHAR2(3);
   x_msg_count                  NUMBER(15);
   x_msg_data                   VARCHAR2(2000);
   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN

   arp_message.set_line('CS_SR_PARTY_MERGE_PKG.CS_INC_ALL_MERGE_SITE_USES()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   SELECT merge_reason_code
     INTO l_merge_reason_code
     FROM hz_merge_batch
    WHERE batch_id  = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      null;
   ELSE
      -- if there are any validations to be done, include it in this section
      null;
   END IF;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   IF p_from_fk_id = p_to_fk_id THEN
      x_to_id := p_from_id;
      RETURN;
   END IF;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   -- In the case of CS_INCIDENTS_ALL_B table, we store bill_to_site_use_id which is a forign key to
   -- to HZ_PARTY_SITE_USES.PARTY_SITE_USE_ID. If the party who is tied to this site has been merged,
   -- then, it is possible that this site use id is being transferred under the new party or it
   -- may have been deleted if its a duplicate party_site_use_id

   IF p_from_fk_id <> p_to_fk_id THEN
      BEGIN
         -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CS_INCIDENTS_ALL_B', FALSE);

	 OPEN  c1;
         LOOP
  	     FETCH c1 bulk collect
              INTO l_rowid_tbl,
                   l_incident_id ,
                   l_bill_to_site_use_id ,
                   l_ship_to_site_use_id ,
                   l_last_update_program_code
             LIMIT 1000;

             IF c1%NOTFOUND THEN
                l_last_fetch := TRUE ;
             END IF ;

             IF l_rowid_tbl.COUNT = 0 AND l_last_fetch THEN
                EXIT ;
             END IF ;

	     IF l_rowid_tbl.count = 0 THEN
	        RETURN;
             END IF;

	     FORALL i IN 1..l_rowid_tbl.COUNT
	     UPDATE cs_incidents_all_b
	     SET    bill_to_site_use_id         = decode(bill_to_site_use_id, p_from_fk_id, p_to_fk_id,
					                            bill_to_site_use_id ),
	            ship_to_site_use_id         = decode(ship_to_site_use_id, p_from_fk_id, p_to_fk_id,
					                            ship_to_site_use_id ),
	    	    object_version_number       = object_version_number + 1,
                    incident_last_modified_date = sysdate,
                    last_update_program_code    = 'PARTY_MERGE',
	            last_update_date            = SYSDATE,
	            last_updated_by             = G_USER_ID,
	            last_update_login           = G_LOGIN_ID
             WHERE  rowid = l_rowid_tbl(i);

             l_count := SQL%ROWCOUNT;

             arp_message.set_name('AR', 'AR_ROWS_UPDATED');
             arp_message.set_token('NUM_ROWS', to_char(l_count) );


             -- Create an audit record for each service request in cs_incidents_audit_b table
             -- for which the bill_to_site_use_id or ship_to_site_use_id is updated

             FOR i IN 1..l_incident_id.COUNT
                 LOOP
                      CS_Servicerequest_UTIL.Prepare_Audit_Record (
      	                  p_api_version            => 1,
		          p_request_id             => l_incident_id(i),
	                  x_return_status          => l_return_status,
                          x_msg_count              => x_msg_count,
                          x_msg_data               => x_msg_data,
                          x_audit_vals_rec         => l_audit_vals_rec );


		      IF l_return_status <> FND_API.G_RET_STS_ERROR Then

		          IF l_bill_to_site_use_id(i) = p_from_fk_id THEN
                             l_audit_vals_rec.bill_to_site_use_id           := p_to_fk_id ;
		             l_audit_vals_rec.old_bill_to_site_use_id	:= l_bill_to_site_use_id(i);
                          ELSE
                             l_audit_vals_rec.bill_to_site_use_id           := l_bill_to_site_use_id(i);
                             l_audit_vals_rec.old_bill_to_site_use_id       := l_bill_to_site_use_id(i);
		          END IF;

		          IF l_ship_to_site_use_id(i) = p_from_fk_id THEN
                             l_audit_vals_rec.ship_to_site_use_id           := p_to_fk_id ;
		             l_audit_vals_rec.old_ship_to_site_use_id	:= l_ship_to_site_use_id(i);
                          ELSE
                             l_audit_vals_rec.ship_to_site_use_id           := l_ship_to_site_use_id(i);
                             l_audit_vals_rec.old_ship_to_site_use_id       := l_ship_to_site_use_id(i);
		          END IF;


                             l_audit_vals_rec.old_last_update_program_code  := l_last_update_program_code(i) ;
                             l_audit_vals_rec.last_update_program_code      := 'PARTY_MERGE' ;
                             l_audit_vals_rec.updated_entity_code           := 'SR_HEADER';
                             l_audit_vals_rec.updated_entity_id             := l_incident_id(i);
                             l_audit_vals_rec.entity_activity_code          := 'U' ;

                       END IF;

  	              CS_ServiceRequest_PVT.Create_Audit_Record
                          ( p_api_version         => 2.0,
                            x_return_status       => l_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data,
                            p_request_id          => l_incident_id(i),
                            p_audit_id            => NULL,
                            p_audit_vals_rec      => l_audit_vals_rec,
                            p_user_id             => G_USER_ID,
                            p_login_id            => G_LOGIN_ID,
                            p_last_update_date    => SYSDATE,
                            p_creation_date       => SYSDATE,
                            p_comments            => NULL,
                            x_audit_id            => l_audit_id);

                  END LOOP;

              IF l_last_fetch THEN
                 EXIT;
              END IF ;

          END LOOP ;  -- End Loop for BULK selecting and  processing the BULK selection in a batch of 1000

        CLOSE c1;

      EXCEPTION
         WHEN resource_busy THEN
            arp_message.set_line(g_proc_name || '.' || l_api_name ||
            '; Could not obtain lock for records in table '  ||
            'CS_INCIDENTS_ALL_B  for bill_to_site_use_id / ship_to_site_use_id / '
	    || p_from_fk_id );
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            RAISE;

         WHEN others THEN
	    arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
	    RAISE;
      END;
   END IF;

END CS_INC_ALL_MERGE_SITE_USES;

-- The following procedure will not perform any operations; the update of the
-- install_site_use_id is done in procedure CS_INC_ALL_MERGE_SITE_USES
PROCEDURE CS_INC_ALL_MERGE_INST_SITE_USE (
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
BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
END CS_INC_ALL_MERGE_INST_SITE_USE;

-- The following procedure will not perform any operations; the update of the
-- ship_to_site_use_id is done in procedure CS_INC_ALL_MERGE_SITE_USES
PROCEDURE CS_INC_ALL_MERGE_SHIP_SITE_USE(
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
BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
END CS_INC_ALL_MERGE_SHIP_SITE_USE;


-- The following procedure merges CS_INCIDENTS_ALL_B columns:
-- site_id
-- customer_site_id
-- bill_to_site_id - added from 11.5.9
-- ship_to_site_id - added from 11.5.9
-- install_site_id - added from 11.5.9
-- install_site_use_id - moved from proc. CS_INC_ALL_MERGE_SITE_USES
-- The above columns are FKs to HZ_PARTY_SITES.
PROCEDURE CS_INC_ALL_MERGE_SITE_ID (
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
   -- cursor fetches all the records that need to be merged.
   CURSOR C1 IS
   SELECT rowid,
          incident_id ,
          site_id,
          customer_site_id,
          install_site_use_id,
          bill_to_site_id,
          ship_to_site_id,
          install_site_id,
          incident_location_id ,
          incident_location_type,
          last_update_program_code
   FROM   cs_incidents_all_b
   WHERE  p_from_fk_id IN (site_id, customer_site_id, install_site_use_id,
			   bill_to_site_id, ship_to_site_id, install_site_id)
      OR  (incident_location_type = 'HZ_PARTY_SITE' AND incident_location_id = p_from_fk_id)
   FOR    UPDATE NOWAIT;

--   CURSOR c2 IS  -- This cursor is not required since the audit record creation id done using main cursor.
--   SELECT incident_id , site_id , last_update_program_code
--   FROM cs_incidents_all_b
--   WHERE site_id = p_from_fk_id ;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CS_INC_ALL_MERGE_SITE_ID';
   l_count                      NUMBER(10)   := 0;

   l_rowid_tbl                  ROWID_TBL;
   l_incident_id		NUM_TBL ;
   l_site_id 			NUM_TBL ;
   l_customer_site_id           NUM_TBL ;
   l_install_site_use_id        NUM_TBL ;
   l_bill_to_site_id            NUM_TBL ;
   l_ship_to_site_id            NUM_TBL ;
   l_install_site_id            NUM_TBL ;
   l_incident_location_id       NUM_TBL ;
   l_incident_location_type     VARCHAR2_30_TBl ;
   l_last_update_program_code	VARCHAR2_30_TBL ;
   l_audit_vals_rec		CS_ServiceRequest_PVT.SR_AUDIT_REC_TYPE;
   l_return_status               VARCHAR2(3);
   x_msg_count                  NUMBER;
   x_msg_data                   VARCHAR2(2000);
   l_audit_id			NUMBER;
   l_last_fetch                 BOOLEAN := FALSE ;


   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('CS_SR_PARTY_MERGE_PKG.CS_INC_ALL_MERGE_SITE_ID()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   SELECT merge_reason_code
   INTO   l_merge_reason_code
   FROM   hz_merge_batch
   WHERE  batch_id  = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' THEN
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      null;
   ELSE
      -- if there are any validations to be done, include it in this section
      null;
   END IF;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   IF p_from_fk_id = p_to_fk_id THEN
       x_to_id := p_from_id;
      RETURN;
   END IF;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id


   -- In the case of CS_INCIDENTS_ALL_B table, we store install_site_use_id which is a forign key to
   -- to HZ_PARTY_SITES.PARTY_SITE_ID. If the party who is tied to this site has been merged,
   -- then, it is possible that this site use id is being transferred under the new party or it
   -- may have been deleted if its a duplicate party_site_use_id


   IF p_from_fk_id <> p_to_fk_id THEN
      BEGIN
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CS_INCIDENTS_ALL_B', FALSE);

	 OPEN  C1;
         LOOP          -- Bulk fetch loop for 1000 records
	     FETCH C1 BULK COLLECT
              INTO l_rowid_tbl,
                   l_incident_id ,
                   l_site_id,
                   l_customer_site_id,
                   l_install_site_use_id,
                   l_bill_to_site_id,
                   l_ship_to_site_id,
                   l_install_site_id,
                   l_incident_location_id ,
                   l_incident_location_type ,
                   l_last_update_program_code
             LIMIT 1000 ;

             IF c1%NOTFOUND THEN
                l_last_fetch := TRUE ;
             END IF ;

             IF l_rowid_tbl.COUNT = 0 AND l_last_fetch THEN
                EXIT ;
             END IF ;

--    	     IF l_rowid_tbl.COUNT = 0 THEN
--	        RETURN;
--            END IF;

--         OPEN c2;
--         FETCH c2 BULK COLLECT INTO l_incident_id ,
--                                 l_site_id ,
--                                 l_last_update_program_code ;
--         CLOSE c2;


           FORALL i IN 1..l_rowid_tbl.COUNT
	     UPDATE cs_incidents_all_b
	     SET    site_id               = decode(site_id, p_from_fk_id, p_to_fk_id, site_id),
	            customer_site_id      = decode(customer_site_id, p_from_fk_id, p_to_fk_id,
								 customer_site_id),
	            bill_to_site_id       = decode(bill_to_site_id , p_from_fk_id, p_to_fk_id,
								 bill_to_site_id ),
	            ship_to_site_id       = decode(ship_to_site_id , p_from_fk_id, p_to_fk_id,
								 ship_to_site_id ),
	            install_site_id       = decode(install_site_id , p_from_fk_id, p_to_fk_id,
								 install_site_id ),
	            install_site_use_id   = decode(install_site_use_id, p_from_fk_id, p_to_fk_id,
								 install_site_use_id ),
                    incident_location_id  = Decode(NVL(incident_location_type,'XXX') ,
                                               'HZ_LOCATION',incident_location_id ,
                                               'HZ_PARTY_SITE',decode(incident_location_id,
                                                                      p_from_fk_id,p_to_fk_id,incident_location_id),
                                               'XXX',incident_location_id
                                              ),
                    incident_last_modified_date = sysdate ,
		    object_version_number = object_version_number + 1,
                    last_update_program_code = 'PARTY_MERGE',
	            last_update_date      = SYSDATE,
	            last_updated_by       = G_USER_ID,
	            last_update_login     = G_LOGIN_ID
             WHERE  rowid = l_rowid_tbl(i);

             l_count := sql%rowcount;

             arp_message.set_name('AR', 'AR_ROWS_UPDATED');
             arp_message.set_token('NUM_ROWS', to_char(l_count) );

            -- create audit record in cs_incidents_audit_b table for each service
            -- request for which site_id is updated.

        FOR i IN 1..l_incident_id.COUNT
         LOOP

           CS_Servicerequest_UTIL.Prepare_Audit_Record (
                      p_api_version            => 1,
	              p_request_id             => l_incident_id(i),
	              x_return_status          => x_return_status,
                      x_msg_count              => x_msg_count,
                      x_msg_data               => x_msg_data,
                      x_audit_vals_rec         => l_audit_vals_rec );

          IF x_return_status <> FND_API.G_RET_STS_ERROR THEN

             -- set the site_id/old_site_id of audit record

   	     IF l_site_id(i) = p_from_fk_id THEN
                l_audit_vals_rec.site_id := p_to_fk_id ;
	        l_audit_vals_rec.old_site_id := l_site_id(i);
             ELSE
                l_audit_vals_rec.site_id := l_site_id(i);
	        l_audit_vals_rec.old_site_id := l_site_id(i);
	     END IF;


             -- set the customer_site_id/old_customer_site_id of audit record

   	     IF l_customer_site_id(i) = p_from_fk_id THEN
                l_audit_vals_rec.customer_site_id     := p_to_fk_id ;
	        l_audit_vals_rec.old_customer_site_id := l_customer_site_id(i);
             ELSE
                l_audit_vals_rec.customer_site_id     := l_customer_site_id(i);
	        l_audit_vals_rec.old_customer_site_id := l_customer_site_id(i);
	     END IF;

             -- set the install_site_id/old_install_site_id of audit record

   	     IF l_install_site_id(i) = p_from_fk_id THEN
                l_audit_vals_rec.install_site_id     := p_to_fk_id ;
	        l_audit_vals_rec.old_install_site_id := l_install_site_id(i);
             ELSE
                l_audit_vals_rec.install_site_id     := l_install_site_id(i);
	        l_audit_vals_rec.old_install_site_id := l_install_site_id(i);
	     END IF;

             -- set the bill_to_site_id/old_bill_to_site_id of audit record

   	     IF l_bill_to_site_id(i) = p_from_fk_id THEN
                l_audit_vals_rec.bill_to_site_id     := p_to_fk_id ;
	        l_audit_vals_rec.old_bill_to_site_id := l_bill_to_site_id(i);
             ELSE
                l_audit_vals_rec.bill_to_site_id     := l_bill_to_site_id(i);
	        l_audit_vals_rec.old_bill_to_site_id := l_bill_to_site_id(i);
	     END IF;

             -- set the ship_to_site_id/old_ship_to_site_id of audit record

   	     IF l_ship_to_site_id(i) = p_from_fk_id THEN
                l_audit_vals_rec.ship_to_site_id     := p_to_fk_id ;
	        l_audit_vals_rec.old_ship_to_site_id := l_ship_to_site_id(i);
             ELSE
                l_audit_vals_rec.ship_to_site_id     := l_ship_to_site_id(i);
	        l_audit_vals_rec.old_ship_to_site_id := l_ship_to_site_id(i);
	     END IF;

             -- set the site_id/old_site_id of audit record

   	     IF l_install_site_use_id(i) = p_from_fk_id THEN
                l_audit_vals_rec.install_site_use_id := p_to_fk_id ;
	        l_audit_vals_rec.old_install_site_use_id := l_install_site_use_id(i);
             ELSE
                l_audit_vals_rec.install_site_use_id := l_install_site_use_id(i);
	        l_audit_vals_rec.old_install_site_use_id := l_install_site_use_id(i);
	     END IF;

             -- set the site_id/old_site_id of audit record

   	     IF (NVL(l_incident_location_type(i),'XXX') = 'HZ_PARTY_SITE' AND l_incident_location_id(i) = p_from_fk_id) THEN
                l_audit_vals_rec.incident_location_id     := p_to_fk_id ;
	        l_audit_vals_rec.old_incident_location_id := l_incident_location_id(i);
             ELSE
                l_audit_vals_rec.incident_location_id     := l_incident_location_id(i);
	        l_audit_vals_rec.old_incident_location_id := l_incident_location_id(i);
	     END IF;
             -- set the last_program_code/old_last_progream_code of audit record

              l_audit_vals_rec. last_update_program_code    := 'PARTY_MERGE' ;
	      l_audit_vals_rec.old_last_update_program_code := l_last_update_program_code (i);
              l_audit_vals_rec.updated_entity_code          := 'SR_HEADER';
              l_audit_vals_rec.updated_entity_id            := l_incident_id(i);
              l_audit_vals_rec.entity_activity_code         := 'U';

          END IF;

          CS_ServiceRequest_PVT.Create_Audit_Record (
                         p_api_version         => 2.0,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_request_id          => l_incident_id(i),
                         p_audit_id            => NULL,
                         p_audit_vals_rec      => l_audit_vals_rec              ,
                         p_user_id             => G_USER_ID,
                         p_login_id            => G_LOGIN_ID,
                         p_last_update_date    => SYSDATE,
                         p_creation_date       => SYSDATE,
                         p_comments            => NULL,
                         x_audit_id            => l_audit_id);

        END LOOP;

        IF l_last_fetch THEN
           EXIT ;
        END IF ;

   END LOOP ;    -- Bulk fetch end loop

   CLOSE c1 ;

  EXCEPTION
	 WHEN resource_busy THEN
	    arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'CS_INCIDENTS_ALL_B  for site_id / customer_site_id / ' ||
			  'install_site_use_id / bill_to_site_id / ship_to_site_id / '||
			  'install_site_id = ' || p_from_fk_id );
            x_return_status :=  FND_API.G_RET_STS_ERROR;
	    RAISE;

         WHEN others THEN
	    arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
	    RAISE;
  END;
   END IF;
END CS_INC_ALL_MERGE_SITE_ID;

-- The following procedure will not perform any operations; the update of the
-- customer_id is done in procedure CS_INC_ALL_MERGE_SITE_ID
PROCEDURE CS_INC_ALL_MERGE_CT_SITE_ID (
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

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
END CS_INC_ALL_MERGE_CT_SITE_ID;

-- The following procedure merges CS_INCIDENT_AUDIT_B columns:
-- bill_to_contact_id
-- ship_to_contact_id
-- old_bill_to_contact_id
-- old_ship_to_contact_id
-- The above columns are FKs to HZ_PARTIES.
PROCEDURE CS_AUDIT_MERGE_PARTY(
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
   select rowid
   from   cs_incidents_audit_b
   where  p_from_fk_id in (bill_to_contact_id, ship_to_contact_id, old_bill_to_contact_id,
			   old_ship_to_contact_id)
   for    update nowait;

   l_rowid_tbl                  ROWID_TBL;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CS_AUDIT_MERGE_PARTY';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('CS_SR_PARTY_MERGE_PKG.CS_AUDIT_MERGE_PARTY()+');

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

   -- In the case of CS_INCIDENTS_ALL_B table, if party id 1000 gets merged to party
   -- id 2000 then, we have to update all records with bill_to_contact_id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CS_INCIDENTS_AUDIT_B', FALSE);

	 open  c1;
	 fetch c1 bulk collect into l_rowid_tbl;
	 close c1;

	 if l_rowid_tbl.count = 0 then
	    RETURN;
         end if;

	 forall i in 1.. l_rowid_tbl.count
	 update cs_incidents_audit_b
	 set bill_to_contact_id    = decode(bill_to_contact_id, p_from_fk_id, p_to_fk_id,
                                                                bill_to_contact_id ),
	     old_bill_to_contact_id= decode(old_bill_to_contact_id, p_from_fk_id, p_to_fk_id,
								old_bill_to_contact_id ),
	     ship_to_contact_id    = decode(ship_to_contact_id, p_from_fk_id, p_to_fk_id,
								ship_to_contact_id ),
	     old_ship_to_contact_id= decode(old_ship_to_contact_id, p_from_fk_id, p_to_fk_id,
								old_ship_to_contact_id ),
	     object_version_number = object_version_number + 1,
	     last_update_date      = SYSDATE,
	     last_updated_by       = G_USER_ID,
	     last_update_login     = G_LOGIN_ID
         where  rowid = l_rowid_tbl(i);

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
         when resource_busy then
	    arp_message.set_line(g_proc_name || '.' || l_api_name ||
		    '; Could not obtain lock for records in table '  ||
		    'CS_INCIDENTS_AUDIT_B  for bill_to_contact_id = ' || p_from_fk_id );

            x_return_status :=  FND_API.G_RET_STS_ERROR;
            raise;

         when others then
	    arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
	    raise;
      end;
   end if;
END CS_AUDIT_MERGE_PARTY;


-- The following procedure will not perform any operations; the update of the
-- old_bill_to_contact_id is done in procedure CS_AUDIT_MERGE_PARTY
PROCEDURE CS_AUDIT_MERGE_OLD_BILL_CONT(
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
BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
END CS_AUDIT_MERGE_OLD_BILL_CONT;

-- The following procedure will not perform any operations; the update of the
-- ship_to_contact_id is done in procedure CS_AUDIT_MERGE_PARTY
PROCEDURE CS_AUDIT_MERGE_SHIP_TO_CONT(
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
BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
END CS_AUDIT_MERGE_SHIP_TO_CONT;

-- The following procedure will not perform any operations; the update of the
-- old_ship_to_contact_id is done in procedure CS_AUDIT_MERGE_PARTY
PROCEDURE CS_AUDIT_MERGE_OLD_SHIP_CONT(
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
BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
END CS_AUDIT_MERGE_OLD_SHIP_CONT;


PROCEDURE CS_AUDIT_MERGE_SITE_ID(
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
   -- cursor fetches all the records that need to be merged.
   cursor c1 is
   select rowid
   from   cs_incidents_audit_b
   where  p_from_fk_id in (site_id, old_site_id)
   for    update nowait;

   l_rowid_tbl                  ROWID_TBL;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CS_AUDIT_MERGE_SITE_ID';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('CS_SR_PARTY_MERGE_PKG.CS_AUDIT_MERGE_SITE_ID()+');

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

   -- In the case of CS_INCIDENTS_ALL_B table, if site id 1000 gets merged to site
   -- id 2000 then, we have to update all records with site_id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CS_INCIDENTS_AUDIT_B', FALSE);

	 open  c1;
	 fetch c1 bulk collect into l_rowid_tbl;
	 close c1;

	 if l_rowid_tbl.count = 0 then
	    RETURN;
         end if;

	 forall i in 1..l_rowid_tbl.count
	 update cs_incidents_audit_b
	 set site_id               = decode(site_id, p_from_fk_id, p_to_fk_id,
					             site_id),
	     old_site_id      = decode(old_site_id, p_from_fk_id, p_to_fk_id,
					            old_site_id),
	     object_version_number = object_version_number + 1,
	     last_update_date      = SYSDATE,
	     last_updated_by       = G_USER_ID,
	     last_update_login     = G_LOGIN_ID
         where  rowid = l_rowid_tbl(i);

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
	    when resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'CS_INCIDENTS_AUDIT_B  for site_id = ' || p_from_fk_id );

               x_return_status :=  FND_API.G_RET_STS_ERROR;
               raise;

         when others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;
      end;
   end if;
END CS_AUDIT_MERGE_SITE_ID;

-- The following procedure will not perform any operations; the update of the
-- old_site_id is done in procedure CS_AUDIT_MERGE_SITE_ID
PROCEDURE CS_AUDIT_MERGE_OLD_SITE_ID(
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
BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
END CS_AUDIT_MERGE_OLD_SITE_ID;


PROCEDURE CS_CONTACTS_MERGE_PARTY(
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
   from   cs_hz_sr_contact_points
   where  sr_contact_point_id = p_from_id
   and    party_id = p_from_fk_id
   and    contact_type <> 'EMPLOYEE'
   for    update nowait;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CS_CONTACTS_MERGE_PARTY';
   l_count                      NUMBER(10)   := 0;
   l_incident_id                NUM_TBL;
   l_sr_contact_point_id        NUM_TBL;
   v_merged_to_id               NUMBER;
   l_primary_flag               VARCHAR2(1);
   l_audit_id                   NUMBER;
   l_return_status               VARCHAR2(3);
   x_msg_count                  NUMBER(15);
   x_msg_data                   VARCHAR2(2000);
   l_sr_contact_old_rec         CS_SERVICEREQUEST_PVT.CONTACTS_REC;
   l_sr_contact_new_rec         CS_SERVICEREQUEST_PVT.CONTACTS_REC;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('CS_PARTY_MERGE_PKG.CS_CONTACTS_MERGE_PARTY()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   ---dbms_output.put_line('am going to get reason code');

   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   ---l_merge_reason_code := null;
   --dbms_output.put_line('got  reason code');

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


   -- In the case of CS_HZ_SR_CONTACT_POINTS  table, if party id 1000 gets merged to
   -- party id 2000 then, we have to update all records with customer_id = 1000 to 2000

   if p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CS_HZ_SR_CONTACT_POINTS', FALSE);

	    open  c1;
	    close c1;


            BEGIN
             --Before updating the record with the new party id, check if it will result in a duplicate
	     --record in cs_hz_sr_contact_points
	     --If so, need to set one of them to DUPLICATE

             --dbms_output.put_line('getting v_merged_to_id');

             --V_MERGED_TO_ID will have the SR_CONTACT_POINT_ID which results in a duplicate record
             --
             select sr_contact_point_id INTO v_merged_to_id
             from cs_hz_sr_contact_points
             where party_id = p_to_fk_id
	     and   ( contact_point_id, incident_id ) = ( select contact_point_id, incident_id
		 					 from   cs_hz_sr_contact_points
							 where  sr_contact_point_id = p_from_id )
             and   sr_contact_point_id <> p_from_id
             and   contact_type <> 'EMPLOYEE'
	     and   rownum = 1;

             --dbms_output.put_line('got  v_merged_id' || v_merged_to_id);

            EXCEPTION
              when no_data_found then
                v_merged_to_id := null;
            END ;


            IF v_merged_to_id IS NULL  THEN
		    --Did'nt find any record which would result in a duplicate
		    --Hence, just update the record with the new party id.

              ----dbms_output.put_line('hi 1' || v_merged_to_id);

              UPDATE CS_HZ_SR_CONTACT_POINTS
              SET    party_id              = p_to_fk_id,
		     object_version_number = object_version_number + 1,
	             last_update_date      = SYSDATE,
	             last_updated_by       = G_USER_ID,
	             last_update_login     = G_LOGIN_ID
              WHERE  sr_contact_point_id = p_from_id
                AND  party_id    = p_from_fk_id
            RETURNING incident_id , sr_contact_point_id BULK COLLECT
                 INTO l_incident_id , l_sr_contact_point_id ;

            FOR  i IN  1..l_incident_id.COUNT
 	       LOOP
                  -- Contact point audit record
                     -- Populate CP audit Records structure.

                        CS_SRCONTACT_PKG.Populate_CP_Audit_Rec
                             (p_sr_contact_point_id => p_from_id ,
                              x_sr_contact_rec      => l_sr_contact_new_rec,
                              x_return_status       => l_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data ) ;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE FND_API.G_EXC_ERROR;
                        END IF ;

                     -- Change the old value of the party id in the old CP audit record.

                        l_sr_contact_old_rec          := l_sr_contact_new_rec;
                        l_sr_contact_old_rec.party_id := p_from_fk_id;

                     -- Create CP audit record

                        CS_SRCONTACT_PKG.create_cp_audit
                             (p_sr_contact_point_id  => p_from_id,
                              p_incident_id          => l_incident_id(i),
                              p_new_cp_rec           => l_sr_contact_new_rec,
                              p_old_cp_rec           => l_sr_contact_old_rec,
                              p_cp_modified_by       => fnd_global.user_id,
                              p_cp_modified_on       => sysdate,
                              x_return_status        => l_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data ) ;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE FND_API.G_EXC_ERROR;
                        END IF ;

                  -- Create SR Child Audit Record

                       CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
                             (p_incident_id           	=> l_incident_id(i),
                              p_updated_entity_code   	=> 'SR_CONTACT_POINT',
                              p_updated_entity_id     	=> l_sr_contact_point_id(i) ,
                              p_entity_update_date    	=> sysdate ,
                              p_entity_activity_code  	=> 'U',
                              p_update_program_code     => 'PARTY_MERGE',
                              x_audit_id             	=> l_audit_id ,
                              x_return_status        	=> l_return_status ,
                              x_msg_count            	=> x_msg_count ,
                              x_msg_data            	=> x_msg_data  ) ;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE FND_API.G_EXC_ERROR;
                        END IF ;

		END LOOP ;

              ---RETURN;

           ELSE   ---found a dup record


		  --Found a record which would create duplicates in cs_hz_sr_contact_points
		  --HEnce, mark the the other found record as duplicate and update the current
		  --one which needs to updated with the new party id. WHile marking the record
		  --as DUPLICATE, check if it is the PRIMARY CONTACT. IF so, make the current one
		  --which is going to be updated with new party id,  as PRIMARY CONTACT

              --Found a record whcih results in duplicate, hence delete it
              DELETE FROM
              CS_HZ_SR_CONTACT_POINTS
              WHERE sr_contact_point_id = v_merged_to_id
              RETURNING primary_flag INTO l_primary_flag ;


             ---dbms_output.put_line('hi 2' || v_merged_to_id);

              IF l_primary_flag= 'N' OR l_primary_flag IS NULL THEN
                UPDATE CS_HZ_SR_CONTACT_POINTS
                SET    party_id              = p_to_fk_id,
		       object_version_number = object_version_number + 1,
	               last_update_date        = SYSDATE,
	               last_updated_by         = G_USER_ID,
	               last_update_login       = G_LOGIN_ID
                WHERE  sr_contact_point_id = p_from_id
                  AND  party_id            = p_from_fk_id
                RETURNING incident_id , sr_contact_point_id BULK COLLECT
                 INTO l_incident_id , l_sr_contact_point_id ;

                FOR  i IN  1..l_incident_id.COUNT
                   LOOP

                     -- Contact point audit record
                        -- Populate CP audit Records structure.

                           CS_SRCONTACT_PKG.Populate_CP_Audit_Rec
                             (p_sr_contact_point_id => p_from_id ,
                              x_sr_contact_rec      => l_sr_contact_new_rec,
                              x_return_status       => l_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data ) ;

                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE FND_API.G_EXC_ERROR;
                           END IF ;

                        -- Change the old value of the party id in the old CP audit record.

                           l_sr_contact_old_rec          := l_sr_contact_new_rec;
                           l_sr_contact_old_rec.party_id := p_from_fk_id;

                        -- Create CP audit record

                           CS_SRCONTACT_PKG.create_cp_audit
                                (p_sr_contact_point_id  => p_from_id,
                                 p_incident_id          => l_incident_id(i),
                                 p_new_cp_rec           => l_sr_contact_new_rec,
                                 p_old_cp_rec           => l_sr_contact_old_rec,
                                 p_cp_modified_by       => fnd_global.user_id,
                                 p_cp_modified_on       => sysdate,
                                 x_return_status        => l_return_status,
                                 x_msg_count           => x_msg_count,
                                 x_msg_data            => x_msg_data ) ;

                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE FND_API.G_EXC_ERROR;
                           END IF ;

                        -- Create SR Child Audit Record


                           CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
                             (p_incident_id           	=> l_incident_id(i),
                              p_updated_entity_code   	=> 'SR_CONTACT_POINT',
                              p_updated_entity_id     	=> l_sr_contact_point_id(i) ,
                              p_entity_update_date    	=> sysdate ,
                              p_entity_activity_code  	=> 'U',
                              p_update_program_code     => 'PARTY_MERGE',
                              x_audit_id             	=> l_audit_id ,
                              x_return_status        	=> l_return_status ,
                              x_msg_count            	=> x_msg_count ,
                              x_msg_data            	=> x_msg_data  ) ;

                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE FND_API.G_EXC_ERROR;
                           END IF ;

		  END LOOP ;

              ELSE
                --PRIMARY_FLAG of the deleted record was Y, hence make this record as primary
                 ---dbms_output.put_line('hi 3' || v_merged_to_id);
                 UPDATE CS_HZ_SR_CONTACT_POINTS
                 SET    party_id              = p_to_fk_id,
			object_version_number = object_version_number + 1,
	                last_update_date      = SYSDATE,
	                last_updated_by       = G_USER_ID,
	                last_update_login     = G_LOGIN_ID,
                        primary_flag          = 'Y'
                 WHERE  sr_contact_point_id   = p_from_id
                   AND  party_id              = p_from_fk_id
                 RETURNING incident_id , sr_contact_point_id BULK COLLECT
                 INTO l_incident_id , l_sr_contact_point_id ;

                 FOR  i IN  1..l_incident_id.COUNT
 	            LOOP

                       -- Contact point audit record
                          -- Populate CP audit Records structure.

                             CS_SRCONTACT_PKG.Populate_CP_Audit_Rec
                                  (p_sr_contact_point_id => p_from_id ,
                                   x_sr_contact_rec      => l_sr_contact_new_rec,
                                   x_return_status       => l_return_status,
                                   x_msg_count           => x_msg_count,
                                   x_msg_data            => x_msg_data ) ;

                               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                  RAISE FND_API.G_EXC_ERROR;
                               END IF ;

                          -- Change the old value of the party id in the old CP audit record.

                             l_sr_contact_old_rec              := l_sr_contact_new_rec;
                             l_sr_contact_old_rec.party_id     := p_from_fk_id;
                             l_sr_contact_old_rec.primary_flag := 'N';

                          -- Create CP audit record


                             CS_SRCONTACT_PKG.create_cp_audit
                                  (p_sr_contact_point_id  => p_from_id,
                                   p_incident_id          => l_incident_id(i),
                                   p_new_cp_rec           => l_sr_contact_new_rec,
                                   p_old_cp_rec           => l_sr_contact_old_rec,
                                   p_cp_modified_by       => fnd_global.user_id,
                                   p_cp_modified_on       => sysdate,
                                   x_return_status        => l_return_status,
                                   x_msg_count           => x_msg_count,
                                   x_msg_data            => x_msg_data ) ;

                               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                  RAISE FND_API.G_EXC_ERROR;
                               END IF ;

                       -- Create SR Child Audit Record

                              CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
                                  (p_incident_id           	=> l_incident_id(i),
                                   p_updated_entity_code   	=> 'SR_CONTACT_POINT',
                                   p_updated_entity_id     	=> l_sr_contact_point_id(i) ,
                                   p_entity_update_date    	=> sysdate ,
                                   p_entity_activity_code  	=> 'U',
                                   p_update_program_code     => 'PARTY_MERGE',
                                   x_audit_id             	=> l_audit_id ,
                                   x_return_status        	=> l_return_status ,
                                   x_msg_count            	=> x_msg_count ,
                                   x_msg_data            	=> x_msg_data  ) ;

                               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                  RAISE FND_API.G_EXC_ERROR;
                               END IF ;

		     END LOOP ;

              END IF;

          END IF;

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
           WHEN FND_API.G_EXC_ERROR THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get
                 ( p_count => x_msg_count,
                   p_data  => x_msg_data
                 );
	       raise;
             WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               FND_MSG_PUB.Count_And_Get
                 ( p_count => x_msg_count,
                   p_data  => x_msg_data
                 );
	       raise;
	     WHEN resource_busy then
	       arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'CS_HZ_SR_CONTACT_POINTS for party_id = ' || p_from_fk_id );
               x_return_status :=  FND_API.G_RET_STS_ERROR;
	       raise;

            WHEN others then
	       arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
               x_return_status :=  FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get
                 ( p_count => x_msg_count,
                   p_data  => x_msg_data
                 );
	       raise;
      end;
   end if;
END CS_CONTACTS_MERGE_PARTY;


PROCEDURE CS_CONTACTS_MERGE_CONT_POINTS(
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
   CURSOR c1 IS
   SELECT 1
   FROM   cs_hz_sr_contact_points
   WHERE  sr_contact_point_id = p_from_id
   AND    contact_point_id = p_from_fk_id
   AND    contact_type <> 'EMPLOYEE'
   FOR    UPDATE NOWAIT;


   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(60) := 'CS_CONTACTS_MERGE_CONTACT_POINTS';
   l_count                      NUMBER(10)   := 0;
   l_audit_id                   NUMBER ;
   l_return_status               VARCHAR2(3);
   x_msg_count                  NUMBER;
   x_msg_data                   VARCHAR2(1000);
   v_merged_to_id               NUMBER;
   l_primary_flag               VARCHAR2(1);
   l_incident_id                NUM_TBL;
   l_sr_contact_point_id        NUM_TBL;
   l_sr_contact_old_rec         CS_SERVICEREQUEST_PVT.CONTACTS_REC;
   l_sr_contact_new_rec         CS_SERVICEREQUEST_PVT.CONTACTS_REC;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('CS_PARTY_MERGE_PKG.CS_CONTACTS_MERGE_CONTACT_POINTS()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   SELECT merge_reason_code
     INTO l_merge_reason_code
     FROM hz_merge_batch
    WHERE batch_id  = p_batch_id;


   --dbms_output.put_line('gping to get merged id for ct id');
   --l_merge_reason_code := null;
   --dbms_output.put_line('gping to get merged id for ct id');

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

   -- In the case of CS_HZ_SR_CONTACT_POINTS table, if party id 1000 gets merged to party
   -- id 2000 then, we have to update all records with customer_id = 1000 to 2000

   IF p_from_fk_id <> p_to_fk_id then
      begin
	    -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CS_HZ_SR_CONTACT_POINTS', FALSE);

	 open  c1;
	 close c1;


         BEGIN

            --dbms_output.put_line('gping to get merged id for ct id');
            --check if the merge results in a dupliacte record.
            --V_MERGED_TO_ID will have the SR_CONTACT_POINT_ID of the duplicate record.

            select sr_contact_point_id INTO v_merged_to_id
            from   cs_hz_sr_contact_points
            where  contact_point_id          = p_to_fk_id
	    and    ( party_id, incident_id ) = ( select party_id, incident_id
						 from   cs_hz_sr_contact_points
						 where  sr_contact_point_id = p_from_id )
            and   sr_contact_point_id <> p_from_id
            and   contact_type <> 'EMPLOYEE'
	    and   rownum              = 1;

		   --dbms_output.put_line('got merged id ' ||  v_merged_to_id) ;

         EXCEPTION
              when no_data_found then
                v_merged_to_id := null;
         END ;


         -- dbms_output.put_line('gt merged id for ct id'|| v_merged_to_id);

         IF v_merged_to_id IS NULL  THEN
            --Did'nt find any record which would result in duplicate
            --dbms_output.put_line('going to update ct pd ');
            --dbms_output.put_line(' meged id is null');

            UPDATE CS_HZ_SR_CONTACT_POINTS
               SET contact_point_id      = p_to_fk_id,
		   object_version_number = object_version_number + 1,
	           last_update_date      = SYSDATE,
	           last_updated_by       = G_USER_ID,
	           last_update_login     = G_LOGIN_ID
             WHERE sr_contact_point_id   = p_from_id
               AND contact_point_id      = p_from_fk_id
            RETURNING incident_id , sr_contact_point_id BULK COLLECT
                 INTO l_incident_id , l_sr_contact_point_id ;

            FOR  i IN  1..l_incident_id.COUNT
 	       LOOP

                   -- Contact point audit record
                      -- Populate CP audit Records structure.

                        CS_SRCONTACT_PKG.Populate_CP_Audit_Rec
                           (p_sr_contact_point_id => p_from_id ,
                            x_sr_contact_rec      => l_sr_contact_new_rec,
                            x_return_status       => l_return_status,
                            x_msg_count           => x_msg_count,
                            x_msg_data            => x_msg_data ) ;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE FND_API.G_EXC_ERROR;
                        END IF ;

                      -- Change the old value of the party id in the old CP audit record.

                         l_sr_contact_old_rec                   := l_sr_contact_new_rec;
                         l_sr_contact_old_rec.contact_point_id  := p_from_fk_id;

                      -- Create CP audit record


                         CS_SRCONTACT_PKG.create_cp_audit
                            (p_sr_contact_point_id  => p_from_id,
                             p_incident_id          => l_incident_id(i),
                             p_new_cp_rec           => l_sr_contact_new_rec,
                             p_old_cp_rec           => l_sr_contact_old_rec,
                             p_cp_modified_by       => fnd_global.user_id,
                             p_cp_modified_on       => sysdate,
                             x_return_status        => l_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data ) ;

                          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                             RAISE FND_API.G_EXC_ERROR;
                          END IF ;

                       -- Create SR Child Audit Record

                          CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
                             (p_incident_id           	=> l_incident_id(i),
                              p_updated_entity_code   	=> 'SR_CONTACT_POINT',
                              p_updated_entity_id     	=> l_sr_contact_point_id(i) ,
                              p_entity_update_date    	=> sysdate ,
                              p_entity_activity_code  	=> 'U',
                              p_update_program_code     => 'PARTY_MERGE',
                              x_audit_id             	=> l_audit_id ,
                              x_return_status        	=> l_return_status ,
                              x_msg_count            	=> x_msg_count ,
                              x_msg_data            	=> x_msg_data  ) ;

                          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                             RAISE FND_API.G_EXC_ERROR;
                          END IF ;

		END LOOP ;


         ELSE   --found dup rec
            --Found a record which would create duplicates in cs_hz_sr_contact_points
	    --HEnce, mark the the other found record as duplicate and update the current
	    --one which needs to updated with the new party id. WHile marking the record
	    --as DUPLICATE, check if it is the PRIMARY CONTACT. IF so, make the current one
	    --which is going to be updated with new party id,  as PRIMARY CONTACT

            --Found a record which would result in duplicate. hence delete it
	    ---dbms_output.put_line('merged id is not null');

            DELETE FROM CS_HZ_SR_CONTACT_POINTS
            WHERE SR_CONTACT_POINT_ID = v_merged_to_id
            RETURNING primary_flag INTO l_primary_flag ;

            IF l_primary_flag= 'N' OR l_primary_flag IS NULL THEN
               ---dbms_output.put_line('primary flag is N');

               UPDATE CS_HZ_SR_CONTACT_POINTS
                  SET contact_point_id      = p_to_fk_id,
		      object_version_number = object_version_number + 1,
	              last_update_date      = SYSDATE,
	              last_updated_by       = G_USER_ID,
	              last_update_login     = G_LOGIN_ID
                WHERE sr_contact_point_id   = p_from_id
                  AND contact_point_id      = p_from_fk_id
                  RETURNING incident_id , sr_contact_point_id BULK COLLECT
                 INTO l_incident_id , l_sr_contact_point_id ;

            FOR  i IN  1..l_incident_id.COUNT
               LOOP
                  -- Contact point audit record
                     -- Populate CP audit Records structure.

                        CS_SRCONTACT_PKG.Populate_CP_Audit_Rec
                            (p_sr_contact_point_id => p_from_id ,
                             x_sr_contact_rec      => l_sr_contact_new_rec,
                             x_return_status       => l_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data ) ;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE FND_API.G_EXC_ERROR;
                        END IF ;

                      -- Change the old value of the party id in the old CP audit record.

                         l_sr_contact_old_rec                   := l_sr_contact_new_rec;
                         l_sr_contact_old_rec.contact_point_id  := p_from_fk_id;

                      -- Create CP audit record

                         CS_SRCONTACT_PKG.create_cp_audit
                             (p_sr_contact_point_id  => p_from_id,
                              p_incident_id          => l_incident_id(i),
                              p_new_cp_rec           => l_sr_contact_new_rec,
                              p_old_cp_rec           => l_sr_contact_old_rec,
                              p_cp_modified_by       => fnd_global.user_id,
                              p_cp_modified_on       => sysdate,
                              x_return_status        => l_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data ) ;

                          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                             RAISE FND_API.G_EXC_ERROR;
                          END IF ;

                       -- Create SR Child Audit Record

                          CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
                               (p_incident_id             => l_incident_id(i),
                                p_updated_entity_code     => 'SR_CONTACT_POINT',
                                p_updated_entity_id       => l_sr_contact_point_id(i) ,
                                p_entity_update_date      => sysdate ,
                                p_entity_activity_code    => 'U',
                                p_update_program_code     => 'PARTY_MERGE',
                                x_audit_id                => l_audit_id ,
                                x_return_status           => l_return_status ,
                                x_msg_count               => x_msg_count ,
                                x_msg_data                => x_msg_data  ) ;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE FND_API.G_EXC_ERROR;
                        END IF ;


                END LOOP ;
            ELSE
	       --PRIMARY_FLAG of the deleted record was Y, hence make this record as primary
	       ---dbms_output.put_line('primary flag is Y');
               UPDATE CS_HZ_SR_CONTACT_POINTS
                  SET contact_point_id      = p_to_fk_id,
	              object_version_number = object_version_number + 1,
	              last_update_date      = SYSDATE,
	              last_updated_by       = G_USER_ID,
	              last_update_login     = G_LOGIN_ID,
                      primary_flag          = 'Y'
                WHERE sr_contact_point_id = p_from_id
                  AND contact_point_id    = p_from_fk_id
                  RETURNING incident_id , sr_contact_point_id BULK COLLECT
                 INTO l_incident_id , l_sr_contact_point_id ;

               FOR  i IN  1..l_incident_id.COUNT
                  LOOP

                    -- Contact point audit record
                       -- Populate CP audit Records structure.

                          CS_SRCONTACT_PKG.Populate_CP_Audit_Rec
                             (p_sr_contact_point_id => p_from_id ,
                              x_sr_contact_rec      => l_sr_contact_new_rec,
                              x_return_status       => l_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data ) ;

                          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                             RAISE FND_API.G_EXC_ERROR;
                          END IF ;

                       -- Change the old value of the party id in the old CP audit record.

                          l_sr_contact_old_rec                   := l_sr_contact_new_rec;
                          l_sr_contact_old_rec.contact_point_id  := p_from_fk_id;

                       -- Create CP audit record

                          CS_SRCONTACT_PKG.create_cp_audit
                             (p_sr_contact_point_id  => p_from_id,
                              p_incident_id          => l_incident_id(i),
                              p_new_cp_rec           => l_sr_contact_new_rec,
                              p_old_cp_rec           => l_sr_contact_old_rec,
                              p_cp_modified_by       => fnd_global.user_id,
                              p_cp_modified_on       => sysdate,
                              x_return_status        => l_return_status,
                              x_msg_count           => x_msg_count,
                              x_msg_data            => x_msg_data ) ;

                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE FND_API.G_EXC_ERROR;
                           END IF ;

                       -- Create SR Child Audit Record

                          CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
                               (p_incident_id             => l_incident_id(i),
                                p_updated_entity_code     => 'SR_CONTACT_POINT',
                                p_updated_entity_id       => l_sr_contact_point_id(i) ,
                                p_entity_update_date      => sysdate ,
                                p_entity_activity_code    => 'U',
                                p_update_program_code     => 'PARTY_MERGE',
                                x_audit_id                => l_audit_id ,
                                x_return_status           => l_return_status ,
                                x_msg_count               => x_msg_count ,
                                x_msg_data                => x_msg_data  ) ;

                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE FND_API.G_EXC_ERROR;
                           END IF ;

                  END LOOP;

            END IF;  -- IF l_primary_flag= 'N' OR l_primary_flag IS NULL
         END IF;  -- IF v_merged_to_id IS NULL


         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

      exception
           WHEN FND_API.G_EXC_ERROR THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get
                 ( p_count => x_msg_count,
                   p_data  => x_msg_data
                 );
               RAISE;
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               FND_MSG_PUB.Count_And_Get
                 ( p_count => x_msg_count,
                   p_data  => x_msg_data
                 );
               RAISE;
            when resource_busy then
	          arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
		       'CS_HZ_SR_CONTACT_POINTS for contact_point_id = ' || p_from_fk_id );
                  x_return_status :=  FND_API.G_RET_STS_ERROR;
	          raise;

            when others then
	          arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
                  x_return_status :=  FND_API.G_RET_STS_ERROR;
	          raise;
      end;
   end if;  --  IF p_from_fk_id <> p_to_fk_id

END CS_CONTACTS_MERGE_CONT_POINTS;

-- New procedure added for party merge for the following contact points added
-- for the SR customer in 11.5.9
-- cs_incidents_all_b.customer_phone_id -> hz_contact_points.contact_point_id
-- cs_incidents_all_b.customer_email_id -> hz_contact_points.contact_point_id

PROCEDURE CS_INC_ALL_MERGE_CONT_POINTS (
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
   -- cursor fetches all the records that need to be merged.
   CURSOR c1 IS
   SELECT rowid,
          incident_id ,
          customer_phone_id ,
          customer_email_id ,
          last_update_program_code
     FROM cs_incidents_all_b
    WHERE p_from_fk_id IN ( customer_phone_id, customer_email_id )
      FOR update nowait;

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'CS_INC_ALL_MERGE_CONT_POINTS';
   l_count                      NUMBER(10)   := 0;

   l_rowid_tbl                  ROWID_TBL;
   l_incident_id                NUM_TBL;
   l_customer_phone_id          NUM_TBL;
   l_customer_email_id          NUM_TBL;
   l_last_update_program_code   VARCHAR2_30_TBL;
   l_last_fetch                 BOOLEAN := FALSE ;
   l_audit_vals_rec		CS_ServiceRequest_PVT.SR_AUDIT_REC_TYPE;
   l_audit_id                   NUMBER;
   l_return_status               VARCHAR2(3);
   x_msg_count                  NUMBER(15);
   x_msg_data                   VARCHAR2(2000);
   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   arp_message.set_line('CS_SR_PARTY_MERGE_PKG.CS_INC_ALL_MERGE_CONT_POINTS()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   SELECT merge_reason_code
     INTO l_merge_reason_code
     FROM hz_merge_batch
    WHERE batch_id  = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' THEN
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      null;
   ELSE
      -- if there are any validations to be done, include it in this section
      null;
   END IF;

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   IF p_from_fk_id = p_to_fk_id THEN
       x_to_id := p_from_id;
      RETURN;
   END IF;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   IF p_from_fk_id <> p_to_fk_id THEN
      BEGIN
	 -- obtain lock on records to be updated.
         arp_message.set_name('AR', 'AR_LOCKING_TABLE');
         arp_message.set_token('TABLE_NAME', 'CS_INCIDENTS_ALL_B', FALSE);

       OPEN  c1;
       LOOP        -- loop to batch process 1000 records
	 FETCH c1 bulk collect
          INTO l_rowid_tbl ,
               l_incident_id ,
               l_customer_phone_id ,
               l_customer_email_id ,
               l_last_update_program_code
         LIMIT 1000 ;


--	 IF l_rowid_tbl.count = 0 THEN
--	    RETURN;
--       END IF;

         IF c1%NOTFOUND THEN
            l_last_fetch := TRUE ;
         END IF ;

         IF l_rowid_tbl.COUNT = 0 AND l_last_fetch THEN
            EXIT;
         END IF ;

	 FORALL i IN 1..l_rowid_tbl.COUNT
	 UPDATE cs_incidents_all_b
	    SET customer_phone_id           = decode(customer_phone_id, p_from_fk_id, p_to_fk_id,
								  customer_phone_id ),
	        customer_email_id           = decode(customer_email_id, p_from_fk_id, p_to_fk_id,
								  customer_email_id ),
                incident_last_modified_date = sysdate ,
                last_update_program_code    = 'PARTY_MERGE',
		object_version_number       = object_version_number + 1,
	        last_update_date            = SYSDATE,
	        last_updated_by             = G_USER_ID,
	        last_update_login           = G_LOGIN_ID
         WHERE  rowid = l_rowid_tbl(i);

         l_count := sql%rowcount;

         arp_message.set_name('AR', 'AR_ROWS_UPDATED');
         arp_message.set_token('NUM_ROWS', to_char(l_count) );

         -- create audit record in cs_incidents_audit_b table for each service
         -- request for which site_id is updated.

         FOR i IN 1..l_incident_id.COUNT
           LOOP

           CS_Servicerequest_UTIL.Prepare_Audit_Record (
                      p_api_version            => 1,
	              p_request_id             => l_incident_id(i),
	              x_return_status          => x_return_status,
                      x_msg_count              => x_msg_count,
                      x_msg_data               => x_msg_data,
                      x_audit_vals_rec         => l_audit_vals_rec );

          IF x_return_status <> FND_API.G_RET_STS_ERROR THEN

             -- set the customer_email_id/old_customer_email_id of audit record

   	     IF l_customer_email_id(i) = p_from_fk_id THEN
                l_audit_vals_rec.customer_email_id     := p_to_fk_id ;
	        l_audit_vals_rec.old_customer_email_id := l_customer_email_id(i);
             ELSE
                l_audit_vals_rec.customer_email_id     := l_customer_email_id(i);
	        l_audit_vals_rec.old_customer_email_id := l_customer_email_id(i);
	     END IF;

             -- set the customer_phone_id/old_customer_phone_id of audit record

   	     IF l_customer_phone_id(i) = p_from_fk_id THEN
                l_audit_vals_rec.customer_phone_id     := p_to_fk_id ;
	        l_audit_vals_rec.old_customer_phone_id := l_customer_phone_id(i);
             ELSE
                l_audit_vals_rec.customer_phone_id     := l_customer_phone_id(i);
	        l_audit_vals_rec.old_customer_phone_id := l_customer_phone_id(i);
	     END IF;


             -- set the last_program_code/old_last_progream_code of audit record

              l_audit_vals_rec. last_update_program_code    := 'PARTY_MERGE' ;
	      l_audit_vals_rec.old_last_update_program_code := l_last_update_program_code (i);
              l_audit_vals_rec.updated_entity_code          := 'SR_HEADER';
              l_audit_vals_rec.updated_entity_id            := l_incident_id(i);
              l_audit_vals_rec.entity_activity_code         := 'U';

          END IF;

          CS_ServiceRequest_PVT.Create_Audit_Record (
                         p_api_version         => 2.0,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_request_id          => l_incident_id(i),
                         p_audit_id            => NULL,
                         p_audit_vals_rec      => l_audit_vals_rec ,
                         p_user_id             => G_USER_ID,
                         p_login_id            => G_LOGIN_ID,
                         p_last_update_date    => SYSDATE,
                         p_creation_date       => SYSDATE,
                         p_comments            => NULL,
                         x_audit_id            => l_audit_id);

        END LOOP;

        IF l_last_fetch THEN
           EXIT ;
        END IF ;

       END LOOP;   -- End loop for the batch process.

       CLOSE c1 ;

      EXCEPTION
	 WHEN resource_busy THEN
	    arp_message.set_line(g_proc_name || '.' || l_api_name ||
		       '; Could not obtain lock for records in table '  ||
			  'CS_INCIDENTS_ALL_B  for customer_phone_id / customer_email_id = '
			  || p_from_fk_id );
            x_return_status :=  FND_API.G_RET_STS_ERROR;
	    RAISE;

         WHEN others THEN
	    arp_message.set_line(g_proc_name || '.' || l_api_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
	    RAISE;
      END;
   END IF;
END CS_INC_ALL_MERGE_CONT_POINTS;

END  CS_SR_PARTY_MERGE_PKG;

/
