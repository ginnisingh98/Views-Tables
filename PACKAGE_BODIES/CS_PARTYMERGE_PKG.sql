--------------------------------------------------------
--  DDL for Package Body CS_PARTYMERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_PARTYMERGE_PKG" AS
/* $Header: cssrpmnb.pls 120.2.12010000.3 2009/04/29 10:28:13 bkanimoz ship $ */

-- Declare private package level variables

G_PKG_NAME  CONSTANT  VARCHAR2(30)  := 'CS_PARTYMERGE_PKG';
G_USER_ID   CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID  CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;
G_PROC_NAME  CONSTANT VARCHAR2(30)  := 'UPDATE_CS_DATA';
dbg_msg               VARCHAR2(4000) ;

TYPE ROWID_TBL IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE NUMBER_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_30_TBL IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

PROCEDURE log(
   message 	IN	VARCHAR2,
   newline	IN	BOOLEAN DEFAULT TRUE) IS
BEGIN

  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
END log;

PROCEDURE UPDATE_CS_DATA
     ( p_batch_id         IN   NUMBER,
       p_request_id       IN   NUMBER,
       x_return_status    OUT  NOCOPY VARCHAR2)
IS

-- Declare all the nested tables those will be used in the SR and SR charges transactions merge.

   l_rowid_tbl                      ROWID_TBL;
   l_incident_id_tbl                NUMBER_TBL;
   l_estimate_detail_id_tbl         NUMBER_TBL;
   l_customer_id_tbl                NUMBER_TBL;
   l_from_party_id_tbl              NUMBER_TBL;
   l_to_party_id_tbl                NUMBER_TBL;
   l_bill_to_party_id_tbl           NUMBER_TBL;
   l_from_bill_to_party_id_tbl      NUMBER_TBL;
   l_to_bill_to_party_id_tbl        NUMBER_TBL;
   l_ship_to_party_id_tbl           NUMBER_TBL;
   l_from_ship_to_party_id_tbl      NUMBER_TBL;
   l_to_ship_to_party_id_tbl        NUMBER_TBL;
   l_bill_to_contact_id_tbl         NUMBER_TBL;
   l_from_bill_to_contact_id_tbl    NUMBER_TBL;
   l_to_bill_to_contact_id_tbl      NUMBER_TBL;
   l_ship_to_contact_id_tbl         NUMBER_TBL;
   l_from_ship_to_contact_id_tbl    NUMBER_TBL;
   l_to_ship_to_contact_id_tbl      NUMBER_TBL;
   l_bill_to_site_id_tbl            NUMBER_TBL;
   l_from_bill_to_site_id_tbl       NUMBER_TBL;
   l_to_bill_to_site_id_tbl         NUMBER_TBL;
   l_ship_to_site_id_tbl            NUMBER_TBL;
   l_from_ship_to_site_id_tbl       NUMBER_TBL;
   l_to_ship_to_site_id_tbl         NUMBER_TBL;
   l_site_id_tbl                    NUMBER_TBL;
   l_from_site_id_tbl               NUMBER_TBL;
   l_to_site_id_tbl                 NUMBER_TBL;
   l_customer_site_id_tbl           NUMBER_TBL;
   l_from_customer_site_id_tbl      NUMBER_TBL;
   l_to_customer_site_id_tbl        NUMBER_TBL;
   l_install_site_id_tbl            NUMBER_TBL;
   l_from_install_site_id_tbl       NUMBER_TBL;
   l_to_install_site_id_tbl         NUMBER_TBL;
   l_install_site_use_id_tbl        NUMBER_TBL;
   l_from_install_site_use_id_tbl   NUMBER_TBL;
   l_to_install_site_use_id_tbl     NUMBER_TBL;
   l_incident_location_id_tbl       NUMBER_TBL;
   l_incident_location_type_tbl     VARCHAR2_30_TBL;
   l_from_inc_loc_id_tbl            NUMBER_TBL;
   l_to_incident_location_id_tbl    NUMBER_TBL;
   l_ship_to_site_use_id_tbl        NUMBER_TBL;
   l_from_ship_to_site_use_id_tbl   NUMBER_TBL;
   l_to_ship_to_site_use_id_tbl     NUMBER_TBL;
   l_bill_to_site_use_id_tbl        NUMBER_TBL;
   l_from_bill_to_site_use_id_tbl   NUMBER_TBL;
   l_to_bill_to_site_use_id_tbl     NUMBER_TBL;
   l_customer_phone_id_tbl          NUMBER_TBL;
   l_from_phone_id_tbl              NUMBER_TBL;
   l_to_phone_id_tbl                NUMBER_TBL;
   l_customer_email_id_tbl          NUMBER_TBL;
   l_from_email_id_tbl              NUMBER_TBL;
   l_to_email_id_tbl                NUMBER_TBL;
   l_from_parent_id_tbl             NUMBER_TBL;
   l_to_parent_id_tbl               NUMBER_TBL;
   l_last_update_program_code_tbl   VARCHAR2_30_TBL;
   l_batch_party_id_tbl             NUMBER_TBL;
   l_sr_contact_point_id_tbl        NUMBER_TBL;
   l_extension_id_tbl               NUMBER_TBL;

-- Other local variables

   l_audit_vals_rec             CS_ServiceRequest_PVT.SR_AUDIT_REC_TYPE;
   l_ext_attrs_tbl_new          CS_SR_EXTATTRIBUTES_PVT.Ext_Attr_Audit_Tbl_Type;
   l_ext_attrs_tbl_old          CS_SR_EXTATTRIBUTES_PVT.Ext_Attr_Audit_Tbl_Type;
   l_audit_id                   NUMBER;
   l_last_fetch                 BOOLEAN := FALSE ;
   l_return_status              VARCHAR2(3);
   l_to_id                      NUMBER;
   l_count                      NUMBER;
   x_msg_count                  NUMBER(15);
   x_msg_data                   VARCHAR2(2000);
   RESOURCE_BUSY                EXCEPTION;
   --PRAGMA                       EXCEPTION_INIT(RESOURCE_BUSY, -0054);

