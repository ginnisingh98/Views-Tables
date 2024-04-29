--------------------------------------------------------
--  DDL for Package Body CSD_OM_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_OM_INTERFACE_PVT" AS
/* $Header: csdvomtb.pls 120.4 2005/10/18 16:37:01 mshirkol noship $ */

/* --------------------------------------*/
/* Define global variables               */
/* --------------------------------------*/

G_PKG_NAME  CONSTANT VARCHAR2(30)  := 'CSD_OM_INTERFACE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(30)  := 'csdvomtb.pls';

-- Global variable for storing the debug level
G_debug_level number   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

/*-------------------------------------------------------------------------------------*/
/* Function  name: DEBUG                                                               */
/* Description   : Logs the debug message                                              */
/* Called from   : Called from Update API                                              */
/*                                                                                     */
/* STANDARD PARAMETERS                                                                 */
/*   In Parameters :                                                                   */
/*      p_message        Required    Debug message that needs to be logged             */
/*      p_mod_name       Required    Module name                                       */
/*      p_severity_level Required    Severity level                                    */
/*   Output Parameters:                                                                */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*   Out parameters                                                                    */
/* Change Hist :                                                                       */
/*   09/20/03  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

Procedure DEBUG
          (p_message  in varchar2,
           p_mod_name in varchar2,
           p_severity_level in number
           ) IS

  -- Variables used in FND Log
  l_stat_level   number   := FND_LOG.LEVEL_STATEMENT;
  l_proc_level   number   := FND_LOG.LEVEL_PROCEDURE;
  l_event_level  number   := FND_LOG.LEVEL_EVENT;
  l_excep_level  number   := FND_LOG.LEVEL_EXCEPTION;
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_unexp_level  number   := FND_LOG.LEVEL_UNEXPECTED;

BEGIN

  IF p_severity_level = 1 THEN
    IF ( l_stat_level >= G_debug_level) THEN
        FND_LOG.STRING(l_stat_level,p_mod_name,p_message);
    END IF;
  ELSIF p_severity_level = 2 THEN
    IF ( l_proc_level >= G_debug_level) THEN
        FND_LOG.STRING(l_proc_level,p_mod_name,p_message);
    END IF;
  ELSIF p_severity_level = 3 THEN
    IF ( l_event_level >= G_debug_level) THEN
        FND_LOG.STRING(l_event_level,p_mod_name,p_message);
    END IF;
  ELSIF p_severity_level = 4 THEN
    IF ( l_excep_level >= G_debug_level) THEN
        FND_LOG.STRING(l_excep_level,p_mod_name,p_message);
    END IF;
  ELSIF p_severity_level = 5 THEN
    IF ( l_error_level >= G_debug_level) THEN
        FND_LOG.STRING(l_error_level,p_mod_name,p_message);
    END IF;
  ELSIF p_severity_level = 6 THEN
    IF ( l_unexp_level >= G_debug_level) THEN
        FND_LOG.STRING(l_unexp_level,p_mod_name,p_message);
    END IF;
  END IF;

END DEBUG;

FUNCTION get_sr_contacts (p_contact_id NUMBER)
           RETURN CS_SERVICEREQUEST_PUB.CONTACTS_TABLE ;

/*-------------------------------------------------------------------------------------*/
/* Procedure name: Get_Party_site_id                                                   */
/* Description   : Get the bill to/ship to party site use id                           */
/* Called from   : Called from Process_Rma                                             */
/*                                                                                     */
/* STANDARD PARAMETERS                                                                 */
/*   In Parameters :                                                                   */
/*      p_site_use_type    Required   Site Use Type                                    */
/*      p_cust_site_use_id Required  Cust site use                                     */
/*   Output Parameters:                                                                */
/*      x_return_status             Return Status                                      */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*   Out parameters                                                                    */
/*      x_party_site_use_id   Party Site Use Id                                        */
/* Change Hist :                                                                       */
/*   01/26/04  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

PROCEDURE Get_Party_site_id
  ( p_site_use_type       IN      VARCHAR2,
    p_cust_site_use_id    IN      NUMBER ,
    x_party_site_use_id   OUT  NOCOPY   VARCHAR2,
    x_return_status       OUT  NOCOPY   VARCHAR2
  ) IS

 l_party_site_id       NUMBER;
 l_party_site_use_id   NUMBER;

  -- Variables used in FND Log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_om_interface_pvt.get_party_site_id';

BEGIN
    -- Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    -- Api body starts
    Debug('At the Beginning of Get_Party_site_id',l_mod_name,1);
    Debug('p_cust_site_use_id '||p_cust_site_use_id ,l_mod_name,1);

    Begin
      SELECT hcas.party_site_id
      INTO   l_party_site_id
      FROM   hz_cust_acct_sites_all hcas,
             hz_cust_site_uses_all hcsu
      WHERE  hcas.cust_acct_site_id = hcsu.cust_acct_site_id
       AND   hcsu.site_use_id       = p_cust_site_use_id ;
    Exception
      When No_Data_found then
          IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_INV_PTY_SITE_USE_ID');
             fnd_message.set_token('CUST_SITE_USE_ID',p_cust_site_use_id );
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
          ELSE
             fnd_message.set_name('CSD','CSD_INV_PTY_SITE_USE_ID');
             fnd_message.set_token('CUST_SITE_USE_ID',p_cust_site_use_id );
             fnd_msg_pub.add;
          END IF;
        Debug('Party site does not exist for cust site use  ID='||to_char(p_cust_site_use_id) ,l_mod_name,1);
        Raise FND_API.G_EXC_ERROR ;
    End;

    IF l_party_site_id is not null THEN
      Begin
        SELECT hpsu.party_site_use_id
        INTO  l_party_site_use_id
        FROM  Hz_Party_Sites hps,
              Hz_Party_Site_uses hpsu,
              Hz_Locations hl
        WHERE hps.party_site_id = l_party_site_id
         AND  hpsu.site_use_type = p_site_use_type
         AND  hps.status = 'A'
         AND  hps.location_id = hl.location_id
         AND  hps.party_site_id = hpsu.party_site_id;
      Exception
        When No_Data_found then
          IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_INV_PTY_SITE_ID');
             fnd_message.set_token('PTY_SITE_ID',l_party_site_id);
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
          ELSE
             fnd_message.set_name('CSD','CSD_INV_PTY_SITE_ID');
             fnd_message.set_token('PTY_SITE_ID',l_party_site_id);
             fnd_msg_pub.add;
          END IF;
          Debug('Party site does not exist for party site id='||to_char(l_party_site_id) ,l_mod_name,1);
          Raise FND_API.G_EXC_ERROR ;
        When TOO_MANY_ROWS then
          IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_INV_PTY_SITE_ID');
             fnd_message.set_token('PTY_SITE_ID',l_party_site_id);
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
          ELSE
             fnd_message.set_name('CSD','CSD_INV_PTY_SITE_ID');
             fnd_message.set_token('PTY_SITE_ID',l_party_site_id);
             fnd_msg_pub.add;
          END IF;
          Debug('Too many rows found for party site id='||to_char(l_party_site_id) ,l_mod_name,1);
          Raise FND_API.G_EXC_ERROR ;
      End;
    END IF;

    Debug('l_party_site_use_id='||to_char(l_party_site_use_id) ,l_mod_name,1);

    --Return the party site use id
    x_party_site_use_id := l_party_site_use_id;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  END Get_party_site_id;


/*-------------------------------------------------------------------------------------*/
/* Procedure name: PROCESS_RMA                                                         */
/* Description   : Creates SR/RO against RMA                                           */
/* Called from   : Called from Concurrent Program                                      */
/*                                                                                     */
/* STANDARD PARAMETERS                                                                 */
/*   In Parameters :                                                                   */
/*      p_inventory_org_id   Required   Warehouse                                      */
/*      p_subinventory_name  Required   Received Subinventory                          */
/*   Output Parameters:                                                                */
/*      errbuf                Error Buffer                                             */
/*      retcode               Return Code                                              */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*   Out parameters                                                                    */
/* Change Hist :                                                                       */
/*   01/26/04  vlakaman  Initial Creation.                                             */
/*-------------------------------------------------------------------------------------*/

 PROCEDURE PROCESS_RMA
  (errbuf	            OUT  NOCOPY   VARCHAR2,
   retcode	 	      OUT  NOCOPY   VARCHAR2,
   p_inventory_org_id   IN      NUMBER,
   p_subinventory_name  IN      VARCHAR2
   ) IS

  l_service_request_rec      CS_SERVICEREQUEST_PUB.service_request_rec_type;
  l_notes_table              CS_ServiceRequest_PUB.notes_table;
  l_contacts_table           CS_ServiceRequest_PUB.contacts_table;
  l_rep_line_tbl             CSD_REPAIRS_PUB.REPLN_TBL_Type;
  l_inc_type_id              NUMBER;
  l_inc_status_id            NUMBER;
  l_inc_severity_id          NUMBER;
  l_inc_urgency_id           NUMBER;
  l_inc_sr_owner_id          NUMBER;
  l_inc_work_summary         VARCHAR2(240);
  l_ro_owner_id              NUMBER;
  ln_interaction_id          NUMBER;
  ln_workflow_id             NUMBER;
  l_sr_count                 NUMBER;
  l_count                    NUMBER;
  l_ro_count                 NUMBER;
  l_error_count              NUMBER;
  l_incident_id              NUMBER;
  l_incident_number          NUMBER;
  l_skip_ro_flag             BOOLEAN;
  l_skip_sr_flag             BOOLEAN;
  l_approval_flag            VARCHAR2(1);
  l_repair_mode              VARCHAR2(30);
  l_repair_type_id           NUMBER;
  l_repair_number            VARCHAR2(30);
  l_repair_line_id           NUMBER;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_return_status            VARCHAR2(1);
  l_serialized_flag          BOOLEAN;
  l_dummy                    VARCHAR2(1);
  l_customer_id              NUMBER;
  l_caller_type              VARCHAR2(80);
  l_bill_to_party_site_use_id    NUMBER;
  l_ship_to_party_site_use_id    NUMBER;
  l_rep_hist_id              NUMBER;
  l_instance_id              NUMBER;
  l_msg_index_out            NUMBER;

  CURSOR c_party_site_id(p_party_site_use_id in number) IS
      select party_site_id
      from hz_party_site_uses
      where party_site_use_id = p_party_site_use_id;

  CURSOR c_party_id(p_party_site_id in number) IS
       select party_id
       from hz_party_sites
       where party_site_id = p_party_site_id;

  -- Exception
  SKIP_RECORD           EXCEPTION;
  SKIP_RO               EXCEPTION;

  CURSOR Get_rcv_lines (p_inv_org_id in NUMBER,
                        p_sub_inv    in VARCHAR2) IS
    SELECT /*+ CHOOSE */
       oeh.order_number rma_number,
       oeh.header_id rma_header_id,
       oeh.order_category_code,
       oeh.booked_flag,
       NVL(oeh.invoice_to_org_id,oel.invoice_to_org_id) bill_to_site_use_id,
       NVL(oeh.ship_to_org_id,oel.ship_to_org_id) ship_to_site_use_id,
       oeh.sold_to_org_id cust_account_id,
       oeh.cust_po_number purchase_order_num,
       oeh.transactional_curr_code,
       oeh.SOLD_TO_CONTACT_ID CONTACT_ID ,
       oel.line_id ,
       oel.line_number rma_line_number,
       oel.inventory_item_id,
       oel.item_revision,
       oel.price_list_id,
       oel.shipped_quantity,
       oel.line_type_id,
       oel.order_quantity_uom,
       rcv.organization_id,
       rcv.quantity received_quantity,
       rcv.subinventory received_subinventory,
       rcv.transaction_date received_date,
       rcv.transaction_id,
       rcv.last_updated_by who_col,
       rcv.subinventory,
       hp.party_type,
       hp.party_id,
       haou.name org_name
    FROM RCV_TRANSACTIONS rcv,
      OE_ORDER_LINES_ALL oel,
      OE_ORDER_HEADERS_ALL oeh,
      hz_parties hp,
      hz_cust_accounts hca,
      hr_all_organization_units haou
    WHERE rcv.oe_order_line_id = oel.line_id
    AND rcv.transaction_type = 'DELIVER'
    AND rcv.source_document_code = 'RMA'
    AND oel.header_id = oeh.header_id
    AND oel.sold_to_org_id = hca.cust_account_id
    AND hca.party_id       = hp.party_id
    AND rcv.organization_id = haou.organization_id
    AND rcv.organization_id = p_inv_org_id
    AND rcv.subinventory    = p_sub_inv
    AND not  exists
            ( select 'X'  from  csd_repairs cra
              where cra.original_source_line_id   = oel.line_id
               and  cra.original_source_header_id = oel.header_id)
    AND not exists
             ( select 'x' from cs_estimate_details ced
               where ced.order_header_id = oel.header_id
                and  ced.order_line_id   = oel.line_id);

  -- Get the serial number for the txn Id
  CURSOR Get_serial_num (p_txn_id in NUMBER) IS
    SELECT serial_num
    from   rcv_serial_transactions
    where  transaction_id = p_txn_id;

  -- Variables used in FND Log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_om_interface_pvt.process_rma';

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT  process_rma;

    --
    -- MOAC initialization
    --
    MO_GLOBAL.init('CS_CHARGES');

    -- Initialize message list if p_init_msg_list is set to TRUE.
    FND_MSG_PUB.initialize;

    -- Api body starts
    Debug( 'Begining of concurrent program',l_mod_name,1);
    Debug( '*************In Parameters***************',l_mod_name,1);
    Debug( ' p_inventory_org_id    ='||to_char(p_inventory_org_id),l_mod_name,1);
    Debug( ' p_subinventory_name   ='||p_subinventory_name,l_mod_name,1);
    Debug( '*************In Parameters***************',l_mod_name,1);

    IF p_inventory_org_id  is NULL OR
       p_subinventory_name is NULL then
       IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_PARAMETERS_MISSING');
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
       ELSE
             fnd_message.set_name('CSD','CSD_PARAMETERS_MISSING');
             fnd_msg_pub.add;
       END IF;
       Debug( 'One of the IN parameters(Inv Org, Subinventory) is NULL',l_mod_name,1);
       Raise  FND_API.G_EXC_ERROR ;
    END IF;

    l_approval_flag := FND_PROFILE.value('CSD_CUST_APPROVAL_REQD');

    -- Default values for SR
    l_inc_type_id      := FND_PROFILE.value('CSD_OM_DEFAULT_SR_TYPE');
    l_inc_status_id    := FND_PROFILE.value('CSD_OM_DEFAULT_SR_STATUS');
    l_inc_severity_id  := FND_PROFILE.value('CSD_OM_DEFAULT_SR_SEVERITY');
    l_inc_urgency_id   := FND_PROFILE.value('CSD_OM_DEFAULT_SR_URGENCY');
    -- To fix bug # 3615720 Defined a message in SEED and Seeded translated message will be used
    -- when profile is not defined
    -- l_inc_work_summary := FND_PROFILE.value('CSD_OM_SR_WORK_SUMMARY');
    FND_PROFILE.Get('CSD_OM_SR_WORK_SUMMARY',l_Inc_Work_Summary);
    if l_Inc_Work_Summary is Null Then
       Fnd_Message.Set_Name('CSD','CSD_SR_WORK_SUMMARY_RMA');
	  l_Inc_Work_Summary := Fnd_Message.Get;
    End If;

    -- Default values for RO
    l_ro_owner_id := FND_PROFILE.value('CSD_OM_RO_DEFAULT_OWNER');

    Debug( 'Checking if the IN parameters are not null',l_mod_name,1);

    IF l_inc_type_id      is NULL OR
       l_inc_status_id    is NULL OR
       l_inc_severity_id  is NULL OR
       l_inc_urgency_id   is NULL OR
       l_inc_work_summary is NULL THEN
       IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_PROF_SETUP_MISSING');
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
       ELSE
             fnd_message.set_name('CSD','CSD_PROF_SETUP_MISSING');
             fnd_msg_pub.add;
       END IF;
       Debug( 'One of the profile for SR default values is not set',l_mod_name,1);
       Raise  FND_API.G_EXC_ERROR ;
    END IF;

    Debug( 'Getting Repair Type Id and mode for standard repair',l_mod_name,1);

    -- Get the repair type and repair mode
    -- for standard repair type
    Begin
      Select repair_type_id,
             repair_mode
      into l_repair_type_id,
           l_repair_mode
      from  csd_repair_types_vl
      where repair_type_ref = 'SR'
      and  seeded_flag      = 'Y';
    Exception
      When No_Data_found then
        IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_STD_REP_TYPE_MISSING');
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
        ELSE
             fnd_message.set_name('CSD','CSD_STD_REP_TYPE_MISSING');
             fnd_msg_pub.add;
        END IF;
        Debug( 'Standard Repair Type not found',l_mod_name,1);
        Raise  FND_API.G_EXC_ERROR ;
      When TOO_MANY_ROWS  then
        IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_STD_REP_TYPE_MISSING');
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
        ELSE
             fnd_message.set_name('CSD','CSD_STD_REP_TYPE_MISSING');
             fnd_msg_pub.add;
        END IF;
        Debug( 'Too many Standard Repair Types found',l_mod_name,1);
        Raise  FND_API.G_EXC_ERROR ;
    End;

    Debug( 'Validating the Inv Org',l_mod_name,1);
    -- Validate if the inv org id is set in inventory
    Begin
      Select 'X'
      into l_dummy
      from  mtl_parameters
      where organization_id = p_inventory_org_id;
    Exception
      When No_Data_found then
        IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_INVALID_INV_ORG_ID');
             fnd_message.set_token('INV_ORG_ID',p_inventory_org_id);
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
        ELSE
             fnd_message.set_name('CSD','CSD_INVALID_INV_ORG_ID');
             fnd_message.set_token('INV_ORG_ID',p_inventory_org_id);
             fnd_msg_pub.add;
        END IF;
        Debug( 'Inventory Org not found for INV Org ID='||to_char(p_inventory_org_id),l_mod_name,1);
        Raise  FND_API.G_EXC_ERROR ;
      When TOO_MANY_ROWS  then
        IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_INVALID_INV_ORG_ID');
             fnd_message.set_token('INV_ORG_ID',p_inventory_org_id);
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
        ELSE
             fnd_message.set_name('CSD','CSD_INVALID_INV_ORG_ID');
             fnd_message.set_token('INV_ORG_ID',p_inventory_org_id);
             fnd_msg_pub.add;
        END IF;
        Debug( 'Two many rows Inventory Org is defined for Inv Org  ID='||to_char(p_inventory_org_id),l_mod_name,1);
        Raise  FND_API.G_EXC_ERROR ;
    End;

    Debug( 'Validating the Subinventory',l_mod_name,1);
    -- Validate the subinventory
    Begin
      Select 'X'
      into l_dummy
      from  mtl_secondary_inventories
      where organization_id           = p_inventory_org_id
      and  secondary_inventory_name   = p_subinventory_name ;
    Exception
      When No_Data_found then
        IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_INVALID_SUB_INV');
             fnd_message.set_token('SUB_INV',p_subinventory_name );
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
        ELSE
             fnd_message.set_name('CSD','CSD_INVALID_SUB_INV');
             fnd_message.set_token('SUB_INV',p_subinventory_name );
             fnd_msg_pub.add;
        END IF;
        Debug( 'Subinventory Location  not found='||p_subinventory_name,l_mod_name,1 );
        Raise  FND_API.G_EXC_ERROR ;
      When TOO_MANY_ROWS  then
        IF ( l_error_level >= G_debug_level) THEN
             fnd_message.set_name('CSD','CSD_INVALID_SUB_INV');
             fnd_message.set_token('SUB_INV',p_subinventory_name );
             FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
        ELSE
             fnd_message.set_name('CSD','CSD_INVALID_SUB_INV');
             fnd_message.set_token('SUB_INV',p_subinventory_name );
             fnd_msg_pub.add;
        END IF;
        Debug( 'Too many rows found for subinventory ='||p_subinventory_name,l_mod_name,1 );
        Raise  FND_API.G_EXC_ERROR ;
    End;

    l_sr_count := 0;
    l_ro_count := 0;
    l_error_count := 0;

    FOR C1 in Get_rcv_lines (p_inventory_org_id, p_subinventory_name )
    LOOP
      BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT  rcv_lines;

        Debug( 'Inside FOR LOOP....',l_mod_name,1);
        Debug( 'Order Header Id ='||to_char(c1.rma_header_id),l_mod_name,1);
        Debug( 'Order line Id   ='||to_char(c1.line_id),l_mod_name,1);
	   Debug( 'Checking if SR exists',l_mod_name,1);

        -- Check if SR exists already for the order header Id
        -- Vijay:3840775: Include order line in the where clause.
        -- sragunat, rollbacked the bug fix change,
        -- Removed the order line, as this leads to a new SR being created
	  -- for every order line
        Begin
          Select incident_id
          into   l_incident_id
          from   csd_repairs cra
          where  cra.original_source_header_id = c1.rma_header_id
        --  and    cra.original_source_line_id   = c1.line_id
		and    rownum = 1;
          l_skip_sr_flag := TRUE;
          Debug( 'SR exists for the order line Id :'||to_char(c1.line_id),l_mod_name,1);
        Exception
          When No_Data_Found then
            l_skip_sr_flag := FALSE;
            Debug( 'NO SR exists for the order line Id :'||to_char(c1.line_id),l_mod_name,1);
        End;

        -- Only if SR exist then check the status
        IF l_incident_id is not null and
           l_skip_sr_flag THEN
           Begin
             Select 'X'
             into    l_dummy
             from   cs_incidents_all_b cia,
                    cs_incident_statuses cis
             where  cia.incident_status_id = cis.incident_status_id
             and    cis.status_code        = 'OPEN'
             and    incident_id            = l_incident_id;
             Debug( 'SR is open for the incident Id ='||to_char(l_incident_id),l_mod_name,1);
           Exception
             When No_Data_Found then
               Debug( 'SR is not open for the incident Id ='||l_incident_id,l_mod_name,1);
               RAISE SKIP_RECORD;
           End;
        END IF;

        IF NOT(l_skip_sr_flag) THEN

            Debug( 'Deriving SR Values',l_mod_name,1);
            Debug( 'Deriving Bill to site Use Id',l_mod_name,1);
            --Get the bill to site use Id
            Get_Party_site_id
            ( p_site_use_type       =>  'BILL_TO',
              p_cust_site_use_id    =>  C1.bill_to_site_use_id,
              x_party_site_use_id   =>  l_bill_to_party_site_use_id ,
              x_return_status       =>  l_return_status);

            IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               Debug( 'Get_party_site_id failed for bill-to party site use Id ='||to_char(l_bill_to_party_site_use_id ),l_mod_name,1);
               RAISE SKIP_RECORD;
            END IF;

            Debug( 'Deriving Ship to site Use Id',l_mod_name,1);
            --Get the ship to site use Id
            Get_Party_site_id
               (p_site_use_type       => 'SHIP_TO',
                p_cust_site_use_id    => C1.ship_to_site_use_id,
                x_party_site_use_id   =>  l_ship_to_party_site_use_id ,
                x_return_status       =>  l_return_status);

            IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              Debug( 'Get_party_site_id failed for ship-to party site use Id =  '||to_char(l_ship_to_party_site_use_id ),l_mod_name,1);
              RAISE SKIP_RECORD;
            END IF;

            -- Initialize the SR record values
            CS_SERVICEREQUEST_PUB.initialize_rec(l_service_request_rec);

            l_service_request_rec.request_date            := sysdate;
            l_service_request_rec.type_id                 := l_inc_type_id;
            l_service_request_rec.status_id               := l_inc_status_id;
            l_service_request_rec.severity_id             := l_inc_severity_id;
            l_service_request_rec.urgency_id              := l_inc_urgency_id;
            -- l_service_request_rec.owner_id             := l_inc_sr_owner_id;
            l_service_request_rec.summary                 := l_inc_work_summary;
            l_service_request_rec.caller_type             := C1.party_type;
            l_service_request_rec.customer_id             := C1.party_id;
            l_service_request_rec.inventory_item_id       := C1.inventory_item_id;
            l_service_request_rec.inv_item_revision       := C1.item_revision;
            l_service_request_rec.inventory_org_id        := cs_std.get_item_valdn_orgzn_id;
            --l_service_request_rec.purchase_order_num      := C1.purchase_order_num;
            l_service_request_rec.bill_to_site_use_id     := l_bill_to_party_site_use_id;
            l_service_request_rec.ship_to_site_use_id     := l_ship_to_party_site_use_id;
            l_service_request_rec.account_id              := C1.cust_account_id;
            l_service_request_rec.cust_po_number          := C1.purchase_order_num;
            l_service_request_rec.sr_creation_channel     := 'AGENT';
           -- l_service_request_rec.publish_flag            := NVL(FND_PROFILE.value('INC_PUBLISH_FLAG_UPDATE'),'N');
            l_service_request_rec.creation_program_code   := 'CSD_REPAIR_ORDER_FORM';
            l_service_request_rec.last_update_program_code := 'CSD_REPAIR_ORDER_FORM';
	      l_service_request_rec.group_type               := 'RS_GROUP';

           Debug( 'Getting Bill_to fields = ',l_mod_name,1);
           -- Bill-To fields
           IF (nvl(l_service_request_rec.bill_to_site_use_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) THEN
              OPEN c_party_site_id(l_service_request_rec.bill_to_site_use_id);
              FETCH c_party_site_id INTO l_service_request_rec.bill_to_site_id;
              CLOSE c_party_site_id;
              Debug('l_service_request_rec.bill_to_site_id ' ||l_service_request_rec.bill_to_site_id,l_mod_name,1);
              IF (nvl(l_service_request_rec.bill_to_site_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) THEN
                OPEN c_party_id(l_service_request_rec.bill_to_site_id);
                FETCH c_party_id INTO l_service_request_rec.bill_to_party_id;
                CLOSE c_party_id;
                Debug('l_service_request_rec.bill_to_party_id '||l_service_request_rec.bill_to_party_id,l_mod_name,1);
              END IF;
           END IF;

           -- Ship-To fields
           Debug('GETTING SHIP-TO FIELDS',l_mod_name,1);
           IF (nvl(l_service_request_rec.ship_to_site_use_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) THEN
              OPEN c_party_site_id(l_service_request_rec.ship_to_site_use_id);
	        FETCH c_party_site_id INTO l_service_request_rec.ship_to_site_id;
              CLOSE c_party_site_id;
	        Debug('l_service_request_rec.ship_to_site_id ' ||l_service_request_rec.ship_to_site_id,l_mod_name,1);
              IF (nvl(l_service_request_rec.ship_to_site_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) THEN
                 OPEN c_party_id(l_service_request_rec.ship_to_site_id);
                 FETCH c_party_id INTO l_service_request_rec.ship_to_party_id;
                 CLOSE c_party_id;
                 Debug('l_service_request_rec.ship_to_party_id ' ||l_service_request_rec.ship_to_party_id,l_mod_name,1);
              END IF;
           END IF;

		 Debug( 'C1.contact_id =  '||to_char(C1.contact_id),l_mod_name,1);

           l_contacts_table := Get_sr_contacts(C1.contact_id);

           /*
            -- thinking Not to create contact for SR as it is optional
           If (p_service_request_rec.party_id is not null) then
              l_contacts_table(1).sr_contact_point_id     := p_service_request_rec.sr_contact_point_id;
              l_contacts_table(1).party_id                := p_service_request_rec.party_id;
              l_contacts_table(1).contact_type            := p_service_request_rec.contact_type;
              l_contacts_table(1).contact_point_id        := p_service_request_rec.contact_point_id;
              l_contacts_table(1).contact_point_type      := p_service_request_rec.contact_point_type;
              l_contacts_table(1).primary_flag            := p_service_request_rec.primary_flag;
           end If;
            */

           Debug( 'l_service_request_rec.request_date =  '||to_char(l_service_request_rec.request_date),l_mod_name,1);
           Debug( 'l_service_request_rec.type_id      =  '||to_char(l_service_request_rec.type_id),l_mod_name,1);
           Debug( 'l_service_request_rec.status_id    =  '||to_char(l_service_request_rec.status_id),l_mod_name,1);
           Debug( 'l_service_request_rec.severity_id  =  '||to_char(l_service_request_rec.severity_id),l_mod_name,1);
           Debug( 'l_service_request_rec.urgency_id   =  '||to_char(l_service_request_rec.urgency_id),l_mod_name,1);
           Debug( 'l_service_request_rec.summary      =  '||l_service_request_rec.summary,l_mod_name,1);
           Debug( 'l_service_request_rec.request_date =  '||to_char(l_service_request_rec.request_date),l_mod_name,1);
           Debug( 'l_service_request_rec.caller_type  =  '||l_service_request_rec.caller_type,l_mod_name,1);
           Debug( 'l_service_request_rec.customer_id  =  '||to_char(l_service_request_rec.customer_id),l_mod_name,1);
           Debug( 'l_service_request_rec.inventory_item_id =  '||to_char(l_service_request_rec.inventory_item_id),l_mod_name,1);
           Debug( 'l_service_request_rec.inventory_org_id =  '||to_char(l_service_request_rec.inventory_org_id),l_mod_name,1);
           Debug( 'l_service_request_rec.bill_to_site_use_id =  '||to_char(l_service_request_rec.bill_to_site_use_id),l_mod_name,1);
           Debug( 'l_service_request_rec.ship_to_site_use_id =  '||to_char(l_service_request_rec.ship_to_site_use_id),l_mod_name,1);
           Debug( 'l_service_request_rec.account_id   =  '||to_char(l_service_request_rec.account_id),l_mod_name,1);
           Debug( 'l_service_request_rec.cust_po_number =  '||l_service_request_rec.cust_po_number,l_mod_name,1);

            Debug( 'Calling CS_SERVICEREQUEST_PUB.Create_ServiceRequest ',l_mod_name,1);

            -- Call to Service Request API
            CS_SERVICEREQUEST_PUB.Create_ServiceRequest(
              p_api_version           => 2.0,
              p_init_msg_list         => FND_API.G_TRUE,
              p_commit                => FND_API.G_FALSE,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data,
              p_resp_appl_id          => NULL,
              p_resp_id               => NULL,
              p_user_id               => fnd_global.user_id,
              p_login_id              => fnd_global.conc_login_id,
              p_org_id                => NULL,
              p_request_id            => NULL,
              p_request_number        => NULL,
              p_service_request_rec   => l_service_request_rec,
              p_notes                 => l_notes_table,
              p_contacts              => l_contacts_table,
              x_request_id            => l_incident_id,
              x_request_number        => l_incident_number,
              x_interaction_id        => ln_interaction_id,
              x_workflow_process_id   => ln_workflow_id);

            IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 Debug( 'Create_servicerequest API failed',l_mod_name,1);
                 RAISE SKIP_RECORD;
            END IF;
            l_sr_count := l_sr_count + 1;
            Debug( 'New Incident Number ='||l_incident_number,l_mod_name,1);
        END IF;

        -- Check if Item is serialized item
        --
        Begin
          Select 'x'
          into    l_dummy
          from   mtl_system_items
          where  inventory_item_id  = c1.inventory_item_id
          and    organization_id    = c1.organization_id
          and    serial_number_control_code <> 1;
            l_serialized_flag := TRUE;
            Debug( 'Inv Item is serialized Inv Item Id='||to_char(c1.inventory_item_id),l_mod_name,1);
        Exception
          When No_Data_Found then
            IF ( l_error_level >= G_debug_level) THEN
              fnd_message.set_name('CSD','CSD_INV_ITEM_ID');
              fnd_message.set_token('ITEM_ID',c1.inventory_item_id);
              FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
            ELSE
              fnd_message.set_name('CSD','CSD_INV_ITEM_ID');
              fnd_message.set_token('ITEM_ID',c1.inventory_item_id);
              fnd_msg_pub.add;
            END IF;
            l_serialized_flag := FALSE;
            Debug( 'Inv Item is Non-serialized Inv Item Id='||to_char(c1.inventory_item_id),l_mod_name,1);
        End;

        --Initialize the values
        l_count := 0;
        l_rep_line_tbl.delete;

        If NOT(l_serialized_flag) then

          -- Increment the counter
          l_count := l_count +1;

          l_rep_line_tbl(l_count).INCIDENT_ID        :=   l_incident_id    ;
          l_rep_line_tbl(l_count).INVENTORY_ITEM_ID  :=   C1.inventory_item_id;
          l_rep_line_tbl(l_count).UNIT_OF_MEASURE    :=   C1.order_quantity_uom;
          l_rep_line_tbl(l_count).REPAIR_TYPE_ID     :=   l_repair_type_id ;
          l_rep_line_tbl(l_count).REPAIR_MODE        :=   l_repair_mode    ;
          l_rep_line_tbl(l_count).STATUS             :=   'O'               ;
          l_rep_line_tbl(l_count).STATUS_REASON_CODE :=   FND_API.G_MISS_CHAR;
          l_rep_line_tbl(l_count).DATE_CLOSED        :=   FND_API.G_MISS_DATE;
          l_rep_line_tbl(l_count).APPROVAL_REQUIRED_FLAG := nvl(l_approval_flag,'N');
          l_rep_line_tbl(l_count).APPROVAL_STATUS    :=   FND_API.G_MISS_CHAR;
          l_rep_line_tbl(l_count).QUANTITY           :=   c1.shipped_quantity  ;
          l_rep_line_tbl(l_count).QUANTITY_IN_WIP    :=   FND_API.G_MISS_NUM;
          l_rep_line_tbl(l_count).QUANTITY_RCVD      :=   c1.shipped_quantity;
          l_rep_line_tbl(l_count).QUANTITY_SHIPPED   :=   FND_API.G_MISS_NUM;
          -- Vijay:3840775: change default for group id to null from g_miss_num
          l_rep_line_tbl(l_count).REPAIR_GROUP_ID    :=   null;
          l_rep_line_tbl(l_count).RO_TXN_STATUS      :=   'OM_BOOKED'   ;
          l_rep_line_tbl(l_count).SERIAL_NUMBER      :=   FND_API.G_MISS_CHAR;
          l_rep_line_tbl(l_count).REPAIR_NUMBER      :=   FND_API.G_MISS_CHAR;
          l_rep_line_tbl(l_count).original_source_reference :=   'RMA';
          l_rep_line_tbl(l_count).original_source_header_id :=   c1.rma_header_id;
          l_rep_line_tbl(l_count).original_source_line_id   :=   c1.line_id;
          l_rep_line_tbl(l_count).currency_code      :=   c1.transactional_curr_code;
          l_rep_line_tbl(l_count).price_list_header_id :=   c1.price_list_id;

          --l_rep_line_tbl(l_count).object_version_number   :=   1;

        ELSE

          FOR C2 in Get_Serial_Num(c1.transaction_id)
          LOOP

            Begin
               Select
		   instance_id
		   into l_instance_id
		   from csi_item_instances
		   where serial_number = C2.serial_num
		   and   inventory_item_id = C1.inventory_item_id
		   and   owner_party_id    = C1.party_id;
            Exception
	        When No_Data_Found then
                IF ( l_error_level >= G_debug_level) THEN
                  fnd_message.set_name('CSD','CSD_IB_INSTANCE_MISSING');
                  fnd_message.set_token('SERIAL_NUM', C2.serial_num);
                  FND_LOG.MESSAGE(l_error_level,l_mod_name, FALSE);
                ELSE
                  fnd_message.set_name('CSD','CSD_IB_INSTANCE_MISSING');
                  fnd_message.set_token('SERIAL_NUM', C2.serial_num);
                  fnd_msg_pub.add;
                END IF;
                Debug( 'Instance Id could not be found='||c2.serial_num,l_mod_name,1);
		    l_instance_id := FND_API.G_MISS_NUM;
		  End;

		  -- Increment the counter
            l_count := l_count +1;

		l_rep_line_tbl(l_count).INCIDENT_ID        :=   l_incident_id    ;
            l_rep_line_tbl(l_count).INVENTORY_ITEM_ID  :=   C1.inventory_item_id;
            l_rep_line_tbl(l_count).UNIT_OF_MEASURE    :=   C1.order_quantity_uom;
            l_rep_line_tbl(l_count).REPAIR_TYPE_ID     :=   l_repair_type_id ;
            l_rep_line_tbl(l_count).REPAIR_MODE        :=   l_repair_mode    ;
            l_rep_line_tbl(l_count).STATUS             :=   'O'               ;
            l_rep_line_tbl(l_count).STATUS_REASON_CODE :=   FND_API.G_MISS_CHAR;
            l_rep_line_tbl(l_count).DATE_CLOSED        :=   FND_API.G_MISS_DATE;
            l_rep_line_tbl(l_count).APPROVAL_REQUIRED_FLAG := nvl(l_approval_flag,'N');
            l_rep_line_tbl(l_count).APPROVAL_STATUS    :=   FND_API.G_MISS_CHAR;
            l_rep_line_tbl(l_count).QUANTITY           :=   1 ;
            l_rep_line_tbl(l_count).QUANTITY_IN_WIP    :=   FND_API.G_MISS_NUM;
            l_rep_line_tbl(l_count).QUANTITY_RCVD      :=   1;
            l_rep_line_tbl(l_count).QUANTITY_SHIPPED   :=   FND_API.G_MISS_NUM;
           -- Vijay:3840775: change default for group id to null from g_miss_num
            l_rep_line_tbl(l_count).REPAIR_GROUP_ID    :=   null;
            l_rep_line_tbl(l_count).RO_TXN_STATUS      :=   'OM_BOOKED'   ;
            l_rep_line_tbl(l_count).SERIAL_NUMBER      :=   C2.serial_num;
            l_rep_line_tbl(l_count).CUSTOMER_PRODUCT_ID  :=   l_instance_id;
            l_rep_line_tbl(l_count).REPAIR_NUMBER      :=   FND_API.G_MISS_CHAR;
            l_rep_line_tbl(l_count).original_source_reference :=   'RMA';
            l_rep_line_tbl(l_count).original_source_header_id :=   c1.rma_header_id;
            l_rep_line_tbl(l_count).original_source_line_id   :=   c1.line_id;
            l_rep_line_tbl(l_count).currency_code      :=   c1.transactional_curr_code;
            l_rep_line_tbl(l_count).price_list_header_id :=   c1.price_list_id;
            --l_rep_line_tbl(l_count).object_version_number     :=   1;

          END LOOP;
        END IF;

        Debug( 'l_rep_line_tbl.count ='||l_rep_line_tbl.count,l_mod_name,1);
        FOR i in l_rep_line_tbl.first..l_rep_line_tbl.last
        LOOP
          BEGIN

            -- Savepoint
            Savepoint create_ro;

            l_REPAIR_line_id := NULL;

            Debug( 'Calling CSD_REPAIRS_PVT.Create_Repair_Order',l_mod_name,1);
            CSD_REPAIRS_PVT.Create_Repair_Order
              ( P_Api_Version_Number   => 1.0,
                P_Init_Msg_List        => FND_API.G_TRUE,
                P_Commit               => FND_API.G_FALSE,
                p_validation_level     => fnd_api.g_valid_level_full,
                p_Repair_line_id       => l_REPAIR_line_id,
                P_REPLN_Rec            => l_rep_line_tbl(i) ,
                X_REPAIR_LINE_ID       => l_REPAIR_LINE_ID,
                X_REPAIR_NUMBER        => l_REPAIR_NUMBER,
                X_Return_Status        => l_return_status,
                X_Msg_Count            => l_msg_count,
                X_Msg_Data             => l_msg_data );

            IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                Debug( 'Create Repair Order API failed',l_mod_name,1);
                RAISE SKIP_RO;
            END IF;

            Debug( 'New Repair Number ='||l_REPAIR_NUMBER ,l_mod_name,1);
            l_ro_count := l_ro_count + 1;

            Debug( 'Calling CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write ',l_mod_name,1);
            CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write
            ( P_Api_Version_Number       => 1.0,
              P_Init_Msg_List            => 'T',
              P_Commit                   => 'F',
              p_validation_level         => null,
              p_action_code              => 0  ,
              px_REPAIR_HISTORY_ID       => l_rep_hist_id,
              p_OBJECT_VERSION_NUMBER    => null,
              p_REQUEST_ID               => null,
              p_PROGRAM_ID               => null,
              p_PROGRAM_APPLICATION_ID   => null,
              p_PROGRAM_UPDATE_DATE      => null,
              p_CREATED_BY               => FND_GLOBAL.USER_ID,
              p_CREATION_DATE            => sysdate,
              p_LAST_UPDATED_BY          => FND_GLOBAL.USER_ID,
              p_LAST_UPDATE_DATE         => sysdate,
              p_REPAIR_LINE_ID           => l_repair_line_id,
              p_EVENT_CODE               => 'RR',
              p_EVENT_DATE               => C1.received_date,
              p_QUANTITY                 => l_rep_line_tbl(i).QUANTITY,
              p_PARAMN1                  => C1.transaction_id,
              p_PARAMN2                  => C1.rma_line_number,
              p_PARAMN3                  => C1.organization_id,
              p_PARAMN4                  => NULL,
              p_PARAMN5                  => NULL,
              p_PARAMN6                  => C1.rma_header_id,
              p_PARAMN7                  => null,
              p_PARAMN8                  => null,
              p_PARAMN9                  => null,
              p_PARAMN10                 => null,
              p_PARAMC1                  => C1.subinventory,
              p_PARAMC2                  => C1.rma_number,
              p_PARAMC3                  => C1.org_name,
              p_PARAMC4                  => null,
              p_PARAMC5                  => null,
              p_PARAMC6                  => null,
              p_PARAMC7                  => null,
              p_PARAMC8                  => null,
              p_PARAMC9                  => null,
              p_PARAMC10                 => null,
              p_PARAMD1                  => null,
              p_PARAMD2                  => null,
              p_PARAMD3                  => null,
              p_PARAMD4                  => null,
              p_PARAMD5                  => null,
              p_PARAMD6                  => null,
              p_PARAMD7                  => null,
              p_PARAMD8                  => null,
              p_PARAMD9                  => null,
              p_PARAMD10                 => null,
              p_ATTRIBUTE_CATEGORY       => null,
              p_ATTRIBUTE1               => null,
              p_ATTRIBUTE2               => null,
              p_ATTRIBUTE3               => null,
              p_ATTRIBUTE4               => null,
              p_ATTRIBUTE5               => null,
              p_ATTRIBUTE6               => null,
              p_ATTRIBUTE7               => null,
              p_ATTRIBUTE8               => null,
              p_ATTRIBUTE9               => null,
              p_ATTRIBUTE10              => null,
              p_ATTRIBUTE11              => null,
              p_ATTRIBUTE12              => null,
              p_ATTRIBUTE13              => null,
              p_ATTRIBUTE14              => null,
              p_ATTRIBUTE15              => null,
              p_LAST_UPDATE_LOGIN        => null,
              X_Return_Status            => l_return_status,
              X_Msg_Count                => l_msg_count,
              X_Msg_Data                 => l_msg_data );

            IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                Debug( 'Validate_And_Write failed ',l_mod_name,1);
                RAISE SKIP_RO;
            END IF;

         EXCEPTION
          WHEN SKIP_RO THEN
            ROLLBACK  TO create_ro;
            l_error_count := l_error_count + 1;
            if(fnd_msg_pub.count_msg > 0 ) then
	         for i in 1..fnd_msg_pub.count_msg
	         loop
	             fnd_msg_pub.get(p_msg_index => i,
				    p_encoded   => 'F',
				    p_data      => l_msg_data,
				    p_msg_index_out => l_msg_index_out);
                  Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	         end loop;
            else
               Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	      end if;
            Debug( 'Skipping RO creation =',l_mod_name,1);
            exit;
          WHEN OTHERS THEN
            ROLLBACK  TO create_ro;
            l_error_count := l_error_count + 1;
            if(fnd_msg_pub.count_msg > 0 ) then
	         for i in 1..fnd_msg_pub.count_msg
	         loop
	             fnd_msg_pub.get(p_msg_index => i,
				    p_encoded   => 'F',
				    p_data      => l_msg_data,
				    p_msg_index_out => l_msg_index_out);
                  Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	         end loop;
            else
               Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	      end if;
            Debug( 'Others exception in RO Craetion ',l_mod_name,1);
		exit;
	    END;
        END LOOP; -- End of Repair order creation

      EXCEPTION
        WHEN SKIP_RECORD THEN
            ROLLBACK  TO rcv_lines;
            l_error_count := l_error_count + 1;
            if(fnd_msg_pub.count_msg > 0 ) then
	         for i in 1..fnd_msg_pub.count_msg
	         loop
	             fnd_msg_pub.get(p_msg_index => i,
				    p_encoded   => 'F',
				    p_data      => l_msg_data,
				    p_msg_index_out => l_msg_index_out);
                   Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	         end loop;
            else
               Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	      end if;
            Debug( 'Skipping the record for order line_id ='||to_char(c1.line_id),l_mod_name,1);
        WHEN OTHERS THEN
            ROLLBACK  TO rcv_lines;
            l_error_count := l_error_count + 1;
            if(fnd_msg_pub.count_msg > 0 ) then
	         for i in 1..fnd_msg_pub.count_msg
	         loop
	             fnd_msg_pub.get(p_msg_index => i,
				    p_encoded   => 'F',
				    p_data      => l_msg_data,
				    p_msg_index_out => l_msg_index_out);
                  Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	         end loop;
            else
               Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	       end if;
            Debug( 'In Others exception',l_mod_name,1);
      END;
    END LOOP; --End of processing all rcv lines

 /*
    fnd_file.put_line(fnd_file.output, '================================================== ');
    fnd_file.put_line(fnd_file.output, '********** SUMMARY OF PROCESSED RECORDS ********** ');
    fnd_file.put_line(fnd_file.output, '================================================== ');
    fnd_file.put_line(fnd_file.output, '     Total Number of Service Request Created  = '||to_char(l_sr_count));
    fnd_file.put_line(fnd_file.output, '     Total Number of Repair Orders Created    = '||to_char(l_ro_count));
    fnd_file.put_line(fnd_file.output, '     Total Number of Order Lines Errored      = '||to_char(l_error_count));
    fnd_file.put_line(fnd_file.output, '================================================== ');
*/

    errbuf   := '';
    retcode := '0';
    --- Retcode = 0 is success
    --- Retcode = 1 is warning
    --- Retcode = 2 is error

    -- Commit
    COMMIT WORK;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO process_rma;
     if(fnd_msg_pub.count_msg > 0 ) then
	  for i in 1..fnd_msg_pub.count_msg
	  loop
	   fnd_msg_pub.get(p_msg_index => i,
				    p_encoded   => 'F',
				    p_data      => l_msg_data,
				    p_msg_index_out => l_msg_index_out);
          Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	   end loop;
     else
          Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	end if;
     errbuf  := 'Error occurred in Concurrent Program:'||l_msg_data;
     retcode := '2';
    WHEN OTHERS THEN
     ROLLBACK TO process_rma;
     if(fnd_msg_pub.count_msg > 0 ) then
	  for i in 1..fnd_msg_pub.count_msg
	  loop
	   fnd_msg_pub.get(p_msg_index => i,
				    p_encoded   => 'F',
				    p_data      => l_msg_data,
				    p_msg_index_out => l_msg_index_out);
          Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	   end loop;
     else
          Debug( 'Error Msg='||l_msg_data,l_mod_name,1);
	end if;
	errbuf  := 'Error occurred in Concurrent Program:'||l_msg_data;
     retcode := '2';
  END  PROCESS_RMA;

/*-------------------------------------------------------------------------------------*/
/* Procedure name: GET_SR_CONTACTS                                                     */
/* Description   : Creates SR/RO against RMA                                           */
/* Called from   : Called from Concurrent Program                                      */
/*                                                                                     */
/* STANDARD PARAMETERS                                                                 */
/*   In Parameters :                                                                   */
/*      p_contact_id         Required   Contact Id                                     */
/*   Output Parameters:                                                                */
/* NON-STANDARD PARAMETERS                                                             */
/*   In Parameters                                                                     */
/*   Out parameters                                                                    */
/* Change Hist :                                                                       */
/*             vparvath  Initial creation                                              */
/*   02/16/04  vlakaman  Included in the latest APIs                                   */
/*-------------------------------------------------------------------------------------*/

  FUNCTION GET_SR_CONTACTS(p_contact_id NUMBER)
           RETURN CS_SERVICEREQUEST_PUB.CONTACTS_TABLE IS

  -- cursor definitions
  CURSOR CUR_CONTACTS(p_contact_id NUMBER) IS
  SELECT acct_role.party_id party_id, C.contact_point_id,
         C.contact_point_type,C.primary_flag
  FROM hz_contact_points C,
       HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
  WHERE ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_contact_id
        and C.owner_table_name(+)='HZ_PARTIES'
        and C.contact_point_type(+)='PHONE'
        and C.status(+)='A'
        and C.primary_flag(+)='Y'
        and acct_role.party_id=C.owner_table_id(+) ;

  l_contacts_table           CS_ServiceRequest_PUB.contacts_table;
  i  NUMBER;

  -- Variables used in FND Log
  l_error_level  number   := FND_LOG.LEVEL_ERROR;
  l_mod_name     varchar2(2000) := 'csd.plsql.csd_om_interface_pvt.get_sr_contacts';

  BEGIN
       Debug( 'At the Beginning of GET_SR_CONTACTS',l_mod_name,1);

       i := 1;
       FOR ct_point_rec in CUR_CONTACTS(p_contact_id) LOOP
           Debug( 'In For Loop building the Contact table ',l_mod_name,1);
           If(ct_point_rec.contact_point_id is null) then
       	      l_contacts_table(i).party_id := ct_point_rec.party_id;
                l_contacts_table(i).primary_flag := 'Y';
      	      l_contacts_table(i).contact_type := 'PARTY_RELATIONSHIP';
           Else
                l_contacts_table(i).party_id := ct_point_rec.party_id;
      		 l_contacts_table(i).contact_point_id := ct_point_rec.contact_point_id;
      		 l_contacts_table(i).contact_point_type := ct_point_rec.contact_point_type;
      		 l_contacts_table(i).primary_flag := nvl(ct_point_rec.primary_flag,'N');
      		 l_contacts_table(i).contact_type := 'PARTY_RELATIONSHIP';
           End if;
	     i := i + 1;
       END LOOP;
	 return l_contacts_table;

  END GET_SR_CONTACTS;

END CSD_OM_INTERFACE_PVT;

/