-- Cursor to get the impacted service requests

   CURSOR C_Get_ServiceRequests IS
       SELECT /*+ PARALLEL(i) */
              i.rowid,
              i.incident_id ,
              i.customer_id ,
              pc.from_entity_id          from_party_id ,
              pc.to_entity_id            to_party_id ,
              i.bill_to_party_id,
              pbp.from_entity_id         from_bill_to_party_id ,
              pbp.to_entity_id           to_bill_to_party_id,
              i.ship_to_party_id,
              psp.from_entity_id         from_ship_to_party_id ,
              psp.to_entity_id           to_ship_to_party_id,
              i.bill_to_contact_id ,
              pbc.from_entity_id         from_bill_to_contact_id ,
              pbc.to_entity_id           to_bill_to_contact_id ,
              i.ship_to_contact_id ,
              psc.from_entity_id         from_ship_to_contact_id ,
              psc.to_entity_id           to_ship_to_contact_id ,
              i.bill_to_site_id,
              pbs.from_entity_id         from_bill_to_site_id,
              pbs.to_entity_id           to_bill_to_site_id,
              i.ship_to_site_id,
              pss.from_entity_id         from_ship_to_site_id,
              pss.to_entity_id           to_ship_to_site_id,
              i.site_id ,
              ps.from_entity_id          from_site_id,
              ps.to_entity_id            to_site_id,
              i.customer_site_id,
              pcs.from_entity_id         from_customer_site_id,
              pcs.to_entity_id           to_customer_site_id,
              i.install_site_id,
              pis.from_entity_id         from_install_site_id,
              pis.to_entity_id           to_install_site_id,
              i.install_site_use_id,
              pisu.from_entity_id        from_install_site_use_id,
              pisu.to_entity_id          to_install_site_use_id,
              i.incident_location_id,
	      i.incident_location_type,
              pils.from_entity_id        from_incident_location_id,
              pils.to_entity_id          to_incident_location_id,
              i.ship_to_site_use_id,
              psu.from_entity_id         from_ship_to_site_use_id,
              psu.to_entity_id           to_ship_to_site_use_id,
              i.bill_to_site_use_id,
              pbu.from_entity_id         from_bill_to_site_use_id,
              pbu.to_entity_id           to_bill_to_site_use_id,
              i.customer_phone_id,
              pch.from_entity_id         from_phone_id,
              pch.to_entity_id           to_phone_id ,
              i.customer_email_id,
              pce.from_entity_id         from_email_id,
              pce.to_entity_id           to_email_id ,
              i.last_update_program_code
         FROM cs_incidents_all_B i,
              hz_merge_party_log pc,
              hz_merge_party_log pbp,
              hz_merge_party_log psp,
              hz_merge_party_log pbc,
              hz_merge_party_log psc,
              hz_merge_party_log pbs,
              hz_merge_party_log pss,
              hz_merge_party_log ps,
              hz_merge_party_log pcs,
              hz_merge_party_log pis,
              hz_merge_party_log pisu,
              hz_merge_party_log pils,
              hz_merge_party_log psu,
              hz_merge_party_log pbu,
              hz_merge_party_log pch,
              hz_merge_party_log pce
        WHERE pc.request_id(+)          = p_request_id
          AND pc.merge_dict_id(+)       = 1     -- Entity = HZ Party
          AND pc.from_entity_id(+)      = i.customer_id
	  AND pc.operation_type(+)      = 'Merge'
          AND pbp.merge_dict_id(+)      = 1     -- Entity = HZ Party
          AND pbp.request_id(+)         = p_request_id
          AND pbp.from_entity_id(+)     = i.bill_to_party_id
	  AND pbp.operation_type(+)     = 'Merge'
          AND psp.merge_dict_id(+)      = 1     -- Entity = HZ Party
          AND psp.request_id(+)         = p_request_id
          AND psp.from_entity_id(+)     = i.ship_to_party_id
	  AND psp.operation_type(+)     = 'Merge'
          AND pbc.merge_dict_id(+)      = 1     -- Entity = HZ Party
          AND pbc.request_id(+)         = p_request_id
          AND pbc.from_entity_id(+)     = i.bill_to_contact_id
	  AND pbc.operation_type(+)     = 'Merge'
          AND psc.merge_dict_id(+)      = 1     -- Entity = HZ Party
          AND psc.request_id(+)         = p_request_id
          AND psc.from_entity_id(+)     = i.ship_to_contact_id
	  AND psc.operation_type(+)     = 'Merge'
          AND pbs.merge_dict_id(+)      = 3     -- Entity = HZ Party site
          AND pbs.request_id(+)         = p_request_id
          AND pbs.from_entity_id(+)     = i.bill_to_site_id
	  AND pbs.operation_type(+)     = 'Merge'
          AND pss.merge_dict_id(+)      = 3     -- Entity = HZ Party site
          AND pss.request_id(+)         = p_request_id
          AND pss.from_entity_id(+)     = i.ship_to_site_id
	  AND pss.operation_type(+)     = 'Merge'
          AND ps.merge_dict_id(+)       = 3     -- Entity = HZ Party site
          AND ps.request_id(+)          = p_request_id
          AND ps.from_entity_id(+)      = i.site_id
	  AND ps.operation_type(+)      = 'Merge'
          AND pcs.merge_dict_id(+)      = 3     -- Entity = HZ Party site
          AND pcs.request_id(+)         = p_request_id
          AND pcs.from_entity_id(+)     = i.customer_site_id
	  AND pcs.operation_type(+)     = 'Merge'
          AND pis.merge_dict_id(+)      = 3     -- Entity = HZ Party site
          AND pis.request_id(+)         = p_request_id
          AND pis.from_entity_id(+)     = i.install_site_id
	  AND pis.operation_type(+)     = 'Merge'
          AND pisu.merge_dict_id(+)     = 3     -- Entity = HZ Party site
          AND pisu.request_id(+)        = p_request_id
          AND pisu.from_entity_id(+)    = i.install_site_use_id
	  AND pisu.operation_type(+)    = 'Merge'
          AND pils.merge_dict_id(+)     = 3     -- Entity = HZ Party site
          AND pils.request_id(+)        = p_request_id
          AND pils.from_entity_id(+)    = i.incident_location_id
	  AND pils.operation_type(+)    = 'Merge'
          AND psu.merge_dict_id(+)      = 19     -- Entity = HZ Party Site Use
          AND psu.request_id(+)         = p_request_id
          AND psu.from_entity_id(+)     = i.ship_to_site_use_id
	  AND psu.operation_type(+)     = 'Merge'
          AND pbu.merge_dict_id(+)      = 19     -- Entity = HZ Party Site Use
          AND pbu.request_id(+)         = p_request_id
          AND pbu.from_entity_id(+)     = i.bill_to_site_use_id
	  AND pbu.operation_type(+)     = 'Merge'
          AND pch.merge_dict_id(+)      = 4     -- Entity = HZ Contact Point
          AND pch.request_id(+)         = p_request_id
          AND pch.from_entity_id(+)     = i.customer_phone_id
	  AND pch.operation_type(+)     = 'Merge'
          AND pce.merge_dict_id(+)      = 4     -- Entity = HZ Contact Point
          AND pce.request_id(+)         = p_request_id
          AND pce.from_entity_id(+)     = i.customer_email_id
	  AND pce.operation_type(+)     = 'Merge'
          AND (pc.from_entity_id is not null OR
	       pbp.from_entity_id is not null OR
	       psp.from_entity_id is not null OR
	       pbc.from_entity_id is not null OR
	       psc.from_entity_id is not null OR
	       pbs.from_entity_id is not null OR
	       pss.from_entity_id is not null OR
	       pcs.from_entity_id is not null OR
	       ps.from_entity_id is not null OR
	       pis.from_entity_id is not null OR
	       pisu.from_entity_id is not null OR
	       pils.from_entity_id is not null OR
	       psu.from_entity_id is not null OR
	       pbu.from_entity_id is not null OR
	       pch.from_entity_id is not null OR
	       pce.from_entity_id is not null
	      ) ;

-- Cursor to get the impacted SR charge transactions

   CURSOR C_Get_Estimate_details IS
       SELECT /*+ PARALLEL(c) */
              c.rowid,
              c.estimate_detail_id,
              c.bill_to_party_id,
              pbp.from_entity_id  from_bill_to_party_id ,
              pbp.to_entity_id  to_bill_to_party_id,
              c.ship_to_party_id,
              psp.from_entity_id  from_ship_to_party_id ,
              psp.to_entity_id  to_ship_to_party_id,
              c.bill_to_contact_id ,
              pbc.from_entity_id  from_bill_to_contact_id ,
              pbc.to_entity_id  to_bill_to_contact_id ,
              c.ship_to_contact_id ,
              psc.from_entity_id  from_ship_to_contact_id ,
              psc.to_entity_id  to_ship_to_contact_id ,
              c.invoice_to_org_id,
              pbs.from_entity_id  from_bill_to_site_id,
              pbs.to_entity_id  to_bill_to_site_id,
              c.ship_to_org_id,
              pss.from_entity_id  from_ship_to_site_id,
              pss.to_entity_id  to_ship_to_site_id
         FROM cs_estimate_details c,
              hz_merge_party_log pbp,
              hz_merge_party_log psp,
              hz_merge_party_log pbc,
              hz_merge_party_log psc,
              hz_merge_party_log pbs,
              hz_merge_party_log pss
        WHERE pbp.merge_dict_id(+)         = 1     -- Entity = HZ Party
          AND pbp.request_id(+)            = p_request_id
          AND pbp.from_entity_id(+)        = c.bill_to_party_id
          AND pbp.operation_type(+)        = 'Merge'
          AND psp.merge_dict_id(+)         = 1     -- Entity = HZ Party
          AND psp.request_id(+)            = p_request_id
          AND psp.from_entity_id(+)        = c.ship_to_party_id
          AND psp.operation_type(+)        = 'Merge'
          AND pbc.merge_dict_id(+)         = 1     -- Entity = HZ Party
          AND pbc.request_id(+)            = p_request_id
          AND pbc.from_entity_id(+)        = c.bill_to_contact_id
          AND pbc.operation_type(+)        = 'Merge'
          AND psc.merge_dict_id(+)         = 1     -- Entity = HZ Party
          AND psc.request_id(+)            = p_request_id
          AND psc.from_entity_id(+)        = c.ship_to_contact_id
          AND psc.operation_type(+)        = 'Merge'
          AND pbs.merge_dict_id(+)         = 3     -- Entity = HZ Party Site
          AND pbs.request_id(+)            = p_request_id
          AND pbs.from_entity_id(+)        = c.invoice_to_org_id
          --AND pbs.operation_type(+)        = 'Merge'            --bug 7310180
          AND pss.merge_dict_id(+)         = 3     -- Entity = HZ Party Site
          AND pss.request_id(+)            = p_request_id
          AND pss.from_entity_id(+)        = c.ship_to_org_id
          --AND pss.operation_type(+)        = 'Merge'            --bug 7310180
          AND (pbp.from_entity_id is not null OR
	       psp.from_entity_id is not null OR
	       pbc.from_entity_id is not null OR
	       psc.from_entity_id is not null OR
	       pbs.from_entity_id is not null OR
	       pss.from_entity_id is not null );

-- Cursor to get the merged parties from the TCA log tables.

    CURSOR c_Get_Merged_Parties IS
           SELECT batch_party_id ,
                  from_party_id ,
                  to_party_id
             FROM hz_merge_parties
            WHERE merge_reason_code <> 'SAME_PARTY_MERGE'
              AND batch_id           = p_batch_id;

-- Cursor to get impacted Contact point transactions due to party merge using TCA log table and CS_HZ_SR_Contact_Points table.

   CURSOR C_get_contact_point_txns1 IS
          SELECT p.from_entity_id ,
                 p.to_entity_id ,
                 p.batch_party_id,
                 cc.sr_contact_point_id
            FROM hz_merge_party_log p,
                 cs_hz_sr_contact_points cc
           WHERE p.merge_dict_id         = 4
             AND p.operation_type        = 'Merge'
             AND p.request_id            = p_request_id
             AND p.from_entity_id        = cc.contact_point_id
             AND cc.contact_type         <> 'EMPLOYEE';

-- Cursor to get impacted Contact points data due to contact point merge using TCA log table and cs_hz_sr_contact_points table.

    CURSOR c_Get_contact_point_txns2 IS
           SELECT p.batch_party_id,
                  p.from_party_id ,
                  p.to_party_id ,
                  cc.sr_contact_point_id
             FROM hz_merge_parties p,
                  cs_hz_sr_contact_points cc
            WHERE p.merge_type        <> 'SAME_PARTY_MERGE'
	      AND p.batch_id          = p_batch_id
              AND p.from_party_id    = cc.party_id
              AND cc.contact_type     <> 'EMPLOYEE';

-- Cursor to get impacted ext attr records related to party role

    CURSOR c_get_party_ext_attr_rec IS
           SELECT ex.rowid,
                  ex.extension_id,
                  ex.party_id ,
                  p.from_party_id ,
                  p.to_party_id
             FROM hz_merge_parties p,
                  cs_sr_contacts_ext ex
           WHERE ex.party_id = p.from_party_id
             AND p.batch_id          = p_batch_id
             AND p.merge_type        <> 'SAME_PARTY_MERGE';

BEGIN
-- Call HZ Routine to populate the party merge log table


      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
           dbg_msg := ('In CS_PartyMerge_PKG.Update_CS_Data');
           IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
           END IF;
        END IF;
      END IF;

arp_message.set_line('CS_PARTYMERGE_PKG.UPDATE_CS_DATA()+');

x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- Update service request transaction data and create a SR audit record for each service request that is updated.
  ----------------------------------------------------------------------------------------------------------------

  BEGIN
      -- get all the impacted service request in a batch of 1000 service requests.


      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
           dbg_msg := ('Merging Service Request transactions');
           IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
           END IF;
        END IF;
      END IF;
         -- obtain lock on records to be updated.
            arp_message.set_name('AR', 'AR_LOCKING_TABLE');
            arp_message.set_token('TABLE_NAME', 'CS_INCIDENTS_ALL_B', FALSE);

            OPEN  C_Get_ServiceRequests;
               LOOP            -- Loop for BULK SR  processing in a batch of 1000

                   FETCH C_Get_ServiceRequests BULK COLLECT
                    INTO l_rowid_tbl,
                         l_incident_id_tbl ,
                         l_customer_id_tbl ,
                         l_from_party_id_tbl ,
                         l_to_party_id_tbl ,
                         l_bill_to_party_id_tbl,
                         l_from_bill_to_party_id_tbl ,
                         l_to_bill_to_party_id_tbl,
                         l_ship_to_party_id_tbl,

                         l_from_ship_to_party_id_tbl ,
                         l_to_ship_to_party_id_tbl,
                         l_bill_to_contact_id_tbl ,
                         l_from_bill_to_contact_id_tbl ,
                         l_to_bill_to_contact_id_tbl ,
                         l_ship_to_contact_id_tbl ,
                         l_from_ship_to_contact_id_tbl ,
                         l_to_ship_to_contact_id_tbl ,
                         l_bill_to_site_id_tbl,
                         l_from_bill_to_site_id_tbl,
                         l_to_bill_to_site_id_tbl,
                         l_ship_to_site_id_tbl,
                         l_from_ship_to_site_id_tbl,
                         l_to_ship_to_site_id_tbl,
                         l_site_id_tbl ,
                         l_from_site_id_tbl,
                         l_to_site_id_tbl,
                         l_customer_site_id_tbl,
                         l_from_customer_site_id_tbl,
                         l_to_customer_site_id_tbl,
                         l_install_site_id_tbl,
                         l_from_install_site_id_tbl,
                         l_to_install_site_id_tbl,
                         l_install_site_use_id_tbl,
                         l_from_install_site_use_id_tbl,
                         l_to_install_site_use_id_tbl,
                         l_incident_location_id_tbl,
	                 l_incident_location_type_tbl,
                         l_from_inc_loc_id_tbl          ,
                         l_to_incident_location_id_tbl,
                         l_ship_to_site_use_id_tbl,
                         l_from_ship_to_site_use_id_tbl,
                         l_to_ship_to_site_use_id_tbl,
                         l_bill_to_site_use_id_tbl,
                         l_from_bill_to_site_use_id_tbl,
                         l_to_bill_to_site_use_id_tbl,
                         l_customer_phone_id_tbl,
                         l_from_phone_id_tbl,
                         l_to_phone_id_tbl ,
                         l_customer_email_id_tbl,
                         l_from_email_id_tbl,
                         l_to_email_id_tbl ,
                         l_last_update_program_code_tbl
                   LIMIT 5000 ;    --Bug fix for 7484639

                   IF C_Get_ServiceRequests%NOTFOUND THEN
                      l_last_fetch := TRUE;
                   END IF;

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                     IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                        dbg_msg := ('No of Service requests to be updated : '||C_Get_ServiceRequests%ROWCOUNT);
                        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                        END IF;
                     END IF;
                   END IF;

                   IF l_rowid_tbl.count <> 0 AND NOT l_last_fetch THEN    -- for last fetch
                      EXIT;
                   END IF;

                      -- update cs_incidents_all_b table

                         FORALL i IN 1..l_rowid_tbl.COUNT -- ..l_rowid_tbl.LAST

                           UPDATE cs_incidents_all_b i
                              SET i.customer_id               = DECODE(i.customer_id,l_from_party_id_tbl(i),
                                                                       l_to_party_id_tbl(i) , i.customer_id),
                                  i.bill_to_party_id          = DECODE(i.bill_to_party_id,l_from_bill_to_party_id_tbl(i),
                                                                       l_to_bill_to_party_id_tbl(i),i.bill_to_party_id),
                                  i.ship_to_party_id          = DECODE(i.ship_to_party_id , l_from_ship_to_party_id_tbl(i) ,
                                                                       l_to_ship_to_party_id_tbl(i) , i.ship_to_party_id),
                                  i.bill_to_contact_id        = DECODE(i.bill_to_contact_id , l_from_bill_to_contact_id_tbl(i) ,
                                                                       l_to_bill_to_contact_id_tbl(i) , i.bill_to_contact_id),
                                  i.ship_to_contact_id        = DECODE(i.ship_to_contact_id , l_from_ship_to_contact_id_tbl(i) ,
                                                                       l_to_ship_to_contact_id_tbl(i) , i.ship_to_contact_id),
                                  i.bill_to_site_id           = DECODE(i.bill_to_site_id , l_from_bill_to_site_id_tbl(i),
                                                                       l_to_bill_to_site_id_tbl(i) , i.bill_to_site_id),
                                  i.ship_to_site_id           = DECODE(i.ship_to_site_id , l_from_ship_to_site_id_tbl(i),
                                                                       l_to_ship_to_site_id_tbl(i) , i.ship_to_site_id),
                                  i.site_id                   = DECODE(i.site_id , l_from_site_id_tbl(i) ,
                                                                       l_to_site_id_tbl(i) , i.site_id),
                                  i.customer_site_id          = DECODE(i.customer_site_id , l_from_customer_site_id_tbl(i) ,
                                                                       l_to_customer_site_id_tbl(i) , i.install_site_id),
                                  i.install_site_id           = DECODE(i.install_site_id , l_from_install_site_id_tbl(i) ,
                                                                       l_to_install_site_id_tbl(i) , i.install_site_use_id ),
                                  i.install_site_use_id       = DECODE(i.install_site_use_id , l_from_install_site_use_id_tbl(i) ,
                                                                       l_to_install_site_use_id_tbl(i) , i.install_site_use_id),
                                  i.incident_location_id      = DECODE(i.incident_location_type , 'HZ_PARTY_SITE',
                                                                 DECODE (i.incident_location_id , l_from_inc_loc_id_tbl(i) ,
                                                                         l_to_incident_location_id_tbl(i) , i.incident_location_id),


                                                                       i.incident_location_id),
                                  i.ship_to_site_use_id       = DECODE(i.ship_to_site_use_id , l_from_ship_to_site_use_id_tbl(i) ,
                                                                       l_to_ship_to_site_use_id_tbl(i) , i.ship_to_site_use_id),
                                  i.bill_to_site_use_id       = DECODE(i.bill_to_site_use_id , l_from_bill_to_site_use_id_tbl(i) ,
                                                                       l_to_bill_to_site_use_id_tbl(i) , i.bill_to_site_use_id),
                                  i.customer_phone_id         = DECODE(i.customer_phone_id , l_from_phone_id_tbl(i) ,
                                                                       l_to_phone_id_tbl(i) , i.customer_phone_id),
                                  i.customer_email_id         = DECODE(i.customer_email_id , l_from_email_id_tbl(i) ,
                                                                       l_to_email_id_tbl(i) , i.customer_email_id),
                                  object_version_number       = object_version_number + 1,
                                  incident_last_modified_date = sysdate ,
                                  last_update_program_code    = 'PARTY_MERGE',
                                  last_update_date            = SYSDATE,
                                  last_updated_by             = G_USER_ID,

                                  last_update_login           = G_LOGIN_ID
                            WHERE rowid = l_rowid_tbl(i);

                            l_count := sql%rowcount;

                            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                              IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                                 dbg_msg := ('No. of service requests updated : '||l_count);
                                 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                                 END IF;
                              END IF;
                            END IF;

                            arp_message.set_name('AR', 'AR_ROWS_UPDATED');
                            arp_message.set_token('NUM_ROWS', to_char(l_count) );

                      -- Create SR Audit record for each updated service request transaction

                            dbg_msg := ('Creating SR Audit record for each updated service request');

                            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                              IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                                 dbg_msg := ('Calling CS_PartyMerge_PKG.Update_CS_Data API ');
                                 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                                 END IF;
                              END IF;
                            END IF;

                         FOR i IN 1..l_incident_id_tbl.COUNT
                             LOOP
                                 -- Prepare SR audit record structure
                                    CS_Servicerequest_UTIL.Prepare_Audit_Record
                                              (p_api_version    => 1,
                                               p_request_id     => l_incident_id_tbl(i),
                                               x_return_status  => l_return_status,
                                               x_msg_count      => x_msg_count,
                                               x_msg_data       => x_msg_data,
                                               x_audit_vals_rec => l_audit_vals_rec);

                                     IF l_return_status <> FND_API.G_RET_STS_ERROR Then

                                        -- Populate the old values

                                        IF l_audit_vals_rec.customer_id <> l_customer_id_tbl(i) THEN
                                           l_audit_vals_rec.old_customer_id              := l_customer_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.bill_to_party_id <> l_bill_to_party_id_tbl(i) THEN
                                           l_audit_vals_rec.old_bill_to_party_id         := l_bill_to_party_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.ship_to_party_id <> l_ship_to_party_id_tbl(i) THEN
                                           l_audit_vals_rec.old_ship_to_party_id         := l_ship_to_party_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.bill_to_contact_id <> l_bill_to_contact_id_tbl(i) THEN
                                           l_audit_vals_rec.old_bill_to_contact_id       := l_bill_to_contact_id_tbl(i);
                                           l_audit_vals_rec.change_bill_to_flag          := 'Y';
                                        END IF;

                                        IF l_audit_vals_rec.ship_to_contact_id <> l_ship_to_contact_id_tbl(i) THEN
                                           l_audit_vals_rec.old_ship_to_contact_id       := l_ship_to_contact_id_tbl(i);
                                           l_audit_vals_rec.change_ship_to_FLAG          := 'Y';
                                        END IF;

                                        IF l_audit_vals_rec.bill_to_site_id <> l_bill_to_site_id_tbl(i) THEN
                                           l_audit_vals_rec.old_bill_to_site_id          := l_bill_to_site_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.ship_to_site_id <> l_ship_to_site_id_tbl(i) THEN
                                           l_audit_vals_rec.old_ship_to_site_id          := l_ship_to_site_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.site_id <> l_site_id_tbl(i) THEN
                                           l_audit_vals_rec.old_site_id                  := l_site_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.customer_site_id <> l_customer_site_id_tbl(i) THEN
                                           l_audit_vals_rec.old_customer_site_id         := l_customer_site_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.install_site_id <> l_install_site_id_tbl(i) THEN
                                           l_audit_vals_rec.old_install_site_id          := l_install_site_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.install_site_use_id <> l_install_site_use_id_tbl(i) THEN
                                           l_audit_vals_rec.old_install_site_use_id      := l_install_site_use_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.bill_to_party_id <> l_bill_to_party_id_tbl(i) THEN
                                           l_audit_vals_rec.old_bill_to_party_id         := l_bill_to_party_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.incident_location_type = 'HZ_PARTY_SITE' THEN
                                           IF l_audit_vals_rec.incident_location_id <> l_incident_location_id_tbl(i) THEN
                                              l_audit_vals_rec.old_incident_location_id  := l_incident_location_id_tbl(i);
                                           END IF ;
                                        END IF;

                                        IF l_audit_vals_rec.ship_to_site_use_id <> l_ship_to_site_use_id_tbl(i) THEN
                                           l_audit_vals_rec.old_ship_to_site_use_id      := l_ship_to_site_use_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.customer_phone_id <> l_customer_phone_id_tbl(i) THEN
                                           l_audit_vals_rec.old_customer_phone_id        := l_customer_phone_id_tbl(i);
                                        END IF;

                                        IF l_audit_vals_rec.customer_email_id <> l_customer_email_id_tbl(i) THEN
                                           l_audit_vals_rec.old_customer_email_id        := l_customer_email_id_tbl(i);
                                        END IF;
                                           l_audit_vals_rec.old_last_update_program_code := l_last_update_program_code_tbl(i) ;
                                           l_audit_vals_rec.last_update_program_code     := 'PARTY_MERGE' ;
                                           l_audit_vals_rec.updated_entity_code          := 'SR_HEADER';
                                           l_audit_vals_rec.updated_entity_id            := l_incident_id_tbl(i);
                                           l_audit_vals_rec.entity_activity_code         := 'U' ;

                                     END IF;

                                 -- Call Create SR Audit API

                                    CS_ServiceRequest_PVT.Create_Audit_Record
                                            (p_api_version         => 2.0,
                                             x_return_status       => l_return_status,
                                             x_msg_count           => x_msg_count,
                                             x_msg_data            => x_msg_data,
                                             p_request_id          => l_incident_id_tbl(i),
                                             p_audit_id            => NULL,
                                             p_audit_vals_rec      => l_audit_vals_rec,
                                             p_user_id             => G_USER_ID,
                                             p_login_id            => G_LOGIN_ID,
                                             p_last_update_date    => SYSDATE,
                                             p_creation_date       => SYSDATE,
                                             p_comments            => NULL,
                                             x_audit_id            => l_audit_id);

                                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                          RAISE FND_API.G_EXC_ERROR;
                                       END IF ;

                             END LOOP;   -- End loop for SR auditing


                            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                              IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                                 dbg_msg := ('Created SR audit records for the SRs updated in a batch');
                                 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                                 END IF;
                              END IF;
                            END IF;

                   IF l_last_fetch THEN
                      EXIT;
                   END IF ;

               END LOOP; -- End lool for BULK SR processing  in a batch of 1000
               CLOSE C_Get_ServiceRequests;
  EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
            arp_message.set_line(g_pkg_name || '.' || g_proc_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            ROLLBACK;
            RAISE;

       WHEN resource_busy THEN
            arp_message.set_line(g_pkg_name || '.' || g_proc_name || ': Could not obtain lock for records in table '||
                                 'CS_INCIDENTS_ALL_B  for columns referring HZ parties');
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            ROLLBACK;
            RAISE;

       WHEN others THEN
            arp_message.set_line(g_pkg_name || '.' || g_proc_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            ROLLBACK;
            RAISE;
  END ;



       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
         IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
            dbg_msg := ('Updating Service Request Transactions completed');
            IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
            END IF;
         END IF;
       END IF;

  -- Release the service request data in the memory

  BEGIN

       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
         IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
            dbg_msg := ('Releasing memory');
            IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
            END IF;
         END IF;
       END IF;

   l_rowid_tbl.DELETE;
   l_incident_id_tbl.DELETE;
   l_estimate_detail_id_tbl.DELETE;
   l_customer_id_tbl.DELETE;
   l_from_party_id_tbl.DELETE;
   l_to_party_id_tbl.DELETE;
   l_bill_to_party_id_tbl.DELETE;
   l_from_bill_to_party_id_tbl.DELETE;
   l_to_bill_to_party_id_tbl.DELETE;
   l_ship_to_party_id_tbl.DELETE;
   l_from_ship_to_party_id_tbl.DELETE;
   l_to_ship_to_party_id_tbl.DELETE;
   l_bill_to_contact_id_tbl.DELETE;
   l_from_bill_to_contact_id_tbl.DELETE;
   l_to_bill_to_contact_id_tbl.DELETE;
   l_ship_to_contact_id_tbl.DELETE;
   l_from_ship_to_contact_id_tbl.DELETE;
   l_to_ship_to_contact_id_tbl.DELETE;
   l_bill_to_site_id_tbl.DELETE;
   l_from_bill_to_site_id_tbl.DELETE;
   l_to_bill_to_site_id_tbl.DELETE;
   l_ship_to_site_id_tbl.DELETE;
   l_from_ship_to_site_id_tbl.DELETE;
   l_to_ship_to_site_id_tbl.DELETE;
   l_site_id_tbl.DELETE;
   l_from_site_id_tbl.DELETE;
   l_to_site_id_tbl.DELETE;
   l_customer_site_id_tbl.DELETE;
   l_from_customer_site_id_tbl.DELETE;
   l_to_customer_site_id_tbl.DELETE;
   l_install_site_id_tbl.DELETE;
   l_from_install_site_id_tbl.DELETE;
   l_to_install_site_id_tbl.DELETE;
   l_install_site_use_id_tbl.DELETE;
   l_from_install_site_use_id_tbl.DELETE;
   l_to_install_site_use_id_tbl.DELETE;
   l_incident_location_id_tbl.DELETE;
   l_incident_location_type_tbl.DELETE;
   l_from_inc_loc_id_tbl.DELETE;
   l_to_incident_location_id_tbl.DELETE;
   l_ship_to_site_use_id_tbl.DELETE;
   l_from_ship_to_site_use_id_tbl.DELETE;
   l_to_ship_to_site_use_id_tbl.DELETE;
   l_bill_to_site_use_id_tbl.DELETE;
   l_from_bill_to_site_use_id_tbl.DELETE;
   l_to_bill_to_site_use_id_tbl.DELETE;
   l_customer_phone_id_tbl.DELETE;
   l_from_phone_id_tbl.DELETE;
   l_to_phone_id_tbl.DELETE;
   l_customer_email_id_tbl.DELETE;
   l_from_email_id_tbl.DELETE;
   l_to_email_id_tbl.DELETE;
   l_last_update_program_code_tbl.DELETE;
   l_last_fetch := FALSE;
   l_count      := 0;


       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
         IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
            dbg_msg := ('Releasing memory completed');
            IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
            END IF;
         END IF;
       END IF;
 END;


  -- Update SR charges transaction data
  --------------------------------------------

  BEGIN

       IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
         IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
            dbg_msg := ('Updating SR Charges transactions');
            IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
            END IF;
         END IF;
       END IF;

      -- get all the impacted SR Charges transactions in a batch of 1000 .
         -- obtain lock on records to be updated.
            arp_message.set_name('AR', 'AR_LOCKING_TABLE');
            arp_message.set_token('TABLE_NAME', 'CS_ESTIMATE_DETAILS', FALSE);

            OPEN  C_Get_Estimate_details;
              LOOP            -- Loop for BULK SR charges processing in a batch of 1000
                 FETCH C_Get_Estimate_details BULK COLLECT
                  INTO l_rowid_tbl,
                       l_estimate_detail_id_tbl ,
                       l_bill_to_party_id_tbl,
                       l_from_bill_to_party_id_tbl ,
                       l_to_bill_to_party_id_tbl,
                       l_ship_to_party_id_tbl,
                       l_from_ship_to_party_id_tbl ,
                       l_to_ship_to_party_id_tbl,
                       l_bill_to_contact_id_tbl ,
                       l_from_bill_to_contact_id_tbl ,
                       l_to_bill_to_contact_id_tbl ,
                       l_ship_to_contact_id_tbl ,
                       l_from_ship_to_contact_id_tbl ,
                       l_to_ship_to_contact_id_tbl ,
                       l_bill_to_site_id_tbl,
                       l_from_bill_to_site_id_tbl,
                       l_to_bill_to_site_id_tbl,
                       l_ship_to_site_id_tbl,
                       l_from_ship_to_site_id_tbl,
                       l_to_ship_to_site_id_tbl
                   LIMIT 1000 ;

                   IF C_Get_Estimate_details%NOTFOUND THEN
                      l_last_fetch := TRUE;
                   END IF;

                   IF l_rowid_tbl.count <> 0 AND l_last_fetch = FALSE  THEN    -- for last fetch
                      EXIT;
                   END IF;

                   IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                     IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                        dbg_msg := ('No of SR Charge transactions to be updated in a batch : '||C_Get_Estimate_details%ROWCOUNT);
                        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                        END IF;
                     END IF;
                   END IF;

                      -- update cs_estimate_details table

                         FORALL i IN 1..l_rowid_tbl.COUNT

                           UPDATE cs_estimate_details c
                              SET c.bill_to_party_id          = DECODE(c.bill_to_party_id , l_from_bill_to_party_id_tbl(i) ,
                                                                       l_to_bill_to_party_id_tbl(i) , c.bill_to_party_id),
                                  c.ship_to_party_id          = DECODE(c.ship_to_party_id , l_from_ship_to_party_id_tbl(i) ,
                                                                       l_to_ship_to_party_id_tbl(i) , c.ship_to_party_id),
                                  c.bill_to_contact_id        = DECODE(c.bill_to_contact_id , l_from_bill_to_contact_id_tbl(i) ,
                                                                       l_to_bill_to_contact_id_tbl(i) , c.bill_to_contact_id),
                                  c.ship_to_contact_id        = DECODE(c.ship_to_contact_id , l_from_ship_to_contact_id_tbl(i) ,
                                                                       l_to_ship_to_contact_id_tbl(i) , c.ship_to_contact_id),
                                  c.invoice_to_org_id         = DECODE(c.invoice_to_org_id , l_from_bill_to_site_id_tbl(i),
                                                                       l_to_bill_to_site_id_tbl(i) , c.invoice_to_org_id),
                                  c.ship_to_org_id            = DECODE(c.ship_to_org_id , l_from_ship_to_site_id_tbl(i),
                                                                       l_to_ship_to_site_id_tbl(i) , c.ship_to_org_id),
                                  object_version_number       = object_version_number + 1,
                                  last_update_date            = SYSDATE,
                                  last_updated_by             = G_USER_ID,
                                  last_update_login           = G_LOGIN_ID
                            WHERE rowid = l_rowid_tbl(i);

                            l_count := sql%rowcount;

                            IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                              IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                                 dbg_msg := ('No of SR Charge transactions updated : '||l_count);
                                 IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                                 END IF;
                              END IF;
                            END IF;

                            arp_message.set_name('AR', 'AR_ROWS_UPDATED');
                            arp_message.set_token('NUM_ROWS', to_char(l_count) );

                   IF l_last_fetch THEN
                      EXIT;
                   END IF ;

              END LOOP;    -- End Loop for BULK SR charges processing in a batch of 1000

            CLOSE  C_Get_Estimate_details;

  EXCEPTION
       WHEN resource_busy THEN
            arp_message.set_line(g_pkg_name || '.' || g_proc_name || ': Could not obtain lock for records in table '||
                                 'CS_ESTIMATE_DETAILS  for columns referring HZ entities');
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            ROLLBACK;
            RAISE;

       WHEN others THEN
            arp_message.set_line(g_pkg_name || '.' || g_proc_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;

            ROLLBACK;
            RAISE;
  END ;

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
         dbg_msg := ('SR Charge transactions updated, Releasing memory');
         IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
         END IF;
       END IF;
     END IF;

  -- Release the service request data in the memory

  BEGIN
     l_rowid_tbl.DELETE;
     l_estimate_detail_id_tbl.DELETE;
     l_bill_to_party_id_tbl.DELETE;
     l_from_bill_to_party_id_tbl.DELETE;
     l_to_bill_to_party_id_tbl.DELETE;
     l_ship_to_party_id_tbl.DELETE;
     l_from_ship_to_party_id_tbl.DELETE;
     l_to_ship_to_party_id_tbl.DELETE;
     l_bill_to_contact_id_tbl.DELETE;
     l_from_bill_to_contact_id_tbl.DELETE;
     l_to_bill_to_contact_id_tbl.DELETE;
     l_ship_to_contact_id_tbl.DELETE;
     l_from_ship_to_contact_id_tbl.DELETE;
     l_to_ship_to_contact_id_tbl.DELETE;
     l_from_bill_to_site_id_tbl.DELETE;
     l_to_bill_to_site_id_tbl.DELETE;
     l_from_ship_to_site_id_tbl.DELETE;
     l_to_ship_to_site_id_tbl.DELETE;
   END;


     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
         dbg_msg := ('Releasing memory done');
         IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
         END IF;
       END IF;
     END IF;

  -- Update SR contact points transaction data
  --------------------------------------------

  BEGIN

     IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
       IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
         dbg_msg := ('Updating SR Contact point transactions ');
         IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
         END IF;
       END IF;
     END IF;

   -- Merging party ids in contact points table.
      -- get all the merged parties transactions in a batch of 1000 .

         OPEN  c_Get_contact_point_txns2;
            LOOP            -- Loop for BULK SR charges processing in a batch of 1000
              FETCH c_Get_contact_point_txns2 BULK COLLECT
               INTO l_batch_party_id_tbl ,
                    l_from_party_id_tbl ,
                    l_to_party_id_tbl,
                    l_sr_contact_point_id_tbl
              LIMIT 1000;

              IF c_Get_contact_point_txns2%NOTFOUND THEN
                 l_last_fetch := TRUE;
              END IF;


              IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                  dbg_msg := ('No. of SR Contact point transactions to be updated in a batch and impacted due to party merge : '||c_Get_contact_point_txns2%ROWCOUNT);
                  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                  END IF;
                END IF;
              END IF;

              IF l_from_party_id_tbl.count <> 0 AND l_last_fetch = FALSE  THEN    -- for last fetch
                 EXIT;
              END IF ;

                 -- Call SR routine to update party id in cs_hz_sr_contact_points table.

                    FOR i IN 1..l_sr_contact_point_id_tbl.COUNT
                       LOOP
                           CS_SR_PARTY_MERGE_PKG.CS_CONTACTS_MERGE_PARTY
                               ( p_entity_name         => 'CS_HZ_SR_CONTACT_POINTS',
                                 p_from_id             => l_sr_contact_point_id_tbl(i),
                                 x_to_id               => l_to_id,
                                 p_from_fk_id          => l_from_party_id_tbl(i),
                                 p_to_fk_id            => l_to_party_id_tbl(i),
                                 p_parent_entity_name  => 'HZ_PARTIES',
                                 p_batch_id            => p_batch_id,
                                 p_batch_party_id      => l_batch_party_id_tbl(i),
                                 x_return_status       => l_return_status );
                       END LOOP;

                    IF l_last_fetch THEN
                       EXIT;
                    END IF ;

           END LOOP;    -- End Loop for BULK SR charges processing in a batch of 1000
        CLOSE c_Get_contact_point_txns2;

        -- Clear the memory

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
               dbg_msg := ('SR contact point ,impacted due to party merge, transactions updated, Releasing memory');
               IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
               END IF;
             END IF;
           END IF;

           l_from_party_id_tbl.DELETE;
           l_to_party_id_tbl.DELETE;
           l_batch_party_id_tbl.DELETE;
           l_sr_contact_point_id_tbl.DELETE;

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
               dbg_msg := ('Releasing memory done');
               IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
               END IF;
             END IF;
           END IF;

   -- Merging contact points
      -- get all the merged contact points transactions in a batch of 1000 .


         IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
           IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
             dbg_msg := ('Updating SR contact point transactions.');
             IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
             END IF;
           END IF;
         END IF;

            OPEN  c_Get_contact_point_txns1;
              LOOP            -- Loop for BULK SR charges processing in a batch of 1000
                 FETCH c_Get_contact_point_txns1 BULK COLLECT
                  INTO l_from_email_id_tbl ,
                       l_to_email_id_tbl   ,
                       l_batch_party_id_tbl ,
                       l_sr_contact_point_id_tbl
                 LIMIT 1000;

                 IF c_Get_contact_point_txns1%NOTFOUND THEN
                    l_last_fetch := TRUE;
                 END IF;


                 IF l_from_email_id_tbl.count <> 0 AND l_last_fetch = FALSE  THEN    -- for last fetch
                    EXIT;
                 END IF ;

                 IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                   IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                     dbg_msg := ('SR contact point transactions to be updated : '||c_Get_contact_point_txns1%ROWCOUNT);
                     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                     END IF;
                   END IF;
                 END IF;
                    -- update cs_estimate_details table

                       FOR i IN 1..l_sr_contact_point_id_tbl.COUNT

                           LOOP
                              CS_SR_PARTY_MERGE_PKG.CS_CONTACTS_MERGE_CONT_POINTS
                                   ( p_entity_name         => 'CS_HZ_SR_CONTACT_POINTS',
                                     p_from_id             => l_sr_contact_point_id_tbl(i),
                                     x_to_id               => l_to_id,
                                     p_from_fk_id          => l_from_email_id_tbl(i),
                                     p_to_fk_id            => l_to_email_id_tbl(i),
                                     p_parent_entity_name  => 'HZ_CONTACT_POINTS',
                                     p_batch_id            => p_batch_id,
                                     p_batch_party_id      => l_batch_party_id_tbl(i),
                                     x_return_status       => l_return_status );
                           END LOOP;

                      IF l_last_fetch THEN
                         EXIT;
                      END IF ;
              END LOOP;    -- End Loop for BULK SR charges processing in a batch of 1000
            CLOSE  c_Get_contact_point_txns1;

        -- Clear the memory

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
               dbg_msg := ('SR contact point ,impacted due to contact point merge, transactions updated, Releasing memory');
               IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
               END IF;
             END IF;
           END IF;

           l_from_email_id_tbl.DELETE;
           l_to_email_id_tbl.DELETE;
           l_batch_party_id_tbl.DELETE;
           l_sr_contact_point_id_tbl.DELETE;

           IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
             IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
               dbg_msg := ('Releasing memory done');
               IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
               END IF;
             END IF;
           END IF;

  EXCEPTION
       WHEN others THEN
            arp_message.set_line(g_pkg_name || '.' || g_proc_name || ': ' || sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
            ROLLBACK;
            RAISE;
  END;

  -- Update party id in SR Charges set up data
  --------------------------------------------

  BEGIN
      -- get all merged parties

            OPEN  C_Get_merged_parties;
              LOOP            -- Loop for BULK SR charges processing in a batch of 1000
                 FETCH C_Get_merged_parties BULK COLLECT
                  INTO l_from_party_id_tbl ,
                       l_to_party_id_tbl,
                       l_batch_party_id_tbl
                 LIMIT 1000;

                 IF C_Get_merged_parties%NOTFOUND THEN
                    l_last_fetch := TRUE;
                 END IF;

                 IF l_from_party_id_tbl.count <> 0 AND l_last_fetch = FALSE  THEN    -- for last fetch
                    EXIT;
                 END IF ;

                 IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                   IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                     dbg_msg := ('Calling SR Charges routine to update sub restriction setup. Parties merged : '||C_Get_merged_parties%ROWCOUNT);
                     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                     END IF;
                   END IF;
                 END IF;

                    -- update cs_estimate_details table
                    -- Call Charges party merge routine for sub restrictions.

                       FOR i IN 1..l_from_party_id_tbl.COUNT

                           LOOP
                              CS_CH_PARTY_MERGE_PKG.CS_CHG_ALL_SETUP_PARTY
                                   (p_entity_name        => 'CS_CHG_SUB_RESTRICTIONS',
                                    p_from_id            => null,
                                    x_to_id              => l_to_id,
                                    p_from_fk_id         => l_from_party_id_tbl(i),
                                    p_to_fk_id           => l_to_party_id_tbl(i),
                                    p_parent_entity_name => 'HZ_PARTIES',
                                    p_batch_id           => p_batch_id,
                                    p_batch_party_id     => l_batch_party_id_tbl(i),
                                    x_return_status      => l_return_status );

                           END LOOP;

                 IF l_last_fetch THEN
                    EXIT;
                 END IF ;

              END LOOP;    -- End Loop for BULK SR charges processing in a batch of 1000
            CLOSE  C_Get_merged_parties;

            -- Clear the memory

               IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                 IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                   dbg_msg := ('SR charged sub restrictions data impacted due to party merge, transactions updated, Releasing memory');
                   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                   END IF;
                 END IF;
               END IF;

               l_from_party_id_tbl.DELETE;
               l_to_party_id_tbl.DELETE;
               l_batch_party_id_tbl.DELETE;

               IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                 IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                   dbg_msg := ('Releasing memory done');
                   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                   END IF;
                 END IF;
               END IF;

  EXCEPTION
       WHEN others THEN
            arp_message.set_line(g_pkg_name || '.' || g_proc_name || ': ' || sqlerrm);

            x_return_status :=  FND_API.G_RET_STS_ERROR;
            ROLLBACK;
            RAISE;
  END ;

   l_rowid_tbl.DELETE;
   l_incident_id_tbl.DELETE;
   l_estimate_detail_id_tbl.DELETE;
   l_customer_id_tbl.DELETE;
   l_from_party_id_tbl.DELETE;
   l_to_party_id_tbl.DELETE;
   l_bill_to_party_id_tbl.DELETE;

  -- Update party id in SR Party Role Extensible attributes table
  ---------------------------------------------------------------

  BEGIN
      -- get all impacted ext. attribute records.

            OPEN  c_get_party_ext_attr_rec;
              LOOP            -- Loop for BULK SR charges processing in a batch of 1000
                 FETCH c_get_party_ext_attr_rec BULK COLLECT
                  INTO l_rowid_tbl,
                       l_extension_id_tbl,
                       l_customer_id_tbl,
                       l_from_party_id_tbl ,
                       l_to_party_id_tbl
                 LIMIT 1000;

                 IF c_get_party_ext_attr_rec%NOTFOUND THEN
                    l_last_fetch := TRUE;
                 END IF;

                 IF l_rowid_tbl.count <> 0 AND l_last_fetch = FALSE  THEN    -- for last fetch
                    EXIT;
                 END IF ;

                 IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                   IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                     dbg_msg := ('Updating extensible attributes for the party role. Parties merged : '||c_get_party_ext_attr_rec%ROWCOUNT);
                     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                     END IF;
                   END IF;
                 END IF;

                    -- update cs_estimate_details table
                    -- Call Charges party merge routine for sub restrictions.

                       FORALL i IN 1..l_rowid_tbl.COUNT

                          UPDATE cs_sr_contacts_ext
                             SET party_id = DECODE(party_id,l_from_party_id_tbl(i),l_to_party_id_tbl(i),party_id)
                           WHERE rowid = l_rowid_tbl(i);

                          l_count := sql%rowcount;

                          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                            IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                               dbg_msg := ('No. of Party role ext attribute records updated : '||l_count);
                               IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                               END IF;
                            END IF;
                          END IF;

                            arp_message.set_name('AR', 'AR_ROWS_UPDATED');
                            arp_message.set_token('NUM_ROWS', to_char(l_count) );

                      -- Create SR Audit record for each updated party role extensible attribute transaction

                          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                            IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                               dbg_msg := ('Creating SR Audit record for each updated party role ext. attr. record');
                               IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                               END IF;
                            END IF;
                          END IF;

                          FOR i IN 1..l_rowid_tbl.COUNT
                             LOOP
                                 -- Prepare SR audit record structure
                                    CS_SR_EXTATTRIBUTES_PVT.Populate_Ext_Attr_Audit_Tbl
                                       ( P_EXTENSION_ID   => l_extension_id_tbl(i)
                                       , X_EXT_ATTRS_TBL  => l_ext_attrs_tbl_new
                                       , X_RETURN_STATUS  => l_return_status
                                       , X_MSG_COUNT      => x_msg_count
                                       , X_MSG_DATA       => x_msg_data) ;

                                     IF l_return_status = FND_API.G_RET_STS_SUCCESS Then

                                        l_ext_attrs_tbl_old := l_ext_attrs_tbl_new ;

                                        -- Populate the old values

                                        FOR j IN 1..l_ext_attrs_tbl_old.COUNT
                                           LOOP
                                             l_ext_attrs_tbl_old(j).pk_column_2 := l_customer_id_tbl(i);
                                           END LOOP;

                                     END IF;

                                      -- Call Create SR Audit API

                                     CS_SR_EXTATTRIBUTES_PVT.Create_Ext_Attr_Audit
                                           ( p_sr_ea_new_audit_rec_table   => l_ext_attrs_tbl_new
                                            ,p_sr_ea_old_audit_rec_table   => l_ext_attrs_tbl_old
                                            ,p_object_name                 => 'CS_PARTY_ROLE'
                                            ,p_modified_by                 => FND_GLOBAL.USER_ID
                                            ,p_modified_on                 => sysdate
                                            ,x_return_status               => l_return_status
                                            ,x_msg_count                   => x_msg_count
                                            ,x_msg_data                    => x_msg_data);

                                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                          RAISE FND_API.G_EXC_ERROR;
                                       END IF ;

                             END LOOP;   -- End loop for SR auditing


                             IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                               IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                                  dbg_msg := ('Created SR audit records for the SRs updated in a batch');
                                  IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                                  END IF;
                               END IF;
                             END IF;

                 IF l_last_fetch THEN
                    EXIT;
                 END IF ;

              END LOOP;    -- End Loop for BULK SR charges processing in a batch of 1000
            CLOSE  c_get_party_ext_attr_rec;


  EXCEPTION
       WHEN others THEN
            arp_message.set_line(g_pkg_name || '.' || g_proc_name || ': ' || sqlerrm);

            x_return_status :=  FND_API.G_RET_STS_ERROR;
            ROLLBACK;
            RAISE;
  END ;

            -- Clear the memory

               IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                 IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                   dbg_msg := ('SR extensible attributes,associated with party role, data impacted due to party merge, transactions updated');
                   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                   END IF;
                 END IF;
               END IF;

               l_rowid_tbl.DELETE;
               l_extension_id_tbl.DELETE;
               l_customer_id_tbl.DELETE;
               l_from_party_id_tbl.DELETE;
               l_to_party_id_tbl.DELETE;

               IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
                 IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data')) THEN
                   dbg_msg := ('Releasing memory done');
                   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_PartyMerge_PKG.Update_CS_Data', dbg_msg);
                   END IF;
                 END IF;
               END IF;

EXCEPTION
     WHEN resource_busy THEN
          arp_message.set_line(g_pkg_name || '.' || g_proc_name || ': Could not obtain lock for records in table '||
                                 'for columns referring HZ entities');
          x_return_status :=  FND_API.G_RET_STS_ERROR;
          ROLLBACK;
          RAISE;

     WHEN others THEN
          arp_message.set_line(g_pkg_name || '.' || g_proc_name || ': ' || sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
          ROLLBACK;
          RAISE;

END UPDATE_CS_DATA;

END  CS_PARTYMERGE_PKG;

/
